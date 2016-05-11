{ Version 030515. Copyright © Alexey A.Chernobaev, 1996-2003 }

unit ExtGraph;

interface

{$I VCheck.inc}

uses
  ExtType, AttrType, Boolv, Aliasv, Aliasm, Int16g, Int16v, Int16m, Int64g,
  Pointerv, Graphs;

function CreateCopy(G: TGraph; const AttrPtrName: String): TGraph;
{ создает граф, скелет которого совпадает со скелетом графа G, а вершины и ребра
  имеют единственный атрибут AttrPtrName типа AttrPointer, указывающий на
  соответствующую вершину (ребро) графа G; если G - ориентированный, то
  возвращаемый граф также будет ориентированным }

function EliminateParallelEdges(G: TGraph; CompareEdges: TCompareFunc;
  const AttrPtrName, AttrListName: String): Integer;
{ находит и удаляет все группы параллельных ребер в графе G - копии некоторого
  графа, созданного с помощью CreateCopy(..., AttrPtrName), заменяя каждую такую
  группу одним ребром с локальным атрибутом AttrListName типа AttrAutoFree,
  значением которого является отсортированный в соответствии с CompareEdges
  список указателей на ребра исходного графа, соответствующие удаленным кратным
  ребрам G; функция возвращает количество групп кратных ребер }

function CheckEmbedding(SubG, G: TGraph; IsomorphousMap: TIntegerVector;
  CompareVertices, CompareEdges: TCompareFunc): Bool;
{ проверяет, задает ли IsomorphousMap изоморфное вложение SubG в G }

procedure AnalyzeSpectrum(SortedSpectrum, SpectrumValue: TGenericInt64Vector;
  SpectrumCount: TGenericIntegerVector);
{ классифицирует вершины графа по спектрам степеней Де Моргана; на входе вектор
  SortedSpectrum содержит отсортированные по возрастанию спектры вершин графа
  (этот вектор может быть получен с помощью TGraph.UpdateSpectrum);
  на выходе вектор SpectrumValue содержит упорядоченные по возрастанию различные
  значения спектра, а SpectrumCount[I] = <количество вершин со значением
  спектра SpectrumValue[I]>) }

function CreateEccentricitiesVector(DistanceMatrix: TIntegerMatrix): TIntegerVector;
{ вычисляет вектор эксцентриситетов вершин графа на основе матрицы расстояний;
  эксцентриситетом I-й вершины графа называется максимальное значение I-й строки
  матрицы расстояний }

function CreateDistancesVector(DistanceMatrix: TIntegerMatrix): TIntegerVector;
{ вычисляет вектор дистанций (центральностей) вершин графа на основе матрицы
  расстояния; дистанцией I-й вершины графа называется сумма значений элементов
  I-й строки матрицы расстояний }

function BalabanIndex(CyclomaticNumber: Integer; DistancesVector: TIntegerVector): Float;
{ индекс Балабана графа с известными цикломатическим числом и вектором дистанций }

function RandichIndex(G: TGraph): Float;
{ индекс Рандича графа G }

procedure GetCompleteGraph(G: TGraph; NumVertices: Integer);
{ создает полный граф, т.е. простой граф, в котором каждая пара вершин смежна,
  с NumVertices вершинами (и NumVertices * (NumVertices - 1) div 2 ребрами) }

procedure GetCompleteBipartiteGraph(G: TGraph; NumVerticesPerPart: Integer);
{ создает полный двудольный граф с NumVertices вершинами в каждой доле }

procedure GetRandomGraph(G: TGraph; NumVertices, NumEdges: Integer);
{ создает случайный граф с Vertices вершинами и Edges ребрами (возможны петли и
  кратные ребра); если NumVertices = 0, то создается граф с пустыми множествами
  вершин и ребер }

procedure GetSimpleRandomGraph(G: TGraph; NumVertices, NumEdges: Integer);
{ создает простой (без петель и кратных ребер) случайный граф с NumVertices
  вершинами и min(NumEdges, NumVertices * (NumVertices - 1) div 2) ребрами
  (т.к. в простом графе с n вершинами может быть не больше ребер, чем в полном
  графе с n вершинами) }

