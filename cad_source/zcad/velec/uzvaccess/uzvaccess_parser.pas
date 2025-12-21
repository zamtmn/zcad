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
  uzvaccess_types, uzclog;

type
  {**
    Класс для парсинга управляющих таблиц EXPORT

    Читает таблицы вида EXPORT1, EXPORT2 и преобразует их строки
    в структурированные инструкции для выполнения экспорта.

    ВАЖНО: Col1 таблицы EXPORT считается столбцом ID и игнорируется.
    Парсинг инструкций начинается с Col2 (тип инструкции).
  **}
  TExportTableParser = class
  private

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
    constructor Create;
    destructor Destroy; override;

    // Парсинг управляющей таблицы
    function Parse(
      const ATableName: String;
      ADataset: TDataSet
    ): TExportInstructions;
  end;

implementation

{ TExportTableParser }

constructor TExportTableParser.Create;
begin
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
    programlog.LogOutFormatStr(
      'uzvaccess: Инструкция tTable без имени таблицы - пропускается',
      [],
      LM_Info
    );
    Exit;
  end;

  // Если имя таблицы уже задано, выводим предупреждение
  if AInstruction.TargetTable <> '' then
    programlog.LogOutFormatStr(
      'uzvaccess: Переопределение целевой таблицы: %s -> %s',
      [AInstruction.TargetTable, ACol2],
      LM_Info
    );

  AInstruction.TargetTable := ACol2;
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
    programlog.LogOutFormatStr(
      'uzvaccess: Инструкция typeData без типа данных - пропускается',
      [],
      LM_Info
    );
    Exit;
  end;

  dataType := StringToSourceDataType(ACol2);
  AInstruction.TypeData := dataType;

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
    programlog.LogOutFormatStr(
      'uzvaccess: Инструкция setcolumn с неполными параметрами - пропускается',
      [],
      LM_Info
    );
    Exit;
  end;

  // Создание маппинга колонки
  mapping := TColumnMapping.Create;
  mapping.ColumnName := ACol2;
  mapping.DataType := StringToColumnDataType(ACol3);
  mapping.SourceParam := ACol4;

  AInstruction.AddColumnMapping(mapping);

end;

procedure TExportTableParser.ParseKeyColumnInstruction(
  AInstruction: TExportInstructions;
  ADataset: TDataSet
);
var
  i: Integer;
  colValue: String;
begin
  // Читаем все колонки начиная с Col3 (т.к. Col1 - ID, Col2 - тип инструкции)
  for i := 3 to 11 do
  begin
    colValue := GetColumnValue(ADataset, i);

    if colValue = '' then
      Break; // Больше нет ключевых колонок

    AInstruction.AddKeyColumn(colValue);
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
    programlog.LogOutFormatStr(
      'uzvaccess: Инструкция const с неполными параметрами - пропускается',
      [],
      LM_Info
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

end;

function TExportTableParser.Parse(
  const ATableName: String;
  ADataset: TDataSet
): TExportInstructions;
var
  col2, col3, col4, col5: String;
  instructionType: TInstructionType;
  rowCount: Integer;
begin
  Result := TExportInstructions.Create;
  rowCount := 0;

  programlog.LogOutFormatStr(
    'uzvaccess: Начало парсинга таблицы: %s',
    [ATableName],
    LM_Info
  );

  try
    // Проход по всем строкам датасета
    ADataset.First;

    while not ADataset.EOF do
    begin
      Inc(rowCount);

      // Читаем значения колонок
      // Col1 - это ID, пропускаем его
      // Col2 - тип инструкции (ранее был Col1)
      // Col3, Col4, Col5 - параметры инструкции
      col2 := GetColumnValue(ADataset, 2);
      col3 := GetColumnValue(ADataset, 3);
      col4 := GetColumnValue(ADataset, 4);
      col5 := GetColumnValue(ADataset, 5);

      // Пропускаем пустые строки (где нет типа инструкции)
      if col2 = '' then
      begin
        ADataset.Next;
        Continue;
      end;

      // Определяем тип инструкции из Col2 (ранее Col1)
      instructionType := StringToInstructionType(col2);

      // Парсим инструкцию в зависимости от типа
      case instructionType of
        itTable:
          ParseTableInstruction(Result, col3);

        itTypeData:
          ParseTypeDataInstruction(Result, col3);

        itSetColumn:
          ParseSetColumnInstruction(Result, col3, col4, col5);

        itKeyColumn:
          ParseKeyColumnInstruction(Result, ADataset);

        itConst:
          ParseConstInstruction(Result, col3, col4);

        itUnknown:
          programlog.LogOutFormatStr(
            'uzvaccess: Неизвестная инструкция "%s" в строке %d - пропускается',
            [col2, rowCount],
            LM_Info
          );
      end;

      ADataset.Next;
    end;

    // Валидация результатов парсинга
    if Result.TargetTable = '' then
    begin
      programlog.LogOutFormatStr(
      'uzvaccess: Не найдена инструкция tTable - целевая таблица не задана',
      [],
      LM_Info
    );
      raise Exception.Create('Не задана целевая таблица');
    end;

    if Result.ColumnMappings.Size = 0 then
    begin
      programlog.LogOutFormatStr(
      'uzvaccess: Не найдено ни одной инструкции setcolumn',
      [],
      LM_Info
    );
    end;

    programlog.LogOutFormatStr(
      'uzvaccess: Парсинг завершен: %d строк, %d маппингов, %d ключевых колонок',
      [rowCount, Result.ColumnMappings.Size, Result.KeyColumns.Count],
      LM_Info
    );

  except
    on E: Exception do
    begin
      programlog.LogOutFormatStr(
        'uzvaccess: Ошибка парсинга: %s',
        [E.Message],
        LM_Info
      );
      Result.Free;
      raise;
    end;
  end;
end;

end.
