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
  Модуль LNLibTests - автоматические ABI-тесты для generic-биндинга.

  Обеспечивает проверку корректности работы биндинга к библиотеке LNLib
  путём выполнения вычислений и сравнения результатов с эталонными
  значениями, вычисленными на стороне Pascal.

  Обязательные тесты (выполняются при загрузке):
  1. v := (1, 2, 3)
  2. length(v) = sqrt(14)
  3. sqr_length(v) = 14
  4. normalize(v) -> length = 1
  5. cross((1,0,0), (0,1,0)) = (0,0,1)
  6. dot((1,2,3), (4,5,6)) = 32
  7. distance(a, b) - сверка с Pascal-расчётом

  Допустимая погрешность: 1e-9

  Дата создания: 2025-12-03
  Зависимости: SysUtils, Math, LNLibABI
}
unit LNLibTests;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Math, LNLibABI;

type
  {**
    Результат выполнения теста.
  }
  TTestResult = record
    TestName: string;
    Passed: Boolean;
    Message: string;
    Expected: Double;
    Actual: Double;
  end;

  {**
    Массив результатов тестов.
  }
  TTestResults = array of TTestResult;

  {**
    Generic-класс тестирования биндинга XYZ.

    Выполняет все обязательные тесты для проверки корректности
    ABI-совместимости и работы функций библиотеки.
  }
  generic TLNXYZTests<TVec> = class
  public type
    PVec = ^TVec;

    { Типы функций для тестирования }
    Txyz_create = function(x, y, z: Double): TVec; cdecl;
    Txyz_length = function(v: TVec): Double; cdecl;
    Txyz_sqr_length = function(v: TVec): Double; cdecl;
    Txyz_normalize = function(v: TVec): TVec; cdecl;
    Txyz_dot = function(a, b: TVec): Double; cdecl;
    Txyz_cross = function(a, b: TVec): TVec; cdecl;
    Txyz_distance = function(a, b: TVec): Double; cdecl;

  private
    { Указатели на тестируемые функции }
    class var Fxyz_create: Txyz_create;
    class var Fxyz_length: Txyz_length;
    class var Fxyz_sqr_length: Txyz_sqr_length;
    class var Fxyz_normalize: Txyz_normalize;
    class var Fxyz_dot: Txyz_dot;
    class var Fxyz_cross: Txyz_cross;
    class var Fxyz_distance: Txyz_distance;

    { Вспомогательные методы для доступа к компонентам вектора }
    class function GetX(const v: TVec): Double; static;
    class function GetY(const v: TVec): Double; static;
    class function GetZ(const v: TVec): Double; static;

  public
    {**
      Установка указателей на функции для тестирования.

      @param CreateFunc Функция создания вектора
      @param LengthFunc Функция вычисления длины
      @param SqrLengthFunc Функция вычисления квадрата длины
      @param NormalizeFunc Функция нормализации
      @param DotFunc Функция скалярного произведения
      @param CrossFunc Функция векторного произведения
      @param DistanceFunc Функция вычисления расстояния
    }
    class procedure SetFunctions(
      CreateFunc: Txyz_create;
      LengthFunc: Txyz_length;
      SqrLengthFunc: Txyz_sqr_length;
      NormalizeFunc: Txyz_normalize;
      DotFunc: Txyz_dot;
      CrossFunc: Txyz_cross;
      DistanceFunc: Txyz_distance); static;

    {**
      Выполнение всех обязательных тестов.

      @return Массив результатов тестов
    }
    class function RunAllTests: TTestResults; static;

    {**
      Проверка, прошли ли все тесты.

      @param Results Массив результатов тестов
      @return True если все тесты пройдены успешно
    }
    class function AllTestsPassed(const Results: TTestResults): Boolean; static;

    { Отдельные тесты }
    class function TestVectorCreation: TTestResult; static;
    class function TestLength: TTestResult; static;
    class function TestSqrLength: TTestResult; static;
    class function TestNormalize: TTestResult; static;
    class function TestCross: TTestResult; static;
    class function TestDot: TTestResult; static;
    class function TestDistance: TTestResult; static;
  end;

  {**
    Generic-класс тестирования биндинга Matrix4d.
  }
  generic TLNMatrixTests<TMat, TVec> = class
  public type
    PMat = ^TMat;
    PVec = ^TVec;

    { Типы функций для тестирования }
    Tmatrix4d_identity = function: TMat; cdecl;
    Tmatrix4d_get_determinant = function(matrix: TMat): Double; cdecl;
    Tmatrix4d_multiply = function(a, b: TMat): TMat; cdecl;
    Txyz_create = function(x, y, z: Double): TVec; cdecl;

  private
    class var Fmatrix4d_identity: Tmatrix4d_identity;
    class var Fmatrix4d_get_determinant: Tmatrix4d_get_determinant;
    class var Fmatrix4d_multiply: Tmatrix4d_multiply;
    class var Fxyz_create: Txyz_create;

    { Доступ к элементам матрицы }
    class function GetElement(const m: TMat; index: Integer): Double; static;

  public
    {**
      Установка указателей на функции для тестирования.
    }
    class procedure SetFunctions(
      IdentityFunc: Tmatrix4d_identity;
      DeterminantFunc: Tmatrix4d_get_determinant;
      MultiplyFunc: Tmatrix4d_multiply;
      VecCreateFunc: Txyz_create); static;

    {**
      Выполнение всех тестов.

      @return Массив результатов тестов
    }
    class function RunAllTests: TTestResults; static;

    {**
      Проверка, прошли ли все тесты.
    }
    class function AllTestsPassed(const Results: TTestResults): Boolean; static;

    { Отдельные тесты }
    class function TestIdentity: TTestResult; static;
    class function TestIdentityDeterminant: TTestResult; static;
    class function TestIdentityMultiply: TTestResult; static;
  end;

