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

unit uzeroot;
{$Mode delphi}{$H+}
{$INCLUDE zengineconfig.inc}

interface
Uses
  uzgldrawcontext,uzedrawingdef,uzecamera,uzeentitiestree,uzbtypes,
  uzeconsts,uzeentity,uzeentgenericsubentry,uzeentconnected,uzeentsubordinated,
  gzctnrVectorTypes,uzegeometrytypes,uzegeometry,UGDBOpenArrayOfPV,
  uzelongprocesssupport;

type

  PGDBObjRoot=^GDBObjRoot;
  GDBObjRoot= object(GDBObjGenericSubEntry)
    private
      fInfrustum:TActuality;
      fFrustumPosition:TzePoint3d;
    protected
      function GetInfrustumFromTree:TActuality;virtual;
      procedure SetObjMatrix(const AObjMatrix:TzeTypedMatrix4d);virtual;
    public
      constructor initnul;
      destructor done;virtual;
      procedure FormatAfterEdit(var drawing:TDrawingDef;var DC:TDrawContext;Stage:TEFStages=EFAllStages);virtual;
      function getowner:PGDBObjSubordinated;virtual;
      procedure getoutbound(var DC:TDrawContext);virtual;
      function GetHandle:PtrInt;virtual;
      procedure EraseMi(pobj:pGDBObjEntity;pobjinarray:Integer;var drawing:TDrawingDef);virtual;
      function GetMatrix:PzeTypedMatrix4d;virtual;
      procedure DrawWithAttrib(var DC:TDrawContext;const inFrustumState:TInBoundingVolume);virtual;
      function CalcInFrustum(const frustum:TzeFrustum;const Actuality:TVisActuality;var Counters:TCameraCounters; ProjectProc:GDBProjectProc;const zoom,currentdegradationfactor:Double):Boolean;virtual;
      procedure CalcInFrustumByTree(const frustum:TzeFrustum;const Actuality:TVisActuality;var enttree:TEntTreeNode;var Counters:TCameraCounters; ProjectProc:GDBProjectProc;const zoom,currentdegradationfactor:Double);virtual;
      procedure CalcVisibleBBByTree(const Actuality:TVisActuality;var enttree:TEntTreeNode);virtual;
      function calcvisible(const frustum:TzeFrustum;const Actuality:TVisActuality;var Counters:TCameraCounters;ProjectProc:GDBProjectProc;const zoom,currentdegradationfactor:Double):Boolean;virtual;
      procedure calcbb(var DC:TDrawContext);virtual;
      function GetObjType:TObjID;virtual;
      procedure SetInFrustum(infrustumactualy:TActuality;var Counters:TCameraCounters);virtual;
      procedure SetNotInFrustum(infrustumactualy:TActuality;var Counters:TCameraCounters);virtual;

      property FrustumPosition:TzePoint3d read fFrustumPosition write fFrustumPosition;
  end;

procedure DoFormat(var ConnectedArea:GDBObjGenericSubEntry;var ents,ents2Connected:GDBObjOpenArrayOfPV;var drawing:TDrawingDef;var DC:TDrawContext;lpsh:TLPSHandle;Stage:TEFStages{=EFAllStages});

implementation

procedure GDBObjRoot.SetObjMatrix(const AObjMatrix:TzeTypedMatrix4d);
begin
  inherited;
  fFrustumPosition.x:=AObjMatrix.mtr.v[3].v[0];
  fFrustumPosition.y:=AObjMatrix.mtr.v[3].v[1];
  fFrustumPosition.z:=AObjMatrix.mtr.v[3].v[2];
end;

function GDBObjRoot.GetInfrustumFromTree:TActuality;
begin
  result:=fInfrustum;
end;
procedure GDBObjRoot.SetInFrustum(infrustumactualy:TActuality;var Counters:TCameraCounters);
begin
  fInfrustum:=infrustumactualy;
  inherited;
end;
procedure GDBObjRoot.SetNotInFrustum(infrustumactualy:TActuality;var Counters:TCameraCounters);
begin
  fInfrustum:=0;
  inherited;
