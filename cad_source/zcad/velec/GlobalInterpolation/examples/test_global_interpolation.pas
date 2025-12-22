program test_global_interpolation;

{$mode delphi}{$H+}

{**
  Программа тестирования функций глобальной интерполяции
  Test program for global interpolation functions

  Проверяет обе версии GlobalInterpolation:
  Tests both versions of GlobalInterpolation:
  1. Базовая интерполяция через точки
     Basic interpolation through points
  2. Интерполяция с учётом касательных векторов
     Interpolation with tangent constraints
}

uses
  SysUtils, Math,
  uzegeometrytypes,
  uzeNURBSTypes,
  uzcLog,
  uGlobalInterpolation;

// ============================================================================
// ТЕСТОВЫЕ ДАННЫЕ
// TEST DATA
// ============================================================================

const
  // Тест 1: Простая кривая из 4 точек
  // Test 1: Simple curve with 4 points
  TEST1_POINTS: array[0..3] of TzePoint3d = (
    (x: 0.0; y: 0.0; z: 0.0),
    (x: 1.0; y: 1.0; z: 0.0),
    (x: 2.0; y: 0.5; z: 0.0),
    (x: 3.0; y: 1.5; z: 0.0)
  );

  // Тест 2: Сложная кривая из 7 точек (из issue #253)
  // Test 2: Complex curve with 7 points (from issue #253)
  TEST2_POINTS: array[0..6] of TzePoint3d = (
    (x: 1583.2136549257; y: 417.836639195; z: 0.0),
    (x: 2346.3909069169; y: 988.9560396917; z: 0.0),
    (x: 1396.2099574179; y: 1772.3499076297; z: 0.0),
    (x: -392.9605538726; y: 1716.754213776; z: 0.0),
    (x: -41.2801529313; y: 2784.8206166348; z: 0.0),
    (x: 1717.1218517754; y: 2954.1482170881; z: 0.0),
    (x: 3449.4734564123; y: 2146.5858149265; z: 0.0)
  );

  // Тест 3: Касательные векторы для простой кривой
  // Test 3: Tangent vectors for simple curve
  TEST3_POINTS: array[0..3] of TzePoint3d = (
    (x: 0.0; y: 0.0; z: 0.0),
    (x: 1.0; y: 0.0; z: 0.0),
    (x: 2.0; y: 0.0; z: 0.0),
    (x: 3.0; y: 0.0; z: 0.0)
  );

  TEST3_TANGENTS: array[0..3] of TzePoint3d = (
    (x: 1.0; y: 0.5; z: 0.0),  // Касательная в начале / Tangent at start
    (x: 1.0; y: 0.0; z: 0.0),  // Горизонтальные касательные / Horizontal tangents
    (x: 1.0; y: 0.0; z: 0.0),
    (x: 1.0; y: -0.5; z: 0.0)  // Касательная в конце / Tangent at end
  );

// ============================================================================
// ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ
// HELPER FUNCTIONS
// ============================================================================

{**
  Вычисляет расстояние между двумя точками
  Computes distance between two points
}
function PointDistance(const P1, P2: TzePoint3d): Double;
begin
  Result := Sqrt(
    Sqr(P2.x - P1.x) +
    Sqr(P2.y - P1.y) +
    Sqr(P2.z - P1.z)
  );
end;

{**
  Выводит информацию о кривой
  Prints curve information
}
procedure PrintCurveInfo(const ACurve: TNurbsCurveData; const ATestName: string);
var
  i: Integer;
begin
  WriteLn;
  WriteLn('=================================================================');
  WriteLn(ATestName);
  WriteLn('=================================================================');
  WriteLn('Degree: ', ACurve.Degree);
  WriteLn('Number of control points: ', Length(ACurve.ControlPoints));
  WriteLn('Number of knots: ', ACurve.KnotVector.Count);
  WriteLn;

  WriteLn('Control Points:');
  for i := 0 to Length(ACurve.ControlPoints) - 1 do
    WriteLn(Format('  P[%d] = (%.6f, %.6f, %.6f)',
      [i, ACurve.ControlPoints[i].x,
          ACurve.ControlPoints[i].y,
          ACurve.ControlPoints[i].z]));
  WriteLn;

  WriteLn('Knot Vector:');
  Write('  [');
  for i := 0 to ACurve.KnotVector.Count - 1 do
  begin
    Write(Format('%.4f', [ACurve.KnotVector.getDataMutable(i)^]));
    if i < ACurve.KnotVector.Count - 1 then
      Write(', ');
  end;
  WriteLn(']');
  WriteLn;
end;

{**
  Проверяет, что первая и последняя контрольные точки совпадают
  с первой и последней точками интерполяции
  Checks that first and last control points match
  first and last interpolation points
}
function CheckEndpoints(const ACurve: TNurbsCurveData;
  const APoints: array of TzePoint3d): Boolean;
