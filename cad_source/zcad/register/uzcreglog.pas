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

unit uzcreglog;
{$mode delphi}
{$INCLUDE zengineconfig.inc}
interface
uses uzbLog,uzclog,uzcinterface,uzcuidialogs,uzcuitypes,uzelongprocesssupport,
     {$IFNDEF DELPHI}LCLtype,{$ELSE}windows,{$ENDIF}LCLProc,Forms,
     LazLoggerBase,LazLogger,uzbLogIntf;
implementation

type
  TLogHelper=class
    class procedure EndLongProcessHandler(LPHandle:TLPSHandle;TotalLPTime:TDateTime);
    class procedure LCLOnDebugLN(Sender: TObject; S: string; var Handled: Boolean);
  end;

const
  LPSTIMINGModuleName='LPSTIMING';

var
  LPSTIMINGModuleDeskIndex:TModuleDesk;

class procedure TLogHelper.EndLongProcessHandler(LPHandle:TLPSHandle;TotalLPTime:TDateTime);
var
   ts:string;
begin
  str((TotalLPTime*10e4):3:2,ts);
  programlog.LogOutFormatStr('LongProcess "%s" finished: %s second',[lps.getLPName(LPHandle),ts],lp_OldPos,LM_Necessarily,LPSTIMINGModuleDeskIndex)
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

var
  lz:TLazLogger;

initialization

  LPSTIMINGModuleDeskIndex:=programlog.RegisterModule(LPSTIMINGModuleName);

  lps.AddOnLPEndHandler(TLogHelper.EndLongProcessHandler);
  programlog.HistoryTextOut:=ZCMsgCallBackInterface.Do_HistoryOut();
  programlog.MessageBoxTextOut:=@ShowMessageForLog;
  programlog.WarningBoxTextOut:=@ShowWarningForLog;
  programlog.ErrorBoxTextOut:=@ShowErrorForLog;

  lz:=GetDebugLogger;
  if assigned(lz)then
    if lz is TLazLoggerFile then
      begin
           (lz as TLazLoggerFile).OnDebugLn:=TLogHelper.LCLOnDebugLN;
           (lz as TLazLoggerFile).OnDbgOut:=TLogHelper.LCLOnDebugLN;
      end;

  InstallLoger(programlog.ZDebugLN,nil,programlog.isTraceEnabled);
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
end.

