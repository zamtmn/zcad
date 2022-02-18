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
{$INCLUDE zcadconfig.inc}
interface

uses
  SysUtils,LazLogger,uzclog,uzcsysvars,uzbpaths,uzbexceptionscl,uzcstrconsts;

implementation

procedure ProvideHeader(var f:system.text;Obj : TObject; Addr: CodePointer; _FrameCount: Longint; _Frames: PCodePointer);
begin
  WriteLn(f);
  WriteLn(f,programname,' crashed ((');
  WriteLn(f);
end;

procedure ProvideFooter(var f:system.text;Obj : TObject; Addr: CodePointer; _FrameCount: Longint; _Frames: PCodePointer);
begin
  WriteLn(f,'______________________________________________________________________________________');
end;

procedure ProvideLog(var f:system.text;Obj : TObject; Addr: CodePointer; _FrameCount: Longint; _Frames: PCodePointer);
begin
  WriteLn(f);
  WriteLn(f,'Latest log:');
  programlog.WriteLatestToFile(f);
  WriteLn(f,'Log end.');
end;

procedure ProvideBuildAndRunTimeInfo(var f:system.text;Obj : TObject; Addr: CodePointer; _FrameCount: Longint; _Frames: PCodePointer);
begin
  WriteLn(f);
  WriteLn(f,'Build and runtime info:');
  Write(f,  '  ZCAD ');
  if sysvar.SYS.SYS_Version<>nil then
    WriteLn(f,sysvar.SYS.SYS_Version^)
  else
    WriteLn(f,'unknown version');
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
  //SetCrashReportFilename(GetTempDir+CrashReportFilename);
  RegisterCrashInfoProvider(ProvideHeader,true);
  RegisterCrashInfoProvider(ProvideLog);
  RegisterCrashInfoProvider(ProvideBuildAndRunTimeInfo);
  RegisterCrashInfoProvider(ProvideFooter);
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
end.

