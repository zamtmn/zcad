program TestStrLstSort;

uses
  Windows, StrLst;

{$APPTYPE CONSOLE}

procedure Test1(StrLstClass: TStrLstClass);
var
  S: TStrLst;
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

procedure Test2(StrLstClass: TStrLstClass);
var
  S: TStrLst;
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
  Test1(TStrLst);
  Test1(TASCIIStrLst);
  Test2(TCaseSensStrLst);
  write('(check: ');
  write(CompareString(LOCALE_USER_DEFAULT, 0, 'billet', -1, 'Billet', -1) - 2);
  write(', ');
  write(CompareString(LOCALE_USER_DEFAULT, 0, 'Billet', -1, 'bills', -1) - 2);
  write(', ');
  write(CompareString(LOCALE_USER_DEFAULT, 0, 'bills', -1, 'bill''s', -1) - 2);
  write(', ');
  write(CompareString(LOCALE_USER_DEFAULT, 0, 'bill''s', -1, 'Bills', -1) - 2);
  write(', ');
  write(CompareString(LOCALE_USER_DEFAULT, 0, 'Bills', -1, 'Bill''s', -1) - 2);
  writeln(')');
  writeln;
  Test2(TExactStrLst);
  write('Press Return to continue...');
  readln;
end.