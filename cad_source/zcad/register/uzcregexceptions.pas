{
*****************************************************************************
*                                                                           *
*  This file is part of the ZCAD                                            *
*                                                                           *
*  See the file COPYING.modifiedLGPL.txt, included in this distribution,    *
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

unit uzcregexceptions;
{$INCLUDE def.inc}
interface

uses
  LazLogger,uzclog,uzcsysvars,uzbpaths,uzcexceptions;

implementation

procedure ProvideLog(var f:system.text);
begin
  WriteLn(f);
  WriteLn(f,'Latest log:');
  programlog.WriteLatestToFile(f);
  WriteLn(f,'Log end.');
end;

procedure ProvideBuildAndRunTimeInfo(var f:system.text);
begin
  WriteLn(f);
  WriteLn(f,'Build and runtime info:');
  Write(f,  '  ZCAD ');WriteLn(f,sysvar.SYS.SYS_Version^);
  Write(f,  '  Build with ');Write(f,sysvar.SYS.SSY_CompileInfo.SYS_Compiler);Write(f,' v');WriteLn(f,sysvar.SYS.SSY_CompileInfo.SYS_CompilerVer);
  Write(f,  '  Target CPU: ');WriteLn(f,sysvar.SYS.SSY_CompileInfo.SYS_CompilerTargetCPU);
  Write(f,  '  Target OS: ');WriteLn(f,sysvar.SYS.SSY_CompileInfo.SYS_CompilerTargetOS);
  Write(f,  '  Compile date: ');WriteLn(f,sysvar.SYS.SSY_CompileInfo.SYS_CompileDate);
  Write(f,  '  Compile time: ');WriteLn(f,sysvar.SYS.SSY_CompileInfo.SYS_CompileTime);
  Write(f,  '  LCL version: ');WriteLn(f,sysvar.SYS.SSY_CompileInfo.SYS_LCLVersion);
  Write(f,  '  Environment version: ');WriteLn(f,sysvar.SYS.SSY_CompileInfo.SYS_EnvironmentVersion);
  Write(f,  '  Program  path: ');WriteLn(f,ProgramPath);
  Write(f,  '  Temporary  path: ');WriteLn(f,TempPath);
  WriteLn(f,'end.');
end;

initialization
  debugln('{I}[UnitsInitialization] Unit "',{$INCLUDE %FILE%},'" initialization');
  RegisterCrashInfoProvider(ProvideLog);
  RegisterCrashInfoProvider(ProvideBuildAndRunTimeInfo);
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
end.

