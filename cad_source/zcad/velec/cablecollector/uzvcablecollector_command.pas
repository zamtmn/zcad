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

unit uzvcablecollector_command;

{$INCLUDE zengineconfig.inc}

interface

uses
  uzccommandsabstract,
  uzccommandsimpl,
  uzccommandsmanager,
  uzvcablecollector_core,
  uzcLog;

// Функция-команда для запуска сбора и анализа кабелей
function CableCollector_Run_com(const Context: TZCADCommandContext;
                                operands: TCommandOperands): TCommandResult;

implementation

// Реализация команды сбора кабелей
function CableCollector_Run_com(const Context: TZCADCommandContext;
                                operands: TCommandOperands): TCommandResult;
var
  Collector: TCableCollector;
begin
  programlog.LogOutFormatStr('CableCollector command started', [], LM_Info);

  // Создание экземпляра коллектора
  Collector := TCableCollector.Create;
  try
    // Последовательное выполнение этапов
    Collector.Collect;   // Сбор данных
    Collector.Analyze;   // Анализ и группировка
    Collector.PrintToZcUI; // Вывод результатов

    Result := cmd_ok;
    programlog.LogOutFormatStr('CableCollector command completed successfully',
                               [], LM_Info);
  finally
    Collector.Free;
  end;
end;

initialization
  // Регистрация команды в системе
  CreateZCADCommand(@CableCollector_Run_com, 'CableCollector', CADWG, 0);
  programlog.LogOutFormatStr('CableCollector command registered', [], LM_Info);

end.
