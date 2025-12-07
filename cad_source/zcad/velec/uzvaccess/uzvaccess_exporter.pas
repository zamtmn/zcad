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

unit uzvaccess_exporter;

{$INCLUDE zengineconfig.inc}

interface

uses
  SysUtils, Classes, DB,
  uzvaccess_types, uzvaccess_logger, uzvaccess_config,
  uzvaccess_connection, uzvaccess_parser, uzvaccess_validator,
  uzvaccess_executor, uzvaccess_source_provider;

type
  {**
    Главный класс модуля экспорта в MS Access

    Координирует работу всех компонентов:
    - Подключение к базе данных
    - Парсинг управляющих таблиц EXPORT
    - Получение данных из примитивов
    - Выполнение экспорта с валидацией
  **}
  TAccessExporter = class
  private
    FConfig: TExportConfig;
    FLogger: TExportLogger;
    FConnection: TAccessConnection;
    FParser: TExportTableParser;
    FValidator: TTypeValidator;
    FExecutor: TExportExecutor;
    FSourceProvider: IDataSourceProvider;
    FInitialized: Boolean;

    // Инициализация всех компонентов
    procedure Initialize;

    // Освобождение компонентов
    procedure Finalize;

    // Обработка одной EXPORT-таблицы
    function ProcessExportTable(
      const ATableName: String
    ): TExportTableResult;

  public
    constructor Create(AConfig: TExportConfig);
    destructor Destroy; override;

    // Главный метод выполнения экспорта
    function Execute(const AAccessFile: String = ''): TExportResult;

    // Валидация конфигурации
    function ValidateConfiguration(out AErrors: TStringList): Boolean;

    // Получить список EXPORT-таблиц из базы
    function GetExportTables: TStringList;

    property Config: TExportConfig read FConfig;
    property Logger: TExportLogger read FLogger;
  end;

implementation

{ TAccessExporter }

constructor TAccessExporter.Create(AConfig: TExportConfig);
begin
  FConfig := AConfig;
  FInitialized := False;

  // Создаём логгер
  FLogger := TExportLogger.Create(
    FConfig.LogFilePath,
    FConfig.LogLevel,
    FConfig.LogToGUI
  );

  FLogger.LogInfo('TAccessExporter создан');
end;

destructor TAccessExporter.Destroy;
begin
  Finalize;
  FLogger.LogInfo('TAccessExporter уничтожен');
  FLogger.Free;
  inherited Destroy;
end;

procedure TAccessExporter.Initialize;
begin
  if FInitialized then
    Exit;

  FLogger.LogInfo('Инициализация компонентов экспортера');

  try
    // Создаём подключение
    FConnection := TAccessConnection.Create(FConfig, FLogger);

    // Создаём парсер
    FParser := TExportTableParser.Create(FLogger);

    // Создаём валидатор
    FValidator := TTypeValidator.Create(
      FLogger,
      FConfig.StrictValidation,
      FConfig.AllowNullValues
    );

    // Создаём исполнителя
    FExecutor := TExportExecutor.Create(
      FConnection,
      FLogger,
      FValidator,
      FConfig
    );

    // Создаём провайдер источника данных
    FSourceProvider := TEntitySourceProvider.Create(
      FLogger,
      FConfig.EntityMode,
      FConfig.EntityModeParam
    );

    FInitialized := True;
    FLogger.LogInfo('Инициализация завершена успешно');

  except
    on E: Exception do
    begin
      FLogger.LogError('Ошибка инициализации: ' + E.Message);
      Finalize;
      raise;
    end;
  end;
end;

procedure TAccessExporter.Finalize;
begin
  if not FInitialized then
    Exit;

  FLogger.LogInfo('Освобождение компонентов экспортера');

  // Освобождаем в обратном порядке
  FSourceProvider := nil;

  if FExecutor <> nil then
  begin
    FExecutor.Free;
    FExecutor := nil;
  end;

  if FValidator <> nil then
  begin
    FValidator.Free;
    FValidator := nil;
  end;

  if FParser <> nil then
  begin
    FParser.Free;
    FParser := nil;
  end;

  if FConnection <> nil then
  begin
    FConnection.Free;
    FConnection := nil;
  end;

  FInitialized := False;
end;

function TAccessExporter.ValidateConfiguration(
  out AErrors: TStringList
): Boolean;
begin
  FLogger.LogInfo('Валидация конфигурации');

  Result := FConfig.Validate(AErrors);

  if not Result then
  begin
    FLogger.LogError('Конфигурация содержит ошибки:');
    FLogger.LogError(AErrors.Text);
  end
  else
  begin
    FLogger.LogInfo('Конфигурация валидна');
  end;
end;

function TAccessExporter.GetExportTables: TStringList;
begin
  Initialize;

  if not FConnection.Connect then
    raise Exception.Create('Не удалось подключиться к базе данных');

  Result := FConnection.ListExportTables;
end;

