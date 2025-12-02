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
  Модуль: uzvshxtopdfcmaptestmapping
  Назначение: Unit-тест: проверка полноты и корректности маппинга

  Тест 1 — Полнота mapping:
    ToUnicode должен содержать запись для каждого glyph из CharProcs.

  Тест 2 — Корректность Unicode:
    Проверка корректного преобразования SHX-кодов в Unicode:
    - A  → U+0041
    - Б  → U+0411
    - 1  → U+0031
    - +  → U+002B

  Зависимости:
  - uzvshxtopdfcmaptypes: типы данных этапа 5
  - uzvshxtopdfcmap: основной интерфейс
  - uzvshxtopdfcmapmapping: таблицы маппинга
  - uzvshxtopdfcharprocstypes: типы данных этапа 4
  - uzvshxtopdfcmaptesthelper: вспомогательные функции
  - uzclog: логирование

  Module: uzvshxtopdfcmaptestmapping
  Purpose: Unit test: mapping completeness and correctness verification

  Test 1 — Mapping completeness:
    ToUnicode must contain entry for each glyph from CharProcs.

  Test 2 — Unicode correctness:
    Verify correct SHX to Unicode conversion:
    - A  → U+0041
    - Б  → U+0411
    - 1  → U+0031
    - +  → U+002B

  Dependencies:
  - uzvshxtopdfcmaptypes: Stage 5 data types
  - uzvshxtopdfcmap: main interface
  - uzvshxtopdfcmapmapping: mapping tables
  - uzvshxtopdfcharprocstypes: Stage 4 data types
  - uzvshxtopdfcmaptesthelper: helper functions
  - uzclog: logging
}

unit uzvshxtopdfcmaptestmapping;

{$mode objfpc}{$H+}

interface

uses
  SysUtils,
  uzvshxtopdfcmaptypes,
  uzvshxtopdfcmap,
  uzvshxtopdfcmapmapping,
  uzvshxtopdfcharprocstypes,
  uzvshxtopdfcmaptesthelper,
  uzclog;

// Запустить тест полноты маппинга (Тест 1)
// Run mapping completeness test (Test 1)
function RunMappingCompletenessTest: Boolean;

// Запустить тест корректности Unicode (Тест 2)
// Run Unicode correctness test (Test 2)
function RunUnicodeCorrectnessTest: Boolean;

// Запустить все тесты маппинга
// Run all mapping tests
function RunAllMappingTests: Boolean;

implementation

const
  LOG_PREFIX = 'CMapTestMapping: ';

// Запустить тест полноты маппинга (Тест 1)
function RunMappingCompletenessTest: Boolean;
var
  TestFont: TUzvPdfType3Font;
  CMap: TUzvPdfToUnicodeCMap;
  ValidationResult: TUzvCMapValidationResult;
  I, J: Integer;
  Found: Boolean;
  MissingCount: Integer;
begin
  Result := True;

  programlog.LogOutStr(
    LOG_PREFIX + 'ТЕСТ 1: Полнота маппинга - начало',
    LM_Info
  );

  // Создаём тестовый шрифт со смешанными символами
  // Create test font with mixed characters
  TestFont := CreateTestType3FontMixed;

  programlog.LogOutFormatStr(
    LOG_PREFIX + 'создан тестовый шрифт с %d глифами',
    [Length(TestFont.CharProcs)],
    LM_Info
  );

  // Генерируем CMap
  // Generate CMap
  CMap := BuildToUnicodeCMapSimple(TestFont);

  // Проверяем количество маппингов
  // Check mapping count
  if Length(CMap.Mappings) <> Length(TestFont.CharProcs) then
  begin
    programlog.LogOutFormatStr(
      LOG_PREFIX + 'ОШИБКА: количество маппингов (%d) != количество CharProcs (%d)',
      [Length(CMap.Mappings), Length(TestFont.CharProcs)],
      LM_Info
    );
    Result := False;
  end
  else
  begin
    programlog.LogOutFormatStr(
      LOG_PREFIX + 'OK: количество маппингов = %d',
      [Length(CMap.Mappings)],
      LM_Info
    );
  end;

  // Проверяем, что каждый CharProc имеет соответствующий маппинг
  // Check that each CharProc has corresponding mapping
  MissingCount := 0;
  for I := 0 to High(TestFont.CharProcs) do
  begin
    Found := False;
    for J := 0 to High(CMap.Mappings) do
    begin
      if CMap.Mappings[J].CharCode = TestFont.CharProcs[I].CharCode then
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
        [TestFont.CharProcs[I].CharCode],
        LM_Info
      );
      Result := False;
    end;
  end;

  if MissingCount = 0 then
    programlog.LogOutStr(
      LOG_PREFIX + 'OK: все CharProcs имеют соответствующие маппинги',
      LM_Info
    );

  // Используем встроенную валидацию
  // Use built-in validation
  ValidationResult := ValidateToUnicodeCMap(CMap, TestFont.CharProcs);
  if not ValidationResult.IsValid then
  begin
    programlog.LogOutFormatStr(
      LOG_PREFIX + 'ОШИБКА валидации: %s',
      [ValidationResult.ErrorMessage],
      LM_Info
    );
    Result := False;
  end
  else
  begin
    programlog.LogOutStr(
      LOG_PREFIX + 'OK: валидация CMap пройдена',
      LM_Info
    );
  end;

  if Result then
    programlog.LogOutStr(
      LOG_PREFIX + 'ТЕСТ 1: Полнота маппинга - ПРОЙДЕН',
      LM_Info
    )
  else
    programlog.LogOutStr(
      LOG_PREFIX + 'ТЕСТ 1: Полнота маппинга - ПРОВАЛЕН',
      LM_Info
    );
