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

{** Модуль главной формы визуализации электронных таблиц
    Отвечает только за отображение интерфейса, без бизнес-логики }
unit uzvspreadsheet_gui;

{$INCLUDE zengineconfig.inc}

interface

uses
  Classes,
  SysUtils,
  Forms,
  Controls,
  Graphics,
  Grids,
  ExtCtrls,
  StdCtrls,
  ActnList,
  ComCtrls,
  fpspreadsheet,
  fpsTypes,
  fpsUtils,
  fpspreadsheetgrid,
  fpspreadsheetctrls,
  uzvspreadsheet_actions,
  uzcimagesmanager;

const
  // Размеры по умолчанию для панелей и элементов
  DEFAULT_CONTROL_PANEL_HEIGHT = 40;
  DEFAULT_CELL_INFO_HEIGHT = 30;
  DEFAULT_CELL_ADDRESS_WIDTH = 80;
  DEFAULT_CELL_CONTENT_MIN_WIDTH = 200;

  // Имена параметров для сохранения состояния
  SPREADSHEET_PANEL_CONTROL = 'SpreadSheet_PanelControl';
  SPREADSHEET_PANEL_SHEET = 'SpreadSheet_PanelSheet';

type
  { TuzvSpreadsheetForm }
  { Главная форма модуля визуализации электронных таблиц }
  TuzvSpreadsheetForm = class(TForm)
  private
    // Основные панели
    FPanelControl: TPanel;
    FPanelSheet: TPanel;

    // Панель информации о ячейке
    FPanelCellInfo: TPanel;
    FLabelCellAddress: TLabel;
    FEditCellContent: TEdit;

    // Компоненты fpspreadsheet
    FWorkbookSource: TsWorkbookSource;
    FWorksheetGrid: TsWorksheetGrid;
    FWorksheetTabControl: TsWorkbookTabControl;

    // Панель инструментов
    FToolBar: TToolBar;
    FBtnNew: TToolButton;
    FBtnOpen: TToolButton;
    FBtnSave: TToolButton;
    FBtnSeparator1: TToolButton;
    FBtnUndo: TToolButton;
    FBtnRedo: TToolButton;
    FBtnSeparator2: TToolButton;
    FBtnCalc: TToolButton;
    FBtnAutoCalc: TToolButton;

    // Действия
    FActionList: TActionList;
    FSpreadsheetActions: TSpreadsheetActions;

    // Переменные для отслеживания редактирования ячеек
    FEditingCell: Boolean;
    FEditingRow: Cardinal;
    FEditingCol: Cardinal;
    FOldCellValue: String;  // Содержимое ячейки до начала редактирования
    FUndoSavedForCurrentEdit: Boolean;  // Флаг: undo-запись для текущего редактирования уже создана

    // Процедуры создания компонентов
    procedure CreateActions;
    procedure CreatePanels;
    procedure CreateToolBar;
    procedure CreateSpreadsheetComponents;
    procedure CreateCellInfoPanel;

    // Обработчики событий
    procedure OnWorksheetGridSelection(Sender: TObject;
      aCol, aRow: Integer);
    procedure OnWorksheetGridSelectEditor(Sender: TObject;
      aCol, aRow: Integer; var Editor: TWinControl);
    procedure OnWorksheetGridEditingDone(Sender: TObject);
    procedure OnCellContentEditChange(Sender: TObject);
    procedure OnCellContentEditExit(Sender: TObject);
    procedure OnCellContentKeyPress(Sender: TObject; var Key: Char);

  protected
    procedure DoCreate; override;
    procedure DoDestroy; override;

  public
    { Возвращает источник данных книги }
    property WorkbookSource: TsWorkbookSource read FWorkbookSource;

    { Возвращает компонент отображения таблицы }
    property WorksheetGrid: TsWorksheetGrid read FWorksheetGrid;

    { Возвращает список действий для привязки кнопок }
    property ActionList: TActionList read FActionList;

    { Обновляет отображение информации о текущей ячейке }
    procedure UpdateCellInfo;

    { Устанавливает содержимое ячейки из поля редактирования }
    procedure ApplyCellContent;
  end;

var
  uzvSpreadsheetForm: TuzvSpreadsheetForm;

implementation

uses
  uzclog,
  uzcinterface,
  uzvspreadsheet_cmdundoredo;

{ TuzvSpreadsheetForm }

