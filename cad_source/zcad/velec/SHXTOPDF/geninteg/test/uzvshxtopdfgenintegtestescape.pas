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
  Модуль: uzvshxtopdfgenintegtestescape
  Назначение: Unit-тесты escape-последовательностей для Этапа 7

  Тесты проверяют (Test 3 из ТЗ):
  - Экранирование скобок \( и \)
  - Экранирование обратного слэша \\
  - Обработка строки с комбинацией спецсимволов

  Пример из ТЗ: строка (A\B(C)) должна быть корректно экранирована

  Module: uzvshxtopdfgenintegtestescape
  Purpose: Escape sequence unit tests for Stage 7

  Tests verify (Test 3 from specification):
  - Parentheses escaping \( and \)
  - Backslash escaping \\
  - String processing with special character combinations
}

unit uzvshxtopdfgenintegtestescape;

{$mode objfpc}{$H+}

interface

uses
  SysUtils,
  uzvshxtopdfgenintegescape,
  uzclog;

// Запустить все тесты escape-последовательностей
// Run all escape sequence tests
function RunEscapeTests: Boolean;

// Тест 1: Экранирование скобок
// Test 1: Parentheses escaping
function TestParenthesesEscaping: Boolean;

// Тест 2: Экранирование обратного слэша
// Test 2: Backslash escaping
function TestBackslashEscaping: Boolean;

// Тест 3: Комбинация спецсимволов (A\B(C))
// Test 3: Special character combination (A\B(C))
function TestSpecialCharCombination: Boolean;

// Тест 4: Обычный текст без спецсимволов
// Test 4: Regular text without special characters
function TestRegularText: Boolean;

// Тест 5: Непечатные символы
// Test 5: Non-printable characters
function TestNonPrintableChars: Boolean;

// Тест 6: Преобразование в hex
// Test 6: Hex conversion
function TestHexConversion: Boolean;

implementation

const
  LOG_PREFIX = 'GenIntegTestEscape: ';

// Тест 1: Экранирование скобок
function TestParenthesesEscaping: Boolean;
var
  Input, Output, Expected: AnsiString;
begin
  Result := False;

  programlog.LogOutStr(
    LOG_PREFIX + 'Тест 1: Экранирование скобок',
    LM_Info
  );

  // Тест открывающей скобки
  // Test opening parenthesis
  Input := '(';
  Output := EscapePdfLiteralString(Input);
  Expected := '\(';

  if Output <> Expected then
  begin
    programlog.LogOutFormatStr(
      LOG_PREFIX + 'ОШИБКА: "(" -> "%s", ожидалось "%s"',
      [Output, Expected],
      LM_Info
    );
    Exit;
  end;

  // Тест закрывающей скобки
  // Test closing parenthesis
  Input := ')';
  Output := EscapePdfLiteralString(Input);
  Expected := '\)';

  if Output <> Expected then
  begin
    programlog.LogOutFormatStr(
      LOG_PREFIX + 'ОШИБКА: ")" -> "%s", ожидалось "%s"',
      [Output, Expected],
      LM_Info
    );
    Exit;
  end;

  // Тест вложенных скобок
  // Test nested parentheses
  Input := '(a(b)c)';
  Output := EscapePdfLiteralString(Input);
  Expected := '\(a\(b\)c\)';

  if Output <> Expected then
  begin
    programlog.LogOutFormatStr(
      LOG_PREFIX + 'ОШИБКА: "(a(b)c)" -> "%s", ожидалось "%s"',
      [Output, Expected],
      LM_Info
    );
    Exit;
  end;

  programlog.LogOutStr(
    LOG_PREFIX + 'Тест 1 ПРОЙДЕН: скобки экранируются корректно',
    LM_Info
  );
  Result := True;
end;

// Тест 2: Экранирование обратного слэша
function TestBackslashEscaping: Boolean;
var
  Input, Output, Expected: AnsiString;
