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

unit UDMenuWnd;
{$INCLUDE def.inc}
interface
uses
 gdbase,{zforms,}Forms,memman,gdbasetypes{,ZButtonsGeneric,ZBAsicVisible,ZGUIsCT};
type
  DMMethod=procedure(sender:GDBPointer) of object;
  PTDMenuWnd=^TDMenuWnd;
  TDMenuWnd = class({zform}tform)
    function getstyle:DWord;virtual;
    function getextstyle:DWord;virtual;

    //procedure AddProcedure(Text,HText:GDBString;proc:TonClickProc);
    procedure AddMethod(Text,HText:GDBString;proc:DMMethod);
    //function AddButton(Text,HText:GDBString):PZButtonGeneric;
  end;
implementation
uses mainwindow,log;
function TDMenuWnd.getextstyle;
begin
     //-----------------------------------------------------------------result:=WS_EX_DLGMODALFRAME;
end;
function TDMenuWnd.getstyle;
begin
     //-----------------------------------------------------------------result:=WS_CLIPCHILDREN
end;
(*function TDMenuWnd.AddButton;
var
   _dc:hdc;
   sz:TSIZE;
   hfntOld:HFONT;
   ww,yy,nw,nh:gdbinteger;
begin
  nw:=0;
  nh:=0;
  _dc:=GetDC(handle);
	hfntOld:=SelectObject(_dc, hFontNormal);
	GetTextExtentPoint32A(_dc,@Text[1],length(Text),sz);
  ww:=sz.cx+8;
  nw:=width;
  if ww<clientwidth then
                        ww:=clientwidth
                    else
                        nw:=width+(ww-clientwidth);
  yy:=kids.Count*statusbarclientheight;
  nh:=yy+statusbarclientheight;



  GDBGetMem({$IFDEF DEBUGBUILD}'{2C132A7B-BFC1-4BA8-AF27-9F7DF19F69F7}',{$ENDIF}GDBPointer(result),sizeof(ZButtonGeneric));
  result^.initxywh(Text,hText,@self,0,yy,ww,statusbarclientheight,true);
  result^.align:=al_clientw;
	SelectObject(_dc, hfntOld);
	ReleaseDC(handle,_dc);
  self.setxywh(wndx,wndy,nw,nh+(height-clientheight));

end;
procedure TDMenuWnd.AddProcedure(Text,HText:GDBString;proc:TonClickProc);
begin
     AddButton(Text,HText).onclickproc:=proc;
end;*)
procedure TDMenuWnd.AddMethod;
begin
     //AddButton(Text,HText).onClickMethod:=TonClickMethod(proc);
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('udmenuwnd.initialization');{$ENDIF}
end.
