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
var
  G: TGraph;
  M: TMultiList;
  i,j,k,mmm:integer;
begin
  G:=TGraph.Create;
  G.Features:=[Directed,Weighted];
  M:=TMultiList.Create(TClassList);
  try
    G.AddVertices(ScanResult.UnitInfoArray.Size);

    for i:=0 to ScanResult.UnitInfoArray.Size-1 do
    begin
       for j:=0 to ScanResult.UnitInfoArray[i].InterfaceUses.Size-1 do
       begin
         G.AddEdgeI(i,ScanResult.UnitInfoArray[i].InterfaceUses[j]).Weight:=4;
       end;
       for j:=0 to ScanResult.UnitInfoArray[i].ImplementationUses.Size-1 do
       begin
         G.AddEdgeI(i,ScanResult.UnitInfoArray[i].ImplementationUses[j]).Weight:=2;
       end;
    end;

    for i:=0 to ScanResult.UnitInfoArray.Size-1 do
    begin
       if ScanResult.UnitInfoArray[i].ImplementationUses.Size>0 then
       begin
         for j:=0 to ScanResult.UnitInfoArray[i].ImplementationUses.Size-1 do
         begin
           if G.FindMinPathsDirected(G.Vertices[ScanResult.UnitInfoArray[i].ImplementationUses[j]],G.Vertices[i],0,m)>0 then
           begin
           LogWriter('Loop detected');
           include(ScanResult.UnitInfoArray.mutable[i]^.UnitFlags,UFLoop);
           include(ScanResult.UnitInfoArray.mutable[ScanResult.UnitInfoArray.mutable[i]^.ImplementationUses[j]]^.UnitFlags,UFLoop);
           LogWriter(format('(%s, %s)',[ScanResult.UnitInfoArray[i].UnitName,ScanResult.UnitInfoArray[ScanResult.UnitInfoArray[i].ImplementationUses[j]].UnitName]));
           for k:=0 to M.Count - 1 do begin
             for mmm:=0 to M[k].Count - 1 do With TEdge(M[k][mmm]) do
               begin
                 include(ScanResult.UnitInfoArray.mutable[V1.Index]^.UnitFlags,UFLoop);
                 include(ScanResult.UnitInfoArray.mutable[V2.Index]^.UnitFlags,UFLoop);
                 LogWriter(format('(%s, %s)',[ScanResult.UnitInfoArray[V1.Index].UnitName,ScanResult.UnitInfoArray[V2.Index].UnitName]));
               end;
           end;
           end;

         end;
       end;
    end;

    for i:=0 to ScanResult.UnitInfoArray.Size-1 do
      ScanResult.UnitInfoArray.mutable[i]^.NodeState:=NSNotCheced;
    LogWriter('Loop graph:');
    LogWriter('DiGraph Classes {');
    for i:=0 to G.EdgeCount - 1 do
    begin
      if G.Edges[i].RingEdge then
      begin
       ProcessNode(Options,ScanResult.UnitInfoArray.mutable[G.Edges[i].V1.Index]^,G.Edges[i].V1.Index,LogWriter,true);
       ProcessNode(Options,ScanResult.UnitInfoArray.mutable[G.Edges[i].V2.Index]^,G.Edges[i].V1.Index,LogWriter,true);
       if G.Edges[i].Weight<3 then
                                  LogWriter(' edge [style=dotted]');
       LogWriter(format(' %s -> %s',[ScanResult.UnitInfoArray.mutable[G.Edges[i].V1.Index]^.UnitName,ScanResult.UnitInfoArray.mutable[G.Edges[i].V2.Index]^.UnitName]));
      end;
    end;

    LogWriter('}');

  finally
    G.Free;
    M.Free;
  end;

end;

end.

