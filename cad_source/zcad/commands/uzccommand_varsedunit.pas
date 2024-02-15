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
unit uzccommand_VarsEdUnit;

{$INCLUDE zengineconfig.inc}

interface
uses
  uzcLog,
  Controls,
  sysutils,
  uzbpaths,
  Varman,
  uzccmdinfoform,
  uzccommandsabstract,uzccommandsimpl,
  uzctnrVectorBytes,
  uzcinterface,
  uzcstrconsts,
  UUnitManager,
  uzccmdeditunit,
  uzctranslations;

implementation

function VarsEdUnit_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var
  u:PTSimpleUnit;
  op:ansistring;
begin
  if length(Operands)>0 then begin
    op:=Operands;
    u:=units.findunit(GetSupportPath,InterfaceTranslate,op);
    if u<>nil then
      EditUnit(u^)
    else
      ZCMsgCallBackInterface.TextMessage(format(rsUnableToFindUnit,[op]),TMWOHistoryOut);
  end else
    ZCMsgCallBackInterface.TextMessage(rscmCmdMustHaveOperand,TMWOHistoryOut);
  result:=cmd_ok;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@VarsEdUnit_com,'VarsEdUnit',0,0);
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
