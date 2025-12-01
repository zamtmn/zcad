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
@author(Vladimir Bobrov)
}

{
  Модуль: uzvshxtopdfcmapmapping
  Назначение: Таблицы маппинга SHX кодов на Unicode

  Данный модуль содержит:
  - Встроенные таблицы соответствия SHX -> Unicode
  - Функции преобразования кодов символов
  - Поддержка латиницы, кириллицы, цифр и спецсимволов

  Поддерживаемые кодировки:
  - ASCII (0x20-0x7F) -> Unicode прямой маппинг
  - Windows-1251 (кириллица) -> Unicode кириллица
  - Code page 866 (DOS кириллица) -> Unicode кириллица

  Зависимости:
  - uzvshxtopdfcmaptypes: типы данных этапа 5

  Module: uzvshxtopdfcmapmapping
  Purpose: SHX code to Unicode mapping tables

  This module contains:
  - Built-in SHX -> Unicode mapping tables
  - Character code conversion functions
  - Support for Latin, Cyrillic, digits and special characters

  Supported encodings:
  - ASCII (0x20-0x7F) -> Unicode direct mapping
  - Windows-1251 (Cyrillic) -> Unicode Cyrillic
  - Code page 866 (DOS Cyrillic) -> Unicode Cyrillic

  Dependencies:
  - uzvshxtopdfcmaptypes: Stage 5 data types
}

unit uzvshxtopdfcmapmapping;

{$mode objfpc}{$H+}

interface

uses
  SysUtils,
  uzvshxtopdfcmaptypes;

type
  // Тип локали для выбора таблицы маппинга
  // Locale type for mapping table selection
  TUzvMappingLocale = (
    mlAscii,        // Стандартный ASCII (0x20-0x7F)
    mlWindows1251,  // Windows-1251 кириллица
    mlCP866,        // DOS Code Page 866 кириллица
    mlAuto          // Автоопределение / Auto-detect
  );

// Получить Unicode код для SHX кода символа
// Get Unicode code for SHX character code
function GetUnicodeForSHXCode(
  CharCode: Integer;
  Locale: TUzvMappingLocale = mlAuto
): Integer;

// Построить массив маппингов для диапазона кодов
// Build mapping array for code range
function BuildMappingArray(
  FirstChar, LastChar: Integer;
  Locale: TUzvMappingLocale = mlAuto
): TUzvUnicodeMappingArray;

// Построить массив маппингов для списка кодов
// Build mapping array for code list
function BuildMappingArrayFromCodes(
  const CharCodes: array of Integer;
  Locale: TUzvMappingLocale = mlAuto
): TUzvUnicodeMappingArray;

// Проверить, является ли код ASCII
// Check if code is ASCII
function IsAsciiCode(CharCode: Integer): Boolean;

// Проверить, является ли код кириллическим (Windows-1251)
// Check if code is Cyrillic (Windows-1251)
function IsCyrillicWindows1251(CharCode: Integer): Boolean;

// Проверить, является ли код кириллическим (CP866)
// Check if code is Cyrillic (CP866)
function IsCyrillicCP866(CharCode: Integer): Boolean;

// Автоопределение локали по коду символа
// Auto-detect locale by character code
function DetectLocale(CharCode: Integer): TUzvMappingLocale;

// Получить описание локали
// Get locale description
function GetLocaleDescription(Locale: TUzvMappingLocale): AnsiString;

implementation

