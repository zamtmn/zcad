{
*****************************************************************************
*                                                                           *
*  This file is part of the ZCAD                                            *
*                                                                           *
*  See the file COPYING.modifiedLGPL.txt, included in this distribution,    *
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

unit commandline;
{$INCLUDE def.inc}
interface
uses umytreenode,sysinfo,strproc,UGDBOpenArrayOfPointer,UDMenuWnd,gdbasetypes,commandlinedef, sysutils,gdbase,oglwindowdef,
     memman,shared,log,varmandef,varman;
resourcestring
S_RunCommand='Running command';
S_UnknownCommand='Unknown command';
S_CommandNRInC='Command can not run';

const
     tm:tmethod=(Code:nil;Data:nil);
     nullmethod:{tmethod}TButtonMethod=nil;
type
  tvarstack=object({varmanagerdef}varmanager)
            end;

  GDBcommandmanager=object(GDBcommandmanagerDef)
                          CommandsStack:GDBOpenArrayOfGDBPointer;
                          ContextCommandParams:GDBPointer;
                          busy:GDBBoolean;
                          varstack:tvarstack;
                          constructor init(m:GDBInteger);
                          function execute(const comm:pansichar;silent:GDBBoolean): GDBInteger;virtual;
                          function executecommand(const comm:pansichar): GDBInteger;virtual;
                          function executecommandsilent(const comm:pansichar): GDBInteger;virtual;
                          procedure executecommandend;virtual;
                          procedure executecommandtotalend;virtual;
                          procedure executefile(fn:GDBString);virtual;
                          function executelastcommad: GDBInteger;virtual;
                          procedure sendpoint2command(p3d:gdbvertex; p2d:gdbvertex2di; mode:GDBByte;osp:pos_record);virtual;
                          procedure CommandRegister(pc:PCommandObjectDef);virtual;
                          procedure run(pc:PCommandObjectDef;operands:GDBString);virtual;
                          destructor done;virtual;
                          procedure cleareraseobj;virtual;
                          procedure DMShow;
                          procedure DMHide;
                          procedure DMClear;
                          //-----------------------------------------------------------------procedure DMAddProcedure(Text,HText:GDBString;proc:TonClickProc);
                          procedure DMAddMethod(Text,HText:GDBString;FMethod:TButtonMethod);
                          procedure DMAddProcedure(Text,HText:GDBString;FProc:TButtonProc);
                          function FindCommand(command:GDBString):PCommandObjectDef;
                          procedure PushValue(varname,vartype:GDBString;instance:GDBPointer);virtual;
                          function PopValue:vardesk;virtual;
                          function GetValue:vardesk;virtual;
                          function GetValueHeap:GDBInteger;
                    end;
var commandmanager:GDBcommandmanager;
function getcommandmanager:GDBPointer;export;
function GetCommandContext:TCStartAttr;
procedure ParseCommand(comm:pansichar; out command,operands:GDBString);
{procedure startup;
procedure finalize;}
implementation
uses Objinsp,UGDBStringArray,cmdline,UGDBDescriptor,forms{,varman};
function GDBcommandmanager.GetValueHeap:GDBInteger;
begin
     result:=varstack.vardescarray.count;
end;

procedure GDBcommandmanager.PushValue(varname,vartype:GDBString;instance:GDBPointer);
var
   vd: vardesk;
begin
     vd.name:=varname;
     //vd.data.Instance:=instance;
     vd.data.PTD:=SysUnit.TypeName2PTD(vartype);
     varstack.createvariable(varname,vd);
     vd.data.PTD.CopyInstanceTo(instance,vd.data.Instance);
end;
function GDBcommandmanager.GetValue:vardesk;
var
lastelement:pvardesk;
begin
     lastelement:=pvardesk(varstack.vardescarray.getelement(varstack.vardescarray.Count-1));
     result:=lastelement^;
end;

function GDBcommandmanager.PopValue:vardesk;
var
lastelement:pvardesk;
begin
     lastelement:=pvardesk(varstack.vardescarray.getelement(varstack.vardescarray.Count-1));
     dec(varstack.vardescarray.Count);
     result:=lastelement^;
     lastelement.name:='';
     lastelement.username:='';
     lastelement.data.PTD:=nil;
     lastelement.data.Instance:=nil;
end;

function getcommandmanager:GDBPointer;
begin
     result:=@commandmanager;
end;
procedure GDBcommandmanager.DMShow;
begin
     if assigned(cline) then
     if assigned(CLine.DMenu) then
     begin
     //CLine.DMenu.ajustsize;
     CLine.DMenu.Show;
     end;
end;
procedure GDBcommandmanager.DMHide;
begin
     if assigned(cline) then
     if assigned(CLine.DMenu) then
     CLine.DMenu.Hide;
end;
procedure GDBcommandmanager.DMClear;
begin
     if assigned(cline) then
     if assigned(CLine.DMenu) then
     CLine.DMenu.clear;
end;
{procedure GDBcommandmanager.DMAddProcedure(Text,HText:GDBString;proc:TonClickProc);
begin
     if assigned(cline) then
     if assigned(CLine.DMenu) then
     CLine.DMenu.AddProcedure(Text,HText,Proc);
end;}
procedure GDBcommandmanager.DMAddProcedure;
begin
     if assigned(cline) then
     if assigned(CLine.DMenu) then
     CLine.DMenu.AddProcedure(Text,HText,FProc);
end;

procedure GDBcommandmanager.DMAddMethod;
begin
     if assigned(cline) then
     if assigned(CLine.DMenu) then
     CLine.DMenu.AddMethod(Text,HText,FMethod);
end;


procedure GDBcommandmanager.executefile;
var
   sa:GDBGDBStringArray;
   p:pstring;
   ir:itrec;
   oldlastcomm:GDBString;
   s:gdbstring;
begin
     s:=(ExpandPath(fn));
     historyoutstr('Запущен скрипт "'+s+'";');
     busy:=true;

     shared.DisableCmdLine;

     oldlastcomm:=lastcommand;
     sa.init(200);
     sa.loadfromfile(s);
     //sa.getGDBString(1);
  p:=sa.beginiterate(ir);
  if p<>nil then
  repeat
        if (uppercase(pGDBString(p)^)<>'ABOUT')then
                                                    execute(pointer(pGDBString(p)^),false)
                                                else
                                                    begin
                                                         if not sysparam.nosplash then
                                                                                      execute(pointer(pGDBString(p)^),false)
                                                    end;
        p:=sa.iterate(ir);
  until p=nil;
  sa.FreeAndDone;
  lastcommand:=oldlastcomm;

     shared.EnableCmdLine;
     busy:=false;
end;
procedure GDBcommandmanager.sendpoint2command;
begin
     if pcommandrunning <> nil then
     begin
          pcommandrunning^.MouseMoveCallback(p3d,p2d,mode,osp);
     end;
     //clearotrack;
end;
procedure GDBcommandmanager.cleareraseobj;
var p:PCommandObjectDef;
    ir:itrec;
begin
  p:=beginiterate(ir);
  if p<>nil then
  repeat
       p^.done;
       if p^.dyn then GDBFreeMem(GDBPointer(p));
       p:=iterate(ir);
  until p=nil;
  count:=0;
end;
function GetCommandContext:TCStartAttr;
begin
     result:=0;
     if gdb.GetCurrentDWG<>nil then
                                   result:=result or CADWG;

end;
procedure ParseCommand(comm:pansichar; out command,operands:GDBString);
var
   i,p1,p2: GDBInteger;
begin
  p1:=pos('(',comm);
  p2:=pos(')',comm);
  if  p1<1 then
               begin
                    p1:=length(comm)+1;
                    p2:=p1;
               end;
  command:=copy(comm,1,p1-1);
  operands:=copy(comm,p1+1,p2-p1-1);
  command:=uppercase(Command);
end;
function GDBcommandmanager.FindCommand(command:GDBString):PCommandObjectDef;
var
   p:PCommandObjectDef;
   ir:itrec;
begin
   p:=beginiterate(ir);
   if p<>nil then
   repeat
         if uppercase(p^.CommandName)=command then
                                                  begin
                                                       result:=p;
                                                       exit;
                                                  end;

         p:=iterate(ir);
   until p=nil;
   result:=nil;
end;
procedure GDBcommandmanager.run(pc:PCommandObjectDef;operands:GDBString);
begin
          if pcommandrunning<>nil then
                                      begin
                                           if pc^.overlay then
                                                              begin
                                                                   if CommandsStack.IsObjExist(pc)
                                                                   then
                                                                       self.executecommandtotalend
                                                                   else
                                                                       begin
                                                                            CommandsStack.AddRef(pcommandrunning^)
                                                                       end;
                                                              end
                                                          else
                                                              self.executecommandtotalend;
                                      end;
          pcommandrunning := pointer(pc);
          pcommandrunning^.CommandStart(pansichar(operands));
end;
function GDBcommandmanager.execute(const comm:pansichar;silent:GDBBoolean): GDBInteger;
var i,p1,p2: GDBInteger;
    command,operands:GDBString;
    cc:TCStartAttr;
    pfoundcommand:PCommandObjectDef;
    p:pchar;
begin
  if length(comm)>0 then
  if comm[0]<>';' then
  begin
  ParseCommand(comm,command,operands);

  pfoundcommand:=FindCommand(command);

  if pfoundcommand<>nil then
  begin
    begin
      cc:=GetCommandContext;
      if ((cc xor pfoundcommand^.CStartAttrEnableAttr)and pfoundcommand^.CStartAttrEnableAttr)=0
      then
          begin

          //lastcommand := command;

          if silent then
                        programlog.logoutstr('GDBCommandManager.ExecuteCommandSilent('+pfoundcommand^.CommandName+');',0)
                    else
                        begin
                        historyoutstr(S_RunCommand+':'+pfoundcommand^.CommandName);
                        lastcommand := command;
                        end;

          run(pfoundcommand,operands);
          if pcommandrunning<>nil then
                                      if assigned(CLine) then
                                      CLine.SetMode(CLCOMMANDRUN);
          end
     else
         begin
              historyout(@S_CommandNRInC[1]);
         end;
    end;
  end
  else historyout(GDBPointer(S_UnknownCommand+':"'+command+'"'));
  end;
  command:='';
  operands:='';
end;
function GDBcommandmanager.executecommand(const comm:pansichar): GDBInteger;
begin
     if not busy then
                     result:=execute(comm,false)
                 else
                     shared.ShowError({'Команда не может быть выполнена. Идет выполнение сценария'}S_CommandNRInC);
end;
function GDBcommandmanager.executecommandsilent{(const comm:pansichar): GDBInteger};
begin
     if not busy then
     result:=execute(comm,true);
end;
procedure GDBcommandmanager.executecommandend;
var
   temp:PCommandRTEdObjectDef;
begin
  //ReturnToDefault;
  temp:=pcommandrunning;
  pcommandrunning := nil;
  if temp<>nil then
                   temp^.CommandEnd;
  if pcommandrunning=nil then
  if assigned(cline) then
                   CLine.SetMode(CLCOMMANDREDY);
  if self.CommandsStack.Count>0 then
                                    begin
                                         pcommandrunning:=ppointer(CommandsStack.getelement(CommandsStack.Count-1))^;
                                         dec(CommandsStack.Count);
                                         pcommandrunning.CommandContinue;
                                    end
                                else
                                    begin
                                         self.DMHide;
                                         self.DMClear;
                                    end;
   ContextCommandParams:=nil;

end;
procedure GDBcommandmanager.executecommandtotalend;
var
   temp:PCommandRTEdObjectDef;
begin
  //ReturnToDefault;
  self.DMHide;
  self.DMClear;

  temp:=pcommandrunning;
  pcommandrunning := nil;
  if temp<>nil then
                   temp^.CommandEnd;
  if pcommandrunning=nil then
                             if assigned(CLine)then
                             CLine.SetMode(CLCOMMANDREDY);
  CommandsStack.Clear;
  ContextCommandParams:=nil;
end;
function GDBcommandmanager.executelastcommad: GDBInteger;
begin
  result:=executecommand(@lastcommand[1]);
end;
constructor GDBcommandmanager.init;
begin
  inherited init({$IFDEF DEBUGBUILD}'{8B10F808-46AD-4EF1-BCDD-55B74D27187B}',{$ENDIF}m);
  CommandsStack.init({$IFDEF DEBUGBUILD}'{8B10F808-46AD-4EF1-BCDD-55B74D27187B}',{$ENDIF}10);
  varstack.init;
end;
procedure GDBcommandmanager.CommandRegister(pc:PCommandObjectDef);
begin
  if count=max then exit;
  add(@pc);
end;
procedure comdeskclear(p:GDBPointer);
begin
     {pvardesk(p)^.name:='';
     pvardesk(p)^.vartype:=0;
     pvardesk(p)^.vartypecustom:=0;
     gdbfreemem(pvardesk(p)^.pvalue);}
end;
destructor GDBcommandmanager.done;
begin
     {self.freewithprocanddone(comdeskclear);}
     lastcommand:='';
     inherited done;
     CommandsStack.done;
     varstack.Done;
end;
{procedure startup;
begin
  commandmanager.init(1000);
end;
procedure finalize;
begin
  commandmanager.FreeAndDone;
end;}
initialization
     {$IFDEF DEBUGINITSECTION}LogOut('commandline.initialization');{$ENDIF}
     commandmanager.init(1000);
finalization
     commandmanager.FreeAndDone;
end.
