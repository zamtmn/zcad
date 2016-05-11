{ Version 040803. Copyright © Alexey A.Chernobaev, 1996-2004 }

unit WSPDicFast;
{
  —ловарь WideString-Pointer.

  WideString-Pointer dictionary.
}

interface

{$I VCheck.inc}

uses
  {$IFDEF V_WIN}Windows,
  {$IFDEF DYNAMIC_NLS}NLSProcsDyn{$ELSE}VUnicode, VWideStr{$ENDIF},
  {$ENDIF}
  SysUtils, ExtType, ExtSys, Pointerv, WStrLst, VStream, VectStr, VectErr;

type
  TDicKey = WideString;
  TDicData = Pointer;

  {$DEFINE VIRTUAL_COMPARE}
  {$DEFINE NODE_IS_CLASS}
  {$I RBTree.def}

  EDicError = class(Exception);

  PDicData = ^TDicData;

  TWSPNode = class(TNode)
  protected
    FKey: PWideChar;
    procedure MoveFrom(Source: TNode); override;
    function GetKey: WideString; virtual;
    procedure SetKey(const AKey: WideString); virtual;
  public
    Data: TDicData;
    destructor Destroy; override;
    property Key: WideString read GetKey write SetKey;
  end;

  TWSPPackedNode = class(TWSPNode)
    function GetKey: WideString; override;
    procedure SetKey(const AKey: WideString); override;
    destructor Destroy; override;
  end;

  TWideStrPtrDic = class(TRBTree)
  protected
    FTempNode: TWSPNode;
    function CMP(const a, b: TTreeData): Integer; override;
    function CreateNode: TNode; override;
    procedure WriteItem(VStream: TVStream; const Item: TTreeData); override;
    function ReadItem(VStream: TVStream): TTreeData; override;
    procedure FreeItem(const Item: TTreeData);
  public
    destructor Destroy; override;

    function Add(const AKey: TDicKey; const AData: TDicData): Boolean;
    function AddIfNew(const AKey: TDicKey; const AData: TDicData): Boolean;
    function Find(const AKey: TDicKey): Boolean;
    function FindLessEqual(const AKey: TDicKey; var FoundKey: TDicKey;
      var FoundData: TDicData): Boolean;
    function FindGreaterEqual(const AKey: TDicKey; var FoundKey: TDicKey;
      var FoundData: TDicData): Boolean;
    procedure Delete(const AKey: TDicKey);
    function Data(const AKey: TDicKey): TDicData;
    function PData(const AKey: TDicKey): PDicData;
    function FindKeyForData(const Data: TDicData; var Key: TDicKey): Boolean;

    function AddFast(ANode: TWSPNode): Boolean;
    function AddIfNewFast(ANode: TWSPNode): Boolean;
    function PDataFast(ANode: TWSPNode): PDicData;

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

  TCaseSensWideStrPtrDic = class(TWideStrPtrDic)
  protected
    function CMP(const a, b: TTreeData): Integer; override;
  end;

  TWideStrPtrPackedDic = class(TWideStrPtrDic)
  protected
    function CMP(const a, b: WSPDicFast.TTreeData): Integer; override;
    function CreateNode: TNode; override;
  end;

  TWideStrPtrDicClass = class of TWideStrPtrDic;

  TWideStrPtrDicIterator = TRBTreeIterator;

function UnpackWideString(Key: Pointer): WideString;

implementation

{$IFDEF CHECK_OBJECTS_FREE}
uses ChckFree;
{$ENDIF}

{$I RBTree.imp}

const
  SKeyNotFound = SKeyNotFound_s;

{ TWSPNode }

destructor TWSPNode.Destroy;
begin
  FreeMem(FKey);
  inherited Destroy;
end;

procedure TWSPNode.MoveFrom(Source: TNode);
begin
  FKey:=TWSPNode(Source).FKey;
  Data:=TWSPNode(Source).Data;
  TWSPNode(Source).FKey:=nil;
