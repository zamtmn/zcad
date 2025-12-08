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

unit uzvaccess_connection;

{$INCLUDE zengineconfig.inc}

interface

uses
  SysUtils, Classes, DB,
  SQLDB, odbcconn,
  uzvaccess_types, uzclog, uzvaccess_config;

type
  {**
    Класс для управления подключением к базе данных MS Access

    Обеспечивает подключение, отключение, управление транзакциями
    и выполнение запросов к базе данных Access через ODBC
  **}
  TAccessConnection = class
  private
    FConnection: TODBCConnection;
    FTransaction: TSQLTransaction;
    FQuery: TSQLQuery;
    FConfig: TExportConfig;
    FConnected: Boolean;

    // Попытка подключения с повторами
    function TryConnect: Boolean;

    // Задержка перед повторной попыткой
    procedure DelayRetry(AAttempt: Integer);

  public
    constructor Create(AConfig: TExportConfig);
    destructor Destroy; override;

    // Подключиться к базе данных
    function Connect: Boolean;

    // Отключиться от базы данных
    procedure Disconnect;

    // Начать транзакцию
    procedure BeginTransaction;

    // Зафиксировать транзакцию
    procedure CommitTransaction;

    // Откатить транзакцию
    procedure RollbackTransaction;

    // Получить список таблиц EXPORT
    function ListExportTables: TStringList;

    // Открыть таблицу для чтения
    function OpenTable(const ATableName: String): TDataSet;

    // Выполнить SQL-запрос
    procedure ExecuteSQL(const ASQL: String);

    // Получить запрос для параметризованных вставок
    function GetQuery: TSQLQuery;

    property Connected: Boolean read FConnected;
  end;

implementation

uses
  StrUtils, RegExpr;

{ TAccessConnection }

constructor TAccessConnection.Create(
  AConfig: TExportConfig
);
begin
  FConfig := AConfig;
  FConnected := False;

  // Создание компонентов подключения
  FConnection := TODBCConnection.Create(nil);
  FTransaction := TSQLTransaction.Create(nil);
  FQuery := TSQLQuery.Create(nil);

  // Настройка подключения
  FConnection.Driver := FConfig.Driver;
  FConnection.LoginPrompt := False;

  // Привязка компонентов
  FTransaction.DataBase := FConnection;
  FQuery.DataBase := FConnection;
  FQuery.Transaction := FTransaction;
end;

destructor TAccessConnection.Destroy;
begin
  Disconnect;
  FQuery.Free;
  FTransaction.Free;
  FConnection.Free;
  inherited Destroy;
end;

procedure TAccessConnection.DelayRetry(AAttempt: Integer);
var
  delay: Integer;
begin
  // Экспоненциальная задержка: delay * 2^(attempt-1)
  delay := FConfig.RetryDelay * (1 shl (AAttempt - 1));

  if delay > 10000 then
    delay := 10000; // Максимум 10 секунд

  Sleep(delay);
end;

function TAccessConnection.TryConnect: Boolean;
var
  connectionString: String;
begin
  Result := False;

  try
    // Получаем строку подключения
    connectionString := FConfig.GetODBCConnectionString;


    // Устанавливаем параметры подключения
    FConnection.Params.Clear;
    FConnection.Params.Add('Dbq=' + FConfig.DatabasePath);

    // Подключаемся
    if not FConnection.Connected then
      FConnection.Connected := True;

    FConnected := True;
    Result := True;

    programlog.LogOutFormatStr(
      'uzvaccess: Подключение к базе данных установлено',
      [],
      LM_Info
    );

  except
    on E: Exception do
    begin
      programlog.LogOutFormatStr(
        'uzvaccess: Ошибка подключения: %s',
        [E.Message],
        LM_Info
      );
      FConnected := False;
      Result := False;
    end;
  end;
end;

function TAccessConnection.Connect: Boolean;
var
  attempt: Integer;
  maxAttempts: Integer;
begin
  Result := False;

  if FConnected then
  begin
    Result := True;
    Exit;
  end;

  maxAttempts := FConfig.RetryAttempts + 1;

  for attempt := 1 to maxAttempts do
  begin
    programlog.LogOutFormatStr(
      'uzvaccess: Попытка подключения %d из %d',
      [attempt, maxAttempts],
      LM_Info
    );

    if TryConnect then
    begin
      Result := True;
      Exit;
    end;

    // Если это не последняя попытка, делаем задержку
    if attempt < maxAttempts then
      DelayRetry(attempt);
  end;

  programlog.LogOutFormatStr(
    'uzvaccess: Не удалось подключиться после всех попыток',
    [],
    LM_Info
  );
end;

procedure TAccessConnection.Disconnect;
begin
  if not FConnected then
    Exit;

  try
    if FConnection.Connected then
      FConnection.Connected := False;

    FConnected := False;
    programlog.LogOutFormatStr(
      'uzvaccess: Отключение от базы данных выполнено',
      [],
      LM_Info
    );

  except
    on E: Exception do
      programlog.LogOutFormatStr(
        'uzvaccess: Ошибка отключения: %s',
        [E.Message],
        LM_Info
      );
  end;
