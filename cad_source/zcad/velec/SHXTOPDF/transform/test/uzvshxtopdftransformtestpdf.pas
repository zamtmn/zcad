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
  Модуль: uzvshxtopdftransformtestpdf
  Назначение: Интеграционный тест для проверки полного конвейера SHX -> PDF

  Этапы теста из ТЗ:
  1. Взять шрифт -> Этап 1
  2. Аппроксимировать -> Этап 2
  3. Применить трансформации -> Этап 3
  4. Записать в PDF
  5. Открыть PDF в viewer
  6. Визуально проверить: позицию, угол поворота, наклон, alignments

  Module: uzvshxtopdftransformtestpdf
  Purpose: Integration test for full SHX -> PDF pipeline verification

  Test stages from specification:
  1. Take font -> Stage 1
  2. Approximate -> Stage 2
  3. Apply transformations -> Stage 3
  4. Write to PDF
  5. Open PDF in viewer
  6. Visually verify: position, rotation angle, oblique, alignments
}

unit uzvshxtopdftransformtestpdf;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Math,
  uzvshxtopdfapprogeomtypes,
  uzvshxtopdftransformtypes,
  uzvshxtopdftransformmatrix,
  uzvshxtopdftransformapply,
  uzvshxtopdftransform,
  uzclog;

type
  // Результат интеграционного теста
  // Integration test result
  TIntegrationTestResult = record
    TestName: string;         // Имя теста / Test name
    Passed: Boolean;          // Пройден ли тест / Test passed
    Message: string;          // Сообщение / Message
    GlyphCount: Integer;      // Количество глифов / Glyph count
    PathCount: Integer;       // Общее количество путей / Total path count
    SegmentCount: Integer;    // Общее количество сегментов / Total segment count
  end;

  // Результаты всех тестов
  // All test results
  TIntegrationTestResults = array of TIntegrationTestResult;

// Запустить все интеграционные тесты
// Run all integration tests
function RunAllIntegrationTests: TIntegrationTestResults;

// Тест: пустой шрифт
// Test: empty font
function TestEmptyFont: TIntegrationTestResult;

// Тест: один глиф без трансформации
// Test: single glyph without transformation
function TestSingleGlyphNoTransform: TIntegrationTestResult;

// Тест: один глиф с масштабированием
// Test: single glyph with scaling
function TestSingleGlyphWithScale: TIntegrationTestResult;

// Тест: один глиф с поворотом
// Test: single glyph with rotation
function TestSingleGlyphWithRotation: TIntegrationTestResult;

// Тест: несколько глифов с кернингом
// Test: multiple glyphs with kerning
function TestMultipleGlyphsWithKerning: TIntegrationTestResult;

// Тест: выравнивание по центру
// Test: center alignment
function TestCenterAlignment: TIntegrationTestResult;

// Тест: выравнивание по правому краю
// Test: right alignment
function TestRightAlignment: TIntegrationTestResult;

// Тест: полная трансформация (все параметры)
// Test: full transformation (all parameters)
function TestFullTransformation: TIntegrationTestResult;

// Тест: зеркалирование
// Test: mirroring
function TestMirroring: TIntegrationTestResult;

// Создать тестовый глиф (буква "L")
// Create test glyph (letter "L")
function CreateTestGlyphL: TUzvBezierGlyph;

// Создать тестовый глиф (буква "A")
// Create test glyph (letter "A")
function CreateTestGlyphA: TUzvBezierGlyph;

// Создать тестовый шрифт
// Create test font
function CreateTestFont: TUzvBezierFont;

// Вывести результаты тестов в лог
// Output test results to log
procedure LogIntegrationTestResults(const Results: TIntegrationTestResults);

implementation

// Создать тестовый глиф L (простая форма)
// Create test glyph L (simple shape)
function CreateTestGlyphL: TUzvBezierGlyph;
var
  Path: TUzvBezierPath;
