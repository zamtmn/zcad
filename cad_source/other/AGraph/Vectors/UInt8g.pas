{ Version 030621. Copyright © Alexey A.Chernobaev, 1996-2003 }

unit UInt8g;

interface

{$I VCheck.inc}

uses
  SysUtils, ExtType, Vectors, Base8v,
  {$IFDEF USE_STREAM64}VStrm64{$ELSE}VStream{$ENDIF}, VTxtStrm, VectErr;

{$DEFINE UINT}

type
  NumberType = UInt8;
  PArrayType = PUInt8Array;

  TGenericNumberVector = class(TBase8Vector)
  {$I VGeneric.def}
  end;

  TGenericUInt8Vector = TGenericNumberVector;
  TGenericByteVector = TGenericUInt8Vector;

implementation

{$I VGeneric.imp}

{$UNDEF UINT}

end.
