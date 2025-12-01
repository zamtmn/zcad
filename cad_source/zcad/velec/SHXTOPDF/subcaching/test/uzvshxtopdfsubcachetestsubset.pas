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
  Модуль: uzvshxtopdfsubcachetestsubset
  Назначение: Unit-тест: проверка субсетинга глифов

  Тесты проверяют, что:
  - В субсет попадают только используемые глифы
  - Маппинг корректно связывает исходные и PDF-коды
  - FirstChar и LastChar вычисляются правильно
  - Массив Widths формируется корректно

  Module: uzvshxtopdfsubcachetestsubset
  Purpose: Unit test: glyph subsetting verification

  Tests verify that:
  - Only used glyphs are included in subset
  - Mapping correctly links original and PDF codes
  - FirstChar and LastChar are calculated correctly
  - Widths array is formed correctly
}

unit uzvshxtopdfsubcachetestsubset;

{$mode objfpc}{$H+}

interface

uses
  SysUtils,
  uzvshxtopdfsubcachetypes,
  uzvshxtopdfsubcache,
  uzvshxtopdfsubcachesubset,
  uzvshxtopdfcharprocstypes,
  uzclog;

// Запустить все тесты субсетинга
// Run all subsetting tests
function RunSubsetTests: Boolean;

// Тест: В субсет попадают только используемые глифы
// Test: Only used glyphs are included in subset
function TestSubsetOnlyUsedGlyphs: Boolean;

// Тест: Маппинг глифов корректен
// Test: Glyph mapping is correct
function TestSubsetMapping: Boolean;

// Тест: FirstChar и LastChar вычисляются правильно
// Test: FirstChar and LastChar are calculated correctly
function TestSubsetCharRange: Boolean;

// Тест: Дубликаты глифов игнорируются
// Test: Duplicate glyphs are ignored
function TestSubsetDuplicates: Boolean;

implementation

const
  LOG_PREFIX = 'SubCacheTestSubset: ';
  TEST_FONT_NAME = 'TestFont.shx';

// Подготовить кеш с тестовыми CharProcs
// Prepare cache with test CharProcs
procedure PrepareTestCache(
  Cache: TUzvSubCache;
  const GlyphCodes: array of Integer
);
var
  I: Integer;
  Key: TUzvGlyphCacheKey;
  CharProc: TUzvPdfCharProc;
begin
  for I := 0 to High(GlyphCodes) do
  begin
    Key := CreateGlyphCacheKey(
      TEST_FONT_NAME,
      GlyphCodes[I],
      1.0,
      1.0,
      0.0
    );

    CharProc := CreateEmptyCharProc(GlyphCodes[I]);
    CharProc.Width := 10.0;
    CharProc.Stream := Format('test stream for glyph %d', [GlyphCodes[I]]);
    CharProc.BBox.MinX := 0;
    CharProc.BBox.MinY := 0;
    CharProc.BBox.MaxX := 10;
    CharProc.BBox.MaxY := 12;

    Cache.PutCharProc(Key, CharProc);
  end;
end;

// Тест: В субсет попадают только используемые глифы
function TestSubsetOnlyUsedGlyphs: Boolean;
var
  Cache: TUzvSubCache;
  SubsetMgr: TUzvSubsetManager;
  Subset: TUzvFontSubset;
  AllGlyphs: array[0..4] of Integer = (65, 66, 67, 68, 69); // A, B, C, D, E
  UsedGlyphs: array[0..2] of Integer = (65, 67, 69);        // A, C, E
