{ Version 000602 }
{ Модуль переработан с учетом того, что графы имеют одинаковое количество вершин }

unit VFState;

interface

{$I VCheck.inc}

uses
  ExtType, AttrType, Aliasv, UInt8v, Int16v, UInt16v, Int64v, Pointerv, VFGraph,
  Graphs;

const
  ST_CORE = $01;
  ST_TERM_IN = $02;
  ST_TERM_OUT = $04;

  AttrPtr = '#Ptr';
  AttrList = '#List';

type
  TEdgeCompare = class
  private
    FCompare: TCompareFunc;
    FCopied, FDirected, FExactCompare: Bool;
  public
    constructor Create(CompareFunc: TCompareFunc; ACopied, ADirected,
      AnExactCompare: Bool);
    { AnExactCompare = False: количества и атрибуты кратных ребер должны совпадать;
      AnExactCompare = True: для каждого кратного ребра в Item1 должно быть
      соответствующее ребро в Item2 с равными атрибутами }
    function Compare(E1, E2: TEdge; FromVertex1, FromVertex2: TVertex): Integer;
  end;

  TState = class
  private
    core_len, t1in_len, t1out_len, t2in_len, t2out_len, N: Integer;
    g1, g2: TVFGraph;
    Spectrum1, Spectrum2: TInt64Vector;
    CompareVertices: TCompareFunc;
    CompareEdges: TEdgeCompare;
  public
    constructor Create(AGraph1, AGraph2: TGraph; ASpectrum1, ASpectrum2: TInt64Vector;
      ACompareVertices: TCompareFunc; ACompareEdges: TEdgeCompare);
    constructor Copy(Source: TState);
    destructor Destroy; override;
    function NextPair(var pn1, pn2: Int32; prev_n1, prev_n2: Int32): Bool;
    function IsFeasiblePair(node1, node2: Int32): Bool;
    procedure AddPair(node1, node2: Int32);
    function IsGoal: Bool;
    function IsDead: Bool;
    procedure GetCoreSet(c: TIntegerVector);
    procedure Pack;
    procedure Unpack;

    property CoreLen: Integer read core_len;
  end;

implementation

{ TEdgeCompare }

constructor TEdgeCompare.Create(CompareFunc: TCompareFunc; ACopied, ADirected,
  AnExactCompare: Bool);
begin
  inherited Create;
  FCompare:=CompareFunc;
  FCopied:=ACopied;
  FDirected:=ADirected;
  FExactCompare:=AnExactCompare;
end;

{$IFDEF NOWARN}{$WARNINGS OFF}{$ENDIF}
function TEdgeCompare.Compare(E1, E2: TEdge; FromVertex1, FromVertex2: TVertex): Integer;
{ Item1 и Item2 должны иметь один и только один из атрибутов AttrPtr и AttrList }
var
  I, J, N, M: Integer;
  B1, B2, FreeList: Bool;
  P1, P2: Pointer;
  List1, List2: TClassList;
begin
  if not FCopied then
    Result:=FCompare(E1, E2)
  else begin
    P1:=E1.AsPointer[AttrPtr];
    P2:=E2.AsPointer[AttrPtr];
    B1:=P1 <> nil;
    B2:=P2 <> nil;
    if B1 and B2 then
      if Assigned(FCompare) then
        Result:=FCompare(P1, P2)
      else
        Result:=0
    else begin
      FreeList:=False;
      try
        if B1 <> B2 then begin
          if B2 then begin { ребро Item1 представляет группу кратных ребер }
            Result:=1;
            Exit;
          end;
          { ребро Item2 представляет группу кратных ребер }
          if FExactCompare then begin
            Result:=-1;
            Exit;
          end;
          { InexactCompare = True }
          List1:=TClassList.Create;
          FreeList:=True;
          List1.Count:=1;
          List1[0]:=P1;
        end
        else
          List1:=E1.Local.AsAutoFree[AttrList];
        List2:=E2.Local.AsAutoFree[AttrList];
        N:=List1.Count;
        M:=List2.Count;
        Result:=N - M;
        if FExactCompare or (Result = 0) then
          if (Result = 0) and (FDirected or Assigned(FCompare)) then begin
            if FDirected then
              for I:=0 to N - 1 do begin
                Result:=Ord((TEdge(List1[I]).V1 = FromVertex1)) -
                  Ord(TEdge(List2[I]).V2 = FromVertex2);
                if Result <> 0 then Exit;
              end;
            if Assigned(FCompare) then
              for I:=0 to N - 1 do begin
                Result:=FCompare(List1[I], List2[I]);
                if Result <> 0 then Exit;
              end;
          end
          else
        else
          if Result < 0 then
            if Assigned(FCompare) then begin
              I:=0;
              J:=0;
              repeat
                P1:=List1[I];
                P2:=List2[J];
                Result:=-FCompare(P1, P2);
                if Result > 0 then Exit; { Result < 0 => Return(-Result) }
                if Result = 0 then begin
                  Inc(I);
                  if I >= N then Exit;
                  Inc(J);
                end
                else { Result > 0 }
                  Inc(J);
              until J >= M;
              Result:=1;
            end
            else
              Result:=0;
      finally
        if FreeList then List1.Free;
      end;
    end;
  end;
