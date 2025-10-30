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

{**Модуль управления процессом восстановления таблиц}
unit uzvtable_manager;

{$INCLUDE zengineconfig.inc}

interface

uses
  SysUtils,
  uzvtable_data,
  uzvtable_reader,
  uzvtable_analyzer,
  uzvtable_gui;

type
  // Менеджер процесса восстановления таблицы
  TUzvTableManager = class
  private
    FPrimitives: TUzvPrimitiveList;
    FTable: TUzvTableGrid;
    FStatus: TUzvTableStatus;
    FError: TUzvTableError;

    procedure SetStatus(aStatus: TUzvTableStatus);
    procedure SetError(const aMessage: string; aCode: Integer);
    procedure ClearError;
  public
    constructor Create;
    destructor Destroy; override;

    // Выполнить полный процесс восстановления таблицы
    function ProcessTableRestoration: Boolean;

    // Шаг 1: Считать примитивы с чертежа
    function ReadPrimitivesFromDrawing: Boolean;

    // Шаг 2: Построить таблицу из примитивов
    function BuildTableStructure: Boolean;

    // Шаг 3: Показать таблицу в GUI
    function ShowTableGUI: Boolean;

    // Получить текущий статус обработки
    property Status: TUzvTableStatus read FStatus;

    // Получить информацию об ошибке
    property Error: TUzvTableError read FError;

    // Получить построенную таблицу
    property Table: TUzvTableGrid read FTable;
  end;

// Глобальный экземпляр менеджера
function GetTableManager: TUzvTableManager;

// Освободить глобальный экземпляр менеджера
procedure FreeTableManager;

implementation

uses
  uzclog,
  uzcinterface;

var
  GlobalTableManager: TUzvTableManager = nil;

// Получить глобальный экземпляр менеджера
function GetTableManager: TUzvTableManager;
begin
  if GlobalTableManager = nil then
    GlobalTableManager := TUzvTableManager.Create;
  Result := GlobalTableManager;
end;

// Освободить глобальный экземпляр менеджера
procedure FreeTableManager;
begin
  if GlobalTableManager <> nil then
  begin
    GlobalTableManager.Free;
    GlobalTableManager := nil;
  end;
end;

{ TUzvTableManager }

constructor TUzvTableManager.Create;
begin
  inherited Create;

  FPrimitives:=TUzvPrimitiveList.Create;
  FTable := CreateEmptyTableGrid;
  FStatus := tsNotStarted;
  ClearError;

  zcUI.TextMessage('Менеджер таблиц создан', TMWOHistoryOut);
end;

destructor TUzvTableManager.Destroy;
begin
  // Освобождаем ресурсы
  FPrimitives.Free;
  FTable.rows.Free;
  FTable.columns.Free;
  FTable.cells.Free;

  zcUI.TextMessage('Менеджер таблиц уничтожен', TMWOHistoryOut);

  inherited Destroy;
end;

procedure TUzvTableManager.SetStatus(aStatus: TUzvTableStatus);
begin
  FStatus := aStatus;

  case FStatus of
    tsNotStarted:
      zcUI.TextMessage('Статус: Не начато', TMWOHistoryOut);
    tsReading:
      zcUI.TextMessage('Статус: Чтение примитивов', TMWOHistoryOut);
    tsAnalyzing:
      zcUI.TextMessage('Статус: Анализ структуры', TMWOHistoryOut);
    tsBuilding:
      zcUI.TextMessage('Статус: Построение таблицы', TMWOHistoryOut);
    tsComplete:
      zcUI.TextMessage('Статус: Завершено', TMWOHistoryOut);
    tsError:
      zcUI.TextMessage('Статус: Ошибка', TMWOHistoryOut);
  end;
end;

procedure TUzvTableManager.SetError(const aMessage: string; aCode: Integer);
begin
  FError.hasError := True;
  FError.errorMessage := aMessage;
  FError.errorCode := aCode;
  SetStatus(tsError);

  zcUI.TextMessage('Ошибка [' + IntToStr(aCode) + ']: ' + aMessage, TMWOHistoryOut);
  zcUI.TextMessage('Ошибка: ' + aMessage + ' / Error: ' + aMessage, TMWOHistoryOut);
end;

procedure TUzvTableManager.ClearError;
begin
  FError.hasError := False;
  FError.errorMessage := '';
  FError.errorCode := 0;
end;

