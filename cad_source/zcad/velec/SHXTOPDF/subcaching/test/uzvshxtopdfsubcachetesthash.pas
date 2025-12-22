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
  Модуль: uzvshxtopdfsubcachetesthash
  Назначение: Unit-тест: проверка учёта трансформаций в хеше

  Тесты проверяют, что:
  - Разные трансформации одного символа дают разные хеши
  - Одинаковые трансформации дают одинаковые хеши
  - Разные шрифты с одинаковыми символами различаются

  Критерий успеха (Тест 2 из ТЗ):
    Вход:
      - символ "A" с scale=1.0
      - символ "A" с scale=2.0
    Проверка:
      - создаётся 2 разных CharProc
      - hash различается

  Критерий успеха (Тест 3 из ТЗ):
    Вход:
      - SHX1: "A"
      - SHX2: "A"
    Проверка:
      - создаются два разных CharProc

  Module: uzvshxtopdfsubcachetesthash
  Purpose: Unit test: transform awareness in hash verification

  Tests verify that:
  - Different transforms of same character produce different hashes
  - Same transforms produce same hashes
  - Different fonts with same characters are distinguished
}

unit uzvshxtopdfsubcachetesthash;

{$mode objfpc}{$H+}

interface

uses
  SysUtils,
  uzvshxtopdfsubcachetypes,
  uzvshxtopdfsubcache,
  uzvshxtopdfsubcachehash,
  uzvshxtopdfcharprocstypes,
  uzclog;

// Запустить все тесты хеширования
// Run all hash tests
function RunHashTests: Boolean;

// Тест 2: Учёт scale в хеше
// Test 2: Scale consideration in hash
function TestHashScaleDifference: Boolean;

// Тест 3: Учёт разных шрифтов
// Test 3: Different fonts consideration
function TestHashFontDifference: Boolean;

// Тест: Учёт WidthFactor в хеше
// Test: WidthFactor consideration in hash
function TestHashWidthFactorDifference: Boolean;

// Тест: Учёт Oblique в хеше
// Test: Oblique consideration in hash
function TestHashObliqueDifference: Boolean;

// Тест: Одинаковые параметры дают одинаковый хеш
// Test: Same parameters produce same hash
function TestHashSameParams: Boolean;

implementation

const
  LOG_PREFIX = 'SubCacheTestHash: ';
  TEST_FONT_1 = 'Font1.shx';
  TEST_FONT_2 = 'Font2.shx';

// Тестовый генератор CharProc
// Test CharProc generator
function TestCharProcGenerator(const Key: TUzvGlyphCacheKey): TUzvPdfCharProc;
begin
  Result := CreateEmptyCharProc(Key.GlyphCode);
  Result.Width := 10.0 * Key.WidthFactor;
  Result.Stream := Format('0 0 m 10 0 l 10 12 l 0 12 l h S %% glyph %d h=%.2f',
    [Key.GlyphCode, Key.Height]);
end;

// Тест 2: Учёт scale в хеше
function TestHashScaleDifference: Boolean;
var
  Cache: TUzvSubCache;
  Key1, Key2: TUzvGlyphCacheKey;
  Hash1, Hash2: AnsiString;
  CharProc1, CharProc2: TUzvPdfCharProc;
  Stats: TUzvSubCacheStats;
