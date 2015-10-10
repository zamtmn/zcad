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
unit ugdbopenarrayofucommands;
{$INCLUDE def.inc}
interface
uses zebaseundocommands,usimplegenerics,gdbdrawcontext,varmandef,zcadinterface,UGDBLayerArray,UGDBTextStyleArray,zcadstrconsts,UGDBOpenArrayOfPV,GDBEntity,UGDBOpenArrayOfData,shared,log,gdbasetypes{,math},UGDBOpenArrayOfPObjects{,UGDBOpenArray, oglwindowdef},sysutils,
     gdbase, geometry, {OGLtypes, oglfunc,} {varmandef,gdbobjectsconstdef,}memman{,GDBSubordinated};
const BeginUndo:GDBString='BeginUndo';
      EndUndo:GDBString='EndUndo';
{$MACRO ON}
{$DEFINE INTERFACE}
  {$I TGChangeCommandList.inc}
  {$I TGObjectChangeCommandList.inc}
  {$I TGObjectChangeCommand2List.inc}
  {$I TGMultiObjectChangeCommandList.inc}
  {//$I TGMultiObjectCreateCommand.inc}
  //{$I TTypedChangeCommandIMPL.inc}
{$UNDEF INTERFACE}
type
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
                                 procedure PushStone;
                                 procedure PushChangeCommand(_obj:GDBPointer;_fieldsize:PtrInt);overload;
                                 //procedure PushTypedChangeCommand(_obj:GDBPointer;_PTypeManager:PUserTypeDescriptor);overload;
                                 procedure undo(prevheap:TArrayIndex;overlay:GDBBoolean);
                                 procedure KillLastCommand;
                                 procedure redo;
                                 constructor init;
                                 function Add(p:GDBPointer):TArrayIndex;virtual;
                                 Procedure ClearFrom(cc:TArrayIndex);

                                 {$I TGChangeCommandList.inc}
                                 {$I TGObjectChangeCommandList.inc}
                                 {$I TGObjectChangeCommand2List.inc}
                                 {$I TGMultiObjectChangeCommandList.inc}
                                 {//$I TGMultiObjectCreateCommand.inc}
                                 //{$I TTypedChangeCommandIMPL.inc}

                                 function CreateTTypedChangeCommand(PDataInstance:GDBPointer;PType:PUserTypeDescriptor):PTTypedChangeCommand;overload;
                                 function PushCreateTTypedChangeCommand(PDataInstance:GDBPointer;PType:PUserTypeDescriptor):PTTypedChangeCommand;overload;

                           end;
{$UNDEF CLASSDECLARATION}
implementation
uses UGDBDescriptor,GDBManager;
{$DEFINE IMPLEMENTATION}
  {$I TGChangeCommandList.inc}
  {$I TGObjectChangeCommandList.inc}
  {$I TGObjectChangeCommand2List.inc}
  {$I TGMultiObjectChangeCommandList.inc}
  //{$I TGMultiObjectCreateCommand.inc}
  //{$I TTypedChangeCommandIMPL.inc}
{$UNDEF IMPLEMENTATION}
{$MACRO OFF}

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
procedure GDBObjOpenArrayOfUCommands.PushStone;
var
   pmarker:PTMarkerCommand;
begin
     //inc(startmarkercount);
     //if startmarkercount=1 then
     begin
     GDBGetMem({$IFDEF DEBUGBUILD}'{30D8D2A8-1130-40FB-81BC-10C7D9A1FF38}',{$ENDIF}pointer(pmarker),sizeof(TMarkerCommand));
     pmarker^.init('StoneMarker',-2);
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
//procedure GDBObjOpenArrayOfUCommands.PushTypedChangeCommand(_obj:GDBPointer;_PTypeManager:PUserTypeDescriptor);overload;
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
procedure GDBObjOpenArrayOfUCommands.KillLastCommand;
var
   pcc:PTChangeCommand;
   mcounter:integer;
begin
     begin
          mcounter:=0;
          repeat
          pcc:=pointer(self.GetObject(CurrentCommand-1));

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
procedure GDBObjOpenArrayOfUCommands.undo(prevheap:TArrayIndex;overlay:GDBBoolean);
var
   pcc:PTChangeCommand;
   mcounter:integer;
   DC:TDrawContext;
begin
     if CurrentCommand>prevheap then
     begin
          mcounter:=0;
          repeat
          pcc:=pointer(self.GetObject(CurrentCommand-1));

          if pcc^.GetCommandType=TTC_MEnd then
                                              begin
                                              inc(mcounter);
                                              //pcc^.undo;
                                              end
     else if pcc^.GetCommandType=TTC_MBegin then
                                                begin
                                                     dec(mcounter);
                                                     if mcounter=0 then
                                                     shared.HistoryOutStr('Отмена "'+PTMarkerCommand(pcc)^.Name+'"');
                                                     //pcc^.undo;
                                                end
     else if pcc^.GetCommandType=TTC_MNotUndableIfOverlay then
                                                begin
                                                     if overlay then
                                                     shared.ShowError(rscmNoCTU)
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
                        shared.ShowError(rscmNoCTU)
                    else
                        shared.ShowError(rscmNoCTUSE)
         end;
     DC:=gdb.GetCurrentDWG^.CreateDrawingRC;
     gdb.GetCurrentROOT^.FormatAfterEdit(gdb.GetCurrentDWG^,dc);
end;
procedure GDBObjOpenArrayOfUCommands.redo;
var
   pcc:PTChangeCommand;
   mcounter:integer;
   DC:TDrawContext;
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
         shared.ShowError(rscmNoCTR);
     dc:=gdb.GetCurrentDWG^.CreateDrawingRC;
     gdb.GetCurrentROOT^.FormatAfterEdit(gdb.GetCurrentDWG^,dc);
end;

constructor GDBObjOpenArrayOfUCommands.init;
begin
     inherited init({$IFDEF DEBUGBUILD}'{EF79AD53-2ECF-4848-8EDA-C498803A4188}',{$ENDIF}1);
     CurrentCommand:=0;
end;
procedure GDBObjOpenArrayOfUCommands.ClearFrom(cc:TArrayIndex);
begin
     cleareraseobjfrom2(cc);
     CurrentCommand:=Count;
end;

function GDBObjOpenArrayOfUCommands.Add(p:GDBPointer):TArrayIndex;
begin
     if self.CurrentCommand<count then
                                       self.cleareraseobjfrom2(self.CurrentCommand);
     result:=inherited;
end;
function GDBObjOpenArrayOfUCommands.CreateTTypedChangeCommand(PDataInstance:GDBPointer;PType:PUserTypeDescriptor):PTTypedChangeCommand;overload;
begin
     gdbgetmem({$IFDEF DEBUGBUILD}'{6D631C2E-57FF-4553-991B-332464B7495E}',{$ENDIF}result,sizeof(TTypedChangeCommand));
     result^.Assign(PDataInstance,PType);
end;
function GDBObjOpenArrayOfUCommands.PushCreateTTypedChangeCommand(PDataInstance:GDBPointer;PType:PUserTypeDescriptor):PTTypedChangeCommand;overload;
begin
  if CurrentCommand>0 then
  begin
       result:=pointer(self.GetObject(CurrentCommand-1));
       if result^.GetCommandType=TTC_ChangeCommand then
       if (result^.Addr=PDataInstance)
       and(result^.PTypeManager=PType)
                                                then
                                                    exit;
  end;
  result:=CreateTTypedChangeCommand(PDataInstance,PType);
  {if CurrentCommand<>count then
                               self.cleareraseobjfrom2(CurrentCommand);}

  add(@result);
  inc(CurrentCommand);
end;

begin
  {$IFDEF DEBUGINITSECTION}LogOut('UGDBOpenArrayOfUCommands.initialization');{$ENDIF}
end.

