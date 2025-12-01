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
  Модуль: uzvshxtopdfgenintegtestfont
  Назначение: Unit-тесты регистрации шрифтов для Этапа 7

  Тесты проверяют:
  - Регистрацию одного шрифта (Test 1)
  - Регистрацию двух разных SHX (Test 2)
  - Корректность словаря /Resources /Font

  Module: uzvshxtopdfgenintegtestfont
  Purpose: Font registration unit tests for Stage 7

  Tests verify:
  - Single font registration (Test 1)
  - Two different SHX fonts registration (Test 2)
  - /Resources /Font dictionary correctness
}

unit uzvshxtopdfgenintegtestfont;

{$mode objfpc}{$H+}

interface

uses
  SysUtils,
  uzvshxtopdfgenintegtypes,
  uzvshxtopdfgenintegfontbind,
  uzvshxtopdfgeninteg,
  uzclog;

// Запустить все тесты регистрации шрифтов
// Run all font registration tests
function RunFontTests: Boolean;

// Тест 1: Регистрация одного шрифта
// Test 1: Single font registration
function TestSingleFontRegistration: Boolean;

// Тест 2: Два разных SHX
// Test 2: Two different SHX
function TestTwoFontsRegistration: Boolean;

// Тест 3: Повторная регистрация того же шрифта
// Test 3: Re-registration of the same font
function TestDuplicateFontRegistration: Boolean;

// Тест 4: Построение словаря /Font
// Test 4: Building /Font dictionary
function TestFontDictionary: Boolean;

implementation

const
  LOG_PREFIX = 'GenIntegTestFont: ';
  TEST_FONT_1 = 'txt.shx';
  TEST_FONT_2 = 'simplex.shx';
  TEST_REF_1 = '10 0 R';
  TEST_REF_2 = '11 0 R';

// Тест 1: Регистрация одного шрифта
function TestSingleFontRegistration: Boolean;
var
  Manager: TUzvFontBindManager;
  Binding: TUzvPdfFontBinding;
begin
  Result := False;

  programlog.LogOutStr(
    LOG_PREFIX + 'Тест 1: Регистрация одного шрифта',
    LM_Info
  );

  Manager := CreateFontBindManager;
  try
    Manager.LoggingEnabled := False;

    // Регистрируем шрифт
    // Register font
    Binding := Manager.BindFont(TEST_FONT_1, TEST_REF_1);

    // Проверка: PDF-имя должно быть /F1
    // Check: PDF name should be /F1
    if Binding.PdfFontName <> '/F1' then
    begin
      programlog.LogOutFormatStr(
        LOG_PREFIX + 'ОШИБКА: ожидалось /F1, получено %s',
        [Binding.PdfFontName],
        LM_Info
      );
      Exit;
    end;

    // Проверка: количество шрифтов = 1
    // Check: font count = 1
    if Manager.FontCount <> 1 then
    begin
      programlog.LogOutFormatStr(
        LOG_PREFIX + 'ОШИБКА: ожидалось 1 шрифт, получено %d',
        [Manager.FontCount],
        LM_Info
      );
      Exit;
    end;

    // Проверка: шрифт зарегистрирован
    // Check: font is bound
    if not Manager.IsFontBound(TEST_FONT_1) then
    begin
      programlog.LogOutStr(
        LOG_PREFIX + 'ОШИБКА: шрифт не зарегистрирован',
        LM_Info
      );
      Exit;
    end;

    programlog.LogOutStr(
      LOG_PREFIX + 'Тест 1 ПРОЙДЕН: один шрифт корректно зарегистрирован',
      LM_Info
    );
    Result := True;

  finally
    Manager.Free;
  end;
end;

// Тест 2: Два разных SHX
function TestTwoFontsRegistration: Boolean;
var
  Manager: TUzvFontBindManager;
  Binding1, Binding2: TUzvPdfFontBinding;
begin
  Result := False;

  programlog.LogOutStr(
    LOG_PREFIX + 'Тест 2: Два разных SHX',
    LM_Info
  );

  Manager := CreateFontBindManager;
  try
    Manager.LoggingEnabled := False;

    // Регистрируем два шрифта
    // Register two fonts
    Binding1 := Manager.BindFont(TEST_FONT_1, TEST_REF_1);
    Binding2 := Manager.BindFont(TEST_FONT_2, TEST_REF_2);

    // Проверка: /F1 и /F2 существуют
    // Check: /F1 and /F2 exist
    if Binding1.PdfFontName <> '/F1' then
    begin
      programlog.LogOutFormatStr(
        LOG_PREFIX + 'ОШИБКА: первый шрифт не /F1, а %s',
        [Binding1.PdfFontName],
        LM_Info
      );
      Exit;
    end;

    if Binding2.PdfFontName <> '/F2' then
    begin
      programlog.LogOutFormatStr(
        LOG_PREFIX + 'ОШИБКА: второй шрифт не /F2, а %s',
        [Binding2.PdfFontName],
        LM_Info
      );
      Exit;
    end;

    // Проверка: количество шрифтов = 2
    // Check: font count = 2
    if Manager.FontCount <> 2 then
    begin
      programlog.LogOutFormatStr(
        LOG_PREFIX + 'ОШИБКА: ожидалось 2 шрифта, получено %d',
        [Manager.FontCount],
        LM_Info
      );
      Exit;
    end;

    // Проверка: оба шрифта зарегистрированы
    // Check: both fonts are bound
    if not Manager.IsFontBound(TEST_FONT_1) or
       not Manager.IsFontBound(TEST_FONT_2) then
    begin
      programlog.LogOutStr(
        LOG_PREFIX + 'ОШИБКА: не все шрифты зарегистрированы',
        LM_Info
      );
      Exit;
    end;

    programlog.LogOutStr(
      LOG_PREFIX + 'Тест 2 ПРОЙДЕН: два шрифта корректно зарегистрированы',
      LM_Info
    );
    Result := True;

  finally
    Manager.Free;
  end;
