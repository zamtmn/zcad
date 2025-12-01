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
  Модуль: uzvshxtopdftransformtestmatrix
  Назначение: Unit-тест операций с матрицами трансформации

  Тесты из ТЗ:
  - Корректность перемножения матриц
  - Обратная матрица
  - Применение к точке
  - Зеркалирование X/Y

  Module: uzvshxtopdftransformtestmatrix
  Purpose: Unit test for transformation matrix operations

  Tests from specification:
  - Matrix multiplication correctness
  - Inverse matrix
  - Apply to point
  - Mirror X/Y
}

unit uzvshxtopdftransformtestmatrix;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Math,
  uzvshxtopdfapprogeomtypes,
  uzvshxtopdftransformmatrix,
  uzclog;

type
  // Результат одного теста
  // Single test result
  TMatrixTestResult = record
    TestName: string;       // Имя теста / Test name
    Passed: Boolean;        // Пройден ли тест / Test passed
    Message: string;        // Сообщение / Message
    MaxDeviation: Double;   // Максимальное отклонение / Maximum deviation
  end;

  // Результаты всех тестов
  // All test results
  TMatrixTestResults = array of TMatrixTestResult;

// Запустить все тесты матриц
// Run all matrix tests
function RunAllMatrixTests: TMatrixTestResults;

// Тест: единичная матрица
// Test: identity matrix
function TestIdentityMatrix: TMatrixTestResult;

// Тест: перемножение матриц (общий случай)
// Test: matrix multiplication (general case)
function TestMatrixMultiplication: TMatrixTestResult;

// Тест: перемножение с единичной матрицей
// Test: multiplication with identity matrix
function TestMultiplyWithIdentity: TMatrixTestResult;

// Тест: обратная матрица
// Test: inverse matrix
function TestInverseMatrix: TMatrixTestResult;

// Тест: обратная матрица для вырожденной матрицы
// Test: inverse matrix for singular matrix
function TestInverseSingularMatrix: TMatrixTestResult;

// Тест: применение матрицы к точке
// Test: apply matrix to point
function TestApplyToPoint: TMatrixTestResult;

// Тест: зеркалирование по X
// Test: mirror X
function TestMirrorXMatrix: TMatrixTestResult;

// Тест: зеркалирование по Y
// Test: mirror Y
function TestMirrorYMatrix: TMatrixTestResult;

// Тест: масштабирование
// Test: scale
function TestScaleMatrix: TMatrixTestResult;

// Тест: поворот на 90 градусов
// Test: rotation 90 degrees
function TestRotation90Matrix: TMatrixTestResult;

// Тест: поворот на 180 градусов
// Test: rotation 180 degrees
function TestRotation180Matrix: TMatrixTestResult;

// Тест: перенос
// Test: translation
function TestTranslationMatrix: TMatrixTestResult;

// Тест: комбинированная трансформация
// Test: combined transformation
function TestCombinedMatrix: TMatrixTestResult;

// Вывести результаты тестов в лог
// Output test results to log
procedure LogMatrixTestResults(const Results: TMatrixTestResults);

implementation

const
  // Допуск для сравнения
  // Comparison tolerance
  EPSILON = 1E-9;

// Проверить, близки ли два числа
// Check if two numbers are close
function ValuesClose(V1, V2, Eps: Double): Boolean;
begin
  Result := Abs(V1 - V2) < Eps;
end;

// Проверить, близки ли две матрицы
// Check if two matrices are close
function MatricesClose(const M1, M2: TUzvMatrix3x3; Eps: Double): Boolean;
begin
  Result := ValuesClose(M1.A, M2.A, Eps) and
            ValuesClose(M1.B, M2.B, Eps) and
            ValuesClose(M1.C, M2.C, Eps) and
            ValuesClose(M1.D, M2.D, Eps) and
            ValuesClose(M1.TX, M2.TX, Eps) and
            ValuesClose(M1.TY, M2.TY, Eps);
end;

