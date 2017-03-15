program TestGetSpectrum;

uses
  Pointerv,
  StrLst,
  Aliasv;

{$APPTYPE CONSOLE}

procedure Test(StrLstClass: TStrLstClass);
var
  S: TStrLst;
  T: TIntegerVector;
begin
  writeln;
  S:=StrLstClass.Create;
  T:=TIntegerVector.Create(0, 0);
  try
    S.Add('asdf');
    S.Add('qwerty');
    S.Add('Asdf');
    write('Original list: ');
    S.DebugWrite;
    S.GetSpectrum(S, T);
    write('Different values: ');
    S.DebugWrite;
    write('Spectrum: ');
    T.DebugWrite;
    writeln;
  finally
    S.Free;
    T.Free;
  end;
end;

begin
  writeln('TStrLst');
  Test(TStrLst);
  writeln('TCaseSensStrLst');
  Test(TCaseSensStrLst);
  write('Press Return to continue...');
  readln;
end.