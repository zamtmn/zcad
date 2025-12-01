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
  Модуль: uzvshxtopdftransformmatrix
  Назначение: Работа с 2D матрицами трансформации 3x3

  Данный модуль реализует операции с аффинными матрицами 3x3:
  - Создание матриц трансформации (scale, rotate, translate, shear, mirror)
  - Перемножение матриц
  - Применение матрицы к точке
  - Вычисление обратной матрицы

  Формат матрицы 3x3:
  | a  b  tx |    | M[0,0]  M[0,1]  M[0,2] |
  | c  d  ty | =  | M[1,0]  M[1,1]  M[1,2] |
  | 0  0  1  |    | M[2,0]  M[2,1]  M[2,2] |

  Module: uzvshxtopdftransformmatrix
  Purpose: 2D transformation matrix 3x3 operations

  This module implements affine 3x3 matrix operations:
  - Create transformation matrices (scale, rotate, translate, shear, mirror)
  - Matrix multiplication
  - Apply matrix to point
  - Compute inverse matrix

  3x3 Matrix format:
  | a  b  tx |    | M[0,0]  M[0,1]  M[0,2] |
  | c  d  ty | =  | M[1,0]  M[1,1]  M[1,2] |
  | 0  0  1  |    | M[2,0]  M[2,1]  M[2,2] |
}

unit uzvshxtopdftransformmatrix;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Math,
  uzvshxtopdfapprogeomtypes;

type
  // Матрица трансформации 3x3
  // 3x3 Transformation matrix
  //
  // Представление:
  // | A  B  TX |
  // | C  D  TY |
  // | 0  0  1  |
  //
  // Где A, B, C, D - коэффициенты линейной части,
  // TX, TY - компоненты переноса
  TUzvMatrix3x3 = record
    A, B, TX: Double;  // Первая строка / First row
    C, D, TY: Double;  // Вторая строка / Second row
    // Третья строка всегда (0, 0, 1) / Third row is always (0, 0, 1)
  end;

// === Создание базовых матриц ===
// === Create basic matrices ===

// Создать единичную матрицу
// Create identity matrix
function CreateIdentityMatrix: TUzvMatrix3x3;

// Создать матрицу масштабирования
// Create scale matrix
//
// | sx  0  0 |
// | 0  sy  0 |
// | 0   0  1 |
function CreateScaleMatrix(SX, SY: Double): TUzvMatrix3x3;

// Создать матрицу поворота
// Create rotation matrix
//
// | cos(a) -sin(a)  0 |
// | sin(a)  cos(a)  0 |
// |   0       0     1 |
//
// AngleRad - угол поворота в радианах (против часовой стрелки)
// AngleRad - rotation angle in radians (counter-clockwise)
function CreateRotationMatrix(AngleRad: Double): TUzvMatrix3x3;

// Создать матрицу переноса
// Create translation matrix
//
// | 1  0  tx |
// | 0  1  ty |
// | 0  0  1  |
function CreateTranslationMatrix(TX, TY: Double): TUzvMatrix3x3;

// Создать матрицу наклона (shear/oblique)
// Create shear matrix (oblique)
//
// Для наклона по X (italic effect):
// For X shear (italic effect):
// | 1  shearX  0 |
// | 0    1     0 |
// | 0    0     1 |
//
// shearX = tan(oblique_angle)
function CreateShearMatrix(ShearX, ShearY: Double): TUzvMatrix3x3;

// Создать матрицу зеркалирования по X
// Create X-axis mirror matrix
//
// | -1  0  0 |
// |  0  1  0 |
// |  0  0  1 |
function CreateMirrorXMatrix: TUzvMatrix3x3;

// Создать матрицу зеркалирования по Y
// Create Y-axis mirror matrix
//
// | 1   0  0 |
// | 0  -1  0 |
// | 0   0  1 |
function CreateMirrorYMatrix: TUzvMatrix3x3;

// === Операции с матрицами ===
// === Matrix operations ===

// Перемножить две матрицы: Result = A * B
// Multiply two matrices: Result = A * B
//
// Порядок важен: A * B != B * A (в общем случае)
// Order matters: A * B != B * A (in general)
//
// Для последовательного применения трансформаций T1, T2, T3:
// Result = T3 * T2 * T1 (применяется справа налево)
// For sequential transformations T1, T2, T3:
// Result = T3 * T2 * T1 (applied right to left)
function MultiplyMatrices(const A, B: TUzvMatrix3x3): TUzvMatrix3x3;

