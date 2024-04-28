program streamtest;
uses
 SysUtils,Interfaces,
 uzeFileStream;

var
  filename:string='testint.txt';
procedure testReadLn;
var
  oldStream:text;
  intValue:integer;
  sum:int64;
  LPTime:Tdatetime;
  s:string;
begin
  LPTime:=now();
  sum:=0;
  intValue:=1;
  assign(oldStream,filename);
  reset(oldStream);
  while not EOF(oldStream) do begin
    readln(oldStream,s);
    sum:=sum+intValue;
  end;
  Close(oldStream);
  lptime:=now()-LPTime;
  //writeln('Summ: ',sum);
  writeln('ReadLn: '+inttostr(round(lptime*10e7))+'msec');
end;

procedure testTZctnrVectorBytes;
var
  oldStream:TZFileStream;
  intValue:integer;
  sum:int64;
  LPTime:Tdatetime;
  s:string;
begin
  LPTime:=now();
  sum:=0;
  intValue:=1;
  oldStream.InitFromFile(filename);
  while oldStream.notEOF do begin
    //oldStream.ParseInteger(intValue);
    s:=oldStream.ReadString;
    sum:=sum+intValue;
  end;
  oldStream.destroy;
  lptime:=now()-LPTime;
  //writeln('Summ: ',sum);
  writeln('TZctnrVectorBytes: '+inttostr(round(lptime*10e7))+'msec');
end;
procedure testMMF;
var
  newStream:TZFileStream2;
  mr:TZInMemoryReader;
  intValue:integer;
  sum:int64;
  LPTime:Tdatetime;
  s:String;
begin
  LPTime:=now();
  sum:=0;
  intValue:=1;
  newStream:=TZFileStream2.Create(filename,fmOpenRead);
  mr:=TZInMemoryReader.Create;
  mr.setSource(newStream);
  while not mr.EOF do begin
    s:=mr.ParseString;
    sum:=sum+intValue;
  end;
  newStream.Destroy;
  mr.Destroy;
  lptime:=now()-LPTime;
  //writeln('Summ: ',sum);
  writeln('MMF: '+inttostr(round(lptime*10e7))+'msec');
end;
begin
  testReadLn;
  testTZctnrVectorBytes;
  testMMF;
  readln;
end.


