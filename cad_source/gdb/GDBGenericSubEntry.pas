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

unit GDBGenericSubEntry;
{$INCLUDE def.inc}

interface
uses UGDBDrawingdef,GDBCamera,zcadsysvars,UGDBLayerArray,UGDBOpenArrayOfPObjects,UGDBVisibleTreeArray,UGDBOpenArrayOfPV,gdbasetypes,{GDBWithLocalCS,}GDBWithMatrix,GDBSubordinated,gdbase,
geometry{,GDB3d},{UGDBVisibleOpenArray,}gdbEntity,gdbobjectsconstdef,varmandef,memman,UGDBEntTree;
type
//GDBObjGenericSubEntry=object(GDBObjWithLocalCS)
//GDBObjGenericSubEntry=object(GDBObj3d)
{Export+}
PTDrawingPreCalcData=^TDrawingPreCalcData;
TDrawingPreCalcData=packed record
                          InverseObjMatrix:DMatrix4D;
                    end;
PGDBObjGenericSubEntry=^GDBObjGenericSubEntry;
GDBObjGenericSubEntry={$IFNDEF DELPHI}packed{$ENDIF} object(GDBObjWithMatrix)
                            ObjArray:GDBObjEntityTreeArray;(*saved_to_shd*)
                            ObjCasheArray:GDBObjOpenArrayOfPV;
                            ObjToConnectedArray:GDBObjOpenArrayOfPV;
                            lstonmouse:PGDBObjEntity;
                            VisibleOBJBoundingBox:GDBBoundingBbox;
                            //ObjTree:TEntTreeNode;
                            function AddObjectToObjArray(p:GDBPointer):GDBInteger;virtual;
                            function GoodAddObjectToObjArray(const obj:GDBObjEntity):GDBInteger;virtual;
                            {function AddObjectToNodeTree(pobj:PGDBObjEntity):GDBInteger;virtual;
                            function CorrectNodeTreeBB(pobj:PGDBObjEntity):GDBInteger;virtual;}
                            constructor initnul(owner:PGDBObjGenericWithSubordinated);
                            procedure DrawGeometry(lw:GDBInteger;var DC:TDrawContext{infrustumactualy:TActulity;subrender:GDBInteger});virtual;
                            function CalcInFrustum(frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity;var totalobj,infrustumobj:GDBInteger; ProjectProc:GDBProjectProc;const zoom:GDBDouble):GDBBoolean;virtual;
                            function onmouse(var popa:GDBOpenArrayOfPObjects;const MF:ClipArray):GDBBoolean;virtual;
                            procedure FormatEntity(const drawing:TDrawingDef);virtual;
                            procedure FormatAfterEdit(const drawing:TDrawingDef);virtual;
                            procedure restructure(const drawing:TDrawingDef);virtual;
                            procedure renderfeedbac(infrustumactualy:TActulity;pcount:TActulity;var camera:GDBObjCamera; ProjectProc:GDBProjectProc);virtual;
                            //function select:GDBBoolean;virtual;
                            function getowner:PGDBObjSubordinated;virtual;
                            function CanAddGDBObj(pobj:PGDBObjEntity):GDBBoolean;virtual;
                            function EubEntryType:GDBInteger;virtual;
                            function MigrateTo(new_sub:PGDBObjGenericSubEntry):GDBInteger;virtual;
                            function EraseMi(pobj:pGDBObjEntity;pobjinarray:GDBInteger;const drawing:TDrawingDef):GDBInteger;virtual;
                            function RemoveMiFromArray(pobj:pGDBObjEntity;pobjinarray:GDBInteger):GDBInteger;virtual;
                            function GoodRemoveMiFromArray(const obj:GDBObjEntity):GDBInteger;virtual;
                            {function SubMi(pobj:pGDBObjEntity):GDBInteger;virtual;}
                            function AddMi(pobj:PGDBObjSubordinated):PGDBpointer;virtual;
                            function ImEdited(pobj:PGDBObjSubordinated;pobjinarray:GDBInteger;const drawing:TDrawingDef):GDBInteger;virtual;
                            function ReturnLastOnMouse:PGDBObjEntity;virtual;
                            procedure correctobjects(powner:PGDBObjEntity;pinownerarray:GDBInteger);virtual;
                            destructor done;virtual;
                            procedure getoutbound;virtual;
                            procedure getonlyoutbound;virtual;

                            procedure DrawBB;

                            procedure RemoveInArray(pobjinarray:GDBInteger);virtual;
                            procedure DrawWithAttrib(var DC:TDrawContext{visibleactualy:TActulity;subrender:GDBInteger});virtual;

                            function CreatePreCalcData:PTDrawingPreCalcData;virtual;
                            procedure DestroyPreCalcData(PreCalcData:PTDrawingPreCalcData);virtual;

                            //procedure ProcessTree(const frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity;var enttree:TEntTreeNode;OwnerInFrustum:TInRect);
                            //function CalcVisibleByTree(frustum:ClipArray;infrustumactualy:TActulity;const enttree:TEntTreeNode):GDBBoolean;virtual;
                              function CalcVisibleByTree(frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity;var enttree:TEntTreeNode;var totalobj,infrustumobj:GDBInteger; ProjectProc:GDBProjectProc;const zoom:GDBDouble):GDBBoolean;virtual;
                              //function CalcInFrustumByTree(frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity;var enttree:TEntTreeNode):GDBBoolean;virtual;
                              procedure SetInFrustumFromTree(const frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity;var totalobj,infrustumobj:GDBInteger; ProjectProc:GDBProjectProc;const zoom:GDBDouble);virtual;

                              //function FindObjectsInPointStart(const point:GDBVertex;out Objects:GDBObjOpenArrayOfPV):GDBBoolean;virtual;
                              function FindObjectsInPoint(const point:GDBVertex;var Objects:GDBObjOpenArrayOfPV):GDBBoolean;virtual;
                              function FindObjectsInPointSlow(const point:GDBVertex;var Objects:GDBObjOpenArrayOfPV):GDBBoolean;
                              function FindObjectsInPointInNode(const point:GDBVertex;const Node:TEntTreeNode;var Objects:GDBObjOpenArrayOfPV):GDBBoolean;
                              //function FindObjectsInPointDone(const point:GDBVertex):GDBBoolean;virtual;
                              function onpoint(var objects:GDBOpenArrayOfPObjects;const point:GDBVertex):GDBBoolean;virtual;
                              procedure correctsublayers(var la:GDBLayerArray);virtual;
                              function CalcTrueInFrustum(frustum:ClipArray;visibleactualy:TActulity):TInRect;virtual;

                      end;
{Export-}
implementation
uses OGLSpecFunc,log;
{function GDBObjGenericSubEntry.SubMi;
begin
     //pobj^.bp.PSelfInOwnerArray:=ObjArray.getelement(ObjArray.add(pobj));
     ObjArray.add(pobj);
     pGDBObjEntity(ppointer(pobj)^).bp.Owner:=@self;
end;}
{function GDBObjGenericSubEntry.CorrectNodeTreeBB(pobj:PGDBObjEntity):GDBInteger;
begin
     ConcatBB(ObjTree.BoundingBox,pobj^.vp.BoundingBox);
end;

function GDBObjGenericSubEntry.AddObjectToNodeTree(pobj:PGDBObjEntity):GDBInteger;
begin
    ObjTree.addtonul(pobj);
    CorrectNodeTreeBB(pobj);
end;}
function GDBObjGenericSubEntry.CalcTrueInFrustum;
begin
      result:=ObjArray.CalcTrueInFrustum(frustum,visibleactualy);
