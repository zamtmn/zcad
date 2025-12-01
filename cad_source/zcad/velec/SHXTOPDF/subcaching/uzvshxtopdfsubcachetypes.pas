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
  Модуль: uzvshxtopdfsubcachetypes
  Назначение: Типы данных для Этапа 6 конвейера SHX -> PDF (Subcaching)

  Данный модуль содержит структуры данных для представления:
  - Ключей кеша глифов (GlyphCacheKey)
  - Записей кеша CharProcs
  - Параметров субсетинга
  - Статистики кеширования

  Зависимости:
  - uzvshxtopdfcharprocstypes: типы данных этапа 4 (CharProcs)
  - uzvshxtopdftransformtypes: типы данных этапа 3 (трансформации)

  Module: uzvshxtopdfsubcachetypes
  Purpose: Data types for Stage 6 of SHX -> PDF pipeline (Subcaching)

  This module contains data structures for representing:
  - Glyph cache keys (GlyphCacheKey)
  - CharProcs cache entries
  - Subsetting parameters
  - Caching statistics

  Dependencies:
  - uzvshxtopdfcharprocstypes: Stage 4 data types (CharProcs)
  - uzvshxtopdftransformtypes: Stage 3 data types (transformations)
}

unit uzvshxtopdfsubcachetypes;

{$mode objfpc}{$H+}

interface

uses
  SysUtils,
  uzvshxtopdfcharprocstypes;

type
  // Уникальный ключ для идентификации глифа в кеше
  // Unique key for identifying a glyph in cache
  //
  // Формируется из комбинации:
  //   - Имя SHX-шрифта
  //   - Код символа (глифа)
  //   - Высота текста (height)
  //   - Коэффициент ширины (widthFactor)
  //   - Наклон (oblique)
  //
  // Formed from combination of:
  //   - SHX font name
  //   - Character code (glyph)
  //   - Text height
  //   - Width factor
  //   - Oblique angle
  TUzvGlyphCacheKey = record
    ShxFontName: AnsiString;  // Имя SHX-шрифта / SHX font name
    GlyphCode: Integer;        // Код символа / Character code
    Height: Double;            // Высота текста / Text height
    WidthFactor: Double;       // Коэффициент ширины / Width factor
    ObliqueDeg: Double;        // Наклон в градусах / Oblique angle in degrees
  end;

  // Запись кеша CharProc
  // CharProc cache entry
  TUzvCharProcCacheEntry = record
    Key: TUzvGlyphCacheKey;       // Ключ записи / Entry key
    CharProc: TUzvPdfCharProc;    // Кешированный CharProc / Cached CharProc
    UseCount: Integer;            // Счётчик использований / Usage counter
    CreatedAt: TDateTime;         // Время создания / Creation time
  end;

  // Динамический массив записей кеша
  // Dynamic array of cache entries
  TUzvCharProcCacheEntryArray = array of TUzvCharProcCacheEntry;

  // Статистика кеширования
  // Caching statistics
  TUzvSubCacheStats = record
    TotalRequests: Integer;     // Всего запросов / Total requests
    CacheHits: Integer;         // Попаданий в кеш / Cache hits
    CacheMisses: Integer;       // Промахов кеша / Cache misses
    TotalCharProcs: Integer;    // Всего созданных CharProcs / Total CharProcs created
    ReusePercent: Double;       // Процент повторного использования / Reuse percentage
  end;

  // Параметры субсетинга
  // Subsetting parameters
  TUzvSubsetParams = record
    // Включить субсетинг (в PDF попадут только используемые глифы)
    // Enable subsetting (only used glyphs will be in PDF)
    EnableSubsetting: Boolean;

    // Минимальный код символа для субсета
    // Minimum character code for subset
    MinCharCode: Integer;

    // Максимальный код символа для субсета
    // Maximum character code for subset
    MaxCharCode: Integer;
  end;

  // Запись маппинга для субсета
  // Mapping entry for subset
  //
  // Связывает:
  //   - Логический глиф (из CAD-модели)
  //   - PDF-код символа (в Type3 Font)
  //   - Ссылку на CharProc
  //
  // Links:
  //   - Logical glyph (from CAD model)
  //   - PDF character code (in Type3 Font)
  //   - Reference to CharProc
  TUzvSubsetMappingEntry = record
    LogicalGlyphCode: Integer;    // Исходный код глифа / Original glyph code
    PdfCharCode: Integer;         // Код в PDF / Code in PDF
    CharProcIndex: Integer;       // Индекс в массиве CharProcs / Index in CharProcs array
    ShxFontName: AnsiString;      // Имя SHX-шрифта / SHX font name
  end;

  // Массив записей маппинга субсета
  // Array of subset mapping entries
  TUzvSubsetMappingArray = array of TUzvSubsetMappingEntry;

  // Результат субсетинга - полное описание субсета шрифта
  // Subsetting result - complete font subset description
  TUzvFontSubset = record
    ShxFontName: AnsiString;           // Имя исходного SHX-шрифта
                                        // Original SHX font name
    CharProcs: TUzvPdfCharProcsArray;  // Массив CharProcs субсета
                                        // Subset CharProcs array
    Mappings: TUzvSubsetMappingArray;  // Маппинг глифов
                                        // Glyph mappings
    FirstChar: Integer;                 // Первый код символа / First char code
    LastChar: Integer;                  // Последний код символа / Last char code
    Widths: array of Double;            // Массив ширин / Widths array
    FontBBox: TUzvPdfBBox;              // Bounding box шрифта / Font bounding box
  end;

  // Параметры дискового кеша (для будущего расширения)
  // Disk cache parameters (for future extension)
  TUzvDiskCacheParams = record
    Enabled: Boolean;           // Включен ли дисковый кеш / Is disk cache enabled
    CacheDirectory: AnsiString; // Каталог для кеша / Cache directory
    MaxCacheSize: Int64;        // Максимальный размер кеша в байтах
                                 // Maximum cache size in bytes
    CacheVersion: Integer;      // Версия формата кеша / Cache format version
  end;

