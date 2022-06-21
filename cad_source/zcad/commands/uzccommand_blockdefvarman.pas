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
unit uzccommand_blockdefvarman;

{$INCLUDE zengineconfig.inc}

interface
uses
  LazLogger,
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

function BlockDefVarMan_com(operands:TCommandOperands):TCommandResult;
var
  pobj:PGDBObjEntity;
  op:ansistring;
  pentvarext:TVariablesExtender;
begin
  pobj:=nil;
  if drawings.GetCurrentDWG.wa.param.SelDesc.Selectedobjcount=1 then begin
    op:=PGDBObjEntity(drawings.GetCurrentDWG.GetLastSelected)^.GetNameInBlockTable;
    if op<>'' then
      pobj:=drawings.GetCurrentDWG.BlockDefArray.getblockdef(op)
  end else
    if length(Operands)>0 then begin
      op:=Operands;
      pobj:=drawings.GetCurrentDWG.BlockDefArray.getblockdef(op)
    end;
  if pobj<>nil then begin
    pentvarext:=pobj^.GetExtension<TVariablesExtender>;
    if pentvarext<>nil then begin
      if EditUnit(pentvarext.entityunit) then
        ZCMsgCallBackInterface.Do_GUIaction(nil,ZMsgID_GUIRePrepareObject);
    end;
  end else
    ZCMsgCallBackInterface.TextMessage(rscmSelOrSpecEntity,TMWOHistoryOut);
  result:=cmd_ok;
end;

initialization
  debugln('{I}[UnitsInitialization] Unit "',{$INCLUDE %FILE%},'" initialization');
  CreateCommandFastObjectPlugin(@BlockDefVarMan_com,'BlockDefVarMan',CADWG,0);
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
end.
