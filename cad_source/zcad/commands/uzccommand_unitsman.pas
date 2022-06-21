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
unit uzccommand_unitsman;

{$INCLUDE zengineconfig.inc}

interface
uses
  LazLogger,
  Controls,
  uzbpaths,
  uzccommandsabstract,uzccommandsimpl,
  uzcinterface,
  UUnitManager,
  uzccmdeditunit,
  uzctranslations,
  Varman;

implementation

function UnitsMan_com(operands:TCommandOperands):TCommandResult;
var
  PUnit:ptunit;
begin
  if length(Operands)>0 then begin
    PUnit:=units.findunit(SupportPath,InterfaceTranslate,operands);
    if PUnit<>nil then
      EditUnit(PUnit^)
    else
      ZCMsgCallBackInterface.TextMessage('unit not found!',TMWOHistoryOut);
  end else
    ZCMsgCallBackInterface.TextMessage('Specify unit name!',TMWOHistoryOut);
  result:=cmd_ok;
end;


initialization
  debugln('{I}[UnitsInitialization] Unit "',{$INCLUDE %FILE%},'" initialization');
  CreateCommandFastObjectPlugin(@UnitsMan_com,'UnitsMan',0,0);
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
end.