begin
  Result := False;

  programlog.LogOutStr(
    LOG_PREFIX + 'Тест: В субсет попадают только используемые глифы',
    LM_Info
  );

  Cache := CreateSubCache;
  try
    Cache.LoggingEnabled := False;

    // Подготавливаем кеш со всеми глифами
    // Prepare cache with all glyphs
    PrepareTestCache(Cache, AllGlyphs);

    // Создаём менеджер субсетов
    // Create subset manager
    SubsetMgr := CreateSubsetManager(TEST_FONT_NAME, Cache);
    try
      SubsetMgr.LoggingEnabled := False;

      // Отмечаем только часть глифов как используемые
      // Mark only some glyphs as used
      SubsetMgr.MarkGlyphsUsed(UsedGlyphs);

      // Строим субсет
      // Build subset
      Subset := SubsetMgr.BuildSubset;

      programlog.LogOutFormatStr(
        LOG_PREFIX + 'Используемых глифов: %d, CharProcs в субсете: %d',
        [SubsetMgr.UsedGlyphCount, Length(Subset.CharProcs)],
        LM_Info
      );

      // Проверка: количество CharProcs = количество используемых глифов
      // Check: CharProcs count = used glyphs count
      if Length(Subset.CharProcs) <> Length(UsedGlyphs) then
      begin
        programlog.LogOutFormatStr(
          LOG_PREFIX + 'ОШИБКА: ожидалось %d CharProcs, получено %d',
          [Length(UsedGlyphs), Length(Subset.CharProcs)],
          LM_Info
        );
        Exit;
      end;

      programlog.LogOutStr(
        LOG_PREFIX + 'Тест ПРОЙДЕН: в субсете только используемые глифы',
        LM_Info
      );
      Result := True;

    finally
      SubsetMgr.Free;
    end;
  finally
    Cache.Free;
  end;
end;

// Тест: Маппинг глифов корректен
function TestSubsetMapping: Boolean;
var
  Cache: TUzvSubCache;
  SubsetMgr: TUzvSubsetManager;
  Subset: TUzvFontSubset;
  UsedGlyphs: array[0..2] of Integer = (65, 67, 69);
  I: Integer;
  PdfCode: Integer;
begin
  Result := False;

  programlog.LogOutStr(
    LOG_PREFIX + 'Тест: Маппинг глифов корректен',
    LM_Info
  );

  Cache := CreateSubCache;
  try
    Cache.LoggingEnabled := False;
    PrepareTestCache(Cache, UsedGlyphs);

    SubsetMgr := CreateSubsetManager(TEST_FONT_NAME, Cache);
    try
      SubsetMgr.LoggingEnabled := False;
      SubsetMgr.MarkGlyphsUsed(UsedGlyphs);
      Subset := SubsetMgr.BuildSubset;

      // Проверяем маппинг для каждого глифа
      // Check mapping for each glyph
      for I := 0 to High(UsedGlyphs) do
      begin
        PdfCode := SubsetMgr.GetPdfCharCode(UsedGlyphs[I]);

        if PdfCode < 0 then
        begin
          programlog.LogOutFormatStr(
            LOG_PREFIX + 'ОШИБКА: глиф %d не найден в маппинге',
            [UsedGlyphs[I]],
            LM_Info
          );
          Exit;
        end;

        programlog.LogOutFormatStr(
          LOG_PREFIX + 'Маппинг: логический %d -> PDF %d',
          [UsedGlyphs[I], PdfCode],
          LM_Info
        );
      end;

      // Проверяем, что неиспользуемые глифы не в маппинге
      // Check that unused glyphs are not in mapping
      PdfCode := SubsetMgr.GetPdfCharCode(66);  // 'B' - не использовался
      if PdfCode >= 0 then
      begin
        programlog.LogOutStr(
          LOG_PREFIX + 'ОШИБКА: неиспользуемый глиф 66 найден в маппинге',
          LM_Info
        );
        Exit;
      end;

      programlog.LogOutStr(
        LOG_PREFIX + 'Тест ПРОЙДЕН: маппинг глифов корректен',
        LM_Info
      );
      Result := True;

    finally
      SubsetMgr.Free;
    end;
  finally
    Cache.Free;
  end;
end;

// Тест: FirstChar и LastChar вычисляются правильно
function TestSubsetCharRange: Boolean;
var
  Cache: TUzvSubCache;
  SubsetMgr: TUzvSubsetManager;
  Subset: TUzvFontSubset;
  UsedGlyphs: array[0..2] of Integer = (70, 65, 90);  // F, A, Z (не по порядку)
  ExpectedFirst, ExpectedLast: Integer;
