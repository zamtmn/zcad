program GrTest3;

uses
  MultiLst,
  Pointerv,
  Graphs,
  WinCrt;

procedure Test;
var
  G: TGraph;
  M: TMultiList;

  procedure Debug;
  var
    I, J: Integer;
  begin
    for I:=0 to M.Count - 1 do begin
      writeln('Item', I);
      for J:=0 to M[I].Count - 1 do
        write(TVertex(M[I][J]).Index + 1, '; ');
      writeln;
    end;
  end;

begin
  G:=TGraph.Create;
  M:=TMultiList.Create(TClassList);
  try
    G.AddVertices(8);
    G.AddEdges([0, 1,  0, 5,  1, 6,  2, 3,  2, 4,  3, 7,  4, 5,  5, 6]);
    writeln('Maximum independent sets:');
    G.FindMaxIndependentVertexSets(SelectAll, 0, M);
    Debug;
  finally
    G.Free;
    M.Free;
  end;
end;

begin
  Test;
  write('Press Return to continue...');
  readln;
end.
