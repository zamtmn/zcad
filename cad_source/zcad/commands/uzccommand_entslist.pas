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
unit uzccommand_entslist;

{$INCLUDE zengineconfig.inc}

interface
uses
  LazLogger,SysUtils,
  uzccommandsabstract,uzccommandsimpl,
  uzctnrvectorstrings,
  //uzccommandsmanager,
  uzeentityfactory,
  uzcinterface;

implementation

function EntsList_com(operands:TCommandOperands):TCommandResult;
var
   //p:PCommandObjectDef;
   //ir:itrec;
   clist:TZctnrVectorStrings;
   pair:ObjID2EntInfoData.TDictionaryPair;
   //iterator:ObjID2EntInfoData.TIterator;
begin
   clist.init(200);
   for pair in ObjID2EntInfoData do begin
   //iterator:=ObjID2EntInfoData.Min;
   //if assigned(iterator) then
   //repeat
         clist.PushBackData(format('%s | %s',[pair.Value.UserName,pair.Value.DXFName]));
   //until not iterator.Next;
   //if assigned(iterator) then
   //  iterator.destroy;
   end;
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
