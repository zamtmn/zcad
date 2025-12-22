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
  Модуль: uzvshxtopdfcharprocswriter
  Назначение: Генерация PDF path stream для CharProcs

  Данный модуль предоставляет функции для преобразования
  геометрии глифов (кривые Безье) в PDF path stream.

  Поддерживаемые PDF-операторы:
  - m : moveTo - перемещение без рисования
  - l : lineTo - линия до точки
  - c : curveTo - кубическая кривая Безье
  - h : closePath - замыкание контура
  - S : stroke - обводка
  - f : fill - заливка
  - q : gsave - сохранение состояния
  - Q : grestore - восстановление состояния

  Выбранный подход: прямая запись трансформированных координат
  (координаты уже в мировой системе после Этапа 3)

  Зависимости:
  - uzvshxtopdfcharprocstypes: типы данных этапа 4
  - uzvshxtopdfcharprocsbbox: расчёт bounding box
  - uzvshxtopdfapprogeomtypes: базовые геометрические типы
  - uzvshxtopdftransformtypes: типы данных этапа 3

  Module: uzvshxtopdfcharprocswriter
  Purpose: PDF path stream generation for CharProcs

  This module provides functions for converting
  glyph geometry (Bezier curves) to PDF path stream.

  Supported PDF operators:
  - m : moveTo - move without drawing
  - l : lineTo - line to point
  - c : curveTo - cubic Bezier curve
  - h : closePath - close path
  - S : stroke - stroke the path
  - f : fill - fill the path
  - q : gsave - save graphics state
  - Q : grestore - restore graphics state

  Chosen approach: direct writing of transformed coordinates
  (coordinates are already in world system after Stage 3)

  Dependencies:
  - uzvshxtopdfcharprocstypes: Stage 4 data types
  - uzvshxtopdfcharprocsbbox: bounding box calculation
  - uzvshxtopdfapprogeomtypes: basic geometry types
  - uzvshxtopdftransformtypes: Stage 3 data types
}

unit uzvshxtopdfcharprocswriter;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Math,
  uzvshxtopdfapprogeomtypes,
  uzvshxtopdftransformtypes,
  uzvshxtopdfcharprocstypes,
  uzvshxtopdfcharprocsbbox;

// Сгенерировать PDF path stream для одного глифа
// Generate PDF path stream for single glyph
function GenerateGlyphStream(
  const Glyph: TUzvWorldBezierGlyph;
  const Params: TUzvCharProcsParams
): AnsiString;

// Сгенерировать PDF path stream для пути (контура)
// Generate PDF path stream for path (contour)
function GeneratePathStream(
  const Path: TUzvBezierPath;
  Precision: Integer
): AnsiString;

// Сгенерировать PDF path stream для сегмента Безье
// Generate PDF path stream for Bezier segment
function GenerateSegmentStream(
  const Seg: TUzvBezierSegment;
  IsFirst: Boolean;
  Precision: Integer
): AnsiString;

// Создать CharProc для глифа
// Create CharProc for glyph
function CreateCharProc(
  const Glyph: TUzvWorldBezierGlyph;
  GlyphWidth: Double;
  const Params: TUzvCharProcsParams
): TUzvPdfCharProc;

// Форматировать число с заданной точностью для PDF
// Format number with specified precision for PDF
function FormatPdfNumber(Value: Double; Precision: Integer): AnsiString;

implementation

const
  // Символ новой строки для PDF-стрима
  // Newline character for PDF stream
  PDF_NEWLINE = #10;

  // PDF-операторы
  // PDF operators
  PDF_OP_MOVETO = 'm';
  PDF_OP_LINETO = 'l';
  PDF_OP_CURVETO = 'c';
  PDF_OP_CLOSEPATH = 'h';
  PDF_OP_STROKE = 'S';
  PDF_OP_FILL = 'f';
  PDF_OP_GSAVE = 'q';
  PDF_OP_GRESTORE = 'Q';

  // Порог для определения, является ли сегмент прямой линией
  // Threshold for detecting if segment is a straight line
  LINE_THRESHOLD = 1e-6;

// Форматировать число с заданной точностью для PDF
function FormatPdfNumber(Value: Double; Precision: Integer): AnsiString;
var
  FormatStr: string;
begin
  // Проверка на NaN и Infinity
  // Check for NaN and Infinity
  if IsNaN(Value) or IsInfinite(Value) then
  begin
    Result := '0';
    Exit;
  end;

  // Формируем строку формата
  // Build format string
  FormatStr := '%.' + IntToStr(Precision) + 'f';
  Result := AnsiString(Format(FormatStr, [Value]));

  // Удаляем лишние нули после запятой
  // Remove trailing zeros after decimal point
  while (Length(Result) > 1) and (Result[Length(Result)] = '0') and
        (Pos('.', string(Result)) > 0) do
  begin
    Delete(Result, Length(Result), 1);
  end;

  // Удаляем точку, если после неё ничего не осталось
  // Remove decimal point if nothing left after it
  if (Length(Result) > 0) and (Result[Length(Result)] = '.') then
    Delete(Result, Length(Result), 1);

  // Заменяем "-0" на "0"
  // Replace "-0" with "0"
  if Result = '-0' then
    Result := '0';
end;

// Проверить, является ли сегмент прямой линией
// Check if segment is a straight line
function IsLineSegment(const Seg: TUzvBezierSegment): Boolean;
var
  DX, DY: Double;
  Len: Double;
  D1X, D1Y, D2X, D2Y: Double;
  Dist1, Dist2: Double;
