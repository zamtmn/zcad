unit TestEdgeCovering;

interface

uses
  Aliasv,
  Boolm,
  Graphs,
  Pointerv,
  Optimize;

procedure Test;

implementation

procedure Test;
var
  G: TGraph;
  M: TBoolMatrix;
  Solutions: TClassList;
  I: Integer;
begin
  writeln('*** Edge Covering ***');
  G:=TGraph.Create;
  Solutions:=TClassList.Create;
  M:=nil;
  try
{    G.AddVertices(16);
    G.AddEdges([0,  1,   0,  4,   1,  2,   1,  5,   2,  3,   2, 6,
                3,  7,   4,  5,   4,  8,   5,  6,   5,  9,   6, 7,
                6,  10,  7,  11,  8,  9,   8,  12,  9,  10,  9, 13,
                10, 11,  10, 14,  11, 15,  12, 13,  13, 14,  14, 15]);}
    G.AddVertices(5);
    G.AddEdges([0, 1,  0, 2,  0, 3,  1, 2,  1, 3,  2, 3,  3, 4]);
    writeln('Incidence Matrix:');
    M:=G.CreateIncidenceMatrix;
    M.DebugWrite01;
    writeln('Edge Coverings:');
    FindMinCoverings(M, -1, Solutions);
    for I:=0 to Solutions.Count - 1 do
      TIntegerVector(Solutions[I]).DebugWrite;
  finally
    G.Free;
    M.Free;
    Solutions.FreeItems;
    Solutions.Free;
  end;
end;

end.
