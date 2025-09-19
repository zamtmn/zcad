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

unit uzccommand_DWGPrev;
{$INCLUDE zengineconfig.inc}

interface
uses
  uzcLog,
  uzccommandsabstract,uzccommandsimpl,
  uzcMainForm;

implementation

function DWGPrev_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var
   i:integer;
begin
  if assigned(zcMainForm.PageControl)then
    if zcMainForm.PageControl.PageCount>1 then begin
      i:=zcMainForm.PageControl.ActivePageIndex-1;
      if i<0 then
        i:=zcMainForm.PageControl.PageCount-1;
      zcMainForm.PageControl.ActivePageIndex:=i;
      zcMainForm.ChangedDWGTab(zcMainForm.PageControl);
    end;
  result:=cmd_ok;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@DWGPrev_com,'DWGPrev',0,0);
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
