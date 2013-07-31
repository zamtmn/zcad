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
uses ugdbdrawingdef, GDBCamera, GDBEntity,gdbase,gdbasetypes,geometry,GDBSubordinated,UGDBEntTree;
type
{EXPORT+}
PGDBObjWithMatrix=^GDBObjWithMatrix;
GDBObjWithMatrix={$IFNDEF DELPHI}packed{$ENDIF} object(GDBObjEntity)
                       ObjMatrix:DMatrix4D;(*'OCS Matrix'*)
                       constructor initnul(owner:PGDBObjGenericWithSubordinated);
                       function GetMatrix:PDMatrix4D;virtual;
                       procedure CalcObjMatrix;virtual;
                       procedure FormatEntity(const drawing:TDrawingDef);virtual;
                       procedure createfield;virtual;
                       procedure transform(const t_matrix:DMatrix4D);virtual;
                       procedure ReCalcFromObjMatrix;virtual;abstract;
                       function CalcInFrustumByTree(frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity;var enttree:TEntTreeNode;var totalobj,infrustumobj:GDBInteger; ProjectProc:GDBProjectProc;const zoom:GDBDouble):GDBBoolean;virtual;
                       procedure ProcessTree(const frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity;var enttree:TEntTreeNode;OwnerInFrustum:TInRect;OwnerFuldraw:GDBBoolean;var totalobj,infrustumobj:GDBInteger; ProjectProc:GDBProjectProc;const zoom:GDBDouble);virtual;
                 end;
{EXPORT-}
implementation
uses
    log,zcadsysvars;
procedure GDBObjWithMatrix.ProcessTree(const frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity;var enttree:TEntTreeNode;OwnerInFrustum:TInRect;OwnerFuldraw:GDBBoolean;var totalobj,infrustumobj:GDBInteger; ProjectProc:GDBProjectProc;const zoom:GDBDouble);
var
     ImInFrustum:TInRect;
     pobj:PGDBObjEntity;
     ir:itrec;
     v1{,v2,v3}:gdbvertex;
     tx:double;
     //bb:GDBBoundingBbox;
