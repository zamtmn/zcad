program TestWStrLst;

uses
  SysUtils, ExtType, WStrLst;

{$APPTYPE CONSOLE}

type
  ETestError = class(Exception);

procedure Test;
var
  S1, S2: TWideStrLst;
  B: Bool;

  procedure Error;
  begin
    raise ETestError.Create('Wrong Result');
  end;

  procedure Check(Vector: TWideStrLst; const Values: array of WideString);
  var
    I: Integer;
  begin
    for I:=0 to High(Values) do
      if Vector[I] <> Values[I] then Error;
  end;

begin
  S1:=TWideStrLst.Create;
  S2:=TSortedWideStrLst.Create;
  try
    S1.Add('qwerty');
    S1.Add('asdf');
    Check(S1, ['qwerty', 'asdf']);
    S2.Add('qwerty');
    S2.Add('asdf');
    Check(S2, ['asdf', 'qwerty']);
    S1.Move(0, 1);
    if not (S1.EqualTo(S2)) then Error;
    if (S1.IndexOf('asdf') <> 0) or (S2.IndexOf('asdf') <> 0) then Error;
    if (S1.IndexOf('z') >= 0) or (S2.IndexOf('z') >= 0) then Error;
    S1.Add('asdf');
    Check(S1, ['asdf', 'qwerty', 'asdf']);
    B:=True;
    try
      S2.Add('asdf');
    except
      B:=False;
    end;
    if B then Error;
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
