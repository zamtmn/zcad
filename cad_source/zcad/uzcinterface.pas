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
    TProcedure_String_=procedure(s:String);
    TProcedure_String_HandlersVector=TMyVector<TProcedure_String_>;

    TMethod_TForm_=Procedure (ShowedForm:TForm) of object;
    TMethod_TForm_HandlersVector=TMyVector<TMethod_TForm_>;

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
        procedure RegisterHandler_HistoryOut(Handler:TProcedure_String_);
        procedure RegisterHandler_LogError(Handler:TProcedure_String_);
        procedure RegisterHandler_StatusLineTextOut(Handler:TProcedure_String_);

        procedure RegisterHandler_BeforeShowModal(Handler:TMethod_TForm_);
        procedure RegisterHandler_AfterShowModal(Handler:TMethod_TForm_);

        procedure Do_HistoryOut(s:String);
        procedure Do_LogError(s:String);
        procedure Do_StatusLineTextOut(s:String);

        procedure Do_BeforeShowModal(ShowedForm:TForm);
        procedure Do_AfterShowModal(ShowedForm:TForm);

        procedure TextMessage(msg:String;opt:TTextMessageWriteOptionsSet);
        function TextQuestion(Caption,Question:String;Flags: Longint):integer;
        function DoShowModal(MForm:TForm):Integer;
      private
        procedure RegisterTProcedure_String_HandlersVector(var PSHV:TProcedure_String_HandlersVector;Handler:TProcedure_String_);
        procedure Do_TProcedure_String_HandlersVector(var PSHV:TProcedure_String_HandlersVector;s:String);

        procedure RegisterTMethod_TForm_HandlersVector(var MFHV:TMethod_TForm_HandlersVector;Handler:TMethod_TForm_);
        procedure Do_TMethod_TForm_HandlersVector(var MFHV:TMethod_TForm_HandlersVector;ShowedForm:TForm);

      private
        HistoryOutHandlers:TProcedure_String_HandlersVector;
        LogErrorHandlers:TProcedure_String_HandlersVector;
        StatusLineTextOutHandlers:TProcedure_String_HandlersVector;

        BeforeShowModalHandlers:TMethod_TForm_HandlersVector;
        AfterShowModalHandlers:TMethod_TForm_HandlersVector;
    end;

    TStartLongProcessProc=Procedure(a:integer;s:string) of object;
    TProcessLongProcessProc=Procedure(a:integer) of object;
    TEndLongProcessProc=Procedure of object;
    //Abstract
    TSimpleProcedure=Procedure;
    TOIReturnToDefaultProcedure=Procedure(const f:TzeUnitsFormat);
    TSimpleMethod=Procedure of object;
    TSimpleLCLMethod=Procedure (sender:TObject) of object;
    TProcedure_Pointer_=Procedure(p:pointer);
    TOIClearIfItIs_Pointer_=Procedure(const f:TzeUnitsFormat;p:pointer);
    TProcedure_Integer_=Procedure(a:integer);
    TMethod_Integer_=Procedure(a:integer) of object;
    TMethod_PtrInt_=procedure (Data: PtrInt) of object;
    TMethod_IntegerString_=Procedure(a:integer;s:string) of object;
    TMethod__Pointer=function:Pointer of object;
    TFunction__Integer=Function:integer;
    TFunction__Boolean=Function:boolean;
    TFunction__Pointer=Function:Pointer;
    TFunction__TForm=Function:TForm;
    TFunction__TComponent=Function:TComponent;

    TMethod_String_=procedure (s:String) of object;
    //TProcedure_String_=procedure (s:String);
    TProcedure_PAnsiChar_=procedure (s:PAnsiChar);

    //SimpleProcOfObject=procedure of object;



    //ObjInsp
    TSetGDBObjInsp=procedure(const UndoStack:PTZctnrVectorUndoCommands;const f:TzeUnitsFormat;exttype:PUserTypeDescriptor; addr,context:Pointer);
    TStoreAndSetGDBObjInsp=procedure(const UndoStack:PTZctnrVectorUndoCommands;const f:TzeUnitsFormat;exttype:PUserTypeDescriptor; addr,context:Pointer);

    //mainwindow
    //TMessageBox=function(Text, Caption: PChar; Flags: Longint): Integer of object;

    //UGDBDescriptor
    TSetCurrentDrawing=function(PDWG:Pointer):Pointer;//нужно завязать на UGDBDrawingdef

    //cmdline
    TSetCommandLineMode=procedure(m:TCLineMode) of object;
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
   SetGDBObjInspProc:TSetGDBObjInsp;

   StoreAndSetGDBObjInspProc:TStoreAndSetGDBObjInsp;
   ReStoreGDBObjInspProc:TFunction__Boolean;
   UpdateObjInspProc:TSimpleProcedure;
   ReturnToDefaultProc:TOIReturnToDefaultProcedure;
   ClrarIfItIsProc:TOIClearIfItIs_Pointer_;
   ReBuildProc:TSimpleProcedure;
   SetCurrentObjDefaultProc:TSimpleProcedure;
   GetCurrentObjProc:TFunction__Pointer;
   GetNameColWidthProc:TFunction__Integer;
   GetOIWidthProc:TFunction__Integer;
   GetPeditorProc:TFunction__TComponent;
   FreEditorProc:TSimpleProcedure;
   StoreAndFreeEditorProc:TSimpleProcedure;

   //mainwindow
   //ShowAllCursorsProc,RestoreAllCursorsProc:TMethod_TForm_;
   //StartLongProcessProc:TStartLongProcessProc;
   //ProcessLongProcessProc:TProcessLongProcessProc;
   //EndLongProcessProc:TEndLongProcessProc;
   UpdateVisibleProc:TSimpleProcedure;
   //MessageBoxProc:TMessageBox;
   ProcessFilehistoryProc:TMethod_String_;
   AddOneObjectProc:TSimpleMethod;
   SetVisuaProplProc:TSimpleMethod;
   AppCloseProc:TMethod_PtrInt_;
   SetNormalFocus:TSimpleLCLMethod;

   //UGDBDescriptor
   RedrawOGLWNDProc:TSimpleProcedure;
   ResetOGLWNDProc:TSimpleProcedure;
   SetCurrentDWGProc:TSetCurrentDrawing;
   _GetUndoStack:TMethod__Pointer;

   waSetObjInspProc:TSimpleLCLMethod;

   //cmdline
   SetCommandLineMode:TSetCommandLineMode;

   DisableCmdLine:TSimpleProcedure;
   EnableCmdLine:TSimpleProcedure;


function GetUndoStack:pointer;
var
   ZCMsgCallBackInterface:TZCMsgCallBackInterface;
implementation
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
finalization
  ZCMsgCallBackInterface.free;
end.