procedure TuzvSpreadsheetForm.DoCreate;
begin
  inherited DoCreate;

  // Инициализация переменных отслеживания редактирования
  FEditingCell := False;
  FEditingRow := 0;
  FEditingCol := 0;
  FUndoSavedForCurrentEdit := False;

  // Настройка основных параметров формы
  Caption := 'Электронные таблицы / Spreadsheet';
  Width := 800;
  Height := 600;
  Position := poScreenCenter;

  // Создаем компоненты в правильном порядке
  CreatePanels;
  CreateToolBar;
  CreateCellInfoPanel;
  CreateSpreadsheetComponents;
  CreateActions;

  zcUI.TextMessage('Форма электронных таблиц создана', TMWOHistoryOut);
end;

procedure TuzvSpreadsheetForm.DoDestroy;
begin
  // Освобождаем объект действий
  if Assigned(FSpreadsheetActions) then
    FreeAndNil(FSpreadsheetActions);

  zcUI.TextMessage('Форма электронных таблиц закрыта', TMWOHistoryOut);
  inherited DoDestroy;
end;

{ Создание действий и привязка к кнопкам }
procedure TuzvSpreadsheetForm.CreateActions;
begin
  // Создаём объект действий с передачей ссылки на компонент таблицы
  FSpreadsheetActions := TSpreadsheetActions.Create(FActionList, FWorkbookSource,
    FWorksheetGrid);

  // Привязываем действия к кнопкам панели инструментов
  FBtnNew.Action := FSpreadsheetActions.ActNewBook;
  FBtnOpen.Action := FSpreadsheetActions.ActOpenBook;
  FBtnSave.Action := FSpreadsheetActions.ActSaveBook;
  FBtnUndo.Action := FSpreadsheetActions.ActUndo;
  FBtnRedo.Action := FSpreadsheetActions.ActRedo;
  FBtnCalc.Action := FSpreadsheetActions.ActCalc;
  FBtnAutoCalc.Action := FSpreadsheetActions.ActAutoCalc;
end;

{ Создание основных панелей формы }
procedure TuzvSpreadsheetForm.CreatePanels;
begin
  // Верхняя панель управления
  FPanelControl := TPanel.Create(Self);
  FPanelControl.Parent := Self;
  FPanelControl.Align := alTop;
  FPanelControl.Height := DEFAULT_CONTROL_PANEL_HEIGHT;
  FPanelControl.BevelOuter := bvNone;
  FPanelControl.Caption := '';

  // Нижняя панель отображения таблицы
  FPanelSheet := TPanel.Create(Self);
  FPanelSheet.Parent := Self;
  FPanelSheet.Align := alClient;
  FPanelSheet.BevelOuter := bvNone;
  FPanelSheet.Caption := '';
end;

