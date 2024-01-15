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
unit uzccommand_undo;

{$INCLUDE zengineconfig.inc}

interface
uses
  uzcLog,
  uzccommandsabstract,uzccommandsimpl,
  uzcinterface,
  uzcdrawings,uzcdrawing,
  uzccommandsmanager,
  uzcutils,
  zeundostack,
  uzcstrconsts;

implementation

function Undo_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
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
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@undo_com,'Undo',CADWG or CACanUndo,0).overlay:=true;
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
