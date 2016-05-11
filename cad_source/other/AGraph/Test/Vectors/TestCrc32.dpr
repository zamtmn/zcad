program TestCrc32;

{$APPTYPE CONSOLE}

{$I+}

uses
  SysUtils, Crc32;

function FileCrc32(const FileName: String): Integer;
const
  BufSize = 32768;
var
  I: Integer;
  F: File;
  Buf: array [0..BufSize - 1] of Byte;
begin
  AssignFile(F, FileName);
  Reset(F, 1);
  Result:=-1;
  try
    repeat
      BlockRead(F, Buf, BufSize, I);
      Result:=UpdateCrc32(Result, Buf, I);
    until I < BufSize;
    Result:=not Result;
  finally
    Close(F);
  end;
end;

procedure Main;
var
  I: Integer;
  S: String;
begin
  FileMode:=0;
  for I:=1 to ParamCount do begin
    S:=ParamStr(I);
    writeln(S, ' ', IntToHex(FileCrc32(S), 8), 'h');
  end;
end;

begin
  Main;
end.