// Создать пустой ключ кеша
// Create empty cache key
function CreateEmptyGlyphCacheKey: TUzvGlyphCacheKey;

// Создать ключ кеша из параметров
// Create cache key from parameters
function CreateGlyphCacheKey(
  const AShxFontName: AnsiString;
  AGlyphCode: Integer;
  AHeight: Double;
  AWidthFactor: Double;
  AObliqueDeg: Double
): TUzvGlyphCacheKey;

// Создать пустую запись кеша
// Create empty cache entry
function CreateEmptyCacheEntry: TUzvCharProcCacheEntry;

// Создать пустую статистику кеша
// Create empty cache statistics
function CreateEmptySubCacheStats: TUzvSubCacheStats;

// Получить параметры субсетинга по умолчанию
// Get default subsetting parameters
function GetDefaultSubsetParams: TUzvSubsetParams;

// Получить параметры дискового кеша по умолчанию (отключен)
// Get default disk cache parameters (disabled)
function GetDefaultDiskCacheParams: TUzvDiskCacheParams;

// Создать пустой субсет шрифта
// Create empty font subset
function CreateEmptyFontSubset: TUzvFontSubset;

// Проверить валидность ключа кеша
// Validate cache key
function IsValidGlyphCacheKey(const Key: TUzvGlyphCacheKey): Boolean;

// Сравнить два ключа кеша на равенство
// Compare two cache keys for equality
function CompareGlyphCacheKeys(
  const Key1, Key2: TUzvGlyphCacheKey
): Boolean;

implementation

uses
  Math;

const
  // Допустимая погрешность для сравнения Double-значений
  // Tolerance for Double comparison
  DOUBLE_EPSILON = 1e-6;

// Создать пустой ключ кеша
function CreateEmptyGlyphCacheKey: TUzvGlyphCacheKey;
begin
  Result.ShxFontName := '';
  Result.GlyphCode := 0;
  Result.Height := 0.0;
  Result.WidthFactor := 1.0;
  Result.ObliqueDeg := 0.0;
end;

// Создать ключ кеша из параметров
function CreateGlyphCacheKey(
  const AShxFontName: AnsiString;
  AGlyphCode: Integer;
  AHeight: Double;
  AWidthFactor: Double;
  AObliqueDeg: Double
): TUzvGlyphCacheKey;
begin
  Result.ShxFontName := AShxFontName;
  Result.GlyphCode := AGlyphCode;
  Result.Height := AHeight;
  Result.WidthFactor := AWidthFactor;
  Result.ObliqueDeg := AObliqueDeg;
end;

