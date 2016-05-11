{ Version 040803. Copyright © Alexey A.Chernobaev, 1996-2004 }

unit WSPDic;
{
  —ловарь WideString-Pointer.

  WideString-Pointer dictionary.
}

interface

{$I VCheck.inc}

uses
  {$IFDEF V_WIN}
  {$IFNDEF DYNAMIC_NLS}VUnicode{$ELSE}NLSProcsDyn{$ENDIF},
  {$ENDIF}
  SysUtils, ExtType, ExtSys, Pointerv, WStrLst, VectStr,
  {$IFDEF USE_STREAM64}VStrm64{$ELSE}VStream{$ENDIF}, VectErr;

type
  TDicKey = WideString;
  TDicData = Pointer;

  {$DEFINE USER_COMPARE_OBJECTS}
  {$I Dic.def}

  TWideStrPtrDic = class(TDic)
  protected
    function CMP(const a, b: TTreeData): Integer;
    procedure WriteItem(VStream: TVStream; const Item: TTreeData); override;
    function ReadItem(VStream: TVStream): TTreeData; override;
    procedure FreeItem(const Item: TTreeData);
  public
    constructor Create;
    class function Compare(const S1, S2: WideString): Integer; virtual;
    { используетс€ методом-функцией CMP дл€ сравнении строк }
    { used by the function method CMP for comparing strings }
    procedure CopyToStrLst(S: TWideStrLst);
    { копирует упор€доченные (в соответствии с методом Compare) ключи из словар€
      в список строк S }
    { copies sorted (according to Compare method) keys from the dictionary to
      the string list S }
    procedure CopyToStrLstWithData(S: TWideStrLst; DataVector: TPointerVector);
    { аналог CopyToStrLst, который возвращает также св€занные с ключами данные
      (DataList[I]:=Data(S[I]) }
    { analog of CopyToStrLst which also returns data linked with the keys
      (DataList[I]:=Data(S[I]) }
    procedure CopyToDataVector(DataVector: TPointerVector);
    { копирует данные, св€занные с ключами, в DataVector }
    { copies data linked with the keys to DataVector }
    procedure FreeAndDelete(const AKey: TDicKey);
    { удал€ет и освобождает элемент с ключом AKey, интерпретиру€ его как TObject }
    { frees and deletes element with the key AKey interpreting it as TObject }
    procedure FreeItems;
    { освобождает все элементы, интерпретиру€ их как TObject }
    { frees all elements interpreting them as TObject }
    procedure DebugWriteItem(const Item: TTreeData);
    procedure DebugWrite;
  end;

  TWideStrPtrDicClass = class of TWideStrPtrDic;

  TCaseSensWideStrPtrDic = class(TWideStrPtrDic)
    class function Compare(const S1, S2: WideString): Integer; override;
  end;

  TCaseSensWideStrPtrDicClass = class of TCaseSensWideStrPtrDic;

  TWideStrPtrDicIterator = TDicIterator;

implementation

{$IFDEF CHECK_OBJECTS_FREE}
uses ChckFree;
{$ENDIF}

const
  SKeyNotFound = SKeyNotFound_s;

{$I Dic.imp}

{ TWideStrPtrDic }

constructor TWideStrPtrDic.Create;
begin
  inherited Create(CMP);
end;

function TWideStrPtrDic.CMP(const a, b: TTreeData): Integer;
begin
  Result:=Compare(a.Key, b.Key);
end;

procedure TWideStrPtrDic.WriteItem(VStream: TVStream; const Item: TTreeData);
begin
  VStream.WriteWideString(Item.Key);
  VStream.WriteInt32(Int32(Item.Data));
end;

function TWideStrPtrDic.ReadItem(VStream: TVStream): TTreeData;
begin
  Result.Key:=VStream.ReadWideString;
  Result.Data:=Pointer(VStream.ReadInt32);
end;

class function TWideStrPtrDic.Compare(const S1, S2: WideString): Integer;
begin
  Result:={$IFDEF V_WIN}CompareTextWide{$ELSE}WideCompareText{$ENDIF}(S1, S2);
end;

procedure TWideStrPtrDic.CopyToStrLst(S: TWideStrLst);
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

procedure TWideStrPtrDic.CopyToStrLstWithData(S: TWideStrLst; DataVector: TPointerVector);
var
  I: Integer;
  It: TWideStrPtrDicIterator;
begin
  I:=Count;
  S.Count:=I;
  DataVector.Count:=I;
  It:=TWideStrPtrDicIterator.Create(Self);
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

procedure TWideStrPtrDic.CopyToDataVector(DataVector: TPointerVector);
var
  I: Integer;
  It: TWideStrPtrDicIterator;
begin
  I:=Count;
  DataVector.Count:=I;
  It:=TWideStrPtrDicIterator.Create(Self);
  try
    I:=0;
    while not It.Eof do begin
      DataVector[I]:=It.Data.Data;
      Inc(I);
      It.Next;
    end;
  finally
    It.Free;
  end;
end;

procedure TWideStrPtrDic.FreeAndDelete(const AKey: TDicKey);
var
  TreeData: TTreeData;
  Node: PNode;
begin
  TreeData.Key:=AKey;
  Node:=FindNode(TreeData);
  if Node <> nil then begin
    TObject(Node^.data.Data).Free;
    DeleteNode(Node);
  end
  else
    raise EDicError.CreateFmt(SKeyNotFound, [AKey]);
end;

procedure TWideStrPtrDic.FreeItem(const Item: TTreeData);
begin
  TObject(Item.Data).Free;
end;

procedure TWideStrPtrDic.FreeItems;
begin
  if Self <> nil then Traversal(FreeItem);
end;

procedure TWideStrPtrDic.DebugWriteItem(const Item: TTreeData);
begin
  writeln(String(Item.Key), ' ', IntToHex(Int32(Item.Data), 8));
end;

procedure TWideStrPtrDic.DebugWrite;
begin
  UpwardTraversal(DebugWriteItem);
end;

{ TCaseSensWideStrPtrDic }

class function TCaseSensWideStrPtrDic.Compare(const S1, S2: WideString): Integer;
begin
  Result:=WStrCmp(PWideChar(S1), PWideChar(S2));
end;

end.