function GetSimpleGraphByDegrees(G: TGraph; Degrees: TGenericIntegerVector): Bool;
{ проверяет, можно ли построить простой граф с предписанными степенями вершин
  Degrees; возвращает True, если это возможно, и False - иначе; если ответ
  положительный и G <> nil, то функция строит один из таких графов (в общем
  случае существует более чем один простой граф с заданными степенями вершин) }

implementation

function CreateCopy(G: TGraph; const AttrPtrName: String): TGraph;
{ создает граф, скелет которого создается на основе графа G, а вершины и ребра
  имеют единственный атрибут AttrPtr, указывающий на соответствующую вершину
  (ребро) графа G }
var
  I, VertexOfs, EdgeOfs: Integer;
begin
  Result:=TGraph.Create;
  try
    if Directed in G.Features then Result.Features:=[Directed];
    VertexOfs:=Result.CreateVertexAttr(AttrPtrName, AttrPointer);
    EdgeOfs:=Result.CreateEdgeAttr(AttrPtrName, AttrPointer);
    Result.AssignSceleton(G);
    for I:=0 to Result.VertexCount - 1 do
      Result.Vertices[I].AsPointerByOfs[VertexOfs]:=G.Vertices[I];
    for I:=0 to Result.EdgeCount - 1 do
      Result.Edges[I].AsPointerByOfs[EdgeOfs]:=G.Edges[I];
  except
    Result.Free;
    raise;
  end;
end;

type
  TEdgeCompare = class
    FCompare: TCompareFunc;
    FDirected: Bool;
    constructor Create(ACompare: TCompareFunc; ADirected: Bool);
    function Compare(E1, E2: Pointer): Integer;
  end;

constructor TEdgeCompare.Create(ACompare: TCompareFunc; ADirected: Bool);
begin
  inherited Create;
  FCompare:=ACompare;
  FDirected:=ADirected;
end;

function TEdgeCompare.Compare(E1, E2: Pointer): Integer;
begin
  if FDirected then begin
    Result:=TEdge(E1).V1.Index - TEdge(E2).V1.Index;
    if Result <> 0 then Exit;
  end;
  if Assigned(FCompare) then
    Result:=FCompare(E1, E2)
  else
    Result:=0;
end;

function EliminateParallelEdges(G: TGraph; CompareEdges: TCompareFunc;
  const AttrPtrName, AttrListName: String): Integer;
var
  I, J, N, EdgeOfs: Integer;
  B: Bool;
  E1, E2, OldE1, OldE2: TEdge;
  V1, V2: TVertex;
  ParallelEdgesInOldGraph: TClassList;
  DeleteEdge: TBoolVector;
  EdgeCompare: TEdgeCompare;
begin
  Result:=0;
  { используется для указания ребер, подлежащих уничтожению }
  DeleteEdge:=TBoolVector.Create(G.EdgeCount, False);
  EdgeCompare:=nil;
  try
    B:=Directed in G.Features;
    if Assigned(CompareEdges) or B then
      EdgeCompare:=TEdgeCompare.Create(CompareEdges, B);
    ParallelEdgesInOldGraph:=nil;
    With G do begin
      EdgeOfs:=EdgeAttrOffset(AttrPtrName);
      N:=EdgeCount;
      for I:=0 to N - 1 do begin
        E1:=Edges[I];
        if not DeleteEdge[E1.Index] then begin { ребро не было ранее обработано }
          OldE1:=E1.AsPointerByOfs[EdgeOfs];
          V1:=E1.V1;
          V2:=E1.V2;
          for J:=0 to V1.Degree - 1 do begin
            E2:=V1.IncidentEdge[J];
            if (E2 <> E1) and E2.ParallelToEdge(E1) then begin
              OldE2:=E2.AsPointerByOfs[EdgeOfs]; { nil для вновь добавленных ребер }
              if OldE2 <> nil then begin
                if ParallelEdgesInOldGraph = nil then begin
                  ParallelEdgesInOldGraph:=TClassList.Create;
                  ParallelEdgesInOldGraph.Count:=2;
                  ParallelEdgesInOldGraph[0]:=OldE1;
                  ParallelEdgesInOldGraph[1]:=OldE2;
                  { помечаем ребро для уничтожения }
                  DeleteEdge[E1.Index]:=True;
                end
                else
                  ParallelEdgesInOldGraph.Add(OldE2);
                { помечаем ребро для уничтожения }
                DeleteEdge[E2.Index]:=True;
              end;
            end;
          end; {for J}
          if ParallelEdgesInOldGraph <> nil then begin
            { сортируем ParallelEdgesInOldGraph в соответствии с EdgeCompare }
            With ParallelEdgesInOldGraph do begin
              Pack;
              if (EdgeCompare <> nil) then SortByObject(EdgeCompare.Compare);
            end;
            { добавляем супер-ребро (оно добавляется в конец списка ребер) }
            With AddEdge(V1, V2).Local do
              AsAutoFreeByOfs[Map.CreateAttr(AttrListName, AttrAutoFree)]:=
                ParallelEdgesInOldGraph;
            ParallelEdgesInOldGraph:=nil;
            Inc(Result);
          end;
        end; {if}
      end; {for I}
      if Result > 0 then { уничтожаем помеченные к уничтожению ребра }
        for I:=N - 1 downto 0 do
          if DeleteEdge[I] then Edges[I].Free;
    end; {With}
  finally
    DeleteEdge.Free;
    EdgeCompare.Free;
  end;
