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

unit uzvshxtopdf_shxreader;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Classes,
  uzvshxtopdf_shxglyph,
  uzvshxtopdf_shxutils,
  uzvshxtopdf_shxparser,
  uzclog;

// Главная функция загрузки SHX шрифта
// Параметры:
//   FileName - полный путь к SHX файлу
//   CodePage - номер кодовой страницы (по умолчанию 1251 - Windows Cyrillic)
//   Verbose - режим подробного логирования
//   UsedChars - массив кодов символов, которые нужно загрузить (если пустой - загружаются все)
// Возвращает:
//   Структуру TShxFont с загруженными глифами
function LoadShxFont(
  const FileName: string;
  CodePage: Integer = 1251;
  Verbose: Boolean = False;
  const UsedChars: array of Byte = nil
): TShxFont;

// Проверка валидности загруженного шрифта
function ValidateShxFont(const Font: TShxFont): Boolean;

// Получить информацию о шрифте в текстовом виде (для отладки)
function GetShxFontInfo(const Font: TShxFont): string;

// Нормализовать координаты глифов (масштабирование к единичной высоте)
procedure NormalizeFont(var Font: TShxFont);

// Фильтровать шрифт, оставив только указанные символы
procedure FilterFontByUsedChars(var Font: TShxFont; const UsedChars: array of Byte);

implementation

uses
  Math;

// Главная функция загрузки SHX шрифта
function LoadShxFont(
  const FileName: string;
  CodePage: Integer = 1251;
  Verbose: Boolean = False;
  const UsedChars: array of Byte = nil
): TShxFont;
var
  Parser: TShxParser;
  StartTime: TDateTime;
  ElapsedTime: Double;
begin
  programlog.LogOutFormatStr(
    'Загрузка SHX шрифта: "%s" (CodePage=%d, Verbose=%d)',
    [FileName, CodePage, Ord(Verbose)],
    LM_Info
  );

  StartTime := Now;

  try
    // Создание парсера
    Parser := TShxParser.Create(FileName, CodePage, Verbose);
    try
      // Парсинг файла
      Result := Parser.Parse;

      // Фильтрация по используемым символам
      if Length(UsedChars) > 0 then
      begin
        programlog.LogOutFormatStr(
          'Фильтрация по используемым символам: %d символов',
          [Length(UsedChars)],
          LM_Debug
        );
        FilterFontByUsedChars(Result, UsedChars);
      end;

      // Нормализация координат
      NormalizeFont(Result);

      // Валидация результата
      if ValidateShxFont(Result) then
      begin
        ElapsedTime := (Now - StartTime) * 24 * 3600 * 1000; // в миллисекундах

        programlog.LogOutFormatStr(
          'Шрифт успешно загружен: "%s" (%d глифов, %.1f мс)',
          [Result.FontName, Length(Result.Glyphs), ElapsedTime],
          LM_Info
        );

        if Verbose then
        begin
          programlog.LogOutFormatStr(
            'Информация о шрифте:'#13#10'%s',
            [GetShxFontInfo(Result)],
            LM_Debug
          );
        end;
      end
      else
      begin
        programlog.LogOutFormatStr(
          'Загруженный шрифт не прошел валидацию',
          [],
          LM_Warning
        );
      end;

    finally
      Parser.Free;
    end;

  except
    on E: Exception do
    begin
      programlog.LogOutFormatStr(
        'Ошибка при загрузке SHX шрифта "%s": %s',
        [FileName, E.Message],
        LM_Error
      );
      Result := CreateEmptyFont;
    end;
  end;
end;

// Проверка валидности загруженного шрифта
function ValidateShxFont(const Font: TShxFont): Boolean;
var
  i, j: Integer;
  Cmd: TShxCommand;
  HasErrors: Boolean;
begin
  Result := False;
  HasErrors := False;

  // Проверка имени шрифта
  if Trim(Font.FontName) = '' then
  begin
    programlog.LogOutFormatStr(
      'Ошибка валидации: пустое имя шрифта',
      [],
      LM_Warning
    );
    HasErrors := True;
  end;

  // Проверка UnitsPerEm
  if (Font.UnitsPerEm <= 0) or IsInvalidFloat(Font.UnitsPerEm) then
  begin
    programlog.LogOutFormatStr(
      'Ошибка валидации: некорректное значение UnitsPerEm=%.2f',
      [Font.UnitsPerEm],
      LM_Warning
    );
    HasErrors := True;
  end;

  // Проверка наличия глифов
  if Length(Font.Glyphs) = 0 then
  begin
    programlog.LogOutFormatStr(
      'Предупреждение валидации: шрифт не содержит глифов',
      [],
      LM_Warning
    );
    // Это не критическая ошибка для пустого шрифта
  end;

  // Проверка каждого глифа
  for i := 0 to High(Font.Glyphs) do
  begin
    // Проверка команд на NaN и Infinity
    for j := 0 to High(Font.Glyphs[i].Commands) do
    begin
      Cmd := Font.Glyphs[i].Commands[j];

      if IsInvalidFloat(Cmd.P1.X) or IsInvalidFloat(Cmd.P1.Y) then
      begin
        programlog.LogOutFormatStr(
          'Ошибка валидации: глиф %d содержит NaN/Inf в команде %d',
          [Font.Glyphs[i].Code, j],
          LM_Warning
        );
        HasErrors := True;
      end;

      if (Cmd.Cmd in [cmdArc, cmdCircle]) and IsInvalidFloat(Cmd.Radius) then
      begin
        programlog.LogOutFormatStr(
          'Ошибка валидации: глиф %d содержит некорректный радиус в команде %d',
          [Font.Glyphs[i].Code, j],
          LM_Warning
        );
        HasErrors := True;
      end;
    end;
  end;

  Result := not HasErrors;
