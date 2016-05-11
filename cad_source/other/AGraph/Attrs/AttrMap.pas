{ Version 040228. Copyright © Alexey A.Chernobaev, 1996-2004 }

unit AttrMap;

interface

{$I VCheck.inc}

uses
  SysUtils, ExtType, AttrType, Vectors, UInt8v, Int32v, StrLst, SPDic, VStream,
  VTxtStrm, VectStr, VectErr, AttrErr;

type
  TAttrMap = class(TVectorObject)
  protected
    FAttrNames: TStrLst;
    FAttrTypes, FSizes: TByteVector;
    FAttrOffsets, FOffsets: TInt32Vector;
    FDic: TStrPtrDic;
    Temp: Int32;
    procedure CopyItem(const Item: TTreeData);
    procedure GetNameTypeOffset(const Item: TTreeData);
    procedure GetOffsetSize(const Item: TTreeData);
    procedure GetNamesTypesOffsets;
    procedure ClearNamesTypesOffsets;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    { удалить информацию о созданных атрибутах }
    procedure WriteToStream(VStream: TVStream); {virtual;}
    { запись в поток }
    procedure ReadFromStream(VStream: TVStream); {virtual;}
    { чтение из потока }
    procedure WriteToTextStream(TextStream: TTextStream);
    { запись в текстовый поток }
    procedure ReadFromTextStream(TextStream: TTextStream);
    { чтение из текстового потока }
    procedure Assign(Source: TAttrMap); {virtual;}
    function CompatibleMap(AMap: TAttrMap): Bool;
    { проверяет, являются ли Self и AMap совместимыми, т.е. обладают одинаковым
      набором атрибутов (с точностью до смещений атрибутов) }
    function SafeCreateAttr(const Name: String; AType: TAttrType): Integer;
    { если атрибут типа AType с именем Name не был определен, то создает атрибут
      и возвращает смещение вновь созданного атрибута; если такой атрибут был
      определен, то возвращает -1; если атрибут с именем Name был определен,
      но его тип не совпадает с AType, то возбуждает исключительную ситуацию }
    function CreateAttr(const Name: String; AType: TAttrType): Integer;
    { создает атрибут типа AType с именем Name и возвращает его смещение;
      если атрибут с именем Name был определен, то возбуждает исключительную
      ситуацию }
    function SafeDropAttr(const Name: String): Bool;
    { если атрибут с именем Name определен, то уничтожает атрибут и возвращает
      True, иначе возвращает False }
    procedure DropAttr(const Name: String);
    { если атрибут с именем Name определен, то уничтожает атрибут, иначе
      возбуждает исключительную ситуацию }
    function GetType(const Name: String): TExtAttrType;
    { возвращает тип атрибута с именем Name, либо AttrNone, если атрибут не был
      определен }
    function Offset(const Name: String): Integer;
    { смещение атрибута с заданным именем }
    function Count: Integer;
    { количество атрибутов }
    function IndexOfAttr(const Name: String): Integer;
    { индекс атрибута с заданным именем }
    function AttrTypeByIndex(I: Integer): TExtAttrType;
    { тип атрибута с заданным индексом }
    function OffsetByIndex(I: Integer): Integer;
    { смещение атрибута с заданным индексом }
    function AttrName(I: Integer): String;
    { название I-го атрибута (названия упорядочены по возрастанию, без учета
      регистра) }
    function AttrOffsets: TInt32Vector;
    { смещения атрибутов }
  end;

implementation

{$IFDEF CHECK_OBJECTS_FREE}
uses ChckFree;
{$ENDIF}

constructor TAttrMap.Create;
begin
  inherited Create;
  FAttrNames:=TStrLst.Create;
  FAttrTypes:=TByteVector.Create(0, 0);
  FAttrOffsets:=TInt32Vector.Create(0, 0);
  FDic:=TStrPtrDic.Create;
end;

destructor TAttrMap.Destroy;
begin
  FAttrNames.Free;
  FAttrTypes.Free;
  FAttrOffsets.Free;
  FDic.FreeItems;
  FDic.Free;
  inherited Destroy;
end;

procedure TAttrMap.Clear;
begin
  FDic.FreeItems;
  FDic.Clear;
end;

type
  TItem = class
    AType: TExtAttrType;
    Offset: Int32;
    {$IFDEF CHECK_OBJECTS_FREE}
    constructor Create;
    destructor Destroy; override;
    {$ENDIF}
  end;
  PItem = ^TItem;

{$IFDEF CHECK_OBJECTS_FREE}
constructor TItem.Create;
begin
  inherited Create;
  RegisterObjectCreate(Self);
end;

destructor TItem.Destroy;
begin
  RegisterObjectFree(Self);
  inherited Destroy;
