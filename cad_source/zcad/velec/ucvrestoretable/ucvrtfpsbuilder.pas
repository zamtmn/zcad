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
  Модуль: ucvrtfpsbuilder
  Назначение: Формирование книги TsWorkbook из модели таблицы
  Описание: Модуль является фабрикой объекта TsWorkbook (FPSpreadsheet).
            Принимает на вход модель таблицы TRtTableModel и создает
            полностью заполненную книгу Excel.
            Не содержит UI-логики и диалогов сохранения.
  Зависимости: ucvrtdata, fpspreadsheet, fpsTypes
}
unit ucvrtfpsbuilder;

{$INCLUDE zengineconfig.inc}

interface

uses
  SysUtils,
  fpspreadsheet,
  fpsTypes,
  ucvrtdata;

// Создать и заполнить книгу TsWorkbook из модели таблицы
// ВАЖНО: Вызывающая сторона отвечает за освобождение возвращенного объекта
function CreateWorkbookFromTableModel(
  const aTableModel: TRtTableModel
): TsWorkbook;

// Заполнить существующий лист данными из модели таблицы
procedure PopulateWorksheetFromTableModel(
  aWorksheet: TsWorksheet;
  const aTableModel: TRtTableModel
);

// Получить имя листа по умолчанию
function GetDefaultSheetName: string;

implementation

uses
  uzcinterface;

const
  // Имя листа по умолчанию
  DEFAULT_SHEET_NAME = 'Восстановленная таблица';

// Получить имя листа по умолчанию
function GetDefaultSheetName: string;
begin
  Result := DEFAULT_SHEET_NAME;
end;

// Заполнить существующий лист данными из модели таблицы
procedure PopulateWorksheetFromTableModel(
  aWorksheet: TsWorksheet;
  const aTableModel: TRtTableModel
);
var
  i: Integer;
  cell: PRtTableCell;
  row, col: Integer;
  invertedRow: Integer;
begin
  if aWorksheet = nil then
  begin
    zcUI.TextMessage(
      'Ошибка: лист не инициализирован',
      TMWOHistoryOut
    );
    Exit;
  end;

  if not aTableModel.isValid then
  begin
    zcUI.TextMessage(
      'Ошибка: модель таблицы невалидна',
      TMWOHistoryOut
    );
    Exit;
  end;

  // Заполняем ячейки данными из модели
  for i := 0 to aTableModel.cells.Size - 1 do
  begin
    cell := aTableModel.cells.Mutable[i];
    col := cell^.columnIndex;

    // Инвертируем индекс строки: в CAD Y растет вверх, в таблице - вниз
    // rowIndex=0 в CAD соответствует нижней строке, должна быть последней в GUI
    invertedRow := aTableModel.rowCount - 1 - cell^.rowIndex;
    row := invertedRow;

    // Записываем текстовое содержимое ячейки
    if cell^.textContent <> '' then
      aWorksheet.WriteText(row, col, cell^.textContent);
  end;

  zcUI.TextMessage(
    'Лист заполнен: ' + IntToStr(aTableModel.cells.Size) + ' ячеек',
    TMWOHistoryOut
  );
end;

// Создать и заполнить книгу TsWorkbook из модели таблицы
function CreateWorkbookFromTableModel(
  const aTableModel: TRtTableModel
): TsWorkbook;
var
  workbook: TsWorkbook;
  worksheet: TsWorksheet;
begin
  Result := nil;

  // Проверяем валидность модели
  if not aTableModel.isValid then
  begin
    zcUI.TextMessage(
      'Ошибка: модель таблицы невалидна, невозможно создать книгу',
      TMWOHistoryOut
    );
    Exit;
  end;

  zcUI.TextMessage(
    'Создание книги TsWorkbook из модели таблицы...',
    TMWOHistoryOut
  );

  try
    // Создаем новую книгу
    workbook := TsWorkbook.Create;

    // Добавляем лист
    worksheet := workbook.AddWorksheet(DEFAULT_SHEET_NAME);

    // Заполняем лист данными из модели
    PopulateWorksheetFromTableModel(worksheet, aTableModel);

    zcUI.TextMessage(
      'Книга TsWorkbook успешно создана: ' +
      IntToStr(aTableModel.rowCount) + ' строк, ' +
      IntToStr(aTableModel.columnCount) + ' столбцов',
      TMWOHistoryOut
    );

    Result := workbook;

  except
    on E: Exception do
    begin
      zcUI.TextMessage(
        'Ошибка при создании книги: ' + E.Message,
        TMWOHistoryOut
      );
      // В случае ошибки освобождаем созданную книгу
      if workbook <> nil then
        workbook.Free;
      Result := nil;
    end;
  end;
end;

end.
