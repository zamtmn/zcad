unit TestMatching;

interface

uses
  Boolm,
  Graphs,
  Pointerv,
  MultiLst;

procedure Test;

implementation

procedure Test;
var
  G, LineGraph: TGraph;
  Solutions: TMultiList;
  I, J: Integer;
begin
  writeln('*** Matching ***');
  G:=TGraph.Create;
  LineGraph:=TGraph.Create;
  Solutions:=TMultiList.Create(TClassList);
  try
    G.AddVertices(16);
    G.AddEdges([0,  1,   0,  4,   1,  2,   1,  5,   2,  3,   2, 6,
                3,  7,   4,  5,   4,  8,   5,  6,   5,  9,   6, 7,
                6,  10,  7,  11,  8,  9,   8,  12,  9,  10,  9, 13,
                10, 11,  10, 14,  11, 15,  12, 13,  13, 14,  14, 15]);
    writeln('Maximum matchings:');
    LineGraph.GetLineGraphOf(G); { строим реберный граф для графа G }
    LineGraph.FindMaxIndependentVertexSets(SelectAnyMax, 0, Solutions);
    for I:=0 to Solutions.Count - 1 do begin
      for J:=0 to Solutions[I].Count - 1 do
        With G.Edges[TVertex(Solutions[I][J]).Index] do
          write('(', V1.Index, ', ', V2.Index, ') ');
      writeln;
    end;
  finally
    G.Free;
    LineGraph.Free;
    Solutions.Free;
  end;
end;

end.
