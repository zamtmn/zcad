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
  Модуль: uzvshxtopdfsubcachehash
  Назначение: Вычисление хеш-значений для ключей кеша глифов

  Данный модуль реализует механизм хеширования для:
  - Формирования уникальных идентификаторов глифов
  - Быстрого поиска в кеше CharProcs
  - Сравнения параметров трансформации

  Алгоритм хеширования:
    hash = FNV-1a(shxName + glyphCode + height + widthFactor + oblique)

  Зависимости:
  - uzvshxtopdfsubcachetypes: типы данных этапа 6

  Module: uzvshxtopdfsubcachehash
  Purpose: Hash value calculation for glyph cache keys

  This module implements hashing mechanism for:
  - Forming unique glyph identifiers
  - Fast CharProcs cache lookup
  - Transform parameter comparison

  Hashing algorithm:
    hash = FNV-1a(shxName + glyphCode + height + widthFactor + oblique)

  Dependencies:
  - uzvshxtopdfsubcachetypes: Stage 6 data types
}

unit uzvshxtopdfsubcachehash;

{$mode objfpc}{$H+}

interface

uses
  SysUtils,
  uzvshxtopdfsubcachetypes,
  uzclog;

// Вычислить хеш для ключа кеша глифа
// Calculate hash for glyph cache key
//
// Возвращает строковое представление хеша в формате hex
// Returns hash string representation in hex format
function CalcGlyphHash(const Key: TUzvGlyphCacheKey): AnsiString;

// Вычислить хеш для отдельных компонентов ключа
// Calculate hash for individual key components
//
// Это полезно для инкрементального построения хеша
// Useful for incremental hash building
function CalcGlyphHashFromParams(
  const ShxFontName: AnsiString;
  GlyphCode: Integer;
  Height: Double;
  WidthFactor: Double;
  ObliqueDeg: Double
): AnsiString;

// Вычислить 64-битный хеш (для внутреннего использования)
// Calculate 64-bit hash (for internal use)
function CalcGlyphHash64(const Key: TUzvGlyphCacheKey): UInt64;

// Сформировать строку ключа для отладки
// Build key string for debugging
function BuildKeyDebugString(const Key: TUzvGlyphCacheKey): AnsiString;

// Нормализовать Double-значение для хеширования
// Normalize Double value for hashing
//
// Округляет до заданной точности для стабильного хеширования
// Rounds to specified precision for stable hashing
function NormalizeDoubleForHash(Value: Double; Precision: Integer): Double;

implementation

uses
  Math;

const
  // FNV-1a константы для 64-битного хеша
  // FNV-1a constants for 64-bit hash
  FNV_OFFSET_BASIS_64: UInt64 = 14695981039346656037;
  FNV_PRIME_64: UInt64 = 1099511628211;

  // Точность округления Double для хеширования
  // Double rounding precision for hashing
  HASH_DOUBLE_PRECISION = 6;

  // Префикс для логирования
  // Logging prefix
  LOG_PREFIX = 'SubCacheHash: ';

// Нормализовать Double-значение для хеширования
function NormalizeDoubleForHash(Value: Double; Precision: Integer): Double;
var
  Multiplier: Double;
begin
  // Проверка на специальные значения
  // Check for special values
  if IsNaN(Value) or IsInfinite(Value) then
  begin
    Result := 0.0;
    Exit;
  end;

  // Округление до заданной точности
  // Round to specified precision
  Multiplier := Power(10, Precision);
  Result := Round(Value * Multiplier) / Multiplier;
end;

// Обновить хеш байтом (FNV-1a алгоритм)
// Update hash with byte (FNV-1a algorithm)
function FNV1aUpdateByte(Hash: UInt64; ByteValue: Byte): UInt64;
begin
  Result := (Hash xor ByteValue) * FNV_PRIME_64;
end;

// Обновить хеш строкой
// Update hash with string
function FNV1aUpdateString(Hash: UInt64; const Str: AnsiString): UInt64;
var
  I: Integer;
begin
  Result := Hash;
  for I := 1 to Length(Str) do
    Result := FNV1aUpdateByte(Result, Byte(Str[I]));
end;

// Обновить хеш целым числом (4 байта)
// Update hash with integer (4 bytes)
function FNV1aUpdateInt(Hash: UInt64; Value: Integer): UInt64;
begin
  Result := Hash;
  Result := FNV1aUpdateByte(Result, Byte(Value and $FF));
  Result := FNV1aUpdateByte(Result, Byte((Value shr 8) and $FF));
  Result := FNV1aUpdateByte(Result, Byte((Value shr 16) and $FF));
  Result := FNV1aUpdateByte(Result, Byte((Value shr 24) and $FF));
