(*----------------------------------------------------------------------------*)
(*                  Copyright (c) 2004-2010 Antrey Zubarev                    *)
(*----------------------------------------------------------------------------*)
{
@author(Andrey Zubarev <zamtmn@yandex.ru>) 
}

unit uzccommaps;
{$INCLUDE zengineconfig.inc}
interface
uses

  uzctranslations,uzeentity,uzglviewareaabstract,uzgldrawcontext,
  uzeenttext,uzeentityfactory,uzcsysvars,uzbstrproc,
  uzcinterface,uzccommandsmanager,uzclog,
  uzccommandsabstract,uzccommandsimpl,uzbtypes,uzcdrawings,uzeutils,uzcutils,sysutils,
  varmandef,uzctnrVectorBytes,uzegeometry,uzeconsts,
  uzccomdraw,uzeentline,uzbpaths,uzeentblockinsert,
  uzegeometrytypes,varman,uzeentdevice,uzeentmtext,math,
  uzcentcable,UUnitManager,
  gzctnrVectorTypes,uzccomelectrical,URecordDescriptor,TypeDescriptors,uzcLog,
  gzctnrSTL,gutil,uzccmdfloatinsert;

const
  tabledy=-65.2763;
  tablerowh=-10;

type
  TMAPPoint=record
    Name:AnsiString;
    coord:GDBvertex;
    h:double;
  end;
  TIntersectedCom=record
    BlockName:AnsiString;
    TEXT:AnsiString;
    ground,h,t,t2:double;
  end;

  LessAnsiString=TLess<AnsiString>;
  LessDouble=TLess<double>;
  TIntersections=GKey2DataMapOld<double,TIntersectedCom,LessDouble>;
  TPointMap=GKey2DataMap<AnsiString,TMAPPoint{,LessAnsiString}>;
  {REGISTEROBJECTTYPE TProfileBuildCom}
  TProfileBuildCom= object(FloatInsert_com)
    PointMap:TPointMap;
    PlanScale,VertScale,HorScale:double;
    k:double;
    count:integer;
    summlength:double;
    procedure Command(Operands:TCommandOperands); virtual;
    procedure ProcessCommand(cmd:AnsiString);
    procedure BuildProfile(p1,p2:TMAPPoint);
    procedure DrawProfile(p1,p2:TMAPPoint;Intersections:TIntersections);
    function trans(tracex,tracey,dwgx,dwgy:double):GDBvertex;
    procedure drawdist(var t1:double; t2, FactTraceLength,TraceLength:double;DC:TDrawContext);
    procedure drawlevels(t,l1,l2,l3,FactTraceLength:double;DC:TDrawContext);
    procedure drawruler(p1:TMAPPoint;DC:TDrawContext);
  end;
var
   ProfileBuild_com:TProfileBuildCom;
implementation
function confirmed(var dt:DistAndt):boolean;
begin
  result:=false;
  if (dt.t<=(1+floateps))and(dt.t>=-floateps) then
  if dt.d<20 then begin
    result:=true;
    if (dt.t<=floateps)then dt.t:=0;
    if (dt.t>=(1-floateps))then dt.t:=1;
  end;
end;
function TProfileBuildCom.trans(tracex,tracey,dwgx,dwgy:double):GDBvertex;
begin
  result:=CreateVertex(tracex*k/HorScale+dwgx,tracey/VertScale+dwgy-300*count,0);
end;
procedure TProfileBuildCom.drawruler(p1:TMAPPoint;DC:TDrawContext);
var
   dh,h:double;
   pt:pGDBObjMText;
   pl:pgdbobjline;
   ts:TDXFEntsInternalStringType;
   i:integer;
