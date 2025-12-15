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

{** Модуль команд для работы со строками и столбцами таблицы
    Содержит логику добавления и удаления строк и столбцов }
unit uzvspreadsheet_cmdrowcolumns;

{$INCLUDE zengineconfig.inc}

interface

uses
  Classes,
  SysUtils,
  fpspreadsheet,
  fpsTypes,
  fpspreadsheetctrls,
  fpspreadsheetgrid;

{ Добавляет строку под выделенной ячейкой }
procedure ExecuteAddRowBelow(aWorkbookSource: TsWorkbookSource;
  aWorksheetGrid: TsWorksheetGrid);

{ Добавляет строку над выделенной ячейкой }
procedure ExecuteAddRowAbove(aWorkbookSource: TsWorkbookSource;
  aWorksheetGrid: TsWorksheetGrid);

{ Добавляет столбец справа от выделенной ячейки }
procedure ExecuteAddColumnRight(aWorkbookSource: TsWorkbookSource;
  aWorksheetGrid: TsWorksheetGrid);

{ Добавляет столбец слева от выделенной ячейки }
procedure ExecuteAddColumnLeft(aWorkbookSource: TsWorkbookSource;
  aWorksheetGrid: TsWorksheetGrid);

{ Удаляет строку, в которой выделена ячейка }
procedure ExecuteDeleteRow(aWorkbookSource: TsWorkbookSource;
  aWorksheetGrid: TsWorksheetGrid);

{ Удаляет столбец, в которой выделена ячейка }
procedure ExecuteDeleteColumn(aWorkbookSource: TsWorkbookSource;
  aWorksheetGrid: TsWorksheetGrid);

implementation

uses
  uzclog,
  uzcinterface;

{ Добавляет строку под выделенной ячейкой }
procedure ExecuteAddRowBelow(aWorkbookSource: TsWorkbookSource;
  aWorksheetGrid: TsWorksheetGrid);
var
  workbook: TsWorkbook;
  worksheet: TsWorksheet;
  row, col: Cardinal;
begin
  if (aWorkbookSource = nil) or (aWorksheetGrid = nil) then
  begin
    zcUI.TextMessage('Ошибка: источник данных не инициализирован',
      TMWOHistoryOut);
    Exit;
  end;

  workbook := aWorkbookSource.Workbook;
  if workbook = nil then
  begin
    zcUI.TextMessage('Ошибка: книга не загружена', TMWOHistoryOut);
    Exit;
  end;

  worksheet := workbook.ActiveWorksheet;
  if worksheet = nil then
  begin
    zcUI.TextMessage('Ошибка: активный лист не выбран', TMWOHistoryOut);
    Exit;
  end;

  try
    // Получаем координаты выделенной ячейки
    row := aWorksheetGrid.Row - aWorksheetGrid.FixedRows;
    col := aWorksheetGrid.Col - aWorksheetGrid.FixedCols;

    // Вставляем новую строку после текущей
    worksheet.InsertRow(row + 1);

    programlog.LogOutFormatStr(
      'Добавлена строка под ячейкой [%d, %d]',
      [row, col],
      LM_Info
    );
    zcUI.TextMessage('Строка добавлена', TMWOHistoryOut);
  except
    on E: Exception do
    begin
      programlog.LogOutFormatStr(
        'Ошибка добавления строки: %s',
        [E.Message],
        LM_Error
      );
      zcUI.TextMessage('Ошибка добавления строки: ' + E.Message,
        TMWOHistoryOut);
    end;
  end;
end;

{ Добавляет строку над выделенной ячейкой }
procedure ExecuteAddRowAbove(aWorkbookSource: TsWorkbookSource;
  aWorksheetGrid: TsWorksheetGrid);
var
  workbook: TsWorkbook;
  worksheet: TsWorksheet;
  row, col: Cardinal;
