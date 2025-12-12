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

{** Модуль управления действиями (TAction) для формы электронных таблиц
    Содержит создание и настройку всех действий, без GUI-кода }
unit uzvspreadsheet_actions;

{$INCLUDE zengineconfig.inc}

interface

uses
  Classes,
  SysUtils,
  ActnList,
  fpspreadsheet,
  uzcimagesmanager,
  fpspreadsheetctrls,
  fpspreadsheetgrid;

type
  { TSpreadsheetActions }
  { Класс для управления действиями формы электронных таблиц }
  TSpreadsheetActions = class
  private
    FActionList: TActionList;
    FWorkbookSource: TsWorkbookSource;
    FWorksheetGrid: TsWorksheetGrid;

    // Действия
    FActNewBook: TAction;
    FActOpenBook: TAction;
    FActSaveBook: TAction;
    FActCalc: TAction;
    FActAutoCalc: TAction;
    FActUndo: TAction;
    FActRedo: TAction;

    // Флаг автопересчёта
    FAutoCalcEnabled: Boolean;

    // Обработчики действий
    procedure OnActNewBookExecute(Sender: TObject);
    procedure OnActOpenBookExecute(Sender: TObject);
    procedure OnActSaveBookExecute(Sender: TObject);
    procedure OnActCalcExecute(Sender: TObject);
    procedure OnActAutoCalcExecute(Sender: TObject);
    procedure OnActUndoExecute(Sender: TObject);
    procedure OnActRedoExecute(Sender: TObject);
    procedure OnActUndoUpdate(Sender: TObject);
    procedure OnActRedoUpdate(Sender: TObject);

  public
    constructor Create(aActionList: TActionList;
      aWorkbookSource: TsWorkbookSource; aWorksheetGrid: TsWorksheetGrid);
    destructor Destroy; override;

    { Инициализирует все действия и привязывает обработчики }
    procedure InitActions;

    { Возвращает действие "Создать книгу" }
    property ActNewBook: TAction read FActNewBook;

    { Возвращает действие "Открыть книгу" }
    property ActOpenBook: TAction read FActOpenBook;

    { Возвращает действие "Сохранить книгу" }
    property ActSaveBook: TAction read FActSaveBook;

    { Возвращает действие "Пересчитать формулы" }
    property ActCalc: TAction read FActCalc;

    { Возвращает действие "Автопересчёт" }
    property ActAutoCalc: TAction read FActAutoCalc;

    { Возвращает действие "Отменить" (Undo) }
    property ActUndo: TAction read FActUndo;

    { Возвращает действие "Вернуть" (Redo) }
    property ActRedo: TAction read FActRedo;

    { Возвращает/устанавливает флаг автопересчёта }
    property AutoCalcEnabled: Boolean read FAutoCalcEnabled
      write FAutoCalcEnabled;
  end;

implementation

uses
  uzvspreadsheet_cmdnewbook,
  uzvspreadsheet_cmdopenbook,
  uzvspreadsheet_cmdsavebook,
  uzvspreadsheet_cmdcalc,
  uzvspreadsheet_cmdundoredo,
  uzclog,
  uzcinterface;

{ TSpreadsheetActions }

constructor TSpreadsheetActions.Create(aActionList: TActionList;
  aWorkbookSource: TsWorkbookSource; aWorksheetGrid: TsWorksheetGrid);
begin
  inherited Create;
  FActionList := aActionList;
  FWorkbookSource := aWorkbookSource;
  FWorksheetGrid := aWorksheetGrid;
  FAutoCalcEnabled := True;

  // Инициализируем менеджер отмены/возврата
  InitUndoManager(aWorkbookSource);

  InitActions;
end;

destructor TSpreadsheetActions.Destroy;
begin
  // Освобождаем менеджер отмены/возврата
  FreeUndoManager;

  // Действия освобождаются автоматически через ActionList
  inherited Destroy;
end;

