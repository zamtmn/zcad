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

unit uzvaccess_types;

{$INCLUDE zengineconfig.inc}

interface

uses
  SysUtils, Classes, Variants, gvector;

type
  // Уровни логирования
  TLogLevel = (
    llDebug,    // Отладочная информация
    llInfo,     // Информационные сообщения
    llWarning,  // Предупреждения
    llError     // Ошибки
  );

  // Тип данных колонки
  TColumnDataType = (
    cdtString,   // Строка
    cdtInteger,  // Целое число
    cdtFloat     // Число с плавающей точкой
  );

  // Тип источника данных
  TSourceDataType = (
    sdtDevice,     // Устройство (GDBDeviceID)
    sdtSuperLine,  // Суперлиния (GDBSuperLineID)
    sdtCable       // Кабель (GDBCableID)
  );

  // Режим работы при ошибках
  TErrorMode = (
    emContinue,  // Продолжить выполнение
    emStop       // Остановить выполнение
  );

  // Тип инструкции
  TInstructionType = (
    itUnknown,    // Неизвестная инструкция
    itTable,      // tTable - имя целевой таблицы
    itTypeData,   // typeData - тип данных источника
    itSetColumn,  // setcolumn - настройка колонки
    itKeyColumn,  // keyColumn - ключевые колонки для UPSERT
    itConst,      // const - константное значение
    itExpr        // expr - вычисляемое выражение
  );

  // Маппинг колонки
  TColumnMapping = class
  public
    ColumnIndex: Integer;          // Индекс колонки (1..N)
    ColumnName: String;            // Имя колонки в целевой таблице
    DataType: TColumnDataType;     // Тип данных
    SourceParam: String;           // Имя параметра из источника
    DefaultValue: Variant;         // Значение по умолчанию
    IsConstant: Boolean;           // Является ли константой
    Expression: String;            // Выражение для вычисления

    constructor Create;
  end;

  TColumnMappingList = specialize TVector<TColumnMapping>;

  // Инструкции экспорта для одной EXPORT-таблицы
  TExportInstructions = class
  private
    FTargetTable: String;
    FTypeData: TSourceDataType;
    FColumnMappings: TColumnMappingList;
    FKeyColumns: TStringList;
  public
    constructor Create;
    destructor Destroy; override;

    // Добавить маппинг колонки
    procedure AddColumnMapping(AMapping: TColumnMapping);

    // Добавить ключевую колонку
    procedure AddKeyColumn(const AColumnName: String);

    property TargetTable: String read FTargetTable write FTargetTable;
    property TypeData: TSourceDataType read FTypeData write FTypeData;
    property ColumnMappings: TColumnMappingList read FColumnMappings;
    property KeyColumns: TStringList read FKeyColumns;
  end;

  // Результат обработки одной EXPORT-таблицы
  TExportTableResult = record
    TableName: String;          // Имя EXPORT-таблицы
    TargetTable: String;        // Имя целевой таблицы
    RowsProcessed: Integer;     // Обработано строк
    RowsInserted: Integer;      // Вставлено строк
    RowsUpdated: Integer;       // Обновлено строк
    ErrorCount: Integer;        // Количество ошибок
    ErrorMessages: TStringList; // Сообщения об ошибках
    Success: Boolean;           // Успешность выполнения
  end;

  // Общий результат экспорта
  TExportResult = class
  private
    FTableResults: TList;
    FTotalRowsProcessed: Integer;
    FTotalRowsInserted: Integer;
    FTotalRowsUpdated: Integer;
    FTotalErrors: Integer;
    FStartTime: TDateTime;
    FEndTime: TDateTime;
  public
    constructor Create;
    destructor Destroy; override;

    // Добавить результат обработки таблицы
    procedure AddTableResult(const AResult: TExportTableResult);

    // Получить длительность выполнения
    function GetDuration: Double;

    // Получить общую статистику как текст
    function GetSummary: String;

    property TableResults: TList read FTableResults;
    property TotalRowsProcessed: Integer read FTotalRowsProcessed;
    property TotalRowsInserted: Integer read FTotalRowsInserted;
    property TotalRowsUpdated: Integer read FTotalRowsUpdated;
    property TotalErrors: Integer read FTotalErrors;
    property StartTime: TDateTime read FStartTime write FStartTime;
    property EndTime: TDateTime read FEndTime write FEndTime;
  end;

// Вспомогательные функции

// Преобразование строки в TColumnDataType
function StringToColumnDataType(const AValue: String): TColumnDataType;

// Преобразование строки в TSourceDataType
function StringToSourceDataType(const AValue: String): TSourceDataType;

// Преобразование строки в TInstructionType
function StringToInstructionType(const AValue: String): TInstructionType;

// Преобразование TColumnDataType в строку
function ColumnDataTypeToString(AType: TColumnDataType): String;

// Преобразование TSourceDataType в строку
function SourceDataTypeToString(AType: TSourceDataType): String;

// Преобразование TInstructionType в строку
function InstructionTypeToString(AType: TInstructionType): String;

implementation

{ TColumnMapping }

constructor TColumnMapping.Create;
begin
  ColumnIndex := 0;
  ColumnName := '';
  DataType := cdtString;
  SourceParam := '';
  DefaultValue := Null;
  IsConstant := False;
  Expression := '';
end;

{ TExportInstructions }

constructor TExportInstructions.Create;
begin
  FTargetTable := '';
  FTypeData := sdtDevice;
  FColumnMappings := TColumnMappingList.Create;
  FKeyColumns := TStringList.Create;
end;

destructor TExportInstructions.Destroy;
var
  i: Integer;