end;

function TWSPNode.GetKey: WideString;
begin
  Result:=WideString(FKey);
end;

procedure TWSPNode.SetKey(const AKey: WideString);
var
  L, Sz: Integer;
begin
  FreeMem(FKey);
  L:=Length(AKey);
  Sz:=(L + 1) * 2;
  GetMem(FKey, Sz);
  if L > 0 then
    Move(Pointer(AKey)^, FKey^, Sz)
  else
    FKey:=nil;
end;

{ TWSPPackedNode }

function UnpackWideString(Key: Pointer): WideString;
var
  L: Integer;
  C: Char;
  P: PWideChar;
begin
  if Key <> nil then
    if Int32(Key) and 1 <> 0 then begin
      Int32(Key):=Int32(Key) and not 1;
      L:=StrLen(Key);
      SetLength(Result, L);
      if L = 0 then
        Exit;
      P:=Pointer(Result);
      repeat
        C:=PChar(Key)^;
        P^:=WideChar(C);
        if C = #0 then
          Break;
        Inc(PChar(Key));
        Inc(P);
      until False;
    end
    else
      Result:=WideString(PWideChar(Key))
  {$IFNDEF V_AUTOINITSTRINGS}
  else
    Result:='';
  {$ENDIF}
end;

function TWSPPackedNode.GetKey: WideString;
begin
  Result:=UnpackWideString(FKey);
end;

procedure TWSPPackedNode.SetKey(const AKey: WideString);
var
  Sz: Integer;
  PS, PD: PChar;
begin
  FreeMem(Pointer(Int32(FKey) and not 1));
  Sz:=Length(AKey);
  if Sz > 0 then begin
    Inc(Sz);
    if IsASCIIWideString(AKey) then begin
      GetMem(FKey, Sz);
      PS:=Pointer(PWideChar(AKey));
      PD:=Pointer(FKey);
      repeat
        PD^:=PS^;
        if PS^ = #0 then
          Break;
        Inc(PS, 2);
        Inc(PD);
      until False;
      Int32(FKey):=Int32(FKey) or 1;
    end
    else begin
      Sz:=Sz * 2;
      GetMem(FKey, Sz);
      Move(Pointer(AKey)^, FKey^, Sz);
    end;
  end
  else
    FKey:=nil;
end;

destructor TWSPPackedNode.Destroy;
begin
  Int32(FKey):=Int32(FKey) and not 1;
  inherited Destroy;
end;

{ TWideStrPtrDic }

destructor TWideStrPtrDic.Destroy;
begin
  if FTempNode <> nil then begin
    FTempNode.FKey:=nil; // не уничтожать - это копи€!
    FTempNode.Free;
  end;
  inherited Destroy;
end;

function TWideStrPtrDic.Add(const AKey: TDicKey; const AData: TDicData): Boolean;
var
  Node: PNode;
  AddNode: TWSPNode;
begin
  AddNode:=TWSPNode(CreateNode);
  try
    AddNode.Key:=AKey;
    if not FFindNode(AddNode, Node) then begin
      AddNode.Data:=AData;
      FInsertNode(AddNode, Node);
      Result:=True;
    end
    else begin
      TWSPNode(Node).Data:=AData;
      Result:=False;
    end;
  finally
    AddNode.Free;
  end;
end;

function TWideStrPtrDic.AddIfNew(const AKey: TDicKey; const AData: TDicData): Boolean;
var
  Node: PNode;
  AddNode: TWSPNode;
begin
  AddNode:=TWSPNode(CreateNode);
  try
    AddNode.Key:=AKey;
    if not FFindNode(AddNode, Node) then begin
      AddNode.Data:=AData;
      FInsertNode(AddNode, Node);
      Result:=True;
    end
    else
      Result:=False;
  finally
    AddNode.Free;
  end;
end;