end;
{$IFDEF NOWARN}{$WARNINGS ON}{$ENDIF}

{ TState }

constructor TState.Create(AGraph1, AGraph2: TGraph; ASpectrum1, ASpectrum2: TInt64Vector;
  ACompareVertices: TCompareFunc; ACompareEdges: TEdgeCompare);
begin
  inherited Create;
  N:=AGraph1.VertexCount;
  g1:=TVFGraph.Create(AGraph1);
  g2:=TVFGraph.Create(AGraph2);
  Spectrum1:=ASpectrum1;
  Spectrum2:=ASpectrum2;
  CompareVertices:=ACompareVertices;
  CompareEdges:=ACompareEdges;
end;

constructor TState.Copy(Source: TState);
begin
  inherited Create;
  core_len:=Source.core_len;
  t1in_len:=Source.t1in_len;
  t1out_len:=Source.t1out_len;
  t2in_len:=Source.t2in_len;
  t2out_len:=Source.t2out_len;
  N:=Source.N;
  g1:=TVFGraph.Copy(Source.g1);
  g2:=TVFGraph.Copy(Source.g2);
  Spectrum1:=Source.Spectrum1;
  Spectrum2:=Source.Spectrum2;
  CompareVertices:=Source.CompareVertices;
  CompareEdges:=Source.CompareEdges;
end;

destructor TState.Destroy;
begin
  g1.Free;
  g2.Free;
  inherited Destroy;
end;

function TState.NextPair(var pn1, pn2: Int32; prev_n1, prev_n2: Int32): Bool;
var
  cond1, cond2: Byte;
begin
  Result:=False;
  if (t1out_len > 0) and (t2out_len > 0) then begin
    cond1:=ST_TERM_OUT;
    cond2:=ST_TERM_OUT;
  end
  else if (t1in_len > 0) and (t2in_len > 0) then begin
    cond1:=ST_TERM_IN;
    cond2:=ST_TERM_IN;
  end
  else if (N - t1in_len - t1out_len > 0) and (N - t2in_len - t2out_len > 0)
  then begin
    cond1:=$FF;
    cond2:=0;
  end
  else
    Exit;
  if prev_n1 = NULL_NODE then prev_n1:=0;
  if prev_n2 = NULL_NODE then prev_n2:=0 else Inc(prev_n2);
  while (prev_n1 < N) and (g1.NodeFlags[prev_n1] and cond1 <> cond2) do begin
    Inc(prev_n1);
    prev_n2:=0;
  end;
  if prev_n1 >= N then Exit;
  while (prev_n2 < N) and (g2.NodeFlags[prev_n2] and cond1 <> cond2) do
    Inc(prev_n2);
  if prev_n2 < N then begin
    pn1:=prev_n1;
    pn2:=prev_n2;
    Result:=True;
  end;
end;

function TState.IsFeasiblePair(node1, node2: Int32): Bool;

  function CheckInEdge(g1, g2: TVFGraph; Neighbours: TCoreVector;
    node1, node2: Int32; var termin, termout, new: Integer): Bool;
  var
    I, Other: Integer;
    Flags: Byte;
    E1, E2: TEdge;
  begin
    for I:=0 to Neighbours.Count - 1 do begin
      Other:=Neighbours[I];
      flags:=g1.NodeFlags[Other];
      if flags = 0 then Inc(new)
      else
        if flags and ST_CORE <> 0 then begin
          E1:=g1.GetEdge(Other, node1);
          E2:=g2.GetEdge(g1.core[Other], node2);
          if (E2 = nil) or
            Assigned(CompareEdges) and
            (CompareEdges.Compare(E1, E2, E1.V1, E2.V2) <> 0)
          then begin
            Result:=False;
            Exit;
          end;
        end
        else begin
          if flags and ST_TERM_IN <> 0 then Inc(termin);
          if flags and ST_TERM_OUT <> 0 then Inc(termout);
        end;
    end;
    Result:=True;
  end;

  function CheckOutEdge(g1, g2: TVFGraph; Neighbours: TCoreVector;
    node1, node2: Int32; var termin, termout, new: Integer): Bool;
  var
    I, Other: Integer;
    flags: Byte;
    E1, E2: TEdge;
  begin
    for I:=0 to Neighbours.Count - 1 do begin
      Other:=Neighbours[I];
      flags:=g1.NodeFlags[Other];
      if flags = 0 then Inc(new)
      else
        if flags and ST_CORE <> 0 then begin
          E1:=g1.GetEdge(node1, Other);
          E2:=g2.GetEdge(node2, g1.core[Other]);
          if (E2 = nil) or
            Assigned(CompareEdges) and
            (CompareEdges.Compare(E1, E2, E1.V1, E2.V2) <> 0)
          then begin
            Result:=False;
            Exit;
          end;
        end
        else begin
          if flags and ST_TERM_IN <> 0 then Inc(termin);
          if flags and ST_TERM_OUT <> 0 then Inc(termout);
        end;
    end;
    Result:=True;
  end;

