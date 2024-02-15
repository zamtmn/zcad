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
unit uzccommand_dbgBlocksList;

{$INCLUDE zengineconfig.inc}

interface
uses
  SysUtils,
  uzcLog,
  uzccommandsabstract,uzccommandsimpl,
  uzbstrproc,
  gzctnrVectorTypes,
  uzeblockdef,uzcdrawings,uzcinterface;

implementation

function dbgBlocksList_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var pb:PGDBObjBlockdef;
    ir:itrec;
begin
  pb:=drawings.GetCurrentDWG^.BlockDefArray.beginiterate(ir);
  if pb<>nil then repeat
    ZCMsgCallBackInterface.TextMessage(format('Found block "%s", contains %d entities',[Tria_AnsiToUtf8(pb^.name),pb^.ObjArray.Count]),TMWOHistoryOut);
    pb:=drawings.GetCurrentDWG^.BlockDefArray.iterate(ir);
  until pb=nil;
  result:=cmd_ok;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@dbgBlocksList_com,'dbgBlocksList',CADWG,0);
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
