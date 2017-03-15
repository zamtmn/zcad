program Benchmrk;

{$I VCheck.inc}

uses
  {$IFDEF V_WIN}WinProcs,{$IFNDEF V_32}WinCrt,{$ENDIF}{$ENDIF}
  SysUtils,
  ExtType,
  Boolv,
  Pointerv,
  MultiLst,
  VectStr,
  Graphs,
  GraphIO,
  ExtGraph;

{$IFDEF WIN32}{$APPTYPE CONSOLE}{$ENDIF}

var
  OldTime: DWORD;

procedure StartTimer;
begin
  OldTime:=GetTickCount;
end;

procedure PrintTime;
begin
  write(^I, Abs(GetTickCount - OldTime) / 1000 :0:2, ' sec');
end;

var
  G: TGraph;

procedure TestMinPath;
var
  L: Integer;
begin
  StartTimer;
  L:=G.FindMinPath(G.Vertices[0], G.Vertices[G.VertexCount - 1], nil);
  PrintTime;
  writeln(^I'L = ', L);
end;

procedure TestDFS;
var
  L: Integer;
begin
  StartTimer;
  L:=G.DFSFromVertex(G.Vertices[0]);
  PrintTime;
  writeln(^I'L = ', L);
end;

procedure TestBFS;
var
  L: Integer;
begin
  StartTimer;
  L:=G.BFSFromVertex(G.Vertices[0]);
  PrintTime;
  writeln(^I'L = ', L);
end;

procedure TestMinWeightPath;
var
  I: Integer;
  D, Sum: Float;
  EdgePath, VertexPath: TClassList;
begin
  if not (Weighted in G.Features) then begin
    G.Features:=G.Features + [Weighted];
    for I:=0 to G.EdgeCount - 1 do
      G.Edges[I].Weight:=Random(100);
  end;
  StartTimer;
  EdgePath:=TClassList.Create;
  VertexPath:=TClassList.Create;
  try
    D:=G.FindMinWeightPath(G.Vertices[0], G.Vertices[G.VertexCount - 1], EdgePath);
    PrintTime;
    write(^I'D = ', D :0:2);
    Sum:=0;
    write(^I'Checking... ');
    for I:=0 to EdgePath.Count - 1 do
      Sum:=Sum + TEdge(EdgePath[I]).Weight;
    G.EdgePathToVertexPath(G[0], EdgePath, VertexPath);
    writeln(Sum :0:2);
  finally
    EdgePath.Free;
    VertexPath.Free;
  end;
end;

procedure TestSeparates;
var
  N: Integer;
begin
  StartTimer;
  N:=G.SeparateCount;
  PrintTime;
  writeln(^I'N = ', N);
end;

procedure TestStrongComponents;
var
  N: Integer;
begin
  G.Features:=G.Features + [Directed];
  StartTimer;
  N:=G.FindStrongComponents(nil);
  PrintTime;
  writeln(^I'N = ', N);
end;

procedure TestSST;
var
  D: Float;
begin
  StartTimer;
  D:=G.FindShortestSpanningTree(nil);
  PrintTime;
  writeln(^I'D = ', D :0:2);
end;

procedure TestMinRings;
var
  M: TMultiList;
  N: Integer;
begin
  M:=TMultiList.Create(TClassList);
  try
    StartTimer;
    N:=G.FindMinRingCovering(M);
    PrintTime;
    writeln(^I'N = ', N);
  finally
    M.Free;
  end;
end;

var
  N, M: Integer;
  NewGraph: Bool;
  S: String;
begin
  if ParamCount > 0 then begin
    write('Reading...');
    StartTimer;
    G:=CreateGraphFromGMLFile(ParamStr(1), False);
    PrintTime;
    G.Features:=G.Features - [Directed];
    writeln;
    NewGraph:=False;
  end
  else begin
    write('|V| = ');
    readln(N);
    write('|E| = ');
    readln(M);
    Randomize;
    G:=TGraph.Create;
    write('GetRandomGraph'^I);
    StartTimer;
    GetRandomGraph(G, N, M);
    PrintTime;
    NewGraph:=True;
  end;
  writeln;
  try
    write('Depth-first search:');
    TestDFS;
    write('Breadth-first search:');
    TestBFS;
    write('Min Weight Path'^I);
    TestMinWeightPath;
    write('Separate Components');
    TestSeparates;
    write('Strong Components');
    TestStrongComponents;
    write('Shortest Spanning Tree');
    TestSST;
    write('Min Rings'^I);
    TestMinRings;
    if NewGraph then begin
      write('Enter file name to save graph (or press return): ');
      readln(S);
      S:=Trim(S);
      if S <> '' then begin
        write('writing...');
        StartTimer;
        WriteGraphToGMLFile(G, S, True);
        PrintTime;
        writeln;
      end;
    end;
  finally
    G.Free;
  end;
  write('Press Return to exit...');
  readln;
end.
