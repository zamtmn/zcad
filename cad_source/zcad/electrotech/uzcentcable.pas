(*----------------------------------------------------------------------------*)
(*                  Copyright (c) 2004-2010 Antrey Zubarev                    *)
(*----------------------------------------------------------------------------*)
{
@author(Andrey Zubarev <zamtmn@yandex.ru>) 
}   
unit uzcentcable;
{$INCLUDE def.inc}

interface
uses uzeobjectextender,varman,uzgldrawcontext,uzeentgenericsubentry,uzedrawingdef,
     uzcsysvars,UGDBOpenArrayOfByte,uzestyleslayers,UUnitManager,uzeentcurve,uzegeometry,
     math,gzctnrvectordata,uzbtypesbase,uzeentity,varmandef,uzbtypes,
     uzbgeomtypes,uzeconsts,uzeffdxfsupport,sysutils,uzbmemman,uzeentsubordinated,uzeentdevice,
     gzctnrvectortypes,uzcenitiesvariablesextender,uzeentityfactory,uzclog,LazLogger;
type
{Повторное описание типа в Cableы}
  PTCableType=^TCableType;
  TCableType=(
               TCT_Unknown(*'Не определен'*),
               TCT_ShleifOPS(*'ШлейфОПС'*),
               TCT_Control(*'Контрольный'*),
               TCT_Sila(*'Силовой'*)
              );
{Export+}

