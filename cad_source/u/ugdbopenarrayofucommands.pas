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
uses shared,log,gdbasetypes{,math},UGDBOpenArrayOfPObjects{,UGDBOpenArray, oglwindowdef},sysutils,
     gdbase, geometry, {OGLtypes, oglfunc,} {varmandef,gdbobjectsconstdef,}memman,GDBSubordinated;
const BeginUndo:GDBString='BeginUndo';
      EndUndo:GDBString='EndUndo';
type
TTypeCommand=(TTC_MBegin,TTC_MEnd,TTC_Command,TTC_ChangeCommand);
PTElementaryCommand=^TElementaryCommand;
TElementaryCommand=object(GDBaseObject)
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
generic TGChangeCommand<_T>=object(TCustomChangeCommand)
                                      OldData,NewData:_T;
                                      constructor Assign(const data:_T);

                                      procedure UnDo;virtual;
                                      procedure Comit;virtual;
                                      procedure ComitFromObj;virtual;
                                      function GetDataTypeSize:PtrInt;virtual;
                                end;
{$MACRO ON}
{$DEFINE INTERFACE}
  {$I TGChangeCommandList.inc}
{$UNDEF INTERFACE}

{$DEFINE CLASSDECLARATION}
PGDBObjOpenArrayOfUCommands=^GDBObjOpenArrayOfUCommands;
GDBObjOpenArrayOfUCommands=object(GDBOpenArrayOfPObjects)
                                 CurrentCommand:TArrayIndex;
                                 currentcommandstartmarker:TArrayIndex;
                                 startmarkercount:GDBInteger;
                                 procedure PushStartMarker(CommandName:GDBString);
                                 procedure PushEndMarker;
                                 procedure PushChangeCommand(_obj:GDBPointer;_fieldsize:PtrInt);overload;
                                 procedure undo;
                                 procedure redo;
                                 constructor init;
                                 function Add(p:GDBPointer):TArrayIndex;virtual;

                                 {$I TGChangeCommandList.inc}
                           end;
{$UNDEF CLASSDECLARATION}
implementation
uses {UGDBDescriptor,}GDBManager,GDBEntity;
{$DEFINE IMPLEMENTATION}
  {$I TGChangeCommandList.inc}
{$UNDEF IMPLEMENTATION}
{$MACRO OFF}

constructor TGChangeCommand.Assign(const data:_T);
begin
     Addr:=@data;
     olddata:=data;
     newdata:=data;
end;
procedure TGChangeCommand.UnDo;
begin
     _T(addr^):=OldData;
end;
procedure TGChangeCommand.Comit;
begin
     _T(addr^):=NewData;
end;
procedure TGChangeCommand.ComitFromObj;
begin
     NewData:=_T(addr^);
end;
function TGChangeCommand.GetDataTypeSize:PtrInt;
begin
     result:=sizeof(_T);
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
     GDBGetMem(pointer(tempdata),datasize);
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
begin
     if PrevIndex<>-1 then
                          result:=TTC_MEnd
                      else
                          result:=TTC_MBegin;
end;
procedure TMarkerCommand.UnDo;
begin

end;

procedure TMarkerCommand.Comit;
begin

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
     inc(CurrentCommand);
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
     self.Add(@pmarker);
     inc(CurrentCommand);
     startmarkercount:=0;
     end;
end;
procedure GDBObjOpenArrayOfUCommands.PushChangeCommand(_obj:GDBPointer;_fieldsize:PtrInt);
var
   pcc:PTChangeCommand;
begin
     if CurrentCommand>0 then
     begin
          pcc:=pointer(self.GetObject(CurrentCommand-1));
          if pcc^.GetCommandType=TTC_ChangeCommand then
          if (pcc^.Addr=_obj)
          and(pcc^.datasize=_fieldsize) then
                                             exit;
     end;
     GDBGetMem(pointer(pcc),sizeof(TChangeCommand));
     pcc^.init(_obj,_fieldsize);
     inc(CurrentCommand);
     add(@pcc);
end;
procedure GDBObjOpenArrayOfUCommands.undo;
var
   pcc:PTChangeCommand;
   mcounter:integer;
begin
     if CurrentCommand>0 then
     begin
          mcounter:=0;
          repeat
          pcc:=pointer(self.GetObject(CurrentCommand-1));

          if pcc^.GetCommandType=TTC_MEnd then
                                              inc(mcounter)
     else if pcc^.GetCommandType=TTC_MBegin then
                                                begin
                                                     dec(mcounter);
                                                     if mcounter=0 then
                                                     shared.HistoryOutStr('Отмена "'+PTMarkerCommand(pcc)^.Name+'"');
                                                end
     else pcc^.undo;
          dec(CurrentCommand);
          until mcounter=0;
     end
     else
         shared.ShowError('Нет операций для отмены');

end;
procedure GDBObjOpenArrayOfUCommands.redo;
var
   pcc:PTChangeCommand;
begin
     if CurrentCommand<count then
     begin
          pcc:=pointer(self.GetObject(CurrentCommand));
          pcc^.Comit;
          //pcc^.done;
          inc(CurrentCommand);
     end
     else
         shared.ShowError('Нет операций для повторного применения');
end;

constructor GDBObjOpenArrayOfUCommands.init;
begin
     inherited init({$IFDEF DEBUGBUILD}'{EF79AD53-2ECF-4848-8EDA-C498803A4188}',{$ENDIF}1000);
     CurrentCommand:=0;
end;
function GDBObjOpenArrayOfUCommands.Add(p:GDBPointer):TArrayIndex;
begin
     if self.CurrentCommand<>count then
                                       self.cleareraseobjfrom2(self.CurrentCommand);
     result:=inherited;
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('UGDBOpenArrayOfUCommands.initialization');{$ENDIF}
end.
