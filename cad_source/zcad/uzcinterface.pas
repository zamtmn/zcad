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
unit uzcinterface;
{$Mode delphi}
{$INCLUDE zengineconfig.inc}
{$ModeSwitch advancedrecords}
interface
uses controls,uzcstrconsts,uzedimensionaltypes,gzctnrSTL,zeundostack,varmandef,
     uzcuilcl2zc,uzcuitypes,forms,classes,LCLType,LCLProc,SysUtils,uzbHandles,
     uzbSets;

const
    PopupPriority=1000;
    CLinePriority=500;
    DrawingsFocusPriority=400;
    UnPriority=-1;
type
  TZMessageID=type Integer;
  TZState=type LongWord;
  TZMessageIDCreater=GTSimpleHandles<TZMessageID,GTHandleManipulator<TZMessageID>>;
  TZStateCreater=GTSet<TZState,TZState>;
var
  ZState_Busy:TZState=0;

  zcMsgUIEnable:TZMessageID=-1;
  zcMsgUIDisable:TZMessageID=-1;
  zcMsgUICMDLineCheck:TZMessageID=-1;
  zcMsgUICMDLineReadyMode:TZMessageID=-1;
  zcMsgUICMDLineRunMode:TZMessageID=-1;
  zcMsgUIActionSelectionChanged:TZMessageID=-1;
  zcMsgUIActionRedrawContent:TZMessageID=-1;
  zcMsgUIActionRedraw:TZMessageID=-1;
  zcMsgUIActionRebuild:TZMessageID=-1;
  zcMsgUIResetOGLWNDProc:TZMessageID=-1;//надо убрать это чудо
  zcMsgUITimerTick:TZMessageID=-1;
  zcMsgUIRePrepareObject:TZMessageID=-1;
  zcMsgUISetDefaultObject:TZMessageID=-1;
  zcMsgUIReturnToDefaultObject:TZMessageID=-1;
  zcMsgUIFreEditorProc:TZMessageID=-1;
  zcMsgUIStoreAndFreeEditorProc:TZMessageID=-1;
  zcMsgUIBeforeCloseApp:TZMessageID=-1;
type
  TGetStateFunc=function:TZState of object;
  TGetStateFuncsVector=TMyVector<TGetStateFunc>;

    TProcedure_String_=procedure(s:String);
    TProcedure_String_HandlersVector=TMyVector<TProcedure_String_>;

    TMethod_TForm_=procedure (ShowedForm:TForm) of object;
    TMethod_TForm_HandlersVector=TMyVector<TMethod_TForm_>;

    TProcedure_TZMessageID=procedure(GUIMode:TZMessageID);
    TProcedure_TZMessageID_HandlersVector=TMyVector<TProcedure_TZMessageID>;

    TSimpleProcedure_TZMessageID=Procedure(GUIAction:TZMessageID);
    TSimpleProcedure=Procedure;
    TSimpleProcedure_TZMessageID_HandlersVector=TMyVector<TSimpleProcedure_TZMessageID>;

    TControlWithPriority=record
      control:TWinControl;
      priority:integer;
      constructor CreateRec(ACtrl:TWinControl;APrrt:integer);
    end;
    TGetControlWithPriority_TZMessageID__TControlWithPriority=function:TControlWithPriority of object;
    TGetControlWithPriority_TZMessageID__TControlWithPriority_HandlersVector=TMyVector<TGetControlWithPriority_TZMessageID__TControlWithPriority>;

    TSimpleLCLMethod_TZMessageID=Procedure (sender:TObject;GUIAction:TZMessageID) of object;
    TSimpleLCLMethod_HandlersVector=TMyVector<TSimpleLCLMethod_TZMessageID>;

    //ObjInsp
    TSetGDBObjInsp=procedure(const UndoStack:PTZctnrVectorUndoCommands;const f:TzeUnitsFormat;exttype:PUserTypeDescriptor; addr,context:Pointer;popoldpos:boolean=false);
    TSetGDBObjInsp_HandlersVector=TMyVector<TSetGDBObjInsp>;

    TKeyEvent_HandlersVector=TMyVector<TKeyEvent>;


    TTextMessageWriteOptions=(TMWOToConsole,            //вывод сообщения в консоль
                              TMWOToLog,                //вывод в log
                              TMWOToQuicklyReplaceable, //вывод в статусную строку
                              TMWOToModal,              //messagebox
                              TMWOWarning,              //оформить как варнинг
                              TMWOError);               //оформить как ошибку

    TTextMessageWriteOptionsSet=set of TTextMessageWriteOptions;

    TTextQuestionFunc=function(Caption,Question:TZCMsgStr;buttons:TZCMsgCommonButtons;icon:TZCMsgDlgIcon):TZCMsgCommonButton;

