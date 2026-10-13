{
*****************************************************************************
*                                                                           *
*  This file is part of the ZCAD                                            *
*                                                                           *
*  See the file COPYING.txt, included in this distribution,                 *
*  for details about the copyright.                                         *
*                                                                           *
*  This program is distributed in the hope that it will be useful,          *
*  but WITHOUT ANY WARRANTY; without even the implied warranty of           *
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                     *
*                                                                           *
*****************************************************************************
}
{
  Модуль: uzeffdxfobjects
  Назначение: лёгкий разборщик секции OBJECTS DXF-файла в список «сырых
  объектов» TZDXFRawObject (этап 1 ТЗ
  cad_source/zengine/TZ_NOD_NamedObjectDictionary.md).

  Модуль не содержит предметной логики: он только делит секцию на объекты
  по группе 0 и выделяет общие для всех объектов поля — тип (0), хэндл (5),
  владельца (330 вне блоков 102), реакторы (блок 102 ACAD_REACTORS)
  и расширенный словарь (360 в блоке 102 ACAD_XDICTIONARY). Все пары
  объекта сохраняются в исходном порядке без изменений (нужны для
  round-trip неизвестных объектов).

  Разбор идёт одним проходом по тексту, без TStringList. Поддерживаются
  переводы строк \r\n и \n, пробелы вокруг кодов групп.
}
unit uzeffdxfobjects;
{$Mode delphi}{$H+}
{$INCLUDE zengineconfig.inc}
interface

uses
  SysUtils,
  Generics.Collections,
  uzeTypes;

const
  { Имя блока реакторов в группе 102 }
  CDXFReactorsBlockName = 'ACAD_REACTORS';
  { Имя блока расширенного словаря в группе 102 }
  CDXFXDictionaryBlockName = 'ACAD_XDICTIONARY';

type
  { Одна пара «код группы / значение» DXF.
    Value хранится как в файле (без символов перевода строки). }
  TZDXFGroupPair = record
    Code: Integer;
    Value: string;
  end;
  TZDXFGroupPairs = array of TZDXFGroupPair;

  TZDXFHandleArray = array of TDWGHandle;

  { Один объект секции OBJECTS. }
  TZDXFRawObject = class
  public
    { Значение группы 0 (DICTIONARY, TABLESTYLE, XRECORD, …) }
    ObjType: string;
    { Группа 5 (0, если группы нет или значение некорректно) }
    Handle: TDWGHandle;
    { Группа 330 вне блоков 102 (владелец). 0 — у корневого словаря
      (330=0) или если группы нет, см. HasOwnerGroup. }
    OwnerHandle: TDWGHandle;
    { Была ли у объекта группа 330 владельца }
    HasOwnerGroup: Boolean;
    { Хэндлы 330 из блока 102 ACAD_REACTORS }
    Reactors: TZDXFHandleArray;
    { Хэндл 360 из блока 102 ACAD_XDICTIONARY (0 — нет) }
    XDictHandle: TDWGHandle;
    { Все пары объекта после группы 0 в исходном порядке (сама группа 0
      не входит — её значение в ObjType) }
    Pairs: TZDXFGroupPairs;
    { Количество используемых элементов Pairs }
    PairCount: Integer;
    { Номер строки (с 1) группы 0 объекта во входном тексте }
    LineNumber: Integer;

    procedure AddPair(ACode: Integer; const AValue: string);
    { Хэндл в виде строки DXF (верхний регистр, без ведущих нулей) }
    function HandleStr: string;
    { Индекс первой пары с кодом ACode начиная с AFrom, -1 — нет }
    function IndexOfCode(ACode: Integer; AFrom: Integer = 0): Integer;
    { Значение первой пары с кодом ACode (Trim), ADefault — если нет }
    function ValueOf(ACode: Integer; const ADefault: string = ''): string;
  end;

  TZDXFRawObjectList = TObjectList<TZDXFRawObject>;

{ Нормализует строковый DXF-хэндл так же, как NormalizeHandle в uzeffdxf:
  верхний регистр, без пробелов и ведущих нулей ('00AB' → 'AB', '0' → '0'). }
