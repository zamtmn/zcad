unit TestMaxIndependentVertexSet;

interface

uses
  MultiLst,
  Pointerv,
  Graphs;

procedure Test;

implementation

procedure Test;
var
  G: TGraph;
  M: TMultiList;

  procedure Debug;
  var
    I, J: Integer;
  begin
    for I:=0 to M.Count - 1 do begin
      write('Set ', I + 1, ':'^I);
      for J:=0 to M[I].Count - 1 do
        write(TVertex(M[I][J]).Index, ' ');
      writeln;
    end;
  end;

begin
  writeln('*** Maximum Independent Vertex Sets ***');
  G:=TGraph.Create;
  M:=TMultiList.Create(TClassList);
  try
    G.AddVertices(7);
    G.AddEdges([0, 1,  0, 5,  1, 2,  1, 3,  1, 5,  3, 4,  3, 6,  5, 6]);
    writeln('Maximum independent sets:');
    G.FindMaxIndependentVertexSets(SelectAll, 0, M);
    Debug;
  finally
    G.Free;
    M.Free;
  end;
end;

end.
