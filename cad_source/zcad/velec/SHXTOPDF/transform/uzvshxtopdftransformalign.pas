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
  Модуль: uzvshxtopdftransformalign
  Назначение: Вычисление смещений для выравнивания текста

  Данный модуль вычисляет смещения для различных режимов выравнивания:
  - Горизонтальное: Left, Center, Right
  - Вертикальное: Top, Baseline, Bottom

  Выравнивание производится по bounding-box всего текста.

  Module: uzvshxtopdftransformalign
  Purpose: Calculate offsets for text alignment

  This module calculates offsets for various alignment modes:
  - Horizontal: Left, Center, Right
  - Vertical: Top, Baseline, Bottom

  Alignment is performed based on the bounding box of the entire text.
}

unit uzvshxtopdftransformalign;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Math,
  uzvshxtopdfapprogeomtypes,
  uzvshxtopdftransformtypes,
  uzclog;

// Вычислить смещение для горизонтального выравнивания
// Calculate offset for horizontal alignment
//
// Параметры:
//   BBox - bounding box текста (уже трансформированного)
//   Alignment - тип выравнивания
//
// Возвращает смещение по X, которое нужно добавить к координатам
// Returns X offset that should be added to coordinates
function CalculateHorizontalAlignmentOffset(
  const BBox: TUzvBoundingBox;
  Alignment: TUzvAlignmentH
): Double;

// Вычислить смещение для вертикального выравнивания
// Calculate offset for vertical alignment
//
// Параметры:
//   BBox - bounding box текста (уже трансформированного)
//   Alignment - тип выравнивания
//   BaselineY - позиция базовой линии (обычно 0)
//
// Возвращает смещение по Y, которое нужно добавить к координатам
// Returns Y offset that should be added to coordinates
function CalculateVerticalAlignmentOffset(
  const BBox: TUzvBoundingBox;
  Alignment: TUzvAlignmentV;
  BaselineY: Double
): Double;

// Вычислить полное смещение для выравнивания
// Calculate full alignment offset
//
// Возвращает точку смещения (dX, dY)
// Returns offset point (dX, dY)
function CalculateAlignmentOffset(
  const BBox: TUzvBoundingBox;
  AlignH: TUzvAlignmentH;
  AlignV: TUzvAlignmentV;
  BaselineY: Double
): TPointF;

// Вычислить общую ширину текста с учётом кернинга
// Calculate total text width with kerning
//
// Параметры:
//   GlyphWidths - массив ширин глифов (advance widths)
//   Kerning - дополнительный межсимвольный интервал
//   ScaleFactor - масштаб (Height / UnitsPerEm * WidthFactor)
//
// Возвращает общую ширину текста
// Returns total text width
function CalculateTotalTextWidth(
  const GlyphWidths: array of Double;
  Kerning: Double;
  ScaleFactor: Double
): Double;

// Вычислить позицию глифа по индексу (с учётом кернинга)
// Calculate glyph position by index (with kerning)
//
// Параметры:
//   GlyphWidths - массив ширин глифов
//   GlyphIndex - индекс глифа (0-based)
//   Kerning - дополнительный межсимвольный интервал
//   ScaleFactor - масштаб
//
// Возвращает X-позицию начала глифа
// Returns X position of glyph start
function CalculateGlyphXPosition(
  const GlyphWidths: array of Double;
  GlyphIndex: Integer;
  Kerning: Double;
  ScaleFactor: Double
): Double;

implementation

// Вычислить смещение для горизонтального выравнивания
function CalculateHorizontalAlignmentOffset(
  const BBox: TUzvBoundingBox;
  Alignment: TUzvAlignmentH
): Double;
var
  TextWidth: Double;