function NormalizeDXFHandleStr(const S: string): string;
{ Разбирает строковый DXF-хэндл (шестнадцатеричный). Пустая строка
  и некорректные символы — False, AHandle = 0. }
function TryDXFStrToHandle(const S: string; out AHandle: TDWGHandle): Boolean;
{ Хэндл в строку DXF: шестнадцатеричный, верхний регистр, без ведущих нулей. }
function DXFHandleToStr(AHandle: TDWGHandle): string;

{ Разбирает текст секции OBJECTS в список AObjects (список очищается).
  AText — либо полный текст секции (0/SECTION, 2/OBJECTS … 0/ENDSEC, как
  RawObjectsSection), либо только объекты секции. Разбор прекращается на
  0/ENDSEC или 0/EOF.
  Возвращает False при нарушении структуры (код группы — не число, пара
  без значения); AError — описание с номером строки, в AObjects остаются
  объекты, разобранные до ошибки. }
function ParseDxfObjectsSection(const AText: string;
  AObjects: TZDXFRawObjectList; out AError: string): Boolean;

implementation

uses
  uzeffdxfnodlog;

function NormalizeDXFHandleStr(const S: string): string;
var
  I: Integer;
begin
  Result := UpperCase(Trim(S));
  I := 1;
  while (I < Length(Result)) and (Result[I] = '0') do
    Inc(I);
  if I > 1 then
    Result := Copy(Result, I, Length(Result) - I + 1);
end;

function TryDXFStrToHandle(const S: string; out AHandle: TDWGHandle): Boolean;
var
  H: string;
  I: Integer;
  D: Integer;
begin
  AHandle := 0;
  H := NormalizeDXFHandleStr(S);
  { Хэндл DXF — не более 16 шестнадцатеричных цифр (QWord) }
  if (H = '') or (Length(H) > 16) then
    Exit(False);
  for I := 1 to Length(H) do begin
    case H[I] of
      '0'..'9': D := Ord(H[I]) - Ord('0');
      'A'..'F': D := Ord(H[I]) - Ord('A') + 10;
    else
      AHandle := 0;
      Exit(False);
    end;
    AHandle := (AHandle shl 4) or TDWGHandle(D);
  end;
  Result := True;
end;

function DXFHandleToStr(AHandle: TDWGHandle): string;
begin
  Result := IntToHex(AHandle, 1);
end;

{ TZDXFRawObject }

procedure TZDXFRawObject.AddPair(ACode: Integer; const AValue: string);
begin
  if PairCount >= Length(Pairs) then
    if Length(Pairs) < 8 then
      SetLength(Pairs, 8)
    else
      SetLength(Pairs, Length(Pairs) * 2);
  Pairs[PairCount].Code := ACode;
  Pairs[PairCount].Value := AValue;
  Inc(PairCount);
end;

function TZDXFRawObject.HandleStr: string;
begin
  Result := DXFHandleToStr(Handle);
end;

function TZDXFRawObject.IndexOfCode(ACode: Integer; AFrom: Integer): Integer;
var
  I: Integer;
begin
  if AFrom < 0 then
    AFrom := 0;
  for I := AFrom to PairCount - 1 do
    if Pairs[I].Code = ACode then
      Exit(I);
  Result := -1;
end;

function TZDXFRawObject.ValueOf(ACode: Integer; const ADefault: string): string;
var
  I: Integer;
begin
  I := IndexOfCode(ACode);
  if I >= 0 then
    Result := Trim(Pairs[I].Value)
  else
    Result := ADefault;
end;

{ Чтение текста по строкам }

type
  TZDXFTextCursor = record
    Text: string;
    Pos: Integer;
    Len: Integer;
    { Номер последней прочитанной строки (с 1) }
    LineNo: Integer;
  end;

{ Находит очередную строку: AStart..AStop-1 (без \r\n / \n), курсор
  переходит на следующую строку. False — конец текста. }
