unit uwriter;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms,
  Graphs,MultiLst,Pointerv,
  uprojectoptions,uscanresult,generics.Collections,gvector,masks;

type
  TDecoratedUnitNameMode=(TDUNM_AddUsesCount);
  TDecoratedUnitNameModeSet=set of TDecoratedUnitNameMode;


  TNodeIndexes=specialize TVector<integer>;
  TClusters=specialize TDictionary<string,TClusterInfo>;
  TLinkCounter=class (specialize TDictionary<string,Integer>)
    procedure addlink(ln:string);
  end;
  TLinkCounterPair=specialize TPair<string,Integer>;
  TClusterInfoPair=specialize TPair<string,TClusterInfo>;

procedure WriteGraph(Options:TProjectOptions;ScanResult:TScanResult;const LogWriter:TLogWriter);
procedure ProcessNode(_SourceUnitIndex,_DestUnitIndex:TNodeIndexes;Options:TProjectOptions;ScanResult:TScanResult;var Node:TUnitInfo;const index:integer;const LogWriter:TLogWriter;const LogOpt:TLogOpt;ForceInclude:boolean=false);
function IncludeToGraph(_SourceUnitIndex,_DestUnitIndex:TNodeIndexes;const Options:TProjectOptions;const ScanResult:TScanResult;var Node:TUnitInfo;const index:integer;const LogWriter:TLogWriter):boolean;
function getDecoratedUnnitname(const UI:TUnitInfo;DecoratedUnitNameMode:TDecoratedUnitNameModeSet=[TDUNM_AddUsesCount]):string;

implementation

