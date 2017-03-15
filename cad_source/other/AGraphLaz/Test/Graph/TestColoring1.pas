unit TestColoring1;

interface

uses
  Aliasv,
  Graphs,
  GrColor;

procedure Test;

implementation

procedure Test;
var
  G: TGraph;
  Colors: TIntegerVector;
begin
  writeln('*** Coloring ***');
  G:=TGraph.Create;
  Colors:=TIntegerVector.Create(0, 0);
  try
    G.AddVertices(10);
    G.AddEdges([0, 1,  0, 2,  0, 3,  0, 4,  0, 5,  0, 6,  0, 7,  0, 8,  0, 9,
      1, 2,  2, 3,  3, 4,  4, 5,  5, 6,  6, 7,  7, 8,  8, 9,  9, 1,
      1, 3,  3, 5,  3, 6,  6, 8,  6, 1,  8,  1]);
    writeln('Chromatic number: ', ApproximateColoring1(G, Colors));
    write('Colors: ');
    Colors.DebugWrite;
    writeln('Check: ', CheckColoring(G, Colors));
  finally
    G.Free;
    Colors.Free;
  end;
end;

end.
