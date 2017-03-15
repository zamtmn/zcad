{ Version 030614. Copyright © Alexey A.Chernobaev, 1996-2003 }

unit Int64g;

interface

{$I VCheck.inc}

{$IFDEF VER130}
{ обходим баг Delphi 5.0, связанный с использованием Int64 }
{ work-around for Delphi 5.0 bug connected with use of Int64 }
{$O-}
{$ENDIF}

uses
  SysUtils, ExtType, Vectors, Base64v, VFormat,
 {$IFDEF USE_STREAM64}VStrm64{$ELSE}VStream{$ENDIF}, VTxtStrm, VectErr;

{$DEFINE INT64_VECT}

type
  NumberType = Int64;
  PArrayType = PInt64Array;

  TGenericNumberVector = class(TBase64Vector)
  {$I VGeneric.def}
  end;

  TGenericInt64Vector = TGenericNumberVector;

implementation

{$I VGeneric.imp}

{$UNDEF INT64_VECT}

end.
