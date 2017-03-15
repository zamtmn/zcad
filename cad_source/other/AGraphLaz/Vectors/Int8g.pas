{ Version 030614. Copyright © Alexey A.Chernobaev, 1996-2003 }

unit Int8g;

interface

{$I VCheck.inc}

uses
  SysUtils, ExtType, Vectors, Base8v,
  {$IFDEF USE_STREAM64}VStrm64{$ELSE}VStream{$ENDIF}, VTxtStrm, VectErr;

type
  NumberType = Int8;
  PArrayType = PInt8Array;

  TGenericNumberVector = class(TBase8Vector)
  {$I VGeneric.def}
  end;

  TGenericInt8Vector = TGenericNumberVector;
  TGenericShortIntVector = TGenericInt8Vector;

implementation

{$I VGeneric.imp}

end.