{ Создание панели инструментов с кнопками }
procedure TuzvSpreadsheetForm.CreateToolBar;
begin
  // Создаем список действий
  FActionList := TActionList.Create(Self);

  // Создаем панель инструментов
  FToolBar := TToolBar.Create(Self);
  FToolBar.Parent := FPanelControl;
  FToolBar.Align := alClient;
  FToolBar.ShowCaptions := False;  // Скрываем текст на кнопках
  FToolBar.Images := ImagesManager.IconList;  // Устанавливаем список иконок
  FToolBar.ButtonWidth := 28;
  FToolBar.ButtonHeight := 28;

  // Кнопка "Создать книгу"
  FBtnNew := TToolButton.Create(FToolBar);
  FBtnNew.Parent := FToolBar;
  FBtnNew.Hint := 'Создать новую книгу';
  FBtnNew.ShowHint := True;
  FBtnNew.ShowCaption := False;
  FBtnNew.ImageIndex := ImagesManager.GetImageIndex('new');

  // Кнопка "Открыть книгу"
  FBtnOpen := TToolButton.Create(FToolBar);
  FBtnOpen.Parent := FToolBar;
  FBtnOpen.Hint := 'Открыть файл книги';
  FBtnOpen.ShowHint := True;
  FBtnOpen.ShowCaption := False;
  FBtnOpen.ImageIndex := ImagesManager.GetImageIndex('open');

  // Кнопка "Сохранить книгу"
  FBtnSave := TToolButton.Create(FToolBar);
  FBtnSave.Parent := FToolBar;
  FBtnSave.Hint := 'Сохранить книгу в файл';
  FBtnSave.ShowHint := True;
  FBtnSave.ShowCaption := False;
  FBtnSave.ImageIndex := ImagesManager.GetImageIndex('saveas');

  // Разделитель 1
  FBtnSeparator1 := TToolButton.Create(FToolBar);
  FBtnSeparator1.Parent := FToolBar;
  FBtnSeparator1.Style := tbsSeparator;
  FBtnSeparator1.Width := 10;

  // Кнопка "Назад" (Undo)
  FBtnUndo := TToolButton.Create(FToolBar);
  FBtnUndo.Parent := FToolBar;
  FBtnUndo.Hint := 'Назад: Отменить последнее изменение';
  FBtnUndo.ShowHint := True;
  FBtnUndo.ShowCaption := False;
  FBtnUndo.ImageIndex := ImagesManager.GetImageIndex('undo');

  // Кнопка "Вперёд" (Redo)
  FBtnRedo := TToolButton.Create(FToolBar);
  FBtnRedo.Parent := FToolBar;
  FBtnRedo.Hint := 'Вперёд: Вернуть отменённое изменение';
  FBtnRedo.ShowHint := True;
  FBtnRedo.ShowCaption := False;
  FBtnRedo.ImageIndex := ImagesManager.GetImageIndex('redo');

  // Разделитель 2
  FBtnSeparator2 := TToolButton.Create(FToolBar);
  FBtnSeparator2.Parent := FToolBar;
  FBtnSeparator2.Style := tbsSeparator;
  FBtnSeparator2.Width := 10;

  // Кнопка "Пересчитать формулы"
  FBtnCalc := TToolButton.Create(FToolBar);
  FBtnCalc.Parent := FToolBar;
  FBtnCalc.Hint := 'Расчёт: Пересчитать формулы';
  FBtnCalc.ShowHint := True;
  FBtnCalc.ShowCaption := False;
  FBtnCalc.ImageIndex := ImagesManager.GetImageIndex('velec/spreadsheet_calc');

  // Кнопка "Автопересчёт"
  FBtnAutoCalc := TToolButton.Create(FToolBar);
  FBtnAutoCalc.Parent := FToolBar;
  FBtnAutoCalc.Hint := 'Автопересчёт: Включить/выключить автопересчёт формул';
  FBtnAutoCalc.ShowHint := True;
  FBtnAutoCalc.ShowCaption := False;
  FBtnAutoCalc.ImageIndex := ImagesManager.GetImageIndex('velec/spreadsheet_autocalc');
  FBtnAutoCalc.Style := tbsCheck;
  FBtnAutoCalc.Down := True;
end;

{ Создание панели информации о ячейке }
procedure TuzvSpreadsheetForm.CreateCellInfoPanel;
begin
  // Панель для отображения информации о ячейке
  FPanelCellInfo := TPanel.Create(Self);
  FPanelCellInfo.Parent := FPanelSheet;
  FPanelCellInfo.Align := alTop;
  FPanelCellInfo.Height := DEFAULT_CELL_INFO_HEIGHT;
  FPanelCellInfo.BevelOuter := bvNone;
  FPanelCellInfo.Caption := '';

  // Метка с адресом текущей ячейки
  FLabelCellAddress := TLabel.Create(Self);
  FLabelCellAddress.Parent := FPanelCellInfo;
  FLabelCellAddress.Align := alLeft;
  FLabelCellAddress.Width := DEFAULT_CELL_ADDRESS_WIDTH;
  FLabelCellAddress.Caption := 'A1';
  FLabelCellAddress.Alignment := taCenter;
  FLabelCellAddress.Layout := tlCenter;
  FLabelCellAddress.AutoSize := False;
  FLabelCellAddress.Font.Style := [fsBold];

  // Поле редактирования содержимого ячейки
  FEditCellContent := TEdit.Create(Self);
  FEditCellContent.Parent := FPanelCellInfo;
  FEditCellContent.Align := alClient;
  FEditCellContent.Text := '';
  FEditCellContent.OnChange := @OnCellContentEditChange;
  FEditCellContent.OnExit := @OnCellContentEditExit;
  FEditCellContent.OnKeyPress := @OnCellContentKeyPress;
end;

