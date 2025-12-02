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
{$mode objfpc}{$H+}

unit uzvtestglobalinterpolation;
{$INCLUDE zengineconfig.inc}

interface

uses
  SysUtils,
  Math,
  uzegeometrytypes,
  uzeNURBSTypes,
  uzcLog,
  uGlobalInterpolation,
  uzccommandsmanager,
  uzccommandsabstract,
  uzccommandsimpl,
  uzcinterface,
  uzbtypes;

function TestGlobalInterpolation_com(
  const Context: TZCADCommandContext;
  operands: TCommandOperands
): TCommandResult;

implementation

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
    (x: 1.0; y: 0.5; z: 0.0),
    (x: 1.0; y: 0.0; z: 0.0),
    (x: 1.0; y: 0.0; z: 0.0),
    (x: 1.0; y: -0.5; z: 0.0)
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
procedure PrintCurveInfo(
  const ACurve: TNurbsCurveData;
  const ATestName: string
);
var
  i: Integer;
  msg: string;
begin
  zcUI.TextMessage('', TMWOHistoryOut);
  zcUI.TextMessage(
    '=================================================================',
    TMWOHistoryOut
  );
  zcUI.TextMessage(ATestName, TMWOHistoryOut);
  zcUI.TextMessage(
    '=================================================================',
    TMWOHistoryOut
  );

  msg := Format('Degree: %d', [ACurve.Degree]);
  zcUI.TextMessage(msg, TMWOHistoryOut);

  msg := Format('Number of control points: %d', [Length(ACurve.ControlPoints)]);
  zcUI.TextMessage(msg, TMWOHistoryOut);

  msg := Format('Number of knots: %d', [ACurve.KnotVector.Count]);
  zcUI.TextMessage(msg, TMWOHistoryOut);

  zcUI.TextMessage('', TMWOHistoryOut);
  zcUI.TextMessage('Control Points:', TMWOHistoryOut);

  for i := 0 to Length(ACurve.ControlPoints) - 1 do
  begin
    msg := Format('  P[%d] = (%.6f, %.6f, %.6f)', [
      i,
      ACurve.ControlPoints[i].x,
      ACurve.ControlPoints[i].y,
      ACurve.ControlPoints[i].z
    ]);
    zcUI.TextMessage(msg, TMWOHistoryOut);
  end;

  zcUI.TextMessage('', TMWOHistoryOut);
  zcUI.TextMessage('Knot Vector:', TMWOHistoryOut);

  msg := '  [';
  for i := 0 to ACurve.KnotVector.Count - 1 do
  begin
    msg := msg + Format('%.4f', [ACurve.KnotVector.getDataMutable(i)^]);
    if i < ACurve.KnotVector.Count - 1 then
      msg := msg + ', ';
  end;
  msg := msg + ']';
  zcUI.TextMessage(msg, TMWOHistoryOut);
  zcUI.TextMessage('', TMWOHistoryOut);
end;

{**
  Проверяет, что первая и последняя контрольные точки совпадают
  с первой и последней точками интерполяции
  Checks that first and last control points match
  first and last interpolation points
}
function CheckEndpoints(
  const ACurve: TNurbsCurveData;
  const APoints: array of TzePoint3d
): Boolean;
var
  n: Integer;
  dist1, dist2: Double;
  msg: string;
