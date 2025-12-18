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
@author(Andrey Zubarev <zamtmn@yandex.ru>) 
}

unit uzcLog;
{$INCLUDE zengineconfig.inc}
{$mode objfpc}{$H+}

interface

uses
  sysutils,
  uzbLogTypes,uzblog;

var
//LM_Trace,     //уже определен в uzbLog.TLog // — вывод всего подряд. На тот случай, если Debug не позволяет локализовать ошибку.
  LM_Debug,     // — журналирование моментов вызова «крупных» операций.
  LM_Info,      // — разовые операции, которые повторяются крайне редко, но не регулярно. (загрузка конфига, плагина, запуск бэкапа)
  LM_Warning,   // — неожиданные параметры вызова, странный формат запроса, использование дефолтных значений в замен не корректных. Вообще все, что может свидетельствовать о не штатном использовании.
  LM_Error,     // — повод для внимания разработчиков. Тут интересно окружение конкретного места ошибки.
  LM_Fatal,     // — тут и так понятно. Выводим все до чего дотянуться можем, так как дальше приложение работать не будет.
  LM_Necessarily// — Вывод в любом случае
  :TLogLevel;

  MO_SM,MO_SH:TMsgOpt;


  ProgramLog:TLog;
  UnitsInitializeLMId,UnitsFinalizeLMId:TModuleDesk;

implementation


initialization
  ProgramLog.init; //эти значения теперь по дефолту ('LM_Trace','T');

  LM_Debug:=ProgramLog.RegisterLogLevel('LM_Debug','D',LLTInfo);
  LM_Info:=ProgramLog.RegisterLogLevel('LM_Info','I',LLTInfo);
  LM_Warning:=ProgramLog.RegisterLogLevel('LM_Warning','W',LLTWarning);
  LM_Error:=ProgramLog.RegisterLogLevel('LM_Error','E',LLTError);
  LM_Fatal:=ProgramLog.RegisterLogLevel('LM_Fatal','F',LLTError);
  LM_Necessarily:=ProgramLog.RegisterLogLevel('LM_Necessarily','N',LLTNecessarily);

  MO_SM:=MsgOpt.GetEnum;
  MO_SH:=MsgOpt.GetEnum;
  ProgramLog.addMsgOptAlias('M',MO_SM);
  ProgramLog.addMsgOptAlias('H',MO_SH);

  ProgramLog.SetDefaultLogLevel(LM_Debug);
  ProgramLog.SetCurrentLogLevel(LM_Info);
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
  ProgramLog.done;
end.

