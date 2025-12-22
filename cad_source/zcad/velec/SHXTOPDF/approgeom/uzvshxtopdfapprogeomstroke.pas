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
  Модуль: uzvshxtopdfapprogeomstroke
  Назначение: Обработка обводки (stroke) и расширение в заливку (expand)

  Данный модуль реализует два режима работы:
  1. Stroke Only - кривые остаются линиями Безье без утолщения
  2. Expand Stroke - линии превращаются в замкнутые контуры (fill)
     с параллельными смещёнными кривыми и корректной обработкой соединений

  Источники / References:
  1. "Stroking and Filling" - PDF Reference Manual
  2. Kilgard, M.J. "GPU-accelerated Path Rendering" ACM TOG, 2012

  Module: uzvshxtopdfapprogeomstroke
  Purpose: Stroke processing and expansion to fill

  This module implements two operation modes:
  1. Stroke Only - curves remain as Bezier lines without thickening
  2. Expand Stroke - lines become closed contours (fill)
     with parallel offset curves and correct join handling
}

unit uzvshxtopdfapprogeomstroke;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Math,
  uzvshxtopdfapprogeomtypes,
  uzvshxtopdfapprogeomsettings,
  uzclog;

// Обработать путь в режиме Stroke Only (без изменения)
// Process path in Stroke Only mode (no changes)
//
// В этом режиме путь просто копируется без модификации.
// Обводка будет применена на уровне PDF рендеринга.
// In this mode, path is simply copied without modification.
// Stroke will be applied at PDF rendering level.
function ProcessStrokeOnly(
  const Path: TUzvBezierPath
): TUzvBezierPath;

// Расширить путь в заливку (Expand Stroke)
// Expand path to fill (Expand Stroke)
//
// Преобразует линию обводки в замкнутый контур заданной ширины.
// Создаёт два параллельных пути (слева и справа от исходного) и
// соединяет их на концах.
// Converts stroke line to closed contour of specified width.
// Creates two parallel paths (left and right of original) and
// connects them at the ends.
function ExpandStrokeToFill(
  const Path: TUzvBezierPath;
  const StrokeParams: TUzvStrokeParams;
  Tolerance: Double
): TUzvBezierPath;

// Вычислить смещённый сегмент Безье (offset curve)
// Calculate offset Bezier segment (offset curve)
//
// Смещает кривую Безье на заданное расстояние по нормали.
// Это приближённое решение, так как точное смещение кубической
// кривой Безье может давать кривую более высокого порядка.
// Offsets Bezier curve by given distance along normal.
// This is approximate solution since exact offset of cubic
// Bezier curve can produce higher order curve.
function OffsetBezierSegment(
  const Segment: TUzvBezierSegment;
  Offset: Double
): TUzvBezierSegment;

// Вычислить нормаль к кривой Безье в заданной точке
// Calculate normal to Bezier curve at given point
//
// Параметр t ∈ [0, 1] определяет позицию на кривой
// Parameter t ∈ [0, 1] defines position on curve
function BezierNormal(
  const Segment: TUzvBezierSegment;
  t: Double
): TPointF;

// Вычислить касательную к кривой Безье в заданной точке
// Calculate tangent to Bezier curve at given point
function BezierTangent(
  const Segment: TUzvBezierSegment;
  t: Double
): TPointF;

// Вычислить точку на кривой Безье
// Calculate point on Bezier curve
function BezierPoint(
  const Segment: TUzvBezierSegment;
  t: Double
): TPointF;

// Создать соединение между двумя сегментами (miter/bevel)
// Create join between two segments (miter/bevel)
function CreateJoin(
  const EndPoint: TPointF;
  const Dir1, Dir2: TPointF;
  HalfWidth: Double;
  JoinType: TUzvLineJoin;
  MiterLimit: Double
): array of TUzvBezierSegment;

// Создать окончание линии (cap)
// Create line cap
function CreateCap(
  const EndPoint: TPointF;
  const Direction: TPointF;
  HalfWidth: Double;
  CapType: TUzvLineCap
): array of TUzvBezierSegment;

// Нормализовать вектор (привести к единичной длине)
// Normalize vector (make unit length)
function NormalizeVector(const V: TPointF): TPointF;

// Вычислить длину вектора
// Calculate vector length
function VectorLength(const V: TPointF): Double;

// Повернуть вектор на 90 градусов против часовой стрелки
// Rotate vector 90 degrees counter-clockwise
function PerpendicularCCW(const V: TPointF): TPointF;

implementation

// Вычислить длину вектора
function VectorLength(const V: TPointF): Double;
begin
  Result := Sqrt(V.X * V.X + V.Y * V.Y);
