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

unit uzclog;
{$INCLUDE def.inc}
{$mode objfpc}{$H+}
interface
uses UGDBOpenArrayOfByte,gzctnrvectordata,LazLoggerBase,
     LazLogger,strutils,sysutils{$IFNDEF DELPHI},LazUTF8{$ENDIF},
     uzbnamedhandles,uzbnamedhandleswithdata;
const {$IFDEF DELPHI}filelog='log/zcad_delphi.log';{$ENDIF}
      {$IFDEF FPC}
                  {$IFDEF LINUX}filelog='../../log/zcad_linux.log';{$ENDIF}
                  {$IFDEF WINDOWS}filelog='../../log/zcad_windows.log';{$ENDIF}
      {$ENDIF}
      lp_IncPos=1;
      lp_DecPos=-lp_IncPos;
      lp_OldPos=0;

      tsc2ms=2000;
const
      MaxLatestLogStrings=99;
type
TModuleDeskData=record
  enabled:boolean;
end;
TModuleDesk=LongInt;
TModuleDeskNameType=AnsiString;
TModulesDeskHandles=specialize GTNamedHandlesWithData<TModuleDesk,specialize GTLinearIncHandleManipulator<TModuleDesk>,TModuleDeskNameType,specialize GTStringNamesUPPERCASE<TModuleDeskNameType>,TModuleDeskData>;


TLogLevelFakeData=record end;
TLogLevel=LongInt;
TLogLevelHandleNameType=AnsiString;
TLogLevelsHandles=specialize GTNamedHandlesWithData<TLogLevel,specialize GTLinearIncHandleManipulator<TLogLevel>,TLogLevelHandleNameType,specialize GTStringNamesUPPERCASE<TLogLevelHandleNameType>,TLogLevelFakeData>;
var
          LM_Trace,     // — вывод всего подряд. На тот случай, если Debug не позволяет локализовать ошибку.
          LM_Debug,     // — журналирование моментов вызова «крупных» операций.
          LM_Info,      // — разовые операции, которые повторяются крайне редко, но не регулярно. (загрузка конфига, плагина, запуск бэкапа)
          LM_Warning,   // — неожиданные параметры вызова, странный формат запроса, использование дефолтных значений в замен не корректных. Вообще все, что может свидетельствовать о не штатном использовании.
          LM_Error,     // — повод для внимания разработчиков. Тут интересно окружение конкретного места ошибки.
          LM_Fatal,     // — тут и так понятно. Выводим все до чего дотянуться можем, так как дальше приложение работать не будет.
          LM_Necessarily:TLogLevel;// — Вывод в любом случае
type
TSplashTextOutProc=procedure (s:string;pm:boolean);
THistoryTextOutMethod=procedure (s:string) of object;
THistoryTextOutProc=procedure (s:string);
PTMyTimeStamp=^TMyTimeStamp;
TMyTimeStamp=record
                   time:TDateTime;
                   rdtsc:int64;
end;
TLatestLogStrings=array of AnsiString;

