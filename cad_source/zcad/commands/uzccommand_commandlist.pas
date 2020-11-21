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
{$mode delphi}
unit uzccommand_commandlist;

{$INCLUDE def.inc}

interface
uses
  LazLogger,
  uzccommandsabstract,uzccommandsimpl,
  gzctnrvectortypes,uzctnrvectorgdbstring,
  uzccommandsmanager,
  uzcinterface;

implementation

function CommandList_com(operands:TCommandOperands):TCommandResult;
var
   p:PCommandObjectDef;
   ir:itrec;
   clist:TZctnrVectorGDBString;
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
  debugln('{I}[UnitsInitialization] Unit "',{$INCLUDE %FILE%},'" initialization');
  CreateCommandFastObjectPlugin(@CommandList_com,'CommandList',0,0);
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
end.
