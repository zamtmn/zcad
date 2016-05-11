{ Version 030614. Copyright © Alexey A.Chernobaev, 1996-2003 }

unit F32sv;

interface

{$I VCheck.inc}

uses
  ExtType, Vectors, Indexsv, F32g, 
  {$IFDEF USE_STREAM64}VStrm64{$ELSE}VStream{$ENDIF}, VectErr;

{$DEFINE FLOAT}

type
  {$I SprsVect.def}

  TSparseFloat32Vector = TSparseVector;
  TSparseSingleVector = TSparseFloat32Vector;

implementation

uses Base32v;

{$I SprsVect.imp}

{$UNDEF FLOAT}

end.
