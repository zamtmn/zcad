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

unit uzvshxtopdf_commandstart;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Classes,
  uzccommandsmanager,
  uzccommandsabstract,
  uzccommandsimpl,
  uzclog,
  uzcinterface,
  uzcdrawings,
  uzeenttext,
  uzvshxtopdf_shxglyph,
  uzvshxtopdf_shxreader,
  uzvshxtopdf_shxdebugsvg;

// Команда для чтения и тестирования SHX шрифтов
// Использование: SHX_TO_PDF_READ [путь_к_shx_файлу]
function SHX_TO_PDF_READ_com(
  const Context: TZCADCommandContext;
  operands: TCommandOperands
): TCommandResult;

implementation

// Подсчитать количество выделенных текстовых объектов
function CountSelectedTextObjects: Integer;
var
  EntityPtr: PGDBObjEntity;
  IterRec: itrec;
begin
  Result := 0;

  EntityPtr := drawings.GetCurrentROOT^.ObjArray.beginiterate(IterRec);
  if EntityPtr = nil then
    Exit;

  repeat
    if EntityPtr^.selected then
    begin
      if EntityPtr^.GetObjType = GDBTextID then
        Inc(Result);
    end;

    EntityPtr := drawings.GetCurrentROOT^.ObjArray.iterate(IterRec);
  until EntityPtr = nil;
end;

// Получить путь к SHX файлу из операндов или из выделенного текста
function GetShxFilePath(const Operands: TCommandOperands): string;
var
  EntityPtr: PGDBObjEntity;
  IterRec: itrec;
  TextPtr: PGDBObjText;
begin
  Result := '';

  // Если путь указан явно в операндах
  if Trim(Operands) <> '' then
  begin
    Result := Trim(Operands);
    Exit;
  end;

  // Иначе пытаемся получить из выделенного текста
  EntityPtr := drawings.GetCurrentROOT^.ObjArray.beginiterate(IterRec);
  if EntityPtr = nil then
    Exit;

  repeat
    if EntityPtr^.selected then
    begin
      if EntityPtr^.GetObjType = GDBTextID then
      begin
        TextPtr := PGDBObjText(EntityPtr);

        // В реальной системе здесь нужно получить имя шрифта из свойств текста
        // и найти соответствующий SHX файл
        // Для демонстрации используем имя из контента или параметров

        programlog.LogOutFormatStr(
          'Найден текстовый объект: Content="%s" Height=%.2f',
          [TextPtr^.Content, TextPtr^.obj_height],
          LM_Debug
        );

        // Примечание: в реальной реализации нужно:
        // 1. Извлечь имя стиля текста
        // 2. Получить имя SHX файла из стиля
        // 3. Найти полный путь к SHX файлу в каталогах шрифтов

        Break;
      end;
    end;

    EntityPtr := drawings.GetCurrentROOT^.ObjArray.iterate(IterRec);
  until EntityPtr = nil;
end;

// Собрать массив используемых символов из выделенных текстов
function CollectUsedChars: TBytes;
var
  EntityPtr: PGDBObjEntity;
  IterRec: itrec;
  TextPtr: PGDBObjText;
  CharSet: set of Byte;
  i: Integer;
  Ch: Char;
  Content: string;
  Count: Integer;
begin
  SetLength(Result, 0);
  CharSet := [];

  EntityPtr := drawings.GetCurrentROOT^.ObjArray.beginiterate(IterRec);
  if EntityPtr = nil then
    Exit;

  repeat
    if EntityPtr^.selected then
    begin
      if EntityPtr^.GetObjType = GDBTextID then
      begin
        TextPtr := PGDBObjText(EntityPtr);
        Content := TextPtr^.Content;

        // Добавляем все символы из текста в набор
        for i := 1 to Length(Content) do
        begin
          Ch := Content[i];
          CharSet := CharSet + [Byte(Ch)];
        end;
      end;
    end;

    EntityPtr := drawings.GetCurrentROOT^.ObjArray.iterate(IterRec);
  until EntityPtr = nil;

  // Преобразуем набор в массив
  Count := 0;
  for i := 0 to 255 do
  begin
    if i in CharSet then
      Inc(Count);
  end;

  SetLength(Result, Count);
  Count := 0;

  for i := 0 to 255 do
  begin
    if i in CharSet then
    begin
      Result[Count] := i;
      Inc(Count);
    end;
  end;
end;

// Создать тестовые SVG файлы для проверки
procedure CreateTestSVGs(const Font: TShxFont; const OutputDir: string);
var
  i: Integer;
  TestChars: array[0..2] of Byte;
  GlyphIdx: Integer;
  FileName: string;
begin
  // Тестовые символы: 'A' (0x41), '1' (0x31), 'Б' (0xC1 в CP1251)
  TestChars[0] := $41; // 'A'
  TestChars[1] := $31; // '1'
  TestChars[2] := $C1; // 'Б'

  programlog.LogOutFormatStr(
    'Создание тестовых SVG для символов: A (0x41), 1 (0x31), Б (0xC1)',
    [],
    LM_Info
  );

  for i := 0 to High(TestChars) do
  begin
    GlyphIdx := FindGlyphByCode(Font, TestChars[i]);

    if GlyphIdx >= 0 then
    begin
      FileName := OutputDir + Format('glyph_%2.2X.svg', [TestChars[i]]);

      ExportGlyphToSVG(Font.Glyphs[GlyphIdx], FileName, 100.0);

      programlog.LogOutFormatStr(
        'Создан SVG для символа 0x%2.2X: %s',
        [TestChars[i], FileName],
        LM_Info
      );
    end
    else
    begin
      programlog.LogOutFormatStr(
        'Глиф для символа 0x%2.2X не найден в шрифте',
        [TestChars[i]],
        LM_Warning
      );
    end;
  end;

  // Создаем сводный SVG всего шрифта
  FileName := OutputDir + 'font_overview.svg';
  ExportFontToSVG(Font, FileName, 50.0, 16);

  programlog.LogOutFormatStr(
    'Создан сводный SVG шрифта: %s',
    [FileName],
    LM_Info
  );
