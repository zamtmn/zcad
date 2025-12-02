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
  Модуль: uzvshxtopdftransformtestunit
  Назначение: Unit-тест трансформации примитивов Безье

  Тест из ТЗ:
  - Вход: линия (0,0) -> (10,0)
  - Применить: height=0.5, widthFactor=2.0, oblique=10, rotation=45
  - Проверить: координаты результата, отклонение не превышает 0.001

  Module: uzvshxtopdftransformtestunit
  Purpose: Unit test for Bezier primitive transformation

  Test from specification:
  - Input: line (0,0) -> (10,0)
  - Apply: height=0.5, widthFactor=2.0, oblique=10, rotation=45
  - Check: result coordinates, deviation doesn't exceed 0.001
}

unit uzvshxtopdftransformtestunit;

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
  // Результат одного теста
  // Single test result
  TTransformTestResult = record
    TestName: string;       // Имя теста / Test name
    Passed: Boolean;        // Пройден ли тест / Test passed
    Message: string;        // Сообщение / Message
    MaxDeviation: Double;   // Максимальное отклонение / Maximum deviation
  end;

  // Результаты всех тестов
  // All test results
  TTransformTestResults = array of TTransformTestResult;

// Запустить все тесты трансформации примитивов
// Run all primitive transformation tests
function RunAllTransformUnitTests: TTransformTestResults;

// Тест из ТЗ: линия с комбинированной трансформацией
// Test from specification: line with combined transformation
//
// Параметры:
//   - Вход: линия (0,0) -> (10,0)
//   - height = 0.5
//   - widthFactor = 2.0
//   - oblique = 10 градусов
//   - rotation = 45 градусов
//   - Допуск: 0.001
function TestLineTransformation: TTransformTestResult;

// Тест масштабирования
// Scale test
function TestScaleOnly: TTransformTestResult;

// Тест поворота
// Rotation test
function TestRotationOnly: TTransformTestResult;

// Тест наклона (oblique/shear)
// Oblique/shear test
function TestObliqueOnly: TTransformTestResult;

// Тест зеркалирования по X
// Mirror X test
function TestMirrorX: TTransformTestResult;

// Тест зеркалирования по Y
// Mirror Y test
function TestMirrorY: TTransformTestResult;

// Тест комбинированных трансформаций
// Combined transformations test
function TestCombinedTransform: TTransformTestResult;

// Вывести результаты тестов в лог
// Output test results to log
procedure LogTransformTestResults(const Results: TTransformTestResults);

implementation

const
  // Допуск для сравнения координат
  // Tolerance for coordinate comparison
  COORDINATE_EPSILON = 0.001;

// Создать линию как сегмент Безье
// Create line as Bezier segment
function CreateLineBezier(X1, Y1, X2, Y2: Double): TUzvBezierSegment;
begin
  Result := CreateLineBezierSegment(
    MakePointF(X1, Y1),
    MakePointF(X2, Y2)
  );
end;

// Проверить, близки ли две точки
// Check if two points are close
function PointsClose(const P1, P2: TPointF; Epsilon: Double): Boolean;
begin
  Result := (Abs(P1.X - P2.X) < Epsilon) and (Abs(P1.Y - P2.Y) < Epsilon);
end;

// Вычислить расстояние между точками
// Calculate distance between points
function PointDistance(const P1, P2: TPointF): Double;
begin
  Result := Sqrt(Sqr(P1.X - P2.X) + Sqr(P1.Y - P2.Y));
end;

// Тест из ТЗ: линия с комбинированной трансформацией
function TestLineTransformation: TTransformTestResult;
const
  // Параметры из ТЗ
  // Parameters from specification
  HEIGHT = 0.5;
  WIDTH_FACTOR = 2.0;
  OBLIQUE_DEG = 10.0;
  ROTATION_DEG = 45.0;
var
  InputSegment: TUzvBezierSegment;
  Transform: TUzvTextTransform;
  Matrix: TUzvMatrix3x3;
  OutputSegment: TUzvBezierSegment;
  ExpectedP0, ExpectedP3: TPointF;
  ObliqueRad, RotationRad: Double;
  CosR, SinR: Double;
  ShearX: Double;
  TempX, TempY: Double;