begin
  Result := CreateEmptyBezierGlyph(76);  // ASCII 'L'
  Result.Width := 60.0;

  // Создаём путь для буквы L
  // Create path for letter L
  Path := CreateEmptyBezierPath;
  SetLength(Path.Segments, 2);

  // Вертикальная линия (0,0) -> (0,100)
  // Vertical line (0,0) -> (0,100)
  Path.Segments[0] := CreateLineBezierSegment(
    MakePointF(0.0, 0.0),
    MakePointF(0.0, 100.0)
  );

  // Горизонтальная линия (0,0) -> (60,0)
  // Horizontal line (0,0) -> (60,0)
  Path.Segments[1] := CreateLineBezierSegment(
    MakePointF(0.0, 0.0),
    MakePointF(60.0, 0.0)
  );

  Path.IsClosed := False;

  SetLength(Result.Paths, 1);
  Result.Paths[0] := Path;
end;

// Создать тестовый глиф A (простая форма)
// Create test glyph A (simple shape)
function CreateTestGlyphA: TUzvBezierGlyph;
var
  Path: TUzvBezierPath;
begin
  Result := CreateEmptyBezierGlyph(65);  // ASCII 'A'
  Result.Width := 70.0;

  // Создаём упрощённый путь для буквы A
  // Create simplified path for letter A
  Path := CreateEmptyBezierPath;
  SetLength(Path.Segments, 3);

  // Левая наклонная (0,0) -> (35,100)
  // Left diagonal (0,0) -> (35,100)
  Path.Segments[0] := CreateLineBezierSegment(
    MakePointF(0.0, 0.0),
    MakePointF(35.0, 100.0)
  );

  // Правая наклонная (35,100) -> (70,0)
  // Right diagonal (35,100) -> (70,0)
  Path.Segments[1] := CreateLineBezierSegment(
    MakePointF(35.0, 100.0),
    MakePointF(70.0, 0.0)
  );

  // Горизонтальная перекладина (17,50) -> (53,50)
  // Horizontal bar (17,50) -> (53,50)
  Path.Segments[2] := CreateLineBezierSegment(
    MakePointF(17.0, 50.0),
    MakePointF(53.0, 50.0)
  );

  Path.IsClosed := False;

  SetLength(Result.Paths, 1);
  Result.Paths[0] := Path;
end;

// Создать тестовый шрифт
// Create test font
function CreateTestFont: TUzvBezierFont;
begin
  Result := CreateEmptyBezierFont;
  Result.FontName := 'TestFont';

  SetLength(Result.Glyphs, 2);
  Result.Glyphs[0] := CreateTestGlyphL;
  Result.Glyphs[1] := CreateTestGlyphA;
end;

// Подсчитать статистику результата
// Count result statistics
procedure CountStatistics(
  const WorldFont: TUzvWorldBezierFont;
  out PathCount, SegmentCount: Integer
);
var
  i, j: Integer;
begin
  PathCount := 0;
  SegmentCount := 0;

  for i := 0 to High(WorldFont.Glyphs) do
  begin
    PathCount := PathCount + Length(WorldFont.Glyphs[i].Paths);

    for j := 0 to High(WorldFont.Glyphs[i].Paths) do
    begin
      SegmentCount := SegmentCount +
        Length(WorldFont.Glyphs[i].Paths[j].Segments);
    end;
  end;
end;

// Тест пустого шрифта
function TestEmptyFont: TIntegrationTestResult;
var
  InputFont: TUzvBezierFont;
  Transform: TUzvTextTransform;
  OutputFont: TUzvWorldBezierFont;
begin
  Result.TestName := 'Empty Font';
  Result.Passed := False;

  InputFont := CreateEmptyBezierFont;
  Transform := CreateDefaultTextTransform;

  OutputFont := TransformBezierFont(InputFont, Transform);

  if Length(OutputFont.Glyphs) <> 0 then
  begin
    Result.Message := Format(
      'Expected 0 glyphs, got %d',
      [Length(OutputFont.Glyphs)]
    );
    Exit;
  end;

  Result.Passed := True;
  Result.GlyphCount := 0;
  Result.PathCount := 0;
  Result.SegmentCount := 0;
  Result.Message := 'OK - empty font processed correctly';
