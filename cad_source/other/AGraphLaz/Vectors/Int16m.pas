{ Version 030704. Copyright © Alexey A.Chernobaev, 1996-2003 }

unit Int16m;

interface

{$I VCheck.inc}

uses
  SysUtils, ExtType, ExtSys, Vectors, Aliasv, Int16g, Int16v, Int16sv, Pointerv,
  VFormat,
  {$IFDEF USE_STREAM64}VStrm64{$ELSE}VStream{$ENDIF}, VTxtStrm, VectErr;

type
  BaseType = Int16;
  TGenericBaseVector = TGenericInt16Vector;
  TBaseVector = TInt16Vector;

  {$I NumMatr.def}

  TInt16Matrix = TNumberMatrix;
  TSparseInt16Matrix = TSparseMatrix;
  TSimInt16Matrix = TSimMatrix;
  TSparseSimInt16Matrix = TSparseSimMatrix;

  TSmallIntMatrix = TInt16Matrix;
  TSparseSmallIntMatrix = TSparseInt16Matrix;
  TSparseSimSmallIntMatrix = TSparseSimInt16Matrix;

implementation

uses VectProc;

const
  MatrixProductCode = MatrixProductInt16;

{$I NumMatr.imp}

end.
