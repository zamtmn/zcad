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
  Модуль: uzvshxtopdfapprogeom
  Назначение: Основной интерфейс этапа 2 конвейера SHX → PDF

  Этап 2 предназначен для преобразования геометрических примитивов,
  полученных из SHX-парсера (Этап 1), в форму, совместимую с PDF-графикой,
  а именно: преобразование дуг, окружностей и кривых SHX в последовательности
  кубических кривых Безье (C) с управляемой точностью аппроксимации.

  Module: uzvshxtopdfapprogeom
  Purpose: Main interface of Stage 2 for SHX → PDF pipeline

  Stage 2 is designed to transform geometric primitives obtained from
  SHX parser (Stage 1) into PDF-compatible form, namely: conversion of
  arcs, circles and SHX curves into sequences of cubic Bezier curves (C)
  with controlled approximation precision.
}

unit uzvshxtopdfapprogeom;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Math,
  uzvshxtopdf_shxglyph,
  uzvshxtopdfapprogeomtypes,
  uzvshxtopdfapprogeomsettings,
  uzvshxtopdfapprogeomarc,
  uzvshxtopdfapprogeomstroke,
  uzclog;

// Основная функция этапа 2: аппроксимация шрифта SHX в Безье
// Main Stage 2 function: approximate SHX font to Bezier
//
// Преобразует шрифт из формата этапа 1 (TShxFont) в формат этапа 2
// (TUzvBezierFont) - кубические кривые Безье.
// Transforms font from Stage 1 format (TShxFont) to Stage 2 format
// (TUzvBezierFont) - cubic Bezier curves.
//
// Параметры / Parameters:
//   ShxFont - результат этапа 1 (входные данные) / Stage 1 result (input)
//   Tolerance - допуск аппроксимации / approximation tolerance
//   ExpandStroke - включение режима stroke→fill / enable stroke→fill mode
//
// Возвращает / Returns:
//   Шрифт в форме кривых Безье / Font as Bezier curves
function ApproximateFontToBezier(
  const ShxFont: TShxFont;
  const Tolerance: Double;
  const ExpandStroke: Boolean
): TUzvBezierFont;

// Аппроксимировать один глиф SHX в Безье
// Approximate single SHX glyph to Bezier
function ApproximateGlyphToBezier(
  const ShxGlyph: TShxGlyph;
  const Tolerance: Double;
  const ExpandStroke: Boolean;
  const StrokeParams: TUzvStrokeParams
): TUzvBezierGlyph;

// Преобразовать команду SHX в путь Безье
// Convert SHX command to Bezier path
function ConvertCommandToBezier(
  const Cmd: TShxCommand;
  const Tolerance: Double
): TUzvBezierPath;

// Проверить корректность входных данных этапа 1
// Validate Stage 1 input data
function ValidateStage1Input(const ShxFont: TShxFont): Boolean;

// Проверить корректность выходных данных этапа 2
// Validate Stage 2 output data
function ValidateStage2Output(const BezierFont: TUzvBezierFont): Boolean;

// Получить информацию о результате аппроксимации (для отладки)
// Get approximation result info (for debugging)
function GetApproximationInfo(const BezierFont: TUzvBezierFont): string;

implementation

// Преобразовать команду MoveTo в путь Безье
// Convert MoveTo command to Bezier path
function ConvertMoveToToBezier(const Cmd: TShxCommand): TUzvBezierPath;
begin
  // MoveTo не создаёт видимой геометрии, но начинает новый путь
  // MoveTo doesn't create visible geometry but starts new path
  Result := CreateEmptyBezierPath;
end;

// Преобразовать команду LineTo в путь Безье
// Convert LineTo command to Bezier path
function ConvertLineToToBezier(
  const Cmd: TShxCommand;
  const PrevPoint: TPointF
): TUzvBezierPath;
var
  Segment: TUzvBezierSegment;
begin
  Result := CreateEmptyBezierPath;

  // Создаём линейный сегмент Безье
  // Create linear Bezier segment
  Segment := CreateLineBezierSegment(
    PrevPoint,
    MakePointF(Cmd.P1.X, Cmd.P1.Y)
  );

  SetLength(Result.Segments, 1);
  Result.Segments[0] := Segment;
  Result.IsClosed := False;
end;

