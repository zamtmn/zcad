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
unit uzeentdevice;
{$Mode delphi}
{$INCLUDE zengineconfig.inc}

interface

uses
  uzestyleslayers,uzepalette,uzeobjectextender,uzeentityfactory,
  uzgldrawcontext,uzedrawingdef,uzecamera,uzcsysvars,SysUtils,uzctnrVectorBytesStream,
  uunitmanager,uzegeometry,uzeconsts,uzeentity,uzeentsubordinated,uzsbVarmanDef,
  uzegeometrytypes,uzeentblockinsert,uzeTypes,UGDBVisibleOpenArray,
  UGDBObjBlockdefArray,gzctnrVectorTypes,uzeblockdef,uzeffdxfsupport,
  UGDBSelectedObjArray,uzeentitiestree,uzbLogIntf,uzestrconsts,uzglviewareadata,
  uzeSnap,uzCtnrVectorpBaseEntity;

type
  PGDBObjDevice=^GDBObjDevice;

  GDBObjDevice=object(GDBObjBlockInsert)
    VarObjArray:GDBObjEntityOpenArray;
    lstonmouse:PGDBObjEntity;
    function Clone(own:Pointer):PGDBObjEntity;virtual;
    constructor initnul;
    constructor init(own:Pointer;layeraddres:PGDBLayerProp;LW:smallint);
    destructor done;virtual;
    function CalcInFrustum(const frustum:TzeFrustum;
      const Actuality:TVisActuality;var Counters:TCameraCounters;ProjectProc:GDBProjectProc;
      const zoom,currentdegradationfactor:double):boolean;virtual;
    function CalcTrueInFrustum(
      const frustum:TzeFrustum):TInBoundingVolume;virtual;
    procedure FormatEntity(var drawing:TDrawingDef;
      var DC:TDrawContext;Stage:TEFStages=EFAllStages);virtual;
    function IsStagedFormatEntity:boolean;virtual;
    procedure FormatFeatures(var drawing:TDrawingDef);virtual;
    procedure DrawGeometry(lw:integer;var DC:TDrawContext;
      const inFrustumState:TInBoundingVolume);virtual;
    function onmouse(var popa:TZctnrVectorPGDBaseEntity;
      const MF:TzeFrustum;InSubEntry:boolean):boolean;virtual;
    function ReturnLastOnMouse(InSubEntry:boolean):PGDBObjEntity;virtual;
    procedure ImEdited(pobj:PGDBObjSubordinated;pobjinarray:integer;
      var drawing:TDrawingDef);virtual;
    procedure DeSelect(var SelectedObjCount:integer;
      ds2s:TDeSelect2Stage);virtual;
    procedure getoutbound(var DC:TDrawContext);virtual;
    function getonlyvisibleoutbound(
      var DC:TDrawContext):TBoundingBox;virtual;
    function GetObjTypeName:string;virtual;
    procedure BuildGeometry(var drawing:TDrawingDef);virtual;
    procedure BuildVarGeometry(var drawing:TDrawingDef);virtual;
    procedure postload(var context:TIODXFLoadContext);virtual;
    procedure SaveToDXFFollow(var outStream:TZctnrVectorBytes;
      var drawing:TDrawingDef;var IODXFContext:TIODXFSaveContext);virtual;
    procedure SaveToDXFObjXData(var outStream:TZctnrVectorBytes;
      var IODXFContext:TIODXFSaveContext);virtual;
    procedure AddMi(pobj:PGDBObjSubordinated);virtual;
    procedure SetInFrustumFromTree(const frustum:TzeFrustum;
      const Actuality:TVisActuality;var Counters:TCameraCounters;ProjectProc:GDBProjectProc;
      const zoom,currentdegradationfactor:double);virtual;
    function CalcActualVisible(
      const Actuality:TVisActuality):boolean;virtual;
    procedure addcontrolpoints(tdesc:Pointer);virtual;
    procedure EraseMi(pobj:pGDBObjEntity;pobjinarray:integer;
      var drawing:TDrawingDef);virtual;
    procedure correctobjects(powner:PGDBObjEntity;
      pinownerarray:integer);virtual;
    procedure FormatAfterDXFLoad(var drawing:TDrawingDef;
      var DC:TDrawContext);virtual;
    class function GetDXFIOFeatures:TDXFEntIODataManager;static;
    function CreateInstance:PGDBObjDevice;static;
    function GetNameInBlockTable:string;virtual;
    function GetObjType:TObjID;virtual;
    procedure GoodAddObjectToObjArray(
      const obj:PGDBObjSubordinated);virtual;
    procedure GoodRemoveMiFromArray(const obj:PGDBObjSubordinated;
      const drawing:TDrawingDef);virtual;
  end;

