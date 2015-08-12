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

unit GDBRoot;
{$INCLUDE def.inc}

interface
Uses
   {Varman,}gdbdrawcontext,ugdbdrawingdef,GDBCamera,glstatemanager,
   UGDBEntTree,{UGDBVisibleTreeArray,UGDBOpenArrayOfPV,}
   gdbase,gdbasetypes,gdbobjectsconstdef,varmandef,GDBEntity,GDBGenericSubEntry{,UGDBOpenArrayOfPV},GDBConnected,GDBSubordinated,geometry{,uunitmanager}{,shared};
type
{REGISTEROBJECTTYPE GDBObjRoot}
{Export+}
PGDBObjRoot=^GDBObjRoot;
GDBObjRoot={$IFNDEF DELPHI}packed{$ENDIF} object(GDBObjGenericSubEntry)
                 constructor initnul;
                 destructor done;virtual;
                 //function ImEdited(pobj:PGDBObjSubordinated;pobjinarray:GDBInteger):GDBInteger;virtual;
                 procedure FormatAfterEdit(const drawing:TDrawingDef;var DC:TDrawContext);virtual;
                 function AfterDeSerialize(SaveFlag:GDBWord; membuf:GDBPointer):integer;virtual;
                 function getowner:PGDBObjSubordinated;virtual;
                 function GetMainOwner:PGDBObjSubordinated;virtual;
                 procedure getoutbound;virtual;
                 //function FindVariable(varname:GDBString):pvardesk;virtual;
                 function GetHandle:GDBPlatformint;virtual;
                 function EraseMi(pobj:pGDBObjEntity;pobjinarray:GDBInteger;const drawing:TDrawingDef):GDBInteger;virtual;

                 function GetMatrix:PDMatrix4D;virtual;
                 procedure DrawWithAttrib(var DC:TDrawContext{visibleactualy:TActulity;subrender:GDBInteger});virtual;
                 function CalcInFrustum(frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity;var totalobj,infrustumobj:GDBInteger; ProjectProc:GDBProjectProc;const zoom:GDBDouble):GDBBoolean;virtual;
                 function CalcInFrustumByTree(frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity;var enttree:TEntTreeNode;var totalobj,infrustumobj:GDBInteger; ProjectProc:GDBProjectProc;const zoom:GDBDouble):GDBBoolean;virtual;
                 procedure calcbb;virtual;
                 //function FindShellByClass(_type:TDeviceClass):PGDBObjSubordinated;virtual;
           end;

{Export-}
implementation
uses
    log;
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
function GDBObjRoot.CalcInFrustumByTree(frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity;var enttree:TEntTreeNode;var totalobj,infrustumobj:GDBInteger; ProjectProc:GDBProjectProc;const zoom:GDBDouble):GDBBoolean;
var
   myfrustum:ClipArray;
begin
     myfrustum:=FrustumTransform(frustum,ObjMatrix);
     ProcessTree(myfrustum,infrustumactualy,visibleactualy,enttree,IRPartially,true,totalobj,infrustumobj,ProjectProc,zoom);
     self.VisibleOBJBoundingBox:=ObjArray.calcvisbb({gdb.GetCurrentDWG.pcamera^.POSCOUNT}{visibleactualy}infrustumactualy);
end;
function GDBObjRoot.CalcInFrustum;
var
   myfrustum:ClipArray;
begin
     myfrustum:=FrustumTransform(frustum,ObjMatrix);
     inherited CalcInFrustum(myfrustum,infrustumactualy,visibleactualy,totalobj,infrustumobj, ProjectProc,zoom);
end;
procedure GDBObjRoot.DrawWithAttrib;
begin
     oglsm.myglpushmatrix;
     oglsm.myglMultMatrixD(objmatrix);
     inherited;//self.ObjArray.DrawWithattrib;
     oglsm.myglpopmatrix;

end;
function GDBObjRoot.GetMatrix;
begin
     result:=@self.ObjMatrix{ @OneMatrix};
end;
function GDBObjRoot.EraseMi(pobj:pGDBObjEntity;pobjinarray:GDBInteger;const drawing:TDrawingDef):GDBInteger;
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
function GDBObjRoot.GetHandle:GDBPlatformint;
begin
     result:=H_Root;
end;
{function GDBObjRoot.FindVariable;
begin
     result:=PTObjectUnit(ou.Instance)^.FindVariable(varname);
end;}
procedure GDBObjRoot.getoutbound;
begin
     vp.BoundingBox.LBN:=geometry.NulVertex;
     vp.BoundingBox.RTF:=geometry.NulVertex;
     inherited;
end;
function GDBObjRoot.getowner;
begin
     result:=nil;
end;
function GDBObjRoot.AfterDeSerialize;
begin
     inherited AfterDeSerialize(SaveFlag,membuf);
     correctobjects(nil,-1);
     format;
end;
destructor GDBObjRoot.done;
begin
     ObjArray.FreeAndDone;
     self.ObjCasheArray.FreeAndDone;
     self.
     ObjToConnectedArray.FreeAndDone;
     inherited done;
end;
constructor GDBObjRoot.initnul;
{var
    prootonit:ptunit;}
begin
     inherited initnul(nil);
     bp.ListPos.owner:=nil;
     vp.ID:=GDBRootId;
     //bp.PSelfInOwnerArray:=nil;
     bp.ListPos.SelfIndex:=-1;
     ObjToConnectedArray.init({$IFDEF DEBUGBUILD}'{0AD3CD18-E887-4038-BADA-7616D9F52963}',{$ENDIF}100);
     {prootonit:=units.findunit('objroot');
     if prootonit<>nil then
                           PTObjectUnit(ou.Instance)^.copyfrom(units.findunit('objroot'));}
     //uunitmanager.units.loadunit(expandpath('*blocks\objroot.pas'),@ou);
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
                  self.ObjArray.ObjTree.AddObjectToNodeTree(p);
             end;
            p:=ObjCasheArray.iterate(ir);
       until p=nil;

       ObjCasheArray.clear;
       calcbb;


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
  {$IFDEF DEBUGINITSECTION}LogOut('GDBRoot.initialization');{$ENDIF}
end.

