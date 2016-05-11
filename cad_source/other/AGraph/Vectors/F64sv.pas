{ Version 030614. Copyright © Alexey A.Chernobaev, 1996-2003 }

unit F64sv;

interface

{$I VCheck.inc}

uses
  ExtType, Vectors, Indexsv, F64g, 
  {$IFDEF USE_STREAM64}VStrm64{$ELSE}VStream{$ENDIF}, VectErr;

{$DEFINE FLOAT}

type
  {$I SprsVect.def}

  TSparseFloat64Vector = TSparseVector;
  TSparseDoubleVector = TSparseFloat64Vector;

implementation

uses Base64v;

{$I SprsVect.imp}

{$UNDEF FLOAT}

end.
