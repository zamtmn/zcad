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

unit intftranslations;
{$INCLUDE def.inc}

interface
uses gettext,translations,sysinfo,sysutils,fileutil,log;

function InterfaceTranslate(const Identifier, OriginalValue: String): String;

implementation
var
   PODirectory, Lang, FallbackLang: String;
   po: TPOFile;
procedure createpo;
var
   AFilename:string;
begin
     if Lang<>'' then
                     begin
                          AFilename:=Format(PODirectory + 'zcad.%s.po',[Lang]);
                          if FileExistsUTF8(AFilename) then
                                                           begin
                                                                po:=TPOFile.Create(AFilename);
                                                           end;
                     end;
     if (FallbackLang<>'')and(not assigned(po)) then
                     begin
                          AFilename:=Format(PODirectory + 'zcad.%s.po',[FallbackLang]);
                          if FileExistsUTF8(AFilename) then
                                                           begin
                                                                po:=TPOFile.Create(AFilename);
                                                           end;
                     end;
     if (not assigned(po)) then
                     begin
                          AFilename:=(PODirectory + 'zcad.po');
                          if FileExistsUTF8(AFilename) then
                                                           begin
                                                                po:=TPOFile.Create(AFilename);
                                                           end;
                     end;
     if (not assigned(po)) then
                     begin
                         po:=TPOFile.Create;
                     end;
end;
function InterfaceTranslate(const Identifier, OriginalValue: String): String;
begin
     result:=po.Translate(Identifier, OriginalValue);
end;

procedure initialize;
    begin
      PODirectory := sysinfo.sysparam.programpath+'languades/';
      GetLanguageIDs(Lang, FallbackLang); // определено в модуле gettext
      createpo;
      TranslateResourceStrings(po);
      //TranslateUnitResourceStrings('aboutwnd',PODirectory + 'zcad.%s.po', Lang, FallbackLang);
      //MessageDlg('Title', 'Text', mtInformation, [mbOk, mbCancel, mbYes], 0);
    end;

begin
{$IFDEF DEBUGINITSECTION}log.LogOut('intftranslations.initialization');{$ENDIF}
initialize;
end.
