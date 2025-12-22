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
  Модуль: uzvshxtopdfcmaptesthelper
  Назначение: Вспомогательные функции для тестирования CMap модуля

  Данный модуль содержит:
  - Функции создания тестовых данных
  - Функции проверки результатов
  - Общие утилиты для тестов

  Зависимости:
  - uzvshxtopdfcmaptypes: типы данных этапа 5
  - uzvshxtopdfcharprocstypes: типы данных этапа 4
  - uzclog: логирование

  Module: uzvshxtopdfcmaptesthelper
  Purpose: Helper functions for CMap module testing

  This module contains:
  - Test data creation functions
  - Result verification functions
  - Common test utilities

  Dependencies:
  - uzvshxtopdfcmaptypes: Stage 5 data types
  - uzvshxtopdfcharprocstypes: Stage 4 data types
  - uzclog: logging
}

unit uzvshxtopdfcmaptesthelper;

{$mode objfpc}{$H+}

interface

uses
  SysUtils,
  uzvshxtopdfcmaptypes,
  uzvshxtopdfcharprocstypes,
  uzclog;

// Создать тестовый Type3 Font с заданным количеством глифов
// Create test Type3 Font with specified number of glyphs
function CreateTestType3Font(GlyphCount: Integer): TUzvPdfType3Font;

// Создать тестовый Type3 Font с ASCII символами
// Create test Type3 Font with ASCII characters
function CreateTestType3FontAscii: TUzvPdfType3Font;

// Создать тестовый Type3 Font с кириллицей (Windows-1251)
// Create test Type3 Font with Cyrillic characters (Windows-1251)
function CreateTestType3FontCyrillic: TUzvPdfType3Font;

// Создать тестовый Type3 Font со смешанными символами
// Create test Type3 Font with mixed characters
function CreateTestType3FontMixed: TUzvPdfType3Font;

// Создать тестовый массив CharProcs
// Create test CharProcs array
function CreateTestCharProcs(const CharCodes: array of Integer): TUzvPdfCharProcsArray;

// Проверить наличие текста в строке
// Check if text is present in string
function ContainsText(const Str, SubStr: AnsiString): Boolean;

// Подсчитать количество вхождений подстроки
// Count substring occurrences
function CountOccurrences(const Str, SubStr: AnsiString): Integer;

// Проверить формат hex-строки CMap
// Verify CMap hex string format
function IsValidCMapHexFormat(const HexStr: AnsiString): Boolean;

implementation

const
  LOG_PREFIX = 'CMapTestHelper: ';

// Создать тестовый CharProc
// Create test CharProc
function CreateTestCharProc(CharCode: Integer): TUzvPdfCharProc;
begin
  Result.CharCode := CharCode;
  Result.CharName := 'g' + IntToStr(CharCode);
  Result.Stream := 'q' + #10 + '0 0 m' + #10 + '10 0 l' + #10 + 'S' + #10 + 'Q';
  Result.Width := 10.0;
  Result.BBox := CreateEmptyPdfBBox;
  Result.BBox.MinX := 0;
  Result.BBox.MinY := 0;
  Result.BBox.MaxX := 10;
  Result.BBox.MaxY := 10;
end;

// Создать тестовый Type3 Font с заданным количеством глифов
function CreateTestType3Font(GlyphCount: Integer): TUzvPdfType3Font;
var
  I: Integer;
begin
  Result := CreateEmptyType3Font;

  if GlyphCount <= 0 then
    Exit;

  SetLength(Result.CharProcs, GlyphCount);
  for I := 0 to GlyphCount - 1 do
    Result.CharProcs[I] := CreateTestCharProc(65 + I); // A, B, C, ...

  Result.FirstChar := 65;
  Result.LastChar := 65 + GlyphCount - 1;

  SetLength(Result.Widths, GlyphCount);
  for I := 0 to GlyphCount - 1 do
    Result.Widths[I] := 10.0;

  Result.FontBBox.MinX := 0;
  Result.FontBBox.MinY := 0;
  Result.FontBBox.MaxX := 10;
  Result.FontBBox.MaxY := 10;
end;

// Создать тестовый Type3 Font с ASCII символами
function CreateTestType3FontAscii: TUzvPdfType3Font;
var
  AsciiCodes: array[0..5] of Integer = (65, 66, 67, 49, 50, 43); // A, B, C, 1, 2, +
  I: Integer;
begin
  Result := CreateEmptyType3Font;

  SetLength(Result.CharProcs, Length(AsciiCodes));
  for I := 0 to High(AsciiCodes) do
    Result.CharProcs[I] := CreateTestCharProc(AsciiCodes[I]);

  Result.FirstChar := 43;  // +
  Result.LastChar := 67;   // C

  SetLength(Result.Widths, Result.LastChar - Result.FirstChar + 1);
  for I := 0 to High(Result.Widths) do
    Result.Widths[I] := 10.0;

  Result.FontBBox.MinX := 0;
  Result.FontBBox.MinY := 0;
  Result.FontBBox.MaxX := 10;
  Result.FontBBox.MaxY := 10;
