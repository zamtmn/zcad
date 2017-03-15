unit TestReachabilityMatrix;

interface

uses
  Boolm,
  Graphs;

procedure Test;

implementation

procedure Test;
var
  G: TGraph;
  M: TBoolMatrix;
begin
  writeln('*** Reachability Matrix ***');
  G:=TGraph.Create;
  G.Features:=[Directed];
  M:=nil;
  try
    G.AddVertices(5);
    G.AddEdges([0, 1,  0, 4,  1, 0,  1, 2,  2, 4,  3, 1,  3, 4]);
    M:=G.CreateReachabilityMatrix;
    writeln('Reachability Matrix:');
    M.DebugWrite01;
  finally
    G.Free;
    M.Free;
  end;
end;

end.
 
