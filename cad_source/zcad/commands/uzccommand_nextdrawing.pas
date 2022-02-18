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

unit uzccommand_nextdrawing;
{$INCLUDE zcadconfig.inc}

interface
uses
  LCLProc,
  uzccommandsabstract,uzccommandsimpl,
  uzcmainwindow;

implementation

function NextDrawing_com(operands:TCommandOperands):TCommandResult;
var
   i:integer;
begin
  if assigned(ZCADMainWindow.PageControl)then
    if ZCADMainWindow.PageControl.PageCount>1 then begin
      i:=ZCADMainWindow.PageControl.ActivePageIndex+1;
      if i=ZCADMainWindow.PageControl.PageCount then
        i:=0;
      ZCADMainWindow.PageControl.ActivePageIndex:=i;
      ZCADMainWindow.ChangedDWGTab(ZCADMainWindow.PageControl);
    end;
  result:=cmd_ok;
end;

procedure startup;
begin
  CreateCommandFastObjectPlugin(@NextDrawing_com,'NextDrawing',0,0);
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
