program deldup;

uses
  VTxtStrm;

{$APPTYPE CONSOLE}

procedure Main;
var
  Counter: Integer;
  InStream, OutStream: TTextStream;
  LastString, T: String;
begin
  InStream:=TTextStream.Create(ParamStr(1), tsRead);
  OutStream:=nil;
  Counter:=0;
  try
    OutStream:=TTextStream.Create(ParamStr(2), tsRewrite);
    LastString:='';
    while not InStream.EOF do begin
      T:=InStream.ReadString;
      if T = '' then Break;
      if T <> LastString then begin
        OutStream.WriteString(T);
        Inc(Counter);
        LastString:=T;
      end;
    end;
    writeln(Counter);
  finally
    InStream.Free;
    OutStream.Free;
  end;
end;

begin
  if ParamCount > 1 then
    Main
  else
    writeln('Usage: deldup <from_file> <to_file>');
end.
