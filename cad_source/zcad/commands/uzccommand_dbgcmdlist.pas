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
unit uzccommand_dbgCmdList;

{$INCLUDE zengineconfig.inc}

interface
uses
  uzcLog,
  uzccommandsabstract,uzccommandsimpl,
  gzctnrVectorTypes,uzctnrvectorstrings,
  uzccommandsmanager,
  uzcinterface;

implementation

function dbgCmdList_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var
   p:PCommandObjectDef;
   ir:itrec;
   clist:TZctnrVectorStrings;
begin
   clist.init(200);
   p:=commandmanager.beginiterate(ir);
   if p<>nil then
   repeat
         clist.PushBackData(p^.CommandName);
         p:=commandmanager.iterate(ir);
   until p=nil;
   clist.sort;
   ZCMsgCallBackInterface.TextMessage(clist.GetTextWithEOL,TMWOHistoryOut);
   clist.done;
   result:=cmd_ok;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@dbgCmdList_com,'dbgCmdList',0,0);
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
