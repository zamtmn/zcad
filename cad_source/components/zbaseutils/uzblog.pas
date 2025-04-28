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
  Masks,
  uzbLogTypes,
  uzbHandles,uzbNamedHandles,uzbNamedHandlesWithData,uzbSets;

resourcestring
  rsLogModuleState='Log module name "%s" state: %s';
  rsEnabled='Enabled';
  rsDisabled='Disabled';

const
  MsgDefaultOptions=0;
  LogModeDefault=1;
  LMDIDefault=1;

type

  TMsgOptions=specialize GTSet<TMsgOpt,TMsgOpt>;

  TLog=object
    private
      type

        TEntered=record
          Entered:Boolean;
          EnteredTo:TLogMsg;
          LogLevel:TLogLevel;
          LMDI:TModuleDesk;
          MsgOptions:TMsgOpt;
        end;

        PTTLogLevelData=^TLogLevelData;
        TLogLevelData=record
          LogLevelType:TLogLevelType;
        end;

        TLogLevelsHandles=specialize GTNamedHandlesWithData<TLogLevel,specialize GTLinearIncHandleManipulator<TLogLevel>,TLogLevelHandleNameType,specialize GTStringNamesUPPERCASE<TLogLevelHandleNameType>,TLogLevelData>;
        TLogStampt=LongInt;

        TFmtData=record
          msgFmt:TLogMsg;
          argsI:array of Integer;
          argsP:array of PTLogerBaseDecorator
        end;

        IFmtDataComparer=specialize IEqualityComparer<TFmtData>;
        TFmtDataComparer=class(TInterfacedObject,IFmtDataComparer)
          {todo: убрать $IF когда const попадет в релиз fpc}
          function Equals({$IF FPC_FULlVERSION>30202}const{$ELSE}constref{$ENDIF}ALeft, ARight: TFmtData): Boolean;
          function GetHashCode({$IF FPC_FULlVERSION>30202}const{$ELSE}constref{$ENDIF}AValue: TFmtData): UInt32;
        end;

        TFmtResultData=record
          Fmt:TFmtData;
          Res:TLogMsg;
          Stampt:TLogStampt;
        end;

        TEnable=(EEnable,EDisable,EDefault);
        TLogLevelAliasDic=specialize TDictionary<AnsiChar,TLogLevel>;
        TTMsgOptAliasDic=specialize TDictionary<AnsiChar,TMsgOpt>;

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

        TMasks=specialize TVector<TModuleDeskNameType>;

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
        DisabledModuleAllow:TLogLevelType;

        LogLevelAliasDic:TLogLevelAliasDic;
        EnabledMasks,DisabledMasks:TMasks;
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
      procedure processMsg(const msg:TLogMsg;LogMode:TLogLevel;LMDI:TModuleDesk;MsgOptions:TMsgOpt);
      procedure processFmtResultData(var FRD:TFmtResultData;Stampt:TLogStampt;const msg:TLogMsg;LogMode:TLogLevel;LMDI:TModuleDesk;MsgOptions:TMsgOpt);
      procedure processDecoratorData(var DD:TDecoratorData;Stampt:TLogStampt;const msg:TLogMsg;LogMode:TLogLevel;LMDI:TModuleDesk;MsgOptions:TMsgOpt);

    public
      EnterMsgOpt,ExitMsgOpt:TMsgOpt;
      LM_Trace:TLogLevel;// — вывод всего подряд. На тот случай, если Debug не позволяет локализовать ошибку.


      constructor Init(TraceModeName:TLogLevelHandleNameType='LM_Trace';TraceModeAlias:AnsiChar='T');
      destructor Done;virtual;

      procedure addMsgOptAlias(const ch:AnsiChar;const opt:TMsgOpt);

      function addBackend(var BackEnd:TLogerBaseBackend;const fmt:TLogMsg;const args:array of PTLogerBaseDecorator):TLogExtHandle;
      procedure removeBackend(BackEndH:TLogExtHandle);

      function addDecorator(var Decorator:TLogerBaseDecorator):TLogExtHandle;
      procedure removeDecorator(DecoratorH:TLogExtHandle);

      procedure LogStart;
      procedure LogEnd;

      function Enter(const EnterTo:TLogMsg;LogMode:TLogLevel=1;LMDI:TModuleDesk=1;MsgOptions:TMsgOpt=MsgDefaultOptions):TEntered;
      procedure Leave(AEntered:TEntered);

      procedure LogOutFormatStr(const Fmt:TLogMsg;const Args :Array of const;LogMode:TLogLevel;LMDI:TModuleDesk=1;MsgOptions:TMsgOpt=MsgDefaultOptions);virtual;
      procedure LogOutStr(const str:TLogMsg;LogMode:TLogLevel=1;LMDI:TModuleDesk=1;MsgOptions:TMsgOpt=MsgDefaultOptions);virtual;
      function RegisterLogLevel(LogLevelName:TLogLevelHandleNameType;LLAlias:AnsiChar;_LLD:TLogLevelType):TLogLevel;

      function RegisterModule(ModuleName:TModuleDeskNameType;Enbl:TEnable=EDefault):TModuleDesk;
      procedure SetCurrentLogLevel(LogLevel:TLogLevel;silent:boolean=false);
      function GetCurrentLogLevel:TLogLevel;
      procedure SetDefaultLogLevel(LogLevel:TLogLevel;silent:boolean=false);

      procedure ZOnDebugLN(Sender: TObject; const S: TLogMsg; var Handled: Boolean);
      procedure zDebugLn(const S: TLogMsg);
      function isTraceEnabled:boolean;

      procedure AddEnableModuleMask(Mask:TModuleDeskNameType);
      procedure AddDisableModuleMask(Mask:TModuleDeskNameType);

      procedure EnableModule(ModuleName:TModuleDeskNameType);overload;
      procedure DisableModule(ModuleName:TModuleDeskNameType);overload;
      procedure EnableModule(LMDI:TModuleDesk);overload;
      procedure DisableModule(LMDI:TModuleDesk);overload;
      procedure EnableAllModules;

      function TryGetLogLevelHandle(LogLevelName:TLogLevelHandleNameType;out LogLevel:TLogLevel):Boolean;
      function GetMutableLogLevelData(LL:TLogLevel):PTTLogLevelData;
      function LogMode2String(LogMode:TLogLevel):TLogLevelHandleNameType;
      function isModuleEnabled(LMDI:TModuleDesk):Boolean;
  end;

  TDoEnteredHelper = type helper for TLog.TEntered
    function IfEntered:TLog.TEntered;
  end;

