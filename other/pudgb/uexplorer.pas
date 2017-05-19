unit uexplorer;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,Forms,
  uprojectoptions,uscanresult,PasTree,Generics.Collections;
type
  TNodeName=string;
  TNodeData=record
    Name:TNodeName;
    Text:String;
  end;
  TPasElementHandler=procedure(const pe:TPasElement; var PrevNode,Node:TNodeData;var NNSeed:integer;Options:TProjectOptions;const LogWriter:TLogWriter;var NeedConnectToPrev:boolean);
  TPasElementPasHandlers=specialize TDictionary<pointer,TPasElementHandler>;
var
  PasElementPasHandlers:TPasElementPasHandlers;
procedure ExploreCode(Options:TProjectOptions;ScanResult:TScanResult;const LogWriter:TLogWriter);
procedure DefaultProcessPasImpl(const pe:TPasElement; var Node:TNodeData);
implementation
function GetNodeName(var NodeSeed:integer):TNodeName;
begin
  result:=format('Node_%d',[NodeSeed]);
  inc(NodeSeed);
end;
function ExplorePasImplBlock(PrevNode:TNodeData;PasImplBlock:TPasImplBlock;var NNSeed:integer;Options:TProjectOptions;const LogWriter:TLogWriter;NeedConnectToPrev:boolean):TNodeData;
var
  i:integer;
  pe:TPasElement;
  CurrentNode:TNodeData;
  handler:TPasElementHandler;
begin
     if assigned(PasImplBlock)then
     begin
       for i:=0 to PasImplBlock.Elements.Count-1 do
       begin
        pe:=TPasElement(PasImplBlock.Elements[i]);
        CurrentNode.Name:=GetNodeName(NNSeed);
        NeedConnectToPrev:=true;
        if PasElementPasHandlers.TryGetValue(typeof(pe),handler) then
          handler(pe,PrevNode,CurrentNode,NNSeed,Options,LogWriter,NeedConnectToPrev)
        else
          DefaultProcessPasImpl(pe,CurrentNode);
        LogWriter(format(' %s [shape=box] [label="%s"]',[CurrentNode.Name,CurrentNode.Text]),[LD_Explorer]);
        if NeedConnectToPrev then LogWriter(format(' %s -> %s',[PrevNode.Name,CurrentNode.Name]),[LD_Explorer]);
        PrevNode:=CurrentNode;
       end;
     end;
     result:=CurrentNode;
end;
function ExplorePasImplElement(PrevNode:TNodeData;PasImplElement:TPasImplElement;var NNSeed:integer;Options:TProjectOptions;const LogWriter:TLogWriter;NeedConnectToPrev:boolean):TNodeData;
var
  i:integer;
  pe:TPasElement;
  CurrentNode:TNodeData;
  handler:TPasElementHandler;
begin
     if assigned(PasImplElement)then
     begin
       if typeof(PasImplElement)=pointer(TPasImplBlock) then
         CurrentNode:=ExplorePasImplBlock(PrevNode,TPasImplBlock(PasImplElement),NNSeed,Options,LogWriter,NeedConnectToPrev)
       else
       begin
        CurrentNode.Name:=GetNodeName(NNSeed);
        if PasElementPasHandlers.TryGetValue(typeof(PasImplElement),handler) then
          handler(PasImplElement,PrevNode,CurrentNode,NNSeed,Options,LogWriter,NeedConnectToPrev)
        else
          DefaultProcessPasImpl(PasImplElement,CurrentNode);
        LogWriter(format(' %s [shape=box] [label="%s"]',[CurrentNode.Name,CurrentNode.Text]),[LD_Explorer]);
        if NeedConnectToPrev then LogWriter(format(' %s -> %s',[PrevNode.Name,CurrentNode.Name]),[LD_Explorer]);
        PrevNode:=CurrentNode;
       end;
     end;
     result:=CurrentNode;
end;
procedure ExploreUnit(var UnitInfo:TUnitInfo;Options:TProjectOptions;ScanResult:TScanResult;const LogWriter:TLogWriter);
var
  NNSeed:integer;
  CurrentNode,PrevNode:TNodeData;
  NeedConnectToPrev:boolean;
begin
     NNSeed:=0;
     LogWriter('DiGraph Classes {',[LD_Explorer]);
     CurrentNode.Name:='Start';
     CurrentNode.Text:='Start';
     NeedConnectToPrev:=true;
     LogWriter(format(' %s [shape=box] [label="%s"]',[CurrentNode.Name,CurrentNode.Text]),[LD_Explorer]);
     PrevNode:=ExplorePasImplBlock(CurrentNode,UnitInfo.PasModule.InitializationSection,NNSeed,Options,LogWriter,NeedConnectToPrev);
     CurrentNode.Name:='End';
     CurrentNode.Text:='End';
     LogWriter(format(' %s [shape=box] [label="%s"]',[CurrentNode.Name,CurrentNode.Text]),[LD_Explorer]);
     LogWriter(format(' %s -> %s',[PrevNode.Name,CurrentNode.Name]),[LD_Explorer]);
     LogWriter('}',[LD_Explorer]);