const
    TMWOHistoryOut=[TMWOToConsole,TMWOToLog];
    TMWOShowError=[TMWOToConsole,TMWOToLog,TMWOToModal,TMWOError];
    TMWOSilentShowError=[TMWOToConsole,TMWOToLog,TMWOError];
    TMWOMessageBox=[TMWOToConsole,TMWOToLog,TMWOToModal];
    TMWOQuickly=[TMWOToQuicklyReplaceable];
type
    TZCStates=(ZCSGUIChanged);
    TZCState=set of TZCStates;
    TZCStatekInterface=class
      public
      state:TZCState;
      constructor Create;
      procedure SetState(st:TZCStates);
      function CheckState(st:TZCStates):boolean;
      function CheckAndResetState(st:TZCStates):boolean;
    end;

    TZCUIManager=class
      private
        ZMessageIDCreater:TZMessageIDCreater;
        ZStateCreater:TZStateCreater;

        GetStateFuncsVector:TGetStateFuncsVector;

        HistoryOutHandlers:TProcedure_String_HandlersVector;
        LogErrorHandlers:TProcedure_String_HandlersVector;
        StatusLineTextOutHandlers:TProcedure_String_HandlersVector;

        BeforeShowModalHandlers:TMethod_TForm_HandlersVector;
        AfterShowModalHandlers:TMethod_TForm_HandlersVector;

        GUIModeHandlers:TProcedure_TZMessageID_HandlersVector;
        GUIActionsHandlers:TSimpleLCLMethod_HandlersVector;

        SetGDBObjInsp_HandlersVector:TSetGDBObjInsp_HandlersVector;

        onKeyDown:TKeyEvent_HandlersVector;
        getfocusedcontrol:TGetControlWithPriority_TZMessageID__TControlWithPriority_HandlersVector;

        FTextQuestionFunc:TTextQuestionFunc;
        ModalShowsCount:integer;
      public
        constructor Create;
        destructor Destroy;override;
        function GetUniqueZState:TZState;
        function GetEmptyZState:TZState;
        function GetUniqueZMessageID:TZMessageID;
        procedure RegisterHandler_HistoryOut(Handler:TProcedure_String_);
        procedure RegisterHandler_LogError(Handler:TProcedure_String_);
        procedure RegisterHandler_StatusLineTextOut(Handler:TProcedure_String_);

        procedure RegisterHandler_BeforeShowModal(Handler:TMethod_TForm_);
        procedure RegisterHandler_AfterShowModal(Handler:TMethod_TForm_);

        procedure RegisterHandler_GUIMode(Handler:TProcedure_TZMessageID);
        procedure RegisterHandler_GUIAction(Handler:TSimpleLCLMethod_TZMessageID);

        procedure RegisterHandler_PrepareObject(Handler:TSetGDBObjInsp);

        procedure RegisterHandler_KeyDown(Handler:TKeyEvent);

        procedure RegisterHandler_GetFocusedControl(Handler:TGetControlWithPriority_TZMessageID__TControlWithPriority);

        procedure RegisterGetStateFunc(fnc:TGetStateFunc);

        function GetState:TZState;
        procedure Do_HistoryOut(s:String);
        procedure Do_LogError(s:String);
        procedure Do_StatusLineTextOut(s:String);

        procedure Do_BeforeShowModal(ShowedForm:TForm);
        procedure Do_AfterShowModal(ShowedForm:TForm);

        procedure Do_GUIMode(GUIMode:TZMessageID);
        procedure Do_GUIaction(Sender:TObject;GUIaction:TZMessageID);

        procedure Do_PrepareObject(const UndoStack:PTZctnrVectorUndoCommands;const f:TzeUnitsFormat;exttype:PUserTypeDescriptor; addr,context:Pointer;popoldpos:boolean=false);

        procedure Do_KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
        procedure Do_SetNormalFocus;
        function GetPriorityFocus:TWinControl;


        procedure TextMessage(msg:String;opt:TTextMessageWriteOptionsSet);

        function TextQuestion(Caption,Question:String):TZCMsgCommonButton;
        function DoShowModal(MForm:TForm):Integer;

        property TextQuestionFunc:TTextQuestionFunc read FTextQuestionFunc write FTextQuestionFunc;

      private
        procedure RegisterTProcedure_String_HandlersVector(var PSHV:TProcedure_String_HandlersVector;Handler:TProcedure_String_);
        procedure Do_TProcedure_String_HandlersVector(var PSHV:TProcedure_String_HandlersVector;s:String);

        procedure RegisterTMethod_TForm_HandlersVector(var MFHV:TMethod_TForm_HandlersVector;Handler:TMethod_TForm_);
        procedure Do_TMethod_TForm_HandlersVector(var MFHV:TMethod_TForm_HandlersVector;ShowedForm:TForm);

        procedure RegisterTProcedure_TGUIMode_HandlersVector(var PGUIMHV:TProcedure_TZMessageID_HandlersVector;Handler:TProcedure_TZMessageID);
        procedure Do_TProcedure_TZMessageID_HandlersVector(var PGUIMHV:TProcedure_TZMessageID_HandlersVector;GUIMode:TZMessageID);

        procedure RegisterTProcedure_TSimpleLCLMethod_HandlersVector(var SMHV:TSimpleLCLMethod_HandlersVector;Handler:TSimpleLCLMethod_TZMessageID);
        procedure Do_TSimpleLCLMethod_HandlersVector(var SMHV:TSimpleLCLMethod_HandlersVector;Sender:TObject;GUIAction:TZMessageID);

        procedure RegisterSetGDBObjInsp_HandlersVector(var SOIHV:TSetGDBObjInsp_HandlersVector;Handler:TSetGDBObjInsp);
        procedure Do_SetGDBObjInsp_HandlersVector(var SOIHV:TSetGDBObjInsp_HandlersVector;const UndoStack:PTZctnrVectorUndoCommands;const f:TzeUnitsFormat;exttype:PUserTypeDescriptor; addr,context:Pointer;popoldpos:boolean=false);

        procedure RegisterTKeyEvent_HandlersVector(var KEHV:TKeyEvent_HandlersVector;Handler:TKeyEvent);
        procedure Do_TKeyEvent_HandlersVector(var KEHV:TKeyEvent_HandlersVector;Sender: TObject; var Key: Word; Shift: TShiftState);

        procedure RegisterTGetControlWithPriority_TZMessageID__TControlWithPriority_HandlersVector(var GCWPHV:TGetControlWithPriority_TZMessageID__TControlWithPriority_HandlersVector;Handler:TGetControlWithPriority_TZMessageID__TControlWithPriority);
        function Do_TGetControlWithPriority_TZMessageID__TControlWithPriority_HandlersVector(var GCWPHV:TGetControlWithPriority_TZMessageID__TControlWithPriority_HandlersVector):TWinControl;
    end;

    TStartLongProcessProc=Procedure(a:integer;s:string) of object;
    TProcessLongProcessProc=Procedure(a:integer) of object;
    TEndLongProcessProc=Procedure of object;
    TSimpleMethod=Procedure of object;
    TMethod_PtrInt_=procedure (Data: PtrInt) of object;
    TMethod__Pointer=function:Pointer of object;
    TFunction__Integer=Function:integer;
    TMethod_String_=procedure (s:String) of object;
    TProcedure_PAnsiChar_=procedure (s:PAnsiChar);

