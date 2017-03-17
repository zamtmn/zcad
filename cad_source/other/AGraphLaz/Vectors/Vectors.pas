{ Version 050702. Copyright © Alexey A.Chernobaev, 1996-2005 }

unit Vectors;

interface

{$I VCheck.inc}

uses
  SysUtils, ExtType, ExtSys, {$IFDEF USE_STREAM64}VStrm64{$ELSE}VStream{$ENDIF},
  VectErr;

const
  MaxElemSize = {$IFNDEF V_32}16384{$ELSE}1048576{$ENDIF};
  { максимальный размер элемента вектора }
  { maximum vector element size }

type
  TElemSize = 1..MaxElemSize;

  EVectorError = class(Exception);

  TVectorObject = class
    class procedure Error(const Msg: String);
    class procedure ErrorFmt(const Msg: String; const Data: array of const);
  end;

  { базовый класс векторов }
  { base vector class }
  TVector = class(TVectorObject)
  protected
    FItems: PRegular;
    FCount, FCapacity: Integer;
    FElemSize: TElemSize;
    function GetCount: Integer; virtual;
    procedure SetCount(ACount: Integer); virtual;
    function ItemsSize: Integer;
    procedure ChangeSize(ACount: Integer);
    procedure Resize(ACount: Integer);
    procedure InitMemory(Offset, InitCount: Integer); virtual;
    procedure SetCapacity(NewCapacity: Integer); virtual;
    procedure RawAssign(Source: TVector);
    procedure RawCopyRange(FromIndex: Integer; Source: TVector; SourceFrom,
      SourceTo: Integer);
    procedure RawExchangeRange(FromIndex, ToIndex, ACount: Integer);
    function RawEqualTo(V: TVector): Bool;
  public
    constructor Create(AnElemSize: TElemSize);
    { создает пустой (Count = 0) вектор с элементами размером ElemSize байт }
    { creates empty (Count = 0) vector with elements of size ElemSize bytes }
    destructor Destroy; override;
    procedure WriteToStream(VStream: TVStream); virtual;
    { записывает вектор в поток }
    { writes vector to the stream }
    procedure ReadFromStream(VStream: TVStream); virtual;
    { считывает вектор из потока }
    { reads vector from the stream }
    procedure Get(I: Integer; var Result);
    { возвращает I-й элемент }
    { returns Ith element }
    procedure Put(I: Integer; const Data);
    { изменяет I-й элемент }
    { changes Ith element }
    procedure Expand(I: Integer); virtual;
    { увеличивает размер вектора на единицу и перемещает все элементы с
      индексами >= I на одну позицию вверх }
    { increases vector size by one and moves all elements with indexes >= I up }
    procedure Assign(Source: TVector); virtual;
    { присваивает текущему вектору значения вектора Source }
    { assigns values of vector Source to the current vector }
    procedure CopyRange(FromIndex: Integer; Source: TVector; SourceFrom,
      SourceTo: Integer); virtual;
    { копирует в текущий вектор элементы [SourceFrom..SourceTo] вектора Source,
      размещая их в текущем векторе, начиная с FromIndex; при необходимости
      увеличивает размер текущего вектора }
    { copies elements [SourceFrom..SourceTo] of the vector Source to the current
      vector, placing them from the index FromIndex; increases the length of the
      current vector if needed }
    procedure ExchangeRange(FromIndex, ToIndex, ACount: Integer); virtual;
    { меняет местами ACount элементов: с индексами FromIndex и ToIndex,
      FromIndex+1 и ToIndex+1, ... FromIndex+ACount-1 и ToIndex+ACount-1;
      диапазоны элементов не должны перекрываться }
    { exchanges ACount elements: with indexes FromIndex and ToIndex,
      FromIndex+1 and ToIndex+1, ... FromIndex+ACount-1 and ToIndex+ACount-1;
      element ranges must not overlap }
    function EqualTo(V: TVector): Bool; virtual;
    { сравнивает векторы; векторы считаются равными, если их размеры (FCount) и
      данные (FItems^) совпадают }
    { compares vectors; vectors are considered equal if both their sizes
      (FCount) and data (FItem^) are equal }
    procedure Delete(I: Integer); virtual;
    { удаляет I-й элемент из вектора }
    { deletes element I from the vector }
    procedure DeleteRange(I, ACount: Integer); virtual;
    { если ACount > 0, то удаляет ACount элементов, начиная с I (предусловие:
      I + ACount <= Count), иначе ничего не делает }
    { if ACount > 0 then deletes ACount elements beginning from I (precondition:
      I + ACount <= Count), otherwise does nothing }
    procedure Clear; virtual;
    { очищает вектор (Count:=0) }
    { clears the vector (Count:=0) }
    function SizeInBytes: Integer; virtual;
    { возвращает размер вектора в байтах, с учетом всех полей, но без учета того,
      что фактически память распределяется блоками по несколько элементов (см.
      Capacity, Quantum) }
    { returns vector size in bytes including all fields but not considering the
      fact that actually memory is allocated by blocks (see Capacity, Quantum) }
    procedure Pack; virtual;
    { Capacity:=FCount }
    procedure EnsureRoom(N: Integer);
    { if Capacity < FCount + N then Capacity:=FCount + N }
    procedure Grow(Delta: Integer);
    { Count:=Count + Delta }
    property ElemSize: TElemSize read FElemSize;
    { размер элемента вектора }
    { vector element size }
    property Count: Integer read GetCount write SetCount;
    { количество элементов }
    { number of elements in the vector }
    property Capacity: Integer read FCapacity write SetCapacity;
    { фактический размер вектора в памяти в блоках по ElemSize байт каждый }
    { actual vector size in blocks by ElemSize bytes each }
    property Memory: PRegular read FItems;
    { данные }
    { raw data }
  end;

  TSortableVector = class(TVector)
  public
    function Compare(I: Integer; const V): Int32; virtual; abstract;
    { возвращает число больше нуля, если I-й элемент больше V, нуль, если
      они равны, и число меньше нуля, если I-й элемент меньше V }
    { returns number greater then zero if element I is greater then V, zero
      if they are equal and number less then zero if element I is less then V }
    procedure Exchange(I, J: Integer); virtual; abstract;
    { меняет местами элементы с индексами I и J }
    { exchanges elements with indexes I and J }
    procedure GetUntyped(I: Integer; var Result); virtual; abstract;
    { возвращает I-ый элемент (размер Result должен быть не меньше ElemSize) }
    { returns element I (size of Result can't be less then ElemSize) }
    procedure SortRange(L, R: Integer); virtual;
    { сортирует элементы с L по R по возрастанию (L, R = 0..Count - 1) }
    { sorts elements from L to R ascending (L, R = 0..Count - 1) }
    procedure SortRangeDesc(L, R: Integer); virtual;
    { сортирует элементы с L по R по убыванию (L, R = 0..Count - 1) }
    { sorts elements from L to R descending (L, R = 0..Count - 1) }
    procedure Sort; virtual;
    { сортирует вектор по возрастанию }
    { sorts vector ascending }
    procedure SortDesc; virtual;
    { сортирует вектор по убыванию }
    { sorts vector descending }
    procedure SortRangeWithEx(L, R: Integer; AVector: TSortableVector;
      Ascending: Boolean);
    procedure SortRangeWith(L, R: Integer; AVector: TSortableVector);
    procedure SortRangeDescWith(L, R: Integer; AVector: TSortableVector);
    procedure SortWith(AVector: TSortableVector);
    { сортирует вектор по возрастанию, сохраняя соответствие между элементами
      данного вектора и вектора AVector; AVector должен иметь размер, не меньший,
      чем размер данного вектора }
    { sorts vector ascending preserving correspondence between elements of the
      current vector and vector AVector; size of AVector can not be less then
      the size of the current vector }
    procedure SortDescWith(AVector: TSortableVector);
    { сортирует вектор по убыванию, сохраняя соответствие между элементами
      данного вектора и вектора AVector; AVector должен иметь размер, не меньший,
      чем размер данного вектора }
    { sorts vector descending preserving correspondence between elements of the
      current vector and vector AVector; size of AVector can not be less then
      size of the current vector }
    procedure SortWithArrayEx(VectorArray: array of TSortableVector;
      Ascending: Boolean);
    procedure SortWithArray(VectorArray: array of TSortableVector);
    { аналог SortWith с переменным количеством параметров }
    { analog of SortWith with variable number of parameters }
    procedure SortDescWithArray(VectorArray: array of TSortableVector);
    { аналог SortWithDesc с переменным количеством параметров }
    { analog of SortWithDesc with variable number of parameters }
    procedure GroupSort(VectorArray: array of TSortableVector;
      Ascending: Boolean{$IFDEF V_DEFAULTS} = True{$ENDIF});
    procedure GroupSortEx(VectorArray: array of TSortableVector;
      SortDirectionsArray: array of Boolean;
      Ascending: Boolean{$IFDEF V_DEFAULTS} = True{$ENDIF});
    procedure Reverse;
    { инвертирует вектор (последний элемент становится первым, предпоследний -
      вторым, и т.д.) }
    { inverts the vector (last element becomes the first, next to last - the
      second, etc.) }
  end;

  TVectorClass = class of TVector;
  TSortableVectorClass = class of TSortableVector;

implementation

{$IFDEF CHECK_OBJECTS_FREE}
uses ChckFree;
{$ENDIF}

{ TVectorObject }

class procedure TVectorObject.Error(const Msg: String);
{$IFDEF V_DELPHI}{$IFDEF WIN32}
  function ReturnAddr: Pointer;
  asm
    MOV    EAX, [EBP+4]
  end;
{$ENDIF}{$ENDIF}
begin
  raise EVectorError.Create('Class ' + ClassName + ': ' + Msg)
    {$IFDEF V_DELPHI}{$IFDEF WIN32}at ReturnAddr{$ENDIF}{$ENDIF};
end;

class procedure TVectorObject.ErrorFmt(const Msg: String; const Data: array of const);
{$IFDEF V_DELPHI}{$IFDEF WIN32}
  function ReturnAddr: Pointer;
  asm
    MOV    EAX, [EBP+4]
  end;
{$ENDIF}{$ENDIF}
begin
  raise EVectorError.Create('Class ' + ClassName + ': ' + ErrMsg(Msg, Data))
    {$IFDEF V_DELPHI}{$IFDEF WIN32}at ReturnAddr{$ENDIF}{$ENDIF};
end;

{ TVector }

constructor TVector.Create(AnElemSize: TElemSize);
begin
  {$IFDEF CHECK_OBJECTS_FREE}
  RegisterObjectCreate(Self);
  {$ENDIF}
  inherited Create;
  FElemSize:=AnElemSize;
end;

destructor TVector.Destroy;
begin
  {$IFDEF CHECK_OBJECTS_FREE}
  RegisterObjectFree(Self);
  {$ENDIF}
  ChangeSize(0);
  inherited Destroy;
end;

function TVector.GetCount: Integer;
begin
  Result:=FCount;
end;

procedure TVector.InitMemory(Offset, InitCount: Integer);
begin
  SetNull(FItems^.Int8Array[Offset], InitCount);
end;

const
  Quantum = 4;
{ квант изменения размера вектора: при обращении к менеджеру памяти производится
  выделение или освобождение памяти не менее, чем для Quantum элементов; методы
  класса TVector оптимизированы для Quantum = 4 }

function TVector.ItemsSize: Integer;
begin
{  Result:=(FCount + Quantum - 1) div Quantum * Quantum * FElemSize;}
  Result:=((FCount + 3) and -4) * FElemSize;
end;

procedure TVector.ChangeSize(ACount: Integer);
var
  NewCount, NewSize: Int32;
begin
  {$IFDEF CHECK_VECTORS}
  if ACount < 0 then ErrorFmt(SRangeError_d, [ACount]);
  {$ENDIF}
{  NewCount:=(ACount + Quantum - 1) div Quantum * Quantum;}
  NewCount:=(ACount + 3) and -4;
  if NewCount <> FCapacity then begin
    NewSize:=NewCount * FElemSize;
    if NewSize > MaxBytes then ErrorFmt(SDataTooLarge_d, [NewSize]);
    {$IFDEF V_32}
    if NewSize<>0 then
                      ReAllocMem(FItems, NewSize)
                  else
                    begin
                      Freemem(FItems);
                      FItems:=nil;
                    end;
    {$ELSE}
    FItems:=ReAllocMem(FItems, FCapacity * FElemSize, NewSize);
    {$ENDIF}
    FCapacity:=NewCount;
  end;
  if NewCount > FCount then
    InitMemory(FCount * FElemSize, NewCount - FCount);
end;

procedure TVector.Resize(ACount: Integer);
{ отличается от ChangeSize тем, что не производит инициализацию вновь
  выделенного блока памяти, а также не производит проверку на превышение
  максимального размера MaxBytes; используется в Assign }
var
  NewCount: Int32;
begin
  NewCount:=(ACount + 3) and -4;
  if NewCount <> FCapacity then begin
    {$IFDEF V_32}
    ReAllocMem(FItems, NewCount * FElemSize);
    {$ELSE}
    FItems:=ReAllocMem(FItems, FCapacity * FElemSize, NewCount * FElemSize);
    {$ENDIF}
    FCapacity:=NewCount;
  end;
end;

procedure TVector.SetCount(ACount: Integer);
begin
  ChangeSize(ACount);
  FCount:=ACount;
end;

procedure TVector.WriteToStream(VStream: TVStream);
begin
  VStream.WriteInt32(FCount);
  VStream.WriteProc(FElemSize, SizeOf(FElemSize));
  if FCount > 0 then
    VStream.WriteProc(FItems^, FCount * FElemSize);
end;

procedure TVector.ReadFromStream(VStream: TVStream);
begin
  Clear;
  FCount:=VStream.ReadInt32;
  VStream.ReadProc(FElemSize, SizeOf(FElemSize));
  if FCount > 0 then begin
    ChangeSize(FCount);
    VStream.ReadProc(FItems^, FCount * FElemSize);
  end;
end;

procedure TVector.Get(I: Integer; var Result);
begin
  {$IFDEF CHECK_VECTORS}
  if (I < 0) or (I >= FCount) then ErrorFmt(SRangeError_d, [I]);
  {$ENDIF}
  Move((PChar(FItems) + (I * FElemSize))^, Result, FElemSize);
end;

procedure TVector.Put(I: Integer; const Data);
begin
  {$IFDEF CHECK_VECTORS}
  if (I < 0) or (I >= FCount) then ErrorFmt(SRangeError_d, [I]);
  {$ENDIF}
  Move(Data, (PChar(FItems) + (I * FElemSize))^, FElemSize);
end;

procedure TVector.Expand(I: Integer);
var
  Delta: Integer;
begin
  {$IFDEF CHECK_VECTORS}
  if (I < 0) or (I > FCount) then ErrorFmt(SRangeError_d, [I]);
  {$ENDIF}
  if FCapacity <= FCount then begin
    if FCapacity > 64 then
      Delta:=UInt32(FCapacity) div 4
    else { UInt32(...): allows Delphi 5 to generate more efficient code }
      if FCapacity > 8 then
        Delta:=16
      else
        Delta:=4;
    ChangeSize(FCapacity + Delta);
  end;
  Delta:=I * FElemSize;
  Move(FItems^.Int8Array[Delta], FItems^.Int8Array[Delta + FElemSize],
    (FCount - I) * FElemSize);
  Inc(FCount);
end;

procedure TVector.RawAssign(Source: TVector);
begin
  if FElemSize = Source.FElemSize then begin
    Resize(Source.FCount);
    FCount:=Source.FCount;
    Move(Source.FItems^, FItems^, FCount * FElemSize);
  end
  else
    Error(SAssignError);
end;

procedure TVector.Assign(Source: TVector);
begin
  RawAssign(Source);
end;

procedure TVector.RawCopyRange(FromIndex: Integer; Source: TVector; SourceFrom,
  SourceTo: Integer);
var
  NewLength, CopyCount: Integer;
begin
  {$IFDEF CHECK_VECTORS}
  if (FromIndex < 0) or (SourceFrom < 0) or (SourceTo >= Source.Count) or
    (SourceFrom > SourceTo)
  then
    Error(SErrorInParameters);
  {$ENDIF}
  if FElemSize = Source.FElemSize then begin
    CopyCount:=SourceTo - SourceFrom + 1;
    NewLength:=FromIndex + CopyCount;
    if NewLength > Count then
      Count:=NewLength;
    Move((PChar(Source.FItems) + SourceFrom * FElemSize)^,
      (PChar(FItems) + FromIndex * FElemSize)^, CopyCount * FElemSize);
  end
  else
    Error(SAssignError);
end;

procedure TVector.CopyRange(FromIndex: Integer; Source: TVector; SourceFrom,
  SourceTo: Integer);
begin
  RawCopyRange(FromIndex, Source, SourceFrom, SourceTo);
end;

procedure TVector.RawExchangeRange(FromIndex, ToIndex, ACount: Integer);
begin
  {$IFDEF CHECK_VECTORS}
  if (FromIndex < 0) or (ToIndex < 0) or (FromIndex + ACount > Count) or
    (ToIndex + ACount > Count) or
    (IntMin(FromIndex, ToIndex) + ACount > IntMax(FromIndex, ToIndex))
  then
    Error(SErrorInParameters);
  {$ENDIF}
  MemExchange(
    (PChar(FItems) + FromIndex * FElemSize)^,
    (PChar(FItems) + ToIndex * FElemSize)^,
    ACount * FElemSize);
end;

procedure TVector.ExchangeRange(FromIndex, ToIndex, ACount: Integer);
begin
  RawExchangeRange(FromIndex, ToIndex, ACount);
end;

function TVector.RawEqualTo(V: TVector): Bool;
begin
  if FCount = V.FCount then
    Result:=MemEqual(FItems^, V.FItems^, FCount * FElemSize)
  else
    Result:=False;
end;

function TVector.EqualTo(V: TVector): Bool;
begin
  Result:=RawEqualTo(V);
end;

procedure TVector.SetCapacity(NewCapacity: Integer);
begin
  if NewCapacity < FCount then ErrorFmt(SWrongVectorSize_d, [NewCapacity]);
  ChangeSize(NewCapacity);
end;

procedure TVector.Delete(I: Integer);
var
  Offset: Integer;
begin
  {$IFDEF CHECK_VECTORS}
  if (I < 0) or (I >= FCount) then ErrorFmt(SRangeError_d, [I]);
  {$ENDIF}
  Offset:=I * FElemSize;
  Dec(FCount);
  Move(FItems^.Int8Array[Offset + FElemSize], FItems^.Int8Array[Offset],
    (FCount - I) * FElemSize);
  if FCapacity - FCount > Int32(UInt32(FCapacity) div 4) then
    ChangeSize(FCount);
end;

procedure TVector.DeleteRange(I, ACount: Integer);
var
  Offset: Integer;
begin
  if ACount > 0 then begin
    {$IFDEF CHECK_VECTORS}
    if (I < 0) or (I + ACount > FCount) then ErrorFmt(SRangeError_d, [I]);
    {$ENDIF}
    Offset:=I * FElemSize;
    Dec(FCount, ACount);
    Move(FItems^.Int8Array[Offset + ACount * FElemSize], FItems^.Int8Array[Offset],
      (FCount - I) * FElemSize);
    ChangeSize(FCount);
  end;
end;

procedure TVector.Clear;
begin
  SetCount(0);
end;

function TVector.SizeInBytes: Integer;
begin
  Result:=SizeOf(FCount) + SizeOf(FElemSize) + SizeOf(FItems) +
    FCount * FElemSize;
end;

procedure TVector.Pack;
begin
  Capacity:=FCount;
end;

procedure TVector.EnsureRoom(N: Integer);
begin
  Inc(N, FCount);
  if Capacity < N then
    Capacity:=N;
end;

procedure TVector.Grow(Delta: Integer);
begin
  Count:=Count + Delta;
end;

{ TSortableVector }

procedure TSortableVector.SortRange(L, R: Integer);
var
  MedianValue: Pointer;

  procedure DoSortRange(L, R: Integer);
  var
    I, J: Integer;
  begin
    repeat
      I:=L;
      J:=R;
      GetUntyped((L + R) shr 1, MedianValue^);
      repeat
        while Compare(I, MedianValue^) < 0 do
          Inc(I);
        while Compare(J, MedianValue^) > 0 do
          Dec(J);
        if I <= J then begin
          Exchange(I, J);
          Inc(I);
          Dec(J);
        end;
      until I > J;
      if L < J then
        DoSortRange(L, J);
      L:=I;
    until I >= R;
  end;

begin
  {$IFDEF CHECK_VECTORS}
  if L < 0 then ErrorFmt(SRangeError_d, [L]);
  if R >= Count then ErrorFmt(SRangeError_d, [R]);
  {$ENDIF}
  if L < R then begin
    GetMem(MedianValue, ElemSize);
    try
      DoSortRange(L, R);
    finally
      FreeMem(MedianValue{$IFNDEF V_32}, ElemSize{$ENDIF});
    end;
  end;
end;

procedure TSortableVector.SortRangeDesc(L, R: Integer);
var
  MedianValue: Pointer;

  procedure DoSortRangeDesc(L, R: Integer);
  var
    I, J: Integer;
  begin
    repeat
      I:=L;
      J:=R;
      GetUntyped((L + R) shr 1, MedianValue^);
      repeat
        while Compare(I, MedianValue^) > 0 do
          Inc(I);
        while Compare(J, MedianValue^) < 0 do
          Dec(J);
        if I <= J then begin
          Exchange(I, J);
          Inc(I);
          Dec(J);
        end;
      until I > J;
      if L < J then
        DoSortRangeDesc(L, J);
      L:=I;
    until I >= R;
  end;

begin
  {$IFDEF CHECK_VECTORS}
  if L < 0 then ErrorFmt(SRangeError_d, [L]);
  if R >= Count then ErrorFmt(SRangeError_d, [R]);
  {$ENDIF}
  if L < R then begin
    GetMem(MedianValue, ElemSize);
    try
      DoSortRangeDesc(L, R);
    finally
      FreeMem(MedianValue{$IFNDEF V_32}, ElemSize{$ENDIF});
    end;
  end;
end;

procedure TSortableVector.Sort;
begin
  SortRange(0, Count - 1);
end;

procedure TSortableVector.SortDesc;
begin
  SortRangeDesc(0, Count - 1);
end;

procedure TSortableVector.SortRangeWithEx(L, R: Integer; AVector: TSortableVector;
  Ascending: Boolean);
var
  MedianValue: Pointer;

  procedure DoSortRangeWith(L, R: Integer);
  var
    I, J: Integer;
  begin
    repeat
      I:=L;
      J:=R;
      GetUntyped((L + R) shr 1, MedianValue^);
      repeat
        if Ascending then begin
          while Compare(I, MedianValue^) < 0 do
            Inc(I);
          while Compare(J, MedianValue^) > 0 do
            Dec(J);
        end
        else begin
          while Compare(I, MedianValue^) > 0 do
            Inc(I);
          while Compare(J, MedianValue^) < 0 do
            Dec(J);
        end;
        if I <= J then begin
          Exchange(I, J);
          AVector.Exchange(I, J); { сохраняем соответствие с AVector }
          Inc(I);
          Dec(J);
        end;
      until I > J;
      if L < J then
        DoSortRangeWith(L, J);
      L:=I;
    until I >= R;
  end;

begin
  if L < R then begin
    GetMem(MedianValue, ElemSize);
    try
      DoSortRangeWith(L, R);
    finally
      FreeMem(MedianValue{$IFNDEF V_32}, ElemSize{$ENDIF});
    end;
  end;
end;

procedure TSortableVector.SortRangeWith(L, R: Integer; AVector: TSortableVector);
begin
  {$IFDEF CHECK_VECTORS}
  if L < 0 then ErrorFmt(SRangeError_d, [L]);
  if R >= Count then ErrorFmt(SRangeError_d, [R]);
  {$ENDIF}
  SortRangeWithEx(L, R, AVector, True);
end;

procedure TSortableVector.SortRangeDescWith(L, R: Integer; AVector: TSortableVector);
begin
  {$IFDEF CHECK_VECTORS}
  if L < 0 then ErrorFmt(SRangeError_d, [L]);
  if R >= Count then ErrorFmt(SRangeError_d, [R]);
  {$ENDIF}
  SortRangeWithEx(L, R, AVector, False);
end;

procedure TSortableVector.SortWith(AVector: TSortableVector);
begin
  SortRangeWith(0, Count - 1, AVector);
end;

procedure TSortableVector.SortDescWith(AVector: TSortableVector);
begin
  SortRangeDescWith(0, Count - 1, AVector);
end;

procedure TSortableVector.SortWithArrayEx(VectorArray: array of TSortableVector;
  Ascending: Boolean);
var
  N: Integer;
  MedianValue: Pointer;

  procedure SpecialSortRange(L, R: Integer);
  var
    I, J, K: Integer;
  begin
    repeat
      I:=L;
      J:=R;
      GetUntyped((L + R) shr 1, MedianValue^);
      repeat
        if Ascending then begin
          while Compare(I, MedianValue^) < 0 do
            Inc(I);
          while Compare(J, MedianValue^) > 0 do
            Dec(J);
        end
        else begin
          while Compare(I, MedianValue^) > 0 do
            Inc(I);
          while Compare(J, MedianValue^) < 0 do
            Dec(J);
        end;
        if I <= J then begin
          Exchange(I, J);
          { сохраняем соответствие с Vectors }
          for K:=0 to High(VectorArray) do
            VectorArray[K].Exchange(I, J);
          Inc(I);
          Dec(J);
        end;
      until I > J;
      if L < J then
        SpecialSortRange(L, J);
      L:=I;
    until I >= R;
  end;

begin
  N:=Count - 1;
  if N > 0 then begin
    GetMem(MedianValue, ElemSize);
    try
      SpecialSortRange(0, N);
    finally
      FreeMem(MedianValue{$IFNDEF V_32}, ElemSize{$ENDIF});
    end;
  end;
end;

procedure TSortableVector.SortWithArray(VectorArray: array of TSortableVector);
begin
  SortWithArrayEx(VectorArray, True);
end;

procedure TSortableVector.SortDescWithArray(VectorArray: array of TSortableVector);
begin
  SortWithArrayEx(VectorArray, False);
end;

procedure TSortableVector.GroupSortEx(VectorArray: array of TSortableVector;
  SortDirectionsArray: array of Boolean; Ascending: Boolean);
var
  MedianValue: Pointer;
  MedianValues: PPointerArray;

  procedure SpecialSortRange(L, R: Integer);
  var
    Median: Integer;

    function Cmp(I: Integer): Int32;
    var
      K: Integer;
      V: TSortableVector;
    begin
      Result:=Compare(I, MedianValue^);
      if Result = 0 then
        for K:=0 to High(VectorArray) do begin
          V:=VectorArray[K];
          Result:=V.Compare(I, MedianValues^[K]^);
          if Result <> 0 then begin
            if (K <= High(SortDirectionsArray)) and
              (Ascending <> SortDirectionsArray[K])
            then
              Result:=-Result;
            Break;
          end;
        end;
    end;

  var
    I, J, K: Integer;
  begin
    repeat
      I:=L;
      J:=R;
      Median:=(L + R) shr 1;
      GetUntyped(Median, MedianValue^);
      for K:=0 to High(VectorArray) do
        VectorArray[K].GetUntyped(Median, MedianValues^[K]^);
      repeat
        if Ascending then begin
          while Cmp(I) < 0 do Inc(I);
          while Cmp(J) > 0 do Dec(J);
        end
        else begin
          while Cmp(I) > 0 do Inc(I);
          while Cmp(J) < 0 do Dec(J);
        end;
        if I <= J then begin
          Exchange(I, J);
          { сохраняем соответствие с Vectors }
          for K:=0 to High(VectorArray) do
            VectorArray[K].Exchange(I, J);
          Inc(I);
          Dec(J);
        end;
      until I > J;
      if L < J then
        SpecialSortRange(L, J);
      L:=I;
    until I >= R;
  end;

var
  K, N: Integer;
begin
  N:=Count - 1;
  if N > 0 then begin
    MedianValues:=AllocMem((High(VectorArray) + 1) * SizeOf(Pointer));
    MedianValue:=nil;
    try
      GetMem(MedianValue, ElemSize);
      for K:=0 to High(VectorArray) do
        GetMem(MedianValues^[K], VectorArray[K].ElemSize);
      SpecialSortRange(0, N);
    finally
      for K:=0 to High(VectorArray) do
        FreeMem(MedianValues^[K]{$IFNDEF V_32}, VectorArray[K].ElemSize{$ENDIF});
      FreeMem(MedianValues{$IFNDEF V_32}, (High(VectorArray) + 1) * SizeOf(Pointer){$ENDIF});
      FreeMem(MedianValue{$IFNDEF V_32}, ElemSize{$ENDIF});
    end;
  end;
end;

procedure TSortableVector.GroupSort(VectorArray: array of TSortableVector;
  Ascending: Boolean);
begin
  GroupSortEx(VectorArray, [{$IFDEF V_DELPHI}{$IFNDEF V_D4}Ascending{$ENDIF}{$ENDIF}],
    Ascending);
end;

procedure TSortableVector.Reverse;
var
  I, N: Integer;
begin
  N:=Count;
  for I:=0 to N shr 1 - 1 do begin
    Dec(N);
    Exchange(I, N);
  end;
end;

end.
