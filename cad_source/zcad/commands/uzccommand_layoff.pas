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
function LayOff_com(operands:TCommandOperands):TCommandResult;
var
  pd:PGDBObjEntity;
  UndoStartMarkerPlaced:boolean;
begin
  UndoStartMarkerPlaced:=false;
  while commandmanager.getentity(rscmSelectEntity,pd) do
  begin
   if pd^.vp.Layer._on then begin
     zcPlaceUndoStartMarkerIfNeed(UndoStartMarkerPlaced,'LayOff',true);
     with PushCreateTGChangeCommand(PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack,pd^.vp.Layer._on)^ do
     begin
       pd^.vp.Layer._on:=not pd^.vp.Layer._on;
       ComitFromObj;
     end;
     zcRedrawCurrentDrawing;
   end;
  end;
  zcPlaceUndoEndMarkerIfNeed(UndoStartMarkerPlaced);
  result:=cmd_ok;
end;
initialization
  CreateCommandFastObjectPlugin(@LayOff_com,'LayOff',CADWG,0);
end.
