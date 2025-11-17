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

{**Модуль реализации команды recoveryTable для восстановления таблиц с чертежа}
unit uzvcommand_recoverytable;

{ file def.inc is necessary to include at the beginning of each module zcad
  it contains a centralized compilation parameters settings }

{ файл def.inc необходимо включать в начале каждого модуля zcad
  он содержит в себе централизованные настройки параметров компиляции  }

{$INCLUDE zengineconfig.inc}

interface

uses
  SysUtils,
  uzccommandsmanager,
  uzccommandsabstract,
  uzccommandsimpl,
  uzclog,
  uzcinterface,
  uzcdrawings,
  uzvtable_manager;

// Команда восстановления таблицы из выделенных примитивов
function recoveryTable_com(
  const Context: TZCADCommandContext;
  operands: TCommandOperands
): TCommandResult;

implementation

// Команда восстановления таблицы из выделенных примитивов
function recoveryTable_com(
  const Context: TZCADCommandContext;
  operands: TCommandOperands
): TCommandResult;
var
  manager: TUzvTableManager;
  selectedCount: Integer;
begin
  Result := cmd_ok;

  // Вывод сообщения о запуске команды
  zcUI.TextMessage('==============================================', TMWOHistoryOut);
  zcUI.TextMessage('Команда: Восстановление таблицы / Command: Recovery Table', TMWOHistoryOut);
  zcUI.TextMessage('==============================================', TMWOHistoryOut);

  // Проверяем наличие выделенных объектов
  selectedCount := drawings.GetCurrentDWG^.wa.param.seldesc.Selectedobjcount;

  if selectedCount = 0 then
  begin
    zcUI.TextMessage('Ошибка: не выбрано ни одного объекта', TMWOHistoryOut);
    zcUI.TextMessage('Error: no objects selected', TMWOHistoryOut);
    zcUI.TextMessage('', TMWOHistoryOut);
    zcUI.TextMessage('Выделите примитивы таблицы (линии, тексты) и повторите команду', TMWOHistoryOut);
    zcUI.TextMessage('Select table primitives (lines, texts) and repeat the command', TMWOHistoryOut);
    zcUI.TextMessage('==============================================', TMWOHistoryOut);
    Exit;
  end;

  zcUI.TextMessage('Выделено объектов / Selected objects: ' + IntToStr(selectedCount), TMWOHistoryOut);

  try
    // Получаем глобальный менеджер таблиц
    manager := GetTableManager;

    // Запускаем процесс восстановления таблицы
    if not manager.ProcessTableRestoration then
    begin
      zcUI.TextMessage('', TMWOHistoryOut);
      zcUI.TextMessage('Процесс восстановления завершен с ошибками', TMWOHistoryOut);
      zcUI.TextMessage('Process completed with errors', TMWOHistoryOut);

      // Выводим детали ошибки
      if manager.Error.hasError then
      begin
        zcUI.TextMessage('Код ошибки / Error code: ' + IntToStr(manager.Error.errorCode), TMWOHistoryOut);
        zcUI.TextMessage('Сообщение / Message: ' + manager.Error.errorMessage, TMWOHistoryOut);
      end;
    end
    else
    begin
      zcUI.TextMessage('', TMWOHistoryOut);
      zcUI.TextMessage('Таблица успешно восстановлена', TMWOHistoryOut);
      zcUI.TextMessage('Table successfully recovered', TMWOHistoryOut);
    end;

  except
    on E: Exception do
    begin
      zcUI.TextMessage('', TMWOHistoryOut);
      zcUI.TextMessage('Критическая ошибка / Critical error: ' + E.Message, TMWOHistoryOut);
      zcUI.TextMessage('Исключение в команде recoveryTable_com: ' + E.Message, TMWOHistoryOut);
    end;
  end;

  zcUI.TextMessage('==============================================', TMWOHistoryOut);
end;

initialization
  // Регистрация команды recoveryTable в системе ZCAD
  CreateZCADCommand(
    @recoveryTable_com,
    'recoveryTable',
    CADWG,
    0
  );

  zcUI.TextMessage('Команда recoveryTable зарегистрирована', TMWOHistoryOut);

end.
