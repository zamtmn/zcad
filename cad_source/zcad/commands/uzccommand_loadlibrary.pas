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

unit uzcCommand_LoadLibrary;
{$INCLUDE zengineconfig.inc}

interface
uses
 uzcLog,
 uzbpaths,uzccommandsabstract,uzccommandsimpl,uzccommand_load,
 uzcEnitiesVariablesExtender;

implementation
function LoadLibrary_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
begin
  TVariablesExtender.DisableVariableContentReplace;
  result:=Load_com(Context,operands);
end;


initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@LoadLibrary_com,'LoadLibrary',0,0);
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
