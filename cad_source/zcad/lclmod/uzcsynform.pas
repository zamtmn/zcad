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
  SynEdit,SynHighlighterPas,SynEditHighlighter,
  Forms,StdCtrls,Controls,Graphics;

type
  TSynForm=class(TDialogForm)
                         Memo: {TMemo}TSynEdit;
                         public
                         procedure AfterConstruction; override;
                    end;
implementation
procedure TSynForm.AfterConstruction;
var
  shlist:TSynHighlighterList;
  phli:integer;
begin
  inherited;
  self.Position:=poDesigned;
  Memo:={TMemo}TSynEdit.create(self);
  {$IFNDEF DELPHI}Memo.ScrollBars:=ssAutoBoth;{$ENDIF}
  Memo.Align:=alClient;
  Memo.Parent:=self;
  Memo.Font.Quality:=fqCleartype;
  Memo.Font.Size:=8;
  shlist:=GetPlaceableHighlighters;
  if shlist<>nil then begin
    phli:=shlist.FindByName('ObjectPascal');
    if phli<>-1 then
      Memo.Highlighter:=shlist[phli].Create(Memo);
  end;
end;
initialization
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.

