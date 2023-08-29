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

unit uzeentgenericsubentry;
{$INCLUDE zengineconfig.inc}

interface
uses uzepalette,uzgldrawcontext,uzedrawingdef,uzecamera,uzestyleslayers,
     UGDBVisibleTreeArray,UGDBOpenArrayOfPV,
     uzeentwithmatrix,uzeentsubordinated,uzbtypes,uzegeometry,uzeentity,
     gzctnrVectorTypes,uzegeometrytypes,uzeconsts,uzeentitiestree,uzeffdxfsupport,
     uzctnrvectorpgdbaseobjects;
type
//GDBObjGenericSubEntry=object(GDBObjWithLocalCS)
//GDBObjGenericSubEntry=object(GDBObj3d)
{Export+}
PTDrawingPreCalcData=^TDrawingPreCalcData;
{REGISTERRECORDTYPE TDrawingPreCalcData}
TDrawingPreCalcData=record
                          InverseObjMatrix:DMatrix4D;
                    end;
PGDBObjGenericSubEntry=^GDBObjGenericSubEntry;
{REGISTEROBJECTTYPE GDBObjGenericSubEntry}
GDBObjGenericSubEntry= object(GDBObjWithMatrix)
                            ObjArray:GDBObjEntityTreeArray;(*saved_to_shd*)
                            ObjCasheArray:GDBObjOpenArrayOfPV;
                            ObjToConnectedArray:GDBObjOpenArrayOfPV;
                            lstonmouse:PGDBObjEntity;
                            VisibleOBJBoundingBox:TBoundingBox;
                            //ObjTree:TEntTreeNode;
                            function AddObjectToObjArray(p:Pointer):Integer;virtual;
                            procedure GoodAddObjectToObjArray(const obj:GDBObjEntity);virtual;
                            //function AddObjectToNodeTree(pobj:PGDBObjEntity):Integer;virtual;
                            //function CorrectNodeTreeBB(pobj:PGDBObjEntity):Integer;virtual;
                            constructor initnul(owner:PGDBObjGenericWithSubordinated);
                            procedure DrawGeometry(lw:Integer;var DC:TDrawContext{infrustumactualy:TActulity;subrender:Integer});virtual;
                            function CalcInFrustum(frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity;var totalobj,infrustumobj:Integer; ProjectProc:GDBProjectProc;const zoom,currentdegradationfactor:Double):Boolean;virtual;
                            function onmouse(var popa:TZctnrVectorPGDBaseObjects;const MF:ClipArray;InSubEntry:Boolean):Boolean;virtual;
                            procedure FormatEntity(var drawing:TDrawingDef;var DC:TDrawContext);virtual;
                            procedure FormatAfterEdit(var drawing:TDrawingDef;var DC:TDrawContext);virtual;
                            procedure restructure(var drawing:TDrawingDef);virtual;
                            procedure renderfeedbac(infrustumactualy:TActulity;pcount:TActulity;var camera:GDBObjCamera; ProjectProc:GDBProjectProc;var DC:TDrawContext);virtual;
                            //function select:Boolean;virtual;
                            function getowner:PGDBObjSubordinated;virtual;
                            function CanAddGDBObj(pobj:PGDBObjEntity):Boolean;virtual;
                            function EubEntryType:Integer;virtual;
                            procedure MigrateTo(new_sub:PGDBObjGenericSubEntry);virtual;
                            procedure EraseMi(pobj:pGDBObjEntity;pobjinarray:Integer;var drawing:TDrawingDef);virtual;
                            procedure RemoveMiFromArray(pobj:pGDBObjEntity;pobjinarray:Integer);virtual;
                            procedure GoodRemoveMiFromArray(const obj:GDBObjEntity);virtual;
                            //function SubMi(pobj:pGDBObjEntity):Integer;virtual;
                            //** Добавляет объект в область ConstructObjRoot или mainObjRoot или итд. Пример добавления gdb.GetCurrentDWG^.ConstructObjRoot.AddMi(@sampleObj);
                            procedure AddMi(pobj:PGDBObjSubordinated);virtual;
                            procedure ImEdited(pobj:PGDBObjSubordinated;pobjinarray:Integer;var drawing:TDrawingDef);virtual;
                            function ReturnLastOnMouse(InSubEntry:Boolean):PGDBObjEntity;virtual;
                            procedure correctobjects(powner:PGDBObjEntity;pinownerarray:Integer);virtual;
                            destructor done;virtual;
                            procedure getoutbound(var DC:TDrawContext);virtual;
                            procedure getonlyoutbound(var DC:TDrawContext);virtual;

                            procedure DrawBB(var DC:TDrawContext);

                            procedure RemoveInArray(pobjinarray:Integer);virtual;
                            procedure DrawWithAttrib(var DC:TDrawContext{visibleactualy:TActulity;subrender:Integer});virtual;

                            function CreatePreCalcData:PTDrawingPreCalcData;virtual;
                            procedure DestroyPreCalcData(PreCalcData:PTDrawingPreCalcData);virtual;

                            //procedure ProcessTree(const frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity;var enttree:TEntTreeNode;OwnerInFrustum:TInRect);
                            //function CalcVisibleByTree(frustum:ClipArray;infrustumactualy:TActulity;const enttree:TEntTreeNode):Boolean;virtual;
                              function CalcVisibleByTree(frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity;var enttree:TEntTreeNode;var totalobj,infrustumobj:Integer; ProjectProc:GDBProjectProc;const zoom,currentdegradationfactor:Double):Boolean;virtual;
                              //function CalcInFrustumByTree(frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity;var enttree:TEntTreeNode):Boolean;virtual;
                              procedure SetInFrustumFromTree(const frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity;var totalobj,infrustumobj:Integer; ProjectProc:GDBProjectProc;const zoom,currentdegradationfactor:Double);virtual;

                              //function FindObjectsInPointStart(const point:GDBVertex;out Objects:GDBObjOpenArrayOfPV):Boolean;virtual;
                              function FindObjectsInVolume(const Volume:TBoundingBox;var Objects:GDBObjOpenArrayOfPV):Boolean;virtual;
                              function FindObjectsInPoint(const point:GDBVertex;var Objects:GDBObjOpenArrayOfPV):Boolean;virtual;
                              function FindObjectsInPointSlow(const point:GDBVertex;var Objects:GDBObjOpenArrayOfPV):Boolean;
                              function FindObjectsInPointInNode(const point:GDBVertex;const Node:TEntTreeNode;var Objects:GDBObjOpenArrayOfPV):Boolean;
                              function FindObjectsInVolumeInNode(const Volume:TBoundingBox;const Node:TEntTreeNode;var Objects:GDBObjOpenArrayOfPV):Boolean;
                              //function FindObjectsInPointDone(const point:GDBVertex):Boolean;virtual;
                              function onpoint(var objects:TZctnrVectorPGDBaseObjects;const point:GDBVertex):Boolean;virtual;
                              procedure correctsublayers(var la:GDBLayerArray);virtual;
                              function CalcTrueInFrustum(frustum:ClipArray;visibleactualy:TActulity):TInBoundingVolume;virtual;

                              procedure IterateCounter(PCounted:Pointer;var Counter:Integer;proc:TProcCounter);virtual;

                              procedure postload(var context:TIODXFLoadContext);virtual;

                      end;
{Export-}
implementation
//uses log;
{function GDBObjGenericSubEntry.SubMi;
begin
     //pobj^.bp.PSelfInOwnerArray:=ObjArray.getDataMutable(ObjArray.add(pobj));
     ObjArray.add(pobj);
     pGDBObjEntity(ppointer(pobj)^).bp.Owner:=@self;
end;}
{function GDBObjGenericSubEntry.CorrectNodeTreeBB(pobj:PGDBObjEntity):Integer;
begin
     ConcatBB(ObjTree.BoundingBox,pobj^.vp.BoundingBox);
end;

function GDBObjGenericSubEntry.AddObjectToNodeTree(pobj:PGDBObjEntity):Integer;
begin
    ObjTree.addtonul(pobj);
    CorrectNodeTreeBB(pobj);
end;}
procedure GDBObjGenericSubEntry.postload(var context:TIODXFLoadContext);
var p:pGDBObjEntity;
    ir:itrec;
