unit TestPostman;
{
 См.: "Н.Кристофидес. Теория графов. Алгоритмический подход. М., Мир, 1978 г.";
 с.233-236.
}

interface

uses
  ExtType,
  Graphs,
  Pointerv,
  Postman;

procedure Test;

implementation

procedure Test;
var
  G: TGraph;
  EdgePath: TClassList;
  LastVertex, V: TVertex;
  I: Integer;
  Sum: Float;
begin
  writeln('*** Chinese Postman Problem ***');
  G:=TGraph.Create;
  EdgePath:=TClassList.Create;
  try
    G.Features:=[Weighted];
    G.AddVertices(12);
    G.AddEdges([0, 1,  0, 3,  0, 6,  0, 9,  0, 11,  1, 2,  1, 3,  1, 8,  2, 3,
      2, 4,  4, 5,  4, 11,  4, 10,  5, 6,  5, 11,  6, 7,  7, 9,  7, 10,  8, 9,
      8, 10,  9, 10,  6, 11]);
    G.Edges[0].Weight:=13;
    G.Edges[1].Weight:=17;
    G.Edges[2].Weight:=19;
    G.Edges[3].Weight:=19;
    G.Edges[4].Weight:=4;
    G.Edges[5].Weight:=18;
    G.Edges[6].Weight:=9;
    G.Edges[7].Weight:=2;
    G.Edges[8].Weight:=20;
    G.Edges[9].Weight:=5;
    G.Edges[10].Weight:=7;
    G.Edges[11].Weight:=11;
    G.Edges[12].Weight:=20;
    G.Edges[13].Weight:=4;
    G.Edges[14].Weight:=3;
    G.Edges[15].Weight:=8;
    G.Edges[16].Weight:=3;
    G.Edges[17].Weight:=10;
    G.Edges[18].Weight:=16;
    G.Edges[19].Weight:=14;
    G.Edges[20].Weight:=12;
    G.Edges[21].Weight:=18;
    writeln(SolvePostmanProblem(G, G[0], EdgePath));
    Sum:=0;
    LastVertex:=G[0];
    for I:=0 to EdgePath.Count - 1 do With TEdge(EdgePath[I]) do begin
      Sum:=Sum + Weight;
      if LastVertex = V1 then V:=V2 else V:=V1;
      write('(', LastVertex.Index, ', ', V.Index, ') ');
      LastVertex:=V;
    end;
    writeln;
    if Sum <> 294 then begin
      write('Error!');
      readln;
      Exit;
    end;
    writeln('Sum = ', Sum :4:2);
  finally
    G.Free;
    EdgePath.Free;
  end;
end;

end.
