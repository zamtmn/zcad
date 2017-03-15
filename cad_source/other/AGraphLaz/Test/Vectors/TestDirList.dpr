{$APPTYPE CONSOLE}
uses
  StrLst, VFileLst;
var
  S: String;
  Lst: TStrLst;
begin
  Lst:=TStrLst.Create;
  try
    S:=ParamStr(1);
    if S = '' then
      S:='.';
    GetDirList(Lst, S, '');
    Lst.DebugWrite;
  finally
    Lst.Free;
  end;
end.
