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
  Модуль: uzvshxtopdfcharprocs
  Назначение: Основной интерфейс Этапа 4 конвейера SHX -> PDF

  Данный модуль является точкой входа для Этапа 4:
  - Принимает результат Этапа 3 (TUzvWorldBezierFont)
  - Генерирует CharProcs для каждого глифа
  - Формирует объект Type3 Font
  - Возвращает TUzvPdfType3Font для PDF-экспортера

  ВАЖНО: Этот модуль НЕ выполняет трансформации!
  Координаты уже приведены к мировой системе на Этапе 3.

  Зависимости:
  - uzvshxtopdfcharprocstypes: типы данных этапа 4
  - uzvshxtopdfcharprocsbbox: расчёт bounding box
  - uzvshxtopdfcharprocswriter: генерация path stream
  - uzvshxtopdfcharprocsfont: генерация Type3 Font
  - uzvshxtopdftransformtypes: типы данных этапа 3
  - uzclog: логирование

  Module: uzvshxtopdfcharprocs
  Purpose: Main interface for Stage 4 of SHX -> PDF pipeline

  This module is the entry point for Stage 4:
  - Accepts Stage 3 result (TUzvWorldBezierFont)
  - Generates CharProcs for each glyph
  - Builds Type3 Font object
  - Returns TUzvPdfType3Font for PDF exporter

  IMPORTANT: This module does NOT perform transformations!
  Coordinates are already in world system from Stage 3.

  Dependencies:
  - uzvshxtopdfcharprocstypes: Stage 4 data types
  - uzvshxtopdfcharprocsbbox: bounding box calculation
  - uzvshxtopdfcharprocswriter: path stream generation
  - uzvshxtopdfcharprocsfont: Type3 Font generation
  - uzvshxtopdftransformtypes: Stage 3 data types
  - uzclog: logging
}

unit uzvshxtopdfcharprocs;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Math,
  uzvshxtopdfapprogeomtypes,
  uzvshxtopdftransformtypes,
  uzvshxtopdfcharprocstypes,
  uzvshxtopdfcharprocsbbox,
  uzvshxtopdfcharprocswriter,
  uzvshxtopdfcharprocsfont,
  uzclog;

// Основная функция Этапа 4: построение Type3 Font из World Bezier Font
// Main Stage 4 function: build Type3 Font from World Bezier Font
//
// Параметры:
//   Font: TUzvWorldBezierFont - результат Этапа 3 (мировые координаты)
//   GlyphWidths: array of Double - ширины глифов (advance width)
//                Если пустой, используются ширины из bounding box
//   Params: TUzvCharProcsParams - параметры генерации CharProcs
//
// Возвращает:
//   TUzvPdfType3Font - полное описание Type3 шрифта для PDF
//
// Parameters:
//   Font: TUzvWorldBezierFont - Stage 3 result (world coordinates)
//   GlyphWidths: array of Double - glyph widths (advance width)
//                If empty, bounding box widths are used
//   Params: TUzvCharProcsParams - CharProcs generation parameters
//
// Returns:
//   TUzvPdfType3Font - complete Type3 font description for PDF
function BuildType3FontCharProcs(
  const Font: TUzvWorldBezierFont;
  const GlyphWidths: array of Double;
  const Params: TUzvCharProcsParams
): TUzvPdfType3Font;

// Упрощённая версия: использует параметры по умолчанию
// Simplified version: uses default parameters
function BuildType3FontCharProcsSimple(
  const Font: TUzvWorldBezierFont;
  const GlyphWidths: array of Double
): TUzvPdfType3Font;

// Версия с автоматическим вычислением ширин из bounding box
// Version with automatic width calculation from bounding box
function BuildType3FontCharProcsAuto(
  const Font: TUzvWorldBezierFont
): TUzvPdfType3Font;

// Сгенерировать CharProcs для подмножества глифов
// Generate CharProcs for subset of glyphs
function BuildCharProcsSubset(
  const Font: TUzvWorldBezierFont;
  const CharCodes: array of Integer;
  const GlyphWidths: array of Double;
  const Params: TUzvCharProcsParams
): TUzvPdfCharProcsArray;

// Найти ширину глифа по коду символа
// Find glyph width by character code
function FindGlyphWidth(
  const Font: TUzvWorldBezierFont;
  const GlyphWidths: array of Double;
  CharCode: Integer
): Double;

// Получить количество уникальных глифов в шрифте
// Get number of unique glyphs in font
function GetUniqueGlyphCount(const Font: TUzvWorldBezierFont): Integer;

