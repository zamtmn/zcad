unit uwriter;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms,
  Graphs,MultiLst,Pointerv,
  uoptions,uscanresult,generics.Collections,gvector;

type
  TDecoratedUnitNameMode=(TDUNM_AddUsesCount);
  TDecoratedUnitNameModeSet=set of TDecoratedUnitNameMode;


  TClusterInfo=class(specialize TVector<string>)
  end;
  TClusters=specialize TDictionary<string,TClusterInfo>;
  TClusterInfoPair=specialize TPair<string,TClusterInfo>;

procedure WriteGraph(Options:TOptions;ScanResult:TScanResult;const LogWriter:TLogWriter);
procedure ProcessNode(Options:TOptions;ScanResult:TScanResult;var Node:TUnitInfo;const index:integer;const LogWriter:TLogWriter;ForceInclude:boolean=false);
function IncludeToGraph(_SourceUnitIndex,_DestUnitIndex:Integer;Options:TOptions;ScanResult:TScanResult;var Node:TUnitInfo;const index:integer;const LogWriter:TLogWriter):boolean;
function getDecoratedUnnitname(const UI:TUnitInfo;DecoratedUnitNameMode:TDecoratedUnitNameModeSet=[TDUNM_AddUsesCount]):string;

implementation
var
  SourceUnitIndex,DestUnitIndex:Integer;
function getDecoratedUnnitname(const UI:TUnitInfo;DecoratedUnitNameMode:TDecoratedUnitNameModeSet=[TDUNM_AddUsesCount]):string;
begin
  //result:=UI.UnitName;
  result:=format('%s_%d_%d',[UI.UnitName,UI.InterfaceUses.Size,UI.ImplementationUses.Size]);
  result:=StringReplace(result,'.','_',[rfReplaceAll]);
end;
function IncludeToGraph(_SourceUnitIndex,_DestUnitIndex:Integer;Options:TOptions;ScanResult:TScanResult;var Node:TUnitInfo;const index:integer;const LogWriter:TLogWriter):boolean;
var
  subresult:integer;
begin
  result:=false;
  if not Options.GraphBulding.FullG.IncludeNotFoundedUnits then
    if (node.UnitPath='')and(index<>0) then exit;
  if Options.GraphBulding.FullG.IncludeOnlyLoops and not(UFLoop in node.UnitFlags) then exit;
  subresult:=0;
  if _SourceUnitIndex<>-1 then
     if ScanResult.G.FindMinPathDirected(ScanResult.G.Vertices[index],ScanResult.G.Vertices[_SourceUnitIndex],nil)<0 then
      exit;
  if _DestUnitIndex<>-1 then
     if ScanResult.G.FindMinPathDirected(ScanResult.G.Vertices[_DestUnitIndex],ScanResult.G.Vertices[index],nil)<0 then
      exit;
  result:=true;
end;

