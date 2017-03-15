{ Version 000602. Copyright © Alexey A.Chernobaev, 1996-2000 }

{ »спользуетс€ алгоритм, описанный в статье J.E.Hopcroft, R.E.Tarjan: "Efficient
  Planarity Testing". Journal of the ACM, Vol.21, 549-568, 1974. }

{ This code is partly based on LEDA-R-3.7.1 realization of Hopcroft-Tarjan
  algorithm (file src/_ht_planar.c). According to license terms, "the RESEARCH
  version (LEDA-R) of LEDA... can be used free of charge for academic research
  and teaching". LEDA home page: http://www.mpi-sb.mpg.de/LEDA. }

unit Planar;

interface

{$I VCheck.inc}

uses
  SysUtils, ExtType, ExtSys, Aliasv, Int16v, Boolv, Pointerv, MultiLst, PStack,
  Graphs;

function PlanarGraph(G: TGraph): Bool;
{
  ¬озвращает True, если граф G планарный, и False иначе.
}

implementation

{$IFDEF CHECK_OBJECTS_FREE}
uses ChckFree;
{$ENDIF}

type
  TBlock = class
  public
    LAtt, RAtt: TIntegerVector;
    constructor Create(A: TIntegerVector);
    destructor Destroy; override;
    procedure Flip;
    function LeftInterlace(S: TPointerStack): Bool;
    function RightInterlace(S: TPointerStack): Bool;
    procedure Combine(BPrime: TBlock);
    function Clean(DFSNum: Integer): Bool;
    procedure AddToAtt(Att: TIntegerVector; DFSNum: Integer);
  end;

constructor TBlock.Create(A: TIntegerVector);
begin
  inherited Create;
  LAtt:=TIntegerVector.Create(0, 0);
  RAtt:=TIntegerVector.Create(0, 0);
  LAtt.ConcatenateWith(A);
  A.Clear;
  {$IFDEF CHECK_OBJECTS_FREE}
  RegisterObjectCreate(Self);
  {$ENDIF}
end;

destructor TBlock.Destroy;
begin
  {$IFDEF CHECK_OBJECTS_FREE}
  RegisterObjectFree(Self);
  {$ENDIF}
  LAtt.Free;
  RAtt.Free;
  inherited Destroy;
end;

procedure TBlock.Flip;
var
  P: Pointer;
begin
  P:=LAtt;
  LAtt:=RAtt;
  RAtt:=P;
end;

function TBlock.LeftInterlace(S: TPointerStack): Bool;
begin
  Result:=(S.Count > 0) and (TBlock(S.Top).LAtt.Count > 0) and
    (LAtt.Last < TBlock(S.Top).LAtt[0]);
end;

function TBlock.RightInterlace(S: TPointerStack): Bool;
begin
  Result:=(S.Count > 0) and (TBlock(S.Top).RAtt.Count > 0) and
    (LAtt.Last < TBlock(S.Top).RAtt[0]);
end;

procedure TBlock.Combine(BPrime: TBlock);
begin
  LAtt.ConcatenateWith(BPrime.LAtt);
  RAtt.ConcatenateWith(BPrime.RAtt);
  BPrime.Free;
end;

function TBlock.Clean(DFSNum: Integer): Bool;
var
  I: Integer;
begin
  I:=0;
  while (I < LAtt.Count) and (LAtt[I] = DFSNum) do Inc(I);
  LAtt.DeleteRange(0, I);
  I:=0;
  while (I < RAtt.Count) and (RAtt[I] = DFSNum) do Inc(I);
  RAtt.DeleteRange(0, I);
  Result:=(LAtt.Count = 0) and (RAtt.Count = 0);
end;

procedure TBlock.AddToAtt(Att: TIntegerVector; DFSNum: Integer);
begin
  if (RAtt.Count > 0) and (RAtt[0] > DFSNum) then Flip;
  Att.ConcatenateWith(LAtt);
  Att.ConcatenateWith(RAtt);
  LAtt.Clear;
  RAtt.Clear;
end;

function PlanarGraph(G: TGraph): Bool;
var
  DFSCounter: Integer;
  SimpleCopy: TGraph;
  AdjLists, Buckets: TMultiList;
  Parent: TClassList;
  DFSNum, LowPt1, LowPt2: TIntegerVector;
  TreeArc: TBoolVector;

  procedure DFS(V, U: TVertex);
  var
    I, Cmp: Integer;
    E: TEdge;
    W: TVertex;
  begin
    DFSNum[V.Index]:=DFSCounter;
    LowPt1[V.Index]:=DFSCounter;
    LowPt2[V.Index]:=DFSCounter;
    Inc(DFSCounter);
    for I:=0 to V.Degree - 1 do begin
      E:=V.IncidentEdge[I];
      W:=E.OtherVertex(V);
      if DFSNum[W.Index] = -1 then begin
        TreeArc[E.Index]:=True;
        Parent[W.Index]:=V;
        DFS(W, V);
        Cmp:=LowPt1[W.Index] - LowPt1[V.Index];
        if Cmp < 0 then begin
          LowPt2[V.Index]:=IntMin(LowPt1[V.Index], LowPt2[W.Index]);
          LowPt1[V.Index]:=LowPt1[W.Index];
        end
        else if Cmp = 0 then
          LowPt2[V.Index]:=IntMin(LowPt2[V.Index], LowPt2[W.Index])
        else
          LowPt2[V.Index]:=IntMin(LowPt2[V.Index], LowPt1[W.Index]);
      end
      else
        if (DFSNum[W.Index] < DFSNum[V.Index]) and (W <> U) then begin
          {TreeArc[E.Index]:=False; // значение вектора по умолчанию }
          Cmp:=DFSNum[W.Index] - LowPt1[V.Index];
          if Cmp < 0 then begin
            LowPt2[V.Index]:=LowPt1[V.Index];
            LowPt1[V.Index]:=DFSNum[W.Index];
          end
          else if Cmp > 0 then
            LowPt2[V.Index]:=IntMin(LowPt2[V.Index], DFSNum[W.Index]);
        end;
    end;
  end;

  procedure GetVW(E: TEdge; var V, W: TVertex);
  begin
    if TreeArc[E.Index] xor (DFSNum[E.V1.Index] > DFSNum[E.V2.Index]) then begin
      V:=E.V1;
      W:=E.V2;
    end
    else begin
      V:=E.V2;
      W:=E.V1;
    end;
  end;

  function StronglyPlanar(E0: TEdge; Att: TIntegerVector): Bool;
  var
    I, T: Integer;
    X, W, W0, Neighbour: TVertex;
    E: TEdge;
    AdjList: TClassList;
    S: TPointerStack;
    A: TIntegerVector;
    B: TBlock;
  begin
    GetVW(E0, X, W);
    E:=AdjLists[W.Index][0];
    repeat
      Neighbour:=E.OtherVertex(W);
      if not TreeArc[E.Index] then Break;
      W:=Neighbour;
      E:=AdjLists[W.Index][0];
    until False;
    W0:=Neighbour;
    S:=TPointerStack.Create;
    A:=nil;
    try
      A:=TIntegerVector.Create(0, 0);
      while W <> X do begin
        AdjList:=AdjLists[W.Index];
        for I:=1 to AdjList.Count - 1 do begin
          E:=AdjList[I];
          A.Clear;
          T:=DFSNum[E.OtherVertex(W).Index];
          if DFSNum[W.Index] < T then begin
            if not StronglyPlanar(E, A) then begin
              S.ClearAndFreeItems;
              Result:=False;
              Exit;
            end;
          end
          else
            A.Add(T);
          B:=TBlock.Create(A);
          while True do begin
            if B.LeftInterlace(S) then TBlock(S.Top).Flip;
            if B.LeftInterlace(S) then begin
              B.Free;
              S.ClearAndFreeItems;
              Result:=False;
              Exit;
            end;
            if B.RightInterlace(S) then B.Combine(S.Pop)
            else
              Break;
          end; {while}
          S.Push(B);
        end; {for}
        while (S.Count > 0) and (TBlock(S.Top).Clean(
          DFSNum[TVertex(Parent[W.Index]).Index]))
        do
          TBlock(S.Pop).Free;
        W:=Parent[W.Index];
      end; {while}
      Att.Clear;
      while S.Count > 0 do  begin
        B:=TBlock(S.Pop);
        if (B.LAtt.Count > 0) and (B.RAtt.Count > 0) and
          (B.LAtt[0] > DFSNum[W0.Index]) and (B.RAtt[0] > DFSNum[W0.Index]) then
        begin
          B.Free;
          S.ClearAndFreeItems;
          Result:=False;
          Exit;
        end;
        B.AddToAtt(Att, DFSNum[W0.Index]);
        B.Free;
      end; {while}
      if W0 <> X then Att.Add(DFSNum[W0.Index]);
      Result:=True;
    finally
      S.Free;
      A.Free;
    end;
  end;

var
  I, J, N, M: Integer;
  B: Bool;
  V, W: TVertex;
  E: TEdge;
  Bucket, NewEdges: TClassList;
  Att: TIntegerVector;
  OldFeatures: TGraphFeatures;
begin
  Result:=True;
  N:=G.VertexCount;
  M:=G.EdgeCount;
  { "минимальные" планарные графы - K5 и B33 }
  if (N >= 5) and (M >= 9) then begin
    AdjLists:=TMultiList.Create(TClassList);
    Parent:=TClassList.Create;
    SimpleCopy:=nil;
    NewEdges:=nil;
    DFSNum:=nil;
    try
      AdjLists.Count:=N;
      Parent.Count:=N;
      DFSNum:=TIntegerVector.Create(N, -1);
      { если в графе есть петли или кратные ребра, то создаем копию без петель
        и кратных ребер }
      OldFeatures:=G.Features;
      try
        { интерпретируем граф как неориентированный (это существенно дл€
          HasParallelEdges) }
        G.Features:=OldFeatures - [Directed];
        B:=G.HasLoops or G.HasParallelEdges;
      finally
        G.Features:=OldFeatures;
      end;
      if B then begin
        SimpleCopy:=TGraph.Create;
        SimpleCopy.AssignSimpleSceleton(G);
        M:=SimpleCopy.EdgeCount;
        G:=SimpleCopy;
      end
      else
        NewEdges:=TClassList.Create;
      { планарный граф с трем€ и более вершинами имеет не более 3N - 6 ребер }
      if M > 3 * N - 6 then begin
        Result:=False;
        Exit;
      end;
      { делаем граф двусв€зным }
      G.MakeBiconnected(NewEdges);
      M:=G.EdgeCount;
      { выполн€ем разметку вершин (DFSNum), ребер (TreeArc) и вычисление LowPt
        значений, затем представл€ем граф в виде упор€доченных в соответствии с
        LowPt списков смежности: AdjList[I] = <список вершин, инцидентных G[I]> }
      TreeArc:=TBoolVector.Create(M, False);
      try
        LowPt1:=TIntegerVector.Create(N, -1);
        LowPt2:=nil;
        try
          LowPt2:=TIntegerVector.Create(N, -1);
          DFSCounter:=0;
          DFS(G[0], nil);
          Buckets:=TMultiList.Create(TClassList);
          try
            { поразр€дна€ сортировка }
            Buckets.Count:=2 * N;
            for I:=0 to G.EdgeCount - 1 do begin
              E:=G.Edges[I];
              GetVW(E, V, W);
              if TreeArc[E.Index] then begin
                J:=2 * LowPt1[W.Index];
                if LowPt2[W.Index] < DFSNum[V.Index] then Inc(J);
              end
              else
                J:=2 * DFSNum[W.Index];
              Buckets[J].Add(E);
            end;
            { создание списков смежности }
            for I:=0 to 2 * N - 1 do
              if not Buckets.IsNil(I) then begin
                Bucket:=Buckets[I];
                for J:=0 to Bucket.Count - 1 do begin
                  E:=Bucket[J];
                  GetVW(E, V, W);
                  AdjLists[V.Index].Add(E);
                end;
              end;
          finally
            Buckets.Free;
          end;
        finally
          LowPt1.Free;
          LowPt2.Free;
        end;
        { поиск путей и попытка геометрической реализации их на плоскости }
        Att:=TIntegerVector.Create(0, -1);
        try
          E:=AdjLists[0][0];
          Result:=StronglyPlanar(E, Att);
        finally
          Att.Free;
        end;
      finally
        TreeArc.Free;
      end;
      { восстанавливаем граф }
      if NewEdges <> nil then NewEdges.FreeItems;
    finally
      AdjLists.Free;
      Parent.Free;
      SimpleCopy.Free;
      NewEdges.Free;
      DFSNum.Free;
    end;
  end;
end;

end.
