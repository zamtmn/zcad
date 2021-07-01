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
unit uzccommand_entslist;

{$INCLUDE def.inc}

interface
uses
  LazLogger,SysUtils,
  uzccommandsabstract,uzccommandsimpl,
  gzctnrvectortypes,uzctnrvectorgdbstring,
  //uzccommandsmanager,
  uzeentityfactory,
  uzcinterface;

implementation

function EntsList_com(operands:TCommandOperands):TCommandResult;
var
   p:PCommandObjectDef;
   ir:itrec;
   clist:TZctnrVectorGDBString;
   iterator:ObjID2EntInfoData.TIterator;
begin
   clist.init(200);
   iterator:=ObjID2EntInfoData.Min;
   if assigned(iterator) then
   repeat
         clist.PushBackData(format('%s | %s',[iterator.Data.Value.UserName,iterator.Data.Value.DXFName]));
   until not iterator.Next;
   if assigned(iterator) then
     iterator.destroy;
   clist.sort;
   ZCMsgCallBackInterface.TextMessage(clist.GetTextWithEOL,TMWOHistoryOut);
   clist.done;
   result:=cmd_ok;
end;

initialization
  debugln('{I}[UnitsInitialization] Unit "',{$INCLUDE %FILE%},'" initialization');
  CreateCommandFastObjectPlugin(@EntsList_com,'EntsList',0,0);
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
end.
