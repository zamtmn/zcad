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
  Модуль: uzvshxtopdfcmap
  Назначение: Основной интерфейс Этапа 5 конвейера SHX -> PDF

  Данный модуль является точкой входа для Этапа 5:
  - Принимает результат Этапа 4 (TUzvPdfType3Font)
  - Генерирует ToUnicode CMap для корректного копирования текста из PDF
  - Формирует связь между CharProcs и Unicode кодами
  - Возвращает TUzvPdfToUnicodeCMap для PDF-экспортера

  Использование:
    1. Получить TUzvPdfType3Font из Этапа 4
    2. Вызвать BuildToUnicodeCMap для генерации CMap
    3. Включить CMapStream в PDF-документ как объект ToUnicode

  Зависимости:
  - uzvshxtopdfcmaptypes: типы данных этапа 5
  - uzvshxtopdfcmapmapping: таблицы маппинга SHX -> Unicode
  - uzvshxtopdfcmapwriter: генерация CMap стрима
  - uzvshxtopdfcharprocstypes: типы данных этапа 4
  - uzclog: логирование

  Module: uzvshxtopdfcmap
  Purpose: Main interface for Stage 5 of SHX -> PDF pipeline

  This module is the entry point for Stage 5:
  - Accepts Stage 4 result (TUzvPdfType3Font)
  - Generates ToUnicode CMap for correct text copying from PDF
  - Establishes link between CharProcs and Unicode codes
  - Returns TUzvPdfToUnicodeCMap for PDF exporter

  Usage:
    1. Get TUzvPdfType3Font from Stage 4
    2. Call BuildToUnicodeCMap to generate CMap
    3. Include CMapStream in PDF document as ToUnicode object

  Dependencies:
  - uzvshxtopdfcmaptypes: Stage 5 data types
  - uzvshxtopdfcmapmapping: SHX -> Unicode mapping tables
  - uzvshxtopdfcmapwriter: CMap stream generation
  - uzvshxtopdfcharprocstypes: Stage 4 data types
  - uzclog: logging
}

unit uzvshxtopdfcmap;

{$mode objfpc}{$H+}

interface

uses
  SysUtils,
  uzvshxtopdfcmaptypes,
  uzvshxtopdfcmapmapping,
  uzvshxtopdfcmapwriter,
  uzvshxtopdfcharprocstypes,
  uzclog;

// Основная функция Этапа 5: построение ToUnicode CMap из Type3 Font
// Main Stage 5 function: build ToUnicode CMap from Type3 Font
//
// Параметры:
//   Type3Font: TUzvPdfType3Font - результат Этапа 4
//   Locale: TUzvMappingLocale - локаль для маппинга (по умолчанию Auto)
//   Params: TUzvCMapParams - параметры генерации CMap
//
// Возвращает:
//   TUzvPdfToUnicodeCMap - CMap с готовым стримом для PDF
//
// Parameters:
//   Type3Font: TUzvPdfType3Font - Stage 4 result
//   Locale: TUzvMappingLocale - mapping locale (default Auto)
//   Params: TUzvCMapParams - CMap generation parameters
//
// Returns:
//   TUzvPdfToUnicodeCMap - CMap with ready stream for PDF
function BuildToUnicodeCMap(
  const Type3Font: TUzvPdfType3Font;
  Locale: TUzvMappingLocale;
  const Params: TUzvCMapParams
): TUzvPdfToUnicodeCMap;

// Упрощённая версия: использует параметры по умолчанию
// Simplified version: uses default parameters
function BuildToUnicodeCMapSimple(
  const Type3Font: TUzvPdfType3Font
): TUzvPdfToUnicodeCMap;

// Версия с указанием локали
// Version with locale specification
function BuildToUnicodeCMapWithLocale(
  const Type3Font: TUzvPdfType3Font;
  Locale: TUzvMappingLocale
): TUzvPdfToUnicodeCMap;

// Построить ToUnicode CMap из массива CharProcs
// Build ToUnicode CMap from CharProcs array
function BuildToUnicodeCMapFromCharProcs(
  const CharProcs: TUzvPdfCharProcsArray;
  Locale: TUzvMappingLocale;
  const Params: TUzvCMapParams
): TUzvPdfToUnicodeCMap;

// Валидировать ToUnicode CMap
// Validate ToUnicode CMap
function ValidateToUnicodeCMap(
  const CMap: TUzvPdfToUnicodeCMap;
  const CharProcs: TUzvPdfCharProcsArray
): TUzvCMapValidationResult;

// Проверить полноту маппинга (каждый CharProc имеет запись в CMap)
// Check mapping completeness (each CharProc has entry in CMap)
function CheckMappingCompleteness(
  const CMap: TUzvPdfToUnicodeCMap;
  const CharProcs: TUzvPdfCharProcsArray;
  out MissingCodes: array of Integer
): Boolean;

