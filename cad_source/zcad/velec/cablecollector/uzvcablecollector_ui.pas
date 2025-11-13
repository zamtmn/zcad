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

unit uzvcablecollector_ui;

{$INCLUDE zengineconfig.inc}

interface

uses
  SysUtils,
  uzcinterface,
  uzcuitypes,
  uzvcablecollector_types,
  uzvcablecollector_utils;

const
  // Константы для локализации интерфейса
  MSG_START_COLLECTION = '[INFO] Сбор данных о кабелях...';
  MSG_PRIMITIVES_PROCESSED = '[INFO] Обработано %d примитивов.';
  MSG_ANALYSIS_COMPLETE = '[INFO] Анализ по методам монтажа завершён.';
  MSG_COMPLETE_SUCCESS = '[INFO] Завершено успешно.';

  // Константы для таблицы
  TABLE_HEADER_LINE = '-----------------------------------------------------';
  TABLE_HEADER = 'Имя кабеля              | Метод монтажа   | Суммарная длина';

// Вывод сообщения о начале сбора данных
procedure PrintStartMessage;

// Вывод информации о количестве обработанных примитивов
procedure PrintProcessedCount(const Count: Integer);

// Вывод сообщения о завершении анализа
procedure PrintAnalysisComplete;

// Вывод таблицы с результатами группировки
procedure PrintResultsTable(const GroupedData: TCableGroupInfoVector);

// Вывод сообщения о завершении
procedure PrintCompleteMessage;

implementation

// Вывод сообщения о начале сбора
procedure PrintStartMessage;
begin
  zcUI.TextMessage(MSG_START_COLLECTION, TMWOHistoryOut);
end;

// Вывод количества обработанных примитивов
procedure PrintProcessedCount(const Count: Integer);
begin
  zcUI.TextMessage(Format(MSG_PRIMITIVES_PROCESSED, [Count]), TMWOHistoryOut);
end;

// Вывод сообщения о завершении анализа
procedure PrintAnalysisComplete;
begin
  zcUI.TextMessage(MSG_ANALYSIS_COMPLETE, TMWOHistoryOut);
end;

// Вывод таблицы с результатами
procedure PrintResultsTable(const GroupedData: TCableGroupInfoVector);
var
  I: Integer;
  GroupInfo: PTCableGroupInfo;
  OutputLine: String;
begin
  // Печать заголовка таблицы
  zcUI.TextMessage(TABLE_HEADER_LINE, TMWOHistoryOut);
  zcUI.TextMessage(TABLE_HEADER, TMWOHistoryOut);
  zcUI.TextMessage(TABLE_HEADER_LINE, TMWOHistoryOut);

  // Печать данных
  for I := 0 to GroupedData.Count - 1 do
  begin
    GroupInfo := GroupedData.GetMutable(I);
    OutputLine := Format('%-24s| %-16s| %s',
                        [GroupInfo^.CableName,
                         GroupInfo^.MountingMethod,
                         FormatCableLength(GroupInfo^.TotalLength)]);
    zcUI.TextMessage(OutputLine, TMWOHistoryOut);
  end;

  // Печать нижней линии таблицы
  zcUI.TextMessage(TABLE_HEADER_LINE, TMWOHistoryOut);
end;

// Вывод сообщения о завершении
procedure PrintCompleteMessage;
begin
  zcUI.TextMessage(MSG_COMPLETE_SUCCESS, TMWOHistoryOut);
end;

end.
