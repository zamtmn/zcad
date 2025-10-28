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
{$mode objfpc}{$H+}

{**Модуль реализации команды exportDialux для экспорта в DIALux}
unit uzvcommand_exportdialux;

{ file def.inc is necessary to include at the beginning of each module zcad
  it contains a centralized compilation parameters settings }

{ файл def.inc необходимо включать в начале каждого модуля zcad
  он содержит в себе централизованные настройки параметров компиляции  }

{$INCLUDE zengineconfig.inc}

interface
uses
  sysutils,
  Classes,             //TStringList and related classes
                       //TStringList и связанные классы

  uzccommandsmanager,
  uzccommandsabstract,
  uzccommandsimpl,     //Commands manager and related objects
                       //менеджер команд и объекты связанные с ним
  uzclog,              //log system
                       //система логирования
  uzcinterface,        //interface utilities
                       //утилиты интерфейса
  uzcdrawings,         //Drawings manager
                       //Менеджер чертежей
  uzcutils,            //utility functions
                       //утилиты
  uzbtypes,            //base types
                       //базовые типы
  uzcstrconsts,        //resource strings
                       //строковые константы
  uzvdialuxmanager;    //DIALux manager
                       //менеджер DIALux

function exportDialux_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;

implementation

function exportDialux_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var
  dialuxManager: TZVDIALuxManager;
  fileName: string;
  drawingPath: string;
  drawingName: string;
begin
  // Вывод сообщения о запуске команды
  // Output message about command launch
  zcUI.TextMessage('запущена команда exportDialux / exportDialux command started', TMWOHistoryOut);

  // Получаем путь к текущему чертежу
  // Get path to current drawing
  drawingPath := drawings.GetCurrentDWG^.GetFileName;

  if drawingPath = '' then begin
    zcUI.TextMessage('Ошибка: чертеж не сохранен / Error: drawing not saved', TMWOHistoryOut);
    zcUI.TextMessage('Пожалуйста, сохраните чертеж перед экспортом / Please save drawing before export', TMWOHistoryOut);
    Result := cmd_ok;
    exit;
  end;

  // Проверяем операнды для имени файла
  // Check operands for file name
  if Trim(operands) <> '' then begin
    fileName := Trim(operands);
    // Удаляем кавычки если есть
    // Remove quotes if present
    if (Length(fileName) >= 2) and (fileName[1] = '''') and (fileName[Length(fileName)] = '''') then
      fileName := Copy(fileName, 2, Length(fileName) - 2);
  end else begin
    // Используем имя чертежа с расширением .stf
    // Use drawing name with .stf extension
    drawingName := ExtractFileName(drawingPath);
    fileName := ChangeFileExt(drawingName, '.stf');
    drawingPath := ExtractFileDir(drawingPath);
    fileName := IncludeTrailingPathDelimiter(drawingPath) + fileName;
  end;

  // Убеждаемся что файл имеет расширение .stf
  // Ensure file has .stf extension
  if ExtractFileExt(fileName) = '' then
    fileName := fileName + '.stf';

  zcUI.TextMessage('Экспорт в файл / Exporting to file: ' + fileName, TMWOHistoryOut);

  // Создаем менеджер DIALux
  // Create DIALux manager
  dialuxManager := TZVDIALuxManager.Create;
  try
    // Сначала собираем информацию о пространствах
    // First collect information about spaces
    dialuxManager.CollectSpacesFromDrawing;

    // Строим иерархию пространств
    // Build space hierarchy
    dialuxManager.BuildSpaceHierarchy;

    // Выводим структуру для наглядности
    // Display structure for clarity
    dialuxManager.DisplaySpacesStructure;

    // Собираем информацию о светильниках
    // Collect luminaires information
    dialuxManager.CollectLuminairesFromDrawing;

    // Определяем принадлежность светильников к помещениям
    // Assign luminaires to rooms
    dialuxManager.AssignLuminairesToRooms;

    // Выводим список светильников для наглядности
    // Display luminaires list for clarity
    dialuxManager.DisplayLuminairesList;

    // Экспортируем в формат STF
    // Export to STF format
    if dialuxManager.ExportToSTF(fileName) then begin
      zcUI.TextMessage('Экспорт успешно завершен / Export completed successfully', TMWOHistoryOut);
      zcUI.TextMessage('Экспортировано пространств / Spaces exported: ' + IntToStr(dialuxManager.SpacesList.Count), TMWOHistoryOut);
      zcUI.TextMessage('Экспортировано светильников / Luminaires exported: ' + IntToStr(dialuxManager.LuminairesList.Count), TMWOHistoryOut);
    end else begin
      zcUI.TextMessage('Ошибка при экспорте / Error during export', TMWOHistoryOut);
    end;
  finally
    dialuxManager.Free;
  end;

  Result := cmd_ok;
end;

initialization
  // Регистрация команды exportDialux
  // Register the exportDialux command
  CreateZCADCommand(@exportDialux_com,'exportDialux',CADWG,0);
end.
