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

unit gzctnrtree;
{$INCLUDE def.inc}
interface
uses
    UGDBVisibleOpenArray,uzbtypesbase,uzbtypes,uzbmemman;
type
TTreeLevelStatistik=record
                          NodesCount,EntCount,OverflowCount:GDBInteger;
                    end;
PTTreeLevelStatistikArray=^TTreeLevelStatistikArray;
TTreeLevelStatistikArray=Array [0..0] of  TTreeLevelStatistik;
TTreeStatistik=record
                     NodesCount,EntCount,OverflowCount,MaxDepth,MemCount:GDBInteger;
                     PLevelStat:PTTreeLevelStatistikArray;
               end;
{EXPORT+}
         TStageMode=(TSMStart,TSMAccumulation,TSMCalc,TSMEnd);
         TNodeDir=(TND_Plus,TND_Minus,TND_Root);
         TElemPosition=(TEP_Plus,TEP_Minus,TEP_nul);
         GZBInarySeparatedGeometry{-}<TBoundingBox,TSeparator,TNodeData,TEntsManipulator,TEntity>{//}
                                   ={$IFNDEF DELPHI}packed{$ENDIF} object(GDBaseObject)
         {-}type{//}
            {-}PGZBInarySeparatedGeometry=^GZBInarySeparatedGeometry<TBoundingBox,TSeparator,TNodeData,TEntsManipulator,TEntity>;{//}
            {-}TTestNode=Object(GDBaseObject){//}
                 {-}plane:TSeparator;{//}
                 {-}nul,plus,minus:GDBObjEntityOpenArray;{//}
                 {-}constructor initnul(InNodeCount:integer);{//}
                 {-}destructor done;virtual;{//}
           {-}end;{//}
         {-}var{//}
            Separator:TSeparator;
            BoundingBox:TBoundingBox;
            NodeDir:TNodeDir;
            Root:{-}PGZBInarySeparatedGeometry{/GDBPointer/};
            pplusnode,pminusnode:{-}PGZBInarySeparatedGeometry{/GDBPointer/};
            nul:GDBObjEntityOpenArray;
            NodeData:TNodeData;
            LockCounter:integer;
            destructor done;virtual;
            procedure ClearSub;
            constructor initnul;
            procedure AddObjToNul(var Entity:TEntity);
            procedure updateenttreeadress;
            procedure CorrectNodeBoundingBox(var Entity:TEntity);
            procedure AddObjectToNodeTree(var Entity:TEntity);
            procedure Lock;
            procedure UnLock;
            procedure Separate;virtual;
            function GetNodeDepth:integer;virtual;
            procedure MoveSub(var node:GZBInarySeparatedGeometry<TBoundingBox,TSeparator,TNodeData,TEntsManipulator,TEntity>);
            function GetOptimalTestNode(var TNArray:array of TTestNode):integer;
            procedure StoreOptimalTestNode(var TestNode:TTestNode);
          end;
{EXPORT-}
function MakeTreeStatisticRec(treedepth:integer):TTreeStatistik;
procedure KillTreeStatisticRec(var tr:TTreeStatistik);
implementation
constructor GZBInarySeparatedGeometry<TBoundingBox,TSeparator,TNodeData,TEntsManipulator,TEntity>.TTestNode.initnul;
begin
     nul.init({$IFDEF DEBUGBUILD}'TTestTreeNode.nul',{$ENDIF}InNodeCount{*2});
     plus.init({$IFDEF DEBUGBUILD}'TTestTreeNode.plus',{$ENDIF}InNodeCount{*2});
     minus.init({$IFDEF DEBUGBUILD}'TTestTreeNode.minus',{$ENDIF}InNodeCount{*2});
end;
destructor GZBInarySeparatedGeometry<TBoundingBox,TSeparator,TNodeData,TEntsManipulator,TEntity>.TTestNode.done;
begin
     nul.Clear;
     nul.Done;
     plus.Clear;
     plus.Done;
     minus.Clear;
     minus.Done;
end;

procedure GZBInarySeparatedGeometry<TBoundingBox,TSeparator,TNodeData,TEntsManipulator,TEntity>.Lock;
begin
  inc(LockCounter);
end;
procedure GZBInarySeparatedGeometry<TBoundingBox,TSeparator,TNodeData,TEntsManipulator,TEntity>.UnLock;
begin
  dec(LockCounter);
  if LockCounter=0 then
    separate;
end;
function GZBInarySeparatedGeometry<TBoundingBox,TSeparator,TNodeData,TEntsManipulator,TEntity>.GetNodeDepth:integer;
begin
  if Root=nil then
                  result:=0
              else
                  result:=1+Root^.GetNodeDepth;
end;
function GZBInarySeparatedGeometry<TBoundingBox,TSeparator,TNodeData,TEntsManipulator,TEntity>.GetOptimalTestNode(var TNArray:array of TTestNode):integer;
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
procedure GZBInarySeparatedGeometry<TBoundingBox,TSeparator,TNodeData,TEntsManipulator,TEntity>.StoreOptimalTestNode(var TestNode:TTestNode);
var
    pobj:^TEntity;
    ir:itrec;
begin
  nul.clear;
  TestNode.nul.copyto(nul);
  if TestNode.plus.count>0 then
  begin
    if pplusnode=nil then
      begin
        GDBGetMem({$IFDEF DEBUGBUILD}'TEntTreeNode',{$ENDIF}pointer(pplusnode),sizeof(GZBInarySeparatedGeometry<TBoundingBox,TSeparator,TNodeData,TEntsManipulator,TEntity>));
        pplusnode.initnul;
      end;
      pplusnode.lock;
      pplusnode.root:=@self;
       pobj:=TestNode.plus.beginiterate(ir);
       if pobj<>nil then
         repeat
           pplusnode.AddObjectToNodeTree(pobj^);
           pobj:=TestNode.plus.iterate(ir);
         until pobj=nil;
      pplusnode.unlock;
  end;
  if TestNode.minus.count>0 then
  begin
    if pminusnode=nil then
      begin
        GDBGetMem({$IFDEF DEBUGBUILD}'TEntTreeNode',{$ENDIF}pointer(pminusnode),sizeof(GZBInarySeparatedGeometry<TBoundingBox,TSeparator,TNodeData,TEntsManipulator,TEntity>));
        pminusnode.initnul;
      end;
      pminusnode.lock;
      pminusnode.root:=@self;
      pobj:=TestNode.minus.beginiterate(ir);
      if pobj<>nil then
        repeat
          pminusnode.AddObjectToNodeTree(pobj^);
          pobj:=TestNode.minus.iterate(ir);
        until pobj=nil;
      pminusnode.unlock;
  end;
end;
procedure GZBInarySeparatedGeometry<TBoundingBox,TSeparator,TNodeData,TEntsManipulator,TEntity>.Separate;
var
   TestNodesCount,OptimalTestNode:integer;
   TNArray:array of TTestNode;
   i:integer;
   PFirstStageData:pointer;
   pobj:^TEntity;
   ir:itrec;
   ep:TElemPosition;
begin
  //writeln(GetNodeDepth);
  if TEntsManipulator.isUnneedSeparate(nul.count,GetNodeDepth)then
                                                                  exit;
  MoveSub(self);
  TestNodesCount:=TEntsManipulator.GetTestNodesCount;
  setlength(TNArray,TestNodesCount-1);

     PFirstStageData:=nil;
     TEntsManipulator.FirstStageCalcSeparatirs(TEntity(nil^),PFirstStageData,TSMStart);
     pobj:=nul.beginiterate(ir);
     if pobj<>nil then
     repeat
           TEntsManipulator.FirstStageCalcSeparatirs(pobj^,PFirstStageData,TSMAccumulation);

           pobj:=nul.iterate(ir);
     until pobj=nil;
     TEntsManipulator.FirstStageCalcSeparatirs(TEntity(nil^),PFirstStageData,TSMCalc);

  for i:=0 to high(TNArray) do
    TNArray[i].initnul(nul.count);

  for i:=0 to high(TNArray) do
    TEntsManipulator.CreateSeparator(TNArray[i],PFirstStageData,i);

  for i:=0 to high(TNArray) do
  begin
  pobj:=nul.beginiterate(ir);
  if pobj<>nil then
  repeat
     ep:=TEntsManipulator.GetBBPosition(TNArray[i].plane,pobj^.vp.BoundingBox);
     case ep of
       TEP_Plus:TNArray[i].plus.PushBackData(pobj);
      TEP_Minus:TNArray[i].minus.PushBackData(pobj);
        TEP_nul:TNArray[i].nul.PushBackData(pobj);
     end;
        pobj:=nul.iterate(ir);
  until pobj=nil;
  end;

  OptimalTestNode:=GetOptimalTestNode(TNArray);
  StoreOptimalTestNode(TNArray[OptimalTestNode]);

  for i:=0 to high(TNArray) do
    TNArray[i].done;
end;
procedure GZBInarySeparatedGeometry<TBoundingBox,TSeparator,TNodeData,TEntsManipulator,TEntity>.AddObjectToNodeTree(var Entity:TEntity);
begin
    AddObjToNul(Entity);
    if nul.count<>1 then
                        CorrectNodeBoundingBox(Entity)
                    else
                        BoundingBox:=TEntsManipulator.GetEntityBoundingBox(Entity);
end;
procedure GZBInarySeparatedGeometry<TBoundingBox,TSeparator,TNodeData,TEntsManipulator,TEntity>.CorrectNodeBoundingBox(var Entity:TEntity);
begin
     TEntsManipulator.CorrectNodeBoundingBox(BoundingBox,Entity);
end;
procedure GZBInarySeparatedGeometry<TBoundingBox,TSeparator,TNodeData,TEntsManipulator,TEntity>.updateenttreeadress;
var pobj:^TEntity;
    ir:itrec;
begin
     pobj:=nul.beginiterate(ir);
     if pobj<>nil then
     repeat
           TEntsManipulator.StoreTreeAdressInOnject(pobj^,self,ir.itc);
           {pobj^.bp.TreePos.Owner:=@self;
           pobj^.bp.TreePos.SelfIndex:=ir.itc;}

           pobj:=nul.iterate(ir);
     until pobj=nil;
end;
procedure GZBInarySeparatedGeometry<TBoundingBox,TSeparator,TNodeData,TEntsManipulator,TEntity>.AddObjToNul(var Entity:TEntity);
var
   index:integer;
begin
     index:=nul.PushBackData(@Entity);
     TEntsManipulator.StoreTreeAdressInOnject(Entity,self,index);
     {Entity.bp.TreePos.Owner:=@self;
     Entity.bp.TreePos.SelfIndex:=index;}
end;
constructor GZBInarySeparatedGeometry<TBoundingBox,TSeparator,TNodeData,TEntsManipulator,TEntity>.initnul;
begin
     nul.init({$IFDEF DEBUGBUILD}'TEntTreeNode.nul',{$ENDIF}50);
     NodeData:=default(TNodeData);
     LockCounter:=0;
     //NodeData.FulDraw:={True}TDTFulDraw;
end;
procedure GZBInarySeparatedGeometry<TBoundingBox,TSeparator,TNodeData,TEntsManipulator,TEntity>.ClearSub;
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
                                     gdbfreemem(pointer(pplusnode));
                                end;
     if assigned(pminusnode) then
                                begin
                                     pminusnode^.done;
                                     gdbfreemem(pointer(pminusnode));
                                end;
end;
procedure GZBInarySeparatedGeometry<TBoundingBox,TSeparator,TNodeData,TEntsManipulator,TEntity>.MoveSub(var node:GZBInarySeparatedGeometry<TBoundingBox,TSeparator,TNodeData,TEntsManipulator,TEntity>);
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
                                     gdbfreemem(pointer(pplusnode));
                                end;
     if assigned(pminusnode) then
                                begin
                                     pminusnode^.MoveSub(node);
                                     pminusnode^.done;
                                     gdbfreemem(pointer(pminusnode));
                                end;
end;
destructor GZBInarySeparatedGeometry<TBoundingBox,TSeparator,TNodeData,TEntsManipulator,TEntity>.done;
begin
     ClearSub;
     nul.done;
end;
function MakeTreeStatisticRec(treedepth:integer):TTreeStatistik;
begin
     fillchar(result,sizeof(TTreeStatistik),0);
     gdbgetmem({$IFDEF DEBUGBUILD}'{7604D7A4-2788-49B5-BB45-F9CD42F9785B}',{$ENDIF}pointer(result.PLevelStat),(treedepth+1)*sizeof(TTreeLevelStatistik));
     fillchar(result.PLevelStat^,(treedepth+1)*sizeof(TTreeLevelStatistik),0);
end;
procedure KillTreeStatisticRec(var tr:TTreeStatistik);
begin
     gdbfreemem(pointer(tr.PLevelStat));
end;
begin
end.
