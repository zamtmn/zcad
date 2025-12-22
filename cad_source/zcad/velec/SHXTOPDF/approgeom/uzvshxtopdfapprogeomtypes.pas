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
  Модуль: uzvshxtopdfapprogeomtypes
  Назначение: Определение типов данных для этапа 2 конвейера SHX → PDF

  Данный модуль содержит структуры данных для представления глифов шрифта
  в форме кубических кривых Безье, совместимых с PDF-графикой.

  Module: uzvshxtopdfapprogeomtypes
  Purpose: Data types definition for Stage 2 of SHX → PDF pipeline

  This module contains data structures for representing font glyphs
  as cubic Bezier curves compatible with PDF graphics.
}

unit uzvshxtopdfapprogeomtypes;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Math;

type
  // Точка в 2D пространстве с координатами X, Y
  // 2D point with X, Y coordinates
  TPointF = record
    X, Y: Double;
  end;

  // Сегмент кубической кривой Безье
  // Cubic Bezier curve segment
  //
  // Математическое представление кубической кривой Безье:
  // Mathematical representation of cubic Bezier curve:
  //   B(t) = (1-t)^3 * P0 + 3*(1-t)^2 * t * P1 + 3*(1-t) * t^2 * P2 + t^3 * P3
  // где / where t ∈ [0, 1]
  //
  // Источник / Reference: https://pomax.github.io/bezierinfo/
  TUzvBezierSegment = record
    P0: TPointF;  // Начальная точка / Start point
    P1: TPointF;  // Первая контрольная точка / First control point
    P2: TPointF;  // Вторая контрольная точка / Second control point
    P3: TPointF;  // Конечная точка / End point
  end;

  // Путь из сегментов Безье (контур)
  // Path of Bezier segments (contour)
  TUzvBezierPath = record
    Segments: array of TUzvBezierSegment;  // Массив сегментов / Segments array
    IsClosed: Boolean;                      // Замкнут ли контур / Is contour closed
  end;

  // Глиф шрифта в форме кривых Безье
  // Font glyph as Bezier curves
  TUzvBezierGlyph = record
    Code: Integer;                    // Код символа (Unicode или ANSI)
                                      // Character code (Unicode or ANSI)
    Width: Double;                    // Ширина продвижения (advance width)
                                      // Advance width
    Paths: array of TUzvBezierPath;   // Массив контуров глифа
                                      // Array of glyph contours
  end;

  // Шрифт в форме кривых Безье - результат этапа 2
  // Font as Bezier curves - Stage 2 result
  TUzvBezierFont = record
    FontName: string;                      // Имя шрифта / Font name
    Glyphs: array of TUzvBezierGlyph;      // Массив глифов / Glyphs array
  end;

  // Тип соединения линий при расширении обводки (stroke expand)
  // Line join type for stroke expansion
  TUzvLineJoin = (
    ljMiter,   // Острое соединение / Miter join
    ljBevel,   // Скошенное соединение / Bevel join
    ljRound    // Скруглённое соединение / Round join
  );

  // Тип окончания линии при расширении обводки
  // Line cap type for stroke expansion
  TUzvLineCap = (
    lcButt,    // Без окончания / Butt cap
    lcSquare,  // Квадратное окончание / Square cap
    lcRound    // Скруглённое окончание / Round cap
  );

  // Параметры обводки для режима ExpandStroke
  // Stroke parameters for ExpandStroke mode
  TUzvStrokeParams = record
    LineWidth: Double;        // Толщина линии / Line width
    LineJoin: TUzvLineJoin;   // Тип соединения / Join type
    LineCap: TUzvLineCap;     // Тип окончания / Cap type
    MiterLimit: Double;       // Предел острия (для ljMiter) / Miter limit
  end;

// Вспомогательные функции для работы с точками
// Helper functions for working with points

// Создать точку с заданными координатами
// Create point with specified coordinates
function MakePointF(AX, AY: Double): TPointF;

// Сложение двух точек (как векторов)
// Add two points (as vectors)
function AddPoints(const A, B: TPointF): TPointF;

// Вычитание точек (как векторов)
// Subtract points (as vectors)
function SubtractPoints(const A, B: TPointF): TPointF;

// Умножение точки на скаляр
// Multiply point by scalar
function ScalePoint(const P: TPointF; Factor: Double): TPointF;

// Вычислить расстояние между двумя точками
// Calculate distance between two points
function DistancePoints(const A, B: TPointF): Double;

