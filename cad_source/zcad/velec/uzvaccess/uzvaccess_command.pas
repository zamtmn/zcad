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

{**Модуль реализации и регистрации команды экспорта в MS Access}
unit uzvaccess_command;

{$INCLUDE zengineconfig.inc}

interface

uses
  SysUtils,
  Classes,
  Dialogs,
  uzccommandsmanager,
  uzccommandsabstract,
  uzccommandsimpl,
  uzclog,
  uzcinterface,
  uzcdrawings,
  uzbtypes,
  uzvaccess_types,
  uzvaccess_config,
  uzvaccess_exporter;

{**Функция команды экспорта данных в MS Access}
function AccessExport_com(
  const Context: TZCADCommandContext;
  operands: TCommandOperands
): TCommandResult;

implementation

{**Получить путь к файлу базы данных из пользовательского диалога}
function GetDatabasePath: string;
var
  openDialog: TOpenDialog;
begin
  Result := '';

  openDialog := TOpenDialog.Create(nil);
  try
    openDialog.Title := 'Выберите файл базы данных MS Access';
    openDialog.Filter := 'MS Access Database|*.mdb;*.accdb|All Files|*.*';
    openDialog.Options := [ofFileMustExist, ofEnableSizing];

    if openDialog.Execute then
      Result := openDialog.FileName;
  finally
    openDialog.Free;
  end;
end;

{**Вывести результаты экспорта в интерфейс}
procedure DisplayExportResults(const exportResult: TExportResult);
begin
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
end;

{**Определить код результата на основе количества ошибок}
function DetermineCommandResult(totalErrors: Integer): TCommandResult;
begin
  if totalErrors > 0 then
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
end;

{**Выполнить процесс экспорта данных}
function PerformExport(const databasePath: string): TCommandResult;
var
  config: TExportConfig;
  exporter: TAccessExporter;
  exportResult: TExportResult;
begin
  Result := cmd_Error;

  config := TExportConfig.Create;
  try
    config.DatabasePath := databasePath;

    zcUI.TextMessage(
      'Файл базы данных: ' + databasePath,
      TMWOHistoryOut
    );

    exporter := TAccessExporter.Create(config);
    try
      exportResult := exporter.Execute;
      try
        DisplayExportResults(exportResult);
        Result := DetermineCommandResult(exportResult.TotalErrors);
      finally
        exportResult.Free;
      end;
    finally
      exporter.Free;
    end;
  finally
    config.Free;
  end;
end;

{**Функция команды экспорта данных в MS Access}
function AccessExport_com(
  const Context: TZCADCommandContext;
  operands: TCommandOperands
): TCommandResult;
var
  databasePath: string;
begin
  zcUI.TextMessage(
    'Запуск экспорта данных в MS Access...',
    TMWOHistoryOut
  );

  programlog.LogOutFormatStr(
    'uzvaccess: Запуск команды экспорта в MS Access',
    [],
    LM_Info
  );

  try
    databasePath := GetDatabasePath;

    if databasePath = '' then
    begin
      zcUI.TextMessage(
        'Экспорт отменён: файл не выбран',
        TMWOHistoryOut
      );
      Result := cmd_OK;
      Exit;
    end;

    Result := PerformExport(databasePath);

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

      Result := cmd_Error;
    end;
  end;
end;

initialization
  CreateZCADCommand(
    @AccessExport_com,
    'AccessExport',
    CADWG,
    0
  );

end.
