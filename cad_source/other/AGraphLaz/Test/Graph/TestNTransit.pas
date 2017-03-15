unit TestNTransit;

interface

uses
ExtGraph, GraphIO,  AttrType, AttrSet, Aliasv, Graphs, Pointerv, Isomorph;

procedure Test;

implementation

procedure GetSortedSets(K, N: Integer; Sets: TClassList);
{ возвращает лексикографически упорядоченный набор всех возрастающих
  последовательностей длины K из чисел 0..N - 1 }
var
  X: TIntegerVector;

  procedure GetSet(Level, From: Integer);
  var
    I: Integer;
    T: TIntegerVector;
  begin
    if Level < K then
      for I:=From to N - K + Level do begin
        X[Level]:=I;
        GetSet(Level + 1, I + 1);
      end
    else begin
      T:=TIntegerVector.Create(0, 0);
      T.Assign(X);
      Sets.Add(T);
    end;
  end;

begin
  X:=TIntegerVector.Create(K, 0);
  try
    GetSet(0, 0);
  finally
    X.Free;
  end;
end;

function IsNTransitive(G: TGraph; N: Integer): Boolean;
{ проверяет, является ли граф G n-транзитивным; граф называется n-транзитивным,
  если в его группе автоморфизмов для любой пары упорядоченных наборов из n
  различных вершин существует автоморфизм, переводящий один из них в другой;
  проверка осуществляется по определению - рассматриваются все пары упорядоченных
  набором из n-вершин (вернее все лексикографически упорядоченные пары, в которых
  первый набор лексикографически меньше второго), после чего ищется автоморфизм,
  сохраняющий соответствие между ними }
const
  FixSets = 'FixSets';
var
  I, J, K, AttrOfs: Integer;
  Copy1, Copy2: TGraph;
  Set1, Set2: TIntegerVector;
  SortedSets: TClassList;
begin
  SortedSets:=TClassList.Create;
  Copy1:=nil;
  Copy2:=nil;
  try
    GetSortedSets(N, G.VertexCount, SortedSets);
    Copy1:=TGraph.Create;
    Copy2:=TGraph.Create;
    Copy1.AssignSceleton(G);
    Copy2.AssignSceleton(G);
    for I:=0 to SortedSets.Count - 1 do begin
      Set1:=SortedSets[I];
      for J:=I + 1 to SortedSets.Count - 1 do begin
        Set2:=SortedSets[J];
        { "фиксируем" соответствие }
        AttrOfs:=Copy1.CreateVertexAttr(FixSets, AttrInt32);
        Copy2.CreateVertexAttr(FixSets, AttrInt32);
        for K:=0 to N - 1 do begin
          Copy1[Set1[K]].AsInt32ByOfs[AttrOfs]:=K + 1;
          Copy2[Set2[K]].AsInt32ByOfs[AttrOfs]:=K + 1;
        end;
        { проверяем существование автоморфизма при заданном соответствии }
        if not FindMatch(Copy1, Copy2, nil, CompareUserSets, nil) then begin
(*          writeln(False);
          writeln('Unmatchable sets: ');
          Set1.DebugWrite;
          Set2.DebugWrite;*)
          Result:=False;
          Exit;
        end;
        { "стираем" соответствие }
        Copy1.DropVertexAttr(FixSets);
        Copy2.DropVertexAttr(FixSets);
      end;
    end;
    Result:=True;
  finally
    SortedSets.FreeItems;
    SortedSets.Free;
    Copy1.Free;
    Copy2.Free;
  end;
end;

procedure Test;
var
  I: Integer;
  G: TGraph;
begin
  G:=TGraph.Create;
  try
    G.AddVertices(4);
    G.AddEdges([0, 1,  0, 2,  1, 2,  1, 3,  2, 3,  3, 0]);
    for I:=1 to G.VertexCount do begin
      write(I, '-transitive: ');
      if IsNTransitive(G, I) then
        writeln(True)
      else
        Break;
    end;
  finally
    G.Free;
  end;
end;

procedure Test1;
const
  MaxVertices = 20;
var
  I, Count, Seed, NTrans, MaxEdges: Integer;
  G: TGraph;
begin
  Randomize;
  G:=TGraph.Create;
  try
    Count:=0;
    while True do begin
      Seed:=RandSeed;
      I:=Random(MaxVertices - 2) + 3;
      MaxEdges:=I * (I - 1) div 2 - 1; { полный граф - неинтересно }
      GetSimpleRandomGraph(G, I, Random(MaxEdges) + 1);
      Inc(Count);
      write(#13, Count, ' |V| = ', G.VertexCount, ' |E| = ', G.EdgeCount, ' ');
      NTrans:=0;
      for I:=1 to G.VertexCount do
        if IsNTransitive(G, I) then begin
          write('.');
          NTrans:=I;
        end
        else
          Break;
      if NTrans > 1 then begin
        write(NTrans, '-transitive; RandSeed=', Seed);
        readln;
      end;
    end;
  finally
    G.Free;
  end;
end;

end.
