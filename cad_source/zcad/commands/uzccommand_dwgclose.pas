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

unit uzccommand_DWGClose;
{$INCLUDE zengineconfig.inc}

interface
uses
  uzcLog,Forms,
  uzccommandsabstract,uzccommandsimpl,
  uzcdrawing,uzcdrawings,uzccommand_quit,
  uzcmainwindow;

implementation

function DWGClose_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var
   CurrentDWG:PTZCADDrawing;
begin
  application.ProcessMessages;
  CurrentDWG:=PTZCADDrawing(drawings.GetCurrentDWG);
  _CloseDWGPage(CurrentDWG,ZCADMainWindow.PageControl.ActivePage,false,nil);
  result:=cmd_ok;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@DWGClose_com,'DWGClose',CADWG,0).CEndActionAttr:=[CEDWGNChanged];
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
