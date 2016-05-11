unit Mycielski;

interface

uses
  Boolm, Graphs, Pointerv, MultiLst, MathErr, VectErr;

procedure GetMycielski(G: TGraph; ChromaticNumber: Integer);
{
  Строит граф Мыцельского для хроматического числа ChromaticNumber >=2. Граф
  Мыцельского - граф с произвольным хроматическим числом, плотность которого
  равна 2 (плотность графа - наибольшее количество вершин в максимальных полных
  подграфах, или, что то же самое, кликах, этого графа); существование таких
  графов служит опровержением "наивных" попыток доказательства гипотезы о
  четырех красках такого рода:
  "... а в чём собсна пpоблема? Если гpаф нельзя pаскpасить в 4 цвета, то в него
  входит P5 (полный 5-гpаф) => не выполнено необходимое условие планаpности =>
  для планаpности гpафа HЕОБХОДИМО, чтобы он pаскpашивался МАКСИМУМ в 4 цвета";
  здесь первое же утверждение неверно - P5 вовсе не обязан входить в такой граф.
}

implementation

procedure GetMycielski(G: TGraph; ChromaticNumber: Integer);

  procedure Build(N: Integer);
  var
    I, J, OldCount: Integer;
    LastVertex, OldVertex, NewVertex, Neighbour: TVertex;
  begin
    if N = 2 then G.AddEdge(G.AddVertex, G.AddVertex)
    else begin
      Build(N - 1);
      OldCount:=G.VertexCount;
      G.SetTempForVertices(-1);
      G.AddVertices(OldCount + 1);
      LastVertex:=G[2 * OldCount];
      for I:=OldCount to 2 * OldCount - 1 do begin
        OldVertex:=G[I - OldCount];
        NewVertex:=G[I];
        for J:=0 to OldVertex.Degree - 1 do begin
          Neighbour:=OldVertex.Neighbour[J];
          if Neighbour.Temp.AsInt32 = -1 then G.AddEdge(NewVertex, Neighbour);
        end;
        G.AddEdge(NewVertex, LastVertex);
      end;
    end;
  end;

begin
  G.Clear;
  if ChromaticNumber >= 2 then Build(ChromaticNumber)
  else MathError(SErrorInParameters, [0]);
end;

end.
