unit TestMatr;

interface

{$I VCheck.inc}

uses SysUtils, TestProc;

procedure Test;

implementation

uses
  Int8g, UInt8g, Int16g, UInt16g, Int32g, UInt32g, Int64g,
  F32g, F64g, F80g,
  Int8v, UInt8v, Int16v, UInt16v, Int32v, UInt32v, Int64v,
  F32v, F64v, F80v,
  Int8m, UInt8m, Int16m, UInt16m, Int32m, UInt32m, Int64m,
  F32m, F64m, F80m, Aliasv, Aliasm,
  ExtType, VStream;

procedure TestInt8Matrixes;
type
  NumberType = Int8;
  TGenericNumberVector = TGenericInt8Vector;
  TNumberVector = TInt8Vector;
  TMatrix = TInt8Matrix;
  TSparseMatrix = TSparseInt8Matrix;
  TSimMatrix = TSimInt8Matrix;
  TSparseSimMatrix = TSparseSimInt8Matrix;
{$I TestMatr.inc}

procedure TestUInt8Matrixes;
type
  NumberType = UInt8;
  TGenericNumberVector = TGenericUInt8Vector;
  TNumberVector = TUInt8Vector;
  TMatrix = TUInt8Matrix;
  TSparseMatrix = TSparseUInt8Matrix;
  TSimMatrix = TSimUInt8Matrix;
  TSparseSimMatrix = TSparseSimUInt8Matrix;
{$I TestMatr.inc}

procedure TestInt16Matrixes;
type
  NumberType = Int16;
  TGenericNumberVector = TGenericInt16Vector;
  TNumberVector = TInt16Vector;
  TMatrix = TInt16Matrix;
  TSparseMatrix = TSparseInt16Matrix;
  TSimMatrix = TSimInt16Matrix;
  TSparseSimMatrix = TSparseSimInt16Matrix;
{$I TestMatr.inc}

procedure TestUInt16Matrixes;
type
  NumberType = UInt16;
  TGenericNumberVector = TGenericUInt16Vector;
  TNumberVector = TUInt16Vector;
  TMatrix = TUInt16Matrix;
  TSparseMatrix = TSparseUInt16Matrix;
  TSimMatrix = TSimUInt16Matrix;
  TSparseSimMatrix = TSparseSimUInt16Matrix;
{$I TestMatr.inc}

procedure TestInt32Matrixes;
type
  NumberType = Int32;
  TGenericNumberVector = TGenericInt32Vector;
  TNumberVector = TInt32Vector;
  TMatrix = TInt32Matrix;
  TSparseMatrix = TSparseInt32Matrix;
  TSimMatrix = TSimInt32Matrix;
  TSparseSimMatrix = TSparseSimInt32Matrix;
{$I TestMatr.inc}

procedure TestUInt32Matrixes;
type
  NumberType = UInt32;
  TGenericNumberVector = TGenericUInt32Vector;
  TNumberVector = TUInt32Vector;
  TMatrix = TUInt32Matrix;
  TSparseMatrix = TSparseUInt32Matrix;
  TSimMatrix = TSimUInt32Matrix;
  TSparseSimMatrix = TSparseSimUInt32Matrix;
{$I TestMatr.inc}

procedure TestInt64Matrixes;
type
  NumberType = Int64;
  TGenericNumberVector = TGenericInt64Vector;
  TNumberVector = TInt64Vector;
  TMatrix = TInt64Matrix;
  TSparseMatrix = TSparseInt64Matrix;
  TSimMatrix = TSimInt64Matrix;
  TSparseSimMatrix = TSparseSimInt64Matrix;
{$I TestMatr.inc}

procedure TestFloat32Matrixes;
type
  NumberType = Float32;
  TGenericNumberVector = TGenericFloat32Vector;
  TNumberVector = TFloat32Vector;
  TMatrix = TFloat32Matrix;
  TSparseMatrix = TSparseFloat32Matrix;
  TSimMatrix = TSimFloat32Matrix;
  TSparseSimMatrix = TSparseSimFloat32Matrix;
{$I TestMatr.inc}

procedure TestFloat64Matrixes;
type
  NumberType = Float64;
  TGenericNumberVector = TGenericFloat64Vector;
  TNumberVector = TFloat64Vector;
  TMatrix = TFloat64Matrix;
  TSparseMatrix = TSparseFloat64Matrix;
  TSimMatrix = TSimFloat64Matrix;
  TSparseSimMatrix = TSparseSimFloat64Matrix;
{$I TestMatr.inc}

procedure TestFloat80Matrixes;
type
  NumberType = Float80;
  TGenericNumberVector = TGenericFloat80Vector;
  TNumberVector = TFloat80Vector;
  TMatrix = TFloat80Matrix;
  TSparseMatrix = TSparseFloat80Matrix;
  TSimMatrix = TSimFloat80Matrix;
  TSparseSimMatrix = TSparseSimFloat80Matrix;
{$I TestMatr.inc}

procedure Test;
begin
  TestInt8Matrixes;
  writeln('TestInt8Matrixes OK');
  TestUInt8Matrixes;
  writeln('TestUInt8Matrixes OK');
  TestInt16Matrixes;
  writeln('TestInt16Matrixes OK');
  TestUInt16Matrixes;
  writeln('TestUInt16Matrixes OK');
  TestInt32Matrixes;
  writeln('TestInt32Matrixes OK');
  TestUInt32Matrixes;
  writeln('TestUInt32Matrixes OK');
  TestInt64Matrixes;
  writeln('TestInt64Matrixes OK');
  TestFloat32Matrixes;
  writeln('TestFloat32Matrixes OK');
  TestFloat64Matrixes;
  writeln('TestFloat64Matrixes OK');
  TestFloat80Matrixes;
  writeln('TestFloat80Matrixes OK');
  writeln;
end;

end.