const
  // Диапазон ASCII символов
  // ASCII character range
  ASCII_FIRST = $20;    // Пробел / Space
  ASCII_LAST = $7E;     // Тильда / Tilde

  // Диапазон кириллицы Windows-1251 (А-я)
  // Windows-1251 Cyrillic range (А-я)
  WIN1251_CYR_UPPER_FIRST = $C0;  // А / A
  WIN1251_CYR_UPPER_LAST = $DF;   // Я / Ya
  WIN1251_CYR_LOWER_FIRST = $E0;  // а / a
  WIN1251_CYR_LOWER_LAST = $FF;   // я / ya

  // Специальные символы Windows-1251
  // Windows-1251 special characters
  WIN1251_YO_UPPER = $A8;  // Ё
  WIN1251_YO_LOWER = $B8;  // ё

  // Unicode коды кириллицы
  // Unicode Cyrillic codes
  UNICODE_CYR_UPPER_FIRST = $0410;  // А
  UNICODE_CYR_LOWER_FIRST = $0430;  // а
  UNICODE_YO_UPPER = $0401;         // Ё
  UNICODE_YO_LOWER = $0451;         // ё

  // Диапазон кириллицы CP866
  // CP866 Cyrillic range
  CP866_CYR_UPPER_FIRST = $80;  // А
  CP866_CYR_UPPER_LAST = $9F;   // Я (первые 32)
  CP866_CYR_LOWER_FIRST = $A0;  // а
  CP866_CYR_LOWER_LAST = $AF;   // п (первые 16)
  CP866_CYR_LOWER2_FIRST = $E0; // р
  CP866_CYR_LOWER2_LAST = $EF;  // я (остальные 16)
  CP866_YO_UPPER = $F0;         // Ё
  CP866_YO_LOWER = $F1;         // ё

// Проверить, является ли код ASCII
function IsAsciiCode(CharCode: Integer): Boolean;
begin
  Result := (CharCode >= ASCII_FIRST) and (CharCode <= ASCII_LAST);
end;

// Проверить, является ли код кириллическим (Windows-1251)
function IsCyrillicWindows1251(CharCode: Integer): Boolean;
begin
  Result := ((CharCode >= WIN1251_CYR_UPPER_FIRST) and
             (CharCode <= WIN1251_CYR_LOWER_LAST)) or
            (CharCode = WIN1251_YO_UPPER) or
            (CharCode = WIN1251_YO_LOWER);
end;

// Проверить, является ли код кириллическим (CP866)
function IsCyrillicCP866(CharCode: Integer): Boolean;
begin
  Result := ((CharCode >= CP866_CYR_UPPER_FIRST) and
             (CharCode <= CP866_CYR_LOWER_LAST)) or
            ((CharCode >= CP866_CYR_LOWER2_FIRST) and
             (CharCode <= CP866_CYR_LOWER2_LAST)) or
            (CharCode = CP866_YO_UPPER) or
            (CharCode = CP866_YO_LOWER);
end;

// Автоопределение локали по коду символа
function DetectLocale(CharCode: Integer): TUzvMappingLocale;
begin
  // Сначала проверяем ASCII
  // First check ASCII
  if IsAsciiCode(CharCode) then
  begin
    Result := mlAscii;
    Exit;
  end;

  // Проверяем CP866 (приоритет для DOS-совместимых SHX)
  // Check CP866 (priority for DOS-compatible SHX)
  if IsCyrillicCP866(CharCode) then
  begin
    Result := mlCP866;
    Exit;
  end;

  // Проверяем Windows-1251
  // Check Windows-1251
  if IsCyrillicWindows1251(CharCode) then
  begin
    Result := mlWindows1251;
    Exit;
  end;

  // По умолчанию ASCII (прямой маппинг)
  // Default to ASCII (direct mapping)
  Result := mlAscii;
end;

// Конвертация Windows-1251 в Unicode
// Convert Windows-1251 to Unicode
function Windows1251ToUnicode(CharCode: Integer): Integer;
begin
  // Обработка специальных символов
  // Handle special characters
  case CharCode of
    WIN1251_YO_UPPER: Result := UNICODE_YO_UPPER;
    WIN1251_YO_LOWER: Result := UNICODE_YO_LOWER;
  else
    // Прописные буквы А-Я ($C0-$DF -> $0410-$042F)
    // Uppercase letters А-Я
    if (CharCode >= WIN1251_CYR_UPPER_FIRST) and
       (CharCode <= WIN1251_CYR_UPPER_LAST) then
      Result := UNICODE_CYR_UPPER_FIRST + (CharCode - WIN1251_CYR_UPPER_FIRST)

    // Строчные буквы а-я ($E0-$FF -> $0430-$044F)
    // Lowercase letters а-я
    else if (CharCode >= WIN1251_CYR_LOWER_FIRST) and
            (CharCode <= WIN1251_CYR_LOWER_LAST) then
      Result := UNICODE_CYR_LOWER_FIRST + (CharCode - WIN1251_CYR_LOWER_FIRST)

    // Остальные символы - прямой маппинг
    // Other characters - direct mapping
    else
      Result := CharCode;
  end;
