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

unit GDBWithMatrix;
{$INCLUDE def.inc}

interface
uses GDBEntity,gdbase,gdbasetypes,geometry,GDBSubordinated,UGDBEntTree;
type
{EXPORT+}
PGDBObjWithMatrix=^GDBObjWithMatrix;
GDBObjWithMatrix=object(GDBObjEntity)
                       ObjMatrix:DMatrix4D;(*'OCS Matrix'*)
                       constructor initnul(owner:PGDBObjGenericWithSubordinated);
                       function GetMatrix:PDMatrix4D;virtual;
                       procedure CalcObjMatrix;virtual;
                       procedure Format;virtual;
                       procedure createfield;virtual;
                       procedure transform(const t_matrix:DMatrix4D);virtual;
                       procedure ReCalcFromObjMatrix;virtual;abstract;
                       function CalcInFrustumByTree(frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity;var enttree:TEntTreeNode):GDBBoolean;virtual;
                       procedure ProcessTree(const frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity;var enttree:TEntTreeNode;OwnerInFrustum:TInRect);virtual;
                 end;
{EXPORT-}
implementation
uses
    log,ugdbdescriptor;
procedure GDBObjWithMatrix.ProcessTree(const frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity;var enttree:TEntTreeNode;OwnerInFrustum:TInRect);
var
     ImInFrustum:TInRect;
     pobj:PGDBObjEntity;
     ir:itrec;
     v1,v2:gdbvertex;
begin
     //enttree.FulDraw:=random(100)<80;
     gdb.GetCurrentDWG^.myGluProject2(enttree.BoundingBox.LBN,v1);
     gdb.GetCurrentDWG^.myGluProject2(enttree.BoundingBox.RTF,v2);
     if abs((v2.x-v1.x)*(v2.y-v1.y))<10 then
                                             enttree.FulDraw:=false
                                         else
                                             enttree.FulDraw:=true;
     //enttree.FulDraw:=true;
     case OwnerInFrustum of
     IREmpty:begin
                   OwnerInFrustum:=OwnerInFrustum;
             end;
     IRFully:begin
                   enttree.infrustum:=infrustumactualy;
                   pobj:=enttree.nul.beginiterate(ir);
                   if pobj<>nil then
                   repeat
                         pobj^.SetInFrustumFromTree(frustum,infrustumactualy,visibleactualy);
                         //pobj^.infrustum:=infrustumactualy;
                         pobj:=enttree.nul.iterate(ir);
                   until pobj=nil;
                   if assigned(enttree.pminusnode) then
                                                       ProcessTree(frustum,infrustumactualy,visibleactualy,enttree.pminusnode^,IRFully);
                   if assigned(enttree.pplusnode) then
                                                       ProcessTree(frustum,infrustumactualy,visibleactualy,enttree.pplusnode^,IRFully);
             end;
 IRPartially:begin
                  ImInFrustum:=CalcAABBInFrustum(enttree.BoundingBox,frustum);
                  case ImInFrustum of
                       IREmpty:begin
                                     OwnerInFrustum:=OwnerInFrustum;
                               end;
                       IRFully{,IRPartially}:begin
                                     enttree.infrustum:=infrustumactualy;
                                     pobj:=enttree.nul.beginiterate(ir);
                                     if pobj<>nil then
                                     repeat
                                           pobj^.SetInFrustumFromTree(frustum,infrustumactualy,visibleactualy);
                                           //pobj^.infrustum:=infrustumactualy;
                                           pobj:=enttree.nul.iterate(ir);
                                     until pobj=nil;
                                     if assigned(enttree.pminusnode) then
                                                                         ProcessTree(frustum,infrustumactualy,visibleactualy,enttree.pminusnode^,ImInFrustum);
                                     if assigned(enttree.pplusnode) then
                                                                         ProcessTree(frustum,infrustumactualy,visibleactualy,enttree.pplusnode^,ImInFrustum);

                              end;
                  IRPartially:begin
                                     enttree.infrustum:=infrustumactualy;
                                     pobj:=enttree.nul.beginiterate(ir);
                                     if pobj<>nil then
                                     repeat
                                           if pobj^.CalcInFrustum(frustum,infrustumactualy,visibleactualy) then
                                           begin
                                                pobj^.SetInFrustumFromTree(frustum,infrustumactualy,visibleactualy);
                                           end;
                                           pobj:=enttree.nul.iterate(ir);
                                     until pobj=nil;
                                     if assigned(enttree.pminusnode) then
                                                                         ProcessTree(frustum,infrustumactualy,visibleactualy,enttree.pminusnode^,IRPartially);
                                     if assigned(enttree.pplusnode) then
                                                                         ProcessTree(frustum,infrustumactualy,visibleactualy,enttree.pplusnode^,IRPartially);

                              end;
                  end;

             end;
     end;
end;

function GDBObjWithMatrix.CalcInFrustumByTree(frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity;var enttree:TEntTreeNode):GDBBoolean;
begin
     ProcessTree(frustum,infrustumactualy,visibleactualy,enttree,IRPartially)
end;

procedure GDBObjWithMatrix.transform(const t_matrix:DMatrix4D);
begin
     ObjMatrix:=geometry.MatrixMultiply(ObjMatrix,t_matrix);
end;
procedure GDBObjWithMatrix.createfield;
begin
     inherited;
     objmatrix:=onematrix;
end;
function GDBObjWithMatrix.GetMatrix;
begin
     result:=@ObjMatrix;
end;
procedure GDBObjWithMatrix.CalcObjMatrix;
begin
     ObjMatrix:=OneMatrix;
end;
procedure GDBObjWithMatrix.Format;
begin
     CalcObjMatrix;
end;
constructor GDBObjWithMatrix.initnul;
begin
     inherited initnul(owner);
     CalcObjMatrix;
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('GDBWithMatrix.initialization');{$ENDIF}
end.
