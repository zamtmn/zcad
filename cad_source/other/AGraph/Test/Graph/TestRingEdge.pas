unit TestRingEdge;

interface

uses
  Graphs;

procedure Test;

implementation

procedure Test;
var
  G: TGraph;

  procedure ShowEdges;
  var
    I: Integer;
  begin
    writeln('Directed: ', Directed in G.Features);
    for I:=0 to G.EdgeCount - 1 do With G.Edges[I] do
      writeln('(', V1.Index, ', ', V2.Index, '): ', RingEdge);
  end;

begin
  writeln('*** Test Ring Edges ***'#10);
  G:=TGraph.Create;
  try
    G.AddVertices(6);
    G.AddEdges([0, 2,  1, 4,  1, 2,  2, 3,  3, 1,  3, 4,  4, 5,  5, 5]);
    ShowEdges;
    G.Features:=[Directed];
    ShowEdges;
  finally
    G.Free;
  end;
end;

end.