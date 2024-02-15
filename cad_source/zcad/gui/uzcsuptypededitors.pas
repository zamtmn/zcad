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

unit uzcsuptypededitors;
{$INCLUDE zengineconfig.inc}

interface

uses
  zeundostack,zebaseundocommands,usupportgui,Varman,UBaseTypeDescriptor,varmandef,
  StdCtrls,sysutils,Forms,Controls,Classes,uzbstrproc,uzcsysvars,
  uzccommandsmanager,uzcinterface,uzedimensionaltypes;

type
  TUndoContext=record
                       //ppropcurrentedit:PPropertyDeskriptor;
                       UndoStack:PTZctnrVectorUndoCommands;
                       UndoCommand:TTypedChangeCommand;
                 end;
  TOnUpdateControl=procedure (AEditedControl:TObject)of object;
  TUndoPrefixProcedure=procedure of object;
  TSupportTypedEditors = class
    PEditor:TPropEditor;
    EditedControl:TObject;
    OnUpdateEditedControl:TOnUpdateControl;
    UndoContext:TUndoContext;

    procedure freeeditor;
    function createeditor(const TheOwner:TPropEditorOwner; const AEditedControl:TObject; const r: TRect; const variable; const vartype:String;UndoPrefixProcedure:TUndoPrefixProcedure;preferedHeight:integer;f:TzeUnitsFormat; useinternalundo:boolean=true):boolean;
    procedure Notify(Sender: TObject;Command:TMyNotifyCommand); virtual;
    procedure asyncfreeeditor(Data: PtrInt);
    procedure ClearEDContext;
  end;

implementation
procedure TSupportTypedEditors.Notify(Sender: TObject;Command:TMyNotifyCommand);
begin
  if sender=PEditor then
  begin
       if UndoContext.UndoCommand<>nil then
                                         begin
                                              if peditor.changed then
                                                                     UndoContext.UndoCommand.ComitFromObj
                                                                 else
                                                                     UndoContext.UndoStack.KillLastCommand;
                                              ClearEDContext;
                                         end;
    if (Command=TMNC_EditingDoneEnterKey)or(Command=TMNC_EditingDoneLostFocus)or(Command=TMNC_EditingDoneDoNothing) then
                                    begin
                                    Application.QueueAsyncCall(asyncfreeeditor,0);
                                    end;
  end;
end;
procedure TSupportTypedEditors.asyncfreeeditor(Data: PtrInt);
begin
  if peditor<>nil then
  begin
       freeeditor;
  end;
end;
procedure TSupportTypedEditors.freeeditor;
begin
  if peditor<>nil then begin
  ClearEDContext;
  Application.RemoveAsyncCalls(self);
  peditor.geteditor.Hide;
  freeandnil(peditor);
  if assigned(OnUpdateEditedControl) and assigned(EditedControl) then
    OnUpdateEditedControl(EditedControl);
  EditedControl:=nil;
  end;
end;
procedure TSupportTypedEditors.ClearEDContext;
begin
     undocontext.UndoCommand:=nil;
     undocontext.UndoStack:=nil;
end;
function TSupportTypedEditors.createeditor(const TheOwner:TPropEditorOwner; const AEditedControl:TObject; const r: TRect; const variable; const vartype:String;UndoPrefixProcedure:TUndoPrefixProcedure;preferedHeight:integer;f:TzeUnitsFormat;useinternalundo:boolean=true):boolean;
var
  needdropdown:boolean;
  typemanager:PUserTypeDescriptor;
begin
     needdropdown:=false;
     freeeditor;
     if uppercase(vartype)='TENUMDATA' then
     begin
          typemanager:=@GDBEnumDataDescriptorObj;
      PEditor:=GDBEnumDataDescriptorObj.CreateEditor(TheOwner,r,@variable,nil,true,'',preferedHeight,f).Editor;
      needdropdown:=true;
     end
     else
     begin
          typemanager:=SysUnit^.TypeName2PTD(vartype);
          PEditor:=typemanager^.CreateEditor(TheOwner,r,@variable,nil,true,'',preferedHeight,f).Editor;
     end;
     if assigned(peditor) then
     if assigned(PEditor.geteditor) then
     begin
       if PEditor.geteditor is TComboBox then
                                             begin
                                             SetComboSize(TComboBox(PEditor.geteditor),r.Bottom-r.Top-5,CBDoNotTouch);
                                             TComboBox(PEditor.geteditor).DropDownCount:=30;
                                             end;
       PEditor.geteditor.BoundsRect:=r;
       PEditor.geteditor.Parent:=TheOwner;
       //тут педитор может быть асинхронно пришиблен
       if not assigned(peditor) then
         exit(false);
       PEditor.geteditor.SetFocus;
       if needdropdown then
        TComboBox(PEditor.geteditor).DroppedDown:=true;
       PEditor.OwnerNotify:=Notify;
       EditedControl:=AEditedControl;
       ClearEDContext;
       if assigned(UndoPrefixProcedure) then
                                            UndoPrefixProcedure;
       if useinternalundo then
        begin
       undocontext.UndoStack:=GetUndoStack;
       if undocontext.UndoStack<>nil then
        begin
         undocontext.UndoCommand:=undocontext.UndoStack.PushCreateTTypedChangeCommand(@variable,typemanager);
        end;
        end;
     end;
end;

end.
