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

unit UGDBOpenArrayOfUCommands;
{$INCLUDE def.inc}
interface
uses log,gdbasetypes{,math},UGDBOpenArrayOfPObjects{,UGDBOpenArray, oglwindowdef},sysutils,
     gdbase, geometry, {OGLtypes, oglfunc,} {varmandef,gdbobjectsconstdef,}memman,GDBSubordinated;
const BeginUndo:GDBString='BeginUndo';
      EndUndo:GDBString='EndUndo';
type
{Export+}
TTypeCommand=(TTC_MBegin,TTC_MEnd,TTC_Command,TTC_ChangeCommand);
PTElementaryCommand=^TElementaryCommand;
TElementaryCommand=object(GDBaseObject)
                         function GetCommandType:TTypeCommand;virtual;
                         procedure undo;virtual;abstract;
                         destructor Done;virtual;
                   end;
PTMarkerCommand=^TMarkerCommand;
TMarkerCommand=object(TElementaryCommand)
                     Name:GDBstring;
                     PrevIndex:TArrayIndex;
                     constructor init(_name:GDBString;_index:TArrayIndex);
                     function GetCommandType:TTypeCommand;virtual;
               end;
PTChangeCommand=^TChangeCommand;
TChangeCommand=object(TElementaryCommand)
                     obj:GDBPointer;
                     fieldoffset,fieldsize:PtrInt;
                     tempdata:GDBPointer;
                     constructor init(_obj:GDBPointer;_fieldoffset,_fieldsize:PtrInt);
                     function GetCommandType:TTypeCommand;virtual;
                     procedure undo;virtual;
               end;
PGDBObjOpenArrayOfUCommands=^GDBObjOpenArrayOfUCommands;
GDBObjOpenArrayOfUCommands=object(GDBOpenArrayOfPObjects)
                                 currentcommandstartmarker:TArrayIndex;
                                 startmarkercount:GDBInteger;
                                 procedure PushStartMarker(CommandName:GDBString);
                                 procedure PushEndMarker;
                                 procedure PushChangeCommand(_obj:GDBPointer;_fieldoffset,_fieldsize:PtrInt);
                                 procedure undo;
                                 constructor init;
                                 //procedure PushStartMarker(CommandName:GDBString);
                           end;
{Export-}
implementation
uses {UGDBDescriptor,}GDBManager,GDBEntity;
function TElementaryCommand.GetCommandType:TTypeCommand;
begin
     result:=TTC_Command;
end;
destructor TElementaryCommand.Done;
begin
end;

constructor TChangeCommand.init(_obj:GDBPointer;_fieldoffset,_fieldsize:PtrInt);
begin
     obj:=_obj;
     fieldoffset:=_fieldoffset;
     fieldsize:=_fieldsize;
     GDBGetMem(pointer(tempdata),fieldsize);
     Move(pointer(ptrint(obj)+fieldoffset)^,tempdata^,fieldsize);
end;

function TChangeCommand.GetCommandType:TTypeCommand;
begin
     result:=TTC_ChangeCommand;
end;
procedure TChangeCommand.undo;
begin
     Move(tempdata^,pointer(ptrint(obj)+fieldoffset)^,fieldsize);
end;

function TMarkerCommand.GetCommandType:TTypeCommand;
begin
     if PrevIndex<>-1 then
                          result:=TTC_MEnd
                      else
                          result:=TTC_MBegin;
end;

constructor TMarkerCommand.init(_name:GDBString;_index:TArrayIndex);
begin
     name:=_name;
     PrevIndex:=_index;
end;

procedure GDBObjOpenArrayOfUCommands.PushStartMarker(CommandName:GDBString);
var
   pmarker:PTMarkerCommand;
begin
     inc(startmarkercount);
     if startmarkercount=1 then
     begin
     GDBGetMem(pointer(pmarker),sizeof(TMarkerCommand));
     pmarker.init(CommandName,-1);
     currentcommandstartmarker:=self.Add(@pmarker);
     end;
end;

procedure GDBObjOpenArrayOfUCommands.PushEndMarker;
var
   pmarker:PTMarkerCommand;
begin
     dec(startmarkercount);
     if startmarkercount=0 then
     begin
     GDBGetMem(pointer(pmarker),sizeof(TMarkerCommand));
     pmarker.init('EndMarker',currentcommandstartmarker);
     currentcommandstartmarker:=-1;
     startmarkercount:=0;
     end;
end;
procedure GDBObjOpenArrayOfUCommands.PushChangeCommand(_obj:GDBPointer;_fieldoffset,_fieldsize:PtrInt);
var
   pcc:PTChangeCommand;
begin
     if count>0 then
     begin
          pcc:=pointer(self.GetObject(count-1));
          if pcc^.GetCommandType=TTC_ChangeCommand then
          if (pcc^.obj=_obj)
          and(pcc^.fieldoffset=_fieldoffset)
          and(pcc^.fieldsize=_fieldsize) then
                                             exit;
     end;
     GDBGetMem(pointer(pcc),sizeof(TChangeCommand));
     pcc^.init(_obj,_fieldoffset,_fieldsize);
     add(@pcc);
end;
procedure GDBObjOpenArrayOfUCommands.undo;
var
   pcc:PTChangeCommand;
begin
     if count>0 then
     begin
          pcc:=pointer(self.GetObject(count-1));
          pcc^.undo;
          //pcc^.done;
          dec(count);
     end;
end;

constructor GDBObjOpenArrayOfUCommands.init;
begin
     inherited init({$IFDEF DEBUGBUILD}'{EF79AD53-2ECF-4848-8EDA-C498803A4188}',{$ENDIF}1000);
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('UGDBOpenArrayOfUCommands.initialization');{$ENDIF}
end.
