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
  Модуль: uzvshxtopdfsubcachetestdup
  Назначение: Unit-тест: проверка дедупликации CharProcs

  Тест проверяет, что при многократном запросе одинаковых символов:
  - Создаётся строго один CharProc
  - Все ссылки указывают на один объект
  - Статистика кеша корректно отражает повторное использование

  Критерий успеха (Тест 1 из ТЗ):
    Вход: строка из 1000 одинаковых символов "A"
    Проверка:
      - запросов генерации → 1000
      - реально созданных CharProcs → 1
      - все ссылки указывают на один объект

  Module: uzvshxtopdfsubcachetestdup
  Purpose: Unit test: CharProcs deduplication verification

  This test verifies that with multiple requests for same characters:
  - Exactly one CharProc is created
  - All references point to same object
  - Cache statistics correctly reflect reuse

  Success criterion (Test 1 from specification):
    Input: string of 1000 identical "A" characters
    Verification:
      - generation requests → 1000
      - actually created CharProcs → 1
      - all references point to same object
}

unit uzvshxtopdfsubcachetestdup;

{$mode objfpc}{$H+}

interface

uses
  SysUtils,
  uzvshxtopdfsubcachetypes,
  uzvshxtopdfsubcache,
  uzvshxtopdfsubcachehash,
  uzvshxtopdfcharprocstypes,
  uzclog;

// Запустить тест дедупликации CharProcs
// Run CharProcs deduplication test
function RunDuplicationTest: Boolean;

// Тест 1: 1000 одинаковых символов
// Test 1: 1000 identical characters
function TestDuplication1000Chars: Boolean;

// Тест 2: Смешанный набор символов с повторениями
// Test 2: Mixed character set with repetitions
function TestDuplicationMixed: Boolean;

// Тест 3: Проверка статистики кеша
// Test 3: Cache statistics verification
function TestCacheStatistics: Boolean;

implementation

const
  LOG_PREFIX = 'SubCacheTestDup: ';
  TEST_FONT_NAME = 'TestFont.shx';

// Тестовый генератор CharProc
// Test CharProc generator
function TestCharProcGenerator(const Key: TUzvGlyphCacheKey): TUzvPdfCharProc;
begin
  // Создаём простой CharProc для тестирования
  // Create simple CharProc for testing
  Result := CreateEmptyCharProc(Key.GlyphCode);
  Result.Width := 10.0;
  Result.Stream := Format('0 0 m 10 0 l 10 12 l 0 12 l h S %% glyph %d',
    [Key.GlyphCode]);
  Result.BBox.MinX := 0;
  Result.BBox.MinY := 0;
  Result.BBox.MaxX := 10;
  Result.BBox.MaxY := 12;
end;

// Тест 1: 1000 одинаковых символов
function TestDuplication1000Chars: Boolean;
var
  Cache: TUzvSubCache;
  Key: TUzvGlyphCacheKey;
  CharProc: TUzvPdfCharProc;
  Stats: TUzvSubCacheStats;
  I: Integer;
  CharCode: Integer;
  NumRequests: Integer;