//PTDateTime=^TDateTime;
{EXPORT+}
ptlog=^tlog;
{REGISTEROBJECTTYPE tlog}
tlog= object
           LogFileName:AnsiString;
           FileHandle:cardinal;
           Indent:integer;
           LatestLogStrings:TLatestLogStrings;
           LatestLogStringsCount,TotalLogStringsCount:integer;

           LogLevels:TLogLevelsHandles;
           CurrentLogLevel:TLogLevel;


           ModulesDesks:TModulesDeskHandles;

           NewModuleDesk:TModuleDeskData;
           DefaultModuleDeskIndex:TModuleDesk;

           constructor init(fn:AnsiString;TraceModeName:TLogLevelHandleNameType);
           procedure WriteLogHeader;
           function registermodule(modulename:TModuleDeskNameType):TModuleDesk;

           procedure enablemodule(modulename:TModuleDeskNameType);
           procedure disablemodule(modulename:TModuleDeskNameType);
           procedure enableallmodules;
           procedure SetLogLevel(LogLevel:TLogLevel);
           destructor done;virtual;
           procedure AddStrToLatest(str:AnsiString);
           procedure WriteLatestToFile(var f:system.text);
           procedure LogOutStrFast(str:AnsiString;IncIndent:integer);virtual;
           procedure WriteToLog(s:AnsiString;todisk:boolean;t,dt:TDateTime;tick,dtick:int64;IncIndent:integer);virtual;
           procedure OpenLog;
           procedure CloseLog;
           procedure CreateLog;

           function IsNeedToLog(LogMode:TLogLevel;LMDI:TModuleDesk):boolean;

           procedure LogOutStr(str:AnsiString;IncIndent:integer;LogMode:TLogLevel;LMDI:TModuleDesk=1);virtual;
           procedure LogOutFormatStr(Const Fmt:AnsiString;const Args :Array of const;IncIndent:integer;LogMode:TLogLevel;LMDI:TModuleDesk=1);virtual;
           procedure ZOnDebugLN(Sender: TObject; S: string; var Handled: Boolean);
           private
           procedure ProcessStr(str:AnsiString;IncIndent:integer);virtual;
           procedure ProcessStrToLog(str:AnsiString;IncIndent:integer;todisk:boolean);virtual;

           function LogMode2string(LogMode:TLogLevel):TLogLevelHandleNameType;
    end;
{EXPORT-}
procedure LogOut(s:AnsiString);
var programlog:tlog;
   VerboseLog:boolean;
   SplashTextOut:TSplashTextOutProc;
   HistoryTextOut:THistoryTextOutMethod;
   MessageBoxTextOut,WarningBoxTextOut,ErrorBoxTextOut:THistoryTextOutProc;
implementation
var
    PerfomaneBuf:GDBOpenArrayOfByte;
    TimeBuf:specialize GZVectorData<TMyTimeStamp>;
function tlog.LogMode2string(LogMode:TLogLevel):AnsiString;
begin
  result:=LogLevels.GetHandleName(LogMode);
  if result='' then result:='LM_Unknown';
end;
procedure LogOut(s:AnsiString);
var
   FileHandle:cardinal;
   logname:string;
begin
     if assigned(SplashTextOut) then
                                   SplashTextOut(s,true);
     logname:={$IFNDEF DELPHI}SysToUTF8{$ENDIF}(ExtractFilePath(paramstr(0)))+filelog+'hard';
     FileHandle:=0;
     if not fileexists({$IFNDEF DELPHI}UTF8ToSys{$ENDIF}(logname)) then
                                   FileHandle:=FileCreate({$IFNDEF DELPHI}UTF8ToSys{$ENDIF}(logname))
                                else
                                    FileHandle := FileOpen({$IFNDEF DELPHI}UTF8ToSys{$ENDIF}(logname), fmOpenWrite);
     FileSeek(FileHandle, 0, 2);

        s:=s+#13#10;
        FileWrite(FileHandle,s[1],length(s));

     fileclose(FileHandle);
     FileHandle:=0;
end;
function MyTimeToStr(MyTime:TDateTime):string;
var
    Hour,Minute,Second,MilliSecond:word;
begin
     decodetime(MyTime,Hour,Minute,Second,MilliSecond);
     if hour<>0 then
                    result:=Format('%.2d:', [hour]);
                            // inttostr(hour)+':';
     if Minute<>0 then
                    result:=result+Format('%.2d:', [minute]);
                                   //inttostr(minute,2)+':';
     if Second<>0 then
                    result:=result+Format('%.2d.', [Second]);
                                  //inttostr(Second,2)+'.';
     //if MilliSecond<>0 then
                    result:=result+Format('%.3d', [MilliSecond]);
                                   //inttostr(MilliSecond,3);

end;

