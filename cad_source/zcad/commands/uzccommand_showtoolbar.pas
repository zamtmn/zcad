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
unit uzccommand_showtoolbar;

{$INCLUDE zengineconfig.inc}

interface
uses
  SysUtils,
  Classes,Controls,AnchorDocking,
  uzcLog,
  uzcinterface,
  uzcstrconsts,
  uztoolbarsmanager,
  uzccommandsabstract,uzccommandsimpl;

implementation

function ShowToolBar_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
begin
  if Operands<>'' then begin
    ToolBarsManager.ShowFloatToolbar(operands,rect(0,0,300,50));
  end else
    ZCMsgCallBackInterface.TextMessage(rscmCmdMustHaveOperand,TMWOShowError);
  result:=cmd_ok;
end;


initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@ShowToolBar_com,'ShowToolBar',0,0);
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
