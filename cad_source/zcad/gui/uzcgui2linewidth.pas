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

unit uzcgui2linewidth;
{$INCLUDE def.inc}

interface

uses
  uzeconsts,uzcflineweights,usupportgui,StdCtrls,uzcdrawings,
  Controls,Classes,strproc,uzcsysvars,uzccommandsmanager;

type
  TSupportLineWidthCombo = class
                             class procedure LineWBoxDrawItem(Control: TWinControl; Index: Integer; ARect: TRect;
                                                              State: StdCtrls.TOwnerDrawState);
  end;

implementation
uses
  uzcmainwindow;
class procedure TSupportLineWidthCombo.LineWBoxDrawItem(Control: TWinControl; Index: Integer; ARect: TRect;
                                                        State: StdCtrls.TOwnerDrawState);
var
   ll:integer;
   s:string;
begin
    if gdb.GetCurrentDWG=nil then
                                 exit;
    ComboBoxDrawItem(Control,ARect,State);
    if not TComboBox(Control).DroppedDown then
                                      begin
                                           index:=IVars.CLWeight;
                                      end
                                 else
                                     index:=integer(tcombobox(Control).items.Objects[Index]);
   s:=GetLWNameFromLW(index);
   if (index<4)or(index=ClDifferent) then
              ll:=0
          else
              ll:=30;
    ARect.Left:=ARect.Left+2;
    drawLW(TComboBox(Control).canvas,ARect,ll,(index) div 10,s);
end;

end.
