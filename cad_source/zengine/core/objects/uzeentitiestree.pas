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

unit uzeentitiestree;
{$Mode delphi}{$H+}
{$INCLUDE zengineconfig.inc}
interface
uses
    gzctnrVectorTypes,graphics,gzctnrVectorSimple,gzctnrVectorPObjects,
    uzegeometrytypes,gzctnrBinarySeparatedTree,uzgldrawcontext,uzegeometry,
    UGDBVisibleOpenArray,uzeentity,uzbtypes,gzctnrVectorP;
type
TZEntsManipulator=class;
TFirstStageData=record
                  midlepoint:TzePoint3d;
                  d:double;
                  counter:integer;
                end;
{EXPORT+}
  TDrawType=(TDTFulDraw,TDTSimpleDraw);
  TEntityArray=GZVectorPObects<PGDBObjEntity,GDBObjEntity>;
  TEntTreeNodeData=record
    infrustum:TActuality;
    inFrustumState:TInBoundingVolume;
    nuldrawpos,minusdrawpos,plusdrawpos:TActuality;
    FulDraw:TDrawType;
    InFrustumBoundingBox:TBoundingBox;
    NeedToSeparated:GZVectorP<PGDBObjEntity>;
    //nodedepth:Integer;
    //pluscount,minuscount:Integer;
    procedure CreateDef;
    procedure Clear;
    procedure Destroy;
    procedure AfterSeparateNode(var nul:TEntityArray);
  end;
         PTEntTreeNode=^TEntTreeNode;
         {---REGISTEROBJECTTYPE TEntTreeNode}
         TEntTreeNode=object(GZBInarySeparatedGeometry{-}<TBoundingBox,DVector4d,TEntTreeNodeData,TZEntsManipulator,GDBObjEntity,PGDBObjEntity,TEntityArray>{//})
                            procedure MakeTreeFrom(var entitys:GDBObjEntityOpenArray;AABB:TBoundingBox;const RN:Pointer);
                            procedure DrawVolume(var DC:TDrawContext);
                            procedure DrawNodeVolume(var DC:TDrawContext);
                            procedure DrawWithAttribExternalArray(var DC:TDrawContext;LODDeep:integer=0);
                            procedure DeleteFromSeparated(var Entity:GDBObjEntity);
                      end;
{EXPORT-}
TZEntsManipulator=class
                   class procedure StoreTreeAdressInOnject(var Entity:GDBObjEntity;var Node:GZBInarySeparatedGeometry<TBoundingBox,DVector4d,TEntTreeNodeData,TZEntsManipulator,GDBObjEntity,PGDBObjEntity,TEntityArray>;const index:Integer);
                   class procedure CorrectNodeBoundingBox(var NodeBB:TBoundingBox;var Entity:GDBObjEntity);
                   class function GetEntityBoundingBox(var Entity:GDBObjEntity):TBoundingBox;
                   class function GetBBPosition(const sep:DVector4d;const BB:TBoundingBox):TElemPosition;
                   class function isUnneedSeparate(const count,depth:integer):boolean;
                   class function GetTestNodesCount:integer;
                   class procedure FirstStageCalcSeparatirs(var NodeBB:TBoundingBox;var Entity:GDBObjEntity;var PFirstStageData:pointer;TSM:TStageMode);
                   class procedure CreateSeparator(var NodeBB:TBoundingBox;var TestNode:TEntTreeNode.TTestNode;var PFirstStageData:pointer;const NodeNum:integer);
                   class function IterateResult2PEntity(const IterateResult:pointer):PGDBObjEntity;inline;
                   class function StoreEntityToArray(var Entity:GDBObjEntity;var arr:TEntityArray):TArrayIndex;
                   class function EntitySizeOrOne(var Entity:GDBObjEntity):integer;
                   class procedure SetSizeInArray(ns:integer;var arr:TEntityArray);

                   {not used in generic, for external use}
                   class procedure treerender(var Node:GZBInarySeparatedGeometry<TBoundingBox,DVector4d,TEntTreeNodeData,TZEntsManipulator,GDBObjEntity,PGDBObjEntity,TEntityArray>;var DC:TDrawContext;LODDeep:integer=0);
                  end;
TTestTreeArray=array [0..2] of TEntTreeNode.TTestNode;
var
   SysVarRDSpatialNodeCount:integer=500;
   SysVarRDSpatialNodesDepth:integer=16;
   FirstStageData:TFirstStageData;
function GetInNodeCount(_InNodeCount:Integer):Integer;
implementation
procedure TEntTreeNodeData.CreateDef;
begin
  infrustum:=0;
  inFrustumState:=TInBoundingVolume.IRNotAplicable;
  nuldrawpos:=0;
  FulDraw:=TDTFulDraw;
  InFrustumBoundingBox:=default(TBoundingBox);
  NeedToSeparated.initnul;
end;
procedure TEntTreeNodeData.Clear;
begin
  infrustum:=0;
  nuldrawpos:=0;
  FulDraw:=TDTFulDraw;
  NeedToSeparated.clear;
end;
procedure TEntTreeNodeData.Destroy;
begin
  NeedToSeparated.Clear;
  NeedToSeparated.done;
end;
procedure TEntTreeNodeData.AfterSeparateNode(var nul:TEntityArray);
var
  pobj:PGDBObjEntity;
  ir:itrec;
begin
  pobj:=nul.beginiterate(ir);
  if pobj<>nil then
  repeat
    if pobj^.IsNeedSeparate then begin
      if NeedToSeparated.GetCount=0 then begin
        NeedToSeparated.SetSize(nul.Count-ir.itc+1);
      end;
      NeedToSeparated.PushBackData(pobj);
    end;
    pobj:=nul.iterate(ir);
  until pobj=nil;
end;
class function TZEntsManipulator.EntitySizeOrOne(var Entity:GDBObjEntity):integer;
begin
  result:=1;
end;

procedure TEntTreeNode.DrawWithAttribExternalArray(var DC:TDrawContext;LODDeep:integer=0);
var
  pobj:pGDBObjEntity;
  ir:itrec;
begin
  pobj:=nul.beginiterate(ir);
  if pobj<>nil then
  repeat
       pobj:=TZEntsManipulator.IterateResult2PEntity(pobj);
       if pobj^.infrustum=dc.DrawingContext.VActuality.infrustumactualy then
         pobj^.DrawWithAttrib(dc,NodeData.inFrustumState);
       pobj:=nul.iterate(ir);
       if LODDeep>2 then
         pobj:=nul.iterate(ir);
       if LODDeep>3 then
         pobj:=nul.iterate(ir);
  until pobj=nil;
end;
procedure TEntTreeNode.DeleteFromSeparated(var Entity:GDBObjEntity);
begin
  NodeData.NeedToSeparated.RemoveData(@Entity);
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

function SqrCanSimplyDrawInWCS(const DC:TDrawContext;const ParamSize,TargetSize:Double):Boolean;
var
   templod:Double;
begin
     if dc.maxdetail then
                         exit(true);
  templod:=(ParamSize)/(dc.DrawingContext.zoom*dc.DrawingContext.zoom);
  if templod>TargetSize then
                            exit(true)
                        else
                            exit(false);
end;

class procedure TZEntsManipulator.treerender(var Node:GZBInarySeparatedGeometry<TBoundingBox,DVector4d,TEntTreeNodeData,TZEntsManipulator,GDBObjEntity,PGDBObjEntity,TEntityArray>;var DC:TDrawContext;LODDeep:integer=0);
const
  MaxLODDeepDrtaw=2;
var
  v:TzePoint3d;
  LODSave:TLOD;
begin
  if (Node.NodeData.infrustum=dc.DrawingContext.VActuality.InfrustumActualy) then begin

    LODSave:=DC.LOD;
    if DC.LOD=LODCalculatedDetail then begin
      if LODDeep=0 then begin
        v:=Node.BoundingBox.RTF-Node.BoundingBox.LBN;
        if not SqrCanSimplyDrawInWCS(DC,uzegeometry.SqrOneVertexlength(v),300) then begin
          DC.LOD:=LODLowDetail;
          inc(LODDeep);
        end;
      end else
        inc(LODDeep);
      end else if LODDeep>0 then
        inc(loddeep);

    if Node.NodeData.FulDraw=TDTFulDraw then
    if (Node.NodeData.FulDraw=TDTFulDraw)or(Node.nul.count=0) then begin
      if assigned(Node.pminusnode)and(LODDeep<MaxLODDeepDrtaw)then
        if (Node.NodeData.minusdrawpos<>dc.DrawingContext.DRAWCOUNT)or(dc.MaxDetail) then begin
          treerender(Node.pminusnode^,dc,loddeep);
          Node.NodeData.minusdrawpos:=dc.DrawingContext.DRAWCOUNT
        end;
      if assigned(Node.pplusnode)and(LODDeep<MaxLODDeepDrtaw)then
        if (Node.NodeData.plusdrawpos<>dc.DrawingContext.DRAWCOUNT)or(dc.MaxDetail) then begin
          treerender(Node.pplusnode^,dc,loddeep);
          Node.NodeData.plusdrawpos:=dc.DrawingContext.DRAWCOUNT
        end;
    end;
    if (Node.NodeData.FulDraw=TDTFulDraw)or(dc.MaxDetail) then
      TEntTreeNode(Node).DrawWithAttribExternalArray(dc);
    Node.NodeData.nuldrawpos:=dc.DrawingContext.DRAWCOUNT;

    DC.LOD:=LODSave;
  end;
end;
class procedure TZEntsManipulator.SetSizeInArray(ns:integer;var arr:TEntityArray);
begin
  arr.SetSize(ns);
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
class procedure TZEntsManipulator.StoreTreeAdressInOnject(var Entity:GDBObjEntity;var Node:GZBInarySeparatedGeometry{-}<TBoundingBox,DVector4d,TEntTreeNodeData,TZEntsManipulator,GDBObjEntity,PGDBObjEntity,TEntityArray>;const index:Integer);
begin
  Entity.bp.TreePos.Owner:=@Node;
  Entity.bp.TreePos.SelfIndexInNode:=index;
  if Entity.IsNeedSeparate then
    node.NodeData.NeedToSeparated.PushBackData(@Entity);
end;
class procedure TZEntsManipulator.CorrectNodeBoundingBox(var NodeBB:TBoundingBox;var Entity:GDBObjEntity);
begin
     ConcatBB(NodeBB,GetEntityBoundingBox(Entity));
end;
class function TZEntsManipulator.GetEntityBoundingBox(var Entity:GDBObjEntity):TBoundingBox;
begin
     result:=Entity.vp.BoundingBox;
end;

class function TZEntsManipulator.GetBBPosition(const sep:DVector4d;const BB:TBoundingBox):TElemPosition;
var
    d,d1,d2:double;
begin
     d1:=sep.v[0] * BB.RTF.x + sep.v[1] * BB.RTF.y + sep.v[2] * BB.RTF.z + sep.v[3];
     d2:=sep.v[0] * BB.LBN.x + sep.v[1] * BB.LBN.y + sep.v[2] * BB.LBN.z + sep.v[3];
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
     nul.SetSize(entitys.Count);
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
function GetInNodeCount(_InNodeCount:Integer):Integer;
begin
     if _InNodeCount>0 then
                           result:=_InNodeCount
                       else
                           result:=500;
end;
begin
end.
