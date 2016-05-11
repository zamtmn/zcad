program TestStrLst;

{$I VCheck.inc}

uses
  SysUtils, ExtType, StrLst;

{$APPTYPE CONSOLE}

type
  ETestError = class(Exception);

procedure Test;
type
  ErrCodes = (EWrongResult, EExceptionExpected);
var
  S1, S2: TStrLst;
  B: Bool;

  procedure Error(ErrCode: ErrCodes);
  begin
    Case ErrCode of
      EWrongResult:
        raise ETestError.Create('Wrong Result');
      EExceptionExpected:
        raise ETestError.Create('Exception Expected');
    End;
  end;

  procedure Check(Vector: TStrLst; const Values: array of String);
  var
    I: Integer;
  begin
    for I:=0 to High(Values) do
      if Vector[I] <> Values[I] then Error(EWrongResult);
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
    if (S1.IndexOf('asdf') <> 1) or (S2.IndexOf('asdf') <> 0) then Error(EWrongResult);
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
