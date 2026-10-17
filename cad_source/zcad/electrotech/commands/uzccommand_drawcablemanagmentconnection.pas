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
unit uzcCommand_DrawCableManagmentConnection;

{$INCLUDE zengineconfig.inc}

interface
uses
  uzcLog,
  uzccommandsabstract,uzccommandsimpl,
  uzcstrconsts,
  uzccommandsmanager,
  uzcExtdrSCHConnector,
  uzccommand_line,uzcComSCHConnection;

const
  cNTCableManagmentName='ELCableManagmentConnection';

var
  NTCableManagment:TNetTypeHandle;


implementation

function DrawCableManagmentConnection_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
begin
  Result:=InteractiveDrawLines(Context,rscmSpecifyFirstPoint,rscmSpecifyNextPoint,AddExtdrSCHConnection,
    Pointer(NTCableManagment));
end;

initialization
  programlog.LogOutFormatStr(clUInit,[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  NTCableManagment:=RegisrterNETType(cNTCableManagmentName,TNetTypeData.CreateRec(0.5,0.5,KTEmpty,KTCircle));
  CreateZCADCommand(@DrawCableManagmentConnection_com,'DrawCableManagmentConnection',CADWG,0);
finalization
  ProgramLog.LogOutFormatStr(clUFin,[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
