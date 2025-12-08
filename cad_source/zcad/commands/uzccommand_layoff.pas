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
unit uzccommand_layoff;

{$INCLUDE zengineconfig.inc}

interface

uses
  uzcLog,
  uzccommandsabstract,uzeentity,uzcdrawing,uzcdrawings,uzccommandsmanager,
  uzcstrconsts,uzcutils,zUndoCmdChgBaseTypes,zUndoCmdChgTypes,uzccommandsimpl;

implementation

const
  LayOffCommandName='LayOff';

function LayOff_com(const Context:TZCADCommandContext;
  operands:TCommandOperands):TCommandResult;
var
  _PEntity:PGDBObjEntity;
  UndoStartMarkerPlaced:boolean;
begin
  UndoStartMarkerPlaced:=False;
  while commandmanager.getentity(rscmSelectEntity,_PEntity)=IRNormal do begin
    if _PEntity^.vp.Layer._on then begin
      zcPlaceUndoStartMarkerIfNeed(UndoStartMarkerPlaced,LayOffCommandName,True);
      with TBooleanChangeCommand.CreateAndPushIfNeed(
             PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack,
             TChangedBoolean.CreateRec(_PEntity^.vp.Layer._on),
             TSharedEmpty(Default(TEmpty)),
             TAfterChangeEmpty(Default(TEmpty))) do begin
        _PEntity^.vp.Layer._on:=not _PEntity^.vp.Layer._on;
        //ComitFromObj;
      end;
      zcRedrawCurrentDrawing;
    end;
  end;
  zcPlaceUndoEndMarkerIfNeed(UndoStartMarkerPlaced);
  Result:=cmd_ok;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@LayOff_com,LayOffCommandName,CADWG,0);

finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsFinalizeLMId);
end.
