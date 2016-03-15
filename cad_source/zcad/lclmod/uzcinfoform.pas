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

unit uzcinfoform;
{$INCLUDE def.inc}
interface

uses
  zcadinterface,ExtCtrls,
  {$IFNDEF DELPHI}lclproc,{$ENDIF}
  Graphics,ActnList,ComCtrls,StdCtrls,Controls,Classes,menus,Forms,{$IFDEF FPC}lcltype,fileutil,ButtonPanel,{$ENDIF}Buttons,
  {strutils,}{$IFNDEF DELPHI}uzctranslations,{$ENDIF}sysutils,strproc,varmandef,Varman,UBaseTypeDescriptor,gdbasetypes,uzcshared,uzcsysinfo,UGDBOpenArrayOfByte;
type
  TButtonMethod=procedure({Sender:pointer;}pdata:{GDBPointer}GDBPlatformint)of object;
  TButtonProc=procedure(pdata:GDBPointer);
  TDialogForm=class(tform)
                         {$IFNDEF DELPHI}
                         DialogPanel: TButtonPanel;
                         {$ENDIF}
                         public
                         procedure AfterConstruction;override;
                    end;
  TInfoForm=class(TDialogForm)
                         Memo: TMemo;
                         public
                         procedure AfterConstruction; override;
                    end;
  TmyProcToolButton=class({Tmy}TToolButton)
                public
                FProc:TButtonProc;
                FMethod:TButtonMethod;
                PPata:GDBPointer;
                protected procedure Click; override;
                end;
implementation
uses uzclog;
procedure TDialogForm.AfterConstruction;
begin
     inherited;
     self.Width:=sysparam.screenx div 2;
     self.Height:=sysparam.screeny div 2;
     self.Position:=poScreenCenter;
     self.BorderStyle:=bsSizeToolWin;
     {$IFNDEF DELPHI}
     DialogPanel:=TButtonPanel.create(self);
     DialogPanel.ShowButtons:=[pbOK, pbCancel];
     DialogPanel.Align:=alBottom;
     DialogPanel.Parent:=self;
     {$ENDIF}
end;
procedure TInfoForm.AfterConstruction;
begin
     inherited;
     self.Position:=poDesigned;
     Memo:=TMemo.create(self);
     {$IFNDEF DELPHI}Memo.ScrollBars:=ssAutoBoth;{$ENDIF}
     Memo.Align:=alClient;
     Memo.Parent:=self;
end;
procedure TmyProcToolButton.Click;
begin
     if assigned(StoreAndFreeEditorProc)then
                                            StoreAndFreeEditorProc;
     {$IFNDEF DELPHI}
     if assigned(FProc) then
                            FProc(PPata);
     if assigned(FMethod) then
                            Application.QueueAsyncCall(FMethod,GDBPlatformint(PPata));
     {$ENDIF}
end;
initialization
finalization
end.