end;

// Запустить тест корректности Unicode (Тест 2)
function RunUnicodeCorrectnessTest: Boolean;
type
  TTestCase = record
    CharCode: Integer;
    ExpectedUnicode: Integer;
    Description: AnsiString;
  end;
var
  TestCases: array[0..3] of TTestCase;
  I: Integer;
  ActualUnicode: Integer;
begin
  Result := True;

  programlog.LogOutStr(
    LOG_PREFIX + 'ТЕСТ 2: Корректность Unicode - начало',
    LM_Info
  );

  // Определяем тестовые случаи согласно ТЗ
  // Define test cases per specification
  // A -> U+0041 (ASCII)
  TestCases[0].CharCode := 65;      // 'A' в ASCII
  TestCases[0].ExpectedUnicode := $0041;
  TestCases[0].Description := 'A -> U+0041';

  // Б -> U+0411 (Windows-1251: $C1)
  TestCases[1].CharCode := $C1;     // 'Б' в Windows-1251
  TestCases[1].ExpectedUnicode := $0411;
  TestCases[1].Description := 'Б (Win1251 $C1) -> U+0411';

  // 1 -> U+0031 (ASCII)
  TestCases[2].CharCode := 49;      // '1' в ASCII
  TestCases[2].ExpectedUnicode := $0031;
  TestCases[2].Description := '1 -> U+0031';

  // + -> U+002B (ASCII)
  TestCases[3].CharCode := 43;      // '+' в ASCII
  TestCases[3].ExpectedUnicode := $002B;
  TestCases[3].Description := '+ -> U+002B';

  // Проверяем каждый тестовый случай
  // Check each test case
  for I := 0 to High(TestCases) do
  begin
    ActualUnicode := GetUnicodeForSHXCode(TestCases[I].CharCode, mlAuto);

    if ActualUnicode = TestCases[I].ExpectedUnicode then
    begin
      programlog.LogOutFormatStr(
        LOG_PREFIX + 'OK: %s (получено: $%04X)',
        [TestCases[I].Description, ActualUnicode],
        LM_Info
      );
    end
    else
    begin
      programlog.LogOutFormatStr(
        LOG_PREFIX + 'ОШИБКА: %s, ожидалось $%04X, получено $%04X',
        [TestCases[I].Description, TestCases[I].ExpectedUnicode, ActualUnicode],
        LM_Info
      );
      Result := False;
    end;
  end;

  // Дополнительный тест: проверка кириллицы в Windows-1251
  // Additional test: Cyrillic in Windows-1251
  programlog.LogOutStr(
    LOG_PREFIX + 'Дополнительная проверка кириллицы Windows-1251:',
    LM_Info
  );

  // А ($C0) -> U+0410
  ActualUnicode := GetUnicodeForSHXCode($C0, mlWindows1251);
  if ActualUnicode = $0410 then
    programlog.LogOutStr(LOG_PREFIX + 'OK: А ($C0) -> U+0410', LM_Info)
  else
  begin
    programlog.LogOutFormatStr(
      LOG_PREFIX + 'ОШИБКА: А ($C0), ожидалось $0410, получено $%04X',
      [ActualUnicode],
      LM_Info
    );
    Result := False;
  end;

  // Ё ($A8) -> U+0401
  ActualUnicode := GetUnicodeForSHXCode($A8, mlWindows1251);
  if ActualUnicode = $0401 then
    programlog.LogOutStr(LOG_PREFIX + 'OK: Ё ($A8) -> U+0401', LM_Info)
  else
  begin
    programlog.LogOutFormatStr(
      LOG_PREFIX + 'ОШИБКА: Ё ($A8), ожидалось $0401, получено $%04X',
      [ActualUnicode],
      LM_Info
    );
    Result := False;
  end;

  // ё ($B8) -> U+0451
  ActualUnicode := GetUnicodeForSHXCode($B8, mlWindows1251);
  if ActualUnicode = $0451 then
    programlog.LogOutStr(LOG_PREFIX + 'OK: ё ($B8) -> U+0451', LM_Info)
  else
  begin
    programlog.LogOutFormatStr(
      LOG_PREFIX + 'ОШИБКА: ё ($B8), ожидалось $0451, получено $%04X',
      [ActualUnicode],
      LM_Info
    );
    Result := False;
  end;

  if Result then
    programlog.LogOutStr(
      LOG_PREFIX + 'ТЕСТ 2: Корректность Unicode - ПРОЙДЕН',
      LM_Info
    )
  else
    programlog.LogOutStr(
      LOG_PREFIX + 'ТЕСТ 2: Корректность Unicode - ПРОВАЛЕН',
      LM_Info
    );
end;

// Запустить все тесты маппинга
function RunAllMappingTests: Boolean;
var
  Test1Result, Test2Result: Boolean;
begin
  programlog.LogOutStr(
    LOG_PREFIX + '========== Начало тестирования маппинга ==========',
    LM_Info
  );

  Test1Result := RunMappingCompletenessTest;
  Test2Result := RunUnicodeCorrectnessTest;

  Result := Test1Result and Test2Result;

  if Result then
    programlog.LogOutStr(
      LOG_PREFIX + '========== ВСЕ ТЕСТЫ МАППИНГА ПРОЙДЕНЫ ==========',
      LM_Info
    )
  else
    programlog.LogOutStr(
      LOG_PREFIX + '========== НЕКОТОРЫЕ ТЕСТЫ ПРОВАЛЕНЫ ==========',
      LM_Info
    );
end;

end.
