{
*****************************************************************************
*                                                                           *
*  This file is part of the ZCAD                                            *
*                                                                           *
*  See the file COPYING.modifiedLGPL.txt, included in this distribution,    *
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
{$INCLUDE zcadconfig.inc}

interface
Uses
   uzgldrawcontext,uzedrawingdef,uzecamera,uzeentitiestree,uzbtypes,
   uzeconsts,uzeentity,uzeentgenericsubentry,uzeentconnected,uzeentsubordinated,
   gzctnrVectorTypes,uzegeometrytypes,uzegeometry;
type
{Export+}
PGDBObjRoot=^GDBObjRoot;
{REGISTEROBJECTTYPE GDBObjRoot}
GDBObjRoot= object(GDBObjGenericSubEntry)
                 constructor initnul;
                 destructor done;virtual;
                 //function ImEdited(pobj:PGDBObjSubordinated;pobjinarray:Integer):Integer;virtual;
                 procedure FormatAfterEdit(var drawing:TDrawingDef;var DC:TDrawContext);virtual;
                 procedure AfterDeSerialize(SaveFlag:Word; membuf:Pointer);virtual;
                 function getowner:PGDBObjSubordinated;virtual;
                 function GetMainOwner:PGDBObjSubordinated;virtual;
                 procedure getoutbound(var DC:TDrawContext);virtual;
                 //function FindVariable(varname:String):pvardesk;virtual;
                 function GetHandle:PtrInt;virtual;
                 procedure EraseMi(pobj:pGDBObjEntity;pobjinarray:Integer;var drawing:TDrawingDef);virtual;

                 function GetMatrix:PDMatrix4D;virtual;
                 procedure DrawWithAttrib(var DC:TDrawContext{visibleactualy:TActulity;subrender:Integer});virtual;
                 function CalcInFrustum(frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity;var totalobj,infrustumobj:Integer; ProjectProc:GDBProjectProc;const zoom,currentdegradationfactor:Double):Boolean;virtual;
                 procedure CalcInFrustumByTree(frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity;var enttree:TEntTreeNode;var totalobj,infrustumobj:Integer; ProjectProc:GDBProjectProc;const zoom,currentdegradationfactor:Double);virtual;
                 procedure calcbb(var DC:TDrawContext);virtual;
                 //function FindShellByClass(_type:TDeviceClass):PGDBObjSubordinated;virtual;
                 function GetObjType:TObjID;virtual;
           end;

{Export-}
implementation
//uses
//    log;
function GDBObjRoot.GetMainOwner:PGDBObjSubordinated;
begin
     result:=@self;
end;
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
procedure GDBObjRoot.CalcInFrustumByTree(frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity;var enttree:TEntTreeNode;var totalobj,infrustumobj:Integer; ProjectProc:GDBProjectProc;const zoom,currentdegradationfactor:Double);
var
   myfrustum:ClipArray;
begin
     myfrustum:=FrustumTransform(frustum,ObjMatrix);
     ProcessTree(myfrustum,infrustumactualy,visibleactualy,enttree,IRPartially,TDTFulDraw,totalobj,infrustumobj,ProjectProc,zoom,currentdegradationfactor);
     self.VisibleOBJBoundingBox:=ObjArray.calcvisbb({gdb.GetCurrentDWG.pcamera^.POSCOUNT}{visibleactualy}infrustumactualy);
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
     result:=@self.ObjMatrix{ @OneMatrix};
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
     ObjArray.Done;
     self.ObjCasheArray.Done;
     self.
     ObjToConnectedArray.Done;
     inherited done;
end;
constructor GDBObjRoot.initnul;
{var
    prootonit:ptunit;}
begin
     inherited initnul(nil);
     bp.ListPos.owner:=nil;
     //vp.ID:=GDBRootId;
     //bp.PSelfInOwnerArray:=nil;
     bp.ListPos.SelfIndex:=-1;
     ObjToConnectedArray.init(100);
     {prootonit:=units.findunit('objroot');
     if prootonit<>nil then
                           PTObjectUnit(ou.Instance)^.copyfrom(units.findunit('objroot'));}
     //uunitmanager.units.loadunit(expandpath('*blocks\objroot.pas'),@ou);
end;
function GDBObjRoot.GetObjType;
begin
     result:=GDBRootId;
end;
procedure GDBObjRoot.formatafteredit;
var pobj:PGDBObjConnected;
    p:pGDBObjEntity;
    ir:itrec;
begin

     //inherited formatafteredit;
       ObjCasheArray.Formatafteredit(drawing,dc);

       p:=ObjCasheArray.beginiterate(ir);
       if p<>nil then
       repeat
             if p^.bp.TreePos.Owner<>nil then
             begin
                  self.ObjArray.RemoveFromTree(p);
                  self.ObjArray.ObjTree.AddObjectToNodeTree(p^);
             end;
            p:=ObjCasheArray.iterate(ir);
       until p=nil;

       ObjCasheArray.clear;
       calcbb(dc);


     pobj:=self.ObjToConnectedArray.beginiterate(ir);
     if pobj<>nil then
     repeat
           pobj^.connectedtogdb(@self,drawing);

           pobj:=self.ObjToConnectedArray.iterate(ir);
     until pobj=nil;
     self.ObjToConnectedArray.clear;


  {ObjCasheArray.Format;
  ObjCasheArray.clear;
  vp.BoundingBox:=objarray.calcbb;
  restructure;}
end;
begin
end.

