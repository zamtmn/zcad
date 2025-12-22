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
  uzvaccess_types, uzclog, uzvaccess_config,
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
    FConnection: TAccessConnection;
    FParser: TExportTableParser;
    FValidator: TTypeValidator;
    FExecutor: TExportExecutor;
    FSourceProvider: TEntitySourceProvider;
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
  end;

implementation

{ TAccessExporter }

constructor TAccessExporter.Create(AConfig: TExportConfig);
begin
  FConfig := AConfig;
  FInitialized := False;

  programlog.LogOutFormatStr(
    'uzvaccess: TAccessExporter создан',
    [],
    LM_Info
  );
end;

destructor TAccessExporter.Destroy;
begin
  Finalize;
  programlog.LogOutFormatStr(
    'uzvaccess: TAccessExporter уничтожен',
    [],
    LM_Info
  );
  inherited Destroy;
end;

procedure TAccessExporter.Initialize;
begin
  if FInitialized then
    Exit;

  programlog.LogOutFormatStr(
    'uzvaccess: Инициализация компонентов экспортера',
    [],
    LM_Info
  );

  try
    // Создаём подключение
    FConnection := TAccessConnection.Create(FConfig);

    // Создаём парсер
    FParser := TExportTableParser.Create;

    // Создаём валидатор
    FValidator := TTypeValidator.Create(
      FConfig.StrictValidation,
      FConfig.AllowNullValues
    );

    // Создаём исполнителя
    FExecutor := TExportExecutor.Create(
      FConnection,
      FValidator,
      FConfig
    );

    // Создаём провайдер источника данных
    FSourceProvider := TEntitySourceProvider.Create(
      FConfig.EntityMode,
      FConfig.EntityModeParam
    );

    FInitialized := True;
    programlog.LogOutFormatStr(
      'uzvaccess: Инициализация завершена успешно',
      [],
      LM_Info
    );

  except
    on E: Exception do
    begin
      programlog.LogOutFormatStr(
        'uzvaccess: Ошибка инициализации: %s',
        [E.Message],
        LM_Info
      );
      Finalize;
      raise;
    end;
  end;
end;

