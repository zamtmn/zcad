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

unit uzcCommand_LPCSRun;
{$INCLUDE zengineconfig.inc}

interface

uses
  SysUtils,
  uzcLog,uzcreglog,
  uzbpaths,uzccommandsabstract,uzccommandsimpl,uzmenusmanager,
  uzcLapeScriptsManager,uzcLapeScriptsImplBase,uzcLapeScriptsImplDrawing,
  uzcsysvars;

var
  CommandScriptsManager:TScriptsManager;

implementation

function LPCSRun_com(const Context:TZCADCommandContext;
  operands:TCommandOperands):TCommandResult;
begin
  try
    CommandScriptsManager.RunScript(Context,operands);
  except
    on E:Exception do begin
      ProgramLog.LogOutFormatStr('LPCSRun: %s',[E.Message],LM_Error,LapeLMId,MO_SM);
    end;
  end;
  Result:=cmd_ok;
end;


initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsInitializeLMId);
  CommandScriptsManager:=STManager.CreateType('lpcs','Command script',
    TCurrentDrawingContext,LSCMRecreate,
    [TLapeBase.zcBase2cplr,
     TLapeDwg.ze2cplr,TLapeDwg.zcEnt2cplr,TLapeDwg.zcUndo2cplr,
     TLapeDwg.zcInteractive2cplr,TLapeDwg.zcStyles2cplr,
     TLapeDwg.ctxSetup]);
  if sysvar.PATH.Preload_Paths<>nil then
    CommandScriptsManager.ScanDirs(ExpandPath(sysvar.PATH.Preload_Paths^));
  CreateZCADCommand(@LPCSRun_com,'LPCSRun',0,0);

finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsFinalizeLMId);
end.