// Получить количество маппингов в CMap
// Get number of mappings in CMap
function GetMappingCount(const CMap: TUzvPdfToUnicodeCMap): Integer;

// Найти Unicode значение по коду символа
// Find Unicode value by character code
function FindUnicodeByCharCode(
  const CMap: TUzvPdfToUnicodeCMap;
  CharCode: Integer;
  out UnicodeValue: Integer
): Boolean;

implementation

const
  // Префикс для логирования
  // Logging prefix
  LOG_PREFIX = 'ToUnicodeCMap: ';

// Построить массив маппингов из CharProcs
// Build mapping array from CharProcs
function BuildMappingsFromCharProcs(
  const CharProcs: TUzvPdfCharProcsArray;
  Locale: TUzvMappingLocale
): TUzvUnicodeMappingArray;
var
  I: Integer;
begin
  SetLength(Result, Length(CharProcs));
  for I := 0 to High(CharProcs) do
  begin
    Result[I].CharCode := CharProcs[I].CharCode;
    Result[I].UnicodeValue := GetUnicodeForSHXCode(
      CharProcs[I].CharCode,
      Locale
    );
  end;
end;

// Вычислить диапазон кодов символов
// Calculate character code range
procedure CalcCodeRange(
  const Mappings: TUzvUnicodeMappingArray;
  out MinCode, MaxCode: Integer
);
var
  I: Integer;
begin
  MinCode := MaxInt;
  MaxCode := -1;

  for I := 0 to High(Mappings) do
  begin
    if Mappings[I].CharCode < MinCode then
      MinCode := Mappings[I].CharCode;
    if Mappings[I].CharCode > MaxCode then
      MaxCode := Mappings[I].CharCode;
  end;

  // Если массив пустой
  // If array is empty
  if MinCode = MaxInt then
    MinCode := 0;
  if MaxCode = -1 then
    MaxCode := 0;
end;

// Построить ToUnicode CMap из массива CharProcs
function BuildToUnicodeCMapFromCharProcs(
  const CharProcs: TUzvPdfCharProcsArray;
  Locale: TUzvMappingLocale;
  const Params: TUzvCMapParams
): TUzvPdfToUnicodeCMap;
var
  I: Integer;
begin
  // Логирование: начало генерации
  // Logging: start generation
  programlog.LogOutFormatStr(
    LOG_PREFIX + 'начало генерации CMap, CharProcs: %d, локаль: %s',
    [Length(CharProcs), GetLocaleDescription(Locale)],
    LM_Info
  );

  // Инициализация результата
  // Initialize result
  Result := CreateEmptyCMap;
  Result.CMapName := Params.CMapName;

  // Проверка на пустой массив
  // Check for empty array
  if Length(CharProcs) = 0 then
  begin
    programlog.LogOutStr(
      LOG_PREFIX + 'пустой массив CharProcs, возврат пустого CMap',
      LM_Info
    );
    Exit;
  end;

  // Строим маппинги из CharProcs
  // Build mappings from CharProcs
  Result.Mappings := BuildMappingsFromCharProcs(CharProcs, Locale);

  // Вычисляем диапазон кодов
  // Calculate code range
  CalcCodeRange(Result.Mappings, Result.MinCharCode, Result.MaxCharCode);

  // Логируем каждый маппинг
  // Log each mapping
  for I := 0 to High(Result.Mappings) do
  begin
    programlog.LogOutFormatStr(
      LOG_PREFIX + 'маппинг: code=%d -> unicode=$%04X',
      [Result.Mappings[I].CharCode, Result.Mappings[I].UnicodeValue],
      LM_Info
    );
  end;

  // Генерируем CMap стрим
  // Generate CMap stream
  Result.CMapStream := GenerateCMapStream(Result.Mappings, Params);

  // Логирование: завершение генерации
  // Logging: generation complete
  programlog.LogOutFormatStr(
    LOG_PREFIX + 'завершение генерации CMap, маппингов: %d, ' +
    'диапазон: %d-%d, размер стрима: %d байт',
    [Length(Result.Mappings), Result.MinCharCode, Result.MaxCharCode,
     Length(Result.CMapStream)],
    LM_Info
  );
end;

// Основная функция Этапа 5: построение ToUnicode CMap из Type3 Font
function BuildToUnicodeCMap(
  const Type3Font: TUzvPdfType3Font;
  Locale: TUzvMappingLocale;
  const Params: TUzvCMapParams
): TUzvPdfToUnicodeCMap;
begin
  Result := BuildToUnicodeCMapFromCharProcs(
    Type3Font.CharProcs,
    Locale,
    Params
  );
end;