// Преобразовать команду Arc в путь Безье
// Convert Arc command to Bezier path
function ConvertArcToBezier(
  const Cmd: TShxCommand;
  const Tolerance: Double
): TUzvBezierPath;
var
  Segments: TArray<TUzvBezierSegment>;
  i: Integer;
begin
  Result := CreateEmptyBezierPath;

  // Защита от некорректных данных
  // Protection from invalid data
  if IsNaN(Cmd.Radius) or (Abs(Cmd.Radius) < MIN_SEGMENT_LENGTH) then
  begin
    programlog.LogOutFormatStr(
      'ApproGeom: Arc conversion skipped - invalid radius %.6f',
      [Cmd.Radius],
      LM_Info
    );
    Exit;
  end;

  // Аппроксимируем дугу
  // Approximate arc
  Segments := ApproximateArc(
    Cmd.P1.X, Cmd.P1.Y,  // Центр дуги
    Cmd.Radius,           // Радиус
    Cmd.StartAngle,       // Начальный угол
    Cmd.EndAngle,         // Конечный угол
    Tolerance             // Допуск
  );

  // Копируем сегменты в результат
  // Copy segments to result
  SetLength(Result.Segments, Length(Segments));
  for i := 0 to High(Segments) do
    Result.Segments[i] := Segments[i];

  Result.IsClosed := False;
end;

// Преобразовать команду Circle в путь Безье
// Convert Circle command to Bezier path
function ConvertCircleToBezier(
  const Cmd: TShxCommand;
  const Tolerance: Double
): TUzvBezierPath;
var
  Segments: TArray<TUzvBezierSegment>;
  i: Integer;
begin
  Result := CreateEmptyBezierPath;

  // Защита от некорректных данных
  // Protection from invalid data
  if IsNaN(Cmd.Radius) or (Abs(Cmd.Radius) < MIN_SEGMENT_LENGTH) then
  begin
    programlog.LogOutFormatStr(
      'ApproGeom: Circle conversion skipped - invalid radius %.6f',
      [Cmd.Radius],
      LM_Info
    );
    Exit;
  end;

  // Аппроксимируем окружность
  // Approximate circle
  Segments := ApproximateCircle(
    Cmd.P1.X, Cmd.P1.Y,  // Центр окружности
    Cmd.Radius,           // Радиус
    Tolerance             // Допуск
  );

  // Копируем сегменты в результат
  // Copy segments to result
  SetLength(Result.Segments, Length(Segments));
  for i := 0 to High(Segments) do
    Result.Segments[i] := Segments[i];

  Result.IsClosed := True;  // Окружность всегда замкнута
end;

// Преобразовать команду SHX в путь Безье
function ConvertCommandToBezier(
  const Cmd: TShxCommand;
  const Tolerance: Double
): TUzvBezierPath;
begin
  case Cmd.Cmd of
    cmdMoveTo:
      Result := ConvertMoveToToBezier(Cmd);

    cmdLineTo:
      // Для LineTo нужна предыдущая точка, пока создаём пустой путь
      // For LineTo we need previous point, for now create empty path
      Result := CreateEmptyBezierPath;

    cmdArc:
      Result := ConvertArcToBezier(Cmd, Tolerance);

    cmdCircle:
      Result := ConvertCircleToBezier(Cmd, Tolerance);

  else
    begin
      programlog.LogOutFormatStr(
        'ApproGeom: Unknown command type %d',
        [Ord(Cmd.Cmd)],
        LM_Info
      );
      Result := CreateEmptyBezierPath;
    end;
  end;
end;

// Аппроксимировать один глиф SHX в Безье
function ApproximateGlyphToBezier(
  const ShxGlyph: TShxGlyph;
  const Tolerance: Double;
  const ExpandStroke: Boolean;
  const StrokeParams: TUzvStrokeParams
): TUzvBezierGlyph;
var
  i: Integer;
  Cmd: TShxCommand;
  CurrentPath: TUzvBezierPath;
  AllPaths: array of TUzvBezierPath;
  PathCount: Integer;
  CurrentPoint: TPointF;
  PathStartPoint: TPointF;
  Segment: TUzvBezierSegment;
  ArcSegments: TArray<TUzvBezierSegment>;
  j: Integer;
