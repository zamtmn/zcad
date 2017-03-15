unit TestMaxFlow;

interface

uses
  ExtType, Graphs;

procedure Test;

implementation

procedure Test;
var
  G: TGraph;
  I: Integer;
  Flow: Float;
begin
  writeln('*** Max Flow in Network ***');
  G:=TGraph.Create;
  try
    G.Features:=[Network];
    G.AddVertices(6);
    G.AddEdges([0, 1,  1, 2,  0, 4,  2, 3,  2, 5,  4, 3,  4, 5,  3, 5]);
    G.Edges[0].MaxFlow:=5;
    G.Edges[1].MaxFlow:=7;
    G.Edges[2].MaxFlow:=6;
    G.Edges[3].MaxFlow:=3;
    G.Edges[4].MaxFlow:=2;
    G.Edges[5].MaxFlow:=2;
    G.Edges[6].MaxFlow:=3;
    G.Edges[7].MaxFlow:=4;
    G.NetworkSource:=G[0];
    G.NetworkSink:=G[5];
    Flow:=G.FindMaxFlowThroughNetwork;
    if Flow <> 9 then begin
      write('Error!');
      readln;
      Exit;
    end;
    writeln('MaxFlow: ', Flow :0:2);
    for I:=0 to G.EdgeCount - 1 do With G.Edges[I] do
      writeln('(', V1.Index, ', ', V2.Index, '): ', Flow :0:2);
  finally
    G.Free;
  end;
end;

end.
