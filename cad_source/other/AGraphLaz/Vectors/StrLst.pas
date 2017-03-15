{ Version 050602. Copyright © Alexey A.Chernobaev, 1996-2005 }

unit StrLst;

interface

{$I VCheck.inc}

uses
  {$IFDEF WIN32}Windows,{$ENDIF} SysUtils,
  ExtType, ExtSys, Vectors, Pointerv, VectStr,
  {$IFDEF USE_STREAM64}VStrm64{$ELSE}VStream{$ENDIF}, VTxtStrm, VectErr;

type
  TOnCompareStrings = function (const S1, S2: String): Int32 of object;

  { список строк без учета регистра символов, с учетом локализации (метод
    "Compare" использует AnsiCompareText) }
  { string list without case sensitivity which is affected by locale ("Compare"
    method uses AnsiCompareText) }
  TStrLst = class(TPointerVector)
  protected
    procedure ClearItems(FromIndex: Integer);
    procedure SetCount(ACount: Integer); override;
    function GetItem(I: Integer): String;
    (* {$IFDEF V_INLINE}inline;{$ENDIF}
       - this inline doesn't speed-up (Pentium IV) *)
    procedure SetItem(I: Integer; const Value: String);
    (* {$IFDEF V_INLINE}inline;{$ENDIF}
       - this inline doesn't speed-up (Pentium IV) *)
    function GetName(I: Integer): String;
    function GetValue(I: Integer): String;
    function GetText: String;
    procedure SetText(const AText: String);
    function GetCommaText2: String;
    function GetCommaText1: String;
    procedure SetCommaText2(const Value: String);
    procedure SetCommaText1(const Value: String);
    function GetLast: String;
    procedure SetLast(Value: String);
  public
    function CreateCompatibleVector: TPointerVector; override;
    destructor Destroy; override;
    procedure WriteToStream(VStream: TVStream); override;
    procedure ReadFromStream(VStream: TVStream); override;
    procedure WriteToTextStream(TextStream: TTextStream);
    procedure ReadFromTextStream(TextStream: TTextStream);
    procedure Assign(Source: TVector); override;
    function EqualTo(V: TVector): Bool; override;
    procedure Delete(I: Integer); override;
    procedure DeleteRange(I, ACount: Integer); override;
    procedure GetUntyped(I: Integer; var Result); override;
    procedure SetUntyped(I: Integer; const Value); override;
    class function CompareStrings(const S1, S2: String): Int32; virtual;
    function Compare(I: Integer; const V): Int32; override;
    procedure SetToDefault; override;
    procedure SetItems(Values: array of String);
    { устанавливает значения элементов списка в Values (Count:=High(Values) + 1) }
    { sets the list elements to Values (Count:=High(Values) + 1) }
    procedure Insert(I: Integer; const Value: String); virtual;
    { вставляет значение Value в позицию I }
    { inserts Value in the position I }
    function Add(const Value: String): Integer; virtual;
    { добавляет значение в конец списка и возвращает его индекс (Count - 1) }
    { appends Value to the end of the list and returns it's index (Count - 1) }
    procedure Move(CurIndex, NewIndex: Integer); override;
    { изменяет позицию элемента CurIndex на NewIndex }
    { moves the element from the position CurIndex to NewIndex }
    function IndexFrom(I: Integer; const Value: String): Integer; virtual;
    { возвращает индекс первого, начиная с I, вхождения значения Value в список,
      либо -1, если такого вхождения не существует }
    { returns the index of the first occurrence of Value in the list beginning
      from I or -1 if there's no such occurrence }
    function IndexOf(const Value: String): Integer;
    { IndexOf(Value) = IndexFrom(0, Value) }
    function LastIndexFrom(I: Integer; const Value: String): Integer; virtual;
    { возвращает индекс последнего вхождения значения Value в список, который
      не превышает I, либо -1, если нет таких вхождений }
    { returns the index of the last occurrence of Value in the list which is not
      greater then I or -1 if there's no such occurrence }
    function LastIndexOf(const Value: String): Integer;
    { LastIndexOf(Value) = LastIndexFrom(Count - 1, Value) }
    function Remove(const Value: String): Integer;
    { находит первое вхождение Value в список, удаляет его вызовом Delete и
      возвращает индекс удаленного значения, либо -1, если Value не найдено }
    { searches for the first occurrence of Value in the list, deletes it with
      Delete and returns the index of the deleted value or -1 if Value wasn't
      found }
    function RemoveLast(const Value: String): Integer;
    { находит последнее вхождение Value в список, удаляет его вызовом Delete и
      возвращает индекс удаленного значения, либо -1, если Value не найдено }
    { searches for the last occurrence of Value in the list, deletes it with
      Delete and returns the index of the deleted value or -1 if Value wasn't
      found }
    function RemoveFrom(I: Integer; const Value: String): Integer;
    { находит первое, начиная с I, вхождение Value в список, удаляет его вызовом
      Delete и возвращает индекс удаленного значения, либо -1, если Value
      не найдено }
    { searches for the first occurrence of Value in the list beginning from I,
      deletes it with Delete and returns the index of the deleted value or -1 if
      Value wasn't found }
    function RemoveLastFrom(I: Integer; const Value: String): Integer;
    { находит последнее, но не больше I, вхождение Value в список и удаляет его
      вызовом Delete, возвращая индекс удаленного значения, либо -1, если Value
      не найдено }
    { searches for the last occurrence of Value in the list which is not greater
      then I, deletes it with Delete and returns the index of the deleted value
      or -1 if Value wasn't found }
    function NumberOfValues(const Value: String): Integer;
    { возвращает количество элементов, равных Value }
    { returns the number of elements equal to Value }
    function FindInSortedRange(const Value: String; L, H: Integer): Integer;
    { находит дихотомически значение Value в упорядоченном по возрастанию
      списке, начиная с индекса L и кончая H; возвращает минимальный индекс
      найденного значения, либо -1, если значение не найдено }
    { searches for the Value in the sorted (ascending) list dichotomically
      from the index L to H; returns the minimum index of Value or -1 if Value
      wasn't found }
    function FindInSorted(const Value: String): Integer;
    { ищет значение Value в упорядоченном по возрастанию списке дихотомически;
      возвращает минимальный индекс найденного значения, либо -1, если значение
      не найдено }
    { searches for the Value in the sorted (ascending) list dichotomically;
      returns the minimum index of Value or -1 if Value wasn't found }
    function FindInsertPosition(const Value: String; L, H: Integer;
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
    function Find(const Value: String; var Index: Integer): Bool;
    { аналог FindInsertPosition для всего списка}
    { analog of FindInsertPosition for the whole list }
    procedure AddStrings(List: TStrLst); 
    { добавить строки List }
    { adds strings List }
    function Pop: String;
    { возвращает последний элемент списка (который не должен быть пустым)
      и удаляет его (т.е. уменьшает длину списка на единицу) }
    { returns the last element of the list (which must be non-empty) and removes
      it (i.e. decreases the length of the list by one) }
    procedure ConcatenateWith(V: TPointerVector); override;
    procedure FreeItems; override;
    function GetCommaText(DoubleQuote: Bool; Delimiter: Char;
      DelimChars: TCharSet): String;
    procedure SetCommaText(const Value: String; QuoteChar: Char;
      const DelimChars: TCharSet; AddEmpty: Bool);
    function Equals(Strings: TStrLst): Bool;
    { сравнивает строки Self со строками Strings }
    { compares strings in Self with strings in Strings }
    property CommaText: String read GetCommaText2 write SetCommaText2;
    { представляет список в виде строки, состоящей из всех его элементов,
      которые разделены запятыми и заключены в двойные кавычки, если в элемент
      входят символы, отличные от латинских букв, цифр и ряда других символов
      (см. CheckText в модуле VectStr) }
    { presents the list as a single comma-delimited string where the list
      elements are separated with commas and enclosed in the double quotes if
      they contain characters other then the Latin letters, digits and several
      other characters (see ChectText in the unit VectStr) }
    property CommaText1: String read GetCommaText1 write SetCommaText1;
    { представляет список в виде строки, состоящей из всех его элементов,
      которые разделены запятыми и заключены в одинарные кавычки, если в элемент
      входят символы, отличные от латинских букв, цифр и ряда других символов
      (см. CheckText в модуле VectStr) }
    { presents the list as a single comma-delimited string where the list
      elements are separated with commas and enclosed in the single quotes if
      they contain characters other then the Latin letters, digits and several
      other characters (see ChectText in the unit VectStr) }
    property Items[I: Integer]: String read GetItem write SetItem; {$IFDEF V_32}default;{$ENDIF}
    property Strings[I: Integer]: String read GetItem write SetItem; { for compatibility }
    property Names[I: Integer]: String read GetName;
    property Values[I: Integer]: String read GetValue;
    property Text: String read GetText write SetText;
    property Last: String read GetLast write SetLast;
    { возвращает или устанавливает последний элемент списка (список не должен
      быть пустым) }
    { gets or sets the last element of the list (the list must not be empty) }
    procedure DebugWrite;
    { отладочная печать; для вывода отладочной информации в графических
      Win32-приложениях необходимо создать консоль с помощью AllocConsole }
    { debug write; to use in Win32 GUI applications it's necessary to create
      console with AllocConsole }
  end;

  TStrLstClass = class of TStrLst;

  { список строк с учетом регистра символов, но без учета локализации (метод
    "Compare" использует CompareText) }
  { string list without case sensitivity which is not affected by locale
    ("Compare" method uses CompareText) }
  TASCIIStrLst = class(TStrLst)
    function CreateCompatibleVector: TPointerVector; override;
    class function CompareStrings(const S1, S2: String): Int32; override;
  end;

  TASCIIStrLstClass = class of TASCIIStrLst;

  { список строк с учетом регистра символов и локализации (метод "Compare"
    использует AnsiCompareStr) }
  { string list with case sensitivity which is affected by locale ("Compare"
    method uses AnsiCompareStr) }
  TCaseSensStrLst = class(TStrLst)
    function CreateCompatibleVector: TPointerVector; override;
    class function CompareStrings(const S1, S2: String): Int32; override;
  end;

  TCaseSensStrLstClass = class of TCaseSensStrLst;

  { список строк с учетом регистра символов, но без учета локализации (метод
    "Compare" использует CompareStr) }
  { string list without case sensitivity which is not affected by locale
    ("Compare" method uses CompareStr) }
  TExactStrLst = class(TStrLst)
    function CreateCompatibleVector: TPointerVector; override;
    class function CompareStrings(const S1, S2: String): Int32; override;
  end;

  TExactStrLstClass = class of TExactStrLst;

  { список строк с определяемым пользователем способом сравнения строк }
  { string list with user-defined string compare method }
  TUserCompareStrLst = class(TStrLst)
    OnCompareStrings: TOnCompareStrings;
    procedure Assign(Source: TVector); override;
    function Compare(I: Integer; const V): Int32; override;
    function CreateCompatibleVector: TPointerVector; override;
    class function CompareStrings(const S1, S2: String): Int32; override;
  end;

  TUserCompareStrLstClass = class of TUserCompareStrLst;

  TSortedStrLst = class(TStrLst)
    function CreateCompatibleVector: TPointerVector; override;
    procedure Insert(I: Integer; const Value: String); override;
    function Add(const Value: String): Integer; override;
    procedure Move(CurIndex, NewIndex: Integer); override;
    function IndexFrom(I: Integer; const Value: String): Integer; override;
    function LastIndexFrom(I: Integer; const Value: String): Integer; override;
  end;

  TSortedStrLstClass = class of TSortedStrLst;

  TASCIISortedStrLst = class(TSortedStrLst)
    function CreateCompatibleVector: TPointerVector; override;
    class function CompareStrings(const S1, S2: String): Int32; override;
  end;

  TASCIISortedStrLstClass = class of TASCIISortedStrLst;

  TCaseSensSortedStrLst = class(TSortedStrLst)
    function CreateCompatibleVector: TPointerVector; override;
    class function CompareStrings(const S1, S2: String): Int32; override;
  end;

  TCaseSensSortedStrLstClass = class of TCaseSensSortedStrLst;

  TExactSortedStrLst = class(TSortedStrLst)
    function CreateCompatibleVector: TPointerVector; override;
    class function CompareStrings(const S1, S2: String): Int32; override;
  end;

  TExactSortedStrLstClass = class of TExactSortedStrLst;

  { список строк с ассоциированными объектами }
  { string list with associated objects }

  TString = String;

  TStrObj = class(TStrLst)
  {$I StrObj.def}

  TStrLstObj = TStrObj;

  TStrLstObjClass = class of TStrLstObj;

  TASCIIStrLstObj = class(TStrLstObj)
    function CreateCompatibleVector: TPointerVector; override;
    class function CompareStrings(const S1, S2: String): Int32; override;
  end;

  TASCIIStrLstObjClass = class of TASCIIStrLstObj;

  TCaseSensStrLstObj = class(TStrLstObj)
    function CreateCompatibleVector: TPointerVector; override;
    class function CompareStrings(const S1, S2: String): Int32; override;
  end;

  TCaseSensStrLstObjClass = class of TCaseSensStrLstObj;

  TExactStrLstObj = class(TStrLstObj)
    function CreateCompatibleVector: TPointerVector; override;
    class function CompareStrings(const S1, S2: String): Int32; override;
  end;

  TExactStrLstObjClass = class of TExactStrLstObj;

  TUserCompareStrLstObj = class(TStrLstObj)
    OnCompareStrings: TOnCompareStrings;
    function Compare(I: Integer; const V): Int32; override;
    procedure Assign(Source: TVector); override;
    function CreateCompatibleVector: TPointerVector; override;
    class function CompareStrings(const S1, S2: String): Int32; override;
  end;

  TUserCompareStrLstObjClass = class of TUserCompareStrLstObj;

implementation

{ TStrLst }

procedure TStrLst.ClearItems(FromIndex: Integer);
var
  I: Integer;
begin
  for I:=FromIndex to Count - 1 do
    Items[I]:='';
end;

procedure TStrLst.SetCount(ACount: Integer);
begin
  if ACount < Count then
    ClearItems(ACount);
  inherited SetCount(ACount);
end;

function TStrLst.GetItem(I: Integer): String;
var
  P: PVString;
begin
  {$IFDEF CHECK_VECTORS}
  if (I < 0) or (I >= Count) then ErrorFmt(SRangeError_d, [I]);
  {$ENDIF}
  P:=PPointerArray(FItems)^[I];
  if P <> nil then
    Result:=P^
  else
    Result:='';
end;

procedure TStrLst.SetItem(I: Integer; const Value: String);
begin
  {$IFDEF CHECK_VECTORS}
  if (I < 0) or (I >= Count) then ErrorFmt(SRangeError_d, [I]);
  {$ENDIF}
  DisposeVStr(PPointerArray(FItems)^[I]);
  PPointerArray(FItems)^[I]:=NewVStr(Value);
end;

function TStrLst.GetName(I: Integer): String;
begin
  Result:=Items[I];
  I:=CharPos('=', Result, 1);
  if I > 0 then
    Dec(I);
  SetLength(Result, I);
end;

function TStrLst.GetValue(I: Integer): String;
begin
  Result:=Items[I];
  I:=CharPos('=', Result, 1);
  if I > 0 then
    System.Delete(Result, 1, I)
  else
    Result:='';
end;

function TStrLst.GetText: String;
var
  I, L, N, Sz: Integer;
  P: PChar;
  S: String;
begin
  N:=Count;
  Sz:=0;
  for I:=0 to N - 1 do
    Inc(Sz, Length(Items[I]));
  Inc(Sz, N{$IFNDEF LINUX} * 2{$ENDIF});
  SetLength(Result, Sz);
  {$IFDEF V_LONGSTRINGS}
  P:=Pointer(Result);
  {$ELSE}
  P:=@Result[1];
  {$ENDIF}
  for I:=0 to N - 1 do begin
    S:=Items[I];
    L:=Length(S);
    if L <> 0 then begin
      System.Move({$IFDEF V_LONGSTRINGS}Pointer(S)^{$ELSE}S[1]{$ENDIF}, P^, L);
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

procedure TStrLst.SetText(const AText: String);
var
  P, Limit, Start: PChar;
  S: String;
begin
  Clear;
  {$IFDEF V_LONGSTRINGS}
  P:=Pointer(AText);
  {$ELSE}
  P:=@AText[1];
  {$ENDIF}
  Limit:=P + Length(AText);
  while P < Limit do begin
    Start:=P;
    repeat
      if P^ in [#10, #13] then
        Break;
      Inc(P);
    until P >= Limit;
    SetString(S, Start, P - Start);
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

function TStrLst.GetCommaText2: String;
begin
  Result:=GetCommaText(True, ',', []);
end;

function TStrLst.GetCommaText1: String;
begin
  Result:=GetCommaText(False, ',', []);
end;

procedure TStrLst.SetCommaText2(const Value: String);
begin
  SetCommaText(Value, '"', [','], True);
end;

procedure TStrLst.SetCommaText1(const Value: String);
begin
  SetCommaText(Value, '''', [','], True);
end;

function TStrLst.GetLast: String;
begin
  Result:=GetItem(FCount - 1);
end;

procedure TStrLst.SetLast(Value: String);
begin
  SetItem(FCount - 1, Value);
end;

function TStrLst.CreateCompatibleVector: TPointerVector;
begin
  Result:=TStrLst.Create;
end;

destructor TStrLst.Destroy;
begin
  ClearItems(0);
  inherited Destroy;
end;

procedure TStrLst.WriteToStream(VStream: TVStream);
var
  I: Integer;
begin
  VStream.WriteInt32(FCount);
  for I:=0 to FCount - 1 do
    VStream.WriteString(Items[I]);
end;

procedure TStrLst.ReadFromStream(VStream: TVStream);
var
  I: Integer;
begin
  Clear;
  for I:=0 to VStream.ReadInt32 - 1 do
    Add(VStream.ReadString);
end;

procedure TStrLst.WriteToTextStream(TextStream: TTextStream);
var
  I: Integer;
begin
  for I:=0 to FCount - 1 do
    TextStream.WriteString(Items[I]);
end;

procedure TStrLst.ReadFromTextStream(TextStream: TTextStream);
begin
  Clear;
  while not TextStream.Eof do
    Add(TextStream.ReadString);
end;

procedure TStrLst.Delete(I: Integer);
begin
  Items[I]:='';
  inherited Delete(I);
end;

procedure TStrLst.DeleteRange(I, ACount: Integer);
var
  J: Integer;
begin
  for J:=I to I + ACount - 1 do
    Items[J]:='';
  inherited DeleteRange(I, ACount);
end;

procedure TStrLst.GetUntyped(I: Integer; var Result);
begin
  PVString(Result):=inherited GetValue(I);
end;

procedure TStrLst.SetUntyped(I: Integer; const Value);
begin
  Items[I]:=PVString(Value)^;
end;

class function TStrLst.CompareStrings(const S1, S2: String): Int32;
begin
  {$IFDEF WIN32} { for efficiency }
  Result:=CompareString(LOCALE_USER_DEFAULT, NORM_IGNORECASE, PChar(S1),
    Length(S1), PChar(S2), Length(S2)) - 2;
  {$ELSE}
  Result:=AnsiCompareText(S1, S2);
  {$ENDIF}
end;

function TStrLst.Compare(I: Integer; const V): Int32;
var
  S: String;
begin
  if PVString(V) <> nil then
    S:=PVString(V)^
  else
    S:='';
  Result:=CompareStrings(Items[I], S);
end;

procedure TStrLst.SetToDefault;
begin
  ClearItems(0);
end;

procedure TStrLst.SetItems(Values: array of String);
var
  I: Integer;
begin
  Count:=High(Values) + 1;
  for I:=0 to High(Values) do
    Items[I]:=Values[I];
end;

procedure TStrLst.Insert(I: Integer; const Value: String);
begin
  inherited Insert(I, nil);
  PPointerArray(FItems)^[I]:=NewVStr(Value);
end;

function TStrLst.Add(const Value: String): Integer;
begin
  Result:=Count;
  Insert(Result, Value);
end;

procedure TStrLst.Move(CurIndex, NewIndex: Integer);
var
  T: String;
begin
  if CurIndex <> NewIndex then begin
    T:=Items[CurIndex];
    Delete(CurIndex);
    Insert(NewIndex, T);
  end;
end;

function TStrLst.IndexFrom(I: Integer; const Value: String): Integer;
var
  ACount: Integer;
  P: PVString;
begin
  Result:=I;
  ACount:=Count;
  P:=@Value;
  while Result < ACount do begin
    if Compare(Result, P) = 0 then
      Exit;
    Inc(Result);
  end;
  Result:=-1;
end;

function TStrLst.IndexOf(const Value: String): Integer;
begin
  Result:=IndexFrom(0, Value);
end;

function TStrLst.LastIndexFrom(I: Integer; const Value: String): Integer;
var
  P: PVString;
begin
  P:=@Value;
  Result:=I;
  while Result >= 0 do begin
    if Compare(Result, P) = 0 then
      Exit;
    Dec(Result);
  end;
end;

function TStrLst.LastIndexOf(const Value: String): Integer;
begin
  Result:=LastIndexFrom(Count - 1, Value);
end;

function TStrLst.Remove(const Value: String): Integer;
begin
  Result:=IndexOf(Value);
  if Result >= 0 then
    Delete(Result);
end;

function TStrLst.RemoveLast(const Value: String): Integer;
begin
  Result:=LastIndexOf(Value);
  if Result >= 0 then
    Delete(Result);
end;

function TStrLst.RemoveFrom(I: Integer; const Value: String): Integer;
begin
  Result:=IndexFrom(I, Value);
  if Result >= 0 then
    Delete(Result);
end;

function TStrLst.RemoveLastFrom(I: Integer; const Value: String): Integer;
begin
  Result:=LastIndexFrom(I, Value);
  if Result >= 0 then
    Delete(Result);
end;

function TStrLst.NumberOfValues(const Value: String): Integer;
var
  I: Integer;
  P: PVString;
begin
  P:=@Value;
  Result:=0;
  for I:=0 to Count - 1 do
    if Compare(I, P) = 0 then
      Inc(Result);
end;

function TStrLst.FindInsertPosition(const Value: String; L, H: Integer;
  var Index: Integer): Bool;
var
  I, C: Integer;
  P: PVString;
begin
  Result:=False;
  P:=@Value;
  while L <= H do begin
    I:=(L + H) div 2;
    C:=Compare(I, P);
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

function TStrLst.Find(const Value: String; var Index: Integer): Bool;
begin
  Result:=FindInsertPosition(Value, 0, FCount - 1, Index);
end;

function TStrLst.FindInSortedRange(const Value: String; L, H: Integer): Integer;
begin
  if not FindInsertPosition(Value, L, H, Result) then
    Result:=-1;
end;

function TStrLst.FindInSorted(const Value: String): Integer;
begin
  if not FindInsertPosition(Value, 0, FCount - 1, Result) then
    Result:=-1;
end;

procedure TStrLst.Assign(Source: TVector);
var
  I: Integer;
begin
  if not (Source is TStrLst) then
    Error(SAssignError);
  Count:=Source.Count;
  for I:=0 to Count - 1 do
    Items[I]:=TStrLst(Source).Items[I];
end;

function TStrLst.EqualTo(V: TVector): Bool;
var
  I: Integer;
begin
  if not (V is TStrLst) then
    Error(SIncompatibleClasses);
  Result:=False;
  if FCount = V.Count then begin
    for I:=0 to FCount - 1 do
      if Compare(I, PPointerArray(TStrLst(V).FItems)^[I]) <> 0 then
        Exit;
    Result:=True;
  end;
end;

procedure TStrLst.AddStrings(List: TStrLst);
begin
  ConcatenateWith(List);
end;

function TStrLst.Pop: String;
var
  N: Integer;
begin
  N:=Count - 1;
  Result:=Items[N];
  Count:=N;
end;

procedure TStrLst.ConcatenateWith(V: TPointerVector);
var
  I: Integer;
begin
  if not (V is TStrLst) then
    Error(SIncompatibleClasses);
  for I:=0 to TStrLst(V).Count - 1 do
    Add(TStrLst(V).Items[I]);
end;

procedure TStrLst.FreeItems;
begin
  Error(SMethodNotApplicable);
end;

function TStrLst.GetCommaText(DoubleQuote: Bool; Delimiter: Char;
  DelimChars: TCharSet): String;
type
  TFunc = function (const S: String): String;
var
  I: Integer;
  S: String;
  Func1, Func2: TFunc;
begin
  if DoubleQuote then begin
    Func1:=TextToLiteral2;
    Func2:=StringToLiteral2;
  end
  else begin
    Func1:=TextToLiteral;
    Func2:=StringToLiteral;
  end;
  Include(DelimChars, Delimiter);
  Result:='';
  for I:=0 to Count - 1 do begin
    if I > 0 then
      Result:=Result + Delimiter;
    S:=Items[I];
    if ContainsChars(S, DelimChars) then
      S:=Func2(S)
    else
      S:=Func1(S);
    Result:=Result + S;
  end;
end;

procedure TStrLst.SetCommaText(const Value: String; QuoteChar: Char;
  const DelimChars: TCharSet; AddEmpty: Bool);
var
  I: Integer;
  Delim, Quote, Coming: Bool;
  C: Char;
  S: String;
begin
  Clear;
  S:='';
  Quote:=False;
  Coming:=False;
  for I:=1 to Length(Value) do begin
    C:=Value[I];
    Delim:=C in DelimChars;
    if  Quote or not Delim then begin
      if C = QuoteChar then
        Quote:=not Quote;
      S:=S + C;
      Coming:=True;
    end
    else begin
      S:=LiteralToString(S);
      if AddEmpty or (S <> '') then
        Add(S);
      S:='';
      Coming:=Delim;
    end;
  end;
  if Coming and (AddEmpty or (S <> '')) then
    Add(LiteralToString(S));
end;

function TStrLst.Equals(Strings: TStrLst): Bool;
begin
  Result:=EqualTo(Strings);
end;

procedure TStrLst.DebugWrite;
var
  I, N: Integer;
begin
  N:=FCount - 1;
  for I:=0 to N do begin
    write(Items[I]);
    if I < N then
      write(', ')
    else
      writeln;
  end;
end;

{ TASCIIStrLst }

function TASCIIStrLst.CreateCompatibleVector: TPointerVector;
begin
  Result:=TASCIIStrLst.Create;
end;

class function TASCIIStrLst.CompareStrings(const S1, S2: String): Int32;
begin
  Result:=CompareText(S1, S2);
end;

{ TCaseSensStrLst }

function TCaseSensStrLst.CreateCompatibleVector: TPointerVector;
begin
  Result:=TCaseSensStrLst.Create;
end;

class function TCaseSensStrLst.CompareStrings(const S1, S2: String): Int32;
begin
  {$IFDEF WIN32} { for efficiency }
  Result:=CompareString(LOCALE_USER_DEFAULT, 0, PChar(S1), Length(S1),
    PChar(S2), Length(S2)) - 2;
  {$ELSE}
  Result:=AnsiCompareStr(S1, S2);
  {$ENDIF}
end;

{ TExactStrLst }

function TExactStrLst.CreateCompatibleVector: TPointerVector;
begin
  Result:=TExactStrLst.Create;
end;

class function TExactStrLst.CompareStrings(const S1, S2: String): Int32;
begin
  Result:=CompareStr(S1, S2);
end;

{ TUserCompareStrLst }

procedure TUserCompareStrLst.Assign(Source: TVector);
begin
  inherited Assign(Source);
  if Source is TUserCompareStrLst then
    OnCompareStrings:=TUserCompareStrLst(Source).OnCompareStrings
  else if Source is TUserCompareStrLstObj then
    OnCompareStrings:=TUserCompareStrLstObj(Source).OnCompareStrings;
end;

function TUserCompareStrLst.Compare(I: Integer; const V): Int32;
var
  S: String;
begin
  if PVString(V) <> nil then
    S:=PVString(V)^
  else
    S:='';
  Result:=OnCompareStrings(Items[I], S);
end;

function TUserCompareStrLst.CreateCompatibleVector: TPointerVector;
begin
  Result:=TUserCompareStrLst.Create;
end;

{$IFDEF NOWARN}{$WARNINGS OFF}{$ENDIF}
class function TUserCompareStrLst.CompareStrings(const S1, S2: String): Int32;
begin
  Error(SMethodNotApplicable);
end;
{$IFDEF NOWARN}{$WARNINGS ON}{$ENDIF}

{ TSortedStrLst }

function TSortedStrLst.CreateCompatibleVector: TPointerVector;
begin
  Result:=TSortedStrLst.Create;
end;

procedure TSortedStrLst.Insert(I: Integer; const Value: String);
begin
  Error(SMethodNotApplicable);
end;

function TSortedStrLst.Add(const Value: String): Integer;
begin
  if FindInsertPosition(Value, 0, FCount - 1, Result) then
    Error(SDuplicateError)
  else
    inherited Insert(Result, Value);
end;

procedure TSortedStrLst.Move(CurIndex, NewIndex: Integer);
begin
  Error(SMethodNotApplicable);
end;

function TSortedStrLst.IndexFrom(I: Integer; const Value: String): Integer;
begin
  Result:=FindInSorted(Value);
end;

function TSortedStrLst.LastIndexFrom(I: Integer; const Value: String): Integer;
begin
  Result:=FindInSorted(Value);
end;

{ TASCIISortedStrLst }

function TASCIISortedStrLst.CreateCompatibleVector: TPointerVector;
begin
  Result:=TASCIISortedStrLst.Create;
end;

class function TASCIISortedStrLst.CompareStrings(const S1, S2: String): Int32;
begin
  Result:=TASCIIStrLst.CompareStrings(S1, S2);
end;

{ TCaseSensSortedStrLst }

function TCaseSensSortedStrLst.CreateCompatibleVector: TPointerVector;
begin
  Result:=TCaseSensSortedStrLst.Create;
end;

class function TCaseSensSortedStrLst.CompareStrings(const S1, S2: String): Int32;
begin
  Result:=TCaseSensStrLst.CompareStrings(S1, S2);
end;

{ TExactSortedStrLst }

function TExactSortedStrLst.CreateCompatibleVector: TPointerVector;
begin
  Result:=TExactSortedStrLst.Create;
end;

class function TExactSortedStrLst.CompareStrings(const S1, S2: String): Int32;
begin
  Result:=TExactStrLst.CompareStrings(S1, S2);
end;

{ TStrLstObj }

{$I StrObj.imp}

{ TASCIIStrLstObj }

function TASCIIStrLstObj.CreateCompatibleVector: TPointerVector;
begin
  Result:=TASCIIStrLstObj.Create;
end;

class function TASCIIStrLstObj.CompareStrings(const S1, S2: String): Int32;
begin
  Result:=TASCIIStrLst.CompareStrings(S1, S2);
end;

{ TCaseSensStrLstObj }

function TCaseSensStrLstObj.CreateCompatibleVector: TPointerVector;
begin
  Result:=TCaseSensStrLstObj.Create;
end;

class function TCaseSensStrLstObj.CompareStrings(const S1, S2: String): Int32;
begin
  Result:=TCaseSensStrLst.CompareStrings(S1, S2);
end;

{ TExactStrLstObj }

function TExactStrLstObj.CreateCompatibleVector: TPointerVector;
begin
  Result:=TExactStrLstObj.Create;
end;

class function TExactStrLstObj.CompareStrings(const S1, S2: String): Int32;
begin
  Result:=TExactStrLst.CompareStrings(S1, S2);
end;

{ TUserCompareStrLstObj }

procedure TUserCompareStrLstObj.Assign(Source: TVector);
begin
  inherited Assign(Source);
  if Source is TUserCompareStrLst then
    OnCompareStrings:=TUserCompareStrLst(Source).OnCompareStrings
  else if Source is TUserCompareStrLstObj then
    OnCompareStrings:=TUserCompareStrLstObj(Source).OnCompareStrings;
end;

function TUserCompareStrLstObj.Compare(I: Integer; const V): Int32;
var
  S: String;
begin
  if PVString(V) <> nil then
    S:=PVString(V)^
  else
    S:='';
  Result:=OnCompareStrings(Items[I], S);
end;

function TUserCompareStrLstObj.CreateCompatibleVector: TPointerVector;
begin
  Result:=TUserCompareStrLstObj.Create;
end;

{$IFDEF NOWARN}{$WARNINGS OFF}{$ENDIF}
class function TUserCompareStrLstObj.CompareStrings(const S1, S2: String): Int32;
begin
  Error(SMethodNotApplicable);
end;
{$IFDEF NOWARN}{$WARNINGS ON}{$ENDIF}

end.
