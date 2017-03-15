{ Version 050602. Copyright © Alexey A.Chernobaev, 1996-2005 }

unit SPDic;
{
  —ловарь string-pointer.

  String-pointer dictionary.
}

interface

{$I VCheck.inc}

uses
  {$IFDEF V_WIN32}Windows{for "inline"},{$ENDIF}
  SysUtils, ExtType, ExtSys, Pointerv, StrLst,
  {$IFDEF USE_STREAM64}VStrm64{$ELSE}VStream{$ENDIF}, VectErr;

type
  TDicKey = String;
  TDicData = Pointer;

  {$DEFINE NON_VIRTUAL_COMPARE}
  {$DEFINE INLINE_COMPARE}
  {$I Dic.def}

  TStrPtrDic = class(TDic)
  protected
    procedure WriteItem(VStream: TVStream; const Item: TTreeData); override;
    function ReadItem(VStream: TVStream): TTreeData; override;
    procedure FreeItem(const Item: TTreeData);
  public
    class function Compare(const S1, S2: String): Integer; virtual;
    { используетс€ методом-функцией CMP дл€ сравнении строк }
    { used by the function method CMP for comparing strings }
    procedure CopyToStrLst(S: TStrLst);
    { копирует упор€доченные (в соответствии с методом Compare) ключи из словар€
      в список строк S }
    { copies sorted (according to Compare method) keys from the dictionary to
      the string list S }
    procedure CopyToStrLstWithData(S: TStrLst; DataVector: TPointerVector);
    { аналог CopyToStrLst, который возвращает также св€занные с ключами данные
      (DataList[I]:=Data(S[I]) }
    { analog of CopyToStrLst which also returns data linked with the keys
      (DataList[I]:=Data(S[I]) }
    procedure CopyToDataVector(DataVector: TPointerVector);
    { копирует данные, св€занные с ключами, в DataVector }
    { copies data linked with the keys to DataVector }
    procedure FreeAndDelete(const AKey: TDicKey);
    { если в словаре есть значение с ключом AKey, то удал€ет его и освобождает,
      интерпретиру€ как TObject, иначе возбуждает исключение EDicError }
    { if there is a value with the key AKey in the dictionary then deletes it
      and frees, interpreting it as TObject, else raises exception EDicError }
    function SafeFreeAndDelete(const AKey: TDicKey): Boolean;
    { если в словаре есть значение с ключом AKey, то удал€ет его и освобождает,
      интерпретиру€ как TObject, и возвращает значение True, иначе возвращает
      False }
    { if there is a value with the key AKey in the dictionary then deletes it
      and frees, interpreting it as TObject, and returns True, else returns
      False }
    procedure FreeItems;
    { освобождает все элементы, интерпретиру€ их как TObject }
    { frees all elements interpreting them as TObject }
    procedure DebugWriteItem(const Item: TTreeData);
    procedure DebugWrite;
  end;

  TStrPtrDicClass = class of TStrPtrDic;

  TCaseSensStrPtrDic = class(TStrPtrDic)
    class function Compare(const S1, S2: String): Integer; override;
  end;

  TExactStrPtrDic = class(TStrPtrDic)
    class function Compare(const S1, S2: String): Integer; override;
  end;

  TCaseSensStrPtrDicClass = class of TCaseSensStrPtrDic;

  TStrPtrDicIterator = TDicIterator;

implementation

{$IFDEF CHECK_OBJECTS_FREE}
uses ChckFree;
{$ENDIF}

const
  SKeyNotFound = SKeyNotFound_s;

{$I Dic.imp}

{ TRBTree }

function TRBTree.CMP(const a, b: TTreeData): Integer;
begin
  Result:=TStrPtrDic(Self).Compare(a.Key, b.Key);
end;

{ TStrPtrDic }

procedure TStrPtrDic.WriteItem(VStream: TVStream; const Item: TTreeData);
begin
  VStream.WriteString(Item.Key);
  VStream.WriteInt32(Int32(Item.Data));
end;

function TStrPtrDic.ReadItem(VStream: TVStream): TTreeData;
begin
  Result.Key:=VStream.ReadString;
  Result.Data:=Pointer(VStream.ReadInt32);
end;

class function TStrPtrDic.Compare(const S1, S2: String): Integer;
begin
  Result:=AnsiCompareText(S1, S2);
end;

procedure TStrPtrDic.CopyToStrLst(S: TStrLst);
var
  I: Integer;
  It: TStrPtrDicIterator;
begin
  S.Count:=Count;
  It:=TStrPtrDicIterator.Create(Self);
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

procedure TStrPtrDic.CopyToStrLstWithData(S: TStrLst; DataVector: TPointerVector);
var
  I: Integer;
  It: TStrPtrDicIterator;
begin
  I:=Count;
  S.Count:=I;
  DataVector.Count:=I;
  It:=TStrPtrDicIterator.Create(Self);
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

procedure TStrPtrDic.CopyToDataVector(DataVector: TPointerVector);
var
  I: Integer;
  It: TStrPtrDicIterator;
begin
  I:=Count;
  DataVector.Count:=I;
  It:=TStrPtrDicIterator.Create(Self);
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

procedure TStrPtrDic.FreeAndDelete(const AKey: TDicKey);
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

function TStrPtrDic.SafeFreeAndDelete(const AKey: TDicKey): Boolean;
var
  TreeData: TTreeData;
  Node: PNode;
begin
  TreeData.Key:=AKey;
  Node:=FindNode(TreeData);
  if Node <> nil then begin
    TObject(Node^.data.Data).Free;
    DeleteNode(Node);
    Result:=True;
  end
  else
    Result:=False;
end;

procedure TStrPtrDic.FreeItem(const Item: TTreeData);
begin
  TObject(Item.Data).Free;
end;

procedure TStrPtrDic.FreeItems;
begin
  if Self <> nil then Traversal(FreeItem);
end;

procedure TStrPtrDic.DebugWriteItem(const Item: TTreeData);
begin
  writeln(Item.Key, ' ', IntToHex(Int32(Item.Data), 8));
end;

procedure TStrPtrDic.DebugWrite;
begin
  UpwardTraversal(DebugWriteItem);
end;

{ TCaseSensStrPtrDic }

class function TCaseSensStrPtrDic.Compare(const S1, S2: String): Integer;
begin
  Result:=AnsiCompareStr(S1, S2);
end;

{ TExactStrPtrDic }

class function TExactStrPtrDic.Compare(const S1, S2: String): Integer;
begin
  Result:=CompareStr(S1, S2);
end;

end.