PTNodeProp=^TNodeProp;
{REGISTERRECORDTYPE TNodeProp}
TNodeProp=record
                //**Точка в котором кабель был усечен устройством исчез и появился
                PrevP,NextP:GDBVertex;
                //**Устройство коннектор которого попадает в узел кабеля
                DevLink:PGDBObjDevice;
          end;
{REGISTEROBJECTTYPE TNodePropArray}
TNodePropArray= object(GZVectorData{-}<TNodeProp>{//})
end;

PGDBObjCable=^GDBObjCable;
{REGISTEROBJECTTYPE GDBObjCable}
GDBObjCable= object(GDBObjCurve)
                 {**Список устройств DevLink коннектор которых попадает в узел кабеля,
                    а так же показывается PrevP,NextP точка в котором кабель был усечен устройством
                    и точка в которой появился**}
                 NodePropArray:TNodePropArray;(*hidden_in_objinsp*)
                 str11:GDBVertex;(*hidden_in_objinsp*)
                 str12:GDBVertex;(*hidden_in_objinsp*)
                 str13:GDBVertex;(*hidden_in_objinsp*)
                 str21:GDBVertex;(*hidden_in_objinsp*)
                 str22:GDBVertex;(*hidden_in_objinsp*)
                 str23:GDBVertex;(*hidden_in_objinsp*)
                 constructor init(own:GDBPointer;layeraddres:PGDBLayerProp;LW:GDBSmallint);
                 constructor initnul(owner:PGDBObjGenericWithSubordinated);
                 procedure DrawGeometry(lw:GDBInteger;var DC:TDrawContext{infrustumactualy:TActulity;subrender:GDBInteger});virtual;
                 function GetObjTypeName:GDBString;virtual;
                 procedure FormatEntity(var drawing:TDrawingDef;var DC:TDrawContext);virtual;
                 procedure FormatFast(var drawing:TDrawingDef;var DC:TDrawContext);virtual;
                 procedure SaveToDXFObjXData(var outhandle:{GDBInteger}GDBOpenArrayOfByte;var IODXFContext:TIODXFContext);virtual;
                 procedure SaveToDXF(var outhandle:{GDBInteger}GDBOpenArrayOfByte;var drawing:TDrawingDef;var IODXFContext:TIODXFContext);virtual;
                 procedure SaveToDXFfollow(var outhandle:{GDBInteger}GDBOpenArrayOfByte;var drawing:TDrawingDef;var IODXFContext:TIODXFContext);virtual;

                 function Clone(own:GDBPointer):PGDBObjEntity;virtual;

                 destructor done;virtual;
                 class function GetDXFIOFeatures:TDXFEntIODataManager;static;

                 //function Clone(own:GDBPointer):PGDBObjEntity;virtual;
                 function GetObjType:TObjID;virtual;
           end;
{Export-}
function AllocCable:PGDBObjCable;
var
    GDBObjCableDXFFeatures:TDXFEntIODataManager;
implementation
function GDBObjCable.Clone;
var tvo: PGDBObjCable;
    i:GDBInteger;
    p:pgdbvertex;
begin
  //result:=inherited Clone(own);
  //exit;
  GDBGetMem({$IFDEF DEBUGBUILD}'{F9D41F4A-1E80-4D3A-9DD1-D0037EFCA988}',{$ENDIF}GDBPointer(tvo), sizeof(GDBObjCable));
  tvo^.init(bp.ListPos.owner,vp.Layer, vp.LineWeight);
  //tvo^.vp:=vp;
  //tvo^.GetObjType :=GDBCableID;
  CopyVPto(tvo^);
  p:=vertexarrayinocs.GetParrayAsPointer;
  for i:=0 to VertexArrayInOCS.Count-1 do
  begin
      tvo^.vertexarrayinocs.PushBackData(p^);
      inc(p)
  end;
  result := tvo;
  EntExtensions.RunOnCloneProcedures(@self,tvo);
  //PTObjectUnit(ou.Instance)^.CopyTo(PTObjectUnit(tvo.ou.Instance));
end;
procedure GDBObjCable.SaveToDXFFollow;
var
    //ptv:pgdbvertex;
    ir_inNodeArray:itrec;
    ptn1,ptn2:PTNodeProp;
    pl:PGDBLayerProp;
begin
  pl:=vp.Layer;
  vp.Layer:=drawing.GetLayerTable^.{gdb.GetCurrentDWG.LayerTable.}getAddres('SYS_METRIC');
  inherited;
  vp.Layer:=pl;
  ptn2:=NodePropArray.beginiterate(ir_inNodeArray);
  ptn1:=NodePropArray.iterate(ir_inNodeArray);
  if ptn1<>nil then
  begin
  repeat
        SaveToDXFObjPrefix(outhandle,'LINE','AcDbLine',IODXFContext,true);
        dxfvertexout(outhandle,10,ptn2^.Nextp);
        dxfvertexout(outhandle,11,ptn1^.PrevP);

         dxfGDBStringout(outhandle,1001,ZCADAppNameInDXF);
         dxfGDBStringout(outhandle,1002,'{');
         dxfGDBStringout(outhandle,1000,'_OWNERHANDLE=6E');
         //self.SaveToDXFObjXData(handle);
         dxfGDBStringout(outhandle,1002,'}');


        ptn2:=ptn1;
        ptn1:=NodePropArray.iterate(ir_inNodeArray);
  until ptn1=nil;
  end;
end;
procedure GDBObjCable.SaveToDXFObjXData(var outhandle:{GDBInteger}GDBOpenArrayOfByte;var IODXFContext:TIODXFContext);
//var
   //s:gdbstring;
begin
     inherited;
     dxfGDBStringout(outhandle,1000,'_UPGRADE=1');
     dxfGDBStringout(outhandle,1000,'_LAYER='+vp.Layer.name);
end;
procedure GDBObjCable.SaveToDXF;
var
    //ptv:pgdbvertex;
    //ir:itrec;
    pl:PGDBLayerProp;
begin
  pl:=vp.Layer;
  vp.Layer:=drawing.GetLayerTable^.{gdb.GetCurrentDWG.LayerTable.}getAddres('SYS_METRIC');

  SaveToDXFObjPrefix(outhandle,'POLYLINE','AcDb3dPolyline',IODXFContext);
  dxfGDBIntegerout(outhandle,66,1);
  dxfvertexout(outhandle,10,uzegeometry.NulVertex);
  dxfGDBIntegerout(outhandle,70,8);

  vp.Layer:=pl;
end;
procedure GDBObjCable.FormatFast;
var
   ptvnext:pgdbvertex;
   ir_inVertexArray:itrec;
   np:TNodeProp;
begin
     np.DevLink:=nil;
     inherited FormatEntity(drawing,dc);
     NodePropArray.clear;
     ptvnext:=vertexarrayInWCS.beginiterate(ir_inVertexArray);
     if ptvnext<>nil then
     repeat
           np.NextP:=ptvnext^;
           np.PrevP:=ptvnext^;
           ptvnext:=vertexarrayInWCS.iterate(ir_inVertexArray);
           NodePropArray.PushBackData(np);
     until ptvnext=nil;
end;

procedure GDBObjCable.FormatEntity(var drawing:TDrawingDef;var DC:TDrawContext);
var ir_inGDB,ir_inVertexArray,ir_inNodeArray,ir_inDevice,ir_inDevice2:itrec;
    currentobj,CurrentSubObj,CurrentSubObj2,ptd:PGDBObjDevice;
    devpoint,{cabpoint,}tp,tp2,tp3,{_XWCS,}_YWCS,_ZWCS:GDBVertex;
    ptv,ptvpred,ptvnext:pgdbvertex;
    ptn,{ptnfirst,ptnfirst2,}ptnlast,ptnlast2:PTNodeProp;
    tn:TNodeProp;
    psldb:pointer;
    I3DPPrev,I3DPNext,I3DP:Intercept3DProp;
    m,rotmatr:DMatrix4D;
    pvd,{pvd2,}pvds,pvdal,pvdrt:pvardesk;
    {group,pribor,}count:gdbinteger;
    l:gdbdouble;
    pentvarext,pentvarextcirrobj:TVariablesExtender;
begin
  inherited;
  if assigned(EntExtensions)then
    EntExtensions.RunOnBeforeEntityFormat(@self,drawing);
  calcbb(dc);
  psldb:=drawing.GetLayerTable^.{gdb.GetCurrentDWG.LayerTable.}getAddres('SYS_DEVICE_BORDER');

  //CreateDeviceNameProcess(@self);

  {pvd:=ou.FindVariable('GC_HeadDevice');
  group:=pgdbinteger(pvd^.data.Instance)^;
  pvd:=ou.FindVariable('GC_HDGroup');
  pribor:=pgdbinteger(pvd^.data.Instance)^;}


  //pvd:=ou.FindVariable('Cable_Length');
  //pvds:=ou.FindVariable('LENGTH_Scale');
  //pvdal:=ou.FindVariable('LENGTH_Add');
  //pgdbdouble(pvd^.data.Instance)^:=length*pgdbdouble(pvds^.data.Instance)^+pgdbdouble(pvdal^.data.Instance)^;
  ptv:=vertexarrayInWCS.beginiterate(ir_inVertexArray);
  NodePropArray.clear;
  if ptv<>nil then
  begin
       repeat
             //if ptn<>nil then
                             begin
                                  tn.DevLink:=nil;
                                  tn.PrevP:=ptv^;
                                  tn.NextP:=ptv^;
                                  NodePropArray.PushBackData(tn)

                             end;
             ptv:=vertexarrayInWCS.iterate(ir_inVertexArray);
       until ptv=nil;
  end;
  //ptnfirst:=NodePropArray.getelement(0);
  //ptnlast:=NodePropArray.getelement(vertexarrayInWCS.Count-1);
  CurrentObj:=PGDBObjGenericSubEntry(drawing.GetCurrentRootSimple)^.{gdb.GetCurrentROOT.}ObjArray.beginiterate(ir_inGDB);
  if (CurrentObj<>nil) then
     repeat
           if (CurrentObj<>@self)and(CurrentObj^.GetObjType=GDBDeviceID) then
           begin
                if boundingintersect(vp.BoundingBox,CurrentObj^.vp.BoundingBox)
                   and true{CurrentObj^.GetDeviceType=DT_Connector} then
                begin
                     CurrentSubObj:=CurrentObj^.VarObjArray.beginiterate(ir_inDevice);
                     if (CurrentSubObj<>nil) then
                     repeat
                           if (CurrentSubObj^.GetObjType=GDBDeviceID) then
                           begin
                           if CurrentSubObj^.BlockDesc.BType=BT_Connector then
                           begin
                           devpoint:=CurrentSubObj^.P_insert_in_WCS;
                           ptv:=vertexarrayInWCS.beginiterate(ir_inVertexArray);
                           ptvpred:=nil;
                           ptvnext:=vertexarrayInWCS.iterate(ir_inVertexArray);
                           ptn:=NodePropArray.beginiterate(ir_inNodeArray);
                           if ptv<>nil then
                           begin
                                repeat
                                      if SqrVertexlength(ptv^,devpoint)<sqreps then
                                                                                   begin
                                                                                        ptn^.DevLink:=CurrentSubObj;
                                                                                        if CurrentSubObj.BlockDesc.BBorder<>BB_Empty then
                                                                                        begin
                                                                                        I3DPPrev.t1:=Infinity;
                                                                                        I3DPPrev.isintercept:=false;
                                                                                        I3DPNext.t1:=NegInfinity;
                                                                                        I3DPNext.isintercept:=false;
                                                                                        ptd:=CurrentSubObj;
                                                                                        if CurrentSubObj.BlockDesc.BBorder=BB_owner then
                                                                                                                               CurrentSubObj:=pointer(CurrentSubObj^.bp.ListPos.Owner);
                                                                                        CurrentSubObj2:=CurrentSubObj^.VarObjArray.beginiterate(ir_inDevice2);
                                                                                        if (CurrentSubObj2<>nil) then
                                                                                        repeat
                                                                                            begin
                                                                                              if CurrentSubObj2^.GetLayer=psldb then
                                                                                              if ptn<>nil then
                                                                                              begin
                                                                                                   if ptvpred<>nil then
                                                                                                      begin
                                                                                                      I3DP:=CurrentSubObj2^.IsIntersect_Line(ptvpred^,ptv^);
                                                                                                      if I3DP.isintercept then
                                                                                                        begin
                                                                                                             if I3DP.t1<I3DPPrev.t1 then
                                                                                                                                        begin
                                                                                                                                             I3DPPrev:=I3DP;
                                                                                                                                             ptn.PrevP:=I3DP.interceptcoord;
                                                                                                                                        end;

                                                                                                        end;
                                                                                                      end;
                                                                                                      if ptvnext<>nil then
                                                                                                      begin
                                                                                                      I3DP:=CurrentSubObj2^.IsIntersect_Line(ptv^,ptvnext^);
                                                                                                      if I3DP.isintercept then
                                                                                                        begin
                                                                                                             if I3DP.t1>I3DPNext.t1 then
                                                                                                                                        begin
                                                                                                                                             I3DPNext:=I3DP;
                                                                                                                                             ptn.NextP:=I3DP.interceptcoord;
                                                                                                                                        end;

                                                                                                        end;
                                                                                                      end;
                                                                                              end;
                                                                                            end;
                                                                                            CurrentSubObj2:=CurrentSubObj^.VarObjArray.iterate(ir_inDevice2);
                                                                                        until CurrentSubObj2=nil;
                                                                                        CurrentSubObj:=ptd;
                                                                                        end;
                                                                                   end;


                                      ptvpred:=ptv;
                                      ptv:=ptvnext;
                                      ptvnext:=vertexarrayInWCS.iterate(ir_inVertexArray);
                                      ptn:=NodePropArray.iterate(ir_inNodeArray);
                                until ptv=nil;
                           end;
                           end;
                           end;
                           CurrentSubObj:=CurrentObj^.VarObjArray.iterate(ir_inDevice);
                     until CurrentSubObj=nil;

                end;

           end;
           CurrentObj:=PGDBObjGenericSubEntry(drawing.GetCurrentRootSimple)^.{gdb.GetCurrentROOT.}ObjArray.iterate(ir_inGDB);
     until CurrentObj=nil;


  GetDXFIOFeatures.RunFormatProcs(drawing,@self);
  //CreateCableNameProcess(@self,drawing);


  l:=0;
  if vertexarrayInWCS.Count>1 then
  begin
    count:=0;
    ptn:=NodePropArray.beginiterate(ir_inNodeArray);
    if ptn<>nil then
                repeat
                    if ptn^.DevLink<>nil then
                    begin
                    CurrentObj:=pointer(ptn^.DevLink^.bp.ListPos.owner);
                    pentvarextcirrobj:=CurrentObj^.GetExtension<TVariablesExtender>;
                    {pvd:=CurrentObj.ou.FindVariable('OPS_Pribor');
                    if pvd<>nil then
                    pgdbinteger(pvd^.data.Instance)^:=group;
                    pvd:=CurrentObj.ou.FindVariable('OPS_GroupInPribor');
                    if pvd<>nil then
                    pgdbinteger(pvd^.data.Instance)^:=pribor;
                    pvd:=CurrentObj.ou.FindVariable('OPS_NumberInSleif');
                    if pvd<>nil then
                    begin
                    inc(count);
                    pgdbinteger(pvd^.data.Instance)^:=count;
                    end;}
                    pvd:=pentvarextcirrobj.entityunit.FindVariable('EL_Cab_AddLength');
                    if pvd<>nil then
                                    begin
                                         l:=l+pgdbdouble(pvd^.data.Instance)^;
                                    end;
                    inc(count);
                    CurrentObj^.FormatEntity(drawing,dc);
                    CurrentObj^.getoutbound(dc);
                    CurrentObj^.calcbb(dc);
                    end;

                    ptn:=NodePropArray.iterate(ir_inNodeArray);
                until ptn=nil;
  pentvarext:=self.GetExtension<TVariablesExtender>;
  pvd:=pentvarext.entityunit.FindVariable('CABLE_TotalCD');
  if pvd<>nil then
                                  pgdbinteger(pvd^.data.Instance)^:=count;
  pvd:=pentvarext.entityunit.FindVariable('AmountD');
  pvds:=pentvarext.entityunit.FindVariable('LENGTH_Scale');
  pvdal:=pentvarext.entityunit.FindVariable('LENGTH_Add');
  pvdrt:=pentvarext.entityunit.FindVariable('LENGTH_RoundTo');
  if pvds<>nil then
  if pgdbdouble(pvds^.data.Instance)^>0 then
                                             begin
                                             if (pvd<>nil)and(pvds<>nil)and(pvdal<>nil){and(pvdrt<>nil)} then
                                             pgdbdouble(pvd^.data.Instance)^:={roundto(}length*pgdbdouble(pvds^.data.Instance)^+pgdbdouble(pvdal^.data.Instance)^+l{,pgdbinteger(pvdrt^.data.Instance)^)};
                                             pvds:=pentvarext.entityunit.FindVariable('LENGTH_KReserve');
                                             if pvds<>nil then
                                                              pgdbdouble(pvd^.data.Instance)^:=pgdbdouble(pvd^.data.Instance)^*pgdbdouble(pvds^.data.Instance)^;
                                             if (pvdrt<>nil) then
                                                              pgdbdouble(pvd^.data.Instance)^:=roundto(pgdbdouble(pvd^.data.Instance)^,pgdbinteger(pvdrt^.data.Instance)^);

                                             end
                                         else
                                             begin
                                             if (pvd<>nil)and(pvds<>nil) then
                                             pgdbdouble(pvd^.data.Instance)^:=-pgdbdouble(pvds^.data.Instance)^;
                                             end;


  ptnlast:=NodePropArray.getDataMutable(vertexarrayInWCS.Count-1);
  ptnlast2:=NodePropArray.getDataMutable(vertexarrayInWCS.Count-2);

  tp:=vertexsub(ptnlast^.PrevP,ptnlast2^.NextP);
  if uzegeometry.SqrOneVertexlength(tp)>sqreps then
  begin
  _YWCS:=YWCS;//gdb.GetCurrentDWG.pcamera.ydir;
  _ZWCS:=ZWCS;//gdb.GetCurrentDWG.pcamera.look;

  if (abs (tp.x) < 1/64) and (abs (tp.y) < 1/64) then
                                                     tp2:=CrossVertex(_YWCS,tp)
                                                 else
                                                     tp2:=CrossVertex(_ZWCS,tp);
  tp3:=CrossVertex(tp2,tp);
  //tp3:=uzegeometry.VertexMulOnSc(tp3,-1);
  tp3:=NormalizeVertex(tp3);
  tp2:=NormalizeVertex(tp2);
  tp:=NormalizeVertex(tp);

   rotmatr:=onematrix;
   PGDBVertex(@rotmatr[0])^:=tp;
   PGDBVertex(@rotmatr[1])^:=tp2;
   PGDBVertex(@rotmatr[2])^:=tp3;

   m:=onematrix;
   PGDBVertex(@m[3])^:=ptnlast.PrevP;

   m:=MatrixMultiply(rotmatr,m);

  str22:=ptnlast.PrevP;
  str21:=VectorTransform3D(uzegeometry.CreateVertex(-3*SysVar.DSGN.DSGN_HelpScale^,0.5*SysVar.DSGN.DSGN_HelpScale^,0),m);
  str23:=VectorTransform3D(uzegeometry.CreateVertex(-3*SysVar.DSGN.DSGN_HelpScale^,-0.5*SysVar.DSGN.DSGN_HelpScale^,0),m);
  end
  else begin
            str22:=ptnlast.PrevP;
            str21:=ptnlast.PrevP;
            str23:=ptnlast.PrevP;
       end;
  end;
  NodePropArray.Shrink;
end;
function GDBObjCable.GetObjTypeName;
begin
     result:=ObjN_GDBObjCable;
end;
constructor GDBObjCable.init;
//var
   //pvd:pvardesk;
begin
  inherited init(own,layeraddres, lw);
  NodePropArray.init({$IFDEF DEBUGBUILD}'{28ED5BF5-7598-4903-A715-C525BC68C116}',{$ENDIF}1000{,sizeof(TNodeProp)});
  //vp.ID := GDBCableID;
  //PTObjectUnit(self.ou.Instance)^.init('cable');
  GetDXFIOFeatures.AddExtendersToEntity(@self);
end;
constructor GDBObjCable.initnul;
begin
  inherited initnul(owner);
  NodePropArray.init({$IFDEF DEBUGBUILD}'{28ED5BF5-7598-4903-A715-C525BC68C116}',{$ENDIF}1000{,sizeof(TNodeProp)});
  //vp.id := GDBCableID;
  GetDXFIOFeatures.AddExtendersToEntity(@self);
  //OU.done;
  //OU.init('cable');
end;
function GDBObjCable.GetObjType;
begin
     result:=GDBCableID;
end;
destructor GDBObjCable.done;
begin
     inherited done;
     NodePropArray.Clear;
     NodePropArray.Done;
end;

procedure GDBObjCable.DrawGeometry;
var
   ptn1,ptn2:PTNodeProp;
   ir_inNodeArray:itrec;
begin
  ptn2:=NodePropArray.beginiterate(ir_inNodeArray);
  ptn1:=NodePropArray.iterate(ir_inNodeArray);
  if ptn1<>nil then
  begin
  repeat
        DC.Drawer.DrawLine3DInModelSpace(ptn2^.Nextp,ptn1^.PrevP,DC.DrawingContext.matrixs);
        ptn2:=ptn1;
        ptn1:=NodePropArray.iterate(ir_inNodeArray);
  until ptn1=nil;
  end;
  if SysVar.DWG.DWG_HelpGeometryDraw^ then
  if CanSimplyDrawInWCS(DC,SysVar.DSGN.DSGN_HelpScale^,1) then
  begin
  {notfirst:=false;
  ptn2:=NodePropArray.beginiterate(ir_inNodeArray);
  ptn1:=NodePropArray.iterate(ir_inNodeArray);
  if ptn1<>nil then
  begin
  repeat
        if ptn2^.DevLink<>nil then
        begin
        if ptn1<>nil then
        begin
        //oglsm.mytotalglend;
        oglsm.myglpushmatrix;
        oglsm.mygltranslated(ptn2^.Nextp.x+dc.pcamera^.CamCSOffset.x,ptn2^.Nextp.y+dc.pcamera^.CamCSOffset.y,ptn2^.Nextp.z+dc.pcamera^.CamCSOffset.z);
        oglsm.myglScalef(SysVar.DSGN.DSGN_HelpScale^,SysVar.DSGN.DSGN_HelpScale^,SysVar.DSGN.DSGN_HelpScale^);
        circlepointoflod[8].drawgeometry;
        //oglsm.mytotalglend;
        oglsm.myglpopmatrix;
        end;
        if notfirst then
        begin
        //oglsm.mytotalglend;
        oglsm.myglpushmatrix;
        oglsm.mygltranslated(ptn2^.Prevp.x+dc.pcamera^.CamCSOffset.x,ptn2^.Prevp.y+dc.pcamera^.CamCSOffset.y,ptn2^.Prevp.z+dc.pcamera^.CamCSOffset.z);
        oglsm.myglScalef(SysVar.DSGN.DSGN_HelpScale^,SysVar.DSGN.DSGN_HelpScale^,SysVar.DSGN.DSGN_HelpScale^);
        circlepointoflod[8].drawgeometry;
        //oglsm.mytotalglend;
        oglsm.myglpopmatrix;
        end
           else notfirst:=true;
        end
           else notfirst:=true;
        ptn2:=ptn1;
        ptn1:=NodePropArray.iterate(ir_inNodeArray);
  until ptn2=nil;
  end;}
  if vertexarrayInWCS.Count>1 then
  begin
       dc.drawer.DrawLine3DInModelSpace(str21,str22,dc.DrawingContext.matrixs);
       dc.drawer.DrawLine3DInModelSpace(str22,str23,dc.DrawingContext.matrixs);
  end;
  end;
  //inherited;
  drawbb(dc);
end;
function AllocCable:PGDBObjCable;
begin
  GDBGetMem({$IFDEF DEBUGBUILD}'{AllocCable}',{$ENDIF}result,sizeof(GDBObjCable));
end;
function AllocAndInitCable(owner:PGDBObjGenericWithSubordinated):PGDBObjCable;
begin
  result:=AllocCable;
  result.initnul(owner);
  result.bp.ListPos.Owner:=owner;
end;
function Upgrade3DPolyline2Cable(ptu:PExtensionData;pent:PGDBObjCurve;const drawing:TDrawingDef):PGDBObjCable;
var
    ptv:pgdbvertex;
    ir:itrec;
begin
     result:=nil;
     result:=AllocAndInitCable(pent^.bp.ListPos.Owner);
     if pent^.PExtAttrib<>nil then
     begin
       result^.PExtAttrib:=pent^.PExtAttrib;
       pent^.PExtAttrib:=nil;
     end;
     //result^.vp:=pent^.vp;
     pent.CopyVPto(result^);
     //result^.vp.id:=GDBCableID;

     ptv:=pent^.vertexarrayinocs.beginiterate(ir);
     if ptv<>nil then
     repeat
        result^.AddVertex(ptv^);
        ptv:=pent^.vertexarrayinocs.iterate(ir);
     until ptv=nil;
end;
class function GDBObjCable.GetDXFIOFeatures:TDXFEntIODataManager;
begin
  result:=GDBObjCableDXFFeatures;
end;
initialization
  RegisterEntity(GDBCableID,'Cable',@AllocCable,@AllocAndInitCable);
  RegisterEntityUpgradeInfo(GDBPolylineID,1,@Upgrade3DPolyline2Cable);
  GDBObjCableDXFFeatures:=TDXFEntIODataManager.Create;
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
  GDBObjCableDXFFeatures.Destroy
end.
