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

unit usupportgui;

interface

uses
  StdCtrls,Controls,Classes,LCLType,ComCtrls,Graphics,LMessages,LCLIntf;

type
  TIsShortcutFunc=function(var Message: TLMKey): boolean of object;
  TCBReadOnlyMode=(CBReadOnly,CBEditable,CBDoNotTouch);

procedure SetcomboItemsCount(cb:tcombobox;ItemsCount:integer);
procedure ComboBoxDrawItem(Control:TWinControl;ARect:TRect;State:TOwnerDrawState);
function ListViewDrawSubItem(State: TCustomDrawState;canvas:tcanvas;Item: TListItem;SubItem: Integer): TRect;
procedure SetComboSize(cb:tcombobox;ItemH:Integer;ReadOnlyMode:TCBReadOnlyMode);
function IsZEditableShortCut(var Message: TLMKey):boolean;
function IsZShortcut(var Message: TLMKey;const ActiveControl:TWinControl; const CMDEdit:TEdit; const OldFunction:TIsShortcutFunc): boolean;
implementation
function IsZEditableShortCut(var Message: TLMKey):boolean;
var
   chrcode:word;
   ss:tshiftstate;
begin
     chrcode:=Message.CharCode;
     ss:=MsgKeyDataToShiftState(Message.KeyData);
     if ssShift in ss then
                               chrcode:=chrcode or scShift;
    if ssCtrl in ss then
                              chrcode:=chrcode or scCtrl;

     case chrcode of
               (scCtrl or VK_V),
               (scCtrl or VK_A),
               (scCtrl or VK_C),
               (scCtrl or VK_INSERT),
               (scShift or VK_INSERT),
               (scCtrl or VK_Z),
               (scCtrl or scShift or VK_Z),
                VK_DELETE,
                VK_INSERT,
                VK_SPACE,
                VK_HOME,VK_END,
                VK_PRIOR,VK_NEXT,
                VK_BACK,
                VK_LEFT,
                VK_RIGHT,
                VK_UP,
                VK_DOWN,
                VK_0..VK_Z
                    :begin
                         result:=true;
                     end
                else result:=false;

     end;
end;
function IsZexceptionShortCut(var Message: TLMKey):boolean;
var
   chrcode:word;
   ss:tshiftstate;
begin
     chrcode:=Message.CharCode;
     ss:=MsgKeyDataToShiftState(Message.KeyData);
     case chrcode of
                VK_0..VK_Z
                    :begin
                         result:=true;
                     end
                else result:=false;

     end;
end;

function IsZShortcut(var Message: TLMKey;const ActiveControl:TWinControl; const CMDEdit:TEdit; const OldFunction:TIsShortcutFunc): boolean;
var
   IsEditableFocus:boolean;
   IsCommandNotEmpty:boolean;
   s:string;
begin
     if message.charcode<>VK_SHIFT then
     if message.charcode<>VK_CONTROL then
                                      IsCommandNotEmpty:=IsCommandNotEmpty;
  IsCommandNotEmpty:=false;
  IsEditableFocus:=false;
  if ActiveControl is tedit then begin
   IsEditableFocus:=true;
   IsCommandNotEmpty:=(ActiveControl as tedit).text<>'';
  end;
  IsEditableFocus:=(ActiveControl is tedit){and(ActiveControl<>cmdedit)};
  if not IsEditableFocus then begin
    if ActiveControl is tmemo then begin
      IsEditableFocus:=not ((ActiveControl as tmemo).ReadOnly);
      if not IsEditableFocus then
        IsEditableFocus:=(ActiveControl as tmemo).SelLength<>0;
    end;
    if not IsEditableFocus then
      if ActiveControl is TComboBox then
        IsEditableFocus:=True;
  end;

  if not IsEditableFocus then IsEditableFocus:=(ActiveControl is tcombobox);
  {if assigned(cmdedit) then
                           IsCommandNotEmpty:=((cmdedit.Text<>'')and(ActiveControl=cmdedit))
                       else
                           IsCommandNotEmpty:=false;}
  if IsZEditableShortCut(Message)
  and ((IsEditableFocus)or(IsCommandNotEmpty))
       then result:=false
       else
           begin
             if assigned(OldFunction) then
                                          exit(OldFunction(Message))
                                      else
                                          exit(false);
           end;
  if (not IsCommandNotEmpty)and not IsZexceptionShortCut(Message) then
  //if IsZexceptionShortCut(Message) then
    result:=OldFunction(Message)
end;
procedure SetComboSize(cb:tcombobox;ItemH:Integer;ReadOnlyMode:TCBReadOnlyMode);
begin
     cb.AutoSize:=false;
     {$IFDEF LCLWIN32}
     case ReadOnlyMode of
       CBReadOnly:cb.Style:=csOwnerDrawFixed;
       CBEditable:cb.Style:=csOwnerDrawEditableFixed;
     end;
     cb.ItemHeight:=ItemH;
     {$ENDIF}
end;

procedure SetcomboItemsCount(cb:tcombobox;ItemsCount:integer);
var
   i:integer;
begin
  //tcombobox(Sender).ItemIndex:=-1;

  //If use  Items.Clear and add items in GTK2 combobox close on mouseup

  //Add items if need
  if cb.Items.Count<ItemsCount then
  begin
        for i:=0 to ItemsCount-cb.Items.Count-1 do
        begin
             cb.AddItem('',nil);
        end;
  end;
  //Remove items if need
  if cb.Items.Count>ItemsCount then
  begin
        for i:=0 to cb.Items.Count-ItemsCount-1 do
        begin
             cb.Items.Delete(0);
        end;
  end;
end;
procedure ComboBoxDrawItem(Control:TWinControl;ARect:TRect;State:TOwnerDrawState);
begin
     //if not ({odSelected}{odComboBoxEdit}odDisabled in state) then
     if (state<>[])and(state<>[odHotLight])and(state<>[odBackgroundPainted]) then
     {ifdef windows}
     TComboBox(Control).canvas.FillRect(ARect);
     {endif}
end;

function ListViewDrawSubItem(State: TCustomDrawState;canvas:tcanvas;Item: TListItem;SubItem: Integer): TRect;
begin
     {$IF not (defined(LCLQt) or defined(LCLQt5))}
     if (cdsSelected in state) {or (cdsFocused in state)}{or Item.Selected} then
     {if (cdsSelected in state) or (cdsGrayed in state) or (cdsDisabled in state)
     or (cdsChecked in state) or (cdsFocused in state) or (cdsDefault in state)
     or (cdsHot in state) or (cdsMarked in state) or (cdsIndeterminate in state)then}
     begin
     canvas.Brush.Color:=clHighlight;
     canvas.Font.Color:=clHighlightText;
     end;
     {$IFNDEF LCLGTK2}
     result := Item.DisplayRectSubItem( SubItem,drBounds);
     canvas.FillRect(result);
     {$ENDIF}
     {$ENDIF}
     result := Item.DisplayRectSubItem( SubItem,drBounds);
end;


end.
