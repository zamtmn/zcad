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
  Модуль: uzvshxtopdfapprogeomtestarc
  Назначение: Unit-тест аппроксимации дуги окружности кубическими кривыми Безье

  Тест проверяет:
  - Совпадение начальной и конечной точки аппроксимации с исходной дугой
  - Максимальное отклонение аппроксимации не превышает заданный допуск
  - Корректную работу с различными углами дуг

  Module: uzvshxtopdfapprogeomtestarc
  Purpose: Unit test for circular arc approximation with cubic Bezier curves

  Test checks:
  - Start and end points match between approximation and original arc
  - Maximum approximation deviation doesn't exceed specified tolerance
  - Correct operation with various arc angles
}

unit uzvshxtopdfapprogeomtestarc;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Math,
  uzvshxtopdfapprogeomtypes,
  uzvshxtopdfapprogeomsettings,
  uzvshxtopdfapprogeomarc,
  uzclog;

type
  // Результат одного теста
  // Single test result
  TTestResult = record
    TestName: string;       // Имя теста / Test name
    Passed: Boolean;        // Пройден ли тест / Test passed
    Message: string;        // Сообщение / Message
    MaxDeviation: Double;   // Максимальное отклонение / Maximum deviation
  end;

  // Результаты всех тестов
  // All test results
  TTestResults = array of TTestResult;

// Запустить все тесты аппроксимации дуг
// Run all arc approximation tests
function RunAllArcTests: TTestResults;

// Тест четверти окружности (обязательный тест из ТЗ)
// Quarter circle test (mandatory test from specification)
//
// Параметры теста / Test parameters:
//   - Центр: (0, 0) / Center: (0, 0)
//   - Радиус: 100 / Radius: 100
//   - Угол: 0° → 90° / Angle: 0 -> 90 degrees
//   - Допуск: 0.01 / Tolerance: 0.01
function TestQuarterCircle: TTestResult;

// Тест полуокружности
// Semicircle test
function TestSemicircle: TTestResult;

// Тест полной окружности
// Full circle test
function TestFullCircle: TTestResult;

// Тест малой дуги (< 45°)
// Small arc test (< 45 degrees)
function TestSmallArc: TTestResult;

// Тест большой дуги (> 180°)
// Large arc test (> 180 degrees)
function TestLargeArc: TTestResult;

// Тест дуги против часовой стрелки
// Counter-clockwise arc test
function TestCounterClockwiseArc: TTestResult;

// Вычислить максимальное отклонение аппроксимации от дуги
// Calculate maximum deviation of approximation from arc
//
// Проверяет точки на кривых Безье и сравнивает с исходной дугой
// Checks points on Bezier curves and compares with original arc
function CalculateMaxDeviation(
  const Segments: TArray<TUzvBezierSegment>;
  CenterX, CenterY, Radius: Double;
  SamplesPerSegment: Integer
): Double;

// Вывести результаты тестов в лог
// Output test results to log
procedure LogTestResults(const Results: TTestResults);

implementation

const
  // Количество точек проверки на один сегмент Безье
  // Number of check points per Bezier segment
  SAMPLES_PER_SEGMENT = 20;

  // Допуск для сравнения координат (epsilon)
  // Tolerance for coordinate comparison (epsilon)
  COORDINATE_EPSILON = 0.0001;

// Вычислить расстояние от точки до окружности
// Calculate distance from point to circle
function DistanceToCircle(
  const P: TPointF;
  CenterX, CenterY, Radius: Double
): Double;
var
  DistFromCenter: Double;
begin
  DistFromCenter := Sqrt(Sqr(P.X - CenterX) + Sqr(P.Y - CenterY));
  Result := Abs(DistFromCenter - Abs(Radius));
end;

// Вычислить точку на кривой Безье по параметру t
// Calculate point on Bezier curve by parameter t
function EvaluateBezier(const Seg: TUzvBezierSegment; t: Double): TPointF;
var
  mt, mt2, mt3: Double;
  t2, t3: Double;
begin
  mt := 1.0 - t;
  mt2 := mt * mt;
  mt3 := mt2 * mt;
  t2 := t * t;
  t3 := t2 * t;

  Result.X := mt3 * Seg.P0.X +
              3.0 * mt2 * t * Seg.P1.X +
              3.0 * mt * t2 * Seg.P2.X +
              t3 * Seg.P3.X;

  Result.Y := mt3 * Seg.P0.Y +
              3.0 * mt2 * t * Seg.P1.Y +
              3.0 * mt * t2 * Seg.P2.Y +
              t3 * Seg.P3.Y;