var
   //Objinsp
   {**Позволяет в инспектор вывести то что тебе нужно
    Пример:
    SetGDBObjInspProc( nil,gdb.GetUnitsFormat,sampleInternalRTTITypeDesk,
                       @sampleParam,
                        gdb.GetCurrentDWG );
    nil - нужно для работы с УНДО/РЕДО;
    gdb.GetUnitsFormat - так надо всегда (наверное :) )
    sampleInternalRTTITypeDesk - что будет помещено в инспектор (определение в коде sampleInternalRTTITypeDesk:=pointer(SysUnit^.TypeName2PTD( 'TSampleParam'));)
    @sampleParam - адресс на созданную запись, которая помещается в инспектор
    gdb.GetCurrentDWG  - так надо всегда!
    }
   //ReStoreGDBObjInspProc:TFunction__Boolean;
   //ReturnToDefaultProc:TSimpleProcedure;
   //ClrarIfItIsProc:TOIClearIfItIs_Pointer_;
   //GetCurrentObjProc:TFunction__Pointer;
   GetNameColWidthProc:TFunction__Integer;
   GetOIWidthProc:TFunction__Integer;

   //GetPeditorProc:TFunction__TComponent;

   //mainwindow
   ProcessFilehistoryProc:TMethod_String_;
   AppCloseProc:TMethod_PtrInt_;

   //UGDBDescriptor
   //SetCurrentDWGProc:TSetCurrentDrawing;
   _GetUndoStack:TMethod__Pointer;

