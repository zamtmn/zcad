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

unit uzcctrldynamiccommandmenu;
{$INCLUDE zengineconfig.inc}
interface
uses
 uzcinfoform,ComCtrls,Controls,Forms,uzclog,uzcstrconsts,
 uzcinterface;
type
  DMMethod=procedure(sender:Pointer) of object;

  TmyProcToolButton=class({Tmy}TToolButton)
    public
      FMethod:TButtonMethod;
      PData:Pointer;
      procedure Click; override;
  end;

  TDMenuWnd = class(tform)
    ToolBar1: TToolBar;
    procedure AfterConstruction; override;
    procedure AddMethod(Text,HText:String;AMethod:TButtonMethod;APData:Pointer);
    function AddButton(Text,HText:String):TmyProcToolButton;
    public
      procedure CreateToolBar;
      procedure clear;
  end;
implementation

procedure TmyProcToolButton.Click;
begin
  ZCMsgCallBackInterface.Do_GUIaction(self,ZMsgID_GUIStoreAndFreeEditorProc);
  if assigned(FMethod) then
    Application.QueueAsyncCall(FMethod,PtrInt(PData));
end;

procedure TDMenuWnd.AfterConstruction;
begin
     FormStyle:=fsStayOnTop;
     caption:=(rscmCommandParams);
     borderstyle:=bsSizeToolWin;
     autosize:=true;
     CreateToolBar;
     inherited;
end;
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
end;

procedure TDMenuWnd.AddMethod;
begin
  with AddButton(Text,HText) do begin
    FMethod:=AMethod;
    PData:=APData;
  end;
end;
begin
end.
