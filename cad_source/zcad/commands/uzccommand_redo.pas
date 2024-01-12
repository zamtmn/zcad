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
unit uzccommand_redo;

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

function Redo_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var
   msg:string;
begin
  drawings.GetCurrentROOT.ObjArray.DeSelect(drawings.GetCurrentDWG.wa.param.SelDesc.Selectedobjcount,drawings.GetCurrentDWG^.deselector);
  if PTZCADDrawing(drawings.GetCurrentDWG).UndoStack.redo(msg)=URRNoCommandsToUndo then
    ZCMsgCallBackInterface.TextMessage(rscmNoCTR,TMWOShowError);
  if msg<>'' then ZCMsgCallBackInterface.TextMessage(msg,TMWOHistoryOut);
  zcRedrawCurrentDrawing;
  result:=cmd_ok;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@redo_com,'Redo',CADWG or CACanRedo,0).overlay:=true;
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
