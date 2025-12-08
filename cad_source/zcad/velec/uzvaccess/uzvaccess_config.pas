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

unit uzvaccess_config;

{$INCLUDE zengineconfig.inc}

interface

uses
  SysUtils, Classes, IniFiles,
  uzvaccess_types;

const
  // Значения по умолчанию
  DEFAULT_BATCH_SIZE = 50;
  DEFAULT_RETRY_ATTEMPTS = 3;
  DEFAULT_RETRY_DELAY = 1000; // мс
  DEFAULT_ERROR_MODE = emContinue;
  DEFAULT_LOG_LEVEL = llInfo;
  DEFAULT_STRICT_VALIDATION = False;
  DEFAULT_ALLOW_NULL = True;
  DEFAULT_DRY_RUN = False;

type
  {**
    Класс конфигурации модуля экспорта в Access

    Содержит все настройки для управления процессом экспорта,
    включая параметры подключения, поведение при ошибках,
    настройки логирования и производительности
  **}
  TExportConfig = class
  private
    FConnectionString: String;
    FDatabasePath: String;
    FDriver: String;
    FDryRun: Boolean;
    FStrictValidation: Boolean;
    FAllowNullValues: Boolean;
    FErrorMode: TErrorMode;
    FBatchSize: Integer;
    FRetryAttempts: Integer;
    FRetryDelay: Integer;
    FLogLevel: TLogLevel;
    FLogFilePath: String;
    FLogToGUI: Boolean;
    FEntityMode: Integer;
    FEntityModeParam: String;
  public
    constructor Create;

    // Загрузить конфигурацию из INI-файла
    procedure LoadFromFile(const AFileName: String);

    // Сохранить конфигурацию в INI-файл
    procedure SaveToFile(const AFileName: String);

    // Валидация конфигурации
    function Validate(out AErrors: TStringList): Boolean;

    // Получить строку подключения ODBC
    function GetODBCConnectionString: String;

    // Свойства подключения
    property ConnectionString: String read FConnectionString
      write FConnectionString;
    property DatabasePath: String read FDatabasePath write FDatabasePath;
    property Driver: String read FDriver write FDriver;

    // Свойства поведения
    property DryRun: Boolean read FDryRun write FDryRun;
    property StrictValidation: Boolean read FStrictValidation
      write FStrictValidation;
    property AllowNullValues: Boolean read FAllowNullValues
      write FAllowNullValues;
    property ErrorMode: TErrorMode read FErrorMode write FErrorMode;

    // Свойства производительности
    property BatchSize: Integer read FBatchSize write FBatchSize;
    property RetryAttempts: Integer read FRetryAttempts write FRetryAttempts;
    property RetryDelay: Integer read FRetryDelay write FRetryDelay;

    // Свойства логирования
    property LogLevel: TLogLevel read FLogLevel write FLogLevel;
    property LogFilePath: String read FLogFilePath write FLogFilePath;
    property LogToGUI: Boolean read FLogToGUI write FLogToGUI;

    // Свойства источника данных
    property EntityMode: Integer read FEntityMode write FEntityMode;
    property EntityModeParam: String read FEntityModeParam
      write FEntityModeParam;
  end;

implementation

{ TExportConfig }

constructor TExportConfig.Create;
begin
  // Инициализация значениями по умолчанию
  FConnectionString := '';
  FDatabasePath := '';
  FDriver := 'Microsoft Access Driver (*.mdb, *.accdb)';

  FDryRun := DEFAULT_DRY_RUN;
  FStrictValidation := DEFAULT_STRICT_VALIDATION;
  FAllowNullValues := DEFAULT_ALLOW_NULL;
  FErrorMode := DEFAULT_ERROR_MODE;

  FBatchSize := DEFAULT_BATCH_SIZE;
  FRetryAttempts := DEFAULT_RETRY_ATTEMPTS;
  FRetryDelay := DEFAULT_RETRY_DELAY;

  FLogLevel := DEFAULT_LOG_LEVEL;
  FLogFilePath := '';
  FLogToGUI := True;

  FEntityMode := 0; // По умолчанию - все примитивы
  FEntityModeParam := '';
end;

procedure TExportConfig.LoadFromFile(const AFileName: String);
var
  ini: TIniFile;
  errorModeStr: String;
  logLevelStr: String;
