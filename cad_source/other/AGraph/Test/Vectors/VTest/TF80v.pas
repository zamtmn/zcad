unit TF80v;

interface

uses
  ExtType, VStream, Boolv, TestProc,
  Int8g, UInt8g, Int16g, UInt16g, Int32g, UInt32g, Int8v, Int8sv, UInt8v,
  UInt8sv, Int16v, Int16sv, UInt16v, UInt16sv, Int32v, Int32sv, UInt32v,
  UInt32sv, F32g, F64g, F80g, F32v, F32sv, F64v, F64sv, F80v, F80sv;

procedure TestFloat80Vectors;

implementation

procedure TestFloat80Vectors;
type
  NumberType = Float80;
  TGenericVector = TGenericFloat80Vector;
  TFastVector = TFloat80Vector;
  TSparseVector = TSparseFloat80Vector;
{$I TestVect.inc}

end.