begin
  h:=floor(p1.h);
  dh:=p1.h-h;
  for i:=1 downto -5 do begin
    str((h+i):0:0,ts);
    pt:=pointer(AllocEnt(GDBMtextID));
    pt^.init(@drawings.GetCurrentDWG.ConstructObjRoot,sysvar.dwg.DWG_CLayer^,sysvar.dwg.DWG_CLinew^,
    ts,
    trans(0,-dh+i,-25,0),2.5,0,0.65,0,jsmr,0,1);
    pt^.TXTStyleIndex:=pointer(drawings.GetCurrentDWG.GetTextStyleTable^.getDataMutable(0));
    drawings.GetCurrentDWG.ConstructObjRoot.ObjArray.AddPEntity(pt^);
    zcSetEntPropFromCurrentDrawingProp(pt);
    pt^.vp.Layer:=drawings.GetCurrentDWG.LayerTable.getAddres('TEXT');
    zcSetEntPropFromCurrentDrawingProp(pt);
    pt^.Formatentity(drawings.GetCurrentDWG^,dc);
    if ((abs(i) and 1)=1)and(i<>1) then begin
      pl:=pointer(AllocEnt(GDBLineID));
      pl^.init(@drawings.GetCurrentDWG.ConstructObjRoot,drawings.GetCurrentDWG.GetCurrentLayer,sysvar.dwg.DWG_CLinew^,
      trans(0,-dh+i,-23.5,0),trans(0,-dh+i+1,-23.5,0));
      drawings.GetCurrentDWG.ConstructObjRoot.ObjArray.AddPEntity(pl^);
      zcSetEntPropFromCurrentDrawingProp(pl);
      pl.vp.Color:=ClByLayer;
      pl.vp.LineWeight:=LnWt100;
      pl^.Formatentity(drawings.GetCurrentDWG^,dc);
    end;
  end;
  pl:=pointer(AllocEnt(GDBLineID));
  pl^.init(@drawings.GetCurrentDWG.ConstructObjRoot,drawings.GetCurrentDWG.GetCurrentLayer,sysvar.dwg.DWG_CLinew^,
  trans(0,-dh+1,-24,0),trans(0,-dh-5,-24,0));
  drawings.GetCurrentDWG.ConstructObjRoot.ObjArray.AddPEntity(pl^);
  zcSetEntPropFromCurrentDrawingProp(pl);
  pl.vp.Color:=ClByLayer;
  //pl.vp.LineWeight:=LnWt070;
  pl^.Formatentity(drawings.GetCurrentDWG^,dc);

  pl:=pointer(AllocEnt(GDBLineID));
  pl^.init(@drawings.GetCurrentDWG.ConstructObjRoot,drawings.GetCurrentDWG.GetCurrentLayer,sysvar.dwg.DWG_CLinew^,
  trans(0,-dh+1,-23,0),trans(0,-dh-5,-23,0));
  drawings.GetCurrentDWG.ConstructObjRoot.ObjArray.AddPEntity(pl^);
  zcSetEntPropFromCurrentDrawingProp(pl);
  pl.vp.Color:=ClByLayer;
  //pl.vp.LineWeight:=LnWt070;
  pl^.Formatentity(drawings.GetCurrentDWG^,dc);


end;

procedure TProfileBuildCom.drawdist(var t1:double; t2, FactTraceLength,TraceLength:double;DC:TDrawContext);
var
   temp,tx:double;
   ts:TDXFEntsInternalStringType;
   pt:pGDBObjMText;
begin
  tx:=(t2+t1)/2;
  temp:=(t2-t1)*TraceLength;

  str(temp:0:1,ts);
  pt:=pointer(AllocEnt(GDBMtextID));
  pt^.init(@drawings.GetCurrentDWG.ConstructObjRoot,sysvar.dwg.DWG_CLayer^,sysvar.dwg.DWG_CLinew^,
  ts,
  trans(tx*FactTraceLength,0,0,tabledy+3.5*tablerowh),2.5,0,0.65,0,jsmc,0,1);
  pt^.TXTStyleIndex:=pointer(drawings.GetCurrentDWG.GetTextStyleTable^.getDataMutable(0));
  drawings.GetCurrentDWG.ConstructObjRoot.ObjArray.AddPEntity(pt^);
  zcSetEntPropFromCurrentDrawingProp(pt);
  pt^.vp.Layer:=drawings.GetCurrentDWG.LayerTable.getAddres('TEXT');
  zcSetEntPropFromCurrentDrawingProp(pt);
  pt^.Formatentity(drawings.GetCurrentDWG^,dc);

  t1:=t2;

end;

procedure TProfileBuildCom.drawlevels(t,l1,l2,l3,FactTraceLength:double;DC:TDrawContext);
var
   pt:pGDBObjMText;
   ts:TDXFEntsInternalStringType;
