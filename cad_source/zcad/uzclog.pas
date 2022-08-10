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

  PDIncPos,PDDecPos:TMsgOpt;


  ProgramLog:tlog;
  UnitsInitializeLMId,UnitsFinalizeLMId:TModuleDesk;

implementation

type
  TLogerFileBackend=object(TLogerBaseBackend)
    LogFileName:AnsiString;
    FileHandle:cardinal;
    procedure doLog(msg:TLogMsg);virtual;
    procedure endLog;virtual;
    constructor init(fn:AnsiString);
    destructor done;virtual;
    procedure OpenLog;
    procedure CloseLog;
    procedure CreateLog;
  end;
  TTimeBackend=object(TLogerBaseDecorator)
    function GetDecor(msg:TLogMsg;MsgOptions:TMsgOpt;LogMode:TLogLevel=1;LMDI:TModuleDesk=1):TLogMsg;virtual;
    constructor init;
  end;
var
   FileLogBackend:TLogerFileBackend;
   TimeBackend:TTimeBackend;

constructor TTimeBackend.init;
begin
end;

function TTimeBackend.GetDecor(msg:TLogMsg;MsgOptions:TMsgOpt;LogMode:TLogLevel=1;LMDI:TModuleDesk=1):TLogMsg;
begin
  result:=TimeToStr(Time);
end;

procedure TLogerFileBackend.OpenLog;
begin
  FileHandle := FileOpen({$IFNDEF DELPHI}UTF8ToSys{$ENDIF}(logfilename), fmOpenWrite);
  FileSeek(FileHandle, 0, 2);
end;

procedure TLogerFileBackend.CloseLog;
begin
  fileclose(FileHandle);
  FileHandle:=0;
end;
procedure TLogerFileBackend.CreateLog;
begin
  FileHandle:=FileCreate({$IFNDEF DELPHI}UTF8ToSys{$ENDIF}(logfilename));
  CloseLog;
end;

procedure TLogerFileBackend.doLog(msg:TLogMsg);
begin
  OpenLog;
  FileWrite(FileHandle,msg[1],Length(msg)*SizeOf(msg[1]));
  CloseLog;
end;

procedure TLogerFileBackend.endLog;
begin
end;

constructor TLogerFileBackend.init(fn:AnsiString);
begin
  logfilename:=fn;
  CreateLog;
end;

destructor TLogerFileBackend.done;
begin
  logfilename:='';
end;


initialization
  ProgramLog.init; //эти значения теперь по дефолту ('LM_Trace','T');

  LM_Debug:=ProgramLog.RegisterLogLevel('LM_Debug','D',LLTInfo);
  LM_Info:=ProgramLog.RegisterLogLevel('LM_Info','I',LLTInfo);
  LM_Warning:=ProgramLog.RegisterLogLevel('LM_Warning','W',LLTWarning);
  LM_Error:=ProgramLog.RegisterLogLevel('LM_Error','E',LLTError);
  LM_Fatal:=ProgramLog.RegisterLogLevel('LM_Fatal','F',LLTError);
  LM_Necessarily:=ProgramLog.RegisterLogLevel('LM_Necessarily','N',LLTInfo);

  PDIncPos:=MsgOpt.GetEnum;
  PDDecPos:=MsgOpt.GetEnum;

  ProgramLog.SetDefaultLogLevel(LM_Debug);
  ProgramLog.SetCurrentLogLevel(LM_Info);

  UnitsInitializeLMId:=ProgramLog.RegisterModule('UnitsInitialization');
  UnitsFinalizeLMId:=ProgramLog.RegisterModule('UnitsFinalization');

  TimeBackend.init;
  ProgramLog.addDecorator(TimeBackend);


  FileLogBackend.init(SysToUTF8(ExtractFilePath(paramstr(0)))+filelog);
  ProgramLog.addBackend(FileLogBackend,'&0:s &%0:d:s',[@TimeBackend]);

  ProgramLog.LogStart;
  programlog.LogOutFormatStr('Unit "%s" initialization finish, log created',[{$INCLUDE %FILE%}],lp_OldPos,LM_Info,UnitsInitializeLMId);

finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],lp_OldPos,LM_Info,UnitsFinalizeLMId);
  ProgramLog.LogEnd;
  ProgramLog.done;
  FileLogBackend.done;

end.

