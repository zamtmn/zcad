program buftest;
uses
 SysUtils,Interfaces,
 bufstream,Classes;

const
  filename:string='testint.txt';

procedure BufferedFileStreamByByte;
var
  BufferedFileStream:TBufferedFileStream;
  fileSize:int64;
  LPTime:Tdatetime;
  CurrentByte:byte;
begin
  LPTime:=now();
  fileSize:=0;
  BufferedFileStream:=TBufferedFileStream.Create(filename,fmOpenRead);
  while BufferedFileStream.position<BufferedFileStream.Size do begin
    CurrentByte:=BufferedFileStream.ReadByte;
    inc(fileSize);
  end;
  BufferedFileStream.Destroy;
  lptime:=now()-LPTime;
  writeln('fileSize: ',fileSize);
  writeln('BufferedFileStream.ReadByte: '+inttostr(round(lptime*10e7))+'msec');
end;

procedure MemStreamByByte;
var
  memStream:TMemoryStream;
  fileSize:int64;
  LPTime:Tdatetime;
  CurrentByte:byte;
  i:integer;
begin
  LPTime:=now();
  fileSize:=0;
  memStream:=TMemoryStream.Create;
  memStream.LoadFromFile(filename);
  for i:=0 to memStream.Size-1 do begin
    CurrentByte:=pbyte(memStream.Memory)[i];
    inc(fileSize);
  end;
  memStream.Destroy;
  lptime:=now()-LPTime;
  writeln('fileSize: ',fileSize);
  writeln('pbyte(memStream.Memory)[i]: '+inttostr(round(lptime*10e7))+'msec');
end;
begin
  MemStreamByByte;
  BufferedFileStreamByByte;
  readln;
end.