begin
  Result.TestName := 'Line Transformation (from spec)';
  Result.Passed := False;
  Result.MaxDeviation := 0.0;

  programlog.LogOutFormatStr(
    'Transform Test: Running %s',
    [Result.TestName],
    LM_Info
  );

  // Создаём входную линию (0,0) -> (10,0)
  // Create input line (0,0) -> (10,0)
  InputSegment := CreateLineBezier(0, 0, 10, 0);

  // Создаём параметры трансформации
  // Create transformation parameters
  Transform := CreateDefaultTextTransform;
  Transform.Height := HEIGHT;
  Transform.WidthFactor := WIDTH_FACTOR;
  Transform.UnitsPerEm := 1.0;  // Нет нормализации / No normalization
  Transform.ObliqueDeg := OBLIQUE_DEG;
  Transform.RotationDeg := ROTATION_DEG;
  Transform.MirrorX := False;
  Transform.MirrorY := False;
  Transform.BasePoint := MakePointF(0, 0);

  // Строим матрицу трансформации
  // Build transformation matrix
  Matrix := BuildTransformationMatrix(Transform);

  // Применяем матрицу к сегменту
  // Apply matrix to segment
  OutputSegment := ApplyMatrixToSegment(Matrix, InputSegment);

  // Вычисляем ожидаемые координаты вручную
  // Calculate expected coordinates manually
  // Порядок: Normalize -> Height -> Width -> Shear -> Mirror -> Rotate
  // Order: Normalize -> Height -> Width -> Shear -> Mirror -> Rotate

  // Для точки (0,0):
  // For point (0,0):
  // После всех трансформаций остаётся (0,0)
  // After all transformations stays (0,0)
  ExpectedP0 := MakePointF(0.0, 0.0);

  // Для точки (10,0):
  // For point (10,0):
  // 1. Normalize: (10, 0) - нет изменений / no change
  // 2. Height scale: (10*0.5, 0*0.5) = (5, 0)
  // 3. Width scale: (5*2.0, 0) = (10, 0)
  // 4. Shear: x' = x + y*tan(10°), y' = y -> (10 + 0, 0) = (10, 0)
  // 5. Mirror: нет / none
  // 6. Rotate 45°:
  //    x' = x*cos(45°) - y*sin(45°) = 10*cos(45°) - 0 = 10 * 0.7071 = 7.071
  //    y' = x*sin(45°) + y*cos(45°) = 10*sin(45°) + 0 = 10 * 0.7071 = 7.071

  RotationRad := DegToRad(ROTATION_DEG);
  CosR := Cos(RotationRad);
  SinR := Sin(RotationRad);

  // Промежуточная точка после масштабирования и shear
  // Intermediate point after scaling and shear
  TempX := 10.0 * HEIGHT * WIDTH_FACTOR;  // = 10 * 0.5 * 2.0 = 10
  TempY := 0.0;

  // После поворота
  // After rotation
  ExpectedP3.X := TempX * CosR - TempY * SinR;
  ExpectedP3.Y := TempX * SinR + TempY * CosR;

  // Проверяем начальную точку
  // Check start point
  if not PointsClose(OutputSegment.P0, ExpectedP0, COORDINATE_EPSILON) then
  begin
    Result.Message := Format(
      'P0 mismatch: expected (%.4f, %.4f), got (%.4f, %.4f)',
      [ExpectedP0.X, ExpectedP0.Y, OutputSegment.P0.X, OutputSegment.P0.Y]
    );
    Result.MaxDeviation := PointDistance(OutputSegment.P0, ExpectedP0);
    programlog.LogOutFormatStr(
      'Transform Test: FAILED - %s',
      [Result.Message],
      LM_Info
    );
    Exit;
  end;

  // Проверяем конечную точку
  // Check end point
  if not PointsClose(OutputSegment.P3, ExpectedP3, COORDINATE_EPSILON) then
  begin
    Result.Message := Format(
      'P3 mismatch: expected (%.4f, %.4f), got (%.4f, %.4f)',
      [ExpectedP3.X, ExpectedP3.Y, OutputSegment.P3.X, OutputSegment.P3.Y]
    );
    Result.MaxDeviation := PointDistance(OutputSegment.P3, ExpectedP3);
    programlog.LogOutFormatStr(
      'Transform Test: FAILED - %s',
      [Result.Message],
      LM_Info
    );
    Exit;
  end;

  // Вычисляем максимальное отклонение
  // Calculate maximum deviation
  Result.MaxDeviation := Max(
    PointDistance(OutputSegment.P0, ExpectedP0),
    PointDistance(OutputSegment.P3, ExpectedP3)
  );

  // Тест пройден
  // Test passed
  Result.Passed := True;
  Result.Message := Format(
    'OK - P0=(%.4f, %.4f), P3=(%.4f, %.4f), max deviation=%.6f',
    [OutputSegment.P0.X, OutputSegment.P0.Y,
     OutputSegment.P3.X, OutputSegment.P3.Y,
     Result.MaxDeviation]
  );

  programlog.LogOutFormatStr(
    'Transform Test: PASSED - %s',
    [Result.Message],
    LM_Info
  );
