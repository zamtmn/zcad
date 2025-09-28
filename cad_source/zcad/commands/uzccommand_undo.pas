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

function Undo_com(const Context:TZCADCommandContext;
  operands:TCommandOperands):TCommandResult;
var
  prevundo:integer;
  overlay:boolean;
  msg:string;
begin
  drawings.GetCurrentROOT.ObjArray.DeSelect(
    drawings.GetCurrentDWG.wa.param.SelDesc.Selectedobjcount,
    drawings.GetCurrentDWG^.deselector);
  drawings.GetCurrentDWG.GetSelObjArray.Free;
  if commandmanager.CommandsStack.Count>0 then begin
    prevundo:=pCommandRTEdObject(
      ppointer(commandmanager.CommandsStack.getDataMutable(
      commandmanager.CommandsStack.Count-1))^)^.UndoTop;
    overlay:=True;
  end else begin
    prevundo:=0;
    overlay:=False;
    zcUI.Do_GUIaction(nil,zcMsgUIReturnToDefaultObject);
  end;
  case PTZCADDrawing(drawings.GetCurrentDWG).UndoStack.undo(msg,prevundo,overlay) of
    URRNoCommandsToUndoInOverlayMode:zcUI.TextMessage(rscmNoCTUSE,TMWOShowError);
    URRNoCommandsToUndo:zcUI.TextMessage(rscmNoCTU,TMWOShowError);
    URROk,URRNoCommandsToRedo:;//заглушка от варнинга
  end;
  if msg<>'' then
    zcUI.TextMessage(msg,TMWOHistoryOut);
  zcRedrawCurrentDrawing;
  Result:=cmd_ok;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@undo_com,'Undo',CADWG or CACanUndo,0).overlay:=True;

finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsFinalizeLMId);
end.