begin
  if not FileExists(AFileName) then
    raise Exception.CreateFmt('Файл конфигурации не найден: %s', [AFileName]);

  ini := TIniFile.Create(AFileName);
  try
    // Секция Connection
    FDatabasePath := ini.ReadString('Connection', 'DatabasePath', '');
    FDriver := ini.ReadString('Connection', 'Driver', FDriver);
    FConnectionString := ini.ReadString('Connection', 'ConnectionString', '');

    // Секция Behavior
    FDryRun := ini.ReadBool('Behavior', 'DryRun', DEFAULT_DRY_RUN);
    FStrictValidation := ini.ReadBool('Behavior', 'StrictValidation',
      DEFAULT_STRICT_VALIDATION);
    FAllowNullValues := ini.ReadBool('Behavior', 'AllowNullValues',
      DEFAULT_ALLOW_NULL);

    errorModeStr := ini.ReadString('Behavior', 'ErrorMode', 'continue');
    if LowerCase(errorModeStr) = 'stop' then
      FErrorMode := emStop
    else
      FErrorMode := emContinue;

    // Секция Performance
    FBatchSize := ini.ReadInteger('Performance', 'BatchSize',
      DEFAULT_BATCH_SIZE);
    FRetryAttempts := ini.ReadInteger('Performance', 'RetryAttempts',
      DEFAULT_RETRY_ATTEMPTS);
    FRetryDelay := ini.ReadInteger('Performance', 'RetryDelay',
      DEFAULT_RETRY_DELAY);

    // Секция Logging
    logLevelStr := ini.ReadString('Logging', 'LogLevel', 'info');
    case LowerCase(logLevelStr) of
      'debug': FLogLevel := llDebug;
      'warning': FLogLevel := llWarning;
      'error': FLogLevel := llError;
    else
      FLogLevel := llInfo;
    end;

    FLogFilePath := ini.ReadString('Logging', 'LogFilePath', '');
    FLogToGUI := ini.ReadBool('Logging', 'LogToGUI', True);

    // Секция DataSource
    FEntityMode := ini.ReadInteger('DataSource', 'EntityMode', 0);
    FEntityModeParam := ini.ReadString('DataSource', 'EntityModeParam', '');

  finally
    ini.Free;
  end;
end;

procedure TExportConfig.SaveToFile(const AFileName: String);
var
  ini: TIniFile;
  errorModeStr: String;
  logLevelStr: String;
begin
  ini := TIniFile.Create(AFileName);
  try
    // Секция Connection
    ini.WriteString('Connection', 'DatabasePath', FDatabasePath);
    ini.WriteString('Connection', 'Driver', FDriver);
    ini.WriteString('Connection', 'ConnectionString', FConnectionString);

    // Секция Behavior
    ini.WriteBool('Behavior', 'DryRun', FDryRun);
    ini.WriteBool('Behavior', 'StrictValidation', FStrictValidation);
    ini.WriteBool('Behavior', 'AllowNullValues', FAllowNullValues);

    if FErrorMode = emStop then
      errorModeStr := 'stop'
    else
      errorModeStr := 'continue';
    ini.WriteString('Behavior', 'ErrorMode', errorModeStr);

    // Секция Performance
    ini.WriteInteger('Performance', 'BatchSize', FBatchSize);
    ini.WriteInteger('Performance', 'RetryAttempts', FRetryAttempts);
    ini.WriteInteger('Performance', 'RetryDelay', FRetryDelay);

    // Секция Logging
    case FLogLevel of
      llDebug: logLevelStr := 'debug';
      llInfo: logLevelStr := 'info';
      llWarning: logLevelStr := 'warning';
      llError: logLevelStr := 'error';
    else
      logLevelStr := 'info';
    end;
    ini.WriteString('Logging', 'LogLevel', logLevelStr);
    ini.WriteString('Logging', 'LogFilePath', FLogFilePath);
    ini.WriteBool('Logging', 'LogToGUI', FLogToGUI);

    // Секция DataSource
    ini.WriteInteger('DataSource', 'EntityMode', FEntityMode);
    ini.WriteString('DataSource', 'EntityModeParam', FEntityModeParam);

  finally
    ini.Free;
  end;
end;

function TExportConfig.Validate(out AErrors: TStringList): Boolean;
begin
  AErrors := TStringList.Create;
  Result := True;

  // Проверка пути к базе данных (если не задана строка подключения)
  if (FConnectionString = '') and (FDatabasePath = '') then
  begin
    AErrors.Add('Не задан путь к базе данных или строка подключения');
    Result := False;
  end;

  // Проверка существования файла базы данных
  if (FDatabasePath <> '') and not FileExists(FDatabasePath) then
  begin
    AErrors.Add('Файл базы данных не найден: ' + FDatabasePath);
    Result := False;
  end;

  // Проверка BatchSize
  if FBatchSize <= 0 then
  begin
    AErrors.Add('BatchSize должен быть больше 0');
    Result := False;
  end;

  // Проверка RetryAttempts
  if FRetryAttempts < 0 then
  begin
    AErrors.Add('RetryAttempts не может быть отрицательным');
    Result := False;
  end;

  // Проверка RetryDelay
  if FRetryDelay < 0 then
  begin
    AErrors.Add('RetryDelay не может быть отрицательным');
    Result := False;
  end;

  // Проверка EntityMode
  if not (FEntityMode in [0, 1, 2]) then
  begin
    AErrors.Add('EntityMode должен быть 0, 1 или 2');
    Result := False;
  end;

  // Проверка EntityModeParam для режима 2
  if (FEntityMode = 2) and (FEntityModeParam = '') then
  begin
    AErrors.Add('Для EntityMode=2 требуется указать EntityModeParam');
    Result := False;
  end;
end;

function TExportConfig.GetODBCConnectionString: String;
begin
  // Если задана пользовательская строка подключения, используем её
  if FConnectionString <> '' then
  begin
    Result := FConnectionString;
    Exit;
  end;

  // Иначе формируем строку подключения из компонентов
  Result := Format('Driver={%s};Dbq=%s;', [FDriver, FDatabasePath]);
end;

end.
