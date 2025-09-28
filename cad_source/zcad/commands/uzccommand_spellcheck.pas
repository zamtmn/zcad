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
  SysUtils,
  uzcLog,
  uzccommandsabstract,uzccommandsimpl,
  uzcinterface,uzcSpeller,uSpeller,
  uzcCommand_Find,
  uzcdrawings;

implementation

const
  CSpellCheckFN='{SpellCheck}';

var
  IsAllInited:boolean;

function SpellCheckString(FindIn:ansistring;const TextA:ansistring;
  const TextU:unicodestring;var Details:string;const NeedDetails:boolean):boolean;
var
  Opt:TSpeller.TSpellOpts;
  //  errW:string;
begin
  if NeedDetails then
    Opt:=TSpeller.CSpellOptDetail
  else
    Opt:=TSpeller.CSpellOptFast;
  //Opt:=Opt-[SOCheckOneLetterWords];
  Result:=SpellChecker.SpellTextSimple(FindIn,{errW}Details,Opt)=TSpeller.WrongLang;
end;

procedure doInit;
begin
  if not IsAllInited then begin
    IsAllInited:=True;
    RegisterCheckStrProc(CSpellCheckFN,SpellCheckString);
  end;
end;

function SpellCheck_com(const Context:TZCADCommandContext;
  operands:TCommandOperands):TCommandResult;
begin
  if uppercase(operands)='RESET' then begin
    DestroySpellChecker;
    CreateSpellChecker;
    Result:=cmd_ok;
  end else begin
    if drawings.GetCurrentDWG<>nil then begin
      doInit;
      Result:=Find_com(Context,CSpellCheckFN);
    end else
      Result:=cmd_error;
  end;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsInitializeLMId);
  IsAllInited:=False;
  CreateZCADCommand(@SpellCheck_com,'SpellCheck',0,0);

finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsFinalizeLMId);
end.
