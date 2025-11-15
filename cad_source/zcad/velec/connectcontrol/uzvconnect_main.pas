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

{**Главный модуль управления подключениями устройств}
unit uzvconnect_main;

{$INCLUDE zengineconfig.inc}

interface
uses
  SysUtils,
  Forms,
  uzccommandsmanager,
  uzccommandsabstract,
  uzccommandsimpl,
  uzbtypes,
  uzclog,
  uzcdrawings,
  uzcinterface,
  uzvconnect_struct,
  uzvconnect_dwginteraction,
  uzvconnect_form;

{**Функция команды управления подключениями устройств}
function ConnectControl_com(
  const Context: TZCADCommandContext;
  operands: TCommandOperands
): TCommandResult;

implementation

{**Вывести сообщение в историю ZCAD}
procedure PrintMessage(const Msg: String);
begin
  zcUI.TextMessage(Msg, TMWOHistoryOut);
end;

{**Вывести форматированное сообщение в историю ZCAD}
procedure PrintFormatMessage(const Fmt: String; const Args: array of const);
begin
  PrintMessage(Format(Fmt, Args));
end;

{**Проверить наличие выделенных объектов}
function HasSelectedObjects: Boolean;
begin
  Result := drawings.GetCurrentDWG^.SelObjArray.Count > 0;
end;

{**Функция команды управления подключениями устройств}
function ConnectControl_com(
  const Context: TZCADCommandContext;
  operands: TCommandOperands
): TCommandResult;
var
  connectionCount: Integer;
begin
  Result := cmd_ok;

  // Логирование старта команды
  programlog.LogOutFormatStr(
    'Запущена команда управления подключениями устройств',
    [],
    LM_Info
  );

  PrintMessage('[ConnectControl] Запуск анализа подключений...');

  // Проверка наличия выделенных объектов
  if not HasSelectedObjects then
  begin
    PrintMessage('[ConnectControl] Нет выделенных объектов.');
    PrintMessage('[ConnectControl] Выделите устройства на чертеже и повторите команду.');
    programlog.LogOutFormatStr(
      'Команда завершена: нет выделенных объектов',
      [],
      LM_Warning
    );
    Exit;
  end;

  // Сбор данных о подключениях устройств с чертежа
  programlog.LogOutFormatStr(
    'Сбор данных о подключениях устройств',
    [],
    LM_Info
  );

  try
    CollectDevicesFromDWG;

    connectionCount := ConnectList.Size;

    PrintFormatMessage(
      '[ConnectControl] Найдено подключений: %d',
      [connectionCount]
    );

    // Проверка наличия данных
    if connectionCount = 0 then
    begin
      PrintMessage('[ConnectControl] Не найдено подключений для отображения.');
      PrintMessage('[ConnectControl] Убедитесь, что выделенные устройства имеют параметры подключений.');
      programlog.LogOutFormatStr(
        'Команда завершена: не найдено подключений',
        [],
        LM_Warning
      );
      Exit;
    end;

    // Открытие формы с данными подключений
    programlog.LogOutFormatStr(
      'Открытие формы управления подключениями',
      [],
      LM_Info
    );

    try
      with TfrmConnectControl.Create(Application) do
      try
        // Загрузка данных в форму
        LoadConnectionsData;

        // Показ формы модально
        ShowModal;

        programlog.LogOutFormatStr(
          'Форма управления подключениями закрыта пользователем',
          [],
          LM_Info
        );
      finally
        // Освобождение формы
        Free;
      end;
    except
      on E: Exception do
      begin
        PrintFormatMessage(
          '[ConnectControl] Ошибка при работе с формой: %s',
          [E.Message]
        );
        programlog.LogOutFormatStr(
          'Ошибка при работе с формой: %s',
          [E.Message],
          LM_Error
        );
        Result := cmd_error;
      end;
    end;

  except
    on E: Exception do
    begin
      PrintFormatMessage(
        '[ConnectControl] Ошибка при сборе данных: %s',
        [E.Message]
      );
      programlog.LogOutFormatStr(
        'Ошибка при сборе данных: %s',
        [E.Message],
        LM_Error
      );
      Result := cmd_error;
    end;
  end;

  programlog.LogOutFormatStr(
    'Команда управления подключениями устройств завершена',
    [],
    LM_Info
  );
end;

initialization
  // Регистрация команды connectcontrol
  CreateZCADCommand(@ConnectControl_com, 'connectcontrol', CADWG, 0);

end.
