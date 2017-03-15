{ Version 030614. Copyright © Alexey A.Chernobaev, 1996-2003 }

unit F64g;

interface

{$I VCheck.inc}

uses
  SysUtils, ExtType, Vectors, Base64v, VFormat,
  {$IFDEF USE_STREAM64}VStrm64{$ELSE}VStream{$ENDIF}, VTxtStrm, VectErr;

{$DEFINE FLOAT}

type
  NumberType = Float64;
  PArrayType = PFloat64Array;

  TGenericNumberVector = class(TBase64Vector)
  {$I VGeneric.def}
  end;

  TGenericFloat64Vector = TGenericNumberVector;
  TGenericDoubleVector = TGenericFloat64Vector;

implementation

{$I VGeneric.imp}

{$UNDEF FLOAT}

end.
