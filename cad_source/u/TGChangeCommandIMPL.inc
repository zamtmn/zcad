{$IFDEF CLASSDECLARATION}
function CreateTGChangeCommand(const data:TData):PTCommand;overload;
function PushCreateTGChangeCommand(const data:TData):PTCommand;overload;
{$ENDIF}


{$IFDEF INTERFACE}
type
PTCommand=^TCommand;
TCommand=specialize TGChangeCommand<TData>;
//function CreateTGChangeCommand(const data:TData):PTCommand;overload;
{$ENDIF}

{$IFDEF IMPLEMENTATION}
function GDBObjOpenArrayOfUCommands.CreateTGChangeCommand(const data:TData):PTCommand;overload;
begin
     gdbgetmem(result,sizeof(TCommand));
     result.Assign(data);
end;
function GDBObjOpenArrayOfUCommands.PushCreateTGChangeCommand(const data:TData):PTCommand;overload;
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
  add(@result);
  inc(CurrentCommand);
end;

{$ENDIF}
