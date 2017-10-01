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
unit uzcinterface;
{$INCLUDE def.inc}
interface
uses uzcstrconsts,uzedimensionaltypes,gzctnrstl,zeundostack,varmandef,forms,classes,uzbtypes,LCLType;
const
     MenuNameModifier='MENU_';

type
  TZMessageID=type integer;
var
  ZMsgID_GUIEnable:TZMessageID=-1;
  ZMsgID_GUIDisable:TZMessageID=-1;
  ZMsgID_GUIEnableCMDLine:TZMessageID=-1;
  ZMsgID_GUIDisableCMDLine:TZMessageID=-1;

  ZMsgID_GUICMDLineReadyMode:TZMessageID=-1;
  ZMsgID_GUICMDLineRunMode:TZMessageID=-1;

  ZMsgID_GUIActionSelectionChanged:TZMessageID=-1;
  ZMsgID_GUIActionSetNormalFocus:TZMessageID=-1;

  ZMsgID_GUIActionRedrawContent:TZMessageID=-1;
  ZMsgID_GUIActionRedraw:TZMessageID=-1;

  ZMsgID_GUIResetOGLWNDProc:TZMessageID=-1;//надо убрать это чудо
  ZMsgID_GUITimerTick:TZMessageID=-1;

type
    TProcedure_String_=procedure(s:String);
    TProcedure_String_HandlersVector=TMyVector<TProcedure_String_>;

    TMethod_TForm_=procedure (ShowedForm:TForm) of object;
    TMethod_TForm_HandlersVector=TMyVector<TMethod_TForm_>;

    TProcedure_TZMessageID=procedure(GUIMode:TZMessageID);
    TProcedure_TZMessageID_HandlersVector=TMyVector<TProcedure_TZMessageID>;

    TSimpleProcedure_TZMessageID=Procedure(GUIAction:TZMessageID);
    TSimpleProcedure=Procedure;
    TSimpleProcedure_TZMessageID_HandlersVector=TMyVector<TSimpleProcedure_TZMessageID>;

    TSimpleLCLMethod_TZMessageID=Procedure (sender:TObject;GUIAction:TZMessageID) of object;
    TSimpleLCLMethod_HandlersVector=TMyVector<TSimpleLCLMethod_TZMessageID>;

    TTextMessageWriteOptions=(TMWOToConsole,            //вывод сообщения в консоль
                              TMWOToLog,                //вывод в log
                              TMWOToQuicklyReplaceable, //вывод в статусную строку
                              TMWOToModal,              //messagebox
                              TMWOWarning,              //оформить как варнинг
                              TMWOError);               //оформить как ошибку

    TTextMessageWriteOptionsSet=set of TTextMessageWriteOptions;

const
    TMWOHistoryOut=[TMWOToConsole,TMWOToLog];
    TMWOShowError=[TMWOToConsole,TMWOToLog,TMWOToModal,TMWOError];
    TMWOSilentShowError=[TMWOToConsole,TMWOToLog,TMWOError];
    TMWOMessageBox=[TMWOToConsole,TMWOToLog,TMWOToModal];
    TMWOQuickly=[TMWOToQuicklyReplaceable];
