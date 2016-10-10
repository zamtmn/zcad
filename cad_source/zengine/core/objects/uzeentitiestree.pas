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
TZEntsManipulator=class;
TFirstStageData=record
                  midlepoint:gdbvertex;
                  d:double;
                  counter:integer;
                end;
{EXPORT+}
TDrawType=(TDTFulDraw,TDTSimpleDraw);
TEntTreeNodeData=record
                     infrustum:TActulity;
                     nuldrawpos,minusdrawpos,plusdrawpos:TActulity;
                     FulDraw:TDrawType;
                     //nodedepth:GDBInteger;
                     //pluscount,minuscount:GDBInteger;
                 end;
         PTEntTreeNode=^TEntTreeNode;
         TEntTreeNode={$IFNDEF DELPHI}packed{$ENDIF}object(GZBInarySeparatedGeometry{-}<TBoundingBox,DVector4D,TEntTreeNodeData,TZEntsManipulator,GDBObjEntity>{//})
                            procedure MakeTreeFrom(var entitys:GDBObjEntityOpenArray;AABB:TBoundingBox;nodedepth:GDBInteger);
                            class function createtree(var entitys:GDBObjEntityOpenArray;//массив примитивов
                                                      AABB:TBoundingBox;                //ограничивающий объем массива примитивов
                                                      PParentNode:PTEntTreeNode;        //указатель на родительскую ноду
                                                      PNode:PTEntTreeNode;              //указатель на ноду, если не ноль то это начало дерева, если  ноль - нода создается динамически и возвращается в результе
                                                      nodedepth:GDBInteger;             //текущая глубина
                                                      dir:TNodeDir):PTEntTreeNode;      //что есть текущая нода: +,- или корень
                            procedure DrawVolume(var DC:TDrawContext);
                            procedure DrawNodeVolume(var DC:TDrawContext);
                      end;
{EXPORT-}
TZEntsManipulator=class
                   class procedure StoreTreeAdressInOnject(var Entity:GDBObjEntity;var Node:GZBInarySeparatedGeometry<TBoundingBox,DVector4D,TEntTreeNodeData,TZEntsManipulator,GDBObjEntity>;const index:GDBInteger);
                   class procedure CorrectNodeBoundingBox(var NodeBB:TBoundingBox;var Entity:GDBObjEntity);
                   class function GetEntityBoundingBox(var Entity:GDBObjEntity):TBoundingBox;
                   class function GetBBPosition(const sep:DVector4D;const BB:TBoundingBox):TElemPosition;
                   class function isUnneedSeparate(const count,depth:integer):boolean;
                   class function GetTestNodesCount:integer;
                   class procedure FirstStageCalcSeparatirs(var Entity:GDBObjEntity;var PFirstStageData:pointer;TSM:TStageMode);
                   class procedure CreateSeparator(var TestNode:TEntTreeNode.TTestNode;var PFirstStageData:pointer;const NodeNum:integer);

                   {not used in generic, for external use}
                   class procedure treerender(var Node:GZBInarySeparatedGeometry<TBoundingBox,DVector4D,TEntTreeNodeData,TZEntsManipulator,GDBObjEntity>;var DC:TDrawContext);
                  end;
TTestTreeArray=array [0..2] of TEntTreeNode.TTestNode;
var
   SysVarRDSpatialNodeCount:integer=500;
   SysVarRDSpatialNodesDepth:integer=16;
   FirstStageData:TFirstStageData;
function GetInNodeCount(_InNodeCount:GDBInteger):GDBInteger;
implementation
procedure TEntTreeNode.DrawNodeVolume(var DC:TDrawContext);
begin
  dc.drawer.DrawAABB3DInModelSpace(BoundingBox,dc.DrawingContext.matrixs);
end;
procedure TEntTreeNode.DrawVolume;
begin
     if assigned(pplusnode) then
                       PTEntTreeNode(pplusnode)^.DrawVolume(dc);
     if assigned(pminusnode) then
                       PTEntTreeNode(pminusnode)^.DrawVolume(dc);
     DrawNodeVolume(dc);
end;

class function  TEntTreeNode.createtree(var entitys:GDBObjEntityOpenArray;AABB:TBoundingBox;PParentNode:PTEntTreeNode;PNode:PTEntTreeNode;nodedepth:GDBInteger;dir:TNodeDir):PTEntTreeNode;
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
begin
     inc(nodedepth);

     if PNode<>nil then
                           begin
                           result:=PNode;
                           PNode^.ClearSub;
                           end
                       else
                           begin
                           GDBGetMem({$IFDEF DEBUGBUILD}'TEntTreeNode',{$ENDIF}pointer(result),sizeof(TEntTreeNode));
                           result.initnul;
                           end;

     result.BoundingBox:=aabb;
     //result.NodeData.pluscount:=0;
     //result.NodeData.minuscount:=0;
     result.Root:=PParentNode;
     result.NodeDir:=dir;

     if TZEntsManipulator.isUnneedSeparate(entitys.Count,nodedepth) then
                                                begin
                                                     result.Separator:=default(DVector4D);
                                                     result.pminusnode:=nil;
                                                     result.pplusnode:=nil;
                                                     if PNode<>nil then
                                                                           begin
                                                                                entitys.copyto(result.nul);
                                                                           end
                                                                       else
                                                                           begin
                                                                                if Result.nul.PArray<>nil then
                                                                                GDBFreeMem(Result.nul.PArray);
                                                                                result.nul:=entitys;
                                                                                entitys.Clear;
                                                                                entitys.PArray:=nil;
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
        case TZEntsManipulator.GetBBPosition(ta[i].plane,pobj^.vp.BoundingBox) of
          TEP_Plus:ta[i].plus.PushBackData(pobj);
         TEP_Minus:ta[i].minus.PushBackData(pobj);
           TEP_nul:ta[i].nul.PushBackData(pobj);
        end;
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
     //result.NodeData.nodedepth:=nodedepth;
     result.pminusnode:=createtree(ta[imin].minus,minusaabb,result,nil,nodedepth,TND_Minus);
     result.pplusnode:=createtree(ta[imin].plus,plusaabb,result,nil,nodedepth,TND_Plus);
     //result.NodeData.pluscount:=ta[imin].plus.Count;
     //result.NodeData.minuscount:=ta[imin].minus.Count;
     if PNode=nil then
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

class procedure TZEntsManipulator.treerender(var Node:GZBInarySeparatedGeometry<TBoundingBox,DVector4D,TEntTreeNodeData,TZEntsManipulator,GDBObjEntity>;var DC:TDrawContext);
begin
     begin
       if (Node.NodeData.infrustum=dc.DrawingContext.InfrustumActualy) then
       begin
            if Node.NodeData.FulDraw=TDTFulDraw then
            if (Node.NodeData.FulDraw=TDTFulDraw)or(Node.nul.count=0) then
            begin
            if assigned(Node.pminusnode)then
                                            if (Node.NodeData.minusdrawpos<>dc.DrawingContext.DRAWCOUNT)or(dc.MaxDetail) then
                                            begin
                                                 treerender(Node.pminusnode^,dc);
                                                 //PTEntTreeNode(Node.pminusnode)^.treerender(dc);
                                                 Node.NodeData.minusdrawpos:=dc.DrawingContext.DRAWCOUNT
                                            end;
            if assigned(Node.pplusnode)then
                                           if (Node.NodeData.plusdrawpos<>dc.DrawingContext.DRAWCOUNT)or(dc.MaxDetail) then
                                           begin
                                                treerender(Node.pplusnode^,dc);
                                                //PTEntTreeNode(Node.pplusnode)^.treerender(dc);
                                                Node.NodeData.plusdrawpos:=dc.DrawingContext.DRAWCOUNT
                                           end;
            end;
            begin
                 if (Node.NodeData.FulDraw=TDTFulDraw)or(dc.MaxDetail) then
                                                                      Node.nul.DrawWithattrib(dc);
                 Node.NodeData.nuldrawpos:=dc.DrawingContext.DRAWCOUNT;
            end;
       end;
     end;
end;
class function TZEntsManipulator.isUnneedSeparate(const count,depth:integer):boolean;
begin
     if (Count<=GetInNodeCount(SysVarRDSpatialNodeCount))or(depth>=SysVarRDSpatialNodesDepth) then
       result:=true
     else
       result:=false;
end;
class function TZEntsManipulator.GetTestNodesCount:integer;
begin
   result:=3;
end;
class procedure TZEntsManipulator.FirstStageCalcSeparatirs(var Entity:GDBObjEntity;var PFirstStageData:pointer;TSM:TStageMode);
begin
   case TSM of
       TSMStart:begin
                   FirstStageData.midlepoint:=NulVertex;
                   FirstStageData.counter:=0;
                   PFirstStageData:=@FirstStageData;
                end;
TSMAccumulation:begin
                   FirstStageData.midlepoint:=vertexadd(Entity.vp.BoundingBox.LBN,FirstStageData.midlepoint);
                   FirstStageData.midlepoint:=vertexadd(Entity.vp.BoundingBox.RTF,FirstStageData.midlepoint);
                   inc(FirstStageData.counter,2);
                end;
        TSMCalc:begin
                   FirstStageData.midlepoint:=VertexMulOnSc(FirstStageData.midlepoint,1/FirstStageData.counter);
                   FirstStageData.d:=sqrt(sqr(FirstStageData.midlepoint.x) + sqr(FirstStageData.midlepoint.y) + sqr(FirstStageData.midlepoint.z));
                end;
         TSMEnd:begin
                   PFirstStageData:=nil;
                end;
   end;
end;
class procedure TZEntsManipulator.CreateSeparator(var TestNode:TEntTreeNode.TTestNode;var PFirstStageData:pointer;const NodeNum:integer);
begin
case NodeNum of
      0:TestNode.plane:=uzegeometry.PlaneFrom3Pont(FirstStageData.midlepoint,
                                          vertexadd(FirstStageData.midlepoint,VertexMulOnSc(x_Y_zVertex,FirstStageData.d)),
                                          vertexadd(FirstStageData.midlepoint,VertexMulOnSc(xy_Z_Vertex,FirstStageData.d))
                                          );
      1:TestNode.plane:=uzegeometry.PlaneFrom3Pont(FirstStageData.midlepoint,
                                          vertexadd(FirstStageData.midlepoint,VertexMulOnSc(_X_yzVertex,FirstStageData.d)),
                                          vertexadd(FirstStageData.midlepoint,VertexMulOnSc(xy_Z_Vertex,FirstStageData.d))
                                          );
      2:TestNode.plane:=uzegeometry.PlaneFrom3Pont(FirstStageData.midlepoint,
                                          vertexadd(FirstStageData.midlepoint,VertexMulOnSc(_X_yzVertex,FirstStageData.d)),
                                          vertexadd(FirstStageData.midlepoint,VertexMulOnSc(x_Y_ZVertex,FirstStageData.d))
                                          );
end;
end;
class procedure TZEntsManipulator.StoreTreeAdressInOnject(var Entity:GDBObjEntity;var Node:GZBInarySeparatedGeometry{-}<TBoundingBox,DVector4D,TEntTreeNodeData,TZEntsManipulator,GDBObjEntity>;const index:GDBInteger);
begin
  Entity.bp.TreePos.Owner:=@Node;
  Entity.bp.TreePos.SelfIndex:=index;
end;
class procedure TZEntsManipulator.CorrectNodeBoundingBox(var NodeBB:TBoundingBox;var Entity:GDBObjEntity);
begin
     ConcatBB(NodeBB,GetEntityBoundingBox(Entity));
end;
class function TZEntsManipulator.GetEntityBoundingBox(var Entity:GDBObjEntity):TBoundingBox;
begin
     result:=Entity.vp.BoundingBox;
end;

class function TZEntsManipulator.GetBBPosition(const sep:DVector4D;const BB:TBoundingBox):TElemPosition;
var
    d,d1,d2:double;
begin
     d1:=sep[0] * BB.RTF.x + sep[1] * BB.RTF.y + sep[2] * BB.RTF.z + sep[3];
     d2:=sep[0] * BB.LBN.x + sep[1] * BB.LBN.y + sep[2] * BB.LBN.z + sep[3];
     if abs(d1)<eps then
                        d1:=0;
     if abs(d2)<eps then
                        d2:=0;
     d:=d1*d2;

     if d=0 then
                begin
                     if (d1=0)and(d2=0) then
                                            exit(TEP_nul)
                                            //ta[i].nul.PushBackData(pobj)
                else if (d1>0)or(d2>0)  then
                                            exit(TEP_Plus)
                                            //ta[i].plus.PushBackData(pobj)
                                        else
                                            exit(TEP_Minus)
                                            //ta[i].minus.PushBackData(pobj);
                end
else if d<0 then
                exit(TEP_nul)
                //ta[i].nul.PushBackData(pobj)
else if (d1>0)or(d2>0)  then
                            exit(TEP_Plus)
                            //ta[i].plus.PushBackData(pobj)
                        else
                            exit(TEP_Minus)
                            //ta[i].minus.PushBackData(pobj);
     //result:=TEP_nul;
end;

procedure TEntTreeNode.MakeTreeFrom(var entitys:GDBObjEntityOpenArray;AABB:TBoundingBox;nodedepth:GDBInteger);
var
    pobj:PGDBObjEntity;
    ir:itrec;
begin
     ClearSub;
     Lock;
     pobj:=entitys.beginiterate(ir);
     if pobj<>nil then
       repeat
         AddObjectToNodeTree(pobj^);
         pobj:=entitys.iterate(ir);
       until pobj=nil;
     UnLock;
     //createtree(entitys,AABB,nil,@self,nodedepth,TND_Root);
end;
function GetInNodeCount(_InNodeCount:GDBInteger):GDBInteger;
begin
     if _InNodeCount>0 then
                           result:=_InNodeCount
                       else
                           result:=500;
end;
begin
end.
