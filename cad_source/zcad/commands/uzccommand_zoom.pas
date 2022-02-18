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
unit uzccommand_zoom;

{$INCLUDE zcadconfig.inc}

interface
uses
  LazLogger,
  sysutils,
  uzccommandsabstract,uzccommandsimpl,
  uzcdrawings;

implementation

function Zoom_com(operands:TCommandOperands):TCommandResult;
begin
  if uppercase(operands)='ALL' then
    drawings.GetCurrentDWG.wa.ZoomAll
  else if uppercase(operands)='SEL' then
    drawings.GetCurrentDWG.wa.ZoomSel
  else if uppercase(operands)='IN' then
    drawings.GetCurrentDWG.wa.ZoomIn
  else if uppercase(operands)='OUT' then
    drawings.GetCurrentDWG.wa.ZoomOut;
  result:=cmd_ok;
end;

initialization
  debugln('{I}[UnitsInitialization] Unit "',{$INCLUDE %FILE%},'" initialization');
  CreateCommandFastObjectPlugin(@Zoom_com,'Zoom',CADWG,0).overlay:=true;
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
end.
