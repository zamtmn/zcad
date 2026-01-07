{
*****************************************************************************
*                                                                           *
*  This file is part of the ZCAD                                            *
*                                                                           *
*  See the file COPYING.txt, included in this distribution,                 *
*  for details about the copyright.                                         *
*                                                                           *
*  This program is distributed in the hope that it will be useful,          *
*  but WITHOUT ANY WARRANTY; without even the implied warranty of           *
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                     *
*                                                                           *
*****************************************************************************
}
{
@author(Andrey Zubarev <zamtmn@yandex.ru>) 
}
{$MODE OBJFPC}{$H+}
unit uzccommand_NumDevices;
{$INCLUDE zengineconfig.inc}

interface
uses
  gzctnrVectorTypes,
  uzcstrconsts,
  uzeenttext,
  uzccommandsabstract,
  
  uzccommandsmanager,
  uzccommandsimpl,
  uzbtypes,uzbBaseUtils,
  uzcdrawings,
  sysutils,
  uzcinterface,
  uzeconsts,
  uzeentity,
  uzeentmtext,
  uzeentblockinsert,
  Varman, varmandef,
  uzcLog,
  uzccomdraw,UGDBSelectedObjArray,uzeentdevice,uzgldrawcontext,
  uzegeometrytypes,uzegeometry,uzeentwithlocalcs,garrayutils,
  uzcenitiesvariablesextender,uzbstrproc,gzctnrSTL,Generics.Collections,
  zUndoCmdChgTypes,zUndoCmdChgVariable,uzcutils,uzcdrawing;
type
  TAlgoType=(AT_Area,AT_Perimetr);
  PTPerimetrNumberingParam=^TPerimetrNumberingParam;
  TPerimetrNumberingParam=record
    StartAngle:Double;
    Clockwise:Boolean;
  end;


  TST=(
       TST_YX,//Y-X
       TST_XY,//X-Y
       TST_UNSORTED//Unsorted
      );
  PTAreaNumberingParam=^TAreaNumberingParam;
  TAreaNumberingParam=record
    SortMode:TST;//Sorting
    InverseX:Boolean;//Inverse X axis dir
    InverseY:Boolean;//verse Y axis dir
    DeadDandX:Double;//DeadbandX
    DeadDandY:Double;//DeadbandY
  end;


  PTNumberingParams=^TNumberingParams;
  TNumberingParams=record
                     AlgoType:TAlgoType;
                     AlgoParams:THardTypedData;
                     OnlyDevices:Boolean;
                     StartNumber:Integer;//Start
                     Increment:Integer;//Increment
                     SaveStart:Boolean;//Save start number
                     BaseName:AnsiString;//Base name sorting devices
                     MetricVariable:AnsiString;//Metric variable
                     NumberVar:AnsiString;//Number variable
               end;
  Number_com= object(CommandRTEdObject)
                         procedure CommandStart(const Context:TZCADCommandContext;Operands:TCommandOperands); virtual;
                         procedure ShowMenu;virtual;
                         procedure Run(pdata:PtrInt); virtual;
                         procedure FormatAfterFielfmod(PField,PTypeDescriptor:Pointer);virtual;
             end;
  TMetrixDictionary=specialize TMyMapGen<string,devcoordarray>;
  TMetrixwithData=record
    Metrix:string;
    Devs:devcoordarray;
  end;
  TMetrixVector=specialize TMyVector<TMetrixwithData>;
  TMetrixLess=class
    class function c(a,b:TMetrixwithData):boolean;
  end;
  TMetrixVectorSort=specialize TOrderingArrayUtils<TMetrixVector,TMetrixwithData,TMetrixLess>;

  PTDevCoordwithAngle=^TDevCoordwithAngle;
  TDevCoordwithAngle=record
    DevCoord:tdevcoord;
    Angle:double;
  end;
  TDevCoordwithAngleVector=specialize TMyVector<TDevCoordwithAngle>;
  TDevCoordwithAngleLess=class
    class function c(a,b:TDevCoordwithAngle):boolean;
  end;
  TDevCoordwithAngleSort=specialize TOrderingArrayUtils<TDevCoordwithAngleVector,TDevCoordwithAngle,TDevCoordwithAngleLess>;

var
   NumberCom:Number_com;
   NumberingParams:TNumberingParams;
   AreaParam:TAreaNumberingParam;
   PerimetrParam:TPerimetrNumberingParam;
