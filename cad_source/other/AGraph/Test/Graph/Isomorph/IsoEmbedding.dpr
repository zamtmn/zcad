program IsoEmbedding;

uses
  Windows,
  SysUtils,
  TestIsoEmbed;

{$APPTYPE CONSOLE}

procedure Help;
begin
  writeln('Usage: IsoEmbedding [/all] [/show] sub_gml_file gml_file [rep_count]');
  write('Press Return to continue...');
  readln;
  halt(1);
end;

procedure Main;
const
  ParamPrefix = ['-', '/'];
var
  I, N, iParam, rep_count: Integer;
  FindAll, ShowMatch: Boolean;
  S: String;
  Params: array [0..1] of String;
begin
  N:=ParamCount;
  if N < 2 then Help;
  iParam:=0;
  rep_count:=0;
  FindAll:=False;
  ShowMatch:=False;
  for I:=1 to N do begin
    S:=ParamStr(I);
    if S[1] in ParamPrefix then begin
      S:=LowerCase(S);
      Delete(S, 1, 1);
      if S = 'all' then FindAll:=True
      else if S = 'show' then ShowMatch:=True
      else Help
    end
    else begin
      if iParam > 2 then Help;
      if iParam = 2 then rep_count:=StrToInt(S) else Params[iParam]:=S;
      Inc(iParam);
    end;
  end;
  Test(Params[0], Params[1], rep_count, FindAll, ShowMatch);
end;

begin
  Main;
  write('Press Return to continue...');
  readln;
end.