end;
{$ENDIF}

type
  TWriteHelper = class
    Stream: TObject;
    procedure WriteItemToStream(const Item: TTreeData);
    procedure WriteItemToTextStream(const Item: TTreeData);
  end;

procedure TWriteHelper.WriteItemToStream(const Item: TTreeData);
begin
  TVStream(Stream).WriteString(Item.Key);
  With TItem(Item.Data) do begin
    TVStream(Stream).WriteInt8(Int8(AType));
    TVStream(Stream).WriteInt32(Int32(Offset));
  end;
end;

procedure TWriteHelper.WriteItemToTextStream(const Item: TTreeData);
begin
  TTextStream(Stream).WriteString(Format('%s: %s', [Item.Key,
    AttrNames[TItem(Item.Data).AType]]));
end;

procedure TAttrMap.WriteToStream(VStream: TVStream);
var
  WriteHelper: TWriteHelper;
begin
  VStream.WriteInt32(FDic.Count);
  WriteHelper:=TWriteHelper.Create;
  try
    WriteHelper.Stream:=VStream;
    FDic.Traversal(WriteHelper.WriteItemToStream);
  finally
    WriteHelper.Free;
  end;
end;

procedure TAttrMap.ReadFromStream(VStream: TVStream);
var
  I: Integer;
  S: String;
  DicItem: TItem;
begin
  Clear;
  for I:=0 to VStream.ReadInt32 - 1 do begin
    S:=VStream.ReadString;
    DicItem:=TItem.Create;
    try
      DicItem.AType:=TExtAttrType(VStream.ReadInt8);
      DicItem.Offset:=VStream.ReadInt32;
      FDic.Add(S, DicItem);
    except
      DicItem.Free;
      raise;
    end;
  end;
end;

procedure TAttrMap.WriteToTextStream(TextStream: TTextStream);
var
  WriteHelper: TWriteHelper;
begin
  TextStream.WriteString('{');
  WriteHelper:=TWriteHelper.Create;
  try
    WriteHelper.Stream:=TextStream;
    FDic.UpwardTraversal(WriteHelper.WriteItemToTextStream);
  finally
    WriteHelper.Free;
  end;
  TextStream.WriteString('}');
end;

procedure TAttrMap.ReadFromTextStream(TextStream: TTextStream);
var
  S: String;
  I: Integer;
begin
  Clear;
  if TextStream.ReadTrimmed <> '{' then
    Error(SWrongTextStreamFormat);
  while not TextStream.EOF do begin
    S:=TextStream.ReadTrimmed;
    if S = '}' then
      Exit;
    I:=Pos(':', S);
    if I = 0 then
      Error(SWrongTextStreamFormat);
    CreateAttr(Trim(Copy(S, 1, I - 1)), AttrTypeByName(Trim(Copy(S, I + 1,
      Length(S)))));
  end;
end;

procedure TAttrMap.CopyItem(const Item: TTreeData);
begin
  CreateAttr(Item.Key, TItem(Item.Data).AType);
end;

procedure TAttrMap.Assign(Source: TAttrMap);
begin
  Clear;
  Source.FDic.Traversal(CopyItem);
end;

function TAttrMap.CompatibleMap(AMap: TAttrMap): Bool;
var
  It1, It2: TRBTreeIterator;
  Data1, Data2: TTreeData;
begin
  Result:=False;
  if FDic.Count = AMap.FDic.Count then begin
     It1:=TRBTreeIterator.Create(FDic);
     It2:=nil;
     try
       It2:=TRBTreeIterator.Create(AMap.FDic);
       while not It1.EOF do begin
         Data1:=It1.Data;
         Data2:=It2.Data;
         if (FDic.Compare(Data1.Key, Data2.Key) <> 0) or
           (TItem(Data1.Data).AType <> TItem(Data1.Data).AType)
         then
           Exit;
         It1.Next;
         It2.Next;
       end;
     finally
       It1.Free;
       It2.Free;
     end;
     Result:=True;
  end;
end;

procedure TAttrMap.GetOffsetSize(const Item: TTreeData);
begin
  With TItem(Item.Data) do begin
    FOffsets[Temp]:=Offset;
    FSizes[Temp]:=AttrSizes[AType];
  end;
  Inc(Temp);
end;

function TAttrMap.SafeCreateAttr(const Name: String; AType: TAttrType): Integer;
var
  I, ACount, Size, NewOffset, OldOffset: Integer;
  P: Pointer;
  DicItem: TItem;
