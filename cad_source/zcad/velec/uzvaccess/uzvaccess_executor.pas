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

unit uzvaccess_executor;

{$INCLUDE zengineconfig.inc}

interface

uses
  SysUtils, Classes, Variants, DB, SQLDB,
  uzvaccess_types, uzclog, uzvaccess_config,
  uzvaccess_connection, uzvaccess_validator,
  uzvaccess_source_provider;

type
  // Тип для хранения массива Variant в TList
  TVariantArray = array of Variant;
  PVariantArray = ^TVariantArray;


  {**
    Класс для выполнения экспорта данных в Access

    Обрабатывает инструкции экспорта, получает данные из источника,
    выполняет валидацию и вставляет/обновляет данные в целевой таблице
  **}
  TExportExecutor = class
  private
    FConnection: TAccessConnection;
    FValidator: TTypeValidator;
    FConfig: TExportConfig;
    FBatchSize: Integer;

    // Построить SQL для вставки
    function BuildInsertSQL(
      const ATableName: String;
      AInstructions: TExportInstructions
    ): String;

    // Построить SQL для обновления (UPSERT)
    function BuildUpdateSQL(
      const ATableName: String;
      AInstructions: TExportInstructions
    ): String;

    // Построить SQL для проверки существования записи
    function BuildExistsSQL(
      const ATableName: String;
      AInstructions: TExportInstructions
    ): String;

    // Подготовить параметры запроса
    procedure PrepareQueryParams(
      AQuery: TSQLQuery;
      AInstructions: TExportInstructions;
      const AValues: array of Variant
    );

    // Вставить пакет данных
    function InsertBatch(
      const ATableName: String;
      AInstructions: TExportInstructions;
      ABatchData: TList
    ): Integer;

    // Обновить или вставить запись (UPSERT)
    function UpsertRecord(
      const ATableName: String;
      AInstructions: TExportInstructions;
      const AValues: array of Variant
    ): Boolean;

    // Проверить существование записи по ключам
    function RecordExists(
      const ATableName: String;
      AInstructions: TExportInstructions;
      const AValues: array of Variant
    ): Boolean;

    // Извлечь значения из примитива
    function ExtractValues(
      AEntity: Pointer;
      AInstructions: TExportInstructions;
      ASourceProvider: IDataSourceProvider;
      out AValues: array of Variant
    ): Boolean;

  public
    constructor Create(
      AConnection: TAccessConnection;
      AValidator: TTypeValidator;
      AConfig: TExportConfig
    );
    destructor Destroy; override;

    // Выполнить экспорт для одной EXPORT-таблицы
    function ExecuteExport(
      const AExportTableName: String;
      AInstructions: TExportInstructions;
      ASourceProvider: IDataSourceProvider
    ): TExportTableResult;
  end;

implementation

{ TExportExecutor }

constructor TExportExecutor.Create(
  AConnection: TAccessConnection;
  AValidator: TTypeValidator;
  AConfig: TExportConfig
);
begin
  FConnection := AConnection;
  FValidator := AValidator;
  FConfig := AConfig;
  FBatchSize := AConfig.BatchSize;
end;

destructor TExportExecutor.Destroy;
begin
  inherited Destroy;
end;

function TExportExecutor.BuildInsertSQL(
  const ATableName: String;
  AInstructions: TExportInstructions
): String;
var
  i: Integer;
  mapping: TColumnMapping;
  columns, params: String;
begin
  columns := '';
  params := '';

  // Формируем список колонок и параметров
  for i := 0 to AInstructions.ColumnMappings.Size - 1 do
  begin
    mapping := AInstructions.ColumnMappings[i];

    if i > 0 then
    begin
      columns := columns + ', ';
      params := params + ', ';
    end;

    columns := columns + '[' + mapping.ColumnName + ']';
    params := params + ':' + mapping.ColumnName;
  end;

  Result := Format('INSERT INTO [%s] (%s) VALUES (%s)',
    [ATableName, columns, params]);
end;

function TExportExecutor.BuildUpdateSQL(
  const ATableName: String;
  AInstructions: TExportInstructions
): String;
var
  i: Integer;
  mapping: TColumnMapping;
  setClause, whereClause: String;
  isKey: Boolean;