// Проверить, близки ли две точки
// Check if two points are close
function PointsClose(const P1, P2: TPointF; Eps: Double): Boolean;
begin
  Result := ValuesClose(P1.X, P2.X, Eps) and
            ValuesClose(P1.Y, P2.Y, Eps);
end;

// Тест единичной матрицы
function TestIdentityMatrix: TMatrixTestResult;
var
  M: TUzvMatrix3x3;
  P, ResultP: TPointF;
begin
  Result.TestName := 'Identity Matrix';
  Result.Passed := False;
  Result.MaxDeviation := 0.0;

  M := CreateIdentityMatrix;

  // Проверяем значения
  // Check values
  if not ValuesClose(M.A, 1.0, EPSILON) or
     not ValuesClose(M.B, 0.0, EPSILON) or
     not ValuesClose(M.C, 0.0, EPSILON) or
     not ValuesClose(M.D, 1.0, EPSILON) or
     not ValuesClose(M.TX, 0.0, EPSILON) or
     not ValuesClose(M.TY, 0.0, EPSILON) then
  begin
    Result.Message := 'Identity matrix values incorrect';
    Exit;
  end;

  // Проверяем IsIdentityMatrix
  // Check IsIdentityMatrix
  if not IsIdentityMatrix(M) then
  begin
    Result.Message := 'IsIdentityMatrix returned False for identity';
    Exit;
  end;

  // Проверяем применение к точке
  // Check application to point
  P := MakePointF(5.0, 7.0);
  ResultP := ApplyMatrixToPoint(M, P);

  if not PointsClose(P, ResultP, EPSILON) then
  begin
    Result.Message := 'Identity matrix changed point coordinates';
    Exit;
  end;

  Result.Passed := True;
  Result.Message := 'OK';
end;

// Тест перемножения матриц
function TestMatrixMultiplication: TMatrixTestResult;
var
  M1, M2, Product, Expected: TUzvMatrix3x3;
begin
  Result.TestName := 'Matrix Multiplication';
  Result.Passed := False;

  // Матрица 1: scale (2, 3)
  // Matrix 1: scale (2, 3)
  M1 := CreateScaleMatrix(2.0, 3.0);

  // Матрица 2: translation (10, 20)
  // Matrix 2: translation (10, 20)
  M2 := CreateTranslationMatrix(10.0, 20.0);

  // Результат M2 * M1 (сначала масштабируем, потом переносим)
  // Result M2 * M1 (first scale, then translate)
  Product := MultiplyMatrices(M2, M1);

  // Ожидаемый результат:
  // Expected result:
  // | 2  0  10 |
  // | 0  3  20 |
  // | 0  0  1  |
  Expected.A := 2.0;   Expected.B := 0.0;   Expected.TX := 10.0;
  Expected.C := 0.0;   Expected.D := 3.0;   Expected.TY := 20.0;

  if not MatricesClose(Product, Expected, EPSILON) then
  begin
    Result.Message := Format(
      'Product incorrect: A=%.4f B=%.4f C=%.4f D=%.4f TX=%.4f TY=%.4f',
      [Product.A, Product.B, Product.C, Product.D, Product.TX, Product.TY]
    );
    Exit;
  end;

  Result.Passed := True;
  Result.Message := 'OK';
end;

// Тест перемножения с единичной матрицей
function TestMultiplyWithIdentity: TMatrixTestResult;
var
  M, I, Product: TUzvMatrix3x3;
begin
  Result.TestName := 'Multiply with Identity';
  Result.Passed := False;

  M := CreateScaleMatrix(2.0, 3.0);
  M.TX := 5.0;
  M.TY := 7.0;

  I := CreateIdentityMatrix;

  // M * I = M
  Product := MultiplyMatrices(M, I);
  if not MatricesClose(Product, M, EPSILON) then
  begin
    Result.Message := 'M * I != M';
    Exit;
  end;

  // I * M = M
  Product := MultiplyMatrices(I, M);
  if not MatricesClose(Product, M, EPSILON) then
  begin
    Result.Message := 'I * M != M';
    Exit;
  end;

  Result.Passed := True;
  Result.Message := 'OK';
