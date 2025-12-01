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
  Модуль: uzvshxtopdfcmapwriter
  Назначение: Генерация ToUnicode CMap стрима для PDF

  Данный модуль предоставляет функции для формирования
  корректного PDF ToUnicode CMap потока согласно спецификации PDF.

  Формат CMap стрима:
    /CIDInit /ProcSet findresource begin
    12 dict begin
    begincmap
    /CIDSystemInfo << /Registry (Adobe) /Ordering (UCS) /Supplement 0 >> def
    /CMapName /XXX def
    /CMapType 2 def
    1 begincodespacerange <00> <FF> endcodespacerange
    N beginbfchar
      <XX> <YYYY>
      ...
    endbfchar
    endcmap
    CMapName currentdict /CMap defineresource pop
    end
    end

  Зависимости:
  - uzvshxtopdfcmaptypes: типы данных этапа 5

  Module: uzvshxtopdfcmapwriter
  Purpose: ToUnicode CMap stream generation for PDF

  This module provides functions for generating
  correct PDF ToUnicode CMap stream per PDF specification.

  CMap stream format:
    /CIDInit /ProcSet findresource begin
    12 dict begin
    begincmap
    /CIDSystemInfo << /Registry (Adobe) /Ordering (UCS) /Supplement 0 >> def
    /CMapName /XXX def
    /CMapType 2 def
    1 begincodespacerange <00> <FF> endcodespacerange
    N beginbfchar
      <XX> <YYYY>
      ...
    endbfchar
    endcmap
    CMapName currentdict /CMap defineresource pop
    end
    end

  Dependencies:
  - uzvshxtopdfcmaptypes: Stage 5 data types
}

unit uzvshxtopdfcmapwriter;

{$mode objfpc}{$H+}

interface

uses
  SysUtils,
  uzvshxtopdfcmaptypes;

// Сгенерировать полный ToUnicode CMap стрим
// Generate complete ToUnicode CMap stream
function GenerateCMapStream(
  const Mappings: TUzvUnicodeMappingArray;
  const Params: TUzvCMapParams
): AnsiString;

// Сгенерировать заголовок CMap
// Generate CMap header
function GenerateCMapHeader(
  const CMapName: AnsiString;
  UseTwoByteCodespace: Boolean
): AnsiString;

// Сгенерировать секцию codespacerange
// Generate codespacerange section
function GenerateCodespaceRange(
  UseTwoByteCodespace: Boolean
): AnsiString;

// Сгенерировать секции bfchar
// Generate bfchar sections
function GenerateBfcharSections(
  const Mappings: TUzvUnicodeMappingArray;
  MaxEntriesPerBlock: Integer;
  IncludeComments: Boolean
): AnsiString;

// Сгенерировать завершение CMap
// Generate CMap footer
function GenerateCMapFooter(const CMapName: AnsiString): AnsiString;

// Форматировать код символа как hex-строку PDF
// Format character code as PDF hex string
function FormatCharCodeHex(
  CharCode: Integer;
  UseTwoBytes: Boolean
): AnsiString;

// Форматировать Unicode значение как hex-строку PDF
// Format Unicode value as PDF hex string
function FormatUnicodeHex(UnicodeValue: Integer): AnsiString;

// Сортировать маппинги по коду символа
// Sort mappings by character code
procedure SortMappingsByCharCode(var Mappings: TUzvUnicodeMappingArray);

implementation

const
  // Символ новой строки для CMap стрима
  // Newline character for CMap stream
  CMAP_NEWLINE = #10;

  // Максимум записей в одном блоке bfchar (по спецификации PDF)
  // Maximum entries per bfchar block (per PDF specification)
  MAX_BFCHAR_ENTRIES = 100;

// Форматировать код символа как hex-строку PDF
function FormatCharCodeHex(
  CharCode: Integer;
  UseTwoBytes: Boolean
): AnsiString;
begin
  if UseTwoBytes then
    // Два байта: <XXXX>
    // Two bytes: <XXXX>
    Result := '<' + IntToHex(CharCode, 4) + '>'
  else
    // Один байт: <XX>
    // One byte: <XX>
    Result := '<' + IntToHex(CharCode and $FF, 2) + '>';
end;