begin
  Result := False;

  programlog.LogOutStr(
    LOG_PREFIX + 'Тест 2: Учёт scale (height) в хеше',
    LM_Info
  );

  // Создаём два ключа с разным scale
  // Create two keys with different scale
  Key1 := CreateGlyphCacheKey(TEST_FONT_1, 65, 1.0, 1.0, 0.0);  // scale=1.0
  Key2 := CreateGlyphCacheKey(TEST_FONT_1, 65, 2.0, 1.0, 0.0);  // scale=2.0

  // Вычисляем хеши
  // Calculate hashes
  Hash1 := CalcGlyphHash(Key1);
  Hash2 := CalcGlyphHash(Key2);

  programlog.LogOutFormatStr(
    LOG_PREFIX + 'Hash1 (scale=1.0): %s',
    [Hash1],
    LM_Info
  );
  programlog.LogOutFormatStr(
    LOG_PREFIX + 'Hash2 (scale=2.0): %s',
    [Hash2],
    LM_Info
  );

  // Проверка: хеши должны быть разными
  // Check: hashes must be different
  if Hash1 = Hash2 then
  begin
    programlog.LogOutStr(
      LOG_PREFIX + 'ОШИБКА: хеши одинаковы при разных scale',
      LM_Info
    );
    Exit;
  end;

  // Проверяем через кеш
  // Verify through cache
  Cache := CreateSubCache;
  try
    Cache.LoggingEnabled := False;

    CharProc1 := Cache.GetOrCreateCharProc(Key1, @TestCharProcGenerator);
    CharProc2 := Cache.GetOrCreateCharProc(Key2, @TestCharProcGenerator);

    Stats := Cache.GetStats;

    // Должно быть создано 2 разных CharProc
    // 2 different CharProcs must be created
    if Stats.TotalCharProcs <> 2 then
    begin
      programlog.LogOutFormatStr(
        LOG_PREFIX + 'ОШИБКА: ожидалось 2 CharProcs, создано %d',
        [Stats.TotalCharProcs],
        LM_Info
      );
      Exit;
    end;

    programlog.LogOutStr(
      LOG_PREFIX + 'Тест 2 ПРОЙДЕН: разный scale даёт разные CharProcs',
      LM_Info
    );
    Result := True;

  finally
    Cache.Free;
  end;
end;

// Тест 3: Учёт разных шрифтов
function TestHashFontDifference: Boolean;
var
  Cache: TUzvSubCache;
  Key1, Key2: TUzvGlyphCacheKey;
  Hash1, Hash2: AnsiString;
  CharProc1, CharProc2: TUzvPdfCharProc;
  Stats: TUzvSubCacheStats;
begin
  Result := False;

  programlog.LogOutStr(
    LOG_PREFIX + 'Тест 3: Учёт разных шрифтов в хеше',
    LM_Info
  );

  // Создаём два ключа с разными шрифтами, но одинаковым символом
  // Create two keys with different fonts but same character
  Key1 := CreateGlyphCacheKey(TEST_FONT_1, 65, 1.0, 1.0, 0.0);  // Font1
  Key2 := CreateGlyphCacheKey(TEST_FONT_2, 65, 1.0, 1.0, 0.0);  // Font2

  // Вычисляем хеши
  // Calculate hashes
  Hash1 := CalcGlyphHash(Key1);
  Hash2 := CalcGlyphHash(Key2);

  programlog.LogOutFormatStr(
    LOG_PREFIX + 'Hash1 (Font1): %s',
    [Hash1],
    LM_Info
  );
  programlog.LogOutFormatStr(
    LOG_PREFIX + 'Hash2 (Font2): %s',
    [Hash2],
    LM_Info
  );

  // Проверка: хеши должны быть разными
  // Check: hashes must be different
  if Hash1 = Hash2 then
  begin
    programlog.LogOutStr(
      LOG_PREFIX + 'ОШИБКА: хеши одинаковы для разных шрифтов',
      LM_Info
    );
    Exit;
  end;

  // Проверяем через кеш
  // Verify through cache
  Cache := CreateSubCache;
  try
    Cache.LoggingEnabled := False;

    CharProc1 := Cache.GetOrCreateCharProc(Key1, @TestCharProcGenerator);
    CharProc2 := Cache.GetOrCreateCharProc(Key2, @TestCharProcGenerator);

    Stats := Cache.GetStats;

    // Должно быть создано 2 разных CharProc
    // 2 different CharProcs must be created
    if Stats.TotalCharProcs <> 2 then
    begin
      programlog.LogOutFormatStr(
        LOG_PREFIX + 'ОШИБКА: ожидалось 2 CharProcs, создано %d',
        [Stats.TotalCharProcs],
        LM_Info
      );
      Exit;
    end;

    programlog.LogOutStr(
      LOG_PREFIX + 'Тест 3 ПРОЙДЕН: разные шрифты дают разные CharProcs',
      LM_Info
    );
    Result := True;

  finally
    Cache.Free;
  end;
end;

// Тест: Учёт WidthFactor в хеше
function TestHashWidthFactorDifference: Boolean;
var
  Key1, Key2: TUzvGlyphCacheKey;
  Hash1, Hash2: AnsiString;
