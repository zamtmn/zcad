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
unit uzbNamedHandlesWithData;
{$mode delphi}


interface

uses
  sysutils,Generics.Collections,GVector,
  uzbhandles,uzbnamedhandles;

type

  GTLinearIncHandleManipulator<GHandleType>=class(GTHandleManipulator<GHandleType>)
    class function GetIndex(Handle:GHandleType):SizeInt;inline;static;
  end;

 GTNamedHandlesWithData<GHandleType,GHandleManipulator,GNameType,GNameManipulator,GLincedData>=object(GTNamedHandles<GHandleType,GHandleManipulator,GNameType,GNameManipulator>)
   type
     PGLincedData=^GLincedData;
     THandleData=record
      N:GNameType;
      D:GLincedData;
     end;
     THandleDataVector=TVector<THandleData>;
   var
     HandleDataVector:THandleDataVector;
   constructor init;
   function CreateHandle:GHandleType;virtual;
   function CreateHandleWithData(N:GNameType;LD:GLincedData):GHandleType;virtual;
   destructor Done;virtual;
   procedure RegisterHandleName(Handle:GHandleType;HandleName:GNameType);virtual;
   function GetPLincedData(Handle:GHandleType):PGLincedData;
   function GetDataIndex(Handle:GHandleType):SizeInt;
   function GetHandleName(Handle:GHandleType):GNameType;
   function CreateOrGetHandleAndSetData(HandleName:GNameType;data:GLincedData):GHandleType;
 end;

implementation

class function GTLinearIncHandleManipulator<GHandleType>.GetIndex(Handle:GHandleType):SizeInt;
begin
  result:=Handle-1;
end;

constructor GTNamedHandlesWithData<GHandleType,GHandleManipulator,GNameType,GNameManipulator,GLincedData>.init;
begin
  inherited;
  HandleDataVector:=nil;
end;

function GTNamedHandlesWithData<GHandleType,GHandleManipulator,GNameType,GNameManipulator,GLincedData>.CreateHandle:GHandleType;
var
  HD:THandleData;
begin
  result:=inherited;
  if not assigned(HandleDataVector)then
    HandleDataVector:=THandleDataVector.create;
  HD:=Default(THandleData);
  HandleDataVector.PushBack(HD);
end;

function GTNamedHandlesWithData<GHandleType,GHandleManipulator,GNameType,GNameManipulator,GLincedData>.CreateHandleWithData(N:GNameType;LD:GLincedData):GHandleType;
var
  HD:THandleData;
begin
  result:=inherited CreateHandle;
  if not assigned(HandleDataVector)then
    HandleDataVector:=THandleDataVector.create;
  HD.N:=N;
  HD.D:=LD;
  HandleDataVector.PushBack(HD);
end;

destructor GTNamedHandlesWithData<GHandleType,GHandleManipulator,GNameType,GNameManipulator,GLincedData>.done;
begin
  inherited;
  if assigned(HandleNameRegister)then
    FreeAndNil(HandleNameRegister);
  if assigned(HandleDataVector)then
    FreeAndNil(HandleDataVector);
end;

procedure GTNamedHandlesWithData<GHandleType,GHandleManipulator,GNameType,GNameManipulator,GLincedData>.RegisterHandleName(Handle:GHandleType;HandleName:GNameType);
begin
  inherited RegisterHandleName(Handle,HandleName);
  HandleDataVector.Mutable[GHandleManipulator.GetIndex(Handle)]^.N:=HandleName;
end;
function GTNamedHandlesWithData<GHandleType,GHandleManipulator,GNameType,GNameManipulator,GLincedData>.GetPLincedData(Handle:GHandleType):PGLincedData;
begin
  result:=@HandleDataVector.Mutable[GHandleManipulator.GetIndex(Handle)]^.D;
end;
function GTNamedHandlesWithData<GHandleType,GHandleManipulator,GNameType,GNameManipulator,GLincedData>.GetDataIndex(Handle:GHandleType):SizeInt;
begin
  result:=GHandleManipulator.GetIndex(Handle);
end;
function GTNamedHandlesWithData<GHandleType,GHandleManipulator,GNameType,GNameManipulator,GLincedData>.GetHandleName(Handle:GHandleType):GNameType;
begin
  result:=HandleDataVector.Mutable[GHandleManipulator.GetIndex(Handle)]^.N;
end;
function GTNamedHandlesWithData<GHandleType,GHandleManipulator,GNameType,GNameManipulator,GLincedData>.CreateOrGetHandleAndSetData(HandleName:GNameType;data:GLincedData):GHandleType;
begin
  result:=CreateOrGetHandle(HandleName);
  HandleDataVector.Mutable[GHandleManipulator.GetIndex(result)]^.D:=data;
end;
begin
end.