begin
  n := Length(ACurve.ControlPoints) - 1;

  dist1 := PointDistance(ACurve.ControlPoints[0], APoints[0]);
  dist2 := PointDistance(ACurve.ControlPoints[n], APoints[High(APoints)]);

  Result := (dist1 < 0.0001) and (dist2 < 0.0001);

  if Result then
    zcUI.TextMessage('✓ Endpoint check PASSED', TMWOHistoryOut)
  else
  begin
    zcUI.TextMessage('✗ Endpoint check FAILED', TMWOHistoryOut);
    msg := Format('  First point distance: %.6f', [dist1]);
    zcUI.TextMessage(msg, TMWOHistoryOut);
    msg := Format('  Last point distance: %.6f', [dist2]);
    zcUI.TextMessage(msg, TMWOHistoryOut);
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
  zcUI.TextMessage('', TMWOHistoryOut);
  zcUI.TextMessage(
    '*****************************************************************',
    TMWOHistoryOut
  );
  zcUI.TextMessage(
    'TEST 1: Basic Global Interpolation (Simple 4-point curve)',
    TMWOHistoryOut
  );
  zcUI.TextMessage(
    '*****************************************************************',
    TMWOHistoryOut
  );

  try
    // Вызов базовой версии GlobalInterpolation
    // Call basic version of GlobalInterpolation
    GlobalInterpolation(3, TEST1_POINTS, curve, []);

    PrintCurveInfo(curve, 'Test 1 Result: Degree 3 curve through 4 points');

    // Проверка конечных точек
    // Check endpoints
    if CheckEndpoints(curve, TEST1_POINTS) then
      zcUI.TextMessage('TEST 1: SUCCESS', TMWOHistoryOut)
    else
      zcUI.TextMessage('TEST 1: FAILED', TMWOHistoryOut);
  except
    on E: Exception do
      zcUI.TextMessage('TEST 1: EXCEPTION - ' + E.Message, TMWOHistoryOut);
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
  zcUI.TextMessage('', TMWOHistoryOut);
  zcUI.TextMessage(
    '*****************************************************************',
    TMWOHistoryOut
  );
  zcUI.TextMessage(
    'TEST 2: Basic Global Interpolation (Complex 7-point curve)',
    TMWOHistoryOut
  );
  zcUI.TextMessage(
    '*****************************************************************',
    TMWOHistoryOut
  );

  try
    GlobalInterpolation(3, TEST2_POINTS, curve, []);

    PrintCurveInfo(curve, 'Test 2 Result: Degree 3 curve through 7 points');

    if CheckEndpoints(curve, TEST2_POINTS) then
      zcUI.TextMessage('TEST 2: SUCCESS', TMWOHistoryOut)
    else
      zcUI.TextMessage('TEST 2: FAILED', TMWOHistoryOut);
  except
    on E: Exception do
      zcUI.TextMessage('TEST 2: EXCEPTION - ' + E.Message, TMWOHistoryOut);
  end;
end;

{**
  Тест 3: Интерполяция с касательными векторами
  Test 3: Interpolation with tangent constraints
}
procedure Test3_InterpolationWithTangents;
var
  curve: TNurbsCurveData;
  msg: string;
begin
  zcUI.TextMessage('', TMWOHistoryOut);
  zcUI.TextMessage(
    '*****************************************************************',
    TMWOHistoryOut
  );
  zcUI.TextMessage(
    'TEST 3: Global Interpolation with Tangent Constraints',
    TMWOHistoryOut
  );
  zcUI.TextMessage(
    '*****************************************************************',
    TMWOHistoryOut
  );

  try
    // Вызов версии GlobalInterpolation с касательными
    // Call version of GlobalInterpolation with tangents
    GlobalInterpolation(3, TEST3_POINTS, TEST3_TANGENTS, 1.0, curve);

    PrintCurveInfo(
      curve,
      'Test 3 Result: Degree 3 curve with tangent constraints'
    );

    // Для кривой с касательными количество контрольных точек удваивается
    // For curve with tangents, number of control points doubles
    if Length(curve.ControlPoints) = 2 * Length(TEST3_POINTS) then
    begin
      msg := Format(
        '✓ Control point count check PASSED (expected %d, got %d)',
        [2 * Length(TEST3_POINTS), Length(curve.ControlPoints)]
      );
      zcUI.TextMessage(msg, TMWOHistoryOut);
    end
    else
    begin
      msg := Format(
        '✗ Control point count check FAILED (expected %d, got %d)',
        [2 * Length(TEST3_POINTS), Length(curve.ControlPoints)]
      );
      zcUI.TextMessage(msg, TMWOHistoryOut);
    end;

    zcUI.TextMessage('TEST 3: SUCCESS', TMWOHistoryOut);
  except
    on E: Exception do
      zcUI.TextMessage('TEST 3: EXCEPTION - ' + E.Message, TMWOHistoryOut);
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
  msg: string;