begin
  setClause := '';
  whereClause := '';

  // Формируем SET и WHERE части
  for i := 0 to AInstructions.ColumnMappings.Size - 1 do
  begin
    mapping := AInstructions.ColumnMappings[i];
    isKey := AInstructions.KeyColumns.IndexOf(mapping.ColumnName) >= 0;

    if not isKey then
    begin
      // Не ключевые колонки идут в SET
      if setClause <> '' then
        setClause := setClause + ', ';

      setClause := setClause + Format('[%s] = :%s',
        [mapping.ColumnName, mapping.ColumnName]);
    end
    else
    begin
      // Ключевые колонки идут в WHERE
      if whereClause <> '' then
        whereClause := whereClause + ' AND ';

      whereClause := whereClause + Format('[%s] = :%s_key',
        [mapping.ColumnName, mapping.ColumnName]);
    end;
  end;

  Result := Format('UPDATE [%s] SET %s WHERE %s',
    [ATableName, setClause, whereClause]);
end;

function TExportExecutor.BuildExistsSQL(
  const ATableName: String;
  AInstructions: TExportInstructions
): String;
var
  i: Integer;
  keyCol: String;
  whereClause: String;
begin
  whereClause := '';

  // Формируем WHERE по ключевым колонкам
  for i := 0 to AInstructions.KeyColumns.Count - 1 do
  begin
    keyCol := AInstructions.KeyColumns[i];

    if i > 0 then
      whereClause := whereClause + ' AND ';

    whereClause := whereClause + Format('[%s] = :%s',
      [keyCol, keyCol]);
  end;

  Result := Format('SELECT COUNT(*) AS RecCount FROM [%s] WHERE %s',
    [ATableName, whereClause]);
end;

procedure TExportExecutor.PrepareQueryParams(
  AQuery: TSQLQuery;
  AInstructions: TExportInstructions;
  const AValues: array of Variant
);
var
  i: Integer;
  mapping: TColumnMapping;
  paramName: String;
  value: Variant;
begin
  // Очищаем существующие параметры
  AQuery.Params.Clear;

  // Добавляем параметры для каждой колонки
  for i := 0 to AInstructions.ColumnMappings.Size - 1 do
  begin
    if i > High(AValues) then
      Break;

    mapping := AInstructions.ColumnMappings[i];
    value := AValues[i];
    paramName := mapping.ColumnName;

    // Создаём параметр
    if VarIsNull(value) then
    begin
      AQuery.Params.CreateParam(ftString, paramName, ptInput).Clear;
    end
    else
    begin
      case mapping.DataType of
        cdtString:
          AQuery.Params.CreateParam(ftString, paramName, ptInput).AsString :=
            VarToStr(value);

        cdtInteger:
          AQuery.Params.CreateParam(ftInteger, paramName, ptInput).AsInteger :=
            Integer(value);

        cdtFloat:
          AQuery.Params.CreateParam(ftFloat, paramName, ptInput).AsFloat :=
            Double(value);
      end;
    end;
  end;
end;

function TExportExecutor.RecordExists(
  const ATableName: String;
  AInstructions: TExportInstructions;
  const AValues: array of Variant
): Boolean;
var
  query: TSQLQuery;
  sql: String;
  i, idx: Integer;
  keyCol: String;
  value: Variant;
  count: Integer;
begin
  Result := False;

  // Если нет ключевых колонок, считаем что записи не существует
  if AInstructions.KeyColumns.Count = 0 then
    Exit;

  query := TSQLQuery.Create(nil);
  try
    query.DataBase := FConnection.GetQuery.DataBase;
    query.Transaction := FConnection.GetQuery.Transaction;

    sql := BuildExistsSQL(ATableName, AInstructions);
    query.SQL.Text := sql;

    // Устанавливаем параметры только для ключевых колонок
    for i := 0 to AInstructions.KeyColumns.Count - 1 do
    begin
      keyCol := AInstructions.KeyColumns[i];

      // Находим индекс этой колонки в маппингах
      idx := -1;
      for idx := 0 to AInstructions.ColumnMappings.Size - 1 do
      begin
        if AInstructions.ColumnMappings[idx].ColumnName = keyCol then
          Break;
      end;

      if (idx >= 0) and (idx <= High(AValues)) then
      begin
        value := AValues[idx];
        query.Params.CreateParam(ftString, keyCol, ptInput).AsString :=
          VarToStr(value);
      end;
    end;

    // Выполняем запрос
    query.Open;
    try
      count := query.FieldByName('RecCount').AsInteger;
      Result := (count > 0);
    finally
      query.Close;
    end;

  finally
    query.Free;
  end;
