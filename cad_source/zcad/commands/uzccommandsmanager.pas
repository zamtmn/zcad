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

unit uzccommandsmanager;
{$INCLUDE zengineconfig.inc}
{$interfaces corba}
interface
uses gzctnrVectorPObjects,uzcsysvars,uzegeometry,uzglviewareaabstract,uzbpaths,
     uzeconsts,uzcctrldynamiccommandmenu,uzcinfoform,uzcstrconsts,uzcsysinfo,
     gzctnrVectorTypes,uzegeometrytypes,uzbstrproc,gzctnrVectorP,
     uzccommandsabstract, sysutils,uzglviewareadata,
     uzclog,varmandef,varman,uzedrawingdef,uzcinterface,
     uzcsysparams,uzedrawingsimple,uzcdrawings,uzctnrvectorstrings,forms,
     uzcctrlcommandlineprompt,uzeparsercmdprompt,gzctnrSTL,uzeSnap;
const
     tm:tmethod=(Code:nil;Data:nil);
     nullmethod:{tmethod}TButtonMethod=nil;
type
  ICommandLinePrompt=interface
    procedure SetPrompt(APrompt:String);overload;
    procedure SetPrompt(APrompt:TParserCommandLinePrompt.TGeneralParsedText);overload;
  end;
  TICommandLinePromptVector=TMyVector<ICommandLinePrompt>;
  TGetResult=(GRCancel,GRNormal,GRId,GRInput);
  tvarstack=object({varmanagerdef}varmanager)
            end;
  TOnCommandRun=procedure(command:string) of object;

  TZctnrPCommandObjectDef=object(GZVectorP{-}<PCommandObjectDef>{//}) //TODO:почемуто не работают синонимы с объектами, приходится наследовать
                                                         //TODO:надо тут поменять GZVectorP на GZVectorSimple
                    end;

  GDBcommandmanager=object({TZctnrVectorPGDBaseObjects}GZVectorPObects{-}<PCommandObjectDef,CommandObjectDef>{//})

                          lastcommand:String;
                          pcommandrunning:PCommandRTEdObjectDef;

                          LatestRunPC:PCommandObjectDef;
                          LatestRunOperands:String;
                          LatestRunPDrawing:PTDrawingDef;

                          CommandsStack:{TZctnrVectorPointer}TZctnrPCommandObjectDef;
                          ContextCommandParams:Pointer;
                          busy:Boolean;
                          varstack:tvarstack;
                          DMenu:TDMenuWnd;
                          OnCommandRun:TOnCommandRun;
                          DisableExecuteCommandEndCounter:integer;
                          DisabledExecuteCommandEndCounter:integer;
                          SilentCounter:Integer;
                          CommandLinePrompts:TICommandLinePromptVector;
                          CurrentPrompt:TParserCommandLinePrompt.TGeneralParsedText;
                          constructor init(m:Integer);
                          procedure execute(const comm:string;silent:Boolean;pdrawing:PTDrawingDef;POGLWndParam:POGLWndtype);virtual;
                          procedure executecommand(const comm:string;pdrawing:PTDrawingDef;POGLWndParam:POGLWndtype);virtual;
                          procedure executecommandsilent(const comm:pansichar;pdrawing:PTDrawingDef;POGLWndParam:POGLWndtype);virtual;
                          procedure DisableExecuteCommandEnd;virtual;
                          procedure EnableExecuteCommandEnd;virtual;
                          function hasDisabledExecuteCommandEnd:boolean;virtual;
                          procedure resetDisabledExecuteCommandEnd;virtual;
                          procedure executecommandend;virtual;
                          function GetSavedMouseMode:Byte;
                          procedure executecommandtotalend;virtual;
                          procedure ChangeModeAndEnd(newmode:TGetPointMode);
                          procedure executefile(fn:String;pdrawing:PTDrawingDef;POGLWndParam:POGLWndtype);virtual;
                          procedure executelastcommad(pdrawing:PTDrawingDef;POGLWndParam:POGLWndtype);virtual;
                          procedure sendpoint2command(p3d:gdbvertex; p2d:gdbvertex2di; var mode:Byte;osp:pos_record;const drawing:TDrawingDef);virtual;
                          procedure CommandRegister(pc:PCommandObjectDef);virtual;
                          procedure run(pc:PCommandObjectDef;operands:String;pdrawing:PTDrawingDef);virtual;
                          destructor done;virtual;
                          procedure cleareraseobj;virtual;
                          procedure DMShow;
                          procedure DMHide;
                          procedure DMClear;
                          //-----------------------------------------------------------------procedure DMAddProcedure(Text,HText:String;proc:TonClickProc);
                          procedure DMAddMethod(Text,HText:String;FMethod:TButtonMethod);
                          procedure DMAddProcedure(Text,HText:String;FProc:TButtonProc);
                          function FindCommand(command:String):PCommandObjectDef;
                          procedure PushValue(varname,vartype:String;instance:Pointer);virtual;
                          function PopValue:vardesk;virtual;
                          function GetValue:vardesk;virtual;
                          function GetValueHeap:Integer;
                          function CurrentCommandNotUseCommandLine:Boolean;
                          procedure PrepairVarStack;

                          function Get3DPoint(prompt:String;out p:GDBVertex):TGetResult;
                          function Get3DPointWithLineFromBase(prompt:String;const base:GDBVertex;out p:GDBVertex):TGetResult;
                          function GetEntity(prompt:String;out p:Pointer):Boolean;
                          function Get3DPointInteractive(prompt:String;out p:GDBVertex;const InteractiveProc:TInteractiveProcObjBuild;const PInteractiveData:Pointer):TGetResult;
                          function GetInput(Prompt:String;out Input:String):TGetResult;

                          function GetLastId:TTag;
                          function GetLastInput:AnsiString;

                          function ChangeInputMode(incl,excl:TGetInputMode):TGetInputMode;
                          function SetInputMode(NewMode:TGetInputMode):TGetInputMode;

                          function EndGetPoint(newmode:TGetPointMode):Boolean;

                          procedure sendmousecoord(Sender:TAbstractViewArea;key: Byte);
                          procedure sendmousecoordwop(Sender:TAbstractViewArea;key: Byte);
                          procedure sendcoordtocommand(Sender:TAbstractViewArea;coord:GDBVertex;key: Byte);
                          procedure sendcoordtocommandTraceOn(Sender:TAbstractViewArea;coord:GDBVertex;key: Byte;pos:pos_record);

                          procedure PromptTagNotufy(Tag:TTag);


                          procedure AddClPrompt(CLP:ICommandLinePrompt);
                          procedure RemoveClPrompt(CLP:ICommandLinePrompt);
                          procedure SetPrompt(APrompt:String);overload;
                          procedure SetPrompt(APrompt:TParserCommandLinePrompt.TGeneralParsedText);overload;

                    end;
var CommandManager:GDBcommandmanager;
function getcommandmanager:Pointer;export;
function GetCommandContext(pdrawing:PTDrawingDef;POGLWnd:POGLWndtype):TCStartAttr;
procedure ParseCommand(comm:string; out command,operands:String);
{procedure startup;
procedure finalize;}
implementation
procedure GDBcommandmanager.AddClPrompt(CLP:ICommandLinePrompt);
begin
  if CommandLinePrompts=nil then
    CommandLinePrompts:=TICommandLinePromptVector.Create;
  CommandLinePrompts.PushBack(CLP);
end;

procedure GDBcommandmanager.RemoveClPrompt(CLP:ICommandLinePrompt);
var
   i:integer;
begin
  if CommandLinePrompts<>nil then
    for i:=CommandLinePrompts.Size-1 downto 0 do
       if CommandLinePrompts[i]=CLP then
         CommandLinePrompts.Erase(i);
end;

procedure GDBcommandmanager.SetPrompt(APrompt:String);
var
   i:integer;
begin
  CurrentPrompt:=nil;
  if CommandLinePrompts<>nil then
    for i:=0 to CommandLinePrompts.Size-1 do
       CommandLinePrompts[i].SetPrompt(APrompt);
end;

procedure GDBcommandmanager.SetPrompt(APrompt:TParserCommandLinePrompt.TGeneralParsedText);
var
   i:integer;
begin
  CurrentPrompt:=APrompt;
  if CommandLinePrompts<>nil then
    for i:=0 to CommandLinePrompts.Size-1 do
       CommandLinePrompts[i].SetPrompt(APrompt);
end;

procedure GDBcommandmanager.PromptTagNotufy(Tag:TTag);
begin
  if pcommandrunning<>nil then begin
    if (pcommandrunning^.IData.GetPointMode in SomethingWait)and(GPID in pcommandrunning^.IData.PossibleResult) then begin
      pcommandrunning^.IData.GetPointMode:=TGPMId;
      pcommandrunning^.IData.Id:=Tag;
    end;
  end;
end;

procedure GDBcommandmanager.sendcoordtocommandTraceOn(Sender:TAbstractViewArea;coord:GDBVertex;key: Byte;pos:pos_record);
var
   cs:integer;
begin
     //if .pcommandrunning<>nil then
     //if .pcommandrunning.IsRTECommand then
    cs:=CommandsStack.Count;
        sendpoint2command(coord,sender.param.md.mouse,key,pos,sender.pdwg^);

     if (key and MZW_LBUTTON)<>0 then
     if (pcommandrunning<>nil)and(cs=CommandsStack.Count) then
     begin
           inc(sender.tocommandmcliccount);
           sender.param.ontrackarray.otrackarray[0].worldcoord:=coord;
           sender.param.lastpoint:=coord;
           sender.create0axis;
           sender.project0axis;
     end;
     //end;
end;

procedure GDBcommandmanager.sendcoordtocommand(Sender:TAbstractViewArea;coord:GDBVertex;key: Byte);
begin
     if key=MZW_LBUTTON then Sender.param.lastpoint:=coord;
     sendpoint2command(coord, sender.param.md.mouse, key,nil,sender.pdwg^);
end;
procedure GDBcommandmanager.sendmousecoord(Sender:TAbstractViewArea;key: Byte);
begin
  if pcommandrunning <> nil then
    if sender.param.md.mouseonworkplan
    then
        begin
             sendcoordtocommand(sender,sender.param.md.mouseonworkplanecoord,key);
             //if key=MZW_LBUTTON then wa.param.lastpoint:=wa.param.md.mouseonworkplanecoord;
             //.pcommandrunning^.MouseMoveCallback(wa.param.md.mouseonworkplanecoord, wa.param.md.mouse, key,nil)
        end
    else
        begin
             sendcoordtocommand(sender,sender.param.md.mouseray.lbegin,key);
             //if key=MZW_LBUTTON then wa.param.lastpoint:=wa.param.md.mouseray.lbegin;
             //.pcommandrunning^.MouseMoveCallback(wa.param.md.mouseray.lbegin, wa.param.md.mouse, key,nil);
        end;
    //if key=MZW_LBUTTON then wa.param.ontrackarray.otrackarray[0].worldcoord:=wa.param.md.mouseonworkplanecoord;
end;
procedure GDBcommandmanager.sendmousecoordwop(Sender:TAbstractViewArea;key: Byte);
var
   tv:gdbvertex;
begin
  if pcommandrunning <> nil then
    if sender.param.ospoint.ostype <> os_none
    then
    begin
         begin
              {if (key and MZW_LBUTTON)<>0 then
                                              HistoryOutStr(floattostr(wa.param.ospoint.ostype));}
              tv:=sender.param.ospoint.worldcoord;
              if (key and MZW_SHIFT)<>0 then
                                            begin
                                                 key:=key and (not MZW_SHIFT);
                                                 tv:=Vertexmorphabs(sender.param.lastpoint,sender.param.ospoint.worldcoord,1);
                                            end;
              if (key and MZW_CONTROL)<>0 then
                                            begin
                                                 key:=key and (not MZW_CONTROL);
                                                 tv:=Vertexmorphabs(sender.param.lastpoint,sender.param.ospoint.worldcoord,-1);
                                            end;
              key:=key and (not MZW_CONTROL);
              key:=key and (not MZW_SHIFT);

              {if key=MZW_LBUTTON then
                                     begin
                                          inc(tocommandmcliccount);
                                          wa.param.ontrackarray.otrackarray[0].worldcoord:=tv;
                                     end;
              if (key and MZW_LBUTTON)<>0 then
                                              wa.param.lastpoint:=tv;
              .pcommandrunning^.MouseMoveCallback(tv, wa.param.md.mouse, key,@wa.param.ospoint);}

              sendcoordtocommandTraceOn(sender,tv,key,@sender.param.ospoint)
         end;
    end
    else
    begin
        {if key=MZW_LBUTTON then
                               begin
                               inc(tocommandmcliccount);
                               wa.param.ontrackarray.otrackarray[0].worldcoord:=wa.param.md.mouseonworkplanecoord;
                               end;}
        if sender.param.md.mouseonworkplan
        then
            begin
                 if sysvar.DWG.DWG_SnapGrid<>nil then
                 if not sysvar.DWG.DWG_SnapGrid^ then
                 sender.param.ospoint.worldcoord:=sender.param.md.mouseonworkplanecoord;
                 sendcoordtocommandTraceOn({wa.param.md.mouseonworkplanecoord}sender,sender.param.ospoint.worldcoord,key,nil)
                 //if key=MZW_LBUTTON then wa.param.lastpoint:=wa.param.md.mouseonworkplanecoord;
                 //.pcommandrunning.MouseMoveCallback(wa.param.md.mouseonworkplanecoord, wa.param.md.mouse, key,nil)
            end
        else
            begin
                 sender.param.ospoint.worldcoord:=sender.param.md.mouseray.lbegin;
                 sendcoordtocommandTraceOn(sender,sender.param.md.mouseray.lbegin,key,nil)
                 //if key=MZW_LBUTTON then wa.param.lastpoint:=wa.param.md.mouseray.lbegin;
                 //.pcommandrunning^.MouseMoveCallback(wa.param.md.mouseray.lbegin, wa.param.md.mouse, key,nil);
            end;
    end;
end;
function GDBcommandmanager.EndGetPoint(newmode:TGetPointMode):Boolean;
begin
  if pcommandrunning<>nil then
  begin
  if (pcommandrunning^.IData.GetPointMode=TGPMWait)or(pcommandrunning^.IData.GetPointMode=TGPMWaitEnt)or(pcommandrunning^.IData.GetPointMode=TGPMWaitInput) then
                              begin
                                  pcommandrunning^.IData.GetPointMode:=newmode;
                                  result:=true;
                              end
                          else
                              result:=false;
  end
     else
                              result:=false;
end;
function GDBcommandmanager.Get3DPointInteractive(prompt:String;out p:GDBVertex;const InteractiveProc:TInteractiveProcObjBuild;const PInteractiveData:Pointer):TGetResult;
var
   savemode:Byte;//variable to store the current mode of the editor
                     //переменная для сохранения текущего режима редактора
begin
  //PTSimpleDrawing(pcommandrunning.pdwg)^.wa.asyncupdatemouse(0);
  Application.QueueAsyncCall(PTSimpleDrawing(pcommandrunning.pdwg)^.wa.asyncupdatemouse,0);
  savemode:=PTSimpleDrawing(pcommandrunning.pdwg)^.DefMouseEditorMode(MGet3DPoint or MGet3DPointWoOP,//set mode point of the mouse
                                                                                                     //устанавливаем режим указания точек мышью
                                                                      MGetControlpoint or MGetSelectionFrame or MGetSelectObject);//reset selection entities  mode
                                                                                                              //сбрасываем режим выбора примитивов мышью
  if prompt<>'' then
    ZCMsgCallBackInterface.TextMessage(prompt,TMWOHistoryOut);
  pcommandrunning^.IData.GetPointMode:=TGPMWait;
  pcommandrunning^.IData.PInteractiveData:=PInteractiveData;
  pcommandrunning^.IData.PInteractiveProc:=InteractiveProc;

  while (pcommandrunning^.IData.GetPointMode=TGPMWait)and(not Application.Terminated) do
  begin
       Application.HandleMessage;
       //Application.ProcessMessages;
  end;

  if (pcommandrunning^.IData.GetPointMode=TGPMPoint)and(not Application.Terminated) then begin
    p:=pcommandrunning^.IData.GetPointValue;
    result:=GRNormal;
  end else if (pcommandrunning^.IData.GetPointMode=TGPMId)and(not Application.Terminated) then begin
    p:=InfinityVertex;
    result:=GRId;
  end else if (pcommandrunning^.IData.GetPointMode=TGPMInput)and(not Application.Terminated) then begin
    p:=InfinityVertex;
    result:=GRInput;
  end else
    result:=GRCancel;

  if (pcommandrunning^.IData.GetPointMode<>TGPMCloseDWG)then
  PTSimpleDrawing(pcommandrunning.pdwg)^.SetMouseEditorMode(savemode);//restore editor mode
                                                                      //восстанавливаем сохраненный режим редактора
end;
function GDBcommandmanager.GetLastId:TTag;
begin
  if pcommandrunning<>nil then
    result:=pcommandrunning^.IData.Id
  else
    result:=WrongId;
end;
function GDBcommandmanager.GetLastInput:AnsiString;
begin
  if pcommandrunning<>nil then
    result:=pcommandrunning^.IData.Input
  else
    result:='';
end;
function GDBcommandmanager.ChangeInputMode(incl,excl:TGetInputMode):TGetInputMode;
begin
  if pcommandrunning<>nil then begin
    result:=pcommandrunning^.IData.InputMode;
    pcommandrunning^.IData.InputMode:=pcommandrunning^.IData.InputMode+incl;
    pcommandrunning^.IData.InputMode:=pcommandrunning^.IData.InputMode-excl;
  end
  else
    result:=[];
end;
function GDBcommandmanager.SetInputMode(NewMode:TGetInputMode):TGetInputMode;
begin
  if pcommandrunning<>nil then begin
    result:=pcommandrunning^.IData.InputMode;
    pcommandrunning^.IData.InputMode:=NewMode;
  end
  else
    result:=[];
end;

function GDBcommandmanager.GetInput(Prompt:String;out Input:String):TGetResult;
var
   savemode:Byte;//variable to store the current mode of the editor
                     //переменная для сохранения текущего режима редактора
begin
  savemode:=PTSimpleDrawing(pcommandrunning.pdwg)^.DefMouseEditorMode({MGet3DPoint or MGet3DPointWoOP}0,//set mode point of the mouse
                                                                                                     //устанавливаем режим указания точек мышью
                                                                      MGetControlpoint or MGetSelectionFrame or MGetSelectObject);//reset selection entities  mode
                                                                                                              //сбрасываем режим выбора примитивов мышью
  if prompt<>'' then
    ZCMsgCallBackInterface.TextMessage(prompt,TMWOHistoryOut);
  pcommandrunning^.IData.GetPointMode:=TGPMWaitInput;
  pcommandrunning^.IData.PInteractiveData:=nil;
  pcommandrunning^.IData.PInteractiveProc:=nil;
  while (pcommandrunning^.IData.GetPointMode=TGPMWaitInput)and(not Application.Terminated) do
  begin
       Application.HandleMessage;
       //Application.ProcessMessages;
  end;
  if (pcommandrunning^.IData.GetPointMode=TGPMInput)and(not Application.Terminated) then begin
    Input:=pcommandrunning^.IData.Input;
    result:=GRNormal;
  end else if (pcommandrunning^.IData.GetPointMode=TGPMId)and(not Application.Terminated) then begin
    Input:='';
    result:=GRId;
  end else begin
    Input:='';
    result:=GRCancel;
  end;
  if (pcommandrunning^.IData.GetPointMode<>TGPMCloseDWG)then
  PTSimpleDrawing(pcommandrunning.pdwg)^.SetMouseEditorMode(savemode);//restore editor mode
                                                                      //восстанавливаем сохраненный режим редактора
end;

function GDBcommandmanager.Get3DPoint(prompt:String;out p:GDBVertex):TGetResult;
begin
  result:=Get3DPointInteractive(prompt,p,nil,nil);
end;

function GDBcommandmanager.Get3DPointWithLineFromBase(prompt:String;const base:GDBVertex;out p:GDBVertex):TGetResult;
begin
  pcommandrunning^.IData.BasePoint:=base;
  pcommandrunning^.IData.DrawFromBasePoint:=true;
  result:=Get3DPointInteractive(prompt,p,nil,nil);
  pcommandrunning^.IData.DrawFromBasePoint:=False;
end;
function GDBcommandmanager.GetEntity(prompt:String;out p:Pointer):Boolean;
var
   savemode:Byte;
begin
  savemode:=PTSimpleDrawing(pcommandrunning.pdwg)^.DefMouseEditorMode(MGetSelectObject,
                                                                      MGet3DPoint or MGet3DPointWoOP or MGetSelectionFrame or MGetControlpoint);
  ZCMsgCallBackInterface.TextMessage(prompt,TMWOHistoryOut);
  pcommandrunning^.IData.GetPointMode:=TGPMWaitEnt;
  pcommandrunning^.IData.PInteractiveData:=nil;
  pcommandrunning^.IData.PInteractiveProc:=nil;
  while (pcommandrunning^.IData.GetPointMode=TGPMWaitEnt)and(not Application.Terminated) do
  begin
       Application.HandleMessage;
       //Application.ProcessMessages;
  end;
  if (pcommandrunning^.IData.GetPointMode=TGPMEnt)and(not Application.Terminated) then
                                                                                 begin
                                                                                 p:=PTSimpleDrawing(pcommandrunning.pdwg)^.wa.param.SelDesc.LastSelectedObject;
                                                                                 result:=true;
                                                                                 end
                                                                             else
                                                                                 begin
                                                                                 result:=false;
                                                                                 //HistoryOutStr('cancel');
                                                                                 end;
  PTSimpleDrawing(pcommandrunning.pdwg)^.SetMouseEditorMode(savemode);//restore editor mode
                                                                      //восстанавливаем сохраненный режим редактора
end;

function GDBcommandmanager.GetValueHeap:Integer;
begin
     result:=varstack.vardescarray.count;
end;
function GDBcommandmanager.CurrentCommandNotUseCommandLine:Boolean;
begin
     if pcommandrunning<>nil then
                                 result:=pcommandrunning.NotUseCommandLine
                             else
                                 result:=true;
end;

procedure GDBcommandmanager.PushValue(varname,vartype:String;instance:Pointer);
var
   vd: vardesk;
begin
     vd.name:=varname;
     //vd.Instance:=instance;
     vd.data.PTD:=SysUnit.TypeName2PTD(vartype);
     vd.SetInstance(nil);
     //vd.Instance:=nil;
     varstack.createvariable(varname,vd);
     vd.data.PTD.CopyInstanceTo(instance,vd.data.Addr.Instance);
end;
function GDBcommandmanager.GetValue:vardesk;
var
lastelement:pvardesk;
begin
     lastelement:=pvardesk(varstack.vardescarray.getDataMutable(varstack.vardescarray.Count-1));
     result:=lastelement^;
end;

function GDBcommandmanager.PopValue:vardesk;
var
lastelement:pvardesk;
begin
     lastelement:=pvardesk(varstack.vardescarray.getDataMutable(varstack.vardescarray.Count-1));
     dec(varstack.vardescarray.Count);
     result:=lastelement^;
     lastelement.name:='';
     lastelement.username:='';
     lastelement.data.PTD:=nil;
     lastelement.SetInstance(nil);
     //lastelement.Instance:=nil;
end;

function getcommandmanager:Pointer;
begin
     result:=@commandmanager;
end;
procedure GDBcommandmanager.DMShow;
begin
     //if assigned(cline) then
     if assigned({CLine.}DMenu) then
     begin
     //CLine.DMenu.ajustsize;
     {CLine.}DMenu.Show;
     end;
end;
procedure GDBcommandmanager.DMHide;
begin
     //if assigned(cline) then
     if assigned({CLine.}DMenu) then
     {CLine.}DMenu.Hide;
end;
procedure GDBcommandmanager.DMClear;
begin
     //if assigned(cline) then
     if assigned({CLine.}DMenu) then
     {CLine.}DMenu.clear;
end;
{procedure GDBcommandmanager.DMAddProcedure(Text,HText:String;proc:TonClickProc);
begin
     if assigned(cline) then
     if assigned(CLine.DMenu) then
     CLine.DMenu.AddProcedure(Text,HText,Proc);
end;}
procedure GDBcommandmanager.DMAddProcedure;
begin
     //if assigned(cline) then
     if assigned({CLine.}DMenu) then
     {CLine.}DMenu.AddProcedure(Text,HText,FProc);
end;

procedure GDBcommandmanager.DMAddMethod;
begin
     //if assigned(cline) then
     if assigned({CLine.}DMenu) then
     {CLine.}DMenu.AddMethod(Text,HText,FMethod);
end;


procedure GDBcommandmanager.executefile;
var
   sa:TZctnrVectorStrings;
   p:pstring;
   ir:itrec;
   oldlastcomm:String;
   s:String;
begin
     s:=(ExpandPath(fn));
     ZCMsgCallBackInterface.TextMessage(sysutils.format(rsRunScript,[s]),TMWOHistoryOut);
     busy:=true;

     //DisableCmdLine;
     ZCMsgCallBackInterface.Do_GUIMode({ZMsgID_GUIDisableCMDLine}ZMsgID_GUIDisable);

     oldlastcomm:=lastcommand;
     sa.init(200);
     sa.loadfromfile(s);
     //sa.getString(1);
  p:=sa.beginiterate(ir);
  if p<>nil then
  repeat
        if (uppercase(pString(p)^)<>'ABOUT')then
                                                    execute(p^,false,{pdrawing}drawings.GetCurrentDWG,POGLWndParam)
                                                else
                                                    begin
                                                         if not sysparam.saved.nosplash then
                                                         if sysparam.notsaved.preloadedfile='' then
                                                                                      execute(p^,false,pdrawing,POGLWndParam)
                                                    end;
        p:=sa.iterate(ir);
  until p=nil;
  sa.Done;
  lastcommand:=oldlastcomm;

     //EnableCmdLine;
     ZCMsgCallBackInterface.Do_GUIMode({ZMsgID_GUIEnableCMDLine}ZMsgID_GUIEnable);
     ZCMsgCallBackInterface.Do_GUIMode(ZMsgID_GUICMDLineCheck);
     busy:=false;
end;
procedure GDBcommandmanager.sendpoint2command;
var
   p:PCommandRTEdObjectDef;
   ir:itrec;
begin
     if pcommandrunning <> nil then
     if pcommandrunning^.pdwg={gdb.GetCurrentDWG}@drawing then
     if pcommandrunning.IsRTECommand then
     begin
          pcommandrunning^.MouseMoveCallback(p3d,p2d,mode,osp);
     end
     else if pcommandrunning^.IData.GetPointMode=TGPMWait then
                                      begin
                                           if mode=MZW_LBUTTON then
                                           begin
                                                if assigned(pcommandrunning^.IData.PInteractiveProc) then
                                                pcommandrunning^.IData.PInteractiveProc(pcommandrunning^.IData.PInteractiveData,p3d,true);
                                                pcommandrunning^.IData.GetPointMode:=TGPMpoint;
                                                pcommandrunning^.IData.GetPointValue:=p3d;
                                           end
                                           else
                                             begin
                                               pcommandrunning^.IData.currentPointValue:=p3d;
                                               if assigned(pcommandrunning^.IData.PInteractiveProc) then
                                                pcommandrunning^.IData.PInteractiveProc(pcommandrunning^.IData.PInteractiveData,p3d,false);
                                             end;
                                      end;
     //clearotrack;
        p:=CommandsStack.beginiterate(ir);
        if p<>nil then
        repeat
              if p^.pdwg={gdb.GetCurrentDWG}@drawing then
              if p^.IsRTECommand then
                                                       begin
                                                            (p)^.MouseMoveCallback(p3d,p2d,mode,osp);
                                                       end;

              p:=CommandsStack.iterate(ir);
        until p=nil;
end;
procedure GDBcommandmanager.cleareraseobj;
var p:PCommandObjectDef;
    ir:itrec;
begin
  p:=beginiterate(ir);
  if p<>nil then
  repeat
       p^.done;
       if p^.dyn then Freemem(Pointer(p));
       p:=iterate(ir);
  until p=nil;
  count:=0;
end;
function GetCommandContext(pdrawing:PTDrawingDef;POGLWnd:POGLWndtype):TCStartAttr;
begin
     result:=0;
     if pdrawing<>nil then
                          begin
                               result:=result or CADWG;
                               if pdrawing^.CanRedo then
                                                        result:=result or CACanRedo;
                               if pdrawing^.CanUndo then
                                                        result:=result or CACanUndo;
                               if pdrawing^.GetChangeStampt then
                                                                result:=result or CADWGChanged;
                               if pdrawing^.GetConstructEntsCount>0 then
                                 result:=result or CAConstructRootNotEmpty;
                          end;
     if POGLWnd<>nil then
                         begin
                              if POGLWnd^.SelDesc.Selectedobjcount=1 then
                                                                         result:=result or CASelEnt;
                              if POGLWnd^.SelDesc.Selectedobjcount>0 then
                                                                         result:=result or CASelEnts;
                         end;
     if commandmanager.pcommandrunning<>nil then
       result:=result or CAOtherCommandRun;
end;
procedure ParseCommand(comm:string; out command,operands:String);
var
   {i,}p1,p2: Integer;
begin
  p1:=pos('(',comm);
  if  p1<1 then begin
    p1:=length(comm)+1;
    p2:=p1;
  end else begin
    p2:=PosWithBracket(')','(',')',comm,p1+1,1);
    //p2:=PosWithBracket(')',comm);
  end;
  command:=copy(comm,1,p1-1);
  operands:=copy(comm,p1+1,p2-p1-1);
  command:=uppercase(Command);
end;
function GDBcommandmanager.FindCommand(command:String):PCommandObjectDef;
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
procedure GDBcommandmanager.run(pc:PCommandObjectDef;operands:String;pdrawing:PTDrawingDef);
var
   pd:PTSimpleDrawing;
begin
   pd:={gdb.GetCurrentDWG}PTSimpleDrawing(pdrawing);
   if pd<>nil then
   if ((pc^.CEndActionAttr)and CEDWGNChanged)=0 then
                                                   pd.ChangeStampt(true);
          if pcommandrunning<>nil then
                                      begin
                                           if pc^.overlay then
                                                              begin
                                                                   if CommandsStack.IsDataExist(pc)<>-1
                                                                   then
                                                                       self.executecommandtotalend
                                                                   else
                                                                       begin
                                                                            CommandsStack.pushbackdata(@pcommandrunning^)
                                                                       end;
                                                              end
                                                          else
                                                              begin
                                                                      if EndGetPoint(TGPMOtherCommand) then
                                                                       begin
                                                                            LatestRunPC:=pc;
                                                                            LatestRunOperands:=operands;
                                                                            LatestRunPDrawing:=pdrawing;

                                                                            exit;
                                                                       end;
                                                              self.executecommandtotalend;

                                                              end;
                                      end;
          pcommandrunning := pointer(pc);
          pcommandrunning^.pdwg:=pd;
          pcommandrunning^.CommandStart(pansichar(operands));
end;
procedure GDBcommandmanager.execute(const comm:string;silent:Boolean;pdrawing:PTDrawingDef;POGLWndParam:POGLWndtype);
var //i,p1,p2: Integer;
    command,operands:String;
    cc:TCStartAttr;
    pfoundcommand:PCommandObjectDef;
    //p:pchar;
begin
  if length(comm)>0 then
  if comm[1]<>';' then
  begin
  ParseCommand(comm,command,operands);

  pfoundcommand:=FindCommand(command);

  if pfoundcommand<>nil then
  begin
    begin
      cc:=GetCommandContext(pdrawing,POGLWndParam);
      if ((cc xor pfoundcommand^.CStartAttrEnableAttr)and pfoundcommand^.CStartAttrEnableAttr)=0
      then
          begin

          //lastcommand := command;

          if silent then begin
                        programlog.LogOutFormatStr('GDBCommandManager.ExecuteCommandSilent(%s)',[pfoundcommand^.CommandName],LM_Info);
                        inc(SilentCounter);
                    end else
                        begin
                        ZCMsgCallBackInterface.TextMessage(rsRunCommand+':'+pfoundcommand^.CommandName,TMWOHistoryOut);
                        lastcommand := command;
                        if not (busy) then
                        if assigned(OnCommandRun) then
                                                      OnCommandRun(command);
                        end;

          run(pfoundcommand,operands,pdrawing);
          if pcommandrunning<>nil then
                                      ZCMsgCallBackInterface.Do_GUIMode(ZMsgID_GUICMDLineRunMode);
                                      {if assigned(SetCommandLineMode) then
                                      SetCommandLineMode(CLCOMMANDRUN);}
          end
     else
         begin
              ZCMsgCallBackInterface.TextMessage(format(rsCommandNRInC,[comm]),TMWOHistoryOut);
         end;
    end;
  end
  else ZCMsgCallBackInterface.TextMessage(rsUnknownCommand+':"'+command+'"',TMWOHistoryOut);
  end;
  command:='';
  operands:='';
  if silent then
    dec(SilentCounter);
end;
procedure GDBcommandmanager.executecommand(const comm:string;pdrawing:PTDrawingDef;POGLWndParam:POGLWndtype);
begin
     if not busy then
                     execute(comm,false,pdrawing,POGLWndParam)
                 else
                     ZCMsgCallBackInterface.TextMessage(format(rsCommandNRInC,[comm]),TMWOShowError);
end;
procedure GDBcommandmanager.executecommandsilent{(const comm:pansichar): Integer};
begin
     if not busy then
     execute(comm,true,pdrawing,POGLWndParam);
end;
procedure GDBcommandmanager.PrepairVarStack;
var
    ir:itrec;
    pvd:pvardesk;
    value:String;
begin
     if self.varstack.vardescarray.Count<>0 then
     begin
     ZCMsgCallBackInterface.TextMessage(rscmInStackData,TMWOHistoryOut);
     pvd:=self.varstack.vardescarray.beginiterate(ir);
     if pvd<>nil then
     repeat
           value:=pvd.data.PTD.GetValueAsString(pvd.data.Addr.Instance);
           ZCMsgCallBackInterface.TextMessage(pvd.data.PTD.TypeName+':'+value,TMWOHistoryOut);

     pvd:=self.varstack.vardescarray.iterate(ir);
     until pvd=nil;
     end;
     varstack.vardescarray.Clear;
     varstack.vararray.Clear;
end;
procedure GDBcommandmanager.DisableExecuteCommandEnd;
begin
  inc(DisableExecuteCommandEndCounter);
end;
procedure GDBcommandmanager.EnableExecuteCommandEnd;
begin
  dec(DisableExecuteCommandEndCounter)
end;
function GDBcommandmanager.hasDisabledExecuteCommandEnd:boolean;
begin
  result:=DisabledExecuteCommandEndCounter>0;
end;
procedure GDBcommandmanager.resetDisabledExecuteCommandEnd;
begin
  DisabledExecuteCommandEndCounter:=0;
end;
function GDBcommandmanager.GetSavedMouseMode:Byte;
begin
  if pcommandrunning<>nil then
    result:=pcommandrunning.savemousemode
  else
    result:=0;
end;

procedure GDBcommandmanager.executecommandend;
var
   temp:PCommandRTEdObjectDef;
   temp2:PCommandObjectDef;
begin
  if DisableExecuteCommandEndCounter>0 then begin
   inc(DisabledExecuteCommandEndCounter);
   exit;
  end;
  DisabledExecuteCommandEndCounter:=0;
  if EndGetPoint(TGPMCancel) then
                      exit;
  temp:=pcommandrunning;
  pcommandrunning := nil;
  if temp<>nil then
                   temp^.CommandEnd;
  if pcommandrunning=nil then
  //if assigned(cline) then
  //                 CLine.SetMode(CLCOMMANDREDY);
  ZCMsgCallBackInterface.Do_GUIMode(ZMsgID_GUICMDLineReadyMode);
  {if assigned(SetCommandLineMode) then
                   SetCommandLineMode(CLCOMMANDREDY);}
  if self.CommandsStack.Count>0 then
                                    begin
                                         pcommandrunning:=ppointer(CommandsStack.getDataMutable(CommandsStack.Count-1))^;
                                         dec(CommandsStack.Count);
                                         pcommandrunning.CommandContinue;
                                    end
                                else
                                    begin
                                         self.DMHide;
                                         self.DMClear;
                                         PrepairVarStack;
                                    end;
   ContextCommandParams:=nil;
   if LatestRunPC<>nil then
   begin
        temp2:=LatestRunPC;
        LatestRunPC:=nil;
        GDBcommandmanager.run(temp2,LatestRunOperands,LatestRunPDrawing);
   end
   else if pcommandrunning<>nil then if pcommandrunning^.IData.GetPointMode=TGPMCloseApp then
                                        Application.QueueAsyncCall(AppCloseProc, 0);
end;
procedure GDBcommandmanager.ChangeModeAndEnd(newmode:TGetPointMode);
var
   temp:PCommandRTEdObjectDef;
begin
  if EndGetPoint(newmode) then
                      exit;
  self.DMHide;
  self.DMClear;

  temp:=pcommandrunning;
  pcommandrunning := nil;
  if temp<>nil then
                   temp^.CommandEnd;
  if pcommandrunning=nil then
                             ZCMsgCallBackInterface.Do_GUIMode(ZMsgID_GUICMDLineReadyMode);
                             {if assigned(SetCommandLineMode) then
                             SetCommandLineMode(CLCOMMANDREDY);}
  CommandsStack.Clear;
  ContextCommandParams:=nil;
end;

procedure GDBcommandmanager.executecommandtotalend;
begin
  ChangeModeAndEnd(TGPMCancel);
end;
procedure GDBcommandmanager.executelastcommad(pdrawing:PTDrawingDef;POGLWndParam:POGLWndtype);
begin
  executecommand(lastcommand,pdrawing,POGLWndParam);
end;
constructor GDBcommandmanager.init;
var
      pint:PInteger;
begin
  DisableExecuteCommandEndCounter:=0;
  DisabledExecuteCommandEndCounter:=0;
  inherited init(m);
  //pcommandrunning^.GetPointMode:=TGPCancel;
  CommandsStack.init(10);
  varstack.init;
  DMenu:=TDMenuWnd.CreateNew(application);
  if SavedUnit<>nil then
  begin
  pint:=SavedUnit.FindValue('DMenuX').data.Addr.Instance;
  if assigned(pint)then
                       DMenu.Left:=pint^;
  pint:=SavedUnit.FindValue('DMenuY').data.Addr.Instance;
  if assigned(pint)then
                       DMenu.Top:=pint^;
  end;
  SilentCounter:=0;
  CommandLinePrompts:=nil;
end;
procedure GDBcommandmanager.CommandRegister(pc:PCommandObjectDef);
begin
  if count=max then exit;
  PushBackData(pc);
end;
procedure comdeskclear(p:Pointer);
begin
     {pvardesk(p)^.name:='';
     pvardesk(p)^.vartype:=0;
     pvardesk(p)^.vartypecustom:=0;
     Freemem(pvardesk(p)^.pvalue);}
end;
destructor GDBcommandmanager.done;
begin
     {self.freewithprocanddone(comdeskclear);}
     cleareraseobj;
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
  commandmanager.init(1000);
finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],LM_Info,UnitsFinalizeLMId);
  commandmanager.Done;
end.
