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
{$mode delphi}
unit uzccommand_help;

{$INCLUDE zengineconfig.inc}

interface
uses
  {$ifdef unix}Process,{$else}windows,Forms,{$endif}
  LazLogger,LCLIntf,
  uzccommandsabstract,uzccommandsimpl,uzccommandsmanager,
  uzbpaths;

implementation

procedure OpenDocumentWithAnchor(AFile,AAnchor:string);
var
  Browser, Params, FullParams: String;
  {$ifdef unix}AProcess: TProcess;{$endif}
begin
  if FindDefaultBrowser(Browser, Params) then begin
    if AAnchor<>'' then
      FullParams:='"'+'file:///'+AFile+AAnchor+'"'
    else
      FullParams:='';
  {$ifdef unix}
    AProcess := TProcess.Create(nil);
    AProcess.Executable := ABrowser;
    AProcess.Parameters.Add(fulllink);
    AProcess.Execute;
    AProcess.Free;
  {$else}
    ShellExecute(Application.MainForm.Handle,'open',PChar(Browser),PChar(FullParams),nil, SW_SHOWNORMAL);
  {$endif}
  end else
    OpenDocument(AFile);
end;

function Help_com(operands:TCommandOperands):TCommandResult;
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
  debugln('{I}[UnitsInitialization] Unit "',{$INCLUDE %FILE%},'" initialization');
  CreateCommandFastObjectPlugin(@Help_com,'Help',0,0).overlay:=True;
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
end.
