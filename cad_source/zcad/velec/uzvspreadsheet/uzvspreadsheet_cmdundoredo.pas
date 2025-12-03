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

{** Модуль команд отмены и возврата изменений в книге (Undo/Redo)
    Реализует стек изменений для отслеживания и отмены действий пользователя }
unit uzvspreadsheet_cmdundoredo;

{$INCLUDE zengineconfig.inc}

interface

uses
  Classes,
  SysUtils,
  fpspreadsheet,
  fpsTypes,
  fpspreadsheetctrls;

const
  // Максимальное количество записей в стеке отмены
  MAX_UNDO_STACK_SIZE = 100;

type
  { Тип содержимого ячейки }
  TCellContentKind = (cckEmpty, cckNumber, cckText, cckFormula, cckBoolean,
    cckError, cckDateTime);

  { Запись об изменении одной ячейки }
  TCellChange = record
    SheetIndex: Integer;       // Индекс листа
    Row: Cardinal;             // Строка ячейки
    Col: Cardinal;             // Столбец ячейки
    ContentKind: TCellContentKind; // Тип содержимого
    NumberValue: Double;       // Числовое значение
    TextValue: String;         // Текстовое значение или формула
    BoolValue: Boolean;        // Логическое значение
    ErrorValue: TsErrorValue;  // Код ошибки
    DateTimeValue: TDateTime;  // Значение даты/времени
  end;

  { Запись об одном действии (может содержать несколько изменённых ячеек) }
  TUndoRecord = record
    Description: String;                   // Описание действия
    Changes: array of TCellChange;         // Массив изменений ячеек
    ChangeCount: Integer;                  // Количество изменений
  end;

  { Класс для управления стеком отмены/возврата }
  TSpreadsheetUndoManager = class
  private
    FWorkbookSource: TsWorkbookSource;
    FUndoStack: array of TUndoRecord;      // Стек для отмены
    FRedoStack: array of TUndoRecord;      // Стек для возврата
    FUndoCount: Integer;                   // Количество записей в стеке отмены
    FRedoCount: Integer;                   // Количество записей в стеке возврата

    { Сохраняет содержимое ячейки в запись TCellChange }
    procedure SaveCellToChange(aWorksheet: TsWorksheet; aRow, aCol: Cardinal;
      aSheetIndex: Integer; out aChange: TCellChange);

    { Восстанавливает содержимое ячейки из записи TCellChange }
    procedure RestoreCellFromChange(const aChange: TCellChange);

    { Добавляет запись в стек отмены }
    procedure PushToUndoStack(const aRecord: TUndoRecord);

    { Добавляет запись в стек возврата }
    procedure PushToRedoStack(const aRecord: TUndoRecord);

    { Извлекает запись из стека отмены }
    function PopFromUndoStack(out aRecord: TUndoRecord): Boolean;

    { Извлекает запись из стека возврата }
    function PopFromRedoStack(out aRecord: TUndoRecord): Boolean;

  public
    constructor Create(aWorkbookSource: TsWorkbookSource);
    destructor Destroy; override;

    { Сохраняет текущее состояние ячейки перед изменением }
    procedure BeginChange(aRow, aCol: Cardinal; const aDescription: String);

    { Сохраняет текущее состояние диапазона ячеек перед изменением }
    procedure BeginRangeChange(aRow1, aCol1, aRow2, aCol2: Cardinal;
      const aDescription: String);

    { Выполняет отмену последнего действия }
    function ExecuteUndo: Boolean;

    { Выполняет возврат отменённого действия }
    function ExecuteRedo: Boolean;

    { Очищает стек возврата (вызывается при новом изменении) }
    procedure ClearRedoStack;

    { Очищает все стеки }
    procedure ClearAll;

    { Проверяет, есть ли доступные действия для отмены }
    function CanUndo: Boolean;

    { Проверяет, есть ли доступные действия для возврата }
    function CanRedo: Boolean;

    { Возвращает описание следующего действия для отмены }
    function GetUndoDescription: String;

    { Возвращает описание следующего действия для возврата }
    function GetRedoDescription: String;

    { Возвращает количество действий в стеке отмены }
    property UndoCount: Integer read FUndoCount;

    { Возвращает количество действий в стеке возврата }
    property RedoCount: Integer read FRedoCount;
  end;

