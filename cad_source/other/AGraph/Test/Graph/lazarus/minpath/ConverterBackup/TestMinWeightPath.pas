unit TestMinWeightPath;

{$MODE Delphi}

interface

uses
  ExtType,
  Pointerv,
  Graphs;

procedure Test;

implementation

procedure Test;
var
  G: TGraph;
  EdgePath, VertexPath: TClassList;
  I: Integer;
  T: Float;
begin
  writeln('*** Min Weight Path ***');
  G:=TGraph.Create;
  G.Features:=[Weighted];
  EdgePath:=TClassList.Create;
  VertexPath:=TClassList.Create;
  try
    G.AddVertices(7);
    G.AddEdges([0, 2,  0, 3,  0, 4,  0, 5,  1, 2,  1, 3,  1, 5,  2, 4,  3, 4,
      5, 6]);
    G.Edges[0].Weight:=5;
    G.Edges[1].Weight:=7;
    G.Edges[2].Weight:=2;
    G.Edges[3].Weight:=12;
    G.Edges[4].Weight:=2;
    G.Edges[5].Weight:=3;
    G.Edges[6].Weight:=2;
    G.Edges[7].Weight:=1;
    G.Edges[8].Weight:=2;
    G.Edges[9].Weight:=4;
    T:=G.FindMinWeightPath(G[0], G[6], EdgePath);
    if T <> 11 then begin
      write('Error!');
      readln;
      Exit;
    end;
    writeln('Minimal Length: ', T :4:2);
    G.EdgePathToVertexPath(G[0], EdgePath, VertexPath);
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

end.
