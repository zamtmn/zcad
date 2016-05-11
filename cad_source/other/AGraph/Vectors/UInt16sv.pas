{ Version 030614. Copyright © Alexey A.Chernobaev, 1996-2003 }

unit UInt16sv;

interface

{$I VCheck.inc}

uses
  ExtType, Vectors, Indexsv, UInt16g,
  {$IFDEF USE_STREAM64}VStrm64{$ELSE}VStream{$ENDIF}, VectErr;

{$DEFINE UINT}

type
  NumberType = UInt16;

  {$I SprsVect.def}

  TSparseUInt16Vector = TSparseVector;
  TSparseWordVector = TSparseUInt16Vector;

implementation

uses Base16v;

{$I SprsVect.imp}

{$UNDEF UINT}

end.
