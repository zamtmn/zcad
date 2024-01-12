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
unit uzccommand_zoom;

{$INCLUDE zengineconfig.inc}

interface
uses
  uzcLog,
  sysutils,
  uzccommandsabstract,uzccommandsimpl,
  uzcdrawings;

implementation

function Zoom_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
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
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@Zoom_com,'Zoom',CADWG,0).overlay:=true;
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
