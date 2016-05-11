{ Version 040212. Copyright © Alexey A.Chernobaev, 1996-2004 }

unit II64Dic;
{
  Словарь int32-int64.

  Int32-int64 dictionary.
}

interface

{$I VCheck.inc}

uses
  SysUtils, ExtType, ExtSys, Pointerv,
  {$IFDEF USE_STREAM64}VStrm64{$ELSE}VStream{$ENDIF}, VectErr;

type
  TDicKey = Int32;
  TDicData = Int64;

  {$I Dic.def}

  TIntInt64Dic = TDic;

implementation

{$IFDEF CHECK_OBJECTS_FREE}
uses ChckFree;
{$ENDIF}

const
  SKeyNotFound = SKeyNotFound_d;

{$I Dic.imp}

end.
