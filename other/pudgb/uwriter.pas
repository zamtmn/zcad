unit uwriter;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms,
  Graphs,MultiLst,Pointerv,
  uoptions,uscanresult,generics.Collections,gvector,masks;

type
  TDecoratedUnitNameMode=(TDUNM_AddUsesCount);
  TDecoratedUnitNameModeSet=set of TDecoratedUnitNameMode;


  TClusterInfo=specialize TVector<string>;
  TNodeIndexes=specialize TVector<integer>;
  TClusters=specialize TDictionary<string,TClusterInfo>;
  TClusterInfoPair=specialize TPair<string,TClusterInfo>;

  TIncludeToGraph=(ITG_Include,ITG_Exclude);

procedure WriteGraph(Options:TOptions;ScanResult:TScanResult;const LogWriter:TLogWriter);
procedure ProcessNode(_SourceUnitIndex,_DestUnitIndex:TNodeIndexes;Options:TOptions;ScanResult:TScanResult;var Node:TUnitInfo;const index:integer;const LogWriter:TLogWriter;const LogOpt:TLogOpt;ForceInclude:boolean=false);
function IncludeToGraph(_SourceUnitIndex,_DestUnitIndex:TNodeIndexes;const Options:TOptions;const ScanResult:TScanResult;var Node:TUnitInfo;const index:integer;const LogWriter:TLogWriter):boolean;
function getDecoratedUnnitname(const UI:TUnitInfo;DecoratedUnitNameMode:TDecoratedUnitNameModeSet=[TDUNM_AddUsesCount]):string;

implementation
function getDecoratedUnnitname(const UI:TUnitInfo;DecoratedUnitNameMode:TDecoratedUnitNameModeSet=[TDUNM_AddUsesCount]):string;
begin
  //result:=UI.UnitName;
  result:=format('%s_%d_%d',[UI.UnitName,UI.InterfaceUses.Size,UI.ImplementationUses.Size]);
  result:=StringReplace(result,'.','_',[rfReplaceAll]);
end;

function CheckIncludeOptions(const Options:TOptions;const UnitName:string):TIncludeToGraph;
begin
  if Options.GraphBulding.FullG.IncludeToGraph<>'' then
    if not MatchesMaskList(UnitName,Options.GraphBulding.FullG.IncludeToGraph) then
      begin
        result:=ITG_Exclude;
        exit;
      end;
  if Options.GraphBulding.FullG.ExcludeFromGraph<>'' then
    if MatchesMaskList(UnitName,Options.GraphBulding.FullG.ExcludeFromGraph) then
      begin
        result:=ITG_Exclude;
        exit;
      end;
  result:=ITG_Include;
end;

function IncludeToGraph(_SourceUnitIndex,_DestUnitIndex:TNodeIndexes;const Options:TOptions;const ScanResult:TScanResult;var Node:TUnitInfo;const index:integer;const LogWriter:TLogWriter):boolean;
var
  i,j:integer;
  connected:boolean;
begin
  result:=false;
  if not Options.GraphBulding.FullG.IncludeNotFoundedUnits then
    if (node.UnitPath='')and(index<>0) then exit;
  if CheckIncludeOptions(Options,Node.UnitName)=ITG_Exclude then exit;
  if Options.GraphBulding.FullG.IncludeOnlyLoops and not(UFLoop in node.UnitFlags) then exit;
  if node.UnitName='uzestrconsts' then
                                      Node:=Node;
  connected:=true;
  if assigned(_SourceUnitIndex) then
  if _SourceUnitIndex.Size>0 then
  begin
    connected:=false;
    for i:=0 to _SourceUnitIndex.Size-1 do
    begin
     j:=ScanResult.G.FindMinPathDirected(ScanResult.G.Vertices[index],ScanResult.G.Vertices[_SourceUnitIndex[i]],nil);
     if ScanResult.G.FindMinPathDirected(ScanResult.G.Vertices[index],ScanResult.G.Vertices[_SourceUnitIndex[i]],nil)>=0 then
     begin
      connected:=true;
      break;
     end;
    end;
    if not connected then exit;
  end;
  if assigned(_DestUnitIndex) then
  if _DestUnitIndex.Size>0 then
  begin
    connected:=false;
    for i:=0 to _DestUnitIndex.Size-1 do
    begin
     j:=ScanResult.G.FindMinPathDirected(ScanResult.G.Vertices[_DestUnitIndex[i]],ScanResult.G.Vertices[index],nil);
     if ScanResult.G.FindMinPathDirected(ScanResult.G.Vertices[_DestUnitIndex[i]],ScanResult.G.Vertices[index],nil)>=0 then
     begin
      connected:=true;
      break;
     end;
    end;
  end;
  if connected then
    result:=true;