begin
  Result := False;

  programlog.LogOutStr(
    LOG_PREFIX + 'Тест 2: Экранирование обратного слэша',
    LM_Info
  );

  // Тест одиночного слэша
  // Test single backslash
  Input := '\';
  Output := EscapePdfLiteralString(Input);
  Expected := '\\';

  if Output <> Expected then
  begin
    programlog.LogOutFormatStr(
      LOG_PREFIX + 'ОШИБКА: "\" -> "%s", ожидалось "%s"',
      [Output, Expected],
      LM_Info
    );
    Exit;
  end;

  // Тест нескольких слэшей
  // Test multiple backslashes
  Input := 'a\b\c';
  Output := EscapePdfLiteralString(Input);
  Expected := 'a\\b\\c';

  if Output <> Expected then
  begin
    programlog.LogOutFormatStr(
      LOG_PREFIX + 'ОШИБКА: "a\b\c" -> "%s", ожидалось "%s"',
      [Output, Expected],
      LM_Info
    );
    Exit;
  end;

  programlog.LogOutStr(
    LOG_PREFIX + 'Тест 2 ПРОЙДЕН: обратный слэш экранируется корректно',
    LM_Info
  );
  Result := True;
end;

// Тест 3: Комбинация спецсимволов (A\B(C))
function TestSpecialCharCombination: Boolean;
var
  Input, Output, Expected: AnsiString;
  Wrapped: AnsiString;
begin
  Result := False;

  programlog.LogOutStr(
    LOG_PREFIX + 'Тест 3: Комбинация спецсимволов (A\B(C))',
    LM_Info
  );

  // Входная строка из ТЗ: (A\B(C))
  // Input string from specification: (A\B(C))
  Input := '(A\B(C))';
  Output := EscapePdfLiteralString(Input);
  Expected := '\(A\\B\(C\)\)';

  programlog.LogOutFormatStr(
    LOG_PREFIX + 'Вход: "%s"',
    [Input],
    LM_Info
  );
  programlog.LogOutFormatStr(
    LOG_PREFIX + 'Выход: "%s"',
    [Output],
    LM_Info
  );
  programlog.LogOutFormatStr(
    LOG_PREFIX + 'Ожидалось: "%s"',
    [Expected],
    LM_Info
  );

  if Output <> Expected then
  begin
    programlog.LogOutStr(
      LOG_PREFIX + 'ОШИБКА: результат не соответствует ожиданию',
      LM_Info
    );
    Exit;
  end;

  // Проверка обёртки в скобки
  // Check wrapping in parentheses
  Wrapped := WrapInPdfParens(Input);
  programlog.LogOutFormatStr(
    LOG_PREFIX + 'В PDF-скобках: %s',
    [Wrapped],
    LM_Info
  );

  if Pos('(' + Expected + ')', Wrapped) <= 0 then
  begin
    programlog.LogOutStr(
      LOG_PREFIX + 'ОШИБКА: неверная обёртка в скобки',
      LM_Info
    );
    Exit;
  end;

  programlog.LogOutStr(
    LOG_PREFIX + 'Тест 3 ПРОЙДЕН: комбинация спецсимволов обработана корректно',
    LM_Info
  );
  Result := True;
end;

// Тест 4: Обычный текст без спецсимволов
function TestRegularText: Boolean;
var
  Input, Output: AnsiString;
begin
  Result := False;

  programlog.LogOutStr(
    LOG_PREFIX + 'Тест 4: Обычный текст без спецсимволов',
    LM_Info
  );

  // Обычный текст не должен измениться
  // Regular text should not change
  Input := 'Hello World 123';
  Output := EscapePdfLiteralString(Input);

  if Output <> Input then
  begin
    programlog.LogOutFormatStr(
      LOG_PREFIX + 'ОШИБКА: "%s" изменился на "%s"',
      [Input, Output],
      LM_Info
    );
    Exit;
  end;

  // Кириллица (байты > 127) будет экранирована
  // Cyrillic (bytes > 127) will be escaped
  // Это ожидаемое поведение

  programlog.LogOutStr(
    LOG_PREFIX + 'Тест 4 ПРОЙДЕН: обычный текст не изменяется',
    LM_Info
  );
  Result := True;
