{ Version 050603. Copyright © Alexey A.Chernobaev, 1996-2005 }

unit GrColor;

interface

{$I VCheck.inc}

uses
  {$IFDEF V_INLINE}Pointerv,{$ENDIF}
  ExtType, Aliasv, Int16g, Int16v, Graphs, CTrick, VectErr;

function GraphColoring(G: TGraph; Colors: TGenericIntegerVector): Integer;
{ Находит некоторую оптимальную раскраску графа G, т.е. сопоставляет вершинам
  графа цвета (неотрицательные целые числа) так, чтобы ни одна пара смежных
  вершин не получила одинаковые цвета, а количество использованных цветов было
  минимальным. Функция возвращает хроматическое число графа; если Colors <> nil,
  то Colors[I] = <цвет I-й вершины в найденной раскраске> (начиная с 0). }

function ApproximateColoring1(G: TGraph; Colors: TGenericIntegerVector): Integer;
{ простой эмпирический метод раскраски; вектор Colors не может быть равен nil }

function CheckColoring(G: TGraph; Colors: TGenericIntegerVector): Bool;
{ проверяет раскраску графа G, заданную вектором Colors }

implementation

function GraphColoring(G: TGraph; Colors: TGenericIntegerVector): Integer;
var
  I, J, K, N: Integer;
  V: TVertex;
  Component: TGraph;
  ComponentColors, VertexMap: TIntegerVector;
  OldFeatures: TGraphFeatures;
begin
  N:=G.SeparateCount;
  if N = 1 then begin
    OldFeatures:=G.Features;
    G.Features:=OldFeatures - [Directed];
    try
      Result:=ColorConnectedGraph(G, Colors);
    finally
      G.Features:=OldFeatures;
    end;
  end
  else if N > 1 then begin
    Component:=TGraph.Create;
    VertexMap:=nil;
    ComponentColors:=nil;
    try
      if Colors <> nil then begin
        J:=G.VertexCount;
        Colors.Count:=J;
        VertexMap:=TIntegerVector.Create(J, 0);
        ComponentColors:=TIntegerVector.Create(0, 0);
      end;
      Result:=0;
      J:=0;
      for I:=0 to G.VertexCount - 1 do begin
        V:=G[I];
        if V.SeparateIndex = J then begin
          Component.GetSeparateOf(G, V);
          if Colors <> nil then
            for K:=0 to Component.VertexCount - 1 do
              VertexMap[K]:=Component[K].Temp.AsInt32;
          K:=ColorConnectedGraph(Component, ComponentColors);
          if K > Result then Result:=K;
          if Colors <> nil then
            for K:=0 to ComponentColors.Count - 1 do
              Colors[VertexMap[K]]:=ComponentColors[K];
          Inc(J);
          if J = N then Break;
        end;
      end;
    finally
      Component.Free;
      VertexMap.Free;
      ComponentColors.Free;
    end;
  end
  else begin
    Result:=0;
    if Colors <> nil then Colors.Clear;
  end;
end;

function ApproximateColoring1(G: TGraph; Colors: TGenericIntegerVector): Integer;
var
  I, J, N, VertexIndex, NumColored: Integer;
  CanColor: Bool;
  Indexes, Degrees: TIntegerVector;
begin
  N:=G.VertexCount;
  Indexes:=TIntegerVector.Create(N, 0);
  Degrees:=nil;
  try
    { сортируем вершины по убыванию степеней вершин }
    Indexes.ArithmeticProgression(0, 1);
    Degrees:=G.CreateDegreesVector;
    Degrees.SortDescWith(Indexes);
    Result:=0;
    Colors.Count:=N;
    Colors.FillValue(-1);
    NumColored:=0;
    { "раскрашиваем" вершины }
    while NumColored < N do begin
      for I:=0 to N - 1 do begin
        VertexIndex:=Indexes[I];
        With G[VertexIndex] do
          if Colors[VertexIndex] < 0 then begin
            CanColor:=True;
            for J:=0 to Degree - 1 do
              if Colors[Neighbour[J].Index] = Result then begin
                CanColor:=False;
                Break;
              end;
            if CanColor then begin
              Colors[VertexIndex]:=Result;
              Inc(NumColored);
            end;
          end;
      end;
      Inc(Result);
    end;
  finally
    Indexes.Free;
    Degrees.Free;
  end;
end;

function CheckColoring(G: TGraph; Colors: TGenericIntegerVector): Bool;
var
  I: Integer;
begin
  for I:=0 to G.EdgeCount - 1 do
    With G.Edges[I] do
      if (V1.Index <> V2.Index) and (Colors[V1.Index] = Colors[V2.Index]) then begin
        Result:=False;
        Exit;
      end;
  Result:=True;
end;

end.
