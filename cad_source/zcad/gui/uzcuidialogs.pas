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

unit uzcuidialogs;
{$INCLUDE zengineconfig.inc}
interface
uses
    Controls,LCLTaskDialog,SysUtils,Forms,{$IFNDEF DELPHI}LCLtype,{$ELSE}windows,{$ENDIF}
    uzcinterface,uzclog,uzelongprocesssupport,
    uzcuitypes,uzcuiutils,uzcuilcl2zc;

type

  TLPSSupporthelper=class
    class procedure StartLongProcessHandler(LPHandle:TLPSHandle;Total:TLPSCounter;LPName:TLPName);
    class procedure EndLongProcessHandler(LPHandle:TLPSHandle;TotalLPTime:TDateTime);
  end;

procedure FatalError(errstr:String);
function zcMsgDlg(MsgStr:TZCMsgStr;aDialogIcon:TZCMsgDlgIcon;buttons:TZCMsgCommonButtons;NeedAskDonShow:boolean=false;Context:TMessagesContext=nil;MsgTitle:TZCMsgStr=''):TZCMsgDialogResult;

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

class procedure TLPSSupporthelper.EndLongProcessHandler(LPHandle:TLPSHandle;TotalLPTime:TDateTime);
begin
  if lps.{isProcessed}isFirstProcess then begin
    if assigned(SuppressedMessages)then
      SuppressedMessages.clear;
    TaskNameSave:='';
  end;
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

function zcMsgDlg(MsgStr:TZCMsgStr;aDialogIcon:TZCMsgDlgIcon;buttons:TZCMsgCommonButtons;NeedAskDonShow:boolean=false;Context:TMessagesContext=nil;MsgTitle:TZCMsgStr=''):TZCMsgDialogResult;
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
  //PriorityFocusCtrl:TWinControl;
  ParentHWND:THandle;
  TDF:TTaskDialogFlags;
  FirstMainParent,MainParent:TWinControl;
  i:integer;
begin
  Task:=Default(TTaskDialog);
  Result:=Default(TZCMsgDialogResult);
  //FillChar(Task,SizeOf(Task),0);
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

  //считаем сколько фактически форм зкада показано на экране
  FirstMainParent:=nil;
  MainParent:=nil;
  for i:=0 to Screen.CustomFormCount-1 do begin
    MainParent:=Screen.CustomForms[i];
    if MainParent.IsVisible then begin
      while MainParent.Parent<>nil do
        MainParent:=MainParent.Parent;
      if MainParent is TCustomForm then
        //сплэшскрин за отдельнцю форму не считаем
        if (MainParent as TCustomForm).FormStyle=fsSplash then
          continue;
      if FirstMainParent=nil then
        FirstMainParent:=MainParent
      else
        if FirstMainParent<>MainParent then
          Break;
    end else
      MainParent:=FirstMainParent;
  end;

  //если одна, Task в центре формы, если несколько или нет вообще - в центре экрана
  if (FirstMainParent=MainParent)and(FirstMainParent<>nil) then
    TDF:=[tdfPositionRelativeToWindow]
  else
    TDF:=[];

  Result.ModalResult:=TLCLModalResult2TZCMsgModalResult.Convert(Task.Execute(TZCMsgCommonButtons2TCommonButtons.Convert(buttons),0,TDF,TZCMsgDlgIcon2TTaskDialogIcon(aDialogIcon),tfiWarning,0,0,ParentHWND));//controls.mrOk
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
function zcQuestion(Caption,Question:TZCMsgStr;buttons:TZCMsgCommonButtons;icon:TZCMsgDlgIcon):TZCMsgCommonButton;
begin
  ZCMsgCallBackInterface.Do_BeforeShowModal(nil);
  result:=TZCMsgModalResult2TZCMsgCommonButton(zcMsgDlg(Question,icon,buttons,False,nil,Caption).ModalResult);
  ZCMsgCallBackInterface.Do_AfterShowModal(nil);
end;

initialization
  lps.AddOnLPEndHandler(TLPSSupporthelper.EndLongProcessHandler);
  lps.AddOnLPStartHandler(TLPSSupporthelper.StartLongProcessHandler);
  ZCMsgCallBackInterface.TextQuestionFunc:=@zcQuestion;
finalization
  if assigned(SuppressedMessages)then
    freeandnil(SuppressedMessages);
end.