function TWideStrPtrDic.Find(const AKey: TDicKey): Boolean;
begin
  if FTempNode = nil then
    FTempNode:=TWSPNode(CreateNode);
  FTempNode.FKey:=Pointer(AKey);
  Result:=inherited Find(FTempNode);
end;

function TWideStrPtrDic.FindLessEqual(const AKey: TDicKey; var FoundKey: TDicKey;
  var FoundData: TDicData): Boolean;
var
  TreeFoundData: TTreeData;
begin
  if FTempNode = nil then
    FTempNode:=TWSPNode(CreateNode);
  FTempNode.FKey:=Pointer(AKey);
  Result:=inherited FindLessEqual(FTempNode, TreeFoundData);
  if Result then begin
    FoundKey:=TWSPNode(TreeFoundData).Key;
    FoundData:=TWSPNode(TreeFoundData).Data;
  end;
end;

function TWideStrPtrDic.FindGreaterEqual(const AKey: TDicKey; var FoundKey: TDicKey;
  var FoundData: TDicData): Boolean;
var
  TreeFoundData: TTreeData;
begin
  if FTempNode = nil then
    FTempNode:=TWSPNode(CreateNode);
  FTempNode.FKey:=Pointer(AKey);
  Result:=inherited FindGreaterEqual(FTempNode, TreeFoundData);
  if Result then begin
    FoundKey:=TWSPNode(TreeFoundData).Key;
    FoundData:=TWSPNode(TreeFoundData).Data;
  end;
end;

procedure TWideStrPtrDic.Delete(const AKey: TDicKey);
var
  Node: PNode;
begin
  if FTempNode = nil then
    FTempNode:=TWSPNode(CreateNode);
  FTempNode.FKey:=Pointer(AKey);
  Node:=FindNode(FTempNode);
  if Node <> nil then
    DeleteNode(Node)
  else
    raise EDicError.CreateFmt(SKeyNotFound, [AKey]);
end;

function TWideStrPtrDic.Data(const AKey: TDicKey): TDicData;
var
  Node: PNode;
begin
  if FTempNode = nil then
    FTempNode:=TWSPNode(CreateNode);
  FTempNode.FKey:=Pointer(AKey);
  Node:=FindNode(FTempNode);
  if Node <> nil then
    Result:=TWSPNode(Node).Data
  else
    raise EDicError.CreateFmt(SKeyNotFound, [AKey]);
end;

function TWideStrPtrDic.PData(const AKey: TDicKey): PDicData;
begin
  if FTempNode = nil then
    FTempNode:=TWSPNode(CreateNode);
  FTempNode.FKey:=Pointer(AKey);
  PNode(Result):=FindNode(FTempNode);
  if Result <> nil then
    Result:=@(TWSPNode(Result).Data);
end;

function TWideStrPtrDic.FindKeyForData(const Data: TDicData; var Key: TDicKey): Boolean;
var
  It: TRBTreeIterator;
begin
  Result:=False;
  It:=TRBTreeIterator.Create(Self);
  try
    while not It.Eof do begin
      if TWSPNode(It.Data).Data = Data then begin
        Key:=TWSPNode(It.Data).Key;
        Result:=True;
        Exit;
      end;
      It.Next;
    end;
  finally
    It.Free;
  end;
end;

function TWideStrPtrDic.AddFast(ANode: TWSPNode): Boolean;
var
  Node: PNode;
begin
  if not FFindNode(ANode, Node) then begin
    FInsertNode(ANode, Node);
    Result:=True;
  end
  else begin
    TWSPNode(Node).Data:=ANode.Data;
    Result:=False;
  end;
end;

function TWideStrPtrDic.AddIfNewFast(ANode: TWSPNode): Boolean;
var
  Node: PNode;
begin
  if not FFindNode(ANode, Node) then begin
    FInsertNode(ANode, Node);
    Result:=True;
  end
  else
    Result:=False;
end;

function TWideStrPtrDic.PDataFast(ANode: TWSPNode): PDicData;
begin
  PNode(Result):=FindNode(ANode);
  if Result <> nil then
    Result:=@(TWSPNode(Result).Data);