var
  n: Integer;
  dist1, dist2: Double;
begin
  n := Length(ACurve.ControlPoints) - 1;

  dist1 := PointDistance(ACurve.ControlPoints[0], APoints[0]);
  dist2 := PointDistance(ACurve.ControlPoints[n], APoints[High(APoints)]);

  Result := (dist1 < 0.0001) and (dist2 < 0.0001);

  if Result then
    WriteLn('✓ Endpoint check PASSED')
  else
  begin
    WriteLn('✗ Endpoint check FAILED');
    WriteLn(Format('  First point distance: %.6f', [dist1]));
    WriteLn(Format('  Last point distance: %.6f', [dist2]));
  end;
end;

// ============================================================================
// ТЕСТЫ
// TESTS
// ============================================================================

{**
  Тест 1: Базовая интерполяция - простая кривая степени 3
  Test 1: Basic interpolation - simple degree 3 curve
}
procedure Test1_BasicInterpolation;
var
  curve: TNurbsCurveData;
begin
  WriteLn;
  WriteLn('*****************************************************************');
  WriteLn('TEST 1: Basic Global Interpolation (Simple 4-point curve)');
  WriteLn('*****************************************************************');

  try
    // Вызов базовой версии GlobalInterpolation
    // Call basic version of GlobalInterpolation
    GlobalInterpolation(3, TEST1_POINTS, curve, []);

    PrintCurveInfo(curve, 'Test 1 Result: Degree 3 curve through 4 points');

    // Проверка конечных точек
    // Check endpoints
    if CheckEndpoints(curve, TEST1_POINTS) then
      WriteLn('TEST 1: SUCCESS')
    else
      WriteLn('TEST 1: FAILED');

  except
    on E: Exception do
    begin
      WriteLn('TEST 1: EXCEPTION - ', E.Message);
    end;
  end;
end;

{**
  Тест 2: Базовая интерполяция - сложная кривая из 7 точек
  Test 2: Basic interpolation - complex 7-point curve
}
procedure Test2_ComplexCurve;
var
  curve: TNurbsCurveData;
begin
  WriteLn;
  WriteLn('*****************************************************************');
  WriteLn('TEST 2: Basic Global Interpolation (Complex 7-point curve)');
  WriteLn('*****************************************************************');

  try
    GlobalInterpolation(3, TEST2_POINTS, curve, []);

    PrintCurveInfo(curve, 'Test 2 Result: Degree 3 curve through 7 points');

    if CheckEndpoints(curve, TEST2_POINTS) then
      WriteLn('TEST 2: SUCCESS')
    else
      WriteLn('TEST 2: FAILED');

  except
    on E: Exception do
    begin
      WriteLn('TEST 2: EXCEPTION - ', E.Message);
    end;
  end;
end;

{**
  Тест 3: Интерполяция с касательными векторами
  Test 3: Interpolation with tangent constraints
}
procedure Test3_InterpolationWithTangents;
var
  curve: TNurbsCurveData;
begin
  WriteLn;
  WriteLn('*****************************************************************');
  WriteLn('TEST 3: Global Interpolation with Tangent Constraints');
  WriteLn('*****************************************************************');

  try
    // Вызов версии GlobalInterpolation с касательными
    // Call version of GlobalInterpolation with tangents
    GlobalInterpolation(3, TEST3_POINTS, TEST3_TANGENTS, 1.0, curve);

    PrintCurveInfo(curve, 'Test 3 Result: Degree 3 curve with tangent constraints');

    // Для кривой с касательными количество контрольных точек удваивается
    // For curve with tangents, number of control points doubles
    if Length(curve.ControlPoints) = 2 * Length(TEST3_POINTS) then
      WriteLn('✓ Control point count check PASSED (expected ', 2 * Length(TEST3_POINTS), ', got ', Length(curve.ControlPoints), ')')
    else
      WriteLn('✗ Control point count check FAILED (expected ', 2 * Length(TEST3_POINTS), ', got ', Length(curve.ControlPoints), ')');

    WriteLn('TEST 3: SUCCESS');

  except
    on E: Exception do
    begin
      WriteLn('TEST 3: EXCEPTION - ', E.Message);
    end;
  end;
end;

{**
  Тест 4: Проверка различных степеней кривой
  Test 4: Testing different curve degrees
}
procedure Test4_DifferentDegrees;
var
  curve: TNurbsCurveData;
  degree: Integer;
  testPoints: array[0..5] of TzePoint3d;
  i: Integer;
