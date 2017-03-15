{ Version 030704. Copyright © Alexey A.Chernobaev, 1996-2003 }

unit UInt32m;

interface

{$I VCheck.inc}

uses
  SysUtils, ExtType, ExtSys, Vectors, Aliasv, UInt32g, UInt32v, UInt32sv,
  Int16g, Pointerv, VFormat,
  {$IFDEF USE_STREAM64}VStrm64{$ELSE}VStream{$ENDIF}, VTxtStrm, VectErr;

type
  BaseType = UInt32;
  TGenericBaseVector = TGenericUInt32Vector;
  TBaseVector = TUInt32Vector;

  {$I NumMatr.def}

  TUInt32Matrix = TNumberMatrix;
  TSparseUInt32Matrix = TSparseMatrix;
  TSimUInt32Matrix = TSimMatrix;
  TSparseSimUInt32Matrix = TSparseSimMatrix;

  {$IFDEF V_32}
  TCardinalMatrix = TUInt32Matrix;
  TSparseCardinalMatrix = TSparseUInt32Matrix;
  TSparseSimCardinalMatrix = TSparseSimUInt32Matrix;
  {$ENDIF}

implementation

uses VectProc;

const
  MatrixProductCode = MatrixProductUInt32;

{$I NumMatr.imp}

end.