begin
    p:=objarray.beginiterate(ir);
    if p<>nil then
    repeat
      if assigned(p^.EntExtensions) then
        p^.EntExtensions.RunPostload(context);
    p:=objarray.iterate(ir);
    until p=nil;
end;
procedure GDBObjGenericSubEntry.IterateCounter(PCounted:Pointer;var Counter:Integer;proc:TProcCounter);
var p:pGDBObjEntity;
    ir:itrec;
begin
    inherited;
    p:=objarray.beginiterate(ir);
    if p<>nil then
    repeat
         p^.IterateCounter(PCounted,Counter,proc);
    p:=objarray.iterate(ir);
    until p=nil;
end;
function GDBObjGenericSubEntry.CalcTrueInFrustum;
begin
      result:=ObjArray.CalcTrueInFrustum(frustum,visibleactualy);
end;

procedure GDBObjGenericSubEntry.correctsublayers(var la:GDBLayerArray);
var p:pGDBObjEntity;
//    i:Integer;
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
function GDBObjGenericSubEntry.FindObjectsInPointSlow(const point:GDBVertex;var Objects:GDBObjOpenArrayOfPV):Boolean;
var
    //minus:Boolean{$IFNDEF DELPHI}=false{$ENDIF};
    //plus:Boolean{$IFNDEF DELPHI}=false{$ENDIF};
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

