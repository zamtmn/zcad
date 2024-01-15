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
unit uzccommand_selectobjectbyaddres;

{$INCLUDE zengineconfig.inc}

interface
uses
  uzcLog,
  uzccommandsabstract,uzccommandsimpl,
  uzeentity,
  uzcutils,
  uzcinterface,
  uzcdrawings;

implementation

function SelectObjectByAddres_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var
  pp:PGDBObjEntity;
  code:integer;
begin
  val(Operands,PtrUInt(pp),code);
  if (code=0)and(assigned(pp))then
    zcSelectEntity(pp);
  ZCMsgCallBackInterface.Do_GUIaction(nil,ZMsgID_GUIActionRedraw);
  ZCMsgCallBackInterface.Do_GUIaction(drawings.CurrentDWG.wa,ZMsgID_GUIActionSelectionChanged);
  result:=cmd_ok;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@SelectObjectByAddres_com,'SelectObjectByAddres',CADWG,0);
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.


