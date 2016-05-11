program TestLIS;

uses
  Aliasv,
  Optimize;

{$APPTYPE CONSOLE}

procedure Test;
var
  Sequence, Solution: TIntegerVector;
begin
  Sequence:=TIntegerVector.Create(0, 0);
  Solution:=TIntegerVector.Create(0, 0);
  try
    Sequence.SetItems([1, 2, 8, 9, 3, 2, 4, 6]);
    writeln('Sequence: ');
    Sequence.DebugWrite;
    writeln('Longest Increasing Subsequence Length: ', FindLIS(Sequence, Solution));
    write('Solution: ');
    Solution.DebugWrite;
  finally
    Sequence.Free;
    Solution.Free;
  end;
end;

begin
  Test;
  write('Press Return to continue...');
  readln;
end.