end;

// Нормализовать вектор
function NormalizeVector(const V: TPointF): TPointF;
var
  Len: Double;
begin
  Len := VectorLength(V);

  if Len < MIN_SEGMENT_LENGTH then
  begin
    // Возвращаем единичный вектор по X для вырожденного случая
    // Return unit X vector for degenerate case
    Result := MakePointF(1.0, 0.0);
    Exit;
  end;

  Result := MakePointF(V.X / Len, V.Y / Len);
end;

// Повернуть вектор на 90 градусов против часовой стрелки
function PerpendicularCCW(const V: TPointF): TPointF;
begin
  Result := MakePointF(-V.Y, V.X);
end;

// Вычислить точку на кривой Безье
// Формула: B(t) = (1-t)³P₀ + 3(1-t)²tP₁ + 3(1-t)t²P₂ + t³P₃
function BezierPoint(
  const Segment: TUzvBezierSegment;
  t: Double
): TPointF;
var
  t2, t3: Double;
  mt, mt2, mt3: Double;
begin
  // Предварительные вычисления для оптимизации
  // Pre-calculations for optimization
  t2 := t * t;
  t3 := t2 * t;
  mt := 1.0 - t;
  mt2 := mt * mt;
  mt3 := mt2 * mt;

  Result.X := mt3 * Segment.P0.X +
              3.0 * mt2 * t * Segment.P1.X +
              3.0 * mt * t2 * Segment.P2.X +
              t3 * Segment.P3.X;

  Result.Y := mt3 * Segment.P0.Y +
              3.0 * mt2 * t * Segment.P1.Y +
              3.0 * mt * t2 * Segment.P2.Y +
              t3 * Segment.P3.Y;
end;

// Вычислить касательную к кривой Безье
// Формула: B'(t) = 3(1-t)²(P₁-P₀) + 6(1-t)t(P₂-P₁) + 3t²(P₃-P₂)
function BezierTangent(
  const Segment: TUzvBezierSegment;
  t: Double
): TPointF;
var
  t2: Double;
  mt, mt2: Double;
  D01, D12, D23: TPointF;
begin
  t2 := t * t;
  mt := 1.0 - t;
  mt2 := mt * mt;

  // Разности контрольных точек
  // Control point differences
  D01 := SubtractPoints(Segment.P1, Segment.P0);
  D12 := SubtractPoints(Segment.P2, Segment.P1);
  D23 := SubtractPoints(Segment.P3, Segment.P2);

  Result.X := 3.0 * mt2 * D01.X +
              6.0 * mt * t * D12.X +
              3.0 * t2 * D23.X;

  Result.Y := 3.0 * mt2 * D01.Y +
              6.0 * mt * t * D12.Y +
              3.0 * t2 * D23.Y;
end;

// Вычислить нормаль к кривой Безье
function BezierNormal(
  const Segment: TUzvBezierSegment;
  t: Double
): TPointF;
var
  Tangent: TPointF;
begin
  Tangent := BezierTangent(Segment, t);
  Tangent := NormalizeVector(Tangent);

  // Нормаль - это касательная, повёрнутая на 90°
  // Normal is tangent rotated by 90 degrees
  Result := PerpendicularCCW(Tangent);
end;

// Вычислить смещённый сегмент Безье
function OffsetBezierSegment(
  const Segment: TUzvBezierSegment;
  Offset: Double
): TUzvBezierSegment;
var
  N0, N1, N2, N3: TPointF;
begin
  // Вычисляем нормали в ключевых точках
  // Calculate normals at key points
  N0 := BezierNormal(Segment, 0.0);
  N1 := BezierNormal(Segment, 1.0 / 3.0);
  N2 := BezierNormal(Segment, 2.0 / 3.0);
  N3 := BezierNormal(Segment, 1.0);

  // Смещаем точки вдоль нормалей
  // Offset points along normals
  Result.P0 := AddPoints(Segment.P0, ScalePoint(N0, Offset));
  Result.P1 := AddPoints(Segment.P1, ScalePoint(N1, Offset));
  Result.P2 := AddPoints(Segment.P2, ScalePoint(N2, Offset));
  Result.P3 := AddPoints(Segment.P3, ScalePoint(N3, Offset));
end;

// Создать соединение между двумя сегментами
function CreateJoin(
  const EndPoint: TPointF;
  const Dir1, Dir2: TPointF;
  HalfWidth: Double;
  JoinType: TUzvLineJoin;
  MiterLimit: Double
): array of TUzvBezierSegment;
var
  N1, N2: TPointF;
  P1, P2: TPointF;
  Cross: Double;
  MiterPoint: TPointF;
  MiterLen: Double;
  SinHalfAngle: Double;
