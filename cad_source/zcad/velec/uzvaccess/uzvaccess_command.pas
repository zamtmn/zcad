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

unit uzvaccess_command;

{$INCLUDE zengineconfig.inc}

interface

uses
  SysUtils, Classes, Dialogs,
  uzccommandsabstract, uzccommandsimpl, uzcinterface,
  uzvaccess_types, uzvaccess_config, uzvaccess_exporter;

type
  {**
    Команда экспорта данных в MS Access

    Использует гибкую систему управляющих таблиц EXPORT для
    настройки процесса экспорта без перекомпиляции
  **}
  TAccessExportCommand = class(TCommand)
  public
    // Выполнить команду
    function Execute(
      pCommandParam: Pointer;
      operationResult: TCommandResult
    ): TCommandResult; override;
  end;

// Функция инициализации модуля
procedure InitializeAccessExportCommand;

implementation

uses
  uzcLog;

var
  // Глобальный экземпляр команды
  AccessExportCmd: TAccessExportCommand;

{ TAccessExportCommand }

function TAccessExportCommand.Execute(
  pCommandParam: Pointer;
  operationResult: TCommandResult
): TCommandResult;
var
  config: TExportConfig;
  exporter: TAccessExporter;
  exportResult: TExportResult;
  accessFile: String;
  openDialog: TOpenDialog;
begin
  Result := operationResult;

  // Вывод информационного сообщения
  zcUI.TextMessage(
    'Запуск экспорта данных в MS Access...',
    TMWOHistoryOut
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
          Result := cmd_OK;
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

      // Создаём экспортер
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
            Result := cmd_OK_WithErrors;
          end
          else
          begin
            zcUI.TextMessage(
              'Экспорт успешно завершён',
              TMWOHistoryOut
            );
            Result := cmd_OK;
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
        LM_Error
      );

      Result := cmd_Error;
    end;
  end;
end;

{ Инициализация }

procedure InitializeAccessExportCommand;
begin
  // Создаём экземпляр команды
  AccessExportCmd := TAccessExportCommand.Create(
    'AccessExport',
    'Экспорт данных в MS Access'
  );

  // Регистрируем команду в системе ZCAD
  // Примечание: конкретный способ регистрации зависит от
  // архитектуры системы команд ZCAD
  // Здесь показан общий подход

  programlog.LogOutStr(
    'uzvaccess: Команда AccessExport зарегистрирована',
    LM_Info,
    LM2006_01_Messages
  );
end;

initialization
  // Автоматическая регистрация при загрузке модуля
  InitializeAccessExportCommand;

finalization
  // Освобождение ресурсов
  if AccessExportCmd <> nil then
  begin
    AccessExportCmd.Free;
    AccessExportCmd := nil;
  end;

end.