end;

procedure GDBObjGenericSubEntry.correctsublayers(var la:GDBLayerArray);
var p:pGDBObjEntity;
//    i:GDBInteger;
        ir:itrec;
begin
     if objarray.Count=0 then exit;
     p:=objarray.beginiterate(ir);
     if p<>nil then
     repeat
          p^.vp.Layer:=la.createlayerifneed(p^.vp.Layer);
          p^.correctsublayers(la);
     p:=objarray.iterate(ir);
     until p=nil;
end;
function GDBObjGenericSubEntry.FindObjectsInPointSlow(const point:GDBVertex;var Objects:GDBObjOpenArrayOfPV):GDBBoolean;
var
    //minus:gdbboolean{$IFNDEF DELPHI}=false{$ENDIF};
    //plus:gdbboolean{$IFNDEF DELPHI}=false{$ENDIF};
    pobj:PGDBObjEntity;
    ir:itrec;
begin
     pobj:=objarray.beginiterate(ir);
     if pobj<>nil then
     repeat
           if pobj^.onpoint(Objects,point) then
           begin
                result:=true;
                //Objects.Add(@pobj);
           end;

           pobj:=objarray.iterate(ir);
     until pobj=nil;

     //result:=result or (plus or minus);
     //self.ObjArray.ObjTree.BoundingBox;
