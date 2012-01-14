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
unit UGDBOpenArrayOfUCommands;
{$INCLUDE def.inc}
interface
uses UGDBOpenArrayOfPV,GDBEntity,UGDBOpenArrayOfData,shared,log,gdbasetypes{,math},UGDBOpenArrayOfPObjects{,UGDBOpenArray, oglwindowdef},sysutils,
     gdbase, geometry, {OGLtypes, oglfunc,} {varmandef,gdbobjectsconstdef,}memman{,GDBSubordinated};
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
                                      public
                                      OldData,NewData:_T;
                                      constructor Assign(var data:_T);

                                      procedure UnDo;virtual;
                                      procedure Comit;virtual;
                                      procedure ComitFromObj;virtual;
                                      function GetDataTypeSize:PtrInt;virtual;
                                end;
TUndableMethod=procedure of object;
generic TGObjectChangeCommand<_T>=object(TCustomChangeCommand)
                                      {type
                                          TCangeMethod=procedure(data:_T)of object;}
                                      private
                                      DoData,UnDoData:_T;
                                      method:tmethod;
                                      public
                                      constructor Assign(var _dodata:_T;_method:tmethod);
                                      procedure StoreUndoData(var _undodata:_T);virtual;

                                      procedure UnDo;virtual;
                                      procedure Comit;virtual;
                                      //procedure ComitFromObj;virtual;
                                      //function GetDataTypeSize:PtrInt;virtual;
                                  end;
generic TGObjectChangeCommand2<_T>=object(TCustomChangeCommand)
                                      Data:_T;
                                      DoMethod,UnDoMethod:tmethod;
                                      constructor Assign(var _dodata:_T;_domethod,_undomethod:tmethod);

                                      procedure UnDo;virtual;
                                      procedure Comit;virtual;
                                  end;
generic TGMultiObjectChangeCommand<_T>=object(TCustomChangeCommand)
                                      DoData,UnDoData:_T;
                                      ObjArray:GDBOpenArrayOfData;
                                      public
                                      constructor Assign(const _dodata,_undodata:_T;const objcount:GDBInteger);
                                      //procedure StoreUndoData(var _undodata:_T);virtual;
                                      procedure AddMethod(method:tmethod);virtual;

                                      procedure UnDo;virtual;
                                      procedure Comit;virtual;
                                      destructor Done;virtual;
                                  end;
generic TGMultiObjectProcessCommand<_LT>=object(TCustomChangeCommand)
                                      DoData,UnDoData:tmethod;
                                      ObjArray:_LT;
                                      FreeArray:gdbboolean;
                                      public
                                      constructor Assign(const _dodata,_undodata:tmethod;const objcount:GDBInteger);
                                      //procedure StoreUndoData(var _undodata:_T);virtual;
                                      procedure AddObject(PObject:PGDBaseObject);virtual;

                                      procedure UnDo;virtual;
                                      procedure Comit;virtual;
                                      destructor Done;virtual;
                                  end;
{$MACRO ON}
{$DEFINE INTERFACE}
  {$I TGChangeCommandList.inc}
  {$I TGObjectChangeCommandList.inc}
  {$I TGObjectChangeCommand2List.inc}
  {$I TGMultiObjectChangeCommandList.inc}
  {$I TGMultiObjectCreateCommand.inc}
{$UNDEF INTERFACE}

{$DEFINE CLASSDECLARATION}
PGDBObjOpenArrayOfUCommands=^GDBObjOpenArrayOfUCommands;
GDBObjOpenArrayOfUCommands=object(GDBOpenArrayOfPObjects)
                                 {type
                                 TCangeMethod=procedure(data:integer)of object;}
                                 public
                                 CurrentCommand:TArrayIndex;
                                 currentcommandstartmarker:TArrayIndex;
                                 startmarkercount:GDBInteger;
                                 procedure PushStartMarker(CommandName:GDBString);
                                 procedure PushEndMarker;
                                 procedure PushChangeCommand(_obj:GDBPointer;_fieldsize:PtrInt);overload;
                                 procedure undo(prevheap:TArrayIndex;overlay:GDBBoolean);
                                 procedure redo;
                                 constructor init;
                                 function Add(p:GDBPointer):TArrayIndex;virtual;

                                 {$I TGChangeCommandList.inc}
                                 {$I TGObjectChangeCommandList.inc}
                                 {$I TGObjectChangeCommand2List.inc}
                                 {$I TGMultiObjectChangeCommandList.inc}
                                 {$I TGMultiObjectCreateCommand.inc}
                           end;
{$UNDEF CLASSDECLARATION}
implementation
uses UGDBDescriptor,GDBManager;
{$DEFINE IMPLEMENTATION}
  {$I TGChangeCommandList.inc}
  {$I TGObjectChangeCommandList.inc}
  {$I TGObjectChangeCommand2List.inc}
  {$I TGMultiObjectChangeCommandList.inc}
  {$I TGMultiObjectCreateCommand.inc}
{$UNDEF IMPLEMENTATION}
{$MACRO OFF}

