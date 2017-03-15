unit TestMycielski;

interface

uses
  Aliasv, Graphs, GrColor, Boolm, MultiLst, Pointerv, Mycielski;

procedure Test(N: Integer);

implementation

procedure Test(N: Integer);
var
  G: TGraph;
  ConnectionMatrix: TBoolMatrix;
  Colors: TIntegerVector;
  VertexSet: TMultiList;
begin
  writeln('*** Mycielski Graph (', N,  ') ***');
  G:=TGraph.Create;
  ConnectionMatrix:=nil;
  Colors:=TIntegerVector.Create(0, 0);
  VertexSet:=TMultiList.Create(TClassList);
  try
    GetMycielski(G, N);
    ConnectionMatrix:=G.CreateConnectionMatrix;
    writeln('Chromatic number: ', GraphColoring(G, Colors));
    G.GetComplementOf(G);
    G.FindMaxIndependentVertexSets(SelectAnyMax, 0, VertexSet);
    writeln('Compactness: ', VertexSet[0].Count);
  finally
    G.Free;
    ConnectionMatrix.Free;
    Colors.Free;
    VertexSet.Free;
  end;
end;

end.