end;

function GDBObjGenericSubEntry.FindObjectsInPointInNode(const point:GDBVertex;const Node:TEntTreeNode;var Objects:GDBObjOpenArrayOfPV):GDBBoolean;
var
    minus:gdbboolean{$IFNDEF DELPHI}=false{$ENDIF};
    plus:gdbboolean{$IFNDEF DELPHI}=false{$ENDIF};
    pobj:PGDBObjEntity;
    ir:itrec;
begin
     if assigned(Node.pminusnode) then
       if geometry.IsPointInBB(point,Node.pminusnode.BoundingBox) then
       begin
            minus:=FindObjectsInPointInNode(point,Node.pminusnode^,Objects);
       end;
     if assigned(Node.pplusnode) then
       if geometry.IsPointInBB(point,Node.pplusnode.BoundingBox) then
       begin
            plus:=FindObjectsInPointInNode(point,Node.pplusnode^,Objects);
       end;

       pobj:=Node.nul.beginiterate(ir);
     if pobj<>nil then
     repeat
           if pobj^.onpoint(Objects,point) then
           begin
                result:=true;
                //Objects.Add(@pobj);
           end;

           pobj:=Node.nul.iterate(ir);
     until pobj=nil;

     result:=result or (plus or minus);
     //self.ObjArray.ObjTree.BoundingBox;
end;

function GDBObjGenericSubEntry.FindObjectsInPoint(const point:GDBVertex;var Objects:GDBObjOpenArrayOfPV):GDBBoolean;
begin
     if geometry.IsPointInBB(point,self.ObjArray.ObjTree.BoundingBox) then
     begin
          result:=FindObjectsInPointInNode(point,ObjArray.ObjTree,Objects);
     end
     else
         result:=false;
end;
function GDBObjGenericSubEntry.GoodAddObjectToObjArray(const obj:GDBObjEntity):GDBInteger;
var
    p:pointer;
begin
     p:=@obj;
     AddObjectToObjArray(@p);
end;

function GDBObjGenericSubEntry.AddObjectToObjArray(p:GDBPointer):GDBInteger;
begin
     result:=ObjArray.add(p);
     PGDBObjEntity(p^).bp.ListPos.Owner:=@self;
     //ObjArray.ObjTree.AddObjectToNodeTree(PGDBObjEntity(p^));
end;
procedure GDBObjGenericSubEntry.SetInFrustumFromTree;
begin
     inherited;
     ObjArray.SetInFrustumFromTree(frustum,infrustumactualy,visibleactualy,totalobj,infrustumobj, ProjectProc,zoom);
