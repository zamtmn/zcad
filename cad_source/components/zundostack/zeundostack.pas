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
uses
  sysutils,
  gzctnrVectorTypes,gzctnrVector,gzctnrVectorClass,
  uzsbVarmanDef,
  zebaseundocommands;
const
  BeginUndo:String='BeginUndo';
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
  if startmarkercount=1 then begin
    marker:=TUCmdMarker.Create(CommandName,-1);
    currentcommandstartmarker:=self.PushBackData(marker);
    inc(CurrentCommand);
  end;
end;
procedure TZctnrVectorUndoCommands.PushStone;
var
  marker:TUCmdMarker;
begin
  marker:=TUCmdMarker.Create('StoneMarker',-2);
  currentcommandstartmarker:=self.PushBackData(marker);
  inc(CurrentCommand);
end;

procedure TZctnrVectorUndoCommands.PushEndMarker;
var
   marker:TUCmdMarker;
begin
  dec(startmarkercount);
  if startmarkercount=0 then begin
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
  mcounter:=0;
  repeat
    cmd:=self.getDataMutable(CurrentCommand-1)^;
    if cmd.GetCommandType=TTC_MEnd then begin
      inc(mcounter);
      cmd.Destroy;
    end else if cmd.GetCommandType=TTC_MBegin then begin
      dec(mcounter);
      cmd.Destroy;
    end else
      cmd.Destroy;
    dec(CurrentCommand);
  until mcounter=0;
  count:=self.CurrentCommand;
end;

function TZctnrVectorUndoCommands.undo(out msg:string;prevheap:TArrayIndex;overlay:Boolean):TUndoRedoResult;
var
  cmd:TUCmdBase;
  mcounter:integer;
begin
  msg:='';
  result:=URROk;
  if CurrentCommand>prevheap then begin
    mcounter:=0;
    repeat
      cmd:=self.getDataMutable(CurrentCommand-1)^;
      if cmd.GetCommandType=TTC_MEnd then begin
        inc(mcounter);
      end else if cmd.GetCommandType=TTC_MBegin then begin
        dec(mcounter);
        if mcounter=0 then
          msg:='Undo "'+TUCmdMarker(cmd).Name+'"';
      end else if cmd.GetCommandType=TTC_MNotUndableIfOverlay then begin
        if overlay then
          result:=URRNoCommandsToUndo;
      end else
        cmd.undo;

      if (cmd.GetCommandType<>TTC_MNotUndableIfOverlay)then
        dec(CurrentCommand)
      else
        if not overlay then
          dec(CurrentCommand);
    until mcounter=0;
  end else begin
    if overlay then
      result:=URRNoCommandsToUndo
    else
      result:=URRNoCommandsToUndoInOverlayMode;
  end;
  doOnUndoRedo;
end;

function TZctnrVectorUndoCommands.redo(out msg:string):TUndoRedoResult;
var
  cmd:TUCmdBase;
  mcounter:integer;
begin
  if CurrentCommand<count then begin
    mcounter:=0;
    repeat
      cmd:=self.getDataMutable(CurrentCommand)^;
      if cmd.GetCommandType=TTC_MEnd then begin
        inc(mcounter);
        cmd.undo;
      end else if cmd.GetCommandType=TTC_MBegin then begin
        if mcounter=0 then
          msg:='Redo "'+TUCmdMarker(cmd).Name+'"';
        dec(mcounter);
        cmd.undo;
      end else
        cmd.comit;
      inc(CurrentCommand);
    until mcounter=0;
    result:=URROk;
  end else
    result:=URRNoCommandsToRedo;
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
  result:=TTypedChangeCommand.Create(PDataInstance,PType);
end;

function TZctnrVectorUndoCommands.PushCreateTTypedChangeCommand(PDataInstance:Pointer;PType:PUserTypeDescriptor):TTypedChangeCommand;overload;
begin
  if CurrentCommand>0 then begin
    result:=TTypedChangeCommand(self.getDataMutable(CurrentCommand-1)^);
    if result is TTypedChangeCommand then
      if (result.Addr=PDataInstance)and(result.PTypeManager=PType)then
        exit;
  end;
  result:=CreateTTypedChangeCommand(PDataInstance,PType);
  PushBackData(result);
  inc(CurrentCommand);
end;

begin
end.

