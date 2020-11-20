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

unit uzccommand_closedwg;
{$INCLUDE def.inc}

interface
uses
  LCLProc,Forms,
  uzccommandsabstract,uzccommandsimpl,
  uzcdrawing,uzcdrawings,
  uzcmainwindow;

implementation

function CloseDWG_com(operands:TCommandOperands):TCommandResult;
var
   CurrentDWG:PTZCADDrawing;
begin
  application.ProcessMessages;
  CurrentDWG:=PTZCADDrawing(drawings.GetCurrentDWG);
  _CloseDWGPage(CurrentDWG,ZCADMainWindow.PageControl.ActivePage,false,nil);
  result:=cmd_ok;
end;

procedure startup;
begin
  CreateCommandFastObjectPlugin(@CloseDWG_com,'CloseDWG',CADWG,0).CEndActionAttr:=CEDWGNChanged;
end;
procedure finalize;
begin
end;
initialization
  debugln('{I}[UnitsInitialization] Unit "',{$INCLUDE %FILE%},'" initialization');
  startup;
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
  finalize;
end.
