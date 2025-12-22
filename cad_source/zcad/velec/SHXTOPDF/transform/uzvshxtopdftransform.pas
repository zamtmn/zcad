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
  Модуль: uzvshxtopdftransform
  Назначение: Главный модуль этапа 3 - Трансформации геометрии

  Этап 3 применяется после Этапа 2 и работает только с безьевой геометрией,
  полученной на выходе approgeom.

  Порядок применения трансформаций (строго фиксированный):
    1. Нормализация по UnitsPerEm
    2. Масштаб по Height
    3. Масштаб по WidthFactor
    4. Oblique (shear)
    5. Зеркалирование
    6. Поворот
    7. Выравнивание
    8. Перенос в BasePoint
    9. Кернинг

  Результат - окончательная геометрия символов в мировых координатах,
  готовая для прямой записи в PDF.

  Module: uzvshxtopdftransform
  Purpose: Main module for Stage 3 - Geometry transformations

  Stage 3 is applied after Stage 2 and works only with Bezier geometry
  obtained from approgeom output.

  Transformation order (strictly fixed):
    1. Normalize by UnitsPerEm
    2. Scale by Height
    3. Scale by WidthFactor
    4. Oblique (shear)
    5. Mirroring
    6. Rotation
    7. Alignment
    8. Translate to BasePoint
    9. Kerning

  Result - final symbol geometry in world coordinates,
  ready for direct PDF writing.
}

unit uzvshxtopdftransform;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Math,
  uzvshxtopdfapprogeomtypes,
  uzvshxtopdftransformtypes,
  uzvshxtopdftransformmatrix,
  uzvshxtopdftransformapply,
  uzvshxtopdftransformalign,
  uzclog;

// Главная функция трансформации шрифта
// Main font transformation function
//
// Применяет все трансформации из TUzvTextTransform к шрифту TUzvBezierFont
// и возвращает шрифт в мировых координатах TUzvWorldBezierFont
//
// Applies all transformations from TUzvTextTransform to TUzvBezierFont
// and returns font in world coordinates TUzvWorldBezierFont
function TransformBezierFont(
  const BezierFont: TUzvBezierFont;
  const Transform: TUzvTextTransform
): TUzvWorldBezierFont;

// Создать комбинированную матрицу трансформации
// Create combined transformation matrix
//
// Объединяет все трансформации (кроме кернинга и выравнивания)
// в одну матрицу для эффективного применения
// Combines all transformations (except kerning and alignment)
// into single matrix for efficient application
function BuildTransformationMatrix(
  const Transform: TUzvTextTransform
): TUzvMatrix3x3;

// Трансформировать один глиф с позиционированием
// Transform single glyph with positioning
//
// Параметры:
//   Glyph - входной глиф из Этапа 2
//   BaseMatrix - базовая матрица трансформации (без позиции)
//   GlyphXOffset - смещение по X для данного глифа (с учётом кернинга)
//   AlignmentOffset - смещение для выравнивания
//   BasePoint - базовая точка вставки
//
// Parameters:
//   Glyph - input glyph from Stage 2
//   BaseMatrix - base transformation matrix (without position)
//   GlyphXOffset - X offset for this glyph (with kerning)
//   AlignmentOffset - offset for alignment
//   BasePoint - base insertion point
function TransformGlyph(
  const Glyph: TUzvBezierGlyph;
  const BaseMatrix: TUzvMatrix3x3;
  GlyphXOffset: Double;
  const AlignmentOffset: TPointF;
  const BasePoint: TPointF
): TUzvWorldBezierGlyph;

// Проверить валидность входных данных Этапа 2
// Validate Stage 2 input data
function ValidateStage2Input(const BezierFont: TUzvBezierFont): Boolean;

// Проверить валидность выходных данных Этапа 3
// Validate Stage 3 output data
function ValidateStage3Output(const WorldFont: TUzvWorldBezierFont): Boolean;

// Получить информацию о трансформации (для логирования)
// Get transformation info (for logging)
function GetTransformInfo(const Transform: TUzvTextTransform): string;

implementation

// Проверить валидность входных данных Этапа 2
function ValidateStage2Input(const BezierFont: TUzvBezierFont): Boolean;
var
  i, j, k: Integer;
