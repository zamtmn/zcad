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
  Модуль: uzvshxtopdfcharprocstypes
  Назначение: Типы данных для этапа 4 конвейера SHX -> PDF (CharProcs)

  Данный модуль содержит структуры данных для представления:
  - PDF-совместимых CharProcs для Type3-шрифтов
  - Параметров Type3 Font объекта
  - Вспомогательных типов для генерации PDF-стримов

  Зависимости:
  - uzvshxtopdftransformtypes: входные типы из Этапа 3
  - uzvshxtopdfapprogeomtypes: базовые геометрические типы

  Module: uzvshxtopdfcharprocstypes
  Purpose: Data types for Stage 4 of SHX -> PDF pipeline (CharProcs)

  This module contains data structures for representing:
  - PDF-compatible CharProcs for Type3 fonts
  - Type3 Font object parameters
  - Helper types for PDF stream generation

  Dependencies:
  - uzvshxtopdftransformtypes: input types from Stage 3
  - uzvshxtopdfapprogeomtypes: basic geometry types
}

unit uzvshxtopdfcharprocstypes;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Math,
  uzvshxtopdfapprogeomtypes;

type
  // Ограничивающий прямоугольник для PDF (FontBBox)
  // Bounding rectangle for PDF (FontBBox)
  TUzvPdfBBox = record
    MinX: Double;  // Левая граница / Left boundary
    MinY: Double;  // Нижняя граница / Bottom boundary
    MaxX: Double;  // Правая граница / Right boundary
    MaxY: Double;  // Верхняя граница / Top boundary
  end;

  // CharProc для одного глифа (PDF-стрим с path-операторами)
  // CharProc for single glyph (PDF stream with path operators)
  TUzvPdfCharProc = record
    CharCode: Integer;    // Код символа / Character code
    CharName: AnsiString; // Имя символа для /Encoding / Symbol name for /Encoding
    Stream: AnsiString;   // PDF path stream (m, l, c, h, S, f и т.д.)
                          // PDF path stream (m, l, c, h, S, f etc.)
    Width: Double;        // Ширина глифа (advance width) / Glyph width
    BBox: TUzvPdfBBox;    // Bounding box глифа / Glyph bounding box
  end;

  // Массив CharProcs
  // CharProcs array
  TUzvPdfCharProcsArray = array of TUzvPdfCharProc;

  // Type3 Font - полное описание шрифта для PDF
  // Type3 Font - complete font description for PDF
  //
  // Структура соответствует спецификации PDF Reference:
  // Structure follows PDF Reference specification:
  //   /Type /Font
  //   /Subtype /Type3
  //   /FontBBox [...]
  //   /FontMatrix [...]
  //   /CharProcs << ... >>
  //   /Encoding << /Type /Encoding /Differences [...] >>
  //   /FirstChar ...
  //   /LastChar ...
  //   /Widths [...]
  TUzvPdfType3Font = record
    // Общий PDF-стрим для объекта Font (без CharProcs)
    // General PDF stream for Font object (without CharProcs)
    FontObjectStream: AnsiString;

    // Массив CharProcs с PDF-стримами для каждого глифа
    // CharProcs array with PDF streams for each glyph
    CharProcs: TUzvPdfCharProcsArray;

    // Массив ширин глифов, индексированный относительно FirstChar
    // Glyph widths array, indexed relative to FirstChar
    Widths: array of Double;

    // Первый и последний коды символов
    // First and last character codes
    FirstChar: Integer;
    LastChar: Integer;

    // Общий bounding box шрифта (объединение всех глифов)
    // Overall font bounding box (union of all glyphs)
    FontBBox: TUzvPdfBBox;
  end;

  // Параметры генерации CharProcs
  // CharProcs generation parameters
  TUzvCharProcsParams = record
    // Использовать stroke (S) или fill (f) для отрисовки
    // Use stroke (S) or fill (f) for rendering
    UseStroke: Boolean;

    // Точность вывода координат (количество знаков после запятой)
    // Coordinate output precision (decimal places)
    CoordPrecision: Integer;

    // Сохранять/восстанавливать graphics state (q/Q)
    // Save/restore graphics state (q/Q)
    WrapWithGraphicsState: Boolean;
  end;

