program TestGetSpectrum;

uses
  Pointerv,
  WStrLst,
  Aliasv;

{$APPTYPE CONSOLE}

procedure Test(StrLstClass: TWideStrLstClass);
var
  S: TWideStrLst;
  T: TIntegerVector;
begin
  writeln(StrLstClass.ClassName);
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
  Test(TWideStrLst);
  Test(TWinSortWideStrLst);
  Test(TCaseSensWideStrLst);
  Test(TExactWideStrLst);
  write('Press Return to continue...');
  readln;
end.