begin
  Result := True;

  // Проверка на наличие глифов
  // Check for glyphs presence
  if Length(BezierFont.Glyphs) = 0 then
  begin
    programlog.LogOutFormatStr(
      'Transform: Warning - empty input font',
      [],
      LM_Info
    );
    // Пустой шрифт допустим, но логируем предупреждение
    // Empty font is allowed, but log warning
    Exit;
  end;

  // Проверка каждого глифа
  // Check each glyph
  for i := 0 to High(BezierFont.Glyphs) do
  begin
    // Проверка путей глифа
    // Check glyph paths
    for j := 0 to High(BezierFont.Glyphs[i].Paths) do
    begin
      // Проверка сегментов пути
      // Check path segments
      for k := 0 to High(BezierFont.Glyphs[i].Paths[j].Segments) do
      begin
        // Проверка точек на NaN/Infinity
        // Check points for NaN/Infinity
        if not IsValidPoint(BezierFont.Glyphs[i].Paths[j].Segments[k].P0) or
           not IsValidPoint(BezierFont.Glyphs[i].Paths[j].Segments[k].P1) or
           not IsValidPoint(BezierFont.Glyphs[i].Paths[j].Segments[k].P2) or
           not IsValidPoint(BezierFont.Glyphs[i].Paths[j].Segments[k].P3) then
        begin
          programlog.LogOutFormatStr(
            'Transform: Error - invalid point in glyph %d, path %d, segment %d',
            [i, j, k],
            LM_Info
          );
          Result := False;
          Exit;
        end;
      end;
    end;
  end;
end;

// Проверить валидность выходных данных Этапа 3
function ValidateStage3Output(const WorldFont: TUzvWorldBezierFont): Boolean;
var
  i, j, k: Integer;
begin
  Result := True;

  for i := 0 to High(WorldFont.Glyphs) do
  begin
    for j := 0 to High(WorldFont.Glyphs[i].Paths) do
    begin
      for k := 0 to High(WorldFont.Glyphs[i].Paths[j].Segments) do
      begin
        if not IsValidPoint(WorldFont.Glyphs[i].Paths[j].Segments[k].P0) or
           not IsValidPoint(WorldFont.Glyphs[i].Paths[j].Segments[k].P1) or
           not IsValidPoint(WorldFont.Glyphs[i].Paths[j].Segments[k].P2) or
           not IsValidPoint(WorldFont.Glyphs[i].Paths[j].Segments[k].P3) then
        begin
          programlog.LogOutFormatStr(
            'Transform: Error - invalid output point in glyph %d, path %d, segment %d',
            [i, j, k],
            LM_Info
          );
          Result := False;
          Exit;
        end;
      end;
    end;
  end;
end;

// Получить информацию о трансформации
function GetTransformInfo(const Transform: TUzvTextTransform): string;
var
  AlignHStr, AlignVStr: string;
begin
  // Горизонтальное выравнивание
  // Horizontal alignment
  case Transform.AlignmentH of
    alLeft:   AlignHStr := 'Left';
    alCenter: AlignHStr := 'Center';
    alRight:  AlignHStr := 'Right';
  end;

  // Вертикальное выравнивание
  // Vertical alignment
  case Transform.AlignmentV of
    alTop:      AlignVStr := 'Top';
    alBaseline: AlignVStr := 'Baseline';
    alBottom:   AlignVStr := 'Bottom';
  end;

  Result := Format(
    'Height=%.3f WidthFactor=%.3f UnitsPerEm=%.3f ' +
    'Oblique=%.1f Rotation=%.1f MirrorX=%s MirrorY=%s ' +
    'BasePoint=(%.3f, %.3f) Kerning=%.3f Align=%s/%s',
    [Transform.Height, Transform.WidthFactor, Transform.UnitsPerEm,
     Transform.ObliqueDeg, Transform.RotationDeg,
     BoolToStr(Transform.MirrorX, 'Yes', 'No'),
     BoolToStr(Transform.MirrorY, 'Yes', 'No'),
     Transform.BasePoint.X, Transform.BasePoint.Y,
     Transform.Kerning, AlignHStr, AlignVStr]
  );
end;

// Создать комбинированную матрицу трансформации
// Порядок: Scale(normalize) -> Scale(height) -> Scale(width) -> Shear -> Mirror -> Rotate
// Order: Scale(normalize) -> Scale(height) -> Scale(width) -> Shear -> Mirror -> Rotate
function BuildTransformationMatrix(
  const Transform: TUzvTextTransform
): TUzvMatrix3x3;
var
  NormalizeMatrix: TUzvMatrix3x3;
  HeightMatrix: TUzvMatrix3x3;
  WidthMatrix: TUzvMatrix3x3;
  ShearMatrix: TUzvMatrix3x3;
  MirrorMatrix: TUzvMatrix3x3;
  RotateMatrix: TUzvMatrix3x3;
  ObliqueRad: Double;
  RotationRad: Double;
  ShearX: Double;
