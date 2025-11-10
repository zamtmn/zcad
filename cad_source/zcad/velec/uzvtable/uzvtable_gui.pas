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

{**Модуль визуализации таблицы с использованием fpspreadsheet}
unit uzvtable_gui;

{$INCLUDE zengineconfig.inc}

interface

uses
  SysUtils,
  Classes,
  Forms,
  Controls,
  StdCtrls,
  ExtCtrls,
  Grids,
  Dialogs,
  fpspreadsheet,
  fpsTypes,
  fpspreadsheetgrid,
  fpspreadsheetctrls,
  uzvtable_data;

type
  // Форма для отображения таблицы
  TUzvTableForm = class(TForm)
  private
    FWorkbookSource: TsWorkbookSource;
    FWorksheet: TsWorksheet;
    FSpreadsheetGrid: TsWorksheetGrid;
    FTable: PUzvTableGrid;
    FButtonPanel: TPanel;
    FCloseButton: TButton;
    FRefreshButton: TButton;
    FExportButton: TButton;
    FSaveDialog: TSaveDialog;

    procedure CreateComponents;
    procedure CloseButtonClick(Sender: TObject);
    procedure RefreshButtonClick(Sender: TObject);
    procedure ExportButtonClick(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    // Отобразить таблицу в форме
    procedure ShowTable(const aTable: TUzvTableGrid);

    // Обновить данные таблицы
    procedure RefreshTable;

    // Получить указатель на текущую таблицу
    property CurrentTable: PUzvTableGrid read FTable;
  end;

// Создать и показать форму с таблицей
function ShowTableInGUI(const aTable: TUzvTableGrid): TUzvTableForm;

// Заполнить workbook данными из структуры таблицы
procedure PopulateWorkbookFromTable(
  aWorkbook: TsWorkbook;
  const aTable: TUzvTableGrid
);

implementation

uses
  uzclog,
  uzcinterface;

const
  // Размеры и отступы формы
  FORM_DEFAULT_WIDTH = 800;
  FORM_DEFAULT_HEIGHT = 600;
  BUTTON_PANEL_HEIGHT = 50;
  BUTTON_WIDTH = 100;
  BUTTON_HEIGHT = 30;
  BUTTON_SPACING = 10;

// Создать и показать форму с таблицей
function ShowTableInGUI(const aTable: TUzvTableGrid): TUzvTableForm;
begin
  Result := TUzvTableForm.Create(nil);
  try
    Result.ShowTable(aTable);
    Result.ShowModal;
  finally
    Result.Free;
  end;
end;

// Заполнить workbook данными из структуры таблицы
procedure PopulateWorkbookFromTable(
  aWorkbook: TsWorkbook;
  const aTable: TUzvTableGrid
);
var
  worksheet: TsWorksheet;
  i: Integer;
  cell: PUzvTableCell;
  row, col: Integer;
  invertedRow: Integer;
begin
  if aWorkbook = nil then
    Exit;

  // Создаем новый лист
  worksheet := aWorkbook.AddWorksheet('Таблица');

  // Заполняем ячейки данными
  for i := 0 to aTable.cells.Size - 1 do
  begin
    cell := aTable.cells.Mutable[i];
    col := cell^.columnIndex;

    // Инвертируем индекс строки: в CAD Y растет вверх, в таблице - вниз
    // rowIndex=0 в CAD соответствует нижней строке, должна быть последней в GUI
    invertedRow := aTable.rowCount - 1 - cell^.rowIndex;
    row := invertedRow;

    // Записываем текстовое содержимое
    if cell^.textContent <> '' then
      worksheet.WriteText(row, col, cell^.textContent);
  end;

  zcUI.TextMessage('Workbook заполнен данными таблицы',TMWOHistoryOut);
end;

{ TUzvTableForm }

constructor TUzvTableForm.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FWorkbookSource := nil;
  FWorksheet := nil;
  FTable := nil;

  CreateComponents;
end;

destructor TUzvTableForm.Destroy;
begin
  if FWorkbookSource <> nil then
    FWorkbookSource.Free;

  inherited Destroy;
end;

procedure TUzvTableForm.CreateComponents;
begin
  // Настройка формы
  Caption := 'Восстановленная таблица / Restored Table';
  Width := FORM_DEFAULT_WIDTH;
  Height := FORM_DEFAULT_HEIGHT;
  Position := poScreenCenter;
  BorderStyle := bsSizeable;

  // Создаем панель с кнопками
  FButtonPanel := TPanel.Create(Self);
  FButtonPanel.Parent := Self;
  FButtonPanel.Height := BUTTON_PANEL_HEIGHT;
  FButtonPanel.Align := alBottom;
  FButtonPanel.BevelOuter := bvNone;

  // Кнопка "Обновить"
  FRefreshButton := TButton.Create(FButtonPanel);
  FRefreshButton.Parent := FButtonPanel;
  FRefreshButton.Caption := 'Обновить / Refresh';
  FRefreshButton.Width := BUTTON_WIDTH;
  FRefreshButton.Height := BUTTON_HEIGHT;
  FRefreshButton.Left := BUTTON_SPACING;
  FRefreshButton.Top := (BUTTON_PANEL_HEIGHT - BUTTON_HEIGHT) div 2;
  FRefreshButton.OnClick := @RefreshButtonClick;

  // Кнопка "Экспорт"
  FExportButton := TButton.Create(FButtonPanel);
  FExportButton.Parent := FButtonPanel;
  FExportButton.Caption := 'Экспорт / Export';
  FExportButton.Width := BUTTON_WIDTH;
  FExportButton.Height := BUTTON_HEIGHT;
  FExportButton.Left := BUTTON_SPACING * 2 + BUTTON_WIDTH;
  FExportButton.Top := (BUTTON_PANEL_HEIGHT - BUTTON_HEIGHT) div 2;
  FExportButton.OnClick := @ExportButtonClick;

  // Кнопка "Закрыть"
  FCloseButton := TButton.Create(FButtonPanel);
  FCloseButton.Parent := FButtonPanel;
  FCloseButton.Caption := 'Закрыть / Close';
  FCloseButton.Width := BUTTON_WIDTH;
  FCloseButton.Height := BUTTON_HEIGHT;
  FCloseButton.Left := FButtonPanel.Width - BUTTON_WIDTH - BUTTON_SPACING;
  FCloseButton.Top := (BUTTON_PANEL_HEIGHT - BUTTON_HEIGHT) div 2;
  FCloseButton.Anchors := [akRight, akBottom];
  FCloseButton.OnClick := @CloseButtonClick;

  // Создаем источник данных для workbook
  FWorkbookSource := TsWorkbookSource.Create(Self);

  // Создаем компонент для отображения таблицы
  FSpreadsheetGrid := TsWorksheetGrid.Create(Self);
  FSpreadsheetGrid.Parent := Self;
  FSpreadsheetGrid.Align := alClient;
  FSpreadsheetGrid.Options := FSpreadsheetGrid.Options + [goEditing];
  FSpreadsheetGrid.WorkbookSource := FWorkbookSource;

  // Создаем диалог сохранения файла
  FSaveDialog := TSaveDialog.Create(Self);
  FSaveDialog.Title := 'Сохранить таблицу / Save Table';
  FSaveDialog.Filter := 'Файлы Excel (*.xlsx)|*.xlsx|Все файлы (*.*)|*.*';
  FSaveDialog.DefaultExt := 'xlsx';
  FSaveDialog.FilterIndex := 1;
  FSaveDialog.FileName := 'table_export.xlsx';
end;

procedure TUzvTableForm.ShowTable(const aTable: TUzvTableGrid);
begin
  // Сохраняем ссылку на таблицу
  GetMem(FTable, SizeOf(TUzvTableGrid));
  FTable^ := aTable;

  // Создаем новый workbook через WorkbookSource
  FWorkbookSource.CreateNewWorkbook;

  // Заполняем workbook данными из таблицы
  PopulateWorkbookFromTable(FWorkbookSource.Workbook, aTable);

  // Получаем первый лист
  if FWorkbookSource.Workbook.GetWorksheetCount > 0 then
  begin
    FWorksheet := FWorkbookSource.Workbook.GetFirstWorksheet;
  end;

  //zcLog.LogInfo('Таблица отображена в GUI');
  zcUI.TextMessage('Таблица успешно восстановлена и отображена / Table restored and displayed', TMWOHistoryOut);
end;

procedure TUzvTableForm.RefreshTable;
begin
  if (FWorkbookSource = nil) or (FTable = nil) then
    Exit;

  // Создаем новый workbook через WorkbookSource
  FWorkbookSource.CreateNewWorkbook;

  // Заново заполняем данными
  PopulateWorkbookFromTable(FWorkbookSource.Workbook, FTable^);

  // Обновляем отображение
  if FWorkbookSource.Workbook.GetWorksheetCount > 0 then
  begin
    FWorksheet := FWorkbookSource.Workbook.GetFirstWorksheet;
  end;

  zcUI.TextMessage('Таблица обновлена / Table refreshed', TMWOHistoryOut);
end;

procedure TUzvTableForm.CloseButtonClick(Sender: TObject);
begin
  Close;
end;

procedure TUzvTableForm.RefreshButtonClick(Sender: TObject);
begin
  RefreshTable;
end;

procedure TUzvTableForm.ExportButtonClick(Sender: TObject);
var
  fileName: string;
begin
  if FWorkbookSource = nil then
  begin
    zcUI.TextMessage('Ошибка: нет данных для экспорта / Error: no data to export', TMWOHistoryOut);
    Exit;
  end;

  // Показываем стандартный диалог выбора места сохранения и имени файла
  if FSaveDialog.Execute then
  begin
    fileName := FSaveDialog.FileName;

    try
      FWorkbookSource.Workbook.WriteToFile(fileName, sfOOXML, True);
      zcUI.TextMessage('Таблица экспортирована в файл: ' + fileName + ' / Table exported to file: ' + fileName, TMWOHistoryOut);
    except
      on E: Exception do
        zcUI.TextMessage('Ошибка экспорта: ' + E.Message + ' / Export error: ' + E.Message, TMWOHistoryOut);
    end;
  end;
end;

end.
