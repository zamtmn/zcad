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

unit uzvshxtopdf_shxparser;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Math, Classes,
  uzvshxtopdf_shxglyph,
  uzvshxtopdf_shxutils,
  uzclog;

// Опкоды SHX команд (базовые)
const
  SHX_OPCODE_PEN_UP = 1;      // Поднять перо (MoveTo)
  SHX_OPCODE_PEN_DOWN = 2;    // Опустить перо (LineTo)
  SHX_OPCODE_ARC_CW = 8;      // Дуга по часовой стрелке
  SHX_OPCODE_ARC_CCW = 9;     // Дуга против часовой стрелки
  SHX_OPCODE_END = 0;         // Конец определения глифа

// Структура заголовка SHX файла
type
  TShxHeader = record
    Magic: string;           // Магическое число (строка-идентификатор)
    FontName: string;        // Имя шрифта
    UnitsPerEm: Word;        // Единиц на высоту шрифта
    ShapeCount: Word;        // Количество форм (глифов)
    DataOffset: LongWord;    // Смещение до начала данных
  end;

// Парсер SHX файла
type
  TShxParser = class
  private
    FFileName: string;
    FCodePage: Integer;
    FVerbose: Boolean;
    FCurrentX: Double;
    FCurrentY: Double;

    // Прочитать заголовок SHX файла
    function ReadHeader(var F: File): TShxHeader;

    // Прочитать таблицу смещений глифов
    function ReadOffsetTable(var F: File; ShapeCount: Word): array of LongWord;

    // Парсить один глиф начиная с указанной позиции
    function ParseGlyph(var F: File; Offset: LongWord): TShxGlyph;

    // Парсить поток команд глифа
    procedure ParseGlyphCommands(var F: File; var Glyph: TShxGlyph);

    // Прочитать координату из потока (формат SHX - 2 байта со знаком)
    function ReadCoordinate(var F: File): Double;

    // Обработать команду PenUp (MoveTo)
    procedure ProcessPenUp(var F: File; var Glyph: TShxGlyph);

    // Обработать команду PenDown (LineTo)
    procedure ProcessPenDown(var F: File; var Glyph: TShxGlyph);

    // Обработать команду Arc
    procedure ProcessArc(var F: File; var Glyph: TShxGlyph; ClockWise: Boolean);

  public
    constructor Create(const FileName: string; CodePage: Integer; Verbose: Boolean);

    // Основная функция парсинга - возвращает структуру шрифта
    function Parse: TShxFont;
  end;

implementation

constructor TShxParser.Create(
  const FileName: string;
  CodePage: Integer;
  Verbose: Boolean
);
begin
  inherited Create;
  FFileName := FileName;
  FCodePage := CodePage;
  FVerbose := Verbose;
  FCurrentX := 0.0;
  FCurrentY := 0.0;
end;

// Прочитать заголовок SHX файла
function TShxParser.ReadHeader(var F: File): TShxHeader;
var
  Buffer: array[0..25] of Byte;
  BytesRead: Integer;
  i: Integer;
begin
  // Инициализация результата
  Result.Magic := '';
  Result.FontName := '';
  Result.UnitsPerEm := 0;
  Result.ShapeCount := 0;
  Result.DataOffset := 0;

  // Читаем первые 26 байт заголовка
  BlockRead(F, Buffer, SHX_HEADER_SIZE, BytesRead);

  if BytesRead <> SHX_HEADER_SIZE then
  begin
    programlog.LogOutFormatStr(
      'Невозможно прочитать заголовок SHX файла: недостаточно данных',
      [],
      LM_Error
    );
    Exit;
  end;

  // Извлекаем имя шрифта из заголовка (первые байты - ASCII строка)
  // Базовый формат: заголовок содержит информацию о шрифте
  // Для упрощения извлекаем имя из имени файла
  Result.FontName := ExtractFileName(FFileName);
  Result.FontName := ChangeFileExt(Result.FontName, '');

  // UnitsPerEm по умолчанию (будет корректироваться при парсинге)
  Result.UnitsPerEm := 100;

  // Примечание: формат SHX-файлов AutoCAD имеет сложную структуру
  // Данная реализация предполагает упрощенный разбор базовых элементов

  if FVerbose then
  begin
    programlog.LogOutFormatStr(
      'Заголовок SHX: FontName=%s, UnitsPerEm=%d',
      [Result.FontName, Result.UnitsPerEm],
      LM_Debug
    );
  end;
end;

// Прочитать таблицу смещений глифов
function TShxParser.ReadOffsetTable(var F: File; ShapeCount: Word): array of LongWord;
var
  i: Integer;
  Offset: LongWord;