end;

function CheckEmbedding(SubG, G: TGraph; IsomorphousMap: TIntegerVector;
  CompareVertices, CompareEdges: TCompareFunc): Bool;
const
  Temp = '#CheckEmbedding';
var
  I, J, TempOfs: Integer;
  V: TVertex;
  E: TEdge;
  CopyG: TGraph;
  NewMap: TIntegerVector;
begin
  CopyG:=TGraph.Create;
  NewMap:=nil;
  try
    NewMap:=TIntegerVector.Create(IsomorphousMap.Count, -1);
    CopyG.Assign(G);
    TempOfs:=CopyG.CreateVertexAttr(Temp, AttrInt32);
    { удаляем несопоставленные вершины }
    for I:=CopyG.VertexCount - 1 downto 0 do begin
      V:=CopyG[I];
      J:=IsomorphousMap.IndexOf(I);
      if J >= 0 then
        V.AsInt32ByOfs[TempOfs]:=J
      else
        V.Free;
    end;
    { создаем NewMap }
    for I:=0 to CopyG.VertexCount - 1 do
      NewMap[CopyG[I].AsInt32[Temp]]:=I;
    { удаляем несопоставленные ребра }
    for I:=CopyG.EdgeCount - 1 downto 0 do begin
      E:=CopyG.Edges[I];
      if SubG.GetEdgeI(E.V1.AsInt32[Temp], E.V2.AsInt32ByOfs[TempOfs]) = nil then
        E.Free;
    end;
    CopyG.DropVertexAttr(Temp);
    Result:=SubG.EqualToGraph(CopyG, NewMap, CompareVertices, CompareEdges);
  finally
    CopyG.Free;
    NewMap.Free;
  end;
end;

procedure AnalyzeSpectrum(SortedSpectrum, SpectrumValue: TGenericInt64Vector;
  SpectrumCount: TGenericIntegerVector);
var
  I, K, N: Integer;
  OldValue: Int64;
begin
  N:=SortedSpectrum.Count;
  if N > 0 then begin
    SpectrumValue.Count:=N;
    SpectrumCount.Count:=N;
    K:=0;
    OldValue:=SortedSpectrum[0];
    SpectrumCount[0]:=1;
    SpectrumValue[0]:=OldValue;
    for I:=1 to N - 1 do
      if SortedSpectrum[I] <> OldValue then begin
        Inc(K);
        OldValue:=SortedSpectrum[I];
        SpectrumCount[K]:=1;
        SpectrumValue[K]:=OldValue;
      end
      else
        SpectrumCount.IncItem(K, 1);
    Inc(K);
    SpectrumCount.Count:=K;
    SpectrumValue.Count:=K;
  end;
end;

function CreateEccentricitiesVector(DistanceMatrix: TIntegerMatrix): TIntegerVector;
var
  I, N: Integer;
begin
  N:=DistanceMatrix.RowCount;
  Result:=TIntegerVector.Create(N, 0);
  try
    for I:=0 to N - 1 do
      Result[I]:=DistanceMatrix.RowMax(I);
  except
    Result.Free;
    raise;
  end;
end;

function CreateDistancesVector(DistanceMatrix: TIntegerMatrix): TIntegerVector;
var
  I, J, N, Sum: Integer;
