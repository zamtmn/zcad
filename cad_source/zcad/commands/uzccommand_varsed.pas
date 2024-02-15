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
unit uzccommand_VarsED;

{$INCLUDE zengineconfig.inc}

interface
uses
  uzcLog,
  Controls,
  sysutils,
  uzbpaths,
  uzccmdinfoform,
  uzccommandsabstract,uzccommandsimpl,
  uzctnrVectorBytes,
  uzeentity,
  uzcenitiesvariablesextender,
  uzcinterface,
  uzcstrconsts,
  uzcdrawings,
  UUnitManager,
  uzccmdeditunit,
  uzctranslations;

implementation

function VarsEd_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var
  pobj:PGDBObjEntity;
  pentvarext:TVariablesExtender;
begin
  if drawings.GetCurrentDWG.wa.param.SelDesc.Selectedobjcount=1 then
    pobj:=PGDBObjEntity(drawings.GetCurrentDWG.GetLastSelected)
  else
    pobj:=nil;
  if pobj<>nil then begin
    pentvarext:=pobj^.GetExtension<TVariablesExtender>;
    if pentvarext<>nil then begin
      if EditUnit(pentvarext.entityunit) then
        ZCMsgCallBackInterface.Do_GUIaction(nil,ZMsgID_GUIRePrepareObject);
    end;
   end else
     ZCMsgCallBackInterface.TextMessage(rscmSelEntBeforeComm,TMWOHistoryOut);
  result:=cmd_ok;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@VarsEd_com,'VarsEd',CADWG or CASelEnt,0);
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
