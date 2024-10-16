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
unit zeundostack;
interface
uses gzctnrVectorTypes,zebaseundocommands,varmandef,
     {gzctnrVectorc,}gzctnrVector,gzctnrVectorClass,
     {gzctnrVectorPObjects,}sysutils;
const BeginUndo:String='BeginUndo';
      EndUndo:String='EndUndo';
type
TUndoRedoResult=(URROk,
                 URRNoCommandsToUndoInOverlayMode,
                 URRNoCommandsToUndo,
                 URRNoCommandsToRedo);
TOnUndoRedoProc=procedure of object;
PTZctnrVectorUndoCommands=^TZctnrVectorUndoCommands;
TZctnrVectorUndoCommands=object(specialize GZVectorClass<TUCmdBase>)
                                 public
                                 CurrentCommand:TArrayIndex;
                                 currentcommandstartmarker:TArrayIndex;
                                 startmarkercount:Integer;
                                 onUndoRedo:TOnUndoRedoProc;
                                 procedure PushStartMarker(CommandName:String);
                                 procedure PushEndMarker;
                                 procedure PushStone;
                                 function undo(out msg:string;prevheap:TArrayIndex;overlay:Boolean):TUndoRedoResult;
                                 procedure KillLastCommand;
                                 function redo(out msg:string):TUndoRedoResult;
                                 constructor init;
                                 procedure doOnUndoRedo;
                                 function PushBackData(const data:TUCmdBase):TArrayIndex;virtual;
                                 Procedure ClearFrom(cc:TArrayIndex);

                                 function CreateTTypedChangeCommand(PDataInstance:Pointer;PType:PUserTypeDescriptor):TTypedChangeCommand;overload;
                                 function PushCreateTTypedChangeCommand(PDataInstance:Pointer;PType:PUserTypeDescriptor):TTypedChangeCommand;overload;

                           end;
implementation

procedure TZctnrVectorUndoCommands.doOnUndoRedo;
begin
  if assigned(onUndoRedo)then
                             onUndoRedo;
end;

procedure TZctnrVectorUndoCommands.PushStartMarker(CommandName:String);
var
   marker:TUCmdMarker;
begin
     inc(startmarkercount);
     if startmarkercount=1 then
     begin
     //Getmem(pointer(pmarker),sizeof(TUCmdMarker));
     marker:=TUCmdMarker.Create(CommandName,-1);
     currentcommandstartmarker:=self.PushBackData(marker);
     inc(CurrentCommand);
     end;
end;
procedure TZctnrVectorUndoCommands.PushStone;
var
   marker:TUCmdMarker;
begin
     //inc(startmarkercount);
     //if startmarkercount=1 then
     begin
     //Getmem(pointer(pmarker),sizeof(TUCmdMarker));
     marker:=TUCmdMarker.Create('StoneMarker',-2);
     currentcommandstartmarker:=self.PushBackData(marker);
     inc(CurrentCommand);
     end;
end;
procedure TZctnrVectorUndoCommands.PushEndMarker;
var
   marker:TUCmdMarker;
begin
     dec(startmarkercount);
     if startmarkercount=0 then
     begin
     //Getmem(pointer(pmarker),sizeof(TUCmdMarker));
     marker:=TUCmdMarker.Create('EndMarker',currentcommandstartmarker);
     currentcommandstartmarker:=-1;
     self.PushBackData(marker);
     inc(CurrentCommand);
     startmarkercount:=0;
     end;
end;
procedure TZctnrVectorUndoCommands.KillLastCommand;
var
   cmd:TUCmdBase;
   mcounter:integer;
begin
     begin
          mcounter:=0;
          repeat
          cmd:=self.getDataMutable(CurrentCommand-1)^;

          if cmd.GetCommandType=TTC_MEnd then
                                              begin
                                              inc(mcounter);
                                              cmd.Destroy;
                                              end
     else if cmd.GetCommandType=TTC_MBegin then
                                                begin
                                                     dec(mcounter);
                                                     cmd.Destroy;
                                                end
     else
          cmd.Destroy;
          dec(CurrentCommand);
          until mcounter=0;
     end;
     count:=self.CurrentCommand;
end;
function TZctnrVectorUndoCommands.undo(out msg:string;prevheap:TArrayIndex;overlay:Boolean):TUndoRedoResult;
var
   cmd:TUCmdBase;
   mcounter:integer;
begin
     msg:='';
     result:=URROk;
     if CurrentCommand>prevheap then
     begin
          mcounter:=0;
          repeat
          cmd:=self.getDataMutable(CurrentCommand-1)^;

          if cmd.GetCommandType=TTC_MEnd then
                                              begin
                                              inc(mcounter);
                                              //cmd^.undo;
                                              end
     else if cmd.GetCommandType=TTC_MBegin then
                                                begin
                                                     dec(mcounter);
                                                     if mcounter=0 then
                                                     {HistoryOutStr}msg:=msg+('Undo "'+TUCmdMarker(cmd).Name+'"');
                                                     //cmd^.undo;
                                                end
     else if cmd.GetCommandType=TTC_MNotUndableIfOverlay then
                                                begin
                                                     if overlay then
                                                          result:=URRNoCommandsToUndo;
                                                end
     else
          cmd.undo;

          if (cmd.GetCommandType<>TTC_MNotUndableIfOverlay)then
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
   cmd:TUCmdBase;
   mcounter:integer;
begin
     if CurrentCommand<count then
     begin
          {cmd:=pointer(self.getDataMutable(CurrentCommand));
          cmd^.Comit;
          inc(CurrentCommand);}
          mcounter:=0;
          repeat
          cmd:=self.getDataMutable(CurrentCommand)^;

          if cmd.GetCommandType=TTC_MEnd then
                                              begin
                                              inc(mcounter);
                                              cmd.undo;
                                              end
     else if cmd.GetCommandType=TTC_MBegin then
                                                begin
                                                     if mcounter=0 then
                                                     {HistoryOutStr}msg:=msg+('Redo "'+TUCmdMarker(cmd).Name+'"');
                                                     dec(mcounter);
                                                     cmd.undo;
                                                end
     else cmd.comit;
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
     inherited init(1);
     CurrentCommand:=0;
     onUndoRedo:=nil;;
end;
procedure TZctnrVectorUndoCommands.ClearFrom(cc:TArrayIndex);
begin
     cleareraseobjfrom2(cc);
     CurrentCommand:=Count;
end;

function TZctnrVectorUndoCommands.PushBackData(const data:TUCmdBase):TArrayIndex;
begin
     if self.CurrentCommand<count then
                                       self.cleareraseobjfrom2(self.CurrentCommand);
     result:=inherited PushBackData(data);
end;
function TZctnrVectorUndoCommands.CreateTTypedChangeCommand(PDataInstance:Pointer;PType:PUserTypeDescriptor):TTypedChangeCommand;overload;
begin
     //Getmem(result,sizeof(TTypedChangeCommand));
     result:=TTypedChangeCommand.Create(PDataInstance,PType);
end;
function TZctnrVectorUndoCommands.PushCreateTTypedChangeCommand(PDataInstance:Pointer;PType:PUserTypeDescriptor):TTypedChangeCommand;overload;
begin
  if CurrentCommand>0 then
  begin
       result:=TTypedChangeCommand(self.getDataMutable(CurrentCommand-1)^);
       if result is TTypedChangeCommand then
       if (result.Addr=PDataInstance)
       and(result.PTypeManager=PType)
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