end;

// Конвертация CP866 в Unicode
// Convert CP866 to Unicode
function CP866ToUnicode(CharCode: Integer): Integer;
begin
  // Обработка специальных символов
  // Handle special characters
  case CharCode of
    CP866_YO_UPPER: Result := UNICODE_YO_UPPER;
    CP866_YO_LOWER: Result := UNICODE_YO_LOWER;
  else
    // Прописные буквы А-Я ($80-$9F -> $0410-$042F)
    // Uppercase letters А-Я
    if (CharCode >= CP866_CYR_UPPER_FIRST) and
       (CharCode <= CP866_CYR_UPPER_LAST) then
      Result := UNICODE_CYR_UPPER_FIRST + (CharCode - CP866_CYR_UPPER_FIRST)

    // Строчные буквы а-п ($A0-$AF -> $0430-$043F)
    // Lowercase letters а-п
    else if (CharCode >= CP866_CYR_LOWER_FIRST) and
            (CharCode <= CP866_CYR_LOWER_LAST) then
      Result := UNICODE_CYR_LOWER_FIRST + (CharCode - CP866_CYR_LOWER_FIRST)

    // Строчные буквы р-я ($E0-$EF -> $0440-$044F)
    // Lowercase letters р-я
    else if (CharCode >= CP866_CYR_LOWER2_FIRST) and
            (CharCode <= CP866_CYR_LOWER2_LAST) then
      Result := UNICODE_CYR_LOWER_FIRST + 16 + (CharCode - CP866_CYR_LOWER2_FIRST)

    // Остальные символы - прямой маппинг
    // Other characters - direct mapping
    else
      Result := CharCode;
  end;
end;

// Получить Unicode код для SHX кода символа
function GetUnicodeForSHXCode(
  CharCode: Integer;
  Locale: TUzvMappingLocale
): Integer;
var
  ActualLocale: TUzvMappingLocale;
begin
  // Определяем локаль
  // Determine locale
  if Locale = mlAuto then
    ActualLocale := DetectLocale(CharCode)
  else
    ActualLocale := Locale;

  // Конвертируем в зависимости от локали
  // Convert based on locale
  case ActualLocale of
    mlAscii:
      // ASCII - прямой маппинг
      // ASCII - direct mapping
      Result := CharCode;

    mlWindows1251:
      Result := Windows1251ToUnicode(CharCode);

    mlCP866:
      Result := CP866ToUnicode(CharCode);

    else
      // По умолчанию прямой маппинг
      // Default direct mapping
      Result := CharCode;
  end;

  // Проверка валидности результата
  // Validate result
  if not IsValidUnicodeCode(Result) then
    Result := $FFFD; // Символ замены / Replacement character
end;

// Построить массив маппингов для диапазона кодов
function BuildMappingArray(
  FirstChar, LastChar: Integer;
  Locale: TUzvMappingLocale
): TUzvUnicodeMappingArray;
var
  I, Count: Integer;
begin
  Count := LastChar - FirstChar + 1;
  if Count <= 0 then
  begin
    SetLength(Result, 0);
    Exit;
  end;

  SetLength(Result, Count);
  for I := 0 to Count - 1 do
  begin
    Result[I].CharCode := FirstChar + I;
    Result[I].UnicodeValue := GetUnicodeForSHXCode(FirstChar + I, Locale);
  end;
end;

// Построить массив маппингов для списка кодов
function BuildMappingArrayFromCodes(
  const CharCodes: array of Integer;
  Locale: TUzvMappingLocale
): TUzvUnicodeMappingArray;
var
  I: Integer;
begin
  SetLength(Result, Length(CharCodes));
  for I := 0 to High(CharCodes) do
  begin
    Result[I].CharCode := CharCodes[I];
    Result[I].UnicodeValue := GetUnicodeForSHXCode(CharCodes[I], Locale);
  end;
end;

// Получить описание локали
function GetLocaleDescription(Locale: TUzvMappingLocale): AnsiString;
begin
  case Locale of
    mlAscii:       Result := 'ASCII';
    mlWindows1251: Result := 'Windows-1251';
    mlCP866:       Result := 'CP866';
    mlAuto:        Result := 'Auto';
    else           Result := 'Unknown';
  end;
end;

end.