begin
  str(l1:0:2,ts);
  pt:=pointer(AllocEnt(GDBMtextID));
  pt^.init(@drawings.GetCurrentDWG.ConstructObjRoot,sysvar.dwg.DWG_CLayer^,sysvar.dwg.DWG_CLinew^,
  ts,
  trans(t*FactTraceLength,0,0,tabledy+0.5*tablerowh),2.5,0,0.65,RightAngle,jsbc,0,1);
  pt^.TXTStyleIndex:=pointer(drawings.GetCurrentDWG.GetTextStyleTable^.getDataMutable(0));
  drawings.GetCurrentDWG.ConstructObjRoot.ObjArray.AddPEntity(pt^);
  zcSetEntPropFromCurrentDrawingProp(pt);
  pt^.vp.Layer:=drawings.GetCurrentDWG.LayerTable.getAddres('TEXT');
  zcSetEntPropFromCurrentDrawingProp(pt);
  pt^.Formatentity(drawings.GetCurrentDWG^,dc);

  str(l2:0:2,ts);
  pt:=pointer(AllocEnt(GDBMtextID));
  pt^.init(@drawings.GetCurrentDWG.ConstructObjRoot,sysvar.dwg.DWG_CLayer^,sysvar.dwg.DWG_CLinew^,
  ts,
  trans(t*FactTraceLength,0,0,tabledy+1.5*tablerowh),2.5,0,0.65,RightAngle,jsbc,0,1);
  pt^.TXTStyleIndex:=pointer(drawings.GetCurrentDWG.GetTextStyleTable^.getDataMutable(0));
  drawings.GetCurrentDWG.ConstructObjRoot.ObjArray.AddPEntity(pt^);
  zcSetEntPropFromCurrentDrawingProp(pt);
  pt^.vp.Layer:=drawings.GetCurrentDWG.LayerTable.getAddres('TEXT');
  zcSetEntPropFromCurrentDrawingProp(pt);
  pt^.Formatentity(drawings.GetCurrentDWG^,dc);

  str(l3:0:2,ts);
  pt:=pointer(AllocEnt(GDBMtextID));
  pt^.init(@drawings.GetCurrentDWG.ConstructObjRoot,sysvar.dwg.DWG_CLayer^,sysvar.dwg.DWG_CLinew^,
  ts,
  trans(t*FactTraceLength,0,0,tabledy+2.5*tablerowh),2.5,0,0.65,RightAngle,jsbc,0,1);
  pt^.TXTStyleIndex:=pointer(drawings.GetCurrentDWG.GetTextStyleTable^.getDataMutable(0));
  drawings.GetCurrentDWG.ConstructObjRoot.ObjArray.AddPEntity(pt^);
  zcSetEntPropFromCurrentDrawingProp(pt);
  pt^.vp.Layer:=drawings.GetCurrentDWG.LayerTable.getAddres('TEXT');
  zcSetEntPropFromCurrentDrawingProp(pt);
  pt^.Formatentity(drawings.GetCurrentDWG^,dc);

end;


procedure TProfileBuildCom.DrawProfile(p1,p2:TMAPPoint;Intersections:TIntersections);
var
  FactTraceLength,TraceLength,lastx,x:double;
  pv:PGDBObjBlockInsert;
  pl:pgdbobjline;
  pt:pGDBObjMText;
  iterator:TIntersections.TIterator;
  com:TIntersectedCom;
  DC:TDrawContext;
  i:integer;