function TUzvTableManager.ReadPrimitivesFromDrawing: Boolean;
begin
  Result := False;
  SetStatus(tsReading);
  ClearError;

  zcUI.TextMessage('Шаг 1: Чтение примитивов / Step 1: Reading primitives', TMWOHistoryOut);

  // Очищаем предыдущие данные
  FPrimitives.Clear;

  // Считываем примитивы
  if not uzvtable_reader.ReadSelectedPrimitives(FPrimitives) then
  begin
    SetError('Не удалось прочитать примитивы с чертежа', 1001);
    Exit;
  end;

  if FPrimitives.Size = 0 then
  begin
    SetError('Не найдено подходящих примитивов', 1002);
    Exit;
  end;

  zcUI.TextMessage('Прочитано примитивов: ' + IntToStr(FPrimitives.Size) + ' / Primitives read: ' + IntToStr(FPrimitives.Size), TMWOHistoryOut);
  Result := True;
end;

function TUzvTableManager.BuildTableStructure: Boolean;
begin
  Result := False;
  SetStatus(tsAnalyzing);

  zcUI.TextMessage('Шаг 2: Анализ и построение таблицы / Step 2: Analyzing and building table', TMWOHistoryOut);

  // Проверяем, что примитивы считаны
  if FPrimitives.Size = 0 then
  begin
    SetError('Нет примитивов для построения таблицы', 2001);
    Exit;
  end;

  SetStatus(tsBuilding);

  // Строим таблицу
  if not uzvtable_analyzer.BuildTableFromPrimitives(FPrimitives, FTable) then
  begin
    SetError('Не удалось построить структуру таблицы', 2002);
    Exit;
  end;

  if not FTable.isValid then
  begin
    SetError('Построенная таблица невалидна', 2003);
    Exit;
  end;

  zcUI.TextMessage('Таблица построена: ' +
    IntToStr(FTable.rowCount) + ' строк, ' +
    IntToStr(FTable.columnCount) + ' столбцов / Table built: ' +
    IntToStr(FTable.rowCount) + ' rows, ' +
    IntToStr(FTable.columnCount) + ' columns', TMWOHistoryOut);

  Result := True;
end;

function TUzvTableManager.ShowTableGUI: Boolean;
begin
  Result := False;

  zcUI.TextMessage('Шаг 3: Отображение таблицы / Step 3: Displaying table', TMWOHistoryOut);

  // Проверяем, что таблица построена
  if not FTable.isValid then
  begin
    SetError('Таблица не готова к отображению', 3001);
    Exit;
  end;

  try
    // Показываем таблицу в GUI
    uzvtable_gui.ShowTableInGUI(FTable);
    Result := True;
  except
    on E: Exception do
    begin
      SetError('Ошибка при отображении GUI: ' + E.Message, 3002);
      Exit;
    end;
  end;
end;

function TUzvTableManager.ProcessTableRestoration: Boolean;
begin
  Result := False;

  zcUI.TextMessage('=== Начало процесса восстановления таблицы ===', TMWOHistoryOut);
  zcUI.TextMessage('Начало восстановления таблицы / Starting table restoration', TMWOHistoryOut);

  try
    // Шаг 1: Чтение примитивов
    if not ReadPrimitivesFromDrawing then
    begin
      zcUI.TextMessage('Процесс прерван на этапе чтения', TMWOHistoryOut);
      Exit;
    end;

    // Шаг 2: Построение таблицы
    if not BuildTableStructure then
    begin
      zcUI.TextMessage('Процесс прерван на этапе построения', TMWOHistoryOut);
      Exit;
    end;

    // Шаг 3: Отображение в GUI
    if not ShowTableGUI then
    begin
      zcUI.TextMessage('Процесс прерван на этапе отображения', TMWOHistoryOut);
      Exit;
    end;

    // Успешное завершение
    SetStatus(tsComplete);
    zcUI.TextMessage('=== Процесс восстановления таблицы завершен успешно ===', TMWOHistoryOut);
    zcUI.TextMessage('Восстановление таблицы завершено успешно / Table restoration completed successfully', TMWOHistoryOut);

    Result := True;

  except
    on E: Exception do
    begin
      SetError('Неожиданная ошибка: ' + E.Message, 9999);
      zcUI.TextMessage('=== Процесс прерван из-за исключения ===', TMWOHistoryOut);
    end;
  end;
end;

initialization
  // При инициализации модуля ничего не делаем
  // Менеджер будет создан при первом обращении

finalization
  // При завершении освобождаем менеджер
  FreeTableManager;

end.
