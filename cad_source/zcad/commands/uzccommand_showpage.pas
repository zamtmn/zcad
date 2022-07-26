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
unit uzccommand_showpage;

{$INCLUDE zengineconfig.inc}

interface
uses
  SysUtils,
  LazLogger,
  uzccommandsabstract,uzccommandsimpl,
  uzcmainwindow;

implementation

function ShowPage_com(operands:TCommandOperands):TCommandResult;
begin
  if assigned(ZCADMainWindow)then
  if assigned(ZCADMainWindow.PageControl)then
  ZCADMainWindow.PageControl.ActivePageIndex:=strtoint(Operands);
  result:=cmd_ok;
end;

initialization
  debugln('{I}[UnitsInitialization] Unit "',{$INCLUDE %FILE%},'" initialization');
  CreateCommandFastObjectPlugin(@ShowPage_com,'ShowPage',0,0);
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
end.