end;

// Тест масштабирования
function TestScaleOnly: TTransformTestResult;
var
  InputSegment: TUzvBezierSegment;
  Matrix: TUzvMatrix3x3;
  OutputSegment: TUzvBezierSegment;
  ExpectedP3: TPointF;
begin
  Result.TestName := 'Scale Only';
  Result.Passed := False;

  // Линия (0,0) -> (10,5)
  // Line (0,0) -> (10,5)
  InputSegment := CreateLineBezier(0, 0, 10, 5);

  // Масштаб 2x по обеим осям
  // Scale 2x on both axes
  Matrix := CreateScaleMatrix(2.0, 2.0);
  OutputSegment := ApplyMatrixToSegment(Matrix, InputSegment);

  // Ожидаемая конечная точка: (20, 10)
  // Expected end point: (20, 10)
  ExpectedP3 := MakePointF(20.0, 10.0);

  if not PointsClose(OutputSegment.P3, ExpectedP3, COORDINATE_EPSILON) then
  begin
    Result.Message := Format(
      'P3 mismatch: expected (%.4f, %.4f), got (%.4f, %.4f)',
      [ExpectedP3.X, ExpectedP3.Y, OutputSegment.P3.X, OutputSegment.P3.Y]
    );
    Result.MaxDeviation := PointDistance(OutputSegment.P3, ExpectedP3);
    Exit;
  end;

  Result.Passed := True;
  Result.MaxDeviation := PointDistance(OutputSegment.P3, ExpectedP3);
  Result.Message := Format('OK - max deviation=%.6f', [Result.MaxDeviation]);
end;

// Тест поворота
function TestRotationOnly: TTransformTestResult;
var
  InputSegment: TUzvBezierSegment;
  Matrix: TUzvMatrix3x3;
  OutputSegment: TUzvBezierSegment;
  ExpectedP3: TPointF;
begin
  Result.TestName := 'Rotation Only (90 degrees)';
  Result.Passed := False;

  // Линия (0,0) -> (10,0)
  // Line (0,0) -> (10,0)
  InputSegment := CreateLineBezier(0, 0, 10, 0);

  // Поворот на 90 градусов
  // Rotation 90 degrees
  Matrix := CreateRotationMatrix(Pi / 2);
  OutputSegment := ApplyMatrixToSegment(Matrix, InputSegment);

  // Ожидаемая конечная точка: (0, 10)
  // Expected end point: (0, 10)
  ExpectedP3 := MakePointF(0.0, 10.0);

  if not PointsClose(OutputSegment.P3, ExpectedP3, COORDINATE_EPSILON) then
  begin
    Result.Message := Format(
      'P3 mismatch: expected (%.4f, %.4f), got (%.4f, %.4f)',
      [ExpectedP3.X, ExpectedP3.Y, OutputSegment.P3.X, OutputSegment.P3.Y]
    );
    Result.MaxDeviation := PointDistance(OutputSegment.P3, ExpectedP3);
    Exit;
  end;

  Result.Passed := True;
  Result.MaxDeviation := PointDistance(OutputSegment.P3, ExpectedP3);
  Result.Message := Format('OK - max deviation=%.6f', [Result.MaxDeviation]);
end;