begin
  drawings.GetCurrentDWG.wa.SetMouseMode((MGet3DPoint) or (MMoveCamera) or (MRotateCamera));
  dc:=drawings.GetCurrentDWG^.CreateDrawingRC;

  FactTraceLength:=Vertexlength(p1.coord,p2.coord)*PlanScale;
  TraceLength:=Trunc(FactTraceLength+1);
  summlength:=summlength+TraceLength+3;
  k:=TraceLength/FactTraceLength;

  drawings.AddBlockFromDBIfNeed(drawings.GetCurrentDWG,'profilestart');
  pointer(pv):=old_ENTF_CreateBlockInsert(@drawings.GetCurrentDWG.ConstructObjRoot,@drawings.GetCurrentDWG.ConstructObjRoot.ObjArray,
                                      drawings.GetCurrentDWG.GetCurrentLayer,drawings.GetCurrentDWG.GetCurrentLType,sysvar.DWG.DWG_CLinew^,sysvar.DWG.DWG_CColor^,
                                      trans(0,0,0,0), 1, 0,'profilestart');
  drawings.AddBlockFromDBIfNeed(drawings.GetCurrentDWG,'profileend');
  pointer(pv):=old_ENTF_CreateBlockInsert(@drawings.GetCurrentDWG.ConstructObjRoot,@drawings.GetCurrentDWG.ConstructObjRoot.ObjArray,
                                      drawings.GetCurrentDWG.GetCurrentLayer,drawings.GetCurrentDWG.GetCurrentLType,sysvar.DWG.DWG_CLinew^,sysvar.DWG.DWG_CColor^,
                                      trans(FactTraceLength,0,0,0), 1, 0,'profileend');
  zcSetEntPropFromCurrentDrawingProp(pv);

  pl:=pointer(AllocEnt(GDBLineID));
  pl^.init(@drawings.GetCurrentDWG.ConstructObjRoot,drawings.GetCurrentDWG.GetCurrentLayer,sysvar.dwg.DWG_CLinew^,
  trans(0,0,32.7588,-15),trans(FactTraceLength,0,-30.7881,-15));
  drawings.GetCurrentDWG.ConstructObjRoot.ObjArray.AddPEntity(pl^);
  zcSetEntPropFromCurrentDrawingProp(pl);
  pl.vp.Color:=ClByLayer;
  pl.vp.LineWeight:=LnWt070;
  pl^.Formatentity(drawings.GetCurrentDWG^,dc);

  pl:=pointer(AllocEnt(GDBLineID));
  pl^.init(@drawings.GetCurrentDWG.ConstructObjRoot,drawings.GetCurrentDWG.GetCurrentLayer,sysvar.dwg.DWG_CLinew^,
  trans(0,0,0,0),trans(FactTraceLength,0,0,0));
  drawings.GetCurrentDWG.ConstructObjRoot.ObjArray.AddPEntity(pl^);
  zcSetEntPropFromCurrentDrawingProp(pl);
  pl.vp.Color:=ClByLayer;
  pl.vp.LineWeight:=LnWt070;
  pl^.Formatentity(drawings.GetCurrentDWG^,dc);

  pl:=pointer(AllocEnt(GDBLineID));
  pl^.init(@drawings.GetCurrentDWG.ConstructObjRoot,drawings.GetCurrentDWG.GetCurrentLayer,sysvar.dwg.DWG_CLinew^,
  trans(0,0,0,-48.7690),trans(FactTraceLength,0,0,-48.7690));
  drawings.GetCurrentDWG.ConstructObjRoot.ObjArray.AddPEntity(pl^);
  zcSetEntPropFromCurrentDrawingProp(pl);
  pl.vp.Color:=ClByLayer;
  //pl.vp.LineWeight:=LnWt070;
  pl^.Formatentity(drawings.GetCurrentDWG^,dc);

  for i:=0 to 6 do begin
  pl:=pointer(AllocEnt(GDBLineID));
  pl^.init(@drawings.GetCurrentDWG.ConstructObjRoot,drawings.GetCurrentDWG.GetCurrentLayer,sysvar.dwg.DWG_CLinew^,
  trans(0,0,0,tabledy+i*tablerowh),trans(FactTraceLength,0,0,tabledy+i*tablerowh));
  drawings.GetCurrentDWG.ConstructObjRoot.ObjArray.AddPEntity(pl^);
  zcSetEntPropFromCurrentDrawingProp(pl);
  pl.vp.Color:=ClByLayer;
  //pl.vp.LineWeight:=LnWt070;
  pl^.Formatentity(drawings.GetCurrentDWG^,dc);
  end;

  if TraceLength>140 then x:=229.9767+420+209
                     else x:=229.9767+420;

  pt:=pointer(AllocEnt(GDBMtextID));
  pt^.init(@drawings.GetCurrentDWG.ConstructObjRoot,sysvar.dwg.DWG_CLayer^,sysvar.dwg.DWG_CLinew^,
  TDXFEntsInternalStringType(Tria_Utf8ToAnsi(sysutils.format('сумма бурения: %g',[summlength]))),
  trans(0,0,x+120,-202.0388),2.5,0,0.65,0,jsmc,70,1);
  pt^.TXTStyleIndex:=pointer(drawings.GetCurrentDWG.GetTextStyleTable^.getDataMutable(0));
  drawings.GetCurrentDWG.ConstructObjRoot.ObjArray.AddPEntity(pt^);
  zcSetEntPropFromCurrentDrawingProp(pt);
  pt^.vp.Layer:=drawings.GetCurrentDWG.LayerTable.getAddres('TEXT');
  zcSetEntPropFromCurrentDrawingProp(pt);
  pt^.Formatentity(drawings.GetCurrentDWG^,dc);

  pt:=pointer(AllocEnt(GDBMtextID));
  pt^.init(@drawings.GetCurrentDWG.ConstructObjRoot,sysvar.dwg.DWG_CLayer^,sysvar.dwg.DWG_CLinew^,
  TDXFEntsInternalStringType(Tria_Utf8ToAnsi(sysutils.format('Колодец %s - Колодец %s. Профиль скрытого перехода кабельной канализации',[p1.Name,p2.Name]))),
  trans(0,0,x,-202.0388),2.5,0,0.65,0,jsmc,70,1);
  pt^.TXTStyleIndex:=pointer(drawings.GetCurrentDWG.GetTextStyleTable^.getDataMutable(0));
  drawings.GetCurrentDWG.ConstructObjRoot.ObjArray.AddPEntity(pt^);
  zcSetEntPropFromCurrentDrawingProp(pt);
  pt^.vp.Layer:=drawings.GetCurrentDWG.LayerTable.getAddres('TEXT');
  zcSetEntPropFromCurrentDrawingProp(pt);
  pt^.Formatentity(drawings.GetCurrentDWG^,dc);

  pt:=pointer(AllocEnt(GDBMtextID));
  pt^.init(@drawings.GetCurrentDWG.ConstructObjRoot,sysvar.dwg.DWG_CLayer^,sysvar.dwg.DWG_CLinew^,
  TDXFEntsInternalStringType(Tria_Utf8ToAnsi(sysutils.format('Колодец %s - Колодец %s.\PПрофиль скрытого перехода кабельной канализации\PLперех.=%G м, Lбур.=%G м',[p1.Name,p2.Name,TraceLength,TraceLength+3]))),
  trans(FactTraceLength/2,0,0,30),2.5,0,0.65,0,jsbc,0,1);
  pt^.TXTStyleIndex:=pointer(drawings.GetCurrentDWG.GetTextStyleTable^.getDataMutable(0));
  drawings.GetCurrentDWG.ConstructObjRoot.ObjArray.AddPEntity(pt^);
  zcSetEntPropFromCurrentDrawingProp(pt);
  pt^.vp.Layer:=drawings.GetCurrentDWG.LayerTable.getAddres('TEXT');
  zcSetEntPropFromCurrentDrawingProp(pt);
  pt^.Formatentity(drawings.GetCurrentDWG^,dc);

  pt:=pointer(AllocEnt(GDBMtextID));
  pt^.init(@drawings.GetCurrentDWG.ConstructObjRoot,sysvar.dwg.DWG_CLayer^,sysvar.dwg.DWG_CLinew^,
  TDXFEntsInternalStringType(Tria_Utf8ToAnsi('Горизонтально-направленное бурение')),
  trans(FactTraceLength/2,0,0,tabledy+4.5*tablerowh),2.5,0,0.65,0,jsmc,0,1);
  pt^.TXTStyleIndex:=pointer(drawings.GetCurrentDWG.GetTextStyleTable^.getDataMutable(0));
  drawings.GetCurrentDWG.ConstructObjRoot.ObjArray.AddPEntity(pt^);
  zcSetEntPropFromCurrentDrawingProp(pt);
  pt^.vp.Layer:=drawings.GetCurrentDWG.LayerTable.getAddres('TEXT');
  zcSetEntPropFromCurrentDrawingProp(pt);
  pt^.Formatentity(drawings.GetCurrentDWG^,dc);

  pt:=pointer(AllocEnt(GDBMtextID));
  pt^.init(@drawings.GetCurrentDWG.ConstructObjRoot,sysvar.dwg.DWG_CLayer^,sysvar.dwg.DWG_CLinew^,
  TDXFEntsInternalStringType(Tria_Utf8ToAnsi('Установка ГНБ "Навигатор"; 1ПЭ80 SDR17')),
  trans(FactTraceLength/2,0,0,tabledy+5.5*tablerowh),2.5,0,0.65,0,jsmc,0,1);
  pt^.TXTStyleIndex:=pointer(drawings.GetCurrentDWG.GetTextStyleTable^.getDataMutable(0));
  drawings.GetCurrentDWG.ConstructObjRoot.ObjArray.AddPEntity(pt^);
  zcSetEntPropFromCurrentDrawingProp(pt);
  pt^.vp.Layer:=drawings.GetCurrentDWG.LayerTable.getAddres('TEXT');
  zcSetEntPropFromCurrentDrawingProp(pt);
  pt^.Formatentity(drawings.GetCurrentDWG^,dc);



  iterator:=Intersections.Min;
  if assigned(iterator) then
  begin
  repeat
    iterator.MutableValue^.ground:=p1.h+(p2.h-p1.h)*iterator.MutableValue^.t
  until (not iterator.Next);
  iterator.destroy;
  end;
  lastx:=1.5/FactTraceLength;
  iterator:=Intersections.Min;
  if assigned(iterator) then
  begin
  repeat
    com:=iterator.value;
    if length(com.blockname)>1 then
    if com.blockname[1]<>'@' then begin
     drawings.AddBlockFromDBIfNeed(drawings.GetCurrentDWG,com.blockname);
     pointer(pv):=old_ENTF_CreateBlockInsert(@drawings.GetCurrentDWG.ConstructObjRoot,@drawings.GetCurrentDWG.ConstructObjRoot.ObjArray,
                                         drawings.GetCurrentDWG.GetCurrentLayer,drawings.GetCurrentDWG.GetCurrentLType,sysvar.DWG.DWG_CLinew^,sysvar.DWG.DWG_CColor^,
                                         trans(com.t*FactTraceLength,com.h,0,0), 1, 0,@com.blockname[1]);

     pl:=pointer(AllocEnt(GDBLineID));
     pl^.init(@drawings.GetCurrentDWG.ConstructObjRoot,drawings.GetCurrentDWG.GetCurrentLayer,sysvar.dwg.DWG_CLinew^,
     trans(com.t*FactTraceLength,com.h,0,0),trans(com.t*FactTraceLength,0,0,tabledy+4*tablerowh));
     drawings.GetCurrentDWG.ConstructObjRoot.ObjArray.AddPEntity(pl^);
     zcSetEntPropFromCurrentDrawingProp(pl);
     pl.vp.Color:=ClByLayer;
     //pl.vp.LineWeight:=LnWt070;
     pl^.Formatentity(drawings.GetCurrentDWG^,dc);


     pt:=pointer(AllocEnt(GDBMtextID));
     pt^.init(@drawings.GetCurrentDWG.ConstructObjRoot,sysvar.dwg.DWG_CLayer^,sysvar.dwg.DWG_CLinew^,
     TDXFEntsInternalStringType(com.text),
     trans(com.t*FactTraceLength,com.h,4,0),2.5,0,0.65,0,jsbl,0,1);
     pt^.TXTStyleIndex:=pointer(drawings.GetCurrentDWG.GetTextStyleTable^.getDataMutable(0));
     drawings.GetCurrentDWG.ConstructObjRoot.ObjArray.AddPEntity(pt^);
     zcSetEntPropFromCurrentDrawingProp(pt);
     pt^.vp.Layer:=drawings.GetCurrentDWG.LayerTable.getAddres('TEXT');
     zcSetEntPropFromCurrentDrawingProp(pt);
     pt^.Formatentity(drawings.GetCurrentDWG^,dc);


     drawdist(lastx,com.t,FactTraceLength,TraceLength,DC);

     drawlevels(com.t,com.ground,1.5,com.ground-1.5,FactTraceLength,DC);

    end;
    if com.blockname='@@r' then begin
    pl:=pointer(AllocEnt(GDBLineID));
        pl^.init(@drawings.GetCurrentDWG.ConstructObjRoot,drawings.GetCurrentDWG.GetCurrentLayer,sysvar.dwg.DWG_CLinew^,
        trans(com.t*FactTraceLength,com.h,0,2),trans(com.t*FactTraceLength,0,0,tabledy+4*tablerowh));
        drawings.GetCurrentDWG.ConstructObjRoot.ObjArray.AddPEntity(pl^);
        zcSetEntPropFromCurrentDrawingProp(pl);
        pl.vp.Color:=ClByLayer;
        //pl.vp.LineWeight:=LnWt070;
        pl^.Formatentity(drawings.GetCurrentDWG^,dc);

        pl:=pointer(AllocEnt(GDBLineID));
        pl^.init(@drawings.GetCurrentDWG.ConstructObjRoot,drawings.GetCurrentDWG.GetCurrentLayer,sysvar.dwg.DWG_CLinew^,
        trans(com.t2*FactTraceLength,com.h,0,2),trans(com.t2*FactTraceLength,0,0,tabledy+4*tablerowh));
        drawings.GetCurrentDWG.ConstructObjRoot.ObjArray.AddPEntity(pl^);
        zcSetEntPropFromCurrentDrawingProp(pl);
        pl.vp.Color:=ClByLayer;
        //pl.vp.LineWeight:=LnWt070;
        pl^.Formatentity(drawings.GetCurrentDWG^,dc);

        pl:=pointer(AllocEnt(GDBLineID));
        pl^.init(@drawings.GetCurrentDWG.ConstructObjRoot,drawings.GetCurrentDWG.GetCurrentLayer,sysvar.dwg.DWG_CLinew^,
        trans(com.t*FactTraceLength,com.h,0,2),trans(com.t2*FactTraceLength,com.h,0,2));
        drawings.GetCurrentDWG.ConstructObjRoot.ObjArray.AddPEntity(pl^);
        zcSetEntPropFromCurrentDrawingProp(pl);
        pl.vp.Color:=ClByLayer;
        pl.vp.LineWeight:=LnWt070;
        pl^.Formatentity(drawings.GetCurrentDWG^,dc);

        pt:=pointer(AllocEnt(GDBMtextID));
        pt^.init(@drawings.GetCurrentDWG.ConstructObjRoot,sysvar.dwg.DWG_CLayer^,sysvar.dwg.DWG_CLinew^,
        TDXFEntsInternalStringType(Tria_Utf8ToAnsi('Дорога')),
        trans((com.t+com.t2)*FactTraceLength/2,com.h,0,3),2.5,0,0.65,0,jsbc,0,1);
        pt^.TXTStyleIndex:=pointer(drawings.GetCurrentDWG.GetTextStyleTable^.getDataMutable(0));
        drawings.GetCurrentDWG.ConstructObjRoot.ObjArray.AddPEntity(pt^);
        zcSetEntPropFromCurrentDrawingProp(pt);
        pt^.vp.Layer:=drawings.GetCurrentDWG.LayerTable.getAddres('TEXT');
        zcSetEntPropFromCurrentDrawingProp(pt);
        pt^.Formatentity(drawings.GetCurrentDWG^,dc);




        drawdist(lastx,com.t,FactTraceLength,TraceLength,DC);
        drawdist(lastx,com.t2,FactTraceLength,TraceLength,DC);

        drawlevels(com.t,com.ground,1.5,com.ground-1.5,FactTraceLength,DC);
        drawlevels(com.t2,com.ground,1.5,com.ground-1.5,FactTraceLength,DC);
    end;
  until (not iterator.Next);
  iterator.destroy;
  end;
  drawdist(lastx,(FactTraceLength-1.5)/FactTraceLength,FactTraceLength,TraceLength,DC);
  drawlevels(0,p1.h,0.85,p1.h-0.85,FactTraceLength,DC);
  drawlevels(1,p2.h,0.85,p2.h-0.85,FactTraceLength,DC);

  drawruler(p1,dc);

  inc(count);

