{$IFDEF CLASSDECLARATION}
function CreateTGObjectChangeCommand2(var _dodata:TData;_domethod,_undomethod:tmethod):PTCommand;overload;
function PushCreateTGObjectChangeCommand2(var _dodata:TData;_domethod,_undomethod:tmethod):PTCommand;overload;
{$ENDIF}


{$IFDEF INTERFACE}
type
PTCommand=^TCommand;
TCommand=specialize TGObjectChangeCommand2<TData>;
//function CreateTGChangeCommand(const data:TData):PTCommand;overload;
{$ENDIF}

{$IFDEF IMPLEMENTATION}
function GDBObjOpenArrayOfUCommands.CreateTGObjectChangeCommand2(var _dodata:TData;_domethod,_undomethod:tmethod):PTCommand;overload;
begin
     gdbgetmem(result,sizeof(TCommand));
     result^.Assign(_dodata,_domethod,_undomethod);
end;
function GDBObjOpenArrayOfUCommands.PushCreateTGObjectChangeCommand2(var _dodata:TData;_domethod,_undomethod:tmethod):PTCommand;overload;
begin
  result:=CreateTGObjectChangeCommand2(_dodata,_domethod,_undomethod);
  add(@result);
  inc(CurrentCommand);
end;

{$ENDIF}