end;

// Обновить хеш Double-значением (8 байт)
// Update hash with Double value (8 bytes)
function FNV1aUpdateDouble(Hash: UInt64; Value: Double): UInt64;
var
  NormalizedValue: Double;
  Int64Value: Int64;
begin
  // Нормализуем значение для стабильного хеширования
  // Normalize value for stable hashing
  NormalizedValue := NormalizeDoubleForHash(Value, HASH_DOUBLE_PRECISION);

  // Преобразуем в целое (умножаем на 10^precision)
  // Convert to integer (multiply by 10^precision)
  Int64Value := Round(NormalizedValue * Power(10, HASH_DOUBLE_PRECISION));

  Result := Hash;
  Result := FNV1aUpdateByte(Result, Byte(Int64Value and $FF));
  Result := FNV1aUpdateByte(Result, Byte((Int64Value shr 8) and $FF));
  Result := FNV1aUpdateByte(Result, Byte((Int64Value shr 16) and $FF));
  Result := FNV1aUpdateByte(Result, Byte((Int64Value shr 24) and $FF));
  Result := FNV1aUpdateByte(Result, Byte((Int64Value shr 32) and $FF));
  Result := FNV1aUpdateByte(Result, Byte((Int64Value shr 40) and $FF));
  Result := FNV1aUpdateByte(Result, Byte((Int64Value shr 48) and $FF));
  Result := FNV1aUpdateByte(Result, Byte((Int64Value shr 56) and $FF));
end;

// Преобразовать UInt64 в hex-строку
// Convert UInt64 to hex string
function UInt64ToHex(Value: UInt64): AnsiString;
begin
  Result := IntToHex(Value, 16);
end;

// Вычислить 64-битный хеш
function CalcGlyphHash64(const Key: TUzvGlyphCacheKey): UInt64;
var
  LowerFontName: AnsiString;
begin
  // Начинаем с базового значения FNV-1a
  // Start with FNV-1a basis value
  Result := FNV_OFFSET_BASIS_64;

  // Имя шрифта (приводим к нижнему регистру для консистентности)
  // Font name (convert to lowercase for consistency)
  LowerFontName := LowerCase(Key.ShxFontName);
  Result := FNV1aUpdateString(Result, LowerFontName);

  // Код глифа
  // Glyph code
  Result := FNV1aUpdateInt(Result, Key.GlyphCode);

  // Высота
  // Height
  Result := FNV1aUpdateDouble(Result, Key.Height);

  // Коэффициент ширины
  // Width factor
  Result := FNV1aUpdateDouble(Result, Key.WidthFactor);

  // Наклон
  // Oblique
  Result := FNV1aUpdateDouble(Result, Key.ObliqueDeg);
end;

// Вычислить хеш для ключа кеша глифа
function CalcGlyphHash(const Key: TUzvGlyphCacheKey): AnsiString;
var
  Hash64: UInt64;
begin
  // Проверка валидности ключа
  // Key validation
  if not IsValidGlyphCacheKey(Key) then
  begin
    programlog.LogOutFormatStr(
      LOG_PREFIX + 'предупреждение: невалидный ключ для хеширования',
      [],
      LM_Info
    );
    Result := '0000000000000000';
    Exit;
  end;

  // Вычисляем хеш
  // Calculate hash
  Hash64 := CalcGlyphHash64(Key);
  Result := UInt64ToHex(Hash64);

  // Логирование (отключено по умолчанию для производительности)
  // Logging (disabled by default for performance)
  {
  programlog.LogOutFormatStr(
    LOG_PREFIX + 'hash вычислен: %s для %s',
    [Result, BuildKeyDebugString(Key)],
    LM_Info
  );
  }
end;

// Вычислить хеш для отдельных компонентов ключа
function CalcGlyphHashFromParams(
  const ShxFontName: AnsiString;
  GlyphCode: Integer;
  Height: Double;
  WidthFactor: Double;
  ObliqueDeg: Double
): AnsiString;
var
  Key: TUzvGlyphCacheKey;
begin
  Key := CreateGlyphCacheKey(
    ShxFontName,
    GlyphCode,
    Height,
    WidthFactor,
    ObliqueDeg
  );
  Result := CalcGlyphHash(Key);
end;

// Сформировать строку ключа для отладки
function BuildKeyDebugString(const Key: TUzvGlyphCacheKey): AnsiString;
begin
  Result := Format(
    'font=%s, code=%d, h=%.4f, wf=%.4f, obl=%.2f',
    [
      Key.ShxFontName,
      Key.GlyphCode,
      Key.Height,
      Key.WidthFactor,
      Key.ObliqueDeg
    ]
  );
end;

end.
