unit TestPlanar;

interface

uses
  ExtGraph, Graphs, Planar;

procedure Test;

implementation

procedure Test;
var
  G: TGraph;

  procedure TestGraph(const Msg: String);
  begin
    write(Msg + ': ');
    writeln(PlanarGraph(G));
  end;

begin
  writeln('*** Planarity Detection ***');
  G:=TGraph.Create;
  try
    With G.AddEdge(G.AddVertex, G.AddVertex) do begin
      TestGraph('K2');
      G.AddEdge(V1, G.AddEdge(V2, G.AddVertex).V2);
    end;
    TestGraph('K3');
    G.AddVertices(2);
    TestGraph('K3 + 2 vertices');
    G.Clear;
    G.AddVertices(16);
    G.AddEdges([0, 1,  0, 11,  1, 2,  1, 15,  2, 3,  2, 15,  3, 4,  3, 6,
      4, 5,  4, 14,  5, 6,  5, 7,  6, 7,  7, 8,  8, 9,  8, 14,  9, 10,  9, 15,
      10, 11,  10, 13,  11, 12,  12, 13,  12, 14,  13, 14]);
    TestGraph('Graph from J.Hopcroft and R.Tarjan article "Efficient Planarity Testing"');
    GetCompleteGraph(G, 5);
    TestGraph('K5');
    G.AddEdgeI(0, 2); { параллельное ребро }
    G.GetEdgeI(0, 1).Free;
    TestGraph('K5\{one edge}');
    GetCompleteGraph(G, 6);
    TestGraph('K6');
    G.Edges[0].Free;
    TestGraph('K6\{one edge}');
    GetCompleteBipartiteGraph(G, 3);
    TestGraph('B33');
    G.Edges[0].Free;
    TestGraph('B33\{one edge}');
    G.AddEdgeI(0, 0); { петля }
    GetCompleteBipartiteGraph(G, 4);
    TestGraph('B44');
    G.Edges[0].Free;
    TestGraph('B44\{one edge}');
    GetCompleteGraph(G, 200);
    TestGraph('K200');
  finally
    G.Free;
  end;
end;

end.
