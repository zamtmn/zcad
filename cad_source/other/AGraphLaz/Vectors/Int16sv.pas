{ Version 030614. Copyright © Alexey A.Chernobaev, 1996-2003 }

unit Int16sv;

interface

{$I VCheck.inc}

uses
  ExtType, Vectors, Indexsv, Int16g,
  {$IFDEF USE_STREAM64}VStrm64{$ELSE}VStream{$ENDIF}, VectErr;

type
  {$I SprsVect.def}

  TSparseInt16Vector = TSparseVector;
  TSparseSmallIntVector = TSparseInt16Vector;

implementation

uses Base16v;

{$I SprsVect.imp}

end.
