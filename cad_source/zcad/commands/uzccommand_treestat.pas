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
  sysutils,
  uzbtypes,
  uzeentitiestree,
  uzeentity,
  uzgldrawcontext,
  uzccommandsabstract,uzccommandsimpl,

  uzcinterface,
  uzcdrawings,
  uzcsysvars,
  gzctnrSTL;

function PointerToNodeName(node:pointer):string;

implementation

type
  TTreeLevelStatistik=record
                          NodesCount,EntCount,OverflowCount:Integer;
                    end;
  TPopulationCounter=TMyMapCounter<integer{,LessInteger}>;
  PTTreeLevelStatistikArray=^TTreeLevelStatistikArray;
  TTreeLevelStatistikArray=Array [0..0] of  TTreeLevelStatistik;
  TTreeStatistik=record
    NodesCount,EntCount,OverflowCount,MaxDepth,MemCount:Integer;
    PLevelStat:PTTreeLevelStatistikArray;
    pc:TPopulationCounter;
    constructor CreateRec(treedepth:integer);
    procedure FreeRec;
  end;

procedure GetTreeStat(pnode:PTEntTreeNode;depth:integer;var tr:TTreeStatistik);
begin
     inc(tr.NodesCount);
     inc(tr.EntCount,pnode^.nul.Count);
     inc(tr.MemCount,sizeof(pnode^));
     tr.pc.CountKey(pnode^.nul.Count,1);
     if depth>tr.MaxDepth then
                              tr.MaxDepth:=depth;
     if pnode^.nul.Count>GetInNodeCount(SysVar.RD.RD_SpatialNodeCount^) then
                                                                            begin
                                                                                 inc(tr.OverflowCount);
                                                                                 inc(tr.PLevelStat^[depth].OverflowCount);
                                                                            end;
     inc(tr.PLevelStat^[depth].NodesCount);
     inc(tr.PLevelStat^[depth].EntCount,pnode^.nul.Count);

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
  pc:=TPopulationCounter.create;
end;

procedure TTreeStatistik.FreeRec;
begin
     Freemem(PLevelStat);
     pc.destroy;
end;

function PointerToNodeName(node:pointer):string;
begin
  result:=format(' _%s',[inttohex(ptruint(node),8)])
end;

procedure WriteNode(node:PTEntTreeNode;infrustum:TActulity;nodedepth:integer);
var
   nodename:string;
begin
  nodename:=PointerToNodeName(node);
  ZCMsgCallBackInterface.TextMessage(format(' %s [label="None with %d ents"]',[nodename,node.nul.count]),TMWOHistoryOut);
  if node^.NodeData.infrustum=infrustum then
    ZCMsgCallBackInterface.TextMessage(format(' %s [fillcolor=red, style=filled]',[nodename,node.nul.count]),TMWOHistoryOut);
  ZCMsgCallBackInterface.TextMessage(format('rank=same; level_%d;',[nodedepth]),TMWOHistoryOut);
  //{ rank = same; "past"
  if assigned(node.pplusnode)then
  begin
    ZCMsgCallBackInterface.TextMessage(format(' %s->%s [label="+"]',[nodename,PointerToNodeName(PTEntTreeNode(node.pplusnode))]),TMWOHistoryOut);
    WriteNode(PTEntTreeNode(node.pplusnode),infrustum,nodedepth+1);
  end;
  if assigned(node.pminusnode)then
  begin
    ZCMsgCallBackInterface.TextMessage(format(' %s->%s [label="-"]',[nodename,PointerToNodeName(PTEntTreeNode(node.pminusnode))]),TMWOHistoryOut);
    WriteNode(PTEntTreeNode(node.pminusnode),infrustum,nodedepth+1);
  end;
end;

procedure WriteDot(node:PTEntTreeNode; var tr:TTreeStatistik);
var
  i:integer;
  DC:TDrawContext;
