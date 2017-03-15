{ Version 030704. Copyright © Alexey A.Chernobaev, 1996-2003 }

unit Int64m;

interface

{$I VCheck.inc}

{$IFDEF VER130}
{ обходим баг Delphi 5.0, связанный с использованием Int64 }
{ work-around for Delphi 5.0 bug connected with use of Int64 }
{$O-}
{$ENDIF}

uses
  SysUtils, ExtType, ExtSys, Vectors, Aliasv, Int64g, Int64v, Int64sv, Int16g,
  Pointerv, VFormat,
  {$IFDEF USE_STREAM64}VStrm64{$ELSE}VStream{$ENDIF}, VTxtStrm, VectErr;

{$DEFINE INT64_VECT}

type
  BaseType = Int64;
  TGenericBaseVector = TGenericInt64Vector;
  TBaseVector = TInt64Vector;

  {$I NumMatr.def}

  TInt64Matrix = TNumberMatrix;
  TSparseInt64Matrix = TSparseMatrix;
  TSimInt64Matrix = TSimMatrix;
  TSparseSimInt64Matrix = TSparseSimMatrix;

implementation

uses VectProc;

const
  MatrixProductCode = MatrixProductInt64;

{$I NumMatr.imp}

{$UNDEF INT64_VECT}

end.
