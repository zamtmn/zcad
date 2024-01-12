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

unit uzccommand_loadtoolbars;
{$INCLUDE zengineconfig.inc}

interface
uses
 uzcLog,
 uzbpaths,uzccommandsabstract,uzccommandsimpl,uztoolbarsmanager;

implementation
function LoadToolbars_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
begin
  ToolBarsManager.LoadToolBarsContent(ExpandPath(operands));
  result:=cmd_ok;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@LoadToolbars_com,'LoadToolbars',0,0);
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
