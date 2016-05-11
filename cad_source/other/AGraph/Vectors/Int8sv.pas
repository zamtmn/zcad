{ Version 030704. Copyright © Alexey A.Chernobaev, 1996-2003 }

unit Int8sv;

interface

{$I VCheck.inc}

uses
  ExtType, Vectors, Indexsv, Int8g,
  {$IFDEF USE_STREAM64}VStrm64{$ELSE}VStream{$ENDIF}, VectErr;

type
  {$I SprsVect.def}

  TSparseInt8Vector = TSparseVector;
  TSparseShortIntVector = TSparseInt8Vector;

implementation

uses Base8v;

{$I SprsVect.imp}

end.
