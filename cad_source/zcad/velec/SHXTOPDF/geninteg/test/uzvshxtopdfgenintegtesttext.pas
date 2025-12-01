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
  Модуль: uzvshxtopdfgenintegtesttext
  Назначение: Unit-тесты генерации текстовых блоков BT/ET для Этапа 7

  Тесты проверяют:
  - Генерацию простого текстового блока
  - Корректность операторов Tf, Tm, Tj
  - Переключение шрифтов
  - Интеграцию всех компонентов

  Module: uzvshxtopdfgenintegtesttext
  Purpose: BT/ET text block generation unit tests for Stage 7

  Tests verify:
  - Simple text block generation
  - Tf, Tm, Tj operators correctness
  - Font switching
  - All components integration
}

unit uzvshxtopdfgenintegtesttext;

{$mode objfpc}{$H+}

interface

uses
  SysUtils,
  uzvshxtopdfgenintegtypes,
  uzvshxtopdfgenintegtextwriter,
  uzvshxtopdfgeninteg,
  uzclog;

// Запустить все тесты генерации текста
// Run all text generation tests
function RunTextTests: Boolean;

// Тест 1: Простой текстовый блок BT/ET
// Test 1: Simple BT/ET text block
function TestSimpleTextBlock: Boolean;

// Тест 2: Оператор Tf
// Test 2: Tf operator
function TestTfOperator: Boolean;

// Тест 3: Оператор Tm с матрицей
// Test 3: Tm operator with matrix
function TestTmOperator: Boolean;

// Тест 4: Множественные сегменты
// Test 4: Multiple segments
function TestMultipleSegments: Boolean;

// Тест 5: Интеграция через TUzvPdfIntegrator
// Test 5: Integration through TUzvPdfIntegrator
function TestIntegrator: Boolean;

implementation

const
  LOG_PREFIX = 'GenIntegTestText: ';
  TEST_FONT = '/F1';
  TEST_FONT_SIZE = 12.0;
  TEST_X = 100.0;
  TEST_Y = 700.0;

// Тест 1: Простой текстовый блок BT/ET
function TestSimpleTextBlock: Boolean;
var
  Stream: AnsiString;