type
    TZCMsgCallBackInterface=class
      public
        constructor Create;
        function GetUniqueZMessageID:TZMessageID;
        procedure RegisterHandler_HistoryOut(Handler:TProcedure_String_);
        procedure RegisterHandler_LogError(Handler:TProcedure_String_);
        procedure RegisterHandler_StatusLineTextOut(Handler:TProcedure_String_);

        procedure RegisterHandler_BeforeShowModal(Handler:TMethod_TForm_);
        procedure RegisterHandler_AfterShowModal(Handler:TMethod_TForm_);

        procedure RegisterHandler_GUIMode(Handler:TProcedure_TZMessageID);
        procedure RegisterHandler_GUIAction(Handler:TSimpleLCLMethod_TZMessageID);

        procedure Do_HistoryOut(s:String);
        procedure Do_LogError(s:String);
        procedure Do_StatusLineTextOut(s:String);

        procedure Do_BeforeShowModal(ShowedForm:TForm);
        procedure Do_AfterShowModal(ShowedForm:TForm);

        procedure Do_GUIMode(GUIMode:TZMessageID);
        procedure Do_GUIaction(Sender:TObject;GUIaction:TZMessageID);

        procedure TextMessage(msg:String;opt:TTextMessageWriteOptionsSet);
        function TextQuestion(Caption,Question:String;Flags: Longint):integer;
        function DoShowModal(MForm:TForm):Integer;
      private
        procedure RegisterTProcedure_String_HandlersVector(var PSHV:TProcedure_String_HandlersVector;Handler:TProcedure_String_);
        procedure Do_TProcedure_String_HandlersVector(var PSHV:TProcedure_String_HandlersVector;s:String);

        procedure RegisterTMethod_TForm_HandlersVector(var MFHV:TMethod_TForm_HandlersVector;Handler:TMethod_TForm_);
        procedure Do_TMethod_TForm_HandlersVector(var MFHV:TMethod_TForm_HandlersVector;ShowedForm:TForm);

        procedure RegisterTProcedure_TGUIMode_HandlersVector(var PGUIMHV:TProcedure_TZMessageID_HandlersVector;Handler:TProcedure_TZMessageID);
        procedure Do_TProcedure_TZMessageID_HandlersVector(var PGUIMHV:TProcedure_TZMessageID_HandlersVector;GUIMode:TZMessageID);

        procedure RegisterTProcedure_TSimpleLCLMethod_HandlersVector(var SMHV:TSimpleLCLMethod_HandlersVector;Handler:TSimpleLCLMethod_TZMessageID);
        procedure Do_TSimpleLCLMethod_HandlersVector(var SMHV:TSimpleLCLMethod_HandlersVector;Sender:TObject;GUIAction:TZMessageID);


      private
        ZMessageIDSeed:TZMessageID;
        HistoryOutHandlers:TProcedure_String_HandlersVector;
        LogErrorHandlers:TProcedure_String_HandlersVector;
        StatusLineTextOutHandlers:TProcedure_String_HandlersVector;

        BeforeShowModalHandlers:TMethod_TForm_HandlersVector;
        AfterShowModalHandlers:TMethod_TForm_HandlersVector;

        GUIModeHandlers:TProcedure_TZMessageID_HandlersVector;
        GUIActionsHandlers:TSimpleLCLMethod_HandlersVector;
    end;

    TStartLongProcessProc=Procedure(a:integer;s:string) of object;
    TProcessLongProcessProc=Procedure(a:integer) of object;
    TEndLongProcessProc=Procedure of object;
    //Abstract
    TOIReturnToDefaultProcedure=Procedure(const f:TzeUnitsFormat);
    TSimpleMethod=Procedure of object;
    TOIClearIfItIs_Pointer_=Procedure(const f:TzeUnitsFormat;p:pointer);
    TMethod_PtrInt_=procedure (Data: PtrInt) of object;
    TMethod__Pointer=function:Pointer of object;
    TFunction__Integer=Function:integer;
    TFunction__Boolean=Function:boolean;
    TFunction__Pointer=Function:Pointer;
    TFunction__TComponent=Function:TComponent;
    TMethod_String_=procedure (s:String) of object;
    TProcedure_PAnsiChar_=procedure (s:PAnsiChar);

    //ObjInsp
    TSetGDBObjInsp=procedure(const UndoStack:PTZctnrVectorUndoCommands;const f:TzeUnitsFormat;exttype:PUserTypeDescriptor; addr,context:Pointer;popoldpos:boolean=false);

    //UGDBDescriptor
    TSetCurrentDrawing=function(PDWG:Pointer):Pointer;//нужно завязать на UGDBDrawingdef

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
   ReStoreGDBObjInspProc:TFunction__Boolean;
   ReturnToDefaultProc:TOIReturnToDefaultProcedure;
   ClrarIfItIsProc:TOIClearIfItIs_Pointer_;
   GetCurrentObjProc:TFunction__Pointer;
   GetNameColWidthProc:TFunction__Integer;
   GetOIWidthProc:TFunction__Integer;

   GetPeditorProc:TFunction__TComponent;


   SetGDBObjInspProc:TSetGDBObjInsp;
   //StoreAndSetGDBObjInspProc:TSetGDBObjInsp;

   //UpdateObjInspProc        :TSimpleLCLMethod_TZMessageID;
   ReBuildProc              :TSimpleProcedure;
   SetCurrentObjDefaultProc :TSimpleProcedure;
   FreEditorProc            :TSimpleProcedure;
   StoreAndFreeEditorProc   :TSimpleProcedure;

   //mainwindow
   ProcessFilehistoryProc:TMethod_String_;
   AddOneObjectProc:TSimpleMethod;
   SetVisuaProplProc:TSimpleMethod;
   AppCloseProc:TMethod_PtrInt_;

   //UGDBDescriptor
   SetCurrentDWGProc:TSetCurrentDrawing;
   _GetUndoStack:TMethod__Pointer;

function GetUndoStack:pointer;
var
   ZCMsgCallBackInterface:TZCMsgCallBackInterface;
implementation
constructor TZCMsgCallBackInterface.Create;
begin
  ZMessageIDSeed:=0;
end;
function TZCMsgCallBackInterface.GetUniqueZMessageID:TZMessageID;
begin
  inc(ZMessageIDSeed);
  result:=ZMessageIDSeed;
