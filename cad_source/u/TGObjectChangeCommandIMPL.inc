{$IFDEF CLASSDECLARATION}
function CreateTGObjectChangeCommand(var data:TData;_method:tmethod):PTCommand;overload;
function PushCreateTGObjectChangeCommand(var data:TData;_method:tmethod):PTCommand;overload;
{$ENDIF}


{$IFDEF INTERFACE}
type
PTCommand=^TCommand;
TCommand=specialize TGObjectChangeCommand<TData>;
//function CreateTGChangeCommand(const data:TData):PTCommand;overload;
{$ENDIF}

{$IFDEF IMPLEMENTATION}
function GDBObjOpenArrayOfUCommands.CreateTGObjectChangeCommand(var data:TData;_method:tmethod):PTCommand;overload;
begin
     gdbgetmem(result,sizeof(TCommand));
     result^.Assign(data,_method);
end;
function GDBObjOpenArrayOfUCommands.PushCreateTGObjectChangeCommand(var data:TData;_method:tmethod):PTCommand;overload;
begin
  result:=CreateTGObjectChangeCommand(data,_method);
  add(@result);
  inc(CurrentCommand);
end;

{$ENDIF}