begin
  Result := False;

  programlog.LogOutStr(
    LOG_PREFIX + 'Тест 1: Простой текстовый блок BT/ET',
    LM_Info
  );

  // Генерируем простой текстовый блок
  // Generate simple text block
  Stream := GenerateSimpleTextBlock('Hello', TEST_FONT, TEST_FONT_SIZE, TEST_X, TEST_Y);

  programlog.LogOutFormatStr(
    LOG_PREFIX + 'Сгенерированный стрим:%s%s',
    [#10, Stream],
    LM_Info
  );

  // Проверка: BT в начале
  // Check: BT at the beginning
  if Pos('BT', Stream) <= 0 then
  begin
    programlog.LogOutStr(
      LOG_PREFIX + 'ОШИБКА: BT не найден в стриме',
      LM_Info
    );
    Exit;
  end;

  // Проверка: ET в конце
  // Check: ET at the end
  if Pos('ET', Stream) <= 0 then
  begin
    programlog.LogOutStr(
      LOG_PREFIX + 'ОШИБКА: ET не найден в стриме',
      LM_Info
    );
    Exit;
  end;

  // Проверка: BT до ET
  // Check: BT before ET
  if Pos('BT', Stream) > Pos('ET', Stream) then
  begin
    programlog.LogOutStr(
      LOG_PREFIX + 'ОШИБКА: BT должен быть до ET',
      LM_Info
    );
    Exit;
  end;

  programlog.LogOutStr(
    LOG_PREFIX + 'Тест 1 ПРОЙДЕН: BT/ET блок корректен',
    LM_Info
  );
  Result := True;
end;

// Тест 2: Оператор Tf
function TestTfOperator: Boolean;
var
  Stream: AnsiString;
  TfPos: Integer;
begin
  Result := False;

  programlog.LogOutStr(
    LOG_PREFIX + 'Тест 2: Оператор Tf',
    LM_Info
  );

  Stream := GenerateSimpleTextBlock('Test', TEST_FONT, TEST_FONT_SIZE, TEST_X, TEST_Y);

  // Проверка: Tf присутствует
  // Check: Tf is present
  TfPos := Pos('Tf', Stream);
  if TfPos <= 0 then
  begin
    programlog.LogOutStr(
      LOG_PREFIX + 'ОШИБКА: Tf не найден в стриме',
      LM_Info
    );
    Exit;
  end;

  // Проверка: имя шрифта присутствует
  // Check: font name is present
  if Pos(TEST_FONT, Stream) <= 0 then
  begin
    programlog.LogOutFormatStr(
      LOG_PREFIX + 'ОШИБКА: имя шрифта %s не найдено',
      [TEST_FONT],
      LM_Info
    );
    Exit;
  end;

  // Проверка: имя шрифта до Tf
  // Check: font name before Tf
  if Pos(TEST_FONT, Stream) > TfPos then
  begin
    programlog.LogOutStr(
      LOG_PREFIX + 'ОШИБКА: имя шрифта должно быть до Tf',
      LM_Info
    );
    Exit;
  end;

  programlog.LogOutStr(
    LOG_PREFIX + 'Тест 2 ПРОЙДЕН: оператор Tf корректен',
    LM_Info
  );
  Result := True;
end;

// Тест 3: Оператор Tm с матрицей
function TestTmOperator: Boolean;
var
  Stream: AnsiString;
  TmPos: Integer;
begin
  Result := False;

  programlog.LogOutStr(
    LOG_PREFIX + 'Тест 3: Оператор Tm с матрицей',
    LM_Info
  );

  Stream := GenerateSimpleTextBlock('Matrix', TEST_FONT, TEST_FONT_SIZE, TEST_X, TEST_Y);

  // Проверка: Tm присутствует
  // Check: Tm is present
  TmPos := Pos('Tm', Stream);
  if TmPos <= 0 then
  begin
    programlog.LogOutStr(
      LOG_PREFIX + 'ОШИБКА: Tm не найден в стриме',
      LM_Info
    );
    Exit;
  end;

  // Проверка: координаты присутствуют до Tm
  // Check: coordinates are present before Tm
  // Для простой матрицы: 1 0 0 1 x y Tm
  if Pos('100', Stream) <= 0 then
  begin
    programlog.LogOutStr(
      LOG_PREFIX + 'ОШИБКА: координата X не найдена',
      LM_Info
    );
    Exit;
  end;

  if Pos('700', Stream) <= 0 then
  begin
    programlog.LogOutStr(
      LOG_PREFIX + 'ОШИБКА: координата Y не найдена',
      LM_Info
    );
    Exit;
  end;

  programlog.LogOutStr(
    LOG_PREFIX + 'Тест 3 ПРОЙДЕН: оператор Tm корректен',
    LM_Info
  );
  Result := True;
end;

// Тест 4: Множественные сегменты
function TestMultipleSegments: Boolean;
var
  Writer: TUzvPdfTextWriter;
  Stream: AnsiString;
  TjCount: Integer;
  I: Integer;
begin
  Result := False;

  programlog.LogOutStr(
    LOG_PREFIX + 'Тест 4: Множественные сегменты',
    LM_Info
  );

  Writer := CreateTextWriter;
  try
    Writer.LoggingEnabled := False;

    Writer.BeginText;

    // Добавляем три текста
    // Add three texts
    Writer.WriteText('First', TEST_FONT, TEST_FONT_SIZE, 100, 700);
    Writer.WriteText('Second', TEST_FONT, TEST_FONT_SIZE, 100, 680);
    Writer.WriteText('Third', TEST_FONT, TEST_FONT_SIZE, 100, 660);

    Writer.EndText;

    Stream := Writer.GetStream;

    programlog.LogOutFormatStr(
      LOG_PREFIX + 'Стрим с 3 сегментами:%s%s',
      [#10, Stream],
      LM_Info
    );

    // Считаем количество Tj
    // Count Tj occurrences
    TjCount := 0;
    I := 1;
    while I <= Length(Stream) - 1 do
    begin
      if (Stream[I] = 'T') and (Stream[I + 1] = 'j') then
        Inc(TjCount);
      Inc(I);
    end;

    programlog.LogOutFormatStr(
      LOG_PREFIX + 'Найдено операторов Tj: %d',
      [TjCount],
      LM_Info
    );

    // Проверка: 3 оператора Tj
    // Check: 3 Tj operators
    if TjCount < 3 then
    begin
      programlog.LogOutStr(
        LOG_PREFIX + 'ОШИБКА: должно быть минимум 3 оператора Tj',
        LM_Info
      );
      Exit;
    end;

    // Проверка: счётчик сегментов
    // Check: segment counter
    if Writer.SegmentCount <> 3 then
    begin
      programlog.LogOutFormatStr(
        LOG_PREFIX + 'ОШИБКА: счётчик сегментов %d, ожидалось 3',
        [Writer.SegmentCount],
        LM_Info
      );
      Exit;
    end;

    programlog.LogOutStr(
      LOG_PREFIX + 'Тест 4 ПРОЙДЕН: множественные сегменты корректны',
      LM_Info
    );
    Result := True;

  finally
    Writer.Free;
  end;
end;

// Тест 5: Интеграция через TUzvPdfIntegrator
function TestIntegrator: Boolean;
var
  Integrator: TUzvPdfIntegrator;
  EmbedResult: TUzvPdfEmbedResult;
begin
  Result := False;

  programlog.LogOutStr(
    LOG_PREFIX + 'Тест 5: Интеграция через TUzvPdfIntegrator',
    LM_Info
  );

  Integrator := CreatePdfIntegrator;
  try
    Integrator.LoggingEnabled := False;

    // Добавляем тексты с разными шрифтами
    // Add texts with different fonts
    Integrator.AddText('Hello', 'txt.shx', 100, 700, 12);
    Integrator.AddText('World', 'simplex.shx', 100, 680, 12);
    Integrator.AddText('Again', 'txt.shx', 100, 660, 12);

    // Обрабатываем
    // Process
    Integrator.Process;

    // Получаем результат
    // Get result
    EmbedResult := Integrator.GetResult;

    programlog.LogOutFormatStr(
      LOG_PREFIX + 'Успех: %s',
      [BoolToStr(EmbedResult.Success, True)],
      LM_Info
    );
    programlog.LogOutFormatStr(
      LOG_PREFIX + 'Resources: %s',
      [EmbedResult.ResourcesDict],
      LM_Info
    );
    programlog.LogOutFormatStr(
      LOG_PREFIX + 'Статистика: шрифтов=%d, сегментов=%d, символов=%d',
      [EmbedResult.Stats.TotalFonts,
       EmbedResult.Stats.TotalSegments,
       EmbedResult.Stats.TotalCharacters],
      LM_Info
    );

    // Проверка: успешная обработка
    // Check: successful processing
    if not EmbedResult.Success then
    begin
      programlog.LogOutFormatStr(
        LOG_PREFIX + 'ОШИБКА: %s',
        [EmbedResult.ErrorMessage],
        LM_Info
      );
      Exit;
    end;

    // Проверка: 2 шрифта (txt.shx и simplex.shx)
    // Check: 2 fonts (txt.shx and simplex.shx)
    if EmbedResult.Stats.TotalFonts <> 2 then
    begin
      programlog.LogOutFormatStr(
        LOG_PREFIX + 'ОШИБКА: ожидалось 2 шрифта, получено %d',
        [EmbedResult.Stats.TotalFonts],
        LM_Info
      );
      Exit;
    end;

    // Проверка: 3 сегмента
    // Check: 3 segments
    if EmbedResult.Stats.TotalSegments <> 3 then
    begin
      programlog.LogOutFormatStr(
        LOG_PREFIX + 'ОШИБКА: ожидалось 3 сегмента, получено %d',
        [EmbedResult.Stats.TotalSegments],
        LM_Info
      );
      Exit;
    end;

    // Проверка: /F1 и /F2 в Resources
    // Check: /F1 and /F2 in Resources
    if (Pos('/F1', EmbedResult.ResourcesDict) <= 0) or
       (Pos('/F2', EmbedResult.ResourcesDict) <= 0) then
    begin
      programlog.LogOutStr(
        LOG_PREFIX + 'ОШИБКА: /F1 и /F2 должны быть в Resources',
        LM_Info
      );
      Exit;
    end;

    programlog.LogOutStr(
      LOG_PREFIX + 'Тест 5 ПРОЙДЕН: интеграция корректна',
      LM_Info
    );
    Result := True;

  finally
    Integrator.Free;
  end;
end;

// Запустить все тесты генерации текста
function RunTextTests: Boolean;
var
  Test1, Test2, Test3, Test4, Test5: Boolean;
begin
  programlog.LogOutStr(
    LOG_PREFIX + '=== Начало тестов генерации текста ===',
    LM_Info
  );

  Test1 := TestSimpleTextBlock;
  Test2 := TestTfOperator;
  Test3 := TestTmOperator;
  Test4 := TestMultipleSegments;
  Test5 := TestIntegrator;

  Result := Test1 and Test2 and Test3 and Test4 and Test5;

  if Result then
    programlog.LogOutStr(
      LOG_PREFIX + '=== Все тесты генерации текста ПРОЙДЕНЫ ===',
      LM_Info
    )
  else
    programlog.LogOutStr(
      LOG_PREFIX + '=== ОШИБКА: некоторые тесты провалены ===',
      LM_Info
    );
end;

end.
