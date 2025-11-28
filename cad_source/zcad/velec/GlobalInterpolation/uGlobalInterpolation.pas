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
{**
  Модуль GlobalInterpolation - портирование функций глобальной интерполяции
  из библиотеки LNLib (C++) в FreePascal.

  Module GlobalInterpolation - porting of global interpolation functions
  from LNLib library (C++) to FreePascal.

  Основано на реализации из: https://github.com/BIMCoderLiang/LNLib
  Based on implementation from: https://github.com/BIMCoderLiang/LNLib

  Алгоритмы соответствуют "The NURBS Book" 2nd Edition (Piegl & Tiller)
  Algorithms match "The NURBS Book" 2nd Edition (Piegl & Tiller)
}
unit uGlobalInterpolation;

{$mode delphi}{$H+}

interface

uses
  SysUtils, Math,
  uzegeometrytypes,
  uzeNURBSTypes,
  uzcLog;

type
  {** Результат глобальной интерполяции / Result of global interpolation **}
  TNurbsCurveData = record
    Degree: Integer;                      // Степень кривой / Curve degree
    KnotVector: TKnotsVector;             // Вектор узлов / Knot vector
    ControlPoints: TControlPointsArray;   // Контрольные точки / Control points
  end;

{**
  Глобальная интерполяция NURBS-кривой через заданные точки
  Global interpolation of NURBS curve through specified points

  @param ADegree Степень кривой (должна быть >= 1) / Curve degree (must be >= 1)
  @param AThroughPoints Массив точек, через которые должна пройти кривая /
                        Array of points the curve should pass through
  @param ACurve Выходная структура с данными кривой / Output curve data structure
  @param AParams Опциональные параметры (если пустой - используется хордовая параметризация) /
                 Optional parameters (if empty - chord parameterization is used)

  Функция вычисляет контрольные точки NURBS-кривой заданной степени,
  которая точно проходит через все указанные точки.

  The function calculates control points of a NURBS curve of given degree
  that passes exactly through all specified points.
}
procedure GlobalInterpolation(const ADegree: Integer;
  const AThroughPoints: array of TzePoint3d;
  var ACurve: TNurbsCurveData;
  const AParams: array of Double); overload;

{**
  Глобальная интерполяция NURBS-кривой с учётом касательных векторов
  Global interpolation of NURBS curve with tangent constraints

  @param ADegree Степень кривой (должна быть >= 2) / Curve degree (must be >= 2)
  @param AThroughPoints Массив точек, через которые должна пройти кривая /
                        Array of points the curve should pass through
  @param ATangents Касательные векторы в каждой точке / Tangent vectors at each point
  @param ATangentFactor Множитель для касательных (должен быть > 0) /
                        Multiplier for tangents (must be > 0)
  @param ACurve Выходная структура с данными кривой / Output curve data structure

  Функция вычисляет контрольные точки NURBS-кривой, которая проходит через
  заданные точки и имеет указанные касательные векторы в этих точках.

  The function calculates control points of a NURBS curve that passes through
  specified points and has given tangent vectors at those points.
}
procedure GlobalInterpolation(const ADegree: Integer;
  const AThroughPoints: array of TzePoint3d;
  const ATangents: array of TzePoint3d;
  const ATangentFactor: Double;
  var ACurve: TNurbsCurveData); overload;

implementation

type
  TMatrix = array of array of Double;
  TDoubleArray = array of Double;

const
  // Максимальная степень NURBS (из LNLib Constants::NURBSMaxDegree)
  // Maximum NURBS degree (from LNLib Constants::NURBSMaxDegree)
  NURBS_MAX_DEGREE = 20;

  // Эпсилон для сравнения вещественных чисел
  // Epsilon for floating point comparison
  EPSILON = 1e-10;

