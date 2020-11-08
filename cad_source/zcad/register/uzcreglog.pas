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

procedure ShowErrorForLog(errstr:String);
var
   ts:String;
begin
     ZCMsgCallBackInterface.TextMessage(errstr,TMWOSilentShowError);
     ts:=(errstr);
     ZCMsgCallBackInterface.Do_BeforeShowModal(nil);
     Application.MessageBox(@ts[1],'',MB_OKCANCEL or MB_ICONERROR);
     ZCMsgCallBackInterface.Do_AfterShowModal(nil);
end;

initialization
  uzclog.HistoryTextOut:=ZCMsgCallBackInterface.Do_HistoryOut();
  uzclog.MessageBoxTextOut:=@ShowErrorForLog;
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
end.