var
  GDBObjDeviceDXFFeatures:TDXFEntIODataManager;

implementation

procedure GDBObjDevice.GoodAddObjectToObjArray(const obj:PGDBObjSubordinated);
begin
  VarObjArray.AddPEntity(PGDBObjEntity(obj)^);
  PGDBObjEntity(obj).bp.ListPos.Owner:=@self;
end;

procedure GDBObjDevice.GoodRemoveMiFromArray(const obj:PGDBObjSubordinated;
  const drawing:TDrawingDef);
begin
  if assigned(obj^.EntExtensions) then
    obj^.EntExtensions.RunRemoveFromArray(obj,drawing);

  if obj^.bp.TreePos.Owner<>nil then begin
    PTEntTreeNode(obj^.bp.TreePos.Owner)^.nulDeleteElement(
      obj^.bp.TreePos.SelfIndexInNode);
  end;
  obj^.bp.TreePos.Owner:=nil;
  VarObjArray.DeleteElement(obj.bp.ListPos.SelfIndex);
end;


function GDBObjDevice.GetNameInBlockTable:string;
begin
  Result:=DevicePrefix+Name;
end;

procedure GDBObjDevice.correctobjects;
var
  pobj:PGDBObjEntity;
  ir:itrec;
begin
  inherited;
  pobj:=self.VarObjArray.beginiterate(ir);
  if pobj<>nil then
    repeat
      pobj^.correctobjects(@self,ir.itc);
      pobj:=self.VarObjArray.iterate(ir);
    until pobj=nil;
end;

procedure GDBObjDevice.EraseMi;
begin
  if pobj^.bp.TreePos.Owner<>nil then begin
    PTEntTreeNode(pobj^.bp.TreePos.Owner)^.nul.DeleteElement(
      pobj^.bp.TreePos.SelfIndexInNode);
  end;
  VarObjArray.DeleteElement(pobjinarray);
  pobj^.done;
  Freemem(Pointer(pobj));
end;

procedure GDBObjDevice.addcontrolpoints(tdesc:Pointer);
var
  pdesc:controlpointdesc;
  ir:itrec;
  pv:pgdbobjEntity;
begin
  if assigned(SysVar.DWG.DWG_AdditionalGrips) then begin
    if SysVar.DWG.DWG_AdditionalGrips^ then begin
      PSelectedObjDesc(tdesc)^.pcontrolpoint^.init(1);
    end else
      inherited addcontrolpoints(tdesc);
  end;

  pdesc.selected:=False;
  pdesc.PDrawable:=nil;


  if assigned(SysVar.DWG.DWG_AdditionalGrips) then
    if SysVar.DWG.DWG_AdditionalGrips^ then begin
      pv:=VarObjArray.beginiterate(ir);
      if pv<>nil then
        repeat
          if (pv^.GetObjType=GDBDeviceID)or(pv^.GetObjType=GDBBlockInsertID) then
            if PGDBObjDevice(pv).Name='FIX' then begin
              pdesc.pointtype:=os_point;
              pdesc.PDrawable:=pv;
              pdesc.dcoord:=vertexsub(PGDBObjDevice(pv).P_insert_in_WCS,
                P_insert_in_WCS);
              pdesc.worldcoord:=PGDBObjDevice(pv).P_insert_in_WCS;
              PSelectedObjDesc(tdesc)^.pcontrolpoint^.PushBackData(pdesc);
            end;
          pv:=VarObjArray.iterate(ir);
        until pv=nil;
    end;
end;

procedure GDBObjDevice.SetInFrustumFromTree;
begin
  inherited SetInFrustumFromTree(frustum,Actuality,Counters,
    ProjectProc,zoom,currentdegradationfactor);
  VarObjArray.SetInFrustumFromTree(frustum,Actuality,Counters,
    ProjectProc,zoom,currentdegradationfactor);
end;

function GDBObjDevice.CalcActualVisible(const Actuality:TVisActuality):boolean;
var
  q:boolean;
begin
  Result:=inherited;
  q:=VarObjArray.CalcActualVisible(Actuality);
  Result:=Result or q;
end;