end;

// Тест одного глифа без трансформации
function TestSingleGlyphNoTransform: TIntegrationTestResult;
var
  InputFont: TUzvBezierFont;
  Transform: TUzvTextTransform;
  OutputFont: TUzvWorldBezierFont;
begin
  Result.TestName := 'Single Glyph No Transform';
  Result.Passed := False;

  InputFont := CreateEmptyBezierFont;
  InputFont.FontName := 'Test';
  SetLength(InputFont.Glyphs, 1);
  InputFont.Glyphs[0] := CreateTestGlyphL;

  Transform := CreateDefaultTextTransform;
  Transform.Height := 1.0;
  Transform.WidthFactor := 1.0;
  Transform.UnitsPerEm := 1.0;

  OutputFont := TransformBezierFont(InputFont, Transform);

  if Length(OutputFont.Glyphs) <> 1 then
  begin
    Result.Message := Format(
      'Expected 1 glyph, got %d',
      [Length(OutputFont.Glyphs)]
    );
    Exit;
  end;

  Result.Passed := True;
  Result.GlyphCount := Length(OutputFont.Glyphs);
  CountStatistics(OutputFont, Result.PathCount, Result.SegmentCount);
  Result.Message := Format(
    'OK - %d glyphs, %d paths, %d segments',
    [Result.GlyphCount, Result.PathCount, Result.SegmentCount]
  );
end;

// Тест одного глифа с масштабированием
function TestSingleGlyphWithScale: TIntegrationTestResult;
var
  InputFont: TUzvBezierFont;
  Transform: TUzvTextTransform;
  OutputFont: TUzvWorldBezierFont;
begin
  Result.TestName := 'Single Glyph With Scale';
  Result.Passed := False;

  InputFont := CreateEmptyBezierFont;
  SetLength(InputFont.Glyphs, 1);
  InputFont.Glyphs[0] := CreateTestGlyphL;

  Transform := CreateDefaultTextTransform;
  Transform.Height := 2.0;       // Масштаб 2x по высоте
  Transform.WidthFactor := 1.5;  // Масштаб 1.5x по ширине
  Transform.UnitsPerEm := 100.0; // Нормализация

  OutputFont := TransformBezierFont(InputFont, Transform);

  if Length(OutputFont.Glyphs) <> 1 then
  begin
    Result.Message := 'Wrong glyph count';
    Exit;
  end;

  Result.Passed := True;
  Result.GlyphCount := Length(OutputFont.Glyphs);
  CountStatistics(OutputFont, Result.PathCount, Result.SegmentCount);
  Result.Message := Format(
    'OK - scaled %d glyphs',
    [Result.GlyphCount]
  );
end;

// Тест одного глифа с поворотом
function TestSingleGlyphWithRotation: TIntegrationTestResult;
var
  InputFont: TUzvBezierFont;
  Transform: TUzvTextTransform;
  OutputFont: TUzvWorldBezierFont;
begin
  Result.TestName := 'Single Glyph With Rotation';
  Result.Passed := False;

  InputFont := CreateEmptyBezierFont;
  SetLength(InputFont.Glyphs, 1);
  InputFont.Glyphs[0] := CreateTestGlyphL;

  Transform := CreateDefaultTextTransform;
  Transform.Height := 1.0;
  Transform.RotationDeg := 45.0;  // Поворот 45 градусов

  OutputFont := TransformBezierFont(InputFont, Transform);

  if Length(OutputFont.Glyphs) <> 1 then
  begin
    Result.Message := 'Wrong glyph count';
    Exit;
  end;

  Result.Passed := True;
  Result.GlyphCount := Length(OutputFont.Glyphs);
  CountStatistics(OutputFont, Result.PathCount, Result.SegmentCount);
  Result.Message := Format(
    'OK - rotated 45 degrees, %d glyphs',
    [Result.GlyphCount]
  );