var
  MsgOpt:TMsgOptions;

implementation

function TLog.TFmtDataComparer.Equals({$IF FPC_FULlVERSION>30202}const{$ELSE}constref{$ENDIF}ALeft, ARight: TFmtData): Boolean;
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

function TLog.TFmtDataComparer.GetHashCode({$IF FPC_FULlVERSION>30202}const{$ELSE}constref{$ENDIF}AValue: TFmtData): UInt32;
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

function TDoEnteredHelper.IfEntered:TLog.TEntered;
begin
  result.Entered:=Entered;
  Result.EnteredTo:=EnteredTo;
  Result.LogLevel:=LogLevel;
  Result.LMDI:=LMDI;
  Result.MsgOptions:=MsgOptions;
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
  if result then begin
    if LogMode<CurrentLogLevel then
      result:=false
    else
      result:=true;
  end else begin
    result:=LogLevels.GetPLincedData(LogMode)^.LogLevelType>=DisabledModuleAllow;
  end;
end;
procedure TLog.LogOutFormatStr(const Fmt:TLogMsg;const Args :Array of const;LogMode:TLogLevel;LMDI:TModuleDesk;MsgOptions:TMsgOpt=MsgDefaultOptions);
begin
  if IsNeedToLog(LogMode,lmdi) then
    processMsg(format(fmt,args),LogMode,LMDI,MsgOptions);
end;
function TLog.Enter(const EnterTo:TLogMsg;LogMode:TLogLevel=1;LMDI:TModuleDesk=1;MsgOptions:TMsgOpt=MsgDefaultOptions):TEntered;
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

