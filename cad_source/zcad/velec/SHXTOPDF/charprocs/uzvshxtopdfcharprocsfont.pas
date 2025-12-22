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
  Модуль: uzvshxtopdfcharprocsfont
  Назначение: Генерация Type3 Font объекта для PDF

  Данный модуль предоставляет функции для формирования
  полного описания Type3 шрифта, включая:
  - Словарь /CharProcs с ссылками на глифы
  - Массив /Widths
  - /Encoding с /Differences
  - /FontBBox
  - /FontMatrix

  Структура Type3 Font по спецификации PDF:
    /Type /Font
    /Subtype /Type3
    /FontBBox [llx lly urx ury]
    /FontMatrix [a b c d e f]
    /CharProcs << /gXX ref ... >>
    /Encoding << /Type /Encoding /Differences [...] >>
    /FirstChar N
    /LastChar M
    /Widths [w1 w2 ... wN]

  Зависимости:
  - uzvshxtopdfcharprocstypes: типы данных этапа 4
  - uzvshxtopdfcharprocsbbox: расчёт bounding box
  - uzvshxtopdfcharprocswriter: генерация path stream

  Module: uzvshxtopdfcharprocsfont
  Purpose: Type3 Font object generation for PDF

  This module provides functions for building
  complete Type3 font description, including:
  - /CharProcs dictionary with glyph references
  - /Widths array
  - /Encoding with /Differences
  - /FontBBox
  - /FontMatrix

  Type3 Font structure per PDF specification:
    /Type /Font
    /Subtype /Type3
    /FontBBox [llx lly urx ury]
    /FontMatrix [a b c d e f]
    /CharProcs << /gXX ref ... >>
    /Encoding << /Type /Encoding /Differences [...] >>
    /FirstChar N
    /LastChar M
    /Widths [w1 w2 ... wN]

  Dependencies:
  - uzvshxtopdfcharprocstypes: Stage 4 data types
  - uzvshxtopdfcharprocsbbox: bounding box calculation
  - uzvshxtopdfcharprocswriter: path stream generation
}

unit uzvshxtopdfcharprocsfont;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Math,
  uzvshxtopdfapprogeomtypes,
  uzvshxtopdftransformtypes,
  uzvshxtopdfcharprocstypes,
  uzvshxtopdfcharprocsbbox,
  uzvshxtopdfcharprocswriter;

// Сгенерировать словарь /Encoding для Type3 Font
// Generate /Encoding dictionary for Type3 Font
function GenerateEncodingDict(const CharProcs: TUzvPdfCharProcsArray): AnsiString;

// Сгенерировать массив /Widths для Type3 Font
// Generate /Widths array for Type3 Font
function GenerateWidthsArray(
  const CharProcs: TUzvPdfCharProcsArray;
  FirstChar, LastChar: Integer;
  Precision: Integer
): AnsiString;

// Сгенерировать /FontBBox для Type3 Font
// Generate /FontBBox for Type3 Font
function GenerateFontBBoxArray(
  const BBox: TUzvPdfBBox;
  Precision: Integer
): AnsiString;

// Сгенерировать /FontMatrix (единичная матрица)
// Generate /FontMatrix (identity matrix)
function GenerateFontMatrix: AnsiString;

// Сгенерировать словарь /CharProcs (только имена, без объектов)
// Generate /CharProcs dictionary (names only, without objects)
// Примечание: реальные объекты добавляются PDF-экспортером
// Note: actual objects are added by PDF exporter
function GenerateCharProcsDict(const CharProcs: TUzvPdfCharProcsArray): AnsiString;

// Собрать полное описание Type3 Font объекта
// Build complete Type3 Font object description
function BuildType3FontObject(const Font: TUzvPdfType3Font): AnsiString;

// Вычислить FirstChar и LastChar для массива CharProcs
// Calculate FirstChar and LastChar for CharProcs array
procedure CalcCharRange(
  const CharProcs: TUzvPdfCharProcsArray;
  out FirstChar, LastChar: Integer
);

// Построить массив Widths с учётом пробелов в диапазоне символов
// Build Widths array accounting for gaps in character range
function BuildWidthsArray(
  const CharProcs: TUzvPdfCharProcsArray;
  FirstChar, LastChar: Integer
): TDoubleDynArray;

type
  // Динамический массив Double
  // Dynamic array of Double
  TDoubleDynArray = array of Double;

