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
{$MODE OBJFPC}{$H+}
unit zebaseundocommands;
interface
uses uzsbVarmanDef,sysutils,gzctnrVectorTypes;
type
  TTypeCommand=(TTC_MBegin,
                TTC_MEnd,
                TTC_MNotUndableIfOverlay,
                TTC_Command//,
                {TTC_ChangeCommand});
  TUCmdBase=class
      function GetCommandType:TTypeCommand;virtual;
      procedure UnDo;virtual;abstract;
      procedure Comit;virtual;abstract;
      destructor Destroy;override;
  end;
  TUCmdMarker=class(TUCmdBase)
      Name:String;
      PrevIndex:TArrayIndex;
      constructor Create(_name:String;_index:TArrayIndex);
      function GetCommandType:TTypeCommand;override;
      procedure UnDo;override;
      procedure Comit;override;
  end;
  TTypedChangeCommand=class(TUCmdBase)
    public
      Addr:Pointer;
      OldData,NewData:Pointer;
      PTypeManager:PUserTypeDescriptor;
      PDataOwner:{PGDBObjEntity}pointer;//PEntity
      constructor Create(PDataInstance:Pointer;PType:PUserTypeDescriptor);
      procedure UnDo;override;
      procedure Comit;override;
      procedure ComitFromObj;virtual;
      function GetDataTypeSize:PtrInt;virtual;
      destructor Destroy;override;
  end;
TUndableMethod=procedure of object;
TOnUndoRedoDataOwner=procedure(PDataOwner:Pointer) of object;
var
  onUndoRedoDataOwner:TOnUndoRedoDataOwner;
implementation
constructor TTypedChangeCommand.Create(PDataInstance:Pointer;PType:PUserTypeDescriptor);
begin
  Addr:=PDataInstance;
  PTypeManager:=PType;
  OldData:=PTypeManager^.AllocAndInitInstance;
  NewData:=PTypeManager^.AllocAndInitInstance;
  PTypeManager^.CopyValueToInstance(Addr,OldData);
  PTypeManager^.CopyValueToInstance(Addr,NewData);
  PDataOwner:=nil;
end;
procedure TTypedChangeCommand.UnDo;
begin
  PTypeManager^.MagicFreeInstance(Addr);
  PTypeManager^.CopyValueToInstance(OldData,Addr);
  if assigned(onUndoRedoDataOwner)then
    onUndoRedoDataOwner(PDataOwner);
end;
procedure TTypedChangeCommand.Comit;
begin
  PTypeManager^.MagicFreeInstance(Addr);
  PTypeManager^.CopyValueToInstance(NewData,Addr);
  if assigned(onUndoRedoDataOwner)then
    onUndoRedoDataOwner(PDataOwner);
end;
procedure TTypedChangeCommand.ComitFromObj;
begin
  PTypeManager^.MagicFreeInstance(NewData);
  PTypeManager^.CopyValueToInstance(Addr,NewData);
end;
function TTypedChangeCommand.GetDataTypeSize:PtrInt;
begin
  result:=PTypeManager^.SizeInBytes;
end;
destructor TTypedChangeCommand.Destroy;
begin
  inherited;
  PTypeManager^.MagicFreeInstance(NewData);
  PTypeManager^.MagicFreeInstance(OldData);
  Freemem(NewData);
  Freemem(OldData);
end;
function TUCmdBase.GetCommandType:TTypeCommand;
begin
  result:=TTC_Command;
end;
destructor TUCmdBase.Destroy;
begin
end;

function TUCmdMarker.GetCommandType:TTypeCommand;
begin
  case PrevIndex of
    -1:result:=TTC_MBegin;
    -2:result:=TTC_MNotUndableIfOverlay;
    else
      result:=TTC_MEnd
  end;
end;
procedure TUCmdMarker.UnDo;
begin
end;

procedure TUCmdMarker.Comit;
begin
end;

constructor TUCmdMarker.Create(_name:String;_index:TArrayIndex);
begin
  name:=_name;
  PrevIndex:=_index;
end;

begin
  onUndoRedoDataOwner:=nil;
end.