function GDBObjGenericSubEntry.FindObjectsInPointInNode(const point:GDBVertex;const Node:TEntTreeNode;var Objects:GDBObjOpenArrayOfPV):Boolean;
var
    minus:Boolean{$IFNDEF DELPHI}=false{$ENDIF};
    plus:Boolean{$IFNDEF DELPHI}=false{$ENDIF};
    pobj:PGDBObjEntity;
    ir:itrec;
begin
     plus:=false;
     minus:=false;
     result:=false;
     if assigned(Node.pminusnode) then
       if uzegeometry.IsPointInBB(point,Node.pminusnode.BoundingBox) then
       begin
            minus:=FindObjectsInPointInNode(point,PTEntTreeNode(Node.pminusnode)^,Objects);
       end;
     if assigned(Node.pplusnode) then
       if uzegeometry.IsPointInBB(point,Node.pplusnode.BoundingBox) then
       begin
            plus:=FindObjectsInPointInNode(point,PTEntTreeNode(Node.pplusnode)^,Objects);
       end;

       pobj:=Node.nulbeginiterate(ir);
     if pobj<>nil then
     repeat
           if pobj^.onpoint(Objects,point) then
           begin
                result:=true;
                //Objects.Add(@pobj);
           end;

           pobj:=Node.nuliterate(ir);
     until pobj=nil;

     result:=result or (plus or minus);
     //self.ObjArray.ObjTree.BoundingBox;
end;
function GDBObjGenericSubEntry.FindObjectsInVolumeInNode(const Volume:TBoundingBox;const Node:TEntTreeNode;var Objects:GDBObjOpenArrayOfPV):Boolean;
var
    minus:Boolean{$IFNDEF DELPHI}=false{$ENDIF};
    plus:Boolean{$IFNDEF DELPHI}=false{$ENDIF};
    pobj:PGDBObjEntity;
    ir:itrec;
begin
     plus:=false;
     minus:=false;
     result:=false;
     if assigned(Node.pminusnode) then
       if uzegeometry.boundingintersect(Volume,Node.pminusnode.BoundingBox) then
       begin
            minus:=FindObjectsInVolumeInNode(Volume,PTEntTreeNode(Node.pminusnode)^,Objects);
       end;
     if assigned(Node.pplusnode) then
       if uzegeometry.boundingintersect(Volume,Node.pplusnode.BoundingBox) then
       begin
            plus:=FindObjectsInVolumeInNode(Volume,PTEntTreeNode(Node.pplusnode)^,Objects);
       end;

       pobj:=Node.nulbeginiterate(ir);
     if pobj<>nil then
     repeat
           if  boundingintersect(Volume,pobj^.vp.BoundingBox) then
           begin
                result:=true;
                Objects.PushBackData(pobj);
           end;

           pobj:=Node.nuliterate(ir);
     until pobj=nil;

     result:=result or (plus or minus);
end;
function GDBObjGenericSubEntry.FindObjectsInPoint(const point:GDBVertex;var Objects:GDBObjOpenArrayOfPV):Boolean;
begin
     if uzegeometry.IsPointInBB(point,self.ObjArray.ObjTree.BoundingBox) then
     begin
          result:=FindObjectsInPointInNode(point,ObjArray.ObjTree,Objects);
     end
     else
         result:=false;
end;
function GDBObjGenericSubEntry.FindObjectsInVolume(const Volume:TBoundingBox;var Objects:GDBObjOpenArrayOfPV):Boolean;
begin
     if uzegeometry.boundingintersect(Volume,self.ObjArray.ObjTree.BoundingBox) then
     begin
          result:=FindObjectsInVolumeInNode(Volume,ObjArray.ObjTree,Objects);
     end
     else
         result:=false;
end;
procedure GDBObjGenericSubEntry.GoodAddObjectToObjArray(const obj:GDBObjEntity);
var
    p:pointer;