{**
  Находит индекс интервала узлового вектора, содержащего параметр u
  Finds the knot span index containing parameter u

  Соответствует: Polynomials::GetKnotSpanIndex из LNLib
  Corresponds to: Polynomials::GetKnotSpanIndex from LNLib

  Алгоритм A2.1 из "The NURBS Book"
  Algorithm A2.1 from "The NURBS Book"

  @param ADegree Степень кривой / Curve degree
  @param AKnotVector Вектор узлов / Knot vector
  @param AParameter Параметр для поиска / Parameter to find
  @return Индекс интервала узлов / Knot span index
}
function GetKnotSpanIndex(const ADegree: Integer;
  const AKnotVector: array of Double;
  const AParameter: Double): Integer;
var
  n, low, high, mid: Integer;
begin
  // n = число контрольных точек - 1
  // n = number of control points - 1
  n := Length(AKnotVector) - ADegree - 2;

  // Особый случай: параметр на верхней границе
  // Special case: parameter at upper bound
  if Abs(AParameter - AKnotVector[n + 1]) < EPSILON then
  begin
    Result := n;
    Exit;
  end;

  // Бинарный поиск интервала узлов
  // Binary search for knot span
  low := ADegree;
  high := n + 1;
  mid := (low + high) div 2;

  while (AParameter < AKnotVector[mid]) or (AParameter >= AKnotVector[mid + 1]) do
  begin
    if AParameter < AKnotVector[mid] then
      high := mid
    else
      low := mid;
    mid := (low + high) div 2;
  end;

  Result := mid;
end;

{**
  Вычисляет ненулевые базисные функции в точке u
  Computes non-zero basis functions at parameter u

  Соответствует: Polynomials::BasisFunctions из LNLib
  Corresponds to: Polynomials::BasisFunctions from LNLib

  Алгоритм A2.2 из "The NURBS Book"
  Algorithm A2.2 from "The NURBS Book"

  @param ASpanIndex Индекс интервала узлов / Knot span index
  @param ADegree Степень кривой / Curve degree
  @param AKnotVector Вектор узлов / Knot vector
  @param AParameter Параметр / Parameter
  @param ABasis Выходной массив базисных функций (размер ADegree+1) /
                Output array of basis functions (size ADegree+1)
}
procedure BasisFunctionsArray(const ASpanIndex, ADegree: Integer;
  const AKnotVector: array of Double;
  const AParameter: Double;
  var ABasis: array of Double);
var
  left, right: array of Double;
  j, r: Integer;
  saved, temp: Double;
begin
  SetLength(left, ADegree + 1);
  SetLength(right, ADegree + 1);

  ABasis[0] := 1.0;

  for j := 1 to ADegree do
  begin
    left[j] := AParameter - AKnotVector[ASpanIndex + 1 - j];
    right[j] := AKnotVector[ASpanIndex + j] - AParameter;
    saved := 0.0;

    for r := 0 to j - 1 do
    begin
      temp := ABasis[r] / (right[r + 1] + left[j - r]);
      ABasis[r] := saved + right[r + 1] * temp;
      saved := left[j - r] * temp;
    end;

    ABasis[j] := saved;
  end;
end;

{**
  Вычисляет производные базисных функций до порядка ADerivOrder
  Computes basis function derivatives up to order ADerivOrder

  Соответствует: Polynomials::BasisFunctionsDerivatives из LNLib
  Corresponds to: Polynomials::BasisFunctionsDerivatives from LNLib

  Алгоритм A2.3 из "The NURBS Book"
  Algorithm A2.3 from "The NURBS Book"

  @param ASpanIndex Индекс интервала узлов / Knot span index
  @param ADegree Степень кривой / Curve degree
  @param ADerivOrder Порядок производной (обычно 1 или 2) / Derivative order (usually 1 or 2)
  @param AKnotVector Вектор узлов / Knot vector
  @param AParameter Параметр / Parameter
  @return Матрица производных [порядок производной][функция] /
          Matrix of derivatives [derivative order][function]
}
function BasisFunctionsDerivatives(const ASpanIndex, ADegree, ADerivOrder: Integer;
  const AKnotVector: array of Double;
  const AParameter: Double): TMatrix;
var
  ndu, a: TMatrix;
  left, right: TDoubleArray;
  ders: TMatrix;
  i, j, k, r, s1, s2, rk, pk, j1, j2: Integer;
  saved, temp, d: Double;
