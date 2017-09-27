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

unit uzcshared;
{$INCLUDE def.inc}
interface
uses uzcinterface,uzclog,uzbpaths,{$IFNDEF DELPHI}LCLtype,{$ELSE}windows,{$ENDIF}Controls,
     uzbtypesbase,Classes, SysUtils, {$IFNDEF DELPHI}fileutil,{$ENDIF}Forms,
     ExtCtrls{, ComCtrls}{$IFNDEF DELPHI},LCLProc{$ENDIF};

procedure FatalError(errstr:GDBString);

implementation
procedure FatalError(errstr:GDBString);
var s:GDBString;
begin
     s:='FATALERROR: '+errstr;
     programlog.logoutstr(s,0,LM_Fatal);
     s:=(s);
     ZCMsgCallBackInterface.Do_BeforeShowModal(nil);
     Application.MessageBox(@s[1],'',MB_OK);
     ZCMsgCallBackInterface.Do_AfterShowModal(nil);

     halt(0);
end;
procedure ShowError(errstr:String); export;
var
   ts:GDBString;
begin
     ZCMsgCallBackInterface.TextMessage(errstr,TMWOSilentShowError);
     ts:=(errstr);
     ZCMsgCallBackInterface.Do_BeforeShowModal(nil);
     Application.MessageBox(@ts[1],'',MB_ICONERROR);
     ZCMsgCallBackInterface.Do_AfterShowModal(nil);
end;
begin
uzclog.HistoryTextOut:=ZCMsgCallBackInterface.Do_HistoryOut();
uzclog.MessageBoxTextOut:=@ShowError;
end.
