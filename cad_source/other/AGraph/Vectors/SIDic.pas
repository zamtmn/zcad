{ Version 040621. Copyright © Alexey A.Chernobaev, 1996-2004 }

unit SIDic;
{
  Словарь string-integer.

  String-integer dictionary.
}

interface

{$I VCheck.inc}

uses
  SysUtils, ExtType, ExtSys, Pointerv, StrLst,
  {$IFDEF V_32}Int32g{$ELSE}Int16g, Int16v{$ENDIF},
  {$IFDEF USE_STREAM64}VStrm64{$ELSE}VStream{$ENDIF}, VectErr;

type
  TDicKey = String;
  TDicData = Integer;

  {$DEFINE USER_COMPARE_OBJECTS}
  {$I Dic.def}

  TStrIntDic = class(TDic)
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
    procedure CopyToStrLstWithData(S: TStrLst;
      DataVector: {$IFDEF V_32}TGenericInt32Vector{$ELSE}TGenericInt16Vector{$ENDIF});
    { аналог CopyToStrLst, который возвращает также связанные с ключами данные
      (DataList[I]:=Data(S[I]) }
    { analog of CopyToStrLst which also returns data linked with the keys
      (DataList[I]:=Data(S[I]) }
    procedure DebugWriteItem(const Item: TTreeData);
    procedure DebugWrite;
  end;

  TStrIntDicClass = class of TStrIntDic;

  TCaseSensStrIntDic = class(TStrIntDic)
    class function Compare(const S1, S2: String): Integer; override;
  end;

  TCaseSensStrIntDicClass = class of TCaseSensStrIntDic;

  TSimpleStrIntDic = class(TStrIntDic)
    class function Compare(const S1, S2: String): Integer; override;
  end;

  TSimpleStrIntDicClass = class of TSimpleStrIntDic;

  TStrIntDicIterator = TDicIterator;

implementation

{$IFDEF CHECK_OBJECTS_FREE}
uses ChckFree;
{$ENDIF}

const
  SKeyNotFound = SKeyNotFound_s;

{$I Dic.imp}

{ TStrIntDic }

constructor TStrIntDic.Create;
begin
  inherited Create(CMP);
end;

function TStrIntDic.CMP(const a, b: TTreeData): Integer;
begin
  Result:=Compare(a.Key, b.Key);
end;

procedure TStrIntDic.WriteItem(VStream: TVStream; const Item: TTreeData);
begin
  VStream.WriteString(Item.Key);
  VStream.WriteInt32(Item.Data);
end;

function TStrIntDic.ReadItem(VStream: TVStream): TTreeData;
begin
  Result.Key:=VStream.ReadString;
  Result.Data:=VStream.ReadInt32;
end;

class function TStrIntDic.Compare(const S1, S2: String): Integer;
begin
  Result:=AnsiCompareText(S1, S2);
end;

procedure TStrIntDic.CopyToStrLst(S: TStrLst);
var
  It: TStrIntDicIterator;
  I: Integer;
begin
  S.Count:=Count;
  It:=TStrIntDicIterator.Create(Self);
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

procedure TStrIntDic.CopyToStrLstWithData(S: TStrLst;
  DataVector: {$IFDEF V_32}TGenericInt32Vector{$ELSE}TGenericInt16Vector{$ENDIF});
var
  It: TStrIntDicIterator;
  I: Integer;
begin
  I:=Count;
  S.Count:=I;
  DataVector.Count:=I;
  It:=TStrIntDicIterator.Create(Self);
  try
    I:=0;
    while not It.Eof do begin
      S.Items[I]:=It.Data.Key;
      DataVector[I]:=It.Data.Data;
      Inc(I);
      It.Next;
    end;
  finally
    It.Free;
  end;
end;

procedure TStrIntDic.DebugWriteItem(const Item: TTreeData);
begin
  writeln(Item.Key, ' ', Item.Data);
end;

procedure TStrIntDic.DebugWrite;
begin
  UpwardTraversal(DebugWriteItem);
end;

{ TCaseSensStrIntDic }

class function TCaseSensStrIntDic.Compare(const S1, S2: String): Integer;
begin
  Result:=AnsiCompareStr(S1, S2);
end;

{ TSimpleStrIntDic }

class function TSimpleStrIntDic.Compare(const S1, S2: String): Integer;
begin
  Result:=CompareStr(S1, S2);
end;

end.