end;

// Тест 3: Повторная регистрация того же шрифта
function TestDuplicateFontRegistration: Boolean;
var
  Manager: TUzvFontBindManager;
  Binding1, Binding2: TUzvPdfFontBinding;
begin
  Result := False;

  programlog.LogOutStr(
    LOG_PREFIX + 'Тест 3: Повторная регистрация того же шрифта',
    LM_Info
  );

  Manager := CreateFontBindManager;
  try
    Manager.LoggingEnabled := False;

    // Регистрируем шрифт дважды
    // Register font twice
    Binding1 := Manager.BindFont(TEST_FONT_1, TEST_REF_1);
    Binding2 := Manager.BindFont(TEST_FONT_1, TEST_REF_2);  // Тот же шрифт

    // Проверка: должна вернуться та же привязка
    // Check: should return same binding
    if Binding1.PdfFontName <> Binding2.PdfFontName then
    begin
      programlog.LogOutFormatStr(
        LOG_PREFIX + 'ОШИБКА: привязки разные: %s и %s',
        [Binding1.PdfFontName, Binding2.PdfFontName],
        LM_Info
      );
      Exit;
    end;

    // Проверка: количество шрифтов = 1
    // Check: font count = 1
    if Manager.FontCount <> 1 then
    begin
      programlog.LogOutFormatStr(
        LOG_PREFIX + 'ОШИБКА: ожидалось 1 шрифт, получено %d',
        [Manager.FontCount],
        LM_Info
      );
      Exit;
    end;

    programlog.LogOutStr(
      LOG_PREFIX + 'Тест 3 ПРОЙДЕН: дубликат игнорируется',
      LM_Info
    );
    Result := True;

  finally
    Manager.Free;
  end;
end;

// Тест 4: Построение словаря /Font
function TestFontDictionary: Boolean;
var
  Manager: TUzvFontBindManager;
  Dict: AnsiString;
begin
  Result := False;

  programlog.LogOutStr(
    LOG_PREFIX + 'Тест 4: Построение словаря /Font',
    LM_Info
  );

  Manager := CreateFontBindManager;
  try
    Manager.LoggingEnabled := False;

    // Регистрируем два шрифта
    // Register two fonts
    Manager.BindFont(TEST_FONT_1, TEST_REF_1);
    Manager.BindFont(TEST_FONT_2, TEST_REF_2);

    // Строим словарь
    // Build dictionary
    Dict := Manager.BuildResourcesDict;

    programlog.LogOutFormatStr(
      LOG_PREFIX + 'Словарь: %s',
      [Dict],
      LM_Info
    );

    // Проверка: словарь содержит оба шрифта
    // Check: dictionary contains both fonts
    if Pos('/F1', Dict) <= 0 then
    begin
      programlog.LogOutStr(
        LOG_PREFIX + 'ОШИБКА: /F1 не найден в словаре',
        LM_Info
      );
      Exit;
    end;

    if Pos('/F2', Dict) <= 0 then
    begin
      programlog.LogOutStr(
        LOG_PREFIX + 'ОШИБКА: /F2 не найден в словаре',
        LM_Info
      );
      Exit;
    end;

    if Pos(TEST_REF_1, Dict) <= 0 then
    begin
      programlog.LogOutStr(
        LOG_PREFIX + 'ОШИБКА: ссылка ' + TEST_REF_1 + ' не найдена в словаре',
        LM_Info
      );
      Exit;
    end;

    if Pos(TEST_REF_2, Dict) <= 0 then
    begin
      programlog.LogOutStr(
        LOG_PREFIX + 'ОШИБКА: ссылка ' + TEST_REF_2 + ' не найдена в словаре',
        LM_Info
      );
      Exit;
    end;

    programlog.LogOutStr(
      LOG_PREFIX + 'Тест 4 ПРОЙДЕН: словарь /Font корректен',
      LM_Info
    );
    Result := True;

  finally
    Manager.Free;
  end;
end;

// Запустить все тесты регистрации шрифтов
function RunFontTests: Boolean;
var
  Test1, Test2, Test3, Test4: Boolean;
begin
  programlog.LogOutStr(
    LOG_PREFIX + '=== Начало тестов регистрации шрифтов ===',
    LM_Info
  );

  Test1 := TestSingleFontRegistration;
  Test2 := TestTwoFontsRegistration;
  Test3 := TestDuplicateFontRegistration;
  Test4 := TestFontDictionary;

  Result := Test1 and Test2 and Test3 and Test4;

  if Result then
    programlog.LogOutStr(
      LOG_PREFIX + '=== Все тесты регистрации шрифтов ПРОЙДЕНЫ ===',
      LM_Info
    )
  else
    programlog.LogOutStr(
      LOG_PREFIX + '=== ОШИБКА: некоторые тесты провалены ===',
      LM_Info
    );
end;

end.
