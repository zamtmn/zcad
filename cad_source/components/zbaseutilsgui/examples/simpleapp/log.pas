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

unit log;
{$mode objfpc}{$H+}

interface

uses
  sysutils,LazUTF8,
  uzbLogTypes,uzblog,uzbLogDecorators,uzbLogFileBackend,
  uzbCommandLineParser,commandline;

var
//LM_Trace,     //уже определен в uzbLog.TLog // — вывод всего подряд. На тот случай, если Debug не позволяет локализовать ошибку.
  LM_Debug,     // — журналирование моментов вызова «крупных» операций.
  LM_Info,      // — разовые операции, которые повторяются крайне редко, но не регулярно. (загрузка конфига, плагина, запуск бэкапа)
  LM_Warning,   // — неожиданные параметры вызова, странный формат запроса, использование дефолтных значений в замен не корректных. Вообще все, что может свидетельствовать о не штатном использовании.
  LM_Error,     // — повод для внимания разработчиков. Тут интересно окружение конкретного места ошибки.
  LM_Fatal,     // — тут и так понятно. Выводим все до чего дотянуться можем, так как дальше приложение работать не будет.
  LM_Necessarily// — Вывод в любом случае
  :TLogLevel;

  M1,M2:TModuleDesk;
  ProgramLog:TLog;

var
   TimeDecorator:TTimeDecorator;
   PositionDecorator:TPositionDecorator;

implementation

var
   FileLogBackend:TLogFileBackend;
   i:integer;
   mn:TCLStringType;
   ll:TLogLevel;
   LogFileName:string;
   disabledefaultmodule:boolean;

initialization
  ProgramLog.init;

  LM_Debug:=ProgramLog.RegisterLogLevel('LM_Debug','D',LLTInfo);
  LM_Info:=ProgramLog.RegisterLogLevel('LM_Info','I',LLTInfo);
  LM_Warning:=ProgramLog.RegisterLogLevel('LM_Warning','W',LLTWarning);
  LM_Error:=ProgramLog.RegisterLogLevel('LM_Error','E',LLTError);
  LM_Fatal:=ProgramLog.RegisterLogLevel('LM_Fatal','F',LLTError);
  LM_Necessarily:=ProgramLog.RegisterLogLevel('LM_Necessarily','N',LLTInfo);

  ProgramLog.EnterMsgOpt:=lp_IncPos;
  ProgramLog.ExitMsgOpt:=lp_DecPos;

  ProgramLog.SetDefaultLogLevel(LM_Debug);
  ProgramLog.SetCurrentLogLevel(LM_Warning);

  TimeDecorator.init;
  ProgramLog.addDecorator(TimeDecorator);

  PositionDecorator.init;
  ProgramLog.addDecorator(PositionDecorator);


  LogFileName:=SysToUTF8(ExtractFilePath(paramstr(0)))+'log.txt';
  if CommandLineParser.HasOption(logfileCLOH)then
  for i:=0 to CommandLineParser.OptionOperandsCount(logfileCLOH)-1 do
    LogFileName:=CommandLineParser.OptionOperand(logfileCLOH,i);

  FileLogBackend.init(LogFileName);
  ProgramLog.addBackend(FileLogBackend,'%1:s%2:s%0:s',[@TimeDecorator,@PositionDecorator]);

  ProgramLog.LogStart;

  if CommandLineParser.HasOption(lclCLOH)then
  for i:=0 to CommandLineParser.OptionOperandsCount(lclCLOH)-1 do begin
    mn:=CommandLineParser.OptionOperand(lclCLOH,i);
    if programlog.TryGetLogLevelHandle(mn,ll)then
      programlog.SetCurrentLogLevel(ll)
    else
      programlog.LogOutFormatStr('Unable find log level="%s"',[mn],LM_Error);
  end;

  M1:=programlog.RegisterModule('Module1',EDisable);
  M2:=programlog.RegisterModule('Module2',EDisable);
  disabledefaultmodule:=false;

  if CommandLineParser.HasOption(dmCLOH)then
    for i:=0 to CommandLineParser.OptionOperandsCount(dmCLOH)-1 do begin
      mn:=CommandLineParser.OptionOperand(dmCLOH,i);
      if uppercase(mn)<>'DEFAULT'then
        programlog.DisableModule(mn)
      else
        disabledefaultmodule:=true;
    end;


  if CommandLineParser.HasOption(emCLOH)then
    for i:=0 to CommandLineParser.OptionOperandsCount(emCLOH)-1 do begin
      mn:=CommandLineParser.OptionOperand(emCLOH,i);
      if uppercase(mn)<>'DEFAULT'then
        programlog.EnableModule(mn)
      else
        disabledefaultmodule:=false;
    end;

  if disabledefaultmodule then
    programlog.DisableModule('DEFAULT');

finalization
  ProgramLog.LogEnd;
  ProgramLog.done;
  FileLogBackend.done;
end.