begin
  // 1. Нормализация по UnitsPerEm
  //    Normalization by UnitsPerEm
  if Transform.UnitsPerEm > 0 then
    NormalizeMatrix := CreateScaleMatrix(
      1.0 / Transform.UnitsPerEm,
      1.0 / Transform.UnitsPerEm
    )
  else
    NormalizeMatrix := CreateIdentityMatrix;

  // 2. Масштаб по Height
  //    Scale by Height
  HeightMatrix := CreateScaleMatrix(Transform.Height, Transform.Height);

  // 3. Масштаб по WidthFactor (только по X)
  //    Scale by WidthFactor (X only)
  WidthMatrix := CreateScaleMatrix(Transform.WidthFactor, 1.0);

  // 4. Oblique (shear по X)
  //    Oblique (shear on X)
  // Угол oblique преобразуется в коэффициент shear: shearX = tan(angle)
  // Oblique angle converts to shear coefficient: shearX = tan(angle)
  ObliqueRad := DegToRad(Transform.ObliqueDeg);
  ShearX := Tan(ObliqueRad);
  ShearMatrix := CreateShearMatrix(ShearX, 0.0);

  // 5. Зеркалирование
  //    Mirroring
  MirrorMatrix := CreateIdentityMatrix;
  if Transform.MirrorX then
    MirrorMatrix := MultiplyMatrices(CreateMirrorXMatrix, MirrorMatrix);
  if Transform.MirrorY then
    MirrorMatrix := MultiplyMatrices(CreateMirrorYMatrix, MirrorMatrix);

  // 6. Поворот
  //    Rotation
  RotationRad := DegToRad(Transform.RotationDeg);
  RotateMatrix := CreateRotationMatrix(RotationRad);

  // Комбинируем матрицы в правильном порядке
  // Порядок применения справа налево: R * M * S * W * H * N
  // Combine matrices in correct order
  // Application order right to left: R * M * S * W * H * N
  Result := NormalizeMatrix;
  Result := MultiplyMatrices(HeightMatrix, Result);
  Result := MultiplyMatrices(WidthMatrix, Result);
  Result := MultiplyMatrices(ShearMatrix, Result);
  Result := MultiplyMatrices(MirrorMatrix, Result);
  Result := MultiplyMatrices(RotateMatrix, Result);
end;

// Трансформировать один глиф с позиционированием
function TransformGlyph(
  const Glyph: TUzvBezierGlyph;
  const BaseMatrix: TUzvMatrix3x3;
  GlyphXOffset: Double;
  const AlignmentOffset: TPointF;
  const BasePoint: TPointF
): TUzvWorldBezierGlyph;
var
  PositionMatrix: TUzvMatrix3x3;
  FinalMatrix: TUzvMatrix3x3;
  TransformedGlyph: TUzvBezierGlyph;
  i: Integer;
begin
  // Создаём матрицу позиционирования
  // Create positioning matrix
  // Порядок: BasePoint + AlignmentOffset + GlyphOffset
  // Order: BasePoint + AlignmentOffset + GlyphOffset
  PositionMatrix := CreateTranslationMatrix(
    BasePoint.X + AlignmentOffset.X + GlyphXOffset,
    BasePoint.Y + AlignmentOffset.Y
  );

  // Комбинируем: Position * BaseMatrix
  // Combine: Position * BaseMatrix
  FinalMatrix := MultiplyMatrices(PositionMatrix, BaseMatrix);

  // Применяем финальную матрицу к глифу
  // Apply final matrix to glyph
  TransformedGlyph := ApplyMatrixToGlyph(FinalMatrix, Glyph);

  // Конвертируем в мировые координаты
  // Convert to world coordinates
  Result := ConvertToWorldGlyph(TransformedGlyph);
end;

// Главная функция трансформации шрифта
function TransformBezierFont(
  const BezierFont: TUzvBezierFont;
  const Transform: TUzvTextTransform
): TUzvWorldBezierFont;
var
  BaseMatrix: TUzvMatrix3x3;
  GlyphWidths: array of Double;
  ScaleFactor: Double;
  TotalWidth: Double;
  AlignmentOffset: TPointF;
  PreAlignBBox: TUzvBoundingBox;
  i: Integer;
  GlyphXOffset: Double;
  TransformedGlyph: TUzvBezierGlyph;
