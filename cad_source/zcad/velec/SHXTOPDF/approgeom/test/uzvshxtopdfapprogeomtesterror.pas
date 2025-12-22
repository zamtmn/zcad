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
  Модуль: uzvshxtopdfapprogeomtesterror
  Назначение: Тест численной устойчивости аппроксимации геометрии

  Проверяет корректную обработку граничных и вырожденных случаев:
  - Нулевой радиус
  - Дуга 360°
  - Дуга длиной меньше tolerance
  - Отрицательные координаты
  - NaN и Infinity значения

  Module: uzvshxtopdfapprogeomtesterror
  Purpose: Numerical stability test for geometry approximation

  Tests correct handling of edge and degenerate cases:
  - Zero radius
  - 360 degree arc
  - Arc shorter than tolerance
  - Negative coordinates
  - NaN and Infinity values
}

unit uzvshxtopdfapprogeomtesterror;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Math,
  uzvshxtopdfapprogeomtypes,
  uzvshxtopdfapprogeomsettings,
  uzvshxtopdfapprogeomarc,
  uzvshxtopdfapprogeom,
  uzvshxtopdf_shxglyph,
  uzclog;

type
  // Результат теста устойчивости
  // Stability test result
  TStabilityTestResult = record
    TestName: string;           // Имя теста / Test name
    Passed: Boolean;            // Пройден / Passed
    Message: string;            // Сообщение / Message
    HasNaN: Boolean;            // Содержит NaN / Contains NaN
    HasInfinity: Boolean;       // Содержит Infinity / Contains Infinity
    RaisedException: Boolean;   // Было исключение / Exception raised
    ExceptionMessage: string;   // Текст исключения / Exception message
  end;

  TStabilityTestResults = array of TStabilityTestResult;

// Запустить все тесты численной устойчивости
// Run all numerical stability tests
function RunAllStabilityTests: TStabilityTestResults;

// Тест нулевого радиуса
// Zero radius test
function TestZeroRadius: TStabilityTestResult;

// Тест дуги 360°
// 360 degree arc test
function TestFullCircleArc: TStabilityTestResult;

// Тест дуги меньше tolerance
// Arc smaller than tolerance test
function TestTinyArc: TStabilityTestResult;

// Тест отрицательных координат
// Negative coordinates test
function TestNegativeCoordinates: TStabilityTestResult;

// Тест отрицательного радиуса
// Negative radius test
function TestNegativeRadius: TStabilityTestResult;

// Тест NaN входных данных
// NaN input test
function TestNaNInput: TStabilityTestResult;

// Тест Infinity входных данных
// Infinity input test
function TestInfinityInput: TStabilityTestResult;

// Тест очень большого радиуса
// Very large radius test
function TestLargeRadius: TStabilityTestResult;

// Тест очень малого радиуса (> 0, но близко к нулю)
// Very small radius test (> 0 but close to zero)
function TestVerySmallRadius: TStabilityTestResult;

// Проверить массив сегментов на наличие NaN
// Check segment array for NaN values
function ContainsNaN(const Segments: TArray<TUzvBezierSegment>): Boolean;

// Проверить массив сегментов на наличие Infinity
// Check segment array for Infinity values
function ContainsInfinity(const Segments: TArray<TUzvBezierSegment>): Boolean;

// Вывести результаты тестов в лог
// Output test results to log
procedure LogStabilityTestResults(const Results: TStabilityTestResults);

implementation

// Проверить точку на NaN
// Check point for NaN
function PointHasNaN(const P: TPointF): Boolean;
begin
  Result := IsNaN(P.X) or IsNaN(P.Y);
end;

// Проверить точку на Infinity
// Check point for Infinity
function PointHasInfinity(const P: TPointF): Boolean;
begin
  Result := IsInfinite(P.X) or IsInfinite(P.Y);
end;

// Проверить сегмент на NaN
// Check segment for NaN
function SegmentHasNaN(const Seg: TUzvBezierSegment): Boolean;
begin
  Result := PointHasNaN(Seg.P0) or
            PointHasNaN(Seg.P1) or
            PointHasNaN(Seg.P2) or
            PointHasNaN(Seg.P3);
end;

// Проверить сегмент на Infinity
// Check segment for Infinity
function SegmentHasInfinity(const Seg: TUzvBezierSegment): Boolean;
begin
  Result := PointHasInfinity(Seg.P0) or
            PointHasInfinity(Seg.P1) or
            PointHasInfinity(Seg.P2) or
            PointHasInfinity(Seg.P3);
end;

