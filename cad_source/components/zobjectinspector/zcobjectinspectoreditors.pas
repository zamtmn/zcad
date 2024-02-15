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

unit zcobjectinspectoreditors;

{$MODE DELPHI}

interface

uses
  UEnumDescriptor,zcobjectinspector,Forms,sysutils,
  Graphics,LCLType,Themes,uzctnrvectorstrings,
  varmandef,Varman,uzbtypes,usupportgui,
  gzctnrVectorTypes,StdCtrls,Controls,Classes,uzbstrproc,uzedimensionaltypes;
type
    TBaseTypesEditors=class
                             class function BaseCreateEditor           (TheOwner:TPropEditorOwner;rect:trect;pinstance:pointer;psa:PTZctnrVectorStrings;FreeOnLostFocus:boolean;InitialValue:String;ptdesc:PUserTypeDescriptor;preferedHeight:integer;f:TzeUnitsFormat):TEditorDesc;
                             class function BooleanCreateEditor        (TheOwner:TPropEditorOwner;rect:trect;pinstance:pointer;psa:PTZctnrVectorStrings;FreeOnLostFocus:boolean;InitialValue:String;ptdesc:PUserTypeDescriptor;preferedHeight:integer;f:TzeUnitsFormat):TEditorDesc;
                             class function TEnumDataCreateEditor      (TheOwner:TPropEditorOwner;rect:trect;pinstance:pointer;psa:PTZctnrVectorStrings;FreeOnLostFocus:boolean;InitialValue:String;ptdesc:PUserTypeDescriptor;preferedHeight:integer;f:TzeUnitsFormat):TEditorDesc;
                             class function EnumDescriptorCreateEditor (TheOwner:TPropEditorOwner;rect:trect;pinstance:pointer;psa:PTZctnrVectorStrings;FreeOnLostFocus:boolean;InitialValue:String;ptdesc:PUserTypeDescriptor;preferedHeight:integer;f:TzeUnitsFormat):TEditorDesc;
    end;
implementation
class function TBaseTypesEditors.BaseCreateEditor;
   var
      ps:pString;
      ir:itrec;
      propeditor:TPropEditor;
      edit:TEdit;
      cbedit:TComboBox;
   begin
        result.editor:=nil;
        result.mode:=TEM_Nothing;
        if (psa=nil)or(psa^.count=0) then
                            begin
                                  propeditor:=TPropEditor.Create(theowner,PInstance,ptdesc^,FreeOnLostFocus,f);

                                  edit:=TEdit.Create(propeditor);
                                  edit.AutoSize:=false;
                                  if initialvalue='' then
                                                         edit.Text:=ptdesc^.GetFormattedValueAsString(pinstance,f)
                                                     else
                                                         edit.Text:=initialvalue;
                                  edit.OnKeyPress:=propeditor.keyPress;
                                  edit.OnChange:=propeditor.EditingProcess;
                                  edit.OnExit:=propeditor.ExitEdit;

                                 result.editor:=propeditor;
                                 result.mode:=TEM_Integrate;
                            end
                        else
                            begin
                                 propeditor:=TPropEditor.Create(theowner,PInstance,ptdesc^,FreeOnLostFocus,f);
                                 cbedit:=TComboBox.Create(propeditor);
                                 {$IFNDEF DELPHI}
                                 cbedit.AutoSize:=false;
                                 {$ENDIF}
                                 if initialvalue='' then
                                                        cbedit.Text:=ptdesc^.GetFormattedValueAsString(pinstance,f)
                                                    else
                                                        cbedit.Text:=initialvalue;
                                 cbedit.OnKeyPress:=propeditor.keyPress;
                                 cbedit.OnChange:=propeditor.EditingProcess;
                                 cbedit.OnExit:=propeditor.ExitEdit;

                                 result.editor:=propeditor;
                                 result.mode:=TEM_Integrate;
                                       ps:=psa^.beginiterate(ir);
                                        if (ps<>nil) then
                                        repeat
                                             {if uppercase(ps^)=uppercase(s) then
                                                                begin
                                                                     exit;
                                                                end;}
                                             cbedit.Items.Add(ps^);
                                             //PZComboEdBoxWithProc(result).AddLine(pansichar(ps^));
                                             ps:=psa^.iterate(ir);
                                        until ps=nil;
                                  {$IFNDEF DELPHI}
                                  cbedit.AutoSelect:=true;
                                  {$ENDIF}
                                  cbedit.AutoComplete:=true;
                            end;
   end;
