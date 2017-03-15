{ Version 030704. Copyright © Alexey A.Chernobaev, 1996-2003 }

unit UInt8m;

interface

{$I VCheck.inc}

uses
  SysUtils, ExtType, ExtSys, Vectors, Aliasv, UInt8g, UInt8v, UInt8sv, Int16g,
  Pointerv, VFormat, 
  {$IFDEF USE_STREAM64}VStrm64{$ELSE}VStream{$ENDIF}, VTxtStrm, VectErr;

type
  BaseType = UInt8;
  TGenericBaseVector = TGenericUInt8Vector;
  TBaseVector = TUInt8Vector;

  {$I NumMatr.def}

  TUInt8Matrix = TNumberMatrix;
  TSparseUInt8Matrix = TSparseMatrix;
  TSimUInt8Matrix = TSimMatrix;
  TSparseSimUInt8Matrix = TSparseSimMatrix;

  TByteMatrix = TUInt8Matrix;
  TSparseByteMatrix = TSparseUInt8Matrix;
  TSparseSimByteMatrix = TSparseSimUInt8Matrix;

implementation

uses VectProc;

const
  MatrixProductCode = MatrixProductUInt8;

{$I NumMatr.imp}

end.