begin
  Result := False;

  programlog.LogOutStr(
    LOG_PREFIX + 'Тест: Учёт WidthFactor в хеше',
    LM_Info
  );

  Key1 := CreateGlyphCacheKey(TEST_FONT_1, 65, 1.0, 1.0, 0.0);  // wf=1.0
  Key2 := CreateGlyphCacheKey(TEST_FONT_1, 65, 1.0, 0.8, 0.0);  // wf=0.8

  Hash1 := CalcGlyphHash(Key1);
  Hash2 := CalcGlyphHash(Key2);

  if Hash1 = Hash2 then
  begin
    programlog.LogOutStr(
      LOG_PREFIX + 'ОШИБКА: хеши одинаковы при разных WidthFactor',
      LM_Info
    );
    Exit;
  end;

  programlog.LogOutStr(
    LOG_PREFIX + 'Тест ПРОЙДЕН: разный WidthFactor даёт разные хеши',
    LM_Info
  );
  Result := True;
end;

// Тест: Учёт Oblique в хеше
function TestHashObliqueDifference: Boolean;
var
  Key1, Key2: TUzvGlyphCacheKey;
  Hash1, Hash2: AnsiString;
begin
  Result := False;

  programlog.LogOutStr(
    LOG_PREFIX + 'Тест: Учёт Oblique в хеше',
    LM_Info
  );

  Key1 := CreateGlyphCacheKey(TEST_FONT_1, 65, 1.0, 1.0, 0.0);   // obl=0
  Key2 := CreateGlyphCacheKey(TEST_FONT_1, 65, 1.0, 1.0, 15.0);  // obl=15

  Hash1 := CalcGlyphHash(Key1);
  Hash2 := CalcGlyphHash(Key2);

  if Hash1 = Hash2 then
  begin
    programlog.LogOutStr(
      LOG_PREFIX + 'ОШИБКА: хеши одинаковы при разных Oblique',
      LM_Info
    );
    Exit;
  end;

  programlog.LogOutStr(
    LOG_PREFIX + 'Тест ПРОЙДЕН: разный Oblique даёт разные хеши',
    LM_Info
  );
  Result := True;
end;

// Тест: Одинаковые параметры дают одинаковый хеш
function TestHashSameParams: Boolean;
var
  Key1, Key2: TUzvGlyphCacheKey;
  Hash1, Hash2: AnsiString;
begin
  Result := False;

  programlog.LogOutStr(
    LOG_PREFIX + 'Тест: Одинаковые параметры дают одинаковый хеш',
    LM_Info
  );

  Key1 := CreateGlyphCacheKey(TEST_FONT_1, 65, 2.5, 0.9, 12.0);
  Key2 := CreateGlyphCacheKey(TEST_FONT_1, 65, 2.5, 0.9, 12.0);

  Hash1 := CalcGlyphHash(Key1);
  Hash2 := CalcGlyphHash(Key2);

  if Hash1 <> Hash2 then
  begin
    programlog.LogOutFormatStr(
      LOG_PREFIX + 'ОШИБКА: хеши разные при одинаковых параметрах: %s vs %s',
      [Hash1, Hash2],
      LM_Info
    );
    Exit;
  end;

  programlog.LogOutStr(
    LOG_PREFIX + 'Тест ПРОЙДЕН: одинаковые параметры дают одинаковый хеш',
    LM_Info
  );
  Result := True;
end;

// Запустить все тесты хеширования
function RunHashTests: Boolean;
var
  Test1, Test2, Test3, Test4, Test5: Boolean;
begin
  programlog.LogOutStr(
    LOG_PREFIX + '=== Начало тестов хеширования ===',
    LM_Info
  );

  Test1 := TestHashScaleDifference;
  Test2 := TestHashFontDifference;
  Test3 := TestHashWidthFactorDifference;
  Test4 := TestHashObliqueDifference;
  Test5 := TestHashSameParams;

  Result := Test1 and Test2 and Test3 and Test4 and Test5;

  if Result then
    programlog.LogOutStr(
      LOG_PREFIX + '=== Все тесты хеширования ПРОЙДЕНЫ ===',
      LM_Info
    )
  else
    programlog.LogOutStr(
      LOG_PREFIX + '=== ОШИБКА: некоторые тесты хеширования провалены ===',
      LM_Info
    );
end;

end.
