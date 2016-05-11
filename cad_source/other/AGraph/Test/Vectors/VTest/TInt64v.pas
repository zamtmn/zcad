unit TInt64v;

interface

uses
  ExtType, VStream, Boolv, TestProc,
  Int8g, UInt8g, Int16g, UInt16g, Int32g, UInt32g, Int64g, Int8v, Int8sv, UInt8v,
  UInt8sv, Int16v, Int16sv, UInt16v, UInt16sv, Int32v, Int32sv, UInt32v,
  UInt32sv, Int64v, Int64sv, F32g, F64g, F80g, F32v, F32sv,
  F64v, F64sv, F80v, F80sv;

procedure TestInt64Vectors;

implementation

procedure TestInt64Vectors;
type
  NumberType = Int64;
  TGenericVector = TGenericInt64Vector;
  TFastVector = TInt64Vector;
  TSparseVector = TSparseInt64Vector;
{$I TestVect.inc}

end.
