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
  Модуль: uzvshxtopdfcharprocstestwidths
  Назначение: Unit-тест: проверка корректности ширин глифов

  Тест проверяет, что ширины глифов вычисляются корректно:
  - При явном задании ширин: Widths[i] == GlyphWidths[i]
  - При автоматическом вычислении: Widths[i] ≈ BBoxWidth[i]

  Допуск: < 0.001

  Module: uzvshxtopdfcharprocstestwidths
  Purpose: Unit test: glyph widths correctness verification

  This test verifies that glyph widths are calculated correctly:
  - With explicit widths: Widths[i] == GlyphWidths[i]
  - With auto calculation: Widths[i] ≈ BBoxWidth[i]

  Tolerance: < 0.001
}

unit uzvshxtopdfcharprocstestwidths;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Math,
  uzvshxtopdfapprogeomtypes,
  uzvshxtopdftransformtypes,
  uzvshxtopdfcharprocstypes,
  uzvshxtopdfcharprocsbbox,
  uzvshxtopdfcharprocs,
  uzvshxtopdfcharprocstestcount,
  uzclog;

// Запустить тест корректности ширин
// Run widths correctness test
function RunWidthsTest: Boolean;

implementation

const
  LOG_PREFIX = 'CharProcsTestWidths: ';
  // Допустимая погрешность
  // Tolerance
  WIDTH_TOLERANCE = 0.001;

// Запустить тест корректности ширин
function RunWidthsTest: Boolean;
var
  TestFont: TUzvWorldBezierFont;
  Type3Font: TUzvPdfType3Font;
  ExplicitWidths: array[0..2] of Double;
  I: Integer;
  ExpectedWidth, ActualWidth: Double;
  GlyphBBox: TUzvPdfBBox;
  AllWidthsCorrect: Boolean;
begin
  Result := True;

  programlog.LogOutStr(
    LOG_PREFIX + 'начало теста корректности ширин',
    LM_Info
  );

  // === Тест 1: Явные ширины ===
  // === Test 1: Explicit widths ===

  programlog.LogOutStr(
    LOG_PREFIX + 'Тест 1: явные ширины',
    LM_Info
  );

  // Создаём тестовый шрифт с 3 глифами
  // Create test font with 3 glyphs
  TestFont := CreateTestFont(3);

  // Задаём явные ширины
  // Set explicit widths
  ExplicitWidths[0] := 15.5;
  ExplicitWidths[1] := 20.0;
  ExplicitWidths[2] := 12.75;

  // Генерируем Type3 Font с явными ширинами
  // Generate Type3 Font with explicit widths
  Type3Font := BuildType3FontCharProcsSimple(TestFont, ExplicitWidths);

  // Проверяем ширины
  // Check widths
  AllWidthsCorrect := True;
  for I := 0 to 2 do
  begin
    ExpectedWidth := ExplicitWidths[I];
    // Ширины индексируются относительно FirstChar
    // Widths are indexed relative to FirstChar
    ActualWidth := Type3Font.Widths[I];

    if Abs(ActualWidth - ExpectedWidth) > WIDTH_TOLERANCE then
    begin
      programlog.LogOutFormatStr(
        LOG_PREFIX + 'ОШИБКА: глиф %d, ожидалась ширина %.4f, получена %.4f',
        [I, ExpectedWidth, ActualWidth],
        LM_Info
      );
      AllWidthsCorrect := False;
      Result := False;
    end
    else
    begin
      programlog.LogOutFormatStr(
        LOG_PREFIX + 'OK: глиф %d, ширина %.4f ≈ %.4f',
        [I, ActualWidth, ExpectedWidth],
        LM_Info
      );
    end;
  end;

  if AllWidthsCorrect then
    programlog.LogOutStr(
      LOG_PREFIX + 'Тест 1 пройден: явные ширины корректны',
      LM_Info
    );

  // === Тест 2: Автоматическое вычисление ширин ===
  // === Test 2: Automatic width calculation ===

  programlog.LogOutStr(
    LOG_PREFIX + 'Тест 2: автоматические ширины из BBox',
    LM_Info
  );

  // Генерируем Type3 Font с автоматическими ширинами
  // Generate Type3 Font with automatic widths
  Type3Font := BuildType3FontCharProcsAuto(TestFont);

  // Проверяем ширины относительно bounding box
  // Check widths against bounding box
  AllWidthsCorrect := True;
  for I := 0 to High(TestFont.Glyphs) do
  begin
    GlyphBBox := CalcGlyphBBox(TestFont.Glyphs[I]);
    ExpectedWidth := GetPdfBBoxWidth(GlyphBBox);
    ActualWidth := Type3Font.Widths[I];

    if Abs(ActualWidth - ExpectedWidth) > WIDTH_TOLERANCE then
    begin
      programlog.LogOutFormatStr(
        LOG_PREFIX + 'ОШИБКА: глиф %d, ожидалась ширина %.4f (BBox), получена %.4f',
        [I, ExpectedWidth, ActualWidth],
        LM_Info
      );
      AllWidthsCorrect := False;
      Result := False;
    end
    else
    begin
      programlog.LogOutFormatStr(
        LOG_PREFIX + 'OK: глиф %d, ширина %.4f ≈ %.4f (BBox)',
        [I, ActualWidth, ExpectedWidth],
        LM_Info
      );
    end;
  end;

  if AllWidthsCorrect then
    programlog.LogOutStr(
      LOG_PREFIX + 'Тест 2 пройден: автоматические ширины корректны',
      LM_Info
    );

  // === Тест 3: Проверка неотрицательности ширин ===
  // === Test 3: Non-negative widths verification ===

  programlog.LogOutStr(
    LOG_PREFIX + 'Тест 3: неотрицательность ширин',
    LM_Info
  );

  AllWidthsCorrect := True;
  for I := 0 to High(Type3Font.Widths) do
  begin
    if Type3Font.Widths[I] < 0 then
    begin
      programlog.LogOutFormatStr(
        LOG_PREFIX + 'ОШИБКА: отрицательная ширина %.4f для индекса %d',
        [Type3Font.Widths[I], I],
        LM_Info
      );
      AllWidthsCorrect := False;
      Result := False;
    end;
  end;

  if AllWidthsCorrect then
    programlog.LogOutStr(
      LOG_PREFIX + 'Тест 3 пройден: все ширины неотрицательны',
      LM_Info
    );

  if Result then
    programlog.LogOutStr(
      LOG_PREFIX + 'все тесты ширин пройдены успешно',
      LM_Info
    )
  else
    programlog.LogOutStr(
      LOG_PREFIX + 'ТЕСТ ШИРИН ПРОВАЛЕН',
      LM_Info
    );
end;

end.
