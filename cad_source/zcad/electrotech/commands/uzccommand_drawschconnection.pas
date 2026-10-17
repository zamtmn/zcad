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
unit uzcCommand_DrawSCHConnection;

{$INCLUDE zengineconfig.inc}

interface
uses
  uzcLog,
  uzccommandsabstract,uzccommandsimpl,
  uzcstrconsts,
  uzccommandsmanager,
  uzeentity,
  uzcExtdrSCHConnection,uzcExtdrSCHConnector,
  uzccommand_line;

const
  cNTwireName='ELSCHConnection';

var
  NTwire:TNetTypeHandle;


implementation

function AddExtdrSCHConnection(const AStage:TEntitySetupStage;const APEnt:PGDBObjEntity;
  const ASD:TEntitySetupData):boolean;
var
  extdr:TSCHConnectionExtender;
begin
  case AStage of
    ESSSuppressCommandParams:
      result:=true;
    ESSSetEntity:begin
      if APEnt<>nil then begin
        extdr:=AddSCHConnectionExtenderToEntity(APEnt);
        if extdr<>nil then
          extdr.FNetType:=TNetTypeHandle(ASD);
        result:=true;
      end else
        result:=False;
      end;
    ESSSetConstructEntity:
      result:=False;
    ESSCommandEnd:
      result:=False;
  end;
end;

function DrawSCHConnection_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
begin
  Result:=InteractiveDrawLines(Context,rscmSpecifyFirstPoint,rscmSpecifyNextPoint,AddExtdrSCHConnection,
    Pointer(NTwire));
end;

initialization
  programlog.LogOutFormatStr(clUInit,[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  NTwire:=RegisrterNETType(cNTwireName,TNetTypeData.CreateRec(0.5,0.5,KTArc,KTFilledCircle));
  CreateZCADCommand(@DrawSCHConnection_com,'DrawSCHConnection',CADWG,0);
finalization
  ProgramLog.LogOutFormatStr(clUFin,[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