{ Создание компонентов fpspreadsheet }
procedure TuzvSpreadsheetForm.CreateSpreadsheetComponents;
begin
  // Источник данных для книги
  FWorkbookSource := TsWorkbookSource.Create(Self);

  // Табы для переключения листов книги
  FWorksheetTabControl := TsWorkbookTabControl.Create(Self);
  FWorksheetTabControl.Parent := FPanelSheet;
  FWorksheetTabControl.Align := alBottom;
  FWorksheetTabControl.Height := 25;
  FWorksheetTabControl.WorkbookSource := FWorkbookSource;

  // Компонент отображения таблицы
  FWorksheetGrid := TsWorksheetGrid.Create(Self);
  FWorksheetGrid.Parent := FPanelSheet;
  FWorksheetGrid.Align := alClient;
  FWorksheetGrid.WorkbookSource := FWorkbookSource;
  FWorksheetGrid.Options := FWorksheetGrid.Options + [goEditing, goColSizing,
    goRowSizing];
  FWorksheetGrid.OnSelection := @OnWorksheetGridSelection;
  FWorksheetGrid.OnSelectEditor := @OnWorksheetGridSelectEditor;
  FWorksheetGrid.OnEditingDone := @OnWorksheetGridEditingDone;

  // Создаём пустую книгу при запуске
  FWorkbookSource.CreateNewWorkbook;
end;

{ Обработчик выбора ячейки в таблице }
procedure TuzvSpreadsheetForm.OnWorksheetGridSelection(Sender: TObject;
  aCol, aRow: Integer);
begin
  UpdateCellInfo;
end;

{ Обработчик начала редактирования ячейки в таблице }
procedure TuzvSpreadsheetForm.OnWorksheetGridSelectEditor(Sender: TObject;
  aCol, aRow: Integer; var Editor: TWinControl);
var
  row, col: Cardinal;
  worksheet: TsWorksheet;
  cellAddress: String;
begin
  // Вычисляем координаты ячейки (без учёта заголовков)
  row := aRow - FWorksheetGrid.FixedRows;
  col := aCol - FWorksheetGrid.FixedCols;

  // Запоминаем координаты редактируемой ячейки
  FEditingCell := True;
  FEditingRow := row;
  FEditingCol := col;
  FUndoSavedForCurrentEdit := False;

  // Сохраняем текущее значение ячейки для последующего сравнения
  FOldCellValue := '';
  if (FWorkbookSource <> nil) and (FWorkbookSource.Workbook <> nil) then
  begin
    worksheet := FWorkbookSource.Workbook.ActiveWorksheet;
    if worksheet <> nil then
    begin
      if worksheet.FindCell(row, col) <> nil then
        FOldCellValue := worksheet.ReadAsText(worksheet.FindCell(row, col));

      // Сохраняем текущее состояние ячейки перед редактированием
      // BeginChange запоминает ТЕКУЩЕЕ (старое) состояние для возможности отмены
      if SpreadsheetUndoManager <> nil then
      begin
        cellAddress := GetCellString(row, col);
        SpreadsheetUndoManager.BeginChange(row, col,
          'Изменение ячейки ' + cellAddress);
        FUndoSavedForCurrentEdit := True;
      end;
    end;
  end;
end;

{ Обработчик завершения редактирования ячейки в таблице }
procedure TuzvSpreadsheetForm.OnWorksheetGridEditingDone(Sender: TObject);
var
  worksheet: TsWorksheet;
  cell: PCell;
  newCellValue: String;
begin
  // Если редактирование завершено, проверяем, изменилось ли содержимое
  if FEditingCell and (SpreadsheetUndoManager <> nil) then
  begin
    if (FWorkbookSource <> nil) and (FWorkbookSource.Workbook <> nil) then
    begin
      worksheet := FWorkbookSource.Workbook.ActiveWorksheet;
      if worksheet <> nil then
      begin
        // Получаем новое значение ячейки после редактирования
        newCellValue := '';
        cell := worksheet.FindCell(FEditingRow, FEditingCol);
        if cell <> nil then
          newCellValue := worksheet.ReadAsText(cell);

        // Если значение НЕ изменилось, отменяем последнюю запись в истории отмены
        // (она была добавлена в OnWorksheetGridSelectEditor)
        if newCellValue = FOldCellValue then
          SpreadsheetUndoManager.CancelLastUndo;
      end;
    end;
  end;

  // Сбрасываем флаги редактирования
  FEditingCell := False;
  FUndoSavedForCurrentEdit := False;

  // Обновляем информацию о ячейке в панели редактирования
  UpdateCellInfo;
