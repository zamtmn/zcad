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

unit uzcgui2color;
{$INCLUDE zengineconfig.inc}

interface

uses
  uzcinterfacedata,uzepalette,uzeconsts,uzcflineweights,uzgldrawergdi,uzegeometry,
  graphics,  usupportgui,StdCtrls,uzcdrawings,Controls,Classes,
  uzbstrproc,uzcsysvars,uzccommandsmanager,uzcfcolors;

procedure DrawColor(Canvas:TCanvas; Index: Integer; ARect: TRect);

type
  TSupportColorCombo = class
                             class procedure ColorDrawItem(Control: TWinControl; Index: Integer; ARect: TRect;
                                                           State: StdCtrls.TOwnerDrawState);
                             class procedure ColorBoxDrawItem(Control: TWinControl; Index: Integer; ARect: TRect;
                                                              State: StdCtrls.TOwnerDrawState);

  end;

implementation
procedure DrawColor(Canvas:TCanvas; Index: Integer; ARect: TRect);
var
   s:string;
   textrect: TRect;
   y:integer;
   SaveBrushColor:TColor;
const
     cellsize=11;
     textoffset=cellsize+5;
begin
  s:=GetColorNameFromIndex(index);
  if s='' then
    s:=ColorIndex2Name(index);
  ARect.Left:=ARect.Left+2;
  textrect:=ARect;
  SaveBrushColor:=canvas.Brush.Color;
  if index<ClSelColor then
   begin
        textrect.Left:=textrect.Left+textoffset;
        canvas.TextRect(ARect,textrect.Left,(ARect.Top+ARect.Bottom-canvas.TextHeight(s)) div 2,s);
        if index in [1..255] then
                       begin
                            canvas.Brush.Color:=RGBToColor(palette[index].RGB.r,palette[index].RGB.g,palette[index].RGB.b);
                       end
                   else
                       canvas.Brush.Color:=clWhite;
        y:=(ARect.Top+ARect.Bottom-cellsize)div 2;
        canvas.Rectangle(ARect.Left,y,ARect.Left+cellsize,y+cellsize);
        if index=7 then
                       begin
                            canvas.Brush.Color:=clBlack;
                            canvas.Polygon([classes.point(ARect.Left,y),classes.point(ARect.Left+cellsize-1,y),classes.point(ARect.Left+cellsize-1,y+cellsize-1)]);
                        end
   end
  else
  begin
       canvas.TextRect(ARect,ARect.Left,(ARect.Top+ARect.Bottom-canvas.TextHeight(s)) div 2,s);
  end;
  canvas.Brush.Color:=SaveBrushColor;
end;
class procedure TSupportColorCombo.ColorDrawItem(Control: TWinControl; Index: Integer; ARect: TRect;
  State: StdCtrls.TOwnerDrawState);
begin
    begin
    ComboBoxDrawItem(Control,ARect,State);
    index:=integer(tcombobox(Control).items.Objects[Index]);
    DrawColor(TComboBox(Control).canvas,Index,ARect);
    end;
end;
class procedure TSupportColorCombo.ColorBoxDrawItem(Control: TWinControl; Index: Integer; ARect: TRect;
  State: StdCtrls.TOwnerDrawState);
begin
    if (drawings.GetCurrentDWG=nil)or(sysvar.DWG.DWG_CColor=nil) then
    exit;
    begin
    ComboBoxDrawItem(Control,ARect,State);
    if not TComboBox(Control).DroppedDown then
                                      begin
                                           index:=IVars.CColor;
                                      end
                                 else
                                     index:=integer(tcombobox(Control).items.Objects[Index]);
    DrawColor(TComboBox(Control).canvas,Index,ARect);
    end;
end;

end.
