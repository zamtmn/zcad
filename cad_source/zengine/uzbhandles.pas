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
  function GetHandle:GHandleType;
  procedure SetSeed(const Value:GHandleType);
end;
GTSet<GSetType,GEnumType>=object
  type
    TSetType=GSetType;
    TEnumItemType=GEnumType;
    TEnumType=GTSimpleHandles<GEnumType,GTHandleByteManipulator<GEnumType>>;
  constructor init;
  function GetEnum:GEnumType;virtual;
  function GetEmpty:GSetType;virtual;
  function GetFull:GSetType;virtual;
  //function GetByte(Enum:GEnumType):GSetType;

  class procedure Include(var ASet:GSetType;const AEnum:GEnumType);static;
  class procedure Exclude(var ASet:GSetType;const AEnum:GEnumType);static;
  class function IsAllPresent(const ASet:GSetType;const AEnum:GEnumType):boolean;static;
  class function IsOnePresent(const ASet:GSetType;const AEnum:GEnumType):boolean;static;
  private
  var
    Enums:TEnumType;
    Empty,Full:GSetType;
end;
GTSetWithGlobalEnums<GSetType,GEnumType>=object(GTSet<GSetType,GEnumType>)
  type
    TGlobalEnumType=GTSimpleHandles<GEnumType,GTHandleInvByteManipulator<GEnumType>>;
  class var GlobalEnums:TGlobalEnumType;
  class var GlobalEmpty,GlobalFull:GSetType;
  class constructor ObjectInit;
  class function GetGlobalEnum:GEnumType;static;
  function GetEnum:GEnumType;virtual;
  function GetEmpty:GSetType;virtual;
  function GetFull:GSetType;virtual;
end;
type
  TMySet=GTSet<Longword,Longword>;
var
  //ts:TMySet;
  t:Longword;
  e1,e2,e3:TMySet.TEnumItemType;
implementation
class function GTSetWithGlobalEnums<GSetType,GEnumType>.GetGlobalEnum:GEnumType;
begin
  Result:=GlobalEnums.getHandle;
  GlobalFull:=GlobalFull or Result;// GetByte(Result)
  t:=GlobalFull;
end;
function GTSetWithGlobalEnums<GSetType,GEnumType>.GetEnum:GEnumType;
begin
  result:=inherited;
  if ((Full)and(GlobalFull))<>0 then
    Raise Exception.CreateFmt('GTSetWithGlobalEnums<GSetType,GEnumType>.GetHandle overflow',[]);
end;
function GTSetWithGlobalEnums<GSetType,GEnumType>.GetEmpty:GSetType;
begin
  result:=Empty or GlobalEmpty;
end;

function GTSetWithGlobalEnums<GSetType,GEnumType>.GetFull:GSetType;
begin
  result:=Full or GlobalFull;
end;


class constructor GTSetWithGlobalEnums<GSetType,GEnumType>.ObjectInit;
begin
  inherited;
  GlobalEnums.init;
  GlobalEmpty:=0;
  GlobalFull:=0;
end;

constructor GTSet<GSetType,GEnumType>.init;
begin
  Enums.init;
  Empty:=0;
  Full:=0;
end;
function GTSet<GSetType,GEnumType>.GetEnum:GEnumType;
begin
  Result:=Enums.getHandle;
  Full:=Full or Result;// GetByte(Result)
end;
function GTSet<GSetType,GEnumType>.GetEmpty:GSetType;
begin
  result:=Empty;
end;

function GTSet<GSetType,GEnumType>.GetFull:GSetType;
begin
  result:=Full;
end;
class procedure GTSet<GSetType,GEnumType>.Include(var ASet:GSetType;const AEnum:GEnumType);
begin
  ASet:=ASet or AEnum;
end;
class procedure GTSet<GSetType,GEnumType>.Exclude(var ASet:GSetType;const AEnum:GEnumType);
begin
  ASet:=ASet and (not AEnum);
end;
class function GTSet<GSetType,GEnumType>.IsAllPresent(const ASet:GSetType;const AEnum:GEnumType):boolean;
begin
  Result:=(ASet and AEnum)=AEnum;
end;
class function GTSet<GSetType,GEnumType>.IsOnePresent(const ASet:GSetType;const AEnum:GEnumType):boolean;
begin
  Result:=(ASet and AEnum)<>0;
end;
{function GTSet<GSetType,GEnumType>.GetByte(Enum:GEnumType):GSetType;
begin
  result:=1 shl (enum-1);
end;}

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
function GTSimpleHandles<GHandleType,GHandleManipulator>.GetHandle:GHandleType;
begin
  GHandleManipulator.NextValue(Seed);
  if seed=0 then
    Raise Exception.CreateFmt('GTSimpleHandles<GHandleType,GHandleManipulator>.GetHandle overflow',[]);
  result:=Seed;
end;
procedure GTSimpleHandles<GHandleType,GHandleManipulator>.SetSeed(const Value:GHandleType);
begin
  Seed:=Value;
end;


begin
  {ts.init;
  e1:=ts.GetEnum;//1
  e2:=ts.GetEnum;//2
  e3:=ts.GetEnum;//4
  e1:=ts.GetEnum;//8
  e2:=ts.GetEnum;//16
  e3:=ts.GetEnum;//32
  e1:=ts.GetEnum;//64
  e2:=ts.GetEnum;//128
  e3:=ts.GetEnum;//256}
end.
