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
{$H+}
unit zeundostack;
{$INCLUDE def.inc}
interface
uses gzctnrvectortypes,zebaseundocommands,varmandef,uzbtypesbase,
     gzctnrvectorpobjects,sysutils,uzbtypes,uzbmemman;
const BeginUndo:GDBString='BeginUndo';
      EndUndo:GDBString='EndUndo';
type
TUndoRedoResult=(URROk,
                 URRNoCommandsToUndoInOverlayMode,
                 URRNoCommandsToUndo,
                 URRNoCommandsToRedo);
TOnUndoRedoProc=procedure of object;
PTZctnrVectorUndoCommands=^TZctnrVectorUndoCommands;
TZctnrVectorUndoCommands=object(specialize GZVectorPObects{-}<PTElementaryCommand,TElementaryCommand>{//})
                                 public
                                 CurrentCommand:TArrayIndex;
                                 currentcommandstartmarker:TArrayIndex;
                                 startmarkercount:GDBInteger;
                                 onUndoRedo:TOnUndoRedoProc;
                                 procedure PushStartMarker(CommandName:GDBString);
                                 procedure PushEndMarker;
                                 procedure PushStone;
                                 procedure PushChangeCommand(_obj:GDBPointer;_fieldsize:PtrInt);overload;
                                 function undo(out msg:string;prevheap:TArrayIndex;overlay:GDBBoolean):TUndoRedoResult;
                                 procedure KillLastCommand;
                                 function redo(out msg:string):TUndoRedoResult;
                                 constructor init;
                                 procedure doOnUndoRedo;
                                 function PushBackData(const data:GDBPointer):TArrayIndex;virtual;
                                 Procedure ClearFrom(cc:TArrayIndex);

                                 function CreateTTypedChangeCommand(PDataInstance:GDBPointer;PType:PUserTypeDescriptor):PTTypedChangeCommand;overload;
                                 function PushCreateTTypedChangeCommand(PDataInstance:GDBPointer;PType:PUserTypeDescriptor):PTTypedChangeCommand;overload;

                           end;
implementation

procedure TZctnrVectorUndoCommands.doOnUndoRedo;
begin
  if assigned(onUndoRedo)then
                             onUndoRedo;
end;

procedure TZctnrVectorUndoCommands.PushStartMarker(CommandName:GDBString);
var
   pmarker:PTMarkerCommand;
begin
     inc(startmarkercount);
     if startmarkercount=1 then
     begin
     GDBGetMem({$IFDEF DEBUGBUILD}'{30D8D2A8-1130-40FB-81BC-10C7D9A1FF38}',{$ENDIF}pointer(pmarker),sizeof(TMarkerCommand));
     pmarker^.init(CommandName,-1);
     currentcommandstartmarker:=self.PushBackData(pmarker);
     inc(CurrentCommand);
     end;
end;
procedure TZctnrVectorUndoCommands.PushStone;
var
   pmarker:PTMarkerCommand;
begin
     //inc(startmarkercount);
     //if startmarkercount=1 then
     begin
     GDBGetMem({$IFDEF DEBUGBUILD}'{30D8D2A8-1130-40FB-81BC-10C7D9A1FF38}',{$ENDIF}pointer(pmarker),sizeof(TMarkerCommand));
     pmarker^.init('StoneMarker',-2);
     currentcommandstartmarker:=self.PushBackData(pmarker);
     inc(CurrentCommand);
     end;
end;
procedure TZctnrVectorUndoCommands.PushEndMarker;
var
   pmarker:PTMarkerCommand;
begin
     dec(startmarkercount);
     if startmarkercount=0 then
     begin
     GDBGetMem({$IFDEF DEBUGBUILD}'{F5F5F128-96B3-4AB9-81A1-2B86E0C95EF4}',{$ENDIF}pointer(pmarker),sizeof(TMarkerCommand));
     pmarker^.init('EndMarker',currentcommandstartmarker);
     currentcommandstartmarker:=-1;
     self.PushBackData(pmarker);
     inc(CurrentCommand);
     startmarkercount:=0;
     end;
end;
//procedure TZctnrVectorUndoCommands.PushTypedChangeCommand(_obj:GDBPointer;_PTypeManager:PUserTypeDescriptor);overload;
procedure TZctnrVectorUndoCommands.PushChangeCommand(_obj:GDBPointer;_fieldsize:PtrInt);
var
   pcc:PTChangeCommand;
begin
     if CurrentCommand>0 then
     begin
          pcc:=pointer(self.getDataMutable(CurrentCommand-1));
          if pcc^.GetCommandType=TTC_ChangeCommand then
          if (pcc^.Addr=_obj)
          and(pcc^.datasize=_fieldsize) then
                                             exit;
     end;
     GDBGetMem({$IFDEF DEBUGBUILD}'{3A3AAA8F-40EB-415B-BDC2-798712E9F402}',{$ENDIF}pointer(pcc),sizeof(TChangeCommand));
     pcc^.init(_obj,_fieldsize);
     inc(CurrentCommand);
     PushBackData(pcc);
end;
procedure TZctnrVectorUndoCommands.KillLastCommand;
var
   pcc:PTElementaryCommand;
   mcounter:integer;
begin
     begin
          mcounter:=0;
          repeat
          pcc:=self.getDataMutable(CurrentCommand-1);

          if pcc^.GetCommandType=TTC_MEnd then
                                              begin
                                              inc(mcounter);
                                              pcc^.Done;
                                              end
     else if pcc^.GetCommandType=TTC_MBegin then
                                                begin
                                                     dec(mcounter);
                                                     pcc^.Done;
                                                end
     else
          pcc^.Done;
          dec(CurrentCommand);
          until mcounter=0;
     end;
     count:=self.CurrentCommand;
end;
function TZctnrVectorUndoCommands.undo(out msg:string;prevheap:TArrayIndex;overlay:GDBBoolean):TUndoRedoResult;
var
   pcc:PTElementaryCommand;
   mcounter:integer;
begin
     msg:='';
     result:=URROk;
     if CurrentCommand>prevheap then
     begin
          mcounter:=0;
          repeat
          pcc:=self.getDataMutable(CurrentCommand-1);

          if pcc^.GetCommandType=TTC_MEnd then
                                              begin
                                              inc(mcounter);
                                              //pcc^.undo;
                                              end
     else if pcc^.GetCommandType=TTC_MBegin then
                                                begin
                                                     dec(mcounter);
                                                     if mcounter=0 then
                                                     {HistoryOutStr}msg:=msg+('Undo "'+PTMarkerCommand(pcc)^.Name+'"');
                                                     //pcc^.undo;
                                                end
     else if pcc^.GetCommandType=TTC_MNotUndableIfOverlay then
                                                begin
                                                     if overlay then
                                                          result:=URRNoCommandsToUndo;
                                                end
     else
          pcc^.undo;

          if (pcc^.GetCommandType<>TTC_MNotUndableIfOverlay)then
                                                              dec(CurrentCommand)
                                                            else
                                                                if not overlay then
                                                                dec(CurrentCommand);
          until mcounter=0;
     end
     else
         begin
         if overlay then
                        result:=URRNoCommandsToUndo
                    else
                        result:=URRNoCommandsToUndoInOverlayMode;
         end;
     {DC:=gdb.GetCurrentDWG^.CreateDrawingRC;
     gdb.GetCurrentROOT^.FormatAfterEdit(gdb.GetCurrentDWG^,dc);}
     doOnUndoRedo;
end;
function TZctnrVectorUndoCommands.redo(out msg:string):TUndoRedoResult;
var
   pcc:PTElementaryCommand;
   mcounter:integer;
begin
     if CurrentCommand<count then
     begin
          {pcc:=pointer(self.getDataMutable(CurrentCommand));
          pcc^.Comit;
          inc(CurrentCommand);}
          mcounter:=0;
          repeat
          pcc:=self.getDataMutable(CurrentCommand);

          if pcc^.GetCommandType=TTC_MEnd then
                                              begin
                                              inc(mcounter);
                                              pcc^.undo;
                                              end
     else if pcc^.GetCommandType=TTC_MBegin then
                                                begin
                                                     if mcounter=0 then
                                                     {HistoryOutStr}msg:=msg+('Redo "'+PTMarkerCommand(pcc)^.Name+'"');
                                                     dec(mcounter);
                                                     pcc^.undo;
                                                end
     else pcc^.comit;
          inc(CurrentCommand);
          until mcounter=0;
          result:=URROk;
     end
     else
         result:=URRNoCommandsToRedo;
     {dc:=gdb.GetCurrentDWG^.CreateDrawingRC;
     gdb.GetCurrentROOT^.FormatAfterEdit(gdb.GetCurrentDWG^,dc);}
     doOnUndoRedo;
end;

constructor TZctnrVectorUndoCommands.init;
begin
     inherited init({$IFDEF DEBUGBUILD}'{EF79AD53-2ECF-4848-8EDA-C498803A4188}',{$ENDIF}1);
     CurrentCommand:=0;
     onUndoRedo:=nil;;
end;
procedure TZctnrVectorUndoCommands.ClearFrom(cc:TArrayIndex);
begin
     cleareraseobjfrom2(cc);
     CurrentCommand:=Count;
end;

function TZctnrVectorUndoCommands.PushBackData(const data:GDBPointer):TArrayIndex;
begin
     if self.CurrentCommand<count then
                                       self.cleareraseobjfrom2(self.CurrentCommand);
     result:=inherited PushBackData(data);
end;
function TZctnrVectorUndoCommands.CreateTTypedChangeCommand(PDataInstance:GDBPointer;PType:PUserTypeDescriptor):PTTypedChangeCommand;overload;
begin
     gdbgetmem({$IFDEF DEBUGBUILD}'{6D631C2E-57FF-4553-991B-332464B7495E}',{$ENDIF}result,sizeof(TTypedChangeCommand));
     result^.Assign(PDataInstance,PType);
end;
function TZctnrVectorUndoCommands.PushCreateTTypedChangeCommand(PDataInstance:GDBPointer;PType:PUserTypeDescriptor):PTTypedChangeCommand;overload;
begin
  if CurrentCommand>0 then
  begin
       result:=pointer(self.getDataMutable(CurrentCommand-1));
       if result^.GetCommandType=TTC_ChangeCommand then
       if (result^.Addr=PDataInstance)
       and(result^.PTypeManager=PType)
                                                then
                                                    exit;
  end;
  result:=CreateTTypedChangeCommand(PDataInstance,PType);
  {if CurrentCommand<>count then
                               self.cleareraseobjfrom2(CurrentCommand);}

  PushBackData(result);
  inc(CurrentCommand);
end;

begin
end.