function PathToSubGraphName(s:string):string;
begin
  result:=StringReplace(s,'.','_',[rfReplaceAll]);
  result:=StringReplace(s,':','_',[rfReplaceAll]);
  result:=StringReplace(result,'/','_',[rfReplaceAll]);
  result:=StringReplace(result,'\','_',[rfReplaceAll]);
end;

function getDecoratedUnnitName(const UI:TUnitInfo;DecoratedUnitNameMode:TDecoratedUnitNameModeSet=[TDUNM_AddUsesCount]):string;
begin
  //result:=UI.UnitName;
  result:=format('%s_%d_%d',[UI.UnitName,UI.InterfaceUses.Size,UI.ImplementationUses.Size]);
end;
function getDecoratedClusterName(const path:string;ucount:integer):string;
begin
  result:=format('%s_%d',[PathToSubGraphName(path),ucount]);
  result:=StringReplace(result,'.','_',[rfReplaceAll]);
end;

function CheckIncludeOptions(const Options:TProjectOptions;const UnitName:string):TIncludeToGraph;
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

function CheckCollapseOptions(const Options:TProjectOptions;const ClusterName:string):TCollapseCluster;
begin
  result:=CC_Expand;
  if Options.GraphBulding.CollapseClusters<>'' then
    if MatchesMaskList(ClusterName,Options.GraphBulding.CollapseClusters) then
      begin
        result:=CC_Collapse;
      end;
  if Options.GraphBulding.ExpandClusters<>'' then
    if MatchesMaskList(ClusterName,Options.GraphBulding.ExpandClusters) then
      begin
        result:=CC_Expand;
      end;
end;

function IncludeToGraph(_SourceUnitIndex,_DestUnitIndex:TNodeIndexes;const Options:TProjectOptions;const ScanResult:TScanResult;var Node:TUnitInfo;const index:integer;const LogWriter:TLogWriter):boolean;
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

procedure CheckNode(_SourceUnitIndex,_DestUnitIndex:TNodeIndexes;Options:TProjectOptions;ScanResult:TScanResult;var Node:TUnitInfo;const index:integer;const LogWriter:TLogWriter;const LogOpt:TLogOpt;ForceInclude:boolean=false);
begin
  if node.NodeState=NSNotCheced then
  begin
    if ForceInclude or IncludeToGraph(_SourceUnitIndex,_DestUnitIndex,Options,ScanResult,Node,index,LogWriter)then
        node.NodeState:=NSChecedNotWrited
    else
        node.NodeState:=NSFiltredOut;
  end;
end;

procedure WriteNode(var Node:TUnitInfo;const index:integer;const LogWriter:TLogWriter;const LogOpt:TLogOpt);
begin
  if node.NodeState=NSChecedNotWrited then
  begin
    if Node.UnitType=UTProgram then
      LogWriter(format(' %s [shape=box]',[getDecoratedUnnitname(Node)]),LogOpt);
    if (Node.UnitPath='')and(index<>0) then
      LogWriter(format(' %s [style=dashed]',[getDecoratedUnnitname(Node)]),LogOpt);
    node.NodeState:=NSCheced
  end;
end;

procedure ProcessNode(_SourceUnitIndex,_DestUnitIndex:TNodeIndexes;Options:TProjectOptions;ScanResult:TScanResult;var Node:TUnitInfo;const index:integer;const LogWriter:TLogWriter;const LogOpt:TLogOpt;ForceInclude:boolean=false);
begin
  CheckNode(_SourceUnitIndex,_DestUnitIndex,Options,ScanResult,Node,index,LogWriter,LogOpt,ForceInclude);
  WriteNode(Node,index,LogWriter,LogOpt);
end;

procedure TLinkCounter.addlink(ln:string);
var
  counter:integer;
begin
  if trygetvalue(ln,counter) then
    begin
     AddOrSetValue(ln,counter+1);
    end
  else
    begin
     AddOrSetValue(ln,1);
    end;
end;

procedure WriteGraph(Options:TProjectOptions;ScanResult:TScanResult;const LogWriter:TLogWriter);
var
  cc:TCollapseCluster;
  nstart,nend,link:string;
  i,j:integer;
  s:string;
  te:TEdge;
  v1,v2:TVertex;
  EdgePaths:TMultiList=nil;
  Clusters:TClusters;
  ClusterInfo:TClusterInfo;
  ClusterInfoPair:TClusterInfoPair;
  SourceUnitIndexs,DestUnitIndexs:TNodeIndexes;
  LC:TLinkCounter;
  LCP:TLinkCounterPair;
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
    LogWriter('DiGraph Classes {',[LD_FullGraph,LD_Clear]);
    if assigned(ScanResult) then
    begin
      for i:=0 to ScanResult.UnitInfoArray.Size-1 do
      begin
       ScanResult.UnitInfoArray.mutable[i]^.NodeState:=NSNotCheced;
       CheckNode(SourceUnitIndexs,DestUnitIndexs,Options,ScanResult,ScanResult.UnitInfoArray.Mutable[i]^,i,LogWriter,[LD_FullGraph]);
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
            ScanResult.UnitInfoArray.Mutable[i]^.Cluster:=ClusterInfo;
           end
         else
           begin
            s:=ScanResult.UnitInfoArray[i].UnitPath;
            ClusterInfo:=TClusterInfo.Create;
            ScanResult.UnitInfoArray.Mutable[i]^.Cluster:=ClusterInfo;
            ClusterInfo.collapsed:=CheckCollapseOptions(options,PathToSubGraphName(ScanResult.UnitInfoArray[i].UnitPath));
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
         if ClusterInfoPair.Value.collapsed=CC_Expand then
           for i:=0 to ClusterInfoPair.Value.Size-1 do
           begin
             if i<>ClusterInfoPair.Value.Size-1 then
               LogWriter(format('   %S;',[ClusterInfoPair.Value[i]]),[LD_FullGraph])
             else
               LogWriter(format('   %S;',[ClusterInfoPair.Value[i]]),[LD_FullGraph]);
           end
         else
           LogWriter(format('   %S;',[getDecoratedClusterName(ClusterInfoPair.Key,ClusterInfoPair.Value.Size)]),[LD_FullGraph]);
         LogWriter('  }',[LD_FullGraph]);
       end;
       //Clusters.Free;
       //ClusterInfo.Free
      end;

    if Options.GraphBulding.FullG.IncludeInterfaceUses then
    begin
    LC:=TLinkCounter.create;
    if Options.GraphBulding.InterfaceUsesEdgeType=ETDotted then
                                                               LogWriter(' edge [style=dotted]',[LD_FullGraph])
                                                           else
                                                               LogWriter(' edge [style=solid]',[LD_FullGraph]);
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
         if (ScanResult.UnitInfoArray[i].cluster<>nil)and(Options.GraphBulding.PathClusters) then
           cc:=ScanResult.UnitInfoArray[i].cluster.collapsed
         else
           cc:=CC_Expand;

         if cc=CC_Expand then
           nstart:=getDecoratedUnnitname(ScanResult.UnitInfoArray[i])
         else
           nstart:=getDecoratedClusterName(ScanResult.UnitInfoArray[i].UnitPath,ScanResult.UnitInfoArray[i].cluster.size);

         if (ScanResult.UnitInfoArray[ScanResult.UnitInfoArray[i].InterfaceUses[j]].cluster<>nil)and(Options.GraphBulding.PathClusters) then
           cc:=ScanResult.UnitInfoArray[ScanResult.UnitInfoArray[i].InterfaceUses[j]].cluster.collapsed
         else
           cc:=CC_Expand;

         if cc=CC_Expand then
           nend:=getDecoratedUnnitname(ScanResult.UnitInfoArray[ScanResult.UnitInfoArray[i].InterfaceUses[j]])
         else
           nend:=getDecoratedClusterName(ScanResult.UnitInfoArray[ScanResult.UnitInfoArray[i].InterfaceUses[j]].UnitPath,ScanResult.UnitInfoArray[ScanResult.UnitInfoArray[i].InterfaceUses[j]].cluster.size);
         link:=format(' %s -> %s',[nstart,nend]);
         LC.addlink(link);
         //LogWriter(format(' %s -> %s',[nstart,nend]),[LD_FullGraph])
         end;
       end;
     end;
    end;
    for LCP in LC do
       begin
         if (LCP.Value>1)and(Options.GraphBulding.LabelClustersEdges) then
           LogWriter(format('%s  [label=%d]',[LCP.Key,LCP.Value]),[LD_FullGraph])
         else
           LogWriter(LCP.Key,[LD_FullGraph]);
       end;
    LC.free;
    end;

    if Options.GraphBulding.FullG.IncludeImplementationUses then
    begin
    LC:=TLinkCounter.create;
    if Options.GraphBulding.ImplementationUsesEdgeType=ETDotted then
                                                                    LogWriter(' edge [style=dotted]',[LD_FullGraph])
                                                                else
                                                                    LogWriter(' edge [style=solid]',[LD_FullGraph]);
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
         if (ScanResult.UnitInfoArray[i].cluster<>nil)and(Options.GraphBulding.PathClusters) then
           cc:=ScanResult.UnitInfoArray[i].cluster.collapsed
         else
           cc:=CC_Expand;

         if cc=CC_Expand then
           nstart:=getDecoratedUnnitname(ScanResult.UnitInfoArray[i])
         else
           nstart:=getDecoratedClusterName(ScanResult.UnitInfoArray[i].UnitPath,ScanResult.UnitInfoArray[i].cluster.size);

         if (ScanResult.UnitInfoArray[ScanResult.UnitInfoArray[i].ImplementationUses[j]].cluster<>nil)and(Options.GraphBulding.PathClusters) then
           cc:=ScanResult.UnitInfoArray[ScanResult.UnitInfoArray[i].ImplementationUses[j]].cluster.collapsed
         else
           cc:=CC_Expand;

         if cc=CC_Expand then
           nend:=getDecoratedUnnitname(ScanResult.UnitInfoArray[ScanResult.UnitInfoArray[i].ImplementationUses[j]])
         else
           nend:=getDecoratedClusterName(ScanResult.UnitInfoArray[ScanResult.UnitInfoArray[i].ImplementationUses[j]].UnitPath,ScanResult.UnitInfoArray[ScanResult.UnitInfoArray[i].ImplementationUses[j]].cluster.size);
         {nstart:=getDecoratedUnnitname(ScanResult.UnitInfoArray[i]);
         nend:=getDecoratedUnnitname(ScanResult.UnitInfoArray[ScanResult.UnitInfoArray[i].ImplementationUses[j]]);}
         link:=format(' %s -> %s',[nstart,nend]);
         LC.addlink(link);
         //LogWriter(format(' %s -> %s',[nstart,nend]),[LD_FullGraph])
         end;
       end;
     end;
    end;
    for LCP in LC do
       begin
         if (LCP.Value>1)and(Options.GraphBulding.LabelClustersEdges) then
           LogWriter(format('%s  [label=%d]',[LCP.Key,LCP.Value]),[LD_FullGraph])
         else
           LogWriter(LCP.Key,[LD_FullGraph]);
       end;
    LC.free;
    end;

    if Options.GraphBulding.PathClusters then
    begin
     Clusters.Free;
     ClusterInfo.Free
    end;

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