function GetUndoStack:pointer;
var
   zcUI:TZCUIManager;
   ZCStatekInterface:TZCStatekInterface;
implementation

constructor TControlWithPriority.CreateRec(ACtrl:TWinControl;APrrt:integer);
begin
  control:=ACtrl;
  priority:=APrrt;
end;
constructor TZCStatekInterface.Create;
begin
   state:=[];
end;
procedure TZCStatekInterface.SetState(st:TZCStates);
begin
   include(state,st);
end;
function TZCStatekInterface.CheckState(st:TZCStates):boolean;
begin
   result:=st in state;
end;
function TZCStatekInterface.CheckAndResetState(st:TZCStates):boolean;
begin
   result:=st in state;
   if result then
     exclude(state,st);
end;
constructor TZCUIManager.Create;
begin
  ZMessageIDCreater.init;
  ZStateCreater.init;
  FTextQuestionFunc:=nil;
  ModalShowsCount:=0;
end;
destructor TZCUIManager.Destroy;
begin
  ZMessageIDCreater.done;
  ZStateCreater.done;

     FreeAndNil(HistoryOutHandlers);
     FreeAndNil(LogErrorHandlers);
     FreeAndNil(StatusLineTextOutHandlers);

     FreeAndNil(BeforeShowModalHandlers);
     FreeAndNil(AfterShowModalHandlers);

     FreeAndNil(GUIModeHandlers);
     FreeAndNil(GUIActionsHandlers);

     FreeAndNil(SetGDBObjInsp_HandlersVector);

     FreeAndNil(onKeyDown);
     FreeAndNil(getfocusedcontrol);

  if assigned(GetStateFuncsVector) then
    FreeAndNil(GetStateFuncsVector);
end;

function TZCUIManager.GetUniqueZMessageID:TZMessageID;
begin
  result:=ZMessageIDCreater.CreateHandle;
end;
function TZCUIManager.GetUniqueZState:TZState;
begin
  result:=ZStateCreater.GetEnum;
end;
function TZCUIManager.GetEmptyZState:TZState;
begin
  result:=ZStateCreater.GetEmpty;
end;
function TZCUIManager.TextQuestion(Caption,Question:TZCMsgStr):TZCMsgCommonButton;
var
   ptext,pcaption:PChar;
