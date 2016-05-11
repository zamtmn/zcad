{ Version 030704. Copyright © Alexey A.Chernobaev, 1996-2003 }

unit UInt16m;

interface

{$I VCheck.inc}

uses
  SysUtils, ExtType, ExtSys, Vectors, Aliasv, UInt16g, UInt16v, UInt16sv,
  Int16g, Pointerv, VFormat, 
  {$IFDEF USE_STREAM64}VStrm64{$ELSE}VStream{$ENDIF}, VTxtStrm, VectErr;

type
  BaseType = UInt16;
  TGenericBaseVector = TGenericUInt16Vector;
  TBaseVector = TUInt16Vector;

  {$I NumMatr.def}

  TUInt16Matrix = TNumberMatrix;
  TSparseUInt16Matrix = TSparseMatrix;
  TSimUInt16Matrix = TSimMatrix;
  TSparseSimUInt16Matrix = TSparseSimMatrix;

  TWordMatrix = TUInt16Matrix;
  TSparseWordMatrix = TSparseUInt16Matrix;
  TSparseSimWordMatrix = TSparseSimUInt16Matrix;

implementation

uses VectProc;

const
  MatrixProductCode = MatrixProductUInt16;

{$I NumMatr.imp}

end.
