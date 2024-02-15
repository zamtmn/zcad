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
unit uzccommand_help;

{$INCLUDE zengineconfig.inc}

interface
uses
  {$ifdef unix}Process,sysutils,{$else}windows,Forms,{$endif}
  uzcLog,LCLIntf,
  uzccommandsabstract,uzccommandsimpl,uzccommandsmanager,
  uzbpaths;

implementation

{$ifdef unix}
const
  cfVivaldi='/usr/bin/vivaldi';
  cfFirefox='/usr/bin/firefox';
  cfSeamonkey='/usr/bin/seamonkey';
  cfChrome='/usr/bin/google-chrome';
  cfOpera='/usr/bin/opera';

function MyFindDefaultBrowser(out ABrowser, AParams: String): Boolean;
begin
  result:=true;
  AParams:='';
  {FindExecutable not available in Linux, workaround:}
  if FileExists(cfVivaldi) then ABrowser:=cfVivaldi else
  if FileExists(cfFirefox) then ABrowser:=cfFirefox else
  if FileExists(cfSeamonkey) then ABrowser:=cfSeamonkey else
  if FileExists(cfChrome) then ABrowser:=cfChrome else
  if FileExists(cfOpera) then ABrowser:=cfOpera else result:=false;
end;

{$endif}

procedure OpenDocumentWithAnchor(AFile,AAnchor:string);
var
  Browser, Params, FullParams: String;
  {$ifdef unix}AProcess: TProcess;{$endif}
begin
  if {$ifdef unix}MyFindDefaultBrowser{$else}FindDefaultBrowser{$endif}(Browser, Params) then begin
    if AAnchor<>'' then
      FullParams:={$ifndef unix}'"'+{$endif}'file:///'+AFile+AAnchor{$ifndef unix}+'"'{$endif}
    else
      FullParams:='';
  {$ifdef unix}
    AProcess := TProcess.Create(nil);
    AProcess.Executable := Browser;
    AProcess.Parameters.Add(FullParams);
    AProcess.Execute;
    AProcess.Free;
  {$else}
    ShellExecute(Application.MainForm.Handle,'open',PChar(Browser),PChar(FullParams),nil, SW_SHOWNORMAL);
  {$endif}
  end else
    OpenDocument(AFile);
end;

function Help_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var
  htmlDoc:string;
begin
  htmlDoc:=ProgramPath+'help/userguide.ru.html';//todo: расхардкодить
  if CommandManager.CommandsStack.isEmpty then
    OpenDocument(htmlDoc)
  else
    OpenDocumentWithAnchor(htmlDoc,'#_'+lowercase(CommandManager.CommandsStack.getLast^.CommandName));
  result:=cmd_ok;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@Help_com,'Help',0,0).overlay:=True;
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
