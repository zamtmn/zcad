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
  sysutils,
  gvector,
  Generics.Collections,Generics.Defaults,
  uzbLogTypes,
  uzbHandles,uzbNamedHandles,uzbNamedHandlesWithData,uzbSets;

const
  MsgDefaultOptions=0;
  LogModeDefault=1;
  LMDIDefault=1;

type

  TMsgOptions=specialize GTSet<TMsgOpt,TMsgOpt>;

  TEntered=record
    Entered:Boolean;
    EnteredTo:TLogMsg;
    LogLevel:TLogLevel;
    LMDI:TModuleDesk;
    MsgOptions:TMsgOpt;
  end;

  TDoEnteredHelper = type helper for TEntered
    function IfEntered:TEntered;
  end;

  PTTLogLevelData=^TLogLevelData;
  TLogLevelData=record
    LogLevelType:TLogLevelType;
  end;

  TLogLevelsHandles=specialize GTNamedHandlesWithData<TLogLevel,specialize GTLinearIncHandleManipulator<TLogLevel>,TLogLevelHandleNameType,specialize GTStringNamesUPPERCASE<TLogLevelHandleNameType>,TLogLevelData>;

  TLogLevelAliasDic=specialize TDictionary<AnsiChar,TLogLevel>;
  TTMsgOptAliasDic=specialize TDictionary<AnsiChar,TMsgOpt>;

  TBackendHandle=Integer;

  TFmtData=record
    msgFmt:TLogMsg;
    argsI:array of Integer;
    argsP:array of PTLogerBaseDecorator
  end;
  TLogStampt=LongInt;
  TFmtResultData=record
    Fmt:TFmtData;
    Res:TLogMsg;
    Stampt:TLogStampt;
  end;

  IFmtDataComparer=specialize IEqualityComparer<TFmtData>;
  TFmtDataComparer=class(TInterfacedObject,IFmtDataComparer)
      function Equals(constref ALeft, ARight: TFmtData): Boolean;
      function GetHashCode(constref AValue: TFmtData): UInt32;
    end;

  TEnable=(EEnable,EDisable,EDefault);

  TLog=object
    private
      type
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

        TFmtDatas=specialize TVector<TFmtResultData>;
        TFmtDatasDic=specialize TDictionary<TFmtData,Integer>;

        TDecorators=specialize TVector<TDecoratorData>;

        TLogerBackendData=record
          PBackend:PTLogerBaseBackend;
          msgFmtIndex:Integer;
          constructor CreateRec(PBE:PTLogerBaseBackend;Index:Integer);
        end;
        TBackends=specialize TVector<TLogerBackendData>;

      var
        CurrentLogLevel:TLogLevel;
        DefaultLogLevel:TLogLevel;

        LogLevelAliasDic:TLogLevelAliasDic;
        ModulesDesks:TModulesDeskHandles;
        NewModuleDesk:TModuleDeskData;
        DefaultModuleDeskIndex:TModuleDesk;
        Backends:TBackends;
        TotalBackendsCount:Integer;
        LogStampter:TLogStampter;
        Decorators:TDecorators;
        FmtDatas:TFmtDatas;
        FmtDatasDic:TFmtDatasDic;
        LogLevels:TLogLevelsHandles;
        MsgOptAliasDic:TTMsgOptAliasDic;

      function IsNeedToLog(LogMode:TLogLevel;LMDI:TModuleDesk):boolean;
      function LogMode2String(LogMode:TLogLevel):TLogLevelHandleNameType;
      procedure processMsg(msg:TLogMsg;LogMode:TLogLevel;LMDI:TModuleDesk;MsgOptions:TMsgOpt);
      procedure processFmtResultData(var FRD:TFmtResultData;Stampt:TLogStampt;msg:TLogMsg;LogMode:TLogLevel;LMDI:TModuleDesk;MsgOptions:TMsgOpt);
      procedure processDecoratorData(var DD:TDecoratorData;Stampt:TLogStampt;msg:TLogMsg;LogMode:TLogLevel;LMDI:TModuleDesk;MsgOptions:TMsgOpt);

    public
      EnterMsgOpt,ExitMsgOpt:TMsgOpt;
      LM_Trace:TLogLevel;// — вывод всего подряд. На тот случай, если Debug не позволяет локализовать ошибку.


      constructor Init(TraceModeName:TLogLevelHandleNameType='LM_Trace';TraceModeAlias:AnsiChar='T');
      destructor Done;virtual;

      procedure addMsgOptAlias(const ch:AnsiChar;const opt:TMsgOpt);

      function addBackend(var BackEnd:TLogerBaseBackend;fmt:TLogMsg;const args:array of PTLogerBaseDecorator):TBackendHandle;
      procedure removeBackend(BackEndH:TBackendHandle);

      procedure addDecorator(var Decorator:TLogerBaseDecorator);

      procedure LogStart;
      procedure LogEnd;

      function Enter(EnterTo:TLogMsg;LogMode:TLogLevel=1;LMDI:TModuleDesk=1;MsgOptions:TMsgOpt=MsgDefaultOptions):TEntered;
      procedure Leave(AEntered:TEntered);

      procedure LogOutFormatStr(Const Fmt:TLogMsg;const Args :Array of const;LogMode:TLogLevel;LMDI:TModuleDesk=1;MsgOptions:TMsgOpt=MsgDefaultOptions);virtual;
      procedure LogOutStr(str:TLogMsg;LogMode:TLogLevel=1;LMDI:TModuleDesk=1;MsgOptions:TMsgOpt=MsgDefaultOptions);virtual;
      function RegisterLogLevel(LogLevelName:TLogLevelHandleNameType;LLAlias:AnsiChar;_LLD:TLogLevelType):TLogLevel;

      function RegisterModule(ModuleName:TModuleDeskNameType;Enbl:TEnable=EDefault):TModuleDesk;
      procedure SetCurrentLogLevel(LogLevel:TLogLevel;silent:boolean=false);
      procedure SetDefaultLogLevel(LogLevel:TLogLevel;silent:boolean=false);

      procedure ZOnDebugLN(Sender: TObject; S: TLogMsg; var Handled: Boolean);
      procedure ZDebugLN(const S: TLogMsg);
      function isTraceEnabled:boolean;

      procedure EnableModule(ModuleName:TModuleDeskNameType);
      procedure DisableModule(ModuleName:TModuleDeskNameType);
      procedure EnableAllModules;

      function TryGetLogLevelHandle(LogLevelName:TLogLevelHandleNameType;out LogLevel:TLogLevel):Boolean;
      function GetMutableLogLevelData(LL:TLogLevel):PTTLogLevelData;
  end;

