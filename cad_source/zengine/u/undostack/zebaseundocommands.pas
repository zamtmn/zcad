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
uses usimplegenerics,gdbdrawcontext,varmandef,zcadinterface,UGDBLayerArray,GDBEntity,UGDBOpenArrayOfData,shared,log,gdbasetypes{,math}{,UGDBOpenArray, oglwindowdef},sysutils,
     gdbase, geometry, {OGLtypes, oglfunc,} {varmandef,gdbobjectsconstdef,}memman{,GDBSubordinated};
const BeginUndo:GDBString='BeginUndo';
      EndUndo:GDBString='EndUndo';
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
generic TGChangeCommand<_T>=object(TCustomChangeCommand)
                                      public
                                      OldData,NewData:_T;
                                      PEntity:PGDBObjEntity;
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
implementation
uses UGDBDescriptor,GDBManager;
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
        PGDBObjEntity(p^.Data)^.YouChanged(gdb.GetCurrentDWG^);
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
        PGDBObjEntity(p^.Data)^.YouChanged(gdb.GetCurrentDWG^);
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
     PGDBObjEntity(method.Data)^.YouChanged(gdb.GetCurrentDWG^);
     //PGDBObjSubordinated(method.Data)^.bp.owner^.ImEdited(PGDBObjSubordinated(method.Data),PGDBObjSubordinated(method.Data)^.bp.PSelfInOwnerArray);
end;
procedure TGObjectChangeCommand.Comit;
type
    TCangeMethod=procedure(const data:_T)of object;
begin
     TCangeMethod(method)(DoData);
     PGDBObjEntity(method.Data)^.YouChanged(gdb.GetCurrentDWG^);
     //PGDBObjSubordinated(method.Data)^.bp.owner^.ImEdited(PGDBObjSubordinated(method.Data),PGDBObjSubordinated(method.Data)^.bp.PSelfInOwnerArray);
end;
constructor TGObjectChangeCommand2.Assign(var _dodata:_T;_domethod,_undomethod:tmethod);
begin
  AutoProcessGDB:=True;
  AfterAction:=true;
  Data:=_DoData;
  domethod:=_domethod;
  undomethod:=_undomethod;
end;

procedure TGObjectChangeCommand2.UnDo;
var
  DC:TDrawContext;
type
    TCangeMethod=procedure(const data:_T)of object;
begin
     TCangeMethod(undomethod)(Data);
     if AfterAction then
     begin
     if AutoProcessGDB then
                           PGDBObjEntity(undomethod.Data)^.YouChanged(gdb.GetCurrentDWG^)
                       else
                           begin
                                dc:=gdb.GetCurrentDWG^.CreateDrawingRC;
                                PGDBObjEntity(undomethod.Data)^.formatEntity(gdb.GetCurrentDWG^,dc);
                           end;
     end;
end;

procedure TGObjectChangeCommand2.Comit;
var
  DC:TDrawContext;
type
    TCangeMethod=procedure(const data:_T)of object;
begin
     TCangeMethod(domethod)(Data);
     if AfterAction then
     begin
     if AutoProcessGDB then
                           PGDBObjEntity(undomethod.Data)^.YouChanged(gdb.GetCurrentDWG^)
                       else
                           begin
                           dc:=gdb.GetCurrentDWG^.CreateDrawingRC;
                           PGDBObjEntity(undomethod.Data)^.formatEntity(gdb.GetCurrentDWG^,dc);
                           end;
     end;
end;
{TTypedChangeCommand=object(TCustomChangeCommand)
                                      public
                                      OldData,NewData:GDBPointer;
                                      PTypeManager:PUserTypeDescriptor;
                                      PEntity:PGDBObjEntity;
                                      constructor Assign(PDataInstance:GDBPointer;PType:PUserTypeDescriptor);
                                      procedure UnDo;virtual;
                                      procedure Comit;virtual;
                                      procedure ComitFromObj;virtual;
                                      function GetDataTypeSize:PtrInt;virtual;
                                end;}
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

constructor TGChangeCommand.Assign(var data:_T);
begin
     Addr:=@data;
     olddata:=data;
     newdata:=data;
     PEntity:=nil;
end;
procedure TGChangeCommand.UnDo;
begin
     _T(addr^):=OldData;
     if assigned(PEntity)then
                             PEntity^.YouChanged(gdb.GetCurrentDWG^);
     if assigned(SetVisuaProplProc)then
                                       SetVisuaProplProc;
end;
procedure TGChangeCommand.Comit;
begin
     _T(addr^):=NewData;
     if assigned(PEntity)then
                             PEntity^.YouChanged(gdb.GetCurrentDWG^);
     if assigned(SetVisuaProplProc)then
                                       SetVisuaProplProc;

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

