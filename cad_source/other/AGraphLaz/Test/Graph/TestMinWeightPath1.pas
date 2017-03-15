unit TestMinWeightPath1;

{$MODE Delphi}

interface

uses
  Pointerv,
  Aliasv,
  Aliasm,
  Graphs;

procedure Test;

implementation

procedure Test;
var
  G: TGraph;
  EdgePath, VerticePath: TClassList;
  WeightMatrix: TFloatMatrix;
  PathsMatrix: TIntegerMatrix;
  T: TIntegerVector;
  I, J: Integer;
begin
  writeln('*** Min Weight Path ***');
  G:=TGraph.Create;
  G.Features:=[Weighted, Directed];
  EdgePath:=TClassList.Create;
  VerticePath:=TClassList.Create;
  WeightMatrix:=nil;
  PathsMatrix:=TIntegerMatrix.Create(0, 0, 0);
  T:=TIntegerVector.Create(0, 0);
  try
    G.AddVertices(5);
    G.AddEdges([0, 1,  0, 2,  1, 2,  2, 3,  0, 4,  4, 3,  2, 0]);
    G.Edges[0].Weight:=2;
    G.Edges[1].Weight:=1;
    G.Edges[2].Weight:=-2;
    G.Edges[3].Weight:=3;
    G.Edges[4].Weight:=10;
    G.Edges[5].Weight:=-8;
    writeln(G.CreateMinWeightPathsMatrix(WeightMatrix, PathsMatrix));
    writeln('WeightMatrix: ');
    WeightMatrix.DebugWrite;
    write('Press Return to continue...'); readln;
    for I:=0 to G.VertexCount - 1 do
      for J:=0 to G.VertexCount - 1 do begin
        write('(', I, ', ', J, '): ');
        if G.DecodeMinWeightPath(WeightMatrix, PathsMatrix, I, J, T) then
          T.DebugWrite
        else
          writeln('No path');;
      end;
  finally
    G.Free;
    EdgePath.Free;
    VerticePath.Free;
    WeightMatrix.Free;
    PathsMatrix.Free;
    T.Free;
  end;
end;

end.
