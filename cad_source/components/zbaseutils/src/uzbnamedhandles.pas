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
unit uzbNamedHandles;
{$mode delphi}

interface

uses
  SysUtils,Generics.Collections,
  uzbHandles;

type

  GTStringNamesUPPERCASE<GNameType>=class
    class function Standartize(name:GNameType):GNameType;
  end;
  GTStringNamesCaseSensetive<GNameType>=class
    class function Standartize(name:GNameType):GNameType;
  end;


 GTNamedHandles<GHandleType,GHandleManipulator,GNameType,GNameManipulator>=object(GTSimpleHandles<GHandleType,GHandleManipulator>)
   type
     TNameType=GNameType;
     THandleWithNamePair=record
       H:GHandleType;
       N:GNameType;
     end;
     THandleNameRegister=TDictionary<GNameType,THandleWithNamePair>;
   var
     HandleNameRegister:THandleNameRegister;
   constructor init;
   destructor done;virtual;
   procedure RegisterHandleName(Handle:GHandleType;HandleName:GNameType);virtual;
   function GetHandleByName(HandleName:GNameType):GHandleType;
   function CreateOrGetHandle(HandleName:GNameType):GHandleType;
   function TryGetHandle(HandleName:GNameType;out Handle:GHandleType):boolean;
   function StandartizeName(name:GNameType):GNameType;
end;

implementation

function GTNamedHandles<GHandleType,GHandleManipulator,GNameType,GNameManipulator>.GetHandleByName(HandleName:GNameType):GHandleType;
var
  StandartizedHandleName:GNameType;
  OldHN:THandleWithNamePair;
begin
  begin
    if not assigned(HandleNameRegister)then
      exit(GHandleManipulator.GetStartValue);
    StandartizedHandleName:=GNameManipulator.Standartize(HandleName);
    if HandleNameRegister.TryGetValue(StandartizedHandleName,OldHN) then
      exit(OldHN.H)
    else
      exit(GHandleManipulator.GetStartValue);
  end;
end;
function GTNamedHandles<GHandleType,GHandleManipulator,GNameType,GNameManipulator>.CreateOrGetHandle(HandleName:GNameType):GHandleType;
var
  StandartizedHandleName:GNameType;
begin
  StandartizedHandleName:=GNameManipulator.Standartize(HandleName);
  result:=GetHandleByName(StandartizedHandleName);
  if result=GHandleManipulator.GetStartValue then begin
    result:=CreateHandle;
    RegisterHandleName(result,StandartizedHandleName);
  end;
end;
function GTNamedHandles<GHandleType,GHandleManipulator,GNameType,GNameManipulator>.TryGetHandle(HandleName:GNameType;out Handle:GHandleType):boolean;
var
  StandartizedHandleName:GNameType;
begin
  StandartizedHandleName:=GNameManipulator.Standartize(HandleName);
  Handle:=GetHandleByName(StandartizedHandleName);
  if Handle=GHandleManipulator.GetStartValue then
    result:=false
  else
    result:=true;
end;
class function GTStringNamesUPPERCASE<GNameType>.Standartize(name:GNameType):GNameType;
begin
  result:=UpperCase(string{без string не компилится в 3.2}(name));
end;

class function GTStringNamesCaseSensetive<GNameType>.Standartize(name:GNameType):GNameType;
begin
  result:=name;
end;


constructor GTNamedHandles<GHandleType,GHandleManipulator,GNameType,GNameManipulator>.init;
begin
  HandleNameRegister:=nil;
end;

destructor GTNamedHandles<GHandleType,GHandleManipulator,GNameType,GNameManipulator>.done;
begin
  if assigned(HandleNameRegister)then
    FreeAndNil(HandleNameRegister);
end;

procedure GTNamedHandles<GHandleType,GHandleManipulator,GNameType,GNameManipulator>.RegisterHandleName(Handle:GHandleType;HandleName:GNameType);
var
  StandartizedHandleName:GNameType;
  OldHN:THandleWithNamePair;
begin
  if not assigned(HandleNameRegister)then
    HandleNameRegister:=THandleNameRegister.create;
  StandartizedHandleName:=GNameManipulator.Standartize(HandleName);
  if HandleNameRegister.TryGetValue(StandartizedHandleName,OldHN) then
    //error
  else begin
    OldHN.H:=Handle;
    OldHN.N:=HandleName;
    HandleNameRegister.add(StandartizedHandleName,OldHN);
  end;
end;

function GTNamedHandles<GHandleType,GHandleManipulator,GNameType,GNameManipulator>.StandartizeName(name:GNameType):GNameType;
begin
  Result:=GNameManipulator.Standartize(name);
end;

begin
end.

