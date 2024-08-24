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

unit speller;
{$mode objfpc}{$H+}
{$ModeSwitch advancedrecords}
{$Codepage UTF8}

interface

uses
  SysUtils,FileUtil,
  gvector,
  hunspell;

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
        LogProc:TLogProc;
    public
      type
        TLangHandle=integer;
      const
        WrongLang=-1;
        MixedLang=-2;
        NoText=-3;
    constructor CreateRec(ALogProc:TLogProc);
    procedure DestroyRec;
    function LoadDictionary(const DictName:string;const Lang:string=''):TLangHandle;
    procedure LoadDictionaries(Dicts:string);
    function SpellWord(Word:String):TLangHandle;//>WrongLang if ok
    function SpellText(Text:String):TLangHandle;//>WrongLang or MixedLang or NoText if ok
  end;

implementation

constructor TZCSpeller.CreateRec(ALogProc:TLogProc);
begin
  LogProc:=ALogProc;
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
    PSD^.Speller.CreateRec('',LogProc);
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

function GetPart(out APart:String;var AStr:String;const ASeparator:String):String;
var
  i:Integer;
begin
  i:=pos(ASeparator,AStr);
  if i<>0 then begin
    APart:=copy(AStr,1,i-1);
    AStr:=copy(AStr,i+1,length(AStr)-i);
  end else begin
    APart:=AStr;
    AStr:='';
  end;
  result:=APart;
end;


procedure TZCSpeller.LoadDictionaries(Dicts:string);
var
  LangDicts,Lang,LangDict:string;
  LangHandle:TLangHandle;
begin
  repeat
    GetPart(LangDicts,Dicts,'|');
    GetPart(Lang,LangDicts,'=');
    if LangDicts='' then begin
      LangDicts:=Lang;
      Lang:=''
    end;
    GetPart(LangDict,LangDicts,';');
    LangHandle:=LoadDictionary(LangDict,Lang);
    while LangDicts<>'' do begin
      GetPart(LangDict,LangDicts,';');
    end;
  until Dicts='';
end;

function TZCSpeller.SpellWord(Word:String):TLangHandle;
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

function TZCSpeller.SpellText(Text:String):TLangHandle;
var
  startw,endw,chlen:integer;
  word:string;
  t:TLangHandle;

  function ItBreackSumbol(i:integer):boolean;
  begin
    if ord(text[i])in[ord('a')..ord('z'),ord('A')..ord('Z')] then begin
      chlen:=1;
      exit(false);
    end;
    chlen:=Utf8CodePointLen(@Text[i],4,true);
    if chlen=1 then
      result:=true
    else
      result:=false;
  end;

  procedure GoToStartW;
  begin
    while startw<=length(text) do begin
     if not ItBreackSumbol(startw) then
       break;
     inc(startw,chlen);
    end;
    endw:=startw+chlen;
    while endw<=length(text) do begin
     if ItBreackSumbol(endw) then
       break;
     inc(endw,chlen);
    end;

  end;

begin
  result:=NoText;
  startw:=1;
  GoToStartW;
  word:=Copy(text,startw,endw-startw);
  if word<>''then begin
    result:=SpellWord(word);
    if result=WrongLang then
      exit;
    startw:=endw;
    while startw<=length(text) do begin
      GoToStartW;
      word:=Copy(text,startw,endw-startw);
      if word<>''then begin
        t:=SpellWord(word);
        case t of
          WrongLang:exit(WrongLang);
          else
            if t<>result then
              result:=MixedLang;
        end;
      end;
      startw:=endw;
    end;
  end;
end;

end.

