unit TestBipartite;

interface

uses
  ExtType, Boolv, Graphs;

procedure Test;

implementation

procedure Test;
var
  I: Integer;
  B: Bool;
  G: TGraph;
  A: TBoolVector;
begin
  writeln('*** Testing If Graph Bipartite ***');
  G:=TGraph.Create;
  A:=TBoolVector.Create(0, False);
  try
    G.AddVertices(8);
    G.AddEdges([0, 1,  1, 2,  1, 4,  2, 3,  2, 5,  3, 4,  4, 5,  5, 6,  5, 7]);
    write('Bipartite: ');
    B:=G.Bipartite(A);
    writeln(B);
    if B then begin
      writeln('Vertex'#9'Part');
      for I:=0 to A.Count - 1 do
        writeln(I, #9, Ord(A[I]));
    end;
  finally
    G.Free;
    A.Free;
  end;
end;

end.