begin
  ZCMsgCallBackInterface.TextMessage('DiGraph Classes {',TMWOHistoryOut);
  for i:=0 to tr.MaxDepth do
   if i<>tr.MaxDepth then
     ZCMsgCallBackInterface.TextMessage('level_'+inttostr(i)+'->',TMWOHistoryOut)
   else
     ZCMsgCallBackInterface.TextMessage('level_'+inttostr(i),TMWOHistoryOut);
  dc:=drawings.GetCurrentDWG.CreateDrawingRC;
  WriteNode(node,dc.DrawingContext.InfrustumActualy,0);
  ZCMsgCallBackInterface.TextMessage('}',TMWOHistoryOut);
end;

function TreeStat_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var i: Integer;
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
  else
    rootnode:=@PGDBObjEntity(drawings.GetCurrentDWG.wa.param.seldesc.LastSelectedObject)^.Representation.Geometry;
  GetTreeStat(rootnode,depth,tr);
  ZCMsgCallBackInterface.TextMessage('Total entities in drawing: '+inttostr(drawings.GetCurrentROOT.ObjArray.count),TMWOHistoryOut);
  ZCMsgCallBackInterface.TextMessage('Max tree depth: '+inttostr(SysVar.RD.RD_SpatialNodesDepth^),TMWOHistoryOut);
  ZCMsgCallBackInterface.TextMessage('Max in node entities: '+inttostr(GetInNodeCount(SysVar.RD.RD_SpatialNodeCount^)),TMWOHistoryOut);
  ZCMsgCallBackInterface.TextMessage('Current drawing spatial index Info:',TMWOHistoryOut);
  ZCMsgCallBackInterface.TextMessage('Total entities: '+inttostr(tr.EntCount),TMWOHistoryOut);
  ZCMsgCallBackInterface.TextMessage('Memory usage (bytes): '+inttostr(tr.MemCount),TMWOHistoryOut);
  ZCMsgCallBackInterface.TextMessage('Total nodes: '+inttostr(tr.NodesCount),TMWOHistoryOut);
  ZCMsgCallBackInterface.TextMessage('Total overflow nodes: '+inttostr(tr.OverflowCount),TMWOHistoryOut);
  ZCMsgCallBackInterface.TextMessage('Fact tree depth: '+inttostr(tr.MaxDepth),TMWOHistoryOut);
  ZCMsgCallBackInterface.TextMessage('By levels:',TMWOHistoryOut);
  ap:=0;
  for i:=0 to tr.MaxDepth do
  begin
       ZCMsgCallBackInterface.TextMessage('level '+inttostr(i),TMWOHistoryOut);
       ZCMsgCallBackInterface.TextMessage('  Entities: '+inttostr(tr.PLevelStat^[i].EntCount),TMWOHistoryOut);
       if tr.EntCount<>0 then
                             cp:=tr.PLevelStat^[i].EntCount/tr.EntCount*100
                         else
                             cp:=0;
       ap:=ap+cp;
       str(cp:2:2,percent);
       str(ap:2:2,apercent);
       ZCMsgCallBackInterface.TextMessage('  Entities(%)[summary]: '+percent+'['+apercent+']',TMWOHistoryOut);
       ZCMsgCallBackInterface.TextMessage('  Nodes: '+inttostr(tr.PLevelStat^[i].NodesCount),TMWOHistoryOut);
       ZCMsgCallBackInterface.TextMessage('  Overflow nodes: '+inttostr(tr.PLevelStat^[i].OverflowCount),TMWOHistoryOut);
  end;
  for pair in tr.pc do begin
    //iter:=tr.pc.min;
    //if assigned(iter)then
    //repeat
      ZCMsgCallBackInterface.TextMessage('  Nodes with population '+inttostr(pair.Key)+': '+inttostr(pair.Value),TMWOHistoryOut);
    //until not iter.next;
    //if assigned(iter)then iter.destroy;
  end;
  WriteDot(rootnode,tr);
  tr.FreeRec;
  result:=cmd_ok;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@TreeStat_com,'TreeStat',CADWG,0);
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
