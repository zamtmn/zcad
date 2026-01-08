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

unit uzbLogIntf;
{$mode objfpc}{$H+}
{$modeswitch advancedrecords}

interface
uses
  SysUtils,Classes,
  gvector;

type
  TDebugLnProc=procedure(const S:String) of object;
  TDebugLnFormatedProc=procedure(const S:String; const Args: array of const) of object;
  TIsTraceEnabled=function:boolean of object;

procedure zDebugLn(const S:String);
procedure zDebugLn(const Args: array of const);
procedure zDebugLn(const S:String; const Args: array of const);
procedure zTraceLn(const S:String);
procedure zTraceLn(const S:String; const Args: array of const);

procedure InstallLoger(ADebugLnProc:TDebugLnProc;ADebugLnFormatProc:TDebugLnFormatedProc;AIsTraceEnabled:TIsTraceEnabled);
procedure RemoveLoger(ADebugLnProc:TDebugLnProc;ADebugLnFormatProc:TDebugLnFormatedProc;AIsTraceEnabled:TIsTraceEnabled);

implementation

type
  TLoggerRec=record
    public
      DebugLnProc:TDebugLnProc;
      DebugLnFormatedProc:TDebugLnFormatedProc;
      IsTraceEnabled:TIsTraceEnabled;

      constructor CreateRec(ADebugLnProc:TDebugLnProc;ADebugLnFormatedProc:TDebugLnFormatedProc;AIsTraceEnabled:TIsTraceEnabled);
  end;
  TLoggers=specialize TVector<TLoggerRec>;

var
  Loggers:TLoggers;

  function DbgS(const c: cardinal): string;
  begin
    {$IFnDEF USED_BY_LAZLOGGER_DUMMY}
    Result:=IntToStr(c);
    {$ELSE}
    Result := '';
    {$ENDIF}
  end;

  function DbgS(const i: longint): string;
  begin
    {$IFnDEF USED_BY_LAZLOGGER_DUMMY}
    Result:=IntToStr(i);
    {$ELSE}
    Result := '';
    {$ENDIF}
  end;

  function DbgS(const i: int64): string;
  begin
    {$IFnDEF USED_BY_LAZLOGGER_DUMMY}
    Result:=IntToStr(i);
    {$ELSE}
    Result := '';
    {$ENDIF}
  end;

  function DbgS(const q: qword): string;
  begin
    {$IFnDEF USED_BY_LAZLOGGER_DUMMY}
    Result:=IntToStr(q);
    {$ELSE}
    Result := '';
    {$ENDIF}
  end;

  function DbgS(const p: pointer): string;
  begin
    {$IFnDEF USED_BY_LAZLOGGER_DUMMY}
    Result:=HexStr({%H-}PtrUInt(p),2*sizeof(PtrInt));
    {$ELSE}
    Result := '';
    {$ENDIF}
  end;

  function DbgS(const e: extended; MaxDecimals: integer  = 999): string;
  begin
    {$IFnDEF USED_BY_LAZLOGGER_DUMMY}
    Result:=copy(FloatToStr(e),1,MaxDecimals);
    {$ELSE}
    Result := '';
    {$ENDIF}
  end;

  function DbgS(const b: boolean): string;
  begin
    {$IFnDEF USED_BY_LAZLOGGER_DUMMY}
    if b then Result:='True' else Result:='False';
    {$ELSE}
    Result := '';
    {$ENDIF}
  end;

  function DbgSName(const p: TObject): string;
  begin
    {$IFnDEF USED_BY_LAZLOGGER_DUMMY}
    if p=nil then
      Result:='nil'
    else if p is TComponent then
      Result:=TComponent(p).Name+':'+p.ClassName
    else
      Result:=p.ClassName;
    {$ELSE}
    Result := '';
    {$ENDIF}
  end;

  function DbgSName(const p: TClass): string;
  begin
    {$IFnDEF USED_BY_LAZLOGGER_DUMMY}
    if p=nil then
      Result:='nil'
    else
      Result:=p.ClassName;
    {$ELSE}
    Result := '';
    {$ENDIF}
  end;


function ArgsToString(const Args: array of const): string;
var
  i: Integer;
