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

{
  Модуль: uzvrtrestoretablecmd
  Назначение: Команда запуска восстановления таблицы и сохранения в XLSX
  Описание: Модуль регистрирует команду ZCAD UzvRebuildTable, которая:
            1. Запускает процесс реставрации через менеджер
            2. Получает готовый объект TsWorkbook
            3. Открывает диалог сохранения XLSX
            4. Сохраняет книгу на диск
            Обрабатывает ошибки и отмену диалога.
  Зависимости: ucvrtdata, ucvrtmanager, ucvrtfpsbuilder, fpspreadsheet, Dialogs
}
unit uzvrtrestoretablecmd;

{$INCLUDE zengineconfig.inc}

interface

uses
  SysUtils,
  Classes,
  Dialogs,
  fpspreadsheet,
  fpsTypes,
  uzccommandsabstract,
  uzccommandsimpl,
  uzccommandsmanager,
  uzcdrawings,
  uzcinterface,
  ucvrtdata,
  ucvrtmanager,
  ucvrtfpsbuilder;

// Команда восстановления таблицы из выделенных примитивов с сохранением в XLSX
function UzvRebuildTable_com(
  const Context: TZCADCommandContext;
  operands: TCommandOperands
): TCommandResult;

implementation

const
  // Параметры диалога сохранения
  SAVE_DIALOG_TITLE = 'Сохранить таблицу как XLSX / Save table as XLSX';
  SAVE_DIALOG_FILTER = 'Файлы Excel (*.xlsx)|*.xlsx|Все файлы (*.*)|*.*';
  SAVE_DIALOG_DEFAULT_EXT = 'xlsx';
  SAVE_DIALOG_DEFAULT_FILENAME = 'restored_table.xlsx';

// Показать диалог сохранения файла и сохранить книгу
// Возвращает True при успешном сохранении
function SaveWorkbookWithDialog(aWorkbook: TsWorkbook): Boolean;
var
  saveDialog: TSaveDialog;
  fileName: string;
begin
  Result := False;

  if aWorkbook = nil then
  begin
    zcUI.TextMessage(
      'Ошибка: книга не инициализирована',
      TMWOHistoryOut
    );
    Exit;
  end;

  // Создаем диалог сохранения
  saveDialog := TSaveDialog.Create(nil);
  try
    saveDialog.Title := SAVE_DIALOG_TITLE;
    saveDialog.Filter := SAVE_DIALOG_FILTER;
    saveDialog.DefaultExt := SAVE_DIALOG_DEFAULT_EXT;
    saveDialog.FilterIndex := 1;
    saveDialog.FileName := SAVE_DIALOG_DEFAULT_FILENAME;
    saveDialog.Options := saveDialog.Options + [ofOverwritePrompt];

    // Показываем диалог
    if saveDialog.Execute then
    begin
      fileName := saveDialog.FileName;

      try
        // Сохраняем книгу в формате XLSX (OOXML)
        aWorkbook.WriteToFile(fileName, sfOOXML, True);

        zcUI.TextMessage(
          'Таблица успешно сохранена в файл: ' + fileName,
          TMWOHistoryOut
        );
        Result := True;

      except
        on E: Exception do
        begin
          zcUI.TextMessage(
            'Ошибка при сохранении файла: ' + E.Message,
            TMWOHistoryOut
          );
        end;
      end;
    end
    else
    begin
      // Пользователь отменил диалог
      zcUI.TextMessage(
        'Сохранение отменено пользователем',
        TMWOHistoryOut
      );
    end;

  finally
    saveDialog.Free;
  end;
end;

// Команда восстановления таблицы из выделенных примитивов
function UzvRebuildTable_com(
  const Context: TZCADCommandContext;
  operands: TCommandOperands
): TCommandResult;
var
  manager: TRtTableManager;
  workbook: TsWorkbook;
  selectedCount: Integer;
