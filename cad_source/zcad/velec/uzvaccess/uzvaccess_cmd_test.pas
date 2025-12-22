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

unit uzvaccess_cmd_test;

{$INCLUDE zengineconfig.inc}

interface

uses
  SysUtils, Classes,
  uzccommandsabstract, uzcinterface, uzclog;

// Процедура тестовой команды
procedure CmdUzvAccessTest(
  pCommandParam: Pointer;
  var operationResult: TCommandResult
);

implementation

procedure CmdUzvAccessTest(
  pCommandParam: Pointer;
  var operationResult: TCommandResult
);
begin
  zcUI.TextMessage(
    'UzvAccess: Тестовая команда выполнена успешно',
    TMWOHistoryOut
  );

  programlog.LogOutFormatStr(
    'uzvaccess: Тестовая команда выполнена',
    [],
    LM_Info
  );

  operationResult := cmd_OK;
end;

end.
