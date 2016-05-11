program GrTest5;

uses
  Graphs,
  Pointerv,
  EulerCyc,
  WinCrt;

procedure Test;
var
  G: TGraph;
  EdgePath: TClassList;
  I: Integer;
begin
  G:=TGraph.Create;
  EdgePath:=TClassList.Create;
  try
    G.AddVertices(8);
    G.AddEdges([0, 1,  0, 2,  1, 2,  2, 4,  4, 6,  4, 5,  5, 6,  6, 7,  7, 4,
      0, 3,  3, 2, 0, 6]);
    writeln(FindEulerCycle(G, G.Vertices[0], EdgePath));
    for I:=0 to EdgePath.Count - 1 do With TEdge(EdgePath[I]) do
      write('(', V1.Index, ', ', V2.Index, ') ');
    writeln;
  finally
    G.Free;
    EdgePath.Free;
  end;
end;

begin
  Test;
  write('Press Return to continue...');
  readln;
end.