end;
(*function GDBObjGenericSubEntry.CalcInFrustumByTree(frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity;var enttree:TEntTreeNode):GDBBoolean;
begin
     ProcessTree(frustum,infrustumactualy,visibleactualy,enttree,IRPartially)
end;*)
function GDBObjGenericSubEntry.CalcVisibleByTree(frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity;var enttree:TEntTreeNode;var totalobj,infrustumobj:GDBInteger; ProjectProc:GDBProjectProc;const zoom:GDBDouble):GDBBoolean;
begin
  {$IFDEF PERFOMANCELOG}log.programlog.LogOutStrFast('GDBObjGenericSubEntry.CalcVisibleByTree',lp_incPos);{$ENDIF}
  visible:=visibleactualy;
     result:=true;
     //inc(gdb.GetCurrentDWG.pcamera^.totalobj);
     {if }CalcInFrustumByTree(frustum,infrustumactualy,visibleactualy,enttree,totalobj,infrustumobj,ProjectProc,zoom);{ then}
             {             begin
                               setinfrustum(infrustumactualy);
                          end
                      else
                          begin
                               setnotinfrustum(infrustumactualy);
                               visible:=false;
                               result:=false;
                          end;}
     if self.vp.Layer<>nil then
     if not(self.vp.Layer._on) then
                          begin
                               visible:=0;
                               result:=false;
                          end;
     {$IFDEF PERFOMANCELOG}log.programlog.LogOutStrFast('GDBObjGenericSubEntry.CalcVisibleByTree----{end}',lp_decPos);{$ENDIF}
end;
(*procedure GDBObjGenericSubEntry.ProcessTree(const frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity;var enttree:TEntTreeNode;OwnerInFrustum:TInRect);
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
     case OwnerInFrustum of
     IREmpty:begin
                   OwnerInFrustum:=OwnerInFrustum;
             end;
     IRFully:begin
                   enttree.infrustum:=infrustumactualy;
                   pobj:=enttree.nul.beginiterate(ir);
                   if pobj<>nil then
                   repeat
                         pobj^.SetInFrustumFromTree(infrustumactualy,visibleactualy);
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
                                           pobj^.SetInFrustumFromTree(infrustumactualy,visibleactualy);
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
                                                pobj^.SetInFrustumFromTree(infrustumactualy,visibleactualy);
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
end;*)
function GDBObjGenericSubEntry.CreatePreCalcData:PTDrawingPreCalcData;
begin
     GDBGetMem({$IFDEF DEBUGBUILD}'{1F00FCF0-E9C6-4A6B-8B98-FFCC5D163190}',{$ENDIF}GDBPointer(result),sizeof(TDrawingPreCalcData));
     result.InverseObjMatrix:=objmatrix;
     geometry.MatrixInvert(result.InverseObjMatrix);
end;
procedure GDBObjGenericSubEntry.DestroyPreCalcData(PreCalcData:PTDrawingPreCalcData);
begin
     gdbfreemem(pointer(PreCalcData));
end;
procedure GDBObjGenericSubEntry.DrawWithAttrib;
var
   _selected: GDBBoolean;
begin
     inc(dc.subrender);
     _selected:=dc.selected;
     if selected then dc.selected:=true;
     self.ObjArray.DrawWithattrib({infrustumactualy,subrender}dc);
     dec(dc.subrender);
     dc.selected:=_selected;