// Получить список уникальных кодов символов
// Get list of unique character codes
function GetUniqueCharCodes(const Font: TUzvWorldBezierFont): TIntegerDynArray;

type
  // Динамический массив Integer
  // Dynamic array of Integer
  TIntegerDynArray = array of Integer;

implementation

// Константа для логирования
// Logging constant
const
  LOG_PREFIX = 'CharProcs: ';

// Сортировка массива CharProcs по коду символа (пузырьковая сортировка)
// Sort CharProcs array by char code (bubble sort)
procedure SortCharProcsByCode(var CharProcs: TUzvPdfCharProcsArray);
var
  I, J: Integer;
  Temp: TUzvPdfCharProc;
begin
  for I := 0 to High(CharProcs) - 1 do
  begin
    for J := I + 1 to High(CharProcs) do
    begin
      if CharProcs[J].CharCode < CharProcs[I].CharCode then
      begin
        Temp := CharProcs[I];
        CharProcs[I] := CharProcs[J];
        CharProcs[J] := Temp;
      end;
    end;
  end;
end;

// Найти глиф по коду символа
// Find glyph by character code
function FindGlyphByCode(
  const Font: TUzvWorldBezierFont;
  CharCode: Integer;
  out GlyphIndex: Integer
): Boolean;
var
  I: Integer;
begin
  Result := False;
  GlyphIndex := -1;

  for I := 0 to High(Font.Glyphs) do
  begin
    if Font.Glyphs[I].Code = CharCode then
    begin
      GlyphIndex := I;
      Result := True;
      Exit;
    end;
  end;
end;

// Найти ширину глифа по коду символа
function FindGlyphWidth(
  const Font: TUzvWorldBezierFont;
  const GlyphWidths: array of Double;
  CharCode: Integer
): Double;
var
  I: Integer;
  GlyphIndex: Integer;
  BBox: TUzvPdfBBox;
begin
  Result := 0.0;

  // Если есть массив ширин, используем его
  // If widths array is provided, use it
  if Length(GlyphWidths) > 0 then
  begin
    // Ищем глиф по коду
    // Find glyph by code
    for I := 0 to High(Font.Glyphs) do
    begin
      if Font.Glyphs[I].Code = CharCode then
      begin
        // Если индекс в пределах массива ширин
        // If index is within widths array
        if I <= High(GlyphWidths) then
          Result := GlyphWidths[I]
        else
        begin
          // Иначе вычисляем из bounding box
          // Otherwise calculate from bounding box
          BBox := CalcGlyphBBox(Font.Glyphs[I]);
          Result := GetPdfBBoxWidth(BBox);
        end;
        Exit;
      end;
    end;
  end
  else
  begin
    // Вычисляем ширину из bounding box
    // Calculate width from bounding box
    if FindGlyphByCode(Font, CharCode, GlyphIndex) then
    begin
      BBox := CalcGlyphBBox(Font.Glyphs[GlyphIndex]);
      Result := GetPdfBBoxWidth(BBox);
    end;
  end;
end;

// Получить количество уникальных глифов в шрифте
function GetUniqueGlyphCount(const Font: TUzvWorldBezierFont): Integer;
begin
  Result := Length(Font.Glyphs);
end;

// Получить список уникальных кодов символов
function GetUniqueCharCodes(const Font: TUzvWorldBezierFont): TIntegerDynArray;
var
  I: Integer;
begin
  SetLength(Result, Length(Font.Glyphs));
  for I := 0 to High(Font.Glyphs) do
    Result[I] := Font.Glyphs[I].Code;
end;

// Сгенерировать CharProcs для подмножества глифов
function BuildCharProcsSubset(
  const Font: TUzvWorldBezierFont;
  const CharCodes: array of Integer;
  const GlyphWidths: array of Double;
  const Params: TUzvCharProcsParams
): TUzvPdfCharProcsArray;
var
  I: Integer;
  GlyphIndex: Integer;
  Width: Double;
  CharProc: TUzvPdfCharProc;
begin
  SetLength(Result, 0);

  for I := 0 to High(CharCodes) do
  begin
    if FindGlyphByCode(Font, CharCodes[I], GlyphIndex) then
    begin
      // Получаем ширину глифа
      // Get glyph width
      Width := FindGlyphWidth(Font, GlyphWidths, CharCodes[I]);

      // Создаём CharProc
      // Create CharProc
      CharProc := CreateCharProc(
        Font.Glyphs[GlyphIndex],
        Width,
        Params
      );

      // Добавляем в массив
      // Add to array
      SetLength(Result, Length(Result) + 1);
      Result[High(Result)] := CharProc;
    end;
  end;

  // Сортируем по коду символа
  // Sort by char code
  SortCharProcsByCode(Result);