end;

procedure TProfileBuildCom.BuildProfile(p1,p2:TMAPPoint);
var
  temp:double;
  ptextent:PGDBObjText;
  ir:itrec;
  dt,dt2,dtt:DistAndt;
  Intersections:TIntersections;
  com:TIntersectedCom;
  blockname,hstr,comparamstr:string;
  p1h,p2h:boolean;
begin
  Intersections:=TIntersections.Create;
  p1h:=false;
  p2h:=False;
  ptextent:=drawings.GetCurrentROOT^.ObjArray.beginiterate(ir);
  if ptextent<>nil then
  repeat
    if ptextent.GetObjType=GDBLineID then begin
      dt:=distance2ray(PGDBObjLine(ptextent).CoordInWCS.lBegin,p1.coord,p2.coord);
      dt2:=distance2ray(PGDBObjLine(ptextent).CoordInWCS.lEnd,p1.coord,p2.coord);
      if confirmed(dt) and confirmed(dt2) then begin
        if dt.t>dt2.t then begin
          dtt:=dt2;dt2:=dt;dt:=dtt;
        end;
        com.BlockName:='@@r';
        com.h:=0;
        com.t2:=dt2.t;
        com.t:=dt.t;
        Intersections.RegisterKey(com.t,com);
      end;
    end;
    if (ptextent.GetObjType=GDBMTextID)or(ptextent.GetObjType=GDBTextID) then begin
      if not ptextent^.selected then
       if length(ptextent^.Content)>1 then
        if ptextent^.Content[1]<>'*' then begin
