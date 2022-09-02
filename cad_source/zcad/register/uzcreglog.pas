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
uses uzbLogTypes,uzbLog,uzclog,uzcinterface,uzcuidialogs,uzcuitypes,uzelongprocesssupport,
     {$IFNDEF DELPHI}LCLtype,{$ELSE}windows,{$ENDIF}LCLProc,Forms,
     LazLoggerBase,LazLogger,uzbLogIntf;
implementation

type
  TLogHelper=class
    class procedure EndLongProcessHandler(LPHandle:TLPSHandle;TotalLPTime:TDateTime);
    class procedure LCLOnDebugLN(Sender: TObject; S: string; var Handled: Boolean);
  end;

  TLogerMBoxBackend=object(TLogerBaseBackend)
    procedure doLog(msg:TLogMsg;MsgOptions:TMsgOpt;LogMode:TLogLevel;LMDI:TModuleDesk);virtual;
    constructor init;
  end;

const
  LPSTIMINGModuleName='LPSTIMING';

var
  LPSTIMINGModuleDeskIndex:TModuleDesk;
  LogerMBoxBackend:TLogerMBoxBackend;
  MO_SM,MO_SH:TMsgOpt;

class procedure TLogHelper.EndLongProcessHandler(LPHandle:TLPSHandle;TotalLPTime:TDateTime);
var
   ts:string;
begin
  str((TotalLPTime*10e4):3:2,ts);
  programlog.LogOutFormatStr('LongProcess "%s" finished: %s second',[lps.getLPName(LPHandle),ts],LM_Necessarily,LPSTIMINGModuleDeskIndex)
end;

class procedure TLogHelper.LCLOnDebugLN(Sender: TObject; S: string; var Handled: Boolean);
begin
  programlog.ZOnDebugLN(Sender,S,Handled);
end;

procedure ShowMessageForLog(errstr:String);
var
   dr:TZCMsgDialogResult;
begin
  dr:=zcMsgDlg(ErrStr,zcdiInformation,[],true);
end;
procedure ShowWarningForLog(errstr:String);
var
   dr:TZCMsgDialogResult;
begin
  dr:=zcMsgDlg(ErrStr,zcdiWarning,[],true);
end;
procedure ShowErrorForLog(errstr:String);
var
   dr:TZCMsgDialogResult;
begin
  dr:=zcMsgDlg(ErrStr,zcdiError,[],true);
end;

procedure TLogerMBoxBackend.doLog(msg:TLogMsg;MsgOptions:TMsgOpt;LogMode:TLogLevel;LMDI:TModuleDesk);
begin
  if (MO_SM and MsgOptions)<>0 then begin
       case ProgramLog.GetMutableLogLevelData(LogMode)^.LogLevelType of
         LLTWarning:ShowWarningForLog(msg);
           LLTError:ShowErrorForLog(msg);
               else ShowMessageForLog(msg);
      end;
  end;
  if (MO_SH and MsgOptions)<>0 then
    ZCMsgCallBackInterface.Do_HistoryOut(msg);
end;

constructor TLogerMBoxBackend.init;
begin
end;

var
  lz:TLazLogger;

initialization

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
  MO_SM:=MsgOpt.GetEnum;
  MO_SH:=MsgOpt.GetEnum;
  ProgramLog.addMsgOptAlias('M',MO_SM);
  ProgramLog.addMsgOptAlias('H',MO_SH);
  LogerMBoxBackend.init;
  ProgramLog.addBackend(LogerMBoxBackend,'',[]);

finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
end.

