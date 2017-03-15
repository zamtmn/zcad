{ Version 030614. Copyright © Alexey A.Chernobaev, 1996-2003 }

unit UInt32g;

interface

{$I VCheck.inc}

uses
  SysUtils, ExtType, Vectors, Base32v,
  {$IFDEF USE_STREAM64}VStrm64{$ELSE}VStream{$ENDIF}, VTxtStrm, VectErr;

{$DEFINE UINT}

type
  NumberType = UInt32;
  PArrayType = PUInt32Array;

  TGenericNumberVector = class(TBase32Vector)
  {$I VGeneric.def}
  end;

  TGenericUInt32Vector = TGenericNumberVector;

implementation

{$I VGeneric.imp}

{$UNDEF UINT}

end.
