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
{$mode delphi}
unit uzcCommand_SpellCheck;

{$INCLUDE zengineconfig.inc}

interface
uses
  uzcLog,
  uzccommandsabstract,uzccommandsimpl,
  uzcinterface,uzcSpeller,
  uzcCommand_Find;

implementation

const
  CSpellCheckFN='{SpellCheck}';

var
  IsAllInited:Boolean;

function SpellCheckString(FindIn,Text:string;var Details:String;const NeedDetails:Boolean=false):boolean;
//var
//  errW:string;
begin
  result:=SpellChecker.SpellTextSimple(FindIn,{errW}Details)=SpellChecker.WrongLang;
end;

procedure doInit;
begin
  if not IsAllInited then begin
    IsAllInited:=true;
    RegisterCheckStrProc(CSpellCheckFN,SpellCheckString);
  end;
end;

function SpellCheck_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
begin
  doInit;
  result:=Find_com(Context,CSpellCheckFN);
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  IsAllInited:=false;
  CreateZCADCommand(@SpellCheck_com,'SpellCheck',0,0);
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
