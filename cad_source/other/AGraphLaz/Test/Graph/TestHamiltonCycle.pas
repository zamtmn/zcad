unit TestHamiltonCycle;

interface

uses
  Graphs,
  Pointerv,
  MultiLst,
  HamilCyc;

procedure Test;

implementation

procedure Test;
var
  G: TGraph;
  EdgePaths: TMultiList;
  I, J: Integer;
  T: TClassList;
  E: TEdge;
begin
  writeln('*** Hamilton Cycle ***');
  G:=TGraph.Create;
  G.Features:=[Directed];
  EdgePaths:=TMultiList.Create(TClassList);
  try
    G.AddVertices(6);
    G.AddEdges([0, 1,  1, 1,  1, 2,  1, 4,  2, 0,  2, 3,  3, 2,  3, 5,  4, 2,
      4, 3,  5, 0,  5, 1,  5, 2]);
    writeln(FindHamiltonCycles(G, G[0], 0, EdgePaths));
    for I:=0 to EdgePaths.Count - 1 do With EdgePaths[I] do begin
      T:=EdgePaths[I];
      for J:=0 to T.Count - 1 do begin
        E:=TEdge(T[J]);
        write('(', E.V1.Index, ', ', E.V2.Index, ') ');
      end;
      writeln;
    end;
  finally
    G.Free;
    EdgePaths.Free;
  end;
end;

end.
