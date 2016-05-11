unit TestAtilla;

interface

uses
  Graphs,
  Pointerv,
  MultiLst,
  HamilCyc;

procedure Test;

implementation

procedure Test;
const
  N = 8;
  CyclesToFound = 1;
var
  G: TGraph;
  EdgePaths: TMultiList;
  EdgePath, VertexPath: TClassList;
  V: TVertex;
  I, J: Integer;

  procedure AddArcs(I, J, K, L: Integer);
  begin
    if (K in [0..N - 1]) and (L in [0..N - 1]) then
      G.AddEdge(G[I * N + J], G[K * N + L]);
  end;

  function IndexToChess(I: Integer): String;
  begin
    Result:=Chr((I mod N) + Ord('a')) + Chr((I div N) + Ord('1'));
  end;

begin
  writeln('*** Atilla Cycle (Chess Knight Hamiltonian Cycle on the ', N, 'x', N, ' Board) ***');
  G:=TGraph.Create;
  G.Features:=[Directed];
  EdgePaths:=TMultiList.Create(TClassList);
  VertexPath:=TClassList.Create;
  try
    G.AddVertices(N * N);
    for I:=0 to N - 1 do
      for J:=0 to N - 1 do begin
        AddArcs(I, J, I - 2, J - 1);
        AddArcs(I, J, I - 2, J + 1);
        AddArcs(I, J, I - 1, J - 2);
        AddArcs(I, J, I - 1, J + 2);
        AddArcs(I, J, I + 1, J - 2);
        AddArcs(I, J, I + 1, J + 2);
        AddArcs(I, J, I + 2, J - 1);
        AddArcs(I, J, I + 2, J + 1);
      end;
    if FindHamiltonCycles(G, G[0], CyclesToFound, EdgePaths) > 0 then
      for I:=0 to EdgePaths.Count - 1 do begin
        writeln('Cycle ', I + 1);
        EdgePath:=EdgePaths[I];
        G.EdgePathToVertexPath(G[0], EdgePath, VertexPath);
        for J:=0 to VertexPath.Count - 1 do begin
          V:=TVertex(VertexPath[J]);
          write(IndexToChess(V.Index), ' ');
        end;
        writeln;
      end;
  finally
    G.Free;
    EdgePaths.Free;
    VertexPath.Free;
  end;
end;

end.
