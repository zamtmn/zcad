{$IFDEF CLASSDECLARATION}
function CreateMultiObjectCreateCommand(var dodata,undodata:tmethod;objcount:integer):PTCommand;overload;
function PushMultiObjectCreateCommand(var dodata,undodata:tmethod;objcount:integer):PTCommand;overload;
{$ENDIF}


{$IFDEF INTERFACE}
type
PTCommand=^TCommand;
TCommand=specialize {TGObjectChangeCommand}TGMultiObjectProcessCommand<TData>;
{$ENDIF}

{$IFDEF IMPLEMENTATION}
function GDBObjOpenArrayOfUCommands.CreateMultiObjectCreateCommand(var dodata,undodata:tmethod;objcount:integer):PTCommand;overload;
begin
     gdbgetmem({$IFDEF DEBUGBUILD}'{9FE25B12-DEE0-410A-BDCD-7E69A41E4389}',{$ENDIF}result,sizeof(TCommand));
     result^.Assign(dodata,undodata,objcount);
end;
function GDBObjOpenArrayOfUCommands.PushMultiObjectCreateCommand(var dodata,undodata:tmethod;objcount:integer):PTCommand;overload;
begin
  result:=CreateMultiObjectCreateCommand(dodata,undodata,objcount);
  add(@result);
  inc(CurrentCommand);
end;

{$ENDIF}
