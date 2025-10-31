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

unit uzvshxtopdf_shxdebugsvg;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Classes, Math,
  uzvshxtopdf_shxglyph,
  uzclog;

// Экспортировать глиф в SVG файл для визуальной проверки
procedure ExportGlyphToSVG(
  const Glyph: TShxGlyph;
  const FileName: string;
  const Scale: Double = 100.0
);

// Экспортировать несколько глифов в один SVG файл
procedure ExportGlyphsToSVG(
  const Glyphs: array of TShxGlyph;
  const FileName: string;
  const Scale: Double = 100.0
);

// Экспортировать весь шрифт в SVG (все глифы на одной странице)
procedure ExportFontToSVG(
  const Font: TShxFont;
  const FileName: string;
  const Scale: Double = 50.0;
  MaxGlyphsPerRow: Integer = 16
);

implementation

const
  // Цвета для SVG
  SVG_STROKE_COLOR = 'black';
  SVG_FILL_COLOR = 'none';
  SVG_AXIS_COLOR = 'red';
  SVG_GRID_COLOR = 'lightgray';
  SVG_BOUNDS_COLOR = 'blue';
  SVG_BACKGROUND_COLOR = 'white';

  // Толщина линий
  SVG_STROKE_WIDTH = 1.0;
  SVG_AXIS_WIDTH = 0.5;
  SVG_GRID_WIDTH = 0.3;

// Записать заголовок SVG
procedure WriteSVGHeader(
  var SVG: TextFile;
  Width, Height: Double;
  ViewBoxMinX, ViewBoxMinY, ViewBoxWidth, ViewBoxHeight: Double
);
begin
  WriteLn(SVG, '<?xml version="1.0" encoding="UTF-8"?>');
  WriteLn(SVG, Format(
    '<svg width="%.1f" height="%.1f" viewBox="%.2f %.2f %.2f %.2f" ' +
    'xmlns="http://www.w3.org/2000/svg">',
    [Width, Height, ViewBoxMinX, ViewBoxMinY, ViewBoxWidth, ViewBoxHeight]
  ));
  WriteLn(SVG, Format('  <rect width="100%%" height="100%%" fill="%s"/>', [SVG_BACKGROUND_COLOR]));
end;

// Записать футер SVG
procedure WriteSVGFooter(var SVG: TextFile);
begin
  WriteLn(SVG, '</svg>');
end;

// Нарисовать оси координат
procedure DrawAxes(
  var SVG: TextFile;
  MinX, MinY, MaxX, MaxY: Double
);
begin
  WriteLn(SVG, '  <!-- Coordinate axes -->');
  WriteLn(SVG, Format(
    '  <line x1="%.2f" y1="0" x2="%.2f" y2="0" stroke="%s" stroke-width="%.2f" opacity="0.5"/>',
    [MinX, MaxX, SVG_AXIS_COLOR, SVG_AXIS_WIDTH]
  ));
  WriteLn(SVG, Format(
    '  <line x1="0" y1="%.2f" x2="0" y2="%.2f" stroke="%s" stroke-width="%.2f" opacity="0.5"/>',
    [MinY, MaxY, SVG_AXIS_COLOR, SVG_AXIS_WIDTH]
  ));
end;

// Нарисовать сетку
procedure DrawGrid(
  var SVG: TextFile;
  MinX, MinY, MaxX, MaxY: Double;
  GridStep: Double
);
var
  X, Y: Double;
begin
  WriteLn(SVG, '  <!-- Grid -->');

  // Вертикальные линии
  X := Ceil(MinX / GridStep) * GridStep;
  while X <= MaxX do
  begin
    WriteLn(SVG, Format(
      '  <line x1="%.2f" y1="%.2f" x2="%.2f" y2="%.2f" stroke="%s" stroke-width="%.2f" opacity="0.3"/>',
      [X, MinY, X, MaxY, SVG_GRID_COLOR, SVG_GRID_WIDTH]
    ));
    X := X + GridStep;
  end;

  // Горизонтальные линии
  Y := Ceil(MinY / GridStep) * GridStep;
  while Y <= MaxY do
  begin
    WriteLn(SVG, Format(
      '  <line x1="%.2f" y1="%.2f" x2="%.2f" y2="%.2f" stroke="%s" stroke-width="%.2f" opacity="0.3"/>',
      [MinX, Y, MaxX, Y, SVG_GRID_COLOR, SVG_GRID_WIDTH]
    ));
    Y := Y + GridStep;
  end;
