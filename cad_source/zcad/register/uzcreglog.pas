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

unit uzcreglog;
{$mode delphi}
{$INCLUDE zengineconfig.inc}
interface
uses
  uzbPaths,uzbLogTypes,uzbLog,uzcLog,LazLogger,uzcinterface,uzcuidialogs,
  uzcuitypes,uzelongprocesssupport,
  LCLtype,LCLProc,Forms,sysutils,LazUTF8,
  uzbLogDecorators,uzbLogFileBackend,
  LazLoggerBase,uzbLogIntf,
  uzbCommandLineParser,uzcCommandLineParser;

const
  filelog='zcad.log';

implementation

type
  TLogHelper=class
    class procedure EndLongProcessHandler(LPHandle:TLPSHandle;TotalLPTime:TDateTime;Options:TLPOpt);
    class procedure LCLOnDebugLN(Sender: TObject; S: string; var Handled: Boolean);
  end;

  TLogerMBoxBackend=object(TLogerBaseBackend)
    procedure doLog(const msg:TLogMsg;MsgOptions:TMsgOpt;LogMode:TLogLevel;LMDI:TModuleDesk);virtual;
  end;

const
  LPSTIMINGModuleName='LPSTIMING';

var
  LPSTIMINGModuleDeskIndex:TModuleDesk;
  LogerMBoxBackend:TLogerMBoxBackend;

class procedure TLogHelper.EndLongProcessHandler(LPHandle:TLPSHandle;TotalLPTime:TDateTime;Options:TLPOpt);
var
   ts:string;
begin
  str((TotalLPTime*10e4):3:3,ts);
  programlog.LogOutFormatStr('LongProcess "%s" finished: %s second',[lps.getLPName(LPHandle),ts],LM_Necessarily,LPSTIMINGModuleDeskIndex)
end;

class procedure TLogHelper.LCLOnDebugLN(Sender: TObject; S: string; var Handled: Boolean);
begin
  programlog.ZOnDebugLN(Sender,S,Handled);
end;

procedure ShowMessageForLog(errstr:String);
//var
//   dr:TZCMsgDialogResult;
begin
  {dr:=}zcMsgDlg(ErrStr,zcdiInformation,[],true);
end;
procedure ShowWarningForLog(errstr:String);
//var
//   dr:TZCMsgDialogResult;
begin
  {dr:=}zcMsgDlg(ErrStr,zcdiWarning,[],true);
end;
procedure ShowErrorForLog(errstr:String);
//var
//   dr:TZCMsgDialogResult;
begin
  {dr:=}zcMsgDlg(ErrStr,zcdiError,[],true);
end;

procedure TLogerMBoxBackend.doLog(const msg:TLogMsg;MsgOptions:TMsgOpt;LogMode:TLogLevel;LMDI:TModuleDesk);
begin
  if ((MO_SM and MsgOptions)<>0)and((zcUI.GetState and ZState_Busy)=0) then begin
       case ProgramLog.GetMutableLogLevelData(LogMode)^.LogLevelType of
         LLTWarning:ShowWarningForLog(msg);
           LLTError:ShowErrorForLog(msg);
               else ShowMessageForLog(msg);
      end;
  end;
  if (MO_SH and MsgOptions)<>0 then
    zcUI.Do_HistoryOut(msg);
end;

var
  lz:TLazLogger;
  FileLogBackend:TLogFileBackend;
  TimeDecorator:TTimeDecorator;
  PositionDecorator:TPositionDecorator;
  LogFileName:string;
  i:Integer;
  mn:TCLStringType;
  ll:TLogLevel;

  FileLogBackendHandle,LogerMBoxBackendHandle,TimeDecoratorHandle,PositionDecoratorHandle:TLogExtHandle;

initialization

  ProgramLog.EnterMsgOpt:=lp_IncPos;
  ProgramLog.ExitMsgOpt:=lp_DecPos;
  ProgramLog.addMsgOptAlias('+',lp_IncPos);
  ProgramLog.addMsgOptAlias('-',lp_DecPos);

  UnitsInitializeLMId:=ProgramLog.RegisterModule('UnitsInitialization');
  UnitsFinalizeLMId:=ProgramLog.RegisterModule('UnitsFinalization');

  TimeDecorator.init;
  TimeDecoratorHandle:=ProgramLog.addDecorator(TimeDecorator);

  PositionDecorator.init;
  PositionDecoratorHandle:=ProgramLog.addDecorator(PositionDecorator);

  LogFileName:=ConcatPaths([GetTempPath,filelog]);
  if CommandLineParser.HasOption(LOGFILEHDL)then
  for i:=0 to CommandLineParser.OptionOperandsCount(LOGFILEHDL)-1 do
    LogFileName:=CommandLineParser.OptionOperand(LOGFILEHDL,i);

  FileLogBackend.init(copy(LogFileName,1,length(LogFileName)));
  FileLogBackendHandle:=ProgramLog.addBackend(FileLogBackend,'%1:s%2:s%0:s',[@TimeDecorator,@PositionDecorator]);

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

  LPSTIMINGModuleDeskIndex:=programlog.RegisterModule(LPSTIMINGModuleName,EEnable);

  lps.AddOnLPEndHandler(TLogHelper.EndLongProcessHandler);

  lz:=GetDebugLogger;
  if assigned(lz)then
    if lz is TLazLoggerFile then
      begin
           (lz as TLazLoggerFile).OnDebugLn:=TLogHelper.LCLOnDebugLN;
           (lz as TLazLoggerFile).OnDbgOut:=TLogHelper.LCLOnDebugLN;
      end;

  InstallLoger(programlog.ZDebugLN,nil,programlog.isTraceEnabled);
  LogerMBoxBackend.init;
  LogerMBoxBackendHandle:=ProgramLog.addBackend(LogerMBoxBackend,'',[]);

finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
  RemoveLoger(programlog.ZDebugLN,nil,programlog.isTraceEnabled);
  ProgramLog.LogEnd;
  ProgramLog.removeBackend(FileLogBackendHandle);
  ProgramLog.removeBackend(LogerMBoxBackendHandle);
  ProgramLog.removeDecorator(TimeDecoratorHandle);
  ProgramLog.removeDecorator(PositionDecoratorHandle);
  FileLogBackend.done;
  TimeDecorator.done;
  PositionDecorator.done;
end.