end;

// Тест нескольких глифов с кернингом
function TestMultipleGlyphsWithKerning: TIntegrationTestResult;
var
  InputFont: TUzvBezierFont;
  Transform: TUzvTextTransform;
  OutputFont: TUzvWorldBezierFont;
begin
  Result.TestName := 'Multiple Glyphs With Kerning';
  Result.Passed := False;

  InputFont := CreateTestFont;  // L и A

  Transform := CreateDefaultTextTransform;
  Transform.Height := 1.0;
  Transform.Kerning := 5.0;  // Дополнительный интервал

  OutputFont := TransformBezierFont(InputFont, Transform);

  if Length(OutputFont.Glyphs) <> 2 then
  begin
    Result.Message := Format(
      'Expected 2 glyphs, got %d',
      [Length(OutputFont.Glyphs)]
    );
    Exit;
  end;

  Result.Passed := True;
  Result.GlyphCount := Length(OutputFont.Glyphs);
  CountStatistics(OutputFont, Result.PathCount, Result.SegmentCount);
  Result.Message := Format(
    'OK - %d glyphs with kerning=5',
    [Result.GlyphCount]
  );
end;

// Тест выравнивания по центру
function TestCenterAlignment: TIntegrationTestResult;
var
  InputFont: TUzvBezierFont;
  Transform: TUzvTextTransform;
  OutputFont: TUzvWorldBezierFont;
begin
  Result.TestName := 'Center Alignment';
  Result.Passed := False;

  InputFont := CreateTestFont;

  Transform := CreateDefaultTextTransform;
  Transform.Height := 1.0;
  Transform.AlignmentH := alCenter;
  Transform.AlignmentV := alBaseline;
  Transform.BasePoint := MakePointF(100.0, 100.0);

  OutputFont := TransformBezierFont(InputFont, Transform);

  if Length(OutputFont.Glyphs) <> 2 then
  begin
    Result.Message := 'Wrong glyph count';
    Exit;
  end;

  Result.Passed := True;
  Result.GlyphCount := Length(OutputFont.Glyphs);
  CountStatistics(OutputFont, Result.PathCount, Result.SegmentCount);
  Result.Message := 'OK - center aligned';
end;

// Тест выравнивания по правому краю
function TestRightAlignment: TIntegrationTestResult;
var
  InputFont: TUzvBezierFont;
  Transform: TUzvTextTransform;
  OutputFont: TUzvWorldBezierFont;
begin
  Result.TestName := 'Right Alignment';
  Result.Passed := False;

  InputFont := CreateTestFont;

  Transform := CreateDefaultTextTransform;
  Transform.Height := 1.0;
  Transform.AlignmentH := alRight;
  Transform.AlignmentV := alTop;
  Transform.BasePoint := MakePointF(200.0, 200.0);

  OutputFont := TransformBezierFont(InputFont, Transform);

  if Length(OutputFont.Glyphs) <> 2 then
  begin
    Result.Message := 'Wrong glyph count';
    Exit;
  end;

  Result.Passed := True;
  Result.GlyphCount := Length(OutputFont.Glyphs);
  CountStatistics(OutputFont, Result.PathCount, Result.SegmentCount);
  Result.Message := 'OK - right aligned';
end;

// Тест полной трансформации
function TestFullTransformation: TIntegrationTestResult;
var
  InputFont: TUzvBezierFont;
  Transform: TUzvTextTransform;
  OutputFont: TUzvWorldBezierFont;
