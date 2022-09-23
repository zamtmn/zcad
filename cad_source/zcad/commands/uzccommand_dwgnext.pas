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

unit uzccommand_DWGNext;
{$INCLUDE zengineconfig.inc}

interface
uses
  uzcLog,
  uzccommandsabstract,uzccommandsimpl,
  uzcmainwindow;

implementation

function DWGNext_com(operands:TCommandOperands):TCommandResult;
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
  CreateCommandFastObjectPlugin(@DWGNext_com,'DWGNext',0,0);
end;
procedure finalize;
begin
end;
initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  startup;
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
  finalize;
end.
