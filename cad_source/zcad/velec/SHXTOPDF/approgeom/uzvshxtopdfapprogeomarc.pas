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
  Модуль: uzvshxtopdfapprogeomarc
  Назначение: Аппроксимация дуг окружности кубическими кривыми Безье

  Данный модуль реализует стандартную математическую формулу аппроксимации
  дуги окружности кубическими кривыми Безье с контролируемой точностью.

  Источники / References:
  1. Riškus, A. "Approximation of a cubic Bezier curve by circular arcs and vice versa"
     Information Technology and Control, 2006
  2. Dokken, T., et al. "Good approximation of circles by curvature-continuous
     Bezier curves." Computer Aided Geometric Design, 1990

  Module: uzvshxtopdfapprogeomarc
  Purpose: Approximation of circular arcs with cubic Bezier curves

  This module implements standard mathematical formula for approximating
  circular arcs with cubic Bezier curves with controlled precision.
}

unit uzvshxtopdfapprogeomarc;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Math,
  uzvshxtopdfapprogeomtypes,
  uzvshxtopdfapprogeomsettings,
  uzclog;

// Аппроксимировать дугу окружности кубическими кривыми Безье
// Approximate circular arc with cubic Bezier curves
//
// Параметры / Parameters:
//   CenterX, CenterY - координаты центра дуги / arc center coordinates
//   Radius - радиус дуги (может быть отрицательным для изменения направления)
//            arc radius (can be negative to change direction)
//   StartAngle - начальный угол в радианах / start angle in radians
//   EndAngle - конечный угол в радианах / end angle in radians
//   Tolerance - допустимое отклонение аппроксимации / allowed approximation deviation
//
// Возвращает / Returns:
//   Массив сегментов Безье, аппроксимирующих дугу
//   Array of Bezier segments approximating the arc
function ApproximateArc(
  CenterX, CenterY: Double;
  Radius: Double;
  StartAngle, EndAngle: Double;
  Tolerance: Double
): TArray<TUzvBezierSegment>;

// Аппроксимировать один сегмент дуги (угол <= 90°) одной кривой Безье
// Approximate single arc segment (angle <= 90 degrees) with one Bezier curve
//
// Источник формулы / Formula source:
//   Для дуги с углом θ контрольные точки вычисляются как:
//   k = 4/3 * tan(θ/4)
//   P1 = P0 + k * (-sin(α), cos(α)) * r
//   P2 = P3 + k * (sin(β), -cos(β)) * r
//   где α - начальный угол, β - конечный угол
//
// For arc with angle θ, control points are calculated as:
//   k = 4/3 * tan(θ/4)
//   P1 = P0 + k * (-sin(α), cos(α)) * r
//   P2 = P3 + k * (sin(β), -cos(β)) * r
//   where α - start angle, β - end angle
function ApproximateArcSegment(
  CenterX, CenterY: Double;
  Radius: Double;
  StartAngle, EndAngle: Double
): TUzvBezierSegment;

// Аппроксимировать полную окружность
// Approximate full circle
function ApproximateCircle(
  CenterX, CenterY: Double;
  Radius: Double;
  Tolerance: Double
): TArray<TUzvBezierSegment>;

// Вычислить точку на окружности
// Calculate point on circle
function PointOnCircle(
  CenterX, CenterY: Double;
  Radius: Double;
  Angle: Double
): TPointF;

// Нормализовать угол в диапазон [0, 2*Pi)
// Normalize angle to range [0, 2*Pi)
function NormalizeAngleToPositive(Angle: Double): Double;

// Вычислить угол развёртки дуги (с учётом направления)
// Calculate arc sweep angle (considering direction)
function CalculateSweepAngle(StartAngle, EndAngle: Double): Double;

implementation

// Коэффициент для вычисления контрольных точек Безье при аппроксимации дуги
// Coefficient for calculating Bezier control points when approximating arc
//
// Формула: k = 4/3 * tan(θ/4) где θ - угол сегмента
// Formula: k = 4/3 * tan(θ/4) where θ - segment angle
function CalculateBezierKappa(SegmentAngle: Double): Double;
var
  HalfAngle: Double;
begin
  // Защита от некорректных значений
  // Protection from invalid values
  if IsNaN(SegmentAngle) or (Abs(SegmentAngle) < 0.0001) then
  begin
    Result := 0.0;
    Exit;
  end;

  HalfAngle := Abs(SegmentAngle) / 4.0;

  // Формула: k = 4/3 * tan(θ/4)
  // Formula: k = 4/3 * tan(θ/4)
  Result := (4.0 / 3.0) * Tan(HalfAngle);

  // Учитываем знак угла (направление дуги)
  // Consider angle sign (arc direction)
  if SegmentAngle < 0 then
    Result := -Result;
end;

// Нормализовать угол в диапазон [0, 2*Pi)
function NormalizeAngleToPositive(Angle: Double): Double;
begin
  Result := Angle;

  // Приводим к диапазону [0, 2*Pi)
  // Normalize to range [0, 2*Pi)
  while Result < 0 do
    Result := Result + 2 * Pi;

  while Result >= 2 * Pi do
    Result := Result - 2 * Pi;
