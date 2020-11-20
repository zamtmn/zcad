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
unit uzccommand_redo;

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

function Redo_com(operands:TCommandOperands):TCommandResult;
var
   msg:string;
begin
  drawings.GetCurrentROOT.ObjArray.DeSelect(drawings.GetCurrentDWG.wa.param.SelDesc.Selectedobjcount,drawings.GetCurrentDWG^.deselector);
  case PTZCADDrawing(drawings.GetCurrentDWG).UndoStack.redo(msg) of
    URRNoCommandsToUndo:ZCMsgCallBackInterface.TextMessage(rscmNoCTR,TMWOShowError);
  end;
  if msg<>'' then ZCMsgCallBackInterface.TextMessage(msg,TMWOHistoryOut);
  zcRedrawCurrentDrawing;
  result:=cmd_ok;
end;

initialization
  debugln('{I}[UnitsInitialization] Unit "',{$INCLUDE %FILE%},'" initialization');
  CreateCommandFastObjectPlugin(@redo_com,'Redo',CADWG or CACanRedo,0).overlay:=true;
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
end.