begin
  if assigned(FTextQuestionFunc)then
    result:=FTextQuestionFunc(Caption,Question,[zccbYes,zccbNo],zcdiQuestion)
  else begin
    if Question<>'' then
      ptext:=@Question[1]
    else
      ptext:=nil;
    if Caption<>'' then
      pcaption:=@Caption[1]
    else
      pcaption:=nil;
    Do_BeforeShowModal(nil);
    result:=ID2TZCMsgCommonButton(application.MessageBox(ptext,pcaption,MB_YESNO));
    Do_AfterShowModal(nil);
  end;
end;

procedure TZCUIManager.TextMessage(msg:String;opt:TTextMessageWriteOptionsSet);
var
   Caption: string;
   MsgBoxPS:PChar;
   MsgBoxFlags: Longint;
   ZCIcon:TZCMsgDlgIcon;
begin
  if TMWOToModal in opt then begin
    if TMWOWarning in opt then begin
      Caption:=rsWarningCaption;
      msg:=rsWarningPrefix+msg;
      MsgBoxFlags:=MB_OK or MB_ICONWARNING;
      ZCIcon:=zcdiWarning;
    end else
      if TMWOError in opt then begin
         Caption:=rsErrorCaption;
         msg:=rsErrorPrefix+msg;
         MsgBoxFlags:=MB_ICONERROR;
         ZCIcon:=zcdiError;
      end else begin
          Caption:=rsMessageCaption;
          MsgBoxFlags:=MB_OK;
          ZCIcon:=zcdiInformation;
      end;
    if msg<>'' then
      MsgBoxPS:=@msg[1]
    else
      MsgBoxPS:=nil;

    if assigned(FTextQuestionFunc) then
      FTextQuestionFunc(Caption,MsgBoxPS,[zccbOK],ZCIcon)
    else begin
      Do_BeforeShowModal(nil);
      application.MessageBox(MsgBoxPS,@Caption[1],MsgBoxFlags);
      Do_AfterShowModal(nil);
    end;
  end else begin
    if TMWOWarning in opt then begin
      msg:=rsWarningPrefix+msg;
    end else
      if TMWOError in opt then begin
         msg:=rsErrorPrefix+msg;
      end
  end;

  if TMWOToConsole in opt then
    Do_HistoryOut(msg)
  else if TMWOToLog in opt then
    Do_LogError(msg)
  else if TMWOToQuicklyReplaceable in opt then
    Do_StatusLineTextOut(msg)

end;

procedure TZCUIManager.RegisterTProcedure_String_HandlersVector(var PSHV:TProcedure_String_HandlersVector;Handler:TProcedure_String_);
begin
   if not assigned(PSHV) then
     PSHV:=TProcedure_String_HandlersVector.Create;
   PSHV.PushBack(Handler);
end;
procedure TZCUIManager.Do_TProcedure_String_HandlersVector(var PSHV:TProcedure_String_HandlersVector;s:String);
var
   i:integer;
begin
   if assigned(PSHV) then begin
     for i:=0 to PSHV.Size-1 do
       PSHV[i](s);
   end;
end;
procedure TZCUIManager.RegisterTMethod_TForm_HandlersVector(var MFHV:TMethod_TForm_HandlersVector;Handler:TMethod_TForm_);
begin
   if not assigned(MFHV) then
     MFHV:=TMethod_TForm_HandlersVector.Create;
   MFHV.PushBack(Handler);
end;
procedure TZCUIManager.Do_TMethod_TForm_HandlersVector(var MFHV:TMethod_TForm_HandlersVector;ShowedForm:TForm);
var
   i:integer;
begin
   if assigned(MFHV) then begin
     for i:=0 to MFHV.Size-1 do
       MFHV[i](ShowedForm);
   end;
end;
procedure TZCUIManager.RegisterTProcedure_TGUIMode_HandlersVector(var PGUIMHV:TProcedure_TZMessageID_HandlersVector;Handler:TProcedure_TZMessageID);
begin
   if not assigned(PGUIMHV) then
     PGUIMHV:=TProcedure_TZMessageID_HandlersVector.Create;
   PGUIMHV.PushBack(Handler);