end;

// Основная команда
function SHX_TO_PDF_READ_com(
  const Context: TZCADCommandContext;
  operands: TCommandOperands
): TCommandResult;
var
  ShxFilePath: string;
  Font: TShxFont;
  UsedChars: TBytes;
  SelectedTextCount: Integer;
  OutputDir: string;
begin
  programlog.LogOutFormatStr(
    'Запуск команды SHX_TO_PDF_READ',
    [],
    LM_Info
  );

  zcUI.TextMessage('Запущена команда чтения SHX шрифтов', TMWOHistoryOut);

  // Подсчитываем выделенные текстовые объекты
  SelectedTextCount := CountSelectedTextObjects;

  programlog.LogOutFormatStr(
    'Выделено текстовых объектов: %d',
    [SelectedTextCount],
    LM_Info
  );

  if SelectedTextCount > 0 then
  begin
    zcUI.TextMessage(
      Format('Найдено выделенных текстовых объектов: %d', [SelectedTextCount]),
      TMWOHistoryOut
    );

    // Собираем используемые символы
    UsedChars := CollectUsedChars;

    programlog.LogOutFormatStr(
      'Собрано уникальных символов: %d',
      [Length(UsedChars)],
      LM_Info
    );
  end
  else
  begin
    zcUI.TextMessage(
      'Выделенных текстовых объектов не найдено',
      TMWOHistoryOut
    );
    SetLength(UsedChars, 0);
  end;

  // Получаем путь к SHX файлу
  ShxFilePath := GetShxFilePath(operands);

  if ShxFilePath = '' then
  begin
    zcUI.TextMessage(
      'ИСПОЛЬЗОВАНИЕ: SHX_TO_PDF_READ <путь_к_shx_файлу>',
      TMWOHistoryOut
    );
    zcUI.TextMessage(
      'ПРИМЕР: SHX_TO_PDF_READ C:\Fonts\simplex.shx',
      TMWOHistoryOut
    );

    Result := cmd_ok;
    Exit;
  end;

  // Проверяем существование файла
  if not FileExists(ShxFilePath) then
  begin
    zcUI.TextMessage(
      Format('ОШИБКА: Файл не найден: %s', [ShxFilePath]),
      TMWOHistoryOut
    );

    programlog.LogOutFormatStr(
      'SHX файл не найден: "%s"',
      [ShxFilePath],
      LM_Error
    );

    Result := cmd_ok;
    Exit;
  end;

  zcUI.TextMessage(
    Format('Загрузка SHX файла: %s', [ShxFilePath]),
    TMWOHistoryOut
  );

  // Загружаем шрифт
  if Length(UsedChars) > 0 then
  begin
    Font := LoadShxFont(ShxFilePath, 1251, True, UsedChars);
  end
  else
  begin
    Font := LoadShxFont(ShxFilePath, 1251, True);
  end;

  // Проверяем результат
  if Length(Font.Glyphs) = 0 then
  begin
    zcUI.TextMessage(
      'ПРЕДУПРЕЖДЕНИЕ: Шрифт не содержит глифов',
      TMWOHistoryOut
    );

    programlog.LogOutFormatStr(
      'Загруженный шрифт не содержит глифов',
      [],
      LM_Warning
    );
  end
  else
  begin
    zcUI.TextMessage(
      Format('Шрифт успешно загружен: %s (%d глифов)', [Font.FontName, Length(Font.Glyphs)]),
      TMWOHistoryOut
    );

    // Создаем каталог для вывода SVG
    OutputDir := ExtractFilePath(drawings.GetCurrentDWG^.GetFileName);
    if OutputDir = '' then
      OutputDir := GetCurrentDir + PathDelim;

    OutputDir := OutputDir + 'shx_debug' + PathDelim;

    if not DirectoryExists(OutputDir) then
    begin
      CreateDir(OutputDir);
      programlog.LogOutFormatStr(
        'Создан каталог для вывода: %s',
        [OutputDir],
        LM_Info
      );
    end;

    // Создаем тестовые SVG
    CreateTestSVGs(Font, OutputDir);

    zcUI.TextMessage(
      Format('Тестовые SVG файлы созданы в: %s', [OutputDir]),
      TMWOHistoryOut
    );
  end;

  programlog.LogOutFormatStr(
    'Команда SHX_TO_PDF_READ завершена',
    [],
    LM_Info
  );

  Result := cmd_ok;
end;

initialization
  programlog.LogOutFormatStr(
    'Unit "%s" initialization',
    [{$INCLUDE %FILE%}],
    LM_Info,
    UnitsInitializeLMId
  );

  // Регистрация команды в системе
  CreateZCADCommand(
    @SHX_TO_PDF_READ_com,
    'SHX_TO_PDF_READ',
    CADWG,
    0
  );

  programlog.LogOutFormatStr(
    'Команда SHX_TO_PDF_READ зарегистрирована',
    [],
    LM_Info
  );

finalization
  ProgramLog.LogOutFormatStr(
    'Unit "%s" finalization',
    [{$INCLUDE %FILE%}],
    LM_Info,
    UnitsFinalizeLMId
  );

end.