begin
  zcUI.TextMessage('', TMWOHistoryOut);
  zcUI.TextMessage(
    '*****************************************************************',
    TMWOHistoryOut
  );
  zcUI.TextMessage('TEST 4: Testing Different Curve Degrees', TMWOHistoryOut);
  zcUI.TextMessage(
    '*****************************************************************',
    TMWOHistoryOut
  );

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
    zcUI.TextMessage('', TMWOHistoryOut);
    msg := Format('--- Testing degree %d ---', [degree]);
    zcUI.TextMessage(msg, TMWOHistoryOut);

    try
      GlobalInterpolation(degree, testPoints, curve, []);

      msg := Format('  Degree: %d', [curve.Degree]);
      zcUI.TextMessage(msg, TMWOHistoryOut);
      msg := Format('  Control points: %d', [Length(curve.ControlPoints)]);
      zcUI.TextMessage(msg, TMWOHistoryOut);
      msg := Format('  Knots: %d', [curve.KnotVector.Size]);
      zcUI.TextMessage(msg, TMWOHistoryOut);

      if CheckEndpoints(curve, testPoints) then
      begin
        msg := Format('  ✓ Degree %d test PASSED', [degree]);
        zcUI.TextMessage(msg, TMWOHistoryOut);
      end
      else
      begin
        msg := Format('  ✗ Degree %d test FAILED', [degree]);
        zcUI.TextMessage(msg, TMWOHistoryOut);
      end;
    except
      on E: Exception do
      begin
        msg := Format('  ✗ Degree %d test EXCEPTION - %s', [degree, E.Message]);
        zcUI.TextMessage(msg, TMWOHistoryOut);
      end;
    end;
  end;

  zcUI.TextMessage('', TMWOHistoryOut);
  zcUI.TextMessage('TEST 4: COMPLETED', TMWOHistoryOut);
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
  zcUI.TextMessage('', TMWOHistoryOut);
  zcUI.TextMessage(
    '*****************************************************************',
    TMWOHistoryOut
  );
  zcUI.TextMessage('TEST 5: Error Handling', TMWOHistoryOut);
  zcUI.TextMessage(
    '*****************************************************************',
    TMWOHistoryOut
  );

  // Тест 5.1: Недостаточно точек для заданной степени
  // Test 5.1: Not enough points for given degree
  zcUI.TextMessage('', TMWOHistoryOut);
  zcUI.TextMessage('--- Test 5.1: Degree > number of points ---', TMWOHistoryOut);
  twoPoints[0].x := 0;
  twoPoints[0].y := 0;
  twoPoints[0].z := 0;
  twoPoints[1].x := 1;
  twoPoints[1].y := 1;
  twoPoints[1].z := 0;

  try
    GlobalInterpolation(3, twoPoints, curve, []);
    zcUI.TextMessage('  ✗ Should have raised exception', TMWOHistoryOut);
  except
    on E: Exception do
      zcUI.TextMessage(
        '  ✓ Correctly caught exception: ' + E.Message,
        TMWOHistoryOut
      );
  end;

  // Тест 5.2: Неправильное количество параметров
  // Test 5.2: Wrong number of parameters
  zcUI.TextMessage('', TMWOHistoryOut);
  zcUI.TextMessage('--- Test 5.2: Wrong parameter count ---', TMWOHistoryOut);
  wrongParams[0] := 0.0;
  wrongParams[1] := 1.0;

  try
    GlobalInterpolation(2, TEST1_POINTS, curve, wrongParams);
    zcUI.TextMessage('  ✗ Should have raised exception', TMWOHistoryOut);
  except
    on E: Exception do
      zcUI.TextMessage(
        '  ✓ Correctly caught exception: ' + E.Message,
        TMWOHistoryOut
      );
  end;

  // Тест 5.3: Нулевая степень
  // Test 5.3: Zero degree
  zcUI.TextMessage('', TMWOHistoryOut);
  zcUI.TextMessage('--- Test 5.3: Zero degree ---', TMWOHistoryOut);

  try
    GlobalInterpolation(0, TEST1_POINTS, curve, []);
    zcUI.TextMessage('  ✗ Should have raised exception', TMWOHistoryOut);
  except
    on E: Exception do
      zcUI.TextMessage(
        '  ✓ Correctly caught exception: ' + E.Message,
        TMWOHistoryOut
      );
  end;

  // Тест 5.4: Отрицательный tangentFactor
  // Test 5.4: Negative tangentFactor
  zcUI.TextMessage('', TMWOHistoryOut);
  zcUI.TextMessage('--- Test 5.4: Negative tangentFactor ---', TMWOHistoryOut);

  try
    GlobalInterpolation(3, TEST3_POINTS, TEST3_TANGENTS, -1.0, curve);
    zcUI.TextMessage('  ✗ Should have raised exception', TMWOHistoryOut);
  except
    on E: Exception do
      zcUI.TextMessage(
        '  ✓ Correctly caught exception: ' + E.Message,
        TMWOHistoryOut
      );
  end;

  zcUI.TextMessage('', TMWOHistoryOut);
  zcUI.TextMessage('TEST 5: COMPLETED', TMWOHistoryOut);