var
  { Глобальный менеджер отмены/возврата для электронных таблиц }
  SpreadsheetUndoManager: TSpreadsheetUndoManager;

{ Инициализирует менеджер отмены/возврата }
procedure InitUndoManager(aWorkbookSource: TsWorkbookSource);

{ Освобождает менеджер отмены/возврата }
procedure FreeUndoManager;

{ Выполняет отмену последнего изменения }
function ExecuteUndo(aWorkbookSource: TsWorkbookSource): Boolean;

{ Выполняет возврат отменённого изменения }
function ExecuteRedo(aWorkbookSource: TsWorkbookSource): Boolean;

{ Проверяет возможность отмены }
function CanUndo: Boolean;

{ Проверяет возможность возврата }
function CanRedo: Boolean;

implementation

uses
  uzclog,
  uzcinterface;

{ TSpreadsheetUndoManager }

constructor TSpreadsheetUndoManager.Create(aWorkbookSource: TsWorkbookSource);
begin
  inherited Create;
  FWorkbookSource := aWorkbookSource;
  SetLength(FUndoStack, MAX_UNDO_STACK_SIZE);
  SetLength(FRedoStack, MAX_UNDO_STACK_SIZE);
  FUndoCount := 0;
  FRedoCount := 0;
end;

destructor TSpreadsheetUndoManager.Destroy;
begin
  ClearAll;
  SetLength(FUndoStack, 0);
  SetLength(FRedoStack, 0);
  inherited Destroy;
end;

{ Сохраняет содержимое ячейки в структуру TCellChange }
procedure TSpreadsheetUndoManager.SaveCellToChange(aWorksheet: TsWorksheet;
  aRow, aCol: Cardinal; aSheetIndex: Integer; out aChange: TCellChange);
var
  cell: PCell;
begin
  aChange.SheetIndex := aSheetIndex;
  aChange.Row := aRow;
  aChange.Col := aCol;
  aChange.ContentKind := cckEmpty;
  aChange.NumberValue := 0;
  aChange.TextValue := '';
  aChange.BoolValue := False;
  aChange.DateTimeValue := 0;

  if aWorksheet = nil then
    Exit;

  cell := aWorksheet.FindCell(aRow, aCol);
  if cell = nil then
  begin
    aChange.ContentKind := cckEmpty;
    Exit;
  end;

  // Определяем тип содержимого и сохраняем значение
  case cell^.ContentType of
    cctNumber:
      begin
        aChange.ContentKind := cckNumber;
        aChange.NumberValue := cell^.NumberValue;
      end;
    cctUTF8String:
      begin
        // Проверяем, есть ли формула (через ReadFormulaAsString)
        aChange.TextValue := aWorksheet.ReadFormulaAsString(cell);
        if aChange.TextValue <> '' then
        begin
          aChange.ContentKind := cckFormula;
          aChange.TextValue := '=' + aChange.TextValue;
        end
        else
        begin
          aChange.ContentKind := cckText;
          aChange.TextValue := aWorksheet.ReadAsText(cell);
        end;
      end;
    cctBool:
      begin
        aChange.ContentKind := cckBoolean;
        aChange.BoolValue := cell^.BoolValue;
      end;
    cctError:
      begin
        aChange.ContentKind := cckError;
        aChange.ErrorValue := cell^.ErrorValue;
      end;
    cctDateTime:
      begin
        aChange.ContentKind := cckDateTime;
        aChange.DateTimeValue := cell^.DateTimeValue;
      end;
    cctEmpty:
      aChange.ContentKind := cckEmpty;
  end;
