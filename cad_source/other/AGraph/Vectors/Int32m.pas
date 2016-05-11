{ Version 030704. Copyright © Alexey A.Chernobaev, 1996-2003 }

unit Int32m;

interface

{$I VCheck.inc}

uses
  SysUtils, ExtType, ExtSys, Vectors, Aliasv, Int32g, Int32v, Int32sv, Int16g,
  Pointerv, VFormat,
  {$IFDEF USE_STREAM64}VStrm64{$ELSE}VStream{$ENDIF}, VTxtStrm, VectErr;

type
  BaseType = Int32;
  TGenericBaseVector = TGenericInt32Vector;
  TBaseVector = TInt32Vector;

  {$I NumMatr.def}

  TInt32Matrix = TNumberMatrix;
  TSparseInt32Matrix = TSparseMatrix;
  TSimInt32Matrix = TSimMatrix;
  TSparseSimInt32Matrix = TSparseSimMatrix;

  TLongIntMatrix = TInt32Matrix;
  TSparseLongIntMatrix = TSparseInt32Matrix;
  TSparseSimLongIntMatrix = TSparseSimInt32Matrix;

implementation

uses VectProc;

const
  MatrixProductCode = MatrixProductInt32;

{$I NumMatr.imp}

end.