begin
     //enttree.FulDraw:=true;
     if OwnerFuldraw then
     begin
     {вариант с точным расчетом - медленный((
     gdb.GetCurrentDWG^.myGluProject2(createvertex(enttree.BoundingBox.LBN.x,enttree.BoundingBox.LBN.y,enttree.BoundingBox.LBN.Z),v1);
     bb.LBN:=v1;
     bb.RTF:=v1;
     gdb.GetCurrentDWG^.myGluProject2(createvertex(enttree.BoundingBox.RTF.x,enttree.BoundingBox.LBN.y,enttree.BoundingBox.LBN.Z),v1);
     concatBBandPoint(bb, v1);
     gdb.GetCurrentDWG^.myGluProject2(createvertex(enttree.BoundingBox.RTF.x,enttree.BoundingBox.RTF.y,enttree.BoundingBox.LBN.Z),v1);
     concatBBandPoint(bb, v1);
     gdb.GetCurrentDWG^.myGluProject2(createvertex(enttree.BoundingBox.LBN.x,enttree.BoundingBox.RTF.y,enttree.BoundingBox.LBN.Z),v1);
     concatBBandPoint(bb, v1);

     gdb.GetCurrentDWG^.myGluProject2(createvertex(enttree.BoundingBox.LBN.x,enttree.BoundingBox.LBN.y,enttree.BoundingBox.RTF.Z),v1);
     concatBBandPoint(bb, v1);
     gdb.GetCurrentDWG^.myGluProject2(createvertex(enttree.BoundingBox.RTF.x,enttree.BoundingBox.LBN.y,enttree.BoundingBox.RTF.Z),v1);
     concatBBandPoint(bb, v1);
     gdb.GetCurrentDWG^.myGluProject2(createvertex(enttree.BoundingBox.RTF.x,enttree.BoundingBox.RTF.y,enttree.BoundingBox.RTF.Z),v1);
     concatBBandPoint(bb, v1);
     gdb.GetCurrentDWG^.myGluProject2(createvertex(enttree.BoundingBox.LBN.x,enttree.BoundingBox.RTF.y,enttree.BoundingBox.RTF.Z),v1);
     concatBBandPoint(bb, v1);
     v1:=bb.RTF;
     v2:=bb.LBN;}

     {вариант с  неточным расчетом - неточный}
     {ProjectProc(enttree.BoundingBox.LBN,v1);
     ProjectProc(enttree.BoundingBox.RTF,v2);

     if abs((v2.x-v1.x)*(v2.y-v1.y))<10 then
                                            begin
                                                 ProjectProc(createvertex(enttree.BoundingBox.LBN.x,enttree.BoundingBox.RTF.y,enttree.BoundingBox.LBN.Z),v1);
                                                 ProjectProc(createvertex(enttree.BoundingBox.RTF.x,enttree.BoundingBox.LBN.y,enttree.BoundingBox.RTF.Z),v2);
                                                 if abs((v2.x-v1.x)*(v2.y-v1.y))<10 then
                                                                                        enttree.FulDraw:=false
                                                                                    else
                                                                                        enttree.FulDraw:=true;
                                            end
                                         else
                                             enttree.FulDraw:=true;}
     v1:=geometry.VertexSub(enttree.BoundingBox.RTF,enttree.BoundingBox.LBN);
     tx:=geometry.oneVertexlength(v1);
     if tx/zoom<SysVar.RD.RD_ImageDegradation.RD_ID_CurrentDegradationFactor then
                                                                                        enttree.FulDraw:=false
                                                                                    else
                                                                                        enttree.FulDraw:=true;
     end
     else
         enttree.FulDraw:=false;
     case OwnerInFrustum of
     IREmpty:begin
                   OwnerInFrustum:=OwnerInFrustum;
             end;
     IRFully:begin
                   enttree.infrustum:=infrustumactualy;
                   pobj:=enttree.nul.beginiterate(ir);
                   if pobj<>nil then
                   repeat
                         pobj^.SetInFrustumFromTree(frustum,infrustumactualy,visibleactualy,totalobj,infrustumobj,ProjectProc,zoom);
                         //pobj^.infrustum:=infrustumactualy;
                         pobj:=enttree.nul.iterate(ir);
                   until pobj=nil;
                   if assigned(enttree.pminusnode) then
                                                       ProcessTree(frustum,infrustumactualy,visibleactualy,enttree.pminusnode^,IRFully,enttree.FulDraw,totalobj,infrustumobj,ProjectProc,zoom);
                   if assigned(enttree.pplusnode) then
                                                       ProcessTree(frustum,infrustumactualy,visibleactualy,enttree.pplusnode^,IRFully,enttree.FulDraw,totalobj,infrustumobj,ProjectProc,zoom);
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
                                           pobj^.SetInFrustumFromTree(frustum,infrustumactualy,visibleactualy,totalobj,infrustumobj,ProjectProc,zoom);
                                           //pobj^.infrustum:=infrustumactualy;
                                           pobj:=enttree.nul.iterate(ir);
                                     until pobj=nil;
                                     if assigned(enttree.pminusnode) then
                                                                         ProcessTree(frustum,infrustumactualy,visibleactualy,enttree.pminusnode^,ImInFrustum,enttree.FulDraw,totalobj,infrustumobj,ProjectProc,zoom);
                                     if assigned(enttree.pplusnode) then
                                                                         ProcessTree(frustum,infrustumactualy,visibleactualy,enttree.pplusnode^,ImInFrustum,enttree.FulDraw,totalobj,infrustumobj,ProjectProc,zoom);

                              end;
                  IRPartially:begin
                                     enttree.infrustum:=infrustumactualy;
                                     pobj:=enttree.nul.beginiterate(ir);
                                     if pobj<>nil then
                                     repeat
                                           if pobj^.CalcInFrustum(frustum,infrustumactualy,visibleactualy,totalobj,infrustumobj,ProjectProc,zoom) then
                                           begin
                                                pobj^.SetInFrustumFromTree(frustum,infrustumactualy,visibleactualy,totalobj,infrustumobj,ProjectProc,zoom);
                                           end;
                                           pobj:=enttree.nul.iterate(ir);
                                     until pobj=nil;
                                     if assigned(enttree.pminusnode) then
                                                                         ProcessTree(frustum,infrustumactualy,visibleactualy,enttree.pminusnode^,IRPartially,enttree.FulDraw,totalobj,infrustumobj,ProjectProc,zoom);
                                     if assigned(enttree.pplusnode) then
                                                                         ProcessTree(frustum,infrustumactualy,visibleactualy,enttree.pplusnode^,IRPartially,enttree.FulDraw,totalobj,infrustumobj,ProjectProc,zoom);

                              end;
                  end;

             end;
     end;
end;

function GDBObjWithMatrix.CalcInFrustumByTree(frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity;var enttree:TEntTreeNode;var totalobj,infrustumobj:GDBInteger; ProjectProc:GDBProjectProc;const zoom:GDBDouble):GDBBoolean;
begin
     ProcessTree(frustum,infrustumactualy,visibleactualy,enttree,IRPartially,true,totalobj,infrustumobj,ProjectProc,zoom)
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
procedure GDBObjWithMatrix.FormatEntity(const drawing:TDrawingDef);
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
