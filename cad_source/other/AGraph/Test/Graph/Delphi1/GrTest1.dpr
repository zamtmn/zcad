program GrTest1;

uses
  Pointerv,
  Graphs,
  WinCrt;

procedure Test;
var
  G: TGraph;
  EdgePath, VertexPath: TClassList;
  I: Integer;
begin
  G:=TGraph.Create;
  G.Features:=[Weighted];
  EdgePath:=TClassList.Create;
  VertexPath:=TClassList.Create;
  try
    G.AddVertices(6);
    G.AddEdges([0, 2,  0, 3,  0, 4,  0, 5,  1, 2,  1, 3,  1, 5,  2, 4,  3, 4]);
    G.Edges[0].Weight:=5;
    G.Edges[1].Weight:=5;
    G.Edges[2].Weight:=2;
    G.Edges[3].Weight:=12;
    G.Edges[4].Weight:=2;
    G.Edges[5].Weight:=2;
    G.Edges[6].Weight:=2;
    G.Edges[7].Weight:=1;
    G.Edges[8].Weight:=2;
    writeln('Minimal Length: ',
      G.FindMinWeightPath(G.Vertices[0], G.Vertices[5], EdgePath) :4:2);
    G.EdgePathToVertexPath(G.Vertices[0], EdgePath, VertexPath);
    write('Vertices: ');
    for I:=0 to VertexPath.Count - 1 do
      write(TVertex(VertexPath[I]).Index, ' ');
    writeln;
  finally
    G.Free;
    EdgePath.Free;
    VertexPath.Free;
  end;
end;

begin
  Test;
  write('Press Return to continue...');
  readln;
end.