end;

{ *** }

function TWideStrPtrDic.CMP(const a, b: TTreeData): Integer;
var
  PW1, PW2: PWideChar;
begin
  PW1:=TWSPNode(a).FKey;
  PW2:=TWSPNode(b).FKey;
  if PW1 = PW2 then begin
    Result:=0;
    Exit;
  end;
  if PW1 = nil then begin
    Result:=-1;
    Exit;
  end;
  if PW2 = nil then begin
    Result:=1;
    Exit;
  end;
  {$IFDEF V_WIN}
  Result:=CompareTextBufWide(PW1, PW2, StrLenW(PW1), StrLenW(PW2));
  {$ELSE}
  Result:=WideCompareText(WideString(PW1), WideString(PW2));
  {$ENDIF}
end;

function TWideStrPtrDic.CreateNode: TNode;
begin
  Result:=TWSPNode.Create;
end;

procedure TWideStrPtrDic.WriteItem(VStream: TVStream; const Item: TTreeData);
begin
  VStream.WriteWideString(TWSPNode(Item).Key);
  VStream.WriteInt32(Int32(TWSPNode(Item).Data));
end;

function TWideStrPtrDic.ReadItem(VStream: TVStream): TTreeData;
begin
  Result:=CreateNode;
  try
    TWSPNode(Result).Key:=VStream.ReadWideString;
    TWSPNode(Result).Data:=Pointer(VStream.ReadInt32);
  except
    Result.Free;
    raise;
  end;
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
      S.Items[I]:=TWSPNode(It.Data).Key;
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
      S.Items[I]:=TWSPNode(It.Data).Key;
      DataVector[I]:=TWSPNode(It.Data).Data;
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
      DataVector[I]:=TWSPNode(It.Data).Data;
      Inc(I);
      It.Next;
    end;
  finally
    It.Free;
  end;
end;

procedure TWideStrPtrDic.FreeAndDelete(const AKey: TDicKey);
var
  Node: PNode;
begin
  if FTempNode = nil then
    FTempNode:=TWSPNode(CreateNode);
  FTempNode.FKey:=Pointer(AKey);
  Node:=FindNode(FTempNode);
  if Node <> nil then begin
    TObject(TWSPNode(Node).Data).Free;
    DeleteNode(Node);
  end
  else
    raise EDicError.CreateFmt(SKeyNotFound, [AKey]);
end;

procedure TWideStrPtrDic.FreeItem(const Item: TTreeData);
begin
  TObject(TWSPNode(Item).Data).Free;
end;

procedure TWideStrPtrDic.FreeItems;
begin
  if Self <> nil then
    Traversal(FreeItem);
end;

procedure TWideStrPtrDic.DebugWriteItem(const Item: TTreeData);
begin
  writeln(String(TWSPNode(Item).Key), ' ', IntToHex(Int32(TWSPNode(Item).Data), 8));
end;

procedure TWideStrPtrDic.DebugWrite;
begin
  UpwardTraversal(DebugWriteItem);
end;

{ TCaseSensWideStrPtrDic }

function TCaseSensWideStrPtrDic.CMP(const a, b: TTreeData): Integer;
begin
  Result:=WStrCmp(TWSPNode(a).FKey, TWSPNode(b).FKey);
end;

{ TWideStrPtrPackedDic }

function TWideStrPtrPackedDic.CMP(const a, b: WSPDicFast.TTreeData): Integer;
begin
  {$IFDEF V_WIN}
  Result:=CompareTextWide(TWSPNode(a).Key, TWSPNode(b).Key);
  {$ELSE}
  Result:=WideCompareText(TWSPNode(a).Key, TWSPNode(b).Key);
  {$ENDIF}
end;

function TWideStrPtrPackedDic.CreateNode: TNode;
begin
  Result:=TWSPPackedNode.Create;
end;

end.
