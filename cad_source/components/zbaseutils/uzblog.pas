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

unit uzbLog;
{$mode objfpc}{$H+}
{$modeswitch TypeHelpers}{$modeswitch advancedrecords}
interface

uses
  gvector,strutils,sysutils{$IFNDEF DELPHI},LazUTF8{$ENDIF},
  uzbLogTypes,
  uzbhandles,
  Generics.Collections,uzbnamedhandles,uzbnamedhandleswithdata,uzbsets;

const
  lp_IncPos=1;
  lp_DecPos=-lp_IncPos;
  lp_OldPos=0;

  tsc2ms=2000;

  MsgDefaultOptions=0;

type

  TMsgOptions=specialize GTSet<TMsgOpt,TMsgOpt>;

  TEntered=record
    Entered:boolean;
    EnteredTo:AnsiString;
  end;
  TDoEnteredHelper = type helper for TEntered
    function IfEntered:TEntered;
  end;

  TLogLevelData=record
    LogLevelType:TLogLevelType;
  end;

  TLogLevelsHandles=specialize GTNamedHandlesWithData<TLogLevel,specialize GTLinearIncHandleManipulator<TLogLevel>,TLogLevelHandleNameType,specialize GTStringNamesUPPERCASE<TLogLevelHandleNameType>,TLogLevelData>;

  TSplashTextOutProc=procedure (s:string;pm:boolean);
  THistoryTextOutMethod=procedure (s:string) of object;
  THistoryTextOutProc=procedure (s:string);
  TLogLevelAliasDic=specialize TDictionary<AnsiChar,TLogLevel>;

  PTMyTimeStamp=^TMyTimeStamp;
  TMyTimeStamp=record
    time:TDateTime;
    rdtsc:int64;
  end;
  TTimeBuf=specialize TVector<TMyTimeStamp>;

  TBackendHandle=Integer;

  tlog=object
    private
      type
        TLogStampt=LongInt;
        TLogStampter=specialize GTSimpleHandles<TLogStampt,specialize GTHandleManipulator<TLogStampt>>;
        TModuleDeskData=record
          enabled:boolean;
        end;
        TModulesDeskHandles=specialize GTNamedHandlesWithData<TModuleDesk,specialize GTLinearIncHandleManipulator<TModuleDesk>,TModuleDeskNameType,specialize GTStringNamesUPPERCASE<TModuleDeskNameType>,TModuleDeskData>;

        TDecoratorData=record
          PDecorator:PTLogerBaseDecorator;
          CurrRes:TLogMsg;
          Stampt:TLogStampt;
          constructor CreateRec(PDD:PTLogerBaseDecorator;s:TLogStampt);
        end;

        TDecorators=specialize TVector<TDecoratorData>;

        TLogerBackendData=record
          PBackend:PTLogerBaseBackend;
          msgFmt:string;
          constructor CreateRec(PBE:PTLogerBaseBackend;Fmt:string;const args:array of integer);
        end;
        TBackends=specialize TVector<TLogerBackendData>;

      var
        Indent:integer;
        LogLevels:TLogLevelsHandles;
        LogLevelAliasDic:TLogLevelAliasDic;
        CurrentLogLevel:TLogLevel;
        DefaultLogLevel:TLogLevel;

        ModulesDesks:TModulesDeskHandles;
        NewModuleDesk:TModuleDeskData;
        DefaultModuleDeskIndex:TModuleDesk;
        TimeBuf:TTimeBuf;
        Backends:TBackends;
        TotalBackendsCount:Integer;
        LogStampter:TLogStampter;
        Decorators:TDecorators;
      procedure WriteLogHeader;


      procedure LogOutStrFast(str:AnsiString;IncIndent:integer);virtual;
      procedure WriteToLog(s:AnsiString;t,dt:TDateTime;tick,dtick:int64;IncIndent:integer);virtual;

      function IsNeedToLog(LogMode:TLogLevel;LMDI:TModuleDesk):boolean;

      procedure ProcessStr(str:AnsiString;IncIndent:integer);virtual;
      procedure ProcessStrToLog(str:AnsiString;IncIndent:integer);virtual;

      function LogMode2string(LogMode:TLogLevel):TLogLevelHandleNameType;

      procedure processMsg(msg:TLogMsg);

    public
      HistoryTextOut:THistoryTextOutMethod;
      SplashTextOut:TSplashTextOutProc;
      MessageBoxTextOut,WarningBoxTextOut,ErrorBoxTextOut:THistoryTextOutProc;


      LM_Trace:TLogLevel;     // — вывод всего подряд. На тот случай, если Debug не позволяет локализовать ошибку.


      constructor init(TraceModeName:TLogLevelHandleNameType='LM_Trace';TraceModeAlias:AnsiChar='T');
      destructor done;virtual;

      function addBackend(var BackEnd:TLogerBaseBackend;fmt:string;const args:array of PTLogerBaseDecorator):TBackendHandle;
      procedure removeBackend(BackEndH:TBackendHandle);

      procedure addDecorator(var Decorator:TLogerBaseDecorator);

      procedure LogStart;
      procedure LogEnd;

      function Enter(EnterTo:AnsiString;LogMode:TLogLevel=1;LMDI:TModuleDesk=1):TEntered;
      procedure Leave(AEntered:TEntered);

      procedure LogOutFormatStr(Const Fmt:AnsiString;const Args :Array of const;IncIndent:integer;LogMode:TLogLevel;LMDI:TModuleDesk=1;MsgOptions:TMsgOpt=MsgDefaultOptions);virtual;
      procedure LogOutStr(str:AnsiString;IncIndent:integer;LogMode:TLogLevel=1;LMDI:TModuleDesk=1;MsgOptions:TMsgOpt=MsgDefaultOptions);virtual;
      function RegisterLogLevel(LogLevelName:TLogLevelHandleNameType;LLAlias:AnsiChar;_LLD:TLogLevelType):TLogLevel;

      function RegisterModule(ModuleName:TModuleDeskNameType):TModuleDesk;
      procedure SetCurrentLogLevel(LogLevel:TLogLevel;silent:boolean=false);
      procedure SetDefaultLogLevel(LogLevel:TLogLevel;silent:boolean=false);

      procedure ZOnDebugLN(Sender: TObject; S: string; var Handled: Boolean);
      procedure ZDebugLN(const S: string);
      function isTraceEnabled:boolean;

      procedure EnableModule(ModuleName:TModuleDeskNameType);
      procedure DisableModule(ModuleName:TModuleDeskNameType);
      procedure EnableAllModules;

      function TryGetLogLevelHandle(LogLevelName:TLogLevelHandleNameType;out LogLevel:TLogLevel):Boolean;
  end;

