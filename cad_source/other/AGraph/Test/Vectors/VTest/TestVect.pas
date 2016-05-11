unit TestVect;

interface

{$I VCheck.inc}

uses SysUtils;

procedure Test;

implementation

uses
  TBool, TInt8v, TUInt8v, TInt16v, TUInt16v, TInt32v, TUInt32v, TInt64v, TF32v,
  TF64v, TF80v;

procedure Test;
begin
  TestBoolVectors;
  writeln('TestBoolVectors OK');
  TestInt8Vectors;
  writeln('TestInt8Vectors OK');
  TestUInt8Vectors;
  writeln('TestUInt8Vectors OK');
  TestInt16Vectors;
  writeln('TestInt16Vectors OK');
  TestUInt16Vectors;
  writeln('TestUInt16Vectors OK');
  TestInt32Vectors;
  writeln('TestInt32Vectors OK');
  TestUInt32Vectors;
  writeln('TestUInt32Vectors OK');
  TestInt64Vectors;
  writeln('TestInt64Vectors OK');
  TestFloat32Vectors;
  writeln('TestFloat32Vectors OK');
  TestFloat64Vectors;
  writeln('TestFloat64Vectors OK');
  TestFloat80Vectors;
  writeln('TestFloat80Vectors OK');
  writeln;
end;

end.
