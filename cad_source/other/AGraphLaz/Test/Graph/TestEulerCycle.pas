unit TestEulerCycle;

interface

uses
  Graphs,
  Pointerv,
  EulerCyc;

procedure Test;

implementation

procedure Test;
var
  G: TGraph;
  EdgePath, VertexPath: TClassList;
  I: Integer;
begin
  writeln('*** Eulerian Cycle ***');
  G:=TGraph.Create;
  EdgePath:=TClassList.Create;
  VertexPath:=TClassList.Create;
  try
    G.AddVertices(8);
    G.AddEdges([0, 1,  0, 2,  1, 2,  2, 4,  4, 6,  4, 5,  5, 6,  6, 7,  7, 4,
      0, 3,  3, 2, 0, 6]);
    writeln(FindEulerCycle(G, G.Vertices[0], EdgePath));
    if G.EdgePathToVertexPath(G.Vertices[0], EdgePath, VertexPath) then
      for I:=0 to VertexPath.Count - 1 do With TVertex(VertexPath[I]) do
        write(Index, ' ');
    writeln;
  finally
    G.Free;
    EdgePath.Free;
    VertexPath.Free;
  end;
end;

end.
