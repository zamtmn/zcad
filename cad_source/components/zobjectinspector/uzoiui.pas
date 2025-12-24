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

unit uzOIUI;

{$MODE DELPHI}
interface
uses Classes,Types,Themes,Graphics,LCLIntf,LCLType,Forms,
     varmandef,uzbtypes,uzObjectInspectorManager;
function OIUI_FE_ButtonGetPrefferedSize(PInstance:Pointer;ARect:TRect):TSize;
function OIUI_FE_HalfButtonGetPrefferedSize(PInstance:Pointer;ARect:TRect):TSize;
function OIUI_FE_BooleanGetPrefferedSize(PInstance:Pointer;ARect:TRect):TSize;

procedure OIUI_ButtonDraw(canvas:TCanvas;r:trect;state:TFastEditorState;s:string;boundr:trect);
procedure OIUI_FE_BooleanDraw(canvas:TCanvas;r:trect;PInstance:Pointer;state:TFastEditorState;boundr:trect);
procedure OIUI_FE_GetterSetterBooleanDraw(canvas:TCanvas;r:trect;PInstance:Pointer;state:TFastEditorState;boundr:trect);
procedure OIUI_FE_GetterSetterUsableIntegerUsableDraw(canvas:TCanvas;r:trect;PInstance:Pointer;state:TFastEditorState;boundr:trect);
procedure OIUI_FE_ButtonDraw(canvas:TCanvas;r:trect;PInstance:Pointer;state:TFastEditorState;boundr:trect);
procedure OIUI_FE_ButtonCrossDraw(canvas:TCanvas;r:trect;PInstance:Pointer;state:TFastEditorState;boundr:trect);
procedure OIUI_FE_ButtonMultiplyDraw(canvas:TCanvas;r:trect;PInstance:Pointer;state:TFastEditorState;boundr:trect);
procedure OIUI_FE_ButtonHLineDraw(canvas:TCanvas;r:trect;PInstance:Pointer;state:TFastEditorState;boundr:trect);
procedure OIUI_FE_ButtonGreatThatDraw(canvas:TCanvas;r:trect;PInstance:Pointer;state:TFastEditorState;boundr:trect);
procedure OIUI_FE_ButtonLessThatDraw(canvas:TCanvas;r:trect;PInstance:Pointer;state:TFastEditorState;boundr:trect);

procedure OIUI_FE_BooleanInverse(PInstance:Pointer);
procedure OIUI_FE_IntegerInc(PInstance:Pointer);
procedure OIUI_FE_IntegerDec(PInstance:Pointer);

procedure OIUI_FE_GetterSetterIntegerInc(PInstance:Pointer);
procedure OIUI_FE_GetterSetterIntegerDec(PInstance:Pointer);
procedure OIUI_FE_GetterSetterBooleanInverse(PInstance:Pointer);

procedure OIUI_FE_GetterSetterUsableIntegerInc(PInstance:Pointer);
procedure OIUI_FE_GetterSetterUsableIntegerDec(PInstance:Pointer);
procedure OIUI_FE_GetterSetterUsableIntegerUsableInverse(PInstance:Pointer);


implementation
function OIUI_FE_ButtonGetPrefferedSize(PInstance:Pointer;ARect:TRect):TSize;
//var
  //Details: TThemedElementDetails;
  //ComboElem:TThemedButton;
begin
     {if assigned(PInstance) then
     begin
     ComboElem:=tbCheckBoxCheckedNormal;
     Details:=ThemeServices.GetElementDetails(ComboElem);
     result:=ThemeServices.GetDetailSize(Details);
     end
     else
         result:=types.size(0,0);}
     {if assigned(sysvar.INTF.INTF_DefaultControlHeight) then
                                                   begin
                                                        result.cx:=sysvar.INTF.INTF_DefaultControlHeight^-6;
                                                        if result.cx<15 then
                                                                            result.cx:=15;
                                                        result.cy:=result.cx;
                                                   end
                                               else
                                                   begin
                                                        result.cx:=15;
                                                        result.cy:=15;
                                                   end}

     result.cy:=ARect.Bottom-ARect.Top-OIManager.INTFObjInspButtonSizeReducing;
     result.cx:=result.cy{-INTFObjInspButtonSizeReducing};

     {if result.cx<15 then
                         result.cx:=15;}