end;

{ Восстанавливает содержимое ячейки из структуры TCellChange }
procedure TSpreadsheetUndoManager.RestoreCellFromChange(
  const aChange: TCellChange);
var
  workbook: TsWorkbook;
  worksheet: TsWorksheet;
  cell: PCell;
begin
  if FWorkbookSource = nil then
    Exit;

  workbook := FWorkbookSource.Workbook;
  if workbook = nil then
    Exit;

  // Получаем лист по индексу
  if (aChange.SheetIndex < 0) or
     (aChange.SheetIndex >= workbook.GetWorksheetCount) then
    Exit;

  worksheet := workbook.GetWorksheetByIndex(aChange.SheetIndex);
  if worksheet = nil then
    Exit;

  // Восстанавливаем содержимое ячейки
  case aChange.ContentKind of
    cckEmpty:
      begin
        // DeleteCell принимает PCell, не координаты
        cell := worksheet.FindCell(aChange.Row, aChange.Col);
        if cell <> nil then
          worksheet.DeleteCell(cell);
      end;
    cckNumber:
      worksheet.WriteNumber(aChange.Row, aChange.Col, aChange.NumberValue);
    cckText:
      worksheet.WriteText(aChange.Row, aChange.Col, aChange.TextValue);
    cckFormula:
      begin
        // Убираем знак '=' в начале формулы если есть
        if (Length(aChange.TextValue) > 0) and (aChange.TextValue[1] = '=') then
          worksheet.WriteFormula(aChange.Row, aChange.Col,
            Copy(aChange.TextValue, 2, Length(aChange.TextValue) - 1))
        else
          worksheet.WriteFormula(aChange.Row, aChange.Col, aChange.TextValue);
      end;
    cckBoolean:
      worksheet.WriteBoolValue(aChange.Row, aChange.Col, aChange.BoolValue);
    cckError:
      worksheet.WriteErrorValue(aChange.Row, aChange.Col, aChange.ErrorValue);
    cckDateTime:
      worksheet.WriteDateTime(aChange.Row, aChange.Col, aChange.DateTimeValue);
  end;
end;

{ Добавляет запись в стек отмены }
procedure TSpreadsheetUndoManager.PushToUndoStack(const aRecord: TUndoRecord);
var
  i: Integer;
begin
  // Если стек полон - удаляем самую старую запись
  if FUndoCount >= MAX_UNDO_STACK_SIZE then
  begin
    // Освобождаем память первой записи
    SetLength(FUndoStack[0].Changes, 0);
    // Сдвигаем все записи на одну позицию вниз
    for i := 0 to MAX_UNDO_STACK_SIZE - 2 do
      FUndoStack[i] := FUndoStack[i + 1];
    Dec(FUndoCount);
  end;

  FUndoStack[FUndoCount] := aRecord;
  Inc(FUndoCount);
end;

{ Добавляет запись в стек возврата }
procedure TSpreadsheetUndoManager.PushToRedoStack(const aRecord: TUndoRecord);
var
  i: Integer;
begin
  // Если стек полон - удаляем самую старую запись
  if FRedoCount >= MAX_UNDO_STACK_SIZE then
  begin
    SetLength(FRedoStack[0].Changes, 0);
    for i := 0 to MAX_UNDO_STACK_SIZE - 2 do
      FRedoStack[i] := FRedoStack[i + 1];
    Dec(FRedoCount);
  end;

  FRedoStack[FRedoCount] := aRecord;
  Inc(FRedoCount);
end;

{ Извлекает запись из стека отмены }
function TSpreadsheetUndoManager.PopFromUndoStack(
  out aRecord: TUndoRecord): Boolean;
begin
  Result := False;
  if FUndoCount <= 0 then
    Exit;

  Dec(FUndoCount);
  aRecord := FUndoStack[FUndoCount];
  Result := True;