end;

// Получить информацию о шрифте в текстовом виде
function GetShxFontInfo(const Font: TShxFont): string;
var
  i: Integer;
  Info: TStringList;
begin
  Info := TStringList.Create;
  try
    Info.Add(Format('FontName: %s', [Font.FontName]));
    Info.Add(Format('UnitsPerEm: %.2f', [Font.UnitsPerEm]));
    Info.Add(Format('Glyphs: %d', [Length(Font.Glyphs)]));
    Info.Add('');

    for i := 0 to Min(High(Font.Glyphs), 9) do
    begin
      Info.Add(Format(
        '  Glyph[%d]: Code=%d Name=%s Commands=%d Width=%.2f',
        [
          i,
          Font.Glyphs[i].Code,
          Font.Glyphs[i].Name,
          Length(Font.Glyphs[i].Commands),
          Font.Glyphs[i].AdvanceWidth
        ]
      ));
    end;

    if Length(Font.Glyphs) > 10 then
    begin
      Info.Add(Format('  ... и еще %d глифов', [Length(Font.Glyphs) - 10]));
    end;

    Result := Info.Text;
  finally
    Info.Free;
  end;
end;

// Найти максимальную высоту глифов для нормализации
function FindMaxGlyphHeight(const Font: TShxFont): Double;
var
  i: Integer;
  Height: Double;
begin
  Result := 0.0;

  for i := 0 to High(Font.Glyphs) do
  begin
    Height := Font.Glyphs[i].Bounds.MaxY - Font.Glyphs[i].Bounds.MinY;
    if Height > Result then
      Result := Height;
  end;
end;

// Нормализовать координаты глифов
procedure NormalizeFont(var Font: TShxFont);
var
  i, j: Integer;
  MaxHeight: Double;
  Scale: Double;
begin
  // Находим максимальную высоту глифов
  MaxHeight := FindMaxGlyphHeight(Font);

  if MaxHeight <= 0.0 then
  begin
    programlog.LogOutFormatStr(
      'Нормализация шрифта: максимальная высота = 0, нормализация пропущена',
      [],
      LM_Debug
    );
    Exit;
  end;

  // Вычисляем коэффициент масштабирования для высоты ≈ 1.0
  Scale := 1.0 / MaxHeight;

  programlog.LogOutFormatStr(
    'Нормализация шрифта: MaxHeight=%.2f Scale=%.4f',
    [MaxHeight, Scale],
    LM_Debug
  );

  // Масштабируем все координаты и размеры
  for i := 0 to High(Font.Glyphs) do
  begin
    // Масштабируем команды
    for j := 0 to High(Font.Glyphs[i].Commands) do
    begin
      Font.Glyphs[i].Commands[j].P1.X := Font.Glyphs[i].Commands[j].P1.X * Scale;
      Font.Glyphs[i].Commands[j].P1.Y := Font.Glyphs[i].Commands[j].P1.Y * Scale;
      Font.Glyphs[i].Commands[j].P2.X := Font.Glyphs[i].Commands[j].P2.X * Scale;
      Font.Glyphs[i].Commands[j].P2.Y := Font.Glyphs[i].Commands[j].P2.Y * Scale;
      Font.Glyphs[i].Commands[j].P3.X := Font.Glyphs[i].Commands[j].P3.X * Scale;
      Font.Glyphs[i].Commands[j].P3.Y := Font.Glyphs[i].Commands[j].P3.Y * Scale;

      if Font.Glyphs[i].Commands[j].Cmd in [cmdArc, cmdCircle] then
      begin
        Font.Glyphs[i].Commands[j].Radius := Font.Glyphs[i].Commands[j].Radius * Scale;
      end;
    end;

    // Масштабируем границы
    Font.Glyphs[i].Bounds.MinX := Font.Glyphs[i].Bounds.MinX * Scale;
    Font.Glyphs[i].Bounds.MinY := Font.Glyphs[i].Bounds.MinY * Scale;
    Font.Glyphs[i].Bounds.MaxX := Font.Glyphs[i].Bounds.MaxX * Scale;
    Font.Glyphs[i].Bounds.MaxY := Font.Glyphs[i].Bounds.MaxY * Scale;

    // Масштабируем ширину продвижения
    Font.Glyphs[i].AdvanceWidth := Font.Glyphs[i].AdvanceWidth * Scale;
  end;

  // Обновляем UnitsPerEm
  Font.UnitsPerEm := 1.0;
end;

// Фильтровать шрифт, оставив только указанные символы
procedure FilterFontByUsedChars(var Font: TShxFont; const UsedChars: array of Byte);
var
  i, j: Integer;
  NewGlyphs: array of TShxGlyph;
  Count: Integer;
  IsUsed: Boolean;
begin
  if Length(UsedChars) = 0 then
    Exit;

  Count := 0;
  SetLength(NewGlyphs, Length(Font.Glyphs));

  // Копируем только используемые глифы
  for i := 0 to High(Font.Glyphs) do
  begin
    IsUsed := False;

    for j := 0 to High(UsedChars) do
    begin
      if Font.Glyphs[i].Code = UsedChars[j] then
      begin
        IsUsed := True;
        Break;
      end;
    end;

    if IsUsed then
    begin
      NewGlyphs[Count] := Font.Glyphs[i];
      Inc(Count);
    end;
  end;

  // Обрезаем массив до фактического размера
  SetLength(NewGlyphs, Count);
  Font.Glyphs := NewGlyphs;

  programlog.LogOutFormatStr(
    'Фильтрация завершена: осталось %d глифов из запрошенных %d',
    [Count, Length(UsedChars)],
    LM_Debug
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