//          if ptextent^.Content[1]='^' then
//                                          dt:=dt;
          dt:=distance2ray(ptextent^.P_insert_in_WCS,p1.coord,p2.coord);
          if confirmed(dt) then begin
           if TryStrToFloat(string(ptextent^.Content),temp) then begin
             com.BlockName:='@@h';
             com.h:=temp;
             com.t2:=0;
             com.t:=dt.t;
             if com.t=0 then begin p1.h:=com.h;p1h:=true end
        else if com.t=1 then begin p2.h:=com.h;p2h:=true end
        else Intersections.RegisterKey(com.t,com);
           end
      else if ptextent^.Content[1]='^' then begin
             comparamstr:=string(system.copy(ptextent^.Content,2,length(ptextent^.Content)-1));
             GetPartOfPath(blockname,comparamstr,';');
             GetPartOfPath(hstr,comparamstr,';');
             com.BlockName:=readspace(blockname);
             com.TEXT:=comparamstr;
             TryStrToFloat(hstr,com.h);
             com.t2:=0;
             com.t:=dt.t;
             Intersections.RegisterKey(com.t,com);

          end;
        end;
     end;
   end;
   ptextent:=drawings.GetCurrentROOT^.ObjArray.iterate(ir);
  until ptextent=nil;
  if not p1h then ZCMsgCallBackInterface.TextMessage('Start h not deffined',TMWOHistoryOut);
  if not p2h then ZCMsgCallBackInterface.TextMessage('End h not deffined',TMWOHistoryOut);
  DrawProfile(p1,p2,Intersections);
  Intersections.Free;