end;

function TExportExecutor.UpsertRecord(
  const ATableName: String;
  AInstructions: TExportInstructions;
  const AValues: array of Variant
): Boolean;
var
  query: TSQLQuery;
  sql: String;
  exists: Boolean;
begin
  Result := False;

  query := FConnection.GetQuery;

  try
    // Проверяем существование записи
    exists := RecordExists(ATableName, AInstructions, AValues);

    if exists then
    begin
      // UPDATE
      sql := BuildUpdateSQL(ATableName, AInstructions);
    end
    else
    begin
      // INSERT
      sql := BuildInsertSQL(ATableName, AInstructions);
    end;

    query.SQL.Text := sql;
    PrepareQueryParams(query, AInstructions, AValues);
    query.ExecSQL;

    Result := True;

  except
    on E: Exception do
    begin
      programlog.LogOutFormatStr(
        'uzvaccess: Ошибка при выполнении UPSERT: %s',
        [E.Message],
        LM_Info
      );
      Result := False;
    end;
  end;
end;

function TExportExecutor.InsertBatch(
  const ATableName: String;
  AInstructions: TExportInstructions;
  ABatchData: TList
): Integer;
var
  i: Integer;
  query: TSQLQuery;
  sql: String;
  values: array of Variant;
begin
  Result := 0;

  if ABatchData.Count = 0 then
    Exit;

  query := FConnection.GetQuery;
  sql := BuildInsertSQL(ATableName, AInstructions);

  query.SQL.Text := sql;

  // Вставляем записи по одной
  for i := 0 to ABatchData.Count - 1 do
  begin
    // Извлекаем указатель на массив значений и разыменовываем его
    values := PVariantArray(ABatchData[i])^;

    try
      PrepareQueryParams(query, AInstructions, values);
      query.ExecSQL;
      Inc(Result);

    except
      on E: Exception do
      begin
        programlog.LogOutFormatStr(
          'uzvaccess: Ошибка вставки записи %d: %s',
          [i + 1, E.Message],
          LM_Info
        );

        if FConfig.ErrorMode = emStop then
          raise;
      end;
    end;
  end;
end;

function TExportExecutor.ExtractValues(
  AEntity: Pointer;
  AInstructions: TExportInstructions;
  ASourceProvider: IDataSourceProvider;
  out AValues: array of Variant
): Boolean;
var
  i: Integer;
  mapping: TColumnMapping;
  rawValue, convertedValue: Variant;
begin
  Result := True;

  // Извлекаем значения для каждой колонки
  for i := 0 to AInstructions.ColumnMappings.Count - 1 do
  begin
    mapping := AInstructions.ColumnMappings[i];

    // Обработка константных значений
    if mapping.IsConstant then
    begin
      AValues[i] := mapping.DefaultValue;
      Continue;
    end;

    // Получаем значение из примитива
    rawValue := ASourceProvider.GetPropertyValue(AEntity, mapping.SourceParam);

    // Валидируем и преобразуем тип
    if not FValidator.ValidateAndConvert(
      rawValue,
      mapping.DataType,
      convertedValue
    ) then
    begin
      programlog.LogOutFormatStr(
        'uzvaccess: Ошибка валидации значения для колонки "%s"',
        [mapping.ColumnName],
        LM_Info
      );

      if FConfig.ErrorMode = emStop then
      begin
        Result := False;
        Exit;
      end;

      // В мягком режиме используем значение по умолчанию
      convertedValue := Null;
    end;

    AValues[i] := convertedValue;
  end;
end;

function TExportExecutor.ExecuteExport(
  const AExportTableName: String;
  AInstructions: TExportInstructions;
  ASourceProvider: IDataSourceProvider
): TExportTableResult;
var
  entities: TList;
  i, j: Integer;
  entity: Pointer;
  values: array of Variant;
  batchData: TList;
  inserted, updated: Integer;
  hasKeys: Boolean;