end;
function OIUI_FE_HalfButtonGetPrefferedSize(PInstance:Pointer;ARect:TRect):TSize;
begin
     result:=OIUI_FE_ButtonGetPrefferedSize(nil,arect);
     result.cx:=(result.cx+((result.cx+1) div 2)+1) div 2
end;
function OIUI_FE_BooleanGetPrefferedSize(PInstance:Pointer;ARect:TRect):TSize;
var
  Details: TThemedElementDetails;
  ComboElem:TThemedButton;
begin
     if assigned(PInstance) then
     begin
     ComboElem:=tbCheckBoxUncheckedNormal;
     Details:=ThemeServices.GetElementDetails(ComboElem);
     result:=ThemeServices.GetDetailSizeForPPI(Details,Screen.PixelsPerInch);
     end
     else
         result:=types.size(0,0);
end;

procedure BooleanDraw(AValue:boolean;canvas:TCanvas;r:trect;state:TFastEditorState;boundr:trect);
var
  Details: TThemedElementDetails;
  ComboElem:TThemedButton;
begin
  if AValue then begin
    if state=TFES_Hot then
      ComboElem:=tbCheckBoxCheckedHot
    else if state=TFES_Pressed then
      ComboElem:=tbCheckBoxCheckedPressed
    else
      ComboElem:=tbCheckBoxCheckedNormal
  end else begin
    if state=TFES_Hot then
      ComboElem:=tbCheckBoxUncheckedHot
    else if state=TFES_Pressed then
      ComboElem:=tbCheckBoxUncheckedPressed
    else
      ComboElem:=tbCheckBoxUncheckedNormal
  end;
    Details:=ThemeServices.GetElementDetails(ComboElem);
    ThemeServices.DrawElement(Canvas.Handle,Details,r,@boundr);
end;

procedure OIUI_FE_BooleanDraw(canvas:TCanvas;r:trect;PInstance:Pointer;state:TFastEditorState;boundr:trect);
begin
  BooleanDraw(pboolean(PInstance)^,canvas,r,state,boundr);
end;
procedure OIUI_FE_GetterSetterBooleanDraw(canvas:TCanvas;r:trect;PInstance:Pointer;state:TFastEditorState;boundr:trect);
begin
  BooleanDraw(PTGetterSetterBoolean(PInstance)^.Getter,canvas,r,state,boundr);
end;
procedure OIUI_FE_GetterSetterUsableIntegerUsableDraw(canvas:TCanvas;r:trect;PInstance:Pointer;state:TFastEditorState;boundr:trect);
begin
  BooleanDraw(PTGetterSetterTUsableInteger(PInstance)^.Getter.Usable,canvas,r,state,boundr);
end;

procedure OIUI_ButtonDraw(canvas:TCanvas;r:trect;state:TFastEditorState;s:string;boundr:trect);
var
  Details: TThemedElementDetails;
  ComboElem:TThemedButton;
  //tr:trect;
begin
     if state=TFES_Hot then
                           ComboElem:=tbPushButtonHot
                       else if state=TFES_Pressed then
                           ComboElem:=tbPushButtonPressed
                       else
                           ComboElem:=tbPushButtonNormal;
     Details:=ThemeServices.GetElementDetails(ComboElem);
     ThemeServices.DrawElement(Canvas.Handle,Details,r,@boundr);
     if {not IntersectRect(tr,boundr,r))}(r.Right-r.Left)<(boundr.Right-boundr.Left) then
                                           ThemeServices.DrawText(Canvas,Details,s,r,DT_CENTER or DT_VCENTER,0);
end;
procedure OIUI_FE_ButtonDraw(canvas:TCanvas;r:trect;PInstance:Pointer;state:TFastEditorState;boundr:trect);
begin
     OIUI_ButtonDraw(canvas,r,state,'...',boundr);
end;
procedure OIUI_FE_ButtonCrossDraw(canvas:TCanvas;r:trect;PInstance:Pointer;state:TFastEditorState;boundr:trect);
begin
     OIUI_ButtonDraw(canvas,r,state,'+',boundr);
