(*----------------------------------------------------------------------------*)
(*                  Copyright (c) 2004-2010 Antrey Zubarev                    *)
(*----------------------------------------------------------------------------*)
{
@author(Andrey Zubarev <zamtmn@yandex.ru>) 
}   
unit uzcentcable;
{$INCLUDE zengineconfig.inc}

interface
uses
  uzeobjectextender,varman,uzgldrawcontext,uzeentgenericsubentry,uzedrawingdef,
  uzcsysvars,uzctnrVectorBytesStream,uzestyleslayers,UUnitManager,uzeentcurve,
  uzegeometry,math,gzctnrVector,uzeentity,uzsbVarmanDef,uzeTypes,
  uzegeometrytypes,uzeconsts,uzeffdxfsupport,sysutils,uzeentsubordinated,
  uzeentdevice,gzctnrVectorTypes,uzcenitiesvariablesextender,uzeentityfactory,
  uzcLog,uzeblockdef;
type
{Повторное описание типа в Cableы}
  PTCableType=^TCableType;
  TCableType=(
               TCT_Unknown(*'Не определен'*),
               TCT_ShleifOPS(*'ШлейфОПС'*),
               TCT_Control(*'Контрольный'*),
               TCT_Sila(*'Силовой'*)
              );
PTNodeProp=^TNodeProp;
TNodeProp=record
                //**Точка в котором кабель был усечен устройством исчез и появился
                PrevP,NextP:TzePoint3d;
                //**Устройство коннектор которого попадает в узел кабеля
                DevLink:PGDBObjDevice;
          end;
TNodePropArray= object(GZVector<TNodeProp>)
end;

PGDBObjCable=^GDBObjCable;
GDBObjCable= object(GDBObjCurve)
                 {**Список устройств DevLink коннектор которых попадает в узел кабеля,
                    а так же показывается PrevP,NextP точка в котором кабель был усечен устройством
                    и точка в которой появился**}
                 NodePropArray:TNodePropArray;(*hidden_in_objinsp*)
                 str11:TzePoint3d;
                 str12:TzePoint3d;
                 str13:TzePoint3d;
                 str21:TzePoint3d;
                 str22:TzePoint3d;
                 str23:TzePoint3d;
                 constructor init(own:Pointer;layeraddres:PGDBLayerProp;LW:SmallInt);
                 constructor initnul(owner:PGDBObjGenericWithSubordinated);
                 procedure DrawGeometry(lw:Integer;var DC:TDrawContext;const inFrustumState:TInBoundingVolume);virtual;
                 function GetObjTypeName:String;virtual;
                 procedure FormatEntity(var drawing:TDrawingDef;var DC:TDrawContext;Stage:TEFStages=EFAllStages);virtual;
                 procedure FormatFast(var drawing:TDrawingDef;var DC:TDrawContext);virtual;
                 procedure SaveToDXFObjXData(var outStream:TZctnrVectorBytes;var IODXFContext:TIODXFSaveContext);virtual;
                 procedure SaveToDXF(var outStream:TZctnrVectorBytes;var drawing:TDrawingDef;var IODXFContext:TIODXFSaveContext);virtual;
                 procedure SaveToDXFfollow(var outStream:TZctnrVectorBytes;var drawing:TDrawingDef;var IODXFContext:TIODXFSaveContext);virtual;

                 function Clone(own:Pointer):PGDBObjEntity;virtual;

                 destructor done;virtual;
                 class function GetDXFIOFeatures:TDXFEntIODataManager;static;

                 //function Clone(own:Pointer):PGDBObjEntity;virtual;
                 function GetObjType:TObjID;virtual;
           end;
function AllocCable:PGDBObjCable;
var
    GDBObjCableDXFFeatures:TDXFEntIODataManager;
implementation
function GDBObjCable.Clone;
var tvo: PGDBObjCable;
    i:Integer;
    p:PzePoint3d;
begin
  //result:=inherited Clone(own);
  //exit;
  Getmem(Pointer(tvo), sizeof(GDBObjCable));
  tvo^.init(bp.ListPos.owner,vp.Layer, vp.LineWeight);
  //tvo^.vp:=vp;
  //tvo^.GetObjType :=GDBCableID;
  CopyVPto(tvo^);
  CopyExtensionsTo(tvo^);
  p:=vertexarrayinocs.GetParrayAsPointer;
  for i:=0 to VertexArrayInOCS.Count-1 do
  begin
      tvo^.vertexarrayinocs.PushBackData(p^);
      inc(p)
  end;
  result := tvo;
  EntExtensions.RunOnCloneProcedures(@self,tvo);
  //PTEntityUnit(ou.Instance)^.CopyTo(PTEntityUnit(tvo.ou.Instance));