implementation
class function TDevCoordwithAngleLess.c(a,b:TDevCoordwithAngle):boolean;
begin
  result:=a.Angle<b.Angle;
end;

class function TMetrixLess.c(a,b:TMetrixwithData):boolean;
begin
  result:=AnsiNaturalCompare(a.Metrix,b.Metrix)<0;
end;

procedure Number_com.FormatAfterFielfmod(PField,PTypeDescriptor:Pointer);
begin
  case NumberingParams.AlgoType of
    AT_Area:begin
      NumberingParams.AlgoParams.Instance:=@AreaParam;
      NumberingParams.AlgoParams.PTD:=SysUnit^.TypeName2PTD('PTAreaNumberingParam');
    end;
    AT_Perimetr:begin
      NumberingParams.AlgoParams.Instance:=@PerimetrParam;
      NumberingParams.AlgoParams.PTD:=SysUnit^.TypeName2PTD('PTPerimetrNumberingParam');
    end;
  end;
end;

procedure Number_com.CommandStart(const Context:TZCADCommandContext;Operands:TCommandOperands);
begin
  self.savemousemode:=drawings.GetCurrentDWG^.wa.param.md.mode;
  if drawings.GetCurrentDWG^.SelObjArray.Count>0 then
  begin
       showmenu;
       inherited CommandStart(context,'');
  end
  else
  begin
    zcUI.TextMessage(rscmSelEntBeforeComm,TMWOHistoryOut);
    Commandmanager.executecommandend;
  end;
end;
procedure Number_com.ShowMenu;
begin
  commandmanager.DMAddMethod(rscmNumber,'Number selected devices',@run);
  commandmanager.DMShow;
end;

function IsHavePoint(pent:PGDBObjEntity;out pt:TzePoint3d):boolean;
begin
  if IsObjectIt(TypeOf(pent^),typeof(GDBObjWithLocalCS)) then
    pt:=PGDBObjWithLocalCS(pent)^.P_insert_in_WCS
  else
    pt:=(pent^.vp.BoundingBox.LBN+pent^.vp.BoundingBox.RTF)/2;
  result:=true;
end;

procedure FillMetrixDictionary(var md:TMetrixDictionary);
var
  psd:PSelectedObjDesc;
  pt:TzePoint3d;
  pent:PGDBObjEntity;
  ir:itrec;
  pvd:pvardesk;
  pdevvarext:TVariablesExtender;
  metric:string;
  pmpd:^devcoordarray;
  mpd:devcoordarray;
  process:boolean;
begin
  psd:=drawings.GetCurrentDWG^.SelObjArray.beginiterate(ir);
  if psd<>nil then
  repeat
    if (not NumberingParams.OnlyDevices)or(psd^.objaddr^.GetObjType=GDBDeviceID) then
      if IsHavePoint(psd^.objaddr,pt) then begin
        pent:=pointer(psd^.objaddr);
        pdevvarext:=pent^.specialize GetExtension<TVariablesExtender>;
        if pdevvarext<>nil then begin
          if NumberingParams.BaseName<>'' then begin
            pvd:=pdevvarext.entityunit.FindVariable('NMO_BaseName');
            if pvd<>nil then begin
              if uppercase(pvd^.data.PTD^.GetUserValueAsString(pvd^.data.Addr.Instance))=
                 uppercase({Tria_AnsiToUtf8}(NumberingParams.BaseName)) then
                process:=true
              else begin
                process:=false;
                zcUI.TextMessage('Device with basename "'+pvd^.data.PTD^.GetUserValueAsString(pvd^.data.Addr.Instance)+'" filtred out',TMWOHistoryOut);
              end;
            end
              else begin
                process:=true;
                zcUI.TextMessage('In device not found BaseName variable. Processed',TMWOHistoryOut);
              end;
          end else
            process:=true;

          if process then begin
            pvd:=pdevvarext.entityunit.FindVariable(NumberingParams.NumberVar);
            if pvd<>nil then begin
              pvd:=pdevvarext.entityunit.FindVariable(NumberingParams.MetricVariable);
              if pvd=nil then
                metric:=''
              else
                metric:=pvd^.GetValueAsString;

              if md.tryGetMutableValue(metric,pmpd) then begin
                pmpd^.PushBack(tdevcoord.CreateRec(pt,pointer(pent)));
              end else begin
                mpd:=devcoordarray.Create;
                mpd.PushBack(tdevcoord.CreateRec(pt,pointer(pent)));
                md.Add(metric,mpd);
              end;
            end else
              zcUI.TextMessage('In device not found numbering variable, filtred out',TMWOHistoryOut);
          end;
        end else
          zcUI.TextMessage('In device not found VariablesExtender, filtred out',TMWOHistoryOut);
      end;
    psd:=drawings.GetCurrentDWG^.SelObjArray.iterate(ir);
  until psd=nil;