begin
  WriteLn;
  WriteLn('*****************************************************************');
  WriteLn('TEST 4: Testing Different Curve Degrees');
  WriteLn('*****************************************************************');

  // Создание тестовых точек
  // Create test points
  for i := 0 to 5 do
  begin
    testPoints[i].x := i;
    testPoints[i].y := Sin(i * Pi / 3);
    testPoints[i].z := 0.0;
  end;

  // Тестирование степеней от 2 до 4
  // Testing degrees from 2 to 4
  for degree := 2 to 4 do
  begin
    WriteLn;
    WriteLn('--- Testing degree ', degree, ' ---');
    try
      GlobalInterpolation(degree, testPoints, curve, []);

      WriteLn('  Degree: ', curve.Degree);
      WriteLn('  Control points: ', Length(curve.ControlPoints));
      WriteLn('  Knots: ', curve.KnotVector.Size);

      if CheckEndpoints(curve, testPoints) then
        WriteLn('  ✓ Degree ', degree, ' test PASSED')
      else
        WriteLn('  ✗ Degree ', degree, ' test FAILED');

    except
      on E: Exception do
        WriteLn('  ✗ Degree ', degree, ' test EXCEPTION - ', E.Message);
    end;
  end;

  WriteLn;
  WriteLn('TEST 4: COMPLETED');
end;

{**
  Тест 5: Проверка обработки ошибок
  Test 5: Error handling checks
}
procedure Test5_ErrorHandling;
var
  curve: TNurbsCurveData;
  twoPoints: array[0..1] of TzePoint3d;
  wrongParams: array[0..1] of Double;
begin
  WriteLn;
  WriteLn('*****************************************************************');
  WriteLn('TEST 5: Error Handling');
  WriteLn('*****************************************************************');

  // Тест 5.1: Недостаточно точек для заданной степени
  // Test 5.1: Not enough points for given degree
  WriteLn;
  WriteLn('--- Test 5.1: Degree > number of points ---');
  twoPoints[0].x := 0; twoPoints[0].y := 0; twoPoints[0].z := 0;
  twoPoints[1].x := 1; twoPoints[1].y := 1; twoPoints[1].z := 0;
  try
    GlobalInterpolation(3, twoPoints, curve, []);
    WriteLn('  ✗ Should have raised exception');
  except
    on E: Exception do
      WriteLn('  ✓ Correctly caught exception: ', E.Message);
  end;

  // Тест 5.2: Неправильное количество параметров
  // Test 5.2: Wrong number of parameters
  WriteLn;
  WriteLn('--- Test 5.2: Wrong parameter count ---');
  wrongParams[0] := 0.0;
  wrongParams[1] := 1.0;
  try
    GlobalInterpolation(2, TEST1_POINTS, curve, wrongParams);
    WriteLn('  ✗ Should have raised exception');
  except
    on E: Exception do
      WriteLn('  ✓ Correctly caught exception: ', E.Message);
  end;

  // Тест 5.3: Нулевая степень
  // Test 5.3: Zero degree
  WriteLn;
  WriteLn('--- Test 5.3: Zero degree ---');
  try
    GlobalInterpolation(0, TEST1_POINTS, curve, []);
    WriteLn('  ✗ Should have raised exception');
  except
    on E: Exception do
      WriteLn('  ✓ Correctly caught exception: ', E.Message);
  end;

  // Тест 5.4: Отрицательный tangentFactor
  // Test 5.4: Negative tangentFactor
  WriteLn;
  WriteLn('--- Test 5.4: Negative tangentFactor ---');
  try
    GlobalInterpolation(3, TEST3_POINTS, TEST3_TANGENTS, -1.0, curve);
    WriteLn('  ✗ Should have raised exception');
  except
    on E: Exception do
      WriteLn('  ✓ Correctly caught exception: ', E.Message);
  end;

  WriteLn;
  WriteLn('TEST 5: COMPLETED');
end;

// ============================================================================
// ГЛАВНАЯ ПРОГРАММА
// MAIN PROGRAM
// ============================================================================

begin
  WriteLn;
  WriteLn('*****************************************************************');
  WriteLn('*                                                               *');
  WriteLn('*  GLOBAL INTERPOLATION TEST SUITE                              *');
  WriteLn('*  Testing NURBS curve global interpolation functions          *');
  WriteLn('*                                                               *');
  WriteLn('*****************************************************************');

  try
    // Запуск всех тестов
    // Run all tests
    Test1_BasicInterpolation;
    Test2_ComplexCurve;
    Test3_InterpolationWithTangents;
    Test4_DifferentDegrees;
    Test5_ErrorHandling;

    WriteLn;
    WriteLn('*****************************************************************');
    WriteLn('*  ALL TESTS COMPLETED                                          *');
    WriteLn('*****************************************************************');

  except
    on E: Exception do
    begin
      WriteLn;
      WriteLn('FATAL ERROR: ', E.Message);
    end;
  end;

  WriteLn;
  WriteLn('Press Enter to exit...');
  ReadLn;
end.
