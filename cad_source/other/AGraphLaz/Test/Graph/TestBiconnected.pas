unit TestBiconnected;

interface

uses
  ExtGraph, Pointerv, Graphs;

procedure Test;

implementation

procedure Test;
var
  I: Integer;
  G: TGraph;
  L: TClassList;
begin
  writeln('*** Test Biconnectivity ***');
  G:=TGraph.Create;
  L:=TClassList.Create;
  try
    GetCompleteGraph(G, 4);
    G.AddVertices(4);
    G.AddEdges([1, 4,  4, 6,  6, 7,  2, 5]);
    writeln('Biconnected: ', G.Biconnected(L));
    write('Articulation Points: ');
    for I:=0 to L.Count - 1 do
      write(TVertex(L[I]).Index, ' ');
    writeln;
    write('New Edges To Make Graph Biconnected: ');
    writeln(G.MakeBiconnected(L));
    for I:=0 to L.Count - 1 do With TEdge(L[I]) do
      write('(', V1.Index, ', ', V2.Index, ') ');
    writeln;
    writeln('Biconnected: ', G.Biconnected(nil));
  finally
    G.Free;
    L.Free;
  end;
end;

end.