// Проверить массив сегментов на наличие NaN
function ContainsNaN(const Segments: TArray<TUzvBezierSegment>): Boolean;
var
  i: Integer;
begin
  Result := False;
  for i := 0 to High(Segments) do
  begin
    if SegmentHasNaN(Segments[i]) then
    begin
      Result := True;
      Exit;
    end;
  end;
end;

// Проверить массив сегментов на наличие Infinity
function ContainsInfinity(const Segments: TArray<TUzvBezierSegment>): Boolean;
var
  i: Integer;
begin
  Result := False;
  for i := 0 to High(Segments) do
  begin
    if SegmentHasInfinity(Segments[i]) then
    begin
      Result := True;
      Exit;
    end;
  end;
end;

// Тест нулевого радиуса
function TestZeroRadius: TStabilityTestResult;
var
  Segments: TArray<TUzvBezierSegment>;
begin
  Result.TestName := 'Zero Radius';
  Result.Passed := False;
  Result.HasNaN := False;
  Result.HasInfinity := False;
  Result.RaisedException := False;

  programlog.LogOutFormatStr(
    'ApproGeom Stability Test: %s',
    [Result.TestName],
    LM_Info
  );

  try
    Segments := ApproximateArc(0, 0, 0, 0, Pi / 2, 0.01);

    Result.HasNaN := ContainsNaN(Segments);
    Result.HasInfinity := ContainsInfinity(Segments);

    // Для нулевого радиуса ожидаем пустой результат или точечный сегмент
    // For zero radius we expect empty result or point segment
    if Result.HasNaN or Result.HasInfinity then
    begin
      Result.Message := 'Output contains NaN or Infinity';
      Exit;
    end;

    Result.Passed := True;
    Result.Message := Format('OK - %d segments returned', [Length(Segments)]);

  except
    on E: Exception do
    begin
      Result.RaisedException := True;
      Result.ExceptionMessage := E.Message;
      Result.Message := 'Exception: ' + E.Message;
    end;
  end;
end;

// Тест дуги 360°
function TestFullCircleArc: TStabilityTestResult;
var
  Segments: TArray<TUzvBezierSegment>;
begin
  Result.TestName := 'Full Circle Arc (360 degrees)';
  Result.Passed := False;
  Result.HasNaN := False;
  Result.HasInfinity := False;
  Result.RaisedException := False;

  programlog.LogOutFormatStr(
    'ApproGeom Stability Test: %s',
    [Result.TestName],
    LM_Info
  );

  try
    // Дуга от 0 до 2*Pi (360°)
    // Arc from 0 to 2*Pi (360 degrees)
    Segments := ApproximateArc(0, 0, 100, 0, 2 * Pi, 0.01);

    Result.HasNaN := ContainsNaN(Segments);
    Result.HasInfinity := ContainsInfinity(Segments);

    if Result.HasNaN or Result.HasInfinity then
    begin
      Result.Message := 'Output contains NaN or Infinity';
      Exit;
    end;

    // Должны получить несколько сегментов для полной окружности
    // Should get multiple segments for full circle
    if Length(Segments) < 4 then
    begin
      Result.Message := Format('Too few segments: %d', [Length(Segments)]);
      Exit;
    end;

    Result.Passed := True;
    Result.Message := Format('OK - %d segments', [Length(Segments)]);

  except
    on E: Exception do
    begin
      Result.RaisedException := True;
      Result.ExceptionMessage := E.Message;
      Result.Message := 'Exception: ' + E.Message;
    end;
  end;
end;

// Тест дуги меньше tolerance
function TestTinyArc: TStabilityTestResult;
var
  Segments: TArray<TUzvBezierSegment>;
  TinyAngle: Double;
begin
  Result.TestName := 'Tiny Arc (< tolerance)';
  Result.Passed := False;
  Result.HasNaN := False;
  Result.HasInfinity := False;
  Result.RaisedException := False;

  programlog.LogOutFormatStr(
    'ApproGeom Stability Test: %s',
    [Result.TestName],
    LM_Info
  );

  try
    // Очень маленькая дуга (0.0001 радиан ≈ 0.006°)
    // Very small arc (0.0001 radians ≈ 0.006 degrees)
    TinyAngle := 0.0001;
    Segments := ApproximateArc(0, 0, 100, 0, TinyAngle, 0.01);

    Result.HasNaN := ContainsNaN(Segments);
    Result.HasInfinity := ContainsInfinity(Segments);

    if Result.HasNaN or Result.HasInfinity then
    begin
      Result.Message := 'Output contains NaN or Infinity';
      Exit;
    end;

    Result.Passed := True;
    Result.Message := Format('OK - %d segments', [Length(Segments)]);

  except
    on E: Exception do
    begin
      Result.RaisedException := True;
      Result.ExceptionMessage := E.Message;
      Result.Message := 'Exception: ' + E.Message;
    end;
  end;
