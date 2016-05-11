unit TestDominatingSet;

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
  writeln('*** Dominating Set ***');
  G:=TGraph.Create;
  Solutions:=TClassList.Create;
  M:=nil;
  try
    G.AddVertices(16);
    G.AddEdges([0,  1,   0,  4,   1,  2,   1,  5,   2,  3,   2, 6,
                3,  7,   4,  5,   4,  8,   5,  6,   5,  9,   6, 7,
                6,  10,  7,  11,  8,  9,   8,  12,  9,  10,  9, 13,
                10, 11,  10, 14,  11, 15,  12, 13,  13, 14,  14, 15]);
    M:=G.CreateConnectionMatrix;
    M.Transpose;
    FindMinCoverings(M, 0, Solutions);
    writeln('Dominating Sets:');
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
