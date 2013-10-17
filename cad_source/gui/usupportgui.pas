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
{$INCLUDE def.inc}

interface

uses
  StdCtrls,gdbasetypes,Controls,Classes,LCLType,ComCtrls,Graphics;

procedure SetcomboItemsCount(cb:tcombobox;ItemsCount:integer);
procedure ComboBoxDrawItem(Control:TWinControl;ARect:TRect;State:TOwnerDrawState);
function ListViewDrawSubItem(State: TCustomDrawState;canvas:tcanvas;Item: TListItem;SubItem: Integer): TRect;
implementation
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
     if (state<>[])and(state<>[odHotLight])and(state<>[odPainted]) then
     {ifdef windows}
     TComboBox(Control).canvas.FillRect(ARect);
     {endif}
end;

function ListViewDrawSubItem(State: TCustomDrawState;canvas:tcanvas;Item: TListItem;SubItem: Integer): TRect;
begin
     {$IFNDEF LCLQT}
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