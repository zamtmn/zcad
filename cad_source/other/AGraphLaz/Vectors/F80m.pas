{ Version 030704. Copyright © Alexey A.Chernobaev, 1996-2003 }

unit F80m;

interface

{$I VCheck.inc}

uses
  ExtType, ExtSys, Vectors, Aliasv, F80g, F80v, F80sv, Int16g, Pointerv, VFormat,
  {$IFDEF USE_STREAM64}VStrm64{$ELSE}VStream{$ENDIF}, VTxtStrm, VectErr;

{$DEFINE FLOAT}

type
  BaseType = Float80;
  TGenericBaseVector = TGenericFloat80Vector;
  TBaseVector = TFloat80Vector;

  {$I NumMatr.def}

  TFloat80Matrix = TNumberMatrix;
  TSparseFloat80Matrix = TSparseMatrix;
  TSimFloat80Matrix = TSimMatrix;
  TSparseSimFloat80Matrix = TSparseSimMatrix;

  TExtendedMatrix = TFloat80Matrix;
  TSparseExtendedMatrix = TSparseFloat80Matrix;
  TSparseSimExtendedMatrix = TSparseSimFloat80Matrix;

implementation

uses VectProc;

const
  MatrixProductCode = MatrixProductFloat80;

{$I NumMatr.imp}

{$UNDEF FLOAT}

end.
