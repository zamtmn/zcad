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

unit uzelongprocesssupport;
{$Mode delphi}{$H+}
{$INCLUDE zengineconfig.inc}


interface

uses
  SysUtils,
  gzctnrSTL,uzbSets,
  uzbLogIntf;

const
  LPSHEmpty=-1;
  LPSDefaultOptions=0;

type
  TLPSHandle=integer;
  TLPSCounter=integer;
  TLPName=string;
  TLPOpt=longword;

  TOnLPStartProc=procedure(LPHandle:TLPSHandle;Total:TLPSCounter;
    LPName:TLPName;Options:TLPOpt) of object;
  TOnLPProgressProc=procedure(LPHandle:TLPSHandle;Current:TLPSCounter;
    Options:TLPOpt) of object;
  TOnLPEndProc=procedure(LPHandle:TLPSHandle;TotalLPTime:TDateTime;Options:TLPOpt) of
    object;

  TLPInfo=record
    LPTotal:TLPSCounter;
    LPName:TLPName;
    LPContext:Pointer;
    LPUseCounter:integer;
    LPTime:TDateTime;
    Options:TLPOpt;
  end;
  TLPInfoVector=TMyVector<TLPInfo>;
  PTLPInfo=^TLPInfo;
  TOnLPStartProcVector=TMyVector<TOnLPStartProc>;
  TOnLPProgressProcVector=TMyVector<TOnLPProgressProc>;
  TOnLPEndProcVector=TMyVector<TOnLPEndProc>;

  TZELongProcessSupport=class
  private
  type
    TMsgOptions=GTSet<TLPOpt,TLPOpt>;
    {PTLPInfo=TLPInfoVector.PT;}
    var
      OptionsGenerator:TMsgOptions;
      ActiveProcessCount:integer;
      LPInfoVector:TLPInfoVector;
      OnLPStartProcVector:TOnLPStartProcVector;
      OnLPProgressProcVector:TOnLPProgressProcVector;
      OnLPEndProcVector:TOnLPEndProcVector;
    procedure DoStartLongProcess(plpi:PTLPInfo;
      LPHandle:TLPSHandle;Options:TLPOpt);
    procedure DoProgressLongProcess(plpi:PTLPInfo;
      LPHandle:TLPSHandle;Current:TLPSCounter;Options:TLPOpt);
    procedure DoEndLongProcess(plpi:PTLPInfo;
      LPHandle:TLPSHandle;Options:TLPOpt);
  public
    function StartLongProcess(LPName:TLPName;
      Context:pointer;Total:TLPSCounter=0;Options:TLPOpt=LPSDefaultOptions):TLPSHandle;
    procedure ProgressLongProcess(LPHandle:TLPSHandle;
      Current:TLPSCounter);
    procedure EndLongProcess(LPHandle:TLPSHandle);

    procedure AddOnLPStartHandler(proc:TOnLPStartProc);
    procedure AddOnLPProgressHandler(proc:TOnLPProgressProc);
    procedure AddOnLPEndHandler(proc:TOnLPEndProc);
    constructor Create;
    destructor Destroy;override;
    function isProcessed:boolean;
    function isFirstProcess:boolean;
    function getLPName(LPHandle:TLPSHandle):TLPName;
    function hasOptions(LPHandle:TLPSHandle;Options:TLPOpt):boolean;
    function CreateOption:TLPOpt;
    function Clone:TZELongProcessSupport;
  end;

var
  LPS:TZELongProcessSupport;
  LPSOSilent,LPSONoProgressBar:TLPOpt;

implementation

function TZELongProcessSupport.Clone:TZELongProcessSupport;
begin
  result:=TZELongProcessSupport.Create;
  // OptionsGenerator:TMsgOptions;
  //result.ActiveProcessCount:=ActiveProcessCount;
  //LPInfoVector.CopyTo(result.LPInfoVector);
  OnLPStartProcVector.CopyTo(result.OnLPStartProcVector);
  OnLPProgressProcVector.CopyTo(result.OnLPProgressProcVector);
  OnLPEndProcVector.CopyTo(result.OnLPEndProcVector);
end;

function TZELongProcessSupport.CreateOption:TLPOpt;
begin
  Result:=OptionsGenerator.GetEnum;
end;

function TZELongProcessSupport.getLPName(LPHandle:TLPSHandle):TLPName;
begin
  if LPHandle<LPInfoVector.Size then
    Result:=LPInfoVector.Mutable[LPHandle].LPName
  else
    Result:='';
end;

function TZELongProcessSupport.hasOptions(LPHandle:TLPSHandle;Options:TLPOpt):boolean;
begin
  if LPHandle<LPInfoVector.Size then
    Result:=OptionsGenerator.IsAllPresent(LPInfoVector.Mutable[LPHandle].Options,Options)
  else
    Result:=False;
end;

function TZELongProcessSupport.isProcessed:boolean;
begin
  Result:=ActiveProcessCount>0;
end;

function TZELongProcessSupport.isFirstProcess:boolean;
begin
  Result:=ActiveProcessCount=1;
end;

procedure TZELongProcessSupport.DoStartLongProcess(plpi:PTLPInfo;
  LPHandle:TLPSHandle;Options:TLPOpt);
var
  i:integer;
begin
  if OnLPStartProcVector.size>0 then
    for i:=0 to OnLPStartProcVector.size-1 do
      OnLPStartProcVector[i](LPHandle,plpi^.LPTotal,plpi^.LPName,Options);