end;
function TZCMsgCallBackInterface.TextQuestion(Caption,Question:String;Flags: Longint):integer;
var
   pc:PChar;
   ps:PChar;
begin
  if Question<>'' then ps:=@Question[1]
                  else ps:=nil;
  if Caption<>'' then pc:=@Caption[1]
                 else pc:=nil;
  Do_BeforeShowModal(nil);
  result:=application.MessageBox(ps,pc,Flags);
  Do_AfterShowModal(nil);
end;

procedure TZCMsgCallBackInterface.TextMessage(msg:String;opt:TTextMessageWriteOptionsSet);
var
   Caption: string;
   ps:PChar;
   Flags: Longint;
begin
     if TMWOToModal in opt then begin
       if TMWOWarning in opt then begin
         Caption:=rsWarningCaption;
         msg:=rsWarningPrefix+msg;
         Flags:=MB_OK or MB_ICONWARNING;
       end
  else if TMWOError in opt then begin
         Caption:=rsErrorCaption;
         msg:=rsErrorPrefix+msg;
         Flags:=MB_ICONERROR;
       end
  else begin
          Caption:=rsMessageCaption;
          Flags:=MB_OK;
       end;

       if msg<>'' then ps:=@msg[1]
                  else ps:=nil;

       Do_BeforeShowModal(nil);

       application.MessageBox(ps,@Caption[1],Flags);

       Do_AfterShowModal(nil);
     end else begin
       if TMWOWarning in opt then begin
         msg:=rsWarningPrefix+msg;
       end
  else if TMWOError in opt then begin
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

procedure TZCMsgCallBackInterface.RegisterTProcedure_String_HandlersVector(var PSHV:TProcedure_String_HandlersVector;Handler:TProcedure_String_);
begin
   if not assigned(PSHV) then
     PSHV:=TProcedure_String_HandlersVector.Create;
   PSHV.PushBack(Handler);
end;
procedure TZCMsgCallBackInterface.Do_TProcedure_String_HandlersVector(var PSHV:TProcedure_String_HandlersVector;s:String);
var
   i:integer;
begin
   if assigned(PSHV) then begin
     for i:=0 to PSHV.Size-1 do
       PSHV[i](s);
   end;
end;
procedure TZCMsgCallBackInterface.RegisterTMethod_TForm_HandlersVector(var MFHV:TMethod_TForm_HandlersVector;Handler:TMethod_TForm_);
begin
   if not assigned(MFHV) then
     MFHV:=TMethod_TForm_HandlersVector.Create;
   MFHV.PushBack(Handler);
end;
procedure TZCMsgCallBackInterface.Do_TMethod_TForm_HandlersVector(var MFHV:TMethod_TForm_HandlersVector;ShowedForm:TForm);
var
   i:integer;
begin
   if assigned(MFHV) then begin
     for i:=0 to MFHV.Size-1 do
       MFHV[i](ShowedForm);
   end;
end;
procedure TZCMsgCallBackInterface.RegisterTProcedure_TGUIMode_HandlersVector(var PGUIMHV:TProcedure_TZMessageID_HandlersVector;Handler:TProcedure_TZMessageID);
begin
   if not assigned(PGUIMHV) then
     PGUIMHV:=TProcedure_TZMessageID_HandlersVector.Create;
   PGUIMHV.PushBack(Handler);
end;
procedure TZCMsgCallBackInterface.Do_TProcedure_TZMessageID_HandlersVector(var PGUIMHV:TProcedure_TZMessageID_HandlersVector;GUIMode:{TGUIMode}TZMessageID);
var
   i:integer;
begin
   if assigned(PGUIMHV) then begin
     for i:=0 to PGUIMHV.Size-1 do
       PGUIMHV[i](GUIMode);
   end;
end;

procedure TZCMsgCallBackInterface.RegisterTProcedure_TSimpleLCLMethod_HandlersVector(var SMHV:TSimpleLCLMethod_HandlersVector;Handler:TSimpleLCLMethod_TZMessageID);
begin
   if not assigned(SMHV) then
     SMHV:=TSimpleLCLMethod_HandlersVector.Create;
   SMHV.PushBack(Handler);
end;
procedure TZCMsgCallBackInterface.Do_TSimpleLCLMethod_HandlersVector(var SMHV:TSimpleLCLMethod_HandlersVector;Sender:TObject;GUIAction:TZMessageID);
var
   i:integer;
begin
   if assigned(SMHV) then begin
     for i:=0 to SMHV.Size-1 do
       SMHV[i](sender,GUIAction);
   end;
end;
procedure TZCMsgCallBackInterface.RegisterHandler_HistoryOut(Handler:TProcedure_String_);
begin
   RegisterTProcedure_String_HandlersVector(HistoryOutHandlers,Handler);
