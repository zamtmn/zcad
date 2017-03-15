{ Version 030614. Copyright © Alexey A.Chernobaev, 1996-2003 }

unit Int32g;

interface

{$I VCheck.inc}

uses
  SysUtils, ExtType, Vectors, Base32v,
  {$IFDEF USE_STREAM64}VStrm64{$ELSE}VStream{$ENDIF}, VTxtStrm, VectErr;

type
  NumberType = Int32;
  PArrayType = PInt32Array;

  TGenericNumberVector = class(TBase32Vector)
  {$I VGeneric.def}
  end;

  TGenericInt32Vector = TGenericNumberVector;
  TGenericLongIntVector = TGenericInt32Vector;

implementation

{$I VGeneric.imp}

end.