// Проверить, являются ли координаты точки валидными (не NaN, не Infinity)
// Check if point coordinates are valid (not NaN, not Infinity)
function IsValidPoint(const P: TPointF): Boolean;

// Создать пустой сегмент Безье
// Create empty Bezier segment
function CreateEmptyBezierSegment: TUzvBezierSegment;

// Создать сегмент Безье для прямой линии (P1 и P2 интерполируются)
// Create Bezier segment for straight line (P1 and P2 are interpolated)
function CreateLineBezierSegment(const Start, Finish: TPointF): TUzvBezierSegment;

// Создать пустой путь Безье
// Create empty Bezier path
function CreateEmptyBezierPath: TUzvBezierPath;

// Создать пустой глиф Безье
// Create empty Bezier glyph
function CreateEmptyBezierGlyph(ACode: Integer): TUzvBezierGlyph;

// Создать пустой шрифт Безье
// Create empty Bezier font
function CreateEmptyBezierFont: TUzvBezierFont;

// Получить параметры обводки по умолчанию
// Get default stroke parameters
function GetDefaultStrokeParams: TUzvStrokeParams;

implementation

// Создать точку с заданными координатами
function MakePointF(AX, AY: Double): TPointF;
begin
  Result.X := AX;
  Result.Y := AY;
end;

// Сложение двух точек (как векторов)
function AddPoints(const A, B: TPointF): TPointF;
begin
  Result.X := A.X + B.X;
  Result.Y := A.Y + B.Y;
end;

// Вычитание точек (как векторов)
function SubtractPoints(const A, B: TPointF): TPointF;
begin
  Result.X := A.X - B.X;
  Result.Y := A.Y - B.Y;
end;

// Умножение точки на скаляр
function ScalePoint(const P: TPointF; Factor: Double): TPointF;
begin
  Result.X := P.X * Factor;
  Result.Y := P.Y * Factor;
end;

// Вычислить расстояние между двумя точками
function DistancePoints(const A, B: TPointF): Double;
var
  DX, DY: Double;
begin
  DX := B.X - A.X;
  DY := B.Y - A.Y;
  Result := Sqrt(DX * DX + DY * DY);
end;

// Проверить, являются ли координаты точки валидными
function IsValidPoint(const P: TPointF): Boolean;
begin
  Result := (not IsNaN(P.X)) and (not IsNaN(P.Y)) and
            (not IsInfinite(P.X)) and (not IsInfinite(P.Y));
end;

// Создать пустой сегмент Безье
function CreateEmptyBezierSegment: TUzvBezierSegment;
begin
  Result.P0 := MakePointF(0.0, 0.0);
  Result.P1 := MakePointF(0.0, 0.0);
  Result.P2 := MakePointF(0.0, 0.0);
  Result.P3 := MakePointF(0.0, 0.0);
end;

// Создать сегмент Безье для прямой линии
// Для прямой линии контрольные точки располагаются на 1/3 и 2/3 длины
// For straight line, control points are placed at 1/3 and 2/3 of length
function CreateLineBezierSegment(const Start, Finish: TPointF): TUzvBezierSegment;
var
  DX, DY: Double;
begin
  Result.P0 := Start;
  Result.P3 := Finish;

  // Контрольные точки на 1/3 и 2/3 отрезка
  // Control points at 1/3 and 2/3 of segment
  DX := (Finish.X - Start.X) / 3.0;
  DY := (Finish.Y - Start.Y) / 3.0;

  Result.P1 := MakePointF(Start.X + DX, Start.Y + DY);
  Result.P2 := MakePointF(Finish.X - DX, Finish.Y - DY);
end;

// Создать пустой путь Безье
function CreateEmptyBezierPath: TUzvBezierPath;
begin
  SetLength(Result.Segments, 0);
  Result.IsClosed := False;
end;

// Создать пустой глиф Безье
function CreateEmptyBezierGlyph(ACode: Integer): TUzvBezierGlyph;
begin
  Result.Code := ACode;
  Result.Width := 0.0;
  SetLength(Result.Paths, 0);
end;

// Создать пустой шрифт Безье
function CreateEmptyBezierFont: TUzvBezierFont;
begin
  Result.FontName := '';
  SetLength(Result.Glyphs, 0);
end;

// Получить параметры обводки по умолчанию
function GetDefaultStrokeParams: TUzvStrokeParams;
begin
  Result.LineWidth := 1.0;
  Result.LineJoin := ljMiter;
  Result.LineCap := lcButt;
  Result.MiterLimit := 10.0;  // Стандартное значение PDF / Standard PDF value
end;

end.
