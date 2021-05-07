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
unit uzbhandles;
{$INCLUDE def.inc}

interface

uses sysutils;

type
GTHandleManipulator<GHandleType>=object
  class function GetStartValue:GHandleType;inline;static;
  class procedure NextValue(var Value:GHandleType);inline;static;
end;
GTHandleInvManipulator<GHandleType>=object
  class function GetStartValue:GHandleType;inline;static;
  class procedure NextValue(var Value:GHandleType);inline;static;
end;
GTHandleByteManipulator<GHandleType>=object
  class function GetStartValue:GHandleType;inline;static;
  class procedure NextValue(var Value:GHandleType);inline;static;
end;
GTHandleInvByteManipulator<GHandleType>=object
  class function GetStartValue:GHandleType;inline;static;
  class procedure NextValue(var Value:GHandleType);inline;static;
end;
GTSimpleHandles<GHandleType,GHandleManipulator>=object
  type
    THandleType=GHandleType;
  var
    Seed:GHandleType;
  constructor init;
  destructor done;virtual;
  function CreateHandle:GHandleType;virtual;
  //procedure SetSeed(const Value:GHandleType);
end;

implementation

class function GTHandleManipulator<GHandleType>.GetStartValue:GHandleType;
begin
  result:={default(GHandleType)}0;
end;
class procedure GTHandleManipulator<GHandleType>.NextValue(var Value:GHandleType);
begin
  inc(Value);
end;

class function GTHandleInvManipulator<GHandleType>.GetStartValue:GHandleType;
begin
  result:=high(GHandleType);
end;
class procedure GTHandleInvManipulator<GHandleType>.NextValue(var Value:GHandleType);
begin
  dec(Value);
end;

class function GTHandleByteManipulator<GHandleType>.GetStartValue:GHandleType;
begin
  result:=0;
end;
class procedure GTHandleByteManipulator<GHandleType>.NextValue(var Value:GHandleType);
begin
  if Value=0 then
    Value:=1
  else
    value:=value shl 1;
end;

class function GTHandleInvByteManipulator<GHandleType>.GetStartValue:GHandleType;
begin
  result:=0;
end;
class procedure GTHandleInvByteManipulator<GHandleType>.NextValue(var Value:GHandleType);
begin
  if Value=0 then
    Value:=1 shl (sizeof(GHandleType)*8-1)
  else
    value:=value shr 1;
end;

constructor GTSimpleHandles<GHandleType,GHandleManipulator>.init;
begin
  Seed:=GHandleManipulator.GetStartValue;
end;

destructor GTSimpleHandles<GHandleType,GHandleManipulator>.done;
begin
end;

function GTSimpleHandles<GHandleType,GHandleManipulator>.CreateHandle:GHandleType;
begin
  GHandleManipulator.NextValue(Seed);
  if seed=0 then
    Raise Exception.CreateFmt('GTSimpleHandles<GHandleType,GHandleManipulator>.GetHandle overflow',[]);
  result:=Seed;
end;
{procedure GTSimpleHandles<GHandleType,GHandleManipulator>.SetSeed(const Value:GHandleType);
begin
  Seed:=Value;
end;}

begin
end.