end;

procedure ProcessNode(_SourceUnitIndex,_DestUnitIndex:TNodeIndexes;Options:TOptions;ScanResult:TScanResult;var Node:TUnitInfo;const index:integer;const LogWriter:TLogWriter;const LogOpt:TLogOpt;ForceInclude:boolean=false);
begin
  if node.NodeState=NSNotCheced then
  begin
    if ForceInclude or IncludeToGraph(_SourceUnitIndex,_DestUnitIndex,Options,ScanResult,Node,index,LogWriter)then
    begin
        if Node.UnitType=UTProgram then
          LogWriter(format(' %s [shape=box]',[getDecoratedUnnitname(Node)]),LogOpt);
        if (Node.UnitPath='')and(index<>0) then
          LogWriter(format(' %s [style=dashed]',[getDecoratedUnnitname(Node)]),LogOpt);
        node.NodeState:=NSCheced;
    end
    else
        node.NodeState:=NSFiltredOut;
  end;
end;
function PathToSubGraphName(s:string):string;
begin
  result:=StringReplace(s,'.','_',[rfReplaceAll]);
  result:=StringReplace(result,'/','_',[rfReplaceAll]);
  result:=StringReplace(result,'\','_',[rfReplaceAll]);
end;

procedure WriteGraph(Options:TOptions;ScanResult:TScanResult;const LogWriter:TLogWriter);
var
  i,j,paths:integer;
  s:string;
  te:TEdge;
  v1,v2:TVertex;
  EdgePaths:TMultiList=nil;
  Clusters:TClusters;
  ClusterInfo:TClusterInfo;
  ClusterInfoPair:TClusterInfoPair;
  SourceUnitIndexs,DestUnitIndexs:TNodeIndexes;
begin
  SourceUnitIndexs:=nil;
  DestUnitIndexs:=nil;

  if Options.GraphBulding.FullG.SourceUnit<>'' then
  begin
    SourceUnitIndexs:=TNodeIndexes.create;
    for i:=0 to ScanResult.UnitInfoArray.Size-1 do
      if CheckIncludeOptions(Options,ScanResult.UnitInfoArray.mutable[i]^.UnitName)=ITG_Include then
         if MatchesMaskList(ScanResult.UnitInfoArray.mutable[i]^.UnitName,Options.GraphBulding.FullG.SourceUnit) then
           SourceUnitIndexs.PushBack(i);

    if SourceUnitIndexs.size<=0 then
      Application.MessageBox('Source unit not found in graph','Error!');
  end;

  if Options.GraphBulding.FullG.DestUnit<>'' then
  begin
    DestUnitIndexs:=TNodeIndexes.create;
    for i:=0 to ScanResult.UnitInfoArray.Size-1 do
      if CheckIncludeOptions(Options,ScanResult.UnitInfoArray.mutable[i]^.UnitName)=ITG_Include then
         if MatchesMaskList(ScanResult.UnitInfoArray.mutable[i]^.UnitName,Options.GraphBulding.FullG.DestUnit) then
           DestUnitIndexs.PushBack(i);

    if DestUnitIndexs.size<=0 then
      Application.MessageBox('Destination unit not found in graph','Error!');
  end;

  if assigned(LogWriter) then
  begin
    LogWriter('DiGraph Classes {',[LD_FullGraph]);
    if assigned(ScanResult) then
    begin
      for i:=0 to ScanResult.UnitInfoArray.Size-1 do
       ScanResult.UnitInfoArray.mutable[i]^.NodeState:=NSNotCheced;
    paths:=-1;
    if Options.GraphBulding.FullG.IncludeInterfaceUses then
    for i:=0 to ScanResult.UnitInfoArray.Size-1 do
    begin
     if ScanResult.UnitInfoArray[i].InterfaceUses.Size>0 then
     begin
       ProcessNode(SourceUnitIndexs,DestUnitIndexs,Options,ScanResult,ScanResult.UnitInfoArray.Mutable[i]^,i,LogWriter,[LD_FullGraph]);
       if ScanResult.UnitInfoArray[i].NodeState<>NSFiltredOut then
       for j:=0 to ScanResult.UnitInfoArray[i].InterfaceUses.Size-1 do
       begin
         ProcessNode(SourceUnitIndexs,DestUnitIndexs,Options,ScanResult,ScanResult.UnitInfoArray.Mutable[ScanResult.UnitInfoArray[i].InterfaceUses[j]]^,ScanResult.UnitInfoArray[i].InterfaceUses[j],LogWriter,[LD_FullGraph]);
         if ScanResult.UnitInfoArray[ScanResult.UnitInfoArray[i].InterfaceUses[j]].NodeState<>NSFiltredOut then
         begin
         {if Options.GraphBulding.FullG.CalcEdgesWeight then
         if (SourceUnitIndex<>-1)and(DestUnitIndex<>-1)then
         begin
           v1:=ScanResult.G.Vertices[i];
           v2:=ScanResult.G.Vertices[ScanResult.UnitInfoArray[i].InterfaceUses[j]];
           te:=ScanResult.G.GetArc(v1,v2);
           te.Hide;
           if EdgePaths=nil then
             EdgePaths:=TMultiList.Create(TClassList);
           v1:=ScanResult.G.Vertices[SourceUnitIndex];
           v2:=ScanResult.G.Vertices[DestUnitIndex];
           paths:=ScanResult.G.FindMinPathsDirected(v2,v1,0,EdgePaths);
           EdgePaths.Clear;
           te.Restore;
         end;}
         if Options.GraphBulding.InterfaceUsesEdgeType=ETDotted then
                                                                    LogWriter(' edge [style=dotted]',[LD_FullGraph])
                                                                else
                                                                    LogWriter(' edge [style=solid]',[LD_FullGraph]);
         if paths<0 then
           LogWriter(format(' %s -> %s',
           [getDecoratedUnnitname(ScanResult.UnitInfoArray[i]),getDecoratedUnnitname(ScanResult.UnitInfoArray[ScanResult.UnitInfoArray[i].InterfaceUses[j]])]),[LD_FullGraph])
         else
           LogWriter(format({' %s -> %s [label=%d]'}' %s -> %s',[getDecoratedUnnitname(ScanResult.UnitInfoArray[i]),getDecoratedUnnitname(ScanResult.UnitInfoArray[ScanResult.UnitInfoArray[i].InterfaceUses[j]]){,paths}]),[LD_FullGraph]);
         end;
       end;
     end;
    end;

    if Options.GraphBulding.FullG.IncludeImplementationUses then
    for i:=0 to ScanResult.UnitInfoArray.Size-1 do
    begin
     if ScanResult.UnitInfoArray[i].NodeState<>NSFiltredOut then
     if ScanResult.UnitInfoArray[i].ImplementationUses.Size>0 then
     begin
       for j:=0 to ScanResult.UnitInfoArray[i].ImplementationUses.Size-1 do
       begin
         ProcessNode(SourceUnitIndexs,DestUnitIndexs,Options,ScanResult,ScanResult.UnitInfoArray.Mutable[ScanResult.UnitInfoArray[i].ImplementationUses[j]]^,ScanResult.UnitInfoArray[i].ImplementationUses[j],LogWriter,[LD_FullGraph]);
         if ScanResult.UnitInfoArray[ScanResult.UnitInfoArray[i].ImplementationUses[j]].NodeState<>NSFiltredOut then
         begin
         {if Options.GraphBulding.FullG.CalcEdgesWeight then
         if (SourceUnitIndex<>-1)and(DestUnitIndex<>-1)then
         begin
         v1:=ScanResult.G.Vertices[i];
         v2:=ScanResult.G.Vertices[ScanResult.UnitInfoArray[i].ImplementationUses[j]];
         te:=ScanResult.G.GetArc(v1,v2);
         te.Hide;
         if EdgePaths=nil then
           EdgePaths:=TMultiList.Create(TClassList);
         v1:=ScanResult.G.Vertices[SourceUnitIndex];
         v2:=ScanResult.G.Vertices[DestUnitIndex];
         paths:=ScanResult.G.FindMinPathsDirected(v2,v1,0,EdgePaths);
         EdgePaths.Clear;
         te.Restore;
         end;}
         if Options.GraphBulding.ImplementationUsesEdgeType=ETDotted then
                                                                         LogWriter(' edge [style=dotted]',[LD_FullGraph])
                                                                     else
                                                                         LogWriter(' edge [style=solid]',[LD_FullGraph]);
         if paths<0 then
           LogWriter(format(' %s -> %s',[getDecoratedUnnitname(ScanResult.UnitInfoArray[i]),getDecoratedUnnitname(ScanResult.UnitInfoArray[ScanResult.UnitInfoArray[i].ImplementationUses[j]])]),[LD_FullGraph])
         else
           LogWriter(format({' %s -> %s [label=%d]'}' %s -> %s',[getDecoratedUnnitname(ScanResult.UnitInfoArray[i]),getDecoratedUnnitname(ScanResult.UnitInfoArray[ScanResult.UnitInfoArray[i].ImplementationUses[j]]){,paths}]),[LD_FullGraph]);
         end;
       end;
     end;
    end;
    end;
    if Options.GraphBulding.PathClusters then
    begin
     Clusters:=TClusters.create;
     for i:=0 to ScanResult.UnitInfoArray.Size-1 do
     if ScanResult.UnitInfoArray[i].NodeState<>NSFiltredOut then
     if ScanResult.UnitInfoArray[i].UnitPath<>'' then
     begin
       //s:=getDecoratedUnnitname(ScanResult.UnitInfoArray[i].UnitName);
       if Clusters.trygetvalue(ScanResult.UnitInfoArray[i].UnitPath,ClusterInfo) then
         begin
          ClusterInfo.PushBack(getDecoratedUnnitname(ScanResult.UnitInfoArray[i]));
         end
       else
         begin
          s:=ScanResult.UnitInfoArray[i].UnitPath;
          ClusterInfo:=TClusterInfo.Create;
          ClusterInfo.PushBack(getDecoratedUnnitname(ScanResult.UnitInfoArray[i]));
          Clusters.add(ScanResult.UnitInfoArray[i].UnitPath,ClusterInfo);
         end;
     end;
     j:=1;
     for ClusterInfoPair in Clusters do
     begin
       LogWriter(format('  subgraph cluster_%d {',[j]),[LD_FullGraph]);
       inc(j);
       LogWriter('   style=filled;',[LD_FullGraph]);
       LogWriter('   color=lightgrey;',[LD_FullGraph]);
       LogWriter(format('   label = "%s";',[PathToSubGraphName(ClusterInfoPair.key)]),[LD_FullGraph]);
       for i:=0 to ClusterInfoPair.Value.Size-1 do
       begin
         if i<>ClusterInfoPair.Value.Size-1 then
           LogWriter(format('   %S;',[ClusterInfoPair.Value[i]]),[LD_FullGraph])
         else
           LogWriter(format('   %S;',[ClusterInfoPair.Value[i]]),[LD_FullGraph]);
       end;
       LogWriter('  }',[LD_FullGraph]);
     end;
     Clusters.free;
     ClusterInfo.Free
    end;
    LogWriter('}',[LD_FullGraph]);
    if assigned(SourceUnitIndexs)then
      SourceUnitIndexs.Free;
    if assigned(DestUnitIndexs)then
      DestUnitIndexs.Free;
    //LogWriter('CUT HERE 8x----------------------');

  end;
end;



end.

