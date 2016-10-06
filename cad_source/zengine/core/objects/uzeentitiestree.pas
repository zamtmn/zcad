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

unit uzeentitiestree;
{$INCLUDE def.inc}
interface
uses
    graphics,
    uzbgeomtypes,gzctnrtree,uzgldrawcontext,uzegeometry,UGDBVisibleOpenArray,uzeentity,uzbtypesbase,uzbtypes,uzbmemman;
const
     IninialNodeDepth=-1;
type
TZEntsManipulator=class
                   class procedure DrawNodeVolume(const BoundingBox:TBoundingBox;var DC:TDrawContext);
                  end;
{EXPORT+}
TDrawType=(TDTFulDraw,TDTSimpleDraw);
TEntTreeNodeData=record
                     infrustum:TActulity;
                     nuldrawpos,minusdrawpos,plusdrawpos:TActulity;
                     FulDraw:TDrawType;
                     nodedepth:GDBInteger;
                     pluscount,minuscount:GDBInteger;
                 end;
         PTEntTreeNode=^TEntTreeNode;
         TEntTreeNode={$IFNDEF DELPHI}packed{$ENDIF}object(GZBInarySeparatedGeometry{-}<TBoundingBox,DVector4D,TEntTreeNodeData,TZEntsManipulator>{//})
                            procedure updateenttreeadress;
                            procedure AddObjToNul(var Entity:GDBObjEntity);
                            procedure AddObjectToNodeTree(var Entity:GDBObjEntity);
                            procedure CorrectNodeTreeBB(var Entity:GDBObjEntity);
                            procedure treerender(var DC:TDrawContext);
                            procedure MakeTreeFrom(var entitys:GDBObjEntityOpenArray;AABB:TBoundingBox);
                      end;
{EXPORT-}
 TTestTreeNode=Object(GDBaseObject)
                    plane:DVector4D;
                    nul,plus,minus:GDBObjEntityOpenArray;
                    constructor initnul(InNodeCount:integer);
                    destructor done;virtual;
              end;
TTestTreeArray=array [0..2] of TTestTreeNode;
var
   SysVarRDSpatialNodeCount:integer=500;
   SysVarRDSpatialNodesDepth:integer=16;
function createtree(var entitys:GDBObjEntityOpenArray;AABB:TBoundingBox;
                    PRootNode:PTEntTreeNode;nodedepth:GDBInteger;_root:PTEntTreeNode;
                    dir:TNodeDir):PTEntTreeNode;
function GetInNodeCount(_InNodeCount:GDBInteger):GDBInteger;
//procedure treerender(var Node:TEntTreeNode;var DC:TDrawContext);
implementation
class procedure TZEntsManipulator.DrawNodeVolume(const BoundingBox:TBoundingBox;var DC:TDrawContext);
begin
  dc.drawer.DrawAABB3DInModelSpace(BoundingBox,dc.DrawingContext.matrixs);
end;

procedure TEntTreeNode.MakeTreeFrom(var entitys:GDBObjEntityOpenArray;AABB:TBoundingBox);
begin
     createtree(entitys,AABB,@self,IninialNodeDepth,nil,TND_Root);
end;

procedure TEntTreeNode.treerender(var DC:TDrawContext);
begin
  if (NodeData.infrustum=dc.DrawingContext.InfrustumActualy) then
  begin
       if NodeData.FulDraw=TDTFulDraw then
       if (NodeData.FulDraw=TDTFulDraw)or(nul.count=0) then
       begin
       if assigned(pminusnode)then
                                       if (NodeData.minusdrawpos<>dc.DrawingContext.DRAWCOUNT)or(dc.MaxDetail) then
                                       begin
                                            PTEntTreeNode(pminusnode)^.treerender(dc);
                                            NodeData.minusdrawpos:=dc.DrawingContext.DRAWCOUNT
                                       end;
       if assigned(pplusnode)then
                                      if (NodeData.plusdrawpos<>dc.DrawingContext.DRAWCOUNT)or(dc.MaxDetail) then
                                      begin
                                           PTEntTreeNode(pplusnode)^.treerender(dc);
                                           NodeData.plusdrawpos:=dc.DrawingContext.DRAWCOUNT
                                      end;
       end;
       begin
            if (NodeData.FulDraw=TDTFulDraw)or(dc.MaxDetail) then
                                                                 nul.DrawWithattrib(dc);
            NodeData.nuldrawpos:=dc.DrawingContext.DRAWCOUNT;
       end;
  end;
end;
procedure TEntTreeNode.CorrectNodeTreeBB(var Entity:GDBObjEntity);
begin
     ConcatBB(BoundingBox,Entity.vp.BoundingBox);
end;
procedure TEntTreeNode.AddObjectToNodeTree(var Entity:GDBObjEntity);
begin
    AddObjToNul(Entity);
    CorrectNodeTreeBB(Entity);
end;
procedure TEntTreeNode.AddObjToNul(var Entity:GDBObjEntity);
begin
     Entity.bp.TreePos.Owner:=@self;
     Entity.bp.TreePos.SelfIndex:=nul.PushBackData(@Entity);
end;
procedure TEntTreeNode.updateenttreeadress;
var pobj:PGDBObjEntity;
    ir:itrec;
begin
     pobj:=nul.beginiterate(ir);
     if pobj<>nil then
     repeat
           pobj^.bp.TreePos.Owner:=@self;
           pobj^.bp.TreePos.SelfIndex:=ir.itc;

           pobj:=nul.iterate(ir);
     until pobj=nil;
end;
constructor TTestTreeNode.initnul;
begin
     nul.init({$IFDEF DEBUGBUILD}'TTestTreeNode.nul',{$ENDIF}InNodeCount{*2});
     plus.init({$IFDEF DEBUGBUILD}'TTestTreeNode.plus',{$ENDIF}InNodeCount{*2});
     minus.init({$IFDEF DEBUGBUILD}'TTestTreeNode.minus',{$ENDIF}InNodeCount{*2});
end;
destructor TTestTreeNode.done;
begin
     nul.Clear;
     nul.Done;
     plus.Clear;
     plus.Done;
     minus.Clear;
     minus.Done;
end;
function GetInNodeCount(_InNodeCount:GDBInteger):GDBInteger;
begin
     if _InNodeCount>0 then
                           result:=_InNodeCount
                       else
                           result:=500;
end;

function createtree(var entitys:GDBObjEntityOpenArray;AABB:TBoundingBox;PRootNode:PTEntTreeNode;nodedepth:GDBInteger;_root:PTEntTreeNode;dir:TNodeDir):PTEntTreeNode;
const
     aabbaxisscale=3;
var pobj:PGDBObjEntity;
    ir:itrec;
    midlepoint:gdbvertex;
    d1,d2,d:gdbdouble;
    entcount,dentcount,i,imin:integer;
    ta:TTestTreeArray;
    plusaabb,minusaabb:TBoundingBox;
    tv:gdbvertex;
     _InNodeCount:gdbinteger;
    SpatialNodeCount,SpatialNodesDepth:integer;
begin
     //_InNodeCount:=entitys.GetRealCount div {_NodeDepth + 1}(nodedepth+2);
     //if _InNodeCount<500 then _InNodeCount:=500;
     //if SysVar.RD.RD_SpatialNodeCount<>nil then
                                               SpatialNodeCount:=SysVarRDSpatialNodeCount;
     //                                      else
     //                                          SpatialNodeCount:=500;
     _InNodeCount:=GetInNodeCount(SpatialNodeCount);
     inc(nodedepth);
     if PRootNode<>nil then
                           begin
                           result:=PRootNode;
                           PRootNode^.ClearSub;
                           end
                       else
                           begin
                           GDBGetMem({$IFDEF DEBUGBUILD}'TEntTreeNode',{$ENDIF}pointer(result),sizeof(TEntTreeNode));
                           result.initnul;
                           end;
     result.BoundingBox:=aabb;
     result.NodeData.pluscount:=0;
     result.NodeData.minuscount:=0;
     result.Root:=_root;
     result.NodeDir:=dir;
     //if SysVar.RD.RD_SpatialNodesDepth<>nil then
                                               SpatialNodesDepth:=SysVarRDSpatialNodesDepth;
     //                                      else
     //                                          SpatialNodesDepth:=16;
     if ((entitys.Count<=_InNodeCount){and(nodedepth>1)})or(nodedepth>=SpatialNodesDepth) then
                                                begin
                                                     //result.selected:=false;
                                                     {if entitys.beginiterate(ir)<>nil then
                                                                       if PGDBObjEntity(entitys.beginiterate(ir))^.Selected then
                                                                           result.selected:=true;}

                                                     result.Separator:=uzegeometry.NulVector4D;
                                                     result.pminusnode:=nil;
                                                     result.pplusnode:=nil;
                                                     if prootnode<>nil then
                                                                           begin
                                                                                //nul.init({$IFDEF DEBUGBUILD}'{A1E9743F-63CF-4C8F-8C40-57CCDC24F8CF}',{$ENDIF}entitys.Count);
                                                                                entitys.copyto{withoutcorrect}({@}result.nul);
                                                                           end
                                                                       else
                                                                           begin
                                                                                if Result.nul.PArray<>nil then
                                                                                GDBFreeMem(Result.nul.PArray);
                                                                                result.nul:=entitys;
                                                                                entitys.Clear;
                                                                                entitys.PArray:=nil;
                                                                                //entitys.FreeAndDone;
                                                                           end;
                                                     result.updateenttreeadress;
                                                     result.nul.Shrink;
                                                     exit;
                                                end;
     midlepoint:=nulvertex;
     entcount:=0;
     pobj:=entitys.beginiterate(ir);
     if pobj<>nil then
     repeat
           midlepoint:=vertexadd(midlepoint,VertexMulOnSc(vertexadd(pobj^.vp.BoundingBox.RTF,pobj^.vp.BoundingBox.LBN),1/2));
           //if abs(midlepoint.x)>100000000 then
           //                              pobj^.Format;
           inc(entcount);

           pobj:=entitys.iterate(ir);
     until pobj=nil;

     if entcount<>0 then
                        midlepoint:=uzegeometry.VertexMulOnSc(midlepoint,1/entcount);

     d:=sqrt(sqr(midlepoint.x) + sqr(midlepoint.y) + sqr(midlepoint.z));
     ta[0].initnul(entitys.GetRealCount);
     ta[0].plane:=uzegeometry.PlaneFrom3Pont(midlepoint,
                                          vertexadd(midlepoint,VertexMulOnSc(x_Y_zVertex,d)),
                                          vertexadd(midlepoint,VertexMulOnSc(xy_Z_Vertex,d))
                                          );
     ta[1].initnul(entitys.GetRealCount);
     ta[1].plane:=uzegeometry.PlaneFrom3Pont(midlepoint,
                                          vertexadd(midlepoint,VertexMulOnSc(_X_yzVertex,d)),
                                          vertexadd(midlepoint,VertexMulOnSc(xy_Z_Vertex,d))
                                          );
     ta[2].initnul(entitys.GetRealCount);
     ta[2].plane:=uzegeometry.PlaneFrom3Pont(midlepoint,
                                          vertexadd(midlepoint,VertexMulOnSc(_X_yzVertex,d)),
                                          vertexadd(midlepoint,VertexMulOnSc(x_Y_ZVertex,d))
                                          );
     for i:=0 to 2 do
     begin
     pobj:=entitys.beginiterate(ir);
     if pobj<>nil then
     repeat
           d1:=ta[i].plane[0] * pobj^.vp.BoundingBox.RTF.x + ta[i].plane[1] * pobj^.vp.BoundingBox.RTF.y + ta[i].plane[2] * pobj^.vp.BoundingBox.RTF.z + ta[i].plane[3];
           d2:=ta[i].plane[0] * pobj^.vp.BoundingBox.LBN.x + ta[i].plane[1] * pobj^.vp.BoundingBox.LBN.y + ta[i].plane[2] * pobj^.vp.BoundingBox.LBN.z + ta[i].plane[3];
           if abs(d1)<eps then
                              d1:=0;
           if abs(d2)<eps then
                              d2:=0;
           d:=d1*d2;

           if d=0 then
                      begin
                           if (d1=0)and(d2=0) then
                                                  //ta[i].nul.AddByRef(pobj^)
                                                  ta[i].nul.PushBackData(pobj)
                      else if (d1>0)or(d2>0)  then
                                                  ta[i].plus.PushBackData(pobj)
                                              else
                                                  ta[i].minus.PushBackData(pobj);
                      end
      else if d<0 then
                      ta[i].nul.PushBackData(pobj)
      else if (d1>0)or(d2>0)  then
                                  ta[i].plus.PushBackData(pobj)
                              else
                                  ta[i].minus.PushBackData(pobj);
           pobj:=entitys.iterate(ir);
     until pobj=nil;
     end;
     entcount:=ta[0].nul.Count;
     dentcount:=abs(ta[0].plus.Count-ta[0].minus.Count);
     imin:=0;
     for i:=1 to 2 do
     begin
          if ta[i].nul.Count<entcount then
                                          begin
                                               entcount:=ta[i].nul.Count;
                                               dentcount:=abs(ta[i].plus.Count-ta[i].minus.Count);
                                               imin:=i;
                                          end
     else if ta[i].nul.Count=entcount then
                                       begin
                                            if abs(ta[i].plus.Count-ta[i].minus.Count)<dentcount then
                                            begin
                                                 entcount:=ta[i].nul.Count;
                                                 dentcount:=abs(ta[i].plus.Count-ta[i].minus.Count);
                                                 imin:=i;
                                            end;
                                       end;
     end;

     //if imin=-1 then
     begin

     tv:=vertexsub(aabb.RTF,aabb.LBN);
     if (tv.x>=tv.y*aabbaxisscale)and(tv.x>=tv.z*aabbaxisscale) then
                                        imin:=0
else if (tv.y>=tv.x*aabbaxisscale)and(tv.y>=tv.z*aabbaxisscale) then
                                        imin:=1
else if (tv.z>=tv.x*aabbaxisscale)and(tv.z>=tv.y*aabbaxisscale) then
                                        imin:=2;
     end;



     plusaabb:=aabb;
     minusaabb:=aabb;

     case imin of
                 0:
                   begin
                        minusaabb.RTF.x:=midlepoint.x;
                        plusaabb.LBN.x:=midlepoint.x;
                        ta[1].done;
                        ta[2].done;
                   end;
                 1:
                   begin
                        minusaabb.LBN.y:=midlepoint.y;
                        plusaabb.RTF.y:=midlepoint.y;
                        ta[0].done;
                        ta[2].done;
                   end;
                 2:
                   begin
                        minusaabb.RTF.z:=midlepoint.z;
                        plusaabb.LBN.z:=midlepoint.z;
                        ta[0].done;
                        ta[1].done;

                   end;
     end;

     result.Separator:=ta[imin].plane;
     //result.point:=midlepoint;
     if Result.nul.PArray<>nil then
     GDBFreeMem(Result.nul.PArray);
     result.nul:=ta[imin].nul;
     ta[imin].nul.PArray:=nil;
     ta[imin].nul.Clear;

     result.nul.Shrink;

     result^.updateenttreeadress;
     result.NodeData.nodedepth:=nodedepth;
     result.pminusnode:=createtree(ta[imin].minus,minusaabb,nil,nodedepth,result,TND_Minus);
     result.pplusnode:=createtree(ta[imin].plus,plusaabb,nil,nodedepth,result,TND_Plus);
     result.NodeData.pluscount:=ta[imin].plus.Count;
     result.NodeData.minuscount:=ta[imin].minus.Count;
     if prootnode=nil then
                          begin
                          ta[imin].done;
                          entitys.Clear;
                          entitys.Done;
                          end;

     //result.BoundingBox:=result.nul.getoutbound;
     //ta[0].nul.done;
     //ta[0].done;
     //ta[1].done;
     //ta[2].done;
end;
begin
end.
