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
uses varmandef,sysutils,gzctnrVectorTypes;
type
TTypeCommand=(TTC_MBegin,TTC_MEnd,TTC_MNotUndableIfOverlay,TTC_Command,TTC_ChangeCommand);
//PTElementaryCommand=^TElementaryCommand;
TElementaryCommand=class
                         AutoProcessGDB:Boolean;
                         AfterAction:Boolean;
                         function GetCommandType:TTypeCommand;virtual;
                         procedure UnDo;virtual;abstract;
                         procedure Comit;virtual;abstract;
                         destructor Destroy;override;
                   end;
//PTMarkerCommand=^TMarkerCommand;
TMarkerCommand=class(TElementaryCommand)
                     Name:String;
                     PrevIndex:TArrayIndex;
                     constructor Create(_name:String;_index:TArrayIndex);
                     function GetCommandType:TTypeCommand;override;
                     procedure UnDo;override;
                     procedure Comit;override;
               end;
//PTCustomChangeCommand=^TCustomChangeCommand;
TCustomChangeCommand=class(TElementaryCommand)
                           Addr:Pointer;
                           function GetCommandType:TTypeCommand;override;
                     end;
//PTChangeCommand=^TChangeCommand;
TChangeCommand=class(TCustomChangeCommand)
                     datasize:PtrInt;
                     tempdata:Pointer;
                     constructor Create(obj:Pointer;_datasize:PtrInt);
                     procedure undo;override;
                     function GetDataTypeSize:PtrInt;virtual;

               end;
//PTTypedChangeCommand=^TTypedChangeCommand;
TTypedChangeCommand=class(TCustomChangeCommand)
                                      public
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
     PTypeManager^.CopyInstanceTo(Addr,OldData);
     PTypeManager^.CopyInstanceTo(Addr,NewData);
     PDataOwner:=nil;
end;
procedure TTypedChangeCommand.UnDo;
//var
//  DC:TDrawContext;
begin
     PTypeManager^.MagicFreeInstance(Addr);
     PTypeManager^.CopyInstanceTo(OldData,Addr);
     if assigned(onUndoRedoDataOwner)then
                                         onUndoRedoDataOwner(PDataOwner);
     {if assigned(PDataOwner)then
                             begin
                                  //PDataOwner^.YouChanged(gdb.GetCurrentDWG^);
                                  if PDataOwner^.bp.ListPos.Owner=gdb.GetCurrentDWG^.GetCurrentRootSimple
                                  then
                                      PDataOwner^.YouChanged(gdb.GetCurrentDWG^)
                                  else
                                      begin
                                           dc:=gdb.GetCurrentDWG^.CreateDrawingRC;
                                           PDataOwner^.FormatEntity(gdb.GetCurrentDWG^,dc);
                                           gdb.GetCurrentDWG^.GetCurrentROOT^.FormatAfterEdit(gdb.GetCurrentDWG^,dc);
                                      end;
                             end;
     if assigned(SetVisuaProplProc)then
                                       SetVisuaProplProc;}
end;
procedure TTypedChangeCommand.Comit;
//var
//  DC:TDrawContext;
begin
     PTypeManager^.MagicFreeInstance(Addr);
     PTypeManager^.CopyInstanceTo(NewData,Addr);
     if assigned(onUndoRedoDataOwner)then
                                    onUndoRedoDataOwner(PDataOwner);
     {if assigned(PDataOwner)then
                             begin
                                  //PDataOwner^.YouChanged(gdb.GetCurrentDWG^);
                                  if PDataOwner^.bp.ListPos.Owner=gdb.GetCurrentDWG^.GetCurrentRootSimple
                                  then
                                      PDataOwner^.YouChanged(gdb.GetCurrentDWG^)
                                  else
                                      begin
                                           dc:=gdb.GetCurrentDWG^.CreateDrawingRC;
                                           PDataOwner^.FormatEntity(gdb.GetCurrentDWG^,dc);
                                           gdb.GetCurrentDWG^.GetCurrentROOT^.FormatAfterEdit(gdb.GetCurrentDWG^,dc);
                                      end;
                             end;
     if assigned(SetVisuaProplProc)then
                                       SetVisuaProplProc;}
end;
procedure TTypedChangeCommand.ComitFromObj;
begin
     PTypeManager^.MagicFreeInstance(NewData);
     PTypeManager^.CopyInstanceTo(Addr,NewData);
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
function TElementaryCommand.GetCommandType:TTypeCommand;
begin
     result:=TTC_Command;
end;
destructor TElementaryCommand.Destroy;
begin
end;

constructor TChangeCommand.Create(obj:Pointer;_datasize:PtrInt);
begin
     Addr:=obj;
     datasize:=_datasize;
     Getmem(pointer(tempdata),datasize);
     Move(Addr^,tempdata^,datasize);
end;

function TCustomChangeCommand.GetCommandType:TTypeCommand;
begin
     result:=TTC_ChangeCommand;
end;
procedure TChangeCommand.undo;
begin
     Move(tempdata^,Addr^,datasize);
end;
function TChangeCommand.GetDataTypeSize:PtrInt;
begin
     result:=self.datasize;
end;

function TMarkerCommand.GetCommandType:TTypeCommand;
begin //TTC_MNotUndableIfOverlay
     case PrevIndex of
                      -1:result:=TTC_MBegin;
                      -2:result:=TTC_MNotUndableIfOverlay;
                    else
                       result:=TTC_MEnd
     end;
    { if PrevIndex<>-1 then
                          result:=TTC_MEnd
                      else
                          result:=TTC_MBegin;}
end;
procedure TMarkerCommand.UnDo;
//var
//  DC:TDrawContext;
begin
//     dc:=gdb.GetCurrentDWG^.CreateDrawingRC;
//     gdb.GetCurrentROOT^.FormatAfterEdit(gdb.GetCurrentDWG^,dc);
end;

procedure TMarkerCommand.Comit;
//var
//  DC:TDrawContext;
begin
//     dc:=gdb.GetCurrentDWG^.CreateDrawingRC;
//     gdb.GetCurrentROOT^.FormatAfterEdit(gdb.GetCurrentDWG^,dc);
end;

constructor TMarkerCommand.Create(_name:String;_index:TArrayIndex);
begin
     name:=_name;
     PrevIndex:=_index;
end;

begin
  onUndoRedoDataOwner:=nil;
end.

