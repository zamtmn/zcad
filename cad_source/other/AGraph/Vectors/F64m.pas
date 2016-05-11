{ Version 030704. Copyright © Alexey A.Chernobaev, 1996-2003 }

unit F64m;

interface

{$I VCheck.inc}

uses
  ExtType, ExtSys, Vectors, Aliasv, F64g, F64v, F64sv, Int16g, Pointerv, VFormat,
  {$IFDEF USE_STREAM64}VStrm64{$ELSE}VStream{$ENDIF}, VTxtStrm, VectErr;

{$DEFINE FLOAT}

type
  BaseType = Float64;
  TGenericBaseVector = TGenericFloat64Vector;
  TBaseVector = TFloat64Vector;

  {$I NumMatr.def}

  TFloat64Matrix = TNumberMatrix;
  TSparseFloat64Matrix = TSparseMatrix;
  TSimFloat64Matrix = TSimMatrix;
  TSparseSimFloat64Matrix = TSparseSimMatrix;

  TDoubleMatrix = TFloat64Matrix;
  TSparseDoubleMatrix = TSparseFloat64Matrix;
  TSparseSimDoubleMatrix = TSparseSimFloat64Matrix;

implementation

uses VectProc;

const
  MatrixProductCode = MatrixProductFloat64;

{$I NumMatr.imp}

{$UNDEF FLOAT}

end.
