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
    Controls,LCLTaskDialog,SysUtils,Forms,{$IFNDEF DELPHI}LCLtype,{$ELSE}windows,{$ENDIF}
    uzcinterface,uzclog,uzelongprocesssupport,Generics.Collections,gvector;

resourcestring
  rsMsgWndTitle='ZCAD';
  rsDontShowThisNextTime='Don''t show this next time (for task "%s")';
  rsMsgKeepChoice='Keep choice (for task "%s")';

type
  TZCMsgCommonButton=(zccbOK,zccbYes,zccbNo,zccbCancel,zccbRetry,zccbClose);
  TZCMsgCommonButtons=set of TZCMsgCommonButton;
  TZCMsgDlgIcon=(zcdiWarning, zcdiQuestion, zcdiError, zcdiInformation, zcdiNotUsed);
  TZCMsgDialogResult=record
    ModalResult:integer;
    RadioRes: integer;
    SelectionRes: integer;
    VerifyChecked: Boolean;
  end;

  TMessagesDictionary=TDictionary<string,TZCMsgDialogResult>;

  TLPSSupporthelper=class
    class procedure EndLongProcessHandler(LPHandle:TLPSHandle;TotalLPTime:TDateTime);
  end;

  TSetConverter<TGEnumIn,TGSetIn,TGEnumOut,TGSetOut,TGEnumConverter>=class
    class function Convert(value:TGSetIn):TGSetOut;
  end;

  TZCMsgCommonButton2TCommonButton_Converter=class
    class function Convert(valueIn:TZCMsgCommonButton;out valueOut:TCommonButton):boolean;
  end;

  TZCMsgCommonButtons2TCommonButtons=TSetConverter<TZCMsgCommonButton,TZCMsgCommonButtons,TCommonButton,TCommonButtons,TZCMsgCommonButton2TCommonButton_Converter>;

procedure FatalError(errstr:String);
function zcMsgDlg(MsgStr:String;aDialogIcon:TZCMsgDlgIcon;buttons:TZCMsgCommonButtons;NeedAskDonShow:boolean=false;MsgTitle:string=''):TZCMsgDialogResult;

implementation
var
  SuppressedMessages:TMessagesDictionary=nil;

class function TZCMsgCommonButton2TCommonButton_Converter.Convert(valueIn:TZCMsgCommonButton;out valueOut:TCommonButton):boolean;
begin
  result:=true;
  case valueIn of
    zccbOK:valueOut:=cbOK;
    zccbYes:valueOut:=cbYes;
    zccbNo:valueOut:=cbNo;
    zccbCancel:valueOut:=cbCancel;
    zccbRetry:valueOut:=cbRetry;
    zccbClose:valueOut:=cbClose;
    else result:=false;
  end;
end;

class function TSetConverter<TGEnumIn,TGSetIn,TGEnumOut,TGSetOut,TGEnumConverter>.Convert(value:TGSetIn):TGSetOut;
var
 CurrentEnumIn:TGEnumIn;
 CurrentEnumOut:TGEnumOut;
 tvalue:TGSetIn;
begin
  result:=[];
  for CurrentEnumIn:=low(TGEnumIn) to high(TGEnumIn) do begin
    tvalue:=value-[CurrentEnumIn];
    if tvalue<>value then begin
      if TGEnumConverter.convert(CurrentEnumIn,CurrentEnumOut) then
        result:=result+[CurrentEnumOut];
      if tvalue=[] then exit;
      value:=tvalue;
    end;
  end;
end;

class procedure TLPSSupporthelper.EndLongProcessHandler(LPHandle:TLPSHandle;TotalLPTime:TDateTime);
begin
  if lps.isProcessed then
    if assigned(SuppressedMessages)then
      SuppressedMessages.clear;
end;

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
function getMsgID(MsgID:String):String;
var
  quoted:boolean;
  count,i,j:integer;
begin
  quoted:=false;
  count:=0;
  for i:=1 to length(MsgID) do begin
    if MsgID[i]='"' then quoted:=not quoted;
    if not quoted then inc(count);
  end;
  setlength(result,count);
  quoted:=false;
  j:=1;
  for i:=1 to length(MsgID) do begin
    if MsgID[i]='"' then quoted:=not quoted;
    if not quoted then begin
      result[j]:=MsgID[i];
      inc(j);
    end;
  end;
end;

function TZCMsgDlgIcon2TTaskDialogIcon(value:TZCMsgDlgIcon):TTaskDialogIcon;
begin
  case value of
    zcdiWarning:result:=tiWarning;
   zcdiQuestion:result:=tiQuestion;
      zcdiError:result:=tiError;
zcdiInformation:result:=tiInformation;
    zcdiNotUsed:result:=tiNotUsed;
  end;
end;

procedure CorrectButtons(var buttons:TZCMsgCommonButtons);
begin
  if buttons=[] then
    buttons:=[zccbOK];
end;

function zcMsgDlg(MsgStr:String;aDialogIcon:TZCMsgDlgIcon;buttons:TZCMsgCommonButtons;NeedAskDonShow:boolean=false;MsgTitle:string=''):TZCMsgDialogResult;
  function isMsgSupressed(MsgID:String;var PrevResult:TZCMsgDialogResult):boolean;
  begin
    if assigned(SuppressedMessages) then
      if SuppressedMessages.TryGetValue(MsgID,PrevResult) then
        exit(true);
    result:=false;
  end;
  function isSupressedMsgPresent:boolean;
  begin
    if assigned(SuppressedMessages) then
      if SuppressedMessages.count>0 then
        exit(true);
    result:=false;
  end;
var
  Task:TTaskDialog;
  MsgID:String;
begin
  if isSupressedMsgPresent then begin
    MsgID:=getMsgID(MsgStr);
    if isMsgSupressed(MsgID,Result) then begin
      exit;
    end;
  end else
    MsgID:='';
  ZCMsgCallBackInterface.Do_BeforeShowModal(nil);

  CorrectButtons(buttons);

  if MsgTitle='' then
    Task.Title:=rsMsgWndTitle
  else
    Task.Title:=MsgTitle;

  Task.Inst:='';
  Task.Content:=MsgStr;
  if (NeedAskDonShow)and(lps.isProcessed) then begin
    if buttons=[zccbOK] then
      Task.Verify:=format(rsDontShowThisNextTime,[lps.getLPName(0)])
    else
      Task.Verify:=format(rsMsgKeepChoice,[lps.getLPName(0)]);
  end
  else
    Task.Verify:='';
  Task.VerifyChecked := false;

  Result.ModalResult:=Task.Execute(TZCMsgCommonButtons2TCommonButtons.Convert(buttons),0,[tdfPositionRelativeToWindow],TZCMsgDlgIcon2TTaskDialogIcon(aDialogIcon));//controls.mrOk
  Result.RadioRes:=Task.RadioRes;
  Result.SelectionRes:=Task.SelectionRes;
  Result.VerifyChecked:=Task.VerifyChecked;

  ZCMsgCallBackInterface.Do_AfterShowModal(nil);

  if Task.VerifyChecked then begin
    if MsgID='' then
      MsgID:=getMsgID(MsgStr);
    if not assigned(SuppressedMessages) then
      SuppressedMessages:=TMessagesDictionary.create;
    SuppressedMessages.add(MsgID,Result);
  end;
end;
initialization
  lps.AddOnLPEndHandler(TLPSSupporthelper.EndLongProcessHandler);
finalization
  if assigned(SuppressedMessages)then
    freeandnil(SuppressedMessages);
end.