// Применить матрицу к точке
// Apply matrix to point
//
// | x' |   | a  b  tx |   | x |
// | y' | = | c  d  ty | * | y |
// | 1  |   | 0  0  1  |   | 1 |
//
// x' = a*x + b*y + tx
// y' = c*x + d*y + ty
function ApplyMatrixToPoint(const M: TUzvMatrix3x3; const P: TPointF): TPointF;

// Вычислить определитель матрицы (линейной части 2x2)
// Calculate matrix determinant (of 2x2 linear part)
//
// det = a*d - b*c
function MatrixDeterminant(const M: TUzvMatrix3x3): Double;

// Вычислить обратную матрицу
// Calculate inverse matrix
//
// Возвращает True если матрица обратима, False если det = 0
// Returns True if matrix is invertible, False if det = 0
function InvertMatrix(
  const M: TUzvMatrix3x3;
  out Inverse: TUzvMatrix3x3
): Boolean;

// Проверить, является ли матрица единичной
// Check if matrix is identity
function IsIdentityMatrix(const M: TUzvMatrix3x3): Boolean;

// Проверить валидность матрицы (нет NaN/Infinity)
// Check matrix validity (no NaN/Infinity)
function IsValidMatrix(const M: TUzvMatrix3x3): Boolean;

// === Утилиты ===
// === Utilities ===

// Преобразовать градусы в радианы
// Convert degrees to radians
function DegToRad(Degrees: Double): Double;

// Преобразовать радианы в градусы
// Convert radians to degrees
function RadToDeg(Radians: Double): Double;

// Получить строковое представление матрицы (для отладки)
// Get string representation of matrix (for debugging)
function MatrixToString(const M: TUzvMatrix3x3): string;

implementation

const
  // Порог для сравнения с нулём
  // Threshold for zero comparison
  EPSILON = 1E-10;

// Создать единичную матрицу
function CreateIdentityMatrix: TUzvMatrix3x3;
begin
  Result.A := 1.0;   Result.B := 0.0;   Result.TX := 0.0;
  Result.C := 0.0;   Result.D := 1.0;   Result.TY := 0.0;
end;

// Создать матрицу масштабирования
function CreateScaleMatrix(SX, SY: Double): TUzvMatrix3x3;
begin
  Result.A := SX;    Result.B := 0.0;   Result.TX := 0.0;
  Result.C := 0.0;   Result.D := SY;    Result.TY := 0.0;
end;

// Создать матрицу поворота
function CreateRotationMatrix(AngleRad: Double): TUzvMatrix3x3;
var
  CosA, SinA: Double;
begin
  CosA := Cos(AngleRad);
  SinA := Sin(AngleRad);

  Result.A := CosA;   Result.B := -SinA;  Result.TX := 0.0;
  Result.C := SinA;   Result.D := CosA;   Result.TY := 0.0;
end;

// Создать матрицу переноса
function CreateTranslationMatrix(TX, TY: Double): TUzvMatrix3x3;
begin
  Result.A := 1.0;   Result.B := 0.0;   Result.TX := TX;
  Result.C := 0.0;   Result.D := 1.0;   Result.TY := TY;
end;

// Создать матрицу наклона (shear)
function CreateShearMatrix(ShearX, ShearY: Double): TUzvMatrix3x3;
begin
  Result.A := 1.0;      Result.B := ShearX;   Result.TX := 0.0;
  Result.C := ShearY;   Result.D := 1.0;      Result.TY := 0.0;
end;

// Создать матрицу зеркалирования по X
function CreateMirrorXMatrix: TUzvMatrix3x3;
begin
  Result.A := -1.0;  Result.B := 0.0;   Result.TX := 0.0;
  Result.C := 0.0;   Result.D := 1.0;   Result.TY := 0.0;
end;

// Создать матрицу зеркалирования по Y
function CreateMirrorYMatrix: TUzvMatrix3x3;
begin
  Result.A := 1.0;   Result.B := 0.0;    Result.TX := 0.0;
  Result.C := 0.0;   Result.D := -1.0;   Result.TY := 0.0;
end;

