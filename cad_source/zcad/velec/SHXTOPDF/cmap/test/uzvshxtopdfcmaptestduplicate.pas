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
  Модуль: uzvshxtopdfcmaptestduplicate
  Назначение: Unit-тест: проверка отсутствия дублирования кодов

  Тест 3 — Дублирование кодов:
    Два разных glyph не могут иметь один и тот же PDF-код.
    При обнаружении дублирования — запись в лог.

  Зависимости:
  - uzvshxtopdfcmaptypes: типы данных этапа 5
  - uzvshxtopdfcmap: основной интерфейс
  - uzvshxtopdfcharprocstypes: типы данных этапа 4
  - uzvshxtopdfcmaptesthelper: вспомогательные функции
  - uzclog: логирование

  Module: uzvshxtopdfcmaptestduplicate
  Purpose: Unit test: duplicate code verification

  Test 3 — Duplicate codes:
    Two different glyphs cannot have the same PDF code.
    Log entry when duplicate is detected.

  Dependencies:
  - uzvshxtopdfcmaptypes: Stage 5 data types
  - uzvshxtopdfcmap: main interface
  - uzvshxtopdfcharprocstypes: Stage 4 data types
  - uzvshxtopdfcmaptesthelper: helper functions
  - uzclog: logging
}

unit uzvshxtopdfcmaptestduplicate;

{$mode objfpc}{$H+}

interface

uses
  SysUtils,
  uzvshxtopdfcmaptypes,
  uzvshxtopdfcmap,
  uzvshxtopdfcharprocstypes,
  uzvshxtopdfcmaptesthelper,
  uzclog;

// Запустить тест на дублирование кодов (Тест 3)
// Run duplicate codes test (Test 3)
function RunDuplicateCodesTest: Boolean;

// Создать тестовые данные с дубликатами (для негативного теста)
// Create test data with duplicates (for negative test)
function CreateCharProcsWithDuplicates: TUzvPdfCharProcsArray;

// Проверить отсутствие дубликатов в CMap
// Check for absence of duplicates in CMap
function CheckNoDuplicatesInCMap(const CMap: TUzvPdfToUnicodeCMap): Boolean;

implementation

const
  LOG_PREFIX = 'CMapTestDuplicate: ';

// Создать CharProc с заданным кодом
// Create CharProc with specified code
function CreateCharProcWithCode(CharCode: Integer): TUzvPdfCharProc;
begin
  Result.CharCode := CharCode;
  Result.CharName := 'g' + IntToStr(CharCode);
  Result.Stream := 'q' + #10 + '0 0 m' + #10 + '10 0 l' + #10 + 'S' + #10 + 'Q';
  Result.Width := 10.0;
  Result.BBox := CreateEmptyPdfBBox;
end;

// Создать тестовые данные с дубликатами (для негативного теста)
function CreateCharProcsWithDuplicates: TUzvPdfCharProcsArray;
begin
  // Создаём массив с намеренным дублированием кода 65
  // Create array with intentional duplicate of code 65
  SetLength(Result, 4);
  Result[0] := CreateCharProcWithCode(65);   // A
  Result[1] := CreateCharProcWithCode(66);   // B
  Result[2] := CreateCharProcWithCode(65);   // A (дубликат / duplicate)
  Result[3] := CreateCharProcWithCode(67);   // C
end;

// Проверить отсутствие дубликатов в CMap
function CheckNoDuplicatesInCMap(const CMap: TUzvPdfToUnicodeCMap): Boolean;
var
  I, J: Integer;
  DuplicateCount: Integer;
begin
  Result := True;
  DuplicateCount := 0;

  for I := 0 to High(CMap.Mappings) - 1 do
  begin
    for J := I + 1 to High(CMap.Mappings) do
    begin
      if CMap.Mappings[I].CharCode = CMap.Mappings[J].CharCode then
      begin
        Inc(DuplicateCount);
        programlog.LogOutFormatStr(
          LOG_PREFIX + 'Обнаружен дубликат: код %d на позициях %d и %d',
          [CMap.Mappings[I].CharCode, I, J],
          LM_Info
        );
        Result := False;
      end;
    end;
  end;

  if DuplicateCount > 0 then
    programlog.LogOutFormatStr(
      LOG_PREFIX + 'Всего найдено дубликатов: %d',
      [DuplicateCount],
      LM_Info
    );