var
  MsgOpt:TMsgOptions;

implementation

function TFmtDataComparer.Equals(constref ALeft, ARight: TFmtData): Boolean;
var
  i:integer;
begin
  if ALeft.msgFmt<>ARight.msgFmt then
    exit(False);
  if length(ALeft.argsP)<>length(ARight.argsP) then
    exit(False);
  if length(ALeft.argsI)<>length(ARight.argsI) then
    exit(False);
  for i:=low(ALeft.argsP) to high(ALeft.argsP) do
    if ALeft.argsP[i]<>ARight.argsP[i] then
      exit(False);
  for i:=low(ALeft.argsI) to high(ALeft.argsI) do
    if ALeft.argsI[i]<>ARight.argsI[i] then
      exit(False);
  Result:=True;
end;

function TFmtDataComparer.GetHashCode(constref AValue: TFmtData): UInt32;
begin
  Result := BobJenkinsHash(AValue.msgFmt[1],length(AValue.msgFmt)*SizeOf(AValue.msgFmt[1]),0);
  Result := BobJenkinsHash(AValue.argsP[0],length(AValue.argsP)*SizeOf(AValue.argsP[1]),Result);
  Result := BobJenkinsHash(AValue.argsI[0],length(AValue.argsI)*SizeOf(AValue.argsI[1]),Result);
