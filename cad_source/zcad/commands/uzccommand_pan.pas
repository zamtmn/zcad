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
unit uzccommand_pan;

{$INCLUDE zengineconfig.inc}

interface
uses
  uzcLog,
  sysutils,
  uzccommandsabstract,uzccommandsimpl,
  uzcdrawings;

implementation

function Pan_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
const
  pix=50;
var
  x,y:integer;
begin
  x:=drawings.GetCurrentDWG.wa.getviewcontrol.ClientWidth div 2;
  y:=drawings.GetCurrentDWG.wa.getviewcontrol.ClientHeight div 2;
  if uppercase(operands)='LEFT' then
    drawings.GetCurrentDWG.wa.PanScreen(x,y,x+pix,y)
  else if uppercase(operands)='RIGHT' then
    drawings.GetCurrentDWG.wa.PanScreen(x,y,x-pix,y)
  else if uppercase(operands)='UP' then
    drawings.GetCurrentDWG.wa.PanScreen(x,y,x,y+pix)
  else if uppercase(operands)='DOWN' then
    drawings.GetCurrentDWG.wa.PanScreen(x,y,x,y-pix);
  drawings.GetCurrentDWG.wa.RestoreMouse;
  result:=cmd_ok;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@Pan_com,'Pan',CADWG,0).overlay:=true;
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
