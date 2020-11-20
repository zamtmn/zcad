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
unit uzccommand_snapproperties;

{$INCLUDE def.inc}

interface
uses
  LazLogger,
  uzccommandsabstract,uzccommandsimpl,
  uzcinterface,
  Varman,
  uzcdrawings;

implementation

function SnapProp_com(operands:TCommandOperands):TCommandResult;
begin
  ZCMsgCallBackInterface.Do_PrepareObject(nil,drawings.GetUnitsFormat,dbunit.TypeName2PTD('TOSModeEditor'),@OSModeEditor,drawings.GetCurrentDWG,true);
  result:=cmd_ok;
end;

initialization
  debugln('{I}[UnitsInitialization] Unit "',{$INCLUDE %FILE%},'" initialization');
  CreateCommandFastObjectPlugin(@SnapProp_com,'SnapProperties',CADWG,0).overlay:=true;
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
end.