end;

// Нарисовать ограничивающий прямоугольник глифа
procedure DrawBounds(var SVG: TextFile; const Bounds: TShxBounds);
begin
  WriteLn(SVG, '  <!-- Bounding box -->');
  WriteLn(SVG, Format(
    '  <rect x="%.2f" y="%.2f" width="%.2f" height="%.2f" ' +
    'stroke="%s" fill="none" stroke-width="%.2f" opacity="0.3" stroke-dasharray="2,2"/>',
    [
      Bounds.MinX,
      Bounds.MinY,
      Bounds.MaxX - Bounds.MinX,
      Bounds.MaxY - Bounds.MinY,
      SVG_BOUNDS_COLOR,
      SVG_AXIS_WIDTH
    ]
  ));
end;

// Преобразовать угол из радиан в градусы
function RadToDeg(Angle: Double): Double;
begin
  Result := Angle * 180.0 / Pi;
end;

// Нарисовать команды глифа
procedure DrawGlyphCommands(
  var SVG: TextFile;
  const Glyph: TShxGlyph;
  OffsetX, OffsetY: Double
);
var
  i: Integer;
  Cmd: TShxCommand;
  PathData: string;
  CurrentX, CurrentY: Double;
  X1, Y1, X2, Y2: Double;
  SweepFlag: Integer;
begin
  if Length(Glyph.Commands) = 0 then
    Exit;

  WriteLn(SVG, '  <!-- Glyph commands -->');

  // Формируем SVG path
  PathData := '';
  CurrentX := 0.0;
  CurrentY := 0.0;

  for i := 0 to High(Glyph.Commands) do
  begin
    Cmd := Glyph.Commands[i];

    case Cmd.Cmd of
      cmdMoveTo:
      begin
        PathData := PathData + Format('M %.2f %.2f ', [Cmd.P1.X + OffsetX, Cmd.P1.Y + OffsetY]);
        CurrentX := Cmd.P1.X;
        CurrentY := Cmd.P1.Y;
      end;

      cmdLineTo:
      begin
        PathData := PathData + Format('L %.2f %.2f ', [Cmd.P1.X + OffsetX, Cmd.P1.Y + OffsetY]);
        CurrentX := Cmd.P1.X;
        CurrentY := Cmd.P1.Y;
      end;

      cmdArc:
      begin
        // Вычисляем конечную точку дуги
        X2 := Cmd.P1.X + Cmd.Radius * Cos(Cmd.EndAngle);
        Y2 := Cmd.P1.Y + Cmd.Radius * Sin(Cmd.EndAngle);

        // Определяем направление дуги
        if Cmd.EndAngle > Cmd.StartAngle then
          SweepFlag := 1
        else
          SweepFlag := 0;

        PathData := PathData + Format(
          'A %.2f %.2f 0 0 %d %.2f %.2f ',
          [Cmd.Radius, Cmd.Radius, SweepFlag, X2 + OffsetX, Y2 + OffsetY]
        );
        CurrentX := X2;
        CurrentY := Y2;
      end;

      cmdCircle:
      begin
        // Рисуем окружность как отдельный элемент
        WriteLn(SVG, Format(
          '  <circle cx="%.2f" cy="%.2f" r="%.2f" stroke="%s" fill="%s" stroke-width="%.2f"/>',
          [
            Cmd.P1.X + OffsetX,
            Cmd.P1.Y + OffsetY,
            Cmd.Radius,
            SVG_STROKE_COLOR,
            SVG_FILL_COLOR,
            SVG_STROKE_WIDTH
          ]
        ));
      end;
    end;
  end;

  // Записываем path, если есть данные
  if PathData <> '' then
  begin
    WriteLn(SVG, Format(
      '  <path d="%s" stroke="%s" fill="%s" stroke-width="%.2f"/>',
      [PathData, SVG_STROKE_COLOR, SVG_FILL_COLOR, SVG_STROKE_WIDTH]
    ));
  end;
end;

// Экспортировать глиф в SVG файл
procedure ExportGlyphToSVG(
  const Glyph: TShxGlyph;
  const FileName: string;
  const Scale: Double = 100.0
);
var
  SVG: TextFile;
  ViewBoxWidth, ViewBoxHeight: Double;
  ViewBoxMinX, ViewBoxMinY: Double;
  Margin: Double;
