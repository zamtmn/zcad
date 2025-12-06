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

unit uzvaccess_logger;

{$INCLUDE zengineconfig.inc}

interface

uses
  SysUtils, Classes,
  uzcLog, uzcinterface,
  uzvaccess_types;

type
  {**
    Класс для логирования процесса экспорта

    Обеспечивает запись сообщений в файл и вывод в GUI ZCAD
  **}
  TExportLogger = class
  private
    FLogFile: TextFile;
    FLogFilePath: String;
    FLogLevel: TLogLevel;
    FLogToGUI: Boolean;
    FLogFileOpened: Boolean;

    // Открыть файл лога
    procedure OpenLogFile;

    // Закрыть файл лога
    procedure CloseLogFile;

    // Форматировать сообщение лога
    function FormatMessage(
      ALevel: TLogLevel;
      const AMessage: String
    ): String;

    // Записать строку в файл
    procedure WriteToFile(const AMessage: String);

    // Вывести сообщение в GUI
    procedure WriteToGUI(const AMessage: String);

    // Вывести сообщение в programlog
    procedure WriteToProgramLog(ALevel: TLogLevel; const AMessage: String);

  public
    constructor Create(
      const ALogFilePath: String;
      ALevel: TLogLevel;
      ALogToGUI: Boolean
    );
    destructor Destroy; override;

    // Основной метод логирования
    procedure Log(ALevel: TLogLevel; const AMessage: String); overload;
    procedure Log(
      ALevel: TLogLevel;
      const AFormat: String;
      const AArgs: array of const
    ); overload;

    // Методы для различных уровней логирования
    procedure LogDebug(const AMessage: String);
    procedure LogInfo(const AMessage: String);
    procedure LogWarning(const AMessage: String);
    procedure LogError(const AMessage: String);

    property LogLevel: TLogLevel read FLogLevel write FLogLevel;
    property LogToGUI: Boolean read FLogToGUI write FLogToGUI;
  end;

implementation

{ TExportLogger }

constructor TExportLogger.Create(
  const ALogFilePath: String;
  ALevel: TLogLevel;
  ALogToGUI: Boolean
);
begin
  FLogFilePath := ALogFilePath;
  FLogLevel := ALevel;
  FLogToGUI := ALogToGUI;
  FLogFileOpened := False;

  if FLogFilePath <> '' then
    OpenLogFile;
end;

destructor TExportLogger.Destroy;
begin
  CloseLogFile;
  inherited Destroy;
end;

procedure TExportLogger.OpenLogFile;
begin
  if FLogFileOpened then
    Exit;

  try
    AssignFile(FLogFile, FLogFilePath);
    if FileExists(FLogFilePath) then
      Append(FLogFile)
    else
      Rewrite(FLogFile);

    FLogFileOpened := True;

    // Записываем заголовок сессии
    WriteToFile('');
    WriteToFile(StringOfChar('=', 70));
    WriteToFile(Format('Начало сессии экспорта: %s',
      [FormatDateTime('yyyy-mm-dd hh:nn:ss', Now)]));
    WriteToFile(StringOfChar('=', 70));

  except
    on E: Exception do
    begin
      FLogFileOpened := False;
      // Выводим ошибку в programlog
      programlog.LogOutFormatStr(
        'uzvaccess: Не удалось открыть файл лога: %s',
        [E.Message],
        LM_Error
      );
    end;
  end;
end;

procedure TExportLogger.CloseLogFile;
begin
  if not FLogFileOpened then
    Exit;

  try
    // Записываем завершение сессии
    WriteToFile(StringOfChar('=', 70));
    WriteToFile(Format('Завершение сессии: %s',
      [FormatDateTime('yyyy-mm-dd hh:nn:ss', Now)]));
    WriteToFile(StringOfChar('=', 70));
    WriteToFile('');

    CloseFile(FLogFile);
    FLogFileOpened := False;

  except
    on E: Exception do
      programlog.LogOutFormatStr(
        'uzvaccess: Ошибка закрытия файла лога: %s',
        [E.Message],
        LM_Error
      );
  end;
end;

function TExportLogger.FormatMessage(
  ALevel: TLogLevel;
  const AMessage: String
): String;
var
  levelStr: String;
  timestamp: String;
begin
  // Форматирование временной метки
  timestamp := FormatDateTime('yyyy-mm-dd hh:nn:ss', Now);

  // Определение строки уровня
  case ALevel of
    llDebug: levelStr := 'DEBUG';
    llInfo: levelStr := 'INFO';
    llWarning: levelStr := 'WARNING';
    llError: levelStr := 'ERROR';
  else
    levelStr := 'UNKNOWN';
  end;

  Result := Format('[%s] [%s] %s', [timestamp, levelStr, AMessage]);
end;

procedure TExportLogger.WriteToFile(const AMessage: String);
begin
  if not FLogFileOpened then
    Exit;

  try
    WriteLn(FLogFile, AMessage);
    Flush(FLogFile);
  except
    on E: Exception do
      programlog.LogOutFormatStr(
        'uzvaccess: Ошибка записи в лог-файл: %s',
        [E.Message],
        LM_Error
      );
  end;
end;

procedure TExportLogger.WriteToGUI(const AMessage: String);
begin
  try
    zcUI.TextMessage(AMessage, TMWOHistoryOut);
  except
    on E: Exception do
      programlog.LogOutFormatStr(
        'uzvaccess: Ошибка вывода в GUI: %s',
        [E.Message],
        LM_Error
      );
  end;
end;

procedure TExportLogger.WriteToProgramLog(
  ALevel: TLogLevel;
  const AMessage: String
);
var
  logMode: TLogMode;
begin
  case ALevel of
    llDebug: logMode := LM_Debug;
    llInfo: logMode := LM_Info;
    llWarning: logMode := LM_Warning;
    llError: logMode := LM_Error;
  else
    logMode := LM_Info;
  end;

  programlog.LogOutFormatStr('uzvaccess: %s', [AMessage], logMode);
end;

procedure TExportLogger.Log(ALevel: TLogLevel; const AMessage: String);
var
  formattedMsg: String;
begin
  // Проверяем уровень логирования
  if ALevel < FLogLevel then
    Exit;

  formattedMsg := FormatMessage(ALevel, AMessage);

  // Записываем в файл
  if FLogFileOpened then
    WriteToFile(formattedMsg);

  // Выводим в GUI
  if FLogToGUI then
    WriteToGUI(AMessage);

  // Выводим в programlog
  WriteToProgramLog(ALevel, AMessage);
end;

procedure TExportLogger.Log(
  ALevel: TLogLevel;
  const AFormat: String;
  const AArgs: array of const
);
begin
  Log(ALevel, Format(AFormat, AArgs));
end;

procedure TExportLogger.LogDebug(const AMessage: String);
begin
  Log(llDebug, AMessage);
end;

procedure TExportLogger.LogInfo(const AMessage: String);
begin
  Log(llInfo, AMessage);
end;

procedure TExportLogger.LogWarning(const AMessage: String);
begin
  Log(llWarning, AMessage);
end;

procedure TExportLogger.LogError(const AMessage: String);
begin
  Log(llError, AMessage);
end;

end.
