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

unit uzcSpeller;
{$INCLUDE zengineconfig.inc}
{$mode objfpc}{$H+}

interface

uses
  sysutils,
  hunspell,
  uzbPaths,
  uzcLog,uzbLogTypes;

var
  Speller:THunspell;
  t:boolean;

implementation

var
  SpellerHunspell:TModuleDesk;

procedure SpellLogCallBack(MsgType:TMsgType;Msg:TMsg);
begin
  case MsgType of
    MsgInfo:
      ProgramLog.LogOutStr(Msg,LM_Info,SpellerHunspell);
    MsgCriticalInfo:
      ProgramLog.LogOutStr(Msg,LM_Necessarily,SpellerHunspell);
    MsgWarning:
      ProgramLog.LogOutStr(Msg,LM_Warning,SpellerHunspell);
    MsgError:
      ProgramLog.LogOutStr(Msg,LM_Error,SpellerHunspell);
  end;
end;

initialization
  SpellerHunspell:=ProgramLog.RegisterModule('Speller/Hunspell');
  Speller.CreateRec('',@SpellLogCallBack);
  Speller.SetDictionary(ExpandPath('$(ZCADPath)\dic\ru_RUs.dic'));
  t:=Speller.Spell('претворяя');
  t:=Speller.Spell('притворяя');
  t:=Speller.Spell('притваряя');
  t:=Speller.Spell('притваряя');
finalization
  Speller.DestroyRec;
end.

