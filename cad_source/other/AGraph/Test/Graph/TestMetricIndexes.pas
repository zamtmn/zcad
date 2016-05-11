unit TestMetricIndexes;

interface

uses
  Aliasv, Aliasm, ExtType, ExtGraph, Graphs;

procedure Test;

implementation

procedure Test;
var
  GraphEcc, GraphDist: Integer;
  AvgGraphEcc, AvgGraphDist: Float;
  G: TGraph;
  D: TIntegerMatrix;
  Ecc, Dist: TIntegerVector;
begin
  writeln('*** Graph Metric Indexes ***');
  G:=TGraph.Create;
  D:=nil;
  Ecc:=nil;
  Dist:=nil;
  try
    G.AddVertices(6);
    G.AddEdges([0, 2,  0, 3,  0, 4,  1, 2,  1, 3,  1, 4,  1, 5,  2, 4,  3, 4]);
    D:=G.CreateDistanceMatrix;
    writeln('Distance Matrix');
    D.DebugWrite;
    { матрица симметричная, поэтому в Vector хранятся только верхнетреугольные
      элементы матрицы, и сумма значений Vector равна полусумме значений всех
      элементов матрицы }
    GraphDist:=2 * D.Vector.Sum;
    write('Graph Distance: ');
    writeln(GraphDist);
    write('Wiener Index: ');
    writeln(GraphDist div 2);
    writeln('Vertex Eccentricities');
    Ecc:=CreateEccentricitiesVector(D);
    Ecc.DebugWrite;
    write('Graph Radius: ');
    writeln(Ecc.Min);
    write('Graph Diameter: ');
    writeln(Ecc.Max);
    write('Graph Eccentricity: ');
    GraphEcc:=Ecc.Sum;
    writeln(GraphEcc);
    write('Average Graph Eccentricity: ');
    AvgGraphEcc:=GraphEcc / G.VertexCount;
    writeln(AvgGraphEcc :0:4);
    writeln('Vertex Distances');
    Dist:=CreateDistancesVector(D);
    Dist.DebugWrite;
    AvgGraphDist:=GraphDist / G.VertexCount;
    write('Average Graph Distance: ');
    writeln(AvgGraphDist :0:4);
    write('Randich Index: ');
    writeln(RandichIndex(G) :0:4);
    write('Balaban Index: ');
    writeln(BalabanIndex(G.CyclomaticNumber, Dist) :0:4);
  finally
    G.Free;
    D.Free;
    Ecc.Free;
    Dist.Free;
  end;
end;

end.

