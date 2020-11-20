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
unit uzccommand_undo;

{$INCLUDE def.inc}

interface
uses
  LazLogger,
  uzccommandsabstract,uzccommandsimpl,
  uzcinterface,
  uzcdrawings,uzcdrawing,
  uzccommandsmanager,
  uzcutils,
  zeundostack,
  uzcstrconsts;

implementation

function Undo_com(operands:TCommandOperands):TCommandResult;
var
   prevundo:integer;
   overlay:Boolean;
   msg:string;
begin
  drawings.GetCurrentROOT.ObjArray.DeSelect(drawings.GetCurrentDWG.wa.param.SelDesc.Selectedobjcount,drawings.GetCurrentDWG^.deselector);
  drawings.GetCurrentDWG.GetSelObjArray.Free;
  if commandmanager.CommandsStack.Count>0 then begin
    prevundo:=pCommandRTEdObject(ppointer(commandmanager.CommandsStack.getDataMutable(commandmanager.CommandsStack.Count-1))^)^.UndoTop;
    overlay:=true;
  end else begin
    prevundo:=0;
    overlay:=false;
    ZCMsgCallBackInterface.Do_GUIaction(nil,ZMsgID_GUIReturnToDefaultObject);
  end;
  case PTZCADDrawing(drawings.GetCurrentDWG).UndoStack.undo(msg,prevundo,overlay) of
    URRNoCommandsToUndoInOverlayMode:ZCMsgCallBackInterface.TextMessage(rscmNoCTUSE,TMWOShowError);
    URRNoCommandsToUndo:ZCMsgCallBackInterface.TextMessage(rscmNoCTU,TMWOShowError);
  end;
  if msg<>'' then ZCMsgCallBackInterface.TextMessage(msg,TMWOHistoryOut);
  zcRedrawCurrentDrawing;
  result:=cmd_ok;
end;

initialization
  debugln('{I}[UnitsInitialization] Unit "',{$INCLUDE %FILE%},'" initialization');
  CreateCommandFastObjectPlugin(@undo_com,'Undo',CADWG or CACanUndo,0).overlay:=true;
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
end.
