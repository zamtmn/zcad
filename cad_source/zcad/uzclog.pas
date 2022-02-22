{
*****************************************************************************
*                                                                           *
*  This file is part of the ZCAD                                            *
*                                                                           *
*  See the file COPYING.modifiedLGPL.txt, included in this distribution,    *
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
{$INCLUDE zcadconfig.inc}
{$mode objfpc}{$H+}
interface
uses uzctnrVectorBytes,LazLoggerBase,
     LazLogger,sysutils{$IFNDEF DELPHI},LazUTF8{$ENDIF},
     uzblog;
const {$IFDEF DELPHI}filelog='log/zcad_delphi.log';{$ENDIF}
      {$IFDEF FPC}
                  {$IFDEF LINUX}filelog='../../log/zcad_linux.log';{$ENDIF}
                  {$IFDEF WINDOWS}filelog='../../log/zcad_windows.log';{$ENDIF}
                  {$IFDEF DARWIN}filelog='../../log/zcad_darwin.log';{$ENDIF}
      {$ENDIF}
      lp_IncPos=uzblog.lp_IncPos;
      lp_DecPos=uzblog.lp_DecPos;
      lp_OldPos=uzblog.lp_OldPos;
var
          //LM_Trace,     // — вывод всего подряд. На тот случай, если Debug не позволяет локализовать ошибку.
          LM_Debug,     // — журналирование моментов вызова «крупных» операций.
          LM_Info,      // — разовые операции, которые повторяются крайне редко, но не регулярно. (загрузка конфига, плагина, запуск бэкапа)
          LM_Warning,   // — неожиданные параметры вызова, странный формат запроса, использование дефолтных значений в замен не корректных. Вообще все, что может свидетельствовать о не штатном использовании.
          LM_Error,     // — повод для внимания разработчиков. Тут интересно окружение конкретного места ошибки.
          LM_Fatal,     // — тут и так понятно. Выводим все до чего дотянуться можем, так как дальше приложение работать не будет.
          LM_Necessarily:TLogLevel;// — Вывод в любом случае
   programlog:tlog;
   VerboseLog:boolean;
implementation

initialization
begin
    programlog.init({$IFNDEF DELPHI}SysToUTF8{$ENDIF}(ExtractFilePath(paramstr(0)))+filelog,'LM_Trace','T');
    LM_Debug:=programlog.RegisterLogLevel('LM_Debug','D',LLD(LLTInfo));
    LM_Info:=programlog.RegisterLogLevel('LM_Info','I',LLD(LLTInfo));
    LM_Warning:=programlog.RegisterLogLevel('LM_Warning','W',LLD(LLTWarning));
    LM_Error:=programlog.RegisterLogLevel('LM_Error','E',LLD(LLTError));
    LM_Fatal:=programlog.RegisterLogLevel('LM_Fatal','F',LLD(LLTError));
    LM_Necessarily:=programlog.RegisterLogLevel('LM_Necessarily','N',LLD(LLTInfo));
    programlog.SetDefaultLogLevel(LM_Debug);
    programlog.SetCurrentLogLevel(LM_Info);
end;
finalization
    debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
    programlog.done;
end.