begin
  SetLength(ders, ADerivOrder + 1, ADegree + 1);
  SetLength(ndu, ADegree + 1, ADegree + 1);
  SetLength(a, 2, ADegree + 1);
  SetLength(left, ADegree + 1);
  SetLength(right, ADegree + 1);

  ndu[0][0] := 1.0;

  for j := 1 to ADegree do
  begin
    left[j] := AParameter - AKnotVector[ASpanIndex + 1 - j];
    right[j] := AKnotVector[ASpanIndex + j] - AParameter;
    saved := 0.0;

    for r := 0 to j - 1 do
    begin
      ndu[j][r] := right[r + 1] + left[j - r];
      temp := ndu[r][j - 1] / ndu[j][r];

      ndu[r][j] := saved + right[r + 1] * temp;
      saved := left[j - r] * temp;
    end;

    ndu[j][j] := saved;
  end;

  // Загрузка базисных функций (нулевая производная)
  // Load basis functions (zero derivative)
  for j := 0 to ADegree do
    ders[0][j] := ndu[j][ADegree];

  // Вычисление производных (Алгоритм A2.3)
  // Compute derivatives (Algorithm A2.3)
  for r := 0 to ADegree do
  begin
    s1 := 0;
    s2 := 1;
    a[0][0] := 1.0;

    for k := 1 to ADerivOrder do
    begin
      d := 0.0;
      rk := r - k;
      pk := ADegree - k;

      if r >= k then
      begin
        a[s2][0] := a[s1][0] / ndu[pk + 1][rk];
        d := a[s2][0] * ndu[rk][pk];
      end;

      if rk >= -1 then
        j1 := 1
      else
        j1 := -rk;

      if (r - 1) <= pk then
        j2 := k - 1
      else
        j2 := ADegree - r;

      for j := j1 to j2 do
      begin
        a[s2][j] := (a[s1][j] - a[s1][j - 1]) / ndu[pk + 1][rk + j];
        d := d + a[s2][j] * ndu[rk + j][pk];
      end;

      if r <= pk then
      begin
        a[s2][k] := -a[s1][k - 1] / ndu[pk + 1][r];
        d := d + a[s2][k] * ndu[r][pk];
      end;

      ders[k][r] := d;

      // Обмен строк
      // Swap rows
      j := s1;
      s1 := s2;
      s2 := j;
    end;
  end;

  // Умножение на корректные факториальные множители
  // Multiply by correct factorial factors
  r := ADegree;
  for k := 1 to ADerivOrder do
  begin
    for j := 0 to ADegree do
      ders[k][j] := ders[k][j] * r;
    r := r * (ADegree - k);
  end;

  Result := ders;
end;

{**
  Вычисляет общую длину хорд между точками
  Computes total chord length between points

  Соответствует: Interpolation::GetTotalChordLength из LNLib
  Corresponds to: Interpolation::GetTotalChordLength from LNLib

  @param APoints Массив точек / Array of points
  @return Суммарная длина хорд / Total chord length
}
function GetTotalChordLength(const APoints: array of TzePoint3d): Double;
var
  i: Integer;
  chordLength: Double;
begin
  Result := 0.0;

  if Length(APoints) < 2 then
    Exit;

  for i := 0 to Length(APoints) - 2 do
  begin
    chordLength := Sqrt(
      Sqr(APoints[i + 1].x - APoints[i].x) +
      Sqr(APoints[i + 1].y - APoints[i].y) +
      Sqr(APoints[i + 1].z - APoints[i].z)
    );
    Result := Result + chordLength;
  end;
end;

{**
  Вычисляет параметры методом хордовой параметризации
  Computes parameters using chord length parameterization

  Соответствует: Interpolation::GetChordParameterization из LNLib
  Corresponds to: Interpolation::GetChordParameterization from LNLib

  Алгоритм из "The NURBS Book" раздел 9.2.1
  Algorithm from "The NURBS Book" section 9.2.1

  @param APoints Массив точек / Array of points
  @param AParams Выходной массив параметров [0,1] / Output parameter array [0,1]
}
procedure GetChordParameterization(const APoints: array of TzePoint3d;
  var AParams: TDoubleArray);