end;

{ Обработчик изменения содержимого поля редактирования }
procedure TuzvSpreadsheetForm.OnCellContentEditChange(Sender: TObject);
begin
  // Ничего не делаем при изменении - применяем только при нажатии Enter или
  // выходе из поля
end;

{ Обработчик выхода из поля редактирования }
procedure TuzvSpreadsheetForm.OnCellContentEditExit(Sender: TObject);
begin
  ApplyCellContent;
end;

{ Обработчик нажатия клавиши в поле редактирования }
procedure TuzvSpreadsheetForm.OnCellContentKeyPress(Sender: TObject;
  var Key: Char);
begin
  // При нажатии Enter применяем содержимое
  if Key = #13 then
  begin
    ApplyCellContent;
    Key := #0;
    FWorksheetGrid.SetFocus;
  end;
end;

{ Обновление информации о текущей ячейке }
procedure TuzvSpreadsheetForm.UpdateCellInfo;
var
  worksheet: TsWorksheet;
  cell: PCell;
  cellAddress: String;
  cellContent: String;
  row, col: Cardinal;
begin
  if (FWorkbookSource = nil) or (FWorkbookSource.Workbook = nil) then
    Exit;

  worksheet := FWorkbookSource.Workbook.ActiveWorksheet;
  if worksheet = nil then
    Exit;

  // Получаем координаты выделенной ячейки
  row := FWorksheetGrid.Row - FWorksheetGrid.FixedRows;
  col := FWorksheetGrid.Col - FWorksheetGrid.FixedCols;

  // Формируем адрес ячейки (например, A1, B2)
  cellAddress := GetCellString(row, col);
  FLabelCellAddress.Caption := cellAddress;

  // Получаем содержимое ячейки
  cell := worksheet.FindCell(row, col);
  if cell <> nil then
  begin
    // Если есть формула - показываем формулу, иначе значение
    cellContent := worksheet.ReadFormulaAsString(cell);
    if cellContent = '' then
      cellContent := worksheet.ReadAsText(cell);
  end
  else
    cellContent := '';

  FEditCellContent.Text := cellContent;
end;

{ Применение содержимого из поля редактирования к ячейке }
procedure TuzvSpreadsheetForm.ApplyCellContent;
var
  worksheet: TsWorksheet;
  row, col: Cardinal;
  content: String;
  cellAddress: String;
  cell: PCell;
  oldContent: String;
begin
  if (FWorkbookSource = nil) or (FWorkbookSource.Workbook = nil) then
    Exit;

  worksheet := FWorkbookSource.Workbook.ActiveWorksheet;
  if worksheet = nil then
    Exit;

  // Получаем координаты выделенной ячейки
  row := FWorksheetGrid.Row - FWorksheetGrid.FixedRows;
  col := FWorksheetGrid.Col - FWorksheetGrid.FixedCols;

  content := FEditCellContent.Text;

  // Получаем текущее содержимое ячейки для сравнения
  oldContent := '';
  cell := worksheet.FindCell(row, col);
  if cell <> nil then
    oldContent := worksheet.ReadAsText(cell);

  // Проверяем, действительно ли содержимое изменилось
  if content = oldContent then
    Exit; // Нет изменений - ничего не делаем

  // Сохраняем текущее состояние ячейки для возможности отмены
  // Только если ещё не создали undo-запись для этой ячейки
  // Проверяем, редактируем ли мы ту же ячейку, для которой уже сохранили undo
  cellAddress := GetCellString(row, col);
  if SpreadsheetUndoManager <> nil then
  begin
    // Если это новая ячейка или ещё не сохраняли undo для текущей ячейки
    if (not FUndoSavedForCurrentEdit) or
       (row <> FEditingRow) or (col <> FEditingCol) then
    begin
      SpreadsheetUndoManager.BeginChange(row, col,
        'Изменение ячейки ' + cellAddress);
      FUndoSavedForCurrentEdit := True;
      FEditingRow := row;
      FEditingCol := col;
    end;
  end;

  // Если начинается с "=" - это формула
  if (Length(content) > 0) and (content[1] = '=') then
    worksheet.WriteFormula(row, col, Copy(content, 2, Length(content) - 1))
  else
    worksheet.WriteText(row, col, content);
end;

end.