end;

// Тест обратной матрицы
function TestInverseMatrix: TMatrixTestResult;
var
  M, Inverse, Product: TUzvMatrix3x3;
  I: TUzvMatrix3x3;
  CanInvert: Boolean;
begin
  Result.TestName := 'Inverse Matrix';
  Result.Passed := False;

  // Создаём комбинированную матрицу
  // Create combined matrix
  M := MultiplyMatrices(
    CreateTranslationMatrix(10.0, 20.0),
    CreateScaleMatrix(2.0, 3.0)
  );

  // Вычисляем обратную
  // Calculate inverse
  CanInvert := InvertMatrix(M, Inverse);

  if not CanInvert then
  begin
    Result.Message := 'Failed to invert non-singular matrix';
    Exit;
  end;

  // Проверяем: M * Inverse = I
  // Check: M * Inverse = I
  Product := MultiplyMatrices(M, Inverse);
  I := CreateIdentityMatrix;

  if not MatricesClose(Product, I, 1E-6) then
  begin
    Result.Message := Format(
      'M * Inverse != I: A=%.6f D=%.6f TX=%.6f TY=%.6f',
      [Product.A, Product.D, Product.TX, Product.TY]
    );
    Exit;
  end;

  // Проверяем: Inverse * M = I
  // Check: Inverse * M = I
  Product := MultiplyMatrices(Inverse, M);

  if not MatricesClose(Product, I, 1E-6) then
  begin
    Result.Message := 'Inverse * M != I';
    Exit;
  end;

  Result.Passed := True;
  Result.Message := 'OK';
end;

// Тест обратной матрицы для вырожденной матрицы
function TestInverseSingularMatrix: TMatrixTestResult;
var
  M, Inverse: TUzvMatrix3x3;
  CanInvert: Boolean;
begin
  Result.TestName := 'Inverse Singular Matrix';
  Result.Passed := False;

  // Создаём вырожденную матрицу (det = 0)
  // Create singular matrix (det = 0)
  M.A := 1.0;   M.B := 2.0;   M.TX := 0.0;
  M.C := 2.0;   M.D := 4.0;   M.TY := 0.0;
  // det = 1*4 - 2*2 = 0

  CanInvert := InvertMatrix(M, Inverse);

  if CanInvert then
  begin
    Result.Message := 'Should not be able to invert singular matrix';
    Exit;
  end;

  Result.Passed := True;
  Result.Message := 'OK - correctly rejected singular matrix';
end;

// Тест применения матрицы к точке
function TestApplyToPoint: TMatrixTestResult;
var
  M: TUzvMatrix3x3;
  P, ResultP, Expected: TPointF;
begin
  Result.TestName := 'Apply Matrix to Point';
  Result.Passed := False;

  // Масштабирование + перенос
  // Scale + translate
  M := MultiplyMatrices(
    CreateTranslationMatrix(100.0, 200.0),
    CreateScaleMatrix(2.0, 3.0)
  );

  P := MakePointF(10.0, 20.0);
  ResultP := ApplyMatrixToPoint(M, P);

  // Ожидаемый результат: (10*2 + 100, 20*3 + 200) = (120, 260)
  // Expected result: (10*2 + 100, 20*3 + 200) = (120, 260)
  Expected := MakePointF(120.0, 260.0);

  if not PointsClose(ResultP, Expected, EPSILON) then
  begin
    Result.Message := Format(
      'Point transformation incorrect: expected (%.4f, %.4f), got (%.4f, %.4f)',
      [Expected.X, Expected.Y, ResultP.X, ResultP.Y]
    );
    Exit;
  end;

  Result.Passed := True;
  Result.Message := 'OK';
end;

// Тест зеркалирования по X
function TestMirrorXMatrix: TMatrixTestResult;
var
  M: TUzvMatrix3x3;
  P, ResultP, Expected: TPointF;
