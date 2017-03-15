{ Version 030704. Copyright © Alexey A.Chernobaev, 1996-2003 }

unit F32m;

interface

{$I VCheck.inc}

uses
  ExtType, ExtSys, Vectors, Aliasv, F32g, F32v, F32sv, Int16g, Pointerv, VFormat,
  {$IFDEF USE_STREAM64}VStrm64{$ELSE}VStream{$ENDIF}, VTxtStrm, VectErr;

{$DEFINE FLOAT}

type
  BaseType = Float32;
  TGenericBaseVector = TGenericFloat32Vector;
  TBaseVector = TFloat32Vector;

  {$I NumMatr.def}

  TFloat32Matrix = TNumberMatrix;
  TSparseFloat32Matrix = TSparseMatrix;
  TSimFloat32Matrix = TSimMatrix;
  TSparseSimFloat32Matrix = TSparseSimMatrix;

  TSingleMatrix = TFloat32Matrix;
  TSparseSingleMatrix = TSparseFloat32Matrix;
  TSparseSimSingleMatrix = TSparseSimFloat32Matrix;

implementation

uses VectProc;

const
  MatrixProductCode = MatrixProductFloat32;

{$I NumMatr.imp}

{$UNDEF FLOAT}

end.
