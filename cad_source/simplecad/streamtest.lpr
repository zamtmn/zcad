program streamtest;
uses
 SysUtils,Interfaces,
 uzeFileStream,bufstream,Classes;

var
  filename:string='C:\1brc-ObjectPascal\bin\test15';//}'testint.txt';
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
  writeln('Lines readed: ',sum);
  writeln('ReadLn: '+inttostr(round(lptime*10e7))+'msec');
end;

procedure testTZctnrVectorBytes;
var
  oldStream:TZFileStream;
  intValue:integer;
  LinesCount:int64;
  LPTime:Tdatetime;
  s:string;
begin
  LPTime:=now();
  LinesCount:=0;
  intValue:=1;
  oldStream.InitFromFile(filename);
  while oldStream.notEOF do begin
    //oldStream.ParseInteger(intValue);
    s:=oldStream.ReadString;
    LinesCount:=LinesCount+intValue;
  end;
  oldStream.destroy;
  lptime:=now()-LPTime;
  writeln('Lines readed: ',LinesCount);
  writeln('TZctnrVectorBytes: '+inttostr(round(lptime*10e7))+'msec');
end;
procedure testMMF;
var
  newStream:TZFileStream2;
  mr:TZInMemoryReader;
  intValue:integer;
  LinesCount:int64;
  LPTime:Tdatetime;
  s:String;
begin
  LPTime:=now();
  LinesCount:=0;
  intValue:=1;
  newStream:=TZFileStream2.Create(filename,fmOpenRead);
  mr:=TZInMemoryReader.Create;
  mr.setSource(newStream);
  while not mr.EOF do begin
    s:=mr.ParseString;
    LinesCount:=LinesCount+intValue;
  end;
  {while mr.ParseString(s) do begin
    //s:=mr.ParseString;
    LinesCount:=LinesCount+intValue;
  end;}
  newStream.Destroy;
  mr.Destroy;
  lptime:=now()-LPTime;
  writeln('Lines readed: ',LinesCount);
  writeln('MMF: '+inttostr(round(lptime*10e7))+'msec');
end;
procedure testBufferedFileStream;
var
  newStream:TBufferedFileStream;
  bs:TZReadBufStream;
  mr:TZInMemoryReader;
  intValue:integer;
  LinesCount:int64;
  LPTime:Tdatetime;
  s:String;
begin
  LPTime:=now();
  LinesCount:=0;
  intValue:=1;
  newStream:=TBufferedFileStream.Create(filename,fmOpenRead);
  bs:=TZReadBufStream.Create(newStream);
  bs.MoveMemViewProc(0);
  mr:=TZInMemoryReader.Create;
  mr.setSource(bs);
  while not mr.EOF do begin
    s:=mr.ParseString;
    LinesCount:=LinesCount+intValue;
  end;
  newStream.Destroy;
  bs.Destroy;
  mr.Destroy;
  lptime:=now()-LPTime;
  writeln('Lines readed: ',LinesCount);
  writeln('BufferedFileStream: '+inttostr(round(lptime*10e7))+'msec');
end;
begin
  //testReadLn;
  //testTZctnrVectorBytes;
  testMMF;
  //testBufferedFileStream;
  //readln;
end.


