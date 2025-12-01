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
  Модуль: uzvshxtopdfcharprocsbbox
  Назначение: Расчёт bounding box для глифов и шрифта

  Данный модуль предоставляет функции для вычисления:
  - Bounding box отдельного сегмента Безье
  - Bounding box пути (контура)
  - Bounding box глифа
  - FontBBox как объединение всех глифов

  Алгоритм для кубических кривых Безье:
  - Находим экстремумы по производной B'(t) = 0
  - Проверяем начальную и конечную точки
  - Проверяем точки экстремумов в диапазоне t ∈ (0, 1)

  Зависимости:
  - uzvshxtopdfcharprocstypes: типы данных этапа 4
  - uzvshxtopdfapprogeomtypes: базовые геометрические типы
  - uzvshxtopdftransformtypes: типы данных этапа 3

  Module: uzvshxtopdfcharprocsbbox
  Purpose: Bounding box calculation for glyphs and fonts

  This module provides functions for calculating:
  - Bounding box of individual Bezier segment
  - Bounding box of path (contour)
  - Bounding box of glyph
  - FontBBox as union of all glyphs

  Algorithm for cubic Bezier curves:
  - Find extrema via derivative B'(t) = 0
  - Check start and end points
  - Check extremum points in range t ∈ (0, 1)

  Dependencies:
  - uzvshxtopdfcharprocstypes: Stage 4 data types
  - uzvshxtopdfapprogeomtypes: basic geometry types
  - uzvshxtopdftransformtypes: Stage 3 data types
}

unit uzvshxtopdfcharprocsbbox;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Math,
  uzvshxtopdfapprogeomtypes,
  uzvshxtopdftransformtypes,
  uzvshxtopdfcharprocstypes;

// Вычислить bounding box для сегмента кубической кривой Безье
// Calculate bounding box for cubic Bezier curve segment
function CalcBezierSegmentBBox(const Seg: TUzvBezierSegment): TUzvPdfBBox;

// Вычислить bounding box для пути (контура)
// Calculate bounding box for path (contour)
function CalcPathBBox(const Path: TUzvBezierPath): TUzvPdfBBox;

// Вычислить bounding box для глифа в мировых координатах
// Calculate bounding box for glyph in world coordinates
function CalcGlyphBBox(const Glyph: TUzvWorldBezierGlyph): TUzvPdfBBox;

// Вычислить FontBBox как объединение bounding box всех глифов
// Calculate FontBBox as union of all glyphs' bounding boxes
function CalcFontBBox(const Font: TUzvWorldBezierFont): TUzvPdfBBox;

// Вычислить bounding box для массива глифов
// Calculate bounding box for array of glyphs
function CalcGlyphArrayBBox(
  const Glyphs: array of TUzvWorldBezierGlyph
): TUzvPdfBBox;

implementation

// Константа для проверки валидности параметра t
// Constant for t parameter validation
const
  T_EPSILON = 1e-10;

// Вычислить значение на кубической кривой Безье в точке t
// Evaluate cubic Bezier curve at point t
// B(t) = (1-t)^3 * P0 + 3*(1-t)^2 * t * P1 + 3*(1-t) * t^2 * P2 + t^3 * P3
function EvalBezier(P0, P1, P2, P3, T: Double): Double;
var
  T2, T3: Double;
  MT, MT2, MT3: Double;
begin
  T2 := T * T;
  T3 := T2 * T;
  MT := 1.0 - T;
  MT2 := MT * MT;
  MT3 := MT2 * MT;

  Result := MT3 * P0 + 3.0 * MT2 * T * P1 + 3.0 * MT * T2 * P2 + T3 * P3;
end;

// Найти корни квадратного уравнения a*t^2 + b*t + c = 0
// Find roots of quadratic equation a*t^2 + b*t + c = 0
// Возвращает количество действительных корней (0, 1 или 2)
// Returns number of real roots (0, 1 or 2)
procedure SolveQuadratic(
  A, B, C: Double;
  out RootCount: Integer;
  out T1, T2: Double
);
var
  D, SqrtD, InvA: Double;
