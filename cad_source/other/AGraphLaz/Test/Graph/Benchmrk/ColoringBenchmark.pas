unit ColoringBenchmark;

interface

uses
  Windows,
  SysUtils,
  Aliasv,
  Graphs,
  ExtGraph,
  GrColor,
  GraphIO;

procedure Test;

implementation

var
  OldTime: LongInt;

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

procedure TestColoring;
var
  C: Integer;
  Colors: TIntegerVector;
begin
  Colors:=TIntegerVector.Create(0, 0);
  try
    StartTimer;
    C:=GraphColoring(G, Colors);
    PrintTime;
    writeln(^I' C = ', C);
    if not CheckColoring(G, Colors) then
      raise Exception.Create('CheckColoring Error!');
    if ApproximateColoring1(G, Colors) < C then
      raise Exception.Create('Coloring is not optimal!');
  finally
    Colors.Free;
  end;
end;

procedure Test;
const
  MaxVertexCount = 500;
  MaxEdgeCount = 1000;
var
  OldRandSeed: LongInt;
  I, MaxCount: Integer;
begin
  writeln('*** Coloring of Random Graphs ***'#10);
  if ParamCount > 0 then RandSeed:=StrToInt(ParamStr(1)) else Randomize;
  if ParamCount > 1 then MaxCount:=StrToInt(ParamStr(2)) else MaxCount:=MaxInt;
  G:=TGraph.Create;
  try
    for I:=1 to MaxCount do begin
      OldRandSeed:=RandSeed;
      GetRandomGraph(G, Random(MaxVertexCount) + 1, Random(MaxEdgeCount) + 1);
      write(#13, I, ' |V|=', G.VertexCount, ' |E|=', G.EdgeCount,
        ' RandSeed=', OldRandSeed, ^I^I);
      try
        TestColoring;
      except
        writeln;
        writeln('Error! RandSeed=', OldRandSeed, ' |V|=', G.VertexCount,
          ' |E|=', G.EdgeCount);
        WriteGraphToGMLFile(G, ExtractFilePath(ParamStr(0)) + 'err.gml', False);
        writeln('Press Return to resume...');
        readln;
      end;
    end;
  finally
    G.Free;
  end;
end;

end.