implementation

const
  // PDF-токены
  // PDF tokens
  PDF_DICT_BEGIN = '<<';
  PDF_DICT_END = '>>';
  PDF_ARRAY_BEGIN = '[';
  PDF_ARRAY_END = ']';
  PDF_NEWLINE = #10;
  PDF_SPACE = ' ';

// Вычислить FirstChar и LastChar для массива CharProcs
procedure CalcCharRange(
  const CharProcs: TUzvPdfCharProcsArray;
  out FirstChar, LastChar: Integer
);
var
  I: Integer;
begin
  FirstChar := MaxInt;
  LastChar := -1;

  for I := 0 to High(CharProcs) do
  begin
    if CharProcs[I].CharCode < FirstChar then
      FirstChar := CharProcs[I].CharCode;
    if CharProcs[I].CharCode > LastChar then
      LastChar := CharProcs[I].CharCode;
  end;

  // Если массив пустой, устанавливаем значения по умолчанию
  // If array is empty, set default values
  if FirstChar = MaxInt then
    FirstChar := 0;
  if LastChar = -1 then
    LastChar := 0;
end;

// Построить массив Widths с учётом пробелов в диапазоне символов
function BuildWidthsArray(
  const CharProcs: TUzvPdfCharProcsArray;
  FirstChar, LastChar: Integer
): TDoubleDynArray;
var
  I, J: Integer;
  Found: Boolean;
begin
  // Создаём массив нужного размера
  // Create array of required size
  SetLength(Result, LastChar - FirstChar + 1);

  // Инициализируем нулями (ширина для отсутствующих глифов)
  // Initialize with zeros (width for missing glyphs)
  for I := 0 to High(Result) do
    Result[I] := 0.0;

  // Заполняем ширины из CharProcs
  // Fill widths from CharProcs
  for I := 0 to High(CharProcs) do
  begin
    J := CharProcs[I].CharCode - FirstChar;
    if (J >= 0) and (J <= High(Result)) then
      Result[J] := CharProcs[I].Width;
  end;
end;

// Сгенерировать словарь /Encoding для Type3 Font
function GenerateEncodingDict(const CharProcs: TUzvPdfCharProcsArray): AnsiString;
var
  SB: AnsiString;
  I: Integer;
  LastCode: Integer;
begin
  // Формат:
  // << /Type /Encoding
  //    /Differences [firstchar /name1 /name2 ... nextfirst /nameN ...] >>
  // Format:
  // << /Type /Encoding
  //    /Differences [firstchar /name1 /name2 ... nextfirst /nameN ...] >>

  SB := PDF_DICT_BEGIN + PDF_NEWLINE;
  SB := SB + '  /Type /Encoding' + PDF_NEWLINE;
  SB := SB + '  /Differences ' + PDF_ARRAY_BEGIN;

  // Сортируем CharProcs по коду символа для корректного Differences
  // Sort CharProcs by char code for correct Differences
  // Примечание: предполагаем, что CharProcs уже отсортированы
  // Note: assuming CharProcs are already sorted

  LastCode := -2;  // Невозможное значение / Impossible value
  for I := 0 to High(CharProcs) do
  begin
    // Если код не следует непосредственно за предыдущим,
    // добавляем новый индекс
    // If code doesn't immediately follow previous,
    // add new index
    if CharProcs[I].CharCode <> LastCode + 1 then
      SB := SB + PDF_SPACE + IntToStr(CharProcs[I].CharCode);

    SB := SB + PDF_SPACE + '/' + CharProcs[I].CharName;
    LastCode := CharProcs[I].CharCode;
  end;

  SB := SB + PDF_ARRAY_END + PDF_NEWLINE;
  SB := SB + PDF_DICT_END;

  Result := SB;
end;

// Сгенерировать массив /Widths для Type3 Font
function GenerateWidthsArray(
  const CharProcs: TUzvPdfCharProcsArray;
  FirstChar, LastChar: Integer;
  Precision: Integer
): AnsiString;
var
  SB: AnsiString;
  Widths: TDoubleDynArray;
  I: Integer;
begin
  Widths := BuildWidthsArray(CharProcs, FirstChar, LastChar);

  SB := PDF_ARRAY_BEGIN;
  for I := 0 to High(Widths) do
  begin
    if I > 0 then
      SB := SB + PDF_SPACE;
    SB := SB + FormatPdfNumber(Widths[I], Precision);
  end;
  SB := SB + PDF_ARRAY_END;

  Result := SB;
