{$APPTYPE CONSOLE}
uses
  Int32v, Pointerv, Graphs;
var
  G: TGraph;
  I, J: Integer;
  NewRing: Boolean;
  Ring, Rings: TClassList;
  ArcIndexes: TInt32Vector;
begin
  G:=TGraph.Create;
  G.Features:=[Directed]; // граф будет ориентированным
  G.AddVertices(4); // добавляем 4 вершины
  // добавляем дуги (направление - от первого параметра ко второму)
  G.AddEdgeI(0,1);
  G.AddEdgeI(1,2);
  G.AddEdgeI(2,3);
  G.AddEdgeI(3,0);
  G.AddEdgeI(0,2);
  Ring:=TClassList.Create;
  Rings:=TClassList.Create;
  for I:=0 to G.VertexCount - 1 do
    if G.FindMinRing(G.Vertices[I], Ring) > 0 then begin
      // проверяем, что Ring не был найден ранее, и если да, то выводим
      ArcIndexes:=TInt32Vector.Create(Ring.Count, 0);
      for J:=0 to Ring.Count - 1 do
        ArcIndexes[J]:=TEdge(Ring[J]).Index;
      ArcIndexes.Sort;
      NewRing:=True;
      for J:=0 to Rings.Count - 1 do
        if TInt32Vector(Rings[J]).EqualTo(ArcIndexes) then begin
          NewRing:=False;
          Break;
        end;
      if NewRing then begin
        Rings.Add(ArcIndexes); // запоминаем вектор, однозначно кодирующий контур
        // выводим контур
        for J:=0 to Ring.Count - 1 do
          write(TEdge(Ring[J]).V1.Index, ' ');
        write(TEdge(Ring[Ring.Count - 1]).V2.Index, ' ');
        writeln;
      end
      else
        ArcIndexes.Free;
    end;
  Rings.FreeItems;
  Rings.Free;
  Ring.Free;
  G.Free;
  write('Press Enter');readln;
end.
