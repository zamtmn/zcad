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
unit uzccommand_show;

{$INCLUDE zengineconfig.inc}

interface

uses
  SysUtils,
  Controls,
  uzcLog,
  uzcinterface,
  uzcstrconsts,
  uzccommandsabstract,uzccommandsimpl;

implementation

function Show_com(const Context:TZCADCommandContext;
  operands:TCommandOperands):TCommandResult;
var
  ctrl:TControl;
begin
  if Operands<>'' then
    zcUI.ShowForm(operands)
  else
    zcUI.TextMessage(rscmCmdMustHaveOperand,TMWOShowError);
  Result:=cmd_ok;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@Show_com,'Show',0,0);

finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsFinalizeLMId);
end.
