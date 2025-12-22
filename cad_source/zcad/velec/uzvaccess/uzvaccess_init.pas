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

unit uzvaccess_init;

{$INCLUDE zengineconfig.inc}

interface

uses
  uzvaccess_cmd_register, uzclog;

implementation

// Инициализация модуля при загрузке
initialization
  programlog.LogOutFormatStr(
    'uzvaccess: Инициализация модуля uzvaccess',
    [],
    LM_Info
  );

  // Регистрируем команды
  RegisterUzvAccessCommands;

  programlog.LogOutFormatStr(
    'uzvaccess: Модуль uzvaccess успешно инициализирован',
    [],
    LM_Info
  );

end.