end;

// Вычислить угол развёртки дуги
function CalculateSweepAngle(StartAngle, EndAngle: Double): Double;
begin
  Result := EndAngle - StartAngle;

  // Нормализуем в диапазон [-2*Pi, 2*Pi]
  // Normalize to range [-2*Pi, 2*Pi]
  while Result > 2 * Pi do
    Result := Result - 2 * Pi;

  while Result < -2 * Pi do
    Result := Result + 2 * Pi;
end;

// Вычислить точку на окружности
function PointOnCircle(
  CenterX, CenterY: Double;
  Radius: Double;
  Angle: Double
): TPointF;
begin
  Result.X := CenterX + Radius * Cos(Angle);
  Result.Y := CenterY + Radius * Sin(Angle);
end;

// Аппроксимировать один сегмент дуги одной кривой Безье
function ApproximateArcSegment(
  CenterX, CenterY: Double;
  Radius: Double;
  StartAngle, EndAngle: Double
): TUzvBezierSegment;
var
  Kappa: Double;
  SegmentAngle: Double;
  CosStart, SinStart: Double;
  CosEnd, SinEnd: Double;
  AbsRadius: Double;
begin
  // Инициализация результата
  // Initialize result
  Result := CreateEmptyBezierSegment;

  // Защита от некорректного радиуса
  // Protection from invalid radius
  AbsRadius := Abs(Radius);
  if IsNaN(AbsRadius) or (AbsRadius < MIN_SEGMENT_LENGTH) then
  begin
    programlog.LogOutFormatStr(
      'ApproGeom: Arc skipped - invalid radius %.6f',
      [Radius],
      LM_Info
    );
    Exit;
  end;

  // Вычисляем угол сегмента
  // Calculate segment angle
  SegmentAngle := EndAngle - StartAngle;

  // Защита от вырожденного сегмента
  // Protection from degenerate segment
  if Abs(SegmentAngle) < 0.0001 then
  begin
    // Возвращаем "точечный" сегмент
    // Return "point" segment
    Result.P0 := PointOnCircle(CenterX, CenterY, AbsRadius, StartAngle);
    Result.P3 := Result.P0;
    Result.P1 := Result.P0;
    Result.P2 := Result.P0;
    Exit;
  end;

  // Предварительно вычисляем тригонометрические функции
  // Pre-calculate trigonometric functions
  SinCos(StartAngle, SinStart, CosStart);
  SinCos(EndAngle, SinEnd, CosEnd);

  // Вычисляем начальную и конечную точки дуги
  // Calculate arc start and end points
  Result.P0 := MakePointF(
    CenterX + AbsRadius * CosStart,
    CenterY + AbsRadius * SinStart
  );

  Result.P3 := MakePointF(
    CenterX + AbsRadius * CosEnd,
    CenterY + AbsRadius * SinEnd
  );

  // Вычисляем коэффициент для контрольных точек
  // Calculate coefficient for control points
  Kappa := CalculateBezierKappa(SegmentAngle);

  // Вычисляем контрольные точки
  // Calculate control points
  //
  // P1 расположена в направлении касательной в начальной точке
  // P1 is placed along the tangent direction at start point
  Result.P1 := MakePointF(
    Result.P0.X - Kappa * AbsRadius * SinStart,
    Result.P0.Y + Kappa * AbsRadius * CosStart
  );

  // P2 расположена в направлении касательной (обратной) в конечной точке
  // P2 is placed along the (reverse) tangent direction at end point
  Result.P2 := MakePointF(
    Result.P3.X + Kappa * AbsRadius * SinEnd,
    Result.P3.Y - Kappa * AbsRadius * CosEnd
  );

  // Если радиус отрицательный, меняем направление контрольных точек
  // If radius is negative, reverse control points direction
  if Radius < 0 then
  begin
    // Зеркалируем контрольные точки относительно центра
    // Mirror control points relative to center
    Result.P1 := MakePointF(
      2 * CenterX - Result.P1.X,
      2 * CenterY - Result.P1.Y
    );
    Result.P2 := MakePointF(
      2 * CenterX - Result.P2.X,
      2 * CenterY - Result.P2.Y
    );
  end;
end;

// Аппроксимировать дугу окружности кубическими кривыми Безье
function ApproximateArc(
  CenterX, CenterY: Double;
  Radius: Double;
  StartAngle, EndAngle: Double;
  Tolerance: Double
): TArray<TUzvBezierSegment>;
var
  Settings: TApproximationSettings;
  SweepAngle: Double;
  AbsRadius: Double;
  SegmentCount: Integer;
  OptimalAngle: Double;
  AngleStep: Double;
  CurrentStartAngle: Double;
  CurrentEndAngle: Double;
  i: Integer;
  Segment: TUzvBezierSegment;