end;
procedure GDBObjCable.SaveToDXFFollow;
var
    //ptv:PzePoint3d;
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
        SaveToDXFObjPrefix(outStream,'LINE','AcDbLine',IODXFContext,true);
        dxfvertexout(outStream,10,ptn2^.Nextp);
        dxfvertexout(outStream,11,ptn1^.PrevP);

         dxfStringout(outStream,1001,ZCADAppNameInDXF);
         dxfStringout(outStream,1002,'{');
         dxfStringout(outStream,1000,'_OWNERHANDLE=6E');
         //self.SaveToDXFObjXData(handle);
         dxfStringout(outStream,1002,'}');


        ptn2:=ptn1;
        ptn1:=NodePropArray.iterate(ir_inNodeArray);
  until ptn1=nil;
  end;
end;
procedure GDBObjCable.SaveToDXFObjXData(var outStream:TZctnrVectorBytes;var IODXFContext:TIODXFSaveContext);
//var
   //s:String;
begin
     inherited;
     dxfStringout(outStream,1000,'_HANDLE='+inttohex(GetHandle,10));
     dxfStringout(outStream,1000,'_UPGRADE=1');
     dxfStringout(outStream,1000,'_LAYER='+vp.Layer.name);
end;
procedure GDBObjCable.SaveToDXF;
var
    //ptv:PzePoint3d;
    //ir:itrec;
    pl:PGDBLayerProp;
begin
  pl:=vp.Layer;
  vp.Layer:=drawing.GetLayerTable^.{gdb.GetCurrentDWG.LayerTable.}getAddres('SYS_METRIC');

  SaveToDXFObjPrefix(outStream,'POLYLINE','AcDb3dPolyline',IODXFContext);
  dxfIntegerout(outStream,66,1);
  dxfvertexout(outStream,10,uzegeometry.NulVertex);
  dxfIntegerout(outStream,70,8);

  vp.Layer:=pl;
end;
procedure GDBObjCable.FormatFast;
var
   ptvnext,ptvprev:PzePoint3d;
   ir_inVertexArray:itrec;
   np:TNodeProp;
begin
     np.DevLink:=nil;
     inherited FormatEntity(drawing,dc);
     Representation.Clear;
     NodePropArray.clear;
     ptvprev:=vertexarrayInWCS.beginiterate(ir_inVertexArray);
     ptvnext:=vertexarrayInWCS.iterate(ir_inVertexArray);
     if (ptvnext<>nil)and(ptvprev<>nil) then
     repeat
           np.NextP:=ptvnext^;
           np.PrevP:=ptvprev^;
           Representation.DrawLineWithLT(self,getmatrix^,DC,np.NextP,np.PrevP,vp);
           ptvprev:=ptvnext;
           ptvnext:=vertexarrayInWCS.iterate(ir_inVertexArray);
           NodePropArray.PushBackData(np);
     until ptvnext=nil;

     {ptn2:=NodePropArray.beginiterate(ir_inNodeArray);
     ptn1:=NodePropArray.iterate(ir_inNodeArray);
     if ptn1<>nil then
     begin
     repeat
       Representation.DrawLineWithLT(DC,ptn2^.Nextp,ptn1^.PrevP,vp);
       //DC.Drawer.DrawLine3DInModelSpace(ptn2^.Nextp,ptn1^.PrevP,DC.DrawingContext.matrixs);
       ptn2:=ptn1;
       ptn1:=NodePropArray.iterate(ir_inNodeArray);
     until ptn1=nil;
     end;}

end;

procedure GDBObjCable.FormatEntity(var drawing:TDrawingDef;var DC:TDrawContext;Stage:TEFStages=EFAllStages);
var ir_inGDB,ir_inVertexArray,ir_inNodeArray,ir_inDevice,ir_inDevice2:itrec;
    currentobj,CurrentSubObj,CurrentSubObj2,ptd:PGDBObjDevice;
    devpoint,{cabpoint,}tp,tp2,tp3,{_XWCS,}_YWCS,_ZWCS:TzePoint3d;
    ptv,ptvpred,ptvnext,ptlast,ptpred:PzePoint3d;
    ptn,{ptnfirst,ptnfirst2,}ptnlastCutted,ptnlast2Cutted:PTNodeProp;
    tn:TNodeProp;
    psldb:pointer;
    I3DPPrev,I3DPNext,I3DP:Intercept3DProp;
    m,rotmatr:TzeTypedMatrix4d;
    pvd,{pvd2,}pvds,pvdal,pvdrt:pvardesk;
    {group,pribor,}count:Integer;
    l:Double;
    pentvarext,pentvarextcirrobj:TVariablesExtender;

    ptn1,ptn2:PTNodeProp;