function TAccessExporter.ProcessExportTable(
  const ATableName: String
): TExportTableResult;
var
  dataset: TDataSet;
  instructions: TExportInstructions;
begin
  FLogger.LogInfo(StringOfChar('=', 70));
  FLogger.LogInfo(Format('Обработка таблицы: %s', [ATableName]));
  FLogger.LogInfo(StringOfChar('=', 70));

  dataset := nil;
  instructions := nil;

  try
    // Открываем управляющую таблицу EXPORT
    dataset := FConnection.OpenTable(ATableName);

    try
      // Парсим инструкции
      instructions := FParser.Parse(ATableName, dataset);

      try
        FLogger.LogInfo(Format(
          'Целевая таблица: %s, Тип данных: %s, Маппингов: %d',
          [instructions.TargetTable,
           SourceDataTypeToString(instructions.TypeData),
           instructions.ColumnMappings.Count]
        ));

        // Выполняем экспорт
        Result := FExecutor.ExecuteExport(
          ATableName,
          instructions,
          FSourceProvider
        );

      finally
        instructions.Free;
      end;

    finally
      dataset.Free;
    end;

  except
    on E: Exception do
    begin
      FLogger.LogError(Format(
        'Ошибка обработки таблицы %s: %s',
        [ATableName, E.Message]
      ));

      // Инициализируем результат с ошибкой
      Result.TableName := ATableName;
      Result.TargetTable := '';
      Result.RowsProcessed := 0;
      Result.RowsInserted := 0;
      Result.RowsUpdated := 0;
      Result.ErrorCount := 1;
      Result.ErrorMessages := TStringList.Create;
      Result.ErrorMessages.Add(E.Message);
      Result.Success := False;

      if FConfig.ErrorMode = emStop then
        raise;
    end;
  end;
end;

function TAccessExporter.Execute(const AAccessFile: String): TExportResult;
var
  exportTables: TStringList;
  i: Integer;
  tableResult: TExportTableResult;
  errors: TStringList;
begin
  Result := TExportResult.Create;
  Result.StartTime := Now;

  FLogger.LogInfo(StringOfChar('=', 70));
  FLogger.LogInfo('Начало выполнения экспорта в MS Access');
  FLogger.LogInfo(StringOfChar('=', 70));

  try
    // Валидация конфигурации
    if not ValidateConfiguration(errors) then
    begin
      FLogger.LogError('Ошибки конфигурации, экспорт прерван');
      errors.Free;
      Exit;
    end;

    errors.Free;

    // Установка пути к базе данных из параметра
    if AAccessFile <> '' then
    begin
      FConfig.DatabasePath := AAccessFile;
      FLogger.LogInfo('Использован файл базы: ' + AAccessFile);
    end;

    // Проверка пути к базе данных
    if not FileExists(FConfig.DatabasePath) then
    begin
      FLogger.LogError('Файл базы данных не найден: ' + FConfig.DatabasePath);
      raise Exception.CreateFmt(
        'Файл базы данных не найден: %s',
        [FConfig.DatabasePath]
      );
    end;

    // Инициализация компонентов
    Initialize;

    // Подключение к базе данных
    if not FConnection.Connect then
    begin
      FLogger.LogError('Не удалось подключиться к базе данных');
      raise Exception.Create('Не удалось подключиться к базе данных');
    end;

    try
      // Получаем список EXPORT-таблиц
      exportTables := FConnection.ListExportTables;
      try
        if exportTables.Count = 0 then
        begin
          FLogger.LogWarning(
            'В базе данных не найдено таблиц экспорта (EXPORT1, EXPORT2, ...)'
          );
          Exit;
        end;

        FLogger.LogInfo(Format(
          'Найдено таблиц экспорта: %d',
          [exportTables.Count]
        ));

        // Обрабатываем каждую EXPORT-таблицу
        for i := 0 to exportTables.Count - 1 do
        begin
          FLogger.LogInfo('');
          FLogger.LogInfo(Format(
            'Обработка таблицы %d из %d',
            [i + 1, exportTables.Count]
          ));

          // Обработка таблицы
          tableResult := ProcessExportTable(exportTables[i]);

          // Добавляем результат
          Result.AddTableResult(tableResult);

          // В режиме остановки при ошибке прерываем обработку
          if (not tableResult.Success) and
             (FConfig.ErrorMode = emStop) then
          begin
            FLogger.LogError('Остановка обработки из-за ошибки');
            Break;
          end;
        end;

      finally
        exportTables.Free;
      end;

    finally
      FConnection.Disconnect;
    end;

  except
    on E: Exception do
    begin
      FLogger.LogError('Критическая ошибка выполнения экспорта: ' + E.Message);
      raise;
    end;
  end;

  Result.EndTime := Now;

  FLogger.LogInfo('');
  FLogger.LogInfo(StringOfChar('=', 70));
  FLogger.LogInfo('Экспорт завершён');
  FLogger.LogInfo(StringOfChar('=', 70));
  FLogger.LogInfo(Result.GetSummary);
end;

end.
