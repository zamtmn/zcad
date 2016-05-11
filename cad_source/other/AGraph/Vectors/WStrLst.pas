{ Version 050602. Copyright © Alexey A.Chernobaev, 1996-2005 }

unit WStrLst;

interface

{$I VCheck.inc}

uses
  {$IFDEF V_WIN}Windows,
  {$IFDEF DYNAMIC_NLS}NLSProcsDyn{$ELSE}VUnicode{$ENDIF},
  {$ENDIF}
  SysUtils, ExtType, ExtSys, Vectors, Pointerv, StrLst, VectStr, VectErr,
  {$IFDEF USE_STREAM64}VStrm64{$ELSE}VStream{$ENDIF};

type
  { список Unicode строк без учета регистра символов и без учета локализации }
  { case-insensitive list of wide strings which is not affected by locale }
  TWideStrLst = class(TPointerVector)
  protected
    procedure ClearItems(FromIndex: Integer);
    procedure SetCount(ACount: Integer); override;
    function GetItem(I: Integer): WideString;
    (* {$IFDEF V_INLINE}inline;{$ENDIF}
       - this inline doesn't speed-up (Pentium IV) *)
    procedure SetItem(I: Integer; const Value: WideString);
    function GetName(I: Integer): WideString;
    function GetValue(I: Integer): WideString;
    function GetText: WideString;
    procedure SetText(const AText: WideString);
    function GetCommaText2: WideString;
    function GetCommaText1: WideString;
    procedure SetCommaText2(const Value: WideString);
    procedure SetCommaText1(const Value: WideString);
  public
    function CreateCompatibleVector: TPointerVector; override;
    destructor Destroy; override;
    procedure WriteToStream(VStream: TVStream); override;
    procedure ReadFromStream(VStream: TVStream); override;
    procedure Assign(Source: TVector); override;
    procedure AssignAnsi(Source: TStrLst); virtual;
    function EqualTo(V: TVector): Bool; override;
    procedure Delete(I: Integer); override;
    procedure DeleteRange(I, ACount: Integer); override;
    procedure SetUntyped(I: Integer; const Value); override;
    {$IFDEF V_WIN}
    class function CompareStringsBuf(const PW1, PW2: PWideChar;
      Count1, Count2: Integer): Integer; virtual;
    {$ENDIF}
    class function CompareStrings(const W1, W2: WideString): Integer;
      {$IFNDEF V_WIN}virtual;{$ENDIF}
    function Compare(I: Integer; const V): Int32; override;
    procedure SetToDefault; override;
    procedure SetItems(Values: array of WideString);
    { устанавливает значения элементов списка в Values (Count:=High(Values) + 1) }
    { sets the list elements to Values (Count:=High(Values) + 1) }
    procedure Insert(I: Integer; const Value: WideString); virtual;
    { вставляет значение Value в позицию I }
    { inserts Value in the position I }
    function Add(const Value: WideString): Integer; virtual;
    { добавляет значение в конец списка и возвращает его индекс (Count - 1) }
    { appends Value to the end of the list and returns it's index (Count - 1) }
    procedure Move(CurIndex, NewIndex: Integer); override;
    { изменяет позицию элемента CurIndex на NewIndex }
    { moves the element from the position CurIndex to NewIndex }
    function IndexFrom(I: Integer; const Value: WideString): Integer; virtual;
    { возвращает индекс первого, начиная с I, вхождения значения Value в список,
      либо -1, если такого вхождения не существует }
    { returns the index of the first occurrence of Value in the list beginning
      from I or -1 if there's no such occurrence }
    function IndexOf(const Value: WideString): Integer;
    { IndexOf(Value) = IndexFrom(0, Value) }
    function LastIndexFrom(I: Integer; const Value: WideString): Integer; virtual;
    { возвращает индекс последнего вхождения значения Value в список, который
      не превышает I, либо -1, если нет таких вхождений }
    { returns the index of the last occurrence of Value in the list which is not
      greater then I or -1 if there's no such occurrence }
    function LastIndexOf(const Value: WideString): Integer;
    { LastIndexOf(Value) = LastIndexFrom(Count - 1, Value) }
    function Remove(const Value: WideString): Integer;
    { находит первое вхождение Value в список, удаляет его вызовом Delete и
      возвращает индекс удаленного значения, либо -1, если Value не найдено }
    { searches for the first occurrence of Value in the list, deletes it with
      Delete and returns the index of the deleted value or -1 if Value wasn't
      found }
    function RemoveLast(const Value: WideString): Integer;
    { находит последнее вхождение Value в список, удаляет его вызовом Delete и
      возвращает индекс удаленного значения, либо -1, если Value не найдено }
    { searches for the last occurrence of Value in the list, deletes it with
      Delete and returns the index of the deleted value or -1 if Value wasn't
      found }
    function RemoveFrom(I: Integer; const Value: WideString): Integer;
    { находит первое, начиная с I, вхождение Value в список, удаляет его вызовом
      Delete и возвращает индекс удаленного значения, либо -1, если Value
      не найдено }
    { searches for the first occurrence of Value in the list beginning from I,
      deletes it with Delete and returns the index of the deleted value or -1 if
      Value wasn't found }
    function RemoveLastFrom(I: Integer; const Value: WideString): Integer;
    { находит последнее, но не больше I, вхождение Value в список и удаляет его
      вызовом Delete, возвращая индекс удаленного значения, либо -1, если Value
      не найдено }
    { searches for the last occurrence of Value in the list which is not greater
      then I, deletes it with Delete and returns the index of the deleted value
      or -1 if Value wasn't found }
    function NumberOfValues(const Value: WideString): Integer;
    { возвращает количество элементов, равных Value }
    { returns the number of elements equal to Value }
    function FindInSortedRange(const Value: WideString; L, H: Integer): Integer;
    { находит дихотомически значение Value в упорядоченном по возрастанию
      списке, начиная с индекса L и кончая H; возвращает минимальный индекс
      найденного значения, либо -1, если значение не найдено }
    { searches for the Value in the sorted (ascending) list dichotomically
      from the index L to H; returns the minimum index of Value or -1 if Value
      wasn't found }
    function FindInSorted(const Value: WideString): Integer;
    { ищет значение Value в упорядоченном по возрастанию списке дихотомически;
      возвращает минимальный индекс найденного значения, либо -1, если значение
      не найдено }
    { searches for the Value in the sorted (ascending) list dichotomically;
      returns the minimum index of Value or -1 if Value wasn't found }
    function FindInsertPosition(const Value: WideString; L, H: Integer;
      var Index: Integer): Bool;
    { ищет значение Value в упорядоченном по возрастанию списке дихотомически,
      начиная с индекса L и кончая H; возвращает True, если значение найдено
      (при этом Index равен минимальному индексу найденного значения), иначе
      возвращает False (при этом Index указывает, куда надо вставить Value,
      чтобы список остался упорядоченным) }
    { searches for the Value in the sorted (ascending) list dichotomically
      from the index L to H; returns True if Value was found (in such case Index
      is equal to the minimum index of Value), otherwise returns False (in such
      case Index is equal to the position where Value can be inserted so that
      the list remains sorted) }
    function Find(const Value: WideString; var Index: Integer): Bool;
    { аналог FindInsertPosition для всего списка}
    { analog of FindInsertPosition for the whole list }
    procedure AddStrings(List: TWideStrLst);
    { добавить строки List }
    { adds strings List }
    function Last: WideString;
    { возвращает последний элемент списка (который не должен быть пустым) }
    { returns the last element of the list (which must be non-empty) }
    function Pop: WideString;
    { возвращает последний элемент списка (который не должен быть пустым)
      и удаляет его (т.е. уменьшает длину списка на единицу) }
    { returns the last element of the list (which must be non-empty) and removes
      it (i.e. decreases the length of the list by one) }
    procedure ConcatenateWith(V: TPointerVector); override;
    procedure FreeItems; override;
    function GetCommaText(DoubleQuote: Bool; Delimiter: Char;
      DelimChars: TCharSet): WideString;
    procedure SetCommaText(const Value: WideString; QuoteChar: Char;
      const DelimChars: TCharSet; AddEmpty: Bool);
    function Equals(Strings: TWideStrLst): Bool;
    { сравнивает строки Self со строками Strings }
    { compares strings in Self with strings in Strings }
    property CommaText: WideString read GetCommaText2 write SetCommaText2;
    { представляет список в виде строки, состоящей из всех его элементов,
      которые разделены запятыми и заключены в двойные кавычки }
    { presents the list as a single comma-delimited WideString where the list
      elements are separated with commas and enclosed in the double quotes }
    property CommaText1: WideString read GetCommaText1 write SetCommaText1;
    { представляет список в виде строки, состоящей из всех его элементов,
      которые разделены запятыми и заключены в одинарные кавычки, если в элемент
      входят символы, отличные от латинских букв, цифр и ряда других символов
      (см. CheckText в модуле VectStr) }
    { presents the list as a single comma-delimited WideString where the list
      elements are separated with commas and enclosed in the single quotes if
      they contain characters other then the Latin letters, digits and several
      other characters (see ChectText in the unit VectStr) }
    property Items[I: Integer]: WideString read GetItem write SetItem; default;
    property Strings[I: Integer]: WideString read GetItem write SetItem; { for compatibility }
    property Names[I: Integer]: WideString read GetName;
    property Values[I: Integer]: WideString read GetValue;
    property Text: WideString read GetText write SetText;
    procedure DebugWrite;
  end;

  TWideStrLstClass = class of TWideStrLst;

  {$IFDEF V_WIN}
  { список Unicode строк без учета регистра символов, с учетом локализации;
    строки-элементы не должны содержать #0 (при сортировке #0 интерпретируется
    как конец строки) }
  { case-insensitive list of wide strings which is affected by locale;
    strings-elements should not contain #0 (character #0 is interpreted
    as a string end on sorting) }
  TWinSortWideStrLst = class(TWideStrLst)
    function CreateCompatibleVector: TPointerVector; override;
    class function CompareStringsBuf(const PW1, PW2: PWideChar;
      Count1, Count2: Integer): Integer; override;
    function Compare(I: Integer; const V): Int32; override;
  end;

  TWinSortWideStrLstClass = class of TWinSortWideStrLst;
  {$ENDIF}

  { список Unicode строк с учетом регистра символов и локализации }
  { case-sensitive list of wide strings which is affected by locale }
  TCaseSensWideStrLst = class(TWideStrLst)
    function CreateCompatibleVector: TPointerVector; override;
    {$IFDEF V_WIN}
    class function CompareStringsBuf(const PW1, PW2: PWideChar;
      Count1, Count2: Integer): Integer; override;
    function Compare(I: Integer; const V): Int32; override;
    {$ELSE}
    class function CompareStrings(const W1, W2: WideString): Integer; override;
    {$ENDIF}
  end;

  TCaseSensWideStrLstClass = class of TCaseSensWideStrLst;

  { список Unicode строк с учетом регистра символов, без учета локализации }
  { case-insensitive list of wide strings which is not affected by locale }
  TExactWideStrLst = class(TWideStrLst)
    function CreateCompatibleVector: TPointerVector; override;
    {$IFDEF V_WIN}
    class function CompareStringsBuf(const PW1, PW2: PWideChar;
      Count1, Count2: Integer): Integer; override;
    {$ELSE}
    class function CompareStrings(const W1, W2: WideString): Integer; override;
    {$ENDIF}
    function Compare(I: Integer; const V): Int32; override;
  end;

  TExactWideStrLstClass = class of TExactWideStrLst;

  TSortedWideStrLst = class(TWideStrLst)
    function CreateCompatibleVector: TPointerVector; override;
    procedure AssignAnsi(Source: TStrLst); override;
    procedure Insert(I: Integer; const Value: WideString); override;
    function Add(const Value: WideString): Integer; override;
    procedure Move(CurIndex, NewIndex: Integer); override;
    function IndexFrom(I: Integer; const Value: WideString): Integer; override;
    function LastIndexFrom(I: Integer; const Value: WideString): Integer; override;
  end;

  TSortedWideStrLstClass = class of TSortedWideStrLst;

  TString = WideString;

  TStrObj = class(TWideStrLst)
  {$I StrObj.def}

  TWideStrLstObj = TStrObj;

  TWideStrLstObjClass = class of TWideStrLstObj;

  {$IFDEF V_WIN}
  TWinSortWideStrLstObj = class(TWideStrLstObj)
    function CreateCompatibleVector: TPointerVector; override;
    {$IFDEF V_WIN}
    class function CompareStringsBuf(const PW1, PW2: PWideChar;
      Count1, Count2: Integer): Integer; override;
    {$ELSE}
    class function CompareStrings(const W1, W2: WideString): Integer; override;
    {$ENDIF}
    function Compare(I: Integer; const V): Int32; override;
  end;

  TWinSortWideStrLstObjClass = class of TWinSortWideStrLst;
  {$ENDIF}

  TCaseSensWideStrLstObj = class(TWideStrLstObj)
    function CreateCompatibleVector: TPointerVector; override;
    {$IFDEF V_WIN}
    class function CompareStringsBuf(const PW1, PW2: PWideChar;
      Count1, Count2: Integer): Integer; override;
    function Compare(I: Integer; const V): Int32; override;
    {$ELSE}
    class function CompareStrings(const W1, W2: WideString): Integer; override;
    {$ENDIF}
  end;

  TCaseSensWideStrLstObjClass = class of TCaseSensWideStrLstObj;

  TExactWideStrLstObj = class(TWideStrLstObj)
    function CreateCompatibleVector: TPointerVector; override;
    {$IFDEF V_WIN}
    class function CompareStringsBuf(const PW1, PW2: PWideChar;
      Count1, Count2: Integer): Integer; override;
    {$ELSE}
    class function CompareStrings(const W1, W2: WideString): Integer; override;
    {$ENDIF}
    function Compare(I: Integer; const V): Int32; override;
  end;

  TExactWideStrLstObjClass = class of TExactWideStrLstObj;

(* {$IFDEF V_INLINE}
function ItemToWideString(P: PInt32): WideString;
{$ENDIF} *)

implementation

{ TWideStrLst }

procedure TWideStrLst.ClearItems(FromIndex: Integer);
var
  I: Integer;
  P: PInt32;
begin
  for I:=FromIndex to Count - 1 do begin
    P:=PPointerArray(FItems)^[I];
    if P <> nil then begin
      FreeMem(Pointer(Integer(P) and not 1));
      PPointerArray(FItems)^[I]:=nil;
    end;
  end;
end;

procedure TWideStrLst.SetCount(ACount: Integer);
begin
  if ACount < Count then
    ClearItems(ACount);
  inherited SetCount(ACount);
end;

function ItemToWideString(P: PInt32): WideString;
var
  L: Integer;
  PC: PChar;
  PW: PWideChar;
begin
  if P <> nil then
    if Integer(P) and 1 = 0 then begin
      L:=P^;
      SetLength(Result, L);
      PC:=PChar(P) + 4;
      PW:=Pointer(Result);
      while L > 0 do begin
        PW^:=WideChar(PC^);
        Inc(PC);
        Inc(PW);
        Dec(L);
      end;
    end
    else begin
      P:=Pointer(Integer(P) and not 1);
      L:=P^;
      SetLength(Result, L div 2);
      System.Move((PChar(P) + 4)^, Pointer(Result)^, L);
    end
  else
    Result:='';
end;

function TWideStrLst.GetItem(I: Integer): WideString;
begin
  {$IFDEF CHECK_VECTORS}
  if (I < 0) or (I >= Count) then
    ErrorFmt(SRangeError_d, [I]);
  {$ENDIF}
  Result:=ItemToWideString(PPointerArray(FItems)^[I]);
end;

procedure TWideStrLst.SetItem(I: Integer; const Value: WideString);
var
  L: Integer;
  P: PInt32;
  PC: PChar;
  PW: PWideChar;
begin
  {$IFDEF CHECK_VECTORS}
  if (I < 0) or (I >= Count) then
    ErrorFmt(SRangeError_d, [I]);
  {$ENDIF}
  P:=PPointerArray(FItems)^[I];
  if P <> nil then
    FreeMem(Pointer(Integer(P) and not 1));
  L:=Length(Value);
  if L > 0 then
    if IsASCIIWideString(Value) then begin
      GetMem(P, L + 4);
      P^:=L;
      PC:=PChar(P) + 4;
      PW:=Pointer(Value);
      repeat
        PC^:=Char(PW^);
        Inc(PW);
        Inc(PC);
        Dec(L);
      until L = 0;
    end
    else begin
      L:=L * 2;
      GetMem(P, L + 4);
      P^:=L;
      System.Move(Pointer(Value)^, (PChar(P) + 4)^, L);
      P:=Pointer(Integer(P) or 1);
    end
  else
    P:=nil;
  PPointerArray(FItems)^[I]:=P;
end;

function TWideStrLst.GetName(I: Integer): WideString;
begin
  Result:=Items[I];
  I:=WideCharPos('=', Result, 1);
  if I > 0 then
    Dec(I);
  SetLength(Result, I);
end;

function TWideStrLst.GetValue(I: Integer): WideString;
begin
  Result:=Items[I];
  I:=WideCharPos('=', Result, 1);
  if I > 0 then
    System.Delete(Result, 1, I)
  else
    Result:='';
end;

function TWideStrLst.GetText: WideString;
var
  I, L, N, Sz: Integer;
  P: PWideChar;
  S: WideString;
begin
  N:=Count;
  Sz:=0;
  for I:=0 to N - 1 do
    Inc(Sz, Length(Items[I]));
  Inc(Sz, N{$IFNDEF LINUX} * 2{$ENDIF});
  SetLength(Result, Sz);
  P:=Pointer(Result);
  for I:=0 to N - 1 do begin
    S:=Items[I];
    L:=Length(S);
    if L <> 0 then begin
      System.Move(Pointer(S)^, P^, L * 2);
      Inc(P, L);
    end;
    {$IFNDEF LINUX}
    P^:=#13;
    Inc(P);
    {$ENDIF}
    P^:=#10;
    Inc(P);
  end;
end;

procedure TWideStrLst.SetText(const AText: WideString);
var
  P, Limit, Start: PWideChar;
  S: WideString;
begin
  Clear;
  P:=Pointer(AText);
  Limit:=P + Length(AText);
  while P < Limit do begin
    Start:=P;
    repeat
      if (P^ < #256) and (Char(P^) in [#10, #13]) then
        Break;
      Inc(P);
    until P >= Limit;
    SetWideString(S, Start, P - Start);
    Add(S);
    if P >= Limit then
      Break;
    if P^ = #13 then begin
      Inc(P);
      if P >= Limit then
        Break;
    end;
    if P^ = #10 then
      Inc(P);
  end;
end;

function TWideStrLst.GetCommaText2: WideString;
begin
  Result:=GetCommaText(True, ',', []);
end;

function TWideStrLst.GetCommaText1: WideString;
begin
  Result:=GetCommaText(False, ',', []);
end;

procedure TWideStrLst.SetCommaText2(const Value: WideString);
begin
  SetCommaText(Value, '"', [','], True);
end;

procedure TWideStrLst.SetCommaText1(const Value: WideString);
begin
  SetCommaText(Value, '''', [','], True);
end;

function TWideStrLst.CreateCompatibleVector: TPointerVector;
begin
  Result:=TWideStrLst.Create;
end;

destructor TWideStrLst.Destroy;
begin
  ClearItems(0);
  inherited Destroy;
end;

procedure TWideStrLst.WriteToStream(VStream: TVStream);
var
  I: Integer;
begin
  VStream.WriteInt32(FCount);
  for I:=0 to FCount - 1 do VStream.WriteWideString(Items[I]);
end;

procedure TWideStrLst.ReadFromStream(VStream: TVStream);
var
  I: Integer;
begin
  Clear;
  for I:=0 to VStream.ReadInt32 - 1 do Add(VStream.ReadWideString);
end;

procedure TWideStrLst.Delete(I: Integer);
begin
  Items[I]:='';
  inherited Delete(I);
end;

procedure TWideStrLst.DeleteRange(I, ACount: Integer);
var
  J: Integer;
begin
  for J:=I to I + ACount - 1 do
    Items[J]:='';
  inherited DeleteRange(I, ACount);
end;

procedure TWideStrLst.SetUntyped(I: Integer; const Value);
begin
  SetItem(I, ItemToWideString(Pointer(Value)));
end;

{$IFDEF V_WIN}
class function TWideStrLst.CompareStringsBuf(const PW1, PW2: PWideChar;
  Count1, Count2: Integer): Integer;
begin
  Result:=CompareTextBufWide(PW1, PW2, Count1, Count2);
end;
{$ENDIF}

class function TWideStrLst.CompareStrings(const W1, W2: WideString): Integer;
begin
  {$IFDEF V_WIN}
  Result:=CompareStringsBuf(PWideChar(W1), PWideChar(W2), Length(W1), Length(W2));
  {$ELSE}
  Result:=WideCompareText(W1, W2);
  {$ENDIF}
end;

function TWideStrLst.Compare(I: Integer; const V): Int32;
var
  P1, P2: PInt32;
  {$IFDEF V_WIN}B1, B2: Bool;{$ENDIF}
begin
  P1:=PPointerArray(FItems)^[I];
  P2:=PInt32(V);
  if P1 = P2 then begin
    Result:=0;
    Exit;
  end;
  if P1 = nil then begin
    Result:=-1;
    Exit;
  end;
  if P2 = nil then begin
    Result:=1;
    Exit;
  end;
  {$IFDEF V_WIN}
  B1:=Integer(P1) and 1 <> 0;
  B2:=Integer(P2) and 1 <> 0;
  if B1 and B2 then begin
    P1:=Pointer(Integer(P1) and not 1);
    P2:=Pointer(Integer(P2) and not 1);
    Result:=CompareStringsBuf(Pointer(PChar(P1) + 4), Pointer(PChar(P2) + 4),
      P1^ div 2, P2^ div 2);
  end
  else
    {$IFDEF WIN32} { for efficiency }
    if not (B1 or B2) then
      Result:=CompareTextBuf(PChar(P1) + 4, PChar(P2) + 4, P1^, P2^)
    else
    {$ENDIF}
  {$ENDIF}
      Result:=CompareStrings(ItemToWideString(P1), ItemToWideString(P2));
end;

procedure TWideStrLst.SetToDefault;
begin
  ClearItems(0);
end;

procedure TWideStrLst.SetItems(Values: array of WideString);
var
  I: Integer;
begin
  Count:=High(Values) + 1;
  for I:=0 to High(Values) do
    Items[I]:=Values[I];
end;

procedure TWideStrLst.Insert(I: Integer; const Value: WideString);
begin
  inherited Insert(I, nil);
  Items[I]:=Value;
end;

function TWideStrLst.Add(const Value: WideString): Integer;
begin
  Result:=Count;
  Insert(Result, Value);
end;

procedure TWideStrLst.Move(CurIndex, NewIndex: Integer);
var
  T: WideString;
begin
  if CurIndex <> NewIndex then begin
    T:=Items[CurIndex];
    Delete(CurIndex);
    Insert(NewIndex, T);
  end;
end;

function TWideStrLst.IndexFrom(I: Integer; const Value: WideString): Integer;
var
  N: Integer;
begin
  N:=Count;
  Result:=I;
  while Result < N do begin
    if CompareStrings(ItemToWideString(PPointerArray(FItems)^[Result]), Value) = 0 then
      Exit;
    Inc(Result);
  end;
  Result:=-1;
end;

function TWideStrLst.IndexOf(const Value: WideString): Integer;
begin
  Result:=IndexFrom(0, Value);
end;

function TWideStrLst.LastIndexFrom(I: Integer; const Value: WideString): Integer;
begin
  Result:=I;
  while Result >= 0 do begin
    if CompareStrings(ItemToWideString(PPointerArray(FItems)^[Result]), Value) = 0 then
      Exit;
    Dec(Result);
  end;
end;

function TWideStrLst.LastIndexOf(const Value: WideString): Integer;
begin
  Result:=LastIndexFrom(Count - 1, Value);
end;

function TWideStrLst.Remove(const Value: WideString): Integer;
begin
  Result:=IndexOf(Value);
  if Result >= 0 then
    Delete(Result);
end;

function TWideStrLst.RemoveLast(const Value: WideString): Integer;
begin
  Result:=LastIndexOf(Value);
  if Result >= 0 then
    Delete(Result);
end;

function TWideStrLst.RemoveFrom(I: Integer; const Value: WideString): Integer;
begin
  Result:=IndexFrom(I, Value);
  if Result >= 0 then
    Delete(Result);
end;

function TWideStrLst.RemoveLastFrom(I: Integer; const Value: WideString): Integer;
begin
  Result:=LastIndexFrom(I, Value);
  if Result >= 0 then
    Delete(Result);
end;

function TWideStrLst.NumberOfValues(const Value: WideString): Integer;
var
  I: Integer;
begin
  Result:=0;
  for I:=0 to Count - 1 do
    if CompareStrings(ItemToWideString(PPointerArray(FItems)^[I]), Value) = 0 then
      Inc(Result);
end;

function TWideStrLst.FindInsertPosition(const Value: WideString; L, H: Integer;
  var Index: Integer): Bool;
var
  I, C: Integer;
begin
  Result:=False;
  while L <= H do begin
    I:=(L + H) shr 1;
    C:=CompareStrings(ItemToWideString(PPointerArray(FItems)^[I]), Value);
    if C < 0 then
      L:=I + 1
    else begin
      H:=I - 1;
      if C = 0 then
        Result:=True;
    end;
  end;
  Index:=L;
end;

function TWideStrLst.Find(const Value: WideString; var Index: Integer): Bool;
begin
  Result:=FindInsertPosition(Value, 0, FCount - 1, Index);
end;

function TWideStrLst.FindInSortedRange(const Value: WideString; L, H: Integer): Integer;
begin
  if not FindInsertPosition(Value, L, H, Result) then
    Result:=-1;
end;

function TWideStrLst.FindInSorted(const Value: WideString): Integer;
begin
  Result:=FindInSortedRange(Value, 0, FCount - 1);
end;

procedure TWideStrLst.Assign(Source: TVector);
var
  I: Integer;
begin
  if Source is TWideStrLst then begin
    Count:=Source.Count;
    for I:=0 to Count - 1 do
      Items[I]:=TWideStrLst(Source).Items[I];
  end
  else
    Error(SAssignError);
end;

procedure TWideStrLst.AssignAnsi(Source: TStrLst);
var
  I, N: Integer;
begin
  N:=Source.Count;
  Count:=N;
  for I:=0 to N - 1 do
    Items[I]:=Source[I];
end;

function TWideStrLst.EqualTo(V: TVector): Bool;
var
  I: Integer;
begin
  if not (V is TWideStrLst) then
    Error(SIncompatibleClasses);
  Result:=False;
  if FCount = V.Count then begin
    for I:=0 to FCount - 1 do
      if Compare(I, PPointerArray(TWideStrLst(V).FItems)^[I]) <> 0 then
        Exit;
    Result:=True;
  end;
end;

procedure TWideStrLst.AddStrings(List: TWideStrLst);
begin
  ConcatenateWith(List);
end;

function TWideStrLst.Last: WideString;
begin
  Result:=Items[Count - 1];
end;

function TWideStrLst.Pop: WideString;
var
  N: Integer;
begin
  N:=Count - 1;
  Result:=Items[N];
  Count:=N;
end;

procedure TWideStrLst.ConcatenateWith(V: TPointerVector);
var
  I: Integer;
begin
  if not (V is TWideStrLst) then
    Error(SIncompatibleClasses);
  for I:=0 to TWideStrLst(V).Count - 1 do
    Add(TWideStrLst(V).Items[I]);
end;

procedure TWideStrLst.FreeItems;
begin
  Error(SMethodNotApplicable);
end;

function TWideStrLst.GetCommaText(DoubleQuote: Bool; Delimiter: Char;
  DelimChars: TCharSet): WideString;
type
  TFunc = function (const W: WideString): WideString;
var
  I: Integer;
  W: WideString;
  Func1, Func2: TFunc;
begin
  if DoubleQuote then begin
    Func1:=WideTextToLiteral2;
    Func2:=WideStringToLiteral2;
  end
  else begin
    Func1:=WideTextToLiteral;
    Func2:=WideStringToLiteral;
  end;
  Include(DelimChars, Delimiter);
  Result:='';
  for I:=0 to Count - 1 do begin
    if I > 0 then
      Result:=Result + Delimiter;
    W:=Items[I];
    if ContainsChars(W, DelimChars) then
      W:=Func2(W)
    else
      W:=Func1(W);
    Result:=Result + W;
  end;
end;

procedure TWideStrLst.SetCommaText(const Value: WideString; QuoteChar: Char;
  const DelimChars: TCharSet; AddEmpty: Bool);
var
  I: Integer;
  Delim, Quote, Coming: Bool;
  C: WideChar;
  W: WideString;
begin
  Clear;
  W:='';
  Quote:=False;
  Coming:=False;
  for I:=1 to Length(Value) do begin
    C:=Value[I];
    Delim:=(C <= #256) and (Char(C) in DelimChars);
    if Quote or not Delim then begin
      if C = WideChar(QuoteChar) then
        Quote:=not Quote;
      {$IFDEF V_WIDESTRING_PLUS}
      W:=W + C;
      {$ELSE}
      SetLength(W, Length(W) + 1);
      W[Length(W)]:=C;
      {$ENDIF}
      Coming:=True;
    end
    else begin
      W:=LiteralToWideString(W);
      if AddEmpty or (W <> '') then
        Add(W);
      W:='';
      Coming:=Delim;
    end;
  end;
  if Coming and (AddEmpty or (W <> '')) then
    Add(LiteralToWideString(W));
end;

function TWideStrLst.Equals(Strings: TWideStrLst): Bool;
begin
  Result:=EqualTo(Strings);
end;

procedure TWideStrLst.DebugWrite;
var
  I, N: Integer;
begin
  N:=FCount - 1;
  for I:=0 to N do begin
    write(String(ItemToWideString(PPointerArray(FItems)^[I])));
    if I < N then write(', ') else writeln;
  end;
end;

{$IFDEF V_WIN}

{ TWinSortWideStrLst }

function TWinSortWideStrLst.CreateCompatibleVector: TPointerVector;
begin
  Result:=TWinSortWideStrLst.Create;
end;

class function TWinSortWideStrLst.CompareStringsBuf(const PW1, PW2: PWideChar;
  Count1, Count2: Integer): Integer;
begin
  Result:=SystemIndependent_CompareStringW(LOCALE_USER_DEFAULT, NORM_IGNORECASE,
    PW1, Count1, PW2, Count2) - 2;
end;

function WinSortCompare(P1, P2: PInt32): Int32;
var
  B1, B2: Bool;
begin
  if P1 = P2 then begin
    Result:=0;
    Exit;
  end;
  if P1 = nil then begin
    Result:=-1;
    Exit;
  end;
  if P2 = nil then begin
    Result:=1;
    Exit;
  end;
  B1:=Integer(P1) and 1 <> 0;
  B2:=Integer(P2) and 1 <> 0;
  if B1 and B2 then begin
    P1:=Pointer(Integer(P1) and not 1);
    P2:=Pointer(Integer(P2) and not 1);
    Result:=SystemIndependent_CompareStringW(LOCALE_USER_DEFAULT, NORM_IGNORECASE,
      Pointer(PChar(P1) + 4), P1^ div 2, Pointer(PChar(P2) + 4), P2^ div 2) - 2;
  end
  else
    {$IFDEF WIN32} { for efficiency }
    if not (B1 or B2) then
      Result:=CompareString(LOCALE_USER_DEFAULT, NORM_IGNORECASE,
        Pointer(PChar(P1) + 4), P1^, Pointer(PChar(P2) + 4), P2^) - 2
    else
    {$ENDIF}
      Result:=TWinSortWideStrLst.CompareStrings(ItemToWideString(P1), ItemToWideString(P2));
end;

function TWinSortWideStrLst.Compare(I: Integer; const V): Int32;
begin
  Result:=WinSortCompare(PPointerArray(FItems)^[I], PInt32(V));
end;

{$ENDIF}

{ TCaseSensWideStrLst }

function TCaseSensWideStrLst.CreateCompatibleVector: TPointerVector;
begin
  Result:=TCaseSensWideStrLst.Create;
end;

{$IFDEF V_WIN}
class function TCaseSensWideStrLst.CompareStringsBuf(const PW1, PW2: PWideChar;
  Count1, Count2: Integer): Integer;
begin
  Result:=SystemIndependent_CompareStringW(LOCALE_USER_DEFAULT, 0, PW1, Count1,
    PW2, Count2) - 2;
end;

function CaseSensCompare(P1, P2: PInt32): Int32;
var
  B1, B2: Bool;
begin
  if P1 = P2 then begin
    Result:=0;
    Exit;
  end;
  if P1 = nil then begin
    Result:=-1;
    Exit;
  end;
  if P2 = nil then begin
    Result:=1;
    Exit;
  end;
  B1:=Integer(P1) and 1 <> 0;
  B2:=Integer(P2) and 1 <> 0;
  if B1 and B2 then begin
    P1:=Pointer(Integer(P1) and not 1);
    P2:=Pointer(Integer(P2) and not 1);
    Result:=SystemIndependent_CompareStringW(LOCALE_USER_DEFAULT, 0,
      Pointer(PChar(P1) + 4), P1^ div 2, Pointer(PChar(P2) + 4), P2^ div 2) - 2;
  end
  else
    {$IFDEF WIN32} { for efficiency }
    if not (B1 or B2) then
      Result:=CompareString(LOCALE_USER_DEFAULT, 0,
        Pointer(PChar(P1) + 4), P1^, Pointer(PChar(P2) + 4), P2^) - 2
    else
    {$ENDIF}
      Result:=TCaseSensWideStrLst.CompareStrings(ItemToWideString(P1), ItemToWideString(P2));
end;

function TCaseSensWideStrLst.Compare(I: Integer; const V): Int32;
begin
  Result:=CaseSensCompare(PPointerArray(FItems)^[I], PInt32(V));
end;

{$ELSE}

class function TCaseSensWideStrLst.CompareStrings(const W1, W2: WideString): Integer;
begin
  Result:=WideCompareStr(W1, W2);
end;
{$ENDIF}

{ TExactWideStrLst }

function TExactWideStrLst.CreateCompatibleVector: TPointerVector;
begin
  Result:=TExactWideStrLst.Create;
end;

function ExactCompare(P1, P2: PInt32): Int32;
var
  B1, B2: Bool;
begin
  if P1 = P2 then begin
    Result:=0;
    Exit;
  end;
  if P1 = nil then begin
    Result:=-1;
    Exit;
  end;
  if P2 = nil then begin
    Result:=1;
    Exit;
  end;
  B1:=Integer(P1) and 1 <> 0;
  B2:=Integer(P2) and 1 <> 0;
  if B1 and B2 then begin
    P1:=Pointer(Integer(P1) and not 1);
    P2:=Pointer(Integer(P2) and not 1);
    Result:=CompareStrBufWide(Pointer(PChar(P1) + 4), Pointer(PChar(P2) + 4),
      P1^ div 2, P2^ div 2);
  end
  else
    {$IFDEF WIN32} { for efficiency }
    if not (B1 or B2) then
      Result:=CompareStrBuf(PChar(P1) + 4, PChar(P2) + 4, P1^, P2^)
    else
    {$ENDIF}
      Result:=TExactWideStrLst.CompareStrings(ItemToWideString(P1), ItemToWideString(P2));
end;

{$IFDEF V_WIN}
class function TExactWideStrLst.CompareStringsBuf(const PW1, PW2: PWideChar;
  Count1, Count2: Integer): Integer;
begin
  Result:=CompareStrBufWide(PW1, PW2, Count1, Count2);
end;

{$ELSE}

class function TExactWideStrLst.CompareStrings(const W1, W2: WideString): Integer;
begin
  Result:=CompareStrWide(W1, W2);
end;
{$ENDIF}

function TExactWideStrLst.Compare(I: Integer; const V): Int32;
begin
  Result:=ExactCompare(PPointerArray(FItems)^[I], PInt32(V));
end;

{ TSortedWideStrLst }

function TSortedWideStrLst.CreateCompatibleVector: TPointerVector;
begin
  Result:=TSortedWideStrLst.Create;
end;

procedure TSortedWideStrLst.AssignAnsi(Source: TStrLst);
begin
  inherited AssignAnsi(Source);
  Sort;
end;

procedure TSortedWideStrLst.Insert(I: Integer; const Value: WideString);
begin
  Error(SMethodNotApplicable);
end;

function TSortedWideStrLst.Add(const Value: WideString): Integer;
begin
  if FindInsertPosition(Value, 0, FCount - 1, Result) then
    Error(SDuplicateError)
  else
    inherited Insert(Result, Value);
end;

procedure TSortedWideStrLst.Move(CurIndex, NewIndex: Integer);
begin
  Error(SMethodNotApplicable);
end;

function TSortedWideStrLst.IndexFrom(I: Integer; const Value: WideString): Integer;
begin
  Result:=FindInSorted(Value);
end;

function TSortedWideStrLst.LastIndexFrom(I: Integer; const Value: WideString): Integer;
begin
  Result:=FindInSorted(Value);
end;

{ TWideStrLstObj }

{$I StrObj.imp}

{$IFDEF V_WIN}

{ TWinSortWideStrLstObj }

function TWinSortWideStrLstObj.CreateCompatibleVector: TPointerVector;
begin
  Result:=TWinSortWideStrLstObj.Create;
end;

class function TWinSortWideStrLstObj.CompareStringsBuf(const PW1, PW2: PWideChar;
  Count1, Count2: Integer): Integer;
begin
  Result:=SystemIndependent_CompareStringW(LOCALE_USER_DEFAULT, NORM_IGNORECASE,
    PW1, Count1, PW2, Count2) - 2;
end;

function TWinSortWideStrLstObj.Compare(I: Integer; const V): Int32;
begin
  Result:=WinSortCompare(PPointerArray(FItems)^[I], PInt32(V));
end;
{$ENDIF}

{ TCaseSensWideStrLstObj }

function TCaseSensWideStrLstObj.CreateCompatibleVector: TPointerVector;
begin
  Result:=TCaseSensWideStrLstObj.Create;
end;

{$IFDEF V_WIN}
class function TCaseSensWideStrLstObj.CompareStringsBuf(const PW1, PW2: PWideChar;
  Count1, Count2: Integer): Integer;
begin
  Result:=SystemIndependent_CompareStringW(LOCALE_USER_DEFAULT, 0, PW1, Count1,
    PW2, Count2) - 2;
end;

function TCaseSensWideStrLstObj.Compare(I: Integer; const V): Int32;
begin
  Result:=CaseSensCompare(PPointerArray(FItems)^[I], PInt32(V));
end;

{$ELSE}

class function TCaseSensWideStrLstObj.CompareStrings(const W1, W2: WideString): Integer;
begin
  Result:=TCaseSensWideStrLst.CompareStrings(W1, W2);
end;
{$ENDIF}

{ TExactWideStrLstObj }

function TExactWideStrLstObj.CreateCompatibleVector: TPointerVector;
begin
  Result:=TExactWideStrLstObj.Create;
end;

{$IFDEF V_WIN}
class function TExactWideStrLstObj.CompareStringsBuf(const PW1, PW2: PWideChar;
  Count1, Count2: Integer): Integer;
begin
  Result:=CompareStrBufWide(PW1, PW2, Count1, Count2);
end;

{$ELSE}

class function TExactWideStrLstObj.CompareStrings(const W1, W2: WideString): Integer;
begin
  Result:=TExactWideStrLst.CompareStrings(W1, W2);
end;
{$ENDIF}

function TExactWideStrLstObj.Compare(I: Integer; const V): Int32;
begin
  Result:=ExactCompare(PPointerArray(FItems)^[I], PInt32(V));
end;

end.
