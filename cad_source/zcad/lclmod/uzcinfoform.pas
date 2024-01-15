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

unit uzcinfoform;
{$INCLUDE zengineconfig.inc}
interface

uses
  uzcsysparams,uzcinterface,uzclog,
  Forms,ButtonPanel,StdCtrls,ComCtrls,Controls;
type
  TButtonMethod=procedure(PData:PtrInt)of object;
  TButtonProc=procedure(pdata:Pointer);
  TDialogForm=class(tform)
      DialogPanel: TButtonPanel;
    public
      procedure AfterConstruction;override;
  end;
  TInfoForm=class(TDialogForm)
      Memo: TMemo;
    public
      procedure AfterConstruction; override;
  end;
implementation
procedure TDialogForm.AfterConstruction;
begin
  inherited;
  self.Width:=sysparam.notsaved.screenx div 2;
  self.Height:=sysparam.notsaved.screeny div 2;
  self.Position:=poScreenCenter;
  self.BorderStyle:=bsSizeToolWin;

  DialogPanel:=TButtonPanel.create(self);
  DialogPanel.ShowButtons:=[pbOK, pbCancel];
  DialogPanel.Align:=alBottom;
  DialogPanel.Parent:=self;
end;
procedure TInfoForm.AfterConstruction;
begin
  inherited;
  self.Position:=poDesigned;
  Memo:=TMemo.create(self);
  Memo.ScrollBars:=ssAutoBoth;
  Memo.Align:=alClient;
  Memo.Parent:=self;
end;
initialization
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.

