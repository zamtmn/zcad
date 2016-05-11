program TestKnapsackPacking;

uses
  Aliasv,
  Boolv,
  Optimize;

{$APPTYPE CONSOLE}

procedure Test;
const
  Limit = 45;
var
  Values, Volumes: TIntegerVector;
  Solution: TBoolVector;
  I, ValuesSum, VolumesSum: Integer;
begin
  Values:=TIntegerVector.Create(0, 0);
  Volumes:=TIntegerVector.Create(0, 0);
  Solution:=TBoolVector.Create(0, False);
  try
    Values.SetItems([1, 2, 5, 4, 7, 6]);
    Volumes.SetItems([14, 23, 32, 16, 34, 12]);
    write('Values: ');
    Values.DebugWrite;
    write('Volumes: ');
    Volumes.DebugWrite;
    writeln('Volume limit: ', Limit);
    I:=KnapsackPacking(Values, Volumes, Limit, Solution);
    if I <> 11 then begin
      write('Error!');
      readln;
      Exit;
    end;
    writeln('Knapsack packing: ', I);
    Solution.DebugWrite01;
    ValuesSum:=0;
    VolumesSum:=0;
    for I:=0 to Solution.Count - 1 do
      if Solution[I] then begin
        Inc(ValuesSum, Values[I]);
        Inc(VolumesSum, Volumes[I]);
      end;
    writeln('Sum of values: ', ValuesSum);
    writeln('Sum of volumes: ', VolumesSum);
    writeln;
  finally
    Values.Free;
    Volumes.Free;
    Solution.Free;
  end;
end;

begin
  Test;
  write('Press Return to continue...');
  readln;
end.
