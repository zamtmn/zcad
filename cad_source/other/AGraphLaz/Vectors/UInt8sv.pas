{ Version 030704. Copyright © Alexey A.Chernobaev, 1996-2003 }

unit UInt8sv;

interface

{$I VCheck.inc}

uses
  ExtType, Vectors, Indexsv, UInt8g,
  {$IFDEF USE_STREAM64}VStrm64{$ELSE}VStream{$ENDIF}, VectErr;

{$DEFINE UINT}

type
  {$I SprsVect.def}

  TSparseUInt8Vector = TSparseVector;
  TSparseByteVector = TSparseUInt8Vector;

implementation

uses Base8v;

{$I SprsVect.imp}

{$UNDEF UINT}

end.