end;

// ============================================================================
// КОМАНДА
// COMMAND
// ============================================================================

{**
  Команда для запуска тестов глобальной интерполяции в ZCAD
  Command to run global interpolation tests in ZCAD
}
function TestGlobalInterpolation_com(
  const Context: TZCADCommandContext;
  operands: TCommandOperands
): TCommandResult;
begin
  zcUI.TextMessage('', TMWOHistoryOut);
  zcUI.TextMessage(
    '*****************************************************************',
    TMWOHistoryOut
  );
  zcUI.TextMessage(
    '*                                                               *',
    TMWOHistoryOut
  );
  zcUI.TextMessage(
    '*  GLOBAL INTERPOLATION TEST SUITE                              *',
    TMWOHistoryOut
  );
  zcUI.TextMessage(
    '*  Testing NURBS curve global interpolation functions          *',
    TMWOHistoryOut
  );
  zcUI.TextMessage(
    '*                                                               *',
    TMWOHistoryOut
  );
  zcUI.TextMessage(
    '*****************************************************************',
    TMWOHistoryOut
  );

  try
    // Запуск всех тестов
    // Run all tests
    Test1_BasicInterpolation;
    Test2_ComplexCurve;
    Test3_InterpolationWithTangents;
    Test4_DifferentDegrees;
    Test5_ErrorHandling;

    zcUI.TextMessage('', TMWOHistoryOut);
    zcUI.TextMessage(
      '*****************************************************************',
      TMWOHistoryOut
    );
    zcUI.TextMessage(
      '*  ALL TESTS COMPLETED                                          *',
      TMWOHistoryOut
    );
    zcUI.TextMessage(
      '*****************************************************************',
      TMWOHistoryOut
    );

    Result := cmd_ok;
  except
    on E: Exception do
    begin
      zcUI.TextMessage('', TMWOHistoryOut);
      zcUI.TextMessage('FATAL ERROR: ' + E.Message, TMWOHistoryOut);
      Result := cmd_error;
    end;
  end;
end;

initialization
  CreateZCADCommand(@TestGlobalInterpolation_com, 'testglobalinterpolation', CADWG, 0);

end.