end;

{ Извлекает запись из стека возврата }
function TSpreadsheetUndoManager.PopFromRedoStack(
  out aRecord: TUndoRecord): Boolean;
begin
  Result := False;
  if FRedoCount <= 0 then
    Exit;

  Dec(FRedoCount);
  aRecord := FRedoStack[FRedoCount];
  Result := True;
end;

{ Сохраняет текущее состояние ячейки перед изменением }
procedure TSpreadsheetUndoManager.BeginChange(aRow, aCol: Cardinal;
  const aDescription: String);
var
  undoRecord: TUndoRecord;
  workbook: TsWorkbook;
  worksheet: TsWorksheet;
  sheetIndex: Integer;
begin
  if FWorkbookSource = nil then
    Exit;

  workbook := FWorkbookSource.Workbook;
  if workbook = nil then
    Exit;

  worksheet := workbook.ActiveWorksheet;
  if worksheet = nil then
    Exit;

  // Находим индекс активного листа
  sheetIndex := workbook.GetWorksheetIndex(worksheet);

  // Создаём запись отмены
  undoRecord.Description := aDescription;
  undoRecord.ChangeCount := 1;
  SetLength(undoRecord.Changes, 1);

  // Сохраняем текущее состояние ячейки
  SaveCellToChange(worksheet, aRow, aCol, sheetIndex, undoRecord.Changes[0]);

  // Добавляем в стек отмены
  PushToUndoStack(undoRecord);

  // Очищаем стек возврата (новое действие делает redo невозможным)
  ClearRedoStack;
end;

{ Сохраняет текущее состояние диапазона ячеек перед изменением }
procedure TSpreadsheetUndoManager.BeginRangeChange(
  aRow1, aCol1, aRow2, aCol2: Cardinal; const aDescription: String);
var
  undoRecord: TUndoRecord;
  workbook: TsWorkbook;
  worksheet: TsWorksheet;
  sheetIndex: Integer;
  row, col: Cardinal;
  changeIndex: Integer;
begin
  if FWorkbookSource = nil then
    Exit;

  workbook := FWorkbookSource.Workbook;
  if workbook = nil then
    Exit;

  worksheet := workbook.ActiveWorksheet;
  if worksheet = nil then
    Exit;

  sheetIndex := workbook.GetWorksheetIndex(worksheet);

  // Создаём запись отмены
  undoRecord.Description := aDescription;
  undoRecord.ChangeCount := (aRow2 - aRow1 + 1) * (aCol2 - aCol1 + 1);
  SetLength(undoRecord.Changes, undoRecord.ChangeCount);

  // Сохраняем все ячейки диапазона
  changeIndex := 0;
  for row := aRow1 to aRow2 do
  begin
    for col := aCol1 to aCol2 do
    begin
      SaveCellToChange(worksheet, row, col, sheetIndex,
        undoRecord.Changes[changeIndex]);
      Inc(changeIndex);
    end;
  end;

  PushToUndoStack(undoRecord);
  ClearRedoStack;
end;

{ Выполняет отмену последнего действия }
function TSpreadsheetUndoManager.ExecuteUndo: Boolean;
var
  undoRecord: TUndoRecord;
  redoRecord: TUndoRecord;
  workbook: TsWorkbook;
  worksheet: TsWorksheet;
  i: Integer;
