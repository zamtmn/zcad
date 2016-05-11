unit TestSST;

interface

uses
  ExtType,
  Graphs;

procedure Test;

implementation

procedure Test;
var
  G, SST: TGraph;
  I: Integer;
  T: Float;
begin
  writeln('*** SST ***');
  G:=TGraph.Create;
  SST:=TGraph.Create;
  G.Features:=[Weighted];
  try
    G.AddVertices(6);
    G.AddEdges([0, 2,  0, 3,  0, 4,  0, 5,  1, 2,  1, 3,  1, 5,  2, 4,  3, 4]);
    G.Edges[0].Weight:=5;
    G.Edges[1].Weight:=6;
    G.Edges[2].Weight:=2;
    G.Edges[3].Weight:=12;
    G.Edges[4].Weight:=2;
    G.Edges[5].Weight:=3;
    G.Edges[6].Weight:=2;
    G.Edges[7].Weight:=1;
    G.Edges[8].Weight:=4;
    T:=SST.GetShortestSpanningTreeOf(G);
    if T <> 10 then begin
      write('Error!');
      readln;
      Exit;
    end;
    writeln('SST Weight: ', T :4:2);
    writeln('SST Edges: ');
    for I:=0 to SST.EdgeCount - 1 do With SST.Edges[I] do
      writeln(Temp.AsInt32, ' (', V1.Index, ', ', V2.Index, '); Weight: ',
        Weight :4:2);
  finally
    G.Free;
    SST.Free;
  end;
end;

end.
 
