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
unit uzccommand_deselectall;

{$INCLUDE zengineconfig.inc}

interface

uses
  uzcLog,
  uzccommandsabstract,uzccommandsimpl,
  uzeentity,
  uzcinterface;

implementation

var
  deselall:pCommandFastObjectPlugin;

function DeSelectAll_com(const Context:TZCADCommandContext;
  operands:TCommandOperands):TCommandResult;
begin
  zcUI.Do_GUIaction(nil,zcMsgUIActionRedraw);
  //if assigned(updatevisibleproc) then updatevisibleproc(zcMsgUIActionRedraw);
  Result:=cmd_ok;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsInitializeLMId);
  deselall:=CreateZCADCommand(@DeSelectAll_com,'DeSelectAll',CADWG  or CASelEnts,0);
  deselall^.CEndActionAttr:=[CEGUIReturnToDefaultObject,CEDeSelect];
  deselall^.overlay:=True;

finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsFinalizeLMId);
end.