begin
  Result.TestName := 'Mirror X Matrix';
  Result.Passed := False;

  M := CreateMirrorXMatrix;

  // Точка (5, 7) -> (-5, 7)
  // Point (5, 7) -> (-5, 7)
  P := MakePointF(5.0, 7.0);
  ResultP := ApplyMatrixToPoint(M, P);
  Expected := MakePointF(-5.0, 7.0);

  if not PointsClose(ResultP, Expected, EPSILON) then
  begin
    Result.Message := Format(
      'Mirror X incorrect: expected (%.4f, %.4f), got (%.4f, %.4f)',
      [Expected.X, Expected.Y, ResultP.X, ResultP.Y]
    );
    Exit;
  end;

  Result.Passed := True;
  Result.Message := 'OK';
end;

// Тест зеркалирования по Y
function TestMirrorYMatrix: TMatrixTestResult;
var
  M: TUzvMatrix3x3;
  P, ResultP, Expected: TPointF;
begin
  Result.TestName := 'Mirror Y Matrix';
  Result.Passed := False;

  M := CreateMirrorYMatrix;

  // Точка (5, 7) -> (5, -7)
  // Point (5, 7) -> (5, -7)
  P := MakePointF(5.0, 7.0);
  ResultP := ApplyMatrixToPoint(M, P);
  Expected := MakePointF(5.0, -7.0);

  if not PointsClose(ResultP, Expected, EPSILON) then
  begin
    Result.Message := Format(
      'Mirror Y incorrect: expected (%.4f, %.4f), got (%.4f, %.4f)',
      [Expected.X, Expected.Y, ResultP.X, ResultP.Y]
    );
    Exit;
  end;

  Result.Passed := True;
  Result.Message := 'OK';
end;

// Тест масштабирования
function TestScaleMatrix: TMatrixTestResult;
var
  M: TUzvMatrix3x3;
  P, ResultP, Expected: TPointF;
begin
  Result.TestName := 'Scale Matrix';
  Result.Passed := False;

  M := CreateScaleMatrix(3.0, 2.0);

  // Точка (10, 20) -> (30, 40)
  // Point (10, 20) -> (30, 40)
  P := MakePointF(10.0, 20.0);
  ResultP := ApplyMatrixToPoint(M, P);
  Expected := MakePointF(30.0, 40.0);

  if not PointsClose(ResultP, Expected, EPSILON) then
  begin
    Result.Message := Format(
      'Scale incorrect: expected (%.4f, %.4f), got (%.4f, %.4f)',
      [Expected.X, Expected.Y, ResultP.X, ResultP.Y]
    );
    Exit;
  end;

  Result.Passed := True;
  Result.Message := 'OK';
end;

// Тест поворота на 90 градусов
function TestRotation90Matrix: TMatrixTestResult;
var
  M: TUzvMatrix3x3;
  P, ResultP, Expected: TPointF;
begin
  Result.TestName := 'Rotation 90 degrees';
  Result.Passed := False;

  M := CreateRotationMatrix(Pi / 2);  // 90 градусов

  // Точка (10, 0) -> (0, 10)
  // Point (10, 0) -> (0, 10)
  P := MakePointF(10.0, 0.0);
  ResultP := ApplyMatrixToPoint(M, P);
  Expected := MakePointF(0.0, 10.0);

  if not PointsClose(ResultP, Expected, EPSILON) then
  begin
    Result.Message := Format(
      'Rotation 90 incorrect: expected (%.4f, %.4f), got (%.4f, %.4f)',
      [Expected.X, Expected.Y, ResultP.X, ResultP.Y]
    );
    Exit;
  end;

  Result.Passed := True;
  Result.Message := 'OK';
end;

// Тест поворота на 180 градусов
function TestRotation180Matrix: TMatrixTestResult;
var
  M: TUzvMatrix3x3;
  P, ResultP, Expected: TPointF;