begin
  programlog.LogOutFormatStr(
    'Экспорт глифа в SVG: Code=%d Name=%s File=%s',
    [Glyph.Code, Glyph.Name, FileName],
    LM_Info
  );

  try
    AssignFile(SVG, FileName);
    Rewrite(SVG);

    try
      // Вычисляем размеры viewBox с учетом границ глифа
      Margin := 0.2;
      ViewBoxMinX := Glyph.Bounds.MinX - Margin;
      ViewBoxMinY := Glyph.Bounds.MinY - Margin;
      ViewBoxWidth := (Glyph.Bounds.MaxX - Glyph.Bounds.MinX) + 2 * Margin;
      ViewBoxHeight := (Glyph.Bounds.MaxY - Glyph.Bounds.MinY) + 2 * Margin;

      // Если глиф пустой, используем единичные размеры
      if ViewBoxWidth <= 0 then ViewBoxWidth := 1.0;
      if ViewBoxHeight <= 0 then ViewBoxHeight := 1.0;

      // Записываем заголовок
      WriteSVGHeader(
        SVG,
        ViewBoxWidth * Scale,
        ViewBoxHeight * Scale,
        ViewBoxMinX,
        ViewBoxMinY,
        ViewBoxWidth,
        ViewBoxHeight
      );

      // Рисуем сетку
      DrawGrid(SVG, ViewBoxMinX, ViewBoxMinY, ViewBoxMinX + ViewBoxWidth, ViewBoxMinY + ViewBoxHeight, 0.1);

      // Рисуем оси
      DrawAxes(SVG, ViewBoxMinX, ViewBoxMinY, ViewBoxMinX + ViewBoxWidth, ViewBoxMinY + ViewBoxHeight);

      // Рисуем границы глифа
      if Length(Glyph.Commands) > 0 then
      begin
        DrawBounds(SVG, Glyph.Bounds);
      end;

      // Рисуем команды глифа
      DrawGlyphCommands(SVG, Glyph, 0.0, 0.0);

      // Добавляем текстовую информацию
      WriteLn(SVG, '  <!-- Glyph info -->');
      WriteLn(SVG, Format(
        '  <text x="%.2f" y="%.2f" font-size="%.2f" fill="black" font-family="monospace">',
        [ViewBoxMinX + 0.05, ViewBoxMinY + ViewBoxHeight - 0.05, ViewBoxHeight * 0.1]
      ));
      WriteLn(SVG, Format('Code: %d (%s) Width: %.2f', [Glyph.Code, Glyph.Name, Glyph.AdvanceWidth]));
      WriteLn(SVG, '  </text>');

      // Футер
      WriteSVGFooter(SVG);

      programlog.LogOutFormatStr(
        'SVG успешно создан: %s',
        [FileName],
        LM_Info
      );

    finally
      CloseFile(SVG);
    end;

  except
    on E: Exception do
    begin
      programlog.LogOutFormatStr(
        'Ошибка при экспорте глифа в SVG: %s',
        [E.Message],
        LM_Error
      );
    end;
  end;
end;

// Экспортировать несколько глифов в один SVG файл
procedure ExportGlyphsToSVG(
  const Glyphs: array of TShxGlyph;
  const FileName: string;
  const Scale: Double = 100.0
);
var
  SVG: TextFile;
  i: Integer;
  OffsetX: Double;
  TotalWidth: Double;
  MaxHeight: Double;
  ViewBoxHeight: Double;
  Margin: Double;