end;

constructor TLog.TLogerBackendData.CreateRec(PBE:PTLogerBaseBackend;Index:Integer);
begin
  PBackend:=PBE;
  msgFmtIndex:=Index;
end;

function TDoEnteredHelper.IfEntered:TEntered;
begin
  result.Entered:=Entered;
  Result.EnteredTo:=EnteredTo;
  Result.LogLevel:=LogLevel;
  Result.LMDI:=LMDI;
  Result.MsgOptions:=MsgOptions;
end;
function LLD(_LLD:TLogLevelType):TLogLevelData;
begin
  result.LogLevelType:=_LLD;
end;
function TLog.TryGetLogLevelHandle(LogLevelName:TLogLevelHandleNameType;out LogLevel:TLogLevel):Boolean;
begin
  result:=LogLevels.TryGetHandle(LogLevelName,LogLevel);
end;
function TLog.GetMutableLogLevelData(LL:TLogLevel):PTTLogLevelData;
begin
  result:=LogLevels.GetPLincedData(LL);
end;

function TLog.LogMode2String(LogMode:TLogLevel):TLogLevelHandleNameType;
begin
  result:=LogLevels.GetHandleName(LogMode);
  if result='' then result:='LM_Unknown';
end;

{function MyTimeToStr(MyTime:TDateTime):string;
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
end;}

function TLog.IsNeedToLog(LogMode:TLogLevel;LMDI:TModuleDesk):boolean;
begin
  result:=ModulesDesks.GetPLincedData(LMDI)^.enabled;
  if result then
  if LogMode<CurrentLogLevel then
    result:=false
  else
    result:=true;
end;
procedure TLog.LogOutFormatStr(Const Fmt:TLogMsg;const Args :Array of const;LogMode:TLogLevel;LMDI:TModuleDesk;MsgOptions:TMsgOpt=MsgDefaultOptions);
begin
  if IsNeedToLog(LogMode,lmdi) then
    processMsg(format(fmt,args),LogMode,LMDI,MsgOptions);
end;
function TLog.Enter(EnterTo:TLogMsg;LogMode:TLogLevel=1;LMDI:TModuleDesk=1;MsgOptions:TMsgOpt=MsgDefaultOptions):TEntered;
begin
  if IsNeedToLog(LogMode,lmdi) then begin
    result.Entered:=true;
    result.EnteredTo:=EnterTo;
    result.LogLevel:=LogMode;
    result.LMDI:=LMDI;
    result.MsgOptions:=MsgOptions;
    processMsg(EnterTo,LogMode,LMDI,MsgOptions or EnterMsgOpt);
  end else begin
    result.Entered:=false;
    result.EnteredTo:='';
  end;
end;

procedure TLog.Leave(AEntered:TEntered);
begin
  if AEntered.Entered then
    processMsg(format('end; {%s}',[AEntered.EnteredTo]),AEntered.LogLevel,AEntered.LMDI,AEntered.MsgOptions or ExitMsgOpt);
end;

procedure TLog.logoutstr(str:TLogMsg;LogMode:TLogLevel;LMDI:TModuleDesk;MsgOptions:TMsgOpt=MsgDefaultOptions);
begin
  if IsNeedToLog(LogMode,lmdi) then
    processMsg(str,LogMode,LMDI,MsgOptions);
end;
procedure TLog.SetCurrentLogLevel(LogLevel:TLogLevel;silent:boolean=false);
begin
  if CurrentLogLevel<>LogLevel then begin
    CurrentLogLevel:=LogLevel;
    if not silent then
      processMsg('Current log level changed to: '+LogMode2string(LogLevel),LogModeDefault,LMDIDefault,MsgDefaultOptions);
  end;
