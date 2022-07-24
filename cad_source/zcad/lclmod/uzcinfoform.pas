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
  uzcsysparams,uzcinterface,ExtCtrls,
  {$IFNDEF DELPHI}lclproc,{$ENDIF}
  Graphics,ActnList,ComCtrls,StdCtrls,Controls,Classes,menus,Forms,{$IFDEF FPC}lcltype,fileutil,ButtonPanel,{$ENDIF}Buttons,
  uzclog,{$IFNDEF DELPHI}uzctranslations,{$ENDIF}sysutils,uzbstrproc,varmandef,Varman,UBaseTypeDescriptor,uzcsysinfo,uzctnrVectorBytes;
type
  TButtonMethod=procedure({Sender:pointer;}pdata:{Pointer}PtrInt)of object;
  TButtonProc=procedure(pdata:Pointer);
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
                PPata:Pointer;
                procedure Click; override;
                end;
implementation
procedure TDialogForm.AfterConstruction;
begin
     inherited;
     self.Width:=sysparam.notsaved.screenx div 2;
     self.Height:=sysparam.notsaved.screeny div 2;
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
     ZCMsgCallBackInterface.Do_GUIaction(self,ZMsgID_GUIStoreAndFreeEditorProc);
     {$IFNDEF DELPHI}
     if assigned(FProc) then
                            FProc(PPata);
     if assigned(FMethod) then
                            Application.QueueAsyncCall(FMethod,PtrInt(PPata));
     {$ENDIF}
end;
initialization
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
end.