end;

procedure AreaSort(mpd:devcoordarray);
  function ProcessCoord(const coord:TzePoint3d):TzePoint3d;
  begin
    case AreaParam.SortMode of
      TST_YX,TST_UNSORTED:begin
        result:=coord;
      end;
      TST_XY:begin
        result.x:=coord.y;
        result.y:=coord.x;
        result.z:=coord.z;
      end;
    end;{case}
    if AreaParam.InverseX then
      result.x:=-result.x;
    if AreaParam.InverseY then
      result.y:=-result.y;
  end;
var
  i:integer;
  pdc:^tdevcoord;
begin
  if AreaParam.SortMode<>TST_UNSORTED then begin
    for i:=0 to mpd.Size-1 do begin
      pdc:=mpd.Mutable[i];
      pdc^.coord:=ProcessCoord(pdc^.coord);
    end;
    TGDBVertexLess.deadbandX:=AreaParam.DeadDandX;
    TGDBVertexLess.deadbandY:=AreaParam.DeadDandY;
    devcoordsort.Sort(mpd,mpd.Size);
  end;
end;

procedure PerimetrSort(mpd:devcoordarray);
var
  i:integer;
  CenterPoint:TzePoint3d;
  dcwa:TDevCoordwithAngleVector;
  sav:TzePoint3d;
  a,aa:double;
begin
  CenterPoint:=NulVertex;
  for i:=0 to mpd.Size-1 do
    CenterPoint:=CenterPoint+mpd.Mutable[i]^.coord;
  CenterPoint:=CenterPoint/mpd.Size;
  aa:=PerimetrParam.StartAngle*pi/180;
  dcwa:=TDevCoordwithAngleVector.Create;
  dcwa.Resize(mpd.Size);
  for i:=0 to mpd.Size-1 do
    with dcwa.Mutable[i]^ do begin
      DevCoord:=mpd[i];
      sav:=(DevCoord.coord-CenterPoint).NormalizeVertex;
      a:=uzegeometry.TwoVectorAngle(_X_yzVertex,sav);
      if sav.y<-eps then
        a:=2*pi-a;
      a:=a-aa;
      if a<-eps then
        a:=2*pi+a;
      if PerimetrParam.Clockwise then
        a:=-a;
      angle:=a;
      a:=angle*180/pi;
    end;
  TDevCoordwithAngleSort.Sort(dcwa,dcwa.Size);
  for i:=0 to mpd.Size-1 do
    mpd.Mutable[i]^:=dcwa.Mutable[i]^.DevCoord;
end;

procedure Number_com.Run(pdata:PtrInt);
var
  index,i:integer;
  count:integer;
  md:TMetrixDictionary;
  mv:TMetrixVector;
  MWD:TMetrixWithData;
  pair:TMetrixDictionary.TDictionaryPair;
  DC:TDrawContext;
  dcoord:tdevcoord;
  pdev:PGDBObjDevice;
  pdevvarext:TVariablesExtender;
  pvd:pvardesk;
  UndoStartMarkerPlaced:boolean;
  cp:UCmdChgVariable;
