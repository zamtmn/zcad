unit TestSteinerTree;

interface

uses
  ExtType,
  Pointerv,
  Graphs,
  Steiner;

procedure Test;

implementation

procedure Test;
var
  G: TGraph;
  I: Integer;
  T: Float;
  SteinerVertices, SteinerEdges: TClassList;
begin
  writeln('*** Approximate Steiner Tree ***');
  G:=TGraph.Create;
  SteinerVertices:=TClassList.Create;
  SteinerEdges:=TClassList.Create;
  try
    G.Features:=[Weighted];
    G.AddVertices(8);
    G.AddEdges([0, 1,  0, 4,  0, 5,  0, 7,  1, 2,  1, 4,  1, 6,  2, 3,  2, 4,
      3, 4,  3, 5,  4, 5]);
    G.Edges[0].Weight:=2;
    G.Edges[1].Weight:=7;
    G.Edges[2].Weight:=1;
    G.Edges[3].Weight:=0;
    G.Edges[4].Weight:=1;
    G.Edges[5].Weight:=4;
    G.Edges[6].Weight:=8;
    G.Edges[7].Weight:=5;
    G.Edges[8].Weight:=2;
    G.Edges[9].Weight:=2;
    G.Edges[10].Weight:=4;
    G.Edges[11].Weight:=3;
    SteinerVertices.Add(G[5]);
    SteinerVertices.Add(G[6]);
    SteinerVertices.Add(G[7]);
    T:=ApproximateSteinerTree(G, SteinerVertices, SteinerEdges);
    if T <> 11 then begin
      write('Error!');
      readln;
      Exit;
    end;
    writeln('Approximate Steiner Tree Weight: ', T :4:2);
    writeln('Tree Edges: ');
    for I:=0 to SteinerEdges.Count - 1 do With TEdge(SteinerEdges[I]) do
      writeln(Index, ' (', V1.Index, ', ', V2.Index, '); Weight: ',
        Weight :4:2);
  finally
    G.Free;
    SteinerVertices.Free;
    SteinerEdges.Free;
  end;
end;

end.