class function TBaseTypesEditors.BooleanCreateEditor;
var
    cbedit:TComboBox;
    propeditor:TPropEditor;
begin
     propeditor:=TPropEditor.Create(theowner,PInstance,ptdesc^,FreeOnLostFocus,f);
     cbedit:=TComboBox.Create(propeditor);
     cbedit.Text:=ptdesc^.GetValueAsString(pinstance);
     cbedit.OnChange:=propeditor.EditingProcess;
     SetComboSize(cbedit,{sysvar.INTF.INTF_DefaultControlHeight^}preferedHeight-6,CBReadOnly);
     {$IFNDEF DELPHI}
     cbedit.Style:=csDropDownList;
     {$ENDIF}

     cbedit.Items.Add('True');
     cbedit.Items.Add('False');
     if pBoolean(pinstance)^ then
                                    cbedit.ItemIndex:=0
                                else
                                    cbedit.ItemIndex:=1;

     result.editor:=propeditor;
     result.mode:=TEM_Integrate;
end;
class function TBaseTypesEditors.TEnumDataCreateEditor;
var
    cbedit:TComboBox;
    propeditor:TPropEditor;
    ir:itrec;
    p:pString;
begin
     propeditor:=TPropEditor.Create(theowner,PInstance,ptdesc^,FreeOnLostFocus,f);
     cbedit:=TComboBox.Create(propeditor);
     cbedit.Text:=ptdesc^.GetValueAsString(pinstance);
     cbedit.OnChange:=propeditor.EditingProcess;
     cbedit.OnExit:=propeditor.ExitEdit;
     SetComboSize(cbedit,{sysvar.INTF.INTF_DefaultControlHeight^}preferedHeight-6,CBReadOnly);
     {$IFNDEF DELPHI}
     cbedit.Style:=csDropDownList;
     {$ENDIF}

                             p:=PTEnumData(Pinstance)^.Enums.beginiterate(ir);
                             if p<>nil then
                             repeat
                                   cbedit.Items.Add(p^);
                                   p:=PTEnumData(Pinstance)^.Enums.iterate(ir);
                             until p=nil;

     cbedit.ItemIndex:=PTEnumData(Pinstance)^.Selected;

     result.editor:=propeditor;
     result.mode:=TEM_Integrate;
end;
class function TBaseTypesEditors.EnumDescriptorCreateEditor;
var
    cbedit:TComboBox;
    propeditor:TPropEditor;
    ir:itrec;
    number:LongWord;
    p:pString;
begin
     propeditor:=TPropEditor.Create(theowner,PInstance,ptdesc^,FreeOnLostFocus,f);
     cbedit:=TComboBox.Create(propeditor);
     cbedit.Text:=ptdesc^.GetValueAsString(pinstance);
     cbedit.OnChange:=propeditor.EditingProcess;
     SetComboSize(cbedit,{sysvar.INTF.INTF_DefaultControlHeight^}preferedHeight-6,CBReadOnly);
     {$IFNDEF DELPHI}
     cbedit.Style:=csDropDownList;
     {$ENDIF}

                             p:=PEnumDescriptor(ptdesc)^.UserValue.beginiterate(ir);
                             if p<>nil then
                             repeat
                                   cbedit.Items.Add(p^);
                                   p:=PEnumDescriptor(ptdesc)^.UserValue.iterate(ir);
                             until p=nil;

     PEnumDescriptor(ptdesc)^.GetNumberInArrays(PInstance,number);
     cbedit.ItemIndex:=number;

     result.editor:=propeditor;
     result.mode:=TEM_Integrate;
end;
end.
