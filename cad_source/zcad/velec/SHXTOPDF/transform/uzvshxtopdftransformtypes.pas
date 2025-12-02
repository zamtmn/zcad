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
  Модуль: uzvshxtopdftransformtypes
  Назначение: Типы данных для этапа 3 конвейера SHX -> PDF (Трансформации)

  Данный модуль содержит структуры данных для представления:
  - Параметров трансформации текста из CAD-системы
  - Выходных структур с мировыми координатами
  - Типов выравнивания текста

  Module: uzvshxtopdftransformtypes
  Purpose: Data types for Stage 3 of SHX -> PDF pipeline (Transformations)

  This module contains data structures for representing:
  - Text transformation parameters from CAD system
  - Output structures with world coordinates
  - Text alignment types
}

unit uzvshxtopdftransformtypes;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Math,
  uzvshxtopdfapprogeomtypes;

type
  // Горизонтальное выравнивание текста
  // Horizontal text alignment
  TUzvAlignmentH = (
    alLeft,    // По левому краю / Left alignment
    alCenter,  // По центру / Center alignment
    alRight    // По правому краю / Right alignment
  );

  // Вертикальное выравнивание текста
  // Vertical text alignment
  TUzvAlignmentV = (
    alTop,      // По верхнему краю / Top alignment
    alBaseline, // По базовой линии / Baseline alignment
    alBottom    // По нижнему краю / Bottom alignment
  );

  // Параметры трансформации текста из CAD-системы
  // Text transformation parameters from CAD system
  //
  // Порядок применения трансформаций (строго фиксированный):
  // Transformation order (strictly fixed):
  //   1. Нормализация по UnitsPerEm / Normalization by UnitsPerEm
  //   2. Масштаб по Height / Scale by Height
  //   3. Масштаб по WidthFactor / Scale by WidthFactor
  //   4. Oblique (shear) / Oblique (shear)
  //   5. Зеркалирование / Mirroring
  //   6. Поворот / Rotation
  //   7. Выравнивание / Alignment
  //   8. Перенос в BasePoint / Translate to BasePoint
  //   9. Кернинг / Kerning
  TUzvTextTransform = record
    Height: Double;           // Высота текста / Text height
    WidthFactor: Double;      // Коэффициент ширины / Width factor
    UnitsPerEm: Double;       // Единицы SHX/EM / SHX/EM units
    ObliqueDeg: Double;       // Наклон в градусах / Oblique angle in degrees
    RotationDeg: Double;      // Поворот в градусах / Rotation angle in degrees
    MirrorX: Boolean;         // Зеркалирование по X / Mirror on X axis
    MirrorY: Boolean;         // Зеркалирование по Y / Mirror on Y axis
    BasePoint: TPointF;       // Базовая точка вставки / Base insertion point
    Kerning: Double;          // Межсимвольный интервал / Character spacing
    AlignmentH: TUzvAlignmentH; // Горизонтальное выравнивание
    AlignmentV: TUzvAlignmentV; // Вертикальное выравнивание
  end;

  // Глиф в мировых координатах (результат трансформации)
  // Glyph in world coordinates (transformation result)
  TUzvWorldBezierGlyph = record
    Code: Integer;                    // Код символа / Character code
    Paths: array of TUzvBezierPath;   // Пути в мировых координатах
                                      // Paths in world coordinates
  end;

  // Шрифт в мировых координатах - результат этапа 3
  // Font in world coordinates - Stage 3 result
  TUzvWorldBezierFont = record
    Glyphs: array of TUzvWorldBezierGlyph;  // Массив глифов / Glyphs array
  end;

  // Ограничивающий прямоугольник (bounding box)
  // Bounding box
  TUzvBoundingBox = record
    MinX, MinY: Double;  // Минимальные координаты / Minimum coordinates
    MaxX, MaxY: Double;  // Максимальные координаты / Maximum coordinates
  end;

// Создать параметры трансформации по умолчанию
// Create default transformation parameters
function CreateDefaultTextTransform: TUzvTextTransform;

// Создать пустой глиф в мировых координатах
// Create empty world glyph
function CreateEmptyWorldBezierGlyph(ACode: Integer): TUzvWorldBezierGlyph;

// Создать пустой шрифт в мировых координатах
// Create empty world font
function CreateEmptyWorldBezierFont: TUzvWorldBezierFont;

// Создать пустой bounding box
// Create empty bounding box
function CreateEmptyBoundingBox: TUzvBoundingBox;

// Проверить валидность параметров трансформации
// Validate transformation parameters
function ValidateTextTransform(const Transform: TUzvTextTransform): Boolean;

// Проверить, является ли bounding box пустым
// Check if bounding box is empty
function IsBoundingBoxEmpty(const Box: TUzvBoundingBox): Boolean;

// Получить ширину bounding box
// Get bounding box width
function GetBoundingBoxWidth(const Box: TUzvBoundingBox): Double;

// Получить высоту bounding box
// Get bounding box height
function GetBoundingBoxHeight(const Box: TUzvBoundingBox): Double;

// Объединить два bounding box
// Merge two bounding boxes
function MergeBoundingBoxes(
  const Box1, Box2: TUzvBoundingBox
): TUzvBoundingBox;

// Расширить bounding box точкой
// Expand bounding box with point
function ExpandBoundingBox(
  const Box: TUzvBoundingBox;
  const P: TPointF
): TUzvBoundingBox;

implementation

