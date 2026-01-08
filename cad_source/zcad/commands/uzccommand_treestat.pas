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
{$mode delphi}
{$modeswitch advancedrecords}
unit uzccommand_treestat;

{$INCLUDE zengineconfig.inc}

interface

uses
  uzcLog,
  SysUtils,
  uzbBaseUtils,uzeTypes,
  uzeentitiestree,
  uzeentity,
  uzgldrawcontext,
  uzccommandsabstract,uzccommandsimpl,
  uzcinterface,
  uzcdrawings,
  uzcsysvars,
  gzctnrSTL,
  uzeentgenericsubentry,
  uzeentcomplex;

function PointerToNodeName(node:pointer):string;

implementation

type
  TTreeLevelStatistik=record
    NodesCount,EntCount,OverflowCount:integer;
  end;
  TPopulationCounter=TMyMapCounter<integer{,LessInteger}>;
  PTTreeLevelStatistikArray=^TTreeLevelStatistikArray;
  TTreeLevelStatistikArray=array [0..0] of TTreeLevelStatistik;

  TTreeStatistik=record
    NodesCount,EntCount,OverflowCount,MaxDepth,MemCount:integer;
    PLevelStat:PTTreeLevelStatistikArray;
    pc:TPopulationCounter;
    constructor CreateRec(treedepth:integer);
    procedure FreeRec;
  end;

procedure GetTreeStat(pnode:PTEntTreeNode;depth:integer;var tr:TTreeStatistik);
begin
  Inc(tr.NodesCount);
  Inc(tr.EntCount,pnode^.nul.Count);
  Inc(tr.MemCount,sizeof(pnode^));
  tr.pc.CountKey(pnode^.nul.Count,1);
  if depth>tr.MaxDepth then
    tr.MaxDepth:=depth;
  if pnode^.nul.Count>GetInNodeCount(SysVar.RD.RD_SpatialNodeCount^) then begin
    Inc(
      tr.OverflowCount);
    Inc(
      tr.PLevelStat^[depth].OverflowCount);
  end;
  Inc(tr.PLevelStat^[depth].NodesCount);
  Inc(tr.PLevelStat^[depth].EntCount,pnode^.nul.Count);

  if assigned(pnode.pplusnode) then
    GetTreeStat(PTEntTreeNode(pnode.pplusnode),depth+1,tr);
  if assigned(pnode.pminusnode) then
    GetTreeStat(PTEntTreeNode(pnode.pminusnode),depth+1,tr);
end;

constructor TTreeStatistik.CreateRec(treedepth:integer);
begin
  NodesCount:=0;
  EntCount:=0;
  OverflowCount:=0;
  MaxDepth:=0;
  MemCount:=0;
  Getmem(PLevelStat,(treedepth+1)*sizeof(TTreeLevelStatistik));
  fillchar(PLevelStat^,(treedepth+1)*sizeof(TTreeLevelStatistik),0);
  pc:=TPopulationCounter.Create;
end;

procedure TTreeStatistik.FreeRec;
begin
  Freemem(PLevelStat);
  pc.Destroy;
end;

function PointerToNodeName(node:pointer):string;
begin
  Result:=format(' _%s',[inttohex(ptruint(node),8)]);
end;

procedure WriteNode(node:PTEntTreeNode;infrustum:TActuality;nodedepth:integer);
var
  nodename:string;
begin
  nodename:=PointerToNodeName(node);
  zcUI.TextMessage(format(' %s [label="None with %d ents, %fx%fx%f"]',
    [nodename,node.nul.Count,node.BoundingBox.RTF.x-node.BoundingBox.LBN.x,
    node.BoundingBox.RTF.y-node.BoundingBox.LBN.y,node.BoundingBox.RTF.z-
    node.BoundingBox.LBN.z]),TMWOHistoryOut);
  if node^.NodeData.infrustum=infrustum then
    zcUI.TextMessage(format(' %s [fillcolor=red, style=filled]',
      [nodename,node.nul.Count]),TMWOHistoryOut);
  zcUI.TextMessage(format('rank=same; level_%d;',[nodedepth]),TMWOHistoryOut);
  //{ rank = same; "past"
  if assigned(node.pplusnode) then begin
    zcUI.TextMessage(format(' %s->%s [label="+"]',
      [nodename,PointerToNodeName(PTEntTreeNode(node.pplusnode))]),TMWOHistoryOut);
    WriteNode(PTEntTreeNode(node.pplusnode),infrustum,nodedepth+1);
  end;
  if assigned(node.pminusnode) then begin
    zcUI.TextMessage(format(' %s->%s [label="-"]',
      [nodename,PointerToNodeName(PTEntTreeNode(node.pminusnode))]),TMWOHistoryOut);
    WriteNode(PTEntTreeNode(node.pminusnode),infrustum,nodedepth+1);
  end;
end;

procedure WriteDot(node:PTEntTreeNode;var tr:TTreeStatistik);
var
  i:integer;
  DC:TDrawContext;
