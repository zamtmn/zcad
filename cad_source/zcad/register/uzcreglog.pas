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
uses uzclog,uzcinterface,uzcmessagedialogs,
     {$IFNDEF DELPHI}LCLtype,{$ELSE}windows,{$ENDIF}LCLProc,Forms;
implementation

procedure ShowMessageForLog(errstr:String);
var
   dr:TMsgDialogResult;
begin
  dr:=zcMsgDlgInformation(ErrStr,true);
end;
procedure ShowWarningForLog(errstr:String);
var
   dr:TMsgDialogResult;
begin
  dr:=zcMsgDlgWarning(ErrStr,true);
end;
procedure ShowErrorForLog(errstr:String);
var
   dr:TMsgDialogResult;
begin
  dr:=zcMsgDlgError(ErrStr,true);
end;

initialization
  uzclog.HistoryTextOut:=ZCMsgCallBackInterface.Do_HistoryOut();
  uzclog.MessageBoxTextOut:=@ShowMessageForLog;
  uzclog.WarningBoxTextOut:=@ShowWarningForLog;
  uzclog.ErrorBoxTextOut:=@ShowErrorForLog;
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
end.