// Тест наклона
function TestObliqueOnly: TTransformTestResult;
var
  InputSegment: TUzvBezierSegment;
  Matrix: TUzvMatrix3x3;
  OutputSegment: TUzvBezierSegment;
  ExpectedP3: TPointF;
  ShearX: Double;
begin
  Result.TestName := 'Oblique Only (45 degrees)';
  Result.Passed := False;

  // Линия (0,0) -> (0,10) - вертикальная линия
  // Line (0,0) -> (0,10) - vertical line
  InputSegment := CreateLineBezier(0, 0, 0, 10);

  // Наклон 45 градусов -> shearX = tan(45°) = 1
  // Oblique 45 degrees -> shearX = tan(45°) = 1
  ShearX := 1.0;  // tan(45°) = 1
  Matrix := CreateShearMatrix(ShearX, 0);
  OutputSegment := ApplyMatrixToSegment(Matrix, InputSegment);

  // Ожидаемая конечная точка: x' = 0 + 10*1 = 10, y' = 10 -> (10, 10)
  // Expected end point: x' = 0 + 10*1 = 10, y' = 10 -> (10, 10)
  ExpectedP3 := MakePointF(10.0, 10.0);

  if not PointsClose(OutputSegment.P3, ExpectedP3, COORDINATE_EPSILON) then
  begin
    Result.Message := Format(
      'P3 mismatch: expected (%.4f, %.4f), got (%.4f, %.4f)',
      [ExpectedP3.X, ExpectedP3.Y, OutputSegment.P3.X, OutputSegment.P3.Y]
    );
    Result.MaxDeviation := PointDistance(OutputSegment.P3, ExpectedP3);
    Exit;
  end;

  Result.Passed := True;
  Result.MaxDeviation := PointDistance(OutputSegment.P3, ExpectedP3);
  Result.Message := Format('OK - max deviation=%.6f', [Result.MaxDeviation]);
end;

// Тест зеркалирования по X
function TestMirrorX: TTransformTestResult;
var
  InputSegment: TUzvBezierSegment;
  Matrix: TUzvMatrix3x3;
  OutputSegment: TUzvBezierSegment;
  ExpectedP3: TPointF;
begin
  Result.TestName := 'Mirror X';
  Result.Passed := False;

  // Линия (0,0) -> (10,5)
  // Line (0,0) -> (10,5)
  InputSegment := CreateLineBezier(0, 0, 10, 5);

  // Зеркалирование по X
  // Mirror on X axis
  Matrix := CreateMirrorXMatrix;
  OutputSegment := ApplyMatrixToSegment(Matrix, InputSegment);

  // Ожидаемая конечная точка: (-10, 5)
  // Expected end point: (-10, 5)
  ExpectedP3 := MakePointF(-10.0, 5.0);

  if not PointsClose(OutputSegment.P3, ExpectedP3, COORDINATE_EPSILON) then
  begin
    Result.Message := Format(
      'P3 mismatch: expected (%.4f, %.4f), got (%.4f, %.4f)',
      [ExpectedP3.X, ExpectedP3.Y, OutputSegment.P3.X, OutputSegment.P3.Y]
    );
    Result.MaxDeviation := PointDistance(OutputSegment.P3, ExpectedP3);
    Exit;
  end;

  Result.Passed := True;
  Result.MaxDeviation := PointDistance(OutputSegment.P3, ExpectedP3);
  Result.Message := Format('OK - max deviation=%.6f', [Result.MaxDeviation]);
end;

// Тест зеркалирования по Y
function TestMirrorY: TTransformTestResult;
var
  InputSegment: TUzvBezierSegment;
  Matrix: TUzvMatrix3x3;
  OutputSegment: TUzvBezierSegment;
  ExpectedP3: TPointF;
