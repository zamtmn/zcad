{ Version 040621. Copyright © Alexey A.Chernobaev, 1996-2004 }

unit SSDic;
{
  Словарь string-string.

  String-string dictionary.
}

interface

{$I VCheck.inc}

uses
  SysUtils, ExtType, ExtSys, Pointerv, StrLst,
  {$IFDEF USE_STREAM64}VStrm64{$ELSE}VStream{$ENDIF}, VectErr;

type
  TDicKey = String;
  TDicData = String;

  {$DEFINE USER_COMPARE_OBJECTS}
  {$I Dic.def}

  TStrStrDic = class(TDic)
  protected
    function CMP(const a, b: TTreeData): Integer;
    procedure WriteItem(VStream: TVStream; const Item: TTreeData); override;
    function ReadItem(VStream: TVStream): TTreeData; override;
  public
    constructor Create;
    class function Compare(const S1, S2: String): Integer; virtual;
    { используется методом-функцией CMP для сравнении строк }
    { used by the function method CMP for comparing strings }
    procedure CopyToStrLst(S: TStrLst);
    { копирует упорядоченные (в соответствии с методом Compare) ключи из словаря
      в список строк S }
    { copies sorted (according to Compare method) keys from the dictionary to
      the string list S }
    procedure CopyToStrLstWithData(S, DataList: TStrLst);
    { аналог CopyToStrLst, который возвращает также связанные с ключами данные
      (DataList[I]:=Data(S[I]) }
    { analog of CopyToStrLst which also returns data linked with the keys
      (DataList[I]:=Data(S[I]) }
  end;

  TStrStrDicClass = class of TStrStrDic;

  TCaseSensStrStrDic = class(TStrStrDic)
    class function Compare(const S1, S2: String): Integer; override;
  end;

  TCaseSensStrStrDicClass = class of TCaseSensStrStrDic;

  TExactStrStrDic = class(TStrStrDic)
    class function Compare(const S1, S2: String): Integer; override;
  end;

  TExactStrStrDicClass = class of TExactStrStrDic;

  TStrStrDicIterator = TDicIterator;

implementation

{$IFDEF CHECK_OBJECTS_FREE}
uses ChckFree;
{$ENDIF}

const
  SKeyNotFound = SKeyNotFound_s;

{$I Dic.imp}

{ TStrStrDic }

constructor TStrStrDic.Create;
begin
  inherited Create(CMP);
end;

function TStrStrDic.CMP(const a, b: TTreeData): Integer;
begin
  Result:=Compare(a.Key, b.Key);
end;

procedure TStrStrDic.WriteItem(VStream: TVStream; const Item: TTreeData);
begin
  VStream.WriteString(Item.Key);
  VStream.WriteString(Item.Data);
end;

function TStrStrDic.ReadItem(VStream: TVStream): TTreeData;
begin
  Result.Key:=VStream.ReadString;
  Result.Data:=VStream.ReadString;
end;

class function TStrStrDic.Compare(const S1, S2: String): Integer;
begin
  Result:=AnsiCompareText(S1, S2);
end;

procedure TStrStrDic.CopyToStrLst(S: TStrLst);
var
  It: TStrStrDicIterator;
  I: Integer;
begin
  S.Count:=Count;
  It:=TStrStrDicIterator.Create(Self);
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

procedure TStrStrDic.CopyToStrLstWithData(S, DataList: TStrLst);
var
  It: TStrStrDicIterator;
  I: Integer;
begin
  I:=Count;
  S.Count:=I;
  DataList.Count:=I;
  It:=TStrStrDicIterator.Create(Self);
  try
    I:=0;
    while not It.Eof do begin
      S.Items[I]:=It.Data.Key;
      DataList.Items[I]:=It.Data.Data;
      Inc(I);
      It.Next;
    end;
  finally
    It.Free;
  end;
end;

{ TCaseSensStrStrDic }

class function TCaseSensStrStrDic.Compare(const S1, S2: String): Integer;
begin
  Result:=AnsiCompareStr(S1, S2);
end;

{ TExactStrStrDic }

class function TExactStrStrDic.Compare(const S1, S2: String): Integer;
begin
  if S1 < S2 then Result:=-1
  else if S1 > S2 then Result:=1
  else Result:=0;
end;

end.