var
  MsgOpt:TMsgOptions;

implementation

constructor tlog.TLogerBackendData.CreateRec(PBE:PTLogerBaseBackend;Fmt:string;const args:array of integer);
begin
  PBackend:=PBE;
end;

function TDoEnteredHelper.IfEntered:TEntered;
begin
  result.Entered:=Entered;
  Result.EnteredTo:=EnteredTo;
end;
function LLD(_LLD:TLogLevelType):TLogLevelData;
begin
  result.LogLevelType:=_LLD;
end;
function tlog.TryGetLogLevelHandle(LogLevelName:TLogLevelHandleNameType;out LogLevel:TLogLevel):Boolean;
begin
  result:=LogLevels.TryGetHandle(LogLevelName,LogLevel);
end;

function tlog.LogMode2string(LogMode:TLogLevel):AnsiString;
begin
  result:=LogLevels.GetHandleName(LogMode);
  if result='' then result:='LM_Unknown';
end;
function MyTimeToStr(MyTime:TDateTime):string;
var
    Hour,Minute,Second,MilliSecond:word;
begin
  result:='';
  decodetime(MyTime,Hour,Minute,Second,MilliSecond);
  if hour<>0 then
    result:=Format('%.2d:',[hour]);
  if Minute<>0 then
    result:=result+Format('%.2d:', [minute]);
  if Second<>0 then
    result:=result+Format('%.2d.', [Second]);
  result:=result+Format('%.3d', [MilliSecond]);
end;

