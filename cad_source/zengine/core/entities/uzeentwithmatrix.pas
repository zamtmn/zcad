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

unit uzeentwithmatrix;
{$INCLUDE def.inc}

interface
uses uzgldrawcontext,uzedrawingdef,uzecamera,uzeentity,uzbtypesbase,uzbtypes,
     uzegeometry,uzeentsubordinated,uzeentitiestree;
type
{EXPORT+}
PGDBObjWithMatrix=^GDBObjWithMatrix;
GDBObjWithMatrix={$IFNDEF DELPHI}packed{$ENDIF} object(GDBObjEntity)
                       ObjMatrix:DMatrix4D;(*'OCS Matrix'*)(*oi_readonly*)(*hidden_in_objinsp*)
                       constructor initnul(owner:PGDBObjGenericWithSubordinated);
                       function GetMatrix:PDMatrix4D;virtual;
                       procedure CalcObjMatrix;virtual;
                       procedure FormatEntity(var drawing:TDrawingDef;var DC:TDrawContext);virtual;
                       procedure createfield;virtual;
                       procedure transform(const t_matrix:DMatrix4D);virtual;
                       procedure ReCalcFromObjMatrix;virtual;abstract;
                       procedure CalcInFrustumByTree(frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity;var enttree:TEntTreeNode;var totalobj,infrustumobj:GDBInteger; ProjectProc:GDBProjectProc;const zoom,currentdegradationfactor:GDBDouble);virtual;
                       procedure ProcessTree(const frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity;var enttree:TEntTreeNode;OwnerInFrustum:TInBoundingVolume;OwnerFuldraw:GDBBoolean;var totalobj,infrustumobj:GDBInteger; ProjectProc:GDBProjectProc;const zoom,currentdegradationfactor:GDBDouble);virtual;
                 end;
{EXPORT-}
implementation
//uses
//    log{,zcadsysvars};
procedure GDBObjWithMatrix.ProcessTree(const frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity;var enttree:TEntTreeNode;OwnerInFrustum:TInBoundingVolume;OwnerFuldraw:GDBBoolean;var totalobj,infrustumobj:GDBInteger; ProjectProc:GDBProjectProc;const zoom,currentdegradationfactor:GDBDouble);
var
     ImInFrustum:TInBoundingVolume;
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
     v1:=uzegeometry.VertexSub(enttree.BoundingBox.RTF,enttree.BoundingBox.LBN);
     tx:=uzegeometry.oneVertexlength(v1);
     if tx/zoom<currentdegradationfactor then
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
                         pobj^.SetInFrustumFromTree(frustum,infrustumactualy,visibleactualy,totalobj,infrustumobj,ProjectProc,zoom,currentdegradationfactor);
                         //pobj^.infrustum:=infrustumactualy;
                         pobj:=enttree.nul.iterate(ir);
                   until pobj=nil;
                   if assigned(enttree.pminusnode) then
                                                       ProcessTree(frustum,infrustumactualy,visibleactualy,enttree.pminusnode^,IRFully,enttree.FulDraw,totalobj,infrustumobj,ProjectProc,zoom,currentdegradationfactor);
                   if assigned(enttree.pplusnode) then
                                                       ProcessTree(frustum,infrustumactualy,visibleactualy,enttree.pplusnode^,IRFully,enttree.FulDraw,totalobj,infrustumobj,ProjectProc,zoom,currentdegradationfactor);
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
                                           pobj^.SetInFrustumFromTree(frustum,infrustumactualy,visibleactualy,totalobj,infrustumobj,ProjectProc,zoom,currentdegradationfactor);
                                           //pobj^.infrustum:=infrustumactualy;
                                           pobj:=enttree.nul.iterate(ir);
                                     until pobj=nil;
                                     if assigned(enttree.pminusnode) then
                                                                         ProcessTree(frustum,infrustumactualy,visibleactualy,enttree.pminusnode^,ImInFrustum,enttree.FulDraw,totalobj,infrustumobj,ProjectProc,zoom,currentdegradationfactor);
                                     if assigned(enttree.pplusnode) then
                                                                         ProcessTree(frustum,infrustumactualy,visibleactualy,enttree.pplusnode^,ImInFrustum,enttree.FulDraw,totalobj,infrustumobj,ProjectProc,zoom,currentdegradationfactor);

                              end;
                  IRPartially:begin
                                     enttree.infrustum:=infrustumactualy;
                                     pobj:=enttree.nul.beginiterate(ir);
                                     if pobj<>nil then
                                     repeat
                                           if pobj^.CalcInFrustum(frustum,infrustumactualy,visibleactualy,totalobj,infrustumobj,ProjectProc,zoom,currentdegradationfactor) then
                                           begin
                                                pobj^.SetInFrustumFromTree(frustum,infrustumactualy,visibleactualy,totalobj,infrustumobj,ProjectProc,zoom,currentdegradationfactor);
                                           end;
                                           pobj:=enttree.nul.iterate(ir);
                                     until pobj=nil;
                                     if assigned(enttree.pminusnode) then
                                                                         ProcessTree(frustum,infrustumactualy,visibleactualy,enttree.pminusnode^,IRPartially,enttree.FulDraw,totalobj,infrustumobj,ProjectProc,zoom,currentdegradationfactor);
                                     if assigned(enttree.pplusnode) then
                                                                         ProcessTree(frustum,infrustumactualy,visibleactualy,enttree.pplusnode^,IRPartially,enttree.FulDraw,totalobj,infrustumobj,ProjectProc,zoom,currentdegradationfactor);

                              end;
                  end;

             end;
     end;
end;

procedure GDBObjWithMatrix.CalcInFrustumByTree(frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity;var enttree:TEntTreeNode;var totalobj,infrustumobj:GDBInteger; ProjectProc:GDBProjectProc;const zoom,currentdegradationfactor:GDBDouble);
begin
     ProcessTree(frustum,infrustumactualy,visibleactualy,enttree,IRPartially,true,totalobj,infrustumobj,ProjectProc,zoom,currentdegradationfactor)
end;

procedure GDBObjWithMatrix.transform(const t_matrix:DMatrix4D);
begin
     ObjMatrix:=uzegeometry.MatrixMultiply(ObjMatrix,t_matrix);
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
procedure GDBObjWithMatrix.FormatEntity(var drawing:TDrawingDef;var DC:TDrawContext);
begin
     CalcObjMatrix;
end;
constructor GDBObjWithMatrix.initnul;
begin
     inherited initnul(owner);
     CalcObjMatrix;
end;
begin
end.
