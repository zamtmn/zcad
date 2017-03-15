program TestStream;

uses
  F64m, VStream;

{$APPTYPE CONSOLE}

procedure Test;
var
  Strm: TVMemStream;
  A, B: TFloat64Matrix;
begin
  A:=TFloat64Matrix.Create(3, 2, 1.3);
  B:=TFloat64Matrix.Create(3, 2, 0);
  Strm:=TVMemStream.Create;
  try
    A.SetItems([
      3.5, 2.7,
      -0.2, 4.5,
      3.6, 7,2
    ]);
    writeln('A:');
    A.DebugWrite;
    A.WriteToStream(Strm);
    Strm.Seek(0);
    B.ReadFromStream(Strm);
    writeln('B:');
    B.DebugWrite;
  finally
    A.Free;
    B.Free;
    Strm.Free;
  end;
end;

begin
  Test;
  readln;
end.