var
  i: Integer;
  totalLength, chordLength: Double;
begin
  if Length(APoints) < 2 then
    Exit;

  SetLength(AParams, Length(APoints));
  AParams[0] := 0.0;
  AParams[Length(APoints) - 1] := 1.0;

  if Length(APoints) = 2 then
    Exit;

  // Вычисление общей длины хорд
  // Calculate total chord length
  totalLength := 0.0;
  for i := 0 to Length(APoints) - 2 do
  begin
    chordLength := Sqrt(
      Sqr(APoints[i + 1].x - APoints[i].x) +
      Sqr(APoints[i + 1].y - APoints[i].y) +
      Sqr(APoints[i + 1].z - APoints[i].z)
    );
    totalLength := totalLength + chordLength;
    AParams[i + 1] := totalLength;
  end;

  // Нормализация к интервалу [0,1]
  // Normalize to interval [0,1]
  if totalLength > EPSILON then
  begin
    for i := 1 to Length(APoints) - 1 do
      AParams[i] := AParams[i] / totalLength;
  end
  else
  begin
    // Если все точки совпадают, используем равномерную параметризацию
    // If all points coincide, use uniform parameterization
    for i := 1 to Length(APoints) - 1 do
      AParams[i] := i / (Length(APoints) - 1);
  end;
end;

{**
  Генерирует вектор узлов методом усреднения
  Generates knot vector using averaging method

  Соответствует: Interpolation::AverageKnotVector из LNLib
  Corresponds to: Interpolation::AverageKnotVector from LNLib

  Алгоритм A9.1 из "The NURBS Book"
  Algorithm A9.1 from "The NURBS Book"

  @param ADegree Степень кривой / Curve degree
  @param AParams Параметры точек / Point parameters
  @param AKnots Выходной вектор узлов / Output knot vector
}
procedure AverageKnotVector(const ADegree: Integer;
  const AParams: TDoubleArray;
  var AKnots: TDoubleArray);
var
  n, m, i, j: Integer;
  sum: Double;
begin
  n := Length(AParams) - 1;  // n = m (индекс последней точки)
  m := n + ADegree + 1;      // m для вектора узлов

  SetLength(AKnots, m + 1);

  // Зажатый вектор узлов: первые (p+1) узлов = 0
  // Clamped knot vector: first (p+1) knots = 0
  for i := 0 to ADegree do
    AKnots[i] := 0.0;

  // Внутренние узлы: усреднение p последовательных параметров
  // Internal knots: average p consecutive parameters
  for j := 1 to n - ADegree do
  begin
    sum := 0.0;
    for i := j to j + ADegree - 1 do
      sum := sum + AParams[i];
    AKnots[j + ADegree] := sum / ADegree;
  end;

  // Зажатый вектор узлов: последние (p+1) узлов = 1
  // Clamped knot vector: last (p+1) knots = 1
  for i := n + 1 to m do
    AKnots[i] := 1.0;
end;

{**
  Решение системы линейных уравнений методом Гаусса с частичным выбором ведущего элемента
  Solves linear system using Gaussian elimination with partial pivoting

  Соответствует: MathUtils::SolveLinearSystem из LNLib
  Corresponds to: MathUtils::SolveLinearSystem from LNLib

  @param A Матрица коэффициентов (будет изменена) / Coefficient matrix (will be modified)
  @param B Правая часть (массив столбцов для x,y,z) / Right-hand side (array of columns for x,y,z)
  @return Решение (массив столбцов для x,y,z) / Solution (array of columns for x,y,z)
}
function SolveLinearSystem(var A: TMatrix; const B: TMatrix): TMatrix;
var
  n, m, i, j, k, maxRow: Integer;
  maxVal, tmp, factor: Double;
  C: TMatrix;
