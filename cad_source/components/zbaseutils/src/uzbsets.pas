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
unit uzbSets;
{$mode delphi}

interface

uses sysutils,uzbhandles;

type
GTSet<GSetType,GEnumType>=object
  type
    TSetType=GSetType;
    TEnumItemType=GEnumType;
    TEnumType=GTSimpleHandles<GEnumType,GTHandleBitManipulator<GEnumType>>;
  constructor init;
  destructor done;virtual;
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
    TGlobalEnumType=GTSimpleHandles<GEnumType,GTHandleInvBitManipulator<GEnumType>>;
  class var GlobalEnums:TGlobalEnumType;
  class var GlobalEmpty,GlobalFull:GSetType;
  class constructor ObjectInit;
  class function GetGlobalEnum:GEnumType;static;
  function GetEnum:GEnumType;virtual;
  function GetEmpty:GSetType;virtual;
  function GetFull:GSetType;virtual;
end;
type
  TMySet=GTSet<LongWord,LongWord>;

implementation
class function GTSetWithGlobalEnums<GSetType,GEnumType>.GetGlobalEnum:GEnumType;
begin
  Result:=GlobalEnums.CreateHandle;
  GlobalFull:=GlobalFull or Result;// GetByte(Result)
  //t:=GlobalFull;
end;
function GTSetWithGlobalEnums<GSetType,GEnumType>.GetEnum:GEnumType;
begin
  result:=inherited;
  if ((Full)and(GlobalFull))<>0 then
    Raise Exception.CreateFmt('GTSetWithGlobalEnums<GSetType,GEnumType>.CreateHandle overflow',[]);
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
destructor GTSet<GSetType,GEnumType>.done;
begin
  Enums.done;
end;

function GTSet<GSetType,GEnumType>.GetEnum:GEnumType;
begin
  Result:=Enums.CreateHandle;
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

begin
end.
