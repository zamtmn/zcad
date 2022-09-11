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

unit uzcregexceptions;
{$INCLUDE zengineconfig.inc}
interface

uses
  SysUtils,LazLogger,uzbLog, uzbLogTypes, uzcLog,uzcsysvars,uzbpaths,uzbexceptionscl,uzcstrconsts;

implementation

type
  TLatestLogStrings=array of AnsiString;
  TLatestMsgsBackend=object(TLogerBaseBackend)
    LatestLogStrings:TLatestLogStrings;
    LatestLogStringsCount,TotalLogStringsCount:integer;
    procedure doLog(msg:TLogMsg;MsgOptions:TMsgOpt;LogMode:TLogLevel;LMDI:TModuleDesk);virtual;
    procedure endLog;virtual;
    constructor init(MaxLLStrings:Integer);
    destructor done;virtual;
    procedure WriteLatestToFile(var f:system.text);
  end;
var
  LLMsgs:TLatestMsgsBackend;
  LLMsgsH:TBackendHandle;

procedure TLatestMsgsBackend.doLog(msg:TLogMsg;MsgOptions:TMsgOpt;LogMode:TLogLevel;LMDI:TModuleDesk);
begin
  if LatestLogStringsCount>High(LatestLogStrings) then
    LatestLogStringsCount:=Low(LatestLogStrings);
  LatestLogStrings[LatestLogStringsCount]:=msg;
  inc(TotalLogStringsCount);
  inc(LatestLogStringsCount);
end;

procedure TLatestMsgsBackend.endLog;
begin
end;

constructor TLatestMsgsBackend.init(MaxLLStrings:Integer);
begin
  setlength(LatestLogStrings,MaxLLStrings);
  LatestLogStringsCount:=0;
  TotalLogStringsCount:=0;
end;

destructor TLatestMsgsBackend.done;
begin
  setlength(LatestLogStrings,0);
end;

procedure TLatestMsgsBackend.WriteLatestToFile(var f:system.text);
var
  currentindex,LatestLogArraySize:integer;
begin
     if TotalLogStringsCount=0 then exit;
     LatestLogArraySize:=Low(LatestLogStrings);
     LatestLogArraySize:=High(LatestLogStrings);
     LatestLogArraySize:=High(LatestLogStrings)-Low(LatestLogStrings)+1;
     if TotalLogStringsCount>LatestLogArraySize then
                                                    currentindex:=LatestLogStringsCount
                                                else
                                                    currentindex:=Low(LatestLogStrings);
     if TotalLogStringsCount<LatestLogArraySize then
                                                    LatestLogArraySize:=TotalLogStringsCount;
     repeat
       if currentindex>High(LatestLogStrings) then
                                                  currentindex:=Low(LatestLogStrings);
       WriteLn(f,pchar(@LatestLogStrings[currentindex][1]));
       inc(currentindex);
       dec(LatestLogArraySize);
     until LatestLogArraySize=0;
end;

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
  LLMsgs.WriteLatestToFile(f);
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
  LLMsgs.init(99);
  LLMsgsH:=ProgramLog.addBackend(LLMsgs,'',[]);
  RegisterCrashInfoProvider(ProvideHeader,true);
  RegisterCrashInfoProvider(ProvideLog);
  RegisterCrashInfoProvider(ProvideBuildAndRunTimeInfo);
  RegisterCrashInfoProvider(ProvideFooter);
finalization
  debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
  ProgramLog.removeBackend(LLMsgsH);
  LLMsgs.done;
end.

