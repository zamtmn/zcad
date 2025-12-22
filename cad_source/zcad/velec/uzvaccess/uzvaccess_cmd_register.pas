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

unit uzvaccess_cmd_register;

{$INCLUDE zengineconfig.inc}

interface

uses
  SysUtils,
  uzccommandsmanager, uzccommandsabstract, uzccommandsimpl,
  uzvaccess_cmd_export, uzvaccess_cmd_test, uzclog;

// Регистрация всех команд модуля uzvaccess
procedure RegisterUzvAccessCommands;

implementation

type
  // Обёртка для команды экспорта
  TAccessExportCommand = class(TCommand)
  public
    function Execute(
      pCommandParam: Pointer;
      operationResult: TCommandResult
    ): TCommandResult; override;
  end;

  // Обёртка для тестовой команды
  TAccessTestCommand = class(TCommand)
  public
    function Execute(
      pCommandParam: Pointer;
      operationResult: TCommandResult
    ): TCommandResult; override;
  end;

{ TAccessExportCommand }

function TAccessExportCommand.Execute(
  pCommandParam: Pointer;
  operationResult: TCommandResult
): TCommandResult;
begin
  CmdUzvAccessExport(pCommandParam, Result);
end;

{ TAccessTestCommand }

function TAccessTestCommand.Execute(
  pCommandParam: Pointer;
  operationResult: TCommandResult
): TCommandResult;
begin
  CmdUzvAccessTest(pCommandParam, Result);
end;

// Регистрация команд в системе ZCAD
procedure RegisterUzvAccessCommands;
var
  exportCmd: TAccessExportCommand;
  testCmd: TAccessTestCommand;
begin
  programlog.LogOutFormatStr(
    'uzvaccess: Начало регистрации команд',
    [],
    LM_Info
  );

  // Создаём и регистрируем команду экспорта
  exportCmd := TAccessExportCommand.Create('AccessExport', 0);
  CommandManager.RegisterCommand(exportCmd);

  // Создаём и регистрируем тестовую команду
  testCmd := TAccessTestCommand.Create('AccessTest', 0);
  CommandManager.RegisterCommand(testCmd);

  programlog.LogOutFormatStr(
    'uzvaccess: Команды зарегистрированы: AccessExport, AccessTest',
    [],
    LM_Info
  );
end;

end.