procedure GDBObjDevice.AddMi;
begin
  VarObjArray.AddPEntity(pGDBObjEntity(ppointer(pobj)^)^);
  pGDBObjEntity(ppointer(pobj)^).bp.ListPos.Owner:=@self;
  if assigned(pGDBObjEntity(ppointer(pobj)^).EntExtensions) then
    pGDBObjEntity(ppointer(pobj)^).EntExtensions.RunSetRoot(
      pobj,GetMainOwner{ @self});
end;

destructor GDBObjDevice.done;
begin
  VarObjArray.Free;
  VarObjArray.done;
  inherited done;
end;

procedure GDBObjDevice.postload(var context:TIODXFLoadContext);
var
  pv:pgdbobjEntity;
  ir:itrec;
begin
  inherited postload(context);
  pv:=VarObjArray.beginiterate(ir);
  if pv<>nil then
    repeat
      pv^.postload(context);
      pv:=VarObjArray.iterate(ir);
    until pv=nil;
end;

procedure GDBObjDevice.SaveToDXFFollow;
var
  pv,pvc,pvc2:pgdbobjEntity;
  ir:itrec;
  m4:TzeTypedMatrix4d;
  DC:TDrawContext;
  SaveLocalEntityFlags:TLocalEntityFlags;
begin
  SaveLocalEntityFlags:=IODXFContext.LocalEntityFlags;
  inherited;
  m4:=getmatrix^;
  dc:=drawing.createdrawingrc;

  //пытался так починить https://github.com/zamtmn/zcad/issues/141
  //но это ведет https://github.com/zamtmn/zcad/issues/143
  {dc.Options:=dc.Options-[DCODrawable];}
  //пока просто чищу списки на присоединение примитивов при закрытии чертежа

  pv:=VarObjArray.beginiterate(ir);
  if pv<>nil then
    repeat
      pvc:=pv^.Clone(@self);
      pvc2:=pv^.Clone(@self);

      pvc^.bp.ListPos.Owner:=@self;

      self.ObjMatrix:=onematrix;
      if pvc^.IsHaveLCS then begin
        pvc^.State:=pv^.State+[ESCalcWithoutOwner,ESTemp];
        pvc^.FormatEntity(drawing,dc);
        pvc^.State:=pv^.State-[ESCalcWithoutOwner,ESTemp];
      end;
      pvc^.transform(m4);
      pvc^.State:=pv^.State+[ESCalcWithoutOwner,ESTemp];
      pvc^.FormatEntity(drawing,dc);
      pvc^.State:=pv^.State-[ESCalcWithoutOwner,ESTemp];


      pv.rtsave(pvc2);
      pvc.rtsave(pv);
      pv^.State:=pv^.State+[ESCalcWithoutOwner,ESTemp];

      //if pv^.IsHaveLCS then
      begin
        pv^.FormatEntity(drawing,dc,EFAllStages-[EFDraw]);
      end;
      IODXFContext.LocalEntityFlags:=DefaultLocalEntityFlags;

      pv^.DXFOut(outStream,drawing,IODXFContext);
      //pv^.SaveToDXF(outStream,drawing,IODXFContext);
      //pv^.SaveToDXFPostProcess(outStream,IODXFContext);
      //pv^.SaveToDXFFollow(outStream,drawing,IODXFContext);
      pvc2.rtsave(pv);

      pvc2.rtsave(pv);
      pv^.State:=pv^.State-[ESCalcWithoutOwner,ESTemp];

      pvc^.done;
      Freemem(pointer(pvc));

      pvc2^.done;
      Freemem(pointer(pvc2));

      pv:=VarObjArray.iterate(ir);
    until pv=nil;
  objmatrix:=m4;
  VarObjArray.CalcObjMatrix(@drawing);
  IODXFContext.LocalEntityFlags:=SaveLocalEntityFlags;
end;

procedure GDBObjDevice.SaveToDXFObjXData(var outStream:TZctnrVectorBytes;
  var IODXFContext:TIODXFSaveContext);
begin
  inherited;
  dxfStringout(outStream,1000,'_HANDLE='+inttohex(GetHandle,10));
  dxfStringout(outStream,1000,'_UPGRADE=1');
end;

function GDBObjDevice.GetObjTypeName;
begin
  Result:=ObjN_GDBObjDevice;
end;

function GDBObjDevice.CalcInFrustum;
var
  a:boolean;
begin
  Result:=inherited CalcInFrustum(frustum,Actuality,Counters,
    ProjectProc,zoom,currentdegradationfactor);
  a:=VarObjArray.calcvisible(frustum,Actuality,Counters,
    ProjectProc,zoom,currentdegradationfactor);
  Result:=Result or a;