begin
  RootCount := 0;
  T1 := 0.0;
  T2 := 0.0;

  // Проверка на вырожденный случай (линейное уравнение)
  // Check for degenerate case (linear equation)
  if Abs(A) < T_EPSILON then
  begin
    if Abs(B) >= T_EPSILON then
    begin
      T1 := -C / B;
      RootCount := 1;
    end;
    Exit;
  end;

  // Дискриминант
  // Discriminant
  D := B * B - 4.0 * A * C;

  if D < -T_EPSILON then
  begin
    // Нет действительных корней
    // No real roots
    Exit;
  end;

  InvA := 1.0 / (2.0 * A);

  if D < T_EPSILON then
  begin
    // Один корень (дискриминант ≈ 0)
    // One root (discriminant ≈ 0)
    T1 := -B * InvA;
    RootCount := 1;
  end
  else
  begin
    // Два корня
    // Two roots
    SqrtD := Sqrt(D);
    T1 := (-B - SqrtD) * InvA;
    T2 := (-B + SqrtD) * InvA;
    RootCount := 2;
  end;
end;

// Найти экстремумы кубической кривой Безье по одной координате
// Find extrema of cubic Bezier curve for one coordinate
// Производная: B'(t) = 3*(1-t)^2*(P1-P0) + 6*(1-t)*t*(P2-P1) + 3*t^2*(P3-P2)
// После упрощения: a*t^2 + b*t + c = 0
// Derivative: B'(t) = 3*(1-t)^2*(P1-P0) + 6*(1-t)*t*(P2-P1) + 3*t^2*(P3-P2)
// After simplification: a*t^2 + b*t + c = 0
procedure FindBezierExtrema(
  P0, P1, P2, P3: Double;
  out ExtremumCount: Integer;
  out T1, T2: Double
);
var
  A, B, C: Double;
  RootCount: Integer;
  Temp1, Temp2: Double;
begin
  ExtremumCount := 0;
  T1 := 0.0;
  T2 := 0.0;

  // Коэффициенты производной после приведения к стандартной форме
  // Coefficients of derivative after reduction to standard form
  // B'(t) = 3 * [(P1-P0)(1-t)^2 + 2(P2-P1)(1-t)t + (P3-P2)t^2]
  // Раскрываем: a*t^2 + b*t + c = 0
  // где / where:
  //   a = (P0 - 3*P1 + 3*P2 - P3)
  //   b = 2*(3*P1 - 3*P2 - P0 + P0) = 2*(P0 - 2*P1 + P2)
  //   c = P1 - P0
  A := P0 - 3.0 * P1 + 3.0 * P2 - P3;
  B := 2.0 * (P1 - 2.0 * P1 + P2);
  // Упрощённо: B = 2*(P0 - 2*P1 + P2) - на самом деле нужно пересчитать
  // Правильные коэффициенты:
  // a = -P0 + 3*P1 - 3*P2 + P3
  // b = 2*(P0 - 2*P1 + P2)
  // c = -P0 + P1
  A := -P0 + 3.0 * P1 - 3.0 * P2 + P3;
  B := 2.0 * (P0 - 2.0 * P1 + P2);
  C := -P0 + P1;

  SolveQuadratic(A, B, C, RootCount, Temp1, Temp2);

  // Фильтруем корни: оставляем только те, что в (0, 1)
  // Filter roots: keep only those in (0, 1)
  if RootCount >= 1 then
  begin
    if (Temp1 > T_EPSILON) and (Temp1 < 1.0 - T_EPSILON) then
    begin
      Inc(ExtremumCount);
      T1 := Temp1;
    end;
  end;

  if RootCount >= 2 then
  begin
    if (Temp2 > T_EPSILON) and (Temp2 < 1.0 - T_EPSILON) then
    begin
      Inc(ExtremumCount);
      if ExtremumCount = 1 then
        T1 := Temp2
      else
        T2 := Temp2;
    end;
  end;
end;

// Вычислить bounding box для сегмента кубической кривой Безье
function CalcBezierSegmentBBox(const Seg: TUzvBezierSegment): TUzvPdfBBox;
var
  Box: TUzvPdfBBox;
  ExtCountX, ExtCountY: Integer;
  TX1, TX2, TY1, TY2: Double;
  Val: Double;