end;
procedure GDBObjGenericSubEntry.DrawBB;
begin
  inherited;
  if (sysvar.DWG.DWG_SystmGeometryDraw^){and(GDB.GetCurrentDWG.OGLwindow1.param.subrender=0)} then
  begin
  oglsm.glcolor3ubv(palette[{sysvar.SYS.SYS_SystmGeometryColor^+2}4]);
  OGLSpecFunc.DrawAABB(VisibleOBJBoundingBox);
  {oglsm.myglbegin(GL_LINE_LOOP);
     oglsm.myglVertex(VisibleOBJBoundingBox.LBN.x,VisibleOBJBoundingBox.LBN.y,VisibleOBJBoundingBox.LBN.Z);
     oglsm.myglVertex(VisibleOBJBoundingBox.RTF.x,VisibleOBJBoundingBox.LBN.y,VisibleOBJBoundingBox.LBN.Z);
     oglsm.myglVertex(VisibleOBJBoundingBox.RTF.x,VisibleOBJBoundingBox.RTF.y,VisibleOBJBoundingBox.LBN.Z);
     oglsm.myglVertex(VisibleOBJBoundingBox.LBN.x,VisibleOBJBoundingBox.RTF.y,VisibleOBJBoundingBox.LBN.Z);
  oglsm.myglend();
  oglsm.myglbegin(GL_LINE_LOOP);
     oglsm.myglVertex(VisibleOBJBoundingBox.LBN.x,VisibleOBJBoundingBox.LBN.y,VisibleOBJBoundingBox.RTF.Z);
     oglsm.myglVertex(VisibleOBJBoundingBox.RTF.x,VisibleOBJBoundingBox.LBN.y,VisibleOBJBoundingBox.RTF.Z);
     oglsm.myglVertex(VisibleOBJBoundingBox.RTF.x,VisibleOBJBoundingBox.RTF.y,VisibleOBJBoundingBox.RTF.Z);
     oglsm.myglVertex(VisibleOBJBoundingBox.LBN.x,VisibleOBJBoundingBox.RTF.y,VisibleOBJBoundingBox.RTF.Z);
  oglsm.myglend();
  oglsm.myglbegin(GL_LINES);
     oglsm.myglVertex(VisibleOBJBoundingBox.LBN.x,VisibleOBJBoundingBox.LBN.y,VisibleOBJBoundingBox.LBN.Z);
     oglsm.myglVertex(VisibleOBJBoundingBox.LBN.x,VisibleOBJBoundingBox.LBN.y,VisibleOBJBoundingBox.RTF.Z);
     oglsm.myglVertex(VisibleOBJBoundingBox.RTF.x,VisibleOBJBoundingBox.LBN.y,VisibleOBJBoundingBox.LBN.Z);
     oglsm.myglVertex(VisibleOBJBoundingBox.RTF.x,VisibleOBJBoundingBox.LBN.y,VisibleOBJBoundingBox.RTF.Z);
     oglsm.myglVertex(VisibleOBJBoundingBox.RTF.x,VisibleOBJBoundingBox.RTF.y,VisibleOBJBoundingBox.LBN.Z);
     oglsm.myglVertex(VisibleOBJBoundingBox.RTF.x,VisibleOBJBoundingBox.RTF.y,VisibleOBJBoundingBox.RTF.Z);
     oglsm.myglVertex(VisibleOBJBoundingBox.LBN.x,VisibleOBJBoundingBox.RTF.y,VisibleOBJBoundingBox.LBN.Z);
     oglsm.myglVertex(VisibleOBJBoundingBox.LBN.x,VisibleOBJBoundingBox.RTF.y,VisibleOBJBoundingBox.RTF.Z);
  oglsm.myglend();}
  end;
end;
procedure GDBObjGenericSubEntry.RemoveInArray(pobjinarray:GDBInteger);
begin
     ObjArray.deliteminarray(pobjinarray);
end;
function GDBObjGenericSubEntry.AddMi;
begin
     //pobj^.bp.PSelfInOwnerArray:=ObjArray.getelement(ObjArray.add(pobj));
     ObjArray.add(pobj);
     pGDBObjEntity(ppointer(pobj)^).bp.ListPos.Owner:=@self;
end;
procedure GDBObjGenericSubEntry.correctobjects;
var pobj:PGDBObjEntity;
    ir:itrec;
begin
     bp.ListPos.Owner:=powner;
     bp.ListPos.SelfIndex:=pinownerarray;
     pobj:=self.ObjArray.beginiterate(ir);
     if pobj<>nil then
     repeat
           pobj^.correctobjects(@self,ir.itc);
           pobj:=self.ObjArray.iterate(ir);
     until pobj=nil;
end;
function GDBObjGenericSubEntry.GoodRemoveMiFromArray(const obj:GDBObjEntity):GDBInteger;
begin
     RemoveMiFromArray(@obj,obj.bp.ListPos.SelfIndex);