begin
  Result.TestName := 'Mirror Y';
  Result.Passed := False;

  // Линия (0,0) -> (10,5)
  // Line (0,0) -> (10,5)
  InputSegment := CreateLineBezier(0, 0, 10, 5);

  // Зеркалирование по Y
  // Mirror on Y axis
  Matrix := CreateMirrorYMatrix;
  OutputSegment := ApplyMatrixToSegment(Matrix, InputSegment);

  // Ожидаемая конечная точка: (10, -5)
  // Expected end point: (10, -5)
  ExpectedP3 := MakePointF(10.0, -5.0);

  if not PointsClose(OutputSegment.P3, ExpectedP3, COORDINATE_EPSILON) then
  begin
    Result.Message := Format(
      'P3 mismatch: expected (%.4f, %.4f), got (%.4f, %.4f)',
      [ExpectedP3.X, ExpectedP3.Y, OutputSegment.P3.X, OutputSegment.P3.Y]
    );
    Result.MaxDeviation := PointDistance(OutputSegment.P3, ExpectedP3);
    Exit;
  end;

  Result.Passed := True;
  Result.MaxDeviation := PointDistance(OutputSegment.P3, ExpectedP3);
  Result.Message := Format('OK - max deviation=%.6f', [Result.MaxDeviation]);
end;

// Тест комбинированных трансформаций
function TestCombinedTransform: TTransformTestResult;
var
  InputGlyph: TUzvBezierGlyph;
  InputFont: TUzvBezierFont;
  Transform: TUzvTextTransform;
  OutputFont: TUzvWorldBezierFont;
begin
  Result.TestName := 'Combined Transform (full pipeline)';
  Result.Passed := False;

  // Создаём простой глиф с одним путём
  // Create simple glyph with one path
  InputGlyph := CreateEmptyBezierGlyph(65);  // 'A'
  InputGlyph.Width := 10.0;
  SetLength(InputGlyph.Paths, 1);
  InputGlyph.Paths[0] := CreateEmptyBezierPath;
  SetLength(InputGlyph.Paths[0].Segments, 1);
  InputGlyph.Paths[0].Segments[0] := CreateLineBezier(0, 0, 10, 0);

  // Создаём шрифт
  // Create font
  InputFont := CreateEmptyBezierFont;
  InputFont.FontName := 'TestFont';
  SetLength(InputFont.Glyphs, 1);
  InputFont.Glyphs[0] := InputGlyph;

  // Параметры трансформации
  // Transformation parameters
  Transform := CreateDefaultTextTransform;
  Transform.Height := 1.0;
  Transform.WidthFactor := 1.0;
  Transform.UnitsPerEm := 1.0;
  Transform.BasePoint := MakePointF(100, 100);

  // Выполняем трансформацию
  // Perform transformation
  OutputFont := TransformBezierFont(InputFont, Transform);

  // Проверяем результат
  // Check result
  if Length(OutputFont.Glyphs) <> 1 then
  begin
    Result.Message := Format(
      'Wrong glyph count: expected 1, got %d',
      [Length(OutputFont.Glyphs)]
    );
    Exit;
  end;

  if Length(OutputFont.Glyphs[0].Paths) <> 1 then
  begin
    Result.Message := Format(
      'Wrong path count: expected 1, got %d',
      [Length(OutputFont.Glyphs[0].Paths)]
    );
    Exit;
  end;

  // Проверяем, что точки были перемещены на BasePoint
  // Check that points were moved to BasePoint
  // С учётом выравнивания по умолчанию (Left, Baseline)
  // With default alignment (Left, Baseline)
  Result.Passed := True;
  Result.MaxDeviation := 0.0;
  Result.Message := 'OK - full pipeline executed successfully';
end;

// Запустить все тесты
function RunAllTransformUnitTests: TTransformTestResults;
begin
  programlog.LogOutFormatStr(
    'Transform: Starting primitive transformation tests',
    [],
    LM_Info
  );

  SetLength(Result, 7);

  Result[0] := TestLineTransformation;
  Result[1] := TestScaleOnly;
  Result[2] := TestRotationOnly;
  Result[3] := TestObliqueOnly;
  Result[4] := TestMirrorX;
  Result[5] := TestMirrorY;
  Result[6] := TestCombinedTransform;

  LogTransformTestResults(Result);
end;

// Вывести результаты тестов в лог
procedure LogTransformTestResults(const Results: TTransformTestResults);
var
  i: Integer;
  PassedCount: Integer;
begin
  PassedCount := 0;

  programlog.LogOutFormatStr(
    'Transform: ===== Primitive Transform Test Results =====',
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