end;

// Вычислить максимальное отклонение аппроксимации от дуги
function CalculateMaxDeviation(
  const Segments: TArray<TUzvBezierSegment>;
  CenterX, CenterY, Radius: Double;
  SamplesPerSegment: Integer
): Double;
var
  i, j: Integer;
  t: Double;
  P: TPointF;
  Dev: Double;
begin
  Result := 0.0;

  for i := 0 to High(Segments) do
  begin
    for j := 0 to SamplesPerSegment do
    begin
      t := j / SamplesPerSegment;
      P := EvaluateBezier(Segments[i], t);
      Dev := DistanceToCircle(P, CenterX, CenterY, Radius);

      if Dev > Result then
        Result := Dev;
    end;
  end;
end;

// Проверить совпадение начальной точки
// Check start point match
function CheckStartPointMatch(
  const Segments: TArray<TUzvBezierSegment>;
  ExpectedX, ExpectedY: Double
): Boolean;
begin
  if Length(Segments) = 0 then
  begin
    Result := False;
    Exit;
  end;

  Result := (Abs(Segments[0].P0.X - ExpectedX) < COORDINATE_EPSILON) and
            (Abs(Segments[0].P0.Y - ExpectedY) < COORDINATE_EPSILON);
end;

// Проверить совпадение конечной точки
// Check end point match
function CheckEndPointMatch(
  const Segments: TArray<TUzvBezierSegment>;
  ExpectedX, ExpectedY: Double
): Boolean;
var
  LastIdx: Integer;
begin
  if Length(Segments) = 0 then
  begin
    Result := False;
    Exit;
  end;

  LastIdx := High(Segments);
  Result := (Abs(Segments[LastIdx].P3.X - ExpectedX) < COORDINATE_EPSILON) and
            (Abs(Segments[LastIdx].P3.Y - ExpectedY) < COORDINATE_EPSILON);
end;

// Тест четверти окружности (обязательный тест из ТЗ)
function TestQuarterCircle: TTestResult;
const
  CENTER_X = 0.0;
  CENTER_Y = 0.0;
  RADIUS = 100.0;
  START_ANGLE = 0.0;        // 0 градусов
  END_ANGLE = Pi / 2;       // 90 градусов
  TOLERANCE = 0.01;
var
  Segments: TArray<TUzvBezierSegment>;
  MaxDev: Double;
  ExpectedStartX, ExpectedStartY: Double;
  ExpectedEndX, ExpectedEndY: Double;
begin
  Result.TestName := 'Quarter Circle (0 -> 90 degrees)';
  Result.Passed := False;
  Result.MaxDeviation := 0.0;

  programlog.LogOutFormatStr(
    'ApproGeom Test: Running %s',
    [Result.TestName],
    LM_Info
  );

  // Выполняем аппроксимацию
  // Perform approximation
  Segments := ApproximateArc(
    CENTER_X, CENTER_Y,
    RADIUS,
    START_ANGLE, END_ANGLE,
    TOLERANCE
  );

  // Проверяем, что получены сегменты
  // Check that segments were produced
  if Length(Segments) = 0 then
  begin
    Result.Message := 'No segments produced';
    programlog.LogOutFormatStr(
      'ApproGeom Test: FAILED - %s',
      [Result.Message],
      LM_Info
    );
    Exit;
  end;

  // Ожидаемые точки
  // Expected points
  ExpectedStartX := CENTER_X + RADIUS * Cos(START_ANGLE);  // 100
  ExpectedStartY := CENTER_Y + RADIUS * Sin(START_ANGLE);  // 0
  ExpectedEndX := CENTER_X + RADIUS * Cos(END_ANGLE);      // 0
  ExpectedEndY := CENTER_Y + RADIUS * Sin(END_ANGLE);      // 100

  // Проверяем начальную точку
  // Check start point
  if not CheckStartPointMatch(Segments, ExpectedStartX, ExpectedStartY) then
  begin
    Result.Message := Format(
      'Start point mismatch: expected (%.2f, %.2f), got (%.2f, %.2f)',
      [ExpectedStartX, ExpectedStartY, Segments[0].P0.X, Segments[0].P0.Y]
    );
    programlog.LogOutFormatStr(
      'ApproGeom Test: FAILED - %s',
      [Result.Message],
      LM_Info
    );
    Exit;
  end;

  // Проверяем конечную точку
  // Check end point
  if not CheckEndPointMatch(Segments, ExpectedEndX, ExpectedEndY) then
  begin
    Result.Message := Format(
      'End point mismatch: expected (%.2f, %.2f), got (%.2f, %.2f)',
      [ExpectedEndX, ExpectedEndY,
       Segments[High(Segments)].P3.X, Segments[High(Segments)].P3.Y]
    );
    programlog.LogOutFormatStr(
      'ApproGeom Test: FAILED - %s',
      [Result.Message],
      LM_Info
    );
    Exit;
  end;

  // Вычисляем максимальное отклонение
  // Calculate maximum deviation
  MaxDev := CalculateMaxDeviation(
    Segments,
    CENTER_X, CENTER_Y, RADIUS,
    SAMPLES_PER_SEGMENT
  );
  Result.MaxDeviation := MaxDev;

  // Проверяем, что отклонение в пределах допуска
  // Check that deviation is within tolerance
  if MaxDev > TOLERANCE then
  begin
    Result.Message := Format(
      'Deviation %.6f exceeds tolerance %.6f',
      [MaxDev, TOLERANCE]
    );
    programlog.LogOutFormatStr(
      'ApproGeom Test: FAILED - %s',
      [Result.Message],
      LM_Info
    );
    Exit;
  end;

  // Тест пройден
  // Test passed
  Result.Passed := True;
  Result.Message := Format(
    'OK - %d segments, max deviation %.6f',
    [Length(Segments), MaxDev]
  );

  programlog.LogOutFormatStr(
    'ApproGeom Test: PASSED - %s',
    [Result.Message],
    LM_Info
  );
