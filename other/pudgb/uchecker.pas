unit uchecker;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,
  uoptions,uscanresult,uwriter,
  MultiLst,
  Pointerv,
  Graphs;


procedure CheckGraph(Options:TOptions;ScanResult:TScanResult;const LogWriter:TLogWriter);

implementation

procedure CheckGraph(Options:TOptions;ScanResult:TScanResult;const LogWriter:TLogWriter);
function getDecoratedUnnitname(index:integer):string;
begin
  //result:=ScanResult.UnitInfoArray[index].UnitName;
  result:=format('%s_%d_%d',[ScanResult.UnitInfoArray[index].UnitName,ScanResult.UnitInfoArray[index].InterfaceUses.Size,ScanResult.UnitInfoArray[index].ImplementationUses.Size])
end;

var
  G: TGraph;
  M: TMultiList;
  i,j,k,mmm:integer;
  TotalUnitsWithImplUses,
  TotalFoundedUnits,
  TotaEdgesWithLoops,CurrentEdgesWithLoops,
  TotaUnitsWithLoops:integer;
  ts:string;
  te:TEdge;
begin
  G:=TGraph.Create;
  G.Features:=[Directed,Weighted];
  M:=TMultiList.Create(TClassList);
  try
    G.AddVertices(ScanResult.UnitInfoArray.Size);

    TotalUnitsWithImplUses:=0;
    TotalFoundedUnits:=0;
    for i:=0 to ScanResult.UnitInfoArray.Size-1 do
    begin
       if ScanResult.UnitInfoArray[i].UnitPath<>'' then inc(TotalFoundedUnits);
       for j:=0 to ScanResult.UnitInfoArray[i].InterfaceUses.Size-1 do
       begin
         G.AddEdgeI(i,ScanResult.UnitInfoArray[i].InterfaceUses[j]).Weight:=4;
       end;
       if ScanResult.UnitInfoArray[i].ImplementationUses.Size>0 then
       begin
         inc(TotalUnitsWithImplUses);
         for j:=0 to ScanResult.UnitInfoArray[i].ImplementationUses.Size-1 do
         begin
           G.AddEdgeI(i,ScanResult.UnitInfoArray[i].ImplementationUses[j]).Weight:=2;
         end;
       end;
    end;
    (*LogWriter('Loop graph by units:');
    LogWriter('DiGraph Classes {');
    for i:=0 to ScanResult.UnitInfoArray.Size-1 do
    begin
       if ScanResult.UnitInfoArray[i].ImplementationUses.Size>0 then
       begin
         for j:=0 to ScanResult.UnitInfoArray[i].ImplementationUses.Size-1 do
         begin
           if G.FindMinPathsDirected(G.Vertices[ScanResult.UnitInfoArray[i].ImplementationUses[j]],G.Vertices[i],0,m)>0 then
           begin
           //LogWriter('Loop detected');
           include(ScanResult.UnitInfoArray.mutable[i]^.UnitFlags,UFLoop);
           include(ScanResult.UnitInfoArray.mutable[ScanResult.UnitInfoArray.mutable[i]^.ImplementationUses[j]]^.UnitFlags,UFLoop);
           //LogWriter(format('(%s, %s)',[ScanResult.UnitInfoArray[i].UnitName,ScanResult.UnitInfoArray[ScanResult.UnitInfoArray[i].ImplementationUses[j]].UnitName]));
           LogWriter(format(' %s -> %s',[ScanResult.UnitInfoArray[i].UnitName,ScanResult.UnitInfoArray[ScanResult.UnitInfoArray[i].ImplementationUses[j]].UnitName]));
           for k:=0 to M.Count - 1 do begin
             for mmm:=0 to M[k].Count - 1 do With TEdge(M[k][mmm]) do
               begin
                 include(ScanResult.UnitInfoArray.mutable[V1.Index]^.UnitFlags,UFLoop);
                 include(ScanResult.UnitInfoArray.mutable[V2.Index]^.UnitFlags,UFLoop);
                 //LogWriter(format('(%s, %s)',[ScanResult.UnitInfoArray[V1.Index].UnitName,ScanResult.UnitInfoArray[V2.Index].UnitName]));
                 LogWriter(format(' %s -> %s',[ScanResult.UnitInfoArray[V1.Index].UnitName,ScanResult.UnitInfoArray[V2.Index].UnitName]));
               end;
           end;
           end;

         end;
       end;
    end;
    LogWriter('}');*)

    TotaEdgesWithLoops:=0;
    for i:=0 to ScanResult.UnitInfoArray.Size-1 do
      ScanResult.UnitInfoArray.mutable[i]^.NodeState:=NSNotCheced;
    LogWriter('Loop graph by edges:');
    LogWriter('DiGraph Classes {');
    for i:=0 to G.EdgeCount - 1 do
    begin
      if G.Edges[i].RingEdge then
      begin
       inc(TotaEdgesWithLoops);
       include(ScanResult.UnitInfoArray.mutable[G.Edges[i].V1.Index]^.UnitFlags,UFLoop);
       include(ScanResult.UnitInfoArray.mutable[G.Edges[i].V2.Index]^.UnitFlags,UFLoop);
       ProcessNode(Options,ScanResult.UnitInfoArray.mutable[G.Edges[i].V1.Index]^,G.Edges[i].V1.Index,LogWriter,true);
       ProcessNode(Options,ScanResult.UnitInfoArray.mutable[G.Edges[i].V2.Index]^,G.Edges[i].V1.Index,LogWriter,true);
       if G.Edges[i].Weight<3 then
                                  LogWriter(' edge [style=dotted]')
                              else
                                  LogWriter(' edge [style=solid]');
       te:=G.Edges[i];
       te.Hide;
       CurrentEdgesWithLoops:=0;
       begin
       for j:=0 to G.EdgeCount - 1 do
       if G.Edges[j].RingEdge then
         inc(CurrentEdgesWithLoops);
       end;
       te.Restore;
       LogWriter(format(' %s -> %s [label=%d]',[getDecoratedUnnitname(G.Edges[i].V1.Index),getDecoratedUnnitname(G.Edges[i].V2.Index),CurrentEdgesWithLoops]));
      end;
    end;
    LogWriter('}');

    TotaUnitsWithLoops:=0;
    for i:=0 to ScanResult.UnitInfoArray.Size-1 do
    begin
       if UFLoop in ScanResult.UnitInfoArray[i].UnitFlags then
                                                              inc(TotaUnitsWithLoops)
       else
         if ScanResult.UnitInfoArray[i].ImplementationUses.Size>0 then
         begin
          if ts<>'' then
                        ts:=ts+', '+ScanResult.UnitInfoArray[i].UnitName
                    else
                        ts:=ScanResult.UnitInfoArray[i].UnitName;
         end;
    end;
    if ts<>'' then ts:=ts+';';

    LogWriter(format('Total units: %d ',[ScanResult.UnitInfoArray.Size]));
    LogWriter(format('Total founded units: %d ',[TotalFoundedUnits]));
    LogWriter(format('Total units with Implimentation uses: %d ',[TotalUnitsWithImplUses]));
    LogWriter(format('Total units in loops: %d ',[TotaUnitsWithLoops]));

    LogWriter(format('Total dependencies: %d ',[G.EdgeCount]));
    LogWriter(format('Total dependencies in loops: %d ',[TotaEdgesWithLoops]));

    if ts<>'' then LogWriter(format('Implimentation uses can be move to interface in %s ',[ts]));
  finally
    G.Free;
    M.Free;
  end;

end;

end.