end;

procedure GDBObjRoot.calcbb;
begin
  inherited;
  vp.BoundingBox.LBN:=VectorTransform3D(vp.BoundingBox.LBN,ObjMatrix);
  vp.BoundingBox.RTF:=VectorTransform3D(vp.BoundingBox.RTF,ObjMatrix);
end;
procedure GDBObjRoot.CalcVisibleBBByTree(const Actuality:TVisActuality;var enttree:TEntTreeNode);
begin
  InFrustumAABB:=enttree.NodeData.InFrustumBoundingBox;
end;

function correctFrustum(const frustum:TzeFrustum;const objmatrix:TzeTypedMatrix4d;frustumpos:TzePoint3d):TzeFrustum;
var
  im:TzeTypedMatrix4d;
begin
  im:=ObjMatrix;
  im.mtr.v[3].v[0]:=frustumpos.x;
  im.mtr.v[3].v[1]:=frustumpos.y;
  im.mtr.v[3].v[2]:=frustumpos.z;
  result:=FrustumTransform(frustum,im);
end;

function GDBObjRoot.calcvisible(const frustum:TzeFrustum;const Actuality:TVisActuality;var Counters:TCameraCounters;ProjectProc:GDBProjectProc;const zoom,currentdegradationfactor:Double):Boolean;
var
  tfrustum:TzeFrustum;
begin
  tfrustum:=correctFrustum(frustum,ObjMatrix,FrustumPosition);
  result:=inherited calcvisible(tfrustum,Actuality,Counters,ProjectProc,zoom,currentdegradationfactor);
end;

procedure GDBObjRoot.CalcInFrustumByTree(const frustum:TzeFrustum;const Actuality:TVisActuality;var enttree:TEntTreeNode;var Counters:TCameraCounters; ProjectProc:GDBProjectProc;const zoom,currentdegradationfactor:Double);
var
   tfrustum:TzeFrustum;
begin
  fInfrustum:=Actuality.InfrustumActualy;
  tfrustum:=correctFrustum(frustum,ObjMatrix,FrustumPosition);
  ProcessTree(tfrustum,Actuality,enttree,IRPartially,TDTFulDraw,Counters,ProjectProc,zoom,currentdegradationfactor);
  CalcVisibleBBByTree(Actuality,enttree);
end;
function GDBObjRoot.CalcInFrustum;
var
  tfrustum:TzeFrustum;
begin
  fInfrustum:=Actuality.InfrustumActualy;
  tfrustum:=correctFrustum(frustum,ObjMatrix,FrustumPosition);
  result:=inherited CalcInFrustum(tfrustum,Actuality,Counters, ProjectProc,zoom,currentdegradationfactor);
end;
procedure GDBObjRoot.DrawWithAttrib;
begin
  DC.drawer.pushMatrixAndSetTransform(objmatrix);
  inherited;
  DC.drawer.popMatrix;
end;
function GDBObjRoot.GetMatrix;
begin
  result:={@self.ObjMatrix}@OneMatrix;
end;
procedure GDBObjRoot.EraseMi(pobj:pGDBObjEntity;pobjinarray:Integer;var drawing:TDrawingDef);
var p:PGDBObjConnected;
    ir:itrec;
begin
     inherited EraseMi(pobj,pobjinarray,drawing);
     p:=self.ObjToConnectedArray.beginiterate(ir);
     if p<>nil then
     repeat
           //if p=pobj then
                         //ppointer(ir.itp)^:=nil;

           p:=self.ObjToConnectedArray.iterate(ir);
     until p=nil;
end;
function GDBObjRoot.GetHandle:PtrInt;
begin
     result:=H_Root;
end;
procedure GDBObjRoot.getoutbound;
begin
  vp.BoundingBox.LBN:=NulVertex;
  vp.BoundingBox.RTF:=NulVertex;
  inherited;
end;
function GDBObjRoot.getowner;
begin
  result:=nil;
end;
destructor GDBObjRoot.done;
begin
  inherited done;
