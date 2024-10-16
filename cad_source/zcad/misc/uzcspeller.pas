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
{$ModeSwitch advancedrecords}
{$Codepage UTF8}

interface

uses
  SysUtils,FileUtil,
  uHunspell,uSpeller,
  uzbPaths,
  uzcLog,uzbLog,uzbLogTypes,
  uzcSysParams,
  uzelongprocesssupport;

var
  SpellChecker:TSpeller;

procedure CreateSpellChecker;
procedure DestroySpellChecker;

implementation

var
  LMDSpeller:TModuleDesk;
  //lph:TLPSHandle;

procedure SpellLogCallBack(MsgType:TMsgType;Msg:TMsg);
begin
  case MsgType of
    MsgInfo:
      ProgramLog.LogOutStr(Msg,LM_Info,LMDSpeller);
    MsgCriticalInfo:
      ProgramLog.LogOutStr(Msg,LM_Necessarily,LMDSpeller);
    MsgWarning:
      ProgramLog.LogOutStr(Msg,LM_Warning,LMDSpeller);
    MsgError:
      ProgramLog.LogOutStr(Msg,LM_Error,LMDSpeller);
  end;
end;

procedure CreateSpellChecker;
var
  lph:TLPSHandle;
begin
  lph:=LPS.StartLongProcess('SpellChecker.Create and LoadDictionaries',nil);
  SpellChecker.CreateRec(@SpellLogCallBack);
  SpellChecker.LoadDictionaries(ExpandPath(SysParam.saved.DictionariesPath));
  LPS.EndLongProcess(lph);
end;

procedure DestroySpellChecker;
begin
  SpellChecker.DestroyRec;
end;

initialization
  LMDSpeller:=ProgramLog.RegisterModule('Speller/Hunspell');
  CreateSpellChecker;
  {t:=SpellChecker.SpellTextSimple('претворяя в');
  t:=SpellChecker.SpellTextSimple('претворяя the');
  t:=SpellChecker.SpellTextSimple('претворяя ##');
  t:=SpellChecker.SpellTextSimple('##');
  t:=SpellChecker.SpellWord('притворяя');
  t:=SpellChecker.SpellWord('the');
  t:=SpellChecker.SpellWord('притваряя');}
finalization
  DestroySpellChecker;
end.