// Форматировать Unicode значение как hex-строку PDF
function FormatUnicodeHex(UnicodeValue: Integer): AnsiString;
begin
  // Unicode всегда минимум 2 байта
  // Unicode is always at least 2 bytes
  if UnicodeValue > $FFFF then
    // Суррогатная пара для символов выше BMP (редко для SHX)
    // Surrogate pair for characters above BMP (rare for SHX)
    Result := '<' + IntToHex(UnicodeValue, 6) + '>'
  else
    // Стандартный 2-байтовый Unicode
    // Standard 2-byte Unicode
    Result := '<' + IntToHex(UnicodeValue, 4) + '>';
end;

// Сортировать маппинги по коду символа (пузырьковая сортировка)
// Sort mappings by character code (bubble sort)
procedure SortMappingsByCharCode(var Mappings: TUzvUnicodeMappingArray);
var
  I, J: Integer;
  Temp: TUzvUnicodeMapping;
begin
  for I := 0 to High(Mappings) - 1 do
  begin
    for J := I + 1 to High(Mappings) do
    begin
      if Mappings[J].CharCode < Mappings[I].CharCode then
      begin
        Temp := Mappings[I];
        Mappings[I] := Mappings[J];
        Mappings[J] := Temp;
      end;
    end;
  end;
end;

// Сгенерировать заголовок CMap
function GenerateCMapHeader(
  const CMapName: AnsiString;
  UseTwoByteCodespace: Boolean
): AnsiString;
var
  SB: AnsiString;
begin
  // Заголовок CMap согласно спецификации PDF
  // CMap header per PDF specification
  SB := '/CIDInit /ProcSet findresource begin' + CMAP_NEWLINE;
  SB := SB + '12 dict begin' + CMAP_NEWLINE;
  SB := SB + 'begincmap' + CMAP_NEWLINE;

  // CIDSystemInfo - обязательный словарь
  // CIDSystemInfo - required dictionary
  SB := SB + '/CIDSystemInfo <<' + CMAP_NEWLINE;
  SB := SB + '  /Registry (Adobe)' + CMAP_NEWLINE;
  SB := SB + '  /Ordering (UCS)' + CMAP_NEWLINE;
  SB := SB + '  /Supplement 0' + CMAP_NEWLINE;
  SB := SB + '>> def' + CMAP_NEWLINE;

  // Имя CMap
  // CMap name
  SB := SB + '/CMapName /' + CMapName + ' def' + CMAP_NEWLINE;

  // Тип CMap (2 = ToUnicode)
  // CMap type (2 = ToUnicode)
  SB := SB + '/CMapType 2 def' + CMAP_NEWLINE;

  Result := SB;
end;

// Сгенерировать секцию codespacerange
function GenerateCodespaceRange(UseTwoByteCodespace: Boolean): AnsiString;
var
  SB: AnsiString;
begin
  SB := '1 begincodespacerange' + CMAP_NEWLINE;

  if UseTwoByteCodespace then
    // Двухбайтовый диапазон
    // Two-byte range
    SB := SB + '<0000> <FFFF>' + CMAP_NEWLINE
  else
    // Однобайтовый диапазон
    // One-byte range
    SB := SB + '<00> <FF>' + CMAP_NEWLINE;

  SB := SB + 'endcodespacerange' + CMAP_NEWLINE;

  Result := SB;
end;

// Сгенерировать одну секцию bfchar
// Generate one bfchar section
function GenerateBfcharSection(
  const Mappings: TUzvUnicodeMappingArray;
  StartIndex, Count: Integer;
  UseTwoBytes: Boolean;
  IncludeComments: Boolean
): AnsiString;
var
  SB: AnsiString;
  I: Integer;
  Mapping: TUzvUnicodeMapping;
