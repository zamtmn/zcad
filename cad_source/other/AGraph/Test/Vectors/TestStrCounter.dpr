program TestStrCounter;

uses
  Aliasv,
  StrLst,
  StrCount;

{$APPTYPE CONSOLE}

procedure Test(StrCounterClass: TStrCounterClass);
var
  SC: TStrCounter;
  S: TStrLst;
  Counts: TIntegerVector;
begin
  SC:=StrCounterClass.Create;
  S:=TStrLst.Create;
  Counts:=TIntegerVector.Create(0, 0);
  try
    SC.Add('asdf');
    SC.AddWithCount('qwerty', 2);
    SC.Add('asdf');
    SC.Add('Asdf');
    writeln(SC.Find('asdf'));
    writeln(SC.Find('qwerty'));
    writeln(SC.Find('asd'));
    writeln(SC.StringCount('asdf'));
    writeln(SC.StringCount('qwerty'));
    writeln(SC.StringCount('asd'));
    SC.Dic.CopyToStrLstWithData(S, Counts);
    S.DebugWrite;
    SC.Dic.DebugWrite;
    Counts.DebugWrite;
    writeln('Values in descending order');
    while not SC.IsEmpty do
      writeln(SC.DeleteMax);
  finally
    SC.Free;
    S.Free;
    Counts.Free;
  end;
end;

begin
  writeln('TStrCounter'#10);
  Test(TStrCounter);
  writeln(#10'TCaseSensStrCounter'#10);
  Test(TCaseSensStrCounter);
  writeln;
  write('Press Return to continue...');
  readln;
end.