begin
  // Освобождаем маппинги колонок
  for i := 0 to FColumnMappings.Count - 1 do
    FColumnMappings[i].Free;

  FColumnMappings.Free;
  FKeyColumns.Free;
  inherited Destroy;
end;

procedure TExportInstructions.AddColumnMapping(AMapping: TColumnMapping);
begin
  FColumnMappings.PushBack(AMapping);
end;

procedure TExportInstructions.AddKeyColumn(const AColumnName: String);
begin
  if FKeyColumns.IndexOf(AColumnName) = -1 then
    FKeyColumns.Add(AColumnName);
end;

{ TExportResult }

constructor TExportResult.Create;
begin
  FTableResults := TList.Create;
  FTotalRowsProcessed := 0;
  FTotalRowsInserted := 0;
  FTotalRowsUpdated := 0;
  FTotalErrors := 0;
  FStartTime := Now;
  FEndTime := Now;
end;

destructor TExportResult.Destroy;
var
  i: Integer;
  pResult: ^TExportTableResult;
begin
  // Освобождаем результаты таблиц
  for i := 0 to FTableResults.Count - 1 do
  begin
    pResult := FTableResults[i];
    pResult^.ErrorMessages.Free;
    Dispose(pResult);
  end;

  FTableResults.Free;
  inherited Destroy;
end;

procedure TExportResult.AddTableResult(const AResult: TExportTableResult);
var
  pResult: ^TExportTableResult;
begin
  New(pResult);
  pResult^ := AResult;
  FTableResults.Add(pResult);

  // Обновляем общую статистику
  Inc(FTotalRowsProcessed, AResult.RowsProcessed);
  Inc(FTotalRowsInserted, AResult.RowsInserted);
  Inc(FTotalRowsUpdated, AResult.RowsUpdated);
  Inc(FTotalErrors, AResult.ErrorCount);
end;

function TExportResult.GetDuration: Double;
begin
  Result := (FEndTime - FStartTime) * 24 * 60 * 60; // в секундах
end;

function TExportResult.GetSummary: String;
var
  i: Integer;
  pResult: ^TExportTableResult;
begin
  Result := Format('Экспорт завершен за %.2f сек.' + LineEnding, [GetDuration]);
  Result := Result + Format('Обработано таблиц: %d' + LineEnding, [FTableResults.Count]);
  Result := Result + Format('Всего строк обработано: %d' + LineEnding, [FTotalRowsProcessed]);
  Result := Result + Format('Вставлено строк: %d' + LineEnding, [FTotalRowsInserted]);
  Result := Result + Format('Обновлено строк: %d' + LineEnding, [FTotalRowsUpdated]);
  Result := Result + Format('Ошибок: %d' + LineEnding, [FTotalErrors]);

  // Детали по каждой таблице
  if FTableResults.Count > 0 then
  begin
    Result := Result + LineEnding + 'Детали по таблицам:' + LineEnding;
    for i := 0 to FTableResults.Count - 1 do
    begin
      pResult := FTableResults[i];
      Result := Result + Format('  %s -> %s: обработано %d, вставлено %d, обновлено %d, ошибок %d',
        [pResult^.TableName, pResult^.TargetTable, pResult^.RowsProcessed,
         pResult^.RowsInserted, pResult^.RowsUpdated, pResult^.ErrorCount]) + LineEnding;
    end;
  end;
end;

{ Вспомогательные функции }

function StringToColumnDataType(const AValue: String): TColumnDataType;
var
  lowerValue: String;
begin
  lowerValue := LowerCase(Trim(AValue));

  if lowerValue = 'integer' then
    Result := cdtInteger
  else if lowerValue = 'float' then
    Result := cdtFloat
  else
    Result := cdtString; // По умолчанию
end;

function StringToSourceDataType(const AValue: String): TSourceDataType;
var
  lowerValue: String;
begin
  lowerValue := LowerCase(Trim(AValue));

  if lowerValue = 'device' then
    Result := sdtDevice
  else if lowerValue = 'superline' then
    Result := sdtSuperLine
  else if lowerValue = 'cable' then
    Result := sdtCable
  else
    Result := sdtDevice; // По умолчанию
end;

function StringToInstructionType(const AValue: String): TInstructionType;
var
  lowerValue: String;
begin
  lowerValue := LowerCase(Trim(AValue));

  if lowerValue = 'ttable' then
    Result := itTable
  else if lowerValue = 'typedata' then
    Result := itTypeData
  else if lowerValue = 'setcolumn' then
    Result := itSetColumn
  else if lowerValue = 'keycolumn' then
    Result := itKeyColumn
  else if lowerValue = 'const' then
    Result := itConst
  else if lowerValue = 'expr' then
    Result := itExpr
  else
    Result := itUnknown;
end;

function ColumnDataTypeToString(AType: TColumnDataType): String;
begin
  case AType of
    cdtString: Result := 'string';
    cdtInteger: Result := 'integer';
    cdtFloat: Result := 'float';
  else
    Result := 'unknown';
  end;
end;

function SourceDataTypeToString(AType: TSourceDataType): String;
begin
  case AType of
    sdtDevice: Result := 'device';
    sdtSuperLine: Result := 'superline';
    sdtCable: Result := 'cable';
  else
    Result := 'unknown';
  end;
end;

function InstructionTypeToString(AType: TInstructionType): String;
begin
  case AType of
    itTable: Result := 'tTable';
    itTypeData: Result := 'typeData';
    itSetColumn: Result := 'setcolumn';
    itKeyColumn: Result := 'keyColumn';
    itConst: Result := 'const';
    itExpr: Result := 'expr';
  else
    Result := 'unknown';
  end;
end;

end.
