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
{$INCLUDE def.inc}
interface
uses uzclog,uzcinterface,uzcuidialogs,uzcuitypes,uzelongprocesssupport,
     {$IFNDEF DELPHI}LCLtype,{$ELSE}windows,{$ENDIF}LCLProc,Forms;
implementation

type
  TLogHelper=class
    class procedure EndLongProcessHandler(LPHandle:TLPSHandle;TotalLPTime:TDateTime);
  end;

const
  LPSTIMINGModuleName='LPSTIMING';

var
  LPSTIMINGModuleDeskIndex:TLogModuleDeskIndex;

class procedure TLogHelper.EndLongProcessHandler(LPHandle:TLPSHandle;TotalLPTime:TDateTime);
var
   ts:string;
begin
  str((TotalLPTime*10e4):3:2,ts);
  programlog.LogOutFormatStr('LongProcess "%s" finished: %s second',[lps.getLPName(LPHandle),ts],lp_OldPos,LM_Necessarily,LPSTIMINGModuleDeskIndex)
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

initialization

  LPSTIMINGModuleDeskIndex:=programlog.registermodule(LPSTIMINGModuleName);

  lps.AddOnLPEndHandler(TLogHelper.EndLongProcessHandler);
  uzclog.HistoryTextOut:=ZCMsgCallBackInterface.Do_HistoryOut();
  uzclog.MessageBoxTextOut:=@ShowMessageForLog;
  uzclog.WarningBoxTextOut:=@ShowWarningForLog;
  uzclog.ErrorBoxTextOut:=@ShowErrorForLog;
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
end.