{**
  Создание успешного результата теста.
}
function TestOK(const Name: string): TTestResult;

{**
  Создание неуспешного результата теста.
}
function TestFail(const Name, Msg: string; Expected, Actual: Double): TTestResult;

{**
  Формирование текстового отчёта о тестах.
}
function FormatTestReport(const Results: TTestResults): string;

implementation

function TestOK(const Name: string): TTestResult;
begin
  Result.TestName := Name;
  Result.Passed := True;
  Result.Message := 'OK';
  Result.Expected := 0;
  Result.Actual := 0;
end;

function TestFail(const Name, Msg: string; Expected, Actual: Double): TTestResult;
begin
  Result.TestName := Name;
  Result.Passed := False;
  Result.Message := Msg;
  Result.Expected := Expected;
  Result.Actual := Actual;
end;

function FormatTestReport(const Results: TTestResults): string;
var
  i, passed, failed: Integer;
  sb: string;
begin
  passed := 0;
  failed := 0;
  sb := 'ABI Tests Report' + LineEnding;
  sb := sb + StringOfChar('=', 50) + LineEnding;

  for i := 0 to High(Results) do
  begin
    if Results[i].Passed then
    begin
      sb := sb + Format('[PASS] %s', [Results[i].TestName]) + LineEnding;
      Inc(passed);
    end
    else
    begin
      sb := sb + Format('[FAIL] %s: %s (expected=%g, actual=%g)',
        [Results[i].TestName, Results[i].Message,
         Results[i].Expected, Results[i].Actual]) + LineEnding;
      Inc(failed);
    end;
  end;

  sb := sb + StringOfChar('=', 50) + LineEnding;
  sb := sb + Format('Total: %d tests, %d passed, %d failed',
    [passed + failed, passed, failed]) + LineEnding;

  Result := sb;
end;

{ TLNXYZTests }

class function TLNXYZTests.GetX(const v: TVec): Double;
begin
  { Предполагаем, что x находится по смещению 0 }
  Result := PDouble(@v)^;
end;

class function TLNXYZTests.GetY(const v: TVec): Double;
begin
  { Предполагаем, что y находится по смещению 8 (sizeof(Double)) }
  Result := PDouble(PByte(@v) + 8)^;
end;

class function TLNXYZTests.GetZ(const v: TVec): Double;
begin
  { Предполагаем, что z находится по смещению 16 }
  Result := PDouble(PByte(@v) + 16)^;
end;

class procedure TLNXYZTests.SetFunctions(
  CreateFunc: Txyz_create;
  LengthFunc: Txyz_length;
  SqrLengthFunc: Txyz_sqr_length;
  NormalizeFunc: Txyz_normalize;
  DotFunc: Txyz_dot;
  CrossFunc: Txyz_cross;
  DistanceFunc: Txyz_distance);
begin
  Fxyz_create := CreateFunc;
  Fxyz_length := LengthFunc;
  Fxyz_sqr_length := SqrLengthFunc;
  Fxyz_normalize := NormalizeFunc;
  Fxyz_dot := DotFunc;
  Fxyz_cross := CrossFunc;
  Fxyz_distance := DistanceFunc;
end;

class function TLNXYZTests.RunAllTests: TTestResults;
begin
  Result := nil;
  SetLength(Result, 7);
  Result[0] := TestVectorCreation;
  Result[1] := TestLength;
  Result[2] := TestSqrLength;
  Result[3] := TestNormalize;
  Result[4] := TestCross;
  Result[5] := TestDot;
  Result[6] := TestDistance;
end;

class function TLNXYZTests.AllTestsPassed(const Results: TTestResults): Boolean;
var
  i: Integer;