end;
procedure TZCMsgCallBackInterface.RegisterHandler_LogError(Handler:TProcedure_String_);
begin
   RegisterTProcedure_String_HandlersVector(LogErrorHandlers,Handler);
end;
procedure TZCMsgCallBackInterface.RegisterHandler_StatusLineTextOut(Handler:TProcedure_String_);
begin
   RegisterTProcedure_String_HandlersVector(StatusLineTextOutHandlers,Handler);
end;
procedure TZCMsgCallBackInterface.RegisterHandler_BeforeShowModal(Handler:TMethod_TForm_);
begin
   RegisterTMethod_TForm_HandlersVector(BeforeShowModalHandlers,Handler);
end;
procedure TZCMsgCallBackInterface.RegisterHandler_AfterShowModal(Handler:TMethod_TForm_);
begin
   RegisterTMethod_TForm_HandlersVector(AfterShowModalHandlers,Handler);
end;
procedure TZCMsgCallBackInterface.RegisterHandler_GUIMode(Handler:TProcedure_TZMessageID);
begin
   RegisterTProcedure_TGUIMode_HandlersVector(GUIModeHandlers,Handler);
end;
procedure TZCMsgCallBackInterface.RegisterHandler_GUIAction(Handler:TSimpleLCLMethod_TZMessageID);
begin
   RegisterTProcedure_TSimpleLCLMethod_HandlersVector(GUIActionsHandlers,Handler);
end;
procedure TZCMsgCallBackInterface.Do_HistoryOut(s:String);
begin
   Do_TProcedure_String_HandlersVector(HistoryOutHandlers,s);
end;
procedure TZCMsgCallBackInterface.Do_LogError(s:String);
begin
   Do_TProcedure_String_HandlersVector(LogErrorHandlers,s);
end;
procedure TZCMsgCallBackInterface.Do_StatusLineTextOut(s:String);
begin
   Do_TProcedure_String_HandlersVector(StatusLineTextOutHandlers,s);
end;
procedure TZCMsgCallBackInterface.Do_BeforeShowModal(ShowedForm:TForm);
begin
   Do_TMethod_TForm_HandlersVector(BeforeShowModalHandlers,ShowedForm);
end;
procedure TZCMsgCallBackInterface.Do_AfterShowModal(ShowedForm:TForm);
begin
   Do_TMethod_TForm_HandlersVector(AfterShowModalHandlers,ShowedForm);
end;
procedure TZCMsgCallBackInterface.Do_GUIMode(GUIMode:TZMessageID);
begin
   Do_TProcedure_TZMessageID_HandlersVector(GUIModeHandlers,GUIMode);
end;
procedure TZCMsgCallBackInterface.Do_GUIaction(Sender:TObject;GUIaction:TZMessageID);
begin
   Do_TSimpleLCLMethod_HandlersVector(GUIActionsHandlers,Sender,GUIaction);
end;
function TZCMsgCallBackInterface.DoShowModal(MForm:TForm): Integer;
begin
     Do_BeforeShowModal(MForm);
     result:=MForm.ShowModal;
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
  ZCMsgCallBackInterface:=TZCMsgCallBackInterface.create;
  ZMsgID_GUIEnable:=ZCMsgCallBackInterface.GetUniqueZMessageID;
  ZMsgID_GUIDisable:=ZCMsgCallBackInterface.GetUniqueZMessageID;
  ZMsgID_GUIEnableCMDLine:=ZCMsgCallBackInterface.GetUniqueZMessageID;
  ZMsgID_GUIDisableCMDLine:=ZCMsgCallBackInterface.GetUniqueZMessageID;

  ZMsgID_GUICMDLineReadyMode:=ZCMsgCallBackInterface.GetUniqueZMessageID;
  ZMsgID_GUICMDLineRunMode:=ZCMsgCallBackInterface.GetUniqueZMessageID;

  ZMsgID_GUIActionSelectionChanged:=ZCMsgCallBackInterface.GetUniqueZMessageID;
  ZMsgID_GUIActionSetNormalFocus:=ZCMsgCallBackInterface.GetUniqueZMessageID;
  ZMsgID_GUIActionRedrawContent:=ZCMsgCallBackInterface.GetUniqueZMessageID;
  ZMsgID_GUIActionRedraw:=ZCMsgCallBackInterface.GetUniqueZMessageID;
  ZMsgID_GUIResetOGLWNDProc:=ZCMsgCallBackInterface.GetUniqueZMessageID;
  ZMsgID_GUITimerTick:=ZCMsgCallBackInterface.GetUniqueZMessageID;
finalization
  ZCMsgCallBackInterface.free;
end.
