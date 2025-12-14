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
  Назначение: Команда запуска восстановления таблицы
  Описание: Модуль регистрирует команду ZCAD UzvRebuildTable, которая:
            1. Запускает процесс реставрации через менеджер
            2. Получает готовый объект TsWorkbook
            3. Показывает консольный диалог выбора действия
            4. Передает управление в мост uzvspreadsheet_bridge
            Обрабатывает ошибки и отмену диалога.
  Зависимости: ucvrtdata, ucvrtmanager, ucvrtfpsbuilder, fpspreadsheet,
               uzvspreadsheet_bridge
}
unit uzvrtrestoretablecmd;

{$INCLUDE zengineconfig.inc}

interface

uses
  SysUtils,
  Classes,
  fpspreadsheet,
  fpsTypes,
  uzccommandsabstract,
  uzccommandsimpl,
  uzccommandsmanager,
  uzcdrawings,
  uzcinterface,
  ucvrtdata,
  ucvrtmanager,
  ucvrtfpsbuilder,
  uzvrtrestoretable_dialogs;

// Команда восстановления таблицы из выделенных примитивов с сохранением в XLSX
function UzvRebuildTable_com(
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

    // Шаг 3: Показываем консольный диалог выбора действия
    zcUI.TextMessage('', TMWOHistoryOut);
    zcUI.TextMessage(
      'Таблица восстановлена успешно',
      TMWOHistoryOut
    );
    zcUI.TextMessage(
      'Table recovered successfully',
      TMWOHistoryOut
    );

    // Передаем книгу в модуль-мост для показа диалога
    uzvrtrestoretable_ShowDialog(workbook);

    // ВАЖНО: После вызова диалога НЕ освобождаем workbook,
    // если пользователь открыл книгу в редакторе.
    // Владельцем книги становится редактор.
    // Если пользователь сохранил в файл или отменил - книга остается,
    // и мы освободим её в блоке finally
    zcUI.TextMessage('', TMWOHistoryOut);

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

  // ПРИМЕЧАНИЕ: Книгу НЕ освобождаем здесь, так как владельцем может стать
  // редактор uzvspreadsheet при выборе опции "Открыть в редакторе".
  // Если пользователь выбрал "Сохранить в файл" или отменил - книга всё равно
  // остается в памяти до закрытия команды, что приемлемо для кратковременного
  // использования.
  // TODO: Возможно, потребуется доработка механизма владения книгой

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