procedure TLog.logoutstr(const str:TLogMsg;LogMode:TLogLevel;LMDI:TModuleDesk;MsgOptions:TMsgOpt=MsgDefaultOptions);
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
function TLog.GetCurrentLogLevel:TLogLevel;
begin
  Result:=CurrentLogLevel;
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
  function LLD(_LLD:TLogLevelType):TLogLevelData;
  begin
    result.LogLevelType:=_LLD;
  end;
var
  data:TLogLevelData;
begin
  data:=LLD(_LLD);
  result:=LogLevels.CreateOrGetHandleAndSetData(LogLevelName,data);
  if LLAlias<>#0 then
    LogLevelAliasDic.Add(LLAlias,result);
end;

function TLog.registermodule(modulename:TModuleDeskNameType;Enbl:TEnable=EDefault):TModuleDesk;
var
  i:integer;
begin
  if not ModulesDesks.TryGetHandle(modulename,result) then
  begin
    result:=ModulesDesks.CreateOrGetHandle(modulename);
    with ModulesDesks.GetPLincedData(result)^ do begin
      case Enbl of
        EEnable:enabled:=True;
        EDisable:enabled:=False;
        EDefault:begin
          for i:=0 to DisabledMasks.size-1 do
            if MatchesMask(modulename,DisabledMasks[i])then begin
              enabled:=False;
              exit;
            end;
          for i:=0 to EnabledMasks.size-1 do
            if MatchesMask(modulename,EnabledMasks[i])then begin
              enabled:=True;
              exit;
            end;
          enabled:=NewModuleDesk.enabled;
       end;
      end;
    end;
  end;
end;
procedure TLog.AddEnableModuleMask(Mask:TModuleDeskNameType);
var
  i:integer;
begin
  for i:=0 to ModulesDesks.HandleDataVector.Size-1 do
  if not ModulesDesks.HandleDataVector[i].D.Enabled then
    if MatchesMask(ModulesDesks.HandleDataVector[I].N,Mask) then begin
      ModulesDesks.HandleDataVector.Mutable[i]^.D.Enabled:=True;
      processMsg(format(rsLogModuleState,[ModulesDesks.HandleDataVector[I].N,rsEnabled]),LogModeDefault,LMDIDefault,MsgDefaultOptions)
    end;
  EnabledMasks.PushBack(Mask);
end;
procedure TLog.AddDisableModuleMask(Mask:TModuleDeskNameType);
var
  i:integer;
begin
  for i:=0 to ModulesDesks.HandleDataVector.Size-1 do
  if ModulesDesks.HandleDataVector[i].D.Enabled then
    if MatchesMask(ModulesDesks.HandleDataVector[I].N,Mask) then begin
      ModulesDesks.HandleDataVector.Mutable[i]^.D.Enabled:=False;
      processMsg(format(rsLogModuleState,[ModulesDesks.HandleDataVector[I].N,rsDisabled]),LogModeDefault,LMDIDefault,MsgDefaultOptions)
    end;
  DisabledMasks.PushBack(Mask);
end;
procedure TLog.enablemodule(modulename:TModuleDeskNameType);
begin
  enablemodule(ModulesDesks.CreateOrGetHandle(modulename));
end;
procedure TLog.disablemodule(modulename:TModuleDeskNameType);
begin
  disablemodule(ModulesDesks.CreateOrGetHandle(modulename));
end;
procedure TLog.EnableModule(LMDI:TModuleDesk);
begin
  ModulesDesks.GetPLincedData(LMDI)^.enabled:=true;
end;

procedure TLog.DisableModule(LMDI:TModuleDesk);
begin
  ModulesDesks.GetPLincedData(LMDI)^.enabled:=false;
end;

function TLog.isModuleEnabled(LMDI:TModuleDesk):Boolean;
begin
  result:=ModulesDesks.GetPLincedData(LMDI)^.enabled;
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


function TLog.addDecorator(var Decorator:TLogerBaseDecorator):TLogExtHandle;
var
  DD:TDecoratorData;
  i:Integer;
