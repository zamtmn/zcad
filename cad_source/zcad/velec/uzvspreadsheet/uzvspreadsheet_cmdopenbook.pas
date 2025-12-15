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

{** Модуль команды открытия книги из файла
    Содержит логику диалога выбора файла, загрузки книги и обработки ошибок }
unit uzvspreadsheet_cmdopenbook;

{$INCLUDE zengineconfig.inc}

interface

uses
  Classes,
  SysUtils,
  fpspreadsheet,
  fpsTypes,
  uzvspreadsheet_gui,
  fpspreadsheetctrls;

{ Выполняет открытие книги из файла через диалог выбора }
procedure ExecuteOpenBook(aWorkbookSource: TsWorkbookSource);

{ Загружает книгу из указанного файла }
function LoadBookFromFile(aWorkbookSource: TsWorkbookSource;
  const aFilePath: String): Boolean;

{ Загружает книгу из указанной книги }
function LoadBookFromFileTsWorkbook(aWorkbook: TsWorkbook): Boolean;

implementation

uses
  Dialogs,
  uzclog,
  uzcinterface;

const
  // Фильтр для диалога открытия файлов
  XLSX_FILTER = 'Файлы Excel (*.xlsx)|*.xlsx|' +
                'Файлы Excel 97-2003 (*.xls)|*.xls|' +
                'Все файлы (*.*)|*.*';

{ Загружает книгу из указанного файла }
function LoadBookFromFile(aWorkbookSource: TsWorkbookSource;
  const aFilePath: String): Boolean;
begin
  Result := False;

  if aWorkbookSource = nil then
  begin
    zcUI.TextMessage('Ошибка: источник данных книги не инициализирован',
      TMWOHistoryOut);
    Exit;
  end;

  // Проверяем существование файла
  if not FileExists(aFilePath) then
  begin
    programlog.LogOutFormatStr(
      'Файл не найден: %s',
      [aFilePath],
      LM_Info
    );
    zcUI.TextMessage('Ошибка: файл не найден - ' + aFilePath, TMWOHistoryOut);
    Exit;
  end;

  try
    // Загружаем книгу из файла
    // WorkbookSource автоматически определит формат по расширению
    aWorkbookSource.LoadFromSpreadsheetFile(aFilePath);

    // Включаем чтение формул
    if aWorkbookSource.Workbook <> nil then
      aWorkbookSource.Workbook.Options :=
        aWorkbookSource.Workbook.Options + [boReadFormulas];

    programlog.LogOutFormatStr(
      'Книга загружена из файла: %s',
      [aFilePath],
      LM_Info
    );
    zcUI.TextMessage('Книга загружена: ' + aFilePath, TMWOHistoryOut);

    Result := True;
  except
    on E: Exception do
    begin
      programlog.LogOutFormatStr(
        'Ошибка загрузки книги из файла %s: %s',
        [aFilePath, E.Message],
        LM_Info
      );
      zcUI.TextMessage('Ошибка загрузки книги: ' + E.Message, TMWOHistoryOut);
    end;
  end;
end;
{ Загружает книгу из указанной книги }
function LoadBookFromFileTsWorkbook(aWorkbook: TsWorkbook): Boolean;
var
  aWorkbookSource: TsWorkbookSource;
begin
  Result := False;

  if aWorkbook = nil then
  begin
    zcUI.TextMessage('Ошибка: книга для выгрузки не создана',
      TMWOHistoryOut);
    Exit;
  end;


  try
    aWorkbookSource:=uzvspreadsheet_gui.uzvSpreadsheetForm.FWorkbookSource;
    // Загружаем книгу из файла
    // WorkbookSource автоматически определит формат по расширению
    aWorkbookSource.LoadFromWorkbook(aWorkbook);

    // Включаем чтение формул
    if aWorkbookSource.Workbook <> nil then
      aWorkbookSource.Workbook.Options :=
        aWorkbookSource.Workbook.Options + [boReadFormulas];

    Result := True;
  except
    on E: Exception do
    begin
      programlog.LogOutFormatStr(
        'Ошибка загрузки книги из ZCAD',
        [aWorkbook, E.Message],
        LM_Info
      );
      zcUI.TextMessage('Ошибка загрузки книги: ' + E.Message, TMWOHistoryOut);
    end;
  end;
end;
{ Выполняет открытие книги из файла через диалог выбора }
procedure ExecuteOpenBook(aWorkbookSource: TsWorkbookSource);
var
  openDialog: TOpenDialog;
begin
  if aWorkbookSource = nil then
  begin
    zcUI.TextMessage('Ошибка: источник данных книги не инициализирован',
      TMWOHistoryOut);
    Exit;
  end;

  // Создаём диалог открытия файла
  openDialog := TOpenDialog.Create(nil);
  try
    openDialog.Title := 'Открыть книгу / Open Workbook';
    openDialog.Filter := XLSX_FILTER;
    openDialog.FilterIndex := 1;
    openDialog.DefaultExt := 'xlsx';

    // Показываем диалог выбора файла
    if openDialog.Execute then
    begin
      programlog.LogOutFormatStr(
        'Пользователь выбрал файл: %s',
        [openDialog.FileName],
        LM_Info
      );

      // Загружаем выбранный файл
      LoadBookFromFile(aWorkbookSource, openDialog.FileName);
    end
    else
    begin
      programlog.LogOutFormatStr(
        'Открытие файла отменено пользователем',
        [],
        LM_Info
      );
      zcUI.TextMessage('Открытие файла отменено', TMWOHistoryOut);
    end;
  finally
    openDialog.Free;
  end;
end;

end.
