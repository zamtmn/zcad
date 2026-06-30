{*************************************************************************** }
{  fpdwg - DWG targeted handle logging (Issue #1203)                         }
{                                                                            }
{        Copyright (C) 2026 Andrey Zubarev <zamtmn@yandex.ru>                }
{                                                                            }
{  This library is free software, licensed under the terms of the GNU        }
{  General Public License as published by the Free Software Foundation,      }
{  either version 3 of the License, or (at your option) any later version.   }
{*************************************************************************** }

{ Issue #1203: targeted per-handle diagnostics for the DWG loader.

  Назначение модуля:
  ------------------
  При отладке DWG-загрузчика регулярно возникает ситуация, когда конкретный
  объект (MTEXT, LINE и т.д.), присутствующий в выходе внешней утилиты
  `dwgread`/LibreDWG, не появляется в готовом чертеже ZCAD. Без поэтапной
  трассировки конкретного handle невозможно понять, на какой именно фазе
  загрузки объект «теряется»: при сканировании, при диспетчеризации mapper'а,
  при разрешении ссылок или при привязке к владельцу.

  Этот модуль решает задачу точечного логирования: разработчик задаёт список
  интересующих handle'ов через константу DWG_TARGET_HANDLE_LIST
  (значения из dwgread JSON в десятичном формате либо hex с A-F/0x/$,
  через запятую), а вызовы
  TargetedLogXxx размещены в ключевых точках конвейера загрузки. Если handle
  не входит в список — функции являются no-op'ами (нулевая нагрузка на
  обычную загрузку).

  Пример настройки для отладки MTEXT 0xA325E и LINE 0xA08 / OWNER 0x9FC:
    DWG_TARGET_HANDLE_LIST = 'A325E,A08,9FC'

  Если handle скопирован из JSON dwgread как [0,3,668254], можно задавать
  десятичное значение напрямую:
    DWG_TARGET_HANDLE_LIST = '668254'

  Формат лога — единая строка в специализированном модуле programlog DWG,
  чтобы целевые сообщения можно было включать отдельно от обычной загрузки. }

unit uzedwgtargetedlog;

{$mode objfpc}{$H+}
{$modeswitch advancedrecords}

interface

uses
  SysUtils,
  uzedwgtypes;

const
  { Compile-time/default list of target handles. Keep empty for release builds.
    Значение — список чисел из dwgread JSON в десятичном формате либо hex с
    A-F/0x/$, разделённых запятыми, пробелами, точками с запятой или
    двоеточиями. }
  DWG_TARGET_HANDLE_LIST = '';

  { Верхний предел числа отслеживаемых handle'ов. Достаточно для типичной
    отладочной сессии и не даёт случайно «зацепить» весь чертёж, если
    пользователь подставил неверный список. }
  DWG_TARGET_HANDLES_LIMIT = 64;

type
  { Список целевых handle'ов. Хранится отсортированным массивом фиксированного
    размера: расход памяти константный, поиск двоичный. }
  TDWGTargetedHandleSet = record
  private
    FValues: array[0..DWG_TARGET_HANDLES_LIMIT - 1] of TDWGZCADHandle;
    FCount:  Integer;
    function FindIndex(AHandle: TDWGZCADHandle; out Index: Integer): Boolean;
  public
    { Очистка набора (используется при перечитывании константы). }
    procedure Clear;
    { Добавить handle. Дубликаты молча игнорируются; при переполнении возвращает
      False, чтобы вызывающая сторона могла увидеть факт усечения. }
    function Add(AHandle: TDWGZCADHandle): Boolean;
    { Проверка вхождения. Активный «горячий путь» в hook'ах загрузчика. }
    function Contains(AHandle: TDWGZCADHandle): Boolean;
    function Count: Integer;
    { Доступ к handle'у по индексу. Используется для вывода списка в лог. }
    function ValueAt(Index: Integer): TDWGZCADHandle;
  end;

{ Перечитать список целевых handle'ов из константы. Вызывается в начале
  каждого импорта; результат кэшируется до следующего вызова или до
  принудительного сброса через TargetedLogClear. }
procedure TargetedLogRefresh;

{ Принудительно сбросить кэш (на случай, если тесты проверяют разные списки
  между прогонами). }
procedure TargetedLogClear;

{ Проверка: интересен ли данный handle разработчику. Возвращает False, если
  набор пуст (это и есть штатный режим работы загрузчика). }
function TargetedLogIsActive: Boolean;
function TargetedLogHandle(AHandle: TDWGZCADHandle): Boolean;

{ Базовая операция записи: если handle входит в целевой набор — печатает
  заранее форматированную строку через DWG-модуль programlog с LM_Info.
  Phase — короткий ярлык точки кода ('scan', 'register', 'parse', 'attach',
  'attach-ref'), Details — произвольный текст с конкретикой места.

  Несколько перегрузок упрощают вызов: разработчику не нужно собирать
  format-строку на месте, можно сразу передать handle + текст. }
procedure TargetedLog(const Phase: string; AHandle: TDWGZCADHandle;
  const Details: string);

{ То же, но с дополнительным owner-handle для пары «сущность → владелец»;
  срабатывает, если в целевом наборе есть хотя бы один из двух handle'ов. }
procedure TargetedLogPair(const Phase: string; AEntity, AOwner: TDWGZCADHandle;
  const Details: string);

{ Парсинг одного hex-токена и списка handle'ов. Список дополнительно принимает
  десятичные значения из dwgread JSON. Функции выведены в interface специально
  ради юнит-тестов: проверять парсер напрямую проще, чем менять
  compile-time константу под отдельные тестовые случаи. }
function TargetedLogParseHexHandle(const Token: string;
  out Value: TDWGZCADHandle): Boolean;
procedure TargetedLogParseTargetList(const Raw: string;
  var Target: TDWGTargetedHandleSet);

implementation

uses
  uzedwglog;

var
  { Кэш списка целевых handle'ов. Все обращения идут через TargetedLogHandle,
    которая на первый вызов запрашивает обновление из константы. }
  TargetSet:           TDWGTargetedHandleSet;
  TargetSetInitialized: Boolean = False;

{ ---------- TDWGTargetedHandleSet ---------- }

function TDWGTargetedHandleSet.FindIndex(AHandle: TDWGZCADHandle;
  out Index: Integer): Boolean;
var
  Lo, Hi, Mid: Integer;
begin
  Lo := 0;
  Hi := FCount - 1;
  while Lo <= Hi do begin
    Mid := (Lo + Hi) shr 1;
    if FValues[Mid] = AHandle then begin
      Index := Mid;
      Exit(True);
    end;
    if FValues[Mid] < AHandle then
      Lo := Mid + 1
    else
      Hi := Mid - 1;
  end;
  Index := Lo;
  Result := False;
end;

procedure TDWGTargetedHandleSet.Clear;
begin
  FCount := 0;
end;

function TDWGTargetedHandleSet.Add(AHandle: TDWGZCADHandle): Boolean;
var
  Index, I: Integer;
begin
  if AHandle = 0 then
    Exit(False);
  if FindIndex(AHandle, Index) then
    Exit(True);
  if FCount >= DWG_TARGET_HANDLES_LIMIT then
    Exit(False);
  for I := FCount downto Index + 1 do
    FValues[I] := FValues[I - 1];
  FValues[Index] := AHandle;
  Inc(FCount);
  Result := True;
end;

function TDWGTargetedHandleSet.Contains(AHandle: TDWGZCADHandle): Boolean;
var
  Index: Integer;
begin
  Result := FindIndex(AHandle, Index);
end;

function TDWGTargetedHandleSet.Count: Integer;
begin
  Result := FCount;
end;

function TDWGTargetedHandleSet.ValueAt(Index: Integer): TDWGZCADHandle;
begin
  if (Index < 0) or (Index >= FCount) then
    Exit(0);
  Result := FValues[Index];
end;

{ ---------- Парсер списка handle'ов ---------- }

{ Проверка одного символа на принадлежность шестнадцатеричной цифре.
  Используется парсером, чтобы аккуратно отделять токены от разделителей. }
function IsHexDigit(C: Char): Boolean;
begin
  Result := ((C >= '0') and (C <= '9'))
         or ((C >= 'a') and (C <= 'f'))
         or ((C >= 'A') and (C <= 'F'));
end;

{ Преобразование строки в QWord с шестнадцатеричным основанием. Поддерживает
  префиксы '0x' и '$', а также допускает обычные hex-числа без префикса.
  При ошибке возвращает False — целевое значение остаётся неизменным. }
function TryParseHexHandle(const Token: string; out Value: TDWGZCADHandle
  ): Boolean;
var
  Trimmed: string;
  I:       Integer;
  Acc:     QWord;
  Digit:   Integer;
begin
  Result := False;
  Trimmed := Trim(Token);
  if Trimmed = '' then
    Exit;
  if (Length(Trimmed) >= 2) and (Trimmed[1] = '0')
     and ((Trimmed[2] = 'x') or (Trimmed[2] = 'X')) then
    Delete(Trimmed, 1, 2)
  else if (Length(Trimmed) >= 1) and (Trimmed[1] = '$') then
    Delete(Trimmed, 1, 1);
  if Trimmed = '' then
    Exit;
  Acc := 0;
  for I := 1 to Length(Trimmed) do begin
    if not IsHexDigit(Trimmed[I]) then
      Exit;
    case Trimmed[I] of
      '0'..'9': Digit := Ord(Trimmed[I]) - Ord('0');
      'a'..'f': Digit := Ord(Trimmed[I]) - Ord('a') + 10;
      'A'..'F': Digit := Ord(Trimmed[I]) - Ord('A') + 10;
    else
      Digit := 0;
    end;
    Acc := (Acc shl 4) or QWord(Digit);
  end;
  Value := Acc;
  Result := True;
end;

function TokenHasExplicitHexPrefix(const Token: string): Boolean;
var
  Trimmed: string;
begin
  Trimmed := Trim(Token);
  Result := ((Length(Trimmed) >= 2) and (Trimmed[1] = '0') and
             ((Trimmed[2] = 'x') or (Trimmed[2] = 'X')))
         or ((Length(Trimmed) >= 1) and (Trimmed[1] = '$'));
end;

function TokenHasHexLetter(const Token: string): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 1 to Length(Token) do
    if ((Token[I] >= 'a') and (Token[I] <= 'f')) or
       ((Token[I] >= 'A') and (Token[I] <= 'F')) then
      Exit(True);
end;

function TryParseDecimalHandle(const Token: string; out Value: TDWGZCADHandle
  ): Boolean;
var
  Trimmed: string;
  I:       Integer;
  Acc:     QWord;
  Digit:   Integer;
begin
  Result := False;
  Trimmed := Trim(Token);
  if Trimmed = '' then
    Exit;
  Acc := 0;
  for I := 1 to Length(Trimmed) do begin
    if (Trimmed[I] < '0') or (Trimmed[I] > '9') then
      Exit;
    Digit := Ord(Trimmed[I]) - Ord('0');
    if Acc > (High(QWord) - QWord(Digit)) div 10 then
      Exit;
    Acc := Acc * 10 + QWord(Digit);
  end;
  Value := Acc;
  Result := True;
end;

function TryParseTargetHandle(const Token: string; out Value: TDWGZCADHandle
  ): Boolean;
begin
  if TokenHasExplicitHexPrefix(Token) or TokenHasHexLetter(Token) then
    Result := TryParseHexHandle(Token, Value)
  else
    Result := TryParseDecimalHandle(Token, Value);
end;

{ Разобрать список целевых handle'ов из строки. Разделители: запятая, пробел,
  точка с запятой, двоеточие. Голые числа читаются как десятичные значения из
  JSON dwgread; hex можно задавать через A-F или префиксы 0x/$.
  Некорректные токены пропускаются без шумной диагностики — разработчик
  увидит реальный эффект (или его отсутствие) по факту работы загрузчика. }
procedure ParseTargetList(const Raw: string; var Target: TDWGTargetedHandleSet);
var
  I:      Integer;
  Token:  string;
  Handle: TDWGZCADHandle;

  procedure FlushToken;
  begin
    if Token = '' then
      Exit;
    if TryParseTargetHandle(Token, Handle) then
      Target.Add(Handle);
    Token := '';
  end;

begin
  Token := '';
  for I := 1 to Length(Raw) do begin
    case Raw[I] of
      ',', ';', ':', ' ', #9, #10, #13:
        FlushToken;
    else
      Token := Token + Raw[I];
    end;
  end;
  FlushToken;
end;

{ ---------- Внешний API ---------- }

function TargetedLogParseHexHandle(const Token: string;
  out Value: TDWGZCADHandle): Boolean;
begin
  Result := TryParseHexHandle(Token, Value);
end;

procedure TargetedLogParseTargetList(const Raw: string;
  var Target: TDWGTargetedHandleSet);
begin
  ParseTargetList(Raw, Target);
end;

procedure TargetedLogRefresh;
var
  Raw: string;
  I: Integer;
begin
  TargetSet.Clear;
  Raw := DWG_TARGET_HANDLE_LIST;
  if Raw <> '' then
    ParseTargetList(Raw, TargetSet);
  TargetSetInitialized := True;
  if TargetSet.Count > 0 then begin
    DWGLogInfoFormatStr(
      'uzedwgtargetedlog: tracking %d DWG handle(s) from DWG_TARGET_HANDLE_LIST=''%s''',
      [TargetSet.Count, Raw]);
    for I := 0 to TargetSet.Count - 1 do
      DWGLogInfoFormatStr(
        'uzedwgtargetedlog:   [%d] handle=%s',
        [I, DWGHandleLogText(TargetSet.ValueAt(I))]);
  end;
end;

procedure TargetedLogClear;
begin
  TargetSet.Clear;
  TargetSetInitialized := False;
end;

function TargetedLogIsActive: Boolean;
begin
  if not TargetSetInitialized then
    TargetedLogRefresh;
  Result := TargetSet.Count > 0;
end;

function TargetedLogHandle(AHandle: TDWGZCADHandle): Boolean;
begin
  if not TargetSetInitialized then
    TargetedLogRefresh;
  if TargetSet.Count = 0 then
    Exit(False);
  Result := TargetSet.Contains(AHandle);
end;

procedure TargetedLog(const Phase: string; AHandle: TDWGZCADHandle;
  const Details: string);
begin
  if not TargetedLogHandle(AHandle) then
    Exit;
  DWGLogInfoFormatStr(
    'uzedwgtargetedlog [%s] handle=%s %s',
    [Phase, DWGHandleLogText(AHandle), Details]);
end;

procedure TargetedLogPair(const Phase: string; AEntity, AOwner: TDWGZCADHandle;
  const Details: string);
var
  IsEntityTarget, IsOwnerTarget: Boolean;
begin
  if not TargetedLogIsActive then
    Exit;
  IsEntityTarget := (AEntity <> 0) and TargetSet.Contains(AEntity);
  IsOwnerTarget  := (AOwner  <> 0) and TargetSet.Contains(AOwner);
  if not (IsEntityTarget or IsOwnerTarget) then
    Exit;
  DWGLogInfoFormatStr(
    'uzedwgtargetedlog [%s] entity=%s owner=%s %s',
    [Phase, DWGHandleLogText(AEntity), DWGHandleLogText(AOwner), Details]);
end;

initialization
  TargetSet.Clear;
end.