procedure tlog.WriteToLog(s:AnsiString;t,dt:TDateTime;tick,dtick:int64;IncIndent:integer);
var ts:AnsiString;
begin
  ts:=TimeToStr(Time)+{'|'+}DupeString(' ',Indent*2);
  ts :='!!!! '+ts +s;

  ts:=ts+DupeString('-',80-length(ts));
  //decodetime(t,Hour,Minute,Second,MilliSecond);
  ts := ts +' t:=' + {inttostr(round(t*10e7))}MyTimeToStr(t) + ', dt:=' + {inttostr(round(dt*10e7))}MyTimeToStr(dt) {+#13+#10};
  ts := ts +' tick:=' + inttostr(tick div tsc2ms) + ', dtick:=' + inttostr(dtick div tsc2ms)+#13+#10;
  if (Indent=1)and(IncIndent<0) then ts:=ts+#13+#10;

  processMsg(ts);
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
//var a:int64;
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

procedure tlog.processstrtolog(str:AnsiString;IncIndent:integer);
var
   CurrentTime:TMyTimeStamp;
   DeltaTime,FromStartTime:TDateTime;
   tick,dtick:int64;

begin
     CurrentTime:=mynow();

     if timebuf.size>0 then
                            begin
                                 FromStartTime:=CurrentTime.time-PTMyTimeStamp(TimeBuf.Mutable[0])^.time;
                                 DeltaTime:=CurrentTime.time-PTMyTimeStamp(TimeBuf.Mutable[timebuf.Size-1])^.time;
                                 tick:=CurrentTime.rdtsc-PTMyTimeStamp(TimeBuf.Mutable[0])^.rdtsc;
                                 dtick:=CurrentTime.rdtsc-PTMyTimeStamp(TimeBuf.Mutable[timebuf.Size-1])^.rdtsc;
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
                           WriteToLog(str,FromStartTime,DeltaTime,tick,dtick,IncIndent);
                      end
else if IncIndent>0 then
                      begin
                           WriteToLog(str,FromStartTime,DeltaTime,tick,dtick,IncIndent);
                           inc(Indent,IncIndent);

                           timebuf.PushBack(CurrentTime);
                      end
                  else
                      begin
                           inc(Indent,IncIndent);
                           WriteToLog(str,FromStartTime,DeltaTime,tick,dtick,IncIndent);

                           timebuf.PopBack;
                           //dec(timebuf.Count);
                      end;
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
procedure tlog.LogOutFormatStr(Const Fmt:AnsiString;const Args :Array of const;IncIndent:integer;LogMode:TLogLevel;LMDI:TModuleDesk;MsgOptions:TMsgOpt=MsgDefaultOptions);
begin
     if IsNeedToLog(LogMode,lmdi) then
                                 ProcessStr(format(fmt,args),IncIndent);
end;
procedure tlog.ProcessStr(str:AnsiString;IncIndent:integer);
begin
     if (Indent=0) then
                    if assigned(SplashTextOut) then
                                                  SplashTextOut(str,false);
     ProcessStrToLog(str,IncIndent);
end;
function tlog.Enter(EnterTo:AnsiString;LogMode:TLogLevel=1;LMDI:TModuleDesk=1):TEntered;
begin
  if IsNeedToLog(LogMode,lmdi) then begin
    result.Entered:=true;
    result.EnteredTo:=EnterTo;
    ProcessStr(EnterTo,lp_IncPos);
  end else begin
    result.Entered:=false;
    result.EnteredTo:='';
  end;
end;

procedure tlog.Leave(AEntered:TEntered);
begin
  if AEntered.Entered then
    ProcessStr(format('end; {%s}',[AEntered.EnteredTo]),lp_DecPos);
end;

procedure tlog.logoutstr(str:AnsiString;IncIndent:integer;LogMode:TLogLevel;LMDI:TModuleDesk;MsgOptions:TMsgOpt=MsgDefaultOptions);
begin
     if IsNeedToLog(LogMode,lmdi) then
                                 ProcessStr(str,IncIndent);
end;
procedure tlog.LogOutStrFast(str:AnsiString;IncIndent:integer);
begin
  ProcessStrToLog(str,IncIndent);
end;
procedure tlog.SetCurrentLogLevel(LogLevel:TLogLevel;silent:boolean=false);
var
   CurrentTime:TMyTimeStamp;
begin
     if CurrentLogLevel<>LogLevel then
                                    begin
                                         CurrentTime:=mynow();
                                         CurrentLogLevel:=LogLevel;
                                         if not silent then
                                           WriteToLog('Current log level changed to: '+LogMode2string(LogLevel),CurrentTime.time,0,CurrentTime.rdtsc,0,0);
                                    end;
end;
procedure tlog.SetDefaultLogLevel(LogLevel:TLogLevel;silent:boolean=false);
var
   CurrentTime:TMyTimeStamp;
begin
     if DefaultLogLevel<>LogLevel then
                                    begin
                                         CurrentTime:=mynow();
                                         DefaultLogLevel:=LogLevel;
                                         if not silent then
                                           WriteToLog('Default log level changed to: '+LogMode2string(LogLevel),CurrentTime.time,0,CurrentTime.rdtsc,0,0);
                                    end;
end;
function tlog.RegisterLogLevel(LogLevelName:TLogLevelHandleNameType;LLAlias:AnsiChar;_LLD:TLogLevelType):TLogLevel;
var
  data:TLogLevelData;
begin
  data:=LLD(_LLD);
  result:=LogLevels.CreateOrGetHandleAndSetData(LogLevelName,data);
  if LLAlias<>#0 then
    LogLevelAliasDic.Add(LLAlias,result);
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
procedure tlog.EnableAllModules;
var
   i:integer;
begin
  for i:=0 to ModulesDesks.HandleDataVector.Size-1 do
    ModulesDesks.HandleDataVector.mutable[i]^.D.enabled:=true;
  NewModuleDesk.enabled:=true;
end;

constructor tlog.TDecoratorData.CreateRec(PDD:PTLogerBaseDecorator;s:TLogStampt);
begin
  PDecorator:=PDD;
  CurrRes:='';
  Stampt:=s;
end;


procedure tlog.addDecorator(var Decorator:TLogerBaseDecorator);
var
  DD:TDecoratorData;
  i:Integer;
begin
  for i:=0 to Decorators.Size-1 do
    if Decorators.Mutable[i]^.PDecorator=@Decorator then
      exit;
  DD.CreateRec(@Decorator,LogStampter.GetInitialHandleValue);
  Decorators.PushBack(DD);
end;


function tlog.addBackend(var BackEnd:TLogerBaseBackend;fmt:string;const args:array of PTLogerBaseDecorator):TBackendHandle;
var
  BD:TLogerBackendData;
  i,j,k:Integer;
  arrVT:array of TVarRec;
  arr:array of integer;
begin
  //хрень. нужно хранить отдельно форматы сообщений а не в бакэндах
  if length(args)=0 then
    BD.CreateRec(@BackEnd,fmt,[])
  else begin
    setlength(arrVT,length(args));
    setlength(arr,length(args));
    for i:=low(args) to high(args) do begin
      k:=0;
      for j:=0 to Decorators.Size-1 do
        if Decorators.Mutable[i]^.PDecorator=args[i] then begin
          k:=j+1;
          break;
        end;
      arr[i]:=k;
      arrVT[i].VType:=vtInteger;
      arrVT[i].VInteger:=k;
      fmt:=format(fmt,arrVT);
      fmt:=StringsReplace(fmt,['&'],['%'],[rfReplaceAll]);
    end;
    BD.CreateRec(@BackEnd,fmt,arr);
  end;

  if TotalBackendsCount=Backends.Size then begin
    result:=Backends.Size;
    Backends.PushBack(BD);
  end else begin
    for i:=0 to Backends.Size-1 do
      if Backends.Mutable[i]^.PBackend=nil then begin
        Backends.Mutable[i]^:=BD;
        result:=i;
      end;
  end;
  inc(TotalBackendsCount);
end;

procedure tlog.removeBackend(BackEndH:TBackendHandle);
begin
  if Backends.Mutable[BackEndH]^.PBackend<>nil then begin
    Backends.Mutable[BackEndH]^.PBackend:=nil;
    dec(TotalBackendsCount);
  end;
end;

procedure tlog.processMsg(msg:TLogMsg);
var
  i:Integer;
begin
  for i:=0 to Backends.Size-1 do
    if Backends.Mutable[i]^.PBackend<>nil then
      Backends.Mutable[i]^.PBackend^.doLog(msg);
end;

constructor tlog.init(TraceModeName:TLogLevelHandleNameType;TraceModeAlias:AnsiChar);
var
   CurrentTime:TMyTimeStamp;
   //lz:TLazLogger;
begin
  LogLevels.init;
  ModulesDesks.init;
  LogLevelAliasDic:=TLogLevelAliasDic.create;
  LogStampter.init;
  LogStampter.CreateHandle;
  LM_Trace:=RegisterLogLevel(TraceModeName,TraceModeAlias,LLTInfo);// — вывод всего подряд. На тот случай, если Debug не позволяет локализовать ошибку.
  CurrentTime:=mynow();
  TimeBuf:=TTimeBuf.Create;
  Indent:=1;
  timebuf.PushBack(CurrentTime);

  NewModuleDesk.enabled:=true;
  DefaultModuleDeskIndex:=RegisterModule('DEFAULT');
  NewModuleDesk.enabled:=false;
  SetDefaultLogLevel(LM_Trace,true);
  SetCurrentLogLevel(LM_Trace,true);

  Backends:=TBackends.Create;
  TotalBackendsCount:=0;

  Decorators:=TDecorators.Create;
end;

procedure tlog.LogStart;
begin
  WriteLogHeader;
end;

procedure tlog.LogEnd;
begin

end;

procedure tlog.WriteLogHeader;
var
  CurrentTime:TMyTimeStamp;
begin
  CurrentTime:=mynow();
  WriteToLog('------------------------Log started------------------------',CurrentTime.time,0,CurrentTime.rdtsc,0,0);
  //WriteToLog('Log mode: '+LogMode2string(CurrentLogLevel),true,CurrentTime.time,0,CurrentTime.rdtsc,0,0);
end;

function tlog.isTraceEnabled:boolean;
begin
  result:=LM_Trace>=CurrentLogLevel
end;
procedure tlog.ZDebugLN(const S: string);
var
  dbgmode,tdbgmode:TLogLevel;
  _indent:integer;
  prefixlength,prefixstart:integer;
  NeedToHistory,NeedMessageBox:boolean;
  modulename:string;
  lmdi:TModuleDesk;
  ss:string;
begin
   ss:=s;
   dbgmode:=LM_Trace;
   _indent:=lp_OldPos;
   NeedToHistory:=false;
   NeedMessageBox:=false;
   if length(ss)>1 then
     if ss[1]='{' then begin
       prefixlength:=2;
       while (ss[prefixlength]<>'}')and(prefixlength<=length(ss)) do begin
         case ss[prefixlength] of
           {'T':dbgmode:=LM_Trace;
           'D':dbgmode:=LM_Debug;
           'I':dbgmode:=LM_Info;
           'W':dbgmode:=LM_Warning;
           'E':dbgmode:=LM_Error;
           'F':dbgmode:=LM_Fatal;
           'N':dbgmode:=LM_Necessarily;}
           '+':_indent:=lp_IncPos;
           '-':_indent:=lp_DecPos;
           'H':NeedToHistory:=true;
           'M':NeedMessageBox:=true;
            else begin
              if LogLevelAliasDic.TryGetValue(ss[prefixlength],tdbgmode) then
                dbgmode:=tdbgmode;
            end;
         end;
         inc(prefixlength);
       end;
       ss:=copy(ss,prefixlength+1,length(ss)-prefixlength);
     end;
   if length(ss)>1 then
     if ss[1]='[' then begin
        prefixstart:=2;
        prefixlength:=2;
        while (ss[prefixlength]<>']')and(prefixlength<=length(ss)) do
        begin
          inc(prefixlength);
        end;
        modulename:=uppercase(copy(ss,prefixstart,prefixlength-2));
        ss:=copy(ss,prefixlength+1,length(ss)-prefixlength);
     end;

   if modulename='' then
     lmdi:=DefaultModuleDeskIndex
   else
     lmdi:=RegisterModule(modulename);

   if NeedToHistory then
       if assigned(HistoryTextOut) then
         HistoryTextOut(ss);
     if NeedMessageBox then
       begin case LogLevels.GetPLincedData(dbgmode)^.LogLevelType of
         LLTWarning:if assigned(WarningBoxTextOut) then
                      WarningBoxTextOut(ss);
           LLTError:if assigned(ErrorBoxTextOut) then
                      ErrorBoxTextOut(ss);
               else if assigned(MessageBoxTextOut) then
                      MessageBoxTextOut(ss);
       end;
       end;
     if IsNeedToLog(dbgmode,lmdi) then
      LogOutStr(ss,_indent,dbgmode,lmdi);
end;

procedure tlog.ZOnDebugLN(Sender: TObject; S: string; var Handled: Boolean);
begin
     ZDebugLN(S);
end;

destructor tlog.done;
var
   CurrentTime:TMyTimeStamp;
   i:integer;
begin
  CurrentTime:=mynow();
  for i:=0 to ModulesDesks.HandleDataVector.Size-1 do
  if ModulesDesks.HandleDataVector[i].D.enabled then
    WriteToLog(format('Log module name "%s" state: Enabled',[ModulesDesks.HandleDataVector[I].N]),CurrentTime.time,0,CurrentTime.rdtsc,0,0)
  else
    WriteToLog(format('Log module name "%s" state: Disabled',[ModulesDesks.HandleDataVector[I].N]),CurrentTime.time,0,CurrentTime.rdtsc,0,0);
  CurrentTime:=mynow();
  WriteToLog('-------------------------Log ended-------------------------',CurrentTime.time,0,CurrentTime.rdtsc,0,0);
  TimeBuf.Front;
  LogLevels.done;
  ModulesDesks.done;
  LogStampter.done;
  if assigned(Backends)then
    FreeAndNil(Backends);
  if assigned(Decorators)then
    FreeAndNil(Decorators);
  if assigned(LogLevelAliasDic)then
    FreeAndNil(LogLevelAliasDic);
end;

initialization
  MsgOpt.init;
finalization
  MsgOpt.done;
end.

