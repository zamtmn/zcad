program vsort;
{ sort demo }

uses
  StrLst,
  VTxtStrm;

{$APPTYPE CONSOLE}

procedure Main;
var
  InStream, OutStream: TTextStream;
  S: TStrLst;
begin
  InStream:=TTextStream.Create(ParamStr(1), tsRead);
  OutStream:=nil;
  S:=nil;
  try
    OutStream:=TTextStream.Create(ParamStr(2), tsRewrite);
    write('Reading...');
    S:=TStrLst.Create;
    S.ReadFromTextStream(InStream);
    writeln;
    write('Sorting...');
    S.Sort;
    writeln;
    write('Writing...');
    S.WriteToTextStream(OutStream);
    writeln('done');
  finally
    S.Free;
    InStream.Free;
    OutStream.Free;
  end;
end;

begin
  if ParamCount > 1 then
    Main
  else
    writeln('Usage: vsort <from_file> <to_file>');
end.