// Создать пустой bounding box для PDF
// Create empty PDF bounding box
function CreateEmptyPdfBBox: TUzvPdfBBox;

// Проверить, является ли bounding box пустым
// Check if bounding box is empty
function IsPdfBBoxEmpty(const Box: TUzvPdfBBox): Boolean;

// Объединить два bounding box
// Merge two bounding boxes
function MergePdfBBoxes(const Box1, Box2: TUzvPdfBBox): TUzvPdfBBox;

// Расширить bounding box точкой
// Expand bounding box with point
function ExpandPdfBBox(const Box: TUzvPdfBBox; const P: TPointF): TUzvPdfBBox;

// Получить ширину bounding box
// Get bounding box width
function GetPdfBBoxWidth(const Box: TUzvPdfBBox): Double;

// Получить высоту bounding box
// Get bounding box height
function GetPdfBBoxHeight(const Box: TUzvPdfBBox): Double;

// Создать пустой CharProc
// Create empty CharProc
function CreateEmptyCharProc(ACharCode: Integer): TUzvPdfCharProc;

// Создать пустой Type3 Font
// Create empty Type3 Font
function CreateEmptyType3Font: TUzvPdfType3Font;

// Получить параметры генерации по умолчанию
// Get default generation parameters
function GetDefaultCharProcsParams: TUzvCharProcsParams;

// Сформировать имя символа для PDF Encoding
// Generate symbol name for PDF Encoding
// Формат: /g<code> (например, /g65 для 'A')
// Format: /g<code> (e.g., /g65 for 'A')
function MakeCharName(CharCode: Integer): AnsiString;

// Проверить валидность Type3 Font
// Validate Type3 Font structure
function ValidateType3Font(const Font: TUzvPdfType3Font): Boolean;

implementation

const
  // Константа для определения пустого bounding box
  // Constant for detecting empty bounding box
  EMPTY_BBOX_MARKER = 1e30;

// Создать пустой bounding box для PDF
function CreateEmptyPdfBBox: TUzvPdfBBox;
begin
  // Используем "инвертированный" box для удобства расширения
  // Use "inverted" box for convenient expansion
  Result.MinX := EMPTY_BBOX_MARKER;
  Result.MinY := EMPTY_BBOX_MARKER;
  Result.MaxX := -EMPTY_BBOX_MARKER;
  Result.MaxY := -EMPTY_BBOX_MARKER;
end;

// Проверить, является ли bounding box пустым
function IsPdfBBoxEmpty(const Box: TUzvPdfBBox): Boolean;
begin
  Result := (Box.MinX > Box.MaxX) or (Box.MinY > Box.MaxY);
end;

// Объединить два bounding box
function MergePdfBBoxes(const Box1, Box2: TUzvPdfBBox): TUzvPdfBBox;
begin
  // Если один из box пустой, вернуть другой
  // If one box is empty, return the other
  if IsPdfBBoxEmpty(Box1) then
  begin
    Result := Box2;
    Exit;
  end;

  if IsPdfBBoxEmpty(Box2) then
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
function ExpandPdfBBox(const Box: TUzvPdfBBox; const P: TPointF): TUzvPdfBBox;
begin
  // Проверка валидности точки
  // Point validation
  if not IsValidPoint(P) then
  begin
    Result := Box;
    Exit;
  end;

  if IsPdfBBoxEmpty(Box) then
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

// Получить ширину bounding box
function GetPdfBBoxWidth(const Box: TUzvPdfBBox): Double;
begin
  if IsPdfBBoxEmpty(Box) then
    Result := 0.0
  else
    Result := Box.MaxX - Box.MinX;
