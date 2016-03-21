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
unit zcadinterface;
{$INCLUDE def.inc}
interface
uses uzelongprocesssupport,zeundostack,varmandef,forms,classes{,UGDBDrawingdef},gdbase;
const
     menutoken='MAINMENUITEM';
     popupmenutoken='POPUPMENU';
     submenutoken='MENUITEM';
     createmenutoken='CREATEMENU';
     setmainmenutoken='SETMAINMENU';
     MenuNameModifier='MENU_';

type
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


    //ObjInsp
    TSetGDBObjInsp=procedure(const UndoStack:PGDBObjOpenArrayOfUCommands;const f:TzeUnitsFormat;exttype:PUserTypeDescriptor; addr,context:Pointer);
    TStoreAndSetGDBObjInsp=procedure(const UndoStack:PGDBObjOpenArrayOfUCommands;const f:TzeUnitsFormat;exttype:PUserTypeDescriptor; addr,context:Pointer);

    //mainwindow
    TMessageBox=function(Text, Caption: PChar; Flags: Longint): Integer of object;

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
   CreateObjInspInstanceProc:TFunction__TForm;
   GetPeditorProc:TFunction__TComponent;
   FreEditorProc:TSimpleProcedure;
   StoreAndFreeEditorProc:TSimpleProcedure;

   //mainwindow
   ShowAllCursorsProc,RestoreAllCursorsProc:TSimpleMethod;
   StartLongProcessProc:TStartLongProcessProc;
   ProcessLongProcessProc:TProcessLongProcessProc;
   EndLongProcessProc:TEndLongProcessProc;
   UpdateVisibleProc:TSimpleProcedure;
   MessageBoxProc:TMessageBox;
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

   //cmdline
    SetCommandLineMode:TSetCommandLineMode;


function DoShowModal(MForm:TForm): Integer;
function MessageBox(Text, Caption: PChar; Flags: Longint): Integer;
function GetUndoStack:pointer;
implementation
function GetUndoStack:pointer;
begin
     if assigned(_GetUndoStack) then
                                    result:=_GetUndoStack
                                else
                                    result:=nil;
end;

function DoShowModal(MForm:TForm): Integer;
begin
     if assigned(ShowAllCursorsProc) then
                                         ShowAllCursorsProc;
     result:=MForm.ShowModal;
     if assigned(RestoreAllCursorsProc) then
                                         RestoreAllCursorsProc;
end;
function MessageBox(Text, Caption: PChar; Flags: Longint): Integer;
begin
     if assigned(ShowAllCursorsProc) then
                                         ShowAllCursorsProc;
     result:=application.MessageBox(Text, Caption,Flags);
     if assigned(RestoreAllCursorsProc) then
                                         RestoreAllCursorsProc;
end;

end.
