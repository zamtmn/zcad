program GrTest2;

uses
  Boolm,
  Graphs,
  WinCrt;

procedure Test;
var
  G: TGraph;
  M: TBoolMatrix;
begin
  G:=TGraph.Create;
  M:=nil;
  try
    G.Features:=[Directed];
    G.AddVertices(5);
    G.AddEdges([0, 1,  0, 4,  1, 0,  1, 2,  2, 4,  3, 1,  3, 4]);
    M:=G.CreateReachabilityMatrix;
    writeln('Reachability Matrix:');
    M.DebugWrite;
  finally
    G.Free;
    M.Free;
  end;
end;

begin
  Test;
  write('Press Return to continue...');
  readln;
end.
