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
unit uzccommand_VarsLink;

{$INCLUDE zengineconfig.inc}

interface
uses
  uzcLog,
  uzccommandsabstract,uzccommandsimpl,
  uzcenitiesvariablesextender,
  uzccommandsmanager,uzeentity,
  uzcinterface;

resourcestring
  rscmSelectEntityWithMainFunction='Select entity with main function';
  rscmSelectLinkedEntity='Select linked entity';

implementation

function VarsLink_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var
    pobj: pGDBObjEntity;
    pmainobj: pGDBObjEntity;

    pCentralVarext,pVarext:TVariablesExtender;
begin
  pmainobj:=nil;
  repeat
    if pmainobj=nil then
      if not commandmanager.getentity(rscmSelectEntityWithMainFunction,pmainobj) then
        exit(cmd_ok);
    pCentralVarext:=pmainobj^.GetExtension<TVariablesExtender>;
    if pCentralVarext=nil then begin
      pmainobj:=nil;
      ZCMsgCallBackInterface.TextMessage('Please select device with variables',TMWOSilentShowError);
    end;
  until pCentralVarext<>nil;

  repeat
    if not commandmanager.getentity(rscmSelectLinkedEntity,pobj) then
      exit(cmd_ok);
    pVarext:=pobj^.GetExtension<TVariablesExtender>;
    if pVarext=nil then begin
      ZCMsgCallBackInterface.TextMessage('Please select device with variables',TMWOSilentShowError);
    end else begin
      pCentralVarext.addDelegate({pmainobj,}pobj,pVarext);
    end;
  until false;

  result:=cmd_ok;
end;



initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  CreateZCADCommand(@VarsLink_com,'VarsLink',   CADWG,0);
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
