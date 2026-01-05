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
  SysUtils,uzcLog,uzbLog, uzbLogTypes,uzcsysvars,uzbpaths,uzbexceptionscl,
  uzcstrconsts,uzcCommandLineParser;

implementation

type
  TLatestLogStrings=array of AnsiString;
  TLatestMsgsBackend=object(TLogerBaseBackend)
    LatestLogStrings:TLatestLogStrings;
    LatestLogStringsCount,TotalLogStringsCount:integer;
    procedure doLog(const msg:TLogMsg;MsgOptions:TMsgOpt;LogMode:TLogLevel;LMDI:TModuleDesk);virtual;
    procedure endLog;virtual;
    constructor init(MaxLLStrings:Integer);
    destructor done;virtual;
    procedure WriteLatestToFile(var f:system.text);
  end;
var
  LLMsgs:TLatestMsgsBackend;
  LLMsgsH:TLogExtHandle;
  MaxStackFrameCount:LongInt;

procedure TLatestMsgsBackend.doLog(const msg:TLogMsg;MsgOptions:TMsgOpt;LogMode:TLogLevel;LMDI:TModuleDesk);
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
  inherited init;
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
       WriteLn(f,'  ',pchar(@LatestLogStrings[currentindex][1]));
       inc(currentindex);
       dec(LatestLogArraySize);
     until LatestLogArraySize=0;
end;

procedure ProvideHeader(var f:system.text;ARaiseList:PExceptObject);
function lead0(d:Word):ShortString;
begin
  SetLength(Result,2);
  if d>9 then begin
    Result[1]:=char(ord('0')+(d div 10));
    Result[2]:=char(ord('0')+(d mod 10));
  end else begin
    Result[1]:='0';
    Result[2]:=char(ord('0')+d);
  end;
end;
var
  DateTime:TDateTime;
  Year,Month,Day:Word;
  Hour,Minute,Second,MilliSecond:Word;
begin
  WriteLn(f);
  WriteLn(f,programname,' crashed ((');
  DateTime:=Now;
  DecodeDate(DateTime,Year,Month,Day);
  DecodeTime(DateTime,Hour,Minute,Second,MilliSecond);
  WriteLn(f,'  Date: ',Year:4,'-',lead0(Month),'-',lead0(Day));
  WriteLn(f,'  Time: ',lead0(Hour),':',lead0(Minute),':',lead0(Second));
  WriteLn(f);
end;

procedure ProvideFooter(var f:system.text;ARaiseList:PExceptObject);
begin
  WriteLn(f,'______________________________________________________________________________________');
end;

procedure ProvideLog(var f:system.text;ARaiseList:PExceptObject);
begin
  WriteLn(f);
  WriteLn(f,'Latest log:');
  LLMsgs.WriteLatestToFile(f);
  WriteLn(f,'Log end.');
end;

procedure ProvideBuildAndRunTimeInfo(var f:system.text;ARaiseList:PExceptObject);
begin
  WriteLn(f);
  WriteLn(f,'Build and runtime info:');
  Write(f,  '  ZCAD ');
  if sysvar.SYS.SYS_Version<>nil then
    WriteLn(f,sysvar.SYS.SYS_Version^)
  else
    WriteLn(f,'unknown version');
  Write(f,  '  Build with ');Write(f,sysvar.SYS.SYS_CompileInfo.SYS_Compiler);Write(f,' v');WriteLn(f,sysvar.SYS.SYS_CompileInfo.SYS_CompilerVer);
  Write(f,  '  Target CPU: ');WriteLn(f,sysvar.SYS.SYS_CompileInfo.SYS_CompilerTargetCPU);
  Write(f,  '  Target OS: ');WriteLn(f,sysvar.SYS.SYS_CompileInfo.SYS_CompilerTargetOS);
  Write(f,  '  Compile date: ');WriteLn(f,sysvar.SYS.SYS_CompileInfo.SYS_CompileDate);
  Write(f,  '  Compile time: ');WriteLn(f,sysvar.SYS.SYS_CompileInfo.SYS_CompileTime);
  Write(f,  '  LCL version: ');WriteLn(f,sysvar.SYS.SYS_CompileInfo.SYS_LCLVersion);
  Write(f,  '  Environment version: ');WriteLn(f,sysvar.SYS.SYS_CompileInfo.SYS_EnvironmentVersion);
  Write(f,  '  Read only cfg path: ');WriteLn(f,GetRoCfgsPath);
  Write(f,  '  Temporary  path: ');WriteLn(f,GetTempPath);
  WriteLn(f,'end.');
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization',[{$INCLUDE %FILE%}],LM_Info,UnitsInitializeLMId);
  if CommandLineParser.HasOption(MaxStackFrameCountHDL) then
    if TryStrToInt(CommandLineParser.OptionOperand(MaxStackFrameCountHDL,0),MaxStackFrameCount) then begin
      RaiseMaxFrameCount:=MaxStackFrameCount;
      ProgramLog.LogOutFormatStr('set MaxStackFrameCount to "%d"',[MaxStackFrameCount],LM_Info);
    end else
      ProgramLog.LogOutFormatStr('MaxStackFrameCount "%s" - not a integer',[CommandLineParser.OptionOperand(MaxStackFrameCountHDL,0)],LM_Error);
  LLMsgs.init(99);
  LLMsgsH:=ProgramLog.addBackend(LLMsgs,'',[]);
  RegisterCrashInfoProvider(ProvideHeader,true);
  RegisterCrashInfoProvider(ProvideLog);
  RegisterCrashInfoProvider(ProvideBuildAndRunTimeInfo);
  RegisterCrashInfoProvider(ProvideFooter);
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
  ProgramLog.removeBackend(LLMsgsH);
  LLMsgs.done;
end.