end;
procedure TZCUIManager.Do_TProcedure_TZMessageID_HandlersVector(var PGUIMHV:TProcedure_TZMessageID_HandlersVector;GUIMode:{TGUIMode}TZMessageID);
var
   i:integer;
begin
   if assigned(PGUIMHV) then begin
     for i:=0 to PGUIMHV.Size-1 do
       PGUIMHV[i](GUIMode);
   end;
end;

procedure TZCUIManager.RegisterTProcedure_TSimpleLCLMethod_HandlersVector(var SMHV:TSimpleLCLMethod_HandlersVector;Handler:TSimpleLCLMethod_TZMessageID);
begin
   if not assigned(SMHV) then
     SMHV:=TSimpleLCLMethod_HandlersVector.Create;
   SMHV.PushBack(Handler);
end;
procedure TZCUIManager.Do_TSimpleLCLMethod_HandlersVector(var SMHV:TSimpleLCLMethod_HandlersVector;Sender:TObject;GUIAction:TZMessageID);
var
   i:integer;
begin
   if assigned(SMHV) then begin
     for i:=0 to SMHV.Size-1 do
       SMHV[i](sender,GUIAction);
   end;
end;
procedure TZCUIManager.RegisterSetGDBObjInsp_HandlersVector(var SOIHV:TSetGDBObjInsp_HandlersVector;Handler:TSetGDBObjInsp);
begin
   if not assigned(SOIHV) then
     SOIHV:=TSetGDBObjInsp_HandlersVector.Create;
   SOIHV.PushBack(Handler);
end;
procedure TZCUIManager.Do_SetGDBObjInsp_HandlersVector(var SOIHV:TSetGDBObjInsp_HandlersVector;const UndoStack:PTZctnrVectorUndoCommands;const f:TzeUnitsFormat;exttype:PUserTypeDescriptor; addr,context:Pointer;popoldpos:boolean=false);
var
   i:integer;
begin
   if assigned(SOIHV) then begin
     for i:=0 to SOIHV.Size-1 do
       SOIHV[i](UndoStack,f,exttype,addr,context,popoldpos);
   end;
end;
procedure TZCUIManager.RegisterTKeyEvent_HandlersVector(var KEHV:TKeyEvent_HandlersVector;Handler:TKeyEvent);
begin
   if not assigned(KEHV) then
     KEHV:=TKeyEvent_HandlersVector.Create;
   KEHV.PushBack(Handler);
end;
procedure TZCUIManager.Do_TKeyEvent_HandlersVector(var KEHV:TKeyEvent_HandlersVector;Sender: TObject; var Key: Word; Shift: TShiftState);
var
   i:integer;
begin
   if assigned(KEHV) then begin
     for i:=0 to KEHV.Size-1 do
       begin
         KEHV[i](Sender,Key,Shift);
         if key=0 then exit;
       end;
   end;
end;
procedure TZCUIManager.RegisterTGetControlWithPriority_TZMessageID__TControlWithPriority_HandlersVector(var GCWPHV:TGetControlWithPriority_TZMessageID__TControlWithPriority_HandlersVector;Handler:TGetControlWithPriority_TZMessageID__TControlWithPriority);
begin
   if not assigned(GCWPHV) then
     GCWPHV:=TGetControlWithPriority_TZMessageID__TControlWithPriority_HandlersVector.Create;
   GCWPHV.PushBack(Handler);
end;
function TZCUIManager.Do_TGetControlWithPriority_TZMessageID__TControlWithPriority_HandlersVector(var GCWPHV:TGetControlWithPriority_TZMessageID__TControlWithPriority_HandlersVector):TWinControl;
var
   i:integer;
   acwp,ccwp:TControlWithPriority;
begin
   if assigned(GCWPHV) then begin
     acwp.control:=nil;
     acwp.priority:=-1;;
     for i:=0 to GCWPHV.Size-1 do
       begin
         ccwp:=GCWPHV[i];
         if ccwp.priority>acwp.priority then
           acwp:=ccwp;
       end;
     result:=acwp.control;
   end else
     result:=nil;