end;

function GDBObjDevice.CalcTrueInFrustum;
var
  inhresult:TInBoundingVolume;
begin
  inhresult:=inherited;
  Result:=VarObjArray.CalcTrueInFrustum(frustum);
  if Result<>inhresult then begin
    if Result=IRNotAplicable then
      exit(inhresult);
    if inhresult=IRNotAplicable then
      exit(Result);
    Result:=IRPartially;
  end;
end;

procedure GDBObjDevice.getoutbound;
var
  tbb:TBoundingBox;
begin
  inherited;
  tbb:=VarObjArray.getoutbound(dc);
  if (tbb.LBN.x=tbb.RTF.x)  and (tbb.LBN.y=tbb.RTF.y)  and
    (tbb.LBN.z=tbb.RTF.z) then
  else
    concatbb(vp.BoundingBox,tbb);
end;

function GDBObjDevice.getonlyvisibleoutbound(var DC:TDrawContext):TBoundingBox;
var
  tbb:TBoundingBox;
begin
  Result:=inherited;
  tbb:=VarObjArray.getonlyvisibleoutbound(dc);
  if tbb.RTF.x>=tbb.LBN.x then
    ConcatBB(Result,tbb);
end;

function GDBObjDevice.Clone;
var
  tvo:PGDBObjDevice;
begin
  Getmem(Pointer(tvo),sizeof(GDBObjDevice));
  tvo^.init(own,vp.Layer,vp.LineWeight);
  CopyVPto(tvo^);
  CopyExtensionsTo(tvo^);
  Pointer(tvo^.Name):=nil;
  tvo^.Name:=Name;
  tvo^.pattrib:=nil;
  tvo^.Local.p_insert:=Local.p_insert;
  tvo^.Local:=Local;
  tvo^.scale:=scale;
  tvo^.rotate:=rotate;
  tvo.index:=index;
  tvo.VarObjArray.init(varObjArray.Count+1);
  ConstObjArray.CloneEntityTo(@tvo.ConstObjArray,tvo);
  varObjArray.CloneEntityTo(@tvo.varObjArray,tvo);
  tvo^.bp.ListPos.Owner:=own;
  Result:=tvo;
  if assigned(EntExtensions) then
    EntExtensions.RunOnCloneProcedures(@self,tvo);
  tvo^.BlockDesc:=BlockDesc;
end;

procedure GDBObjDevice.DeSelect;
begin
  inherited deselect(SelectedObjCount,ds2s);
  VarObjArray.DeSelect(SelectedObjCount,ds2s);
end;

procedure GDBObjDevice.ImEdited;
begin
  inherited imedited(pobj,pobjinarray,drawing);
  YouChanged(drawing);
end;

function GDBObjDevice.ReturnLastOnMouse;
begin
  if (InSubEntry) then begin
    if lstonmouse<>nil then
      Result:=lstonmouse
    else
      Result:=@self;
  end else
    Result:=@self;
end;

function GDBObjDevice.onmouse;
var
  p:pgdbobjEntity;
  ot:boolean;
  ir:itrec;
begin
  Result:=inherited onmouse(popa,mf,InSubEntry);
  p:=VarObjArray.beginiterate(ir);
  if p<>nil then
    repeat
      ot:=p^.isonmouse(popa,mf,InSubEntry);
      if ot then begin
        lstonmouse:=p^.ReturnLastOnMouse(InSubEntry);
        (popa).PushBackData(p);
      end;
      Result:=Result or ot;
      p:=VarObjArray.iterate(ir);
    until p=nil;
  if not Result then
    lstonmouse:=nil;
end;

procedure GDBObjDevice.DrawGeometry;
var
  p:pgdbobjEntity;
  v:TzePoint3d;
  ir:itrec;
  oldlw:smallint;
begin
  oldlw:=dc.OwnerLineWeight;
  dc.OwnerLineWeight:=self.GetLineWeight;
  dc.subrender:=dc.subrender+1;
  VarObjArray.DrawWithattrib(dc,inFrustumState);
  dc.subrender:=dc.subrender-1;
  p:=VarObjArray.beginiterate(ir);
  dc.drawer.SetColor(palette[dc.SystmGeometryColor].RGB);
  if DC.SystmGeometryDraw then begin
    if p<>nil then
      repeat
        v:=p^.getcenterpoint;
        dc.drawer.DrawLine3DInModelSpace(self.P_insert_in_WCS,v,
          dc.DrawingContext.matrixs);
        p:=VarObjArray.iterate(ir);
      until p=nil;
  end;
  dc.OwnerLineWeight:=oldlw;
  inherited;
