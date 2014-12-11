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

unit usuptypededitors;
{$INCLUDE def.inc}

interface

uses
  usupportgui,Varman,UBaseTypeDescriptor,varmandef,StdCtrls,sysutils,Forms,UGDBDescriptor,zcadstrconsts,Controls,Classes,UGDBTextStyleArray,strproc,zcadsysvars,commandline,zcadinterface;

type
  TOnUpdateControl=procedure (AEditedControl:TObject)of object;
  TSupportTypedEditors = class
    PEditor:TPropEditor;
    EditedControl:TObject;
    OnUpdateEditedControl:TOnUpdateControl;

    procedure freeeditor;
    function createeditor(const TheOwner:TPropEditorOwner; const AEditedControl:TObject; const r: TRect; const variable; const vartype:String):boolean;
    procedure Notify(Sender: TObject;Command:TMyNotifyCommand); virtual;
    procedure asyncfreeeditor(Data: PtrInt);
  end;

implementation
procedure TSupportTypedEditors.Notify(Sender: TObject;Command:TMyNotifyCommand);
begin
  if sender=PEditor then
  begin
    if (Command=TMNC_EditingDoneEnterKey)or(Command=TMNC_EditingDoneLostFocus) then
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
  if peditor<>nil then
  begin
       Application.RemoveAsyncCalls(self);
       freeandnil(peditor);
       if assigned(OnUpdateEditedControl) then
                                              OnUpdateEditedControl(EditedControl);
       EditedControl:=nil;
  end;
end;
function TSupportTypedEditors.createeditor(const TheOwner:TPropEditorOwner; const AEditedControl:TObject; const r: TRect; const variable; const vartype:String):boolean;
var
  needdropdown:boolean;
begin
     needdropdown:=false;
     freeeditor;
     if uppercase(vartype)='TENUMDATA' then
     begin
      PEditor:=GDBEnumDataDescriptorObj.CreateEditor(TheOwner,r,@variable,nil,true).Editor;
      needdropdown:=true;
     end
     else
     PEditor:=SysUnit^.TypeName2PTD(vartype)^.CreateEditor(TheOwner,r,@variable,nil,true).Editor;
     if PEditor.geteditor is TComboBox then
                                           begin
                                           SetComboSize(TComboBox(PEditor.geteditor),r.Bottom-r.Top-5);
                                           TComboBox(PEditor.geteditor).DropDownCount:=30;
                                           end;
     PEditor.geteditor.BoundsRect:=r;
     PEditor.geteditor.Parent:=TheOwner;
     PEditor.geteditor.SetFocus;
     if needdropdown then
      TComboBox(PEditor.geteditor).DroppedDown:=true;
     PEditor.OwnerNotify:=Notify;
     EditedControl:=AEditedControl;
end;

end.
