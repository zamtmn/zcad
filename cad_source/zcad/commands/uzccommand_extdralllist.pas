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
unit uzccommand_extdralllist;

interface
uses
  uzcLog,SysUtils,
  uzccommandsabstract,uzccommandsimpl,
  uzcinterface,uzeentityextender;

implementation

function extdrAllList_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var
  pair:TEntityExtendersMap.TDictionaryPair;
begin
  for pair in EntityExtenders do
    ZCMsgCallBackInterface.TextMessage(pair.value.getExtenderName,TMWOHistoryOut);
  result:=cmd_ok;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@extdrAllList_com,'extdrAllList',0,0);
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