begin
  inherited;
  if assigned(EntExtensions)then
    EntExtensions.RunOnBeforeEntityFormat(@self,drawing,DC);
  calcbb(dc);
  psldb:=drawing.GetLayerTable^.{gdb.GetCurrentDWG.LayerTable.}getAddres('SYS_DEVICE_BORDER');

  //CreateDeviceNameProcess(@self);

  {pvd:=ou.FindVariable('GC_HeadDevice');
  group:=PInteger(pvd^.Instance)^;
  pvd:=ou.FindVariable('GC_HDGroup');
  pribor:=PInteger(pvd^.Instance)^;}


  //pvd:=ou.FindVariable('Cable_Length');
  //pvds:=ou.FindVariable('LENGTH_Scale');
  //pvdal:=ou.FindVariable('LENGTH_Add');
  //pDouble(pvd^.Instance)^:=length*pDouble(pvds^.Instance)^+pDouble(pvdal^.Instance)^;
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
  //ptnlastCutted:=NodePropArray.getelement(vertexarrayInWCS.Count-1);
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
                                                                                                             if (I3DP.t1>0-bigeps)and(I3DP.t1<I3DPPrev.t1) then
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
                                                                                                             if (I3DP.t1<1+bigeps)and(I3DP.t1>I3DPNext.t1) then
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
                    PInteger(pvd^.Instance)^:=group;
                    pvd:=CurrentObj.ou.FindVariable('OPS_GroupInPribor');
                    if pvd<>nil then
                    PInteger(pvd^.Instance)^:=pribor;
                    pvd:=CurrentObj.ou.FindVariable('OPS_NumberInSleif');
                    if pvd<>nil then
                    begin
                    inc(count);
                    PInteger(pvd^.Instance)^:=count;
                    end;}
                    pvd:=pentvarextcirrobj.entityunit.FindVariable('EL_Cab_AddLength');
                    if pvd<>nil then
                                    begin
                                         l:=l+pDouble(pvd^.data.Addr.Instance)^;
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
                                  PInteger(pvd^.data.Addr.Instance)^:=count;
  pvd:=pentvarext.entityunit.FindVariable('AmountD');
  pvds:=pentvarext.entityunit.FindVariable('LENGTH_Scale');
  pvdal:=pentvarext.entityunit.FindVariable('LENGTH_Add');
  pvdrt:=pentvarext.entityunit.FindVariable('LENGTH_RoundTo');
  if pvds<>nil then
  if pDouble(pvds^.data.Addr.Instance)^>0 then
                                             begin
                                             if (pvd<>nil)and(pvds<>nil)and(pvdal<>nil){and(pvdrt<>nil)} then
                                             pDouble(pvd^.data.Addr.Instance)^:={roundto(}length*pDouble(pvds^.data.Addr.Instance)^+pDouble(pvdal^.data.Addr.Instance)^+l{,PInteger(pvdrt^.Instance)^)};
                                             pvds:=pentvarext.entityunit.FindVariable('LENGTH_KReserve');
                                             if pvds<>nil then
                                                              pDouble(pvd^.data.Addr.Instance)^:=pDouble(pvd^.data.Addr.Instance)^*pDouble(pvds^.data.Addr.Instance)^;
                                             if (pvdrt<>nil) then
                                                              pDouble(pvd^.data.Addr.Instance)^:=roundto(pDouble(pvd^.data.Addr.Instance)^,PInteger(pvdrt^.data.Addr.Instance)^);

                                             end
                                         else
                                             begin
                                             if (pvd<>nil)and(pvds<>nil) then
                                             pDouble(pvd^.data.Addr.Instance)^:=-pDouble(pvds^.data.Addr.Instance)^;
                                             end;


  ptnlastCutted:=NodePropArray.getDataMutable(vertexarrayInWCS.Count-1);
  ptnlast2Cutted:=NodePropArray.getDataMutable(vertexarrayInWCS.Count-2);

  ptlast:=VertexArrayInWCS.getDataMutable(vertexarrayInWCS.Count-1);
  ptpred:=VertexArrayInWCS.getDataMutable(vertexarrayInWCS.Count-2);

  tp:=vertexsub(ptlast^,ptpred^);
  if uzegeometry.SqrOneVertexlength(tp)>sqreps then
  begin
  _YWCS:=YWCS;//gdb.GetCurrentDWG.pcamera.ydir;
  _ZWCS:=ZWCS;//gdb.GetCurrentDWG.pcamera.look;

  if (abs (tp.x) < 1/64) and (abs (tp.y) < 1/64) then
                                                     tp2:=VectorDot(_YWCS,tp)
                                                 else
                                                     tp2:=VectorDot(_ZWCS,tp);
  tp3:=VectorDot(tp2,tp);
  //tp3:=uzegeometry.VertexMulOnSc(tp3,-1);
  tp3:=NormalizeVertex(tp3);
  tp2:=NormalizeVertex(tp2);
  tp:=NormalizeVertex(tp);

   //rotmatr:=onematrix;
   //PzePoint3d(@rotmatr.mtr[0])^:=tp;
   //PzePoint3d(@rotmatr.mtr[1])^:=tp2;
   //PzePoint3d(@rotmatr.mtr[2])^:=tp3;
   rotmatr:=CreateMatrixFromBasis(tp,tp2,tp3);

   //m:=onematrix;
   //PzePoint3d(@m.mtr[3])^:=ptnlastCutted.PrevP;
   m:=CreateTranslationMatrix(ptnlastCutted.PrevP);

   m:=MatrixMultiply(rotmatr,m);

  str22:=ptnlastCutted.PrevP;
  str21:=VectorTransform3D(uzegeometry.CreateVertex(-3*SysVar.DSGN.DSGN_HelpScale^,0.5*SysVar.DSGN.DSGN_HelpScale^,0),m);
  str23:=VectorTransform3D(uzegeometry.CreateVertex(-3*SysVar.DSGN.DSGN_HelpScale^,-0.5*SysVar.DSGN.DSGN_HelpScale^,0),m);
  end
  else begin
            str22:=ptnlastCutted.PrevP;
            str21:=ptnlastCutted.PrevP;
            str23:=ptnlastCutted.PrevP;
       end;
  end;
  NodePropArray.Shrink;

  Representation.Clear;
  ptn2:=NodePropArray.beginiterate(ir_inNodeArray);
  ptn1:=NodePropArray.iterate(ir_inNodeArray);
  if ptn1<>nil then
  begin
  repeat
    Representation.DrawLineWithLT(self,getmatrix^,DC,ptn2^.Nextp,ptn1^.PrevP,vp);
    //DC.Drawer.DrawLine3DInModelSpace(ptn2^.Nextp,ptn1^.PrevP,DC.DrawingContext.matrixs);
    ptn2:=ptn1;
    ptn1:=NodePropArray.iterate(ir_inNodeArray);
  until ptn1=nil;
  end;

  if assigned(EntExtensions)then
    EntExtensions.RunOnAfterEntityFormat(@self,drawing,DC);
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
  NodePropArray.init(1000);
  //vp.ID := GDBCableID;
  //PTEntityUnit(self.ou.Instance)^.init('cable');
  GetDXFIOFeatures.AddExtendersToEntity(@self);