begin
  Result := False;

  if not PopFromUndoStack(undoRecord) then
    Exit;

  if FWorkbookSource = nil then
    Exit;

  workbook := FWorkbookSource.Workbook;
  if workbook = nil then
    Exit;

  // Сначала сохраняем текущее состояние для возможности Redo
  redoRecord.Description := undoRecord.Description;
  redoRecord.ChangeCount := undoRecord.ChangeCount;
  SetLength(redoRecord.Changes, redoRecord.ChangeCount);

  for i := 0 to undoRecord.ChangeCount - 1 do
  begin
    // Получаем лист для этого изменения
    if (undoRecord.Changes[i].SheetIndex >= 0) and
       (undoRecord.Changes[i].SheetIndex < workbook.GetWorksheetCount) then
    begin
      worksheet := workbook.GetWorksheetByIndex(undoRecord.Changes[i].SheetIndex);
      if worksheet <> nil then
        SaveCellToChange(worksheet, undoRecord.Changes[i].Row,
          undoRecord.Changes[i].Col, undoRecord.Changes[i].SheetIndex,
          redoRecord.Changes[i]);
    end;
  end;

  // Добавляем в стек Redo
  PushToRedoStack(redoRecord);

  // Восстанавливаем предыдущее состояние ячеек
  for i := 0 to undoRecord.ChangeCount - 1 do
    RestoreCellFromChange(undoRecord.Changes[i]);

  // Освобождаем память
  SetLength(undoRecord.Changes, 0);

  Result := True;
end;

{ Выполняет возврат отменённого действия }
function TSpreadsheetUndoManager.ExecuteRedo: Boolean;
var
  redoRecord: TUndoRecord;
  undoRecord: TUndoRecord;
  workbook: TsWorkbook;
  worksheet: TsWorksheet;
  i: Integer;
begin
  Result := False;

  if not PopFromRedoStack(redoRecord) then
    Exit;

  if FWorkbookSource = nil then
    Exit;

  workbook := FWorkbookSource.Workbook;
  if workbook = nil then
    Exit;

  // Сохраняем текущее состояние для возможности повторной отмены
  undoRecord.Description := redoRecord.Description;
  undoRecord.ChangeCount := redoRecord.ChangeCount;
  SetLength(undoRecord.Changes, undoRecord.ChangeCount);

  for i := 0 to redoRecord.ChangeCount - 1 do
  begin
    if (redoRecord.Changes[i].SheetIndex >= 0) and
       (redoRecord.Changes[i].SheetIndex < workbook.GetWorksheetCount) then
    begin
      worksheet := workbook.GetWorksheetByIndex(redoRecord.Changes[i].SheetIndex);
      if worksheet <> nil then
        SaveCellToChange(worksheet, redoRecord.Changes[i].Row,
          redoRecord.Changes[i].Col, redoRecord.Changes[i].SheetIndex,
          undoRecord.Changes[i]);
    end;
  end;

  // Добавляем в стек Undo
  PushToUndoStack(undoRecord);

  // Восстанавливаем состояние ячеек из Redo
  for i := 0 to redoRecord.ChangeCount - 1 do
    RestoreCellFromChange(redoRecord.Changes[i]);

  // Освобождаем память
  SetLength(redoRecord.Changes, 0);

  Result := True;
end;

{ Очищает стек возврата }
procedure TSpreadsheetUndoManager.ClearRedoStack;
var
  i: Integer;
begin
  for i := 0 to FRedoCount - 1 do
    SetLength(FRedoStack[i].Changes, 0);
  FRedoCount := 0;
end;

{ Очищает все стеки }
procedure TSpreadsheetUndoManager.ClearAll;
var
  i: Integer;
begin
  for i := 0 to FUndoCount - 1 do
    SetLength(FUndoStack[i].Changes, 0);
  FUndoCount := 0;

  ClearRedoStack;
end;

{ Проверяет возможность отмены }
function TSpreadsheetUndoManager.CanUndo: Boolean;
begin
  Result := FUndoCount > 0;
end;

{ Проверяет возможность возврата }
function TSpreadsheetUndoManager.CanRedo: Boolean;
begin
  Result := FRedoCount > 0;
end;

{ Возвращает описание следующего действия для отмены }
function TSpreadsheetUndoManager.GetUndoDescription: String;
begin
  if FUndoCount > 0 then
    Result := FUndoStack[FUndoCount - 1].Description
  else
    Result := '';
end;