end;
procedure OIUI_FE_ButtonMultiplyDraw(canvas:TCanvas;r:trect;PInstance:Pointer;state:TFastEditorState;boundr:trect);
begin
     OIUI_ButtonDraw(canvas,r,state,'*',boundr);
end;

procedure OIUI_FE_ButtonHLineDraw(canvas:TCanvas;r:trect;PInstance:Pointer;state:TFastEditorState;boundr:trect);
begin
     OIUI_ButtonDraw(canvas,r,state,'-',boundr);
end;
procedure OIUI_FE_ButtonGreatThatDraw(canvas:TCanvas;r:trect;PInstance:Pointer;state:TFastEditorState;boundr:trect);
begin
     OIUI_ButtonDraw(canvas,r,state,'>',boundr);
end;
procedure OIUI_FE_ButtonLessThatDraw(canvas:TCanvas;r:trect;PInstance:Pointer;state:TFastEditorState;boundr:trect);
begin
     OIUI_ButtonDraw(canvas,r,state,'<',boundr);
end;

procedure OIUI_FE_BooleanInverse(PInstance:Pointer);
begin
     pboolean(PInstance)^:=not pboolean(PInstance)^;
end;
procedure OIUI_FE_IntegerInc(PInstance:Pointer);
begin
     inc(pinteger(PInstance)^);
end;
procedure OIUI_FE_IntegerDec(PInstance:Pointer);
begin
     dec(pinteger(PInstance)^);
end;

procedure OIUI_FE_GetterSetterIntegerInc(PInstance:Pointer);
var
  d:Integer;
begin
  if (@PTGetterSetterInteger(PInstance).Getter<>nil)
  and(@PTGetterSetterInteger(PInstance).Setter<>nil)then begin
    d:=PTGetterSetterInteger(PInstance).Getter;
    Inc(d);
    PTGetterSetterInteger(PInstance).Setter(d);
  end;
end;
procedure OIUI_FE_GetterSetterIntegerDec(PInstance:Pointer);
var
  d:Integer;
begin
  if (@PTGetterSetterInteger(PInstance).Getter<>nil)
  and(@PTGetterSetterInteger(PInstance).Setter<>nil)then begin
    d:=PTGetterSetterInteger(PInstance).Getter;
    Dec(d);
    PTGetterSetterInteger(PInstance).Setter(d);
  end;
end;

procedure OIUI_FE_GetterSetterBooleanInverse(PInstance:Pointer);
begin
  if (@PTGetterSetterBoolean(PInstance).Getter<>nil)
    and(@PTGetterSetterBoolean(PInstance).Setter<>nil)then begin
      PTGetterSetterBoolean(PInstance).Setter(not PTGetterSetterBoolean(PInstance).Getter);
  end;
end;

procedure OIUI_FE_GetterSetterUsableIntegerInc(PInstance:Pointer);
var
  d:TUsableInteger;
begin
  if (@PTGetterSetterTUsableInteger(PInstance).Getter<>nil)
  and(@PTGetterSetterTUsableInteger(PInstance).Setter<>nil)then begin
    d:=PTGetterSetterTUsableInteger(PInstance).Getter;
    d.Value:=d.Value+1;
    PTGetterSetterTUsableInteger(PInstance).Setter(d);
  end;
end;
procedure OIUI_FE_GetterSetterUsableIntegerDec(PInstance:Pointer);
var
  d:TUsableInteger;
begin
  if (@PTGetterSetterTUsableInteger(PInstance).Getter<>nil)
  and(@PTGetterSetterTUsableInteger(PInstance).Setter<>nil)then begin
    d:=PTGetterSetterTUsableInteger(PInstance).Getter;
    d.Value:=d.Value-1;
    PTGetterSetterTUsableInteger(PInstance).Setter(d);
  end;
end;

procedure OIUI_FE_GetterSetterUsableIntegerUsableInverse(PInstance:Pointer);
var
  d:TUsableInteger;
begin
  if (@PTGetterSetterTUsableInteger(PInstance).Getter<>nil)
    and(@PTGetterSetterTUsableInteger(PInstance).Setter<>nil)then begin
      d:=PTGetterSetterTUsableInteger(PInstance).Getter;
      d.Usable:=not d.Usable;
      PTGetterSetterTUsableInteger(PInstance).Setter(d);
  end;
end;



end.
