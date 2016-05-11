{ Version 050603. Copyright © Alexey A.Chernobaev, 1996-2005 }

unit Boolv;
{
  Логические векторы.

  Boolean vectors.
}

interface

{$I VCheck.inc}

uses
  SysUtils, ExtType, ExtSys, VectProc, Vectors, VFormat,
  {$IFDEF USE_STREAM64}VStrm64{$ELSE}VStream{$ENDIF}, VTxtStrm, VectErr;

type
  TBoolVector = class(TSortableVector)
  protected
    FDefaultValue: Bool;
    function GetValue(I: Integer): Bool; virtual;
    procedure SetValue(I: Integer; Value: Bool); virtual;
    {$IFDEF V_INLINE}
    function GetValueI(I: Integer): Bool; inline;
    procedure SetValueI(I: Integer; Value: Bool); inline;
    {$ENDIF}
    procedure InitMemory(Offset, InitCount: Integer); override;
  public
    constructor Create(ElemCount: Integer; ADefaultValue: Bool);
    procedure WriteToStream(VStream: TVStream); override;
    { записывает вектор в поток }
    { writes the vector to the stream }
    procedure ReadFromStream(VStream: TVStream); override;
    { читает вектор из потока }
    { reads the vector from the stream }
    procedure WriteToTextStream(TextStream: TTextStream);
    { записывает вектор в текстовый поток }
    { writes the vector to the text stream }
    procedure ReadFromTextStream(TextStream: TTextStream);
    { читает вектор из текстового потока }
    { reads the vector from the text stream }
    procedure Assign(Source: TVector); override;
    { совместимые типы: TPackedBoolVector, TBoolVector и их потомки }
    { compatible types: TPackedBoolVector, TBoolVector and their descendants }
    function EqualTo(V: TVector): Bool; override;
    function Compare(I: Integer; const V): Int32; override;
    procedure Exchange(I, J: Integer); override;
    procedure GetUntyped(I: Integer; var Result); override;
    procedure SetToDefault;
    { устанавливает все элементы в DefaultValue }
    { set all elements to DefaultValue }
    function IndexOf(Value: Bool): Integer;
    { возвращает индекс первого вхождения Value в вектор либо -1 }
    { returns the index of the first occurrence of Value in the vector or -1 }
    procedure Insert(I: Integer; Value: Bool); virtual;
    { вставляет значение в позицию I }
    { inserts the value at position I }
    function Add(Value: Bool): Integer;
    { добавляет значение в конец вектора и возвращает его индекс (Count - 1) }
    { adds value to the end of the vector and returns it's index (Count - 1) }
    procedure SetItems(Values: array of Bool);
    { устанавливает значения элементов вектора в Values (Count:=High(Values) + 1) }
    { sets vector elements to Values (Count:=High(Values) + 1) }
    procedure FillValue(Value: Bool); virtual;
    { присвоить всем элементам значение Value }
    { sets all vector elements to Value }
    procedure FillRandom(ANumTrue: Integer);
    { заполнить вектор случайным образом так, чтобы количество True-элементов
      в нем стало равно числу ANumTrue (это число должно находиться в диапазоне
      0..Count) }
    { fills the vector randomly to get vector with ANumTrue True-elements (this
      number must be in the range 0..Count) }
    procedure AndVector(T: TBoolVector); virtual;
    { конъюнкция векторов }
    { conjunction of vectors }
    procedure OrVector(T: TBoolVector); virtual;
    { дизъюнкция векторов }
    { disjunction of vectors }
    procedure XorVector(T: TBoolVector); virtual;
    { сложение векторов по модулю два }
    { addition of vectors by modulo two }
    procedure NotVector; virtual;
    { отрицание вектора }
    { negation of the vector }
    procedure AndItem(I: Integer; Value: Bool); virtual;
    { Items[I]:=Items[I] and Value }
    procedure OrItem(I: Integer; Value: Bool); virtual;
    { Items[I]:=Items[I] or Value }
    procedure XorItem(I: Integer; Value: Bool); virtual;
    { Items[I]:=Items[I] xor Value }
    procedure NotItem(I: Integer); virtual;
    { Items[I]:=not Items[I] }
    function Dominates(T: TBoolVector): Bool;
    { проверяет, доминирует ли вектор Self над вектором T (булевский вектор T1
      доминирует над вектором T2, если (T2[I] and not T1[I]) = False для всех I,
      иными словами, для каждой "единицы" вектора T2 на соответствующей позиции
      вектора T1 также находится "единица") }
    { checks whether vector Self dominates vector T (boolean vector T1 dominates
      vector T2 iff (T2[I] and not T1[I]) = False for all I or, in other words,
      for every True value in the vector T2 the corresponding element in the
      vector T1 is also True) }
    function NumTrue: Integer; virtual;
    { возвращает число True-элементов }
    { returns the number of True-elements }
    property Items[I: Integer]: Bool read GetValue write SetValue;
    {$IFNDEF V_INLINE}default;{$ELSE}
    property ItemsI[I: Integer]: Bool read GetValueI write SetValueI; default;
    {$ENDIF}
    property DefaultValue: Bool read FDefaultValue;
    procedure DebugWrite;
    procedure DebugWrite01;
    { отладочная печать; для вывода отладочной информации в графических
      Win32-приложениях необходимо создать консоль с помощью AllocConsole }
    { debug write; to use in Win32 GUI applications it's necessary to create
      console with AllocConsole }
  end;

  TPackedBoolVector = class(TBoolVector)
  { упакованный булевский вектор (каждый элемент занимает один бит) }
  { packed boolean vector (every element takes one bit) }
  protected
    FPackedCount: Integer;
    function GetCount: Integer; override;
    procedure SetCount(ACount: Integer); override;
    function GetValue(I: Integer): Bool; override;
    procedure SetValue(I: Integer; Value: Bool); override;
    procedure InitMemory(Offset, InitCount: Integer); override;
    procedure ClearTail;
    { обнуляет "расширенную" часть последнего байта }
    { clears the "extended" part of the last byte }
  public
    function NewValue(I: Integer; Value: Bool): Bool;
    { присваивает новое значение I-му элементу и возвращает его старое значение }
    { sets the new value to the element I and returns it's old value }
    procedure Assign(Source: TVector); override;
    procedure FillValue(Value: Bool); override;
    procedure Insert(I: Integer; Value: Bool); override;
    { реализовано неэффективно - только для совместимости с TBoolVector }
    { implementation is ineffective - only for compatiblity with TBoolVector }
    procedure Delete(I: Integer); override;
    { реализовано неэффективно - только для совместимости с TBoolVector }
    { implementation is ineffective - only for compatiblity with TBoolVector }
    procedure AndVector(T: TBoolVector); override;
    procedure OrVector(T: TBoolVector); override;
    procedure XorVector(T: TBoolVector); override;
    procedure NotVector; override;
    procedure AndItem(I: Integer; Value: Bool); override;
    procedure OrItem(I: Integer; Value: Bool); override;
    procedure XorItem(I: Integer; Value: Bool); override;
    procedure NotItem(I: Integer); override;
    function NumTrue: Integer; override;
    {$IFDEF V_INLINE}
    property Items[I: Integer]: Bool read GetValue write SetValue; default;
    {$ENDIF}
  end;

  TBooleanVector = TBoolVector;
  TPackedBooleanVector = TPackedBoolVector;

  TBoolVectorClass = class of TBoolVector;
  TPackedBoolVectorClass = class of TPackedBoolVector;

function CreateBoolVector(ElemCount: Integer; ADefaultValue: Bool): TBoolVector;
{ если объем свободной физической памяти достаточен для хранения вектора класса
  TBoolVector с ElemCount элементами, то создает вектор класса TBoolVector,
  иначе создает вектор класса TPackedBoolVector }
{ if the amount of the free physical memory is large enough to store a vector of
  class TBoolVector with ElemCount elements then creates such vector else creates
  a vector of class TPackedBoolVector }

implementation

{ TBoolVector }

constructor TBoolVector.Create(ElemCount: Integer; ADefaultValue: Bool);
begin
  inherited Create(SizeOf(Bool));
  FDefaultValue:=ADefaultValue;
  SetCount(ElemCount);
end;

procedure TBoolVector.InitMemory(Offset, InitCount: Integer);
begin
  FillChar(FItems^.BoolArray[Offset], InitCount, FDefaultValue);
end;

procedure TBoolVector.WriteToStream(VStream: TVStream);
begin
  inherited WriteToStream(VStream);
  VStream.WriteProc(FDefaultValue, SizeOf(FDefaultValue));
end;

procedure TBoolVector.ReadFromStream(VStream: TVStream);
begin
  inherited ReadFromStream(VStream);
  VStream.ReadProc(FDefaultValue, SizeOf(FDefaultValue));
end;

procedure TBoolVector.WriteToTextStream(TextStream: TTextStream);
var
  I: Integer;
  S: String;
begin
  S:='';
  for I:=0 to Count - 1 do begin
    if I > 0 then
      S:=S + ' ';
    S:=S + IntToStr(Ord(Items[I]));
  end;
  TextStream.WriteString(S);
end;

procedure TBoolVector.ReadFromTextStream(TextStream: TTextStream);
var
  I: Integer;
  C, LastChar: Char;
  S, Value: String;
begin
  Clear;
  S:=TextStream.ReadString + ' ';
  LastChar:=' ';
  Value:='';
  for I:=1 to Length(S) do begin
    C:=S[I];
    if C = #9 then
      C:=' ';
    if (C = ' ') and (C <> LastChar) then begin
      Add(StrToBool(Value));
      Value:='';
    end
    else
      Value:=Value + C;
    LastChar:=C;
  end;
end;

procedure TBoolVector.Assign(Source: TVector);
var
  I: Integer;
begin
  if Source is TBoolVector then begin
    if Source is TPackedBoolVector then begin
      Count:=Source.Count;
      for I:=0 to Source.Count - 1 do
        Items[I]:=TPackedBoolVector(Source).Items[I];
    end
    else
      inherited Assign(Source);
    FDefaultValue:=TBoolVector(Source).FDefaultValue;
  end
  else
    Error(SAssignError);
end;

function TBoolVector.Compare(I: Integer; const V): Int32;
begin
  Result:=Ord(Items[I]) - Ord(Bool(V));
end;

procedure TBoolVector.Exchange(I, J: Integer);
var
  B: Bool;
begin
  B:=Items[I];
  Items[I]:=Items[J];
  Items[J]:=B;
end;

procedure TBoolVector.GetUntyped(I: Integer; var Result);
begin
  Bool(Result):=Items[I];
end;

procedure TBoolVector.SetToDefault;
begin
  InitMemory(0, FCount);
end;

function TBoolVector.IndexOf(Value: Bool): Integer;
var
  I: Integer;
begin
  for I:=0 to Count - 1 do
    if Items[I] = Value then begin
      Result:=I;
      Exit;
    end;
  Result:=-1;
end;

procedure TBoolVector.Insert(I: Integer; Value: Bool);
begin
  Expand(I);
  Items[I]:=Value;
end;

function TBoolVector.Add(Value: Bool): Integer;
begin
  Result:=Count;
  Grow(1);
  Items[Result]:=Value;
end;

procedure TBoolVector.SetItems(Values: array of Bool);
var
  I: Integer;
begin
  Count:=High(Values) + 1;
  for I:=0 to High(Values) do
    Items[I]:=Values[I];
end;

procedure TBoolVector.FillValue(Value: Bool);
begin
  FillChar(FItems^.BoolArray[0], FCount, Value);
end;

procedure TBoolVector.FillRandom(ANumTrue: Integer);

  procedure FillRange(L, R, ANumTrue: Integer);
  var
    RangeLength, Offset, Avg, LeftNumTrue: Integer;
  begin
    if (L <= R) and (ANumTrue > 0) then begin
      RangeLength:=R - L + 1;
      Offset:=Random(RangeLength);
      Avg:=L + Offset;
      Items[Avg]:=True;
      Dec(ANumTrue);
      LeftNumTrue:=Round(Offset * ANumTrue / RangeLength);
      FillRange(L, Avg - 1, LeftNumTrue);
      FillRange(Avg + 1, R, ANumTrue - LeftNumTrue);
    end;
  end;

var
  N: Integer;
  Inv: Bool;
begin
  {$IFDEF CHECK_VECTORS}
  if (ANumTrue < 0) or (ANumTrue > Count) then Error(SErrorInParameters);
  {$ENDIF}
  N:=Count;
  if ANumTrue > N div 2 then begin
    ANumTrue:=N - ANumTrue;
    Inv:=True;
  end
  else
    Inv:=False;
  FillValue(False);
  FillRange(0, N - 1, ANumTrue);
  if Inv then
    NotVector;
end;

{$IFDEF NOWARN}{$WARNINGS OFF}{$ENDIF}
function TBoolVector.EqualTo(V: TVector): Bool;
var
  I, N: Integer;
begin
  if V is TBoolVector then
    if ClassType = V.ClassType then begin
      if Self is TPackedBoolVector then begin
        TPackedBoolVector(Self).ClearTail;
        TPackedBoolVector(V).ClearTail;
      end;
      Result:=inherited EqualTo(V);
    end
    else begin
      Result:=False;
      N:=Count;
      if N = V.Count then begin
        for I:=0 to N - 1 do
          if Items[I] <> TBoolVector(V)[I] then
            Exit;
        Result:=True;
      end;
    end
  else
    Error(SIncompatibleClasses);
end;
{$IFDEF NOWARN}{$WARNINGS OFF}{$ENDIF}

function TBoolVector.GetValue(I: Integer): Bool;
begin
  {$IFDEF CHECK_VECTORS}
  if (I < 0) or (I >= Count) then ErrorFmt(SRangeError_d, [I]);
  {$ENDIF}
  Result:=PBoolArray(FItems)^[I];
end;

procedure TBoolVector.SetValue(I: Integer; Value: Bool);
begin
  {$IFDEF CHECK_VECTORS}
  if (I < 0) or (I >= Count) then ErrorFmt(SRangeError_d, [I]);
  {$ENDIF}
  PBoolArray(FItems)^[I]:=Value;
end;

{$IFDEF V_INLINE}
function TBoolVector.GetValueI(I: Integer): Bool;
begin
  {$IFDEF CHECK_VECTORS}
  if (I < 0) or (I >= Count) then ErrorFmt(SRangeError_d, [I]);
  {$ENDIF}
  Result:=PBoolArray(FItems)^[I];
end;

procedure TBoolVector.SetValueI(I: Integer; Value: Bool);
begin
  {$IFDEF CHECK_VECTORS}
  if (I < 0) or (I >= Count) then ErrorFmt(SRangeError_d, [I]);
  {$ENDIF}
  PBoolArray(FItems)^[I]:=Value;
end;
{$ENDIF}

procedure TBoolVector.AndVector(T: TBoolVector);
var
  I: Integer;
begin
  {$IFDEF CHECK_VECTORS}
  if Count <> T.Count then ErrorFmt(SWrongVectorSize_d, [T.Count]);
  {$ENDIF}
  if ClassType = T.ClassType then
    AndBoolProc(FItems^, T.FItems^, FCount)
  else
    for I:=0 to Count - 1 do
      FItems^.BoolArray[I]:=FItems^.BoolArray[I] and T[I];
end;

procedure TBoolVector.OrVector(T: TBoolVector);
var
  I: Integer;
begin
  {$IFDEF CHECK_VECTORS}
  if Count <> T.Count then ErrorFmt(SWrongVectorSize_d, [T.Count]);
  {$ENDIF}
  if ClassType = T.ClassType then
    OrBoolProc(FItems^, T.FItems^, FCount)
  else
    for I:=0 to Count - 1 do
      FItems^.BoolArray[I]:=FItems^.BoolArray[I] or T[I];
end;

procedure TBoolVector.XorVector(T: TBoolVector);
var
  I: Integer;
begin
  {$IFDEF CHECK_VECTORS}
  if Count <> T.Count then ErrorFmt(SWrongVectorSize_d, [T.Count]);
  {$ENDIF}
  if ClassType = T.ClassType then
    XorBoolProc(FItems^, T.FItems^, FCount)
  else
    for I:=0 to Count - 1 do
      FItems^.BoolArray[I]:=FItems^.BoolArray[I] xor T[I];
end;

procedure TBoolVector.NotVector;
begin
  NotBoolProc(FItems^, FItems^, FCount);
end;

procedure TBoolVector.AndItem(I: Integer; Value: Bool);
begin
  {$IFDEF CHECK_VECTORS}
  if (I < 0) or (I >= Count) then ErrorFmt(SRangeError_d, [I]);
  {$ENDIF}
  PBoolArray(FItems)^[I]:=PBoolArray(FItems)^[I] and Value;
end;

procedure TBoolVector.OrItem(I: Integer; Value: Bool);
begin
  {$IFDEF CHECK_VECTORS}
  if (I < 0) or (I >= Count) then ErrorFmt(SRangeError_d, [I]);
  {$ENDIF}
  PBoolArray(FItems)^[I]:=PBoolArray(FItems)^[I] or Value;
end;

procedure TBoolVector.XorItem(I: Integer; Value: Bool);
begin
  {$IFDEF CHECK_VECTORS}
  if (I < 0) or (I >= Count) then ErrorFmt(SRangeError_d, [I]);
  {$ENDIF}
  PBoolArray(FItems)^[I]:=PBoolArray(FItems)^[I] xor Value;
end;

procedure TBoolVector.NotItem(I: Integer);
begin
  {$IFDEF CHECK_VECTORS}
  if (I < 0) or (I >= Count) then ErrorFmt(SRangeError_d, [I]);
  {$ENDIF}
  PBoolArray(FItems)^[I]:=not PBoolArray(FItems)^[I];
end;

function TBoolVector.Dominates(T: TBoolVector): Bool;
var
  I, N, N1, N2: Integer;
  C: TClass;
begin
  N1:=Count;
  N2:=T.Count;
  if N1 < N2 then begin
    for I:=N1 to N2 - 1 do
      if T[I] then begin
        Result:=False;
        Exit;
      end;
    N:=N1;
  end
  else
    N:=N2;
  C:=ClassType;
  if (C = T.ClassType) and (C = TBoolVector) then
    Result:=BoolDominateFunc(FItems^, T.FItems^, N)
  else begin
    for I:=0 to N - 1 do
      if T[I] and not Items[I] then begin
        Result:=False;
        Exit;
      end;
    Result:=True;
  end;
end;

function TBoolVector.NumTrue: Integer;
begin
  Result:=CountEqualToValue8(FItems^, Int8(True), FCount);
end;

procedure TBoolVector.DebugWrite;
var
  I: Integer;
begin
  for I:=0 to Count - 1 do
    write(Items[I], ' ');
  writeln;
end;

procedure TBoolVector.DebugWrite01;
var
  I: Integer;
begin
  for I:=0 to Count - 1 do
    write(Ord(Items[I]), ' ');
  writeln;
end;

{ TPackedBoolVector }

procedure TPackedBoolVector.InitMemory(Offset, InitCount: Integer);
var
  Value: UInt8;
begin
  if FDefaultValue then
    Value:=$FF
  else
    Value:=0;
  FillChar(FItems^.UInt8Array[Offset], InitCount, Value);
end;

procedure TPackedBoolVector.ClearTail;
var
  T: UInt8;
  I: Integer;
begin
  T:=FPackedCount mod 8;
  if T > 0 then begin
    T:=8 - T;
    I:=FCount - 1;
    FItems^.UInt8Array[I]:=UInt8(FItems^.UInt8Array[I] shl T) shr T;
  end;
end;

function TPackedBoolVector.GetCount: Integer;
begin
  Result:=FPackedCount;
end;

procedure TPackedBoolVector.SetCount(ACount: Integer);
var
  T1, T2, SetBits: UInt8;
  I, OldCount: Integer;
begin
  OldCount:=FCount;
  inherited SetCount((ACount + 7) div 8);
  { инициализируем "новые" биты в последнем байте }
  if (ACount > FPackedCount) and (OldCount = FCount) then begin
    I:=FCount - 1;
    T1:=FPackedCount mod 8;
    T2:=8 - T1;
    SetBits:=UInt8(FItems^.UInt8Array[I] shl T2) shr T2;
    if FDefaultValue then
      FItems^.UInt8Array[I]:=UInt8($FF shl T1) or SetBits
    else
      FItems^.UInt8Array[I]:=SetBits;
  end;
  FPackedCount:=ACount;
end;

function TPackedBoolVector.GetValue(I: Integer): Bool;
begin
  {$IFDEF CHECK_VECTORS}
  if (I < 0) or (I >= FPackedCount) then ErrorFmt(SRangeError_d, [I]);
  {$ENDIF}
  Result:=FItems^.UInt8Array[I div 8] and (1 shl (I mod 8)) <> 0;
end;

procedure TPackedBoolVector.SetValue(I: Integer; Value: Bool);
begin
  NewValue(I, Value);
end;

function TPackedBoolVector.NewValue(I: Integer; Value: Bool): Bool;
var
  Mask, T: UInt8;
begin
  {$IFDEF CHECK_VECTORS}
  if (I < 0) or (I >= FPackedCount) then ErrorFmt(SRangeError_d, [I]);
  {$ENDIF}
  Mask:=1 shl (I mod 8);
  I:=I div 8;
  With FItems^ do begin
    T:=UInt8Array[I];
    Result:=T and Mask <> 0;
    if Value then
      UInt8Array[I]:=T or Mask
    else
      UInt8Array[I]:=T and not Mask;
  end;
end;

procedure TPackedBoolVector.Assign(Source: TVector);
var
  I: Integer;
begin
  if Source is TBoolVector then begin
    FDefaultValue:=TBoolVector(Source).FDefaultValue;
    if Source is TPackedBoolVector then begin
      inherited Assign(Source);
      FPackedCount:=TPackedBoolVector(Source).FPackedCount;
    end
    else begin
      Count:=Source.Count;
      for I:=0 to Source.Count - 1 do
        NewValue(I, TBoolVector(Source).Items[I]);
    end;
  end
  else
    Error(SAssignError);
end;

procedure TPackedBoolVector.FillValue(Value: Bool);
var
  AFillValue: UInt8;
begin
  if Value then
    AFillValue:=$FF
  else
    AFillValue:=0;
  FillChar(FItems^.UInt8Array[0], FCount, AFillValue);
end;

procedure TPackedBoolVector.Insert(I: Integer; Value: Bool);
var
  J: Integer;
begin
  Grow(1);
  for J:=Count - 1 downto I + 1 do
    Items[J]:=Items[J - 1];
  Items[I]:=Value;
end;

procedure TPackedBoolVector.Delete(I: Integer);
var
  J: Integer;
begin
  for J:=I to Count - 2 do
    Items[J]:=Items[J + 1];
  Count:=Count - 1;
end;

procedure TPackedBoolVector.AndVector(T: TBoolVector);
var
  I: Integer;
begin
  {$IFDEF CHECK_VECTORS}
  if Count <> T.Count then ErrorFmt(SWrongVectorSize_d, [T.Count]);
  {$ENDIF}
  if T is TPackedBoolVector then
    AndBoolProc(FItems^, T.FItems^, FCount)
  else
    for I:=0 to Count - 1 do
      Items[I]:=Items[I] and T[I];
end;

procedure TPackedBoolVector.OrVector(T: TBoolVector);
var
  I: Integer;
begin
  {$IFDEF CHECK_VECTORS}
  if Count <> T.Count then ErrorFmt(SWrongVectorSize_d, [T.Count]);
  {$ENDIF}
  if T is TPackedBoolVector then
    OrBoolProc(FItems^, T.FItems^, FCount)
  else
    for I:=0 to Count - 1 do
      Items[I]:=Items[I] or T[I];
end;

procedure TPackedBoolVector.XorVector(T: TBoolVector);
var
  I: Integer;
begin
  {$IFDEF CHECK_VECTORS}
  if Count <> T.Count then ErrorFmt(SWrongVectorSize_d, [T.Count]);
  {$ENDIF}
  if T is TPackedBoolVector then
    XorBoolProc(FItems^, T.FItems^, FCount)
  else
    for I:=0 to Count - 1 do
      Items[I]:=Items[I] xor T[I];
end;

procedure TPackedBoolVector.NotVector;
var
  I: Integer;
begin
  for I:=0 to FCount - 1 do
    With FItems^ do UInt8Array[I]:=not UInt8Array[I];
end;

function TPackedBoolVector.NumTrue: Integer;
const
  NumberOfSetBit: array [0..255] of UInt8 = (
    0, 1, 1, 2, 1, 2, 2, 3, 1, 2, 2, 3, 2, 3, 3, 4, 1, 2, 2, 3, 2, 3, 3, 4, 2, 3,
    3, 4, 3, 4, 4, 5, 1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 5, 2, 3, 3, 4,
    3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6, 1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4,
    4, 5, 2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6, 2, 3, 3, 4, 3, 4, 4, 5,
    3, 4, 4, 5, 4, 5, 5, 6, 3, 4, 4, 5, 4, 5, 5, 6, 4, 5, 5, 6, 5, 6, 6, 7, 1, 2,
    2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 5, 2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5,
    4, 5, 5, 6, 2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6, 3, 4, 4, 5, 4, 5,
    5, 6, 4, 5, 5, 6, 5, 6, 6, 7, 2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6,
    3, 4, 4, 5, 4, 5, 5, 6, 4, 5, 5, 6, 5, 6, 6, 7, 3, 4, 4, 5, 4, 5, 5, 6, 4, 5,
    5, 6, 5, 6, 6, 7, 4, 5, 5, 6, 5, 6, 6, 7, 5, 6, 6, 7, 6, 7, 7, 8);
var
  I: Integer;
begin
  ClearTail;
  Result:=0;
  for I:=0 to FCount - 1 do
    Result:=Result + NumberOfSetBit[FItems^.UInt8Array[I]];
end;

procedure TPackedBoolVector.AndItem(I: Integer; Value: Bool);
begin
  NewValue(I, GetValue(I) and Value);
end;

procedure TPackedBoolVector.OrItem(I: Integer; Value: Bool);
begin
  NewValue(I, GetValue(I) or Value);
end;

procedure TPackedBoolVector.XorItem(I: Integer; Value: Bool);
begin
  NewValue(I, GetValue(I) xor Value);
end;

procedure TPackedBoolVector.NotItem(I: Integer);
begin
  NewValue(I, not GetValue(I));
end;

function CreateBoolVector(ElemCount: Integer; ADefaultValue: Bool): TBoolVector;
begin
  if PhysicalMemoryFree > ElemCount then
    Result:=TBoolVector.Create(ElemCount, ADefaultValue)
  else
    Result:=TPackedBoolVector.Create(ElemCount, ADefaultValue);
end;

end.