function NextLine(var C: TZDXFTextCursor; out AStart, AStop: Integer): Boolean;
begin
  AStart := C.Pos;
  AStop := C.Pos;
  if C.Pos > C.Len then
    Exit(False);
  while (C.Pos <= C.Len) and (C.Text[C.Pos] <> #10) and (C.Text[C.Pos] <> #13) do
    Inc(C.Pos);
  AStop := C.Pos;
  { Перевод строки: \r\n, \n или одиночный \r }
  if C.Pos <= C.Len then begin
    if C.Text[C.Pos] = #13 then begin
      Inc(C.Pos);
      if (C.Pos <= C.Len) and (C.Text[C.Pos] = #10) then
        Inc(C.Pos);
    end else
      Inc(C.Pos);
  end;
  Inc(C.LineNo);
  Result := True;
end;

{ Читает очередную строку (без \r\n / \n). False — конец текста. }
function ReadLine(var C: TZDXFTextCursor; out ALine: string): Boolean;
var
  Start, Stop: Integer;
begin
  Result := NextLine(C, Start, Stop);
  ALine := Copy(C.Text, Start, Stop - Start);
end;

{ Быстрый разбор кода группы без выделения строки: необязательный минус и
  не более 9 цифр, по краям — пробельные символы (как у Trim). Для всего
  остального — False, и код разбирается TryStrToInt (та же семантика, что
  до оптимизации). }
function TryFastGroupCode(const C: TZDXFTextCursor; AStart, AStop: Integer;
  out ACode: Integer): Boolean;
var
  Neg: Boolean;
  Digits: Integer;
begin
  ACode := 0;
  while (AStart < AStop) and (C.Text[AStart] <= ' ') do
    Inc(AStart);
  while (AStop > AStart) and (C.Text[AStop - 1] <= ' ') do
    Dec(AStop);
  Neg := (AStart < AStop) and (C.Text[AStart] = '-');
  if Neg then
    Inc(AStart);
  Digits := AStop - AStart;
  if (Digits < 1) or (Digits > 9) then
    Exit(False);
  while AStart < AStop do begin
    if (C.Text[AStart] < '0') or (C.Text[AStart] > '9') then
      Exit(False);
    ACode := ACode * 10 + (Ord(C.Text[AStart]) - Ord('0'));
    Inc(AStart);
  end;
  if Neg then
    ACode := -ACode;
  Result := True;
end;

type
  TZDXFPairReadResult = (prOk, prEnd, prError);

{ Читает пару код/значение. Пустые строки перед кодом группы (например,
  перевод строки в конце текста) пропускаются. }
function ReadPair(var C: TZDXFTextCursor; out ACode: Integer;
  out AValue: string; out AError: string): TZDXFPairReadResult;
var
  CodeLine: string;
  Start, Stop: Integer;
begin
  ACode := 0;
  AValue := '';
  AError := '';
  repeat
    if not NextLine(C, Start, Stop) then
      Exit(prEnd);
    while (Start < Stop) and (C.Text[Start] <= ' ') do
      Inc(Start);
  until Start < Stop;
  if not TryFastGroupCode(C, Start, Stop, ACode) then begin
    CodeLine := Trim(Copy(C.Text, Start, Stop - Start));
    if not TryStrToInt(CodeLine, ACode) then begin
      AError := Format('line %d: invalid group code "%s"', [C.LineNo, CodeLine]);
      Exit(prError);
    end;
  end;
  if not ReadLine(C, AValue) then begin
    AError := Format('line %d: group code %d without value', [C.LineNo, ACode]);
    Exit(prError);
  end;
  Result := prOk;
end;

{ Заполняет общие поля объекта (хэндл, владелец, реакторы, xdictionary)
  по его парам.
  Блоки 102 (открывающая и закрывающая скобки) отслеживаются в любом месте объекта, но реакторы,
  xdictionary и владелец берутся только до первой группы 100 (маркер
  подкласса): по DXF Reference они идут в заголовке объекта, а после 100
  начинаются данные, в которых те же коды (330, 360, 102) могут означать
  другое — например, хэндлы продолжений ACAD_TABLE в XRECORD. }
procedure FillCommonFields(AObj: TZDXFRawObject);
var
  I: Integer;
  Code: Integer;
  Value, BlockName: string;
  InBlock, SubclassSeen, HandleSeen: Boolean;
  H: TDWGHandle;
begin
  InBlock := False;
  BlockName := '';
  SubclassSeen := False;
  HandleSeen := False;
  for I := 0 to AObj.PairCount - 1 do begin
    Code := AObj.Pairs[I].Code;
    { Значение нужно только для кодов заголовка объекта: у больших объектов
      (ACAD_TABLE/TABLECONTENT — сотни тысяч пар) лишний Trim заметен }
    case Code of
      5, 102, 330, 360:
        Value := Trim(AObj.Pairs[I].Value);
    else
      if not InBlock then
        if Code = 100 then
          SubclassSeen := True;
      Continue;
    end;
    if Code = 102 then begin
      if (Value <> '') and (Value[1] = '{') then begin
        if InBlock then
          NODLogTraceFormatStr(
            'uzeffdxfobjects: object %s (line %d): block "%s" is not closed before "%s"',
            [AObj.HandleStr, AObj.LineNumber, BlockName, Value]);
        InBlock := True;
        BlockName := UpperCase(Trim(Copy(Value, 2, Length(Value) - 1)));
      end else if Value = '}' then begin
        InBlock := False;
        BlockName := '';
      end;
      Continue;
    end;
    if InBlock then begin
      if not SubclassSeen then
        if (Code = 330) and (BlockName = CDXFReactorsBlockName) then begin
          if TryDXFStrToHandle(Value, H) then begin
            SetLength(AObj.Reactors, Length(AObj.Reactors) + 1);
            AObj.Reactors[High(AObj.Reactors)] := H;
          end;
        end else if (Code = 360) and (BlockName = CDXFXDictionaryBlockName) then
          TryDXFStrToHandle(Value, AObj.XDictHandle);
      Continue;
    end;
    case Code of
      5:
        if not HandleSeen then begin
          HandleSeen := True;
          if not TryDXFStrToHandle(Value, AObj.Handle) then
            NODLogTraceFormatStr(
              'uzeffdxfobjects: object %s (line %d): invalid handle "%s"',
              [AObj.ObjType, AObj.LineNumber, Value]);
        end;
      100:
        SubclassSeen := True;
      330:
        if (not SubclassSeen) and (not AObj.HasOwnerGroup) then begin
          AObj.HasOwnerGroup := True;
          TryDXFStrToHandle(Value, AObj.OwnerHandle);
        end;
    end;
  end;
end;

function ParseDxfObjectsSection(const AText: string;
  AObjects: TZDXFRawObjectList; out AError: string): Boolean;
var
  C: TZDXFTextCursor;
  Code: Integer;
  Value, UValue: string;
  Obj: TZDXFRawObject;
  R: TZDXFPairReadResult;
  ExpectSectionName: Boolean;
begin
  AError := '';
  AObjects.Clear;
  C.Text := AText;
  C.Pos := 1;
  C.Len := Length(AText);
  C.LineNo := 0;
  { Пропуск UTF-8 BOM, если текст взят из файла целиком }
  if (C.Len >= 3) and (AText[1] = #$EF) and (AText[2] = #$BB) and (AText[3] = #$BF) then
    C.Pos := 4;
  Obj := nil;
  ExpectSectionName := False;
  Result := True;
  while True do begin
    R := ReadPair(C, Code, Value, AError);
    if R = prEnd then
      Break;
    if R = prError then begin
      Result := False;
      Break;
    end;
    if ExpectSectionName then begin
      { Пара 2/OBJECTS после 0/SECTION }
      ExpectSectionName := False;
      if Code = 2 then
        Continue;
    end;
    if Code = 0 then begin
      if Obj <> nil then begin
        FillCommonFields(Obj);
        Obj := nil;
      end;
      UValue := UpperCase(Trim(Value));
      if (UValue = 'ENDSEC') or (UValue = 'EOF') then
        Break;
      if UValue = 'SECTION' then begin
        ExpectSectionName := True;
        Continue;
      end;
      Obj := TZDXFRawObject.Create;
      Obj.ObjType := Trim(Value);
      Obj.LineNumber := C.LineNo - 1;
      AObjects.Add(Obj);
    end else if Obj <> nil then
      Obj.AddPair(Code, Value);
    { Пары вне объекта (например, заголовок секции) пропускаются }
  end;
  if Obj <> nil then
    FillCommonFields(Obj);
end;

end.
