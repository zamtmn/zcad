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

unit uzvaccess_parser;

{$INCLUDE zengineconfig.inc}

interface

uses
  SysUtils, Classes, DB,
  uzvaccess_types, uzvaccess_logger;

type
  {**
    Класс для парсинга управляющих таблиц EXPORT

    Читает таблицы вида EXPORT1, EXPORT2 и преобразует их строки
    в структурированные инструкции для выполнения экспорта
  **}
  TExportTableParser = class
  private
    FLogger: TExportLogger;

    // Получить значение колонки из датасета
    function GetColumnValue(ADataset: TDataSet; AColumnIndex: Integer): String;

    // Парсинг инструкции tTable
    procedure ParseTableInstruction(
      AInstruction: TExportInstructions;
      const ACol2: String
    );

    // Парсинг инструкции typeData
    procedure ParseTypeDataInstruction(
      AInstruction: TExportInstructions;
      const ACol2: String
    );

    // Парсинг инструкции setcolumn
    procedure ParseSetColumnInstruction(
      AInstruction: TExportInstructions;
      const ACol2, ACol3, ACol4: String
    );

    // Парсинг инструкции keyColumn
    procedure ParseKeyColumnInstruction(
      AInstruction: TExportInstructions;
      ADataset: TDataSet
    );

    // Парсинг инструкции const
    procedure ParseConstInstruction(
      AInstruction: TExportInstructions;
      const ACol2, ACol3: String
    );

  public
    constructor Create(ALogger: TExportLogger);
    destructor Destroy; override;

    // Парсинг управляющей таблицы
    function Parse(
      const ATableName: String;
      ADataset: TDataSet
    ): TExportInstructions;
  end;

implementation

{ TExportTableParser }

constructor TExportTableParser.Create(ALogger: TExportLogger);
begin
  FLogger := ALogger;
end;

destructor TExportTableParser.Destroy;
begin
  inherited Destroy;
end;

function TExportTableParser.GetColumnValue(
  ADataset: TDataSet;
  AColumnIndex: Integer
): String;
var
  fieldName: String;
begin
  Result := '';

  // Формируем имя колонки (Col1, Col2, ...)
  fieldName := Format('Col%d', [AColumnIndex]);

  // Проверяем наличие поля
  if ADataset.FindField(fieldName) = nil then
    Exit;

  // Получаем значение и обрезаем пробелы
  Result := Trim(ADataset.FieldByName(fieldName).AsString);
end;

procedure TExportTableParser.ParseTableInstruction(
  AInstruction: TExportInstructions;
  const ACol2: String
);
begin
  if ACol2 = '' then
  begin
    FLogger.LogWarning('Инструкция tTable без имени таблицы - пропускается');
    Exit;
  end;

  // Если имя таблицы уже задано, выводим предупреждение
  if AInstruction.TargetTable <> '' then
    FLogger.LogWarning(Format(
      'Переопределение целевой таблицы: %s -> %s',
      [AInstruction.TargetTable, ACol2]
    ));

  AInstruction.TargetTable := ACol2;
  FLogger.LogDebug('Целевая таблица: ' + ACol2);
end;

procedure TExportTableParser.ParseTypeDataInstruction(
  AInstruction: TExportInstructions;
  const ACol2: String
);
var
  dataType: TSourceDataType;
begin
  if ACol2 = '' then
  begin
    FLogger.LogWarning('Инструкция typeData без типа данных - пропускается');
    Exit;
  end;

  dataType := StringToSourceDataType(ACol2);
  AInstruction.TypeData := dataType;

  FLogger.LogDebug(Format('Тип данных источника: %s', [ACol2]));
end;

procedure TExportTableParser.ParseSetColumnInstruction(
  AInstruction: TExportInstructions;
  const ACol2, ACol3, ACol4: String
);
var
  mapping: TColumnMapping;
begin
  // Проверка обязательных параметров
  if (ACol2 = '') or (ACol3 = '') or (ACol4 = '') then
  begin
    FLogger.LogWarning(
      'Инструкция setcolumn с неполными параметрами - пропускается'
    );
    Exit;
  end;

  // Создание маппинга колонки
  mapping := TColumnMapping.Create;
  mapping.ColumnName := ACol2;
  mapping.DataType := StringToColumnDataType(ACol3);
  mapping.SourceParam := ACol4;

  AInstruction.AddColumnMapping(mapping);

  FLogger.LogDebug(Format(
    'Добавлен маппинг: %s (%s) <- %s',
    [mapping.ColumnName, ColumnDataTypeToString(mapping.DataType),
     mapping.SourceParam]
  ));
