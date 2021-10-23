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
unit uzccommand_extdralllist;

{$INCLUDE def.inc}

interface
uses
  LazLogger,SysUtils,
  uzccommandsabstract,uzccommandsimpl,
  uzeentity,gzctnrvectortypes,uzcdrawings,uzcdrawing,uzcstrconsts,
  uzcinterface,uzcutils,gzctnrstl,gutil;

function extdrAllList_com(operands:TCommandOperands):TCommandResult;

implementation

function extdrAllList_com(operands:TCommandOperands):TCommandResult;
type
  TExtCounter=TMyMapCounter<string,TLess<String>>;
var
  pv:pGDBObjEntity;
  ir:itrec;
  i:integer;
  count:integer;
  //extendername:string;
  extcounter:TExtCounter;
  //tp:TExtCounter.TPair;
  Iterator:TExtCounter.TIterator;
begin
  extcounter:=TExtCounter.create;
  try
    count:=0;
    pv:=drawings.GetCurrentROOT^.ObjArray.beginiterate(ir);
    if pv<>nil then
    repeat
      if pv^.Selected then begin
        inc(count);
        if Assigned(pv^.EntExtensions) then begin
          for i:=0 to pv^.EntExtensions.GetExtensionsCount-1 do begin
            extcounter.CountKey(pv^.EntExtensions.GetExtension(i).getExtenderName,1);
          end;
        end;
      end;
      pv:=drawings.GetCurrentROOT^.ObjArray.iterate(ir);
    until pv=nil;
    ZCMsgCallBackInterface.TextMessage(format(rscmNEntitiesProcessed,[count]),TMWOHistoryOut);
    //не работает for in для TMap((
    //https://gitlab.com/freepascal.org/fpc/source/-/issues/39354
    {count:=0;
    for tp in extcounter do begin
      ZCMsgCallBackInterface.TextMessage(format('Extender "%s" found %d times',[tp.key,tp.value]),TMWOHistoryOut);
      inc(count);
    end;
    if count=0 then
      ZCMsgCallBackInterface.TextMessage(format('No extenders found',[]),TMWOHistoryOut);}

    //поэтому приходится делать через итератор
    count:=0;
    iterator:=extcounter.Min;
    if assigned(iterator) then
    repeat
      ZCMsgCallBackInterface.TextMessage(format('Extender "%s" found %d times',[iterator.GetKey,iterator.GetValue]),TMWOHistoryOut);
      inc(count);
    until not iterator.Next;
    if assigned(iterator) then
      iterator.destroy;
    if count=0 then
      ZCMsgCallBackInterface.TextMessage(format('No extenders found',[]),TMWOHistoryOut);
  finally
    extcounter.Free;
    result:=cmd_ok;
  end;
end;

initialization
  debugln('{I}[UnitsInitialization] Unit "',{$INCLUDE %FILE%},'" initialization');
  CreateCommandFastObjectPlugin(@extdrAllList_com,'extdrAllList',CADWG or CASelEnts,0);
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
end.