var
  termin1, termin2, termout1, termout2, new1, new2: Integer;
  Neighbours1, Neighbours2: TCoreVector;
begin
  Result:=False;
  if (Spectrum1[node1] = Spectrum2[node2]) and
    (not Assigned(CompareVertices) or
    (CompareVertices(g1.Graph.Vertices[node1], g2.Graph.Vertices[node2]) = 0))
  then begin
    termin1:=0; termin2:=0; termout1:=0; termout2:=0; new1:=0; new2:=0;
    Neighbours1:=g1.InNeighbours[node1];
    Neighbours2:=g2.InNeighbours[node2];
    if (Neighbours1.Count = Neighbours2.Count) and
      CheckInEdge(g1, g2, Neighbours1, node1, node2, termin1, termout1, new1) and
      CheckInEdge(g2, g1, Neighbours2, node2, node1, termin2, termout2, new2)
    then begin
      if g1.IsDirected then begin
        Neighbours1:=g1.OutNeighbours[node1];
        Neighbours2:=g2.OutNeighbours[node2];
        if not ((Neighbours1.Count = Neighbours2.Count) and
          CheckOutEdge(g1, g2, Neighbours1, node1, node2, termin1, termout1, new1) and
          CheckOutEdge(g2, g1, Neighbours2, node2, node1, termin2, termout2, new2))
        then Exit;
      end;
      Result:=(termin1 = termin2) and (termout1 = termout2) and (new1 = new2);
    end;
  end;
end;

procedure TState.AddPair(node1, node2: Int32);

  procedure Process(Neighbours: TCoreVector; NodeFlags: TByteVector;
    var in_len, out_len: Integer);
  var
    I, Other: Integer;
    flags: Byte;
  begin
    for I:=0 to Neighbours.Count - 1 do begin
      Other:=Neighbours[I];
      flags:=NodeFlags[Other];
      if flags and (ST_CORE or ST_TERM_IN) = 0 then begin
        NodeFlags.OrItem(Other, ST_TERM_IN);
        Inc(in_len);
      end;
      if flags and (ST_CORE or ST_TERM_OUT) = 0 then begin
        NodeFlags.OrItem(Other, ST_TERM_OUT);
        Inc(out_len);
      end;
    end;
  end;

var
  flags: Byte;
begin
  flags:=g1.NodeFlags[node1];
  if flags and ST_TERM_IN <> 0 then Dec(t1in_len);
  if flags and ST_TERM_OUT <> 0 then Dec(t1out_len);
  flags:=g2.NodeFlags[node2];
  if flags and ST_TERM_IN <> 0 then Dec(t2in_len);
  if flags and ST_TERM_OUT <> 0 then Dec(t2out_len);
  g1.NodeFlags[node1]:=ST_CORE;
  g1.core[node1]:=node2;
  g2.NodeFlags[node2]:=ST_CORE;
  g2.core[node2]:=node1;
  Inc(core_len);
  Process(g1.InNeighbours[node1], g1.NodeFlags, t1in_len, t1out_len);
  Process(g2.InNeighbours[node2], g2.NodeFlags, t2in_len, t2out_len);
  if g1.IsDirected then begin
    Process(g1.OutNeighbours[node1], g1.NodeFlags, t1in_len, t1out_len);
    Process(g2.OutNeighbours[node2], g2.NodeFlags, t2in_len, t2out_len);
  end;
end;

function TState.IsGoal: Bool;
begin
  Result:=core_len = N;
end;

function TState.IsDead: Bool;
begin
  Result:=not ((t1out_len > 0) and (t2out_len > 0) or
    (t1in_len > 0) and (t2in_len > 0) or
    (N - t1in_len - t1out_len > 0) and (N - t2in_len - t2out_len > 0));
end;

procedure TState.GetCoreSet(c: TIntegerVector);
var
  I, K: Integer;
begin
  K:=g1.Core.Count;
  c.Count:=K;
  for I:=0 to K - 1 do
    c[I]:=g1.Core[I];
end;

procedure TState.Pack;
begin
  if CoreLen < N div 4 then begin
    g1.Pack;
    g2.Pack;
  end;
end;

procedure TState.Unpack;
begin
  if CoreLen < N div 4 then begin
    g1.Unpack;
    g2.Unpack;
  end;
end;

end.