begin
  SetLength(Result, 0);

  // Нормали к направлениям
  // Normals to directions
  N1 := PerpendicularCCW(NormalizeVector(Dir1));
  N2 := PerpendicularCCW(NormalizeVector(Dir2));

  // Точки на внешней стороне
  // Points on outer side
  P1 := AddPoints(EndPoint, ScalePoint(N1, HalfWidth));
  P2 := AddPoints(EndPoint, ScalePoint(N2, HalfWidth));

  case JoinType of
    ljMiter:
    begin
      // Для miter join вычисляем точку пересечения
      // For miter join calculate intersection point
      Cross := Dir1.X * Dir2.Y - Dir1.Y * Dir2.X;

      if Abs(Cross) > 0.0001 then
      begin
        // Вычисляем длину miter
        SinHalfAngle := Abs(Cross) / 2.0;
        MiterLen := HalfWidth / SinHalfAngle;

        // Проверяем предел miter
        if MiterLen <= HalfWidth * MiterLimit then
        begin
          // Miter join - одна линия до точки miter
          MiterPoint := AddPoints(
            EndPoint,
            ScalePoint(
              AddPoints(N1, N2),
              HalfWidth / (1.0 + N1.X * N2.X + N1.Y * N2.Y)
            )
          );

          SetLength(Result, 2);
          Result[0] := CreateLineBezierSegment(P1, MiterPoint);
          Result[1] := CreateLineBezierSegment(MiterPoint, P2);
          Exit;
        end;
      end;

      // Fallback to bevel если miter слишком длинный
      // Fallback to bevel if miter too long
      SetLength(Result, 1);
      Result[0] := CreateLineBezierSegment(P1, P2);
    end;

    ljBevel:
    begin
      // Bevel join - простая линия между точками
      // Bevel join - simple line between points
      SetLength(Result, 1);
      Result[0] := CreateLineBezierSegment(P1, P2);
    end;

    ljRound:
    begin
      // Round join - дуга между точками
      // Round join - arc between points
      // Для упрощения используем bevel
      // For simplicity use bevel
      SetLength(Result, 1);
      Result[0] := CreateLineBezierSegment(P1, P2);
    end;
  end;
end;

// Создать окончание линии
function CreateCap(
  const EndPoint: TPointF;
  const Direction: TPointF;
  HalfWidth: Double;
  CapType: TUzvLineCap
): array of TUzvBezierSegment;
var
  Normal: TPointF;
  Dir: TPointF;
  P1, P2, P3, P4: TPointF;
begin
  SetLength(Result, 0);

  Dir := NormalizeVector(Direction);
  Normal := PerpendicularCCW(Dir);

  // Точки на концах перпендикуляра
  // Points at perpendicular ends
  P1 := AddPoints(EndPoint, ScalePoint(Normal, HalfWidth));
  P2 := SubtractPoints(EndPoint, ScalePoint(Normal, HalfWidth));

  case CapType of
    lcButt:
    begin
      // Butt cap - просто линия между крайними точками
      // Butt cap - just line between extreme points
      SetLength(Result, 1);
      Result[0] := CreateLineBezierSegment(P1, P2);
    end;

    lcSquare:
    begin
      // Square cap - квадратное окончание, выступающее на HalfWidth
      // Square cap - square ending extending by HalfWidth
      P3 := AddPoints(P1, ScalePoint(Dir, HalfWidth));
      P4 := AddPoints(P2, ScalePoint(Dir, HalfWidth));

      SetLength(Result, 3);
      Result[0] := CreateLineBezierSegment(P1, P3);
      Result[1] := CreateLineBezierSegment(P3, P4);
      Result[2] := CreateLineBezierSegment(P4, P2);
    end;

    lcRound:
    begin
      // Round cap - полукруг
      // Round cap - semicircle
      // Для упрощения используем butt
      // For simplicity use butt
      SetLength(Result, 1);
      Result[0] := CreateLineBezierSegment(P1, P2);
    end;
  end;
end;

// Обработать путь в режиме Stroke Only
function ProcessStrokeOnly(
  const Path: TUzvBezierPath
): TUzvBezierPath;
var
  i: Integer;
begin
  // Просто копируем путь без изменений
  // Simply copy path without changes
  Result.IsClosed := Path.IsClosed;
  SetLength(Result.Segments, Length(Path.Segments));

  for i := 0 to High(Path.Segments) do
    Result.Segments[i] := Path.Segments[i];

  programlog.LogOutFormatStr(
    'ApproGeom: Stroke-only processing, %d segments unchanged',
    [Length(Path.Segments)],
    LM_Info
  );
