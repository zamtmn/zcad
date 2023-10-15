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
unit uzceCommand_SCHConnection;

{$INCLUDE zengineconfig.inc}

interface
uses
  uzcLog,
  uzccommandsabstract,uzccommandsimpl,
  uzcstrconsts,
  uzccommandsmanager,
  uzeentity,
  uzcExtdrSCHConnection,
  uzccommand_line;

implementation

procedure AddExtdrSCHConnection(const PEnt:PGDBObjEntity);
begin
  AddSCHConnectionExtenderToEntity(PEnt);
end;

function SCHConnection_com(operands:TCommandOperands):TCommandResult;
begin
 Result:=InteractiveDrawLines(rscmSpecifyFirstPoint,rscmSpecifyNextPoint,AddExtdrSCHConnection);
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  CreateCommandFastObjectPlugin(@SCHConnection_com,'SCHConnection',CADWG,0);
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
