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

{**Модуль реализации команды addZona для работы с зонами}
unit uzvcommand_space;

{ file def.inc is necessary to include at the beginning of each module zcad
  it contains a centralized compilation parameters settings }

{ файл def.inc необходимо включать в начале каждого модуля zcad
  он содержит в себе централизованные настройки параметров компиляции  }

{$INCLUDE zengineconfig.inc}

interface
uses
  sysutils,

  uzccommandsmanager,
  uzccommandsabstract,
  uzccommandsimpl, //Commands manager and related objects
                   //менеджер команд и объекты связанные с ним
  uzclog,          //log system
                   //система логирования
  uzcinterface;    //interface utilities
                   //утилиты интерфейса

function addSpace_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;

implementation

function addSpace_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
begin
  // Вывод сообщения о запуске команды
  // Output message about command launch
  zcUI.TextMessage('запущена команда addSpace',TMWOHistoryOut);

  result:=cmd_ok;
end;

initialization
  // Регистрация команды addSpace
  // Register the addSpace command
  CreateZCADCommand(@addSpace_com,'addSpace',CADWG,0);
end.
