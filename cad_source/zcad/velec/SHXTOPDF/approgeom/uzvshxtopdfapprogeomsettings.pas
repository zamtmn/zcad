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
  Модуль: uzvshxtopdfapprogeomsettings
  Назначение: Параметры точности аппроксимации геометрии (tolerance / flatness)

  Данный модуль управляет параметрами точности аппроксимации:
  - Tolerance (допуск) - максимальное отклонение аппроксимации от исходной кривой
  - Flatness - параметр "плоскостности" для определения минимального разбиения

  Module: uzvshxtopdfapprogeomsettings
  Purpose: Geometry approximation precision parameters (tolerance / flatness)

  This module manages approximation precision parameters:
  - Tolerance - maximum deviation of approximation from original curve
  - Flatness - flatness parameter for determining minimum subdivision
}

unit uzvshxtopdfapprogeomsettings;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Math;

const
  // Минимально допустимое значение tolerance
  // Minimum allowed tolerance value
  MIN_TOLERANCE = 0.0001;

  // Максимально допустимое значение tolerance
  // Maximum allowed tolerance value
  MAX_TOLERANCE = 10.0;

  // Значение tolerance по умолчанию (высокая точность)
  // Default tolerance value (high precision)
  DEFAULT_TOLERANCE = 0.01;

  // Минимальный угол дуги для одного сегмента Безье (в радианах)
  // Для углов > 90° дуга разбивается на несколько сегментов
  // Minimum arc angle for single Bezier segment (in radians)
  // For angles > 90 degrees, arc is split into multiple segments
  MAX_ARC_ANGLE_PER_SEGMENT = Pi / 2;  // 90 градусов / 90 degrees

  // Минимальная длина сегмента (защита от вырождения)
  // Minimum segment length (protection from degeneration)
  MIN_SEGMENT_LENGTH = 0.0001;

  // Максимальное количество сегментов Безье на одну дугу
  // Maximum number of Bezier segments per arc
  MAX_BEZIER_SEGMENTS_PER_ARC = 16;

type
  // Настройки аппроксимации
  // Approximation settings
  TApproximationSettings = record
    Tolerance: Double;       // Допуск аппроксимации / Approximation tolerance
    MaxArcAngle: Double;     // Максимальный угол на сегмент / Max angle per segment
    MinSegmentLen: Double;   // Минимальная длина сегмента / Minimum segment length
    MaxSegmentsPerArc: Integer; // Макс. сегментов на дугу / Max segments per arc
  end;

// Получить настройки по умолчанию
// Get default settings
function GetDefaultApproximationSettings: TApproximationSettings;

// Получить настройки для высокой точности
// Get high precision settings
function GetHighPrecisionSettings: TApproximationSettings;

// Получить настройки для низкой точности (быстрая обработка)
// Get low precision settings (fast processing)
function GetLowPrecisionSettings: TApproximationSettings;

// Создать настройки с заданным tolerance
// Create settings with specified tolerance
function CreateApproximationSettings(ATolerance: Double): TApproximationSettings;

// Проверить корректность настроек
// Validate settings
function ValidateApproximationSettings(
  const Settings: TApproximationSettings
): Boolean;

// Вычислить количество сегментов для дуги заданного угла
// Calculate number of segments for arc of given angle
function CalculateArcSegmentCount(
  ArcAngle: Double;
  const Settings: TApproximationSettings
): Integer;

// Вычислить максимальную ошибку аппроксимации дуги одним сегментом Безье
// Calculate maximum approximation error for arc with single Bezier segment
// Формула / Formula: error ≈ r * (1 - cos(θ/4)) где θ - угол дуги
// Reference: Dokken, Tor, et al. "Good approximation of circles by
// curvature-continuous Bezier curves." Computer Aided Geometric Design, 1990
function CalculateArcApproximationError(
  Radius: Double;
  ArcAngle: Double
): Double;

// Вычислить оптимальный угол сегмента для заданного tolerance
// Calculate optimal segment angle for given tolerance
function CalculateOptimalSegmentAngle(
  Radius: Double;
  Tolerance: Double
): Double;

implementation

// Получить настройки по умолчанию
function GetDefaultApproximationSettings: TApproximationSettings;
begin
  Result.Tolerance := DEFAULT_TOLERANCE;
  Result.MaxArcAngle := MAX_ARC_ANGLE_PER_SEGMENT;
  Result.MinSegmentLen := MIN_SEGMENT_LENGTH;
  Result.MaxSegmentsPerArc := MAX_BEZIER_SEGMENTS_PER_ARC;
end;

// Получить настройки для высокой точности
function GetHighPrecisionSettings: TApproximationSettings;
begin
  Result.Tolerance := 0.001;           // Очень высокая точность
  Result.MaxArcAngle := Pi / 4;        // 45 градусов максимум
  Result.MinSegmentLen := 0.00001;
  Result.MaxSegmentsPerArc := 32;      // Больше сегментов
end;

// Получить настройки для низкой точности
function GetLowPrecisionSettings: TApproximationSettings;
begin
  Result.Tolerance := 0.1;             // Грубая аппроксимация
  Result.MaxArcAngle := Pi / 2;        // 90 градусов
  Result.MinSegmentLen := 0.001;
  Result.MaxSegmentsPerArc := 8;       // Меньше сегментов