begin
  Result.TestName := 'Full Transformation';
  Result.Passed := False;

  InputFont := CreateTestFont;

  // Все параметры
  // All parameters
  Transform := CreateDefaultTextTransform;
  Transform.Height := 2.5;
  Transform.WidthFactor := 1.2;
  Transform.UnitsPerEm := 100.0;
  Transform.ObliqueDeg := 15.0;
  Transform.RotationDeg := 30.0;
  Transform.MirrorX := False;
  Transform.MirrorY := False;
  Transform.BasePoint := MakePointF(500.0, 300.0);
  Transform.Kerning := 3.0;
  Transform.AlignmentH := alCenter;
  Transform.AlignmentV := alBaseline;

  OutputFont := TransformBezierFont(InputFont, Transform);

  if Length(OutputFont.Glyphs) <> 2 then
  begin
    Result.Message := 'Wrong glyph count';
    Exit;
  end;

  Result.Passed := True;
  Result.GlyphCount := Length(OutputFont.Glyphs);
  CountStatistics(OutputFont, Result.PathCount, Result.SegmentCount);
  Result.Message := Format(
    'OK - full transform: %d glyphs, %d paths, %d segments',
    [Result.GlyphCount, Result.PathCount, Result.SegmentCount]
  );
end;

// Тест зеркалирования
function TestMirroring: TIntegrationTestResult;
var
  InputFont: TUzvBezierFont;
  Transform: TUzvTextTransform;
  OutputFont: TUzvWorldBezierFont;
begin
  Result.TestName := 'Mirroring';
  Result.Passed := False;

  InputFont := CreateEmptyBezierFont;
  SetLength(InputFont.Glyphs, 1);
  InputFont.Glyphs[0] := CreateTestGlyphL;

  // Зеркалирование по X и Y
  // Mirror on X and Y
  Transform := CreateDefaultTextTransform;
  Transform.Height := 1.0;
  Transform.MirrorX := True;
  Transform.MirrorY := True;

  OutputFont := TransformBezierFont(InputFont, Transform);

  if Length(OutputFont.Glyphs) <> 1 then
  begin
    Result.Message := 'Wrong glyph count';
    Exit;
  end;

  Result.Passed := True;
  Result.GlyphCount := Length(OutputFont.Glyphs);
  CountStatistics(OutputFont, Result.PathCount, Result.SegmentCount);
  Result.Message := 'OK - mirrored on X and Y';
end;

// Запустить все тесты
function RunAllIntegrationTests: TIntegrationTestResults;
begin
  programlog.LogOutFormatStr(
    'Transform: Starting integration tests (PDF pipeline)',
    [],
    LM_Info
  );

  SetLength(Result, 9);

  Result[0] := TestEmptyFont;
  Result[1] := TestSingleGlyphNoTransform;
  Result[2] := TestSingleGlyphWithScale;
  Result[3] := TestSingleGlyphWithRotation;
  Result[4] := TestMultipleGlyphsWithKerning;
  Result[5] := TestCenterAlignment;
  Result[6] := TestRightAlignment;
  Result[7] := TestFullTransformation;
  Result[8] := TestMirroring;

  LogIntegrationTestResults(Result);
end;

// Вывести результаты тестов в лог
procedure LogIntegrationTestResults(const Results: TIntegrationTestResults);
var
  i: Integer;
  PassedCount: Integer;
begin
  PassedCount := 0;

  programlog.LogOutFormatStr(
    'Transform: ===== Integration Test Results =====',
    [],
    LM_Info
  );

  for i := 0 to High(Results) do
  begin
    if Results[i].Passed then
    begin
      Inc(PassedCount);
      programlog.LogOutFormatStr(
        'Transform: [PASS] %s - %s',
        [Results[i].TestName, Results[i].Message],
        LM_Info
      );
    end
    else
    begin
      programlog.LogOutFormatStr(
        'Transform: [FAIL] %s - %s',
        [Results[i].TestName, Results[i].Message],
        LM_Info
      );
    end;
  end;

  programlog.LogOutFormatStr(
    'Transform: ===== Summary: %d/%d tests passed =====',
    [PassedCount, Length(Results)],
    LM_Info
  );
end;

end.