procedure TAccessExporter.Finalize;
begin
  if not FInitialized then
    Exit;

  programlog.LogOutFormatStr(
    'uzvaccess: Освобождение компонентов экспортера',
    [],
    LM_Info
  );

  // Освобождаем в обратном порядке
  if FSourceProvider <> nil then
  begin
    FSourceProvider.Free;
    FSourceProvider := nil;
  end;

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
  programlog.LogOutFormatStr(
    'uzvaccess: Валидация конфигурации',
    [],
    LM_Info
  );

  Result := FConfig.Validate(AErrors);

  if not Result then
  begin
    programlog.LogOutFormatStr(
      'uzvaccess: Конфигурация содержит ошибки: %s',
      [AErrors.Text],
      LM_Info
    );
  end
  else
  begin
    programlog.LogOutFormatStr(
      'uzvaccess: Конфигурация валидна',
      [],
      LM_Info
    );
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
  programlog.LogOutFormatStr(
    'uzvaccess: %s',
    [StringOfChar('=', 70)],
    LM_Info
  );
  programlog.LogOutFormatStr(
    'uzvaccess: Обработка таблицы: %s',
    [ATableName],
    LM_Info
  );
  programlog.LogOutFormatStr(
    'uzvaccess: %s',
    [StringOfChar('=', 70)],
    LM_Info
  );

  dataset := nil;
  instructions := nil;

  try
    // Открываем управляющую таблицу EXPORT
    dataset := FConnection.OpenTable(ATableName);

    try
      // Парсим инструкции
      instructions := FParser.Parse(ATableName, dataset);

      try
        programlog.LogOutFormatStr(
          'uzvaccess: Целевая таблица: %s, Тип данных: %s, Маппингов: %d',
          [instructions.TargetTable,
           SourceDataTypeToString(instructions.TypeData),
           instructions.ColumnMappings.Size],
          LM_Info
        );

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
      programlog.LogOutFormatStr(
        'uzvaccess: Ошибка обработки таблицы %s: %s',
        [ATableName, E.Message],
        LM_Info
      );

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

  programlog.LogOutFormatStr(
    'uzvaccess: %s',
    [StringOfChar('=', 70)],
    LM_Info
  );
  programlog.LogOutFormatStr(
    'uzvaccess: Начало выполнения экспорта в MS Access',
    [],
    LM_Info
  );
  programlog.LogOutFormatStr(
    'uzvaccess: %s',
    [StringOfChar('=', 70)],
    LM_Info
  );

  try
    // Валидация конфигурации
    if not ValidateConfiguration(errors) then
    begin
      programlog.LogOutFormatStr(
        'uzvaccess: Ошибки конфигурации, экспорт прерван',
        [],
        LM_Info
      );
      errors.Free;
      Exit;
    end;

    errors.Free;

    // Установка пути к базе данных из параметра
    if AAccessFile <> '' then
    begin
      FConfig.DatabasePath := AAccessFile;
      programlog.LogOutFormatStr(
        'uzvaccess: Использован файл базы: %s',
        [AAccessFile],
        LM_Info
      );
    end;

    // Проверка пути к базе данных
    if not FileExists(FConfig.DatabasePath) then
    begin
      programlog.LogOutFormatStr(
        'uzvaccess: Файл базы данных не найден: %s',
        [FConfig.DatabasePath],
        LM_Info
      );
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
      programlog.LogOutFormatStr(
        'uzvaccess: Не удалось подключиться к базе данных',
        [],
        LM_Info
      );
      raise Exception.Create('Не удалось подключиться к базе данных');
    end;

    try
      // Получаем список EXPORT-таблиц
      exportTables := FConnection.ListExportTables;
      try
        if exportTables.Count = 0 then
        begin
          programlog.LogOutFormatStr(
            'uzvaccess: В базе данных не найдено таблиц экспорта (EXPORT1, EXPORT2, ...)',
            [],
            LM_Info
          );
          Exit;
        end;

        programlog.LogOutFormatStr(
          'uzvaccess: Найдено таблиц экспорта: %d',
          [exportTables.Count],
          LM_Info
        );

        // Обрабатываем каждую EXPORT-таблицу
        for i := 0 to exportTables.Count - 1 do
        begin
          programlog.LogOutFormatStr(
            'uzvaccess: Обработка таблицы %d из %d',
            [i + 1, exportTables.Count],
            LM_Info
          );

          // Обработка таблицы
          tableResult := ProcessExportTable(exportTables[i]);

          // Добавляем результат
          Result.AddTableResult(tableResult);

          // В режиме остановки при ошибке прерываем обработку
          if (not tableResult.Success) and
             (FConfig.ErrorMode = emStop) then
          begin
            programlog.LogOutFormatStr(
              'uzvaccess: Остановка обработки из-за ошибки',
              [],
              LM_Info
            );
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
      programlog.LogOutFormatStr(
        'uzvaccess: Критическая ошибка выполнения экспорта: %s',
        [E.Message],
        LM_Info
      );
      raise;
    end;
  end;

  Result.EndTime := Now;

  programlog.LogOutFormatStr(
    'uzvaccess: %s',
    [StringOfChar('=', 70)],
    LM_Info
  );
  programlog.LogOutFormatStr(
    'uzvaccess: Экспорт завершён',
    [],
    LM_Info
  );
  programlog.LogOutFormatStr(
    'uzvaccess: %s',
    [StringOfChar('=', 70)],
    LM_Info
  );
  programlog.LogOutFormatStr(
    'uzvaccess: %s',
    [Result.GetSummary],
    LM_Info
  );
end;

end.
