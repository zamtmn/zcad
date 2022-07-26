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
  SysUtils,gvector;

type
  TDebugLnProc=procedure(const S:String) of object;
  TDebugLnFormatedProc=procedure(const S:String;Args: array of const) of object;
  TIsTraceEnabled=function:boolean of object;

procedure zDebugLn(const S:String);
procedure zDebugLn(const S:String;Args: array of const);
procedure zTraceLn(const S:String);
procedure zTraceLn(const S:String;Args: array of const);

procedure InstallLoger(ADebugLnProc:TDebugLnProc;ADebugLnFormatProc:TDebugLnFormatedProc;AIsTraceEnabled:TIsTraceEnabled);
//procedure RemoveLoger(DebugLnProc:TDebugLnStr;DebugLnFormatProc:TDebugLnFormatProc;IsTraceEnabled:TIsTraceEnabled);

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

procedure zDebugLn(const S:String);
var
  Logger:TLoggerRec;
begin
  if Loggers<>nil then
    for Logger in Loggers do
      if Assigned(Logger.DebugLnProc) then
        Logger.DebugLnProc(S);
end;

procedure zDebugLn(const S:String; Args: array of const);
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

procedure zTraceLn(const S:String; Args: array of const);
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
end.