begin
  Result := CreateEmptyBezierGlyph(ShxGlyph.Code);
  Result.Width := ShxGlyph.AdvanceWidth;

  // Проверка на пустой глиф
  // Check for empty glyph
  if Length(ShxGlyph.Commands) = 0 then
  begin
    programlog.LogOutFormatStr(
      'ApproGeom: Glyph %d has no commands',
      [ShxGlyph.Code],
      LM_Info
    );
    Exit;
  end;

  // Инициализация
  // Initialization
  SetLength(AllPaths, 0);
  PathCount := 0;
  CurrentPath := CreateEmptyBezierPath;
  CurrentPoint := MakePointF(0.0, 0.0);
  PathStartPoint := CurrentPoint;

  // Обрабатываем команды глифа
  // Process glyph commands
  for i := 0 to High(ShxGlyph.Commands) do
  begin
    Cmd := ShxGlyph.Commands[i];

    case Cmd.Cmd of
      cmdMoveTo:
      begin
        // Сохраняем текущий путь если он не пустой
        // Save current path if not empty
        if Length(CurrentPath.Segments) > 0 then
        begin
          SetLength(AllPaths, PathCount + 1);
          AllPaths[PathCount] := CurrentPath;
          Inc(PathCount);
          CurrentPath := CreateEmptyBezierPath;
        end;

        // Перемещаемся в новую точку
        // Move to new point
        CurrentPoint := MakePointF(Cmd.P1.X, Cmd.P1.Y);
        PathStartPoint := CurrentPoint;
      end;

      cmdLineTo:
      begin
        // Создаём линейный сегмент
        // Create linear segment
        Segment := CreateLineBezierSegment(
          CurrentPoint,
          MakePointF(Cmd.P1.X, Cmd.P1.Y)
        );

        // Добавляем к текущему пути
        // Add to current path
        SetLength(
          CurrentPath.Segments,
          Length(CurrentPath.Segments) + 1
        );
        CurrentPath.Segments[High(CurrentPath.Segments)] := Segment;

        // Обновляем текущую точку
        // Update current point
        CurrentPoint := MakePointF(Cmd.P1.X, Cmd.P1.Y);
      end;

      cmdArc:
      begin
        // Аппроксимируем дугу
        // Approximate arc
        ArcSegments := ApproximateArc(
          Cmd.P1.X, Cmd.P1.Y,
          Cmd.Radius,
          Cmd.StartAngle,
          Cmd.EndAngle,
          Tolerance
        );

        // Добавляем сегменты к текущему пути
        // Add segments to current path
        for j := 0 to High(ArcSegments) do
        begin
          SetLength(
            CurrentPath.Segments,
            Length(CurrentPath.Segments) + 1
          );
          CurrentPath.Segments[High(CurrentPath.Segments)] := ArcSegments[j];
        end;

        // Обновляем текущую точку (конец дуги)
        // Update current point (arc end)
        if Length(ArcSegments) > 0 then
          CurrentPoint := ArcSegments[High(ArcSegments)].P3;
      end;

      cmdCircle:
      begin
        // Сохраняем текущий путь
        // Save current path
        if Length(CurrentPath.Segments) > 0 then
        begin
          SetLength(AllPaths, PathCount + 1);
          AllPaths[PathCount] := CurrentPath;
          Inc(PathCount);
          CurrentPath := CreateEmptyBezierPath;
        end;

        // Аппроксимируем окружность
        // Approximate circle
        ArcSegments := ApproximateCircle(
          Cmd.P1.X, Cmd.P1.Y,
          Cmd.Radius,
          Tolerance
        );

        // Создаём замкнутый путь для окружности
        // Create closed path for circle
        CurrentPath.IsClosed := True;
        SetLength(CurrentPath.Segments, Length(ArcSegments));
        for j := 0 to High(ArcSegments) do
          CurrentPath.Segments[j] := ArcSegments[j];

        // Сохраняем путь окружности
        // Save circle path
        SetLength(AllPaths, PathCount + 1);
        AllPaths[PathCount] := CurrentPath;
        Inc(PathCount);
        CurrentPath := CreateEmptyBezierPath;
      end;
    end;
  end;

  // Сохраняем последний путь
  // Save last path
  if Length(CurrentPath.Segments) > 0 then
  begin
    SetLength(AllPaths, PathCount + 1);
    AllPaths[PathCount] := CurrentPath;
    Inc(PathCount);
  end;

  // Применяем обработку stroke если нужно
  // Apply stroke processing if needed
  if ExpandStroke then
  begin
    // Расширяем каждый путь в заливку
    // Expand each path to fill
    SetLength(Result.Paths, PathCount);
    for i := 0 to PathCount - 1 do
      Result.Paths[i] := ExpandStrokeToFill(AllPaths[i], StrokeParams, Tolerance);
  end
  else
  begin
    // Копируем пути без изменения (stroke-only)
    // Copy paths unchanged (stroke-only)
    SetLength(Result.Paths, PathCount);
    for i := 0 to PathCount - 1 do
      Result.Paths[i] := ProcessStrokeOnly(AllPaths[i]);
  end;

  programlog.LogOutFormatStr(
    'ApproGeom: Glyph %d approximated: %d commands -> %d paths',
    [ShxGlyph.Code, Length(ShxGlyph.Commands), Length(Result.Paths)],
    LM_Info
  );