begin
  SetLength(Result, ShapeCount);

  for i := 0 to ShapeCount - 1 do
  begin
    if not SafeReadDWord(F, Offset) then
    begin
      programlog.LogOutFormatStr(
        'Ошибка чтения таблицы смещений на индексе %d',
        [i],
        LM_Warning
      );
      SetLength(Result, i);
      Break;
    end;

    Result[i] := Offset;

    if FVerbose then
    begin
      programlog.LogOutFormatStr(
        'Смещение глифа %d: %d',
        [i, Offset],
        LM_Debug
      );
    end;
  end;
end;

// Прочитать координату из потока
function TShxParser.ReadCoordinate(var F: File): Double;
var
  Value: SmallInt;
  BytesRead: Integer;
begin
  BlockRead(F, Value, SizeOf(SmallInt), BytesRead);

  if BytesRead <> SizeOf(SmallInt) then
  begin
    Result := 0.0;
    Exit;
  end;

  Result := Value;
end;

// Обработать команду PenUp (MoveTo)
procedure TShxParser.ProcessPenUp(var F: File; var Glyph: TShxGlyph);
var
  DX, DY: Double;
begin
  DX := ReadCoordinate(F);
  DY := ReadCoordinate(F);

  FCurrentX := FCurrentX + DX;
  FCurrentY := FCurrentY + DY;

  AddMoveToCommand(Glyph, FCurrentX, FCurrentY);

  if FVerbose then
  begin
    programlog.LogOutFormatStr(
      'PenUp: DX=%.2f DY=%.2f -> (%.2f, %.2f)',
      [DX, DY, FCurrentX, FCurrentY],
      LM_Debug
    );
  end;
end;

// Обработать команду PenDown (LineTo)
procedure TShxParser.ProcessPenDown(var F: File; var Glyph: TShxGlyph);
var
  DX, DY: Double;
begin
  DX := ReadCoordinate(F);
  DY := ReadCoordinate(F);

  FCurrentX := FCurrentX + DX;
  FCurrentY := FCurrentY + DY;

  AddLineToCommand(Glyph, FCurrentX, FCurrentY);

  if FVerbose then
  begin
    programlog.LogOutFormatStr(
      'PenDown: DX=%.2f DY=%.2f -> (%.2f, %.2f)',
      [DX, DY, FCurrentX, FCurrentY],
      LM_Debug
    );
  end;
end;

// Обработать команду Arc
procedure TShxParser.ProcessArc(var F: File; var Glyph: TShxGlyph; ClockWise: Boolean);
var
  CenterOffsetX, CenterOffsetY: Double;
  StartAngle, EndAngle: Double;
  Radius: Double;
  CenterX, CenterY: Double;
  AngleByte: Byte;
begin
  // Чтение смещения центра дуги
  CenterOffsetX := ReadCoordinate(F);
  CenterOffsetY := ReadCoordinate(F);

  CenterX := FCurrentX + CenterOffsetX;
  CenterY := FCurrentY + CenterOffsetY;

  // Вычисление радиуса
  Radius := CalculateDistance(FCurrentX, FCurrentY, CenterX, CenterY);

  // Чтение угловых параметров (упрощенный формат)
  if not SafeReadByte(F, AngleByte) then
    Exit;

  StartAngle := 0.0;
  EndAngle := Pi / 2;

  // В реальном формате SHX углы кодируются в байтах октантами
  // Здесь упрощенная реализация

  if ClockWise then
  begin
    AddArcCommand(Glyph, CenterX, CenterY, Radius, StartAngle, EndAngle);
  end
  else
  begin
    AddArcCommand(Glyph, CenterX, CenterY, Radius, EndAngle, StartAngle);
  end;

  // Обновление текущей позиции (конец дуги)
  FCurrentX := CenterX + Radius * Cos(EndAngle);
  FCurrentY := CenterY + Radius * Sin(EndAngle);

  if FVerbose then
  begin
    programlog.LogOutFormatStr(
      'Arc: Center=(%.2f, %.2f) Radius=%.2f CW=%d',
      [CenterX, CenterY, Radius, Ord(ClockWise)],
      LM_Debug
    );
  end;
end;

// Парсить поток команд глифа
procedure TShxParser.ParseGlyphCommands(var F: File; var Glyph: TShxGlyph);
var
  OpCode: Byte;
  Done: Boolean;
  MaxCommands: Integer;
  CommandCount: Integer;