end;

procedure GDBObjDevice.BuildVarGeometry;
var
  pvisible,pvisible2:PGDBObjEntity;
  devnam:string;
  DC:TDrawContext;
  pblockdef:PGDBObjBlockdef;
  ir:itrec;
begin
  devnam:=DevicePrefix+Name;
  pblockdef:=PGDBObjBlockdefArray(drawing.GetBlockDefArraySimple).getblockdef(devnam);
  index:=PGDBObjBlockdefArray(drawing.GetBlockDefArraySimple).getindex(devnam);
  if pblockdef<>nil then begin
    dc:=drawing.createdrawingrc;
    pvisible:=pblockdef.ObjArray.beginiterate(ir);
    if pvisible<>nil then
      repeat
        pvisible:=pvisible^.Clone(@self);
        pvisible2:=PGDBObjEntity(pvisible^.FromDXFPostProcessBeforeAdd(nil,drawing));
        if pvisible2=nil then begin
          pvisible^.formatEntity(drawing,dc);
          pvisible.BuildGeometry(drawing);
          VarObjArray.AddPEntity(pvisible^);
        end else begin
          pvisible2^.FromDXFPostProcessBeforeAdd(nil,drawing);
          pvisible2^.formatEntity(drawing,dc);
          pvisible2.BuildGeometry(drawing);
          VarObjArray.AddPEntity(pvisible2^);
        end;
        pvisible:=pblockdef.ObjArray.iterate(ir);
      until pvisible=nil;
    ConstObjArray.Shrink;
    VarObjArray.Shrink;
    self.BlockDesc:=pblockdef.BlockDesc;
    if assigned(EntExtensions) then
      EntExtensions.RunOnBuildVarGeometryProcedures(@self,drawing);
  end;
end;

procedure GDBObjDevice.BuildGeometry;
var
  pblockdef:PGDBObjBlockdef;
  pvisible,pvisible2:PGDBObjEntity;
  i:integer;
  DC:TDrawContext;
begin
  inherited;
  exit;
  begin
    dc:=drawing.createdrawingrc;
    if not PBlockDefArray(PGDBObjBlockdefArray(
      drawing.GetBlockDefArraySimple).parray)^[index].Formated then
      PBlockDefArray(
        PGDBObjBlockdefArray(drawing.GetBlockDefArraySimple).parray)^
        [index].formatEntity(drawing,dc);
    index:=PGDBObjBlockdefArray(drawing.GetBlockDefArraySimple).getindex(Name);
    assert((index>=0) and
      (index<PGDBObjBlockdefArray(drawing.GetBlockDefArraySimple).Count),
      rsWrongBlockDefIndex);
    ConstObjArray.Free;
    pblockdef:=PGDBObjBlockdefArray(
      drawing.GetBlockDefArraySimple).getDataMutable(index);
    for i:=0 to pblockdef.ObjArray.Count-1 do begin
      pvisible:=Pointer(pblockdef.ObjArray.getDataMutable(i)^);
      pvisible:=pvisible^.Clone(@self);
      pvisible2:=PGDBObjEntity(pvisible^.FromDXFPostProcessBeforeAdd(
        nil,drawing));
      if pvisible2=nil then begin
        pvisible^.correctobjects(@self,i);
        pvisible^.formatEntity(drawing,dc);
        pvisible.BuildGeometry(drawing);
        ConstObjArray.AddPEntity(pvisible^);

      end else begin
        pvisible2^.correctobjects(@self,i);
        pvisible2^.FromDXFPostProcessBeforeAdd(
          nil,drawing);
        pvisible2^.formatEntity(drawing,dc);
        pvisible2.BuildGeometry(drawing);
        ConstObjArray.AddPEntity(pvisible2^);
      end;
    end;
    ConstObjArray.Shrink;
    VarObjArray.Shrink;
    self.BlockDesc:=pblockdef.BlockDesc;
  end;
end;

procedure GDBObjDevice.FormatAfterDXFLoad;
var
  p:pgdbobjEntity;
  ir:itrec;
begin
  inherited;
  p:=VarObjArray.beginiterate(ir);
  if p<>nil then
    repeat
      p^.FormatAfterDXFLoad(drawing,dc);
      p:=VarObjArray.iterate(ir);
    until p=nil;
  ConstObjArray.FormatEntity(drawing,dc);
  VarObjArray.FormatEntity(drawing,dc);
  calcbb(dc);