end;
procedure TZCUIManager.RegisterHandler_HistoryOut(Handler:TProcedure_String_);
begin
   RegisterTProcedure_String_HandlersVector(HistoryOutHandlers,Handler);
end;
procedure TZCUIManager.RegisterHandler_LogError(Handler:TProcedure_String_);
begin
   RegisterTProcedure_String_HandlersVector(LogErrorHandlers,Handler);
end;
procedure TZCUIManager.RegisterHandler_StatusLineTextOut(Handler:TProcedure_String_);
begin
   RegisterTProcedure_String_HandlersVector(StatusLineTextOutHandlers,Handler);
end;
procedure TZCUIManager.RegisterHandler_BeforeShowModal(Handler:TMethod_TForm_);
begin
   RegisterTMethod_TForm_HandlersVector(BeforeShowModalHandlers,Handler);
end;
procedure TZCUIManager.RegisterHandler_AfterShowModal(Handler:TMethod_TForm_);
begin
   RegisterTMethod_TForm_HandlersVector(AfterShowModalHandlers,Handler);
end;
procedure TZCUIManager.RegisterHandler_GUIMode(Handler:TProcedure_TZMessageID);
begin
   RegisterTProcedure_TGUIMode_HandlersVector(GUIModeHandlers,Handler);
end;
procedure TZCUIManager.RegisterHandler_GUIAction(Handler:TSimpleLCLMethod_TZMessageID);
begin
   RegisterTProcedure_TSimpleLCLMethod_HandlersVector(GUIActionsHandlers,Handler);
end;
procedure TZCUIManager.RegisterHandler_PrepareObject(Handler:TSetGDBObjInsp);
begin
   RegisterSetGDBObjInsp_HandlersVector(SetGDBObjInsp_HandlersVector,Handler);
end;
procedure TZCUIManager.RegisterHandler_KeyDown(Handler:TKeyEvent);
begin
   RegisterTKeyEvent_HandlersVector(onKeyDown,Handler);
end;
procedure TZCUIManager.RegisterHandler_GetFocusedControl(Handler:TGetControlWithPriority_TZMessageID__TControlWithPriority);
begin
   RegisterTGetControlWithPriority_TZMessageID__TControlWithPriority_HandlersVector(getfocusedcontrol,Handler);
end;
procedure TZCUIManager.Do_HistoryOut(s:String);
begin
   Do_TProcedure_String_HandlersVector(HistoryOutHandlers,s);
end;
procedure TZCUIManager.Do_LogError(s:String);
begin
   Do_TProcedure_String_HandlersVector(LogErrorHandlers,s);
end;
procedure TZCUIManager.Do_StatusLineTextOut(s:String);
begin
   Do_TProcedure_String_HandlersVector(StatusLineTextOutHandlers,s);
end;
procedure TZCUIManager.Do_BeforeShowModal(ShowedForm:TForm);
begin
   inc(ModalShowsCount);
   Do_TMethod_TForm_HandlersVector(BeforeShowModalHandlers,ShowedForm);
end;
procedure TZCUIManager.Do_AfterShowModal(ShowedForm:TForm);
begin
   Do_TMethod_TForm_HandlersVector(AfterShowModalHandlers,ShowedForm);
   dec(ModalShowsCount);
end;
procedure TZCUIManager.Do_GUIMode(GUIMode:TZMessageID);
begin
   Do_TProcedure_TZMessageID_HandlersVector(GUIModeHandlers,GUIMode);
end;
procedure TZCUIManager.Do_GUIaction(Sender:TObject;GUIaction:TZMessageID);
begin
   Do_TSimpleLCLMethod_HandlersVector(GUIActionsHandlers,Sender,GUIaction);
end;
procedure TZCUIManager.Do_PrepareObject(const UndoStack:PTZctnrVectorUndoCommands;const f:TzeUnitsFormat;exttype:PUserTypeDescriptor; addr,context:Pointer;popoldpos:boolean=false);
begin
   Do_SetGDBObjInsp_HandlersVector(SetGDBObjInsp_HandlersVector,UndoStack,f,exttype,addr,context,popoldpos);
