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
  StdCtrls,gdbasetypes,Controls,Classes,LCLType;

procedure SetcomboItemsCount(cb:tcombobox;ItemsCount:integer);
procedure ComboBoxDrawItem(Control:TWinControl;ARect:TRect;State:TOwnerDrawState);
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
             cb.Items.Delete(1);
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


end.
