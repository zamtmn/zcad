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
unit uzccommand_LayerOff;

{$INCLUDE zengineconfig.inc}

interface
uses
  uzcLog,SysUtils,
  uzccommandsabstract,uzeentity,uzcdrawing,uzcdrawings,uzccommandsmanager,
  uzcstrconsts,uzcutils,gzundoCmdChgData,uzccommandsimpl,
  uzestyleslayers,uzcinterface;

implementation
const
  LayerOnCommandName='LayerOff';
function LayerOff_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var
  UndoStartMarkerPlaced:boolean;
  plp:PGDBLayerProp;
begin
  UndoStartMarkerPlaced:=false;
  plp:=drawings.GetCurrentDWG^.LayerTable.getAddres(operands);
  if plp<>nil then begin
    if not plp^._on then begin
      ZCMsgCallBackInterface.TextMessage(format(rsLayerAlreadyOff,[operands]),TMWOHistoryOut);
      result:=cmd_error;
    end else begin
      zcPlaceUndoStartMarkerIfNeed(UndoStartMarkerPlaced,LayerOnCommandName,true);
      with TBooleanChangeCommand.CreateAndPushIfNeed(PTZCADDrawing(drawings.GetCurrentDWG)^.UndoStack,plp^._on,nil,nil) do begin
        plp^._on:=not plp^._on;
        ComitFromObj;
      end;
      zcPlaceUndoEndMarkerIfNeed(UndoStartMarkerPlaced);
      result:=cmd_ok;
    end;
  end else begin
    ZCMsgCallBackInterface.TextMessage(format(rsLayerNotFound,[operands]),TMWOShowError);
    result:=cmd_error;
  end;
end;
initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@LayerOff_com,LayerOnCommandName,CADWG,0);
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