end;

// Сгенерировать /FontBBox для Type3 Font
function GenerateFontBBoxArray(
  const BBox: TUzvPdfBBox;
  Precision: Integer
): AnsiString;
begin
  // Формат: [llx lly urx ury]
  // Format: [llx lly urx ury]
  if IsPdfBBoxEmpty(BBox) then
  begin
    // Пустой bounding box - возвращаем нулевой
    // Empty bounding box - return zero
    Result := '[0 0 0 0]';
  end
  else
  begin
    Result := PDF_ARRAY_BEGIN +
      FormatPdfNumber(BBox.MinX, Precision) + PDF_SPACE +
      FormatPdfNumber(BBox.MinY, Precision) + PDF_SPACE +
      FormatPdfNumber(BBox.MaxX, Precision) + PDF_SPACE +
      FormatPdfNumber(BBox.MaxY, Precision) +
      PDF_ARRAY_END;
  end;
end;

// Сгенерировать /FontMatrix (единичная матрица)
function GenerateFontMatrix: AnsiString;
begin
  // Единичная матрица: [1 0 0 1 0 0]
  // Координаты уже в мировой системе после Этапа 3,
  // поэтому дополнительные преобразования не нужны
  // Identity matrix: [1 0 0 1 0 0]
  // Coordinates are already in world system after Stage 3,
  // so no additional transformations needed
  Result := '[1 0 0 1 0 0]';
end;

// Сгенерировать словарь /CharProcs (только имена)
function GenerateCharProcsDict(const CharProcs: TUzvPdfCharProcsArray): AnsiString;
var
  SB: AnsiString;
  I: Integer;
begin
  // Формат:
  // << /gXX refXX /gYY refYY ... >>
  // Примечание: реальные ссылки на объекты добавляются PDF-экспортером
  // Здесь просто список имён для документации
  // Format:
  // << /gXX refXX /gYY refYY ... >>
  // Note: actual object references are added by PDF exporter
  // Here we just list names for documentation

  SB := PDF_DICT_BEGIN + PDF_NEWLINE;
  for I := 0 to High(CharProcs) do
  begin
    // Формат: /gXX (placeholder для ссылки на объект)
    // Format: /gXX (placeholder for object reference)
    SB := SB + '  /' + CharProcs[I].CharName + ' (stream)' + PDF_NEWLINE;
  end;
  SB := SB + PDF_DICT_END;

  Result := SB;
end;

// Собрать полное описание Type3 Font объекта
function BuildType3FontObject(const Font: TUzvPdfType3Font): AnsiString;
var
  SB: AnsiString;
begin
  // Формируем полное описание Type3 Font
  // Build complete Type3 Font description
  //
  // Примечание: это шаблон, реальные ссылки на объекты
  // добавляются PDF-экспортером CAD-системы
  // Note: this is a template, actual object references
  // are added by CAD system's PDF exporter

  SB := PDF_DICT_BEGIN + PDF_NEWLINE;
  SB := SB + '  /Type /Font' + PDF_NEWLINE;
  SB := SB + '  /Subtype /Type3' + PDF_NEWLINE;
  SB := SB + '  /FontBBox ' + GenerateFontBBoxArray(Font.FontBBox, 4) + PDF_NEWLINE;
  SB := SB + '  /FontMatrix ' + GenerateFontMatrix + PDF_NEWLINE;
  SB := SB + '  /FirstChar ' + IntToStr(Font.FirstChar) + PDF_NEWLINE;
  SB := SB + '  /LastChar ' + IntToStr(Font.LastChar) + PDF_NEWLINE;
  SB := SB + '  /Widths ' +
    GenerateWidthsArray(Font.CharProcs, Font.FirstChar, Font.LastChar, 4) +
    PDF_NEWLINE;
  SB := SB + '  /Encoding ' + GenerateEncodingDict(Font.CharProcs) + PDF_NEWLINE;
  SB := SB + '  /CharProcs ' + GenerateCharProcsDict(Font.CharProcs) + PDF_NEWLINE;
  SB := SB + '  /Resources << >>' + PDF_NEWLINE;
  SB := SB + PDF_DICT_END;

  Result := SB;
end;

end.
