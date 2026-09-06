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
  uzcinterface;

implementation

function DWGPrev_com(const Context:TZCADCommandContext;
  operands:TCommandOperands):TCommandResult;
var
  i,c:integer;
begin
  c:=zcUI.getDocumentControlsCount;
  if c>1 then begin
    i:=zcUI.getActiveDocumentControlIndex-1;
    if i<0 then
      i:=c-1;
    zcUI.setActiveDocumentControlIndex(i);
  end;
  Result:=cmd_ok;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@DWGPrev_com,'DWGPrev',0,0);

finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