end;
procedure TLog.SetDefaultLogLevel(LogLevel:TLogLevel;silent:boolean=false);
begin
  if DefaultLogLevel<>LogLevel then begin
    DefaultLogLevel:=LogLevel;
    if not silent then
      processMsg('Default log level changed to: '+LogMode2string(LogLevel),LogModeDefault,LMDIDefault,MsgDefaultOptions);
  end;
end;
function TLog.RegisterLogLevel(LogLevelName:TLogLevelHandleNameType;LLAlias:AnsiChar;_LLD:TLogLevelType):TLogLevel;
var
  data:TLogLevelData;
begin
  data:=LLD(_LLD);
  result:=LogLevels.CreateOrGetHandleAndSetData(LogLevelName,data);
  if LLAlias<>#0 then
    LogLevelAliasDic.Add(LLAlias,result);
end;

function TLog.registermodule(modulename:TModuleDeskNameType;Enbl:TEnable=EDefault):TModuleDesk;
begin
  if not ModulesDesks.TryGetHandle(modulename,result) then
  begin
    result:=ModulesDesks.CreateOrGetHandle(modulename);
    with ModulesDesks.GetPLincedData(result)^ do begin
      case Enbl of
        EEnable:enabled:=True;
        EDisable:enabled:=False;
        EDefault:enabled:=NewModuleDesk.enabled;
      end;
    end;
  end;
end;
procedure TLog.enablemodule(modulename:TModuleDeskNameType);
begin
  ModulesDesks.GetPLincedData(ModulesDesks.CreateOrGetHandle(modulename))^.enabled:=true;
end;
procedure TLog.disablemodule(modulename:TModuleDeskNameType);
begin
  ModulesDesks.GetPLincedData(ModulesDesks.CreateOrGetHandle(modulename))^.enabled:=false;
end;
procedure TLog.EnableAllModules;
var
   i:integer;
begin
  for i:=0 to ModulesDesks.HandleDataVector.Size-1 do
    ModulesDesks.HandleDataVector.mutable[i]^.D.enabled:=true;
  NewModuleDesk.enabled:=true;
end;

constructor TLog.TDecoratorData.CreateRec(PDD:PTLogerBaseDecorator;s:TLogStampt);
begin
  PDecorator:=PDD;
  CurrRes:='';
  Stampt:=s;
end;


procedure TLog.addDecorator(var Decorator:TLogerBaseDecorator);
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


function TLog.addBackend(var BackEnd:TLogerBaseBackend;fmt:TLogMsg;const args:array of PTLogerBaseDecorator):TBackendHandle;
var
  BD:TLogerBackendData;
  i,j,k:Integer;
  FmtData:TFmtData;
  FmtRData:TFmtResultData;
  num:integer;
begin
  if fmt<>'' then begin
    FmtData.msgFmt:=fmt;
    setlength(FmtData.argsI,length(args));
    setlength(FmtData.argsP,length(args));
    for i:=low(args) to high(args) do begin
      k:=-1;
      for j:=0 to Decorators.Size-1 do
        if Decorators.Mutable[j]^.PDecorator=args[i] then begin
          k:=j;
          break;
        end;
      FmtData.argsI[i]:=k;
      FmtData.argsP[i]:=args[i];
    end;

    if not FmtDatasDic.tryGetValue(FmtData,num) then begin
      num:=FmtDatas.Size;
      FmtDatasDic.add(FmtData,num);
      FmtRData.Fmt:=FmtData;
      FmtRData.Res:='';
      FmtRData.Stampt:=LogStampter.GetInitialHandleValue;
      FmtDatas.PushBack(FmtRData);
    end;
  end else begin
    num:=-1;
  end;

  BD.CreateRec(@BackEnd,num);

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

procedure TLog.removeBackend(BackEndH:TBackendHandle);
begin
  if Backends.Mutable[BackEndH]^.PBackend<>nil then begin
    Backends.Mutable[BackEndH]^.PBackend:=nil;
    dec(TotalBackendsCount);
  end;