// Создать параметры трансформации по умолчанию
function CreateDefaultTextTransform: TUzvTextTransform;
begin
  Result.Height := 1.0;
  Result.WidthFactor := 1.0;
  Result.UnitsPerEm := 1.0;
  Result.ObliqueDeg := 0.0;
  Result.RotationDeg := 0.0;
  Result.MirrorX := False;
  Result.MirrorY := False;
  Result.BasePoint := MakePointF(0.0, 0.0);
  Result.Kerning := 0.0;
  Result.AlignmentH := alLeft;
  Result.AlignmentV := alBaseline;
end;

// Создать пустой глиф в мировых координатах
function CreateEmptyWorldBezierGlyph(ACode: Integer): TUzvWorldBezierGlyph;
begin
  Result.Code := ACode;
  SetLength(Result.Paths, 0);
end;

// Создать пустой шрифт в мировых координатах
function CreateEmptyWorldBezierFont: TUzvWorldBezierFont;
begin
  SetLength(Result.Glyphs, 0);
end;

// Создать пустой bounding box
function CreateEmptyBoundingBox: TUzvBoundingBox;
begin
  // Используем "инвертированный" box для удобства расширения
  // Use "inverted" box for convenient expansion
  Result.MinX := MaxDouble;
  Result.MinY := MaxDouble;
  Result.MaxX := -MaxDouble;
  Result.MaxY := -MaxDouble;
end;

// Проверить валидность параметров трансформации
function ValidateTextTransform(const Transform: TUzvTextTransform): Boolean;
begin
  Result := True;

  // Проверка Height - должна быть положительной
  // Height validation - must be positive
  if (Transform.Height <= 0) or
     IsNaN(Transform.Height) or
     IsInfinite(Transform.Height) then
  begin
    Result := False;
    Exit;
  end;

  // Проверка WidthFactor - должен быть положительным
  // WidthFactor validation - must be positive
  if (Transform.WidthFactor <= 0) or
     IsNaN(Transform.WidthFactor) or
     IsInfinite(Transform.WidthFactor) then
  begin
    Result := False;
    Exit;
  end;

  // Проверка UnitsPerEm - должен быть положительным
  // UnitsPerEm validation - must be positive
  if (Transform.UnitsPerEm <= 0) or
     IsNaN(Transform.UnitsPerEm) or
     IsInfinite(Transform.UnitsPerEm) then
  begin
    Result := False;
    Exit;
  end;

  // Проверка углов - не должны быть NaN или Infinity
  // Angle validation - must not be NaN or Infinity
  if IsNaN(Transform.ObliqueDeg) or IsInfinite(Transform.ObliqueDeg) then
  begin
    Result := False;
    Exit;
  end;

  if IsNaN(Transform.RotationDeg) or IsInfinite(Transform.RotationDeg) then
  begin
    Result := False;
    Exit;
  end;

  // Проверка BasePoint
  // BasePoint validation
  if not IsValidPoint(Transform.BasePoint) then
  begin
    Result := False;
    Exit;
  end;

  // Проверка Kerning
  // Kerning validation
  if IsNaN(Transform.Kerning) or IsInfinite(Transform.Kerning) then
  begin
    Result := False;
    Exit;
  end;
end;

// Проверить, является ли bounding box пустым
function IsBoundingBoxEmpty(const Box: TUzvBoundingBox): Boolean;
begin
  Result := (Box.MinX > Box.MaxX) or (Box.MinY > Box.MaxY);
end;

// Получить ширину bounding box
function GetBoundingBoxWidth(const Box: TUzvBoundingBox): Double;
begin
  if IsBoundingBoxEmpty(Box) then
    Result := 0.0
  else
    Result := Box.MaxX - Box.MinX;
end;

// Получить высоту bounding box
function GetBoundingBoxHeight(const Box: TUzvBoundingBox): Double;
begin
  if IsBoundingBoxEmpty(Box) then
    Result := 0.0
  else
    Result := Box.MaxY - Box.MinY;
end;

// Объединить два bounding box
function MergeBoundingBoxes(
  const Box1, Box2: TUzvBoundingBox
): TUzvBoundingBox;
begin
  // Если один из box пустой, вернуть другой
  // If one box is empty, return the other
  if IsBoundingBoxEmpty(Box1) then
  begin
    Result := Box2;
    Exit;
  end;

  if IsBoundingBoxEmpty(Box2) then
  begin
    Result := Box1;
    Exit;
  end;

  // Объединение - берём минимальные min и максимальные max
  // Merge - take minimum of mins and maximum of maxs
  Result.MinX := Min(Box1.MinX, Box2.MinX);
  Result.MinY := Min(Box1.MinY, Box2.MinY);
  Result.MaxX := Max(Box1.MaxX, Box2.MaxX);
  Result.MaxY := Max(Box1.MaxY, Box2.MaxY);
end;

// Расширить bounding box точкой
function ExpandBoundingBox(
  const Box: TUzvBoundingBox;
  const P: TPointF
): TUzvBoundingBox;
begin
  // Проверка валидности точки
  // Point validation
  if not IsValidPoint(P) then
  begin
    Result := Box;
    Exit;
  end;

  if IsBoundingBoxEmpty(Box) then
  begin
    // Первая точка - инициализация
    // First point - initialization
    Result.MinX := P.X;
    Result.MinY := P.Y;
    Result.MaxX := P.X;
    Result.MaxY := P.Y;
  end
  else
  begin
    // Расширение существующего box
    // Expand existing box
    Result.MinX := Min(Box.MinX, P.X);
    Result.MinY := Min(Box.MinY, P.Y);
    Result.MaxX := Max(Box.MaxX, P.X);
    Result.MaxY := Max(Box.MaxY, P.Y);
  end;
end;

end.
