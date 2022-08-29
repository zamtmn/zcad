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
  uzbLogTypes,uzblog,StrUtils;

const
  {$IFDEF LINUX}filelog='../../log/zcad_linux.log';{$ENDIF}
  {$IFDEF WINDOWS}filelog='../../log/zcad_windows.log';{$ENDIF}
  {$IFDEF DARWIN}filelog='../../log/zcad_darwin.log';{$ENDIF}

var
//LM_Trace,     //уже определен в uzbLog.tlog // — вывод всего подряд. На тот случай, если Debug не позволяет локализовать ошибку.
  LM_Debug,     // — журналирование моментов вызова «крупных» операций.
  LM_Info,      // — разовые операции, которые повторяются крайне редко, но не регулярно. (загрузка конфига, плагина, запуск бэкапа)
  LM_Warning,   // — неожиданные параметры вызова, странный формат запроса, использование дефолтных значений в замен не корректных. Вообще все, что может свидетельствовать о не штатном использовании.
  LM_Error,     // — повод для внимания разработчиков. Тут интересно окружение конкретного места ошибки.
  LM_Fatal,     // — тут и так понятно. Выводим все до чего дотянуться можем, так как дальше приложение работать не будет.
  LM_Necessarily// — Вывод в любом случае
  :TLogLevel;

  lp_IncPos,lp_DecPos:TMsgOpt;


  ProgramLog:tlog;
  UnitsInitializeLMId,UnitsFinalizeLMId:TModuleDesk;

implementation

type
  TLogerFileBackend=object(TLogerBaseBackend)
    LogFileName:AnsiString;
    FileHandle:cardinal;
    procedure doLog(msg:TLogMsg;MsgOptions:TMsgOpt;LogMode:TLogLevel;LMDI:TModuleDesk);virtual;
    procedure endLog;virtual;
    constructor init(fn:AnsiString);
    destructor done;virtual;
    procedure OpenLog;
    procedure CloseLog;
    procedure CreateLog;
  end;

  TTimeDecorator=object(TLogerBaseDecorator)
    function GetDecor(msg:TLogMsg;MsgOptions:TMsgOpt;LogMode:TLogLevel;LMDI:TModuleDesk):TLogMsg;virtual;
    constructor init;
  end;
  TPositionDecorator=object(TLogerBaseDecorator)
    offset:integer;
    function GetDecor(msg:TLogMsg;MsgOptions:TMsgOpt;LogMode:TLogLevel;LMDI:TModuleDesk):TLogMsg;virtual;
    constructor init;
  end;

var
   FileLogBackend:TLogerFileBackend;
   TimeDecorator:TTimeDecorator;
   PositionDecorator:TPositionDecorator;

function TPositionDecorator.GetDecor(msg:TLogMsg;MsgOptions:TMsgOpt;LogMode:TLogLevel;LMDI:TModuleDesk):TLogMsg;
begin
 if (MsgOptions and lp_DecPos)>0 then
   dec(offset,2);
 result:=dupestring(' ',offset);
 if (MsgOptions and lp_IncPos)>0 then
   inc(offset,2);
end;

constructor TPositionDecorator.init;
begin
  offset:=1;
end;

constructor TTimeDecorator.init;
begin
end;

function TTimeDecorator.GetDecor(msg:TLogMsg;MsgOptions:TMsgOpt;LogMode:TLogLevel;LMDI:TModuleDesk):TLogMsg;
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

procedure TLogerFileBackend.doLog(msg:TLogMsg;MsgOptions:TMsgOpt;LogMode:TLogLevel;LMDI:TModuleDesk);
begin
  OpenLog;
  FileWrite(FileHandle,msg[1],Length(msg)*SizeOf(msg[1]));
  FileWrite(FileHandle,LineEnding[1],Length(LineEnding)*SizeOf(LineEnding[1]));
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

  lp_DecPos:=MsgOpt.GetEnum;
  lp_IncPos:=MsgOpt.GetEnum;
  ProgramLog.EnterMsgOpt:=lp_IncPos;
  ProgramLog.ExitMsgOpt:=lp_DecPos;
  ProgramLog.MsgOptAliasDic.add('+',lp_IncPos);
  ProgramLog.MsgOptAliasDic.add('-',lp_DecPos);


  ProgramLog.SetDefaultLogLevel(LM_Debug);
  ProgramLog.SetCurrentLogLevel(LM_Info);

  UnitsInitializeLMId:=ProgramLog.RegisterModule('UnitsInitialization');
  UnitsFinalizeLMId:=ProgramLog.RegisterModule('UnitsFinalization');

  TimeDecorator.init;
  ProgramLog.addDecorator(TimeDecorator);

  PositionDecorator.init;
  ProgramLog.addDecorator(PositionDecorator);


  FileLogBackend.init(SysToUTF8(ExtractFilePath(paramstr(0)))+filelog);
  ProgramLog.addBackend(FileLogBackend,'%1:s%2:s%0:s',[@TimeDecorator,@PositionDecorator]);

  ProgramLog.LogStart;
  programlog.LogOutFormatStr('Unit "%s" initialization finish, log created',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);

finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
  ProgramLog.LogEnd;
  ProgramLog.done;
  FileLogBackend.done;
end.