end;

procedure TProfileBuildCom.ProcessCommand(cmd:AnsiString);
var
  i:integer;
  operand:AnsiString;
  p1,p2:TMAPPoint;
procedure getoperand(position,len:integer);
begin
  operand:=system.copy(cmd,position+2,length(cmd)-len-1);
  cmd:=system.copy(cmd,1,position-1);
end;

begin
  ZCMsgCallBackInterface.TextMessage(format('ProfileBuild: process "%s" command',[cmd]),TMWOHistoryOut);
  i:=pos(':=',cmd);
  if i<>0 then begin
    getoperand(i,2);
    cmd:=uppercase(cmd);
    if cmd='VERTSCALE' then TryStrToFloat(operand,VertScale)
else if cmd='PLANSCALE' then TryStrToFloat(operand,PlanScale)
else if cmd='HORSCALE' then TryStrToFloat(operand,HorScale);
    exit;
  end;
  i:=pos('->',cmd);
  if i<>0 then begin
    getoperand(i,2);
    if not PointMap.MyGetValue(cmd,p1) then begin
      ZCMsgCallBackInterface.TextMessage(format('ProfileBuild: point "%s" not found',[cmd]),TMWOHistoryOut);
      exit;
    end;
    if not PointMap.MyGetValue(operand,p2) then begin
      ZCMsgCallBackInterface.TextMessage(format('ProfileBuild: point "%s" not found',[operand]),TMWOHistoryOut);
      exit;
    end;
    BuildProfile(p1,p2);
  end;