end;

// Тест 5: Непечатные символы
function TestNonPrintableChars: Boolean;
var
  Input, Output: AnsiString;
begin
  Result := False;

  programlog.LogOutStr(
    LOG_PREFIX + 'Тест 5: Непечатные символы',
    LM_Info
  );

  // Тест символа табуляции
  // Test tab character
  Input := 'a' + #9 + 'b';
  Output := EscapePdfLiteralString(Input);

  if Pos('\t', Output) <= 0 then
  begin
    programlog.LogOutStr(
      LOG_PREFIX + 'ОШИБКА: табуляция не экранирована',
      LM_Info
    );
    Exit;
  end;

  // Тест символа переноса строки
  // Test line feed character
  Input := 'a' + #10 + 'b';
  Output := EscapePdfLiteralString(Input);

  if Pos('\n', Output) <= 0 then
  begin
    programlog.LogOutStr(
      LOG_PREFIX + 'ОШИБКА: перенос строки не экранирован',
      LM_Info
    );
    Exit;
  end;

  // Тест символа возврата каретки
  // Test carriage return character
  Input := 'a' + #13 + 'b';
  Output := EscapePdfLiteralString(Input);

  if Pos('\r', Output) <= 0 then
  begin
    programlog.LogOutStr(
      LOG_PREFIX + 'ОШИБКА: возврат каретки не экранирован',
      LM_Info
    );
    Exit;
  end;

  programlog.LogOutStr(
    LOG_PREFIX + 'Тест 5 ПРОЙДЕН: непечатные символы экранируются',
    LM_Info
  );
  Result := True;
end;

// Тест 6: Преобразование в hex
function TestHexConversion: Boolean;
var
  Input, Output: AnsiString;
begin
  Result := False;

  programlog.LogOutStr(
    LOG_PREFIX + 'Тест 6: Преобразование в hex',
    LM_Info
  );

  // Простая строка
  // Simple string
  Input := 'AB';
  Output := StringToHexPdf(Input);

  // A=0x41, B=0x42
  if Output <> '4142' then
  begin
    programlog.LogOutFormatStr(
      LOG_PREFIX + 'ОШИБКА: "AB" -> "%s", ожидалось "4142"',
      [Output],
      LM_Info
    );
    Exit;
  end;

  // Обёртка в угловые скобки
  // Wrap in angle brackets
  Output := WrapInHexBrackets(Output);

  if Output <> '<4142>' then
  begin
    programlog.LogOutFormatStr(
      LOG_PREFIX + 'ОШИБКА: обёртка -> "%s", ожидалось "<4142>"',
      [Output],
      LM_Info
    );
    Exit;
  end;

  programlog.LogOutStr(
    LOG_PREFIX + 'Тест 6 ПРОЙДЕН: hex-преобразование корректно',
    LM_Info
  );
  Result := True;
end;

// Запустить все тесты escape-последовательностей
function RunEscapeTests: Boolean;
var
  Test1, Test2, Test3, Test4, Test5, Test6: Boolean;
begin
  programlog.LogOutStr(
    LOG_PREFIX + '=== Начало тестов escape-последовательностей ===',
    LM_Info
  );

  Test1 := TestParenthesesEscaping;
  Test2 := TestBackslashEscaping;
  Test3 := TestSpecialCharCombination;
  Test4 := TestRegularText;
  Test5 := TestNonPrintableChars;
  Test6 := TestHexConversion;

  Result := Test1 and Test2 and Test3 and Test4 and Test5 and Test6;

  if Result then
    programlog.LogOutStr(
      LOG_PREFIX + '=== Все тесты escape-последовательностей ПРОЙДЕНЫ ===',
      LM_Info
    )
  else
    programlog.LogOutStr(
      LOG_PREFIX + '=== ОШИБКА: некоторые тесты провалены ===',
      LM_Info
    );
end;

end.