begin
     p:=@obj;
     AddObjectToObjArray(@p);
end;

function GDBObjGenericSubEntry.AddObjectToObjArray(p:Pointer):Integer;
begin
     result:=ObjArray.AddPEntity(PGDBObjEntity(p^)^);
     PGDBObjEntity(p^).bp.ListPos.Owner:=@self;
     //ObjArray.ObjTree.AddObjectToNodeTree(PGDBObjEntity(p^));
end;
procedure GDBObjGenericSubEntry.SetInFrustumFromTree;
begin
     inherited;
     ObjArray.SetInFrustumFromTree(frustum,infrustumactualy,visibleactualy,totalobj,infrustumobj, ProjectProc,zoom,currentdegradationfactor);
end;
(*function GDBObjGenericSubEntry.CalcInFrustumByTree(frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity;var enttree:TEntTreeNode):Boolean;
begin
     ProcessTree(frustum,infrustumactualy,visibleactualy,enttree,IRPartially)
end;*)
function GDBObjGenericSubEntry.CalcVisibleByTree(frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity;var enttree:TEntTreeNode;var totalobj,infrustumobj:Integer; ProjectProc:GDBProjectProc;const zoom,currentdegradationfactor:Double):Boolean;
begin
  visible:=visibleactualy;
     result:=true;
     //inc(gdb.GetCurrentDWG.pcamera^.totalobj);
     {if }CalcInFrustumByTree(frustum,infrustumactualy,visibleactualy,enttree,totalobj,infrustumobj,ProjectProc,zoom,currentdegradationfactor);{ then}
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
end;
function GDBObjGenericSubEntry.CreatePreCalcData:PTDrawingPreCalcData;
begin
     Getmem(Pointer(result),sizeof(TDrawingPreCalcData));
     result.InverseObjMatrix:=objmatrix;
     uzegeometry.MatrixInvert(result.InverseObjMatrix);
end;
procedure GDBObjGenericSubEntry.DestroyPreCalcData(PreCalcData:PTDrawingPreCalcData);
begin
     Freemem(pointer(PreCalcData));
end;
procedure GDBObjGenericSubEntry.DrawWithAttrib;
var
   _selected: Boolean;
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
  if DC.SystmGeometryDraw{and(GDB.GetCurrentDWG.OGLwindow1.param.subrender=0)} then
  begin

  dc.drawer.SetColor(palette[{sysvar.SYS.SYS_SystmGeometryColor^+2}4].RGB);
  dc.drawer.DrawAABB3DInModelSpace(VisibleOBJBoundingBox,dc.DrawingContext.matrixs);
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
procedure GDBObjGenericSubEntry.RemoveInArray(pobjinarray:Integer);
begin
     ObjArray.DeleteElement(pobjinarray);
end;
procedure GDBObjGenericSubEntry.AddMi;
begin
     //pobj^.bp.PSelfInOwnerArray:=ObjArray.getDataMutable(ObjArray.add(pobj));
     ObjArray.AddPEntity(pGDBObjEntity(ppointer(pobj)^)^);
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
procedure GDBObjGenericSubEntry.GoodRemoveMiFromArray(const obj:GDBObjEntity);
begin
     RemoveMiFromArray(@obj,obj.bp.ListPos.SelfIndex);
end;
procedure GDBObjGenericSubEntry.RemoveMiFromArray(pobj:pGDBObjEntity;pobjinarray:Integer);
//var
//p:PGDBObjEntity;
begin
     if pobj^.bp.TreePos.Owner<>nil then
     begin
          PTEntTreeNode(pobj^.bp.TreePos.Owner)^.nulDeleteElement(pobj^.bp.TreePos.SelfIndex);
     end;
     pobj^.bp.TreePos.Owner:=nil;

     //pointer(p):=ObjArray.getDataMutable(pobjinarray);
     ObjArray.DeleteElement(pobjinarray);
