{$IFDEF CLASSDECLARATION}
function CreateTTypedChangeCommand(PDataInstance:GDBPointer;PType:PUserTypeDescriptor):PTTypedChangeCommand;overload;
function PushCreateTTypedChangeCommand(PDataInstance:GDBPointer;PType:PUserTypeDescriptor):PTTypedChangeCommand;overload;
{$ENDIF}


{$IFDEF IMPLEMENTATION}
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

{$ENDIF}