end;

procedure TLog.processDecoratorData(var DD:TDecoratorData;Stampt:TLogStampt;msg:TLogMsg;LogMode:TLogLevel;LMDI:TModuleDesk;MsgOptions:TMsgOpt);
begin
  if DD.Stampt=Stampt then
    exit;
  DD.CurrRes:=DD.PDecorator^.GetDecor(msg,MsgOptions,LogMode,LMDI);
  DD.Stampt:=Stampt
end;

procedure TLog.processFmtResultData(var FRD:TFmtResultData;Stampt:TLogStampt;msg:TLogMsg;LogMode:TLogLevel;LMDI:TModuleDesk;MsgOptions:TMsgOpt);
var
  arrVT:array of TVarRec;
  i:integer;
begin
  if FRD.Stampt=Stampt then
    exit;
  SetLength(arrVT,length(FRD.Fmt.argsI)+1);
  arrVT[0].VAnsiString:=@msg[1];
  arrVT[0].VType:=vtAnsiString;
  for i:=low(FRD.Fmt.argsI) to high(FRD.Fmt.argsI) do begin
    processDecoratorData(Decorators.Mutable[FRD.Fmt.argsI[i]]^,Stampt,msg,LogMode,LMDI,MsgOptions);
    arrVT[i+1].VAnsiString:=@Decorators.Mutable[FRD.Fmt.argsI[i]]^.CurrRes[1];
    arrVT[i+1].VType:=vtAnsiString;
  end;
  FRD.Stampt:=Stampt;
  FRD.Res:=format(FRD.Fmt.msgFmt,arrVT);
end;

procedure TLog.processMsg(msg:TLogMsg;LogMode:TLogLevel;LMDI:TModuleDesk;MsgOptions:TMsgOpt);
var
  i:Integer;
  Stampt:TLogStampt;
begin
  Stampt:=LogStampter.CreateHandle;
  for i:=0 to Backends.Size-1 do
    if Backends.Mutable[i]^.PBackend<>nil then begin
      if Backends.Mutable[i]^.msgFmtIndex=-1 then
        Backends.Mutable[i]^.PBackend^.doLog(msg,MsgOptions,LogMode,LMDI)
      else begin
        processFmtResultData(FmtDatas.Mutable[Backends.Mutable[i]^.msgFmtIndex]^,Stampt,msg,LogMode,LMDI,MsgOptions);
        Backends.Mutable[i]^.PBackend^.doLog(FmtDatas.Mutable[Backends.Mutable[i]^.msgFmtIndex]^.Res,MsgOptions,LogMode,LMDI);
      end;
    end;
end;

constructor TLog.init(TraceModeName:TLogLevelHandleNameType;TraceModeAlias:AnsiChar);
begin
  MsgOptAliasDic:=TTMsgOptAliasDic.Create;
  LogLevels.init;
  ModulesDesks.init;
  LogLevelAliasDic:=TLogLevelAliasDic.create;
  LogStampter.init;
  LogStampter.CreateHandle;
  LM_Trace:=RegisterLogLevel(TraceModeName,TraceModeAlias,LLTInfo);// — вывод всего подряд. На тот случай, если Debug не позволяет локализовать ошибку.

  NewModuleDesk.enabled:=true;
  DefaultModuleDeskIndex:=RegisterModule('DEFAULT');
  NewModuleDesk.enabled:=false;
  SetDefaultLogLevel(LM_Trace,true);
  SetCurrentLogLevel(LM_Trace,true);

  Backends:=TBackends.Create;
  TotalBackendsCount:=0;

  Decorators:=TDecorators.Create;
  FmtDatas:=TFmtDatas.Create;
  FmtDatasDic:=TFmtDatasDic.Create(TFmtDataComparer.Create);
  EnterMsgOpt:=0;
  ExitMsgOpt:=0;