procedure tlog.WriteToLog(s:AnsiString;todisk:boolean;t,dt:TDateTime;tick,dtick:int64;IncIndent:integer);
var ts:AnsiString;
begin
  ts:=TimeToStr(Time)+{'|'+}DupeString(' ',Indent*2);
  if todisk then ts :='!!!! '+ts +s
            else ts :=IntToHex(PerfomaneBuf.Count,4)+' '+ts +s;
  ts:=ts+DupeString('-',80-length(ts));
  //decodetime(t,Hour,Minute,Second,MilliSecond);
  ts := ts +' t:=' + {inttostr(round(t*10e7))}MyTimeToStr(t) + ', dt:=' + {inttostr(round(dt*10e7))}MyTimeToStr(dt) {+#13+#10};
  ts := ts +' tick:=' + inttostr(tick div tsc2ms) + ', dtick:=' + inttostr(dtick div tsc2ms)+#13+#10;
  if (Indent=1)and(IncIndent<0) then ts:=ts+#13+#10;
  PerfomaneBuf.TXTAddGDBString(ts);
  //FileWrite(FileHandle,ts[1],length(ts));
  if todisk then
  begin
        OpenLog;
        FileWrite(FileHandle,PerfomaneBuf.parray^,PerfomaneBuf.count);
        PerfomaneBuf.Clear;
        CloseLog;
  end;
end;
procedure tlog.OpenLog;
begin
  FileHandle := FileOpen({$IFNDEF DELPHI}UTF8ToSys{$ENDIF}(logfilename), fmOpenWrite);
  FileSeek(FileHandle, 0, 2);
end;

procedure tlog.CloseLog;
begin
  fileclose(FileHandle);
  FileHandle:=0;
end;
procedure tlog.CreateLog;
begin
  FileHandle:=FileCreate({$IFNDEF DELPHI}UTF8ToSys{$ENDIF}(logfilename){,fmOpenWrite});
  CloseLog;
end;
{procedure tlog.logout;
begin
     logoutstr(str,IncIndent);
end;}
(*function RDTSC: comp;
var
  TimeStamp: record
    case byte of
      1: (Whole: comp);
      2: (Lo, Hi: Longint);
  end;
begin
  asm
    db $0F; db $31;
  {$ifdef Cpu386}
    mov [TimeStamp.Lo], eax
    mov [TimeStamp.Hi], edx
  {$else}
    db D32
    mov word ptr TimeStamp.Lo, AX   dfg
    db D32
    mov word ptr TimeStamp.Hi, DX
  {$endif}
  end;
  Result := TimeStamp.Whole;
end;*)
function mynow:TMyTimeStamp;
var a:int64;
begin
     result.time:=now();
     {asm
        rdtsc
        mov dword ptr [a],eax
        mov dword ptr [a+4],edx
     end;
     result.rdtsc:=a;}
     result.rdtsc:=GetTickCount64;
end;

procedure tlog.processstrtolog(str:AnsiString;IncIndent:integer;todisk:boolean);
var
   CurrentTime:TMyTimeStamp;
   DeltaTime,FromStartTime:TDateTime;
   tick,dtick:int64;

begin
     CurrentTime:=mynow();

     if timebuf.Count>0 then
                            begin
                                 FromStartTime:=CurrentTime.time-PTMyTimeStamp(TimeBuf.getDataMutable(0))^.time;
                                 DeltaTime:=CurrentTime.time-PTMyTimeStamp(TimeBuf.getDataMutable(timebuf.Count-1))^.time;
                                 tick:=CurrentTime.rdtsc-PTMyTimeStamp(TimeBuf.getDataMutable(0))^.rdtsc;
                                 dtick:=CurrentTime.rdtsc-PTMyTimeStamp(TimeBuf.getDataMutable(timebuf.Count-1))^.rdtsc;
                            end
                        else
                            begin
                                  FromStartTime:=0;
                                  DeltaTime:=0;
                                  tick:=0;
                                  dtick:=0;
                            end;
     if IncIndent=0 then
                      begin
                           WriteToLog(str,todisk,FromStartTime,DeltaTime,tick,dtick,IncIndent);
                      end
else if IncIndent>0 then
                      begin
                           WriteToLog(str,todisk,FromStartTime,DeltaTime,tick,dtick,IncIndent);
                           inc(Indent,IncIndent);

                           timebuf.PushBackData(CurrentTime);
                      end
                  else
                      begin
                           inc(Indent,IncIndent);
                           WriteToLog(str,todisk,FromStartTime,DeltaTime,tick,dtick,IncIndent);

                           dec(timebuf.Count);
                      end;
end;
procedure tlog.WriteLatestToFile(var f:system.text);
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
       WriteLn(f,pchar(@programlog.LatestLogStrings[currentindex][1]));
       inc(currentindex);
       dec(LatestLogArraySize);
     until LatestLogArraySize=0;
end;

procedure tlog.AddStrToLatest(str:AnsiString);
begin
     if LatestLogStringsCount>High(LatestLogStrings) then
                                                         LatestLogStringsCount:=Low(LatestLogStrings);
     LatestLogStrings[LatestLogStringsCount]:=str;
     inc(TotalLogStringsCount);
     inc(LatestLogStringsCount);
end;
function tlog.IsNeedToLog(LogMode:TLogLevel;LMDI:TModuleDesk):boolean;
begin
     result:=ModulesDesks.GetPLincedData(LMDI)^.enabled;
     if result then
     if LogMode<CurrentLogLevel then
                                   result:=false
                               else
                                   result:=true;
end;
procedure tlog.LogOutFormatStr(Const Fmt:AnsiString;const Args :Array of const;IncIndent:integer;LogMode:TLogLevel;LMDI:TModuleDesk);
begin
     if IsNeedToLog(LogMode,lmdi) then
                                 ProcessStr(format(fmt,args),IncIndent);
end;
procedure tlog.ProcessStr(str:AnsiString;IncIndent:integer);
begin
     if (Indent=0) then
                    if assigned(SplashTextOut) then
                                                  SplashTextOut(str,false);
     ProcessStrToLog(str,IncIndent,true);
     AddStrToLatest('  '+str);
end;
procedure tlog.logoutstr(str:AnsiString;IncIndent:integer;LogMode:TLogLevel;LMDI:TModuleDesk);
begin
     if IsNeedToLog(LogMode,lmdi) then
                                 ProcessStr(str,IncIndent);
end;
procedure tlog.LogOutStrFast(str:AnsiString;IncIndent:integer);
begin
     //if (str='TOGLWnd.Pre_MouseMove----{end}')and(Indent=3) then
     //               indent:=3;
     if PerfomaneBuf.Count<1024 then
                                    ProcessStrToLog(str,IncIndent,false)
                                else
                                    ProcessStrToLog(str,IncIndent,true);
end;
procedure tlog.SetLogLevel(LogLevel:TLogLevel);
var
   CurrentTime:TMyTimeStamp;
begin
     if CurrentLogLevel<>LogLevel then
                                    begin
                                         CurrentTime:=mynow();
                                         CurrentLogLevel:=LogLevel;
                                         WriteToLog('Log mode changed to: '+LogMode2string(LogLevel),true,CurrentTime.time,0,CurrentTime.rdtsc,0,0);
                                         if LogLevel=LM_Trace then
                                                                 VerboseLog:=true;
                                    end;
end;
function tlog.registermodule(modulename:AnsiString):TModuleDesk;
begin
  if not ModulesDesks.TryGetHandle(modulename,result) then
  begin
    result:=ModulesDesks.CreateOrGetHandle(modulename);
    ModulesDesks.GetPLincedData(result)^.enabled:=NewModuleDesk.enabled;
    //LogOutStr(format('Register log module "%s"',[modulename]),0,LM_Info);
  end;
end;
procedure tlog.enablemodule(modulename:AnsiString);
begin
  ModulesDesks.GetPLincedData(ModulesDesks.CreateOrGetHandle(modulename))^.enabled:=true;
end;
procedure tlog.disablemodule(modulename:AnsiString);
begin
  ModulesDesks.GetPLincedData(ModulesDesks.CreateOrGetHandle(modulename))^.enabled:=false;
end;
procedure tlog.enableallmodules;
var
   i:integer;
begin
  for i:=0 to ModulesDesks.HandleDataVector.Size-1 do
    ModulesDesks.HandleDataVector.mutable[i]^.D.enabled:=true;
  NewModuleDesk.enabled:=true;
end;
constructor tlog.init(fn:AnsiString;TraceModeName:TLogLevelHandleNameType);
var
   CurrentTime:TMyTimeStamp;
   lz:TLazLogger;
begin
  LogLevels.init;
  ModulesDesks.init;
  LM_Trace:=programlog.LogLevels.CreateHandle;     // — вывод всего подряд. На тот случай, если Debug не позволяет локализовать ошибку.
  programlog.LogLevels.RegisterHandleName(LM_Trace,TraceModeName);
     CurrentLogLevel:=LM_Trace;
     CurrentTime:=mynow();
     logfilename:=fn;
     PerfomaneBuf.init({$IFDEF DEBUGBUILD}'{39063C66-9D18-4707-8AD3-97DFBCB23185}',{$ENDIF}5*1024);
     TimeBuf.init({$IFDEF DEBUGBUILD}'{6EE1BC6B-1177-40B0-B4A5-793D66BF8BC8}',{$ENDIF}50{,sizeof(TMyTimeStamp)});
     Indent:=1;
     CreateLog;
     timebuf.PushBackData(CurrentTime);
     setlength(LatestLogStrings,MaxLatestLogStrings);
     LatestLogStringsCount:=0;
     TotalLogStringsCount:=0;
     lz:=GetDebugLogger;
     if assigned(lz)then
       if lz is TLazLoggerFile then
         begin
              TLazLoggerFile(lz).OnDebugLn:=@ZOnDebugLN;
              TLazLoggerFile(lz).OnDbgOut:=@ZOnDebugLN;
         end;
     NewModuleDesk.enabled:=true;
     DefaultModuleDeskIndex:=registermodule('DEFAULT');
     NewModuleDesk.enabled:=false;
end;
procedure tlog.WriteLogHeader;
var
  CurrentTime:TMyTimeStamp;
begin
  CurrentTime:=mynow();
  WriteToLog('------------------------Log started------------------------',true,CurrentTime.time,0,CurrentTime.rdtsc,0,0);
  WriteToLog('Log mode: '+LogMode2string(CurrentLogLevel),true,CurrentTime.time,0,CurrentTime.rdtsc,0,0);
end;

procedure tlog.ZOnDebugLN(Sender: TObject; S: string; var Handled: Boolean);
var
   dbgmode:TLogLevel;
   _indent:integer;
   prefixlength,prefixstart:integer;
   NeedToHistory,NeedMessageBox:boolean;
   modulename:string;
   lmdi:TModuleDesk;
begin
     dbgmode:=LM_Info;
     _indent:=lp_OldPos;
     NeedToHistory:=false;
     NeedMessageBox:=false;
     if length(s)>1 then
     if s[1]='{' then
     begin
        prefixlength:=2;
        while (s[prefixlength]<>'}')and(prefixlength<=length(s)) do
        begin
             case s[prefixlength] of
                'T':dbgmode:=LM_Trace;
                'D':dbgmode:=LM_Debug;
                'I':dbgmode:=LM_Info;
                'W':dbgmode:=LM_Warning;
                'E':dbgmode:=LM_Error;
                'F':dbgmode:=LM_Fatal;
                'N':dbgmode:=LM_Necessarily;
                '+':_indent:=lp_IncPos;
                '-':_indent:=lp_DecPos;
                'H':NeedToHistory:=true;
                'M':NeedMessageBox:=true;
             end;
          inc(prefixlength);
        end;
        s:=copy(s,prefixlength+1,length(s)-prefixlength);
     end;
     if length(s)>1 then
     if s[1]='[' then
     begin
        prefixstart:=2;
        prefixlength:=2;
        while (s[prefixlength]<>']')and(prefixlength<=length(s)) do
        begin
          inc(prefixlength);
        end;
        modulename:=uppercase(copy(s,prefixstart,prefixlength-2));
        s:=copy(s,prefixlength+1,length(s)-prefixlength);
     end;
     if modulename='' then
                 lmdi:=DefaultModuleDeskIndex
             else
                 begin
                  lmdi:=registermodule(modulename);
                 end;
     if NeedToHistory then
       if assigned(HistoryTextOut) then
         HistoryTextOut(s);
     if NeedMessageBox then
       begin//case dbgmode of
         if dbgmode=LM_Warning then if assigned(WarningBoxTextOut) then
                      WarningBoxTextOut(s)
  else if (dbgmode=LM_Error)or(dbgmode=LM_Fatal) then if assigned(ErrorBoxTextOut) then
                      ErrorBoxTextOut(s)
               else if assigned(MessageBoxTextOut) then
                      MessageBoxTextOut(s);
       end;
     if IsNeedToLog(dbgmode,lmdi) then
      LogOutStr(S,_indent,dbgmode,lmdi);
end;

destructor tlog.done;
var
   CurrentTime:TMyTimeStamp;
   i:integer;
begin
     CurrentTime:=mynow();
     for i:=0 to ModulesDesks.HandleDataVector.Size-1 do
      if ModulesDesks.HandleDataVector[i].D.enabled then
                                         WriteToLog(format('Log module name "%s" state: Enabled',[ModulesDesks.HandleDataVector[I].N]),true,CurrentTime.time,0,CurrentTime.rdtsc,0,0)
                                     else
                                         WriteToLog(format('Log module name "%s" state: Disabled',[ModulesDesks.HandleDataVector[I].N]),true,CurrentTime.time,0,CurrentTime.rdtsc,0,0);
     CurrentTime:=mynow();
     WriteToLog('-------------------------Log ended-------------------------',true,CurrentTime.time,0,CurrentTime.rdtsc,0,0);
     TimeBuf.done;
     PerfomaneBuf.done;
     setlength(LatestLogStrings,0);
     LogLevels.done;
     ModulesDesks.done;
end;
initialization
begin
    programlog.init({$IFNDEF DELPHI}SysToUTF8{$ENDIF}(ExtractFilePath(paramstr(0)))+filelog,'LM_Trace');
    //LM_Trace:=programlog.LogLevels.CreateHandle;     // — вывод всего подряд. На тот случай, если Debug не позволяет локализовать ошибку.
    //programlog.LogLevels.RegisterHandleName(LM_Trace,'LM_Trace');
    LM_Debug:=programlog.LogLevels.CreateOrGetHandle('LM_Debug');     // — журналирование моментов вызова «крупных» операций.
    LM_Info:=programlog.LogLevels.CreateOrGetHandle('LM_Info');      // — разовые операции, которые повторяются крайне редко, но не регулярно. (загрузка конфига, плагина, запуск бэкапа)
    LM_Warning:=programlog.LogLevels.CreateOrGetHandle('LM_Warning');   // — неожиданные параметры вызова, странный формат запроса, использование дефолтных значений в замен не корректных. Вообще все, что может свидетельствовать о не штатном использовании.
    LM_Error:=programlog.LogLevels.CreateOrGetHandle('LM_Error');     // — повод для внимания разработчиков. Тут интересно окружение конкретного места ошибки.
    LM_Fatal:=programlog.LogLevels.CreateOrGetHandle('LM_Fatal');     // — тут и так понятно. Выводим все до чего дотянуться можем, так как дальше приложение работать не будет.
    LM_Necessarily:=programlog.LogLevels.CreateOrGetHandle('LM_Necessarily');// — Вывод в любом случае
    programlog.WriteLogHeader;
end;
finalization
    debugln('{I}[UnitsFinalization] Unit "',{$INCLUDE %FILE%},'" finalization');
    programlog.done;
end.