constructor TGMultiObjectProcessCommand.Assign(const _dodata,_undodata:tmethod;const objcount:GDBInteger);
begin
     DoData:=_DoData;
     UnDoData:=_UnDoData;
     self.ObjArray.init({$IFDEF DEBUGBUILD}'{108FD060-E408-4161-9548-64EEAFC3BEB2}',{$ENDIF}objcount);
     FreeArray:={false}true;
end;
procedure TGMultiObjectProcessCommand.AddObject(PObject:PGDBaseObject);
var
   p:pointer;
begin
     p:=PObject;
     objarray.add(@P{Object});
end;
procedure TGMultiObjectProcessCommand.UnDo;
type
    TCangeMethod=procedure(const data:GDBASEOBJECT)of object;
    PTMethod=^TMethod;
var
  p:PGDBASEOBJECT;
  ir:itrec;
begin
  p:=ObjArray.beginiterate(ir);
  if p<>nil then
  repeat
        TCangeMethod(UnDoData)(p^);
       // if FreeArray then
       //                      PGDBObjEntity(p)^.YouChanged;
       p:=ObjArray.iterate(ir);
  until p=nil;
  FreeArray:=not FreeArray;
end;
procedure TGMultiObjectProcessCommand.Comit;
type
    TCangeMethod=procedure(const data:GDBASEOBJECT)of object;
    PTMethod=^TMethod;
var
  p:PGDBASEOBJECT;
  ir:itrec;
begin
  p:=ObjArray.beginiterate(ir);
  if p<>nil then
  repeat
        TCangeMethod(DoData)(p^);
        //if FreeArray then
        //                     PGDBObjEntity(p)^.YouChanged;
       p:=ObjArray.iterate(ir);
  until p=nil;
  FreeArray:=not FreeArray;
end;
destructor TGMultiObjectProcessCommand.Done;
begin
     inherited;
     if {not} FreeArray then
                          ObjArray.freeanddone;
end;

constructor TGMultiObjectChangeCommand.Assign(const _dodata,_undodata:_T;const objcount:GDBInteger);
begin
     DoData:=_DoData;
     UnDoData:=_UnDoData;
     self.ObjArray.init({$IFDEF DEBUGBUILD}'{108FD060-E408-4161-9548-64EEAFC3BEB2}',{$ENDIF}objcount,sizeof(tmethod));
end;
procedure TGMultiObjectChangeCommand.AddMethod(method:tmethod);
begin
     objarray.add(@method);
end;
{procedure TGMultiObjectChangeCommand.StoreUndoData(var _undodata:_T);
begin
     UnDoData:=_undodata;
end;}
procedure TGMultiObjectChangeCommand.UnDo;
type
    TCangeMethod=procedure(const data:_T)of object;
    PTMethod=^TMethod;
var
  p:PTMethod;
  ir:itrec;
begin
  p:=ObjArray.beginiterate(ir);
  if p<>nil then
  repeat
        TCangeMethod(p^)(UnDoData);
        PGDBObjEntity(p^.Data)^.YouChanged;
        //PGDBObjSubordinated(p^.Data)^.bp.owner^.ImEdited(PGDBObjSubordinated(p^.Data),PGDBObjSubordinated(p^.Data)^.bp.PSelfInOwnerArray);

       p:=ObjArray.iterate(ir);
  until p=nil;
end;
procedure TGMultiObjectChangeCommand.Comit;
type
    TCangeMethod=procedure(const data:_T)of object;
    PTMethod=^TMethod;
var
  p:PTMethod;
  ir:itrec;
begin
  p:=ObjArray.beginiterate(ir);
  if p<>nil then
  repeat
        TCangeMethod(p^)(DoData);
        PGDBObjEntity(p^.Data)^.YouChanged;
        //PGDBObjSubordinated(p^.Data)^.bp.owner^.ImEdited(PGDBObjSubordinated(p^.Data),PGDBObjSubordinated(p^.Data)^.bp.PSelfInOwnerArray);

       p:=ObjArray.iterate(ir);
  until p=nil;
end;

destructor TGMultiObjectChangeCommand.Done;
begin
     inherited;
     ObjArray.done;
end;


constructor TGObjectChangeCommand.Assign(var _dodata:_T;_method:tmethod);
begin
     DoData:=_DoData;
     method:=_method;
end;
procedure TGObjectChangeCommand.StoreUndoData(var _undodata:_T);
begin
     UnDoData:=_undodata;
end;
procedure TGObjectChangeCommand.UnDo;
type
    TCangeMethod=procedure(const data:_T)of object;
begin
     TCangeMethod(method)(UnDoData);
     PGDBObjEntity(method.Data)^.YouChanged;
     //PGDBObjSubordinated(method.Data)^.bp.owner^.ImEdited(PGDBObjSubordinated(method.Data),PGDBObjSubordinated(method.Data)^.bp.PSelfInOwnerArray);
end;
procedure TGObjectChangeCommand.Comit;
type
    TCangeMethod=procedure(const data:_T)of object;