procedure ProcessNode(Options:TOptions;ScanResult:TScanResult;var Node:TUnitInfo;const index:integer;const LogWriter:TLogWriter;ForceInclude:boolean=false);
begin
  if node.NodeState=NSNotCheced then
  begin
    if ForceInclude or IncludeToGraph(SourceUnitIndex,DestUnitIndex,Options,ScanResult,Node,index,LogWriter)then
    begin
        if Node.UnitType=UTProgram then
          LogWriter(format(' %s [shape=box]',[getDecoratedUnnitname(Node)]));
        if (Node.UnitPath='')and(index<>0) then
          LogWriter(format(' %s [style=dashed]',[getDecoratedUnnitname(Node)]));
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
begin
  SourceUnitIndex:=-1;
  DestUnitIndex:=-1;

  if Options.GraphBulding.FullG.SourceUnit<>'' then
  begin
    if ScanResult.isUnitInfoPresent(Options.GraphBulding.FullG.SourceUnit,i) then
      SourceUnitIndex:=i;
    if SourceUnitIndex=-1 then
      Application.MessageBox('Source unit not found in graph','Error!');
  end;

  if Options.GraphBulding.FullG.DestUnit<>'' then
  begin
    if ScanResult.isUnitInfoPresent(Options.GraphBulding.FullG.DestUnit,i) then
      DestUnitIndex:=i;
    if DestUnitIndex=-1 then
      Application.MessageBox('Destination unit not found in graph','Error!');
  end;

  if assigned(LogWriter) then
  begin
    LogWriter('DiGraph Classes {');
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
       ProcessNode(Options,ScanResult,ScanResult.UnitInfoArray.Mutable[i]^,i,LogWriter);
       if ScanResult.UnitInfoArray[i].NodeState<>NSFiltredOut then
       for j:=0 to ScanResult.UnitInfoArray[i].InterfaceUses.Size-1 do
       begin
         ProcessNode(Options,ScanResult,ScanResult.UnitInfoArray.Mutable[ScanResult.UnitInfoArray[i].InterfaceUses[j]]^,ScanResult.UnitInfoArray[i].InterfaceUses[j],LogWriter);
         if ScanResult.UnitInfoArray[ScanResult.UnitInfoArray[i].InterfaceUses[j]].NodeState<>NSFiltredOut then
         begin
         if Options.GraphBulding.FullG.CalcEdgesWeight then
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
         end;
         if Options.GraphBulding.InterfaceUsesEdgeType=ETDotted then
                                                                    LogWriter(' edge [style=dotted]')
                                                                else
                                                                    LogWriter(' edge [style=solid]');
         if paths<0 then
           LogWriter(format(' %s -> %s',
           [getDecoratedUnnitname(ScanResult.UnitInfoArray[i]),getDecoratedUnnitname(ScanResult.UnitInfoArray[ScanResult.UnitInfoArray[i].InterfaceUses[j]])]))
         else
           LogWriter(format({' %s -> %s [label=%d]'}' %s -> %s',[getDecoratedUnnitname(ScanResult.UnitInfoArray[i]),getDecoratedUnnitname(ScanResult.UnitInfoArray[ScanResult.UnitInfoArray[i].InterfaceUses[j]]){,paths}]));
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
         ProcessNode(Options,ScanResult,ScanResult.UnitInfoArray.Mutable[ScanResult.UnitInfoArray[i].ImplementationUses[j]]^,ScanResult.UnitInfoArray[i].ImplementationUses[j],LogWriter);
         if ScanResult.UnitInfoArray[ScanResult.UnitInfoArray[i].ImplementationUses[j]].NodeState<>NSFiltredOut then
         begin
         if Options.GraphBulding.FullG.CalcEdgesWeight then
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
         end;
         if Options.GraphBulding.ImplementationUsesEdgeType=ETDotted then
                                                                         LogWriter(' edge [style=dotted]')
                                                                     else
                                                                         LogWriter(' edge [style=solid]');
         if paths<0 then
           LogWriter(format(' %s -> %s',[getDecoratedUnnitname(ScanResult.UnitInfoArray[i]),getDecoratedUnnitname(ScanResult.UnitInfoArray[ScanResult.UnitInfoArray[i].ImplementationUses[j]])]))
         else
           LogWriter(format({' %s -> %s [label=%d]'}' %s -> %s',[getDecoratedUnnitname(ScanResult.UnitInfoArray[i]),getDecoratedUnnitname(ScanResult.UnitInfoArray[ScanResult.UnitInfoArray[i].ImplementationUses[j]]){,paths}]));
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
       LogWriter(format('  subgraph cluster_%d {',[j]));
       inc(j);
       LogWriter('   style=filled;');
       LogWriter('   color=lightgrey;');
       LogWriter(format('   label = "%s";',[PathToSubGraphName(ClusterInfoPair.key)]));
       for i:=0 to ClusterInfoPair.Value.Size-1 do
       begin
         if i<>ClusterInfoPair.Value.Size-1 then
           LogWriter(format('   %S;',[ClusterInfoPair.Value[i]]))
         else
           LogWriter(format('   %S;',[ClusterInfoPair.Value[i]]));
       end;
       LogWriter('  }');
     end;
    end;
    LogWriter('}');
    //LogWriter('CUT HERE 8x----------------------');

  end;
end;



end.

