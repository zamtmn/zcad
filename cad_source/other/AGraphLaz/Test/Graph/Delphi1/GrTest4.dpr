program GrTest4;

uses
  Aliasv,
  Int16v,
  Graphs,
  GrColor,
  WinCrt;

procedure Test;
var
  G: TGraph;
  Colors: TIntegerVector;
begin
  G:=TGraph.Create;
  Colors:=TIntegerVector.Create(0, 0);
  try
    G.AddVertices(7);
    G.AddEdges([0, 1,  1, 2,  2, 3,  3, 4,  4, 5,  5, 0,  1, 6,  3, 6,  4, 6,
      5, 6,  2, 5,  1, 4]);
    writeln('Chromatic number: ', GraphColoring(G, Colors));
    write('Colors: ');
    Colors.DebugWrite;
    writeln('Check: ', CheckColoring(G, Colors));
  finally
    G.Free;
    Colors.Free;
  end;
end;

begin
  Test;
  write('Press Return to continue...');
  readln;
end.
