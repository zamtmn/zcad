{ Version 000607 experimental. Copyright © Alexey A.Chernobaev, 1996-2000 }

{ This code is partly based on VF: An efficient graph isomorphism algorithm by
  the Artificial Vision Group of the "Federico II" University of Naples, Italy
  (C++ implementation rel.0.9b, http://amalfi.dis.unina.it/graph). Author:
  dr. Mario Vento (e-mail: vento@unina.it). Reference: L.P.Cordella, P.Foggia,
  C.Sansone, M.Vento, "An Efficient Algorithm for the Inexact Matching of ARG
  Using a Contextual Transformational Model", in Proceedings of the 13th ICPR,
  IEEE Computer Society Press, vol.III, pp.180-184 (1996).

  Для распознавания изоморфизма графов используется алгоритм М.Венто (см. выше);
  поиск изоморфных вложений осуществляется с помощью алгоритма Ульмана (см.
  J.R.Ullman, "An Algorithm for Subgraph Isomorphism", Journal of the Association
  for Computing Machinery, 23, pp. 31-42 (1976)); оба алгоритма дополнены
  проверками некоторых инвариантов вершин графа с целью повышения скорости
  работы. }

unit Isomorph;

{$I VCheck.inc}

interface

uses
  SysUtils, ExtType, ExtSys, AttrType, Boolv, Boolm, Aliasv, Int16v, Int64v,
  Pointerv, Graphs, ExtGraph, VFState, VFGraph;

type
  TVisitorFunc = function (N: Integer; IsomorphousMap: TIntegerVector): Bool;
{ функция, вызываемая при нахождении изоморфизмов из FindMatches или изоморфных
  вложений из FindEmbeddings; N: количество найденных изоморфизмов или изоморфных
  вложений, включая данный; IsomorphousMap: вектор, задающий найденный изоморфизм
  или изоморфное вложение (см. ниже) }

function FindMatch(G1, G2: TGraph; IsomorphousMap: TIntegerVector;
  CompareVertices, CompareEdges: TCompareFunc): Bool;
{ проверяет, являются ли графы G1 и G2 изоморфными; для сравнения атрибутов
  вершин и ребер используются функции CompareVertices и CompareEdges (если они
  равны nil, то различие атрибутов игнорируется); если изоморфизм существует и
  IsomorphousMap <> nil, то IsomorphousMap[I] = <номер вершины G2, которая
  соответствует I-й вершине G1>; возвращает True, если изоморфизм существует, и
  False иначе; функция позволяет находить автоморфизмы (т.е. допускаются G1=G2) }

function FindMatches(G1, G2: TGraph; Visitor: TVisitorFunc;
  CompareVertices, CompareEdges: TCompareFunc): Integer;
{ находит все или заданное количество изоморфизмов между графами G1 и G2; для
  сравнения атрибутов вершин и ребер используются функции CompareVertices и
  CompareEdges (если они равны nil, то различие атрибутов игнорируется); если
  Visitor <> nil, то каждый раз, когда функция FindMatches находит изоморфизм,
  она вызывает функцию Visitor, передавая ей в качестве параметра найденный
  изоморфизм; если Visitor возвратит True, то поиск изоморфизмов прекратится;
  возвращает количество найденных изоморфизмов; функция позволяет находить
  автоморфизмы (т.е. допускаются G1=G2)  }

function FindEmbedding(SubG, G: TGraph; IsomorphousMap: TIntegerVector;
  CompareVertices, CompareEdges: TCompareFunc): Bool;
{ проверяет, существует ли изоморфное вложение графа SubG в граф G (т.е. в G
  существует подграф, изоморфный SubG); для сравнения атрибутов вершин и ребер
  используются функции CompareVertices и CompareEdges (если они равны nil, то
  различие атрибутов игнорируется); если изоморфное вложение существует и
  IsomorphousMap <> nil, то IsomorphousMap[I] = <номер вершины G, которая
  соответствует I-й вершине SubG>; возвращает True, если изоморфное вложение
  существует, и False иначе }

function FindEmbeddings(SubG, G: TGraph; Visitor: TVisitorFunc;
  CompareVertices, CompareEdges: TCompareFunc): Integer;
{ находит все или заданное количество изоморфных вложений графа SubG в граф G;
  для сравнения атрибутов вершин и ребер используются функции CompareVertices и
  CompareEdges (если они равны nil, то различие атрибутов игнорируется);
  возвращает количество найденных изоморфных вложений; каждый раз, когда функция
  FindEmbeddings находит изоморфное вложение, она вызывает функцию Visitor,
  передавая ей в качестве параметра найденное изоморфное вложение; если Visitor
  возвратит True, то поиск изоморфных вложений прекратится }

implementation

function Match(G1, G2: TGraph; IsomorphousMap: TIntegerVector;
  Visitor: TVisitorFunc; CompareVertices, CompareEdges: TCompareFunc): Integer;
var
  Count: Integer;
  LowMemory: Bool;

  function DoMatch(s: TState): Bool;
  { рекурсивный поиск }
  var
    n1, n2: Int32;
    s1: TState;
  begin
    if s.IsGoal then begin
      Inc(Count);
      if IsomorphousMap <> nil then s.GetCoreSet(IsomorphousMap);
      if Assigned(Visitor) then
        Result:=Visitor(Count, IsomorphousMap)
      else
        Result:=True;
      Exit;
    end;
    if s.IsDead then begin
      Result:=False;
      Exit;
    end;
    n1:=NULL_NODE;
    n2:=NULL_NODE;
    while s.NextPair(n1, n2, n1, n2) do
      if s.IsFeasiblePair(n1, n2) then begin
        s1:=TState.Copy(s);
        try
          if LowMemory then s.Pack;
          s1.AddPair(n1, n2);
          if DoMatch(s1) then begin
            Result:=True;
            Exit;
          end;
          if LowMemory then s.Unpack;
        finally
          s1.Free;
        end;
      end;
    Result:=False;
  end;

var
  s0: TState;

  function MemoryRequirements: Float64;
  { оценивает размер памяти, необходимый для работы алгоритма при условии
    неэкономного расхода памяти }
  var
    N: Integer;
  begin
    N:=G1.VertexCount;
    Result:=(N - s0.CoreLen) { количество еще несопоставленных вершин } *
      6{2 * 3} * N;
      { на каждом шаге рекурсии создается 2 копии класса TVFGraph; конструктор
        копии TVFGraph создает векторы Core типа TUInt16Vector и NodeFlags типа
        TByteVector длины N элементов каждый }
  end;

var
  I, ParallelEdgeCount, OldCount, Count1, Count2, Vertex1, Vertex2: Integer;
  G1Copied, G2Copied, HasParallelEdges: Bool;
  Value: Int64;
  Spectrum1, Spectrum2, SortedSpectrum1, SortedSpectrum2, SpectrumValue,
    TempVector: TInt64Vector;
  SpectrumCount: TIntegerVector;
  EdgeHelper: TEdgeCompare;
begin
  Result:=0;
  if (G1.VertexCount > 0) and
    (G1.VertexCount = G2.VertexCount) and (G1.EdgeCount = G2.EdgeCount) and
    ((Directed in G1.Features) = (Directed in G2.Features))
  then begin
    if G1.VertexCount > MaxVertices then
      raise Exception.CreateFmt('Match error: maximum allowed number of vertices is %d',
        [MaxVertices]);
    G1Copied:=False;
    G2Copied:=False;
    { сравнение количества кратных ребер }
    ParallelEdgeCount:=G1.ParallelEdgeCount;
    if ParallelEdgeCount <> G2.ParallelEdgeCount then Exit;
    HasParallelEdges:=ParallelEdgeCount > 0;
    { сравнение спектров Де Моргана }
    Spectrum1:=G1.CreateInt64DegreesVector;
    Spectrum2:=nil;
    SortedSpectrum1:=nil;
    try
      Spectrum2:=G2.CreateInt64DegreesVector;
      SortedSpectrum1:=TInt64Vector.Create(0, 0);
      SortedSpectrum2:=TInt64Vector.Create(0, 0);
      TempVector:=nil;
      try
        TempVector:=TInt64Vector.Create(0, 0);
        Count1:=1;
        repeat
          OldCount:=Count1;
          Count1:=G1.UpdateSpectrum(Spectrum1, SortedSpectrum1, TempVector);
          Count2:=G2.UpdateSpectrum(Spectrum2, SortedSpectrum2, TempVector);
          if (Count1 <> Count2) or not SortedSpectrum1.EqualTo(SortedSpectrum2)
          then Exit;
        until (Count1 <= OldCount) or (Count1 = G1.VertexCount);
      finally
        SortedSpectrum2.Free;
        TempVector.Free;
      end;
      { обрабатываем кратные ребра, если они есть }
      if HasParallelEdges then begin
        G1:=CreateCopy(G1, AttrPtr);
        G1Copied:=True;
        G2:=CreateCopy(G2, AttrPtr);
        G2Copied:=True;
        { удаляем кратные ребра, попутно проверяя, что количества групп кратных
          ребер совпадают }
        if EliminateParallelEdges(G1, CompareEdges, AttrPtr, AttrList) <>
          EliminateParallelEdges(G2, CompareEdges, AttrPtr, AttrList) then Exit;
      end;
      EdgeHelper:=nil;
      s0:=nil;
      try
        if HasParallelEdges or Assigned(CompareEdges) then
          EdgeHelper:=TEdgeCompare.Create(CompareEdges, G1Copied, Directed in G1.Features, False);
        s0:=TState.Create(G1, G2, Spectrum1, Spectrum2, CompareVertices, EdgeHelper);
        SpectrumCount:=TIntegerVector.Create(0, 0);
        SpectrumValue:=nil;
        try
          SpectrumValue:=TInt64Vector.Create(0, 0);
          AnalyzeSpectrum(SortedSpectrum1, SpectrumValue, SpectrumCount);
          SortedSpectrum1.Free;
          SortedSpectrum1:=nil;
          for I:=0 to Count1 - 1 do { SpectrumCount.Count = Count1 = Count2 }
            if SpectrumCount[I] = 1 then begin
              Value:=SpectrumValue[I];
              Vertex1:=Spectrum1.IndexOf(Value);
              Vertex2:=Spectrum2.IndexOf(Value);
              if not s0.IsFeasiblePair(Vertex1, Vertex2) then Exit;
              s0.AddPair(Vertex1, Vertex2);
            end;
        finally
          SpectrumCount.Free;
          SpectrumValue.Free;
        end;
        { принимаем меры к сокращению расхода оперативной памяти, если при
          неэкономном ее использовании будет недостаточно половины объема
          физической памяти (при достаточном количестве памяти неэкономный
          вариант работает быстрее) }
        LowMemory:=MemoryRequirements > PhysicalMemorySize div 2;
        { рекурсивный поиск }
        Count:=0;
        DoMatch(s0);
        Result:=Count;
      finally
        EdgeHelper.Free;
        s0.Free;
      end;
    finally
      if G1Copied then G1.Free;
      if G2Copied then G2.Free;
      Spectrum1.Free;
      Spectrum2.Free;
      SortedSpectrum1.Free;
    end;
  end;
end;

function FindMatch(G1, G2: TGraph; IsomorphousMap: TIntegerVector;
  CompareVertices, CompareEdges: TCompareFunc): Bool;
begin
  Result:=Match(G1, G2, IsomorphousMap, nil, CompareVertices, CompareEdges) > 0;
end;

function FindMatches(G1, G2: TGraph; Visitor: TVisitorFunc;
  CompareVertices, CompareEdges: TCompareFunc): Integer;
var
  Map: TIntegerVector;
begin
  Map:=TIntegerVector.Create(0, 0);
  try
    Result:=Match(G1, G2, Map, Visitor, CompareVertices, CompareEdges);
  finally
    Map.Free;
  end;
end;

type
  TVertexCompare = class
  { сравнивает вершины по степеням Де Моргана }
  private
    Spectrum: TInt64Vector;
  public
    constructor Create(G: TGraph);
    destructor Destroy; override;
    function Compare(Item1, Item2: Pointer): Integer;
  end;

constructor TVertexCompare.Create(G: TGraph);
var
  Count, OldCount: Integer;
  TempVector: TInt64Vector;
begin
  inherited Create;
  Spectrum:=G.CreateInt64DegreesVector;
  TempVector:=TInt64Vector.Create(0, 0);
  try
    Count:=1;
    repeat
      OldCount:=Count;
      Count:=G.UpdateSpectrum(Spectrum, nil, TempVector);
    until (Count <= OldCount) or (Count = G.VertexCount);
  finally
    TempVector.Free;
  end;
end;

destructor TVertexCompare.Destroy;
begin
  Spectrum.Free;
  inherited Destroy;
end;

function TVertexCompare.Compare(Item1, Item2: Pointer): Integer;
var
  S1, S2: Int64;
begin
  S1:=Spectrum[TVertex(Item1).Index];
  S2:=Spectrum[TVertex(Item2).Index];
  if S2 > S1 then
    Result:=1
  else if S2 < S1 then
    Result:=-1
  else
    Result:=0;
end;

function Embedding(SubG, G: TGraph; IsomorphousMap: TIntegerVector;
  Visitor: TVisitorFunc; CompareVertices, CompareEdges: TCompareFunc): Integer;
{ поиск изоморфного вложения графа SubG в G с использованием алгоритма Ульмана
  и дополнительными проверками некоторых инвариантов вершин }
var
  GN, SubGN, EmbeddingsFound, GAttrPtrOfs, SubGAttrPtrOfs: Integer;
  IsDirected: Bool;
  Temp: TIntegerVector;
  VertexAttrsEqual, EdgeAttrsEqual: TBoolMatrix;

  procedure FindMinRingSizes(AGraph: TGraph; Result: TIntegerVector);
  var
    I: Integer;
  begin
    for I:=0 to Result.Count - 1 do
      Result[I]:=AGraph.FindMinRing(AGraph[I], nil);
  end;

  procedure FindComponentSizes(AGraph: TGraph; Result: TIntegerVector);
  var
    I: Integer;
  begin
    for I:=0 to Result.Count - 1 do
      Result[I]:=AGraph.BFSFromVertex(AGraph[I]);
  end;

  procedure FindLoops(AGraph: TGraph; Result: TClassList);
  var
    I: Integer;
    E: TEdge;
  begin
    Result.Count:=AGraph.VertexCount;
    for I:=0 to AGraph.EdgeCount - 1 do begin
      E:=AGraph.Edges[I];
      if E.IsLoop then Result[E.V1.Index]:=E;
    end;
  end;

  function ForwardChecking(I: Integer; P: TBoolMatrix): Bool;
  var
    K, L, M, N: Integer;
    VK, WL: TVertex;
    E1, E2: TEdge;
  begin
    Result:=True;
    for K:=I + 1 to SubGN - 1 do begin
      for L:=0 to GN - 1 do
        if P[K, L] then begin
          VK:=SubG[K];
          WL:=G[L];
          for M:=0 to VK.Degree - 1 do begin
            E1:=VK.IncidentEdge[M];
            N:=IsomorphousMap[E1.OtherVertex(VK).Index];
            if N >= 0 then begin
              E2:=G.GetEdgeI(L, N);
              if (E2 <> nil) and
                ((EdgeAttrsEqual = nil) or EdgeAttrsEqual[E1.Index, E2.Index]) and
                (not IsDirected or ((E1.V1 = VK) = (E2.V1 = WL)))
              then
                Continue;
              P[K, L]:=False;
              Break;
            end; {if N}
          end; {for M}
        end;
      if P.RowMax(K) = False then begin
        Result:=False;
        Exit;
      end;
    end; {for K}
  end;

  function Backtrack(I: Integer; P: TBoolMatrix): Bool;
  var
    J, K: Integer;
    P1: TBoolMatrix;
  begin
    if I >= SubGN then begin
      Inc(EmbeddingsFound);
      { пересчитываем IsomorphousMap согласно AttrPtr }
      for J:=0 to SubGN - 1 do
        Temp[TVertex(SubG[J].AsPointerByOfs[SubGAttrPtrOfs]).Index]:=
          TVertex(G[IsomorphousMap[J]].AsPointerByOfs[GAttrPtrOfs]).Index;
      if Assigned(Visitor) then
        Result:=Visitor(EmbeddingsFound, Temp)
      else begin
        IsomorphousMap.Assign(Temp);
        Result:=True;
      end;
      Exit;
    end;
    Result:=False;
    P1:=TBoolMatrix.Create(0, 0, False);
    try
      for J:=0 to GN - 1 do
        if P[I, J] then begin
          IsomorphousMap[I]:=J;
          P1.Assign(P);
          for K:=I + 1 to SubGN - 1 do
            P1[K, J]:=False;
          if ForwardChecking(I, P1) then
            if Backtrack(I + 1, P1) then begin
              Result:=True;
              Exit;
            end;
          IsomorphousMap[I]:=-1;
        end;
    finally
      P1.Free;
    end;
  end;

var
  I, J, GParallelEdges, SubGParallelEdges, GLoopCount, SubGLoopCount: Integer;
  GCopied, SubGCopied, GHasParallel, SubGHasParallel: Bool;
  E1, E2: TEdge;
  OrigG, OrigSubG: TGraph;
  GLoops, SubGLoops: TClassList;
  MinRingSizeG, MinRingSizeSubG, ComponentSizeG, ComponentSizeSubG: TIntegerVector;
  EdgeHelper: TEdgeCompare;
  VertexCompare: TVertexCompare;
begin
  EmbeddingsFound:=0;
  SubGN:=SubG.VertexCount;
  GN:=G.VertexCount;
  IsDirected:=Directed in SubG.Features;
  if (SubGN > 0) and (SubGN <= GN) and (SubG.EdgeCount <= G.EdgeCount) and
    (IsDirected = (Directed in G.Features))
  then begin
    SubGLoopCount:=SubG.LoopCount;
    GLoopCount:=G.LoopCount;
    if SubGLoopCount <= GLoopCount then begin
      OrigG:=G;
      OrigSubG:=SubG;
      if IsDirected then begin
        SubG.Features:=SubG.Features - [Directed];
        G.Features:=G.Features - [Directed];
      end;
      try
        SubGParallelEdges:=SubG.ParallelEdgeCount;
        GParallelEdges:=G.ParallelEdgeCount;
        if SubGParallelEdges <= GParallelEdges then begin
          IsomorphousMap.Count:=SubGN;
          IsomorphousMap.FillValue(-1);
          VertexAttrsEqual:=nil;
          EdgeAttrsEqual:=nil;
          SubGCopied:=False;
          GCopied:=False;
          try
            { эмпирическое правило: для повышения скорости работы следует
              отсортировать вершины по убыванию их степеней Де Моргана }
            SubG:=CreateCopy(SubG, AttrPtr);
            SubGCopied:=True;
            SubGAttrPtrOfs:=SubG.VertexAttrOffset(AttrPtr);
            VertexCompare:=TVertexCompare.Create(SubG);
            try
              SubG.SortVerticesByObject(VertexCompare.Compare);
            finally
              VertexCompare.Free;
            end;
            G:=CreateCopy(G, AttrPtr);
            GCopied:=True;
            GAttrPtrOfs:=G.VertexAttrOffset(AttrPtr);
            VertexCompare:=TVertexCompare.Create(G);
            try
              G.SortVerticesByObject(VertexCompare.Compare);
            finally
              VertexCompare.Free;
            end;
            { заменяем каждую группу параллельных ребер на одно ребро с атрибутом }
            SubGHasParallel:=SubGParallelEdges > 0;
            if SubGHasParallel then
              EliminateParallelEdges(SubG, CompareEdges, AttrPtr, AttrList);
            GHasParallel:=GParallelEdges > 0;
            if GHasParallel then
              EliminateParallelEdges(G, CompareEdges, AttrPtr, AttrList);
            if IsDirected then begin
              SubG.Features:=SubG.Features + [Directed];
              G.Features:=G.Features + [Directed];
            end;
            if SubGHasParallel or GHasParallel or Assigned(CompareEdges) then
              EdgeHelper:=TEdgeCompare.Create(CompareEdges, GCopied, IsDirected, True)
            else
              EdgeHelper:=nil;
            VertexAttrsEqual:=CreateBoolMatrix(SubGN, GN, True);
            MinRingSizeG:=TIntegerVector.Create(GN, 0);
            MinRingSizeSubG:=nil;
            ComponentSizeG:=nil;
            ComponentSizeSubG:=nil;
            GLoops:=nil;
            SubGLoops:=nil;
            try
              MinRingSizeSubG:=TIntegerVector.Create(SubGN, 0);
              FindMinRingSizes(G, MinRingSizeG);
              FindMinRingSizes(SubG, MinRingSizeSubG);
              if not (SubG.Connected and G.Connected) then begin
                ComponentSizeG:=TIntegerVector.Create(GN, 0);
                ComponentSizeSubG:=TIntegerVector.Create(SubGN, 0);
                FindComponentSizes(G, ComponentSizeG);
                FindComponentSizes(SubG, ComponentSizeSubG);
              end;
              if SubGLoopCount > 0 then begin { обрабатываем петли }
                GLoops:=TClassList.Create;
                SubGLoops:=TClassList.Create;
                FindLoops(G, GLoops);
                FindLoops(SubG, SubGLoops);
              end;
              for I:=0 to SubGN - 1 do begin
                for J:=0 to GN - 1 do
                  if (SubG[I].Degree > G[J].Degree) or
                    Assigned(CompareVertices) and (CompareVertices(SubG[I], G[J]) <> 0) or
                    { если вершина V графа SubG - кольцевая, то соответствующая вершина
                      U графа G тоже должна быть кольцевой, причем размер минимального
                      кольца, проходящего через кольцевую вершину U, должен быть
                      не больше размера минимального кольца, проходящего через V }
                    (MinRingSizeSubG[I] > 0) and ((MinRingSizeG[J] <= 0) or
                    (MinRingSizeG[J] > MinRingSizeSubG[I])) or
                    { количество вершин в компоненте связности, которому принадлежит
                      вершина V графа SubG, должно быть не больше количества вершин
                      в компонент связности, которому принадлежит соответствующая
                      вершина U графа G }
                    (ComponentSizeG <> nil) and (ComponentSizeSubG[I] > ComponentSizeG[J]) or
                    (SubGLoopCount > 0) and (SubGLoops[I] <> nil) and
                      ((GLoops[J] = nil) or (EdgeHelper <> nil) and
                        (EdgeHelper.Compare(SubGLoops[I], GLoops[J], SubG[I], G[J]) <> 0))
                  then
                    VertexAttrsEqual[I, J]:=False;
                { если в матрице существует строка, все элементы которой равны False,
                  то нет решения }
                if VertexAttrsEqual.RowMax(I) = False then begin
                  Result:=0;
                  Exit;
                end;
              end;
            finally
              MinRingSizeG.Free;
              MinRingSizeSubG.Free;
              ComponentSizeG.Free;
              ComponentSizeSubG.Free;
              GLoops.Free;
              SubGLoops.Free;
            end;
            { аналогично для ребер }
            if EdgeHelper <> nil then begin
              EdgeAttrsEqual:=CreateBoolMatrix(SubG.EdgeCount, G.EdgeCount, True);
              for I:=0 to SubG.EdgeCount - 1 do
                for J:=0 to G.EdgeCount - 1 do begin
                  E1:=SubG.Edges[I];
                  E2:=G.Edges[J];
                  if EdgeHelper.Compare(E1, E2, E1.V1, E2.V1) <> 0 then
                    EdgeAttrsEqual[I, J]:=False;
                  end;
              for I:=0 to SubG.EdgeCount - 1 do
                if EdgeAttrsEqual.RowMax(I) = False then begin
                  Result:=0;
                  Exit;
                end;
            end;
            Temp:=TIntegerVector.Create(SubGN, 0);
            try
              Backtrack(0, VertexAttrsEqual);
            finally
              Temp.Free;
            end;
          finally
            if SubGCopied then SubG.Free;
            if GCopied then G.Free;
            VertexAttrsEqual.Free;
            EdgeAttrsEqual.Free;
          end;
        end;
      finally
        if IsDirected then begin
          OrigSubG.Features:=OrigSubG.Features + [Directed];
          OrigG.Features:=OrigG.Features + [Directed];
        end;
      end;
    end;
  end;
  Result:=EmbeddingsFound;
end;

function FindEmbedding(SubG, G: TGraph; IsomorphousMap: TIntegerVector;
  CompareVertices, CompareEdges: TCompareFunc): Bool;
var
  FreeMap: Bool;
begin
  if IsomorphousMap = nil then begin
    IsomorphousMap:=TIntegerVector.Create(0, 0);
    FreeMap:=True;
  end
  else
    FreeMap:=False;
  try
    Result:=Embedding(SubG, G, IsomorphousMap, nil, CompareVertices, CompareEdges) > 0;
  finally
    if FreeMap then IsomorphousMap.Free;
  end;
end;

function FindEmbeddings(SubG, G: TGraph; Visitor: TVisitorFunc;
  CompareVertices, CompareEdges: TCompareFunc): Integer;
var
  Map: TIntegerVector;
begin
  Map:=TIntegerVector.Create(0, 0);
  try
    Result:=Embedding(SubG, G, Map, Visitor, CompareVertices, CompareEdges);
  finally
    Map.Free;
  end;
end;

end.