{ Инициализация всех действий }
procedure TSpreadsheetActions.InitActions;
begin
  // Действие "Создать книгу"
  FActNewBook := TAction.Create(FActionList);
  FActNewBook.ActionList := FActionList;
  FActNewBook.Caption := 'Создать';
  FActNewBook.Hint := 'Создать новую книгу';
  FActNewBook.ImageIndex := ImagesManager.GetImageIndex('new');
  FActNewBook.OnExecute := @OnActNewBookExecute;

  // Действие "Открыть книгу"
  FActOpenBook := TAction.Create(FActionList);
  FActOpenBook.ActionList := FActionList;
  FActOpenBook.Caption := 'Открыть';
  FActOpenBook.Hint := 'Открыть файл книги';
  FActOpenBook.ImageIndex := ImagesManager.GetImageIndex('open');
  FActOpenBook.OnExecute := @OnActOpenBookExecute;

  // Действие "Сохранить книгу"
  FActSaveBook := TAction.Create(FActionList);
  FActSaveBook.ActionList := FActionList;
  FActSaveBook.Caption := 'Сохранить';
  FActSaveBook.Hint := 'Сохранить книгу в файл';
  FActSaveBook.ImageIndex := ImagesManager.GetImageIndex('saveas');
  FActSaveBook.OnExecute := @OnActSaveBookExecute;

  // Действие "Пересчитать формулы"
  FActCalc := TAction.Create(FActionList);
  FActCalc.ActionList := FActionList;
  FActCalc.Caption := 'Расчёт';
  FActCalc.Hint := 'Пересчитать все формулы';
  FActCalc.ImageIndex := ImagesManager.GetImageIndex('spreadsheet_calc');
  FActCalc.OnExecute := @OnActCalcExecute;

  // Действие "Автопересчёт"
  FActAutoCalc := TAction.Create(FActionList);
  FActAutoCalc.ActionList := FActionList;
  FActAutoCalc.Caption := 'Автопересчёт';
  FActAutoCalc.Hint := 'Включить/выключить автопересчёт формул';
  FActAutoCalc.ImageIndex := ImagesManager.GetImageIndex('spreadsheet_autocalc');
  FActAutoCalc.OnExecute := @OnActAutoCalcExecute;

  // Действие "Отменить" (Назад)
  FActUndo := TAction.Create(FActionList);
  FActUndo.ActionList := FActionList;
  FActUndo.Caption := 'Назад';
  FActUndo.Hint := 'Отменить последнее изменение (Ctrl+Z)';
  FActUndo.ImageIndex := ImagesManager.GetImageIndex('undo');
  FActUndo.ShortCut := 16474; // Ctrl+Z
  FActUndo.OnExecute := @OnActUndoExecute;
  FActUndo.OnUpdate := @OnActUndoUpdate;

  // Действие "Вернуть" (Вперёд)
  FActRedo := TAction.Create(FActionList);
  FActRedo.ActionList := FActionList;
  FActRedo.Caption := 'Вперёд';
  FActRedo.Hint := 'Вернуть отменённое изменение (Ctrl+Y)';
  FActRedo.ImageIndex := ImagesManager.GetImageIndex('redo');
  FActRedo.ShortCut := 16473; // Ctrl+Y
  FActRedo.OnExecute := @OnActRedoExecute;
  FActRedo.OnUpdate := @OnActRedoUpdate;

  zcUI.TextMessage('Действия электронных таблиц инициализированы', TMWOHistoryOut);
end;

{ Обработчик действия "Создать книгу" }
procedure TSpreadsheetActions.OnActNewBookExecute(Sender: TObject);
begin
  ExecuteNewBook(FWorkbookSource);

  // Принудительное обновление отображения таблицы
  if FWorksheetGrid <> nil then
    FWorksheetGrid.Invalidate;
end;

{ Обработчик действия "Открыть книгу" }
procedure TSpreadsheetActions.OnActOpenBookExecute(Sender: TObject);
begin
  ExecuteOpenBook(FWorkbookSource);

  // Принудительное обновление отображения таблицы
  if FWorksheetGrid <> nil then
    FWorksheetGrid.Invalidate;
end;

{ Обработчик действия "Сохранить книгу" }
procedure TSpreadsheetActions.OnActSaveBookExecute(Sender: TObject);
begin
  // Вызываем команду сохранения книги
  // Если файл не был сохранён ранее - откроется диалог "Сохранить как"
  ExecuteSaveBookAs(FWorkbookSource);
end;

{ Обработчик действия "Пересчитать формулы" }
procedure TSpreadsheetActions.OnActCalcExecute(Sender: TObject);
begin
  ExecuteCalcFormulas(FWorkbookSource);

  // Принудительное обновление отображения таблицы
  if FWorksheetGrid <> nil then
    FWorksheetGrid.Invalidate;
end;

{ Обработчик действия "Автопересчёт" }
procedure TSpreadsheetActions.OnActAutoCalcExecute(Sender: TObject);
begin
  FAutoCalcEnabled := not FAutoCalcEnabled;
  SetAutoCalcEnabled(FWorkbookSource, FAutoCalcEnabled);

  if FAutoCalcEnabled then
    zcUI.TextMessage('Автопересчёт формул включён', TMWOHistoryOut)
  else
    zcUI.TextMessage('Автопересчёт формул выключен', TMWOHistoryOut);
end;

{ Обработчик действия "Отменить" (Назад) }
procedure TSpreadsheetActions.OnActUndoExecute(Sender: TObject);
begin
  ExecuteUndo(FWorkbookSource);

  // Принудительное обновление отображения таблицы
  if FWorksheetGrid <> nil then
    FWorksheetGrid.Invalidate;
end;

{ Обработчик действия "Вернуть" (Вперёд) }
procedure TSpreadsheetActions.OnActRedoExecute(Sender: TObject);
begin
  ExecuteRedo(FWorkbookSource);

  // Принудительное обновление отображения таблицы
  if FWorksheetGrid <> nil then
    FWorksheetGrid.Invalidate;
end;

{ Обновление состояния кнопки "Отменить" }
procedure TSpreadsheetActions.OnActUndoUpdate(Sender: TObject);
begin
  FActUndo.Enabled := CanUndo;
end;

{ Обновление состояния кнопки "Вернуть" }
procedure TSpreadsheetActions.OnActRedoUpdate(Sender: TObject);
begin
  FActRedo.Enabled := CanRedo;
end;

end.