begin
  Result := True;
  for i := 0 to High(Results) do
    if not Results[i].Passed then
    begin
      Result := False;
      Exit;
    end;
end;

class function TLNXYZTests.TestVectorCreation: TTestResult;
var
  v: TVec;
begin
  if not Assigned(Fxyz_create) then
    Exit(TestFail('VectorCreation', 'xyz_create not assigned', 0, 0));

  v := Fxyz_create(1, 2, 3);

  if not DoubleEquals(GetX(v), 1) then
    Exit(TestFail('VectorCreation', 'x component mismatch', 1, GetX(v)));
  if not DoubleEquals(GetY(v), 2) then
    Exit(TestFail('VectorCreation', 'y component mismatch', 2, GetY(v)));
  if not DoubleEquals(GetZ(v), 3) then
    Exit(TestFail('VectorCreation', 'z component mismatch', 3, GetZ(v)));

  Result := TestOK('VectorCreation');
end;

class function TLNXYZTests.TestLength: TTestResult;
var
  v: TVec;
  expected, actual: Double;
begin
  if not Assigned(Fxyz_create) or not Assigned(Fxyz_length) then
    Exit(TestFail('Length', 'Functions not assigned', 0, 0));

  v := Fxyz_create(1, 2, 3);
  expected := Sqrt(14);  { sqrt(1^2 + 2^2 + 3^2) = sqrt(14) }
  actual := Fxyz_length(v);

  if not DoubleEquals(expected, actual) then
    Exit(TestFail('Length', 'length(1,2,3) != sqrt(14)', expected, actual));

  Result := TestOK('Length');
end;

class function TLNXYZTests.TestSqrLength: TTestResult;
var
  v: TVec;
  expected, actual: Double;
begin
  if not Assigned(Fxyz_create) or not Assigned(Fxyz_sqr_length) then
    Exit(TestFail('SqrLength', 'Functions not assigned', 0, 0));

  v := Fxyz_create(1, 2, 3);
  expected := 14;  { 1^2 + 2^2 + 3^2 = 14 }
  actual := Fxyz_sqr_length(v);

  if not DoubleEquals(expected, actual) then
    Exit(TestFail('SqrLength', 'sqr_length(1,2,3) != 14', expected, actual));

  Result := TestOK('SqrLength');
end;

class function TLNXYZTests.TestNormalize: TTestResult;
var
  v, n: TVec;
  len: Double;
begin
  if not Assigned(Fxyz_create) or not Assigned(Fxyz_normalize) or
     not Assigned(Fxyz_length) then
    Exit(TestFail('Normalize', 'Functions not assigned', 0, 0));

  v := Fxyz_create(1, 2, 3);
  n := Fxyz_normalize(v);
  len := Fxyz_length(n);

  if not DoubleEquals(len, 1.0) then
    Exit(TestFail('Normalize', 'length of normalized vector != 1', 1.0, len));

  Result := TestOK('Normalize');
end;

class function TLNXYZTests.TestCross: TTestResult;
var
  vx, vy, result_vec: TVec;
begin
  if not Assigned(Fxyz_create) or not Assigned(Fxyz_cross) then
    Exit(TestFail('Cross', 'Functions not assigned', 0, 0));

  { cross((1,0,0), (0,1,0)) = (0,0,1) }
  vx := Fxyz_create(1, 0, 0);
  vy := Fxyz_create(0, 1, 0);
  result_vec := Fxyz_cross(vx, vy);

  if not DoubleEquals(GetX(result_vec), 0) then
    Exit(TestFail('Cross', 'result.x != 0', 0, GetX(result_vec)));
  if not DoubleEquals(GetY(result_vec), 0) then
    Exit(TestFail('Cross', 'result.y != 0', 0, GetY(result_vec)));
  if not DoubleEquals(GetZ(result_vec), 1) then
    Exit(TestFail('Cross', 'result.z != 1', 1, GetZ(result_vec)));

  Result := TestOK('Cross');
end;

class function TLNXYZTests.TestDot: TTestResult;
var
  v1, v2: TVec;
  expected, actual: Double;
begin
  if not Assigned(Fxyz_create) or not Assigned(Fxyz_dot) then
    Exit(TestFail('Dot', 'Functions not assigned', 0, 0));

  { dot((1,2,3), (4,5,6)) = 1*4 + 2*5 + 3*6 = 4 + 10 + 18 = 32 }
  v1 := Fxyz_create(1, 2, 3);
  v2 := Fxyz_create(4, 5, 6);
  expected := 32;
  actual := Fxyz_dot(v1, v2);

  if not DoubleEquals(expected, actual) then
    Exit(TestFail('Dot', 'dot((1,2,3),(4,5,6)) != 32', expected, actual));

  Result := TestOK('Dot');
end;

class function TLNXYZTests.TestDistance: TTestResult;
var
  v1, v2: TVec;
  expected, actual: Double;