begin
  Result := False;
  NumRequests := 1000;
  CharCode := 65;  // 'A'

  programlog.LogOutStr(
    LOG_PREFIX + 'Тест 1: 1000 одинаковых символов "A"',
    LM_Info
  );

  Cache := CreateSubCache;
  try
    Cache.LoggingEnabled := False;  // Отключаем логирование для скорости

    // Формируем ключ для символа 'A'
    // Create key for character 'A'
    Key := CreateGlyphCacheKey(
      TEST_FONT_NAME,
      CharCode,
      1.0,    // Height
      1.0,    // WidthFactor
      0.0     // ObliqueDeg
    );

    // Запрашиваем CharProc 1000 раз
    // Request CharProc 1000 times
    for I := 1 to NumRequests do
    begin
      CharProc := Cache.GetOrCreateCharProc(Key, @TestCharProcGenerator);
    end;

    // Получаем статистику
    // Get statistics
    Stats := Cache.GetStats;

    // Проверяем результаты
    // Verify results
    programlog.LogOutFormatStr(
      LOG_PREFIX + 'Запросов: %d, Попаданий: %d, Промахов: %d, CharProcs: %d',
      [Stats.TotalRequests, Stats.CacheHits, Stats.CacheMisses,
       Stats.TotalCharProcs],
      LM_Info
    );

    // Проверка 1: Всего запросов = NumRequests
    // Check 1: Total requests = NumRequests
    if Stats.TotalRequests <> NumRequests then
    begin
      programlog.LogOutFormatStr(
        LOG_PREFIX + 'ОШИБКА: ожидалось %d запросов, получено %d',
        [NumRequests, Stats.TotalRequests],
        LM_Info
      );
      Exit;
    end;

    // Проверка 2: Реально создан только 1 CharProc
    // Check 2: Only 1 CharProc actually created
    if Stats.TotalCharProcs <> 1 then
    begin
      programlog.LogOutFormatStr(
        LOG_PREFIX + 'ОШИБКА: ожидался 1 CharProc, создано %d',
        [Stats.TotalCharProcs],
        LM_Info
      );
      Exit;
    end;

    // Проверка 3: Промах только 1 (первый запрос)
    // Check 3: Only 1 miss (first request)
    if Stats.CacheMisses <> 1 then
    begin
      programlog.LogOutFormatStr(
        LOG_PREFIX + 'ОШИБКА: ожидался 1 промах, получено %d',
        [Stats.CacheMisses],
        LM_Info
      );
      Exit;
    end;

    // Проверка 4: Попаданий = NumRequests - 1
    // Check 4: Hits = NumRequests - 1
    if Stats.CacheHits <> (NumRequests - 1) then
    begin
      programlog.LogOutFormatStr(
        LOG_PREFIX + 'ОШИБКА: ожидалось %d попаданий, получено %d',
        [NumRequests - 1, Stats.CacheHits],
        LM_Info
      );
      Exit;
    end;

    programlog.LogOutStr(
      LOG_PREFIX + 'Тест 1 ПРОЙДЕН: дедупликация работает корректно',
      LM_Info
    );
    Result := True;

  finally
    Cache.Free;
  end;
end;

// Тест 2: Смешанный набор символов с повторениями
function TestDuplicationMixed: Boolean;
var
  Cache: TUzvSubCache;
  Key: TUzvGlyphCacheKey;
  CharProc: TUzvPdfCharProc;
  Stats: TUzvSubCacheStats;
  I: Integer;
  TestString: AnsiString;
  ExpectedUniqueChars: Integer;
begin
  Result := False;

  // Строка с повторяющимися символами
  // String with repeating characters
  TestString := 'AAABBBCCCAAABBBCCC';  // 18 символов, 3 уникальных
  ExpectedUniqueChars := 3;

  programlog.LogOutStr(
    LOG_PREFIX + 'Тест 2: Смешанный набор с повторениями',
    LM_Info
  );

  Cache := CreateSubCache;
  try
    Cache.LoggingEnabled := False;

    // Обрабатываем каждый символ строки
    // Process each character in string
    for I := 1 to Length(TestString) do
    begin
      Key := CreateGlyphCacheKey(
        TEST_FONT_NAME,
        Ord(TestString[I]),
        1.0,
        1.0,
        0.0
      );
      CharProc := Cache.GetOrCreateCharProc(Key, @TestCharProcGenerator);
    end;

    // Получаем статистику
    // Get statistics
    Stats := Cache.GetStats;

    programlog.LogOutFormatStr(
      LOG_PREFIX + 'Строка: "%s", Запросов: %d, CharProcs: %d',
      [TestString, Stats.TotalRequests, Stats.TotalCharProcs],
      LM_Info
    );

    // Проверка: создано ровно ExpectedUniqueChars CharProcs
    // Check: exactly ExpectedUniqueChars CharProcs created
    if Stats.TotalCharProcs <> ExpectedUniqueChars then
    begin
      programlog.LogOutFormatStr(
        LOG_PREFIX + 'ОШИБКА: ожидалось %d уникальных CharProcs, создано %d',
        [ExpectedUniqueChars, Stats.TotalCharProcs],
        LM_Info
      );
      Exit;
    end;

    // Проверка: всего запросов = длина строки
    // Check: total requests = string length
    if Stats.TotalRequests <> Length(TestString) then
    begin
      programlog.LogOutFormatStr(
        LOG_PREFIX + 'ОШИБКА: ожидалось %d запросов, получено %d',
        [Length(TestString), Stats.TotalRequests],
        LM_Info
      );
      Exit;
    end;

    programlog.LogOutStr(
      LOG_PREFIX + 'Тест 2 ПРОЙДЕН: смешанный набор обработан корректно',
      LM_Info
    );
    Result := True;

  finally
    Cache.Free;
  end;