end;

// Тест отрицательных координат
function TestNegativeCoordinates: TStabilityTestResult;
var
  Segments: TArray<TUzvBezierSegment>;
begin
  Result.TestName := 'Negative Coordinates';
  Result.Passed := False;
  Result.HasNaN := False;
  Result.HasInfinity := False;
  Result.RaisedException := False;

  programlog.LogOutFormatStr(
    'ApproGeom Stability Test: %s',
    [Result.TestName],
    LM_Info
  );

  try
    // Дуга с центром в отрицательных координатах
    // Arc with center at negative coordinates
    Segments := ApproximateArc(-100, -200, 50, 0, Pi / 2, 0.01);

    Result.HasNaN := ContainsNaN(Segments);
    Result.HasInfinity := ContainsInfinity(Segments);

    if Result.HasNaN or Result.HasInfinity then
    begin
      Result.Message := 'Output contains NaN or Infinity';
      Exit;
    end;

    if Length(Segments) = 0 then
    begin
      Result.Message := 'No segments produced';
      Exit;
    end;

    Result.Passed := True;
    Result.Message := Format('OK - %d segments', [Length(Segments)]);

  except
    on E: Exception do
    begin
      Result.RaisedException := True;
      Result.ExceptionMessage := E.Message;
      Result.Message := 'Exception: ' + E.Message;
    end;
  end;
end;

// Тест отрицательного радиуса
function TestNegativeRadius: TStabilityTestResult;
var
  Segments: TArray<TUzvBezierSegment>;
begin
  Result.TestName := 'Negative Radius';
  Result.Passed := False;
  Result.HasNaN := False;
  Result.HasInfinity := False;
  Result.RaisedException := False;

  programlog.LogOutFormatStr(
    'ApproGeom Stability Test: %s',
    [Result.TestName],
    LM_Info
  );

  try
    // Отрицательный радиус (меняет направление дуги)
    // Negative radius (changes arc direction)
    Segments := ApproximateArc(0, 0, -100, 0, Pi / 2, 0.01);

    Result.HasNaN := ContainsNaN(Segments);
    Result.HasInfinity := ContainsInfinity(Segments);

    if Result.HasNaN or Result.HasInfinity then
    begin
      Result.Message := 'Output contains NaN or Infinity';
      Exit;
    end;

    Result.Passed := True;
    Result.Message := Format('OK - %d segments', [Length(Segments)]);

  except
    on E: Exception do
    begin
      Result.RaisedException := True;
      Result.ExceptionMessage := E.Message;
      Result.Message := 'Exception: ' + E.Message;
    end;
  end;
end;

// Тест NaN входных данных
function TestNaNInput: TStabilityTestResult;
var
  Segments: TArray<TUzvBezierSegment>;
begin
  Result.TestName := 'NaN Input';
  Result.Passed := False;
  Result.HasNaN := False;
  Result.HasInfinity := False;
  Result.RaisedException := False;

  programlog.LogOutFormatStr(
    'ApproGeom Stability Test: %s',
    [Result.TestName],
    LM_Info
  );

  try
    // Передаём NaN в качестве радиуса
    // Pass NaN as radius
    Segments := ApproximateArc(0, 0, NaN, 0, Pi / 2, 0.01);

    // Ожидаем пустой результат без NaN
    // Expect empty result without NaN
    if Length(Segments) > 0 then
    begin
      Result.HasNaN := ContainsNaN(Segments);
      Result.HasInfinity := ContainsInfinity(Segments);

      if Result.HasNaN or Result.HasInfinity then
      begin
        Result.Message := 'NaN or Infinity propagated to output';
        Exit;
      end;
    end;

    Result.Passed := True;
    Result.Message := Format('OK - NaN handled gracefully, %d segments', [Length(Segments)]);

  except
    on E: Exception do
    begin
      Result.RaisedException := True;
      Result.ExceptionMessage := E.Message;
      Result.Message := 'Exception: ' + E.Message;
    end;
  end;
end;

// Тест Infinity входных данных
function TestInfinityInput: TStabilityTestResult;
var
  Segments: TArray<TUzvBezierSegment>;
