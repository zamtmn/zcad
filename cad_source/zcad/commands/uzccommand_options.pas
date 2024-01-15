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
unit uzccommand_options;

{$INCLUDE zengineconfig.inc}

interface
uses
  uzcLog,
  uzccommandsabstract,uzccommandsimpl,
  uzcinterface,
  uzcdrawings,
  Varman,
  uzcsysvars,
  uzcstrconsts;

implementation

function Options_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
begin
  ZCMsgCallBackInterface.Do_PrepareObject(nil,drawings.GetUnitsFormat,SysUnit.TypeName2PTD('gdbsysvariable'),@sysvar,drawings.GetCurrentDWG);
  ZCMsgCallBackInterface.TextMessage(rscmOptions2OI,TMWOMessageBox);
  result:=cmd_ok;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@Options_com,'Options',0,0);
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
