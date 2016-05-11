program GraphTestAll;

uses
  TestColoring,
  TestDominatingSet,
  TestEdgeCovering,
  TestEulerCycle,
  TestHamiltonCycle,
  TestMatching,
  TestMaxFlow,
  TestMaxIndependentVertexSet,
  TestMinPaths,
  TestMinRings,
  TestMinWeightPath,
  TestPostman,
  TestReachabilityMatrix,
  TestSST,
  TestStrongComponents,
  TestTree;

{$APPTYPE CONSOLE}

procedure Prompt;
begin
  write('Press Return to continue or ^C to exit...');
  readln;
end;

begin
  TestColoring.Test;
  Prompt;
  TestDominatingSet.Test;
  Prompt;
  TestEdgeCovering.Test;
  Prompt;
  TestEulerCycle.Test;
  Prompt;
  TestHamiltonCycle.Test;
  Prompt;
  TestMatching.Test;
  Prompt;
  TestMaxFlow.Test;
  Prompt;
  TestMaxIndependentVertexSet.Test;
  Prompt;
  TestMinPaths.Test;
  Prompt;
  TestMinRings.Test;
  Prompt;
  TestMinWeightPath.Test;
  Prompt;
  TestPostman.Test;
  Prompt;
  TestReachabilityMatrix.Test;
  Prompt;
  TestSST.Test;
  Prompt;
  TestStrongComponents.Test;
  Prompt;
  TestTree.Test;
  Prompt;
end.
