{$IFDEF CLASSDECLARATION}
function CreateTGChangeCommand(var data:TData):PTCommand;overload;
function PushCreateTGChangeCommand(var data:TData):PTCommand;overload;
{$ENDIF}


{$IFDEF INTERFACE}
type
PTCommand=^TCommand;
TCommand=specialize TGChangeCommand<TData>;
//function CreateTGChangeCommand(const data:TData):PTCommand;overload;
{$ENDIF}

{$IFDEF IMPLEMENTATION}
function GDBObjOpenArrayOfUCommands.CreateTGChangeCommand(var data:TData):PTCommand;overload;
begin
     gdbgetmem({$IFDEF DEBUGBUILD}'{6D631C2E-57FF-4553-991B-332464B7495E}',{$ENDIF}result,sizeof(TCommand));
     result^.Assign(data);
end;
function GDBObjOpenArrayOfUCommands.PushCreateTGChangeCommand(var data:TData):PTCommand;overload;
begin
  if CurrentCommand>0 then
  begin
       result:=pointer(self.GetObject(CurrentCommand-1));
       if result^.GetCommandType=TTC_ChangeCommand then
       if (result^.Addr=@data)
       and(result^.GetDataTypeSize=sizeof(data))
                                                then
                                                    exit;
  end;
  result:=CreateTGChangeCommand(data);
  {if CurrentCommand<>count then
                               self.cleareraseobjfrom2(CurrentCommand);}

  add(@result);
  inc(CurrentCommand);
end;

{$ENDIF}
