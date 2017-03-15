{ Version 000602. Copyright © Alexey A.Chernobaev, 1996-2000 }

{ This code is partly based on LEDA-R-3.7.1 code (file src/_five_color.c).
  According to license terms, "the RESEARCH version (LEDA-R) of LEDA... can be
  used free of charge for academic research and teaching". LEDA home page:
  http://www.mpi-sb.mpg.de/LEDA. }

unit MapColor;

interface

{$I VCheck.inc}

uses
  ExtType, Aliasv, Int16g, Int16v, Boolv, Pointerv, MultiLst, PStack, Graphs,
  GraphErr;

function MapFiveColoring(G: TGraph; Colors: TGenericIntegerVector): Integer;
{ Находит некоторую раскраску планарного графа G без петель и кратных ребер
  не более чем в 5 цветов. Функция применима также ко многим непланарным графам;
  если функция не применима, то возбуждается исключение. Функция возвращает
  реальное количество использованных цветов; если Colors <> nil, то Colors[I] =
  <цвет I-й вершины в найденной раскраске> (начиная с 0).
  Примечание: даже в случае планарных графов раскраска не обязательно является
  оптимальной! }

implementation

function MapFiveColoring(G: TGraph; Colors: TGenericIntegerVector): Integer;
var
  V, U, W: TVertex;
  C1: TIntegerVector;

  procedure FindIndependentNeighbours;
  { на входе: V, C1; на выходе: U, W; находит среди соседей вершины V степени 5
    вершины U и W, которые, во-первых, не "уничтожены" (C1[I] <> -1), и,
    во-вторых, не инцидентны }
  var
    I, J, K, L: Integer;
    Independent: Bool;
    X: TVertex;
    Neighbours: array [0..5] of TVertex;
  begin
    L:=0;
    for I:=0 to V.Degree - 1 do begin
      X:=V.Neighbour[I];
      if C1[X.Index] <> -1 then begin
        Neighbours[L]:=X;
        Inc(L);
      end;
    end;
    Dec(L);
    for I:=0 to L do begin
      U:=Neighbours[I];
      for J:=I + 1 to L do begin
        W:=Neighbours[J];
        Independent:=True;
        for K:=0 to W.Degree - 1 do
          if W.Neighbour[K] = U then begin
            Independent:=False;
            Break;
          end;
        if Independent then Exit;
      end;
    end;
    TGraph.Error(SGraphNotPlanar{, [0]});
  end;

var
  I, J, N: Integer;
  X: TVertex;
  G1: TGraph;
  Degrees: TIntegerVector;
  Removed: TPointerStack;
  SmallDeg: TClassList;
  InSmallDeg, Mark: TBoolVector;
  L: TMultiList;
  Used: array [0..5] of Bool;
begin
  Result:=0;
  N:=G.VertexCount;
  G1:=TGraph.Create;
  Degrees:=nil;
  C1:=nil;
  Removed:=nil;
  SmallDeg:=nil;
  InSmallDeg:=nil;
  Mark:=nil;
  L:=nil;
  try
    Degrees:=G.CreateDegreesVector;
    C1:=TIntegerVector.Create(N, 0);
    Removed:=TPointerStack.Create;
    SmallDeg:=TClassList.Create;
    InSmallDeg:=TBoolVector.Create(N, False);
    Mark:=TBoolVector.Create(N, False);
    L:=TMultiList.Create(TClassList);
    L.Count:=N;
    G1.AssignSimpleSceleton(G);
    SmallDeg.Capacity:=N;
    { SmallDeg: список вершин степени <= 5; L[I] - список вершин графа G,
      соответствующих I-й вершине графа G1 }
    for I:=0 to N - 1 do begin
      V:=G1[I];
      if Degrees[I] <= 5 then begin
        SmallDeg.Add(V);
        InSmallDeg[V.Index]:=True;
      end;
      L[V.Index].Add(G[I]);
    end;
    while N > 0 do begin
      if SmallDeg.Count = 0 then TGraph.Error(SGraphNotPlanar{, [0]});
      V:=SmallDeg.Pop;
      if Degrees[V.Index] = 5 then begin
        FindIndependentNeighbours;
        if U = W then TGraph.Error(SGraphNotPlanar{, [0]});
        for I:=0 to U.Degree - 1 do
          Mark[U.Neighbour[I].Index]:=True;
        for I:=0 to W.Degree - 1 do begin
          X:=W.Neighbour[I];
          if Mark[X.Index] then begin
            Degrees.DecItem(X.Index, 1);
            if Degrees[X.Index] = 5 then begin
              SmallDeg.Add(X);
              InSmallDeg[X.Index]:=True;
            end;
          end
          else begin
            G1.AddEdge(U, X);
            if C1[X.Index] <> -1 then Degrees.IncItem(U.Index, 1);
          end;
        end;
        for I:=0 to U.Degree - 1 do
          Mark[U.Neighbour[I].Index]:=False;
        Degrees.DecItem(V.Index, 1);
        if (Degrees[U.Index] > 5) and InSmallDeg[U.Index] then begin
          SmallDeg.Remove(U);
          InSmallDeg[U.Index]:=False;
        end;
        L[U.Index].ConcatenateWith(L[W.Index]);
        if InSmallDeg[W.Index] then SmallDeg.Remove(W);
        for I:=W.Degree - 1 downto 0 do
          W.IncidentEdge[I].Free;
        Dec(N);
      end;
      { степень V меньше 5 }
      C1[V.Index]:=-1;
      Removed.Push(V);
      for I:=0 to V.Degree - 1 do begin
        X:=V.Neighbour[I];
        J:=Degrees[X.Index] - 1;
        Degrees[X.Index]:=J;
        if J = 5 then begin
          SmallDeg.Add(X);
          InSmallDeg[X.Index]:=True;
        end;
      end;
      Dec(N);
    end;
    if Colors <> nil then Colors.Count:=G.VertexCount;
    while not Removed.IsEmpty do begin
      V:=Removed.Pop;
      for I:=0 to 5 do Used[I]:=False;
      for I:=0 to V.Degree - 1 do begin
        X:=V.Neighbour[I];
        J:=C1[X.Index];
        if J <> -1 then Used[J]:=True;
      end;
      J:=0;
      while Used[J] do Inc(J);
      if J >= 5 then TGraph.Error(SGraphNotPlanar{, [0]});
      if J > Result then Result:=J;
      C1[V.Index]:=J;
      if Colors <> nil then With L[V.Index] do
        for I:=0 to Count - 1 do
          Colors[TVertex(Items[I]).Index]:=J;
    end;
  finally
    G1.Free;
    Degrees.Free;
    C1.Free;
    Removed.Free;
    SmallDeg.Free;
    InSmallDeg.Free;
    Mark.Free;
    L.Free;
  end;
  Inc(Result);
end;

end.
