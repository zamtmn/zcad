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

interface

uses
  SysUtils,FileUtil,
  gvector,
  hunspell,
  uzbPaths,
  uzcLog,uzbLogTypes,
  uzcsysvars;

type
  TSpellerData=record
    Lang:string;
    Speller:THunspell;
  end;

  TZCSpeller=record
    private
      type
        TSpellers=specialize TVector<TSpellerData>;
      var
        Spellers:TSpellers;
    public
      type
        TLangHandle=integer;
      const
        WrongLang=-1;
        MixedLang=-2;
    procedure CreateRec;
    procedure DestroyRec;
    function LoadDictionary(const DictName:string;const Lang:string=''):TLangHandle;
    procedure LoadDictionaries(Dicts:string);
    function SpellWord(Word:string):TLangHandle;//>WrongLang if ok
  end;

var
  SpellChecker:TZCSpeller;
  t:integer;

implementation

var
  LMDSpeller:TModuleDesk;

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

procedure TZCSpeller.CreateRec;
begin
  Spellers:=TSpellers.Create;
end;

procedure TZCSpeller.DestroyRec;
begin
  Spellers.Destroy;
end;

function TZCSpeller.LoadDictionary(const DictName:string;const Lang:string=''):integer;
var
  PSD:TSpellers.PT;
begin
  if FileExists(DictName) then begin
    Result:=Spellers.Size;
    Spellers.Resize(Spellers.Size+1);
    PSD:=Spellers.Mutable[Spellers.Size-1];
    PSD^.Speller.CreateRec('',@SpellLogCallBack);
    if not PSD^.Speller.SetDictionary(DictName) then begin
      PSD^.Speller.DestroyRec;
      Spellers.Erase(Spellers.Size-1);
      Result:=WrongLang;
    end;
    if Lang<>'' then
      PSD^.Lang:=Lang
    else
      PSD^.Lang:=ChangeFileExt(ExtractFileName(DictName),'');
  end else
    Result:=WrongLang;
end;

procedure TZCSpeller.LoadDictionaries(Dicts:string);
var
  LangDicts,Lang,LangDict:string;
  LangHandle:TLangHandle;
begin
  repeat
    GetPartOfPath(LangDicts,Dicts,'|');
    GetPartOfPath(Lang,LangDicts,'=');
    if LangDicts='' then begin
      LangDicts:=Lang;
      Lang:=''
    end;
    GetPartOfPath(LangDict,LangDicts,';');
    LangHandle:=LoadDictionary(LangDict,Lang);
    while LangDicts<>'' do begin
      GetPartOfPath(LangDict,LangDicts,';');
    end;
  until Dicts='';
end;

function TZCSpeller.SpellWord(Word:string):TLangHandle;
var
  i:integer;
  PSD:TSpellers.PT;
begin
  for i:=0 to Spellers.Size-1 do begin
    PSD:=Spellers.Mutable[i];
    if PSD^.Speller.Spell(Word) then
      exit(i);
  end;
  Result:=WrongLang;
end;

initialization
  LMDSpeller:=ProgramLog.RegisterModule('Speller/Hunspell');
  SpellChecker.CreateRec;
  SpellChecker.LoadDictionaries(ExpandPath(SysVar.PATH.Dictionaries));
  t:=SpellChecker.SpellWord('претворяя');
  t:=SpellChecker.SpellWord('притворяя');
  t:=SpellChecker.SpellWord('the');
  t:=SpellChecker.SpellWord('притваряя');
finalization
  SpellChecker.DestroyRec;
end.

