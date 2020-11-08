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

unit uzcmessagedialogs;
{$INCLUDE def.inc}
interface
uses
    LCLTaskDialog,SysUtils,Forms,{$IFNDEF DELPHI}LCLtype,{$ELSE}windows,{$ENDIF}
    uzcinterface,uzclog;

resourcestring
  rsMsgWndTitle='ZCad';
  rsMsgNoAsk='Do no ask next time';

type
  TMsgDialogResult=record
    ModalResult:integer;
    RadioRes: integer;
    SelectionRes: integer;
    VerifyChecked: Boolean;
  end;

procedure FatalError(errstr:String);
function zcMsgDlgError(ErrStr:String;NeedNoAsk:boolean=false):TMsgDialogResult;
function zcMsgDlgWarning(ErrStr:String;NeedNoAsk:boolean=false):TMsgDialogResult;
function zcMsgDlgInformation(ErrStr:String;NeedNoAsk:boolean=false):TMsgDialogResult;

implementation
procedure FatalError(errstr:String);
var s:String;
begin
     s:='FATALERROR: '+errstr;
     programlog.logoutstr(s,0,LM_Fatal);
     s:=(s);
     ZCMsgCallBackInterface.Do_BeforeShowModal(nil);
     Application.MessageBox(@s[1],'',MB_OK or MB_ICONSTOP);
     ZCMsgCallBackInterface.Do_AfterShowModal(nil);

     halt(0);
end;
function zcMsgDlg(MsgStr:String;aDialogIcon: TTaskDialogIcon;NeedNoAsk:boolean=false):TMsgDialogResult;
var
  Task: TTaskDialog;
begin
  ZCMsgCallBackInterface.Do_BeforeShowModal(nil);

  Task.Title:=rsMsgWndTitle;
  Task.Inst:='';
  Task.Content:=MsgStr;
  if NeedNoAsk then
    Task.Verify:=rsMsgNoAsk
  else
    Task.Verify:='';
  Task.VerifyChecked := false;

  Result.ModalResult:=Task.Execute([],0,[tdfPositionRelativeToWindow],aDialogIcon);//controls.mrOk
  Result.RadioRes:=Task.RadioRes;
  Result.SelectionRes:=Task.SelectionRes;
  Result.VerifyChecked:=Task.VerifyChecked;

  ZCMsgCallBackInterface.Do_AfterShowModal(nil);
end;
function zcMsgDlgError(ErrStr:String;NeedNoAsk:boolean=false):TMsgDialogResult;
var
  Task: TTaskDialog;
begin
  Result:=zcMsgDlg(ErrStr,tiError,NeedNoAsk);
end;
function zcMsgDlgWarning(ErrStr:String;NeedNoAsk:boolean=false):TMsgDialogResult;
var
  Task: TTaskDialog;
begin
  Result:=zcMsgDlg(ErrStr,tiWarning,NeedNoAsk);
end;
function zcMsgDlgInformation(ErrStr:String;NeedNoAsk:boolean=false):TMsgDialogResult;
var
  Task: TTaskDialog;
begin
  Result:=zcMsgDlg(ErrStr,tiInformation,NeedNoAsk);
end;
begin
end.
