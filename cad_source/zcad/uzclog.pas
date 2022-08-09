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
  sysutils,LazUTF8,
  uzbLogTypes,uzblog;

const
  {$IFDEF LINUX}filelog='../../log/zcad_linux.log';{$ENDIF}
  {$IFDEF WINDOWS}filelog='../../log/zcad_windows.log';{$ENDIF}
  {$IFDEF DARWIN}filelog='../../log/zcad_darwin.log';{$ENDIF}
  lp_IncPos=uzblog.lp_IncPos;
  lp_DecPos=uzblog.lp_DecPos;
  lp_OldPos=uzblog.lp_OldPos;

var
//LM_Trace,     //уже определен в uzbLog.tlog // — вывод всего подряд. На тот случай, если Debug не позволяет локализовать ошибку.
  LM_Debug,     // — журналирование моментов вызова «крупных» операций.
  LM_Info,      // — разовые операции, которые повторяются крайне редко, но не регулярно. (загрузка конфига, плагина, запуск бэкапа)
  LM_Warning,   // — неожиданные параметры вызова, странный формат запроса, использование дефолтных значений в замен не корректных. Вообще все, что может свидетельствовать о не штатном использовании.
  LM_Error,     // — повод для внимания разработчиков. Тут интересно окружение конкретного места ошибки.
  LM_Fatal,     // — тут и так понятно. Выводим все до чего дотянуться можем, так как дальше приложение работать не будет.
  LM_Necessarily// — Вывод в любом случае
  :TLogLevel;

  ProgramLog:tlog;
  UnitsInitializeLMId,UnitsFinalizeLMId:TModuleDesk;
  FileLogBackend:TLogerFileBackend;

implementation

initialization

  ProgramLog.init; //эти значения теперь по дефолту ('LM_Trace','T');

  LM_Debug:=ProgramLog.RegisterLogLevel('LM_Debug','D',LLD(LLTInfo));
  LM_Info:=ProgramLog.RegisterLogLevel('LM_Info','I',LLD(LLTInfo));
  LM_Warning:=ProgramLog.RegisterLogLevel('LM_Warning','W',LLD(LLTWarning));
  LM_Error:=ProgramLog.RegisterLogLevel('LM_Error','E',LLD(LLTError));
  LM_Fatal:=ProgramLog.RegisterLogLevel('LM_Fatal','F',LLD(LLTError));
  LM_Necessarily:=ProgramLog.RegisterLogLevel('LM_Necessarily','N',LLD(LLTInfo));

  ProgramLog.SetDefaultLogLevel(LM_Debug);
  ProgramLog.SetCurrentLogLevel(LM_Info);

  UnitsInitializeLMId:=ProgramLog.RegisterModule('UnitsInitialization');
  UnitsFinalizeLMId:=ProgramLog.RegisterModule('UnitsFinalization');


  FileLogBackend.init(SysToUTF8(ExtractFilePath(paramstr(0)))+filelog);
  ProgramLog.addBackend(FileLogBackend);
  ProgramLog.LogStart;
  programlog.LogOutFormatStr('Unit "%s" initialization finish, log created',[{$INCLUDE %FILE%}],lp_OldPos,LM_Info,UnitsInitializeLMId);

finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],lp_OldPos,LM_Info,UnitsFinalizeLMId);
  ProgramLog.LogEnd;
  ProgramLog.done;
  FileLogBackend.done;

end.