begin
  Result := '';
  for i:=Low(Args) to High(Args) do begin
    case Args[i].VType of
      vtInteger:    Result := Result + dbgs(Args[i].vinteger);
      vtInt64:      Result := Result + dbgs(Args[i].VInt64^);
      vtQWord:      Result := Result + dbgs(Args[i].VQWord^);
      vtBoolean:    Result := Result + dbgs(Args[i].vboolean);
      vtExtended:   Result := Result + dbgs(Args[i].VExtended^);
  {$ifdef FPC_CURRENCY_IS_INT64}
      // MWE:
      // fpc 2.x has troubles in choosing the right dbgs()
      // so we convert here
      vtCurrency:   Result := Result + dbgs(int64(Args[i].vCurrency^)/10000, 4);
  {$else}
      vtCurrency:   Result := Result + dbgs(Args[i].vCurrency^);
  {$endif}
      vtString:     Result := Result + Args[i].VString^;
      vtAnsiString: Result := Result + AnsiString(Args[i].VAnsiString);
      vtChar:       Result := Result + Args[i].VChar;
      vtPChar:      Result := Result + Args[i].VPChar;
      vtPWideChar:  Result := {%H-}Result {%H-}+ Args[i].VPWideChar;
      vtWideChar:   Result := Result + AnsiString(Args[i].VWideChar);
      vtWidestring: Result := Result + AnsiString(WideString(Args[i].VWideString));
      vtObject:     Result := Result + DbgSName(Args[i].VObject);
      vtClass:      Result := Result + DbgSName(Args[i].VClass);
      vtPointer:    Result := Result + Dbgs(Args[i].VPointer);
      else          Result := Result + '?unknown variant?';
    end;
  end;
end;


constructor TLoggerRec.CreateRec(ADebugLnProc:TDebugLnProc;ADebugLnFormatedProc:TDebugLnFormatedProc;AIsTraceEnabled:TIsTraceEnabled);
begin
  DebugLnProc:=ADebugLnProc;
  DebugLnFormatedProc:=ADebugLnFormatedProc;
  IsTraceEnabled:=AIsTraceEnabled;
end;

procedure InstallLoger(ADebugLnProc:TDebugLnProc;ADebugLnFormatProc:TDebugLnFormatedProc;AIsTraceEnabled:TIsTraceEnabled);
begin
  if Assigned(ADebugLnProc)or Assigned(ADebugLnFormatProc) then begin
    if Loggers=nil then
      Loggers:=TLoggers.Create;
    Loggers.PushBack(TLoggerRec.CreateRec(ADebugLnProc,ADebugLnFormatProc,AIsTraceEnabled));
  end;
end;

procedure RemoveLoger(ADebugLnProc:TDebugLnProc;ADebugLnFormatProc:TDebugLnFormatedProc;AIsTraceEnabled:TIsTraceEnabled);
var
  lr:TLoggerRec;
  plr:^TLoggerRec;
  i:integer;
begin
  if Loggers<>nil then
    if Loggers.Size>0 then
      if Assigned(ADebugLnProc)or Assigned(ADebugLnFormatProc) then begin
        lr:=TLoggerRec.CreateRec(ADebugLnProc,ADebugLnFormatProc,AIsTraceEnabled);
        i:=0;
        repeat
          plr:=Loggers.Mutable[i];
          if ((plr^.DebugLnProc)=(lr.DebugLnProc))
          and ((plr^.DebugLnFormatedProc)=(lr.DebugLnFormatedProc))
          and ((plr^.IsTraceEnabled)=(lr.IsTraceEnabled))then
            loggers.Erase(i)
          else
            inc(i);
        until i>=Loggers.Size;
      end;
end;

procedure zDebugLn(const S:String);
var
  Logger:TLoggerRec;
begin
  if Loggers<>nil then
    for Logger in Loggers do
      if Assigned(Logger.DebugLnProc) then
        Logger.DebugLnProc(S);
end;
procedure zDebugLn(const Args: array of const);
begin
  zDebugLn(ArgsToString(Args));
end;

procedure zDebugLn(const S:String; const Args: array of const);
var
  Logger:TLoggerRec;
begin
  if Loggers<>nil then
    for Logger in Loggers do
      if Assigned(Logger.DebugLnFormatedProc) then
        Logger.DebugLnFormatedProc(S,Args)
      else
        Logger.DebugLnProc(format(S,Args));
end;

procedure zTraceLn(const S:String);
var
  Logger:TLoggerRec;
  TraceEnabled:Boolean;
begin
  if Loggers<>nil then
    for Logger in Loggers do begin
      TraceEnabled:=not Assigned(Logger.IsTraceEnabled);
      if not TraceEnabled then
        TraceEnabled:=Logger.IsTraceEnabled();
      if TraceEnabled then
        if Assigned(Logger.DebugLnProc) then
          Logger.DebugLnProc(S);
    end;
end;

procedure zTraceLn(const S:String; const Args: array of const);
var
  Logger:TLoggerRec;
  TraceEnabled:Boolean;
begin
  if Loggers<>nil then
    for Logger in Loggers do begin
      TraceEnabled:=not Assigned(Logger.IsTraceEnabled);
      if not TraceEnabled then
        TraceEnabled:=Logger.IsTraceEnabled();
      if TraceEnabled then
        if Assigned(Logger.DebugLnFormatedProc) then
          Logger.DebugLnFormatedProc(S,Args)
        else
          Logger.DebugLnProc(format(S,Args));
    end;
end;

initialization
  Loggers:=nil;
finalization
  FreeAndNil(Loggers);
end.

