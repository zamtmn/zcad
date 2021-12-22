{$IFDEF CLASSDECLARATION}
function CreateTGChangeCommand(var data:TData):PTCommand;overload;
function PushCreateTGChangeCommand(var us:TZctnrVectorUndoCommands; var data:TData):PTCommand;overload;
{$ENDIF}


{$IFDEF INTERFACE}
PTCommand=^TCommand;
TCommand=specialize TGChangeCommand<TData>;
//function CreateTGChangeCommand(const data:TData):PTCommand;overload;
{$ENDIF}

{$IFDEF IMPLEMENTATION}
function {GDBObjOpenArrayOfUCommands.}CreateTGChangeCommand(var data:TData):PTCommand;overload;
begin
     Getmem(result,sizeof(TCommand));
     result^.Assign(data);
end;
function {GDBObjOpenArrayOfUCommands.}PushCreateTGChangeCommand(var us:TZctnrVectorUndoCommands; var data:TData):PTCommand;overload;
begin
  if us.CurrentCommand>0 then
  begin
       result:=pointer(us.getDataMutable(us.CurrentCommand-1));
       if result^.GetCommandType=TTC_ChangeCommand then
       if (result^.Addr=@data)
       and(result^.GetDataTypeSize=sizeof(data))
                                                then
                                                    exit;
  end;
  result:=CreateTGChangeCommand(data);
  {if CurrentCommand<>count then
                               self.cleareraseobjfrom2(CurrentCommand);}

  us.PushBackData(result);
  inc(us.CurrentCommand);
end;

{$ENDIF}