// Создать пустую запись кеша
function CreateEmptyCacheEntry: TUzvCharProcCacheEntry;
begin
  Result.Key := CreateEmptyGlyphCacheKey;
  Result.CharProc := CreateEmptyCharProc(0);
  Result.UseCount := 0;
  Result.CreatedAt := Now;
end;

// Создать пустую статистику кеша
function CreateEmptySubCacheStats: TUzvSubCacheStats;
begin
  Result.TotalRequests := 0;
  Result.CacheHits := 0;
  Result.CacheMisses := 0;
  Result.TotalCharProcs := 0;
  Result.ReusePercent := 0.0;
end;

// Получить параметры субсетинга по умолчанию
function GetDefaultSubsetParams: TUzvSubsetParams;
begin
  Result.EnableSubsetting := True;  // Субсетинг включен по умолчанию
  Result.MinCharCode := 0;
  Result.MaxCharCode := 255;        // По умолчанию один байт (0-255)
end;

// Получить параметры дискового кеша по умолчанию
function GetDefaultDiskCacheParams: TUzvDiskCacheParams;
begin
  Result.Enabled := False;          // Дисковый кеш отключен по умолчанию
  Result.CacheDirectory := '';
  Result.MaxCacheSize := 100 * 1024 * 1024; // 100 МБ по умолчанию
  Result.CacheVersion := 1;
end;

// Создать пустой субсет шрифта
function CreateEmptyFontSubset: TUzvFontSubset;
begin
  Result.ShxFontName := '';
  SetLength(Result.CharProcs, 0);
  SetLength(Result.Mappings, 0);
  Result.FirstChar := 0;
  Result.LastChar := 0;
  SetLength(Result.Widths, 0);
  Result.FontBBox := CreateEmptyPdfBBox;
end;

// Проверить валидность ключа кеша
function IsValidGlyphCacheKey(const Key: TUzvGlyphCacheKey): Boolean;
begin
  Result := True;

  // Проверка имени шрифта (не должно быть пустым)
  // Font name validation (must not be empty)
  if Trim(Key.ShxFontName) = '' then
  begin
    Result := False;
    Exit;
  end;

  // Проверка кода глифа (должен быть неотрицательным)
  // Glyph code validation (must be non-negative)
  if Key.GlyphCode < 0 then
  begin
    Result := False;
    Exit;
  end;

  // Проверка высоты (должна быть положительной)
  // Height validation (must be positive)
  if (Key.Height <= 0) or IsNaN(Key.Height) or IsInfinite(Key.Height) then
  begin
    Result := False;
    Exit;
  end;

  // Проверка WidthFactor (должен быть положительным)
  // WidthFactor validation (must be positive)
  if (Key.WidthFactor <= 0) or IsNaN(Key.WidthFactor) or
     IsInfinite(Key.WidthFactor) then
  begin
    Result := False;
    Exit;
  end;

  // Проверка ObliqueDeg (не должен быть NaN или Infinity)
  // ObliqueDeg validation (must not be NaN or Infinity)
  if IsNaN(Key.ObliqueDeg) or IsInfinite(Key.ObliqueDeg) then
  begin
    Result := False;
    Exit;
  end;
end;

// Сравнить два ключа кеша на равенство
function CompareGlyphCacheKeys(
  const Key1, Key2: TUzvGlyphCacheKey
): Boolean;
begin
  Result := False;

  // Сравнение имён шрифтов (без учёта регистра)
  // Font name comparison (case-insensitive)
  if not SameText(Key1.ShxFontName, Key2.ShxFontName) then
    Exit;

  // Сравнение кодов глифов
  // Glyph code comparison
  if Key1.GlyphCode <> Key2.GlyphCode then
    Exit;

  // Сравнение высоты с допуском
  // Height comparison with tolerance
  if Abs(Key1.Height - Key2.Height) > DOUBLE_EPSILON then
    Exit;

  // Сравнение WidthFactor с допуском
  // WidthFactor comparison with tolerance
  if Abs(Key1.WidthFactor - Key2.WidthFactor) > DOUBLE_EPSILON then
    Exit;

  // Сравнение ObliqueDeg с допуском
  // ObliqueDeg comparison with tolerance
  if Abs(Key1.ObliqueDeg - Key2.ObliqueDeg) > DOUBLE_EPSILON then
    Exit;

  Result := True;
end;

end.
