{ Version 040212. Copyright © Alexey A.Chernobaev, 1996-2004 }

unit IIDic;
{
  Словарь integer-integer.

  Integer-integer dictionary.
}

interface

{$I VCheck.inc}

uses
  SysUtils, ExtType, ExtSys, Pointerv,
  {$IFDEF USE_STREAM64}VStrm64{$ELSE}VStream{$ENDIF}, VectErr;

type
  TDicKey = Int32;
  TDicData = Int32;

  {$I Dic.def}

  TIntIntDic = TDic;

implementation

{$IFDEF CHECK_OBJECTS_FREE}
uses ChckFree;
{$ENDIF}

const
  SKeyNotFound = SKeyNotFound_d;

{$I Dic.imp}

end.