begin
  zcUI.TextMessage('DiGraph Classes {',TMWOHistoryOut);
  for i:=0 to tr.MaxDepth do
    if i<>tr.MaxDepth then
      zcUI.TextMessage('level_'+IntToStr(i)+'->',TMWOHistoryOut)
    else
      zcUI.TextMessage('level_'+IntToStr(i),TMWOHistoryOut);
  dc:=drawings.GetCurrentDWG.CreateDrawingRC;
  WriteNode(node,dc.DrawingContext.VActuality.InfrustumActualy,0);
  zcUI.TextMessage('}',TMWOHistoryOut);
end;

function TreeStat_com(const Context:TZCADCommandContext;
  operands:TCommandOperands):TCommandResult;
var
  i:integer;
  percent,apercent:string;
  cp,ap:single;
  depth:integer;
  tr:TTreeStatistik;
  rootnode:PTEntTreeNode;
  pair:TPopulationCounter.TDictionaryPair;
  //iter:TPopulationCounter.TIterator;
begin
  depth:=0;
  tr:=TTreeStatistik.CreateRec({SysVar.RD.RD_SpatialNodesDepth^}64);
  if drawings.GetCurrentDWG.wa.param.seldesc.LastSelectedObject=nil then
    rootnode:=@drawings.GetCurrentDWG^.pObjRoot.ObjArray.ObjTree
  else begin
    if IsObjectIt(typeof(PGDBObjEntity(
      drawings.GetCurrentDWG.wa.param.seldesc.LastSelectedObject)^),typeof(
      GDBObjGenericSubEntry)) then
      rootnode:=@PGDBObjGenericSubEntry(
        drawings.GetCurrentDWG.wa.param.seldesc.LastSelectedObject)^.ObjArray.ObjTree
    else if IsObjectIt(typeof(PGDBObjEntity(
      drawings.GetCurrentDWG.wa.param.seldesc.LastSelectedObject)^),typeof(GDBObjComplex)) then
      rootnode:=@PGDBObjComplex(
        drawings.GetCurrentDWG.wa.param.seldesc.LastSelectedObject)^.ConstObjArray.ObjTree
    else
      rootnode:=nil;
    //@PGDBObjEntity(drawings.GetCurrentDWG.wa.param.seldesc.LastSelectedObject)^.Representation.Geometry;
  end;
  if rootnode<>nil then begin
    GetTreeStat(rootnode,depth,tr);
    zcUI.TextMessage('Total entities in drawing: '+IntToStr(
      drawings.GetCurrentROOT.ObjArray.Count),TMWOHistoryOut);
    zcUI.TextMessage('Max tree depth: '+IntToStr(SysVar.RD.RD_SpatialNodesDepth^),
      TMWOHistoryOut);
    zcUI.TextMessage('Max in node entities: '+IntToStr(
      GetInNodeCount(SysVar.RD.RD_SpatialNodeCount^)),TMWOHistoryOut);
    zcUI.TextMessage('Current drawing spatial index Info:',TMWOHistoryOut);
    zcUI.TextMessage('Total entities: '+IntToStr(tr.EntCount),TMWOHistoryOut);
    zcUI.TextMessage('Memory usage (bytes): '+IntToStr(tr.MemCount),TMWOHistoryOut);
    zcUI.TextMessage('Total nodes: '+IntToStr(tr.NodesCount),TMWOHistoryOut);
    zcUI.TextMessage('Total overflow nodes: '+IntToStr(tr.OverflowCount),TMWOHistoryOut);
    zcUI.TextMessage('Fact tree depth: '+IntToStr(tr.MaxDepth),TMWOHistoryOut);
    zcUI.TextMessage('By levels:',TMWOHistoryOut);
    ap:=0;
    for i:=0 to tr.MaxDepth do begin
      zcUI.TextMessage('level '+IntToStr(i),TMWOHistoryOut);
      zcUI.TextMessage('  Entities: '+IntToStr(tr.PLevelStat^[i].EntCount),
        TMWOHistoryOut);
      if tr.EntCount<>0 then
        cp:=tr.PLevelStat^[i].EntCount/tr.EntCount*100
      else
        cp:=0;
      ap:=ap+cp;
      str(cp:2:2,percent);
      str(ap:2:2,apercent);
      zcUI.TextMessage('  Entities(%)[summary]: '+percent+'['+
        apercent+']',TMWOHistoryOut);
      zcUI.TextMessage('  Nodes: '+IntToStr(tr.PLevelStat^[i].NodesCount),
        TMWOHistoryOut);
      zcUI.TextMessage('  Overflow nodes: '+IntToStr(
        tr.PLevelStat^[i].OverflowCount),TMWOHistoryOut);
    end;
    for pair in tr.pc do begin
      //iter:=tr.pc.min;
      //if assigned(iter)then
      //repeat
      zcUI.TextMessage('  Nodes with population '+IntToStr(pair.Key)+
        ': '+IntToStr(pair.Value),TMWOHistoryOut);
      //until not iter.next;
      //if assigned(iter)then iter.destroy;
    end;
    WriteDot(rootnode,tr);
    tr.FreeRec;
  end else
    zcUI.TextMessage('Сan''t find tree in selected entity',TMWOMessageBox);
  Result:=cmd_ok;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@TreeStat_com,'TreeStat',CADWG,0);

finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsFinalizeLMId);
end.