begin
  md:=TMetrixDictionary.Create;
  FillMetrixDictionary(md);
  count:=0;
  UndoStartMarkerPlaced:=false;

  if md.Count=0 then begin
    zcUI.TextMessage('In selection not found devices',TMWOHistoryOut);
    md.Destroy;
    Commandmanager.executecommandend;
    exit;
  end;

  dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
  count:=0;


  mv:=TMetrixVector.Create;
  mv.Resize(md.Count);
  i:=0;
  for pair in md do begin
    with mv.Mutable[i]^ do begin
      Metrix:=pair.Key;
      Devs:=pair.Value;
    end;
    inc(i);
  end;

  TMetrixVectorSort.Sort(mv,mv.Size);

  for MWD in mv do begin
    index:=NumberingParams.StartNumber;

    if NumberingParams.AlgoType=AT_Area then
      AreaSort(MWD.Devs)
    else
      PerimetrSort(MWD.Devs);

    for i:=0 to MWD.Devs.Size-1 do begin
      dcoord:=MWD.Devs[i];
      pdev:=dcoord.pdev;
      pointer(pdevvarext):=pdev^.specialize GetExtension<TVariablesExtender>;

      pvd:=pdevvarext.entityunit.FindVariable(NumberingParams.NumberVar);
      if pvd<>nil then begin
        zcPlaceUndoStartMarkerIfNeed(UndoStartMarkerPlaced,'NumDevices');
        cp:=UCmdChgVariable.CreateAndPush(PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack,
                                          TChangedVariableDesc.CreateRec(pvd^.data.PTD,pvd^.data.Addr.GetInstance,NumberingParams.NumberVar),
                                          TSharedPEntityData.CreateRec(pdev),
                                          TAfterChangePDrawing.CreateRec(drawings.GetCurrentDWG));
        //cp.ChangedData.StoreUndoData(pvd^.data.Addr.GetInstance);
        pvd^.data.PTD^.SetValueFromString(pvd^.data.Addr.Instance,inttostr(index));
        //cp.ChangedData.StoreDoData(pvd^.data.Addr.GetInstance);
        inc(index,NumberingParams.Increment);
        inc(count);
        pdev^.FormatEntity(drawings.GetCurrentDWG^,dc);
      end
    end;

    if NumberingParams.SaveStart then
      NumberingParams.StartNumber:=index;
  end;
  zcPlaceUndoEndMarkerIfNeed(UndoStartMarkerPlaced);

  zcUI.TextMessage(sysutils.format(rscmNEntitiesProcessed,[count]),TMWOHistoryOut);
  for pair in md do begin
    pair.Value.Destroy;
  end;
  md.Destroy;
  mv.Destroy;
  Commandmanager.executecommandend;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  if SysUnit<>nil then begin
    SysUnit^.RegisterType(TypeInfo(TAlgoType));
    SysUnit^.RegisterType(TypeInfo(TPerimetrNumberingParam));
    SysUnit^.SetTypeDesk(TypeInfo(TPerimetrNumberingParam),['StartAngle','Clockwise']);
    SysUnit^.RegisterType(TypeInfo(PTPerimetrNumberingParam));

    SysUnit^.RegisterType(TypeInfo(TST));
    SysUnit^.SetTypeDesk(TypeInfo(TST),['Y-X','X-Y','Unsorted']);

    SysUnit^.RegisterType(TypeInfo(TAreaNumberingParam));
    SysUnit^.SetTypeDesk(TypeInfo(TAreaNumberingParam),['Sorting','Inverse X axis dir','Inverse Y axis dir','Deadband X','Deadband Y']);
    SysUnit^.RegisterType(TypeInfo(PTAreaNumberingParam));

    SysUnit^.RegisterType(TypeInfo(TAlgoType));
    SysUnit^.SetTypeDesk(TypeInfo(TAlgoType),['Area','Perimetral']);


    SysUnit^.RegisterType(TypeInfo(TNumberingParams));
    SysUnit^.SetTypeDesk(TypeInfo(TNumberingParams),['AlgoType','AlgoParams','Only devices','Start',
                                                     'Increment','Save start number','Base name sorting devices','Metric variable','Number variable']);
    SysUnit^.RegisterType(TypeInfo(PTNumberingParams));
    NumberingParams.AlgoParams.PTD:=SysUnit^.TypeName2PTD('PTAreaNumberingParam');
  end;
  NumberingParams.AlgoParams.Instance:=@AreaParam;


  NumberingParams.AlgoType:=AT_Area;

  NumberingParams.OnlyDevices:=True;
  NumberingParams.BaseName:='??';
  NumberingParams.Increment:=1;
  NumberingParams.StartNumber:=1;
  NumberingParams.SaveStart:=false;
  AreaParam.DeadDandX:=3;
  AreaParam.DeadDandY:=3;
  AreaParam.InverseX:=false;
  AreaParam.InverseY:=true;
  AreaParam.SortMode:=TST_YX;

  PerimetrParam.Clockwise:=false;
  PerimetrParam.StartAngle:=90;

  NumberingParams.MetricVariable:='GC_HeadDevice';
  NumberingParams.NumberVar:='NMO_Suffix';
  NumberCom.init('NumDevices',CADWG,0);
  NumberCom.SetCommandParam(@NumberingParams,'PTNumberingParams');
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