begin
  Result.TestName := 'Rotation 180 degrees';
  Result.Passed := False;

  M := CreateRotationMatrix(Pi);  // 180 градусов

  // Точка (10, 5) -> (-10, -5)
  // Point (10, 5) -> (-10, -5)
  P := MakePointF(10.0, 5.0);
  ResultP := ApplyMatrixToPoint(M, P);
  Expected := MakePointF(-10.0, -5.0);

  if not PointsClose(ResultP, Expected, EPSILON) then
  begin
    Result.Message := Format(
      'Rotation 180 incorrect: expected (%.4f, %.4f), got (%.4f, %.4f)',
      [Expected.X, Expected.Y, ResultP.X, ResultP.Y]
    );
    Exit;
  end;

  Result.Passed := True;
  Result.Message := 'OK';
end;

// Тест переноса
function TestTranslationMatrix: TMatrixTestResult;
var
  M: TUzvMatrix3x3;
  P, ResultP, Expected: TPointF;
begin
  Result.TestName := 'Translation Matrix';
  Result.Passed := False;

  M := CreateTranslationMatrix(50.0, 30.0);

  // Точка (10, 20) -> (60, 50)
  // Point (10, 20) -> (60, 50)
  P := MakePointF(10.0, 20.0);
  ResultP := ApplyMatrixToPoint(M, P);
  Expected := MakePointF(60.0, 50.0);

  if not PointsClose(ResultP, Expected, EPSILON) then
  begin
    Result.Message := Format(
      'Translation incorrect: expected (%.4f, %.4f), got (%.4f, %.4f)',
      [Expected.X, Expected.Y, ResultP.X, ResultP.Y]
    );
    Exit;
  end;

  Result.Passed := True;
  Result.Message := 'OK';
end;

// Тест комбинированной трансформации
function TestCombinedMatrix: TMatrixTestResult;
var
  M: TUzvMatrix3x3;
  P, ResultP, Expected: TPointF;
begin
  Result.TestName := 'Combined Matrix (scale + rotate + translate)';
  Result.Passed := False;

  // Порядок: сначала масштаб, потом поворот 90°, потом перенос
  // Order: first scale, then rotate 90 degrees, then translate
  M := CreateScaleMatrix(2.0, 2.0);
  M := MultiplyMatrices(CreateRotationMatrix(Pi / 2), M);
  M := MultiplyMatrices(CreateTranslationMatrix(100.0, 100.0), M);

  // Точка (5, 0):
  // Point (5, 0):
  // 1. Scale: (10, 0)
  // 2. Rotate 90: (0, 10)
  // 3. Translate: (100, 110)
  P := MakePointF(5.0, 0.0);
  ResultP := ApplyMatrixToPoint(M, P);
  Expected := MakePointF(100.0, 110.0);

  if not PointsClose(ResultP, Expected, EPSILON) then
  begin
    Result.Message := Format(
      'Combined incorrect: expected (%.4f, %.4f), got (%.4f, %.4f)',
      [Expected.X, Expected.Y, ResultP.X, ResultP.Y]
    );
    Exit;
  end;

  Result.Passed := True;
  Result.Message := 'OK';
end;

// Запустить все тесты
function RunAllMatrixTests: TMatrixTestResults;
begin
  programlog.LogOutFormatStr(
    'Transform: Starting matrix operation tests',
    [],
    LM_Info
  );

  SetLength(Result, 13);

  Result[0] := TestIdentityMatrix;
  Result[1] := TestMatrixMultiplication;
  Result[2] := TestMultiplyWithIdentity;
  Result[3] := TestInverseMatrix;
  Result[4] := TestInverseSingularMatrix;
  Result[5] := TestApplyToPoint;
  Result[6] := TestMirrorXMatrix;
  Result[7] := TestMirrorYMatrix;
  Result[8] := TestScaleMatrix;
  Result[9] := TestRotation90Matrix;
  Result[10] := TestRotation180Matrix;
  Result[11] := TestTranslationMatrix;
  Result[12] := TestCombinedMatrix;

  LogMatrixTestResults(Result);
end;

// Вывести результаты тестов в лог
procedure LogMatrixTestResults(const Results: TMatrixTestResults);
var
  i: Integer;
  PassedCount: Integer;
begin
  PassedCount := 0;

  programlog.LogOutFormatStr(
    'Transform: ===== Matrix Test Results =====',
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