begin
  if (aWorkbookSource = nil) or (aWorksheetGrid = nil) then
  begin
    zcUI.TextMessage('Ошибка: источник данных не инициализирован',
      TMWOHistoryOut);
    Exit;
  end;

  workbook := aWorkbookSource.Workbook;
  if workbook = nil then
  begin
    zcUI.TextMessage('Ошибка: книга не загружена', TMWOHistoryOut);
    Exit;
  end;

  worksheet := workbook.ActiveWorksheet;
  if worksheet = nil then
  begin
    zcUI.TextMessage('Ошибка: активный лист не выбран', TMWOHistoryOut);
    Exit;
  end;

  try
    // Получаем координаты выделенной ячейки
    row := aWorksheetGrid.Row - aWorksheetGrid.FixedRows;
    col := aWorksheetGrid.Col - aWorksheetGrid.FixedCols;

    // Вставляем новую строку перед текущей
    worksheet.InsertRow(row);

    programlog.LogOutFormatStr(
      'Добавлена строка над ячейкой [%d, %d]',
      [row, col],
      LM_Info
    );
    zcUI.TextMessage('Строка добавлена', TMWOHistoryOut);
  except
    on E: Exception do
    begin
      programlog.LogOutFormatStr(
        'Ошибка добавления строки: %s',
        [E.Message],
        LM_Error
      );
      zcUI.TextMessage('Ошибка добавления строки: ' + E.Message,
        TMWOHistoryOut);
    end;
  end;
end;

{ Добавляет столбец справа от выделенной ячейки }
procedure ExecuteAddColumnRight(aWorkbookSource: TsWorkbookSource;
  aWorksheetGrid: TsWorksheetGrid);
var
  workbook: TsWorkbook;
  worksheet: TsWorksheet;
  row, col: Cardinal;
begin
  if (aWorkbookSource = nil) or (aWorksheetGrid = nil) then
  begin
    zcUI.TextMessage('Ошибка: источник данных не инициализирован',
      TMWOHistoryOut);
    Exit;
  end;

  workbook := aWorkbookSource.Workbook;
  if workbook = nil then
  begin
    zcUI.TextMessage('Ошибка: книга не загружена', TMWOHistoryOut);
    Exit;
  end;

  worksheet := workbook.ActiveWorksheet;
  if worksheet = nil then
  begin
    zcUI.TextMessage('Ошибка: активный лист не выбран', TMWOHistoryOut);
    Exit;
  end;

  try
    // Получаем координаты выделенной ячейки
    row := aWorksheetGrid.Row - aWorksheetGrid.FixedRows;
    col := aWorksheetGrid.Col - aWorksheetGrid.FixedCols;

    // Вставляем новый столбец после текущего
    worksheet.InsertCol(col + 1);

    programlog.LogOutFormatStr(
      'Добавлен столбец справа от ячейки [%d, %d]',
      [row, col],
      LM_Info
    );
    zcUI.TextMessage('Столбец добавлен', TMWOHistoryOut);
  except
    on E: Exception do
    begin
      programlog.LogOutFormatStr(
        'Ошибка добавления столбца: %s',
        [E.Message],
        LM_Error
      );
      zcUI.TextMessage('Ошибка добавления столбца: ' + E.Message,
        TMWOHistoryOut);
    end;
  end;
end;

{ Добавляет столбец слева от выделенной ячейки }
procedure ExecuteAddColumnLeft(aWorkbookSource: TsWorkbookSource;
  aWorksheetGrid: TsWorksheetGrid);
var
  workbook: TsWorkbook;
  worksheet: TsWorksheet;
  row, col: Cardinal;
begin
  if (aWorkbookSource = nil) or (aWorksheetGrid = nil) then
  begin
    zcUI.TextMessage('Ошибка: источник данных не инициализирован',
      TMWOHistoryOut);
    Exit;
  end;

  workbook := aWorkbookSource.Workbook;
  if workbook = nil then
  begin
    zcUI.TextMessage('Ошибка: книга не загружена', TMWOHistoryOut);
    Exit;
  end;

  worksheet := workbook.ActiveWorksheet;
  if worksheet = nil then
  begin
    zcUI.TextMessage('Ошибка: активный лист не выбран', TMWOHistoryOut);
    Exit;
  end;

  try
    // Получаем координаты выделенной ячейки
    row := aWorksheetGrid.Row - aWorksheetGrid.FixedRows;
    col := aWorksheetGrid.Col - aWorksheetGrid.FixedCols;

    // Вставляем новый столбец перед текущим
    worksheet.InsertCol(col);

    programlog.LogOutFormatStr(
      'Добавлен столбец слева от ячейки [%d, %d]',
      [row, col],
      LM_Info
    );
    zcUI.TextMessage('Столбец добавлен', TMWOHistoryOut);
  except
    on E: Exception do
    begin
      programlog.LogOutFormatStr(
        'Ошибка добавления столбца: %s',
        [E.Message],
        LM_Error
      );
      zcUI.TextMessage('Ошибка добавления столбца: ' + E.Message,
        TMWOHistoryOut);
    end;
  end;