begin
  SB := IntToStr(Count) + ' beginbfchar' + CMAP_NEWLINE;

  for I := StartIndex to StartIndex + Count - 1 do
  begin
    Mapping := Mappings[I];
    SB := SB + FormatCharCodeHex(Mapping.CharCode, UseTwoBytes);
    SB := SB + ' ';
    SB := SB + FormatUnicodeHex(Mapping.UnicodeValue);

    // Добавляем комментарий с символом (для отладки)
    // Add comment with character (for debugging)
    if IncludeComments then
    begin
      SB := SB + ' % ';
      // Для печатаемых ASCII символов показываем сам символ
      // For printable ASCII characters show the character itself
      if (Mapping.UnicodeValue >= $20) and (Mapping.UnicodeValue < $7F) then
        SB := SB + Chr(Mapping.UnicodeValue)
      else
        SB := SB + 'U+' + IntToHex(Mapping.UnicodeValue, 4);
    end;

    SB := SB + CMAP_NEWLINE;
  end;

  SB := SB + 'endbfchar' + CMAP_NEWLINE;

  Result := SB;
end;

// Сгенерировать секции bfchar
function GenerateBfcharSections(
  const Mappings: TUzvUnicodeMappingArray;
  MaxEntriesPerBlock: Integer;
  IncludeComments: Boolean
): AnsiString;
var
  SB: AnsiString;
  TotalMappings: Integer;
  CurrentIndex: Integer;
  BlockSize: Integer;
  ActualMaxEntries: Integer;
  UseTwoBytes: Boolean;
  I: Integer;
begin
  SB := '';
  TotalMappings := Length(Mappings);

  if TotalMappings = 0 then
  begin
    Result := '';
    Exit;
  end;

  // Ограничиваем максимальное количество записей
  // Limit maximum entries
  ActualMaxEntries := MaxEntriesPerBlock;
  if ActualMaxEntries > MAX_BFCHAR_ENTRIES then
    ActualMaxEntries := MAX_BFCHAR_ENTRIES;
  if ActualMaxEntries < 1 then
    ActualMaxEntries := MAX_BFCHAR_ENTRIES;

  // Определяем, нужен ли 2-байтовый формат
  // Determine if 2-byte format is needed
  UseTwoBytes := False;
  for I := 0 to High(Mappings) do
  begin
    if Mappings[I].CharCode > $FF then
    begin
      UseTwoBytes := True;
      Break;
    end;
  end;

  // Генерируем блоки bfchar
  // Generate bfchar blocks
  CurrentIndex := 0;
  while CurrentIndex < TotalMappings do
  begin
    // Вычисляем размер текущего блока
    // Calculate current block size
    BlockSize := TotalMappings - CurrentIndex;
    if BlockSize > ActualMaxEntries then
      BlockSize := ActualMaxEntries;

    // Генерируем блок
    // Generate block
    SB := SB + GenerateBfcharSection(
      Mappings,
      CurrentIndex,
      BlockSize,
      UseTwoBytes,
      IncludeComments
    );

    CurrentIndex := CurrentIndex + BlockSize;
  end;

  Result := SB;
end;

// Сгенерировать завершение CMap
function GenerateCMapFooter(const CMapName: AnsiString): AnsiString;
var
  SB: AnsiString;
begin
  SB := 'endcmap' + CMAP_NEWLINE;
  SB := SB + 'CMapName currentdict /CMap defineresource pop' + CMAP_NEWLINE;
  SB := SB + 'end' + CMAP_NEWLINE;
  SB := SB + 'end' + CMAP_NEWLINE;

  Result := SB;
end;

// Сгенерировать полный ToUnicode CMap стрим
function GenerateCMapStream(
  const Mappings: TUzvUnicodeMappingArray;
  const Params: TUzvCMapParams
): AnsiString;
var
  SB: AnsiString;
  SortedMappings: TUzvUnicodeMappingArray;
  I: Integer;
begin
  // Создаём копию для сортировки
  // Create copy for sorting
  SetLength(SortedMappings, Length(Mappings));
  for I := 0 to High(Mappings) do
    SortedMappings[I] := Mappings[I];

  // Сортируем по коду символа
  // Sort by character code
  SortMappingsByCharCode(SortedMappings);

  // Собираем CMap стрим
  // Assemble CMap stream
  SB := GenerateCMapHeader(Params.CMapName, Params.UseTwoByteCodespace);
  SB := SB + GenerateCodespaceRange(Params.UseTwoByteCodespace);
  SB := SB + GenerateBfcharSections(
    SortedMappings,
    Params.MaxEntriesPerBlock,
    Params.IncludeComments
  );
  SB := SB + GenerateCMapFooter(Params.CMapName);

  Result := SB;
end;

end.