end;
procedure TZCUIManager.Do_KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
   Do_TKeyEvent_HandlersVector(onKeyDown,Sender,Key,Shift);
end;
function TZCUIManager.GetPriorityFocus:TWinControl;
begin
  result:=Do_TGetControlWithPriority_TZMessageID__TControlWithPriority_HandlersVector(getfocusedcontrol);
end;

procedure TZCUIManager.RegisterGetStateFunc(fnc:TGetStateFunc);
begin
   if not assigned(GetStateFuncsVector) then
     GetStateFuncsVector:=TGetStateFuncsVector.Create;
   GetStateFuncsVector.PushBack(fnc);
end;

function TZCUIManager.GetState:TZState;
var
  fnc:TGetStateFunc;
  v:TGetStateFuncsVector;
begin
   Result:=ZStateCreater.GetEmpty;
   v:=GetStateFuncsVector;
   if v<>nil then
     for fnc in v do begin
       ZStateCreater.Include(Result,fnc);
     end;
end;

procedure TZCUIManager.Do_SetNormalFocus;
var
  ctrl:TWinControl;
  aform:TCustomForm;
begin
  if ModalShowsCount=0 then begin
    ctrl:=GetPriorityFocus;
    if assigned(ctrl) then begin
      aform:=GetParentForm(ctrl);
      aform.SetFocus;
      ctrl.SetFocus;
    end;
  end;
end;
function TZCUIManager.DoShowModal(MForm:TForm): Integer;
begin
     Do_BeforeShowModal(MForm);
     result:=TLCLModalResult2TZCMsgModalResult.Convert(MForm.ShowModal);
     Do_BeforeShowModal(MForm);
end;

function GetUndoStack:pointer;
begin
     if assigned(_GetUndoStack) then
                                    result:=_GetUndoStack
                                else
                                    result:=nil;
end;


initialization
  zcUI:=TZCUIManager.create;
  ZCStatekInterface:=TZCStatekInterface.create;
  ZState_Busy:=zcUI.GetUniqueZState;
  zcMsgUIEnable:=zcUI.GetUniqueZMessageID;
  zcMsgUIDisable:=zcUI.GetUniqueZMessageID;
  zcMsgUICMDLineCheck:=zcUI.GetUniqueZMessageID;
  //zcMsgUIEnableCMDLine:=zcUI.GetUniqueZMessageID;
  //zcMsgUIDisableCMDLine:=zcUI.GetUniqueZMessageID;

  zcMsgUICMDLineReadyMode:=zcUI.GetUniqueZMessageID;
  zcMsgUICMDLineRunMode:=zcUI.GetUniqueZMessageID;

  zcMsgUIActionSelectionChanged:=zcUI.GetUniqueZMessageID;
  //zcMsgUIActionSetNormalFocus:=zcUI.GetUniqueZMessageID;
  zcMsgUIActionRedrawContent:=zcUI.GetUniqueZMessageID;
  zcMsgUIActionRedraw:=zcUI.GetUniqueZMessageID;
  zcMsgUIActionRebuild:=zcUI.GetUniqueZMessageID;
  zcMsgUIResetOGLWNDProc:=zcUI.GetUniqueZMessageID;
  zcMsgUITimerTick:=zcUI.GetUniqueZMessageID;
  zcMsgUIRePrepareObject:=zcUI.GetUniqueZMessageID;
  zcMsgUISetDefaultObject:=zcUI.GetUniqueZMessageID;
  zcMsgUIReturnToDefaultObject:=zcUI.GetUniqueZMessageID;
  zcMsgUIFreEditorProc:=zcUI.GetUniqueZMessageID;
  zcMsgUIStoreAndFreeEditorProc:=zcUI.GetUniqueZMessageID;
  zcMsgUIBeforeCloseApp:=zcUI.GetUniqueZMessageID;
finalization
  zcUI.free;
  ZCStatekInterface.Free;
end.
