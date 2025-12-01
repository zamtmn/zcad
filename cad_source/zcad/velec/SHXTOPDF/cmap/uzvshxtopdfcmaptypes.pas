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
  Модуль: uzvshxtopdfcmaptypes
  Назначение: Типы данных для этапа 5 конвейера SHX -> PDF (ToUnicode CMap)

  Данный модуль содержит структуры данных для представления:
  - Маппинга кодов символов на Unicode
  - Записей ToUnicode CMap
  - Параметров генерации CMap

  Зависимости:
  - uzvshxtopdfcharprocstypes: типы данных этапа 4

  Module: uzvshxtopdfcmaptypes
  Purpose: Data types for Stage 5 of SHX -> PDF pipeline (ToUnicode CMap)

  This module contains data structures for representing:
  - Character code to Unicode mapping
  - ToUnicode CMap entries
  - CMap generation parameters

  Dependencies:
  - uzvshxtopdfcharprocstypes: Stage 4 data types
}

unit uzvshxtopdfcmaptypes;

{$mode objfpc}{$H+}

interface

uses
  SysUtils;

type
  // Запись маппинга: код символа PDF -> код Unicode
  // Mapping entry: PDF character code -> Unicode code
  TUzvUnicodeMapping = record
    CharCode: Integer;     // Код символа в PDF / Character code in PDF
    UnicodeValue: Integer; // Код Unicode (например, $0410 для 'А')
                           // Unicode code (e.g., $0410 for 'А')
  end;

  // Массив маппингов Unicode
  // Array of Unicode mappings
  TUzvUnicodeMappingArray = array of TUzvUnicodeMapping;

  // ToUnicode CMap - полное описание CMap для PDF
  // ToUnicode CMap - complete CMap description for PDF
  //
  // Структура соответствует спецификации PDF Reference:
  // Structure follows PDF Reference specification:
  //   /CIDInit /ProcSet findresource begin
  //   12 dict begin
  //   begincmap
  //   /CIDSystemInfo << ... >> def
  //   /CMapName /... def
  //   /CMapType 2 def
  //   1 begincodespacerange ... endcodespacerange
  //   N beginbfchar ... endbfchar
  //   endcmap
  TUzvPdfToUnicodeCMap = record
    // Имя CMap (например, 'UZVSHXToUnicode')
    // CMap name (e.g., 'UZVSHXToUnicode')
    CMapName: AnsiString;

    // Массив маппингов символов
    // Character mappings array
    Mappings: TUzvUnicodeMappingArray;

    // Минимальный и максимальный коды символов
    // Minimum and maximum character codes
    MinCharCode: Integer;
    MaxCharCode: Integer;

    // Сгенерированный PDF-стрим CMap
    // Generated PDF CMap stream
    CMapStream: AnsiString;
  end;

  // Параметры генерации ToUnicode CMap
  // ToUnicode CMap generation parameters
  TUzvCMapParams = record
    // Имя CMap (по умолчанию 'UZVSHXToUnicode')
    // CMap name (default 'UZVSHXToUnicode')
    CMapName: AnsiString;

    // Использовать codespacerange на 1 байт (00-FF) или 2 байта (0000-FFFF)
    // Use 1-byte (00-FF) or 2-byte (0000-FFFF) codespacerange
    UseTwoByteCodespace: Boolean;

    // Максимальное количество записей в одном блоке bfchar
    // Maximum entries per bfchar block
    MaxEntriesPerBlock: Integer;

    // Включить комментарии в CMap стрим (для отладки)
    // Include comments in CMap stream (for debugging)
    IncludeComments: Boolean;
  end;

  // Результат валидации CMap
  // CMap validation result
  TUzvCMapValidationResult = record
    IsValid: Boolean;           // Валиден ли CMap / Is CMap valid
    ErrorMessage: AnsiString;   // Сообщение об ошибке / Error message
    TotalMappings: Integer;     // Всего маппингов / Total mappings
    DuplicateCodes: Integer;    // Количество дублей / Duplicate count
    MissingMappings: Integer;   // Отсутствующие маппинги / Missing mappings
  end;

// Создать пустой ToUnicode CMap
// Create empty ToUnicode CMap
function CreateEmptyCMap: TUzvPdfToUnicodeCMap;

// Создать пустой маппинг
// Create empty mapping
function CreateEmptyMapping(ACharCode: Integer): TUzvUnicodeMapping;

// Получить параметры генерации по умолчанию
// Get default generation parameters
function GetDefaultCMapParams: TUzvCMapParams;

