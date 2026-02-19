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
{$Mode delphi}
{$INCLUDE zengineconfig.inc}
interface
uses
    Controls,{LCLTaskDialog,}Dialogs, SysUtils,Forms,{$IFNDEF DELPHI}LCLtype,{$ELSE}windows,{$ENDIF}
    uzcinterface,uzclog,uzelongprocesssupport,
    uzcuitypes,uzcuiutils,uzcuilcl2zc;

type

  TLPSSupporthelper=class
    class procedure StartLongProcessHandler(LPHandle:TLPSHandle;Total:TLPSCounter;LPName:TLPName;Options:TLPOpt);
    class procedure EndLongProcessHandler(LPHandle:TLPSHandle;TotalLPTime:TDateTime;Options:TLPOpt);
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

class procedure TLPSSupporthelper.EndLongProcessHandler(LPHandle:TLPSHandle;TotalLPTime:TDateTime;Options:TLPOpt);
begin
  if lps.{isProcessed}isFirstProcess then begin
    if assigned(SuppressedMessages)then
      SuppressedMessages.clear;
    TaskNameSave:='';
  end;
end;
class procedure TLPSSupporthelper.StartLongProcessHandler(LPHandle:TLPSHandle;Total:TLPSCounter;LPName:TLPName;Options:TLPOpt);
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
     zcUI.Do_BeforeShowModal(nil);
     try
       Application.MessageBox(@s[1],'',MB_OK or MB_ICONSTOP);
     finally
       zcUI.Do_AfterShowModal(nil);
     end;
     halt(0);
end;

function TZCMsgDlgIcon2TTaskDialogIcon(value:TZCMsgDlgIcon):TTaskDialogIcon;
begin
  case value of
    zcdiWarning:result:=tdiWarning;
   zcdiQuestion:result:=tdiQuestion;
      zcdiError:result:=tdiError;
zcdiInformation:result:=tdiInformation;
    zcdiNotUsed:result:=tdiNone;
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
  Result.ModalResult:=ZCmrCancel;
  Task:=TTaskDialog.Create(nil);
  try
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
    zcUI.Do_BeforeShowModal(nil);
    try
      CorrectButtons(buttons);

      if MsgTitle='' then
        Task.Caption:=rsMsgWndTitle
      else
        Task.Caption:=MsgTitle;

      Task.{Inst}Title:='';
      Task.Text:=MsgStr;
      if (NeedAskDonShow)and((lps.isProcessed)or(assigned(PContext^))) then begin
        if buttons=[zccbOK] then
          Task.VerificationText:=format(rsDontShowThisNextTime,[TaskName])
        else
          Task.VerificationText:=format(rsMsgKeepChoice,[TaskName]);
      end
      else
        Task.VerificationText:='';
      Task.Flags:=Task.Flags-[tfVerificationFlagChecked];
      //Task.VerifyChecked := false;

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
        TDF:=[tfPositionRelativeToWindow]
      else
        TDF:=[];

      Task.Flags:=Task.Flags+TDF;
      Task.CommonButtons:=TZCMsgCommonButtons2TCommonButtons.Convert(buttons);
      Task.MainIcon:=TZCMsgDlgIcon2TTaskDialogIcon(aDialogIcon);
      //Task.Execute(TZCMsgCommonButtons2TCommonButtons.Convert(buttons),0,TDF,TZCMsgDlgIcon2TTaskDialogIcon(aDialogIcon),tdiWarning,0,0,}ParentHWND)

      if Task.Execute{(ParentHWND)} then begin
        Result.ModalResult:=TLCLModalResult2TZCMsgModalResult.Convert(Task.ModalResult);
        //Result.RadioRes:=Task.RadioRes;
        //Result.SelectionRes:=Task.SelectionRes;
        Result.VerifyChecked:={Task.VerifyChecked}tfVerificationFlagChecked in Task.Flags;
      end;
    finally
      zcUI.Do_AfterShowModal(nil);
    end;

    if {Task.VerifyChecked}tfVerificationFlagChecked in Task.Flags then begin
      if MsgID='' then
        MsgID:=getMsgID(MsgStr);
      if not assigned(PContext^) then
        PContext^:=TMessagesContext.Create(TaskNameSave);
      PContext^.add(MsgID,Result);
    end;
  finally
    Task.Free;
  end;
end;
function zcQuestion(Caption,Question:TZCMsgStr;buttons:TZCMsgCommonButtons;icon:TZCMsgDlgIcon):TZCMsgCommonButton;
begin
  zcUI.Do_BeforeShowModal(nil);
  try
    result:=TZCMsgModalResult2TZCMsgCommonButton(zcMsgDlg(Question,icon,buttons,False,nil,Caption).ModalResult);
  finally
    zcUI.Do_AfterShowModal(nil);
  end;
end;

initialization
  lps.AddOnLPEndHandler(TLPSSupporthelper.EndLongProcessHandler);
  lps.AddOnLPStartHandler(TLPSSupporthelper.StartLongProcessHandler);
  zcUI.TextQuestionFunc:=@zcQuestion;
finalization
  if assigned(SuppressedMessages)then
    freeandnil(SuppressedMessages);
end.