{ Возвращает описание следующего действия для возврата }
function TSpreadsheetUndoManager.GetRedoDescription: String;
begin
  if FRedoCount > 0 then
    Result := FRedoStack[FRedoCount - 1].Description
  else
    Result := '';
end;

{ Глобальные процедуры }

procedure InitUndoManager(aWorkbookSource: TsWorkbookSource);
begin
  if SpreadsheetUndoManager <> nil then
    FreeAndNil(SpreadsheetUndoManager);

  SpreadsheetUndoManager := TSpreadsheetUndoManager.Create(aWorkbookSource);

  programlog.LogOutFormatStr(
    'Менеджер отмены/возврата для электронных таблиц инициализирован',
    [],
    LM_Info
  );
end;

procedure FreeUndoManager;
begin
  if SpreadsheetUndoManager <> nil then
  begin
    FreeAndNil(SpreadsheetUndoManager);

    programlog.LogOutFormatStr(
      'Менеджер отмены/возврата для электронных таблиц освобождён',
      [],
      LM_Info
    );
  end;
end;

function ExecuteUndo(aWorkbookSource: TsWorkbookSource): Boolean;
var
  description: String;
begin
  Result := False;

  if SpreadsheetUndoManager = nil then
  begin
    zcUI.TextMessage('Ошибка: менеджер отмены не инициализирован',
      TMWOHistoryOut);
    Exit;
  end;

  if not SpreadsheetUndoManager.CanUndo then
  begin
    zcUI.TextMessage('Нет действий для отмены', TMWOHistoryOut);
    Exit;
  end;

  description := SpreadsheetUndoManager.GetUndoDescription;

  try
    Result := SpreadsheetUndoManager.ExecuteUndo;

    if Result then
    begin
      programlog.LogOutFormatStr(
        'Отменено действие: %s',
        [description],
        LM_Info
      );
      zcUI.TextMessage('Отменено: ' + description, TMWOHistoryOut);
    end;
  except
    on E: Exception do
    begin
      programlog.LogOutFormatStr(
        'Ошибка отмены действия: %s',
        [E.Message],
        LM_Info
      );
      zcUI.TextMessage('Ошибка отмены: ' + E.Message, TMWOHistoryOut);
    end;
  end;
end;

function ExecuteRedo(aWorkbookSource: TsWorkbookSource): Boolean;
var
  description: String;
begin
  Result := False;

  if SpreadsheetUndoManager = nil then
  begin
    zcUI.TextMessage('Ошибка: менеджер отмены не инициализирован',
      TMWOHistoryOut);
    Exit;
  end;

  if not SpreadsheetUndoManager.CanRedo then
  begin
    zcUI.TextMessage('Нет действий для возврата', TMWOHistoryOut);
    Exit;
  end;

  description := SpreadsheetUndoManager.GetRedoDescription;

  try
    Result := SpreadsheetUndoManager.ExecuteRedo;

    if Result then
    begin
      programlog.LogOutFormatStr(
        'Возвращено действие: %s',
        [description],
        LM_Info
      );
      zcUI.TextMessage('Возвращено: ' + description, TMWOHistoryOut);
    end;
  except
    on E: Exception do
    begin
      programlog.LogOutFormatStr(
        'Ошибка возврата действия: %s',
        [E.Message],
        LM_Info
      );
      zcUI.TextMessage('Ошибка возврата: ' + E.Message, TMWOHistoryOut);
    end;
  end;
end;

function CanUndo: Boolean;
begin
  if SpreadsheetUndoManager <> nil then
    Result := SpreadsheetUndoManager.CanUndo
  else
    Result := False;
end;

function CanRedo: Boolean;
begin
  if SpreadsheetUndoManager <> nil then
    Result := SpreadsheetUndoManager.CanRedo
  else
    Result := False;
end;

initialization
  SpreadsheetUndoManager := nil;

finalization
  FreeUndoManager;

end.
