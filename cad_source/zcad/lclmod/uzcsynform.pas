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

unit uzcSynForm;
{$INCLUDE zengineconfig.inc}
interface

uses

  uzcsysparams,uzcinterface,uzclog,uzcinfoform,
  SynEdit,Forms,StdCtrls,Controls;

type
  TSynForm=class(TDialogForm)
                         Memo: {TMemo}TSynEdit;
                         public
                         procedure AfterConstruction; override;
                    end;
implementation
procedure TSynForm.AfterConstruction;
begin
     inherited;
     self.Position:=poDesigned;
     Memo:={TMemo}TSynEdit.create(self);
     {$IFNDEF DELPHI}Memo.ScrollBars:=ssAutoBoth;{$ENDIF}
     Memo.Align:=alClient;
     Memo.Parent:=self;
end;
initialization
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.