end;

// Создать тестовый Type3 Font с кириллицей (Windows-1251)
function CreateTestType3FontCyrillic: TUzvPdfType3Font;
var
  // А, Б, В в Windows-1251: $C0, $C1, $C2
  CyrillicCodes: array[0..2] of Integer = ($C0, $C1, $C2);
  I: Integer;
begin
  Result := CreateEmptyType3Font;

  SetLength(Result.CharProcs, Length(CyrillicCodes));
  for I := 0 to High(CyrillicCodes) do
    Result.CharProcs[I] := CreateTestCharProc(CyrillicCodes[I]);

  Result.FirstChar := $C0;
  Result.LastChar := $C2;

  SetLength(Result.Widths, Result.LastChar - Result.FirstChar + 1);
  for I := 0 to High(Result.Widths) do
    Result.Widths[I] := 10.0;

  Result.FontBBox.MinX := 0;
  Result.FontBBox.MinY := 0;
  Result.FontBBox.MaxX := 10;
  Result.FontBBox.MaxY := 10;
end;

// Создать тестовый Type3 Font со смешанными символами
function CreateTestType3FontMixed: TUzvPdfType3Font;
var
  // A, B, C + А, Б, В (Windows-1251) + 1, 2, 3
  MixedCodes: array[0..8] of Integer = (65, 66, 67, $C0, $C1, $C2, 49, 50, 51);
  I: Integer;
begin
  Result := CreateEmptyType3Font;

  SetLength(Result.CharProcs, Length(MixedCodes));
  for I := 0 to High(MixedCodes) do
    Result.CharProcs[I] := CreateTestCharProc(MixedCodes[I]);

  // Определяем диапазон
  // Determine range
  Result.FirstChar := 49;   // '1'
  Result.LastChar := $C2;   // 'В'

  SetLength(Result.Widths, Result.LastChar - Result.FirstChar + 1);
  for I := 0 to High(Result.Widths) do
    Result.Widths[I] := 10.0;

  Result.FontBBox.MinX := 0;
  Result.FontBBox.MinY := 0;
  Result.FontBBox.MaxX := 10;
  Result.FontBBox.MaxY := 10;
end;

// Создать тестовый массив CharProcs
function CreateTestCharProcs(const CharCodes: array of Integer): TUzvPdfCharProcsArray;
var
  I: Integer;
begin
  SetLength(Result, Length(CharCodes));
  for I := 0 to High(CharCodes) do
    Result[I] := CreateTestCharProc(CharCodes[I]);
end;

// Проверить наличие текста в строке
function ContainsText(const Str, SubStr: AnsiString): Boolean;
begin
  Result := Pos(SubStr, Str) > 0;
end;

// Подсчитать количество вхождений подстроки
function CountOccurrences(const Str, SubStr: AnsiString): Integer;
var
  P: Integer;
  SearchStr: AnsiString;
begin
  Result := 0;
  SearchStr := Str;

  P := Pos(SubStr, SearchStr);
  while P > 0 do
  begin
    Inc(Result);
    Delete(SearchStr, 1, P + Length(SubStr) - 1);
    P := Pos(SubStr, SearchStr);
  end;
end;

// Проверить формат hex-строки CMap
function IsValidCMapHexFormat(const HexStr: AnsiString): Boolean;
var
  I: Integer;
  InBracket: Boolean;
begin
  Result := False;

  // Должна начинаться с '<' и заканчиваться '>'
  // Must start with '<' and end with '>'
  if (Length(HexStr) < 3) then
    Exit;
  if (HexStr[1] <> '<') or (HexStr[Length(HexStr)] <> '>') then
    Exit;

  // Проверяем содержимое между скобками
  // Check content between brackets
  InBracket := False;
  for I := 1 to Length(HexStr) do
  begin
    if HexStr[I] = '<' then
    begin
      if InBracket then
        Exit; // Вложенные скобки / Nested brackets
      InBracket := True;
    end
    else if HexStr[I] = '>' then
    begin
      if not InBracket then
        Exit; // Закрывающая без открывающей / Closing without opening
      InBracket := False;
    end
    else if InBracket then
    begin
      // Внутри скобок только hex-символы
      // Inside brackets only hex characters
      if not (HexStr[I] in ['0'..'9', 'A'..'F', 'a'..'f']) then
        Exit;
    end;
  end;

  Result := not InBracket; // Все скобки закрыты / All brackets closed
end;

end.