end;

// Тест полуокружности
function TestSemicircle: TTestResult;
const
  RADIUS = 50.0;
  TOLERANCE = 0.01;
var
  Segments: TArray<TUzvBezierSegment>;
  MaxDev: Double;
begin
  Result.TestName := 'Semicircle (0 -> 180 degrees)';
  Result.Passed := False;

  Segments := ApproximateArc(0, 0, RADIUS, 0, Pi, TOLERANCE);

  if Length(Segments) = 0 then
  begin
    Result.Message := 'No segments produced';
    Exit;
  end;

  MaxDev := CalculateMaxDeviation(Segments, 0, 0, RADIUS, SAMPLES_PER_SEGMENT);
  Result.MaxDeviation := MaxDev;

  if MaxDev > TOLERANCE then
  begin
    Result.Message := Format('Deviation %.6f exceeds tolerance', [MaxDev]);
    Exit;
  end;

  Result.Passed := True;
  Result.Message := Format('OK - %d segments, max deviation %.6f',
    [Length(Segments), MaxDev]);
end;

// Тест полной окружности
function TestFullCircle: TTestResult;
const
  RADIUS = 75.0;
  TOLERANCE = 0.01;
var
  Segments: TArray<TUzvBezierSegment>;
  MaxDev: Double;
begin
  Result.TestName := 'Full Circle';
  Result.Passed := False;

  Segments := ApproximateCircle(0, 0, RADIUS, TOLERANCE);

  if Length(Segments) < 4 then
  begin
    Result.Message := Format('Too few segments: %d', [Length(Segments)]);
    Exit;
  end;

  MaxDev := CalculateMaxDeviation(Segments, 0, 0, RADIUS, SAMPLES_PER_SEGMENT);
  Result.MaxDeviation := MaxDev;

  if MaxDev > TOLERANCE then
  begin
    Result.Message := Format('Deviation %.6f exceeds tolerance', [MaxDev]);
    Exit;
  end;

  Result.Passed := True;
  Result.Message := Format('OK - %d segments, max deviation %.6f',
    [Length(Segments), MaxDev]);
end;

// Тест малой дуги
function TestSmallArc: TTestResult;
const
  RADIUS = 100.0;
  TOLERANCE = 0.01;
var
  Segments: TArray<TUzvBezierSegment>;
  MaxDev: Double;
  SmallAngle: Double;
