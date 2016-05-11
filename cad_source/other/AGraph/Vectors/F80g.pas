{ Version 030614. Copyright © Alexey A.Chernobaev, 1996-2003 }

unit F80g;

interface

{$I VCheck.inc}

uses
  SysUtils, ExtType, Vectors, Base80v, VFormat,
  {$IFDEF USE_STREAM64}VStrm64{$ELSE}VStream{$ENDIF}, VTxtStrm, VectErr;

{$DEFINE FLOAT}

type
  NumberType = Float80;
  PArrayType = PFloat80Array;

  TGenericNumberVector = class(TBase80Vector)
  {$I VGeneric.def}
  end;

  TGenericFloat80Vector = TGenericNumberVector;
  TGenericExtendedVector = TGenericFloat80Vector;

implementation

{$I VGeneric.imp}

{$UNDEF FLOAT}

end.