end;

procedure TZELongProcessSupport.DoProgressLongProcess(plpi:PTLPInfo;
  LPHandle:TLPSHandle;Current:TLPSCounter;Options:TLPOpt);
var
  i:integer;
begin
  if OnLPProgressProcVector.size>0 then
    for i:=0 to OnLPProgressProcVector.size-1 do
      OnLPProgressProcVector[i](LPHandle,Current,Options);
end;

procedure TZELongProcessSupport.DoEndLongProcess(plpi:PTLPInfo;
  LPHandle:TLPSHandle;Options:TLPOpt);
var
  i:integer;
begin
  if OnLPEndProcVector.size>0 then
    for i:=0 to OnLPEndProcVector.size-1 do
      OnLPEndProcVector[i](LPHandle,plpi^.LPTime,Options);
end;

function TZELongProcessSupport.StartLongProcess(LPName:TLPName;
  Context:pointer;Total:TLPSCounter=0;Options:TLPOpt=LPSDefaultOptions):TLPSHandle;
var
  LPI:TLPInfo;
  PLPI:PTLPInfo;
begin
  if Context<>nil then
    if LPInfoVector.Size>0 then begin
      Result:=LPInfoVector.Size-1;
      PLPI:=LPInfoVector.mutable{$IFDEF DELPHI}({$ENDIF}{$IFNDEF DELPHI}[{$ENDIF}Result{$IFNDEF DELPHI}]{$ENDIF}{$IFDEF DELPHI}){$ENDIF};
      if Context=PLPI^.LPContext then begin
        Inc(PLPI^.LPUseCounter);
        exit;
      end;
    end;
  LPI.LPName:=LPName;
  LPI.LPTotal:=Total;
  LPI.LPContext:=Context;
  LPI.LPUseCounter:=0;
  LPI.Options:=Options;
  LPInfoVector.PushBack(LPI);

  Inc(ActiveProcessCount);
  Result:=LPInfoVector.Size-1;
  PLPI:=LPInfoVector.mutable{$IFDEF DELPHI}({$ENDIF}{$IFNDEF DELPHI}[{$ENDIF}Result{$IFNDEF DELPHI}]{$ENDIF}{$IFDEF DELPHI}){$ENDIF};
  PLPI^.LPTime:=now;
  DoStartLongProcess(PLPI,Result,Options);
end;

procedure TZELongProcessSupport.ProgressLongProcess(LPHandle:TLPSHandle;
  Current:TLPSCounter);
var
  PLPI:PTLPInfo;
begin
  PLPI:=LPInfoVector.mutable{$IFDEF DELPHI}({$ENDIF}{$IFNDEF DELPHI}[{$ENDIF}LPHandle{$IFNDEF DELPHI}]{$ENDIF}{$IFDEF DELPHI}){$ENDIF};
  DoProgressLongProcess(PLPI,LPHandle,Current,PLPI^.Options);
end;

procedure TZELongProcessSupport.EndLongProcess(LPHandle:TLPSHandle);
var
  PLPI:PTLPInfo;
begin
  PLPI:=LPInfoVector.mutable{$IFDEF DELPHI}({$ENDIF}{$IFNDEF DELPHI}[{$ENDIF}LPHandle{$IFNDEF DELPHI}]{$ENDIF}{$IFDEF DELPHI}){$ENDIF};
  if PLPI^.LPUseCounter>0 then begin
    Dec(PLPI^.LPUseCounter);
    exit;
  end;
  PLPI^.LPTime:=now-PLPI^.LPTime;

  DoEndLongProcess(PLPI,LPHandle,PLPI^.Options);

  PLPI^.LPName:='';
  PLPI^.LPContext:=nil;
  Dec(ActiveProcessCount);
  if ActiveProcessCount=0 then
    LPInfoVector.Clear;
end;

procedure TZELongProcessSupport.AddOnLPStartHandler(proc:TOnLPStartProc);
begin
  OnLPStartProcVector.pushback(proc);
end;

procedure TZELongProcessSupport.AddOnLPProgressHandler(proc:TOnLPProgressProc);
begin
  OnLPProgressProcVector.pushback(proc);
end;

procedure TZELongProcessSupport.AddOnLPEndHandler(proc:TOnLPEndProc);
begin
  OnLPEndProcVector.pushback(proc);
end;

constructor TZELongProcessSupport.Create;
begin
  inherited;
  OptionsGenerator.init;
  LPInfoVector:=TLPInfoVector.Create;
  OnLPStartProcVector:=TOnLPStartProcVector.Create;
  OnLPProgressProcVector:=TOnLPProgressProcVector.Create;
  OnLPEndProcVector:=TOnLPEndProcVector.Create;
  ActiveProcessCount:=0;
end;

destructor TZELongProcessSupport.Destroy;
begin
  OptionsGenerator.done;
  LPInfoVector.Destroy;
  OnLPStartProcVector.Destroy;
  OnLPProgressProcVector.Destroy;
  OnLPEndProcVector.Destroy;
  inherited;
end;

initialization
  LPS:=TZELongProcessSupport.Create;
  LPSOSilent:=LPS.CreateOption;
  LPSONoProgressBar:=LPS.CreateOption;

finalization
  zDebugLn('{I}[UnitsFinalization] Unit "'+{$INCLUDE %FILE%}+'" finalization');
  LPS.Destroy;
end.
