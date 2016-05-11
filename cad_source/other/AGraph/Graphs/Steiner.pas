{ Version 030515. Copyright © Alexey A.Chernobaev, 1996-2003 }
{
  Находит приближенное решение задачи Штейнера (задачи построения кратчайшего
  дерева, покрывающего заданное подмножество вершин графа).

  Используется алгоритм, описанный в "L.Kou, G.Markowsky and L.Berman. A fast
  algorithm for steiner trees, Acta Informatica, 15, pp.141-145, 1981".
  Источник: "Samir Kuller. Design and Analysis of Algorithms: Course Notes.
  University of Maryland, 1996".

  Ограничение: допускаются только неотрицательные веса ребер.
}

unit Steiner;

interface

{$I VCheck.inc}

uses
  ExtType, AttrType, Aliasv, Int16v, Boolv, Pointerv, Graphs, ExtGraph, VectErr;

function ApproximateSteinerTree(G: TGraph; SteinerVertices,
  SteinerTreeEdges: TClassList): Float;
{
  Находит приближенное решение задачи Штейнера (задачи построения кратчайшего
  дерева, покрывающего заданное подмножество вершин графа) для графов с
  неотрицательными весами ребер. Доказано, что длина получаемого дерева
  не более чем в два раза превосходит длину точного решения.
  На входе: G - взвешенный граф, SteinerVertices - вершины графа G, которые
  должны входить в искомое дерево. На выходе: если SteinerTreeEdges <> nil, то
  в SteinerTreeEdges возвращаются ребра G, входящие в найденное дерево.
  Результат функции равен длине дерева.
}

implementation

function ApproximateSteinerTree(G: TGraph; SteinerVertices,
  SteinerTreeEdges: TClassList): Float;
const
  AttrEdgeIndex = 'I';
var
  I, J, IndexOffset: Integer;
  H: TGraph;
  E: TEdge;
  SSTList, EdgeList: TClassList;
  CopyVertexToGS, CopyEdgeToGS: TBoolVector;
  VertexMap: TIntegerVector;
begin
  if not G.Connected then TGraph.Error(SMethodNotApplicable, [0]);
  H:=TGraph.Create;
  try
    { строим полный граф H на вершинах SteinerVertices; веса ребер H равны
      длинам кратчайших путей между соответствующими вершинами графа G }
    GetCompleteGraph(H, SteinerVertices.Count);
    H.Features:=[Weighted];
    for I:=0 to H.EdgeCount - 1 do begin
      E:=H.Edges[I];
      E.Weight:=G.FindMinWeightPathCond(SteinerVertices[E.V1.Index],
        SteinerVertices[E.V2.Index], nil, nil, nil);
    end;
    SSTList:=TClassList.Create;
    try
      { находим кратчайшее остовное дерево в H }
      H.FindShortestSpanningTree(SSTList);
      CopyVertexToGS:=nil;
      CopyEdgeToGS:=nil;
      EdgeList:=nil;
      VertexMap:=nil;
      try
        { помечаем в G вершины и ребра, входящие в GS }
        CopyVertexToGS:=TBoolVector.Create(G.VertexCount, False);
        CopyEdgeToGS:=TBoolVector.Create(G.EdgeCount, False);
        EdgeList:=TClassList.Create;
        for I:=0 to SteinerVertices.Count - 1 do
          CopyVertexToGS[TVertex(SteinerVertices[I]).Index]:=True;
        for I:=0 to SSTList.Count - 1 do begin
          With TEdge(SSTList[I]) do
            G.FindMinWeightPathCond(SteinerVertices[V1.Index],
              SteinerVertices[V2.Index], nil, nil, EdgeList);
          for J:=0 to EdgeList.Count - 1 do With TEdge(EdgeList[J]) do begin
            CopyVertexToGS[V1.Index]:=True;
            CopyVertexToGS[V2.Index]:=True;
            CopyEdgeToGS[Index]:=True;
          end;
        end;
        { строим подграф GS графа G, содержащий все вершины SteinerVertices,
          а также все вершины и ребра, входящие в те минимальные пути между
          вершинами G, которые соответствуют ребрам SST(H); поскольку старый
          граф H более не нужен, для хранения GS используем тот же объект H }
        H.Clear;
        IndexOffset:=H.CreateEdgeAttr(AttrEdgeIndex, AttrPointer);
        H.AddVertices(CopyVertexToGS.NumTrue);
        VertexMap:=TIntegerVector.Create(G.VertexCount, -1);
        J:=0;
        for I:=0 to G.VertexCount - 1 do
          if CopyVertexToGS[I] then begin
            VertexMap[I]:=J;
            Inc(J);
          end;
        for I:=0 to G.EdgeCount - 1 do begin
          E:=G.Edges[I];
          if CopyEdgeToGS[I] then
            With H.AddEdgeI(VertexMap[E.V1.Index], VertexMap[E.V2.Index]) do begin
              Weight:=E.Weight;
              AsPointerByOfs[IndexOffset]:=E;
            end;
        end;
        { результатом является кратчайшее остовное дерево GS }
        if SteinerTreeEdges <> nil then begin
          Result:=H.FindShortestSpanningTree(SSTList);
          SteinerTreeEdges.Count:=SSTList.Count;
          for I:=0 to SSTList.Count - 1 do
            SteinerTreeEdges[I]:=TEdge(SSTList[I]).AsPointerByOfs[IndexOffset];
        end
        else
          Result:=H.FindShortestSpanningTree(nil);
      finally
        CopyVertexToGS.Free;
        CopyEdgeToGS.Free;
        EdgeList.Free;
        VertexMap.Free;
      end;
    finally
      SSTList.Free;
    end;
  finally
    H.Free;
  end;
end;

end.