begin
  // Инициализация результата
  Result.TableName := AExportTableName;
  Result.TargetTable := AInstructions.TargetTable;
  Result.RowsProcessed := 0;
  Result.RowsInserted := 0;
  Result.RowsUpdated := 0;
  Result.ErrorCount := 0;
  Result.ErrorMessages := TStringList.Create;
  Result.Success := True;

  programlog.LogOutFormatStr(
    'uzvaccess: Начало экспорта из "%s" в "%s"',
    [AExportTableName, AInstructions.TargetTable],
    LM_Info
  );

  try
    // Получаем список примитивов
    entities := ASourceProvider.GetEntities(AInstructions.TypeData);
    try
      if entities.Count = 0 then
      begin
        programlog.LogOutFormatStr(
          'uzvaccess: Нет данных для экспорта',
          [],
          LM_Info
        );
        Exit;
      end;

      programlog.LogOutFormatStr(
        'uzvaccess: Найдено объектов для экспорта: %d',
        [entities.Count],
        LM_Info
      );

      // Подготовка массива значений
      SetLength(values, AInstructions.ColumnMappings.Count);

      // Проверяем наличие ключевых колонок
      hasKeys := AInstructions.KeyColumns.Count > 0;

      // Начинаем транзакцию
      if not FConfig.DryRun then
        FConnection.BeginTransaction;

      try
        if hasKeys then
        begin
          // Режим UPSERT (с ключевыми колонками)
          programlog.LogOutFormatStr(
            'uzvaccess: Режим UPSERT (обновление/вставка)',
            [],
            LM_Info
          );

          for i := 0 to entities.Count - 1 do
          begin
            entity := entities[i];

            // Извлекаем значения
            if not ExtractValues(entity, AInstructions, ASourceProvider, values) then
            begin
              Inc(Result.ErrorCount);
              Continue;
            end;

            Inc(Result.RowsProcessed);

            // Выполняем UPSERT
            if not FConfig.DryRun then
            begin
              if UpsertRecord(AInstructions.TargetTable, AInstructions, values) then
              begin
                // Не различаем вставку и обновление в этом режиме
                Inc(Result.RowsInserted);
              end
              else
              begin
                Inc(Result.ErrorCount);
              end;
            end;

            // Прогресс
            if (i + 1) mod 100 = 0 then
              programlog.LogOutFormatStr(
                'uzvaccess: Обработано: %d / %d',
                [i + 1, entities.Count],
                LM_Info
              );
          end;
        end
        else
        begin
          // Режим только INSERT (пакетная вставка)
          programlog.LogOutFormatStr(
            'uzvaccess: Режим INSERT (пакетная вставка)',
            [],
            LM_Info
          );

          batchData := TList.Create;
          try
            for i := 0 to entities.Count - 1 do
            begin
              entity := entities[i];

              // Извлекаем значения
              if not ExtractValues(entity, AInstructions, ASourceProvider, values) then
              begin
                Inc(Result.ErrorCount);
                Continue;
              end;

              Inc(Result.RowsProcessed);

              // Добавляем в пакет
              batchData.Add(@values);

              // Вставляем пакет при достижении размера батча
              if (batchData.Count >= FBatchSize) or (i = entities.Count - 1) then
              begin
                if not FConfig.DryRun then
                begin
                  inserted := InsertBatch(AInstructions.TargetTable,
                    AInstructions, batchData);
                  Inc(Result.RowsInserted, inserted);
                end;

                batchData.Clear;
              end;

              // Прогресс
              if (i + 1) mod 100 = 0 then
                programlog.LogOutFormatStr(
                  'uzvaccess: Обработано: %d / %d',
                  [i + 1, entities.Count],
                  LM_Info
                );
            end;
          finally
            batchData.Free;
          end;
        end;

        // Фиксируем транзакцию
        if not FConfig.DryRun then
          FConnection.CommitTransaction;

        programlog.LogOutFormatStr(
          'uzvaccess: Экспорт завершён: обработано %d, вставлено %d, ошибок %d',
          [Result.RowsProcessed, Result.RowsInserted, Result.ErrorCount],
          LM_Info
        );

      except
        on E: Exception do
        begin
          // Откатываем транзакцию
          if not FConfig.DryRun then
            FConnection.RollbackTransaction;

          programlog.LogOutFormatStr(
            'uzvaccess: Ошибка экспорта: %s',
            [E.Message],
            LM_Info
          );
          Result.ErrorMessages.Add(E.Message);
          Result.Success := False;

          if FConfig.ErrorMode = emStop then
            raise;
        end;
      end;

    finally
      entities.Free;
    end;

  except
    on E: Exception do
    begin
      programlog.LogOutFormatStr(
        'uzvaccess: Критическая ошибка экспорта: %s',
        [E.Message],
        LM_Info
      );
      Result.ErrorMessages.Add(E.Message);
      Result.Success := False;
    end;
  end;
end;

end.
