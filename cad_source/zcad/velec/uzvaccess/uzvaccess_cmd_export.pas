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

unit uzvaccess_cmd_export;

{$INCLUDE zengineconfig.inc}

interface

uses
  SysUtils, Classes, Dialogs,
  uzccommandsabstract, uzccommandsimpl, uzcinterface,
  uzvaccess_types, uzvaccess_config, uzvaccess_exporter, uzclog;

// Процедура выполнения команды экспорта
procedure CmdUzvAccessExport(
  pCommandParam: Pointer;
  var operationResult: TCommandResult
);

implementation

procedure CmdUzvAccessExport(
  pCommandParam: Pointer;
  var operationResult: TCommandResult
);
var
  config: TExportConfig;
  exporter: TAccessExporter;
  exportResult: TExportResult;
  accessFile: String;
  openDialog: TOpenDialog;
begin
  // Вывод информационного сообщения
  zcUI.TextMessage(
    'Запуск экспорта данных в MS Access...',
    TMWOHistoryOut
  );

  programlog.LogOutFormatStr(
    'uzvaccess: Начало выполнения команды экспорта',
    [],
    LM_Info
  );

  try
    // Создаём конфигурацию по умолчанию
    config := TExportConfig.Create;
    try
      // Показываем диалог выбора файла Access
      accessFile := '';

      openDialog := TOpenDialog.Create(nil);
      try
        openDialog.Title := 'Выберите файл базы данных MS Access';
        openDialog.Filter := 'MS Access Database|*.mdb;*.accdb|All Files|*.*';
        openDialog.Options := [ofFileMustExist, ofEnableSizing];

        if openDialog.Execute then
          accessFile := openDialog.FileName
        else
        begin
          zcUI.TextMessage(
            'Экспорт отменён: файл не выбран',
            TMWOHistoryOut
          );
          operationResult := cmd_OK;
          Exit;
        end;

      finally
        openDialog.Free;
      end;

      // Устанавливаем путь к базе данных
      config.DatabasePath := accessFile;

      zcUI.TextMessage(
        'Файл базы данных: ' + accessFile,
        TMWOHistoryOut
      );

      // Создаём экспортер напрямую
      exporter := TAccessExporter.Create(config);
      try
        // Выполняем экспорт
        exportResult := exporter.Execute;
        try
          // Выводим результаты
          zcUI.TextMessage(
            StringOfChar('=', 70),
            TMWOHistoryOut
          );

          zcUI.TextMessage(
            'РЕЗУЛЬТАТЫ ЭКСПОРТА:',
            TMWOHistoryOut
          );

          zcUI.TextMessage(
            exportResult.GetSummary,
            TMWOHistoryOut
          );

          zcUI.TextMessage(
            StringOfChar('=', 70),
            TMWOHistoryOut
          );

          // Определяем статус выполнения
          if exportResult.TotalErrors > 0 then
          begin
            zcUI.TextMessage(
              'Экспорт завершён с ошибками',
              TMWOHistoryOut
            );
            operationResult := cmd_OK_WithErrors;
          end
          else
          begin
            zcUI.TextMessage(
              'Экспорт успешно завершён',
              TMWOHistoryOut
            );
            operationResult := cmd_OK;
          end;

        finally
          exportResult.Free;
        end;

      finally
        exporter.Free;
      end;

    finally
      config.Free;
    end;

  except
    on E: Exception do
    begin
      zcUI.TextMessage(
        'ОШИБКА: ' + E.Message,
        TMWOHistoryOut
      );

      programlog.LogOutFormatStr(
        'uzvaccess: Ошибка выполнения команды экспорта: %s',
        [E.Message],
        LM_Info
      );

      operationResult := cmd_Error;
    end;
  end;
end;

end.