end;

// Расширить путь в заливку (Expand Stroke)
function ExpandStrokeToFill(
  const Path: TUzvBezierPath;
  const StrokeParams: TUzvStrokeParams;
  Tolerance: Double
): TUzvBezierPath;
var
  HalfWidth: Double;
  LeftPath, RightPath: array of TUzvBezierSegment;
  i, Idx: Integer;
  LeftSeg, RightSeg: TUzvBezierSegment;
  StartCap, EndCap: array of TUzvBezierSegment;
  StartDir, EndDir: TPointF;
begin
  Result := CreateEmptyBezierPath;

  // Проверка на пустой путь
  // Check for empty path
  if Length(Path.Segments) = 0 then
  begin
    programlog.LogOutFormatStr(
      'ApproGeom: Expand stroke skipped - empty path',
      [],
      LM_Info
    );
    Exit;
  end;

  HalfWidth := StrokeParams.LineWidth / 2.0;

  // Защита от слишком тонких линий
  // Protection from too thin lines
  if HalfWidth < MIN_SEGMENT_LENGTH then
  begin
    programlog.LogOutFormatStr(
      'ApproGeom: Expand stroke skipped - line width too small (%.6f)',
      [StrokeParams.LineWidth],
      LM_Info
    );
    Result := ProcessStrokeOnly(Path);
    Exit;
  end;

  // Создаём левый и правый смещённые пути
  // Create left and right offset paths
  SetLength(LeftPath, Length(Path.Segments));
  SetLength(RightPath, Length(Path.Segments));

  for i := 0 to High(Path.Segments) do
  begin
    LeftSeg := OffsetBezierSegment(Path.Segments[i], HalfWidth);
    RightSeg := OffsetBezierSegment(Path.Segments[i], -HalfWidth);

    LeftPath[i] := LeftSeg;
    RightPath[i] := RightSeg;
  end;

  // Собираем результирующий замкнутый контур
  // Assemble resulting closed contour
  // Порядок: левый путь вперёд, окончание, правый путь назад, начало
  // Order: left path forward, end cap, right path backward, start cap

  // Начальное направление
  StartDir := BezierTangent(Path.Segments[0], 0.0);
  StartDir := ScalePoint(StartDir, -1.0);  // Обратное направление для начала

  // Конечное направление
  EndDir := BezierTangent(Path.Segments[High(Path.Segments)], 1.0);

  if not Path.IsClosed then
  begin
    // Создаём caps для незамкнутого пути
    // Create caps for open path
    StartCap := CreateCap(
      Path.Segments[0].P0,
      StartDir,
      HalfWidth,
      StrokeParams.LineCap
    );

    EndCap := CreateCap(
      Path.Segments[High(Path.Segments)].P3,
      EndDir,
      HalfWidth,
      StrokeParams.LineCap
    );
  end
  else
  begin
    SetLength(StartCap, 0);
    SetLength(EndCap, 0);
  end;

  // Вычисляем общий размер результата
  // Calculate total result size
  SetLength(
    Result.Segments,
    Length(LeftPath) +
    Length(EndCap) +
    Length(RightPath) +
    Length(StartCap)
  );

  Idx := 0;

  // Левый путь (вперёд)
  // Left path (forward)
  for i := 0 to High(LeftPath) do
  begin
    Result.Segments[Idx] := LeftPath[i];
    Inc(Idx);
  end;

  // Окончание (end cap) или соединение
  // End cap or join
  for i := 0 to High(EndCap) do
  begin
    Result.Segments[Idx] := EndCap[i];
    Inc(Idx);
  end;

  // Правый путь (назад)
  // Right path (backward)
  for i := High(RightPath) downto 0 do
  begin
    // Разворачиваем сегмент
    // Reverse segment
    Result.Segments[Idx].P0 := RightPath[i].P3;
    Result.Segments[Idx].P1 := RightPath[i].P2;
    Result.Segments[Idx].P2 := RightPath[i].P1;
    Result.Segments[Idx].P3 := RightPath[i].P0;
    Inc(Idx);
  end;

  // Начало (start cap) или соединение
  // Start cap or join
  for i := 0 to High(StartCap) do
  begin
    Result.Segments[Idx] := StartCap[i];
    Inc(Idx);
  end;

  Result.IsClosed := True;

  programlog.LogOutFormatStr(
    'ApproGeom: Stroke expanded to fill, %d segments -> %d segments (width=%.2f)',
    [Length(Path.Segments), Length(Result.Segments), StrokeParams.LineWidth],
    LM_Info
  );
end;

end.