end;

// Проверить корректность входных данных этапа 1
function ValidateStage1Input(const ShxFont: TShxFont): Boolean;
var
  i, j: Integer;
  Cmd: TShxCommand;
begin
  Result := True;

  // Проверка имени шрифта
  // Check font name
  if Trim(ShxFont.FontName) = '' then
  begin
    programlog.LogOutFormatStr(
      'ApproGeom: Validation warning - empty font name',
      [],
      LM_Info
    );
    // Не считаем критической ошибкой
    // Not a critical error
  end;

  // Проверка UnitsPerEm
  // Check UnitsPerEm
  if IsNaN(ShxFont.UnitsPerEm) or IsInfinite(ShxFont.UnitsPerEm) or
     (ShxFont.UnitsPerEm <= 0) then
  begin
    programlog.LogOutFormatStr(
      'ApproGeom: Validation error - invalid UnitsPerEm %.2f',
      [ShxFont.UnitsPerEm],
      LM_Info
    );
    Result := False;
    Exit;
  end;

  // Проверка глифов на NaN/Infinity
  // Check glyphs for NaN/Infinity
  for i := 0 to High(ShxFont.Glyphs) do
  begin
    for j := 0 to High(ShxFont.Glyphs[i].Commands) do
    begin
      Cmd := ShxFont.Glyphs[i].Commands[j];

      // Проверка координат
      // Check coordinates
      if IsNaN(Cmd.P1.X) or IsNaN(Cmd.P1.Y) or
         IsInfinite(Cmd.P1.X) or IsInfinite(Cmd.P1.Y) then
      begin
        programlog.LogOutFormatStr(
          'ApproGeom: Validation error - NaN/Inf in glyph %d command %d',
          [ShxFont.Glyphs[i].Code, j],
          LM_Info
        );
        Result := False;
        Exit;
      end;

      // Проверка радиуса для дуг и окружностей
      // Check radius for arcs and circles
      if Cmd.Cmd in [cmdArc, cmdCircle] then
      begin
        if IsNaN(Cmd.Radius) or IsInfinite(Cmd.Radius) then
        begin
          programlog.LogOutFormatStr(
            'ApproGeom: Validation error - invalid radius in glyph %d',
            [ShxFont.Glyphs[i].Code],
            LM_Info
          );
          Result := False;
          Exit;
        end;
      end;
    end;
  end;
end;

// Проверить корректность выходных данных этапа 2
function ValidateStage2Output(const BezierFont: TUzvBezierFont): Boolean;
var
  i, j, k: Integer;
  Segment: TUzvBezierSegment;
begin
  Result := True;

  // Проверка глифов
  // Check glyphs
  for i := 0 to High(BezierFont.Glyphs) do
  begin
    // Проверка ширины
    // Check width
    if IsNaN(BezierFont.Glyphs[i].Width) or
       IsInfinite(BezierFont.Glyphs[i].Width) then
    begin
      programlog.LogOutFormatStr(
        'ApproGeom: Output validation error - invalid width in glyph %d',
        [BezierFont.Glyphs[i].Code],
        LM_Info
      );
      Result := False;
      Exit;
    end;

    // Проверка путей
    // Check paths
    for j := 0 to High(BezierFont.Glyphs[i].Paths) do
    begin
      // Проверка сегментов
      // Check segments
      for k := 0 to High(BezierFont.Glyphs[i].Paths[j].Segments) do
      begin
        Segment := BezierFont.Glyphs[i].Paths[j].Segments[k];

        // Проверка всех точек сегмента
        // Check all segment points
        if not IsValidPoint(Segment.P0) or
           not IsValidPoint(Segment.P1) or
           not IsValidPoint(Segment.P2) or
           not IsValidPoint(Segment.P3) then
        begin
          programlog.LogOutFormatStr(
            'ApproGeom: Output validation error - NaN/Inf in glyph %d path %d',
            [BezierFont.Glyphs[i].Code, j],
            LM_Info
          );
          Result := False;
          Exit;
        end;
      end;
    end;
  end;