end;

// Основная функция Этапа 4: построение Type3 Font
function BuildType3FontCharProcs(
  const Font: TUzvWorldBezierFont;
  const GlyphWidths: array of Double;
  const Params: TUzvCharProcsParams
): TUzvPdfType3Font;
var
  I: Integer;
  CharProc: TUzvPdfCharProc;
  Width: Double;
  FirstChar, LastChar: Integer;
begin
  // Логирование: начало генерации
  // Logging: start generation
  programlog.LogOutFormatStr(
    LOG_PREFIX + 'начало генерации CharProcs, глифов: %d',
    [Length(Font.Glyphs)],
    LM_Info
  );

  // Инициализация результата
  // Initialize result
  Result := CreateEmptyType3Font;

  // Проверка на пустой шрифт
  // Check for empty font
  if Length(Font.Glyphs) = 0 then
  begin
    programlog.LogOutStr(
      LOG_PREFIX + 'пустой шрифт, возврат пустого Type3Font',
      LM_Info
    );
    Exit;
  end;

  // Генерируем CharProcs для всех глифов
  // Generate CharProcs for all glyphs
  SetLength(Result.CharProcs, Length(Font.Glyphs));
  for I := 0 to High(Font.Glyphs) do
  begin
    // Получаем ширину глифа
    // Get glyph width
    if I <= High(GlyphWidths) then
      Width := GlyphWidths[I]
    else
    begin
      // Вычисляем из bounding box
      // Calculate from bounding box
      Width := GetPdfBBoxWidth(CalcGlyphBBox(Font.Glyphs[I]));
    end;

    // Создаём CharProc
    // Create CharProc
    CharProc := CreateCharProc(
      Font.Glyphs[I],
      Width,
      Params
    );
    Result.CharProcs[I] := CharProc;

    // Логирование: сгенерирован глиф
    // Logging: glyph generated
    programlog.LogOutFormatStr(
      LOG_PREFIX + 'сгенерирован глиф code=%d, width=%.4f',
      [CharProc.CharCode, CharProc.Width],
      LM_Info
    );
  end;

  // Сортируем CharProcs по коду символа
  // Sort CharProcs by char code
  SortCharProcsByCode(Result.CharProcs);

  // Вычисляем FirstChar и LastChar
  // Calculate FirstChar and LastChar
  CalcCharRange(Result.CharProcs, FirstChar, LastChar);
  Result.FirstChar := FirstChar;
  Result.LastChar := LastChar;

  // Строим массив Widths
  // Build Widths array
  Result.Widths := BuildWidthsArray(
    Result.CharProcs,
    Result.FirstChar,
    Result.LastChar
  );

  // Вычисляем FontBBox
  // Calculate FontBBox
  Result.FontBBox := CalcFontBBox(Font);

  // Логирование: FontBBox
  // Logging: FontBBox
  programlog.LogOutFormatStr(
    LOG_PREFIX + 'FontBBox: [%.4f %.4f %.4f %.4f]',
    [Result.FontBBox.MinX, Result.FontBBox.MinY,
     Result.FontBBox.MaxX, Result.FontBBox.MaxY],
    LM_Info
  );

  // Генерируем FontObjectStream
  // Generate FontObjectStream
  Result.FontObjectStream := BuildType3FontObject(Result);

  // Логирование: завершение генерации
  // Logging: generation complete
  programlog.LogOutFormatStr(
    LOG_PREFIX + 'завершение генерации Type3Font, CharProcs: %d, ' +
    'FirstChar: %d, LastChar: %d',
    [Length(Result.CharProcs), Result.FirstChar, Result.LastChar],
    LM_Info
  );
end;

// Упрощённая версия: использует параметры по умолчанию
function BuildType3FontCharProcsSimple(
  const Font: TUzvWorldBezierFont;
  const GlyphWidths: array of Double
): TUzvPdfType3Font;
begin
  Result := BuildType3FontCharProcs(
    Font,
    GlyphWidths,
    GetDefaultCharProcsParams
  );
end;

// Версия с автоматическим вычислением ширин из bounding box
function BuildType3FontCharProcsAuto(
  const Font: TUzvWorldBezierFont
): TUzvPdfType3Font;
var
  EmptyWidths: array of Double;
begin
  SetLength(EmptyWidths, 0);
  Result := BuildType3FontCharProcs(
    Font,
    EmptyWidths,
    GetDefaultCharProcsParams
  );
end;

end.