end;
constructor GDBObjCable.initnul;
begin
  inherited initnul(owner);
  NodePropArray.init(1000);
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
//var
   //ptn1,ptn2:PTNodeProp;
   //ir_inNodeArray:itrec;
begin
  Representation.DrawGeometry(DC,VP.BoundingBox,inFrustumState);

  if SysVar.DWG.DWG_HelpGeometryDraw^ then
    if CanSimplyDrawInWCS(DC,SysVar.DSGN.DSGN_HelpScale^,1) then begin
      if vertexarrayInWCS.Count>1 then begin
        dc.drawer.DrawLine3DInModelSpace(str21,str22,dc.DrawingContext.matrixs);
        dc.drawer.DrawLine3DInModelSpace(str22,str23,dc.DrawingContext.matrixs);
      end;
    end;
  //inherited;
  drawbb(dc);
end;
function AllocCable:PGDBObjCable;
begin
  Getmem(result,sizeof(GDBObjCable));
end;
function AllocAndInitCable(owner:PGDBObjGenericWithSubordinated):PGDBObjCable;
begin
  result:=AllocCable;
  result.initnul(owner);
  result.bp.ListPos.Owner:=owner;
end;
function Upgrade3DPolyline2Cable(ptu:PExtensionData;pent:PGDBObjCurve;const drawing:TDrawingDef):PGDBObjCable;
var
    ptv:PzePoint3d;
    ir:itrec;
begin
     result:=nil;
     result:=AllocAndInitCable(pent^.bp.ListPos.Owner);
     if pent^.PExtAttrib<>nil then
     begin
       result^.PExtAttrib:=pent^.CopyExtAttrib;
       //result^.PExtAttrib:=pent^.PExtAttrib;
       //pent^.PExtAttrib:=nil;
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
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
  GDBObjCableDXFFeatures.Destroy
end.