end;

{ Удаляет строку, в которой выделена ячейка }
procedure ExecuteDeleteRow(aWorkbookSource: TsWorkbookSource;
  aWorksheetGrid: TsWorksheetGrid);
var
  workbook: TsWorkbook;
  worksheet: TsWorksheet;
  row, col: Cardinal;
begin
  if (aWorkbookSource = nil) or (aWorksheetGrid = nil) then
  begin
    zcUI.TextMessage('Ошибка: источник данных не инициализирован',
      TMWOHistoryOut);
    Exit;
  end;

  workbook := aWorkbookSource.Workbook;
  if workbook = nil then
  begin
    zcUI.TextMessage('Ошибка: книга не загружена', TMWOHistoryOut);
    Exit;
  end;

  worksheet := workbook.ActiveWorksheet;
  if worksheet = nil then
  begin
    zcUI.TextMessage('Ошибка: активный лист не выбран', TMWOHistoryOut);
    Exit;
  end;

  try
    // Получаем координаты выделенной ячейки
    row := aWorksheetGrid.Row - aWorksheetGrid.FixedRows;
    col := aWorksheetGrid.Col - aWorksheetGrid.FixedCols;

    // Удаляем строку с текущей ячейкой
    worksheet.DeleteRow(row);

    programlog.LogOutFormatStr(
      'Удалена строка с ячейкой [%d, %d]',
      [row, col],
      LM_Info
    );
    zcUI.TextMessage('Строка удалена', TMWOHistoryOut);
  except
    on E: Exception do
    begin
      programlog.LogOutFormatStr(
        'Ошибка удаления строки: %s',
        [E.Message],
        LM_Error
      );
      zcUI.TextMessage('Ошибка удаления строки: ' + E.Message,
        TMWOHistoryOut);
    end;
  end;
end;

{ Удаляет столбец, в которой выделена ячейка }
procedure ExecuteDeleteColumn(aWorkbookSource: TsWorkbookSource;
  aWorksheetGrid: TsWorksheetGrid);
var
  workbook: TsWorkbook;
  worksheet: TsWorksheet;
  row, col: Cardinal;
begin
  if (aWorkbookSource = nil) or (aWorksheetGrid = nil) then
  begin
    zcUI.TextMessage('Ошибка: источник данных не инициализирован',
      TMWOHistoryOut);
    Exit;
  end;

  workbook := aWorkbookSource.Workbook;
  if workbook = nil then
  begin
    zcUI.TextMessage('Ошибка: книга не загружена', TMWOHistoryOut);
    Exit;
  end;

  worksheet := workbook.ActiveWorksheet;
  if worksheet = nil then
  begin
    zcUI.TextMessage('Ошибка: активный лист не выбран', TMWOHistoryOut);
    Exit;
  end;

  try
    // Получаем координаты выделенной ячейки
    row := aWorksheetGrid.Row - aWorksheetGrid.FixedRows;
    col := aWorksheetGrid.Col - aWorksheetGrid.FixedCols;

    // Удаляем столбец с текущей ячейкой
    worksheet.DeleteCol(col);

    programlog.LogOutFormatStr(
      'Удалён столбец с ячейкой [%d, %d]',
      [row, col],
      LM_Info
    );
    zcUI.TextMessage('Столбец удалён', TMWOHistoryOut);
  except
    on E: Exception do
    begin
      programlog.LogOutFormatStr(
        'Ошибка удаления столбца: %s',
        [E.Message],
        LM_Error
      );
      zcUI.TextMessage('Ошибка удаления столбца: ' + E.Message,
        TMWOHistoryOut);
    end;
  end;
end;

end.
