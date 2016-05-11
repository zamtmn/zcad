{ Version 030704. Copyright © Alexey A.Chernobaev, 1996-2003 }

unit Int8m;

interface

{$I VCheck.inc}

uses
  SysUtils, ExtType, ExtSys, Vectors, Aliasv, Int8g, Int8v, Int8sv, Int16g,
  Pointerv, VFormat,
  {$IFDEF USE_STREAM64}VStrm64{$ELSE}VStream{$ENDIF}, VTxtStrm, VectErr;

type
  BaseType = Int8;
  TGenericBaseVector = TGenericInt8Vector;
  TBaseVector = TInt8Vector;

  {$I NumMatr.def}

  TInt8Matrix = TNumberMatrix;
  TSparseInt8Matrix = TSparseMatrix;
  TSimInt8Matrix = TSimMatrix;
  TSparseSimInt8Matrix = TSparseSimMatrix;

  TShortIntMatrix = TInt8Matrix;
  TSparseShortIntMatrix = TSparseInt8Matrix;
  TSparseSimShortIntMatrix = TSparseSimInt8Matrix;

implementation

uses VectProc;

const
  MatrixProductCode = MatrixProductInt8;

{$I NumMatr.imp}

end.
