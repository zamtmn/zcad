{ Version 040228. Copyright © Alexey A.Chernobaev, 1996-2004 }

unit Indexv;
{
  "Самосортирующийся" вектор 32-битных значений.

  "Self-sorting" vector of 32-bit values.
}

interface

{$I VCheck.inc}

uses
  ExtType, Int32g, VectErr;

type
  TIndexVector = class(TGenericInt32Vector)
  protected
    FNotSorted: Bool;
    procedure SetCount(ACount: Integer); override;
    procedure CheckSorted;
    { сортировка вектора по возрастанию, если это необходимо }
    { sorts the vector ascending if needed }
    function GetValue(I: Integer): Int32; override;
    procedure SetValue(I: Integer; Value: Int32); override;
  public
    function FindValue(Value: Int32; var Index: Integer): Bool;
    { вызывает CheckSorted, после чего ищет значение Value среди элементов
      вектора дихотомически; возвращает True, если значение было найдено; иначе
      False; в первом случае в Index возвращается индекс найденного значения, во
      втором - позиция, в которую надо вставить Value, чтобы вектор остался
      упорядоченным }
    { calls CheckSorted, then searches for the value Value among the elements of
      the vector dichotomously; returns True if the value was found, otherwise
      False; in the first case Index is equal to the index of the found value,
      in the second - to the position in which we can insert Value so as the
      vector remains sorted }
    constructor Create(const ElemCount: Integer);
    function Compare(I: Integer; const V): Int32; override;
    procedure Exchange(I, J: Integer); override;

    function IndexOf(Value: Int32): Integer;
    function FindOrAdd(Value: Int32): Integer;
    { ищет значение Value в векторе и, если не найдено, добавляет его;
      возвращает индекс найденного или добавленного значения }
    { searches for the value Value through the vector and if not found then adds
      it; returns the index of the found or added value }
    function Add(Value: Int32): Integer;

    function IndexOfLastLessThen(Value: Int32): Integer;
    function DecreaseGreater(Value: Int32): Integer;
    function IncreaseGreaterEqual(Value: Int32): Integer;

    property Items[I: Integer]: Int32 read GetValue write SetValue;
      {$IFDEF V_DELPHI}{$IFDEF WIN32}default;{$ENDIF}{$ENDIF}
  end;

implementation

procedure TIndexVector.SetCount(ACount: Integer);
begin
  if ACount > FCount then
    FNotSorted:=True;
  inherited SetCount(ACount);
end;

procedure TIndexVector.CheckSorted;
begin
  if FNotSorted then begin
    Sort;
    FNotSorted:=False;
  end;
end;

function TIndexVector.GetValue(I: Integer): Int32;
begin
  {$IFDEF CHECK_VECTORS}
  if (I < 0) or (I >= Count) then ErrorFmt(SRangeError_d, [I]);
  {$ENDIF}
  CheckSorted;
  Result:=PInt32Array(FItems)^[I];
end;

procedure TIndexVector.SetValue(I: Integer; Value: Int32);
begin
  {$IFDEF CHECK_VECTORS}
  if (I < 0) or (I >= Count) then ErrorFmt(SRangeError_d, [I]);
  {$ENDIF}
  PInt32Array(FItems)^[I]:=Value;
  if not FNotSorted and ((I > 0) and (Value < PInt32Array(FItems)^[I - 1]) or
    (I + 1 < FCount) and (Value > PInt32Array(FItems)^[I + 1]))
  then
    FNotSorted:=True;
end;

constructor TIndexVector.Create(const ElemCount: Integer);
begin
  inherited Create(ElemCount, 0);
end;

function TIndexVector.Compare(I: Integer; const V): Int32;
var
  T: Int32;
begin
  {$IFDEF CHECK_VECTORS}
  if (I < 0) or (I >= Count) then ErrorFmt(SRangeError_d, [I]);
  {$ENDIF}
  T:=PInt32Array(FItems)^[I];
  if T < NumberType(V) then
    Result:=-1
  else
    if T > NumberType(V) then
      Result:=1
    else
      Result:=0;
end;

procedure TIndexVector.Exchange(I, J: Integer);
var
  T: Int32;
begin
  {$IFDEF CHECK_VECTORS}
  if (I < 0) or (I >= Count) then ErrorFmt(SRangeError_d, [I])
  else if (J < 0) or (J >= Count) then ErrorFmt(SRangeError_d, [J]);
  {$ENDIF}
  T:=PInt32Array(FItems)^[I];
  PInt32Array(FItems)^[I]:=PInt32Array(FItems)^[J];
  PInt32Array(FItems)^[J]:=T;
end;

function TIndexVector.FindValue(Value: Int32; var Index: Integer): Bool;
begin
  CheckSorted;
  Result:=Find(Value, Index);
end;

function TIndexVector.IndexOf(Value: Int32): Integer;
begin
  if not FindValue(Value, Result) then
    Result:=-1;
end;

function TIndexVector.IndexOfLastLessThen(Value: Int32): Integer;
begin
  if FindValue(Value, Result) then
    Dec(Result);
end;

function TIndexVector.DecreaseGreater(Value: Int32): Integer;
var
  I, J: Integer;
begin
  if FindValue(Value, J) then begin
    Result:=J;
    Inc(J);
  end
  else
    Result:=-1;
  for I:=FCount - 1 downto J do
    Dec(PInt32Array(FItems)^[I]);
end;

function TIndexVector.IncreaseGreaterEqual(Value: Int32): Integer;
var
  I: Integer;
begin
  FindValue(Value, Result);
  for I:=FCount - 1 downto Result do
    Inc(PInt32Array(FItems)^[I]);
end;

function TIndexVector.FindOrAdd(Value: Int32): Integer;
begin
  if not FindValue(Value, Result) then begin
    Expand(Result);
    PInt32Array(FItems)^[Result]:=Value;
  end;
end;

function TIndexVector.Add(Value: Int32): Integer;
begin
  if not FindValue(Value, Result) then begin
    Expand(Result);
    PInt32Array(FItems)^[Result]:=Value;
  end
  else
    ErrorFmt(SDuplicateError, [Value]);
end;

end.