end;
constructor GDBObjRoot.initnul;
begin
  inherited initnul(nil);
  bp.ListPos.owner:=nil;
  bp.ListPos.SelfIndex:=-1;
end;
function GDBObjRoot.GetObjType;
begin
     result:=GDBRootId;
end;

procedure DoFormat(var ConnectedArea:GDBObjGenericSubEntry;var ents,ents2Connected:GDBObjOpenArrayOfPV;var drawing:TDrawingDef;var DC:TDrawContext;lpsh:TLPSHandle;Stage:TEFStages{=EFAllStages});
var
  p:pGDBObjEntity;
  ir:itrec;
  c:integer;
  bb:TBoundingBox;
  HaveNewBB:boolean;
begin
  c:=ents.count;
  HaveNewBB:=False;
  p:=ents.beginiterate(ir);
  if p<>nil then repeat
    p^.Formatafteredit(drawing,dc,[EFCalcEntityCS]);
    if HaveNewBB then
      ConcatBB(bb,p^.vp.BoundingBox)
    else begin
      bb:=p^.vp.BoundingBox;
      HaveNewBB:=True;
    end;
    if lpsh<>LPSHEmpty then
      lps.ProgressLongProcess(lpsh,ir.itc);
    p:=ents.iterate(ir);
  until p=nil;

  if @ConnectedArea<>nil then
    if HaveNewBB then begin
      ConcatBB(ConnectedArea.vp.BoundingBox,bb);
      ConcatBB(ConnectedArea.ObjArray.ObjTree.BoundingBox,bb);
    end;

  p:=ents2Connected.beginiterate(ir);
  if p<>nil then repeat
    if assigned(p^.EntExtensions)then
      p^.EntExtensions.RunOnBeforeConnect(p,drawing,DC);
    p:=ents2Connected.iterate(ir);
  until p=nil;


  p:=ents2Connected.beginiterate(ir);
  if p<>nil then repeat
      if IsIt(TypeOf(p^),typeof(GDBObjConnected)) then
        PGDBObjConnected(p)^.connectedtogdb(@ConnectedArea,drawing);
      if assigned(p^.EntExtensions)then
        p^.EntExtensions.RunOnConnect(p,drawing,DC);
      p:=ents2Connected.iterate(ir);
  until p=nil;

  if ConnectedArea.EntExtensions<>nil then begin
    p:=ents.beginiterate(ir);
    if p<>nil then repeat
      ConnectedArea.EntExtensions.RunConnectFormattedEntsToRoot(@ConnectedArea,p,drawing,DC);
      p:=ents.iterate(ir);
    until p=nil;
  end;

  p:=ents2Connected.beginiterate(ir);
  if p<>nil then repeat
    if assigned(p^.EntExtensions)then
      p^.EntExtensions.RunOnAfterConnect(p,drawing,DC);
    p:=ents2Connected.iterate(ir);
  until p=nil;

  ents2Connected.clear;

  p:=ents.beginiterate(ir);
  if p<>nil then repeat
    if p^.IsStagedFormatEntity then
      p^.Formatafteredit(drawing,dc,[EFDraw]);
    if lpsh<>LPSHEmpty then
      lps.ProgressLongProcess(lpsh,c+ir.itc);
    p:=ents.iterate(ir);
  until p=nil;

end;

procedure GDBObjRoot.formatafteredit;
var
  p:pGDBObjEntity;
  ir:itrec;
begin
  DoFormat(self,ObjCasheArray,ObjToConnectedArray,drawing,DC,LPSHEmpty,Stage);
  p:=ObjCasheArray.beginiterate(ir);
  if p<>nil then
  repeat
    if p^.bp.TreePos.Owner<>nil then begin
            self.ObjArray.RemoveFromTree(p);
            self.ObjArray.ObjTree.AddObjectToNodeTree(p^);
    end;
    p:=ObjCasheArray.iterate(ir);
  until p=nil;

  ObjCasheArray.clear;
  calcbb(dc);
end;
begin
end.

