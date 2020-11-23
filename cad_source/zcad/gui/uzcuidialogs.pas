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

unit uzcuidialogs;
{$INCLUDE def.inc}
interface
uses
    Controls,LCLTaskDialog,SysUtils,Forms,{$IFNDEF DELPHI}LCLtype,{$ELSE}windows,{$ENDIF}
    uzcinterface,uzclog,uzelongprocesssupport,
    uzcuitypes,uzcuiutils,uzcuilcl2zc;

resourcestring
  rsMsgWndTitle='ZCAD';
  rsDontShowThisNextTime='Don''t show this next time (for task "%s")';
  rsMsgKeepChoice='Keep choice (for task "%s")';

type

  TLPSSupporthelper=class
    class procedure StartLongProcessHandler(LPHandle:TLPSHandle;Total:TLPSCounter;LPName:TLPName);
    class procedure EndLongProcessHandler(LPHandle:TLPSHandle;TotalLPTime:TDateTime);
  end;

  TZCMsgCommonButton2TCommonButton_Converter=class
    class function Convert(valueIn:TZCMsgCommonButton;out valueOut:TCommonButton):boolean;
  end;

  TLCLModalResult2TZCMsgModalResult_Converter=class
    class function Convert(valueIn:Integer;out valueOut:TZCMsgModalResult):boolean;
  end;

  TZCMsgCommonButtons2TCommonButtons=TGSetConverter<TZCMsgCommonButton,TZCMsgCommonButtons,TCommonButton,TCommonButtons,TZCMsgCommonButton2TCommonButton_Converter>;
  TLCLModalResult2TZCMsgModalResult=TGConverter<Integer,TZCMsgModalResult,TLCLModalResult2TZCMsgModalResult_Converter>;

procedure FatalError(errstr:String);
function zcMsgDlg(MsgStr:String;aDialogIcon:TZCMsgDlgIcon;buttons:TZCMsgCommonButtons;NeedAskDonShow:boolean=false;Context:TMessagesContext=nil;MsgTitle:string=''):TZCMsgDialogResult;

function CreateMessagesContext(TN:TLPName):TMessagesContext;
procedure FreeMessagesContext(var Context:TMessagesContext);

implementation
type
  PTMessagesContext=^TMessagesContext;//тупо, но эффективно
var
  SuppressedMessages:TMessagesContext=nil;
  TaskNameSave:TLPName;

function CreateMessagesContext(TN:TLPName):TMessagesContext;
begin
  result:=TMessagesContext.Create(TN);
end;

procedure FreeMessagesContext(var Context:TMessagesContext);
begin
  if assigned(Context) then
    FreeAndNil(Context);
end;

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

class function TLCLModalResult2TZCMsgModalResult_Converter.Convert(valueIn:Integer;out valueOut:TZCMsgModalResult):boolean;
begin
  result:=true;
  if valueIn in [mrNone..mrLast] then
    case valueIn of
      mrNone:    valueOut:=ZCmrNone;
      mrOK:      valueOut:=ZCmrOK;
      mrCancel:  valueOut:=ZCmrCancel;
      mrAbort:   valueOut:=ZCmrAbort;
      mrRetry:   valueOut:=ZCmrRetry;
      mrIgnore:  valueOut:=ZCmrIgnore;
      mrYes:     valueOut:=ZCmrYes;
      mrNo:      valueOut:=ZCmrNo;
      mrAll:     valueOut:=ZCmrAll;
      mrNoToAll: valueOut:=ZCmrNoToAll;
      mrYesToAll:valueOut:=ZCmrYesToAll;
      mrClose:   valueOut:=ZCmrClose;
      else begin
        result:=false;
        valueOut:=ZCmrNone;
      end;
    end
  else
    valueOut:=valueIn;
end;

class procedure TLPSSupporthelper.EndLongProcessHandler(LPHandle:TLPSHandle;TotalLPTime:TDateTime);
begin
  if lps.isProcessed then
    if assigned(SuppressedMessages)then
      SuppressedMessages.clear;
  TaskNameSave:='';
