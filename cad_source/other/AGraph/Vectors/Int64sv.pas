{ Version 030704. Copyright © Alexey A.Chernobaev, 1996-2003 }

unit Int64sv;

interface

{$I VCheck.inc}

{$IFDEF VER130}
{ обходим баг Delphi 5.0, связанный с использованием Int64 }
{ work-around for Delphi 5.0 bug connected with use of Int64 }
{$O-}
{$ENDIF}

uses
  ExtType, Vectors, Indexsv, Int64g,
  {$IFDEF USE_STREAM64}VStrm64{$ELSE}VStream{$ENDIF}, VectErr;

{$DEFINE INT64_VECT}

type
  {$I SprsVect.def}

  TSparseInt64Vector = TSparseVector;

implementation

uses Base64v;

{$I SprsVect.imp}

{$UNDEF INT64_VECT}

end.