begin
  Result := cmd_ok;

  zcUI.TextMessage(
    '==============================================================',
    TMWOHistoryOut
  );
  zcUI.TextMessage(
    'Команда: Восстановление таблицы / Command: Rebuild Table',
    TMWOHistoryOut
  );
  zcUI.TextMessage(
    '==============================================================',
    TMWOHistoryOut
  );

  // Проверяем наличие выделенных объектов
  selectedCount := drawings.GetCurrentDWG^.wa.param.seldesc.Selectedobjcount;

  if selectedCount = 0 then
  begin
    zcUI.TextMessage(
      'Ошибка: не выбрано ни одного объекта',
      TMWOHistoryOut
    );
    zcUI.TextMessage(
      'Error: no objects selected',
      TMWOHistoryOut
    );
    zcUI.TextMessage('', TMWOHistoryOut);
    zcUI.TextMessage(
      'Выделите примитивы таблицы (линии, тексты) и повторите команду',
      TMWOHistoryOut
    );
    zcUI.TextMessage(
      'Select table primitives (lines, texts) and repeat the command',
      TMWOHistoryOut
    );
    zcUI.TextMessage(
      '==============================================================',
      TMWOHistoryOut
    );
    Exit;
  end;

  zcUI.TextMessage(
    'Выделено объектов / Selected objects: ' + IntToStr(selectedCount),
    TMWOHistoryOut
  );

  workbook := nil;
  try
    // Получаем менеджер таблиц
    manager := GetRecoveryTableManager;

    // Шаг 1: Запускаем процесс реставрации таблицы
    if not manager.ProcessTableRecovery then
    begin
      zcUI.TextMessage('', TMWOHistoryOut);
      zcUI.TextMessage(
        'Процесс восстановления завершен с ошибками',
        TMWOHistoryOut
      );

      // Выводим детали ошибки
      if manager.Error.hasError then
      begin
        zcUI.TextMessage(
          'Код ошибки / Error code: ' + IntToStr(manager.Error.errorCode),
          TMWOHistoryOut
        );
        zcUI.TextMessage(
          'Сообщение / Message: ' + manager.Error.errorMessage,
          TMWOHistoryOut
        );
      end;

      zcUI.TextMessage(
        '==============================================================',
        TMWOHistoryOut
      );
      Exit;
    end;

    // Шаг 2: Создаем TsWorkbook из модели таблицы
    zcUI.TextMessage('', TMWOHistoryOut);
    zcUI.TextMessage(
      'Создание книги Excel...',
      TMWOHistoryOut
    );

    workbook := CreateWorkbookFromTableModel(manager.TableModel);

    if workbook = nil then
    begin
      zcUI.TextMessage(
        'Ошибка: не удалось создать книгу Excel',
        TMWOHistoryOut
      );
      zcUI.TextMessage(
        '==============================================================',
        TMWOHistoryOut
      );
      Exit;
    end;

    // Шаг 3: Показываем диалог сохранения и сохраняем файл
    zcUI.TextMessage('', TMWOHistoryOut);
    zcUI.TextMessage(
      'Открытие диалога сохранения...',
      TMWOHistoryOut
    );

    if SaveWorkbookWithDialog(workbook) then
    begin
      zcUI.TextMessage('', TMWOHistoryOut);
      zcUI.TextMessage(
        'Таблица успешно восстановлена и сохранена',
        TMWOHistoryOut
      );
      zcUI.TextMessage(
        'Table successfully recovered and saved',
        TMWOHistoryOut
      );
    end;

  except
    on E: Exception do
    begin
      zcUI.TextMessage('', TMWOHistoryOut);
      zcUI.TextMessage(
        'Критическая ошибка / Critical error: ' + E.Message,
        TMWOHistoryOut
      );
    end;
  end;

  // Освобождаем книгу (ответственность команды)
  if workbook <> nil then
    workbook.Free;

  zcUI.TextMessage(
    '==============================================================',
    TMWOHistoryOut
  );
end;

initialization
  // Регистрируем команду UzvRebuildTable в системе ZCAD
  CreateZCADCommand(
    @UzvRebuildTable_com,
    'UzvRebuildTable',
    CADWG,
    0
  );

  zcUI.TextMessage(
    'Команда UzvRebuildTable зарегистрирована (модуль ucvrecoverytable)',
    TMWOHistoryOut
  );

end.