begin
  n := Length(A);     // Число уравнений / Number of equations
  m := Length(B[0]);  // Число столбцов (3 для x,y,z) / Number of columns (3 for x,y,z)

  // Создание копии правой части
  // Create copy of right-hand side
  SetLength(C, n, m);
  for i := 0 to n - 1 do
    for j := 0 to m - 1 do
      C[i][j] := B[i][j];

  // Прямой ход с частичным выбором ведущего элемента
  // Forward elimination with partial pivoting
  for k := 0 to n - 2 do
  begin
    // Поиск ведущего элемента
    // Find pivot
    maxRow := k;
    maxVal := Abs(A[k][k]);
    for i := k + 1 to n - 1 do
    begin
      if Abs(A[i][k]) > maxVal then
      begin
        maxVal := Abs(A[i][k]);
        maxRow := i;
      end;
    end;

    // Обмен строк при необходимости
    // Swap rows if needed
    if maxRow <> k then
    begin
      for j := k to n - 1 do
      begin
        tmp := A[k][j];
        A[k][j] := A[maxRow][j];
        A[maxRow][j] := tmp;
      end;
      for j := 0 to m - 1 do
      begin
        tmp := C[k][j];
        C[k][j] := C[maxRow][j];
        C[maxRow][j] := tmp;
      end;
    end;

    // Исключение элементов столбца
    // Eliminate column elements
    for i := k + 1 to n - 1 do
    begin
      if Abs(A[k][k]) > EPSILON then
      begin
        factor := A[i][k] / A[k][k];
        for j := k to n - 1 do
          A[i][j] := A[i][j] - factor * A[k][j];
        for j := 0 to m - 1 do
          C[i][j] := C[i][j] - factor * C[k][j];
      end;
    end;
  end;

  // Обратный ход
  // Back substitution
  SetLength(Result, n, m);
  for j := 0 to m - 1 do
  begin
    for i := n - 1 downto 0 do
    begin
      Result[i][j] := C[i][j];
      for k := i + 1 to n - 1 do
        Result[i][j] := Result[i][j] - A[i][k] * Result[k][j];
      if Abs(A[i][i]) > EPSILON then
        Result[i][j] := Result[i][j] / A[i][i]
      else
        Result[i][j] := 0.0;
    end;
  end;
end;

{**
  Нормализация вектора (приведение к единичной длине)
  Vector normalization (making unit length)

  @param AVector Вектор для нормализации / Vector to normalize
  @return Нормализованный вектор / Normalized vector
}
function NormalizeVector(const AVector: TzePoint3d): TzePoint3d;
var
  len: Double;
begin
  len := Sqrt(Sqr(AVector.x) + Sqr(AVector.y) + Sqr(AVector.z));

  if len > EPSILON then
  begin
    Result.x := AVector.x / len;
    Result.y := AVector.y / len;
    Result.z := AVector.z / len;
  end
  else
  begin
    Result.x := 0.0;
    Result.y := 0.0;
    Result.z := 0.0;
  end;
end;

// ============================================================================
// ГЛОБАЛЬНАЯ ИНТЕРПОЛЯЦИЯ - БАЗОВАЯ ВЕРСИЯ
// GLOBAL INTERPOLATION - BASIC VERSION
// ============================================================================

procedure GlobalInterpolation(const ADegree: Integer;
  const AThroughPoints: array of TzePoint3d;
  var ACurve: TNurbsCurveData;
  const AParams: array of Double);
var
  size, n, i, j, spanIndex: Integer;
  uk: TDoubleArray;
  knotVector: TDoubleArray;
  A, right, result: TMatrix;
  basis: array of Double;