end;
class procedure TLPSSupporthelper.StartLongProcessHandler(LPHandle:TLPSHandle;Total:TLPSCounter;LPName:TLPName);
begin
  if lps.isFirstProcess then begin
    if assigned(SuppressedMessages)then
        SuppressedMessages.TaskName:=LPName;
    TaskNameSave:=LPName;
  end;
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

function zcMsgDlg(MsgStr:String;aDialogIcon:TZCMsgDlgIcon;buttons:TZCMsgCommonButtons;NeedAskDonShow:boolean=false;Context:TMessagesContext=nil;MsgTitle:string=''):TZCMsgDialogResult;
  function isMsgSupressed(PC:PTMessagesContext;MsgID:String;var PrevResult:TZCMsgDialogResult):boolean;
  begin
    if assigned(PC^) then
      if PC^.TryGetValue(MsgID,PrevResult) then
        exit(true);
    result:=false;
  end;
  function isSupressedMsgPresent(PC:PTMessagesContext):boolean;
  begin
    if assigned(PC^) then
      if PC^.count>0 then
        exit(true);
    result:=false;
  end;
var
  Task:TTaskDialog;
  MsgID:String;
  PContext:PTMessagesContext;
  TaskName:TLPName;
  PriorityFocusCtrl:TWinControl;
  ParentHWND:THandle;
begin
  FillChar(Task,SizeOf(Task),0);
  if assigned(Context) then begin
    PContext:=@Context;
    TaskName:=Context.TaskName;
  end else begin
    PContext:=@SuppressedMessages;
    TaskName:=TaskNameSave;
  end;
  if isSupressedMsgPresent(PContext) then begin
    MsgID:=getMsgID(MsgStr);
    if isMsgSupressed(PContext,MsgID,Result) then begin
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
  if (NeedAskDonShow)and((lps.isProcessed)or(assigned(PContext^))) then begin
    if buttons=[zccbOK] then
      Task.Verify:=format(rsDontShowThisNextTime,[TaskName])
    else
      Task.Verify:=format(rsMsgKeepChoice,[TaskName]);
  end
  else
    Task.Verify:='';
  Task.VerifyChecked := false;

  ParentHWND:=0;
  PriorityFocusCtrl:= ZCMsgCallBackInterface.GetPriorityFocus;
  if PriorityFocusCtrl<>nil then begin
    while PriorityFocusCtrl.Parent<>nil do
      PriorityFocusCtrl:=PriorityFocusCtrl.Parent;
    ParentHWND:=PriorityFocusCtrl.Handle;
  end;

  Result.ModalResult:=TLCLModalResult2TZCMsgModalResult.Convert(Task.Execute(TZCMsgCommonButtons2TCommonButtons.Convert(buttons),0,[tdfPositionRelativeToWindow],TZCMsgDlgIcon2TTaskDialogIcon(aDialogIcon),tfiWarning,0,0,ParentHWND));//controls.mrOk
  Result.RadioRes:=Task.RadioRes;
  Result.SelectionRes:=Task.SelectionRes;
  Result.VerifyChecked:=Task.VerifyChecked;

  ZCMsgCallBackInterface.Do_AfterShowModal(nil);

  if Task.VerifyChecked then begin
    if MsgID='' then
      MsgID:=getMsgID(MsgStr);
    if not assigned(PContext^) then
      PContext^:=TMessagesContext.Create(TaskNameSave);
    PContext^.add(MsgID,Result);
  end;
end;
initialization
  lps.AddOnLPEndHandler(TLPSSupporthelper.EndLongProcessHandler);
  lps.AddOnLPStartHandler(TLPSSupporthelper.StartLongProcessHandler);
finalization
  if assigned(SuppressedMessages)then
    freeandnil(SuppressedMessages);
end.
