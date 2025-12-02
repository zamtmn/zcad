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
  Модуль: uzvshxtopdftransformapply
  Назначение: Применение матриц трансформации к кривым Безье

  Данный модуль содержит функции для применения матрицы трансформации
  к различным элементам геометрии:
  - Точки
  - Сегменты Безье
  - Пути Безье
  - Глифы
  - Шрифты

  Module: uzvshxtopdftransformapply
  Purpose: Apply transformation matrices to Bezier curves

  This module contains functions to apply transformation matrix
  to various geometry elements:
  - Points
  - Bezier segments
  - Bezier paths
  - Glyphs
  - Fonts
}

unit uzvshxtopdftransformapply;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Math,
  uzvshxtopdfapprogeomtypes,
  uzvshxtopdftransformtypes,
  uzvshxtopdftransformmatrix,
  uzclog;

// Применить матрицу к сегменту Безье
// Apply matrix to Bezier segment
//
// Трансформирует все 4 точки сегмента (P0, P1, P2, P3)
// Transforms all 4 points of segment (P0, P1, P2, P3)
function ApplyMatrixToSegment(
  const M: TUzvMatrix3x3;
  const Segment: TUzvBezierSegment
): TUzvBezierSegment;

// Применить матрицу к пути Безье
// Apply matrix to Bezier path
//
// Трансформирует все сегменты пути
// Transforms all segments in path
function ApplyMatrixToPath(
  const M: TUzvMatrix3x3;
  const Path: TUzvBezierPath
): TUzvBezierPath;

// Применить матрицу к глифу Безье
// Apply matrix to Bezier glyph
//
// Трансформирует все пути глифа
// Transforms all paths of glyph
function ApplyMatrixToGlyph(
  const M: TUzvMatrix3x3;
  const Glyph: TUzvBezierGlyph
): TUzvBezierGlyph;

// Применить матрицу к шрифту Безье
// Apply matrix to Bezier font
//
// Трансформирует все глифы шрифта
// Transforms all glyphs of font
function ApplyMatrixToFont(
  const M: TUzvMatrix3x3;
  const Font: TUzvBezierFont
): TUzvBezierFont;

// Вычислить bounding box сегмента Безье
// Calculate bounding box of Bezier segment
//
// Использует контрольные точки для приблизительного bounding box
// Uses control points for approximate bounding box
function CalculateSegmentBoundingBox(
  const Segment: TUzvBezierSegment
): TUzvBoundingBox;

// Вычислить bounding box пути Безье
// Calculate bounding box of Bezier path
function CalculatePathBoundingBox(
  const Path: TUzvBezierPath
): TUzvBoundingBox;

// Вычислить bounding box глифа
// Calculate bounding box of glyph
function CalculateGlyphBoundingBox(
  const Glyph: TUzvBezierGlyph
): TUzvBoundingBox;

// Вычислить bounding box шрифта
// Calculate bounding box of font
function CalculateFontBoundingBox(
  const Font: TUzvBezierFont
): TUzvBoundingBox;

// Вычислить bounding box массива глифов в мировых координатах
// Calculate bounding box of world glyph array
function CalculateWorldGlyphsBoundingBox(
  const Glyphs: array of TUzvWorldBezierGlyph
): TUzvBoundingBox;

// Преобразовать глиф Безье в глиф мировых координат
// Convert Bezier glyph to world coordinates glyph
function ConvertToWorldGlyph(
  const Glyph: TUzvBezierGlyph
): TUzvWorldBezierGlyph;

implementation

// Применить матрицу к сегменту Безье
function ApplyMatrixToSegment(
  const M: TUzvMatrix3x3;
  const Segment: TUzvBezierSegment
): TUzvBezierSegment;
begin
  Result.P0 := ApplyMatrixToPoint(M, Segment.P0);
  Result.P1 := ApplyMatrixToPoint(M, Segment.P1);
  Result.P2 := ApplyMatrixToPoint(M, Segment.P2);
  Result.P3 := ApplyMatrixToPoint(M, Segment.P3);
end;

// Применить матрицу к пути Безье
function ApplyMatrixToPath(
  const M: TUzvMatrix3x3;
  const Path: TUzvBezierPath
): TUzvBezierPath;
var
  i: Integer;
begin
  SetLength(Result.Segments, Length(Path.Segments));
  Result.IsClosed := Path.IsClosed;

  for i := 0 to High(Path.Segments) do
  begin
    Result.Segments[i] := ApplyMatrixToSegment(M, Path.Segments[i]);
  end;
end;