begin
  Result.TestName := 'Infinity Input';
  Result.Passed := False;
  Result.HasNaN := False;
  Result.HasInfinity := False;
  Result.RaisedException := False;

  programlog.LogOutFormatStr(
    'ApproGeom Stability Test: %s',
    [Result.TestName],
    LM_Info
  );

  try
    // Передаём Infinity в качестве радиуса
    // Pass Infinity as radius
    Segments := ApproximateArc(0, 0, Infinity, 0, Pi / 2, 0.01);

    if Length(Segments) > 0 then
    begin
      Result.HasNaN := ContainsNaN(Segments);
      Result.HasInfinity := ContainsInfinity(Segments);

      if Result.HasNaN or Result.HasInfinity then
      begin
        Result.Message := 'NaN or Infinity propagated to output';
        Exit;
      end;
    end;

    Result.Passed := True;
    Result.Message := Format('OK - Infinity handled gracefully, %d segments',
      [Length(Segments)]);

  except
    on E: Exception do
    begin
      Result.RaisedException := True;
      Result.ExceptionMessage := E.Message;
      Result.Message := 'Exception: ' + E.Message;
    end;
  end;
end;

// Тест очень большого радиуса
function TestLargeRadius: TStabilityTestResult;
var
  Segments: TArray<TUzvBezierSegment>;
begin
  Result.TestName := 'Very Large Radius';
  Result.Passed := False;
  Result.HasNaN := False;
  Result.HasInfinity := False;
  Result.RaisedException := False;

  programlog.LogOutFormatStr(
    'ApproGeom Stability Test: %s',
    [Result.TestName],
    LM_Info
  );

  try
    // Очень большой радиус
    // Very large radius
    Segments := ApproximateArc(0, 0, 1e10, 0, Pi / 4, 0.01);

    Result.HasNaN := ContainsNaN(Segments);
    Result.HasInfinity := ContainsInfinity(Segments);

    if Result.HasNaN or Result.HasInfinity then
    begin
      Result.Message := 'Output contains NaN or Infinity';
      Exit;
    end;

    Result.Passed := True;
    Result.Message := Format('OK - %d segments', [Length(Segments)]);

  except
    on E: Exception do
    begin
      Result.RaisedException := True;
      Result.ExceptionMessage := E.Message;
      Result.Message := 'Exception: ' + E.Message;
    end;
  end;
end;

// Тест очень малого радиуса
function TestVerySmallRadius: TStabilityTestResult;
var
  Segments: TArray<TUzvBezierSegment>;
begin
  Result.TestName := 'Very Small Radius';
  Result.Passed := False;
  Result.HasNaN := False;
  Result.HasInfinity := False;
  Result.RaisedException := False;

  programlog.LogOutFormatStr(
    'ApproGeom Stability Test: %s',
    [Result.TestName],
    LM_Info
  );

  try
    // Очень маленький радиус (но > 0)
    // Very small radius (but > 0)
    Segments := ApproximateArc(0, 0, 0.00001, 0, Pi / 2, 0.01);

    Result.HasNaN := ContainsNaN(Segments);
    Result.HasInfinity := ContainsInfinity(Segments);

    if Result.HasNaN or Result.HasInfinity then
    begin
      Result.Message := 'Output contains NaN or Infinity';
      Exit;
    end;

    Result.Passed := True;
    Result.Message := Format('OK - %d segments', [Length(Segments)]);

  except
    on E: Exception do
    begin
      Result.RaisedException := True;
      Result.ExceptionMessage := E.Message;
      Result.Message := 'Exception: ' + E.Message;
    end;
  end;
end;

// Запустить все тесты
function RunAllStabilityTests: TStabilityTestResults;
begin
  programlog.LogOutFormatStr(
    'ApproGeom: Starting numerical stability tests',
    [],
    LM_Info
  );

  SetLength(Result, 9);

  Result[0] := TestZeroRadius;
  Result[1] := TestFullCircleArc;
  Result[2] := TestTinyArc;
  Result[3] := TestNegativeCoordinates;
  Result[4] := TestNegativeRadius;
  Result[5] := TestNaNInput;
  Result[6] := TestInfinityInput;
  Result[7] := TestLargeRadius;
  Result[8] := TestVerySmallRadius;

  LogStabilityTestResults(Result);
end;

// Вывести результаты тестов в лог
procedure LogStabilityTestResults(const Results: TStabilityTestResults);
var
  i: Integer;
  PassedCount: Integer;
begin
  PassedCount := 0;

  programlog.LogOutFormatStr(
    'ApproGeom: ===== Stability Test Results =====',
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
        'ApproGeom: [FAIL] %s - %s (NaN=%d, Inf=%d, Exc=%d)',
        [Results[i].TestName, Results[i].Message,
         Ord(Results[i].HasNaN),
         Ord(Results[i].HasInfinity),
         Ord(Results[i].RaisedException)],
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
