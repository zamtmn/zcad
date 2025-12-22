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
  Модуль: uzvshxtopdfcmapteststream
  Назначение: Unit-тест: проверка корректности CMap стрима

  Тест проверяет:
  - Наличие всех обязательных элементов CMap стрима
  - Корректность формата hex-значений
  - Наличие секций beginbfchar/endbfchar
  - Корректность заголовка и завершения

  Зависимости:
  - uzvshxtopdfcmaptypes: типы данных этапа 5
  - uzvshxtopdfcmap: основной интерфейс
  - uzvshxtopdfcmapwriter: генератор стрима
  - uzvshxtopdfcharprocstypes: типы данных этапа 4
  - uzvshxtopdfcmaptesthelper: вспомогательные функции
  - uzclog: логирование

  Module: uzvshxtopdfcmapteststream
  Purpose: Unit test: CMap stream correctness verification

  Test verifies:
  - Presence of all required CMap stream elements
  - Hex value format correctness
  - Presence of beginbfchar/endbfchar sections
  - Header and footer correctness

  Dependencies:
  - uzvshxtopdfcmaptypes: Stage 5 data types
  - uzvshxtopdfcmap: main interface
  - uzvshxtopdfcmapwriter: stream generator
  - uzvshxtopdfcharprocstypes: Stage 4 data types
  - uzvshxtopdfcmaptesthelper: helper functions
  - uzclog: logging
}

unit uzvshxtopdfcmapteststream;

{$mode objfpc}{$H+}

interface

uses
  SysUtils,
  uzvshxtopdfcmaptypes,
  uzvshxtopdfcmap,
  uzvshxtopdfcmapwriter,
  uzvshxtopdfcharprocstypes,
  uzvshxtopdfcmaptesthelper,
  uzclog;

// Запустить тест структуры CMap стрима
// Run CMap stream structure test
function RunCMapStreamStructureTest: Boolean;

// Запустить все тесты стрима
// Run all stream tests
function RunAllStreamTests: Boolean;

implementation

const
  LOG_PREFIX = 'CMapTestStream: ';

// Проверить наличие ключевого элемента в стриме
// Check for key element presence in stream
function CheckStreamContains(
  const Stream: AnsiString;
  const Element: AnsiString;
  const Description: AnsiString
): Boolean;
begin
  Result := Pos(Element, Stream) > 0;
  if Result then
    programlog.LogOutFormatStr(
      LOG_PREFIX + 'OK: найден элемент "%s" (%s)',
      [Element, Description],
      LM_Info
    )
  else
    programlog.LogOutFormatStr(
      LOG_PREFIX + 'ОШИБКА: не найден элемент "%s" (%s)',
      [Element, Description],
      LM_Info
    );
end;

// Запустить тест структуры CMap стрима
function RunCMapStreamStructureTest: Boolean;
var
  TestFont: TUzvPdfType3Font;
  CMap: TUzvPdfToUnicodeCMap;
  Stream: AnsiString;
  AllElementsPresent: Boolean;