// Упрощённая версия: использует параметры по умолчанию
function BuildToUnicodeCMapSimple(
  const Type3Font: TUzvPdfType3Font
): TUzvPdfToUnicodeCMap;
begin
  Result := BuildToUnicodeCMap(
    Type3Font,
    mlAuto,
    GetDefaultCMapParams
  );
end;

// Версия с указанием локали
function BuildToUnicodeCMapWithLocale(
  const Type3Font: TUzvPdfType3Font;
  Locale: TUzvMappingLocale
): TUzvPdfToUnicodeCMap;
begin
  Result := BuildToUnicodeCMap(
    Type3Font,
    Locale,
    GetDefaultCMapParams
  );
end;

// Валидировать ToUnicode CMap
function ValidateToUnicodeCMap(
  const CMap: TUzvPdfToUnicodeCMap;
  const CharProcs: TUzvPdfCharProcsArray
): TUzvCMapValidationResult;
var
  I, J: Integer;
  Found: Boolean;
  DuplicateCount: Integer;
  MissingCount: Integer;
begin
  // Проверка на пустой CMap
  // Check for empty CMap
  if Length(CMap.Mappings) = 0 then
  begin
    if Length(CharProcs) = 0 then
      Result := CreateValidationSuccess(0)
    else
      Result := CreateValidationError('CMap пуст, но CharProcs содержит глифы');
    Exit;
  end;

  // Проверка на дублирующиеся коды
  // Check for duplicate codes
  DuplicateCount := 0;
  for I := 0 to High(CMap.Mappings) - 1 do
  begin
    for J := I + 1 to High(CMap.Mappings) do
    begin
      if CMap.Mappings[I].CharCode = CMap.Mappings[J].CharCode then
      begin
        Inc(DuplicateCount);
        programlog.LogOutFormatStr(
          LOG_PREFIX + 'ОШИБКА: дублирующийся код символа: %d',
          [CMap.Mappings[I].CharCode],
          LM_Info
        );
      end;
    end;
  end;

  // Проверка полноты маппинга
  // Check mapping completeness
  MissingCount := 0;
  for I := 0 to High(CharProcs) do
  begin
    Found := False;
    for J := 0 to High(CMap.Mappings) do
    begin
      if CMap.Mappings[J].CharCode = CharProcs[I].CharCode then
      begin
        Found := True;
        Break;
      end;
    end;

    if not Found then
    begin
      Inc(MissingCount);
      programlog.LogOutFormatStr(
        LOG_PREFIX + 'ОШИБКА: отсутствует маппинг для CharProc code=%d',
        [CharProcs[I].CharCode],
        LM_Info
      );
    end;
  end;

  // Формируем результат
  // Build result
  Result.TotalMappings := Length(CMap.Mappings);
  Result.DuplicateCodes := DuplicateCount;
  Result.MissingMappings := MissingCount;

  if (DuplicateCount > 0) or (MissingCount > 0) then
  begin
    Result.IsValid := False;
    Result.ErrorMessage := Format(
      'Найдено ошибок: дубли=%d, отсутствующие=%d',
      [DuplicateCount, MissingCount]
    );
  end
  else
  begin
    Result.IsValid := True;
    Result.ErrorMessage := '';
  end;
end;

// Проверить полноту маппинга
function CheckMappingCompleteness(
  const CMap: TUzvPdfToUnicodeCMap;
  const CharProcs: TUzvPdfCharProcsArray;
  out MissingCodes: array of Integer
): Boolean;
var
  I, J: Integer;
  Found: Boolean;
  MissingIndex: Integer;
begin
  Result := True;
  MissingIndex := 0;

  for I := 0 to High(CharProcs) do
  begin
    Found := False;
    for J := 0 to High(CMap.Mappings) do
    begin
      if CMap.Mappings[J].CharCode = CharProcs[I].CharCode then
      begin
        Found := True;
        Break;
      end;
    end;

    if not Found then
    begin
      Result := False;
      if MissingIndex <= High(MissingCodes) then
      begin
        MissingCodes[MissingIndex] := CharProcs[I].CharCode;
        Inc(MissingIndex);
      end;
    end;
  end;
end;

// Получить количество маппингов в CMap
function GetMappingCount(const CMap: TUzvPdfToUnicodeCMap): Integer;
begin
  Result := Length(CMap.Mappings);
end;

// Найти Unicode значение по коду символа
function FindUnicodeByCharCode(
  const CMap: TUzvPdfToUnicodeCMap;
  CharCode: Integer;
  out UnicodeValue: Integer
): Boolean;
var
  I: Integer;
begin
  Result := False;
  UnicodeValue := 0;

  for I := 0 to High(CMap.Mappings) do
  begin
    if CMap.Mappings[I].CharCode = CharCode then
    begin
      UnicodeValue := CMap.Mappings[I].UnicodeValue;
      Result := True;
      Exit;
    end;
  end;
end;

end.