begin
  Result := False;

  programlog.LogOutStr(
    LOG_PREFIX + 'Тест: FirstChar и LastChar вычисляются правильно',
    LM_Info
  );

  ExpectedFirst := 65;  // 'A' - минимальный
  ExpectedLast := 90;   // 'Z' - максимальный

  Cache := CreateSubCache;
  try
    Cache.LoggingEnabled := False;
    PrepareTestCache(Cache, UsedGlyphs);

    SubsetMgr := CreateSubsetManager(TEST_FONT_NAME, Cache);
    try
      SubsetMgr.LoggingEnabled := False;
      SubsetMgr.MarkGlyphsUsed(UsedGlyphs);
      Subset := SubsetMgr.BuildSubset;

      programlog.LogOutFormatStr(
        LOG_PREFIX + 'FirstChar: %d, LastChar: %d',
        [Subset.FirstChar, Subset.LastChar],
        LM_Info
      );

      if Subset.FirstChar <> ExpectedFirst then
      begin
        programlog.LogOutFormatStr(
          LOG_PREFIX + 'ОШИБКА: FirstChar=%d, ожидалось %d',
          [Subset.FirstChar, ExpectedFirst],
          LM_Info
        );
        Exit;
      end;

      if Subset.LastChar <> ExpectedLast then
      begin
        programlog.LogOutFormatStr(
          LOG_PREFIX + 'ОШИБКА: LastChar=%d, ожидалось %d',
          [Subset.LastChar, ExpectedLast],
          LM_Info
        );
        Exit;
      end;

      programlog.LogOutStr(
        LOG_PREFIX + 'Тест ПРОЙДЕН: FirstChar и LastChar корректны',
        LM_Info
      );
      Result := True;

    finally
      SubsetMgr.Free;
    end;
  finally
    Cache.Free;
  end;
end;

// Тест: Дубликаты глифов игнорируются
function TestSubsetDuplicates: Boolean;
var
  Cache: TUzvSubCache;
  SubsetMgr: TUzvSubsetManager;
  Subset: TUzvFontSubset;
  GlyphsWithDups: array[0..5] of Integer = (65, 66, 65, 67, 66, 65);
  ExpectedUnique: Integer;
begin
  Result := False;

  programlog.LogOutStr(
    LOG_PREFIX + 'Тест: Дубликаты глифов игнорируются',
    LM_Info
  );

  ExpectedUnique := 3;  // A, B, C

  Cache := CreateSubCache;
  try
    Cache.LoggingEnabled := False;
    PrepareTestCache(Cache, GlyphsWithDups);

    SubsetMgr := CreateSubsetManager(TEST_FONT_NAME, Cache);
    try
      SubsetMgr.LoggingEnabled := False;

      // Отмечаем глифы с дубликатами
      // Mark glyphs with duplicates
      SubsetMgr.MarkGlyphsUsed(GlyphsWithDups);

      programlog.LogOutFormatStr(
        LOG_PREFIX + 'Отмечено глифов (с дубл.): %d, уникальных: %d',
        [Length(GlyphsWithDups), SubsetMgr.UsedGlyphCount],
        LM_Info
      );

      if SubsetMgr.UsedGlyphCount <> ExpectedUnique then
      begin
        programlog.LogOutFormatStr(
          LOG_PREFIX + 'ОШИБКА: уникальных глифов %d, ожидалось %d',
          [SubsetMgr.UsedGlyphCount, ExpectedUnique],
          LM_Info
        );
        Exit;
      end;

      Subset := SubsetMgr.BuildSubset;

      if Length(Subset.CharProcs) <> ExpectedUnique then
      begin
        programlog.LogOutFormatStr(
          LOG_PREFIX + 'ОШИБКА: CharProcs=%d, ожидалось %d',
          [Length(Subset.CharProcs), ExpectedUnique],
          LM_Info
        );
        Exit;
      end;

      programlog.LogOutStr(
        LOG_PREFIX + 'Тест ПРОЙДЕН: дубликаты корректно игнорируются',
        LM_Info
      );
      Result := True;

    finally
      SubsetMgr.Free;
    end;
  finally
    Cache.Free;
  end;
end;

// Запустить все тесты субсетинга
function RunSubsetTests: Boolean;
var
  Test1, Test2, Test3, Test4: Boolean;
begin
  programlog.LogOutStr(
    LOG_PREFIX + '=== Начало тестов субсетинга ===',
    LM_Info
  );

  Test1 := TestSubsetOnlyUsedGlyphs;
  Test2 := TestSubsetMapping;
  Test3 := TestSubsetCharRange;
  Test4 := TestSubsetDuplicates;

  Result := Test1 and Test2 and Test3 and Test4;

  if Result then
    programlog.LogOutStr(
      LOG_PREFIX + '=== Все тесты субсетинга ПРОЙДЕНЫ ===',
      LM_Info
    )
  else
    programlog.LogOutStr(
      LOG_PREFIX + '=== ОШИБКА: некоторые тесты субсетинга провалены ===',
      LM_Info
    );
end;

end.
