program TestWStrLstSort;

uses
  Windows, WStrLst;

{$APPTYPE CONSOLE}

procedure Test1(StrLstClass: TWideStrLstClass);
var
  S: TWideStrLst;
begin
  writeln('+++ ', StrLstClass.ClassName, ' +++');
  writeln;
  S:=StrLstClass.Create;
  try
    S.Add('billet');
    S.Add('bills');
    S.Add('bill''s');
    S.Add('cannot');
    S.Add('cant');
    S.Add('can''t');
    S.Add('con');
    S.Add('coop');
    S.Add('co-op');
    S.Add('tanya');
    S.Add('t-aria');
    S.Sort;
    S.DebugWrite;
    writeln;
  finally
    S.Free;
  end;
end;

procedure Test2(StrLstClass: TWideStrLstClass);
var
  S: TWideStrLst;
begin
  writeln('--- ', StrLstClass.ClassName, ' ---');
  writeln;
  S:=StrLstClass.Create;
  try
    S.Add('billet');
    S.Add('bills');
    S.Add('bill''s');
    S.Add('Billet');
    S.Add('Bills');
    S.Add('Bill''s');
    S.Sort;
    S.DebugWrite;
    writeln;
  finally
    S.Free;
  end;
end;

begin
  Test1(TWinSortWideStrLst);
  Test1(TWideStrLst);
  Test2(TCaseSensWideStrLst);
  Test2(TExactWideStrLst);
  write('Press Return to continue...');
  readln;
end.