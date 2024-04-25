program streamtest;
uses
 SysUtils,Interfaces,
 uzeFileStream;

var
  filename:string='testint.txt';
procedure testold;
var
  oldStream:TZFileStream;
  intValue:integer;
  sum:int64;
  LPTime:Tdatetime;
begin
  LPTime:=now();
  sum:=0;
  oldStream.InitFromFile(filename);
  while oldStream.notEOF do begin
    oldStream.ParseInteger(intValue);
    sum:=sum+intValue;
  end;
  oldStream.destroy;
  lptime:=now()-LPTime;
  writeln('Summ: ',sum);
  writeln('Testold: '+inttostr(round(lptime*10e7))+'msec');
end;
procedure testnew;
var
  newStream:TZFileStream2;
  intValue:integer;
  sum:int64;
  LPTime:Tdatetime;
begin
  LPTime:=now();
  sum:=0;
  newStream:=TZFileStream2.Create(filename,fmOpenRead);
  while newStream.notEOF do begin
    newStream.ParseInteger(intValue);
    sum:=sum+intValue;
  end;
  newStream.Destroy;
  lptime:=now()-LPTime;
  writeln('Summ: ',sum);
  writeln('Testnew: '+inttostr(round(lptime*10e7))+'msec');
end;
begin
  testold;
  testold;
  testold;
  testnew;
  testnew;
  testnew;
  readln;
end.


