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

unit uzvshxtopdf_shxglyph;

{$mode objfpc}{$H+}

interface

uses
  SysUtils;

type
  // Точка в 2D пространстве с координатами X, Y
  TShxPoint = record
    X, Y: Double;
  end;

  // Типы команд рисования для векторной геометрии глифов
  TShxCommandType = (
    cmdMoveTo,   // Переместить курсор без рисования
    cmdLineTo,   // Нарисовать линию до точки
    cmdArc,      // Нарисовать дугу
    cmdCircle    // Нарисовать окружность
  );

  // Команда векторного рисования с параметрами
  TShxCommand = record
    Cmd: TShxCommandType;       // Тип команды
    P1, P2, P3: TShxPoint;      // Опорные точки (используются в зависимости от типа команды)
    Radius: Double;             // Радиус для дуги или окружности
    StartAngle, EndAngle: Double; // Углы для дуги (в радианах)
  end;

  // Ограничивающий прямоугольник глифа
  TShxBounds = record
    MinX, MinY: Double;  // Нижний левый угол
    MaxX, MaxY: Double;  // Верхний правый угол
  end;

  // Структура глифа (символа) в шрифте SHX
  TShxGlyph = record
    Code: Byte;                      // Код символа (0-255)
    Name: string;                    // Имя символа для отладки
    AdvanceWidth: Double;            // Ширина продвижения курсора после отрисовки
    Bounds: TShxBounds;              // Ограничивающий прямоугольник
    Commands: array of TShxCommand;  // Массив команд векторного рисования
  end;

  // Структура шрифта SHX со всеми глифами
  TShxFont = record
    FontName: string;              // Имя шрифта
    UnitsPerEm: Double;            // Количество единиц на высоту шрифта (для масштабирования)
    Glyphs: array of TShxGlyph;    // Массив всех глифов шрифта
  end;

// Вспомогательные функции для работы с глифами

// Создать пустой глиф с заданным кодом
function CreateEmptyGlyph(Code: Byte): TShxGlyph;

// Создать пустой шрифт
function CreateEmptyFont: TShxFont;

// Добавить команду MoveTo к глифу
procedure AddMoveToCommand(var Glyph: TShxGlyph; X, Y: Double);

// Добавить команду LineTo к глифу
procedure AddLineToCommand(var Glyph: TShxGlyph; X, Y: Double);

// Добавить команду Arc к глифу
procedure AddArcCommand(
  var Glyph: TShxGlyph;
  CenterX, CenterY, Radius, StartAngle, EndAngle: Double
);

// Добавить команду Circle к глифу
procedure AddCircleCommand(var Glyph: TShxGlyph; CenterX, CenterY, Radius: Double);

// Рассчитать ограничивающий прямоугольник глифа по его командам
procedure CalculateGlyphBounds(var Glyph: TShxGlyph);

// Найти глиф по коду символа в шрифте
function FindGlyphByCode(const Font: TShxFont; Code: Byte): Integer;

implementation

uses
  Math;

// Создать точку
function MakePoint(X, Y: Double): TShxPoint;
begin
  Result.X := X;
  Result.Y := Y;
end;

// Создать пустой глиф с заданным кодом
function CreateEmptyGlyph(Code: Byte): TShxGlyph;
begin
  Result.Code := Code;
  Result.Name := '';
  Result.AdvanceWidth := 0.0;
  Result.Bounds.MinX := 0.0;
  Result.Bounds.MinY := 0.0;
  Result.Bounds.MaxX := 0.0;
  Result.Bounds.MaxY := 0.0;
  SetLength(Result.Commands, 0);
end;

// Создать пустой шрифт
function CreateEmptyFont: TShxFont;
begin
  Result.FontName := '';
  Result.UnitsPerEm := 1.0;
  SetLength(Result.Glyphs, 0);
end;

// Добавить команду MoveTo к глифу
procedure AddMoveToCommand(var Glyph: TShxGlyph; X, Y: Double);
var
  Idx: Integer;
begin
  Idx := Length(Glyph.Commands);
  SetLength(Glyph.Commands, Idx + 1);
  Glyph.Commands[Idx].Cmd := cmdMoveTo;
  Glyph.Commands[Idx].P1 := MakePoint(X, Y);
end;

// Добавить команду LineTo к глифу
procedure AddLineToCommand(var Glyph: TShxGlyph; X, Y: Double);
var
  Idx: Integer;
begin
  Idx := Length(Glyph.Commands);
  SetLength(Glyph.Commands, Idx + 1);
  Glyph.Commands[Idx].Cmd := cmdLineTo;
  Glyph.Commands[Idx].P1 := MakePoint(X, Y);
end;

// Добавить команду Arc к глифу
procedure AddArcCommand(
  var Glyph: TShxGlyph;
  CenterX, CenterY, Radius, StartAngle, EndAngle: Double
);
var
  Idx: Integer;
