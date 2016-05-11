{ Version 030614. Copyright © Alexey A.Chernobaev, 1996-2003 }

unit F80sv;

interface

{$I VCheck.inc}

uses
  ExtType, Vectors, Indexsv, F80g, 
  {$IFDEF USE_STREAM64}VStrm64{$ELSE}VStream{$ENDIF}, VectErr;

{$DEFINE FLOAT}

type
  {$I SprsVect.def}

  TSparseFloat80Vector = TSparseVector;
  TSparseExtendedVector = TSparseFloat80Vector;

implementation

uses Base80v;

{$I SprsVect.imp}

{$UNDEF FLOAT}

end.