begin
  ProgramLog.LogOutFormatStr('GlobalInterpolation: Start with %d points, degree=%d',
    [Length(AThroughPoints), ADegree], LM_Info);

  // Проверка входных параметров
  // Validate input parameters
  if ADegree < 1 then
    raise Exception.Create('GlobalInterpolation: Degree must be >= 1');

  size := Length(AThroughPoints);

  if size <= ADegree then
    raise Exception.CreateFmt('GlobalInterpolation: ThroughPoints size (%d) must be greater than degree (%d)',
      [size, ADegree]);

  n := size - 1;

  // Шаг 1: Вычисление параметров
  // Step 1: Compute parameters
  if Length(AParams) = 0 then
  begin
    ProgramLog.LogOutFormatStr('GlobalInterpolation: Computing chord parameterization', [], LM_Info);
    GetChordParameterization(AThroughPoints, uk);
  end
  else
  begin
    if Length(AParams) <> size then
      raise Exception.CreateFmt('GlobalInterpolation: Params size (%d) must equal ThroughPoints size (%d)',
        [Length(AParams), size]);
    SetLength(uk, size);
    for i := 0 to size - 1 do
      uk[i] := AParams[i];
    ProgramLog.LogOutFormatStr('GlobalInterpolation: Using provided parameters', [], LM_Info);
  end;

  // Шаг 2: Генерация вектора узлов
  // Step 2: Generate knot vector
  ProgramLog.LogOutFormatStr('GlobalInterpolation: Generating knot vector', [], LM_Info);
  AverageKnotVector(ADegree, uk, knotVector);

  // Шаг 3: Построение матрицы интерполяции
  // Step 3: Build interpolation matrix
  ProgramLog.LogOutFormatStr('GlobalInterpolation: Building interpolation matrix %dx%d',
    [size, size], LM_Info);

  SetLength(A, size, size);
  for i := 0 to size - 1 do
    for j := 0 to size - 1 do
      A[i][j] := 0.0;

  SetLength(basis, ADegree + 1);

  // Заполнение внутренних строк матрицы
  // Fill internal matrix rows
  for i := 1 to n - 1 do
  begin
    spanIndex := GetKnotSpanIndex(ADegree, knotVector, uk[i]);
    BasisFunctionsArray(spanIndex, ADegree, knotVector, uk[i], basis);

    for j := 0 to ADegree do
      A[i][spanIndex - ADegree + j] := basis[j];
  end;

  // Граничные условия: первая и последняя строки
  // Boundary conditions: first and last rows
  A[0][0] := 1.0;
  A[n][n] := 1.0;

  // Шаг 4: Подготовка правой части для x, y, z
  // Step 4: Prepare right-hand side for x, y, z
  SetLength(right, size, 3);
  for i := 0 to size - 1 do
  begin
    right[i][0] := AThroughPoints[i].x;
    right[i][1] := AThroughPoints[i].y;
    right[i][2] := AThroughPoints[i].z;
  end;

  // Шаг 5: Решение системы
  // Step 5: Solve system
  ProgramLog.LogOutFormatStr('GlobalInterpolation: Solving linear system', [], LM_Info);
  result := SolveLinearSystem(A, right);

  // Шаг 6: Заполнение выходной структуры
  // Step 6: Fill output structure
  ACurve.Degree := ADegree;

  // Инициализация вектора узлов перед использованием
  // Initialize knot vector before use
  ACurve.KnotVector.initnul;
  ACurve.KnotVector.Clear;
  for i := 0 to Length(knotVector) - 1 do
    ACurve.KnotVector.PushBackData(knotVector[i]);

  SetLength(ACurve.ControlPoints, size);
  for i := 0 to size - 1 do
  begin
    ACurve.ControlPoints[i].x := result[i][0];
    ACurve.ControlPoints[i].y := result[i][1];
    ACurve.ControlPoints[i].z := result[i][2];
  end;

  ProgramLog.LogOutFormatStr('GlobalInterpolation: Success - generated %d control points, %d knots',
    [Length(ACurve.ControlPoints), ACurve.KnotVector.Count], LM_Info);
end;

// ============================================================================
// ГЛОБАЛЬНАЯ ИНТЕРПОЛЯЦИЯ С КАСАТЕЛЬНЫМИ
// GLOBAL INTERPOLATION WITH TANGENTS
// ============================================================================

procedure GlobalInterpolation(const ADegree: Integer;
  const AThroughPoints: array of TzePoint3d;
  const ATangents: array of TzePoint3d;
  const ATangentFactor: Double;
  var ACurve: TNurbsCurveData);