begin
  N:=DistanceMatrix.RowCount;
  Result:=TIntegerVector.Create(N, 0);
  try
    for I:=0 to N - 1 do begin
      Sum:=0;
      for J:=0 to N - 1 do
        Sum:=Sum + DistanceMatrix[I, J];
      Result[I]:=Sum;
    end;
  except
    Result.Free;
    raise;
  end;
end;

function BalabanIndex(CyclomaticNumber: Integer; DistancesVector: TIntegerVector): Float;
var
  I, J, N: Integer;
begin
  Result:=0;
  N:=DistancesVector.Count;
  for I:=0 to N - 1 do
    for J:=I + 1 to N - 1 do
      Result:=Result + 1 / Sqrt(DistancesVector[I] * DistancesVector[J]);
  Result:=2 / (CyclomaticNumber + 1) * Result;
end;

function RandichIndex(G: TGraph): Float;
var
  I: Integer;
begin
  Result:=0;
  for I:=0 to G.EdgeCount - 1 do With G.Edges[I] do
    Result:=Result + 1 / Sqrt(V1.Degree * V2.Degree);
end;

procedure GetCompleteGraph(G: TGraph; NumVertices: Integer);
var
  I, J: Integer;
begin
  G.Clear;
  G.AddVertices(NumVertices);
  for I:=0 to NumVertices - 2 do
    for J:=I + 1 to NumVertices - 1 do
      G.AddEdgeI(I, J);
end;

procedure GetCompleteBipartiteGraph(G: TGraph; NumVerticesPerPart: Integer);
var
  I, J: Integer;
begin
  G.Clear;
  G.AddVertices(NumVerticesPerPart * 2);
  for I:=0 to NumVerticesPerPart - 1 do
    for J:=NumVerticesPerPart to G.VertexCount - 1 do
      G.AddEdgeI(I, J);
end;

procedure GetRandomGraph(G: TGraph; NumVertices, NumEdges: Integer);
var
  I: Integer;
begin
  G.Clear;
  G.AddVertices(NumVertices);
  if NumVertices > 0 then
    for I:=0 to NumEdges - 1 do
      G.AddEdgeI(Random(NumVertices), Random(NumVertices));
end;

procedure GetSimpleRandomGraph(G: TGraph; NumVertices, NumEdges: Integer);
var
  I, J, K, N: Integer;
  B: TBoolVector;
begin
  N:=NumVertices * (NumVertices - 1) div 2;
  if NumEdges >= N then GetCompleteGraph(G, NumVertices)
  else begin
    G.Clear;
    G.AddVertices(NumVertices);
    B:=TBoolVector.Create(N, False);
    try
      B.FillRandom(NumEdges);
      K:=0;
      for I:=0 to NumVertices - 1 do
        for J:=I + 1 to NumVertices - 1 do begin
          if B[K] then G.AddEdgeI(I, J);
          Inc(K);
        end;
    finally
      B.Free;
    end;
  end;
end;

function GetSimpleGraphByDegrees(G: TGraph; Degrees: TGenericIntegerVector): Bool;
var
  I, J, K, MinDegree: Integer;
  TempDegrees, OriginalIndexes: TIntegerVector;
begin
  if G <> nil then G.Clear;
  if (Degrees.Count > 0) and not Odd(Degrees.Sum) then begin
    TempDegrees:=TIntegerVector.Create(0, 0);
    OriginalIndexes:=nil;
    try
      OriginalIndexes:=TIntegerVector.Create(Degrees.Count, 0);
      TempDegrees.Assign(Degrees);
      OriginalIndexes.ArithmeticProgression(0, 1);
      if G <> nil then G.AddVertices(Degrees.Count);
      Result:=True;
      for I:=0 to TempDegrees.Count - 2 do begin
        TempDegrees.SortDescWith(OriginalIndexes);
        MinDegree:=TempDegrees.Pop;
        if MinDegree > TempDegrees.Count then begin
          Result:=False;
          Break;
        end;
        K:=OriginalIndexes[TempDegrees.Count];
        for J:=0 to MinDegree - 1 do begin
          TempDegrees.DecItem(J, 1);
          if G <> nil then G.AddEdgeI(OriginalIndexes[J], K);
        end;
      end;
      Result:=Result and (TempDegrees[0] = 0);
      if not Result and (G <> nil) then G.Clear;
    finally
      TempDegrees.Free;
      OriginalIndexes.Free;
    end;
  end
  else
    Result:=False;
end;

end.
