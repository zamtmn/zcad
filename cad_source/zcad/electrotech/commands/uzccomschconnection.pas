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
unit uzcComSCHConnection;

{$INCLUDE zengineconfig.inc}

interface
uses
  uzcLog,
  uzccommandsabstract,
  uzeentity,
  uzcExtdrSCHConnection,uzcExtdrSCHConnector;

function AddExtdrSCHConnection(const AStage:TEntitySetupStage;const APEnt:PGDBObjEntity;
  const ASD:TEntitySetupData):boolean;

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

initialization
  ProgramLog.LogOutFormatStr(clUInit,[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
finalization
  ProgramLog.LogOutFormatStr(clUFin,[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
