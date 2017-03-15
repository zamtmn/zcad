unit TestMapColoring;

interface

uses
  Aliasv, Graphs, ExtGraph, Planar, GrColor, MapColor;

procedure Test;

implementation

procedure Test;
var
  G: TGraph;
  Colors: TIntegerVector;
  NumColors: Integer;
begin
  writeln('*** Coloring ***');
  G:=TGraph.Create;
  Colors:=TIntegerVector.Create(0, 0);
  try
    G.AddVertices(7);
    G.AddEdges([0, 1,  1, 2,  2, 3,  3, 4,  4, 5,  5, 0,  1, 6,  3, 6,  4, 6,
      5, 6,  2, 5]);
    writeln('Planar: ', PlanarGraph(G));
    NumColors:=MapFiveColoring(G, Colors);
    if NumColors <> 3 then begin
      write('Error!');
      readln;
      Exit;
    end;
    writeln('Approximate chromatic number: ', NumColors);
    write('Colors: ');
    Colors.DebugWrite;
    writeln('Check: ', CheckColoring(G, Colors));
  finally
    G.Free;
    Colors.Free;
  end;
end;

end.
