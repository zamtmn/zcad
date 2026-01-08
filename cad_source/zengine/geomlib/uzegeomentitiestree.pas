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

unit uzegeomentitiestree;
{$Mode delphi}{$H+}
{$INCLUDE zengineconfig.inc}
interface
uses
    graphics,uzgeomentity,
    gzctnrVectorTypes,uzegeometrytypes,gzctnrBinarySeparatedTree,uzegeometry,
    gzctnrAlignedVectorObjects;
type
  TZEntsManipulator=class;
  TFirstStageData=record
    midlepoint:TzePoint3d;
    d:double;
    counter:integer;
  end;
  TEntityArray= object(GZAlignedVectorObjects<PTGeomEntity>)
  end;
  TGeomTreeNodeData=record
    procedure CreateDef;
    procedure Clear;
    procedure Destroy;
    procedure AfterSeparateNode(var nul:TEntityArray);
  end;
  PTEntTreeNode=^TGeomEntTreeNode;
  TGeomEntTreeNode=object(GZBInarySeparatedGeometry<TBoundingBox,TzeVector4d,TGeomTreeNodeData,TZEntsManipulator,TGeomEntity,PTGeomEntity,TEntityArray>)
  end;

  TZEntsManipulator=class
    class procedure StoreTreeAdressInOnject(var Entity:TGeomEntity;var Node:GZBInarySeparatedGeometry<TBoundingBox,TzeVector4d,TGeomTreeNodeData,TZEntsManipulator,TGeomEntity,PTGeomEntity,TEntityArray>;const index:Integer); static;
    class procedure CorrectNodeBoundingBox(var NodeBB:TBoundingBox;var Entity:TGeomEntity); static; inline;
    class function GetEntityBoundingBox(var Entity:TGeomEntity):TBoundingBox; static; inline;
    class function GetBBPosition(const sep:TzeVector4d;const BB:TBoundingBox):TElemPosition; static;
    class function isUnneedSeparate(const count,depth:integer):boolean; static; inline;
    class function GetTestNodesCount:integer; static; inline;
    class procedure FirstStageCalcSeparatirs(var NodeBB:TBoundingBox;var Entity:TGeomEntity;var PFirstStageData:pointer;TSM:TStageMode); static;
    class procedure CreateSeparator(var NodeBB:TBoundingBox;var TestNode:TGeomEntTreeNode.TTestNode;var PFirstStageData:pointer;const NodeNum:integer); static;
    class function IterateResult2PEntity(const IterateResult:pointer):PTGeomEntity; static; inline;
    class function StoreEntityToArray(var Entity:TGeomEntity;var arr:TEntityArray):TArrayIndex; static; inline;
    class function EntitySizeOrOne(var Entity:TGeomEntity):integer; static; inline;
    class procedure SetSizeInArray(ns:integer;var arr:TEntityArray); static; inline;
  end;
var
  SysVarRDSpatialNodeCount:integer=2;
  SysVarRDSpatialNodesDepth:integer=20;
  FirstStageData:TFirstStageData;
function GetInNodeCount(_InNodeCount:Integer):Integer;
implementation
procedure TGeomTreeNodeData.CreateDef;
begin
end;
procedure TGeomTreeNodeData.Clear;
begin
end;
procedure TGeomTreeNodeData.Destroy;
begin
end;
procedure TGeomTreeNodeData.AfterSeparateNode(var nul:TEntityArray);
begin
end;
class function TZEntsManipulator.EntitySizeOrOne(var Entity:TGeomEntity):integer;
begin
  result:=sizeof(Entity);
end;
class procedure TZEntsManipulator.SetSizeInArray(ns:integer;var arr:TEntityArray);
begin
  arr.SetSize(ns);
end;
class function TZEntsManipulator.StoreEntityToArray(var Entity:TGeomEntity;var arr:TEntityArray):TArrayIndex;
begin
     //arr.pushBackData(Entity);
     result:=arr.AddData(@Entity,sizeof(entity));
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
   result:=1;
end;
class procedure TZEntsManipulator.FirstStageCalcSeparatirs(var NodeBB:TBoundingBox;var Entity:TGeomEntity;var PFirstStageData:pointer;TSM:TStageMode);
begin
   case TSM of
       TSMStart:begin
                   FirstStageData.midlepoint:=NulVertex;
                   FirstStageData.counter:=0;
                   PFirstStageData:={@FirstStageData}nil;
                end;
TSMAccumulation:begin
                   //FirstStageData.midlepoint:=vertexadd(Entity.GetBB.LBN,FirstStageData.midlepoint);
                   //FirstStageData.midlepoint:=vertexadd(Entity.GetBB.RTF,FirstStageData.midlepoint);
                   //inc(FirstStageData.counter,2);
                end;
        TSMCalc:begin
                   //FirstStageData.midlepoint:=VertexMulOnSc(FirstStageData.midlepoint,1/FirstStageData.counter);
                   //FirstStageData.d:=sqrt(sqr(FirstStageData.midlepoint.x) + sqr(FirstStageData.midlepoint.y) + sqr(FirstStageData.midlepoint.z));
                end;
         TSMEnd:begin
                   PFirstStageData:=nil;
                end;
   end;
end;
class procedure TZEntsManipulator.CreateSeparator(var NodeBB:TBoundingBox;var TestNode:TGeomEntTreeNode.TTestNode;var PFirstStageData:pointer;const NodeNum:integer);
var
   v:TzePoint3d;
   axis:integer;
begin
   v:=VertexSub(NodeBB.RTF,NodeBB.LBN);
   if v.x>v.y then
              begin
                   if v.x>v.z then
                              axis:=0
                          else
                              axis:=2
              end
          else
              begin
                   if v.y>v.z then
                              axis:=1
                          else
                              axis:=2
              end;
   FirstStageData.midlepoint:=VertexMulOnSc(VertexAdd(NodeBB.RTF,NodeBB.LBN),0.5);
   FirstStageData.d:=sqrt(sqr(FirstStageData.midlepoint.x) + sqr(FirstStageData.midlepoint.y) + sqr(FirstStageData.midlepoint.z));
case axis of
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
class procedure TZEntsManipulator.StoreTreeAdressInOnject(var Entity:TGeomEntity;var Node:GZBInarySeparatedGeometry<TBoundingBox,TzeVector4d,TgeomTreeNodeData,TZEntsManipulator,TGeomEntity,PTGeomEntity,TEntityArray>;const index:Integer);
begin
  {Entity.bp.TreePos.Owner:=@Node;
  Entity.bp.TreePos.SelfIndex:=index;}
end;
class procedure TZEntsManipulator.CorrectNodeBoundingBox(var NodeBB:TBoundingBox;var Entity:TGeomEntity);
begin
     ConcatBB(NodeBB,GetEntityBoundingBox(Entity));
end;
class function TZEntsManipulator.GetEntityBoundingBox(var Entity:TGeomEntity):TBoundingBox;
begin
     result:=Entity.GetBB;
end;

class function TZEntsManipulator.GetBBPosition(const sep:TzeVector4d;const BB:TBoundingBox):TElemPosition;
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
class function TZEntsManipulator.IterateResult2PEntity(const IterateResult:pointer):PTGeomEntity;
begin
  {if IterateResult<>nil then
    result:=ppointer(IterateResult)^
  else
    result:=nil;}
  result:=IterateResult;
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
