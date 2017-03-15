unit TestST;

interface

uses
  ExtType,
  Pointerv,
  Graphs;

procedure Test;

implementation

procedure Test;
var
  G: TGraph;
  ST: TPointerVector;
  I: Integer;
begin
  writeln('*** Spanning Tree ***');
  G:=TGraph.Create;
  ST:=TPointerVector.Create;
  try
    G.AddVertices(12);
    G.AddEdges([0, 1,  1, 2,  2, 3,  3, 4,  1, 4,  5, 6,  6, 7,  8, 9,  9, 10,
      10, 11]);
    writeln(G.FindSpanningTree(nil, ST));
    for I:=0 to ST.Count - 1 do With TEdge(ST[I]) do
      writeln( '(', V1.Index, ', ', V2.Index, ') ');
  finally
    G.Free;
    ST.Free;
  end;
end;

end.
 