end;

procedure TLog.LogStart;
begin
  processMsg('------------------------Log started------------------------',LogModeDefault,LMDIDefault,MsgDefaultOptions);
end;

procedure TLog.LogEnd;
begin
  processMsg('-------------------------Log ended-------------------------',LogModeDefault,LMDIDefault,MsgDefaultOptions);
end;

function TLog.isTraceEnabled:boolean;
begin
  result:=LM_Trace>=CurrentLogLevel
end;
procedure TLog.ZDebugLN(const S: string);
var
  dbgmode,tdbgmode:TLogLevel;
  prefixlength,prefixstart:integer;
  modulename:string;
  lmdi:TModuleDesk;
  MsgOptions,TempMsgOptions:TMsgOpt;
  ss:string;
begin
  ss:=s;
  dbgmode:=LM_Trace;
  MsgOptions:=MsgDefaultOptions;
  if length(ss)>1 then
    if ss[1]='{' then begin
      prefixlength:=2;
      while (ss[prefixlength]<>'}')and(prefixlength<=length(ss)) do begin
        if LogLevelAliasDic.TryGetValue(ss[prefixlength],tdbgmode) then
          dbgmode:=tdbgmode
        else if MsgOptAliasDic.TryGetValue(ss[prefixlength],TempMsgOptions) then
          MsgOptions:=MsgOptions or TempMsgOptions;
        inc(prefixlength);
      end;
      ss:=copy(ss,prefixlength+1,length(ss)-prefixlength);
    end;
   if length(ss)>1 then
     if ss[1]='[' then begin
       prefixstart:=2;
       prefixlength:=2;
       while (ss[prefixlength]<>']')and(prefixlength<=length(ss)) do
        inc(prefixlength);
       modulename:=uppercase(copy(ss,prefixstart,prefixlength-2));
       ss:=copy(ss,prefixlength+1,length(ss)-prefixlength);
     end;
   if modulename='' then
     lmdi:=DefaultModuleDeskIndex
   else
     lmdi:=RegisterModule(modulename);
   if IsNeedToLog(dbgmode,lmdi) then
     LogOutStr(ss,dbgmode,lmdi,MsgOptions);
end;

procedure TLog.addMsgOptAlias(const ch:AnsiChar;const opt:TMsgOpt);
begin
  MsgOptAliasDic.add(ch,opt);
end;

procedure TLog.ZOnDebugLN(Sender: TObject; S: string; var Handled: Boolean);
begin
     ZDebugLN(S);
end;

destructor TLog.done;
var
  i:integer;
begin
  for i:=0 to ModulesDesks.HandleDataVector.Size-1 do
  if ModulesDesks.HandleDataVector[i].D.enabled then
    processMsg(format('Log module name "%s" state: Enabled',[ModulesDesks.HandleDataVector[I].N]),LogModeDefault,LMDIDefault,MsgDefaultOptions)
  else
    processMsg(format('Log module name "%s" state: Disabled',[ModulesDesks.HandleDataVector[I].N]),LogModeDefault,LMDIDefault,MsgDefaultOptions);
  //processMsg('-------------------------Log ended-------------------------',LogModeDefault,LMDIDefault,MsgDefaultOptions);
  LogLevels.done;
  ModulesDesks.done;
  LogStampter.done;
  if assigned(Backends)then
    FreeAndNil(Backends);
  if assigned(Decorators)then
    FreeAndNil(Decorators);
  if assigned(LogLevelAliasDic)then
    FreeAndNil(LogLevelAliasDic);
  if assigned(MsgOptAliasDic)then
    FreeAndNil(MsgOptAliasDic);
  if assigned(FmtDatasDic)then
    FreeAndNil(FmtDatasDic);
  if assigned(FmtDatas)then
    FreeAndNil(FmtDatas);
end;

initialization
  MsgOpt.init;
finalization
  MsgOpt.done;
end.