begin
  // Проверка на пустой bounding box
  // Check for empty bounding box
  if IsBoundingBoxEmpty(BBox) then
  begin
    Result := 0.0;
    Exit;
  end;

  TextWidth := GetBoundingBoxWidth(BBox);

  case Alignment of
    alLeft:
      begin
        // Выравнивание по левому краю - сдвигаем текст так,
        // чтобы левая граница была в начале координат
        // Left alignment - shift text so left edge is at origin
        Result := -BBox.MinX;
      end;

    alCenter:
      begin
        // Выравнивание по центру - центр текста в начале координат
        // Center alignment - text center at origin
        Result := -(BBox.MinX + TextWidth / 2.0);
      end;

    alRight:
      begin
        // Выравнивание по правому краю - правая граница в начале координат
        // Right alignment - right edge at origin
        Result := -BBox.MaxX;
      end;

    else
      Result := 0.0;
  end;
end;

// Вычислить смещение для вертикального выравнивания
function CalculateVerticalAlignmentOffset(
  const BBox: TUzvBoundingBox;
  Alignment: TUzvAlignmentV;
  BaselineY: Double
): Double;
var
  TextHeight: Double;
begin
  // Проверка на пустой bounding box
  // Check for empty bounding box
  if IsBoundingBoxEmpty(BBox) then
  begin
    Result := 0.0;
    Exit;
  end;

  TextHeight := GetBoundingBoxHeight(BBox);

  case Alignment of
    alTop:
      begin
        // Выравнивание по верхнему краю - верхняя граница в начале координат
        // Top alignment - top edge at origin
        Result := -BBox.MaxY;
      end;

    alBaseline:
      begin
        // Выравнивание по базовой линии - базовая линия в начале координат
        // Baseline alignment - baseline at origin
        Result := -BaselineY;
      end;

    alBottom:
      begin
        // Выравнивание по нижнему краю - нижняя граница в начале координат
        // Bottom alignment - bottom edge at origin
        Result := -BBox.MinY;
      end;

    else
      Result := 0.0;
  end;
end;

// Вычислить полное смещение для выравнивания
function CalculateAlignmentOffset(
  const BBox: TUzvBoundingBox;
  AlignH: TUzvAlignmentH;
  AlignV: TUzvAlignmentV;
  BaselineY: Double
): TPointF;
begin
  Result.X := CalculateHorizontalAlignmentOffset(BBox, AlignH);
  Result.Y := CalculateVerticalAlignmentOffset(BBox, AlignV, BaselineY);
end;

// Вычислить общую ширину текста с учётом кернинга
function CalculateTotalTextWidth(
  const GlyphWidths: array of Double;
  Kerning: Double;
  ScaleFactor: Double
): Double;
var
  i: Integer;
  TotalWidth: Double;
  GlyphCount: Integer;
begin
  GlyphCount := Length(GlyphWidths);

  if GlyphCount = 0 then
  begin
    Result := 0.0;
    Exit;
  end;

  TotalWidth := 0.0;

  // Суммируем ширины всех глифов
  // Sum all glyph widths
  for i := 0 to GlyphCount - 1 do
  begin
    TotalWidth := TotalWidth + GlyphWidths[i];
  end;

  // Добавляем кернинг между глифами (N-1 интервалов для N глифов)
  // Add kerning between glyphs (N-1 intervals for N glyphs)
  if GlyphCount > 1 then
  begin
    TotalWidth := TotalWidth + Kerning * (GlyphCount - 1);
  end;

  // Применяем масштаб
  // Apply scale
  Result := TotalWidth * ScaleFactor;
end;

// Вычислить позицию глифа по индексу
function CalculateGlyphXPosition(
  const GlyphWidths: array of Double;
  GlyphIndex: Integer;
  Kerning: Double;
  ScaleFactor: Double
): Double;
var
  i: Integer;
  Position: Double;
begin
  // Проверка границ
  // Bounds check
  if (GlyphIndex < 0) or (GlyphIndex > High(GlyphWidths)) then
  begin
    Result := 0.0;
    Exit;
  end;

  Position := 0.0;

  // Суммируем ширины всех предыдущих глифов
  // Sum widths of all previous glyphs
  for i := 0 to GlyphIndex - 1 do
  begin
    Position := Position + GlyphWidths[i];
    // Добавляем кернинг после каждого глифа (кроме последнего)
    // Add kerning after each glyph (except last)
    Position := Position + Kerning;
  end;

  // Применяем масштаб
  // Apply scale
  Result := Position * ScaleFactor;
end;

end.