begin
     TCangeMethod(method)(DoData);
     PGDBObjEntity(method.Data)^.YouChanged;
     //PGDBObjSubordinated(method.Data)^.bp.owner^.ImEdited(PGDBObjSubordinated(method.Data),PGDBObjSubordinated(method.Data)^.bp.PSelfInOwnerArray);
end;
constructor TGObjectChangeCommand2.Assign(var _dodata:_T;_domethod,_undomethod:tmethod);
begin
  Data:=_DoData;
  domethod:=_domethod;
  undomethod:=_undomethod;
end;

procedure TGObjectChangeCommand2.UnDo;
type
    TCangeMethod=procedure(const data:_T)of object;
begin
     TCangeMethod(undomethod)(Data);
     PGDBObjEntity(undomethod.Data)^.YouChanged;
end;

procedure TGObjectChangeCommand2.Comit;
type
    TCangeMethod=procedure(const data:_T)of object;
begin
     TCangeMethod(domethod)(Data);
     PGDBObjEntity(domethod.Data)^.YouChanged;
end;

constructor TGChangeCommand.Assign(var data:_T);
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
begin
     if PrevIndex<>-1 then
                          result:=TTC_MEnd
                      else
                          result:=TTC_MBegin;
end;
procedure TMarkerCommand.UnDo;
begin
     gdb.GetCurrentROOT^.FormatAfterEdit;
end;

procedure TMarkerCommand.Comit;
begin
     gdb.GetCurrentROOT^.FormatAfterEdit;
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
     GDBGetMem({$IFDEF DEBUGBUILD}'{30D8D2A8-1130-40FB-81BC-10C7D9A1FF38}',{$ENDIF}pointer(pmarker),sizeof(TMarkerCommand));
     pmarker^.init(CommandName,-1);
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
     GDBGetMem({$IFDEF DEBUGBUILD}'{F5F5F128-96B3-4AB9-81A1-2B86E0C95EF4}',{$ENDIF}pointer(pmarker),sizeof(TMarkerCommand));
     pmarker^.init('EndMarker',currentcommandstartmarker);
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
     GDBGetMem({$IFDEF DEBUGBUILD}'{3A3AAA8F-40EB-415B-BDC2-798712E9F402}',{$ENDIF}pointer(pcc),sizeof(TChangeCommand));
     pcc^.init(_obj,_fieldsize);
     inc(CurrentCommand);
     add(@pcc);
end;
procedure GDBObjOpenArrayOfUCommands.undo(prevheap:TArrayIndex;overlay:GDBBoolean);
var
   pcc:PTChangeCommand;
   mcounter:integer;
begin
     if CurrentCommand>prevheap then
     begin
          mcounter:=0;
          repeat
          pcc:=pointer(self.GetObject(CurrentCommand-1));

          if pcc^.GetCommandType=TTC_MEnd then
                                              begin
                                              inc(mcounter);
                                              pcc^.undo;
                                              end
     else if pcc^.GetCommandType=TTC_MBegin then
                                                begin
                                                     dec(mcounter);
                                                     if mcounter=0 then
                                                     shared.HistoryOutStr('Отмена "'+PTMarkerCommand(pcc)^.Name+'"');
                                                     pcc^.undo;
                                                end
     else pcc^.undo;
          dec(CurrentCommand);
          until mcounter=0;
     end
     else
         begin
         if overlay then
                        shared.ShowError('Нет операций для отмены. Завершите текущую команду')
                    else
                        shared.ShowError('Нет операций для отмены. Стек UNDO пуст')
         end;
     gdb.GetCurrentROOT^.FormatAfterEdit;
end;
procedure GDBObjOpenArrayOfUCommands.redo;
var
   pcc:PTChangeCommand;
   mcounter:integer;
begin
     if CurrentCommand<count then
     begin
          {pcc:=pointer(self.GetObject(CurrentCommand));
          pcc^.Comit;
          inc(CurrentCommand);}
          mcounter:=0;
          repeat
          pcc:=pointer(self.GetObject(CurrentCommand));

          if pcc^.GetCommandType=TTC_MEnd then
                                              begin
                                              inc(mcounter);
                                              pcc^.undo;
                                              end
     else if pcc^.GetCommandType=TTC_MBegin then
                                                begin
                                                     if mcounter=0 then
                                                     shared.HistoryOutStr('Повтор "'+PTMarkerCommand(pcc)^.Name+'"');
                                                     dec(mcounter);
                                                     pcc^.undo;
                                                end
     else pcc^.comit;
          inc(CurrentCommand);
          until mcounter=0;
     end
     else
         shared.ShowError('Нет операций для повторного применения');
     gdb.GetCurrentROOT^.FormatAfterEdit;
end;

constructor GDBObjOpenArrayOfUCommands.init;
begin
     inherited init({$IFDEF DEBUGBUILD}'{EF79AD53-2ECF-4848-8EDA-C498803A4188}',{$ENDIF}1);
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

