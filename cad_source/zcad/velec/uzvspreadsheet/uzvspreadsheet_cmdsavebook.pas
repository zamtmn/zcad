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

{** Модуль команды сохранения книги в файл
    Содержит логику диалога выбора файла, сохранения книги и обработки ошибок }
unit uzvspreadsheet_cmdsavebook;

{$INCLUDE zengineconfig.inc}

interface

uses
  Classes,
  SysUtils,
  fpspreadsheet,
  fpsTypes,
  fpspreadsheetctrls;

{ Выполняет сохранение книги в файл через диалог выбора }
procedure ExecuteSaveBookAs(aWorkbookSource: TsWorkbookSource);

{ Выполняет сохранение книги в текущий файл }
function ExecuteSaveBook(aWorkbookSource: TsWorkbookSource): Boolean;

{ Сохраняет книгу в указанный файл }
function SaveBookToFile(aWorkbookSource: TsWorkbookSource;
  const aFilePath: String): Boolean;

implementation

uses
  Dialogs,
  uzclog,
  uzcinterface;

const
  // Фильтр для диалога сохранения файлов
  XLSX_FILTER = 'Файлы Excel (*.xlsx)|*.xlsx|' +
                'Все файлы (*.*)|*.*';

{ Сохраняет книгу в указанный файл }
function SaveBookToFile(aWorkbookSource: TsWorkbookSource;
  const aFilePath: String): Boolean;
begin
  Result := False;

  if aWorkbookSource = nil then
  begin
    zcUI.TextMessage('Ошибка: источник данных книги не инициализирован',
      TMWOHistoryOut);
    Exit;
  end;

  if aWorkbookSource.Workbook = nil then
  begin
    zcUI.TextMessage('Ошибка: книга не загружена', TMWOHistoryOut);
    Exit;
  end;

  try
    // Сохраняем книгу в формате XLSX
    aWorkbookSource.Workbook.WriteToFile(aFilePath, sfOOXML, True);

    programlog.LogOutFormatStr(
      'Книга сохранена в файл: %s',
      [aFilePath],
      LM_Info
    );
    zcUI.TextMessage('Книга сохранена: ' + aFilePath, TMWOHistoryOut);

    Result := True;
  except
    on E: Exception do
    begin
      programlog.LogOutFormatStr(
        'Ошибка сохранения книги в файл %s: %s',
        [aFilePath, E.Message],
        LM_Info
      );
      zcUI.TextMessage('Ошибка сохранения книги: ' + E.Message, TMWOHistoryOut);
    end;
  end;
end;

{ Выполняет сохранение книги в текущий файл }
function ExecuteSaveBook(aWorkbookSource: TsWorkbookSource): Boolean;
var
  currentPath: String;
begin
  Result := False;

  if aWorkbookSource = nil then
  begin
    zcUI.TextMessage('Ошибка: источник данных книги не инициализирован',
      TMWOHistoryOut);
    Exit;
  end;

  if aWorkbookSource.Workbook = nil then
  begin
    zcUI.TextMessage('Ошибка: книга не загружена', TMWOHistoryOut);
    Exit;
  end;

  // Получаем текущий путь к файлу
  currentPath := aWorkbookSource.Workbook.FileName;

  // Если путь не задан - вызываем диалог "Сохранить как"
  if currentPath = '' then
  begin
    ExecuteSaveBookAs(aWorkbookSource);
    Exit;
  end;

  // Сохраняем в текущий файл
  Result := SaveBookToFile(aWorkbookSource, currentPath);
end;

{ Выполняет сохранение книги в файл через диалог выбора }
procedure ExecuteSaveBookAs(aWorkbookSource: TsWorkbookSource);
var
  saveDialog: TSaveDialog;
begin
  if aWorkbookSource = nil then
  begin
    zcUI.TextMessage('Ошибка: источник данных книги не инициализирован',
      TMWOHistoryOut);
    Exit;
  end;

  if aWorkbookSource.Workbook = nil then
  begin
    zcUI.TextMessage('Ошибка: книга не загружена', TMWOHistoryOut);
    Exit;
  end;

  // Создаём диалог сохранения файла
  saveDialog := TSaveDialog.Create(nil);
  try
    saveDialog.Title := 'Сохранить книгу / Save Workbook';
    saveDialog.Filter := XLSX_FILTER;
    saveDialog.FilterIndex := 1;
    saveDialog.DefaultExt := 'xlsx';
    saveDialog.FileName := 'workbook.xlsx';

    // Если книга уже имеет путь - предлагаем его по умолчанию
    if aWorkbookSource.Workbook.FileName <> '' then
      saveDialog.FileName := aWorkbookSource.Workbook.FileName;

    // Показываем диалог выбора файла
    if saveDialog.Execute then
    begin
      programlog.LogOutFormatStr(
        'Пользователь выбрал файл для сохранения: %s',
        [saveDialog.FileName],
        LM_Info
      );

      // Сохраняем в выбранный файл
      SaveBookToFile(aWorkbookSource, saveDialog.FileName);
    end
    else
    begin
      programlog.LogOutFormatStr(
        'Сохранение файла отменено пользователем',
        [],
        LM_Info
      );
      zcUI.TextMessage('Сохранение файла отменено', TMWOHistoryOut);
    end;
  finally
    saveDialog.Free;
  end;
end;

end.