end;

procedure TAccessConnection.BeginTransaction;
begin
  if not FConnected then
    raise Exception.Create('Нет подключения к базе данных');

  try
    if not FTransaction.Active then
      FTransaction.StartTransaction;


  except
    on E: Exception do
    begin
      programlog.LogOutFormatStr(
        'uzvaccess: Ошибка начала транзакции: %s',
        [E.Message],
        LM_Info
      );
      raise;
    end;
  end;
end;

procedure TAccessConnection.CommitTransaction;
begin
  if not FConnected then
    raise Exception.Create('Нет подключения к базе данных');

  try
    if FTransaction.Active then
      FTransaction.Commit;


  except
    on E: Exception do
    begin
      programlog.LogOutFormatStr(
        'uzvaccess: Ошибка фиксации транзакции: %s',
        [E.Message],
        LM_Info
      );
      raise;
    end;
  end;
end;

procedure TAccessConnection.RollbackTransaction;
begin
  if not FConnected then
    Exit;

  try
    if FTransaction.Active then
      FTransaction.Rollback;


  except
    on E: Exception do
      programlog.LogOutFormatStr(
        'uzvaccess: Ошибка отката транзакции: %s',
        [E.Message],
        LM_Info
      );
  end;
end;

function TAccessConnection.ListExportTables: TStringList;
var
  tables: TStringList;
  tempQuery: TSQLQuery;
  tableName: String;
  regex: TRegExpr;
  i: Integer;
begin
  Result := TStringList.Create;

  if not FConnected then
  begin
    programlog.LogOutFormatStr(
      'uzvaccess: Нет подключения к базе данных',
      [],
      LM_Info
    );
    Exit;
  end;

  tempQuery := TSQLQuery.Create(nil);
  try
    tempQuery.DataBase := FConnection;
    tempQuery.Transaction := FTransaction;

    // Получаем список всех таблиц
    tables := TStringList.Create;
    try
      FConnection.GetTableNames(tables, False);

      // Фильтруем таблицы по шаблону EXPORT\d+
      regex := TRegExpr.Create('^EXPORT(\d+)$');
      try
        regex.ModifierI := True; // Регистронезависимый поиск

        for i := 0 to tables.Count - 1 do
        begin
          tableName := tables[i];
          if regex.Exec(tableName) then
          begin
            Result.Add(tableName);
          end;
        end;

      finally
        regex.Free;
      end;

    finally
      tables.Free;
    end;

    // Сортируем таблицы по номеру (EXPORT1, EXPORT2, ...)
    Result.CustomSort(@CompareExportTableNames);

    programlog.LogOutFormatStr(
      'uzvaccess: Найдено таблиц экспорта: %d',
      [Result.Count],
      LM_Info
    );

  finally
    tempQuery.Free;
  end;
end;

// Функция сравнения для сортировки таблиц EXPORT по номеру
function CompareExportTableNames(List: TStringList; Index1, Index2: Integer): Integer;
var
  num1, num2: Integer;
  name1, name2: String;
begin
  name1 := List[Index1];
  name2 := List[Index2];

  // Извлекаем номера
  num1 := StrToIntDef(Copy(name1, 7, Length(name1) - 6), 0);
  num2 := StrToIntDef(Copy(name2, 7, Length(name2) - 6), 0);

  Result := num1 - num2;
end;

function TAccessConnection.OpenTable(const ATableName: String): TDataSet;
var
  tempQuery: TSQLQuery;
begin
  if not FConnected then
    raise Exception.Create('Нет подключения к базе данных');

  tempQuery := TSQLQuery.Create(nil);
  tempQuery.DataBase := FConnection;
  tempQuery.Transaction := FTransaction;

  try
    tempQuery.SQL.Text := Format('SELECT * FROM [%s]', [ATableName]);
    tempQuery.Open;

    FLogger.LogDebug(Format('Таблица %s открыта, строк: %d',
      [ATableName, tempQuery.RecordCount]));

    Result := tempQuery;

  except
    on E: Exception do
    begin
      programlog.LogOutFormatStr(
        'uzvaccess: Ошибка открытия таблицы %s: %s',
        [ATableName, E.Message],
        LM_Info
      );
      tempQuery.Free;
      raise;
    end;
  end;
end;

procedure TAccessConnection.ExecuteSQL(const ASQL: String);
begin
  if not FConnected then
    raise Exception.Create('Нет подключения к базе данных');

  try
    FQuery.SQL.Text := ASQL;
    FQuery.ExecSQL;


  except
    on E: Exception do
    begin
      FLogger.LogError('Ошибка выполнения SQL: ' + E.Message);
      raise;
    end;
  end;
end;

function TAccessConnection.GetQuery: TSQLQuery;
begin
  Result := FQuery;
end;

end.
