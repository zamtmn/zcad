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

unit uzcctrldynamiccommandmenu;
{$INCLUDE zcadconfig.inc}
interface
uses
 uzcinfoform,ComCtrls,Controls,Forms,uzclog,uzcstrconsts;
type
  DMMethod=procedure(sender:Pointer) of object;
  //PTDMenuWnd=^TDMenuWnd;

  { TDMenuWnd }

  TDMenuWnd = class(tform)
    ToolBar1: TToolBar;
    procedure AfterConstruction; override;
    //procedure AddProcedure(Text,HText:String;proc:TonClickProc);
    procedure AddMethod(Text,HText:String;FMethod:TButtonMethod);
    procedure AddProcedure(Text,HText:String;FProc:TButtonProc);
    function AddButton(Text,HText:String):TmyProcToolButton;
    public
      procedure CreateToolBar;
      procedure clear;
  end;
implementation
procedure TDMenuWnd.AfterConstruction;
begin
     FormStyle:=fsStayOnTop;
     caption:=(rscmCommandParams);
     borderstyle:=bsSizeToolWin;
     autosize:=true;
     CreateToolBar;
     inherited;
end;

{procedure TDMenuWnd.AddMethod(Text, HText: String; FMethod: TButtonMethod);
begin

end;

procedure TDMenuWnd.AddProcedure(Text, HText: String; FProc: TButtonProc);
begin

end;

function TDMenuWnd.AddButton(Text, HText: String): TmyProcToolButton;
begin

end;}
procedure TDMenuWnd.clear;
begin
  ToolBar1.Free;
  CreateToolBar;
end;
procedure TDMenuWnd.CreateToolBar;
begin
  ToolBar1:=TToolBar.create(self);
  ToolBar1.AutoSize:=true;
  ToolBar1.parent:=self;
  ToolBar1.Align:=alclient;
  ToolBar1.ShowCaptions:=true;
  ToolBar1.Wrapable:=true;
end;

function TDMenuWnd.AddButton;
begin
     result:=TmyProcToolButton.Create(ToolBar1);
     result.caption:=Text;
     result.showhint:=true;
     result.hint:=HText;
     result.parent:=ToolBar1;
     //result.align:=alTop;
     //self.DoAutoSize;
     //result.height:=18
     //result.height:=10;
(*  nw:=0;
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



  Getmem(Pointer(result),sizeof(ZButtonGeneric));
  result^.initxywh(Text,hText,@self,0,yy,ww,statusbarclientheight,true);
  result^.align:=al_clientw;
	SelectObject(_dc, hfntOld);
	ReleaseDC(handle,_dc);
  self.setxywh(wndx,wndy,nw,nh+(height-clientheight));
*)
end;
(*procedure TDMenuWnd.AddProcedure(Text,HText:String;proc:TonClickProc);
begin
     AddButton(Text,HText).onclickproc:=proc;
end;*)
procedure TDMenuWnd.AddProcedure;
begin

end;

procedure TDMenuWnd.AddMethod;
begin
     AddButton(Text,HText).FMethod:=FMethod;//.onClickMethod:=TonClickMethod(proc);
end;
begin
end.
