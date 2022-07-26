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

unit gzctnrBinarySeparatedTree;

interface
uses
    gzctnrVectorTypes,gzctnrVectorPObjects,gzctnrVectorSimple;
type
{EXPORT+}
         TStageMode=(TSMStart,TSMAccumulation,TSMCalc,TSMEnd);
         TNodeDir=(TND_Plus,TND_Minus,TND_Root);
         TElemPosition=(TEP_Plus,TEP_Minus,TEP_nul);
         {----REGISTEROBJECTTYPE GZBInarySeparatedGeometry}
         GZBInarySeparatedGeometry{-}<TBoundingBox,TSeparator,TNodeData,TEntsManipulator,TEntity,TEntityArrayIterateResult,TEntityArray>{//}
                                   =object
         {-}type{//}
            {-}PGZBInarySeparatedGeometry=^GZBInarySeparatedGeometry<TBoundingBox,//ограничивающий объем{//}
                                                                  {-}TSeparator,//разделитель{//}
                                                                  {-}TNodeData,//дополнительные данные в ноде{//}
                                                                  {-}TEntsManipulator,//то что невозможно закодировать в генерике{//}
                                                                  {-}TEntity,//примитив{//}
                                                                  {-}TEntityArrayIterateResult,//примитив{//}
                                                                  {-}TEntityArray>;//массив примитивов{//}
            {-}(*TEntityArray={GZVectorPObects}GZVectorSimple<PTEntity{,TEntity}>;*){//}
            {-}PTEntity=^TEntity;{//}
            {-}TTestNode=Object{//}
                 {-}plane:TSeparator;{//}
                 {-}nul,plus,minus:TEntityArray;{//}
                 {-}constructor initnul(InNodeCount:integer);{//}
                 {-}destructor done;virtual;{//}
            {-}end;{//}
         {-}var{//}
            {-}pplusnode,pminusnode:PGZBInarySeparatedGeometry;{//}
            {-}nul:TEntityArray;{//}
            {-}Separator:TSeparator;{//}
            {-}BoundingBox:TBoundingBox;{//}
            {-}NodeDir:TNodeDir;{//}
            {-}Root:PGZBInarySeparatedGeometry;{//}
            {-}NodeData:TNodeData;{//}
            {-}LockCounter:integer;{//}
            destructor done;virtual;
            procedure ClearSub;
            procedure Shrink;
            constructor initnul;
            procedure AddObjToNul(var Entity:TEntity);
            procedure updateenttreeadress;
            procedure CorrectNodeBoundingBox(var Entity:TEntity);
            procedure AddObjectToNodeTree(var Entity:TEntity);
            procedure Lock;
            procedure UnLock;
            procedure Separate;virtual;
            function GetNodeDepth:integer;virtual;
            procedure MoveSub(var node:GZBInarySeparatedGeometry<TBoundingBox,TSeparator,TNodeData,TEntsManipulator,TEntity,TEntityArrayIterateResult,TEntityArray>);
            function GetOptimalTestNode(var TNArray:array of TTestNode):integer;
            procedure StoreOptimalTestNode(var TestNode:TTestNode);

            function nuliterate(var ir:itrec):Pointer;
            function nulbeginiterate(out ir:itrec):Pointer;
            function nulDeleteElement(index:Integer):Pointer;
          end;
{EXPORT-}
implementation
constructor GZBInarySeparatedGeometry<TBoundingBox,TSeparator,TNodeData,TEntsManipulator,TEntity,TEntityArrayIterateResult,TEntityArray>.TTestNode.initnul;
begin
     nul.init(InNodeCount);
     plus.init(InNodeCount);
     minus.init(InNodeCount);
end;
destructor GZBInarySeparatedGeometry<TBoundingBox,TSeparator,TNodeData,TEntsManipulator,TEntity,TEntityArrayIterateResult,TEntityArray>.TTestNode.done;
begin
     nul.Clear;
     nul.Done;
     plus.Clear;
     plus.Done;
     minus.Clear;
     minus.Done;
end;

procedure GZBInarySeparatedGeometry<TBoundingBox,TSeparator,TNodeData,TEntsManipulator,TEntity,TEntityArrayIterateResult,TEntityArray>.Lock;
begin
  inc(LockCounter);
end;
procedure GZBInarySeparatedGeometry<TBoundingBox,TSeparator,TNodeData,TEntsManipulator,TEntity,TEntityArrayIterateResult,TEntityArray>.UnLock;
begin
  dec(LockCounter);
  if LockCounter=0 then
    separate;
end;
function GZBInarySeparatedGeometry<TBoundingBox,TSeparator,TNodeData,TEntsManipulator,TEntity,TEntityArrayIterateResult,TEntityArray>.GetNodeDepth:integer;
begin
  if Root=nil then
                  result:=0
              else
                  result:=1+Root^.GetNodeDepth;
end;
function GZBInarySeparatedGeometry<TBoundingBox,TSeparator,TNodeData,TEntsManipulator,TEntity,TEntityArrayIterateResult,TEntityArray>.GetOptimalTestNode(var TNArray:array of TTestNode):integer;
var
   entcount,dentcount,i:integer;
begin
  entcount:=TNArray[0].nul.Count;
  dentcount:=abs(TNArray[0].plus.Count-TNArray[0].minus.Count);
  result:=0;
  for i:=1 to high(TNArray) do
  begin
       if TNArray[i].nul.Count<entcount then
                                       begin
                                            entcount:=TNArray[i].nul.Count;
                                            dentcount:=abs(TNArray[i].plus.Count-TNArray[i].minus.Count);
                                            result:=i;
                                       end
  else if TNArray[i].nul.Count=entcount then
                                    begin
                                         if abs(TNArray[i].plus.Count-TNArray[i].minus.Count)<dentcount then
                                         begin
                                              entcount:=TNArray[i].nul.Count;
                                              dentcount:=abs(TNArray[i].plus.Count-TNArray[i].minus.Count);
                                              result:=i;
                                         end;
                                    end;
  end;
end;
function GZBInarySeparatedGeometry<TBoundingBox,TSeparator,TNodeData,TEntsManipulator,TEntity,TEntityArrayIterateResult,TEntityArray>.nuliterate(var ir:itrec):Pointer;
begin
  result:=nul.iterate(ir);
  result:=TEntsManipulator.IterateResult2PEntity(result);
end;
function GZBInarySeparatedGeometry<TBoundingBox,TSeparator,TNodeData,TEntsManipulator,TEntity,TEntityArrayIterateResult,TEntityArray>.nulbeginiterate(out ir:itrec):Pointer;
begin
  result:=nul.beginiterate(ir);
  result:=TEntsManipulator.IterateResult2PEntity(result);
end;
function GZBInarySeparatedGeometry<TBoundingBox,TSeparator,TNodeData,TEntsManipulator,TEntity,TEntityArrayIterateResult,TEntityArray>.nulDeleteElement(index:Integer):Pointer;
begin
  result:=nul.DeleteElement(index);
end;

procedure GZBInarySeparatedGeometry<TBoundingBox,TSeparator,TNodeData,TEntsManipulator,TEntity,TEntityArrayIterateResult,TEntityArray>.StoreOptimalTestNode(var TestNode:TTestNode);
var
    pobj:PTEntity;
    ir:itrec;
begin
  nul.clear;
  TestNode.nul.copyto(nul);
  Separator:=TestNode.plane;
  if TestNode.plus.count>0 then
  begin
    if pplusnode=nil then
      begin
        Getmem(pointer(pplusnode),sizeof(GZBInarySeparatedGeometry<TBoundingBox,TSeparator,TNodeData,TEntsManipulator,TEntity,TEntityArrayIterateResult,TEntityArray>));
        pplusnode.initnul;
      end;
      pplusnode.lock;
      pplusnode.root:=@self;
       pobj:=TestNode.plus.beginiterate(ir);
       if pobj<>nil then
         repeat
           pobj:=TEntsManipulator.IterateResult2PEntity(pobj);
           pplusnode.AddObjectToNodeTree(pobj^);
           pobj:=TestNode.plus.iterate(ir);
         until pobj=nil;
      pplusnode.unlock;
  end;
  if TestNode.minus.count>0 then
  begin
    if pminusnode=nil then
      begin
        Getmem(pointer(pminusnode),sizeof(GZBInarySeparatedGeometry<TBoundingBox,TSeparator,TNodeData,TEntsManipulator,TEntity,TEntityArrayIterateResult,TEntityArray>));
        pminusnode.initnul;
      end;
      pminusnode.lock;
      pminusnode.root:=@self;
      pobj:=TestNode.minus.beginiterate(ir);
      if pobj<>nil then
        repeat
          pobj:=TEntsManipulator.IterateResult2PEntity(pobj);
          pminusnode.AddObjectToNodeTree(pobj^);
          pobj:=TestNode.minus.iterate(ir);
        until pobj=nil;
      pminusnode.unlock;
  end;
end;
procedure GZBInarySeparatedGeometry<TBoundingBox,TSeparator,TNodeData,TEntsManipulator,TEntity,TEntityArrayIterateResult,TEntityArray>.Separate;
var
   TestNodesCount,OptimalTestNode:integer;
   TNArray:array of TTestNode;
   i:integer;
   PFirstStageData:pointer;
   pobj:PTEntity;
   ir:itrec;
   ep:TElemPosition;
begin
  //writeln(GetNodeDepth);
  if TEntsManipulator.isUnneedSeparate(nul.count,GetNodeDepth)then
                                                                  begin
                                                                    updateenttreeadress;
                                                                    exit;
                                                                  end;
  MoveSub(self);
  TestNodesCount:=TEntsManipulator.GetTestNodesCount;
  TNArray:=[];
  setlength(TNArray,TestNodesCount{-1});

     PFirstStageData:=nil;
     TEntsManipulator.FirstStageCalcSeparatirs(BoundingBox,TEntity(nil^),PFirstStageData,TSMStart);
     if PFirstStageData<>nil then
     begin
       pobj:=nul.beginiterate(ir);
       if pobj<>nil then
       repeat
             pobj:=TEntsManipulator.IterateResult2PEntity(pobj);
             TEntsManipulator.FirstStageCalcSeparatirs(BoundingBox,pobj^,PFirstStageData,TSMAccumulation);

             pobj:=nul.iterate(ir);
       until pobj=nil;
     end;
     TEntsManipulator.FirstStageCalcSeparatirs(BoundingBox,TEntity(nil^),PFirstStageData,TSMCalc);

  for i:=0 to high(TNArray) do
    TNArray[i].initnul(nul.count);

  for i:=0 to high(TNArray) do
    TEntsManipulator.CreateSeparator(BoundingBox,TNArray[i],PFirstStageData,i);

  for i:=0 to high(TNArray) do
  begin
  pobj:=nul.beginiterate(ir);
  if pobj<>nil then
  repeat
     pobj:=TEntsManipulator.IterateResult2PEntity(pobj);
     ep:=TEntsManipulator.GetBBPosition(TNArray[i].plane,TEntsManipulator.GetEntityBoundingBox(pobj^));
     case ep of
       TEP_Plus://TNArray[i].plus.PushBackData(pobj);
                TEntsManipulator.StoreEntityToArray(pobj^,TNArray[i].plus);
      TEP_Minus://TNArray[i].minus.PushBackData(pobj);
                TEntsManipulator.StoreEntityToArray(pobj^,TNArray[i].minus);
        TEP_nul://TNArray[i].nul.PushBackData(pobj);
                TEntsManipulator.StoreEntityToArray(pobj^,TNArray[i].nul);
     end;
        pobj:=nul.iterate(ir);
  until pobj=nil;
  end;

  OptimalTestNode:=GetOptimalTestNode(TNArray);
  StoreOptimalTestNode(TNArray[OptimalTestNode]);
  updateenttreeadress;

  for i:=0 to high(TNArray) do
    TNArray[i].done;
end;
procedure GZBInarySeparatedGeometry<TBoundingBox,TSeparator,TNodeData,TEntsManipulator,TEntity,TEntityArrayIterateResult,TEntityArray>.AddObjectToNodeTree(var Entity:TEntity);
begin
    AddObjToNul(Entity);
    if (nul.count<>1)or(pplusnode<>nil)or(pminusnode<>nil) then
                        CorrectNodeBoundingBox(Entity)
                    else
                        BoundingBox:=TEntsManipulator.GetEntityBoundingBox(Entity);
end;
procedure GZBInarySeparatedGeometry<TBoundingBox,TSeparator,TNodeData,TEntsManipulator,TEntity,TEntityArrayIterateResult,TEntityArray>.CorrectNodeBoundingBox(var Entity:TEntity);
begin
     TEntsManipulator.CorrectNodeBoundingBox(BoundingBox,Entity);
end;
procedure GZBInarySeparatedGeometry<TBoundingBox,TSeparator,TNodeData,TEntsManipulator,TEntity,TEntityArrayIterateResult,TEntityArray>.updateenttreeadress;
var pobj:PTEntity;
    ir:itrec;
begin
     pobj:=nul.beginiterate(ir);
     if pobj<>nil then
     repeat
           pobj:=TEntsManipulator.IterateResult2PEntity(pobj);
           TEntsManipulator.StoreTreeAdressInOnject(pobj^,self,ir.itc);
           {pobj^.bp.TreePos.Owner:=@self;
           pobj^.bp.TreePos.SelfIndex:=ir.itc;}

           pobj:=nul.iterate(ir);
     until pobj=nil;
end;
procedure GZBInarySeparatedGeometry<TBoundingBox,TSeparator,TNodeData,TEntsManipulator,TEntity,TEntityArrayIterateResult,TEntityArray>.AddObjToNul(var Entity:TEntity);
var
   index:integer;
begin
     index:=TEntsManipulator.StoreEntityToArray(Entity,nul);
     //index:=nul.PushBackData(@Entity);
     TEntsManipulator.StoreTreeAdressInOnject(Entity,self,index);
     {Entity.bp.TreePos.Owner:=@self;
     Entity.bp.TreePos.SelfIndex:=index;}
end;
constructor GZBInarySeparatedGeometry<TBoundingBox,TSeparator,TNodeData,TEntsManipulator,TEntity,TEntityArrayIterateResult,TEntityArray>.initnul;
begin
     nul.init(50);
     NodeData:=default(TNodeData);
     LockCounter:=0;
     //NodeData.FulDraw:={True}TDTFulDraw;
end;
procedure GZBInarySeparatedGeometry<TBoundingBox,TSeparator,TNodeData,TEntsManipulator,TEntity,TEntityArrayIterateResult,TEntityArray>.Shrink;
begin
  nul.shrink;
  if assigned(pplusnode) then
                             pplusnode^.shrink;
  if assigned(pminusnode) then
                              pminusnode^.shrink;
end;
procedure GZBInarySeparatedGeometry<TBoundingBox,TSeparator,TNodeData,TEntsManipulator,TEntity,TEntityArrayIterateResult,TEntityArray>.ClearSub;
begin
     Separator:=default(TSeparator);
     BoundingBox:=default(TBoundingBox);
     //NodeDir:TNodeDir;
     Root:=nil;
     NodeData:=default(TNodeData);
     nul.Clear;
     if assigned(pplusnode) then
                                begin
                                     pplusnode^.done;
                                     Freemem(pointer(pplusnode));
                                     pplusnode:=nil;
                                end;
     if assigned(pminusnode) then
                                begin
                                     pminusnode^.done;
                                     Freemem(pointer(pminusnode));
                                     pminusnode:=nil;
                                end;
end;
procedure GZBInarySeparatedGeometry<TBoundingBox,TSeparator,TNodeData,TEntsManipulator,TEntity,TEntityArrayIterateResult,TEntityArray>.MoveSub(var node:GZBInarySeparatedGeometry<TBoundingBox,TSeparator,TNodeData,TEntsManipulator,TEntity,TEntityArrayIterateResult,TEntityArray>);
begin
     if @nul<>@node.nul then
     begin
       nul.copyto(node.nul);
       nul.Clear;
     end;
     if assigned(pplusnode) then
                                begin
                                     pplusnode^.MoveSub(node);
                                     pplusnode^.done;
                                     Freemem(pointer(pplusnode));
                                     pplusnode:=nil;
                                end;
     if assigned(pminusnode) then
                                begin
                                     pminusnode^.MoveSub(node);
                                     pminusnode^.done;
                                     Freemem(pointer(pminusnode));
                                     pminusnode:=nil;
                                end;
end;
destructor GZBInarySeparatedGeometry<TBoundingBox,TSeparator,TNodeData,TEntsManipulator,TEntity,TEntityArrayIterateResult,TEntityArray>.done;
begin
     ClearSub;
     nul.done;
end;
begin
end.
