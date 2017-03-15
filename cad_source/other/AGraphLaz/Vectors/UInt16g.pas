{ Version 030614. Copyright © Alexey A.Chernobaev, 1996-2003 }

unit UInt16g;

interface

{$I VCheck.inc}

uses
  SysUtils, ExtType, Vectors, Base16v,
  {$IFDEF USE_STREAM64}VStrm64{$ELSE}VStream{$ENDIF}, VTxtStrm, VectErr;

{$DEFINE UINT}

type
  NumberType = UInt16;
  PArrayType = PUInt16Array;

  TGenericNumberVector = class(TBase16Vector)
  {$I VGeneric.def}
  end;

  TGenericUInt16Vector = TGenericNumberVector;
  TGenericWordVector = TGenericUInt16Vector;

implementation

{$I VGeneric.imp}

{$UNDEF UINT}

end.
