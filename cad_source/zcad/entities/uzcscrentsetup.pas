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
unit uzcScrEntSetup;
{$INCLUDE zengineconfig.inc}

interface

uses
  SysUtils,
  gzctnrVectorTypes,
  uzccommandsimpl,
  uzeentity,uzeentdevice,
  uzcExtdrReport,
  uzcinterface,uzeconsts,
  uzcsysvars,
  uzccommandsabstract,
  uzcLapeScriptsImplBase,uzcLapeScriptsImplDrawing,uzcLapeScriptsManager;

var
  EntitySetupScriptsManager:TScriptsManager;

procedure RunEntityInitialsetup(const AEnt:PGDBObjEntity;const AScriptName:string; const Context:TZCADCommandContext);

implementation

procedure Execute(const AScriptName:string;var Context:TZCADCommandContext);
var
 scrd:TScriptData;
begin
  scrd:=EntitySetupScriptsManager.CreateExternalScriptData(AScriptName,TDeviceExtentionContext,[]);
  EntitySetupScriptsManager.RunScript(Context,scrd);
  EntitySetupScriptsManager.FreeExternalScriptData(scrd);
end;


procedure RunEntityInitialsetup(const AEnt:PGDBObjEntity;const AScriptName:string; const Context:TZCADCommandContext);
var
  tmpCtx:TZCADCommandContext;
begin
  try
    tmpCtx:=Context;
    tmpCtx.POwner:=AEnt;
    Execute(AScriptName,tmpCtx);
  finally
  end;
end;

initialization
  EntitySetupScriptsManager:=STManager.CreateType('lpeis','Lape script entity initial setup',
    TDeviceExtentionContext,LSCMCreateOnce,[TLapeDwg.ze2cplr,TLapeDwg.zeStyles2cplr,
    TLapeDwg.zeEntsExtenders2cplr,TLapeEntityExtention.thisEntity2cplr,TLapeDwg.ctxSetup,
    TLapeDwg.ctxSetup,TLapeEntityExtention.ctxSetup]);
  if sysvar.PATH.Preload_Paths<>nil then
    EntitySetupScriptsManager.ScanDirs(sysvar.PATH.Preload_Paths^);
finalization
end.
