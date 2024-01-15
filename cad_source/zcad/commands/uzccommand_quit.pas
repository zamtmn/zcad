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
{$mode delphi}
unit uzccommand_quit;

{$INCLUDE zengineconfig.inc}

interface
uses
  uzcLog,Controls,SysUtils,
  uzccommandsmanager,uzcdrawings,uzccommandsabstract,uzccommandsimpl,uzcuitypes,uzglviewareageneral,uzglviewareaabstract,
  uzcdrawing,uzctreenode,uzcuidialogs,uzcstrconsts,LCLType,uzcinterface,uzcuiutils,Forms;

procedure CloseApp;
function CloseDWGPage(Sender: TObject;NeedAskDonShow:boolean;MCtx:TMessagesContext):integer;
function _CloseDWGPage(ClosedDWG:PTZCADDrawing;lincedcontrol:TObject;NeedAskDonShow:boolean;MCtx:TMessagesContext):Integer;

implementation

uses uzcmainwindow,uzccommand_saveas;

{ #todo : Убрать зависимость от главной формы }

function _CloseDWGPage(ClosedDWG:PTZCADDrawing;lincedcontrol:TObject;NeedAskDonShow:boolean;MCtx:TMessagesContext):Integer;
var
   viewcontrol:TCADControl;
   s:string;
   TAWA:TAbstractViewArea;
   dr:TZCMsgDialogResult;
begin
  if ClosedDWG<>nil then
  begin
    result:=ZCmrYes;
    if ClosedDWG.Changed then begin
      repeat
        s:=format(rsCloseDWGQuery,[StringReplace(ClosedDWG.FileName,'\','\\',[rfReplaceAll])]);
        dr:=zcMsgDlg(s,zcdiQuestion,[zccbYes,zccbNo,zccbCancel],NeedAskDonShow,MCTx);
        result:=dr.ModalResult;
        //result:=ZCADMainWindow.MessageBox(@s[1],@rsWarningCaption[1],MB_YESNOCANCEL);
        if result=ZCmrCancel then exit;
        if result=ZCmrNo then system.break;
        if result=ZCmrYes then
          result:=dwgQSave_com(ClosedDWG);
      until result<>cmd_error;
      result:=ZCmrYes;
    end;
    commandmanager.ChangeModeAndEnd(TGPMCloseDWG);
    viewcontrol:=ClosedDWG.wa.getviewcontrol;
    if drawings.GetCurrentDWG=pointer(ClosedDwg) then
                                               drawings.freedwgvars;
    drawings.RemoveData(ClosedDWG);
    drawings.pack;

    viewcontrol.free;

    lincedcontrol.Free;
    tobject(viewcontrol):=ZCADMainWindow.PageControl.ActivePage;

    if viewcontrol<>nil then
    begin
      TAWA:=TAbstractViewArea(FindComponentByType(viewcontrol,TAbstractViewArea));
      drawings.CurrentDWG:=pointer(TAWA.PDWG);
      TAWA.GDBActivate;
    end
    else
      drawings.freedwgvars;
    ZCMsgCallBackInterface.Do_GUIaction(nil,ZMsgID_GUIFreEditorProc);
    ZCMsgCallBackInterface.Do_GUIaction(nil,ZMsgID_GUIReturnToDefaultObject);
    ZCMsgCallBackInterface.TextMessage(rsClosed,TMWOQuickly);
    ZCMsgCallBackInterface.Do_GUIaction(nil,ZMsgID_GUIActionRebuild);
    ZCMsgCallBackInterface.Do_GUIaction(nil,ZMsgID_GUIActionRedraw);
    //if assigned(UpdateVisibleProc) then UpdateVisibleProc(ZMsgID_GUIActionRedraw);
  end;
end;

function CloseDWGPage(Sender: TObject;NeedAskDonShow:boolean;MCtx:TMessagesContext):integer;
var
   wa:TGeneralViewArea;
   ClosedDWG:PTZCADDrawing;
   //i:integer;
begin
  Closeddwg:=nil;
  wa:=TGeneralViewArea(FindComponentByType(TControl(sender),TGeneralViewArea));
  if wa<>nil then
    Closeddwg:=PTZCADDrawing(wa.PDWG);
  result:=_CloseDWGPage(ClosedDWG,Sender,NeedAskDonShow,mctx);
end;


procedure CloseApp;
var
  MCtx:TMessagesContext=nil;
  wa:TGeneralViewArea;
  ClosedDWG:PTZCADDrawing;

  function GetChangedDrawingsCount:integer;
  var
    i:integer;
  begin
    result:=0;
    for i:=0 to ZCADMainWindow.PageControl.PageCount-1 do begin
      wa:=TGeneralViewArea(FindComponentByType(ZCADMainWindow.PageControl.Pages[i],TGeneralViewArea));
      if wa<>nil then begin
        Closeddwg:=PTZCADDrawing(wa.PDWG);
        if ClosedDWG<>nil then
          if ClosedDWG.Changed then
            inc(result);
       end;
    end;
  end;

begin
  if IsRealyQuit then
  begin
    if ZCADMainWindow.PageControl<>nil then
    begin
      if (GetChangedDrawingsCount>1)or(CommandManager.isBusy) then
        MCtx:=CreateMessagesContext(rsCloseDrawings);
      if (ZCMsgCallBackInterface.GetState and ZState_Busy)>0 then begin
      //if CommandManager.isBusy then begin
        MCtx.add(getMsgID(rsQuitQuery),TZCMsgDialogResult.CreateMR(ZCmrYes));
        MCtx.add(getMsgID(rsCloseDWGQuery),TZCMsgDialogResult.CreateMR(ZCmrNo));
      end;
      while ZCADMainWindow.PageControl.ActivePage<>nil do
      begin
        if CloseDWGPage(ZCADMainWindow.PageControl.ActivePage,GetChangedDrawingsCount>1,MCtx)=IDCANCEL then begin
          FreeMessagesContext(MCtx);
          exit;
        end;
      end;
      FreeMessagesContext(MCtx);
    end;
    ZCMsgCallBackInterface.Do_GUIaction(nil,ZMsgID_GUIFreEditorProc);
    ZCMsgCallBackInterface.Do_GUIaction(nil,ZMsgID_GUIReturnToDefaultObject);
    ZCMsgCallBackInterface.Do_GUIaction(nil,ZMsgID_GUIBeforeCloseApp);
    application.terminate;
  end;
end;


function quit_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
begin
  CloseApp;
  result:=cmd_ok;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@quit_com,'Quit',0,0);
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