begin
  if Name = '' then
    Error(SErrorInParameters);
  Result:=-1;
  P:=FDic.PData(Name);
  if P = nil then begin
    ClearNamesTypesOffsets;
    NewOffset:=0;
    ACount:=FDic.Count;
    if ACount > 0 then begin
      FOffsets:=TInt32Vector.Create(ACount, 0);
      FSizes:=nil;
      try
        FSizes:=TByteVector.Create(ACount, 0);
        Temp:=0;
        FDic.Traversal(GetOffsetSize);
        Size:=AttrSizes[AType];
        { ищем "дырку" достаточного размера ("дырка" образуется после DropAttr) }
        FOffsets.SortWith(FSizes);
        for I:=0 to ACount - 2 do begin
          OldOffset:=FOffsets[I] + FSizes[I];
          if FOffsets[I + 1] - OldOffset >= Size then begin
            NewOffset:=OldOffset;
            Break;
          end;
        end;
        if NewOffset = 0 then begin
          I:=ACount - 1;
          NewOffset:=FOffsets[I] + FSizes[I];
        end;
      finally
        FOffsets.Free;
        FSizes.Free;
      end;
    end;
    DicItem:=TItem.Create;
    try
      DicItem.AType:=AType;
      DicItem.Offset:=NewOffset;
      FDic.Add(Name, DicItem);
    except
      DicItem.Free;
      raise;
    end;
    Result:=NewOffset;
  end
  else { если атрибут есть, но другого типа, то ошибка }
    if PItem(P)^.AType <> TExtAttrType(AType) then
      ErrorFmt(SAttrAlreadyDefined_s, [Name]);
end;

function TAttrMap.CreateAttr(const Name: String; AType: TAttrType): Integer;
begin
  Result:=SafeCreateAttr(Name, AType);
  if Result < 0 then
    ErrorFmt(SAttrAlreadyDefined_s, [Name]);
end;

function TAttrMap.SafeDropAttr(const Name: String): Bool;
var
  P: Pointer;
begin
  P:=FDic.PData(Name);
  if P <> nil then begin
    ClearNamesTypesOffsets;
    PItem(P)^.Free;
    FDic.Delete(Name);
    Result:=True;
  end
  else
    Result:=False;
end;

procedure TAttrMap.DropAttr(const Name: String);
begin
  if not SafeDropAttr(Name) then
    ErrorFmt(SAttrNotDefined_s, [Name]);
end;

function TAttrMap.GetType(const Name: String): TExtAttrType;
var
  P: Pointer;
begin
  P:=FDic.PData(Name);
  if P <> nil then
    Result:=PItem(P)^.AType
  else
    Result:=AttrNone;
end;

{$IFDEF NOWARN}{$WARNINGS OFF}{$ENDIF}
function TAttrMap.Offset(const Name: String): Integer;
var
  P: Pointer;
begin
  P:=FDic.PData(Name);
  if P <> nil then
    Result:=PItem(P)^.Offset
  else
    ErrorFmt(SAttrNotDefined_s, [Name]);
end;
{$IFDEF NOWARN}{$WARNINGS ON}{$ENDIF}

function TAttrMap.Count: Integer;
begin
  Result:=FDic.Count;
end;

procedure TAttrMap.GetNameTypeOffset(const Item: TTreeData);
begin
  FAttrNames.Items[Temp]:=Item.Key;
  With TItem(Item.Data) do begin
    FAttrTypes[Temp]:=Byte(AType);
    FAttrOffsets[Temp]:=Offset;
  end;
  Inc(Temp);
end;

procedure TAttrMap.GetNamesTypesOffsets;
var
  N: Integer;
begin
  if FAttrNames.Count = 0 then begin
    N:=FDic.Count;
    FAttrNames.Count:=N;
    FAttrTypes.Count:=N;
    FAttrOffsets.Count:=N;
    Temp:=0;
    FDic.UpwardTraversal(GetNameTypeOffset);
  end;
end;

procedure TAttrMap.ClearNamesTypesOffsets;
begin
  FAttrNames.Clear;
  FAttrTypes.Clear;
  FAttrOffsets.Clear;
end;

function TAttrMap.IndexOfAttr(const Name: String): Integer;
begin
  GetNamesTypesOffsets;
  Result:=FAttrNames.IndexOf(Name);
end;

function TAttrMap.AttrTypeByIndex(I: Integer): TExtAttrType;
begin
  GetNamesTypesOffsets;
  Result:=TExtAttrType(FAttrTypes[I]);
end;

function TAttrMap.OffsetByIndex(I: Integer): Integer;
begin
  GetNamesTypesOffsets;
  Result:=FAttrOffsets[I];
end;

function TAttrMap.AttrName(I: Integer): String;
begin
  GetNamesTypesOffsets;
  Result:=FAttrNames.Items[I];
end;

function TAttrMap.AttrOffsets: TInt32Vector;
begin
  GetNamesTypesOffsets;
  Result:=FAttrOffsets;
end;

end.