end;

procedure TProfileBuildCom.Command(Operands:TCommandOperands);
var
   ptextent:PGDBObjText;
   ir:itrec;
   commandtext,cmd,pointname:String;
   p:TMAPPoint;
begin
  count:=0;
  summlength:=0;
  PointMap:=TPointMap.create;
  commandtext:='';
  ptextent:=drawings.GetCurrentROOT^.ObjArray.beginiterate(ir);
  if ptextent<>nil then
  repeat
    if (ptextent.GetObjType=GDBMTextID)or(ptextent.GetObjType=GDBTextID) then begin
      if ptextent^.selected then
        commandtext:=commandtext+string(ptextent^.Content)
    else begin
      if length(ptextent^.Content)>1 then
        if ptextent^.Content[1]='*' then begin
          pointname:=string(system.copy(ptextent^.Content,2,length(ptextent^.Content)-1));
          if PointMap.MyContans(pointname) then
            ZCMsgCallBackInterface.TextMessage(format('ProfileBuild: point "%s" already exists',[pointname]),TMWOHistoryOut)
          else begin
            p.Name:=pointname;
            p.coord:=ptextent^.P_insert_in_WCS;
            PointMap.RegisterKey(pointname,p);
            ZCMsgCallBackInterface.TextMessage(format('ProfileBuild: point "%s" found',[pointname]),TMWOHistoryOut)
          end;
        end;
    end;
   end;
   ptextent:=drawings.GetCurrentROOT^.ObjArray.iterate(ir);
  until ptextent=nil;
  repeat
    GetPartOfPath(cmd,commandtext,';');
    cmd:=readspace(cmd);
    if cmd<>'' then
      ProcessCommand(cmd);
  until commandtext='';

  freeandnil(PointMap);
end;
procedure startup;
begin
  ProfileBuild_com.init('ProfileBuild',CADWG{CADWG тут можно опустить, он автоматом будет добавлен в FloatInsert_com},0);
end;
procedure finalize;
begin
end;
initialization
  startup;
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
  finalize;
end.
