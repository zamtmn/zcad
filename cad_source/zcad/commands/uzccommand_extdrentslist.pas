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
  uzeentity,gzctnrVectorTypes,uzcdrawings,uzcstrconsts,uzeExtdrAbstractEntityExtender,
  uzcinterface,gzctnrSTL;

function extdrEntsList_com(const Context:TZCADCommandContext;
  operands:TCommandOperands):TCommandResult;

implementation

function extdrEntsList_com(const Context:TZCADCommandContext;
  operands:TCommandOperands):TCommandResult;
type
  TExtCounter=TMyMapCounter<TzeEntityExtenderClass>;
var
  pv,pls:pGDBObjEntity;
  ir:itrec;
  i:integer;
  Count:integer;
  extcounter:TExtCounter;
  pair:TExtCounter.TDictionaryPair;
  ee:TAbstractEntityExtender;
begin
  extcounter:=TExtCounter.Create;
  try
    Count:=0;

    pls:=drawings.GetCurrentOGLWParam.SelDesc.LastSelectedObject;
    if pls<>nil then begin
      Inc(Count);
      if Assigned(pls^.EntExtensions) then begin
        for i:=0 to pls^.EntExtensions.GetExtensionsCount-1 do begin
          ee:=pls^.EntExtensions.GetExtension(i);
          extcounter.CountKey(typeof(ee),1);
        end;
      end;
    end;

    pv:=drawings.GetCurrentROOT^.ObjArray.beginiterate(ir);
    if pv<>nil then
      repeat
        if (pv^.Selected)and(pv<>pls) then begin
          Inc(Count);
          if Assigned(pv^.EntExtensions) then begin
            for i:=0 to pv^.EntExtensions.GetExtensionsCount-1 do begin
              ee:=pls^.EntExtensions.GetExtension(i);
              extcounter.CountKey(typeof(ee),1);
            end;
          end;
        end;
        pv:=drawings.GetCurrentROOT^.ObjArray.iterate(ir);
      until pv=nil;
    zcUI.TextMessage(format(rscmNEntitiesProcessed,[Count]),TMWOHistoryOut);
    Count:=0;
    for pair in extcounter do begin
      zcUI.TextMessage(format('Extender "%s" found %d times',
        [pair.Key.getExtenderName,pair.Value]),TMWOHistoryOut);
      Inc(Count);
    end;
    if Count=0 then
      zcUI.TextMessage(format('No extenders found',[]),TMWOHistoryOut);
  finally
    extcounter.Free;
    Result:=cmd_ok;
  end;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@extdrEntsList_com,'extdrEntsList',CADWG or CASelEnts,0);

finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsFinalizeLMId);
end.