// Применить матрицу к глифу Безье
function ApplyMatrixToGlyph(
  const M: TUzvMatrix3x3;
  const Glyph: TUzvBezierGlyph
): TUzvBezierGlyph;
var
  i: Integer;
begin
  Result.Code := Glyph.Code;
  Result.Width := Glyph.Width;  // Width остаётся как есть / Width stays as is
  SetLength(Result.Paths, Length(Glyph.Paths));

  for i := 0 to High(Glyph.Paths) do
  begin
    Result.Paths[i] := ApplyMatrixToPath(M, Glyph.Paths[i]);
  end;
end;

// Применить матрицу к шрифту Безье
function ApplyMatrixToFont(
  const M: TUzvMatrix3x3;
  const Font: TUzvBezierFont
): TUzvBezierFont;
var
  i: Integer;
begin
  Result.FontName := Font.FontName;
  SetLength(Result.Glyphs, Length(Font.Glyphs));

  for i := 0 to High(Font.Glyphs) do
  begin
    Result.Glyphs[i] := ApplyMatrixToGlyph(M, Font.Glyphs[i]);
  end;
end;

// Вычислить bounding box сегмента Безье
// Примечание: для точного bounding box нужно анализировать кривую,
// но для большинства случаев достаточно использовать контрольные точки
// Note: for exact bounding box need to analyze curve,
// but for most cases using control points is sufficient
function CalculateSegmentBoundingBox(
  const Segment: TUzvBezierSegment
): TUzvBoundingBox;
begin
  Result := CreateEmptyBoundingBox;

  // Расширяем bounding box всеми 4 точками
  // Expand bounding box with all 4 points
  Result := ExpandBoundingBox(Result, Segment.P0);
  Result := ExpandBoundingBox(Result, Segment.P1);
  Result := ExpandBoundingBox(Result, Segment.P2);
  Result := ExpandBoundingBox(Result, Segment.P3);
end;

// Вычислить bounding box пути Безье
function CalculatePathBoundingBox(
  const Path: TUzvBezierPath
): TUzvBoundingBox;
var
  i: Integer;
  SegBox: TUzvBoundingBox;
begin
  Result := CreateEmptyBoundingBox;

  for i := 0 to High(Path.Segments) do
  begin
    SegBox := CalculateSegmentBoundingBox(Path.Segments[i]);
    Result := MergeBoundingBoxes(Result, SegBox);
  end;
end;

// Вычислить bounding box глифа
function CalculateGlyphBoundingBox(
  const Glyph: TUzvBezierGlyph
): TUzvBoundingBox;
var
  i: Integer;
  PathBox: TUzvBoundingBox;
begin
  Result := CreateEmptyBoundingBox;

  for i := 0 to High(Glyph.Paths) do
  begin
    PathBox := CalculatePathBoundingBox(Glyph.Paths[i]);
    Result := MergeBoundingBoxes(Result, PathBox);
  end;
end;

// Вычислить bounding box шрифта
function CalculateFontBoundingBox(
  const Font: TUzvBezierFont
): TUzvBoundingBox;
var
  i: Integer;
  GlyphBox: TUzvBoundingBox;
begin
  Result := CreateEmptyBoundingBox;

  for i := 0 to High(Font.Glyphs) do
  begin
    GlyphBox := CalculateGlyphBoundingBox(Font.Glyphs[i]);
    Result := MergeBoundingBoxes(Result, GlyphBox);
  end;
end;

// Вычислить bounding box массива глифов в мировых координатах
function CalculateWorldGlyphsBoundingBox(
  const Glyphs: array of TUzvWorldBezierGlyph
): TUzvBoundingBox;
var
  i, j: Integer;
  PathBox: TUzvBoundingBox;
begin
  Result := CreateEmptyBoundingBox;

  for i := 0 to High(Glyphs) do
  begin
    for j := 0 to High(Glyphs[i].Paths) do
    begin
      PathBox := CalculatePathBoundingBox(Glyphs[i].Paths[j]);
      Result := MergeBoundingBoxes(Result, PathBox);
    end;
  end;
end;

// Преобразовать глиф Безье в глиф мировых координат
function ConvertToWorldGlyph(
  const Glyph: TUzvBezierGlyph
): TUzvWorldBezierGlyph;
var
  i: Integer;
begin
  Result.Code := Glyph.Code;
  SetLength(Result.Paths, Length(Glyph.Paths));

  for i := 0 to High(Glyph.Paths) do
  begin
    // Копируем пути напрямую (координаты уже мировые)
    // Copy paths directly (coordinates are already world)
    Result.Paths[i] := Glyph.Paths[i];
  end;
end;

end.
