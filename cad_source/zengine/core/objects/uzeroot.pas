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
{Export+}
PGDBObjRoot=^GDBObjRoot;
{REGISTEROBJECTTYPE GDBObjRoot}
GDBObjRoot= object(GDBObjGenericSubEntry)
                 constructor initnul;
                 destructor done;virtual;
                 //function ImEdited(pobj:PGDBObjSubordinated;pobjinarray:Integer):Integer;virtual;
                 procedure FormatAfterEdit(var drawing:TDrawingDef;var DC:TDrawContext;Stage:TEFStages=EFAllStages);virtual;
                 procedure AfterDeSerialize(SaveFlag:Word; membuf:Pointer);virtual;
                 function getowner:PGDBObjSubordinated;virtual;
                 procedure getoutbound(var DC:TDrawContext);virtual;
                 //function FindVariable(varname:String):pvardesk;virtual;
                 function GetHandle:PtrInt;virtual;
                 procedure EraseMi(pobj:pGDBObjEntity;pobjinarray:Integer;var drawing:TDrawingDef);virtual;

                 function GetMatrix:PDMatrix4D;virtual;
                 procedure DrawWithAttrib(var DC:TDrawContext{visibleactualy:TActulity;subrender:Integer});virtual;
                 function CalcInFrustum(const frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity;var totalobj,infrustumobj:Integer; ProjectProc:GDBProjectProc;const zoom,currentdegradationfactor:Double):Boolean;virtual;
                 procedure CalcInFrustumByTree(const frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity;var enttree:TEntTreeNode;var totalobj,infrustumobj:Integer; ProjectProc:GDBProjectProc;const zoom,currentdegradationfactor:Double);virtual;
                 procedure CalcVisibleBBByTree(infrustumactualy:TActulity;visibleactualy:TActulity;var enttree:TEntTreeNode);virtual;
                 procedure calcbb(var DC:TDrawContext);virtual;
                 //function FindShellByClass(_type:TDeviceClass):PGDBObjSubordinated;virtual;
                 function GetObjType:TObjID;virtual;
           end;

{Export-}
procedure DoFormat(var ConnectedArea:GDBObjGenericSubEntry;var ents,ents2Connected:GDBObjOpenArrayOfPV;var drawing:TDrawingDef;var DC:TDrawContext;lpsh:TLPSHandle;Stage:TEFStages{=EFAllStages});
implementation
//uses
//    log;
{function GDBObjRoot.FindShellByClass(_type:TDeviceClass):PGDBObjSubordinated;
begin
     result:=nil;
end;}
procedure GDBObjRoot.calcbb;
begin
     inherited;
     vp.BoundingBox.LBN:=VectorTransform3D(vp.BoundingBox.LBN,ObjMatrix);
     vp.BoundingBox.RTF:=VectorTransform3D(vp.BoundingBox.RTF,ObjMatrix);
end;
procedure GDBObjRoot.CalcVisibleBBByTree(infrustumactualy:TActulity;visibleactualy:TActulity;var enttree:TEntTreeNode);
begin
  InFrustumAABB:=enttree.NodeData.InFrustumBoundingBox;
end;
procedure GDBObjRoot.CalcInFrustumByTree(const frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity;var enttree:TEntTreeNode;var totalobj,infrustumobj:Integer; ProjectProc:GDBProjectProc;const zoom,currentdegradationfactor:Double);
var
   myfrustum:ClipArray;
begin
     myfrustum:=FrustumTransform(frustum,ObjMatrix);
     ProcessTree(myfrustum,infrustumactualy,visibleactualy,enttree,IRPartially,TDTFulDraw,totalobj,infrustumobj,ProjectProc,zoom,currentdegradationfactor);

     CalcVisibleBBByTree(infrustumactualy,visibleactualy,enttree);
     //InFrustumAABB:=ObjArray.calcvisbb(infrustumactualy);
end;
function GDBObjRoot.CalcInFrustum;
var
   myfrustum:ClipArray;
begin
     myfrustum:=FrustumTransform(frustum,ObjMatrix);
     result:=inherited CalcInFrustum(myfrustum,infrustumactualy,visibleactualy,totalobj,infrustumobj, ProjectProc,zoom,currentdegradationfactor);
end;
procedure GDBObjRoot.DrawWithAttrib;
begin
     DC.drawer.pushMatrixAndSetTransform(objmatrix);
     //oglsm.myglpushmatrix;
     //oglsm.myglMultMatrixD(objmatrix);
     inherited;//self.ObjArray.DrawWithattrib;
     DC.drawer.popMatrix;
     //oglsm.myglpopmatrix;

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
{function GDBObjRoot.FindVariable;
begin
     result:=PTObjectUnit(ou.Instance)^.FindVariable(varname);
end;}
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
procedure GDBObjRoot.AfterDeSerialize;
begin
     //inherited AfterDeSerialize(SaveFlag,membuf);
     correctobjects(nil,-1);
     //format;
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