end;

constructor GDBObjDevice.init(own:Pointer;layeraddres:PGDBLayerProp;LW:smallint);
begin
  inherited init(own,layeraddres,LW);
  VarObjArray.init(10);
  GetDXFIOFeatures.AddExtendersToEntity(@self);
end;

function GDBObjDevice.GetObjType;
begin
  Result:=GDBDeviceID;
end;

constructor GDBObjDevice.initnul;
begin
  inherited initnul;
  VarObjArray.init(10);
  GetDXFIOFeatures.AddExtendersToEntity(@self);
end;

procedure GDBObjDevice.FormatFeatures(var drawing:TDrawingDef);
begin
  inherited;
  GetDXFIOFeatures.RunFormatProcs(drawing,@self);
end;

function GDBObjDevice.IsStagedFormatEntity:boolean;
begin
  Result:=True;
end;

procedure GDBObjDevice.FormatEntity(var drawing:TDrawingDef;
  var DC:TDrawContext;Stage:TEFStages=EFAllStages);
begin
  if EFCalcEntityCS in stage then begin
    if assigned(EntExtensions) then
      EntExtensions.RunOnBeforeEntityFormat(@self,drawing,DC);
  end;
  index:=PGDBObjBlockdefArray(drawing.GetBlockDefArraySimple).getindex(Name);
  FormatFeatures(drawing);
  CalcObjMatrix(@drawing);
  ConstObjArray.FormatEntity(drawing,dc,stage);
  VarObjArray.FormatEntity(drawing,dc,stage);
  self.lstonmouse:=nil;
  calcbb(dc);
  CalcActualVisible(dc.DrawingContext.VActuality);
  if EFDraw in stage then begin
    if assigned(EntExtensions) then
      EntExtensions.RunOnAfterEntityFormat(@self,drawing,DC);
  end;
end;

function AllocDevice:PGDBObjDevice;
begin
  Getmem(Result,sizeof(GDBObjDevice));
end;

function AllocAndInitDevice(owner:PGDBObjGenericWithSubordinated):PGDBObjDevice;
begin
  Result:=AllocDevice;
  Result.initnul;
  Result.bp.ListPos.Owner:=owner;
end;

function AllocAndCreateDevice(owner:PGDBObjGenericWithSubordinated;
  const args:array of const):PGDBObjBlockInsert;
begin
  Result:=AllocAndInitDevice(owner);
  SetBlockInsertGeomProps(Result,args);
end;

function GDBObjDevice.CreateInstance:PGDBObjDevice;
begin
  Result:=AllocAndInitDevice(nil);
end;

function UpgradeBlockInsert2Device(ptu:PExtensionData;pent:PGDBObjBlockInsert;
  const drawing:TDrawingDef):PGDBObjDevice;
begin
  pent^.index:=PGDBObjBlockdefArray(drawing.GetBlockDefArraySimple).getindex(
    pent^.Name);
  Result:=nil;
  begin
    Result:=AllocAndInitDevice(pent^.bp.ListPos.Owner);
    Result^.Name:=DevicePrefix+pent^.Name;
    pent.CopyVPto(Result^);
    Result^.Local:=pent^.local;
    Result^.scale:=pent^.scale;
    Result^.rotate:=pent^.rotate;
    Result^.P_insert_in_WCS:=pent^.P_insert_in_WCS;
    {БЛЯДЬ так делать нельзя!!!!}
    if pent^.PExtAttrib<>nil then
      Result^.PExtAttrib:=pent^.CopyExtAttrib;
    Result^.Name:=copy(Result^.Name,8,length(Result^.Name)-7);
    Result^.index:=PGDBObjBlockdefArray(drawing.GetBlockDefArraySimple).getindex(
      Result^.Name);
  end;
end;

class function GDBObjDevice.GetDXFIOFeatures:TDXFEntIODataManager;
begin
  Result:=GDBObjDeviceDXFFeatures;
end;

initialization
  RegisterEntity(GDBDeviceID,'Device',@AllocDevice,@AllocAndInitDevice,@SetBlockInsertGeomProps,@AllocAndCreateDevice);
  RegisterEntityUpgradeInfo(GDBBlockInsertID,1,@UpgradeBlockInsert2Device);
  GDBObjDeviceDXFFeatures:=TDXFEntIODataManager.Create;

finalization
  ZDebugLN('{I}[UnitsFinalization] Unit "'+{$INCLUDE %FILE%}+'" finalization');
  GDBObjDeviceDXFFeatures.Destroy;
end.
