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
  Модуль: uzvshxtopdfcharprocstestcount
  Назначение: Unit-тест: проверка количества CharProcs

  Тест проверяет, что количество сгенерированных CharProcs
  соответствует количеству уникальных кодов символов во входном шрифте.

  Критерий успеха:
    Count(CharProcs) == Count(UniqueCodes)

  Module: uzvshxtopdfcharprocstestcount
  Purpose: Unit test: CharProcs count verification

  This test verifies that the number of generated CharProcs
  matches the number of unique character codes in input font.

  Success criterion:
    Count(CharProcs) == Count(UniqueCodes)
}

unit uzvshxtopdfcharprocstestcount;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Math,
  uzvshxtopdfapprogeomtypes,
  uzvshxtopdftransformtypes,
  uzvshxtopdfcharprocstypes,
  uzvshxtopdfcharprocs,
  uzclog;

// Запустить тест количества CharProcs
// Run CharProcs count test
function RunCharProcsCountTest: Boolean;

// Создать тестовый шрифт с заданным количеством глифов
// Create test font with specified number of glyphs
function CreateTestFont(GlyphCount: Integer): TUzvWorldBezierFont;

// Создать тестовый глиф с заданным кодом
// Create test glyph with specified code
function CreateTestGlyph(CharCode: Integer): TUzvWorldBezierGlyph;

implementation

const
  LOG_PREFIX = 'CharProcsTestCount: ';

// Создать тестовый сегмент Безье (квадрат)
// Create test Bezier segment (square)
function CreateTestSegment(X1, Y1, X2, Y2: Double): TUzvBezierSegment;
begin
  Result.P0 := MakePointF(X1, Y1);
  Result.P1 := MakePointF(X1 + (X2 - X1) / 3, Y1);
  Result.P2 := MakePointF(X1 + 2 * (X2 - X1) / 3, Y2);
  Result.P3 := MakePointF(X2, Y2);
end;

// Создать тестовый путь (простой прямоугольник)
// Create test path (simple rectangle)
function CreateTestPath(X, Y, Width, Height: Double): TUzvBezierPath;
begin
  SetLength(Result.Segments, 4);

  // Нижняя сторона
  // Bottom edge
  Result.Segments[0] := CreateTestSegment(X, Y, X + Width, Y);

  // Правая сторона
  // Right edge
  Result.Segments[1] := CreateTestSegment(X + Width, Y, X + Width, Y + Height);

  // Верхняя сторона
  // Top edge
  Result.Segments[2] := CreateTestSegment(X + Width, Y + Height, X, Y + Height);

  // Левая сторона
  // Left edge
  Result.Segments[3] := CreateTestSegment(X, Y + Height, X, Y);

  Result.IsClosed := True;
end;

// Создать тестовый глиф с заданным кодом
function CreateTestGlyph(CharCode: Integer): TUzvWorldBezierGlyph;
begin
  Result.Code := CharCode;
  SetLength(Result.Paths, 1);
  Result.Paths[0] := CreateTestPath(0, 0, 10.0, 12.0);
end;

// Создать тестовый шрифт с заданным количеством глифов
function CreateTestFont(GlyphCount: Integer): TUzvWorldBezierFont;
var
  I: Integer;
begin
  SetLength(Result.Glyphs, GlyphCount);
  for I := 0 to GlyphCount - 1 do
  begin
    // Коды символов начинаются с 65 ('A')
    // Character codes start from 65 ('A')
    Result.Glyphs[I] := CreateTestGlyph(65 + I);
  end;
end;

// Запустить тест количества CharProcs
function RunCharProcsCountTest: Boolean;
var
  TestFont: TUzvWorldBezierFont;
  Type3Font: TUzvPdfType3Font;
  UniqueCodes: TIntegerDynArray;
  TestCases: array[0..4] of Integer = (0, 1, 5, 10, 26);
  I, ExpectedCount, ActualCount: Integer;
begin
  Result := True;

  programlog.LogOutStr(
    LOG_PREFIX + 'начало теста количества CharProcs',
    LM_Info
  );

  // Тестируем различные размеры шрифтов
  // Test various font sizes
  for I := 0 to High(TestCases) do
  begin
    ExpectedCount := TestCases[I];

    // Создаём тестовый шрифт
    // Create test font
    TestFont := CreateTestFont(ExpectedCount);

    // Генерируем Type3 Font
    // Generate Type3 Font
    Type3Font := BuildType3FontCharProcsAuto(TestFont);

    // Получаем количество уникальных кодов
    // Get unique codes count
    UniqueCodes := GetUniqueCharCodes(TestFont);

    // Проверяем количество CharProcs
    // Check CharProcs count
    ActualCount := Length(Type3Font.CharProcs);

    if ActualCount <> ExpectedCount then
    begin
      programlog.LogOutFormatStr(
        LOG_PREFIX + 'ОШИБКА: ожидалось %d CharProcs, получено %d',
        [ExpectedCount, ActualCount],
        LM_Info
      );
      Result := False;
    end
    else
    begin
      programlog.LogOutFormatStr(
        LOG_PREFIX + 'OK: %d глифов -> %d CharProcs',
        [ExpectedCount, ActualCount],
        LM_Info
      );
    end;

    // Проверяем, что количество уникальных кодов совпадает
    // Verify unique codes count matches
    if Length(UniqueCodes) <> ExpectedCount then
    begin
      programlog.LogOutFormatStr(
        LOG_PREFIX + 'ОШИБКА: уникальных кодов %d, ожидалось %d',
        [Length(UniqueCodes), ExpectedCount],
        LM_Info
      );
      Result := False;
    end;
  end;

  if Result then
    programlog.LogOutStr(
      LOG_PREFIX + 'все тесты количества пройдены успешно',
      LM_Info
    )
  else
    programlog.LogOutStr(
      LOG_PREFIX + 'ТЕСТ КОЛИЧЕСТВА ПРОВАЛЕН',
      LM_Info
    );
end;

end.
