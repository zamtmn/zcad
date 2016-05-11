{ Version 050625. Copyright © Alexey A.Chernobaev, 1996-2005 }

unit Postman;

interface

{$I VCheck.inc}

uses
  {$IFDEF V_INLINE}Vectors,{$ENDIF}
  ExtType, AttrType, Graphs, F32v, F64v, F80v, Boolv, Boolm, Int16v, Aliasv,
  Pointerv, MultiLst, EulerCyc, Optimize, VectErr;

function SolvePostmanProblem(G: TGraph; FromVertex: TVertex; EdgePath: TClassList): Bool;
{
  Решает задачу почтальона для взвешенного графа G с неотрицательными весами
  ребер (граф всегда интерпретируется как неориентированный), начиная с вершины
  FromVertex.

  Задача почтальона: найти замкнутый маршрут, проходящий через каждое ребро
  графа по крайней мере один раз и такой, что суммарный вес входящих в него
  ребер минимален (если у графа существует хотя бы один эйлеров цикл, то он
  является решением данной задачи, т.к. каждое ребро графа входит в эйлеров
  цикл ровно один раз).

  Если решение найдено (решение существует тогда и только тогда, когда граф
  связен), то функция возвращает True и помещает в EdgePath ребра графа в той
  последовательности, в которой они входят в цикл; иначе возвращается False.
}

implementation

function SolvePostmanProblem(G: TGraph; FromVertex: TVertex; EdgePath: TClassList): Bool;
const
  OddVertexIndex = 'Postman1';
  OrigEdgePtr = 'Postman2';
var
  OddVertices {X-}, NewEdges: TClassList;
  I, J, K, M, N, Offset, OddVertexIndexOfs, OrigEdgePtrOfs: Integer;
  V: TVertex;
  E1, E2: TEdge;
  Matrix: TBoolMatrix;
  EdgePaths: TMultiList;
  MinDistances: TFloatVector;
  MinCovering: TIntegerVector;
  Sum: Float;
begin
  {$IFDEF CHECK_GRAPHS}
  for I:=0 to G.EdgeCount - 1 do
    if G.Edges[I].Weight < 0 then TGraph.Error(SMethodNotApplicable);
  {$ENDIF}
  Result:=G.Connected;
  if Result and not FindEulerCycle(G, FromVertex, EdgePath) then begin
    { ищем вершины нечетной степени; они существуют, т.к. иначе существовал бы
      эйлеров цикл }
    OddVertices:=TClassList.Create;
    try
      for I:=0 to G.VertexCount - 1 do begin
        V:=G[I];
        if Odd(V.Degree) then OddVertices.Add(V);
      end;
      M:=OddVertices.Count;
      N:=M * (M - 1) div 2;
      Matrix:=TBoolMatrix.Create(M, N, False);
      EdgePaths:=nil;
      MinDistances:=nil;
      MinCovering:=nil;
      NewEdges:=nil;
      try
        EdgePaths:=TMultiList.Create(TClassList);
        MinDistances:=TFloatVector.Create(N, 0);
        MinCovering:=TIntegerVector.Create(0, 0);
        NewEdges:=TClassList.Create;
        OddVertexIndexOfs:=G.CreateVertexAttr(OddVertexIndex, AttrInt32);
        OrigEdgePtrOfs:=G.CreateEdgeAttr(OrigEdgePtr, AttrPointer);
        EdgePaths.Count:=N;
        Offset:=0;
        { находим кратчайшие пути между каждой парой вершин нечетных степеней }
        for I:=0 to M - 1 do begin
          TVertex(OddVertices[I]).AsInt32ByOfs[OddVertexIndexOfs]:=I + 1;
          for J:=I + 1 to M - 1 do begin
            MinDistances[Offset]:=G.FindMinWeightPath(TVertex(OddVertices[I]),
              TVertex(OddVertices[J]), EdgePaths[Offset]);
            Inc(Offset);
          end;
        end;
        { ищем цепное паросочетание минимального веса путем покрытия булевской
          матрицы размерности M*N, элемент (i, j) которой равен True <=>
          вершина нечетной степени i входит в кратчайший путь j между некоторой
          парой вершин }
        for I:=0 to N - 1 do With EdgePaths[I] do
          for J:=0 to Count - 1 do With TEdge(Items[J]) do begin
            K:=V1.AsInt32ByOfs[OddVertexIndexOfs] - 1;
            if K >= 0 then Matrix[K, I]:=True;
            K:=V2.AsInt32ByOfs[OddVertexIndexOfs] - 1;
            if K >= 0 then Matrix[K, I]:=True;
          end;
        FindMinWeightCovering(Matrix, MinDistances, MinCovering, Sum);
        { добавляем в граф ребра, входящие в найденные цепи }
        for I:=0 to MinCovering.Count - 1 do
          With EdgePaths[MinCovering[I]] do
            for J:=0 to Count - 1 do begin
              E1:=Items[J];
              E2:=G.AddEdge(E1.V1, E1.V2);
              E2.AsPointerByOfs[OrigEdgePtrOfs]:=E1;
              NewEdges.Add(E2);
            end;
        { решением является любой эйлеров цикл графа с добавленными ребрами }
        Result:=FindEulerCycle(G, FromVertex, EdgePath);
        { заменяем вновь добавленные ребра на исходные }
        for I:=0 to EdgePath.Count - 1 do begin
          E1:=TEdge(EdgePath[I]).AsPointerByOfs[OrigEdgePtrOfs];
          if E1 <> nil then EdgePath[I]:=E1;
        end;
        { уничтожаем добавленные ребра }
        NewEdges.FreeItems;
      finally
        Matrix.Free;
        EdgePaths.Free;
        MinDistances.Free;
        MinCovering.Free;
        NewEdges.Free;
        G.SafeDropVertexAttr(OddVertexIndex);
        G.SafeDropEdgeAttr(OrigEdgePtr);
      end;
    finally
      OddVertices.Free;
    end;
  end;
end;

end.
