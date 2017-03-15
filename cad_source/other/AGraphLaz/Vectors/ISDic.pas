{ Version 040419. Copyright © Alexey A.Chernobaev, 1996-2004 }

unit ISDic;
{
  Словарь integer-string.

  Integer-string dictionary.
}

interface

{$I VCheck.inc}

uses
  SysUtils, ExtType, ExtSys, Pointerv,
  {$IFDEF USE_STREAM64}VStrm64{$ELSE}VStream{$ENDIF}, VectErr;

type
  TDicKey = Int32;
  TDicData = String;

  {$I Dic.def}

  TIntStrDic = class(TDic)
  protected
    procedure WriteItem(VStream: TVStream; const Item: TTreeData); override;
    function ReadItem(VStream: TVStream): TTreeData; override;
  end;

  TIntStrDicClass = class of TIntStrDic;

  TIntStrDicIterator = TDicIterator;

implementation

{$IFDEF CHECK_OBJECTS_FREE}
uses ChckFree;
{$ENDIF}

const
  SKeyNotFound = SKeyNotFound_d;

{$I Dic.imp}

procedure TIntStrDic.WriteItem(VStream: TVStream; const Item: TTreeData);
begin
  VStream.WriteInt32(Item.Key);
  VStream.WriteString(Item.Data);
end;

function TIntStrDic.ReadItem(VStream: TVStream): TTreeData;
begin
  Result.Key:=VStream.ReadInt32;
  Result.Data:=VStream.ReadString;
end;

end.