begin
  Idx := Length(Glyph.Commands);
  SetLength(Glyph.Commands, Idx + 1);
  Glyph.Commands[Idx].Cmd := cmdArc;
  Glyph.Commands[Idx].P1 := MakePoint(CenterX, CenterY);
  Glyph.Commands[Idx].Radius := Radius;
  Glyph.Commands[Idx].StartAngle := StartAngle;
  Glyph.Commands[Idx].EndAngle := EndAngle;
end;

// Добавить команду Circle к глифу
procedure AddCircleCommand(var Glyph: TShxGlyph; CenterX, CenterY, Radius: Double);
var
  Idx: Integer;
begin
  Idx := Length(Glyph.Commands);
  SetLength(Glyph.Commands, Idx + 1);
  Glyph.Commands[Idx].Cmd := cmdCircle;
  Glyph.Commands[Idx].P1 := MakePoint(CenterX, CenterY);
  Glyph.Commands[Idx].Radius := Radius;
end;

// Обновить границы с учетом точки
procedure UpdateBoundsWithPoint(var Bounds: TShxBounds; X, Y: Double; var IsFirst: Boolean);
begin
  if IsFirst then
  begin
    Bounds.MinX := X;
    Bounds.MaxX := X;
    Bounds.MinY := Y;
    Bounds.MaxY := Y;
    IsFirst := False;
  end
  else
  begin
    if X < Bounds.MinX then Bounds.MinX := X;
    if X > Bounds.MaxX then Bounds.MaxX := X;
    if Y < Bounds.MinY then Bounds.MinY := Y;
    if Y > Bounds.MaxY then Bounds.MaxY := Y;
  end;
end;

// Рассчитать ограничивающий прямоугольник глифа по его командам
procedure CalculateGlyphBounds(var Glyph: TShxGlyph);
var
  i: Integer;
  Cmd: TShxCommand;
  IsFirst: Boolean;
  Angle: Double;
  X, Y: Double;
  Steps: Integer;
begin
  IsFirst := True;

  for i := 0 to High(Glyph.Commands) do
  begin
    Cmd := Glyph.Commands[i];

    case Cmd.Cmd of
      cmdMoveTo, cmdLineTo:
      begin
        UpdateBoundsWithPoint(Glyph.Bounds, Cmd.P1.X, Cmd.P1.Y, IsFirst);
      end;

      cmdArc:
      begin
        // Для дуги добавляем начальную и конечную точки, а также крайние точки
        UpdateBoundsWithPoint(
          Glyph.Bounds,
          Cmd.P1.X + Cmd.Radius * Cos(Cmd.StartAngle),
          Cmd.P1.Y + Cmd.Radius * Sin(Cmd.StartAngle),
          IsFirst
        );
        UpdateBoundsWithPoint(
          Glyph.Bounds,
          Cmd.P1.X + Cmd.Radius * Cos(Cmd.EndAngle),
          Cmd.P1.Y + Cmd.Radius * Sin(Cmd.EndAngle),
          IsFirst
        );

        // Проверяем критические углы (0, 90, 180, 270 градусов)
        Steps := 4;
        for Angle := 0 to Steps - 1 do
        begin
          X := Cmd.P1.X + Cmd.Radius * Cos(Angle * Pi / 2);
          Y := Cmd.P1.Y + Cmd.Radius * Sin(Angle * Pi / 2);
          UpdateBoundsWithPoint(Glyph.Bounds, X, Y, IsFirst);
        end;
      end;

      cmdCircle:
      begin
        // Для окружности добавляем четыре крайние точки
        UpdateBoundsWithPoint(Glyph.Bounds, Cmd.P1.X - Cmd.Radius, Cmd.P1.Y, IsFirst);
        UpdateBoundsWithPoint(Glyph.Bounds, Cmd.P1.X + Cmd.Radius, Cmd.P1.Y, IsFirst);
        UpdateBoundsWithPoint(Glyph.Bounds, Cmd.P1.X, Cmd.P1.Y - Cmd.Radius, IsFirst);
        UpdateBoundsWithPoint(Glyph.Bounds, Cmd.P1.X, Cmd.P1.Y + Cmd.Radius, IsFirst);
      end;
    end;
  end;

  // Если команд не было, оставляем границы нулевыми
  if IsFirst then
  begin
    Glyph.Bounds.MinX := 0.0;
    Glyph.Bounds.MinY := 0.0;
    Glyph.Bounds.MaxX := 0.0;
    Glyph.Bounds.MaxY := 0.0;
  end;
end;

// Найти глиф по коду символа в шрифте
// Возвращает индекс глифа или -1, если не найден
function FindGlyphByCode(const Font: TShxFont; Code: Byte): Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to High(Font.Glyphs) do
  begin
    if Font.Glyphs[i].Code = Code then
    begin
      Result := i;
      Exit;
    end;
  end;
end;

end.