end;

procedure TExportTableParser.ParseKeyColumnInstruction(
  AInstruction: TExportInstructions;
  ADataset: TDataSet
);
var
  i: Integer;
  colValue: String;
begin
  // Читаем все колонки начиная с Col2
  for i := 2 to 10 do
  begin
    colValue := GetColumnValue(ADataset, i);

    if colValue = '' then
      Break; // Больше нет ключевых колонок

    AInstruction.AddKeyColumn(colValue);
    FLogger.LogDebug('Добавлена ключевая колонка: ' + colValue);
  end;
end;

procedure TExportTableParser.ParseConstInstruction(
  AInstruction: TExportInstructions;
  const ACol2, ACol3: String
);
var
  mapping: TColumnMapping;
begin
  // Проверка обязательных параметров
  if (ACol2 = '') or (ACol3 = '') then
  begin
    FLogger.LogWarning(
      'Инструкция const с неполными параметрами - пропускается'
    );
    Exit;
  end;

  // Создание константного маппинга
  mapping := TColumnMapping.Create;
  mapping.ColumnName := ACol2;
  mapping.DataType := cdtString; // Константы всегда строки
  mapping.IsConstant := True;
  mapping.DefaultValue := ACol3;

  AInstruction.AddColumnMapping(mapping);

  FLogger.LogDebug(Format(
    'Добавлена константа: %s = "%s"',
    [mapping.ColumnName, ACol3]
  ));
end;

function TExportTableParser.Parse(
  const ATableName: String;
  ADataset: TDataSet
): TExportInstructions;
var
  col1, col2, col3, col4: String;
  instructionType: TInstructionType;
  rowCount: Integer;
begin
  Result := TExportInstructions.Create;
  rowCount := 0;

  FLogger.LogInfo(Format('Начало парсинга таблицы: %s', [ATableName]));

  try
    // Проход по всем строкам датасета
    ADataset.First;

    while not ADataset.EOF do
    begin
      Inc(rowCount);

      // Читаем значения колонок
      col1 := GetColumnValue(ADataset, 1);
      col2 := GetColumnValue(ADataset, 2);
      col3 := GetColumnValue(ADataset, 3);
      col4 := GetColumnValue(ADataset, 4);

      // Пропускаем пустые строки
      if col1 = '' then
      begin
        ADataset.Next;
        Continue;
      end;

      // Определяем тип инструкции
      instructionType := StringToInstructionType(col1);

      // Парсим инструкцию в зависимости от типа
      case instructionType of
        itTable:
          ParseTableInstruction(Result, col2);

        itTypeData:
          ParseTypeDataInstruction(Result, col2);

        itSetColumn:
          ParseSetColumnInstruction(Result, col2, col3, col4);

        itKeyColumn:
          ParseKeyColumnInstruction(Result, ADataset);

        itConst:
          ParseConstInstruction(Result, col2, col3);

        itUnknown:
          FLogger.LogWarning(Format(
            'Неизвестная инструкция "%s" в строке %d - пропускается',
            [col1, rowCount]
          ));
      end;

      ADataset.Next;
    end;

    // Валидация результатов парсинга
    if Result.TargetTable = '' then
    begin
      FLogger.LogError('Не найдена инструкция tTable - целевая таблица не задана');
      raise Exception.Create('Не задана целевая таблица');
    end;

    if Result.ColumnMappings.Count = 0 then
    begin
      FLogger.LogWarning('Не найдено ни одной инструкции setcolumn');
    end;

    FLogger.LogInfo(Format(
      'Парсинг завершен: %d строк, %d маппингов, %d ключевых колонок',
      [rowCount, Result.ColumnMappings.Count, Result.KeyColumns.Count]
    ));

  except
    on E: Exception do
    begin
      FLogger.LogError('Ошибка парсинга: ' + E.Message);
      Result.Free;
      raise;
    end;
  end;
end;

end.