begin
  Box := CreateEmptyPdfBBox;

  // Проверка валидности точек
  // Validate points
  if not IsValidPoint(Seg.P0) or not IsValidPoint(Seg.P1) or
     not IsValidPoint(Seg.P2) or not IsValidPoint(Seg.P3) then
  begin
    Result := Box;
    Exit;
  end;

  // Начальная и конечная точки всегда входят в bounding box
  // Start and end points always belong to bounding box
  Box := ExpandPdfBBox(Box, Seg.P0);
  Box := ExpandPdfBBox(Box, Seg.P3);

  // Находим экстремумы по X
  // Find extrema for X
  FindBezierExtrema(Seg.P0.X, Seg.P1.X, Seg.P2.X, Seg.P3.X,
                    ExtCountX, TX1, TX2);

  if ExtCountX >= 1 then
  begin
    Val := EvalBezier(Seg.P0.X, Seg.P1.X, Seg.P2.X, Seg.P3.X, TX1);
    Box := ExpandPdfBBox(Box, MakePointF(Val, 0.0));
    // Примечание: Y-координата не важна для X-экстремума, но нужна для функции
    // Note: Y coordinate doesn't matter for X-extremum, but needed for function
    Box.MinX := Min(Box.MinX, Val);
    Box.MaxX := Max(Box.MaxX, Val);
  end;

  if ExtCountX >= 2 then
  begin
    Val := EvalBezier(Seg.P0.X, Seg.P1.X, Seg.P2.X, Seg.P3.X, TX2);
    Box.MinX := Min(Box.MinX, Val);
    Box.MaxX := Max(Box.MaxX, Val);
  end;

  // Находим экстремумы по Y
  // Find extrema for Y
  FindBezierExtrema(Seg.P0.Y, Seg.P1.Y, Seg.P2.Y, Seg.P3.Y,
                    ExtCountY, TY1, TY2);

  if ExtCountY >= 1 then
  begin
    Val := EvalBezier(Seg.P0.Y, Seg.P1.Y, Seg.P2.Y, Seg.P3.Y, TY1);
    Box.MinY := Min(Box.MinY, Val);
    Box.MaxY := Max(Box.MaxY, Val);
  end;

  if ExtCountY >= 2 then
  begin
    Val := EvalBezier(Seg.P0.Y, Seg.P1.Y, Seg.P2.Y, Seg.P3.Y, TY2);
    Box.MinY := Min(Box.MinY, Val);
    Box.MaxY := Max(Box.MaxY, Val);
  end;

  Result := Box;
end;

// Вычислить bounding box для пути (контура)
function CalcPathBBox(const Path: TUzvBezierPath): TUzvPdfBBox;
var
  I: Integer;
  SegBox: TUzvPdfBBox;
begin
  Result := CreateEmptyPdfBBox;

  // Проходим по всем сегментам и объединяем их bounding boxes
  // Iterate through all segments and merge their bounding boxes
  for I := 0 to High(Path.Segments) do
  begin
    SegBox := CalcBezierSegmentBBox(Path.Segments[I]);
    Result := MergePdfBBoxes(Result, SegBox);
  end;
end;

// Вычислить bounding box для глифа в мировых координатах
function CalcGlyphBBox(const Glyph: TUzvWorldBezierGlyph): TUzvPdfBBox;
var
  I: Integer;
  PathBox: TUzvPdfBBox;
begin
  Result := CreateEmptyPdfBBox;

  // Проходим по всем путям глифа и объединяем их bounding boxes
  // Iterate through all glyph paths and merge their bounding boxes
  for I := 0 to High(Glyph.Paths) do
  begin
    PathBox := CalcPathBBox(Glyph.Paths[I]);
    Result := MergePdfBBoxes(Result, PathBox);
  end;
end;

// Вычислить FontBBox как объединение bounding box всех глифов
function CalcFontBBox(const Font: TUzvWorldBezierFont): TUzvPdfBBox;
var
  I: Integer;
  GlyphBox: TUzvPdfBBox;
begin
  Result := CreateEmptyPdfBBox;

  // Проходим по всем глифам и объединяем их bounding boxes
  // Iterate through all glyphs and merge their bounding boxes
  for I := 0 to High(Font.Glyphs) do
  begin
    GlyphBox := CalcGlyphBBox(Font.Glyphs[I]);
    Result := MergePdfBBoxes(Result, GlyphBox);
  end;
end;

// Вычислить bounding box для массива глифов
function CalcGlyphArrayBBox(
  const Glyphs: array of TUzvWorldBezierGlyph
): TUzvPdfBBox;
var
  I: Integer;
  GlyphBox: TUzvPdfBBox;
begin
  Result := CreateEmptyPdfBBox;

  for I := 0 to High(Glyphs) do
  begin
    GlyphBox := CalcGlyphBBox(Glyphs[I]);
    Result := MergePdfBBoxes(Result, GlyphBox);
  end;
end;

end.
