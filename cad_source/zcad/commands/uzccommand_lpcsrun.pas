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
 uzcLapeScriptsManager,uzcLapeScriptsImplBase,
 uzcsysvars;
var
  CommandScriptsManager:TScriptsManager;
implementation
function LPCSRun_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
begin
  try
    CommandScriptsManager.RunScript(operands);
  except
    on E: Exception do
    begin
      ProgramLog.LogOutFormatStr('LPCSRun: %s',[E.Message],LM_Error,LapeLMId,MO_SM);
    end;
  end;
  result:=cmd_ok;
end;


initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  CommandScriptsManager:=STManager.CreateType('lpcs','Command script',TCurrentDrawingContext,[ttest.testadder,ttest.setCurrentDrawing]);
  CommandScriptsManager.ScanDirs(sysvar.PATH.Preload_Path^);
  CreateZCADCommand(@LPCSRun_com,'LPCSRun',0,0);
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
end.
