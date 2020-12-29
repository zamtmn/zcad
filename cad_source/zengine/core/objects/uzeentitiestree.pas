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
    gzctnrvectortypes,graphics,gzctnrvectorsimple,gzctnrvectorpobjects,
    uzbgeomtypes,gzctnrtree,uzgldrawcontext,uzegeometry,UGDBVisibleOpenArray,uzeentity,uzbtypesbase,uzbtypes,uzbmemman;
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
TEntityArray=GZVectorPObects{GZVectorSimple}{-}<PGDBObjEntity,GDBObjEntity>{//}; {надо вынести куданить отдельно}
         PTEntTreeNode=^TEntTreeNode;
         {---REGISTEROBJECTTYPE TEntTreeNode}
         TEntTreeNode=object(GZBInarySeparatedGeometry{-}<TBoundingBox,DVector4D,TEntTreeNodeData,TZEntsManipulator,GDBObjEntity,PGDBObjEntity,TEntityArray>{//})
                            procedure MakeTreeFrom(var entitys:GDBObjEntityOpenArray;AABB:TBoundingBox;const RN:Pointer);
                            procedure DrawVolume(var DC:TDrawContext);
                            procedure DrawNodeVolume(var DC:TDrawContext);
                            procedure DrawWithAttribExternalArray(var DC:TDrawContext);
                      end;
{EXPORT-}
TZEntsManipulator=class
                   class procedure StoreTreeAdressInOnject(var Entity:GDBObjEntity;var Node:GZBInarySeparatedGeometry<TBoundingBox,DVector4D,TEntTreeNodeData,TZEntsManipulator,GDBObjEntity,PGDBObjEntity,TEntityArray>;const index:GDBInteger);
                   class procedure CorrectNodeBoundingBox(var NodeBB:TBoundingBox;var Entity:GDBObjEntity);
                   class function GetEntityBoundingBox(var Entity:GDBObjEntity):TBoundingBox;
                   class function GetBBPosition(const sep:DVector4D;const BB:TBoundingBox):TElemPosition;
                   class function isUnneedSeparate(const count,depth:integer):boolean;
                   class function GetTestNodesCount:integer;
                   class procedure FirstStageCalcSeparatirs(var NodeBB:TBoundingBox;var Entity:GDBObjEntity;var PFirstStageData:pointer;TSM:TStageMode);
                   class procedure CreateSeparator(var NodeBB:TBoundingBox;var TestNode:TEntTreeNode.TTestNode;var PFirstStageData:pointer;const NodeNum:integer);
                   class function IterateResult2PEntity(const IterateResult:pointer):PGDBObjEntity;
                   class function StoreEntityToArray(var Entity:GDBObjEntity;var arr:TEntityArray):TArrayIndex;

                   {not used in generic, for external use}
                   class procedure treerender(var Node:GZBInarySeparatedGeometry<TBoundingBox,DVector4D,TEntTreeNodeData,TZEntsManipulator,GDBObjEntity,PGDBObjEntity,TEntityArray>;var DC:TDrawContext);
                  end;
TTestTreeArray=array [0..2] of TEntTreeNode.TTestNode;
var
   SysVarRDSpatialNodeCount:integer=500;
   SysVarRDSpatialNodesDepth:integer=16;
   FirstStageData:TFirstStageData;
function GetInNodeCount(_InNodeCount:GDBInteger):GDBInteger;
implementation
procedure TEntTreeNode.DrawWithAttribExternalArray(var DC:TDrawContext);
var
  pobj:pGDBObjEntity;
  ir:itrec;
begin
  pobj:=nul.beginiterate(ir);
  if pobj<>nil then
  repeat
       pobj:=TZEntsManipulator.IterateResult2PEntity(pobj);
       if pobj^.infrustum=dc.DrawingContext.infrustumactualy then
                           pobj^.DrawWithAttrib(dc);
       pobj:=nul.iterate(ir);
  until pobj=nil;
end;
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
class procedure TZEntsManipulator.treerender(var Node:GZBInarySeparatedGeometry<TBoundingBox,DVector4D,TEntTreeNodeData,TZEntsManipulator,GDBObjEntity,PGDBObjEntity,TEntityArray>;var DC:TDrawContext);
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
                                                                      TEntTreeNode(Node).DrawWithAttribExternalArray(dc);
                                                                      //GDBObjEntityOpenArray(Node.nul).DrawWithattrib(dc);
                 Node.NodeData.nuldrawpos:=dc.DrawingContext.DRAWCOUNT;
            end;
       end;
     end;
end;
class function TZEntsManipulator.StoreEntityToArray(var Entity:GDBObjEntity;var arr:TEntityArray):TArrayIndex;
begin
     result:=arr.pushBackData(@Entity);
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
class procedure TZEntsManipulator.FirstStageCalcSeparatirs(var NodeBB:TBoundingBox;var Entity:GDBObjEntity;var PFirstStageData:pointer;TSM:TStageMode);
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
class procedure TZEntsManipulator.CreateSeparator(var NodeBB:TBoundingBox;var TestNode:TEntTreeNode.TTestNode;var PFirstStageData:pointer;const NodeNum:integer);
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
class procedure TZEntsManipulator.StoreTreeAdressInOnject(var Entity:GDBObjEntity;var Node:GZBInarySeparatedGeometry{-}<TBoundingBox,DVector4D,TEntTreeNodeData,TZEntsManipulator,GDBObjEntity,PGDBObjEntity,TEntityArray>;const index:GDBInteger);
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
class function TZEntsManipulator.IterateResult2PEntity(const IterateResult:pointer):PGDBObjEntity;
begin
  {if IterateResult<>nil then
    result:=ppointer(IterateResult)^
  else
    result:=nil;}
  result:=IterateResult;
end;

procedure TEntTreeNode.MakeTreeFrom(var entitys:GDBObjEntityOpenArray;AABB:TBoundingBox;const RN:Pointer);
var
    pobj:PGDBObjEntity;
    ir:itrec;
begin
     ClearSub;
     Lock;
     root:=rn;
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
