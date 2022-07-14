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
  LazLogger,
  uzccommandsabstract,uzccommandsimpl,uzccommandsmanager,
  LCLIntf,
  uzbpaths;

implementation

function Help_com(operands:TCommandOperands):TCommandResult;
var
  URL:string;
begin
  URL:=ProgramPath+'help/userguide.ru.html';
  {if commandmanager.CommandsStack.Count=0 then
    URL:=ProgramPath+'help/userguide.ru.html'
  else
    URL:=ProgramPath+'help\userguide.ru.html#_'+
    lowercase(PCommandObjectDef(commandmanager.CommandsStack.getData(commandmanager.CommandsStack.Count-1))^.CommandName);}
  OpenDocument(URL);
  result:=cmd_ok;
end;

initialization
  debugln('{I}[UnitsInitialization] Unit "',{$INCLUDE %FILE%},'" initialization');
  CreateCommandFastObjectPlugin(@Help_com,'Help',0,0).overlay:=True;
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
end.