begin
  if not Assigned(Fxyz_create) or not Assigned(Fxyz_distance) then
    Exit(TestFail('Distance', 'Functions not assigned', 0, 0));

  { distance((0,0,0), (1,2,3)) = sqrt(1^2 + 2^2 + 3^2) = sqrt(14) }
  v1 := Fxyz_create(0, 0, 0);
  v2 := Fxyz_create(1, 2, 3);
  expected := Sqrt(14);
  actual := Fxyz_distance(v1, v2);

  if not DoubleEquals(expected, actual) then
    Exit(TestFail('Distance', 'distance((0,0,0),(1,2,3)) != sqrt(14)',
      expected, actual));

  Result := TestOK('Distance');
end;

{ TLNMatrixTests }

class function TLNMatrixTests.GetElement(const m: TMat; index: Integer): Double;
begin
  { Предполагаем, что матрица хранится как array[0..15] of Double }
  Result := PDouble(PByte(@m) + index * SizeOf(Double))^;
end;

class procedure TLNMatrixTests.SetFunctions(
  IdentityFunc: Tmatrix4d_identity;
  DeterminantFunc: Tmatrix4d_get_determinant;
  MultiplyFunc: Tmatrix4d_multiply;
  VecCreateFunc: Txyz_create);
begin
  Fmatrix4d_identity := IdentityFunc;
  Fmatrix4d_get_determinant := DeterminantFunc;
  Fmatrix4d_multiply := MultiplyFunc;
  Fxyz_create := VecCreateFunc;
end;

class function TLNMatrixTests.RunAllTests: TTestResults;
begin
  Result := nil;
  SetLength(Result, 3);
  Result[0] := TestIdentity;
  Result[1] := TestIdentityDeterminant;
  Result[2] := TestIdentityMultiply;
end;

class function TLNMatrixTests.AllTestsPassed(const Results: TTestResults): Boolean;
var
  i: Integer;
begin
  Result := True;
  for i := 0 to High(Results) do
    if not Results[i].Passed then
    begin
      Result := False;
      Exit;
    end;
end;

class function TLNMatrixTests.TestIdentity: TTestResult;
var
  m: TMat;
  i: Integer;
  expected: Double;
begin
  if not Assigned(Fmatrix4d_identity) then
    Exit(TestFail('Identity', 'matrix4d_identity not assigned', 0, 0));

  m := Fmatrix4d_identity();

  { Проверяем диагональные элементы (должны быть 1) }
  for i := 0 to 3 do
  begin
    expected := 1.0;
    if not DoubleEquals(GetElement(m, i * 4 + i), expected) then
      Exit(TestFail('Identity',
        Format('Diagonal element [%d,%d] != 1', [i, i]),
        expected, GetElement(m, i * 4 + i)));
  end;

  { Проверяем несколько недиагональных элементов (должны быть 0) }
  if not DoubleEquals(GetElement(m, 1), 0) then
    Exit(TestFail('Identity', 'Element [0,1] != 0', 0, GetElement(m, 1)));
  if not DoubleEquals(GetElement(m, 4), 0) then
    Exit(TestFail('Identity', 'Element [1,0] != 0', 0, GetElement(m, 4)));

  Result := TestOK('Identity');
end;

class function TLNMatrixTests.TestIdentityDeterminant: TTestResult;
var
  m: TMat;
  det: Double;
begin
  if not Assigned(Fmatrix4d_identity) or not Assigned(Fmatrix4d_get_determinant) then
    Exit(TestFail('IdentityDeterminant', 'Functions not assigned', 0, 0));

  m := Fmatrix4d_identity();
  det := Fmatrix4d_get_determinant(m);

  { Определитель единичной матрицы = 1 }
  if not DoubleEquals(det, 1.0) then
    Exit(TestFail('IdentityDeterminant', 'det(I) != 1', 1.0, det));

  Result := TestOK('IdentityDeterminant');
end;

class function TLNMatrixTests.TestIdentityMultiply: TTestResult;
var
  m, result_mat: TMat;
  i: Integer;
begin
  if not Assigned(Fmatrix4d_identity) or not Assigned(Fmatrix4d_multiply) then
    Exit(TestFail('IdentityMultiply', 'Functions not assigned', 0, 0));

  m := Fmatrix4d_identity();
  result_mat := Fmatrix4d_multiply(m, m);

  { I * I = I }
  for i := 0 to 3 do
    if not DoubleEquals(GetElement(result_mat, i * 4 + i), 1.0) then
      Exit(TestFail('IdentityMultiply',
        Format('I*I diagonal [%d,%d] != 1', [i, i]),
        1.0, GetElement(result_mat, i * 4 + i)));

  Result := TestOK('IdentityMultiply');
end;

end.
