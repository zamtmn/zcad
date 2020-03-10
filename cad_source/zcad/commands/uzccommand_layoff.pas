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
unit uzccommand_layoff;

{$INCLUDE def.inc}

interface
uses
  uzccommandsabstract,uzeentity,uzcdrawing,uzcdrawings,uzccommandsmanager,
  uzcstrconsts,uzcutils,zcchangeundocommand,uzbtypes,uzccommandsimpl;

implementation
const
  LayOffCommandName='LayOff';
function LayOff_com(operands:TCommandOperands):TCommandResult;
var
  PEntity:PGDBObjEntity;
  UndoStartMarkerPlaced:boolean;
begin
  UndoStartMarkerPlaced:=false;
  while commandmanager.getentity(rscmSelectEntity,PEntity) do
  begin
   if PEntity^.vp.Layer._on then begin
     zcPlaceUndoStartMarkerIfNeed(UndoStartMarkerPlaced,LayOffCommandName,true);
     with PushCreateTGChangeCommand(PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack,PEntity^.vp.Layer._on)^ do
     begin
       PEntity^.vp.Layer._on:=not PEntity^.vp.Layer._on;
       ComitFromObj;
     end;
     zcRedrawCurrentDrawing;
   end;
  end;
  zcPlaceUndoEndMarkerIfNeed(UndoStartMarkerPlaced);
  result:=cmd_ok;
end;
initialization
  CreateCommandFastObjectPlugin(@LayOff_com,LayOffCommandName,CADWG,0);
end.