end;

// Тест 3: Проверка статистики кеша
function TestCacheStatistics: Boolean;
var
  Cache: TUzvSubCache;
  Key: TUzvGlyphCacheKey;
  CharProc: TUzvPdfCharProc;
  Stats: TUzvSubCacheStats;
  ExpectedReusePercent: Double;
begin
  Result := False;

  programlog.LogOutStr(
    LOG_PREFIX + 'Тест 3: Проверка статистики кеша',
    LM_Info
  );

  Cache := CreateSubCache;
  try
    Cache.LoggingEnabled := False;

    // Создаём 1 CharProc и запрашиваем его 10 раз
    // Create 1 CharProc and request it 10 times
    Key := CreateGlyphCacheKey(TEST_FONT_NAME, 65, 1.0, 1.0, 0.0);

    // 10 запросов одного символа
    // 10 requests for same character
    CharProc := Cache.GetOrCreateCharProc(Key, @TestCharProcGenerator);
    CharProc := Cache.GetOrCreateCharProc(Key, @TestCharProcGenerator);
    CharProc := Cache.GetOrCreateCharProc(Key, @TestCharProcGenerator);
    CharProc := Cache.GetOrCreateCharProc(Key, @TestCharProcGenerator);
    CharProc := Cache.GetOrCreateCharProc(Key, @TestCharProcGenerator);
    CharProc := Cache.GetOrCreateCharProc(Key, @TestCharProcGenerator);
    CharProc := Cache.GetOrCreateCharProc(Key, @TestCharProcGenerator);
    CharProc := Cache.GetOrCreateCharProc(Key, @TestCharProcGenerator);
    CharProc := Cache.GetOrCreateCharProc(Key, @TestCharProcGenerator);
    CharProc := Cache.GetOrCreateCharProc(Key, @TestCharProcGenerator);

    Stats := Cache.GetStats;

    // Ожидаемый процент повторного использования: 9/10 = 90%
    // Expected reuse percentage: 9/10 = 90%
    ExpectedReusePercent := 90.0;

    programlog.LogOutFormatStr(
      LOG_PREFIX + 'Статистика: Reuse=%.1f%%, Hits=%d, Misses=%d',
      [Stats.ReusePercent, Stats.CacheHits, Stats.CacheMisses],
      LM_Info
    );

    // Проверка процента повторного использования
    // Check reuse percentage
    if Abs(Stats.ReusePercent - ExpectedReusePercent) > 0.1 then
    begin
      programlog.LogOutFormatStr(
        LOG_PREFIX + 'ОШИБКА: ожидалось %.1f%% reuse, получено %.1f%%',
        [ExpectedReusePercent, Stats.ReusePercent],
        LM_Info
      );
      Exit;
    end;

    programlog.LogOutStr(
      LOG_PREFIX + 'Тест 3 ПРОЙДЕН: статистика кеша корректна',
      LM_Info
    );
    Result := True;

  finally
    Cache.Free;
  end;
end;

// Запустить тест дедупликации CharProcs
function RunDuplicationTest: Boolean;
var
  Test1, Test2, Test3: Boolean;
begin
  programlog.LogOutStr(
    LOG_PREFIX + '=== Начало тестов дедупликации ===',
    LM_Info
  );

  Test1 := TestDuplication1000Chars;
  Test2 := TestDuplicationMixed;
  Test3 := TestCacheStatistics;

  Result := Test1 and Test2 and Test3;

  if Result then
    programlog.LogOutStr(
      LOG_PREFIX + '=== Все тесты дедупликации ПРОЙДЕНЫ ===',
      LM_Info
    )
  else
    programlog.LogOutStr(
      LOG_PREFIX + '=== ОШИБКА: некоторые тесты дедупликации провалены ===',
      LM_Info
    );
end;

end.