begin
  if Length(Glyphs) = 0 then
    Exit;

  programlog.LogOutFormatStr(
    'Экспорт %d глифов в SVG: %s',
    [Length(Glyphs), FileName],
    LM_Info
  );

  try
    AssignFile(SVG, FileName);
    Rewrite(SVG);

    try
      // Вычисляем общую ширину и максимальную высоту
      TotalWidth := 0.0;
      MaxHeight := 0.0;
      Margin := 0.5;

      for i := 0 to High(Glyphs) do
      begin
        TotalWidth := TotalWidth + Glyphs[i].AdvanceWidth + Margin;
        ViewBoxHeight := Glyphs[i].Bounds.MaxY - Glyphs[i].Bounds.MinY;
        if ViewBoxHeight > MaxHeight then
          MaxHeight := ViewBoxHeight;
      end;

      if MaxHeight <= 0 then MaxHeight := 1.0;

      // Записываем заголовок
      WriteSVGHeader(SVG, TotalWidth * Scale, MaxHeight * Scale, 0, 0, TotalWidth, MaxHeight);

      // Рисуем базовую линию
      WriteLn(SVG, Format(
        '  <line x1="0" y1="0" x2="%.2f" y2="0" stroke="%s" stroke-width="%.2f" opacity="0.5"/>',
        [TotalWidth, SVG_AXIS_COLOR, SVG_AXIS_WIDTH]
      ));

      // Рисуем каждый глиф
      OffsetX := 0.0;
      for i := 0 to High(Glyphs) do
      begin
        WriteLn(SVG, Format('  <g id="glyph_%d">', [i]));
        DrawGlyphCommands(SVG, Glyphs[i], OffsetX, 0);
        WriteLn(SVG, '  </g>');

        OffsetX := OffsetX + Glyphs[i].AdvanceWidth + Margin;
      end;

      // Футер
      WriteSVGFooter(SVG);

      programlog.LogOutFormatStr(
        'SVG успешно создан: %s',
        [FileName],
        LM_Info
      );

    finally
      CloseFile(SVG);
    end;

  except
    on E: Exception do
    begin
      programlog.LogOutFormatStr(
        'Ошибка при экспорте глифов в SVG: %s',
        [E.Message],
        LM_Error
      );
    end;
  end;
end;

// Экспортировать весь шрифт в SVG
procedure ExportFontToSVG(
  const Font: TShxFont;
  const FileName: string;
  const Scale: Double = 50.0;
  MaxGlyphsPerRow: Integer = 16
);
var
  SVG: TextFile;
  i, Row, Col: Integer;
  OffsetX, OffsetY: Double;
  CellSize: Double;
  Rows: Integer;
  ViewBoxWidth, ViewBoxHeight: Double;
begin
  if Length(Font.Glyphs) = 0 then
    Exit;

  programlog.LogOutFormatStr(
    'Экспорт шрифта "%s" (%d глифов) в SVG: %s',
    [Font.FontName, Length(Font.Glyphs), FileName],
    LM_Info
  );

  try
    AssignFile(SVG, FileName);
    Rewrite(SVG);

    try
      // Вычисляем размеры сетки
      Rows := (Length(Font.Glyphs) + MaxGlyphsPerRow - 1) div MaxGlyphsPerRow;
      CellSize := 2.0; // Размер ячейки для каждого глифа
      ViewBoxWidth := MaxGlyphsPerRow * CellSize;
      ViewBoxHeight := Rows * CellSize;

      // Записываем заголовок
      WriteSVGHeader(SVG, ViewBoxWidth * Scale, ViewBoxHeight * Scale, 0, 0, ViewBoxWidth, ViewBoxHeight);

      // Заголовок шрифта
      WriteLn(SVG, '  <!-- Font header -->');
      WriteLn(SVG, Format(
        '  <text x="0.1" y="0.3" font-size="0.3" fill="black" font-family="sans-serif">%s (%d glyphs)</text>',
        [Font.FontName, Length(Font.Glyphs)]
      ));

      // Рисуем каждый глиф в сетке
      for i := 0 to High(Font.Glyphs) do
      begin
        Row := i div MaxGlyphsPerRow;
        Col := i mod MaxGlyphsPerRow;

        OffsetX := Col * CellSize + CellSize * 0.1;
        OffsetY := (Row + 1) * CellSize + CellSize * 0.1;

        WriteLn(SVG, Format('  <g id="glyph_%d" transform="translate(%.2f, %.2f) scale(1.5)">', [i, OffsetX, OffsetY]));
        DrawGlyphCommands(SVG, Font.Glyphs[i], 0, 0);

        // Код символа под глифом
        WriteLn(SVG, Format(
          '  <text x="0" y="%.2f" font-size="%.2f" fill="gray" font-family="monospace">%d</text>',
          [0.7, 0.15, Font.Glyphs[i].Code]
        ));

        WriteLn(SVG, '  </g>');
      end;

      // Футер
      WriteSVGFooter(SVG);

      programlog.LogOutFormatStr(
        'SVG шрифта успешно создан: %s',
        [FileName],
        LM_Info
      );

    finally
      CloseFile(SVG);
    end;

  except
    on E: Exception do
    begin
      programlog.LogOutFormatStr(
        'Ошибка при экспорте шрифта в SVG: %s',
        [E.Message],
        LM_Error
      );
    end;
  end;
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
