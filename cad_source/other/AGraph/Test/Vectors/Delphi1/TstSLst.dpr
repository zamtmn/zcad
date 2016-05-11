program TstSLst;

uses
  WinCrt,
  ExtType,
  StrLst,
  TestProc in '..\VTest\TestProc.pas';

procedure Test;
var
  S1, S2: TStrLst;
  B: Bool;

  procedure Check(Vector: TStrLst; const Values: array of String);
  var
    I: Integer;
  begin
    for I:=0 to High(Values) do
      if Vector.Items[I] <> Values[I] then Error(EWrongResult);
  end;

begin
  S1:=TStrLst.Create;
  S2:=TSortedStrLst.Create;
  try
    S1.Add('qwerty');
    S1.Add('asdf');
    Check(S1, ['qwerty', 'asdf']);
    S2.Add('qwerty');
    S2.Add('asdf');
    Check(S2, ['asdf', 'qwerty']);
    if (S1.LastIndexOf('asdf') <> 1) or (S2.LastIndexOf('asdf') <> 0) then Error(EWrongResult);
    if (S1.IndexOf('z') >= 0) or (S2.IndexOf('z') >= 0) then Error(EWrongResult);
    S1.Add('asdf');
    Check(S1, ['qwerty', 'asdf', 'asdf']);
    B:=True;
    try
      S2.Add('asdf');
    except
      B:=False;
    end;
    if B then Error(EExceptionExpected);
  finally
    S1.Free;
    S2.Free;
  end;
  writeln('Ok');
end;

begin
  Test;
  write('Press Return to continue...');
  readln;
end.
