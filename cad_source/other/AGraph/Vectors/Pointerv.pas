{ Version 050602. Copyright © Alexey A.Chernobaev, 1996-2005 }

unit Pointerv;

interface

{$I VCheck.inc}

uses
  ExtType, Vectors, Base32v, Int32g,
  {$IFDEF USE_STREAM64}VStrm64{$ELSE}VStream{$ENDIF}, VectErr;

type
  TCompareFunc = function (Item1, Item2: Pointer): Integer;
  { используется в методах SortBy/ConservativeSortBy }
  { used in the SortBy/ConservativeSortBy methods }

  TCompareEvent = function (Item1, Item2: Pointer): Integer of object;
  { используется в методах SortByObject/ConservativeSortByObject }
  { used in the SortByObject/ConservativeSortByObject methods }

  TPointerVector = class(TBase32Vector)
  protected
    procedure InitMemory(Offset, InitCount: Integer); override;
    function GetValue(I: Integer): Pointer; {$IFDEF V_INLINE}inline;{$ENDIF}
    procedure SetValue(I: Integer; Value: Pointer); {$IFDEF V_INLINE}inline;{$ENDIF}
    function GetLast: Pointer;
    procedure SetLast(Value: Pointer);
  public
    constructor Create;
    function CreateCompatibleVector: TPointerVector; virtual;
    { создает пустой вектор того же класса }
    { creates the empty vector of the same class }
    procedure WriteToStream(VStream: TVStream); override;
    procedure ReadFromStream(VStream: TVStream); override;
    procedure Assign(Source: TVector); override;
    procedure Exchange(I, J: Integer); override;
    procedure GetUntyped(I: Integer; var Result); override;
    procedure SetUntyped(I: Integer; const Value); virtual;
    function Compare(I: Integer; const V): Int32; override;
    procedure SetToDefault; virtual;
    { устанавливает все элементы в nil }
    { sets all elements to nil }
    procedure SortBy(CompareFunc: TCompareFunc);
    { сортирует вектор по возрастанию в соответствии с функцией CompareFunc }
    { sorts the vector ascending according to CompareFunc }
    procedure SortByWith(CompareFunc: TCompareFunc; AVector: TSortableVector);
    { сортирует вектор по возрастанию в соответствии с функцией CompareFunc,
      сохраняя соответствие между элементами данного вектора и вектора AVector;
      AVector должен иметь размер, не меньший, чем размер данного вектора }
    { sorts the vector ascending according to CompareFunc keeping correspondence
      between elements of the current vector and vector AVector; size of AVector
      must not be less then the size of the current vector }
    procedure SortByObject(CompareEvent: TCompareEvent);
    { сортирует вектор по возрастанию в соответствии с CompareEvent }
    { sorts the vector ascending according to CompareEvent }
    procedure SortByObjectWith(CompareEvent: TCompareEvent; AVector: TSortableVector);
    { сортирует вектор по возрастанию в соответствии с CompareEvent,
      сохраняя соответствие между элементами данного вектора и вектора AVector;
      AVector должен иметь размер, не меньший, чем размер данного вектора }
    { sorts the vector ascending according to CompareEvent keeping correspondence
      between elements of the current vector and vector AVector; size of AVector
      must not be less then the size of the current vector }
    procedure ConservativeSortBy(CompareFunc: TCompareFunc);
    { сортирует вектор по возрастанию в соответствии с функцией CompareFunc,
      используя метод, сохраняющий относительный порядок одинаковых элементов;
      как правило, выполняется медленне, чем SortBy }
    { sorts the vector ascending according to CompareFunc using the method that
      keeps the relative order of the equal elements; as a rule it executes slower
      then SortBy }
    procedure ConservativeSortByObject(CompareEvent: TCompareEvent);
    { сортирует вектор по возрастанию в соответствии с CompareEvent, используя
      метод, сохраняющий относительный порядок одинаковых элементов; как правило,
      выполняется медленне, чем SortBy }
    { sorts the vector ascending according to CompareEvent using the method that
      keeps the relative order of the equal elements; as a rule it executes slower
      then SortBy }
    procedure Insert(I: Integer; Value: Pointer);
    { вставляет значение в позицию I }
    { inserts the value in the position I }
    function Add(Value: Pointer): Integer;
    { добавляет значение в конец вектора и возвращает его индекс (Count - 1) }
    { appends Value to the end of the vector and returns it's index (Count - 1) }
    procedure Move(CurIndex, NewIndex: Integer); virtual;
    { изменяет позицию элемента CurIndex на NewIndex }
    { moves the element from the position CurIndex to NewIndex }
    function IndexFrom(I: Integer; Value: Pointer): Integer;
    { возвращает индекс первого, начиная с I, вхождения значения Value в вектор,
      либо -1, если такого вхождения не существует }
    { returns the index of the first occurrence of Value in the vector beginning
      from I or -1 if there's no such occurrence }
    function IndexOf(Value: Pointer): Integer;
    { IndexOf(Value) = IndexFrom(0, Value) }
    function LastIndexFrom(I: Integer; Value: Pointer): Integer;
    { возвращает индекс последнего вхождения значения Value в вектор, который
      не превышает I, либо -1, если нет таких вхождений }
    { returns the index of the last occurrence of Value in the vector which is
      not greater then I or -1 if there are no such occurrences }
    function LastIndexOf(Value: Pointer): Integer;
    { LastIndexOf(Value) = LastIndexFrom(Count - 1, Value) }
    function Remove(Value: Pointer): Integer;
    { находит первое вхождение Value в вектор и удаляет его вызовом Delete,
      возвращая индекс удаленного значения, либо -1, если Value не найдено }
    { searches for the first occurrence of Value in the vector, deletes it with
      Delete and returns the index of the deleted value or -1 if Value wasn't
      found }
    function RemoveLast(Value: Pointer): Integer;
    { находит последнее вхождение Value в вектор, удаляет его вызовом Delete и
      возвращает индекс удаленного значения, либо -1, если Value не найдено }
    { searches for the last occurrence of Value in the vector, deletes it with
      Delete and returns the index of the deleted value or -1 if Value wasn't
      found }
    function RemoveFrom(I: Integer; Value: Pointer): Integer;
    { находит первое, начиная с I, вхождение Value в вектор и удаляет его вызовом
      Delete, возвращая индекс удаленного значения, либо -1, если Value не найдено }
    function RemoveLastFrom(I: Integer; Value: Pointer): Integer;
    { находит последнее, но не больше I, вхождение Value в вектор и удаляет его
      вызовом Delete, возвращая индекс удаленного значения, либо -1, если Value
      не найдено }
    { searches for the last occurrence of Value in the vector which is not
      greater then I, deletes it with Delete and returns the index of the
      deleted value or -1 if Value wasn't found }
    function NumberOfValues(Value: Pointer): Integer;
    { возвращает количество элементов, равных Value }
    { returns the number of elements equal to Value }
    function FindInSortedRange(Value: Pointer; L, H: Integer): Integer;
    { находит дихотомически значение Value в упорядоченном по возрастанию
      векторе, начиная с индекса L и кончая H; возвращает минимальный индекс
      найденного значения, либо -1, если значение не найдено }
    { searches for the Value in the sorted (ascending) vector dichotomically
      from the index L to H; returns the minimal index of Value or -1 if Value
      wasn't found }
    function FindInSorted(Value: Pointer): Integer;
    { находит дихотомически значение Value в упорядоченном по возрастанию векторе;
      возвращает минимальный индекс найденного значения, либо -1, если значение
      не найдено }
    { searches for the Value in the sorted (ascending) vector dichotomically;
      returns the minimal index of Value or -1 if Value wasn't found }
    function Pop: Pointer;
    { возвращает последний элемент списка (который не должен быть пустым)
      и удаляет его (т.е. уменьшает длину списка на единицу) }
    { returns the last element of the list (which must be non-empty) and removes
      it (i.e. decreases the length of the list by one) }
    procedure ConcatenateWith(V: TPointerVector); virtual;
    { добавляет значения вектора V в конец данного вектора }
    { appends values from the vector V to the end of the current vector }
    procedure GetSpectrum(SpectrumValue: TPointerVector;
      SpectrumCount: TGenericInt32Vector);
    { вычисляет спектр списка: после завершения работы данного метода список
      SpectrumValue содержит все различные элементы данного списка (порядок
      элементов SpectrumValue не определен), а SpectrumCount[I] = <количество
      элементов, равных SpectrumValue[I] в исходном списке>;
      примечания:
      1) эквивалентность элементов устанавливается методом Compare;
      2) в качестве SpectrumValue может использоваться Self;
      3) SpectrumCount может быть равен nil. }
    { calculates the spectrum of the list: after completing this method the list
      SpectrumValue contains all different elements of the current list (in some
      indefinite order) and SpectrumCount[I] = <number of elements equal to
      SpectrumValue[I] in the original list>;
      comments:
      1) equality of elements is defined by the Compare method;
      2) it's possible to pass Self as SpectrumValue;
      3) SpectrumCount can be equal to nil. }
    procedure FreeItems; virtual;
    { освобождает все элементы, интерпретируя их как TObject }
    { frees all items interpreting them as TObject-s }
    property Last: Pointer read GetLast write SetLast;
    { возвращает или устанавливает последний элемент списка (список не должен
      быть пустым) }
    { gets or sets the last element of the list (the list must not be empty) }
    property Items[I: Integer]: Pointer read GetValue write SetValue; default;
    { элементы списка }
    { elements of the list }
  end;

  TClassList = TPointerVector;

  TAutoFreeClassList = class(TClassList)
    function CreateCompatibleVector: TPointerVector; override;
    destructor Destroy; override;
    { автоматически освобождает свои элементы с помощью FreeItems }
    { automatically frees it's own elements with FreeItems }
  end;

  TPointerVectorClass = class of TPointerVector;
  TClassListClass = TPointerVectorClass;

  TAutoFreeClassListClass = class of TAutoFreeClassList;

implementation

{ TPointerVector }

constructor TPointerVector.Create;
begin
  inherited Create(SizeOf(Pointer));
end;

function TPointerVector.CreateCompatibleVector: TPointerVector;
begin
  Result:=TPointerVector.Create;
end;

procedure TPointerVector.InitMemory(Offset, InitCount: Integer);
var
  P: Pointer;
begin
  P:=nil;
  FillMem(Offset, InitCount, TBase32(P));
end;

function TPointerVector.GetValue(I: Integer): Pointer;
begin
  {$IFDEF CHECK_VECTORS}
  if (I < 0) or (I >= Count) then ErrorFmt(SRangeError_d, [I]);
  {$ENDIF}
  Result:=PPointerArray(FItems)^[I];
end;

procedure TPointerVector.SetValue(I: Integer; Value: Pointer);
begin
  {$IFDEF CHECK_VECTORS}
  if (I < 0) or (I >= Count) then ErrorFmt(SRangeError_d, [I]);
  {$ENDIF}
  PPointerArray(FItems)^[I]:=Value;
end;

function TPointerVector.GetLast: Pointer;
begin
  Result:=GetValue(FCount - 1);
end;

procedure TPointerVector.SetLast(Value: Pointer);
begin
  SetValue(FCount - 1, Value);
end;

function TPointerVector.Add(Value: Pointer): Integer;
begin
  Result:=FCount;
  Insert(Result, Value);
end;

procedure TPointerVector.Move(CurIndex, NewIndex: Integer);
var
  T: Pointer;
begin
  if CurIndex <> NewIndex then begin
    {$IFDEF CHECK_VECTORS}
    if (NewIndex < 0) or (NewIndex >= Count) then
      ErrorFmt(SRangeError_d, [NewIndex]);
    {$ENDIF}
    T:=GetValue(CurIndex);
    Delete(CurIndex);
    Insert(NewIndex, T);
  end;
end;

function TPointerVector.Remove(Value: Pointer): Integer;
begin
  Result:=IndexOf(Value);
  if Result >= 0 then
    Delete(Result);
end;

function TPointerVector.RemoveLast(Value: Pointer): Integer;
begin
  Result:=LastIndexOf(Value);
  if Result >= 0 then
    Delete(Result);
end;

function TPointerVector.RemoveFrom(I: Integer; Value: Pointer): Integer;
begin
  Result:=IndexFrom(I, Value);
  if Result >= 0 then
    Delete(Result);
end;

function TPointerVector.RemoveLastFrom(I: Integer; Value: Pointer): Integer;
begin
  Result:=LastIndexFrom(I, Value);
  if Result >= 0 then
    Delete(Result);
end;

procedure TPointerVector.WriteToStream(VStream: TVStream);
begin
  Error(SMethodNotApplicable);
end;

procedure TPointerVector.ReadFromStream(VStream: TVStream);
begin
  Error(SMethodNotApplicable);
end;

procedure TPointerVector.Assign(Source: TVector);
begin
  if not (Source is TPointerVector) then
    Error(SAssignError);
  inherited Assign(Source);
end;

procedure TPointerVector.Exchange(I, J: Integer);
var
  T: Pointer;
begin
  {$IFDEF CHECK_VECTORS}
  if (I < 0) or (I >= Count) then
    ErrorFmt(SRangeError_d, [I])
  else if (J < 0) or (J >= Count) then
    ErrorFmt(SRangeError_d, [J]);
  {$ENDIF}
  T:=PPointerArray(FItems)^[I];
  PPointerArray(FItems)^[I]:=PPointerArray(FItems)^[J];
  PPointerArray(FItems)^[J]:=T;
end;

procedure TPointerVector.GetUntyped(I: Integer; var Result);
begin
  Pointer(Result):=PPointerArray(FItems)^[I];
end;

procedure TPointerVector.SetUntyped(I: Integer; const Value);
begin
  PPointerArray(FItems)^[I]:=Pointer(Value);
end;

function TPointerVector.Compare(I: Integer; const V): Int32;
var
  T: Int32;
begin
  T:=Int32(PPointerArray(FItems)^[I]);
  if T < Int32(Pointer(V)) then
    Result:=-1
  else
    if T > Int32(Pointer(V)) then
      Result:=1
    else
      Result:=0;
end;

procedure TPointerVector.SetToDefault;
begin
  InitMemory(0, FCount);
end;

type
  TCompareHelper = class
    FCompareFunc: TCompareFunc;
    constructor Create(ACompareFunc: TCompareFunc);
    function Compare(Item1, Item2: Pointer): Integer;
  end;

constructor TCompareHelper.Create(ACompareFunc: TCompareFunc);
begin
  inherited Create;
  FCompareFunc:=ACompareFunc;
end;

function TCompareHelper.Compare(Item1, Item2: Pointer): Integer;
begin
  Result:=FCompareFunc(Item1, Item2);
end;

procedure TPointerVector.SortBy(CompareFunc: TCompareFunc);
begin
  SortByWith(CompareFunc, nil);
end;

procedure TPointerVector.SortByWith(CompareFunc: TCompareFunc; AVector: TSortableVector);
var
  CompareHelper: TCompareHelper;
begin
  CompareHelper:=TCompareHelper.Create(CompareFunc);
  try
    SortByObjectWith(CompareHelper.Compare, AVector);
  finally
    CompareHelper.Free;
  end;
end;

procedure TPointerVector.SortByObject(CompareEvent: TCompareEvent);
begin
  SortByObjectWith(CompareEvent, nil);
end;

procedure TPointerVector.SortByObjectWith(CompareEvent: TCompareEvent; AVector: TSortableVector);

  procedure DoSortRangeByObject(L, R: Integer);
  var
    I, J: Integer;
    T: Pointer;
  begin
    repeat
      I:=L;
      J:=R;
      T:=PPointerArray(FItems)^[(L + R) div 2];
      repeat
        while CompareEvent(PPointerArray(FItems)^[I], T) < 0 do Inc(I);
        while CompareEvent(PPointerArray(FItems)^[J], T) > 0 do Dec(J);
        if I <= J then begin
          Exchange(I, J);
          { сохраняем соответствие с AVector }
          if AVector <> nil then
            AVector.Exchange(I, J);
          Inc(I);
          Dec(J);
        end;
      until I > J;
      if L < J then
        DoSortRangeByObject(L, J);
      L:=I;
    until I >= R;
  end;

begin
  if FCount > 1 then
    DoSortRangeByObject(0, FCount - 1);
end;

procedure TPointerVector.ConservativeSortBy(CompareFunc: TCompareFunc);
var
  CompareHelper: TCompareHelper;
begin
  CompareHelper:=TCompareHelper.Create(CompareFunc);
  try
    ConservativeSortByObject(CompareHelper.Compare);
  finally
    CompareHelper.Free;
  end;
end;

{$IFDEF NOWARN}{$WARNINGS OFF}{$ENDIF}
procedure TPointerVector.ConservativeSortByObject(CompareEvent: TCompareEvent);
{ используется сортировка слиянием, т.к. она сохраняет взаимный порядок
  одинаковых в соответствии с CompareEvent элементов }
var
  Temp: TPointerVector;
  I, J, K1, K2, Limit1, Limit2, N1, N2: Integer;
  T, T1, T2: Pointer;
  K1F, K2F: Boolean;
  P, Arr1, Arr2: PRegular;
begin
  if FCount > 1 then begin
    Temp:=TPointerVector.Create;
    Temp.Assign(Self);
    N1:=1;
    Arr1:=Temp.FItems;
    Arr2:=FItems;
    try
      while N1 < FCount do begin
        P:=Arr1;
        Arr1:=Arr2;
        Arr2:=P;
        N2:=N1 * 2;
        I:=0;
        while I < FCount do begin
          K1:=I;
          K2:=I + N1;
          Limit1:=I + N1;
          if Limit1 > FCount then
            Limit1:=FCount;
          Limit2:=I + N2;
          if Limit2 > FCount then
            Limit2:=FCount;
          K1F:=True;
          K2F:=K2 < Limit2;
          T1:=Arr1^.PointerArray[K1];
          if K2F then
            T2:=Arr1^.PointerArray[K2];
          J:=I;
          repeat
            if K1F and (not K2F or (CompareEvent(T1, T2) <= 0)) then begin
              T:=T1;
              Inc(K1);
              K1F:=K1 < Limit1;
              if K1F then
                T1:=Arr1^.PointerArray[K1];
            end
            else begin
              T:=T2;
              Inc(K2);
              K2F:=K2 < Limit2;
              if K2F then
                T2:=Arr1^.PointerArray[K2];
            end;
            Arr2^.PointerArray[J]:=T;
            Inc(J);
          until not (K1F or K2F);
          Inc(I, N2);
        end;
        N1:=N2;
      end;
    finally
      FItems:=Arr2;
      Temp.FItems:=Arr1;
      Temp.Free;
    end;
  end;
end;
{$IFDEF NOWARN}{$WARNINGS ON}{$ENDIF}

procedure TPointerVector.Insert(I: Integer; Value: Pointer);
begin
  Expand(I);
  PPointerArray(FItems)^[I]:=Value;
end;

function TPointerVector.IndexFrom(I: Integer; Value: Pointer): Integer;
begin
  Result:=IndexOfBaseValue(I, TBase(Value));
end;

function TPointerVector.IndexOf(Value: Pointer): Integer;
begin
  Result:=IndexFrom(0, Value);
end;

function TPointerVector.LastIndexFrom(I: Integer; Value: Pointer): Integer;
begin
  Result:=LastIndexOfBaseValue(I, TBase(Value));
end;

function TPointerVector.LastIndexOf(Value: Pointer): Integer;
begin
  Result:=LastIndexFrom(FCount - 1, Value);
end;

function TPointerVector.NumberOfValues(Value: Pointer): Integer;
begin
  Result:=CountValuesEqualTo(TBase(Value));
end;

function TPointerVector.FindInSortedRange(Value: Pointer; L, H: Integer): Integer;
{$I FindSrtd.inc}

function TPointerVector.FindInSorted(Value: Pointer): Integer;
begin
  Result:=FindInSortedRange(Value, 0, FCount - 1);
end;

function TPointerVector.Pop: Pointer;
var
  N: Integer;
begin
  N:=FCount - 1;
  Result:=GetValue(N);
  Count:=N;
end;

procedure TPointerVector.ConcatenateWith(V: TPointerVector);
var
  I, OldCount, VCount: Integer;
begin
  OldCount:=Count;
  VCount:=V.Count;
  Count:=OldCount + VCount;
  for I:=0 to VCount - 1 do begin
    PPointerArray(FItems)^[OldCount]:=PPointerArray(V.FItems)^[I];
    Inc(OldCount);
  end;
end;

procedure TPointerVector.GetSpectrum(SpectrumValue: TPointerVector;
  SpectrumCount: TGenericInt32Vector);
var
  I, LastIndex: Integer;
  T: TPointerVector;
  LastValue: Pointer;
begin
  if SpectrumCount <> nil then
    SpectrumCount.Clear;
  if Count > 0 then begin
    GetMem(LastValue, ElemSize);
    T:=nil;
    try
      T:=CreateCompatibleVector;
      T.Assign(Self);
      SpectrumValue.Clear; { в качестве SpectrumValue может использоваться Self }
      T.Sort;
      T.GetUntyped(0, LastValue^);
      SpectrumValue.Count:=1;
      SpectrumValue.SetUntyped(0, LastValue^);
      LastIndex:=0;
      if SpectrumCount <> nil then
        SpectrumCount.Add(1);
      for I:=1 to T.Count - 1 do
        if T.Compare(I, LastValue^) <> 0 then begin
          T.GetUntyped(I, LastValue^);
          Inc(LastIndex);
          SpectrumValue.Count:=LastIndex + 1;
          SpectrumValue.SetUntyped(LastIndex, LastValue^);
          if SpectrumCount <> nil then
            SpectrumCount.Add(1);
        end
        else
          if SpectrumCount <> nil then
            SpectrumCount.IncItem(LastIndex, 1);
    finally
      FreeMem(LastValue, ElemSize);
      T.Free;
    end;
  end
  else
    SpectrumValue.Clear;
end;

procedure TPointerVector.FreeItems;
var
  I: Integer;
begin
  if Self <> nil then
    for I:=0 to FCount - 1 do
      PObjectArray(FItems)^[I].Free;
end;

{ TAutoFreeClassList }

function TAutoFreeClassList.CreateCompatibleVector: TPointerVector;
begin
  Result:=TAutoFreeClassList.Create;
end;

destructor TAutoFreeClassList.Destroy;
begin
  FreeItems;
  inherited Destroy;
end;

end.