end;

// Создать настройки с заданным tolerance
function CreateApproximationSettings(ATolerance: Double): TApproximationSettings;
begin
  Result := GetDefaultApproximationSettings;

  // Ограничиваем tolerance допустимым диапазоном
  // Clamp tolerance to valid range
  if ATolerance < MIN_TOLERANCE then
    Result.Tolerance := MIN_TOLERANCE
  else if ATolerance > MAX_TOLERANCE then
    Result.Tolerance := MAX_TOLERANCE
  else
    Result.Tolerance := ATolerance;
end;

// Проверить корректность настроек
function ValidateApproximationSettings(
  const Settings: TApproximationSettings
): Boolean;
begin
  Result := True;

  // Проверка tolerance
  if (Settings.Tolerance < MIN_TOLERANCE) or
     (Settings.Tolerance > MAX_TOLERANCE) or
     IsNaN(Settings.Tolerance) or
     IsInfinite(Settings.Tolerance) then
  begin
    Result := False;
    Exit;
  end;

  // Проверка максимального угла
  if (Settings.MaxArcAngle <= 0) or
     (Settings.MaxArcAngle > Pi) or
     IsNaN(Settings.MaxArcAngle) then
  begin
    Result := False;
    Exit;
  end;

  // Проверка минимальной длины сегмента
  if (Settings.MinSegmentLen <= 0) or
     IsNaN(Settings.MinSegmentLen) then
  begin
    Result := False;
    Exit;
  end;

  // Проверка максимального количества сегментов
  if Settings.MaxSegmentsPerArc < 1 then
  begin
    Result := False;
    Exit;
  end;
end;

// Вычислить количество сегментов для дуги заданного угла
function CalculateArcSegmentCount(
  ArcAngle: Double;
  const Settings: TApproximationSettings
): Integer;
var
  AbsAngle: Double;
  Count: Integer;
begin
  // Берём абсолютное значение угла
  // Take absolute angle value
  AbsAngle := Abs(ArcAngle);

  // Защита от некорректных значений
  // Protection from invalid values
  if IsNaN(AbsAngle) or IsInfinite(AbsAngle) or (AbsAngle < 0.0001) then
  begin
    Result := 1;
    Exit;
  end;

  // Вычисляем минимальное количество сегментов на основе угла
  // Calculate minimum segment count based on angle
  Count := Ceil(AbsAngle / Settings.MaxArcAngle);

  // Ограничиваем результат
  // Clamp result
  if Count < 1 then
    Count := 1
  else if Count > Settings.MaxSegmentsPerArc then
    Count := Settings.MaxSegmentsPerArc;

  Result := Count;
end;

// Вычислить максимальную ошибку аппроксимации дуги одним сегментом Безье
// Источник: статья Dokken et al. "Good approximation of circles..."
function CalculateArcApproximationError(
  Radius: Double;
  ArcAngle: Double
): Double;
var
  HalfAngle: Double;
begin
  // Защита от некорректных входных данных
  // Protection from invalid input
  if IsNaN(Radius) or IsNaN(ArcAngle) or (Radius <= 0) then
  begin
    Result := 0.0;
    Exit;
  end;

  // Для малых углов ошибка пренебрежимо мала
  // For small angles, error is negligible
  if Abs(ArcAngle) < 0.001 then
  begin
    Result := 0.0;
    Exit;
  end;

  // Формула ошибки: error ≈ r * (1 - cos(θ/4))
  // Error formula: error ≈ r * (1 - cos(θ/4))
  // Эта формула даёт верхнюю границу ошибки для стандартной аппроксимации
  HalfAngle := Abs(ArcAngle) / 4.0;
  Result := Radius * (1.0 - Cos(HalfAngle));
end;

// Вычислить оптимальный угол сегмента для заданного tolerance
function CalculateOptimalSegmentAngle(
  Radius: Double;
  Tolerance: Double
): Double;
var
  CosValue: Double;
  Angle: Double;
begin
  // Защита от некорректных входных данных
  // Protection from invalid input
  if IsNaN(Radius) or IsNaN(Tolerance) or
     (Radius <= 0) or (Tolerance <= 0) then
  begin
    Result := MAX_ARC_ANGLE_PER_SEGMENT;
    Exit;
  end;

  // Из формулы error = r * (1 - cos(θ/4)) выводим:
  // θ = 4 * arccos(1 - error/r)
  // From formula error = r * (1 - cos(θ/4)) we derive:
  // θ = 4 * arccos(1 - error/r)
  CosValue := 1.0 - (Tolerance / Radius);

  // Ограничиваем значение косинуса
  // Clamp cosine value
  if CosValue < -1.0 then
    CosValue := -1.0
  else if CosValue > 1.0 then
    CosValue := 1.0;

  Angle := 4.0 * ArcCos(CosValue);

  // Ограничиваем результат разумными пределами
  // Clamp result to reasonable limits
  if Angle < 0.01 then
    Angle := 0.01  // Минимум ~0.5 градуса
  else if Angle > MAX_ARC_ANGLE_PER_SEGMENT then
    Angle := MAX_ARC_ANGLE_PER_SEGMENT;

  Result := Angle;
end;

end.
