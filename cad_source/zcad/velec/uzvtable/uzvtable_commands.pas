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

{**Модуль команд для восстановления таблиц}
unit uzvtable_commands;

{$INCLUDE zengineconfig.inc}

interface

uses
  SysUtils,
  uzccommandsabstract,
  uzccommandsimpl,
  uzccommandsmanager,
  uzcdrawings,
  uzcinterface,
  uzclog,
  uzvtable_manager;

// Команда восстановления таблицы из выделенных примитивов
function UzvRebuildTable_com(
  const Context: TZCADCommandContext;
  operands: TCommandOperands
): TCommandResult;

// Команда обновления выделения примитивов для таблицы
function UzvUpdateSelection_com(
  const Context: TZCADCommandContext;
  operands: TCommandOperands
): TCommandResult;

// Команда показа последней восстановленной таблицы
function UzvShowTable_com(
  const Context: TZCADCommandContext;
  operands: TCommandOperands
): TCommandResult;

implementation

// Команда восстановления таблицы из выделенных примитивов
function UzvRebuildTable_com(
  const Context: TZCADCommandContext;
  operands: TCommandOperands
): TCommandResult;
var
  manager: TUzvTableManager;
begin
  Result := cmd_ok;

  zcUI.TextMessage('==============================================', TMWOHistoryOut);
  zcUI.TextMessage('Команда: Восстановление таблицы / Command: Rebuild Table', TMWOHistoryOut);
  zcUI.TextMessage('==============================================', TMWOHistoryOut);

  // Проверяем наличие выделенных объектов
  if drawings.GetCurrentDWG^.wa.param.seldesc.Selectedobjcount = 0 then
  begin
    zcUI.TextMessage('Ошибка: не выбрано ни одного объекта / Error: no objects selected', TMWOHistoryOut);
    zcUI.TextMessage('Выделите примитивы таблицы (линии, тексты) и повторите команду', TMWOHistoryOut);
    zcUI.TextMessage('Select table primitives (lines, texts) and repeat the command', TMWOHistoryOut);
    Exit;
  end;

  try
    // Получаем менеджер таблиц
    manager := GetTableManager;

    // Запускаем процесс восстановления таблицы
    if not manager.ProcessTableRestoration then
    begin
      zcUI.TextMessage('Процесс восстановления завершен с ошибками / Process completed with errors', TMWOHistoryOut);

      if manager.Error.hasError then
      begin
        zcUI.TextMessage('Код ошибки / Error code: ' + IntToStr(manager.Error.errorCode), TMWOHistoryOut);
        zcUI.TextMessage('Сообщение / Message: ' + manager.Error.errorMessage, TMWOHistoryOut);
      end;
    end;

  except
    on E: Exception do
    begin
      zcUI.TextMessage('Критическая ошибка / Critical error: ' + E.Message, TMWOHistoryOut);
      zcLog.LogInfo('Исключение в команде UzvRebuildTable_com: ' + E.Message);
    end;
  end;

  zcUI.TextMessage('==============================================', TMWOHistoryOut);
end;

// Команда обновления выделения примитивов для таблицы
function UzvUpdateSelection_com(
  const Context: TZCADCommandContext;
  operands: TCommandOperands
): TCommandResult;
var
  manager: TUzvTableManager;
begin
  Result := cmd_ok;

  zcUI.TextMessage('Команда: Обновить выделение / Command: Update Selection', TMWOHistoryOut);

  // Проверяем наличие выделенных объектов
  if drawings.GetCurrentDWG^.wa.param.seldesc.Selectedobjcount = 0 then
  begin
    zcUI.TextMessage('Ошибка: не выбрано ни одного объекта / Error: no objects selected', TMWOHistoryOut);
    Exit;
  end;

  try
    // Получаем менеджер таблиц
    manager := GetTableManager;

    // Считываем новые примитивы
    if manager.ReadPrimitivesFromDrawing then
    begin
      zcUI.TextMessage('Выделение обновлено / Selection updated', TMWOHistoryOut);

      // Если нужно, пересобираем таблицу
      if manager.BuildTableStructure then
        zcUI.TextMessage('Структура таблицы обновлена / Table structure updated', TMWOHistoryOut);
    end;

  except
    on E: Exception do
    begin
      zcUI.TextMessage('Ошибка обновления выделения / Update error: ' + E.Message, TMWOHistoryOut);
      zcLog.LogInfo('Исключение в команде UzvUpdateSelection_com: ' + E.Message);
    end;
  end;
end;

// Команда показа последней восстановленной таблицы
function UzvShowTable_com(
  const Context: TZCADCommandContext;
  operands: TCommandOperands
): TCommandResult;
var
  manager: TUzvTableManager;
begin
  Result := cmd_ok;

  zcUI.TextMessage('Команда: Показать таблицу / Command: Show Table', TMWOHistoryOut);

  try
    // Получаем менеджер таблиц
    manager := GetTableManager;

    // Проверяем, что таблица построена
    if not manager.Table.isValid then
    begin
      zcUI.TextMessage('Ошибка: нет восстановленной таблицы / Error: no restored table', TMWOHistoryOut);
      zcUI.TextMessage('Сначала выполните команду UzvRebuildTable / First run UzvRebuildTable command', TMWOHistoryOut);
      Exit;
    end;

    // Показываем таблицу
    if not manager.ShowTableGUI then
    begin
      zcUI.TextMessage('Не удалось отобразить таблицу / Failed to display table', TMWOHistoryOut);
    end;

  except
    on E: Exception do
    begin
      zcUI.TextMessage('Ошибка отображения / Display error: ' + E.Message, TMWOHistoryOut);
      zcLog.LogInfo('Исключение в команде UzvShowTable_com: ' + E.Message);
    end;
  end;
end;

initialization
  // Регистрируем команды в системе ZCAD

  // Основная команда восстановления таблицы
  CreateZCADCommand(
    @UzvRebuildTable_com,
    'UzvRebuildTable',
    CADWG,
    0
  );

  // Команда обновления выделения
  CreateZCADCommand(
    @UzvUpdateSelection_com,
    'UzvUpdateSelection',
    CADWG,
    0
  );

  // Команда показа таблицы
  CreateZCADCommand(
    @UzvShowTable_com,
    'UzvShowTable',
    CADWG,
    0
  );

  zcLog.LogInfo('Команды модуля uzvtable зарегистрированы');

end.