// Перемножить две матрицы
// Формула для 3x3 аффинных матриц (с фиксированной третьей строкой):
// Formula for 3x3 affine matrices (with fixed third row):
//
// | a1 b1 tx1 |   | a2 b2 tx2 |   | a1*a2+b1*c2  a1*b2+b1*d2  a1*tx2+b1*ty2+tx1 |
// | c1 d1 ty1 | * | c2 d2 ty2 | = | c1*a2+d1*c2  c1*b2+d1*d2  c1*tx2+d1*ty2+ty1 |
// | 0  0  1   |   | 0  0  1   |   |     0            0               1          |
function MultiplyMatrices(const A, B: TUzvMatrix3x3): TUzvMatrix3x3;
begin
  // Линейная часть
  // Linear part
  Result.A := A.A * B.A + A.B * B.C;
  Result.B := A.A * B.B + A.B * B.D;
  Result.C := A.C * B.A + A.D * B.C;
  Result.D := A.C * B.B + A.D * B.D;

  // Компонента переноса
  // Translation component
  Result.TX := A.A * B.TX + A.B * B.TY + A.TX;
  Result.TY := A.C * B.TX + A.D * B.TY + A.TY;
end;

// Применить матрицу к точке
function ApplyMatrixToPoint(const M: TUzvMatrix3x3; const P: TPointF): TPointF;
begin
  Result.X := M.A * P.X + M.B * P.Y + M.TX;
  Result.Y := M.C * P.X + M.D * P.Y + M.TY;
end;

// Вычислить определитель матрицы (линейной части)
function MatrixDeterminant(const M: TUzvMatrix3x3): Double;
begin
  Result := M.A * M.D - M.B * M.C;
end;

// Вычислить обратную матрицу
// Формула для обратной 2x2 матрицы:
// Formula for inverse 2x2 matrix:
//
// | a b |-1      1     | d  -b |
// | c d |    = ----- * | -c  a |
//               det
//
// Для аффинной части:
// For affine part:
// tx' = -(a'*tx + b'*ty)
// ty' = -(c'*tx + d'*ty)
function InvertMatrix(
  const M: TUzvMatrix3x3;
  out Inverse: TUzvMatrix3x3
): Boolean;
var
  Det, InvDet: Double;
begin
  Det := MatrixDeterminant(M);

  // Проверка на вырожденность
  // Check for singularity
  if Abs(Det) < EPSILON then
  begin
    Inverse := CreateIdentityMatrix;
    Result := False;
    Exit;
  end;

  InvDet := 1.0 / Det;

  // Обратная линейная часть
  // Inverse linear part
  Inverse.A := M.D * InvDet;
  Inverse.B := -M.B * InvDet;
  Inverse.C := -M.C * InvDet;
  Inverse.D := M.A * InvDet;

  // Обратный перенос
  // Inverse translation
  Inverse.TX := -(Inverse.A * M.TX + Inverse.B * M.TY);
  Inverse.TY := -(Inverse.C * M.TX + Inverse.D * M.TY);

  Result := True;
end;

// Проверить, является ли матрица единичной
function IsIdentityMatrix(const M: TUzvMatrix3x3): Boolean;
begin
  Result := (Abs(M.A - 1.0) < EPSILON) and
            (Abs(M.B) < EPSILON) and
            (Abs(M.TX) < EPSILON) and
            (Abs(M.C) < EPSILON) and
            (Abs(M.D - 1.0) < EPSILON) and
            (Abs(M.TY) < EPSILON);
end;

// Проверить валидность матрицы
function IsValidMatrix(const M: TUzvMatrix3x3): Boolean;
begin
  Result := (not IsNaN(M.A)) and (not IsInfinite(M.A)) and
            (not IsNaN(M.B)) and (not IsInfinite(M.B)) and
            (not IsNaN(M.C)) and (not IsInfinite(M.C)) and
            (not IsNaN(M.D)) and (not IsInfinite(M.D)) and
            (not IsNaN(M.TX)) and (not IsInfinite(M.TX)) and
            (not IsNaN(M.TY)) and (not IsInfinite(M.TY));
end;

// Преобразовать градусы в радианы
function DegToRad(Degrees: Double): Double;
begin
  Result := Degrees * Pi / 180.0;
end;

// Преобразовать радианы в градусы
function RadToDeg(Radians: Double): Double;
begin
  Result := Radians * 180.0 / Pi;
end;

// Получить строковое представление матрицы
function MatrixToString(const M: TUzvMatrix3x3): string;
begin
  Result := Format(
    '| %8.4f %8.4f %8.4f |' + LineEnding +
    '| %8.4f %8.4f %8.4f |' + LineEnding +
    '| %8.4f %8.4f %8.4f |',
    [M.A, M.B, M.TX, M.C, M.D, M.TY, 0.0, 0.0, 1.0]
  );
end;

end.