var
  size, n, i, j, spanIndex: Integer;
  unitTangents: array of TzePoint3d;
  knotVector: TDoubleArray;
  uk, uk2: TDoubleArray;
  d, d0, dn: Double;
  A, right, result: TMatrix;
  basis: array of Double;
  derBasis: TMatrix;
begin
  ProgramLog.LogOutFormatStr('GlobalInterpolation (with tangents): Start with %d points, degree=%d, tangentFactor=%.4f',
    [Length(AThroughPoints), ADegree, ATangentFactor], LM_Info);

  // Проверка входных параметров
  // Validate input parameters
  if ADegree < 2 then
    raise Exception.Create('GlobalInterpolation (tangents): Degree must be >= 2');

  size := Length(AThroughPoints);

  if size <= ADegree then
    raise Exception.CreateFmt('GlobalInterpolation (tangents): ThroughPoints size (%d) must be greater than degree (%d)',
      [size, ADegree]);

  if Length(ATangents) <> size then
    raise Exception.CreateFmt('GlobalInterpolation (tangents): Tangents size (%d) must equal ThroughPoints size (%d)',
      [Length(ATangents), size]);

  if ATangentFactor <= 0.0 then
    raise Exception.Create('GlobalInterpolation (tangents): TangentFactor must be > 0');

  // Нормализация касательных векторов
  // Normalize tangent vectors
  ProgramLog.LogOutFormatStr('GlobalInterpolation (tangents): Normalizing tangent vectors', [], LM_Info);
  SetLength(unitTangents, size);
  for i := 0 to size - 1 do
    unitTangents[i] := NormalizeVector(ATangents[i]);

  n := 2 * size;  // Удвоенное количество контрольных точек / Doubled number of control points

  // Вычисление общей длины хорд
  // Compute total chord length
  d := GetTotalChordLength(AThroughPoints);
  ProgramLog.LogOutFormatStr('GlobalInterpolation (tangents): Total chord length=%.4f', [d], LM_Info);

  // Вычисление параметров
  // Compute parameters
  GetChordParameterization(AThroughPoints, uk);

  // Генерация вектора узлов в зависимости от степени
  // Generate knot vector depending on degree
  ProgramLog.LogOutFormatStr('GlobalInterpolation (tangents): Generating knot vector for degree %d', [ADegree], LM_Info);
  SetLength(knotVector, n + ADegree + 1);

  case ADegree of
    2:
    begin
      // Случай степени 2
      // Degree 2 case
      for i := 0 to ADegree do
      begin
        knotVector[i] := 0.0;
        knotVector[Length(knotVector) - 1 - i] := 1.0;
      end;
      for i := 0 to size - 2 do
      begin
        knotVector[2 * i + ADegree] := uk[i];
        knotVector[2 * i + ADegree + 1] := (uk[i] + uk[i + 1]) / 2.0;
      end;
    end;

    3:
    begin
      // Случай степени 3 (кубический)
      // Degree 3 case (cubic)
      for i := 0 to ADegree do
      begin
        knotVector[i] := 0.0;
        knotVector[Length(knotVector) - 1 - i] := 1.0;
      end;
      for i := 1 to size - 2 do
      begin
        knotVector[ADegree + 2 * i] := (2 * uk[i] + uk[i + 1]) / 3.0;
        knotVector[ADegree + 2 * i + 1] := (uk[i] + 2 * uk[i + 1]) / 3.0;
      end;
      knotVector[4] := uk[1] / 2.0;
      knotVector[Length(knotVector) - ADegree - 2] := (uk[size - 1] + 1.0) / 2.0;
    end;

    else
    begin
      // Общий случай для других степеней
      // General case for other degrees
      SetLength(uk2, 2 * size);
      for i := 0 to size - 2 do
      begin
        uk2[2 * i] := uk[i];
        uk2[2 * i + 1] := (uk[i] + uk[i + 1]) / 2.0;
      end;
      uk2[Length(uk2) - 2] := (uk2[Length(uk2) - 1] + uk2[Length(uk2) - 3]) / 2.0;
      AverageKnotVector(ADegree, uk2, knotVector);
    end;
  end;

  // Построение расширенной матрицы с производными
  // Build augmented matrix with derivatives
  ProgramLog.LogOutFormatStr('GlobalInterpolation (tangents): Building augmented matrix %dx%d',
    [n, n], LM_Info);

  SetLength(A, n, n);
  for i := 0 to n - 1 do
    for j := 0 to n - 1 do
      A[i][j] := 0.0;

  SetLength(basis, ADegree + 1);

  // Заполнение внутренних строк (позиции и производные)
  // Fill internal rows (positions and derivatives)
  for i := 1 to size - 2 do
  begin
    spanIndex := GetKnotSpanIndex(ADegree, knotVector, uk[i]);
    BasisFunctionsArray(spanIndex, ADegree, knotVector, uk[i], basis);
    derBasis := BasisFunctionsDerivatives(spanIndex, ADegree, 1, knotVector, uk[i]);

    for j := 0 to ADegree do
    begin
      A[2 * i][spanIndex - ADegree + j] := basis[j];
      A[2 * i + 1][spanIndex - ADegree + j] := derBasis[1][j];
    end;
  end;

  // Граничные условия
  // Boundary conditions
  A[0][0] := 1.0;
  A[1][0] := -1.0;
  A[1][1] := 1.0;
  A[n - 2][n - 2] := -1.0;
  A[n - 2][n - 1] := 1.0;
  A[n - 1][n - 1] := 1.0;

  // Подготовка правой части
  // Prepare right-hand side
  SetLength(right, n, 3);
  for i := 0 to size - 1 do
  begin
    right[2 * i][0] := AThroughPoints[i].x;
    right[2 * i][1] := AThroughPoints[i].y;
    right[2 * i][2] := AThroughPoints[i].z;

    right[2 * i + 1][0] := unitTangents[i].x * d * ATangentFactor;
    right[2 * i + 1][1] := unitTangents[i].y * d * ATangentFactor;
    right[2 * i + 1][2] := unitTangents[i].z * d * ATangentFactor;
  end;

  // Специальные граничные условия
  // Special boundary conditions
  d0 := knotVector[ADegree + 1] / ADegree;
  dn := (1.0 - knotVector[Length(knotVector) - ADegree - 2]) / ADegree;

  right[1][0] := d0 * unitTangents[0].x * d * ATangentFactor;
  right[1][1] := d0 * unitTangents[0].y * d * ATangentFactor;
  right[1][2] := d0 * unitTangents[0].z * d * ATangentFactor;

  right[n - 2][0] := dn * unitTangents[size - 1].x * d * ATangentFactor;
  right[n - 2][1] := dn * unitTangents[size - 1].y * d * ATangentFactor;
  right[n - 2][2] := dn * unitTangents[size - 1].z * d * ATangentFactor;

  right[n - 1][0] := AThroughPoints[size - 1].x;
  right[n - 1][1] := AThroughPoints[size - 1].y;
  right[n - 1][2] := AThroughPoints[size - 1].z;

  // Решение системы
  // Solve system
  ProgramLog.LogOutFormatStr('GlobalInterpolation (tangents): Solving linear system', [], LM_Info);
  result := SolveLinearSystem(A, right);

  // Заполнение выходной структуры
  // Fill output structure
  ACurve.Degree := ADegree;

  // Инициализация вектора узлов перед использованием
  // Initialize knot vector before use
  ACurve.KnotVector.initnul;
  ACurve.KnotVector.Clear;
  for i := 0 to Length(knotVector) - 1 do
    ACurve.KnotVector.PushBackData(knotVector[i]);

  SetLength(ACurve.ControlPoints, n);
  for i := 0 to n - 1 do
  begin
    ACurve.ControlPoints[i].x := result[i][0];
    ACurve.ControlPoints[i].y := result[i][1];
    ACurve.ControlPoints[i].z := result[i][2];
  end;

  ProgramLog.LogOutFormatStr('GlobalInterpolation (tangents): Success - generated %d control points, %d knots',
    [Length(ACurve.ControlPoints), ACurve.KnotVector.Count], LM_Info);
end;

end.