end;
procedure ExploreCode(Options:TProjectOptions;ScanResult:TScanResult;const LogWriter:TLogWriter);
begin
  Application.MessageBox('Not yet implemented!','Error!');
  if assigned(ScanResult) then
  if ScanResult.UnitInfoArray.Size>0 then
    ExploreUnit(ScanResult.UnitInfoArray.mutable[0]^,Options,ScanResult,LogWriter);
end;
procedure DefaultProcessPasImpl(const pe:TPasElement; var Node:TNodeData);
begin
  Node.Text:=format('Not implement for ''%s''',[pe.ClassName]);
end;
procedure ProcessPasImplAssign(const pe:TPasImplAssign; var PrevNode,Node:TNodeData;var NNSeed:integer;Options:TProjectOptions;const LogWriter:TLogWriter;var NeedConnectToPrev:boolean);
begin
  Node.Text:=format('%s:=%s',[pe.left.GetDeclaration(true),pe.right.GetDeclaration(true)]);
end;
procedure ProcessPasImplSimple(const pe:TPasImplSimple; var PrevNode,Node:TNodeData;var NNSeed:integer;Options:TProjectOptions;const LogWriter:TLogWriter;var NeedConnectToPrev:boolean);
begin
  if pe.expr is tparamsexpr then
    Node.Text:=tparamsexpr(pe.expr).Value.GetDeclaration(true)+pe.expr.GetDeclaration(true)
  else
    Node.Text:=pe.expr.GetDeclaration(true);
end;
procedure ProcessPasImplForLoop(const pe:TPasImplForLoop; var PrevNode,Node:TNodeData;var NNSeed:integer;Options:TProjectOptions;const LogWriter:TLogWriter;var NeedConnectToPrev:boolean);
var
  startnodename:string;
  fakeNeedConnectToPrev:boolean;
begin
  startnodename:=Node.name;
  case pe.LoopType of
  ltNormal:Node.Text:=format('For %s:=%s to %s do',[pe.VariableName.GetDeclaration(true),pe.StartExpr.GetDeclaration(true),pe.EndExpr.GetDeclaration(true)]);
  ltDown:Node.Text:=format('For %s:=%s to %s downto',[pe.VariableName.GetDeclaration(true),pe.StartExpr.GetDeclaration(true),pe.EndExpr.GetDeclaration(true)]);
  ltIn:Node.Text:=format('For %s:=%s to %s downto',[pe.Variable.GetDeclaration(true),pe.StartExpr.GetDeclaration(true),pe.EndExpr.GetDeclaration(true)]);
  end;

  LogWriter(format(' %s [shape="house"] [label="%s"]',[Node.Name,Node.Text]),[LD_Explorer]);
  LogWriter(format(' %s -> %s',[PrevNode.Name,Node.Name]),[LD_Explorer]);

  fakeNeedConnectToPrev:=false;
  PrevNode:=ExplorePasImplElement(Node,pe.Body,NNSeed,Options,LogWriter,fakeNeedConnectToPrev);

  Node.Text:='End ForLoop';
  Node.Name:=GetNodeName(NNSeed);

  LogWriter(format(' %s [shape="invhouse" label="%s"]',[Node.Name,Node.Text]),[LD_Explorer]);
  LogWriter(format(' %s -> %s',[PrevNode.Name,Node.Name]),[LD_Explorer]);
  LogWriter(format(' %s -> %s',[Node.Name,startnodename]),[LD_Explorer]);

  NeedConnectToPrev:=false;
end;
procedure ProcessPasImplIfElse(const pe:TPasImplIfElse; var PrevNode,Node:TNodeData;var NNSeed:integer;Options:TProjectOptions;const LogWriter:TLogWriter;var NeedConnectToPrev:boolean);
var
  fakeNeedConnectToPrev:boolean;
begin
  fakeNeedConnectToPrev:=false;
  Node.Text:=format('if %s',[pe.ConditionExpr.GetDeclaration(true)]);
  LogWriter(format(' %s [shape="diamond" label="%s"]',[Node.Name,Node.Text]),[LD_Explorer]);
  if NeedConnectToPrev then LogWriter(format(' %s -> %s',[PrevNode.Name,Node.Name]),[LD_Explorer]);
  Node:=ExplorePasImplElement(Node,pe.IfBranch,NNSeed,Options,LogWriter,{NeedConnectToPrev}fakeNeedConnectToPrev);
  if assigned(pe.ElseBranch) then PrevNode:=ExplorePasImplElement(Node,pe.IfBranch,NNSeed,Options,LogWriter,NeedConnectToPrev);
  NeedConnectToPrev:=false;
end;
initialization
  PasElementPasHandlers:=TPasElementPasHandlers.create;
  PasElementPasHandlers.add(TPasImplAssign,TPasElementHandler(@ProcessPasImplAssign));
  PasElementPasHandlers.add(TPasImplSimple,TPasElementHandler(@ProcessPasImplSimple));
  PasElementPasHandlers.add(TPasImplForLoop,TPasElementHandler(@ProcessPasImplForLoop));
  PasElementPasHandlers.add(TPasImplIfElse,TPasElementHandler(@ProcessPasImplIfElse));
finalization;
  PasElementPasHandlers.destroy;
end.