begin
  Result.TestName := 'Small Arc (30 degrees)';
  Result.Passed := False;

  SmallAngle := Pi / 6;  // 30 градусов
  Segments := ApproximateArc(0, 0, RADIUS, 0, SmallAngle, TOLERANCE);

  if Length(Segments) = 0 then
  begin
    Result.Message := 'No segments produced';
    Exit;
  end;

  MaxDev := CalculateMaxDeviation(Segments, 0, 0, RADIUS, SAMPLES_PER_SEGMENT);
  Result.MaxDeviation := MaxDev;

  if MaxDev > TOLERANCE then
  begin
    Result.Message := Format('Deviation %.6f exceeds tolerance', [MaxDev]);
    Exit;
  end;

  Result.Passed := True;
  Result.Message := Format('OK - %d segments, max deviation %.6f',
    [Length(Segments), MaxDev]);
end;

// Тест большой дуги
function TestLargeArc: TTestResult;
const
  RADIUS = 100.0;
  TOLERANCE = 0.01;
var
  Segments: TArray<TUzvBezierSegment>;
  MaxDev: Double;
  LargeAngle: Double;
begin
  Result.TestName := 'Large Arc (270 degrees)';
  Result.Passed := False;

  LargeAngle := 3 * Pi / 2;  // 270 градусов
  Segments := ApproximateArc(0, 0, RADIUS, 0, LargeAngle, TOLERANCE);

  if Length(Segments) < 3 then
  begin
    Result.Message := Format('Too few segments for 270 deg: %d', [Length(Segments)]);
    Exit;
  end;

  MaxDev := CalculateMaxDeviation(Segments, 0, 0, RADIUS, SAMPLES_PER_SEGMENT);
  Result.MaxDeviation := MaxDev;

  if MaxDev > TOLERANCE then
  begin
    Result.Message := Format('Deviation %.6f exceeds tolerance', [MaxDev]);
    Exit;
  end;

  Result.Passed := True;
  Result.Message := Format('OK - %d segments, max deviation %.6f',
    [Length(Segments), MaxDev]);
end;

// Тест дуги против часовой стрелки
function TestCounterClockwiseArc: TTestResult;
const
  RADIUS = 100.0;
  TOLERANCE = 0.01;
var
  Segments: TArray<TUzvBezierSegment>;
  MaxDev: Double;
begin
  Result.TestName := 'Counter-clockwise Arc (90 -> 0 degrees)';
  Result.Passed := False;

  // Дуга от 90° к 0° (против часовой стрелки)
  Segments := ApproximateArc(0, 0, RADIUS, Pi / 2, 0, TOLERANCE);

  if Length(Segments) = 0 then
  begin
    Result.Message := 'No segments produced';
    Exit;
  end;

  MaxDev := CalculateMaxDeviation(Segments, 0, 0, RADIUS, SAMPLES_PER_SEGMENT);
  Result.MaxDeviation := MaxDev;

  if MaxDev > TOLERANCE then
  begin
    Result.Message := Format('Deviation %.6f exceeds tolerance', [MaxDev]);
    Exit;
  end;

  Result.Passed := True;
  Result.Message := Format('OK - %d segments, max deviation %.6f',
    [Length(Segments), MaxDev]);
end;

// Запустить все тесты
function RunAllArcTests: TTestResults;
begin
  programlog.LogOutFormatStr(
    'ApproGeom: Starting arc approximation tests',
    [],
    LM_Info
  );

  SetLength(Result, 6);

  Result[0] := TestQuarterCircle;
  Result[1] := TestSemicircle;
  Result[2] := TestFullCircle;
  Result[3] := TestSmallArc;
  Result[4] := TestLargeArc;
  Result[5] := TestCounterClockwiseArc;

  LogTestResults(Result);
end;

// Вывести результаты тестов в лог
procedure LogTestResults(const Results: TTestResults);
var
  i: Integer;
  PassedCount: Integer;
begin
  PassedCount := 0;

  programlog.LogOutFormatStr(
    'ApproGeom: ===== Arc Test Results =====',
    [],
    LM_Info
  );

  for i := 0 to High(Results) do
  begin
    if Results[i].Passed then
    begin
      Inc(PassedCount);
      programlog.LogOutFormatStr(
        'ApproGeom: [PASS] %s - %s',
        [Results[i].TestName, Results[i].Message],
        LM_Info
      );
    end
    else
    begin
      programlog.LogOutFormatStr(
        'ApproGeom: [FAIL] %s - %s',
        [Results[i].TestName, Results[i].Message],
        LM_Info
      );
    end;
  end;

  programlog.LogOutFormatStr(
    'ApproGeom: ===== Summary: %d/%d tests passed =====',
    [PassedCount, Length(Results)],
    LM_Info
  );
end;

end.