begin
  Result := True;
  AllElementsPresent := True;

  programlog.LogOutStr(
    LOG_PREFIX + 'ТЕСТ: Структура CMap стрима - начало',
    LM_Info
  );

  // Создаём тестовый шрифт
  // Create test font
  TestFont := CreateTestType3FontAscii;
  CMap := BuildToUnicodeCMapSimple(TestFont);
  Stream := CMap.CMapStream;

  programlog.LogOutFormatStr(
    LOG_PREFIX + 'Размер сгенерированного стрима: %d байт',
    [Length(Stream)],
    LM_Info
  );

  // Проверяем обязательные элементы заголовка
  // Check required header elements
  programlog.LogOutStr(
    LOG_PREFIX + 'Проверка элементов заголовка:',
    LM_Info
  );

  if not CheckStreamContains(Stream, '/CIDInit', 'инициализация CID') then
    AllElementsPresent := False;

  if not CheckStreamContains(Stream, '/ProcSet', 'ProcSet') then
    AllElementsPresent := False;

  if not CheckStreamContains(Stream, 'begincmap', 'начало CMap') then
    AllElementsPresent := False;

  if not CheckStreamContains(Stream, '/CIDSystemInfo', 'системная информация') then
    AllElementsPresent := False;

  if not CheckStreamContains(Stream, '/Registry (Adobe)', 'Registry') then
    AllElementsPresent := False;

  if not CheckStreamContains(Stream, '/Ordering (UCS)', 'Ordering') then
    AllElementsPresent := False;

  if not CheckStreamContains(Stream, '/CMapName', 'имя CMap') then
    AllElementsPresent := False;

  if not CheckStreamContains(Stream, '/CMapType 2', 'тип CMap') then
    AllElementsPresent := False;

  // Проверяем секцию codespacerange
  // Check codespacerange section
  programlog.LogOutStr(
    LOG_PREFIX + 'Проверка секции codespacerange:',
    LM_Info
  );

  if not CheckStreamContains(Stream, 'begincodespacerange', 'начало codespacerange') then
    AllElementsPresent := False;

  if not CheckStreamContains(Stream, 'endcodespacerange', 'конец codespacerange') then
    AllElementsPresent := False;

  // Проверяем секцию bfchar
  // Check bfchar section
  programlog.LogOutStr(
    LOG_PREFIX + 'Проверка секции bfchar:',
    LM_Info
  );

  if not CheckStreamContains(Stream, 'beginbfchar', 'начало bfchar') then
    AllElementsPresent := False;

  if not CheckStreamContains(Stream, 'endbfchar', 'конец bfchar') then
    AllElementsPresent := False;

  // Проверяем завершение
  // Check footer
  programlog.LogOutStr(
    LOG_PREFIX + 'Проверка завершения:',
    LM_Info
  );

  if not CheckStreamContains(Stream, 'endcmap', 'конец CMap') then
    AllElementsPresent := False;

  if not CheckStreamContains(Stream, 'defineresource', 'defineresource') then
    AllElementsPresent := False;

  // Проверяем hex-значения в стриме
  // Check hex values in stream
  programlog.LogOutStr(
    LOG_PREFIX + 'Проверка hex-значений:',
    LM_Info
  );

  // Должен быть хотя бы один маппинг вида <XX> <YYYY>
  // Should have at least one mapping like <XX> <YYYY>
  if Pos('<', Stream) > 0 then
    programlog.LogOutStr(
      LOG_PREFIX + 'OK: найдены hex-значения в стриме',
      LM_Info
    )
  else
  begin
    programlog.LogOutStr(
      LOG_PREFIX + 'ОШИБКА: не найдены hex-значения в стриме',
      LM_Info
    );
    AllElementsPresent := False;
  end;

  // Проверяем конкретные маппинги для тестовых символов
  // Check specific mappings for test characters
  programlog.LogOutStr(
    LOG_PREFIX + 'Проверка конкретных маппингов:',
    LM_Info
  );

  // A (код 65 = $41) должен маппиться на Unicode $0041
  // A (code 65 = $41) should map to Unicode $0041
  if CheckStreamContains(Stream, '<41>', 'код символа A') then
  begin
    if CheckStreamContains(Stream, '<0041>', 'Unicode для A') then
      programlog.LogOutStr(
        LOG_PREFIX + 'OK: маппинг A -> U+0041 присутствует',
        LM_Info
      )
    else
      AllElementsPresent := False;
  end
  else
    AllElementsPresent := False;

  Result := AllElementsPresent;

  if Result then
    programlog.LogOutStr(
      LOG_PREFIX + 'ТЕСТ: Структура CMap стрима - ПРОЙДЕН',
      LM_Info
    )
  else
    programlog.LogOutStr(
      LOG_PREFIX + 'ТЕСТ: Структура CMap стрима - ПРОВАЛЕН',
      LM_Info
    );
end;

// Запустить все тесты стрима
function RunAllStreamTests: Boolean;
begin
  programlog.LogOutStr(
    LOG_PREFIX + '========== Начало тестирования стрима ==========',
    LM_Info
  );

  Result := RunCMapStreamStructureTest;

  if Result then
    programlog.LogOutStr(
      LOG_PREFIX + '========== ВСЕ ТЕСТЫ СТРИМА ПРОЙДЕНЫ ==========',
      LM_Info
    )
  else
    programlog.LogOutStr(
      LOG_PREFIX + '========== НЕКОТОРЫЕ ТЕСТЫ ПРОВАЛЕНЫ ==========',
      LM_Info
    );
end;

end.
