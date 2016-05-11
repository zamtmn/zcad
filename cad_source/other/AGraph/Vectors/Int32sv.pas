{ Version 030614. Copyright © Alexey A.Chernobaev, 1996-2003 }

unit Int32sv;

interface

{$I VCheck.inc}

uses
  ExtType, Vectors, Indexsv, Int32g,
  {$IFDEF USE_STREAM64}VStrm64{$ELSE}VStream{$ENDIF}, VectErr;

type
  {$I SprsVect.def}

  TSparseInt32Vector = TSparseVector;
  TSparseLongIntVector = TSparseInt32Vector;

implementation

uses Base32v;

{$I SprsVect.imp}

end.