end;
procedure GDBObjGenericSubEntry.EraseMi;
//var
//p:PGDBObjEntity;
begin
     {if pobj^.bp.TreePos.Owner<>nil then
     begin
          PTEntTreeNode(pobj^.bp.TreePos.Owner)^.nul.deliteminarray(pobj^.bp.TreePos.SelfIndex);
     end;

     pointer(p):=ObjArray.getDataMutable(pobjinarray);
     ObjArray.deliteminarray(pobjinarray);

     //p^.done;
     //memman.Freemem(Pointer(p))}
     RemoveMiFromArray(pobj,pobjinarray);
     pobj^.done;
     Freemem(Pointer(pobj));
end;
procedure GDBObjGenericSubEntry.ImEdited;
begin
     ObjCasheArray.PushBackIfNotPresent(pobj);
end;
function GDBObjGenericSubEntry.ReturnLastOnMouse;
begin
     if InSubEntry then result:=lstonmouse
                   else result:=@self;
end;
procedure GDBObjGenericSubEntry.MigrateTo;
var p:pGDBObjEntity;
//    i:Integer;
        ir:itrec;
begin
     if objarray.Count=0 then exit;
     p:=objarray.beginiterate(ir);
     if p<>nil then
     repeat
           p^.bp.ListPos.Owner:=new_sub;
           new_sub^.ObjArray.AddPEntity(p^);
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
     //result:=@self;
     result:=pointer(bp.TreePos.owner);
end;
destructor GDBObjGenericSubEntry.done;
begin
  ObjArray.Done;
  ObjCasheArray.Done;
  ObjToConnectedArray.Done;
  inherited done;
end;
constructor GDBObjGenericSubEntry.initnul;
begin
  inherited initnul(owner);
  ObjArray.init(10);
  ObjCasheArray.init(10);
  ObjToConnectedArray.init(100);
end;
procedure GDBObjGenericSubEntry.DrawGeometry;
var
   _selected: Boolean;
begin
     inc(dc.subrender);
     _selected:=dc.selected;
     if selected then dc.selected:=true;
  ObjArray.DrawGeometry(CalculateLineWeight(dc),dc{infrustumactualy,subrender});
     dc.selected:=_selected;
     dec(dc.subrender);
  DrawBB(dc);
end;
function GDBObjGenericSubEntry.CalcInFrustum(frustum:ClipArray;infrustumactualy:TActulity;visibleactualy:TActulity;var totalobj,infrustumobj:Integer; ProjectProc:GDBProjectProc;const zoom,currentdegradationfactor:Double):Boolean;
begin
     result:=ObjArray.calcvisible(frustum,infrustumactualy,visibleactualy,totalobj,infrustumobj, ProjectProc,zoom,currentdegradationfactor);
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
     vp.BoundingBox:=ObjArray.getonlyoutbound(dc);
end;
procedure GDBObjGenericSubEntry.FormatEntity(var drawing:TDrawingDef;var DC:TDrawContext);
begin
  inherited FormatEntity(drawing,dc);
  ObjArray.FormatEntity(drawing,dc);
  calcbb(dc);
  restructure(drawing);
end;
procedure GDBObjGenericSubEntry.formatafteredit;
//var
  //p:pGDBObjEntity;
      //ir:itrec;

begin
  ObjCasheArray.Formatafteredit(drawing,dc);

  ObjCasheArray.clear;
  calcbb(dc);
  restructure(drawing);
end;
procedure GDBObjGenericSubEntry.restructure;
begin
end;
procedure GDBObjGenericSubEntry.renderfeedbac(infrustumactualy:TActulity;pcount:TActulity;var camera:GDBObjCamera; ProjectProc:GDBProjectProc;var DC:TDrawContext);
begin
  ObjArray.renderfeedbac(infrustumactualy,pcount,camera,ProjectProc,dc);
end;
function GDBObjGenericSubEntry.onpoint(var objects:TZctnrVectorPGDBaseObjects;const point:GDBVertex):Boolean;
var //t,xx,yy:Double;
    i:Integer;
    p:pGDBObjEntity;
    ot:Boolean;
begin
  result:=false;
  for i:=0 to ObjArray.count-1 do
  begin
       p:=Pointer(ObjArray.getDataMutable(i));
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
var //t,xx,yy:Double;
    i:Integer;
    p:pGDBObjEntity;
    ot:Boolean;
begin
  result:=false;
  //p:=Pointer(ObjArray.parray^);
  for i:=0 to ObjArray.count-1 do
  begin
       p:=Pointer(ObjArray.getDataMutable(i));
       if p<>nil then
       begin
       ot:=p^.onmouse(popa,mf,InSubEntry);
       if ot then
                 begin
                      lstonmouse:=p;
                      {PGDBObjOpenArrayOfPV}(popa).PushBackData(p);
                 end;
       result:=result or ot;
       end;
       //if result then exit;
       //inc(PPointer(p));
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
          Getmem(tdesc^.pcontrolpoint,sizeof(GDBControlPointArray));
          addcontrolpoints(tdesc);
          inc(poglwnd^.SelDesc.Selectedobjcount);}
     end;
  end;
end;*)
begin
end.
