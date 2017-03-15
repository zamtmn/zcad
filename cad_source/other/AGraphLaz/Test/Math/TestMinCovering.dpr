program TestMinCovering;

uses
  Aliasv,
  Boolm,
  Optimize,
  Pointerv;

{$APPTYPE CONSOLE}

procedure Test;
var
  Solutions: TClassList;
  Matrix: TBoolMatrix;
  I, N: Integer;
begin
  Solutions:=TClassList.Create;
  Matrix:=TBoolMatrix.Create(6, 6, False);
  try
    Matrix.SetItems([
      False, False, True,  False, False, True,
      False,  False, True,  False, True,  True,
      False, True,  False, True,  False, False,
      False, True,  False, False, True,  True,
      True,  False, False, False, True,  False,
      True,  False, False, False, False, True]);
    Matrix.DebugWrite01;
    write('Coverings: ');
    N:=FindMinCoverings(Matrix, -1, Solutions);
    writeln(N);
    for I:=0 to N - 1 do
      TIntegerVector(Solutions[I]).DebugWrite;
  finally
    Solutions.FreeItems;
    Solutions.Free;
    Matrix.Free;
  end;
end;

begin
  Test;
  write('Press Return to continue...');
  readln;
end.
