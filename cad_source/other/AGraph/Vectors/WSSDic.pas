{ Version 040212. Copyright © Alexey A.Chernobaev, 1996-2004 }

unit WSSDic;
{
  Словарь WideString-Pointer.

  WideString-Pointer dictionary.
}

interface

{$I VCheck.inc}

uses
  SysUtils, ExtType, ExtSys, WStrLst, VectStr,
  {$IFDEF USE_STREAM64}VStrm64{$ELSE}VStream{$ENDIF}, VectErr;

type
  TDicKey = WideString;
  TDicData = WideString;

  {$DEFINE USER_COMPARE_OBJECTS}
  {$I Dic.def}

  TWideStrStrDic = class(TDic)
  protected
    function CMP(const a, b: TTreeData): Integer;
    procedure WriteItem(VStream: TVStream; const Item: TTreeData); override;
    function ReadItem(VStream: TVStream): TTreeData; override;
  public
    constructor Create;
    class function Compare(const S1, S2: WideString): Integer; virtual;
    { используется методом-функцией CMP для сравнении строк }
    { used by the function method CMP for comparing strings }
    procedure CopyToStrLst(S: TWideStrLst);
    { копирует упорядоченные (в соответствии с методом Compare) ключи из словаря
      в список строк S }
    { copies sorted (according to Compare method) keys from the dictionary to
      the string list S }
    procedure CopyToStrLstWithData(S, DataList: TWideStrLst);
    { аналог CopyToStrLst, который возвращает также связанные с ключами данные
      (DataList[I]:=Data(S[I]) }
    { analog of CopyToStrLst which also returns data linked with the keys
      (DataList[I]:=Data(S[I]) }
    procedure DebugWriteItem(const Item: TTreeData);
    procedure DebugWrite;
  end;

  TWideStrPtrDicClass = class of TWideStrStrDic;

  TWideStrPtrDicIterator = TDicIterator;

implementation

{$IFDEF CHECK_OBJECTS_FREE}
uses ChckFree;
{$ENDIF}

const
  SKeyNotFound = SKeyNotFound_s;

{$I Dic.imp}

{ TWideStrStrDic }

constructor TWideStrStrDic.Create;
begin
  inherited Create(CMP);
end;

function TWideStrStrDic.CMP(const a, b: TTreeData): Integer;
begin
  Result:=Compare(a.Key, b.Key);
end;

procedure TWideStrStrDic.WriteItem(VStream: TVStream; const Item: TTreeData);
begin
  VStream.WriteWideString(Item.Key);
  VStream.WriteWideString(Item.Data);
end;

function TWideStrStrDic.ReadItem(VStream: TVStream): TTreeData;
begin
  Result.Key:=VStream.ReadWideString;
  Result.Data:=VStream.ReadWideString;
end;

class function TWideStrStrDic.Compare(const S1, S2: WideString): Integer;
begin
  Result:=CompareWide(PWideChar(S1), PWideChar(S2));
end;

procedure TWideStrStrDic.CopyToStrLst(S: TWideStrLst);
var
  I: Integer;
  It: TWideStrPtrDicIterator;
begin
  S.Count:=Count;
  It:=TWideStrPtrDicIterator.Create(Self);
  try
    I:=0;
    while not It.Eof do begin
      S.Items[I]:=It.Data.Key;
      Inc(I);
      It.Next;
    end;
  finally
    It.Free;
  end;
end;

procedure TWideStrStrDic.CopyToStrLstWithData(S, DataList: TWideStrLst);
var
  I: Integer;
  It: TWideStrPtrDicIterator;
begin
  I:=Count;
  S.Count:=I;
  DataList.Count:=I;
  It:=TWideStrPtrDicIterator.Create(Self);
  try
    I:=0;
    while not It.Eof do begin
      S.Items[I]:=It.Data.Key;
      DataList[I]:=It.Data.Data;
      Inc(I);
      It.Next;
    end;
  finally
    It.Free;
  end;
end;

procedure TWideStrStrDic.DebugWriteItem(const Item: TTreeData);
begin
  writeln(String(Item.Key), ' ', String(Item.Data));
end;

procedure TWideStrStrDic.DebugWrite;
begin
  UpwardTraversal(DebugWriteItem);
end;

end.
