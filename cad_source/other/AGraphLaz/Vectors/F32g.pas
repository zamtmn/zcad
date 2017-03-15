{ Version 030614. Copyright © Alexey A.Chernobaev, 1996-2003 }

unit F32g;

interface

{$I VCheck.inc}

uses
  SysUtils, ExtType, Vectors, Base32v, VFormat,
  {$IFDEF USE_STREAM64}VStrm64{$ELSE}VStream{$ENDIF}, VTxtStrm, VectErr;

{$DEFINE FLOAT}

type
  NumberType = Float32;
  PArrayType = PFloat32Array;

  TGenericNumberVector = class(TBase32Vector)
  {$I VGeneric.def}
  end;

  TGenericFloat32Vector = TGenericNumberVector;
  TGenericSingleVector = TGenericFloat32Vector;

implementation

{$I VGeneric.imp}

{$UNDEF FLOAT}

end.