begin
  // Логирование старта
  // Log start
  programlog.LogOutFormatStr(
    'Transform: Starting Stage 3 transformation',
    [],
    LM_Info
  );

  programlog.LogOutFormatStr(
    'Transform: Parameters - %s',
    [GetTransformInfo(Transform)],
    LM_Info
  );

  // Проверка входных данных
  // Validate input
  if not ValidateTextTransform(Transform) then
  begin
    programlog.LogOutFormatStr(
      'Transform: Error - invalid transformation parameters',
      [],
      LM_Info
    );
    Result := CreateEmptyWorldBezierFont;
    Exit;
  end;

  if not ValidateStage2Input(BezierFont) then
  begin
    programlog.LogOutFormatStr(
      'Transform: Error - invalid Stage 2 input',
      [],
      LM_Info
    );
    Result := CreateEmptyWorldBezierFont;
    Exit;
  end;

  // Пустой шрифт - возвращаем пустой результат
  // Empty font - return empty result
  if Length(BezierFont.Glyphs) = 0 then
  begin
    programlog.LogOutFormatStr(
      'Transform: Warning - empty font, returning empty result',
      [],
      LM_Info
    );
    Result := CreateEmptyWorldBezierFont;
    Exit;
  end;

  // Строим базовую матрицу трансформации
  // Build base transformation matrix
  BaseMatrix := BuildTransformationMatrix(Transform);

  programlog.LogOutFormatStr(
    'Transform: Matrix built - det=%.6f',
    [MatrixDeterminant(BaseMatrix)],
    LM_Info
  );

  // Собираем ширины глифов для расчёта позиций
  // Collect glyph widths for position calculation
  SetLength(GlyphWidths, Length(BezierFont.Glyphs));
  for i := 0 to High(BezierFont.Glyphs) do
  begin
    GlyphWidths[i] := BezierFont.Glyphs[i].Width;
  end;

  // Вычисляем масштабный коэффициент для позиционирования
  // Calculate scale factor for positioning
  if Transform.UnitsPerEm > 0 then
    ScaleFactor := Transform.Height / Transform.UnitsPerEm * Transform.WidthFactor
  else
    ScaleFactor := Transform.Height * Transform.WidthFactor;

  // Вычисляем общую ширину для выравнивания
  // Calculate total width for alignment
  TotalWidth := CalculateTotalTextWidth(GlyphWidths, Transform.Kerning, ScaleFactor);

  // Для вычисления выравнивания нужен bounding box после базовых трансформаций
  // For alignment calculation need bounding box after base transformations
  // Трансформируем все глифы без позиционирования для получения bounding box
  // Transform all glyphs without positioning to get bounding box
  PreAlignBBox := CreateEmptyBoundingBox;
  for i := 0 to High(BezierFont.Glyphs) do
  begin
    GlyphXOffset := CalculateGlyphXPosition(
      GlyphWidths, i, Transform.Kerning, ScaleFactor
    );

    // Создаём временную матрицу с позицией глифа
    // Create temporary matrix with glyph position
    TransformedGlyph := ApplyMatrixToGlyph(
      MultiplyMatrices(CreateTranslationMatrix(GlyphXOffset, 0), BaseMatrix),
      BezierFont.Glyphs[i]
    );

    PreAlignBBox := MergeBoundingBoxes(
      PreAlignBBox,
      CalculateGlyphBoundingBox(TransformedGlyph)
    );
  end;

  // Вычисляем смещение для выравнивания
  // Calculate alignment offset
  AlignmentOffset := CalculateAlignmentOffset(
    PreAlignBBox,
    Transform.AlignmentH,
    Transform.AlignmentV,
    0.0  // Базовая линия в локальных координатах обычно 0
         // Baseline in local coordinates is usually 0
  );

  programlog.LogOutFormatStr(
    'Transform: Alignment offset = (%.3f, %.3f)',
    [AlignmentOffset.X, AlignmentOffset.Y],
    LM_Info
  );

  // Выделяем память под результат
  // Allocate memory for result
  SetLength(Result.Glyphs, Length(BezierFont.Glyphs));

  // Трансформируем каждый глиф
  // Transform each glyph
  for i := 0 to High(BezierFont.Glyphs) do
  begin
    // Вычисляем X-позицию глифа с учётом кернинга
    // Calculate glyph X position with kerning
    GlyphXOffset := CalculateGlyphXPosition(
      GlyphWidths, i, Transform.Kerning, ScaleFactor
    );

    // Трансформируем глиф
    // Transform glyph
    Result.Glyphs[i] := TransformGlyph(
      BezierFont.Glyphs[i],
      BaseMatrix,
      GlyphXOffset,
      AlignmentOffset,
      Transform.BasePoint
    );
  end;

  // Валидация выходных данных
  // Validate output
  if not ValidateStage3Output(Result) then
  begin
    programlog.LogOutFormatStr(
      'Transform: Warning - output validation found issues',
      [],
      LM_Info
    );
  end;

  // Логирование завершения
  // Log completion
  programlog.LogOutFormatStr(
    'Transform: Stage 3 completed - %d glyphs processed',
    [Length(Result.Glyphs)],
    LM_Info
  );
end;

end.
