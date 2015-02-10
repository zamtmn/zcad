{$IFDEF CLASSDECLARATION}
function CreateTGMultiObjectChangeCommand(var data,undodata:TData;const objcount:GDBInteger):PTCommand;overload;
function PushCreateTGMultiObjectChangeCommand(var data,undodata:TData;const objcount:GDBInteger):PTCommand;overload;
{$ENDIF}


{$IFDEF INTERFACE}
type
PTCommand=^TCommand;
TCommand=specialize TGMultiObjectChangeCommand<TData>;
//function CreateTGChangeCommand(const data:TData):PTCommand;overload;
{$ENDIF}

{$IFDEF IMPLEMENTATION}
function GDBObjOpenArrayOfUCommands.CreateTGMultiObjectChangeCommand(var data,undodata:TData;const objcount:GDBInteger):PTCommand;overload;
begin
     gdbgetmem({$IFDEF DEBUGBUILD}'{2FFA68C4-3209-4CB4-8DD1-28A818A795D1}',{$ENDIF}result,sizeof(TCommand));
     result^.Assign(data,undodata,objcount);
end;
function GDBObjOpenArrayOfUCommands.PushCreateTGMultiObjectChangeCommand(var data,undodata:TData;const objcount:GDBInteger):PTCommand;overload;
begin
  result:=CreateTGMultiObjectChangeCommand(data,undodata,objcount);
  add(@result);
  inc(CurrentCommand);
end;

{$ENDIF}
