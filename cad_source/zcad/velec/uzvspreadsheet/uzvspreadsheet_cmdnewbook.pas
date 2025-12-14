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

{** Модуль команды создания новой книги
    Содержит логику диалога подтверждения, очистки и создания книги }
unit uzvspreadsheet_cmdnewbook;

{$INCLUDE zengineconfig.inc}

interface

uses
  Classes,
  SysUtils,
  fpspreadsheet,
  fpspreadsheetctrls;

{ Выполняет создание новой книги с подтверждением пользователя }
procedure ExecuteNewBook(aWorkbookSource: TsWorkbookSource);

{ Создаёт новую пустую книгу без подтверждения }
procedure CreateEmptyBook(aWorkbookSource: TsWorkbookSource);

implementation

uses
  Dialogs,
  Controls,
  uzclog,
  uzcinterface;

{ Создаёт новую пустую книгу без подтверждения }
procedure CreateEmptyBook(aWorkbookSource: TsWorkbookSource);
begin
  if aWorkbookSource = nil then
  begin
    zcUI.TextMessage('Ошибка: источник данных книги не инициализирован',
      TMWOHistoryOut);
    Exit;
  end;

  try
    // Создаём новую книгу через WorkbookSource
    aWorkbookSource.CreateNewWorkbook;

    programlog.LogOutFormatStr(
      'Создана новая книга электронных таблиц',
      [],
      LM_Info
    );
    zcUI.TextMessage('Создана новая книга', TMWOHistoryOut);
  except
    on E: Exception do
    begin
      programlog.LogOutFormatStr(
        'Ошибка создания книги: %s',
        [E.Message],
        LM_Info
      );
      zcUI.TextMessage('Ошибка создания книги: ' + E.Message, TMWOHistoryOut);
    end;
  end;
end;

{ Выполняет создание новой книги с подтверждением пользователя }
procedure ExecuteNewBook(aWorkbookSource: TsWorkbookSource);
var
  dialogResult: Integer;
  hasUnsavedChanges: Boolean;
begin
  if aWorkbookSource = nil then
  begin
    zcUI.TextMessage('Ошибка: источник данных книги не инициализирован',
      TMWOHistoryOut);
    Exit;
  end;

  // Проверяем наличие несохранённых изменений
  hasUnsavedChanges := False;
  if (aWorkbookSource.Workbook <> nil) then
  begin
    // Если книга была изменена - запрашиваем подтверждение
    // NOTE: fpspreadsheet не предоставляет прямого свойства Modified,
    // поэтому всегда спрашиваем подтверждение если книга не пустая
    if aWorkbookSource.Workbook.GetWorksheetCount > 0 then
      hasUnsavedChanges := True;
  end;

  // Если есть несохранённые изменения - запрашиваем подтверждение
  if hasUnsavedChanges then
  begin
    dialogResult := MessageDlg(
      'Подтверждение',
      'Создать новую книгу? Несохранённые данные будут потеряны.',
      mtConfirmation,
      [mbYes, mbNo],
      0
    );

    if dialogResult <> mrYes then
    begin
      programlog.LogOutFormatStr(
        'Создание новой книги отменено пользователем',
        [],
        LM_Info
      );
      zcUI.TextMessage('Создание новой книги отменено', TMWOHistoryOut);
      Exit;
    end;
  end;

  // Создаём новую книгу
  CreateEmptyBook(aWorkbookSource);
end;

end.