end;

// Получить информацию о результате аппроксимации
function GetApproximationInfo(const BezierFont: TUzvBezierFont): string;
var
  TotalPaths, TotalSegments: Integer;
  i, j: Integer;
begin
  TotalPaths := 0;
  TotalSegments := 0;

  for i := 0 to High(BezierFont.Glyphs) do
  begin
    Inc(TotalPaths, Length(BezierFont.Glyphs[i].Paths));
    for j := 0 to High(BezierFont.Glyphs[i].Paths) do
      Inc(TotalSegments, Length(BezierFont.Glyphs[i].Paths[j].Segments));
  end;

  Result := Format(
    'Font: %s'#13#10 +
    'Glyphs: %d'#13#10 +
    'Total paths: %d'#13#10 +
    'Total bezier segments: %d',
    [
      BezierFont.FontName,
      Length(BezierFont.Glyphs),
      TotalPaths,
      TotalSegments
    ]
  );
end;

// Основная функция этапа 2
function ApproximateFontToBezier(
  const ShxFont: TShxFont;
  const Tolerance: Double;
  const ExpandStroke: Boolean
): TUzvBezierFont;
var
  i: Integer;
  SafeTolerance: Double;
  StrokeParams: TUzvStrokeParams;
  StartTime: TDateTime;
  ElapsedMs: Double;
begin
  Result := CreateEmptyBezierFont;

  programlog.LogOutFormatStr(
    'ApproGeom: Starting font approximation (tolerance=%.4f, expand=%d)',
    [Tolerance, Ord(ExpandStroke)],
    LM_Info
  );

  StartTime := Now;

  // Проверка входных данных
  // Validate input
  if not ValidateStage1Input(ShxFont) then
  begin
    programlog.LogOutFormatStr(
      'ApproGeom: Font approximation aborted - invalid input',
      [],
      LM_Info
    );
    Exit;
  end;

  // Безопасное значение tolerance
  // Safe tolerance value
  SafeTolerance := Tolerance;
  if IsNaN(SafeTolerance) or (SafeTolerance <= 0) then
    SafeTolerance := DEFAULT_TOLERANCE
  else if SafeTolerance < MIN_TOLERANCE then
    SafeTolerance := MIN_TOLERANCE
  else if SafeTolerance > MAX_TOLERANCE then
    SafeTolerance := MAX_TOLERANCE;

  // Параметры обводки
  // Stroke parameters
  StrokeParams := GetDefaultStrokeParams;

  // Копируем имя шрифта
  // Copy font name
  Result.FontName := ShxFont.FontName;

  // Выделяем память под глифы
  // Allocate memory for glyphs
  SetLength(Result.Glyphs, Length(ShxFont.Glyphs));

  // Аппроксимируем каждый глиф
  // Approximate each glyph
  for i := 0 to High(ShxFont.Glyphs) do
  begin
    Result.Glyphs[i] := ApproximateGlyphToBezier(
      ShxFont.Glyphs[i],
      SafeTolerance,
      ExpandStroke,
      StrokeParams
    );
  end;

  // Проверка выходных данных
  // Validate output
  if not ValidateStage2Output(Result) then
  begin
    programlog.LogOutFormatStr(
      'ApproGeom: Warning - output validation failed',
      [],
      LM_Info
    );
  end;

  // Вычисляем время выполнения
  // Calculate execution time
  ElapsedMs := (Now - StartTime) * 24 * 3600 * 1000;

  programlog.LogOutFormatStr(
    'ApproGeom: Font approximation completed in %.1f ms'#13#10'%s',
    [ElapsedMs, GetApproximationInfo(Result)],
    LM_Info
  );
end;

initialization
  programlog.LogOutFormatStr(
    'Unit "%s" initialization',
    [{$INCLUDE %FILE%}],
    LM_Info,
    UnitsInitializeLMId
  );

finalization
  ProgramLog.LogOutFormatStr(
    'Unit "%s" finalization',
    [{$INCLUDE %FILE%}],
    LM_Info,
    UnitsFinalizeLMId
  );

end.
