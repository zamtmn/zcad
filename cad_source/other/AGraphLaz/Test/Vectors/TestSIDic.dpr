program TestSIDic;

uses
  ExtSys,
  Pointerv,
  StrLst,
  Aliasv,
  SIDic;

{$APPTYPE CONSOLE}

procedure Test(StrDicClass: TStrIntDicClass);
var
  SD: TStrIntDic;
  S: TStrLst;
  Counts: TIntegerVector;
begin
  SD:=StrDicClass.Create;
  S:=TStrLst.Create;
  Counts:=TIntegerVector.Create(0, 0);
  try
    SD.Add('asdf', 2);
    SD.Add('asdf', 1);
    SD.Add('Asdf', 3);
    writeln(SD.Find('asdf'));
    writeln(SD.Find('qwerty'));
    writeln(SD.Find('asd'));
    writeln(SD.Data('asdf'));
    writeln(SD.Data('Asdf'));
    SD.CopyToStrLstWithData(S, Counts);
    S.DebugWrite;
    Counts.DebugWrite;
  finally
    SD.Free;
    S.Free;
    Counts.Free;
  end;
end;

begin
  writeln('TStrIntDicClass'#10);
  Test(TStrIntDic);
  writeln(#10'TCaseSensStrIntDic'#10);
  Test(TCaseSensStrIntDic);
  writeln;
  write('Press Return to continue...');
  readln;
end.
