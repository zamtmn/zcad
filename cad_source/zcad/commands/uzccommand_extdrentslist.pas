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
unit uzccommand_extdrentslist;

{$INCLUDE zengineconfig.inc}

interface
uses
  uzcLog,SysUtils,
  uzccommandsabstract,uzccommandsimpl,
  uzeentity,gzctnrVectorTypes,uzcdrawings,uzcstrconsts,uzeentityextender,
  uzcinterface,gzctnrSTL;

function extdrEntsList_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;

implementation

function extdrEntsList_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
type
  TExtCounter=TMyMapCounter<TMetaEntityExtender>;
var
  pv,pls:pGDBObjEntity;
  ir:itrec;
  i:integer;
  count:integer;
  extcounter:TExtCounter;
  pair:TExtCounter.TDictionaryPair;
begin
  extcounter:=TExtCounter.create;
  try
    count:=0;

    pls:=drawings.GetCurrentOGLWParam.SelDesc.LastSelectedObject;
    if pls<>nil then begin
      inc(count);
      if Assigned(pls^.EntExtensions) then begin
        for i:=0 to pls^.EntExtensions.GetExtensionsCount-1 do begin
          extcounter.CountKey(typeof(pls^.EntExtensions.GetExtension(i)),1);
        end;
      end;
    end;

    pv:=drawings.GetCurrentROOT^.ObjArray.beginiterate(ir);
    if pv<>nil then
    repeat
      if (pv^.Selected)and(pv<>pls) then begin
        inc(count);
        if Assigned(pv^.EntExtensions) then begin
          for i:=0 to pv^.EntExtensions.GetExtensionsCount-1 do begin
            extcounter.CountKey(typeof(pv^.EntExtensions.GetExtension(i)),1);
          end;
        end;
      end;
      pv:=drawings.GetCurrentROOT^.ObjArray.iterate(ir);
    until pv=nil;
    ZCMsgCallBackInterface.TextMessage(format(rscmNEntitiesProcessed,[count]),TMWOHistoryOut);
    count:=0;
    for pair in extcounter do begin
      ZCMsgCallBackInterface.TextMessage(format('Extender "%s" found %d times',[pair.Key.getExtenderName,pair.Value]),TMWOHistoryOut);
      inc(count);
    end;
    if count=0 then
      ZCMsgCallBackInterface.TextMessage(format('No extenders found',[]),TMWOHistoryOut);
  finally
    extcounter.Free;
    result:=cmd_ok;
  end;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@extdrEntsList_com,'extdrEntsList',CADWG or CASelEnts,0);
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