end;

// Запустить тест на дублирование кодов (Тест 3)
function RunDuplicateCodesTest: Boolean;
var
  TestFont: TUzvPdfType3Font;
  CMap: TUzvPdfToUnicodeCMap;
  ValidationResult: TUzvCMapValidationResult;
  NoDuplicatesFound: Boolean;
begin
  Result := True;

  programlog.LogOutStr(
    LOG_PREFIX + 'ТЕСТ 3: Дублирование кодов - начало',
    LM_Info
  );

  // Часть 1: Проверка нормальных данных (без дубликатов)
  // Part 1: Check normal data (no duplicates)
  programlog.LogOutStr(
    LOG_PREFIX + 'Часть 1: Проверка корректных данных',
    LM_Info
  );

  TestFont := CreateTestType3FontAscii;
  CMap := BuildToUnicodeCMapSimple(TestFont);

  NoDuplicatesFound := CheckNoDuplicatesInCMap(CMap);
  if NoDuplicatesFound then
    programlog.LogOutStr(
      LOG_PREFIX + 'OK: В нормальных данных дубликатов нет',
      LM_Info
    )
  else
  begin
    programlog.LogOutStr(
      LOG_PREFIX + 'ОШИБКА: Обнаружены дубликаты в нормальных данных',
      LM_Info
    );
    Result := False;
  end;

  // Часть 2: Проверка валидации CMap
  // Part 2: Check CMap validation
  programlog.LogOutStr(
    LOG_PREFIX + 'Часть 2: Проверка валидации CMap',
    LM_Info
  );

  ValidationResult := ValidateToUnicodeCMap(CMap, TestFont.CharProcs);

  if ValidationResult.IsValid then
    programlog.LogOutStr(
      LOG_PREFIX + 'OK: Валидация CMap пройдена',
      LM_Info
    )
  else
  begin
    programlog.LogOutFormatStr(
      LOG_PREFIX + 'ПРЕДУПРЕЖДЕНИЕ: Валидация сообщила об ошибке: %s',
      [ValidationResult.ErrorMessage],
      LM_Info
    );
  end;

  if ValidationResult.DuplicateCodes > 0 then
  begin
    programlog.LogOutFormatStr(
      LOG_PREFIX + 'ОШИБКА: Валидация обнаружила %d дубликатов',
      [ValidationResult.DuplicateCodes],
      LM_Info
    );
    Result := False;
  end
  else
    programlog.LogOutStr(
      LOG_PREFIX + 'OK: Валидация не обнаружила дубликатов',
      LM_Info
    );

  // Часть 3: Проверка разных глифов с разными кодами
  // Part 3: Check different glyphs with different codes
  programlog.LogOutStr(
    LOG_PREFIX + 'Часть 3: Проверка уникальности всех кодов',
    LM_Info
  );

  TestFont := CreateTestType3FontMixed;
  CMap := BuildToUnicodeCMapSimple(TestFont);

  NoDuplicatesFound := CheckNoDuplicatesInCMap(CMap);
  if NoDuplicatesFound then
    programlog.LogOutStr(
      LOG_PREFIX + 'OK: Все коды в смешанном шрифте уникальны',
      LM_Info
    )
  else
  begin
    programlog.LogOutStr(
      LOG_PREFIX + 'ОШИБКА: Обнаружены дубликаты в смешанном шрифте',
      LM_Info
    );
    Result := False;
  end;

  // Итог
  // Summary
  if Result then
    programlog.LogOutStr(
      LOG_PREFIX + 'ТЕСТ 3: Дублирование кодов - ПРОЙДЕН',
      LM_Info
    )
  else
    programlog.LogOutStr(
      LOG_PREFIX + 'ТЕСТ 3: Дублирование кодов - ПРОВАЛЕН',
      LM_Info
    );
end;

end.
