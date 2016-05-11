{ Version 030614. Copyright © Alexey A.Chernobaev, 1996-2003 }

unit UInt32sv;

interface

{$I VCheck.inc}

uses
  ExtType, Vectors, Indexsv, UInt32g,
  {$IFDEF USE_STREAM64}VStrm64{$ELSE}VStream{$ENDIF}, VectErr;

{$DEFINE UINT}

type
  {$I SprsVect.def}

  TSparseUInt32Vector = TSparseVector;
{$IFNDEF V_32}
  TSparseCardinalVector = TSparseUInt32Vector;
{$ENDIF}

implementation

uses Base32v;

{$I SprsVect.imp}

{$UNDEF UINT}

end.