begin
  Result := False;

  // Вычисляем направление от P0 к P3
  // Calculate direction from P0 to P3
  DX := Seg.P3.X - Seg.P0.X;
  DY := Seg.P3.Y - Seg.P0.Y;
  Len := Sqrt(DX * DX + DY * DY);

  if Len < LINE_THRESHOLD then
  begin
    // Вырожденный сегмент (точка)
    // Degenerate segment (point)
    Result := True;
    Exit;
  end;

  // Нормализуем направление
  // Normalize direction
  DX := DX / Len;
  DY := DY / Len;

  // Вычисляем расстояния от P1 и P2 до прямой P0-P3
  // Calculate distances from P1 and P2 to line P0-P3
  D1X := Seg.P1.X - Seg.P0.X;
  D1Y := Seg.P1.Y - Seg.P0.Y;
  Dist1 := Abs(D1X * (-DY) + D1Y * DX);

  D2X := Seg.P2.X - Seg.P0.X;
  D2Y := Seg.P2.Y - Seg.P0.Y;
  Dist2 := Abs(D2X * (-DY) + D2Y * DX);

  // Если оба расстояния малы, это прямая линия
  // If both distances are small, it's a straight line
  Result := (Dist1 < LINE_THRESHOLD) and (Dist2 < LINE_THRESHOLD);
end;

// Сгенерировать PDF path stream для сегмента Безье
function GenerateSegmentStream(
  const Seg: TUzvBezierSegment;
  IsFirst: Boolean;
  Precision: Integer
): AnsiString;
var
  SB: AnsiString;
begin
  SB := '';

  // Если это первый сегмент, добавляем moveTo
  // If this is first segment, add moveTo
  if IsFirst then
  begin
    SB := SB + FormatPdfNumber(Seg.P0.X, Precision) + ' ';
    SB := SB + FormatPdfNumber(Seg.P0.Y, Precision) + ' ';
    SB := SB + PDF_OP_MOVETO + PDF_NEWLINE;
  end;

  // Проверяем, является ли сегмент прямой линией
  // Check if segment is a straight line
  if IsLineSegment(Seg) then
  begin
    // Используем lineTo (l) для прямых линий - более компактно
    // Use lineTo (l) for straight lines - more compact
    SB := SB + FormatPdfNumber(Seg.P3.X, Precision) + ' ';
    SB := SB + FormatPdfNumber(Seg.P3.Y, Precision) + ' ';
    SB := SB + PDF_OP_LINETO + PDF_NEWLINE;
  end
  else
  begin
    // Используем curveTo (c) для кривых Безье
    // Use curveTo (c) for Bezier curves
    SB := SB + FormatPdfNumber(Seg.P1.X, Precision) + ' ';
    SB := SB + FormatPdfNumber(Seg.P1.Y, Precision) + ' ';
    SB := SB + FormatPdfNumber(Seg.P2.X, Precision) + ' ';
    SB := SB + FormatPdfNumber(Seg.P2.Y, Precision) + ' ';
    SB := SB + FormatPdfNumber(Seg.P3.X, Precision) + ' ';
    SB := SB + FormatPdfNumber(Seg.P3.Y, Precision) + ' ';
    SB := SB + PDF_OP_CURVETO + PDF_NEWLINE;
  end;

  Result := SB;
end;

// Сгенерировать PDF path stream для пути (контура)
function GeneratePathStream(
  const Path: TUzvBezierPath;
  Precision: Integer
): AnsiString;
var
  SB: AnsiString;
  I: Integer;
  IsFirst: Boolean;
begin
  SB := '';

  // Проходим по всем сегментам
  // Iterate through all segments
  for I := 0 to High(Path.Segments) do
  begin
    IsFirst := (I = 0);
    SB := SB + GenerateSegmentStream(Path.Segments[I], IsFirst, Precision);
  end;

  // Если контур замкнут, добавляем closePath
  // If path is closed, add closePath
  if Path.IsClosed and (Length(Path.Segments) > 0) then
    SB := SB + PDF_OP_CLOSEPATH + PDF_NEWLINE;

  Result := SB;
end;

// Сгенерировать PDF path stream для одного глифа
function GenerateGlyphStream(
  const Glyph: TUzvWorldBezierGlyph;
  const Params: TUzvCharProcsParams
): AnsiString;
var
  SB: AnsiString;
  I: Integer;
  RenderOp: AnsiString;
begin
  SB := '';

  // Сохранение графического состояния (если требуется)
  // Save graphics state (if required)
  if Params.WrapWithGraphicsState then
    SB := SB + PDF_OP_GSAVE + PDF_NEWLINE;

  // Генерируем пути для всех контуров глифа
  // Generate paths for all glyph contours
  for I := 0 to High(Glyph.Paths) do
    SB := SB + GeneratePathStream(Glyph.Paths[I], Params.CoordPrecision);

  // Оператор отрисовки
  // Rendering operator
  if Params.UseStroke then
    RenderOp := PDF_OP_STROKE
  else
    RenderOp := PDF_OP_FILL;

  // Добавляем оператор отрисовки только если есть пути
  // Add rendering operator only if there are paths
  if Length(Glyph.Paths) > 0 then
    SB := SB + RenderOp + PDF_NEWLINE;

  // Восстановление графического состояния (если требуется)
  // Restore graphics state (if required)
  if Params.WrapWithGraphicsState then
    SB := SB + PDF_OP_GRESTORE + PDF_NEWLINE;

  Result := SB;
end;

// Создать CharProc для глифа
function CreateCharProc(
  const Glyph: TUzvWorldBezierGlyph;
  GlyphWidth: Double;
  const Params: TUzvCharProcsParams
): TUzvPdfCharProc;
begin
  Result.CharCode := Glyph.Code;
  Result.CharName := MakeCharName(Glyph.Code);
  Result.Stream := GenerateGlyphStream(Glyph, Params);
  Result.Width := GlyphWidth;
  Result.BBox := CalcGlyphBBox(Glyph);
end;

end.