// Создать результат валидации (успешный)
// Create validation result (success)
function CreateValidationSuccess(ATotalMappings: Integer): TUzvCMapValidationResult;

// Создать результат валидации (ошибка)
// Create validation result (error)
function CreateValidationError(
  const AErrorMessage: AnsiString
): TUzvCMapValidationResult;

// Проверить, является ли маппинг валидным
// Check if mapping is valid
function IsValidMapping(const Mapping: TUzvUnicodeMapping): Boolean;

// Проверить, является ли Unicode код валидным
// Check if Unicode code is valid
function IsValidUnicodeCode(UnicodeValue: Integer): Boolean;

// Сравнить два маппинга по коду символа (для сортировки)
// Compare two mappings by char code (for sorting)
function CompareMappingsByCharCode(
  const A, B: TUzvUnicodeMapping
): Integer;

implementation

const
  // Минимальный валидный код Unicode (не включая управляющие символы)
  // Minimum valid Unicode code (excluding control characters)
  MIN_VALID_UNICODE = $0020;

  // Максимальный валидный код Unicode (BMP - Basic Multilingual Plane)
  // Maximum valid Unicode code (BMP - Basic Multilingual Plane)
  MAX_VALID_UNICODE_BMP = $FFFF;

  // Максимальный код в Supplementary Planes
  // Maximum code in Supplementary Planes
  MAX_VALID_UNICODE = $10FFFF;

// Создать пустой ToUnicode CMap
function CreateEmptyCMap: TUzvPdfToUnicodeCMap;
begin
  Result.CMapName := 'UZVSHXToUnicode';
  SetLength(Result.Mappings, 0);
  Result.MinCharCode := 0;
  Result.MaxCharCode := 0;
  Result.CMapStream := '';
end;

// Создать пустой маппинг
function CreateEmptyMapping(ACharCode: Integer): TUzvUnicodeMapping;
begin
  Result.CharCode := ACharCode;
  Result.UnicodeValue := ACharCode; // По умолчанию 1:1 маппинг
                                     // Default 1:1 mapping
end;

// Получить параметры генерации по умолчанию
function GetDefaultCMapParams: TUzvCMapParams;
begin
  Result.CMapName := 'UZVSHXToUnicode';
  Result.UseTwoByteCodespace := False; // По умолчанию 1 байт (00-FF)
                                        // Default 1 byte (00-FF)
  Result.MaxEntriesPerBlock := 100;    // Стандартное ограничение PDF
                                        // Standard PDF limit
  Result.IncludeComments := False;     // Без комментариев для продакшена
                                        // No comments for production
end;

// Создать результат валидации (успешный)
function CreateValidationSuccess(ATotalMappings: Integer): TUzvCMapValidationResult;
begin
  Result.IsValid := True;
  Result.ErrorMessage := '';
  Result.TotalMappings := ATotalMappings;
  Result.DuplicateCodes := 0;
  Result.MissingMappings := 0;
end;

// Создать результат валидации (ошибка)
function CreateValidationError(
  const AErrorMessage: AnsiString
): TUzvCMapValidationResult;
begin
  Result.IsValid := False;
  Result.ErrorMessage := AErrorMessage;
  Result.TotalMappings := 0;
  Result.DuplicateCodes := 0;
  Result.MissingMappings := 0;
end;

// Проверить, является ли маппинг валидным
function IsValidMapping(const Mapping: TUzvUnicodeMapping): Boolean;
begin
  // CharCode должен быть в диапазоне 0-255 (или 0-65535 для 2-байтовых)
  // CharCode must be in range 0-255 (or 0-65535 for 2-byte)
  Result := (Mapping.CharCode >= 0) and
            (Mapping.CharCode <= $FFFF) and
            IsValidUnicodeCode(Mapping.UnicodeValue);
end;

// Проверить, является ли Unicode код валидным
function IsValidUnicodeCode(UnicodeValue: Integer): Boolean;
begin
  // Проверяем диапазон Unicode
  // Check Unicode range
  Result := (UnicodeValue >= 0) and (UnicodeValue <= MAX_VALID_UNICODE);

  // Исключаем суррогатные пары (D800-DFFF)
  // Exclude surrogate pairs (D800-DFFF)
  if Result then
    Result := not ((UnicodeValue >= $D800) and (UnicodeValue <= $DFFF));
end;

// Сравнить два маппинга по коду символа (для сортировки)
function CompareMappingsByCharCode(
  const A, B: TUzvUnicodeMapping
): Integer;
begin
  if A.CharCode < B.CharCode then
    Result := -1
  else if A.CharCode > B.CharCode then
    Result := 1
  else
    Result := 0;
end;

end.
