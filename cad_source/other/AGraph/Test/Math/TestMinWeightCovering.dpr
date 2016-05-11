program TestMinWeightCovering;

uses
  ExtType,
  Aliasv,
  Boolv,
  Boolm,
  Optimize,
  Pointerv;

{$APPTYPE CONSOLE}

procedure Test;
var
  Solution: TIntegerVector;
  Matrix: TBoolMatrix;
  Weights: TFloatVector;
  Weight: Float;
begin
  Solution:=TIntegerVector.Create(0, 0);
  Matrix:=TBoolMatrix.Create(6, 6, False);
  Weights:=TFloatVector.Create(6, 0);
  try
    Matrix.SetItems([
      False, False, True,  False, False, False,
      False, False, True,  False, True,  True,
      False, True,  False, True,  False, True,
      False, True,  False, False, False,  True,
      True,  False, False, False, True,  False,
      True,  False, False, False, False, True]);
    Matrix.DebugWrite01;
    Weights.SetItems([4, 1, 3, 3, 1, 2]);
    write('Weights: ');
    Weights.DebugWrite;
    write('Min Weight Covering: ');
    if FindMinWeightCovering(Matrix, Weights, Solution, Weight) then begin
      if Weight <> 6 then begin
        write('Error!');
        readln;
        Exit;
      end;
      writeln(Weight :0:4);
    end
    else
      writeln(False);
    Solution.DebugWrite;
  finally
    Solution.Free;
    Matrix.Free;
    Weights.Free;
  end;
end;

begin
  Test;
  write('Press Return to continue...');
  readln;
end.