begin
  for i:=0 to Decorators.Size-1 do
    if Decorators.Mutable[i]^.PDecorator=@Decorator then
      exit(-i);
  DD.CreateRec(@Decorator,LogStampter.GetInitialHandleValue);
  result:=Decorators.Size;
  Decorators.PushBack(DD);
end;

procedure TLog.removeDecorator(DecoratorH:TLogExtHandle);
begin
  if DecoratorH>=0 then begin
    if Decorators.Mutable[DecoratorH]^.PDecorator<>nil then
      Decorators.Mutable[DecoratorH]^.PDecorator:=nil;
  end
end;

function TLog.addBackend(var BackEnd:TLogerBaseBackend;const fmt:TLogMsg;const args:array of PTLogerBaseDecorator):TLogExtHandle;
var
  BD:TLogerBackendData;
  i,j,k:Integer;
  FmtData:TFmtData;
  FmtRData:TFmtResultData;
  num:Integer;
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
        result:=-i;
      end;
  end;
  inc(TotalBackendsCount);
end;

procedure TLog.removeBackend(BackEndH:TLogExtHandle);
begin
  if BackEndH>=0 then begin
    if Backends.Mutable[BackEndH]^.PBackend<>nil then begin
      Backends.Mutable[BackEndH]^.PBackend:=nil;
      dec(TotalBackendsCount);
    end
  end else
  if Backends.Mutable[-BackEndH]^.PBackend<>nil then
    dec(TotalBackendsCount);
end;

procedure TLog.processDecoratorData(var DD:TDecoratorData;Stampt:TLogStampt; const msg:TLogMsg;LogMode:TLogLevel;LMDI:TModuleDesk;MsgOptions:TMsgOpt);
begin
  if DD.Stampt=Stampt then
    exit;
  DD.CurrRes:=DD.PDecorator^.GetDecor(msg,MsgOptions,LogMode,LMDI);
  DD.Stampt:=Stampt
end;

procedure TLog.processFmtResultData(var FRD:TFmtResultData;Stampt:TLogStampt; const msg:TLogMsg;LogMode:TLogLevel;LMDI:TModuleDesk;MsgOptions:TMsgOpt);
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

procedure TLog.processMsg(const msg:TLogMsg;LogMode:TLogLevel;LMDI:TModuleDesk;MsgOptions:TMsgOpt);
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
  EnabledMasks:=TMasks.Create;
  DisabledMasks:=TMasks.Create;
  DisabledModuleAllow:=LLTWarning;
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
var
  i:integer;
begin
  processMsg('-------------------------Log ended-------------------------',LogModeDefault,LMDIDefault,MsgDefaultOptions);
  for i:=0 to ModulesDesks.HandleDataVector.Size-1 do
  if ModulesDesks.HandleDataVector[i].D.enabled then
    processMsg(format(rsLogModuleState,[ModulesDesks.HandleDataVector[I].N,rsEnabled]),LogModeDefault,LMDIDefault,MsgDefaultOptions)
  else
    processMsg(format(rsLogModuleState,[ModulesDesks.HandleDataVector[I].N,rsDisabled]),LogModeDefault,LMDIDefault,MsgDefaultOptions);
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
        if (LogLevelAliasDic<>nil)and(LogLevelAliasDic.TryGetValue(ss[prefixlength],tdbgmode)) then
          dbgmode:=tdbgmode
        else if (MsgOptAliasDic<>nil)and(MsgOptAliasDic.TryGetValue(ss[prefixlength],TempMsgOptions)) then
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

procedure TLog.ZOnDebugLN(Sender: TObject; const S: string; var Handled: Boolean);
begin
     ZDebugLN(S);
end;

destructor TLog.done;
//var
//  i:integer;
begin
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
  if assigned(EnabledMasks)then
    FreeAndNil(EnabledMasks);
  if assigned(DisabledMasks)then
    FreeAndNil(DisabledMasks);
end;

initialization
  MsgOpt.init;
finalization
  MsgOpt.done;
end.

