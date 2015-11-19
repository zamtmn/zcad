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

unit uzelongprocesssupport;
{$INCLUDE def.inc}


interface
uses sysutils,usimplegenerics,
    memman,zcadsysvars,GDBase,GDBasetypes,gdbEntity,Types,Controls,Forms;
type
TLPSHandle=integer;
TLPSCounter=integer;
TLPName=string;

TOnLPStartProc=procedure(LPHandle:TLPSHandle;Total:TLPSCounter;LPName:TLPName) of object;
TOnLPProgressProc=procedure(LPHandle:TLPSHandle;Current:TLPSCounter) of object;
TOnLPEndProc=procedure(LPHandle:TLPSHandle;TotalLPTime:TDateTime) of object;
TLPInfo=record
              LPTotal:TLPSCounter;
              LPName:TLPName;
              LPContext:Pointer;
              LPUseCounter:Integer;
              LPTime:TDateTime;
        end;
TLPInfoVector=TMyVector<TLPInfo>;
TOnLPStartProcVector=TMyVector<TOnLPStartProc>;
TOnLPProgressProcVector=TMyVector<TOnLPProgressProc>;
TOnLPEndProcVector=TMyVector<TOnLPEndProc>;

TZELongProcessSupport=class
                           type
                               PTLPInfo=TLPInfoVector.PT;
                           var

                           LPInfoVector:TLPInfoVector;
                           OnLPStartProcVector:TOnLPStartProcVector;
                           OnLPProgressProcVector:TOnLPProgressProcVector;
                           OnLPEndProcVector:TOnLPEndProcVector;
                           ActiveProcessCount:Integer;
                           function StartLongProcess(Total:TLPSCounter;LPName:TLPName;Context:pointer):TLPSHandle;
                           procedure ProgressLongProcess(LPHandle:TLPSHandle;Current:TLPSCounter);
                           procedure EndLongProcess(LPHandle:TLPSHandle);

                           procedure DoStartLongProcess(plpi:PTLPInfo;LPHandle:TLPSHandle);
                           procedure DoProgressLongProcess(plpi:PTLPInfo;LPHandle:TLPSHandle;Current:TLPSCounter);
                           procedure DoEndLongProcess(plpi:PTLPInfo;LPHandle:TLPSHandle);


                           procedure AddOnLPStartHandler(proc:TOnLPStartProc);
                           procedure AddOnLPProgressHandler(proc:TOnLPProgressProc);
                           procedure AddOnLPEndHandler(proc:TOnLPEndProc);
                           constructor Create;
                           destructor Destroy;virtual;
                       end;
var
  LPS:TZELongProcessSupport;
implementation
procedure TZELongProcessSupport.DoStartLongProcess(plpi:PTLPInfo;LPHandle:TLPSHandle);
var
  i:integer;
begin
  for i:=0 to OnLPStartProcVector.size-1 do
   OnLPStartProcVector[i](LPHandle,plpi^.LPTotal,plpi^.LPName);
end;
procedure TZELongProcessSupport.DoProgressLongProcess(plpi:PTLPInfo;LPHandle:TLPSHandle;Current:TLPSCounter);
var
  i:integer;
begin
  for i:=0 to OnLPStartProcVector.size-1 do
   OnLPProgressProcVector[i](LPHandle,Current);
end;
procedure TZELongProcessSupport.DoEndLongProcess(plpi:PTLPInfo;LPHandle:TLPSHandle);
var
  i:integer;
begin
  for i:=0 to OnLPStartProcVector.size-1 do
   OnLPEndProcVector[i](LPHandle,plpi^.LPTime);
end;
function TZELongProcessSupport.StartLongProcess(Total:TLPSCounter;LPName:TLPName;Context:pointer):TLPSHandle;
var
  LPI:TLPInfo;
  PLPI:PTLPInfo;
begin
  if LPInfoVector.Size>0 then
  begin
    result:=LPInfoVector.Size-1;
    PLPI:=LPInfoVector.mutable[result];
    if Context=PLPI^.LPContext then
    begin
      inc(PLPI^.LPUseCounter);
      exit;
    end;
  end;
  LPI.LPName:=LPName;
  LPI.LPTotal:=Total;
  LPI.LPContext:=Context;
  LPI.LPUseCounter:=0;
  LPInfoVector.PushBack(LPI);

  inc(ActiveProcessCount);
  result:=LPInfoVector.Size-1;
  PLPI:=LPInfoVector.mutable[result];
  PLPI^.LPTime:=now;
  DoStartLongProcess(PLPI,result);
end;
procedure TZELongProcessSupport.ProgressLongProcess(LPHandle:TLPSHandle;Current:TLPSCounter);
var
  PLPI:PTLPInfo;
begin
  PLPI:=LPInfoVector.mutable[LPHandle];
  DoProgressLongProcess(PLPI,LPHandle,Current);
end;
procedure TZELongProcessSupport.EndLongProcess(LPHandle:TLPSHandle);
var
  PLPI:PTLPInfo;
begin
  PLPI:=LPInfoVector.mutable[LPHandle];
  if PLPI^.LPUseCounter>0 then
  begin
    dec(PLPI^.LPUseCounter);
    exit;
  end;
  PLPI^.LPTime:=now-PLPI^.LPTime;

  DoEndLongProcess(PLPI,LPHandle);

  PLPI^.LPName:='';
  dec(ActiveProcessCount);
  if ActiveProcessCount=0 then
                              LPInfoVector.clear;
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
  LPInfoVector:=TLPInfoVector.create;
  OnLPStartProcVector:=TOnLPStartProcVector.create;
  OnLPProgressProcVector:=TOnLPProgressProcVector.create;
  OnLPEndProcVector:=TOnLPEndProcVector.create;
  ActiveProcessCount:=0;
end;
destructor TZELongProcessSupport.Destroy;
begin
  LPInfoVector.destroy;
  OnLPStartProcVector.destroy;
  OnLPProgressProcVector.destroy;
  OnLPEndProcVector.destroy;
end;
initialization
  LPS:=TZELongProcessSupport.Create;
finalization
  LPS.destroy;
end.