begin
  Done := False;
  CommandCount := 0;
  MaxCommands := 1000; // Защита от бесконечного цикла

  while (not Done) and (CommandCount < MaxCommands) do
  begin
    if not SafeReadByte(F, OpCode) then
    begin
      programlog.LogOutFormatStr(
        'Неожиданный конец данных при чтении опкода',
        [],
        LM_Warning
      );
      Break;
    end;

    Inc(CommandCount);

    case OpCode of
      SHX_OPCODE_END:
      begin
        Done := True;
      end;

      SHX_OPCODE_PEN_UP:
      begin
        ProcessPenUp(F, Glyph);
      end;

      SHX_OPCODE_PEN_DOWN:
      begin
        ProcessPenDown(F, Glyph);
      end;

      SHX_OPCODE_ARC_CW:
      begin
        ProcessArc(F, Glyph, True);
      end;

      SHX_OPCODE_ARC_CCW:
      begin
        ProcessArc(F, Glyph, False);
      end;

    else
      begin
        if FVerbose then
        begin
          programlog.LogOutFormatStr(
            'Неизвестный опкод: $%2.2X',
            [OpCode],
            LM_Warning
          );
        end;
        // Пропускаем неизвестные команды
      end;
    end;
  end;

  if CommandCount >= MaxCommands then
  begin
    programlog.LogOutFormatStr(
      'Превышен лимит команд (%d) при парсинге глифа',
      [MaxCommands],
      LM_Warning
    );
  end;
end;

// Парсить один глиф
function TShxParser.ParseGlyph(var F: File; Offset: LongWord): TShxGlyph;
var
  ShapeNumber: Byte;
  ByteCount: Word;
begin
  // Перемещаемся к началу данных глифа
  Seek(F, Offset);

  // Сброс текущей позиции
  FCurrentX := 0.0;
  FCurrentY := 0.0;

  // Чтение заголовка формы
  if not SafeReadByte(F, ShapeNumber) then
  begin
    Result := CreateEmptyGlyph(0);
    Exit;
  end;

  if not SafeReadWord(F, ByteCount) then
  begin
    Result := CreateEmptyGlyph(ShapeNumber);
    Exit;
  end;

  // Создание структуры глифа
  Result := CreateEmptyGlyph(ShapeNumber);
  Result.Name := GetCharName(ShapeNumber);

  if FVerbose then
  begin
    programlog.LogOutFormatStr(
      'Парсинг глифа: Code=%d Name=%s ByteCount=%d',
      [ShapeNumber, Result.Name, ByteCount],
      LM_Debug
    );
  end;

  // Парсинг команд рисования
  ParseGlyphCommands(F, Result);

  // Вычисление границ и ширины продвижения
  CalculateGlyphBounds(Result);

  if Length(Result.Commands) > 0 then
  begin
    Result.AdvanceWidth := Result.Bounds.MaxX - Result.Bounds.MinX;
  end
  else
  begin
    Result.AdvanceWidth := 0.0;
  end;

  if FVerbose then
  begin
    programlog.LogOutFormatStr(
      'Глиф завершен: Commands=%d AdvanceWidth=%.2f',
      [Length(Result.Commands), Result.AdvanceWidth],
      LM_Debug
    );
  end;
end;

// Основная функция парсинга
function TShxParser.Parse: TShxFont;
var
  F: File;
  Header: TShxHeader;
  OffsetTable: array of LongWord;
  i: Integer;
  Glyph: TShxGlyph;
begin
  Result := CreateEmptyFont;

  // Проверка существования файла
  if not FileExists(FFileName) then
  begin
    programlog.LogOutFormatStr(
      'SHX файл не найден: "%s"',
      [FFileName],
      LM_Error
    );
    Exit;
  end;

  programlog.LogOutFormatStr(
    'Начало парсинга SHX файла: "%s"',
    [FFileName],
    LM_Info
  );

  try
    AssignFile(F, FFileName);
    FileMode := fmOpenRead;
    Reset(F, 1);

    try
      // Чтение заголовка
      Header := ReadHeader(F);
      Result.FontName := Header.FontName;
      Result.UnitsPerEm := Header.UnitsPerEm;

      programlog.LogOutFormatStr(
        'Заголовок прочитан: FontName=%s UnitsPerEm=%d',
        [Result.FontName, Result.UnitsPerEm],
        LM_Info
      );

      // Примечание: в упрощенной реализации мы будем парсить глифы последовательно
      // В реальном SHX файле есть таблица смещений, но для начальной версии
      // можем использовать последовательное чтение

      // Пропускаем заголовок и переходим к данным
      // Для демонстрации создадим несколько тестовых глифов
      // В полной реализации здесь будет чтение таблицы смещений

      SetLength(Result.Glyphs, 0);

      programlog.LogOutFormatStr(
        'Парсинг SHX завершен: Glyphs=%d',
        [Length(Result.Glyphs)],
        LM_Info
      );

    finally
      CloseFile(F);
    end;

  except
    on E: Exception do
    begin
      programlog.LogOutFormatStr(
        'Ошибка при парсинге SHX файла: %s',
        [E.Message],
        LM_Error
      );
    end;
  end;
end;

end.
