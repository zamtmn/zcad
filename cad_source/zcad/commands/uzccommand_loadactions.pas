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

unit uzccommand_loadactions;
{$INCLUDE zengineconfig.inc}

interface
uses
 uzcLog,ComCtrls,Controls,
 uzctreenode,uzbpaths,uzccommandsabstract,uzccommandsimpl,uztoolbarsmanager;

implementation
procedure FixButtonCaption(_tb:TToolBar;_control:tcontrol);
begin
  if _control is TToolButton then
    if assigned((_control as TToolButton).action) then
       if ((_control as TToolButton).action)is TmyAction then
         (_control as TToolButton).Caption:=(((_control as TToolButton).action)as TmyAction).imgstr;
end;

function LoadActions_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
begin
  ToolBarsManager.LoadActions(ExpandPath(operands));
  ToolBarsManager.IterateToolBarsContent(FixButtonCaption);
  result:=cmd_ok;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@LoadActions_com,'LoadActions',0,0);
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
