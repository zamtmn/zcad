program Cut;

{$APPTYPE CONSOLE}

uses
  SysUtils, VFormat, VFStrm64;

procedure Main;
var
  FromS, ToS: TVFileStream;
begin
  if ParamCount <> 4 then begin
    writeln('Usage: Cut <FromName> <FromOffset> <Length> <ToName>');
    Halt(1);
  end;
  FromS:=TVBufFileStream.Create(ParamStr(1), fmOpenRead + fmShareDenyWrite);
  ToS:=nil;
  try
    ToS:=TVBufFileStream.Create(ParamStr(4), fmCreate);
    FromS.Seek(StdStrToInt64(ParamStr(2)));
    FromS.Copy(ToS, StdStrToInt64(ParamStr(3)));
  finally
    FromS.Free;
    ToS.Free;
  end;
end;

begin
  Main;
end.