end;
function GDBObjGenericSubEntry.RemoveMiFromArray(pobj:pGDBObjEntity;pobjinarray:GDBInteger):GDBInteger;
//var
//p:PGDBObjEntity;
begin
     if pobj^.bp.TreePos.Owner<>nil then
     begin
          PTEntTreeNode(pobj^.bp.TreePos.Owner)^.nul.deliteminarray(pobj^.bp.TreePos.SelfIndex);
     end;
     pobj^.bp.TreePos.Owner:=nil;

     //pointer(p):=ObjArray.GetObject(pobjinarray);
     ObjArray.deliteminarray(pobjinarray);
end;
function GDBObjGenericSubEntry.EraseMi;
//var
//p:PGDBObjEntity;
begin
     {if pobj^.bp.TreePos.Owner<>nil then
     begin
          PTEntTreeNode(pobj^.bp.TreePos.Owner)^.nul.deliteminarray(pobj^.bp.TreePos.SelfIndex);
     end;

     pointer(p):=ObjArray.GetObject(pobjinarray);
     ObjArray.deliteminarray(pobjinarray);

     //p^.done;
     //memman.GDBFreeMem(GDBPointer(p))}
     RemoveMiFromArray(pobj,pobjinarray);
     pobj^.done;
     memman.GDBFreeMem(GDBPointer(pobj));
end;
function GDBObjGenericSubEntry.ImEdited;
begin
     ObjCasheArray.addnodouble(@pobj);
end;
function GDBObjGenericSubEntry.ReturnLastOnMouse;
begin
     if (sysvar.DWG.DWG_EditInSubEntry)^ then result:=lstonmouse
                                          else result:=@self;
end;
function GDBObjGenericSubEntry.MigrateTo;
var p:pGDBObjEntity;
//    i:GDBInteger;
        ir:itrec;
begin
     if objarray.Count=0 then exit;
     p:=objarray.beginiterate(ir);
     if p<>nil then
     repeat
           p^.bp.ListPos.Owner:=new_sub;
           new_sub^.ObjArray.add(@p);
     p:=objarray.iterate(ir);
     until p=nil;
     {p:=objarray.parray;
     for i:=1 to objarray.Count do
     begin
          p^^.vp.Owner:=new_sub;
          new_sub^.ObjArray.add(p);
     inc(p);
     end;}
     objarray.count:=0;
end;
function GDBObjGenericSubEntry.EubEntryType;
begin
     result:=se_Abstract;
end;
function GDBObjGenericSubEntry.CanAddGDBObj;
begin
     result:=false;
end;

function GDBObjGenericSubEntry.getowner;
begin
     result:=@self;
     //result:=pointer(bp.owner);
end;
destructor GDBObjGenericSubEntry.done;
begin
     ObjArray.FreeAndDone;
     ObjCasheArray.FreeAndDone;
     //self.ObjArray.ObjTree.done;
     inherited done;
end;
constructor GDBObjGenericSubEntry.initnul;
begin
     inherited initnul(owner);
     ObjArray.init({$IFDEF DEBUGBUILD}'{3EB0D466-D2B3-4F03-802A-8C995283688A}',{$ENDIF}10);
     ObjCasheArray.init({$IFDEF DEBUGBUILD}'{A6F0EFFD-8EBB-4DED-9051-D28BF8F9A93C}',{$ENDIF}10);
     //self.ObjArray.ObjTree.initnul;
end;
procedure GDBObjGenericSubEntry.DrawGeometry;
var
   _selected: GDBBoolean;
begin
     inc(dc.subrender);
     _selected:=dc.selected;
     if selected then dc.selected:=true;
  ObjArray.DrawGeometry(CalculateLineWeight(dc),dc{infrustumactualy,subrender});
     dc.selected:=_selected;
     dec(dc.subrender);
  DrawBB;
end;
function GDBObjGenericSubEntry.CalcInFrustum(frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity;var totalobj,infrustumobj:GDBInteger; ProjectProc:GDBProjectProc;const zoom:GDBDouble):GDBBoolean;
begin
     result:=ObjArray.calcvisible(frustum,infrustumactualy,visibleactualy,totalobj,infrustumobj, ProjectProc,zoom);
     self.VisibleOBJBoundingBox:=ObjArray.calcvisbb({gdb.GetCurrentDWG.pcamera^.POSCOUNT}{visibleactualy}infrustumactualy);
     {ObjArray.calcvisible;
     visible:=true;}
end;
procedure GDBObjGenericSubEntry.getoutbound;
begin
     vp.BoundingBox:=ObjArray.calcbb;
end;
procedure GDBObjGenericSubEntry.getonlyoutbound;
begin
     vp.BoundingBox:=ObjArray.getonlyoutbound;
end;
procedure GDBObjGenericSubEntry.FormatEntity(const drawing:TDrawingDef);
begin
  inherited FormatEntity(drawing);
  ObjArray.FormatEntity(drawing);
  calcbb;
  restructure(drawing);
end;
procedure GDBObjGenericSubEntry.formatafteredit;
//var
  //p:pGDBObjEntity;
      //ir:itrec;

begin
  ObjCasheArray.Formatafteredit(drawing);

  ObjCasheArray.clear;
  calcbb;
  restructure(drawing);
end;
procedure GDBObjGenericSubEntry.restructure;
begin
end;
procedure GDBObjGenericSubEntry.renderfeedbac(infrustumactualy:TActulity;pcount:TActulity;var camera:GDBObjCamera; ProjectProc:GDBProjectProc);
begin
  ObjArray.renderfeedbac(infrustumactualy,pcount,camera,ProjectProc);
end;
function GDBObjGenericSubEntry.onpoint(var objects:GDBOpenArrayOfPObjects;const point:GDBVertex):GDBBoolean;
var //t,xx,yy:GDBDouble;
    i:GDBInteger;
    p:pGDBObjEntity;
    ot:GDBBoolean;
begin
  result:=false;
  for i:=0 to ObjArray.count-1 do
  begin
       p:=pGDBPointer(ObjArray.getelement(i))^;
       if p<>nil then
       begin
       ot:=p^.onpoint(objects,point);
       if ot then
                 begin
                      result:=true;
                 end;
       //result:=result or ot;
       end;
  end;
end;
function GDBObjGenericSubEntry.onmouse;
var //t,xx,yy:GDBDouble;
    i:GDBInteger;
    p:pGDBObjEntity;
    ot:GDBBoolean;
begin
  result:=false;
  //p:=GDBPointer(ObjArray.parray^);
  for i:=0 to ObjArray.count-1 do
  begin
       p:=pGDBPointer(ObjArray.getelement(i))^;
       if p<>nil then
       begin
       ot:=p^.onmouse(popa,mf);
       if ot then
                 begin
                      lstonmouse:=p;
                      {PGDBObjOpenArrayOfPV}(popa).add(addr(p));
                 end;
       result:=result or ot;
       end;
       //if result then exit;
       //inc(pGDBPointer(p));
  end;
end;
(*function GDBObjGenericSubEntry.select;
//var tdesc:pselectedobjdesc;
begin
  result:=false;
  if selected=false then
  begin
    result:=SelectQuik;
  if result then
     begin
          selected:=true;
          inc(GDB.GetCurrentDWG.OGLwindow1.param.SelDesc.Selectedobjcount);
          {tdesc:=GDB.SelObjArray.addobject(@self);
          GDBGetMem(tdesc^.pcontrolpoint,sizeof(GDBControlPointArray));
          addcontrolpoints(tdesc);
          inc(poglwnd^.SelDesc.Selectedobjcount);}
     end;
  end;
end;*)
begin
  {$IFDEF DEBUGINITSECTION}LogOut('GDBSubEntry.initialization');{$ENDIF}
end.
