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
{$MODE OBJFPC}
unit zebaseundocommands;
{$INCLUDE def.inc}
interface
uses usimplegenerics,gdbdrawcontext,varmandef,zcadinterface,UGDBLayerArray,GDBEntity,shared,log,gdbasetypes,sysutils,
     gdbase, geometry,memman;
type
TUndoCommandHandle=Integer;
TUndoCommandData=record
                  CreateCommandFunc:pointer;
                  PushCreateCommandFunc:pointer;
                 end;
TUndoCommandHandle2UndoCommandDataMap=specialize GKey2DataMap<TUndoCommandHandle,TUndoCommandData,LessInteger>;
TTypeCommand=(TTC_MBegin,TTC_MEnd,TTC_MNotUndableIfOverlay,TTC_Command,TTC_ChangeCommand);
PTElementaryCommand=^TElementaryCommand;
TElementaryCommand=object(GDBaseObject)
                         AutoProcessGDB:GDBBoolean;
                         AfterAction:GDBBoolean;
                         function GetCommandType:TTypeCommand;virtual;
                         procedure UnDo;virtual;abstract;
                         procedure Comit;virtual;abstract;
                         destructor Done;virtual;
                   end;
PTMarkerCommand=^TMarkerCommand;
TMarkerCommand=object(TElementaryCommand)
                     Name:GDBstring;
                     PrevIndex:TArrayIndex;
                     constructor init(_name:GDBString;_index:TArrayIndex);
                     function GetCommandType:TTypeCommand;virtual;
                     procedure UnDo;virtual;
                     procedure Comit;virtual;
               end;
PTCustomChangeCommand=^TCustomChangeCommand;
TCustomChangeCommand=object(TElementaryCommand)
                           Addr:GDBPointer;
                           function GetCommandType:TTypeCommand;virtual;
                     end;
PTChangeCommand=^TChangeCommand;
TChangeCommand=object(TCustomChangeCommand)
                     datasize:PtrInt;
                     tempdata:GDBPointer;
                     constructor init(obj:GDBPointer;_datasize:PtrInt);
                     procedure undo;virtual;
                     function GetDataTypeSize:PtrInt;virtual;

               end;
PTTypedChangeCommand=^TTypedChangeCommand;
TTypedChangeCommand=object(TCustomChangeCommand)
                                      public
                                      OldData,NewData:GDBPointer;
                                      PTypeManager:PUserTypeDescriptor;
                                      PEntity:PGDBObjEntity;
                                      constructor Assign(PDataInstance:GDBPointer;PType:PUserTypeDescriptor);
                                      procedure UnDo;virtual;
                                      procedure Comit;virtual;
                                      procedure ComitFromObj;virtual;
                                      function GetDataTypeSize:PtrInt;virtual;
                                      destructor Done;virtual;
                                end;
TUndableMethod=procedure of object;
implementation
uses UGDBDescriptor,GDBManager;
constructor TTypedChangeCommand.Assign(PDataInstance:GDBPointer;PType:PUserTypeDescriptor);
begin
     Addr:=PDataInstance;
     PTypeManager:=PType;
     GDBGetMem({$IFDEF DEBUGBUILD}'{49289E94-F423-4497-B0B2-32215E6D5D40}',{$ENDIF}OldData,PTypeManager^.SizeInGDBBytes);
     GDBGetMem({$IFDEF DEBUGBUILD}'{49289E94-F423-4497-B0B2-32215E6D5D40}',{$ENDIF}NewData,PTypeManager^.SizeInGDBBytes);
     PTypeManager^.CopyInstanceTo(Addr,OldData);
     PTypeManager^.CopyInstanceTo(Addr,NewData);
     PEntity:=nil;
end;
procedure TTypedChangeCommand.UnDo;
var
  DC:TDrawContext;
begin
     PTypeManager^.MagicFreeInstance(Addr);
     PTypeManager^.CopyInstanceTo(OldData,Addr);
     if assigned(PEntity)then
                             begin
                                  //PEntity^.YouChanged(gdb.GetCurrentDWG^);
                                  if PEntity^.bp.ListPos.Owner=gdb.GetCurrentDWG^.GetCurrentRootSimple
                                  then
                                      PEntity^.YouChanged(gdb.GetCurrentDWG^)
                                  else
                                      begin
                                           dc:=gdb.GetCurrentDWG^.CreateDrawingRC;
                                           PEntity^.FormatEntity(gdb.GetCurrentDWG^,dc);
                                           gdb.GetCurrentDWG^.GetCurrentROOT^.FormatAfterEdit(gdb.GetCurrentDWG^,dc);
                                      end;
                             end;
     if assigned(SetVisuaProplProc)then
                                       SetVisuaProplProc;
end;
procedure TTypedChangeCommand.Comit;
var
  DC:TDrawContext;
begin
     PTypeManager^.MagicFreeInstance(Addr);
     PTypeManager^.CopyInstanceTo(NewData,Addr);
     if assigned(PEntity)then
                             begin
                                  //PEntity^.YouChanged(gdb.GetCurrentDWG^);
                                  if PEntity^.bp.ListPos.Owner=gdb.GetCurrentDWG^.GetCurrentRootSimple
                                  then
                                      PEntity^.YouChanged(gdb.GetCurrentDWG^)
                                  else
                                      begin
                                           dc:=gdb.GetCurrentDWG^.CreateDrawingRC;
                                           PEntity^.FormatEntity(gdb.GetCurrentDWG^,dc);
                                           gdb.GetCurrentDWG^.GetCurrentROOT^.FormatAfterEdit(gdb.GetCurrentDWG^,dc);
                                      end;
                             end;
     if assigned(SetVisuaProplProc)then
                                       SetVisuaProplProc;
end;
procedure TTypedChangeCommand.ComitFromObj;
begin
     PTypeManager^.MagicFreeInstance(NewData);
     PTypeManager^.CopyInstanceTo(Addr,NewData);
end;
function TTypedChangeCommand.GetDataTypeSize:PtrInt;
begin
     result:=PTypeManager^.SizeInGDBBytes;
end;
destructor TTypedChangeCommand.Done;
begin
     inherited;
     PTypeManager^.MagicFreeInstance(NewData);
     PTypeManager^.MagicFreeInstance(OldData);
     GDBFreeMem(NewData);
     GDBFreeMem(OldData);
end;
function TElementaryCommand.GetCommandType:TTypeCommand;
begin
     result:=TTC_Command;
end;
destructor TElementaryCommand.Done;
begin
end;

constructor TChangeCommand.init(obj:GDBPointer;_datasize:PtrInt);
begin
     Addr:=obj;
     datasize:=_datasize;
     GDBGetMem({$IFDEF DEBUGBUILD}'{E438B065-CE41-4BB2-B1C9-1DC526190A85}',{$ENDIF}pointer(tempdata),datasize);
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
var
  DC:TDrawContext;
begin
     dc:=gdb.GetCurrentDWG^.CreateDrawingRC;
     gdb.GetCurrentROOT^.FormatAfterEdit(gdb.GetCurrentDWG^,dc);
end;

procedure TMarkerCommand.Comit;
var
  DC:TDrawContext;
begin
     dc:=gdb.GetCurrentDWG^.CreateDrawingRC;
     gdb.GetCurrentROOT^.FormatAfterEdit(gdb.GetCurrentDWG^,dc);
end;

constructor TMarkerCommand.init(_name:GDBString;_index:TArrayIndex);
begin
     name:=_name;
     PrevIndex:=_index;
end;

begin
  {$IFDEF DEBUGINITSECTION}LogOut('UGDBOpenArrayOfUCommands.initialization');{$ENDIF}
end.

