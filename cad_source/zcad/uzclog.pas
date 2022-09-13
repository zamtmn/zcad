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
  uzbLogTypes,uzblog,uzbLogDecorators,uzbLogFileBackend,
  uzbCommandLineParser,uzcCommandLineParser;

const
  {$IFDEF LINUX}filelog='../../log/zcad_linux.log';{$ENDIF}
  {$IFDEF WINDOWS}filelog='../../log/zcad_windows.log';{$ENDIF}
  {$IFDEF DARWIN}filelog='../../log/zcad_darwin.log';{$ENDIF}

var
//LM_Trace,     //уже определен в uzbLog.TLog // — вывод всего подряд. На тот случай, если Debug не позволяет локализовать ошибку.
  LM_Debug,     // — журналирование моментов вызова «крупных» операций.
  LM_Info,      // — разовые операции, которые повторяются крайне редко, но не регулярно. (загрузка конфига, плагина, запуск бэкапа)
  LM_Warning,   // — неожиданные параметры вызова, странный формат запроса, использование дефолтных значений в замен не корректных. Вообще все, что может свидетельствовать о не штатном использовании.
  LM_Error,     // — повод для внимания разработчиков. Тут интересно окружение конкретного места ошибки.
  LM_Fatal,     // — тут и так понятно. Выводим все до чего дотянуться можем, так как дальше приложение работать не будет.
  LM_Necessarily// — Вывод в любом случае
  :TLogLevel;


  ProgramLog:TLog;
  UnitsInitializeLMId,UnitsFinalizeLMId:TModuleDesk;

implementation

var
   FileLogBackend:TLogFileBackend;
   TimeDecorator:TTimeDecorator;
   PositionDecorator:TPositionDecorator;
   i:integer;
   mn:TCLStringType;
   ll:TLogLevel;
   LogFileName:string;


initialization
  ProgramLog.init; //эти значения теперь по дефолту ('LM_Trace','T');

  LM_Debug:=ProgramLog.RegisterLogLevel('LM_Debug','D',LLTInfo);
  LM_Info:=ProgramLog.RegisterLogLevel('LM_Info','I',LLTInfo);
  LM_Warning:=ProgramLog.RegisterLogLevel('LM_Warning','W',LLTWarning);
  LM_Error:=ProgramLog.RegisterLogLevel('LM_Error','E',LLTError);
  LM_Fatal:=ProgramLog.RegisterLogLevel('LM_Fatal','F',LLTError);
  LM_Necessarily:=ProgramLog.RegisterLogLevel('LM_Necessarily','N',LLTInfo);

  ProgramLog.EnterMsgOpt:=lp_IncPos;
  ProgramLog.ExitMsgOpt:=lp_DecPos;
  ProgramLog.addMsgOptAlias('+',lp_IncPos);
  ProgramLog.addMsgOptAlias('-',lp_DecPos);


  ProgramLog.SetDefaultLogLevel(LM_Debug);
  ProgramLog.SetCurrentLogLevel(LM_Info);

  UnitsInitializeLMId:=ProgramLog.RegisterModule('UnitsInitialization');
  UnitsFinalizeLMId:=ProgramLog.RegisterModule('UnitsFinalization');

  TimeDecorator.init;
  ProgramLog.addDecorator(TimeDecorator);

  PositionDecorator.init;
  ProgramLog.addDecorator(PositionDecorator);


  LogFileName:=SysToUTF8(ExtractFilePath(paramstr(0)))+filelog;
  if CommandLineParser.HasOption(LOGFILEHDL)then
  for i:=0 to CommandLineParser.OptionOperandsCount(LOGFILEHDL)-1 do
    LogFileName:=CommandLineParser.OptionOperand(LOGFILEHDL,i);

  FileLogBackend.init(LogFileName);
  ProgramLog.addBackend(FileLogBackend,'%1:s%2:s%0:s',[@TimeDecorator,@PositionDecorator]);

  ProgramLog.LogStart;
  programlog.LogOutFormatStr('Unit "%s" initialization finish, log created',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);

  if CommandLineParser.HasOption(LCLHDL)then
  for i:=0 to CommandLineParser.OptionOperandsCount(LCLHDL)-1 do begin
    mn:=CommandLineParser.OptionOperand(LCLHDL,i);
    if programlog.TryGetLogLevelHandle(mn,ll)then
      programlog.SetCurrentLogLevel(ll)
    else
      programlog.LogOutFormatStr('Unable find log level="%s"',[mn],LM_Error);
  end;

finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
  ProgramLog.LogEnd;
  ProgramLog.done;
  FileLogBackend.done;
end.

