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
unit uzccommand_unitsman;

{$INCLUDE zengineconfig.inc}

interface
uses
  uzcLog,
  Controls,
  uzbpaths,
  uzccommandsabstract,uzccommandsimpl,
  uzcinterface,
  UUnitManager,
  uzccmdeditunit,
  uzctranslations,
  Varman;

implementation

function UnitsMan_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var
  PUnit:ptunit;
begin
  if length(Operands)>0 then begin
    PUnit:=units.findunit(GetSupportPath,InterfaceTranslate,operands);
    if PUnit<>nil then
      EditUnit(PUnit^)
    else
      ZCMsgCallBackInterface.TextMessage('unit not found!',TMWOHistoryOut);
  end else
    ZCMsgCallBackInterface.TextMessage('Specify unit name!',TMWOHistoryOut);
  result:=cmd_ok;
end;


initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@UnitsMan_com,'UnitsMan',0,0);
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