begin
  SetLength(Result, 0);

  // Защита от некорректных входных данных
  // Protection from invalid input
  AbsRadius := Abs(Radius);
  if IsNaN(AbsRadius) or IsNaN(CenterX) or IsNaN(CenterY) or
     IsNaN(StartAngle) or IsNaN(EndAngle) or
     IsInfinite(AbsRadius) or (AbsRadius < MIN_SEGMENT_LENGTH) then
  begin
    programlog.LogOutFormatStr(
      'ApproGeom: Arc approximation skipped - invalid parameters',
      [],
      LM_Info
    );
    Exit;
  end;

  // Защита от некорректного tolerance
  // Protection from invalid tolerance
  if IsNaN(Tolerance) or (Tolerance <= 0) then
    Tolerance := DEFAULT_TOLERANCE;

  // Вычисляем угол развёртки
  // Calculate sweep angle
  SweepAngle := CalculateSweepAngle(StartAngle, EndAngle);

  // Для очень малых углов возвращаем один сегмент
  // For very small angles return single segment
  if Abs(SweepAngle) < 0.001 then
  begin
    SetLength(Result, 1);
    Result[0] := ApproximateArcSegment(CenterX, CenterY, Radius, StartAngle, EndAngle);
    Exit;
  end;

  // Вычисляем оптимальный угол сегмента для заданной точности
  // Calculate optimal segment angle for given precision
  OptimalAngle := CalculateOptimalSegmentAngle(AbsRadius, Tolerance);

  // Вычисляем необходимое количество сегментов
  // Calculate required number of segments
  SegmentCount := Ceil(Abs(SweepAngle) / OptimalAngle);

  // Ограничиваем количество сегментов
  // Limit number of segments
  Settings := CreateApproximationSettings(Tolerance);
  if SegmentCount < 1 then
    SegmentCount := 1
  else if SegmentCount > Settings.MaxSegmentsPerArc then
    SegmentCount := Settings.MaxSegmentsPerArc;

  programlog.LogOutFormatStr(
    'ApproGeom: Arc approximated to %d bezier segments (sweep=%.2f deg, r=%.2f)',
    [SegmentCount, RadToDeg(SweepAngle), AbsRadius],
    LM_Info
  );

  // Создаём массив сегментов
  // Create segments array
  SetLength(Result, SegmentCount);

  // Вычисляем шаг угла
  // Calculate angle step
  AngleStep := SweepAngle / SegmentCount;

  // Генерируем сегменты
  // Generate segments
  CurrentStartAngle := StartAngle;

  for i := 0 to SegmentCount - 1 do
  begin
    if i = SegmentCount - 1 then
      CurrentEndAngle := EndAngle  // Последний сегмент точно до EndAngle
    else
      CurrentEndAngle := CurrentStartAngle + AngleStep;

    Result[i] := ApproximateArcSegment(
      CenterX, CenterY, Radius,
      CurrentStartAngle, CurrentEndAngle
    );

    CurrentStartAngle := CurrentEndAngle;
  end;
end;

// Аппроксимировать полную окружность
function ApproximateCircle(
  CenterX, CenterY: Double;
  Radius: Double;
  Tolerance: Double
): TArray<TUzvBezierSegment>;
var
  Settings: TApproximationSettings;
  AbsRadius: Double;
  SegmentCount: Integer;
  AngleStep: Double;
  i: Integer;
  StartAngle, EndAngle: Double;
begin
  SetLength(Result, 0);

  // Защита от некорректного радиуса
  // Protection from invalid radius
  AbsRadius := Abs(Radius);
  if IsNaN(AbsRadius) or (AbsRadius < MIN_SEGMENT_LENGTH) then
  begin
    programlog.LogOutFormatStr(
      'ApproGeom: Circle approximation skipped - invalid radius %.6f',
      [Radius],
      LM_Info
    );
    Exit;
  end;

  // Защита от некорректного tolerance
  if IsNaN(Tolerance) or (Tolerance <= 0) then
    Tolerance := DEFAULT_TOLERANCE;

  // Для окружности обычно используем 4 сегмента (по 90°)
  // For circle we usually use 4 segments (90 degrees each)
  Settings := CreateApproximationSettings(Tolerance);
  SegmentCount := CalculateArcSegmentCount(2 * Pi, Settings);

  // Минимум 4 сегмента для окружности
  // Minimum 4 segments for circle
  if SegmentCount < 4 then
    SegmentCount := 4;

  programlog.LogOutFormatStr(
    'ApproGeom: Circle approximated to %d bezier segments (r=%.2f)',
    [SegmentCount, AbsRadius],
    LM_Info
  );

  SetLength(Result, SegmentCount);
  AngleStep := 2 * Pi / SegmentCount;

  for i := 0 to SegmentCount - 1 do
  begin
    StartAngle := i * AngleStep;
    EndAngle := (i + 1) * AngleStep;

    Result[i] := ApproximateArcSegment(
      CenterX, CenterY, AbsRadius,
      StartAngle, EndAngle
    );
  end;
end;

end.