end;

// Получить высоту bounding box
function GetPdfBBoxHeight(const Box: TUzvPdfBBox): Double;
begin
  if IsPdfBBoxEmpty(Box) then
    Result := 0.0
  else
    Result := Box.MaxY - Box.MinY;
end;

// Создать пустой CharProc
function CreateEmptyCharProc(ACharCode: Integer): TUzvPdfCharProc;
begin
  Result.CharCode := ACharCode;
  Result.CharName := MakeCharName(ACharCode);
  Result.Stream := '';
  Result.Width := 0.0;
  Result.BBox := CreateEmptyPdfBBox;
end;

// Создать пустой Type3 Font
function CreateEmptyType3Font: TUzvPdfType3Font;
begin
  Result.FontObjectStream := '';
  SetLength(Result.CharProcs, 0);
  SetLength(Result.Widths, 0);
  Result.FirstChar := 0;
  Result.LastChar := 0;
  Result.FontBBox := CreateEmptyPdfBBox;
end;

// Получить параметры генерации по умолчанию
function GetDefaultCharProcsParams: TUzvCharProcsParams;
begin
  // По умолчанию используем stroke для SHX-шрифтов (они векторные)
  // Default: use stroke for SHX fonts (they are vector-based)
  Result.UseStroke := True;

  // 4 знака после запятой - достаточная точность для PDF
  // 4 decimal places - sufficient precision for PDF
  Result.CoordPrecision := 4;

  // Обязательно оборачиваем в q/Q для изоляции состояния
  // Always wrap in q/Q to isolate graphics state
  Result.WrapWithGraphicsState := True;
end;

// Сформировать имя символа для PDF Encoding
function MakeCharName(CharCode: Integer): AnsiString;
begin
  // Формат: /g<code>
  // Например: код 65 (A) -> /g65
  // Format: /g<code>
  // Example: code 65 (A) -> /g65
  Result := 'g' + IntToStr(CharCode);
end;

// Проверить валидность Type3 Font
function ValidateType3Font(const Font: TUzvPdfType3Font): Boolean;
var
  I: Integer;
  ExpectedWidthCount: Integer;
begin
  Result := False;

  // Проверка: FirstChar <= LastChar
  // Validation: FirstChar <= LastChar
  if Font.FirstChar > Font.LastChar then
    Exit;

  // Проверка количества CharProcs
  // Validate CharProcs count
  if Length(Font.CharProcs) = 0 then
    Exit;

  // Проверка количества Widths
  // Validate Widths count
  ExpectedWidthCount := Font.LastChar - Font.FirstChar + 1;
  if Length(Font.Widths) <> ExpectedWidthCount then
    Exit;

  // Проверка каждого CharProc
  // Validate each CharProc
  for I := 0 to High(Font.CharProcs) do
  begin
    // Код должен быть в диапазоне [FirstChar..LastChar]
    // Code must be in range [FirstChar..LastChar]
    if (Font.CharProcs[I].CharCode < Font.FirstChar) or
       (Font.CharProcs[I].CharCode > Font.LastChar) then
      Exit;

    // Ширина должна быть неотрицательной
    // Width must be non-negative
    if Font.CharProcs[I].Width < 0 then
      Exit;
  end;

  // Проверка FontBBox (может быть пустым для шрифтов без глифов)
  // FontBBox validation (can be empty for fonts without glyphs)
  if not IsPdfBBoxEmpty(Font.FontBBox) then
  begin
    // Если не пустой, должен быть валидным
    // If not empty, must be valid
    if IsNaN(Font.FontBBox.MinX) or IsNaN(Font.FontBBox.MinY) or
       IsNaN(Font.FontBBox.MaxX) or IsNaN(Font.FontBBox.MaxY) then
      Exit;
  end;

  Result := True;
end;

end.
