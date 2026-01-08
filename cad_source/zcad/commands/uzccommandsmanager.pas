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
{$Mode delphi}
{$INCLUDE zengineconfig.inc}
{$interfaces corba}
interface

uses
  gzctnrVectorPObjects,uzcsysvars,uzegeometry,uzglviewareaabstract,uzbpaths,
  uzeconsts,uzcctrldynamiccommandmenu,uzcinfoform,uzcstrconsts,
  gzctnrVectorTypes,uzegeometrytypes,uzbstrproc,gzctnrVectorP,
  uzccommandsabstract,SysUtils,uzglviewareadata,
  uzclog,uzsbVarmanDef,varman,uzedrawingdef,uzcinterface,
  uzcsysparams,uzedrawingsimple,uzcdrawings,uzctnrvectorstrings,Forms,
  uzcctrlcommandlineprompt,uzeparsercmdprompt,uzeSnap,
  uzeentity,uzgldrawcontext,Classes,
  uzglviewareageneral,uzcdrawing,
  MacroDefIntf,uzmacros;

const
  tm:tmethod=(Code:nil;Data:nil);
  nullmethod:{tmethod}TButtonMethod=nil;

type
  ICommandLinePrompt=interface
    procedure SetPrompt(APrompt:string);overload;
    procedure SetPrompt(APrompt:TParserCommandLinePrompt.TGeneralParsedText);overload;
  end;

  TICommandLinePromptVector=TMyVector<ICommandLinePrompt>;
  TzcInteractiveResult=(IRAbort,IRCancel,IRNormal,IRId,IRInput);
  PzcInteractiveResult=^TzcInteractiveResult;

  tvarstack=object({varmanagerdef}varmanager)
  end;
  TOnCommandRun=procedure(command:string) of object;
  TButtonMethod2=procedure(const Data:TZCADCommandContext) of object;

  TZctnrPCommandObjectDef=object(GZVectorP<PCommandObjectDef>)
    //TODO:почемуто не работают синонимы с объектами, приходится наследовать
    //TODO:надо тут поменять GZVectorP на GZVectorSimple
  end;

  TCmdWithContext=record
    pcommandrunning:PCommandRTEdObjectDef;
    Context:TZCADCommandContext;
  end;

  GDBcommandmanager=object(GZVectorPObects<PCommandObjectDef,CommandObjectDef>)
    lastcommand:string;

    CurrCmd:TCmdWithContext;

    LatestRunPC:PCommandObjectDef;
    LatestRunOperands:string;
    LatestRunPDrawing:PTDrawingDef;

    CommandsStack:TZctnrPCommandObjectDef;
    ContextCommandParams:Pointer;
    busy:integer;
    varstack:tvarstack;
    DMenu:TDMenuWnd;
    OnCommandRun:TOnCommandRun;
    DisableExecuteCommandEndCounter:integer;
    DisabledExecuteCommandEndCounter:integer;
    SilentCounter:integer;
    CommandLinePrompts:TICommandLinePromptVector;
    CurrentPrompt:TParserCommandLinePrompt.TGeneralParsedText;
    currMacros:string;
    function GetState:TzcUIState;
    function isBusy:boolean;
    constructor init(m:integer);
    procedure Execute(const comm:string;
      silent:boolean;pdrawing:PTDrawingDef;POGLWndParam:POGLWndtype);virtual;
    procedure executecommand(
      const comm:string;pdrawing:PTDrawingDef;POGLWndParam:POGLWndtype);virtual;
    procedure executecommandsilent(
      const comm:string;pdrawing:PTDrawingDef;POGLWndParam:POGLWndtype);virtual;
    procedure DisableExecuteCommandEnd;virtual;
    procedure EnableExecuteCommandEnd;virtual;
    function hasDisabledExecuteCommandEnd:boolean;virtual;
    procedure resetDisabledExecuteCommandEnd;virtual;
    procedure executecommandend;virtual;
    function GetSavedMouseMode:byte;
    procedure executecommandtotalend;virtual;
    procedure ChangeModeAndEnd(newmode:TGetPointMode);
    procedure executefile(fn:string;pdrawing:PTDrawingDef;
      POGLWndParam:POGLWndtype);virtual;
    procedure executelastcommad(pdrawing:PTDrawingDef;
      POGLWndParam:POGLWndtype);virtual;
    procedure sendpoint2command(const p3d:TzePoint3d;
      const p2d:TzePoint2i;var mode:byte;osp:pos_record;const drawing:TDrawingDef);virtual;
    procedure CommandRegister(pc:PCommandObjectDef);virtual;
    procedure run(pc:PCommandObjectDef;
      operands:string;pdrawing:PTDrawingDef);virtual;
    procedure done;virtual;
    procedure cleareraseobj;virtual;
    procedure DMShow;
    procedure DMHide;
    procedure DMClear;
    //-----------------------------------------------------------------procedure DMAddProcedure(Text,HText:String;proc:TonClickProc);
    procedure DMAddMethod(Text,HText:string;
      FMethod:TButtonMethod;pcr:PCommandRTEdObjectDef=nil);overload;
    procedure DMAddMethod(Text,HText:string;
      FMethod:TButtonMethod2;pcr:PCommandRTEdObjectDef=nil);overload;
    function FindCommand(command:string):PCommandObjectDef;
    procedure PushValue(varname,vartype:string;
      instance:Pointer);virtual;
    function PopValue:vardesk;virtual;
    function GetValue:vardesk;virtual;
    function GetValueHeap:integer;
    function CurrentCommandNotUseCommandLine:boolean;
    procedure PrepairVarStack;

    function Get3DPoint(prompt:string;out p:TzePoint3d):TzcInteractiveResult;
    function Get3DPointWithLineFromBase(prompt:string;
      const base:TzePoint3d;out p:TzePoint3d):TzcInteractiveResult;
    function GetEntity(prompt:string;out p:Pointer):TzcInteractiveResult;
    function Get3DPointInteractive(prompt:string;
      out p:TzePoint3d;const InteractiveProc:TInteractiveProcObjBuild;
      const PInteractiveData:Pointer;ESP:TEntitySetupProc=nil):TzcInteractiveResult;
    function Get3DAndMoveConstructRootTo(prompt:string;
      out p:TzePoint3d):TzcInteractiveResult;
    function MoveConstructRootTo(prompt:string):TzcInteractiveResult;
    function GetInput(Prompt:string;out Input:string):TzcInteractiveResult;

    function GetLastId:TTag;
    function GetLastInput:ansistring;
    function GetLastPoint:TzePoint3d;

    function ChangeInputMode(
      incl,excl:TGetInputMode):TGetInputMode;
    function SetInputMode(NewMode:TGetInputMode):TGetInputMode;

    function EndGetPoint(newmode:TGetPointMode):boolean;

    procedure sendmousecoord(Sender:TAbstractViewArea;key:byte);
    procedure sendmousecoordwop(Sender:TAbstractViewArea;
      key:byte);
    procedure sendcoordtocommand(Sender:TAbstractViewArea;
      coord:TzePoint3d;key:byte);
    procedure sendcoordtocommandTraceOn(Sender:TAbstractViewArea;
      coord:TzePoint3d;key:byte;pos:pos_record);

    procedure PromptTagNotufy(Tag:TTag);

    function ProcessCommandShortcuts(
      const ShortCut:TShortCut):boolean;


    procedure AddClPrompt(CLP:ICommandLinePrompt);
    procedure RemoveClPrompt(CLP:ICommandLinePrompt);
    procedure SetPrompt(APrompt:string);overload;
    procedure SetPrompt(
      APrompt:TParserCommandLinePrompt.TGeneralParsedText);overload;

    function MacroFuncsCurrentMacrosPath(
      const {%H-}Param:string;const Data:PtrInt;
      var {%H-}Abort:
      boolean):string;
    function MacroFuncsCurrentMacrosFile(
      const {%H-}Param:string;const Data:PtrInt;
      var {%H-}Abort:
      boolean):string;
  end;

var
  CommandManager:GDBcommandmanager;

function getcommandmanager:Pointer;export;
function GetCommandContext(pdrawing:PTDrawingDef;POGLWnd:POGLWndtype):TCStartAttr;
procedure ParseCommand(comm:string;out command,operands:string);

implementation

function GDBcommandmanager.MacroFuncsCurrentMacrosPath(const {%H-}Param:string;
  const Data:PtrInt;
  var {%H-}Abort:boolean):string;
begin
  Result:=ExcludeTrailingPathDelimiter(ExtractFilePath(currMacros));
end;

function GDBcommandmanager.MacroFuncsCurrentMacrosFile(const {%H-}Param:string;
  const Data:PtrInt;
  var {%H-}Abort:boolean):string;
begin
  Result:=ExcludeTrailingPathDelimiter(ExtractFileName(currMacros));
end;

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

function GDBcommandmanager.ProcessCommandShortcuts(const ShortCut:TShortCut):boolean;
var
  Data:TCommandLinePromptOption;
  //ts:TParserCommandLinePrompt.TParserString;
begin
  Result:=False;
  if CurrCmd.pcommandrunning<>nil then
    if CurrCmd.pcommandrunning^.IData.GetPointMode in SomethingWait then
      if IPShortCuts in CurrCmd.pcommandrunning^.IData.InputMode then begin
        Data:=TCommandLinePromptOption.Create(ShortCut);
        CurrentPrompt.Doit(Data);
        Result:=Data.ShortCut<>ShortCut;
        if Result then
          PromptTagNotufy(Data.CurrentTag);
      end;
end;

procedure GDBcommandmanager.SetPrompt(APrompt:string);
var
  i:integer;
begin
  CurrentPrompt:=nil;
  if CommandLinePrompts<>nil then
    for i:=0 to CommandLinePrompts.Size-1 do
      CommandLinePrompts[i].SetPrompt(APrompt);
end;

procedure GDBcommandmanager.SetPrompt(
  APrompt:TParserCommandLinePrompt.TGeneralParsedText);
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
  if CurrCmd.pcommandrunning<>nil then begin
    if (CurrCmd.pcommandrunning^.IData.GetPointMode in SomethingWait)and
      (GPID in CurrCmd.pcommandrunning^.IData.PossibleResult) then begin
      CurrCmd.pcommandrunning^.IData.GetPointMode:=TGPMId;
      CurrCmd.pcommandrunning^.IData.Id:=Tag;
    end;
  end;
end;

procedure GDBcommandmanager.sendcoordtocommandTraceOn(Sender:TAbstractViewArea;
  coord:TzePoint3d;key:byte;pos:pos_record);
var
  cs:integer;
begin
  //if .pcommandrunning<>nil then
  //if .pcommandrunning.IsRTECommand then
  cs:=CommandsStack.Count;
  sendpoint2command(coord,Sender.param.md.mouse,key,pos,Sender.pdwg^);

  if (key and MZW_LBUTTON)<>0 then
    if (CurrCmd.pcommandrunning<>nil)and(cs=CommandsStack.Count) then begin
      Inc(Sender.tocommandmcliccount);
      Sender.param.ontrackarray.otrackarray[0].worldcoord:=coord;
      Sender.param.lastpoint:=coord;
      Sender.create0axis;
      Sender.project0axis;
    end;
  //end;
end;

procedure GDBcommandmanager.sendcoordtocommand(Sender:TAbstractViewArea;
  coord:TzePoint3d;key:byte);
begin
  if key=MZW_LBUTTON then
    Sender.param.lastpoint:=coord;
  sendpoint2command(coord,Sender.param.md.mouse,key,nil,Sender.pdwg^);
end;

procedure GDBcommandmanager.sendmousecoord(Sender:TAbstractViewArea;key:byte);
begin
  if CurrCmd.pcommandrunning<>nil then
    if Sender.param.md.mouseonworkplan then begin
      sendcoordtocommand(Sender,Sender.param.md.mouseonworkplanecoord,key);
      //if key=MZW_LBUTTON then wa.param.lastpoint:=wa.param.md.mouseonworkplanecoord;
      //.pcommandrunning^.MouseMoveCallback(wa.param.md.mouseonworkplanecoord, wa.param.md.mouse, key,nil)
    end else begin
      sendcoordtocommand(Sender,Sender.param.md.mouseray.lbegin,key);
      //if key=MZW_LBUTTON then wa.param.lastpoint:=wa.param.md.mouseray.lbegin;
      //.pcommandrunning^.MouseMoveCallback(wa.param.md.mouseray.lbegin, wa.param.md.mouse, key,nil);
    end;
  //if key=MZW_LBUTTON then wa.param.ontrackarray.otrackarray[0].worldcoord:=wa.param.md.mouseonworkplanecoord;
end;

procedure GDBcommandmanager.sendmousecoordwop(Sender:TAbstractViewArea;key:byte);
var
  tv:TzePoint3d;
begin
  if CurrCmd.pcommandrunning<>nil then
    if Sender.param.ospoint.ostype<>os_none then begin
      begin
              {if (key and MZW_LBUTTON)<>0 then
                                              HistoryOutStr(floattostr(wa.param.ospoint.ostype));}
        tv:=Sender.param.ospoint.worldcoord;
        if (key and MZW_SHIFT)<>0 then begin
          key:=key and (not MZW_SHIFT);
          tv:=
            Vertexmorphabs(Sender.param.lastpoint,Sender.param.ospoint.worldcoord,1);
        end;
        if (key and MZW_ALT)<>0 then begin
          key:=key and (not MZW_CONTROL);
          tv:=
            Vertexmorphabs(Sender.param.lastpoint,Sender.param.ospoint.worldcoord,-1);
        end;
        key:=key and (not MZW_ALT);
        key:=key and (not MZW_SHIFT);

              {if key=MZW_LBUTTON then
                                     begin
                                          inc(tocommandmcliccount);
                                          wa.param.ontrackarray.otrackarray[0].worldcoord:=tv;
                                     end;
              if (key and MZW_LBUTTON)<>0 then
                                              wa.param.lastpoint:=tv;
              .pcommandrunning^.MouseMoveCallback(tv, wa.param.md.mouse, key,@wa.param.ospoint);}

        sendcoordtocommandTraceOn(Sender,tv,key,@Sender.param.ospoint);
      end;
    end else begin
        {if key=MZW_LBUTTON then
                               begin
                               inc(tocommandmcliccount);
                               wa.param.ontrackarray.otrackarray[0].worldcoord:=wa.param.md.mouseonworkplanecoord;
                               end;}
      if Sender.param.md.mouseonworkplan then begin
        if sysvar.DWG.DWG_SnapGrid<>nil then
          if not sysvar.DWG.DWG_SnapGrid^ then
            Sender.param.ospoint.worldcoord:=Sender.param.md.mouseonworkplanecoord;
        sendcoordtocommandTraceOn(
          {wa.param.md.mouseonworkplanecoord}Sender,Sender.param.ospoint.worldcoord,key,nil);
        //if key=MZW_LBUTTON then wa.param.lastpoint:=wa.param.md.mouseonworkplanecoord;
        //.pcommandrunning.MouseMoveCallback(wa.param.md.mouseonworkplanecoord, wa.param.md.mouse, key,nil)
      end else begin
        Sender.param.ospoint.worldcoord:=Sender.param.md.mouseray.lbegin;
        sendcoordtocommandTraceOn(
          Sender,Sender.param.md.mouseray.lbegin,key,nil);
        //if key=MZW_LBUTTON then wa.param.lastpoint:=wa.param.md.mouseray.lbegin;
        //.pcommandrunning^.MouseMoveCallback(wa.param.md.mouseray.lbegin, wa.param.md.mouse, key,nil);
      end;
    end;
end;

function GDBcommandmanager.EndGetPoint(newmode:TGetPointMode):boolean;
begin
  if CurrCmd.pcommandrunning<>nil then begin
    if (CurrCmd.pcommandrunning^.IData.GetPointMode=TGPMWait)or
      (CurrCmd.pcommandrunning^.IData.GetPointMode=TGPMWaitEnt)or
      (CurrCmd.pcommandrunning^.IData.GetPointMode=TGPMWaitInput) then begin
      CurrCmd.pcommandrunning^.IData.GetPointMode:=newmode;
      Result:=True;
    end else
      Result:=False;
  end else
    Result:=False;
end;

function GDBcommandmanager.Get3DPointInteractive(prompt:string;
  out p:TzePoint3d;const InteractiveProc:TInteractiveProcObjBuild;
  const PInteractiveData:Pointer;ESP:TEntitySetupProc):TzcInteractiveResult;
var
  savemode:byte;//variable to store the current mode of the editor
  //переменная для сохранения текущего режима редактора
begin
  //PTSimpleDrawing(pcommandrunning.pdwg)^.wa.asyncupdatemouse(0);
  Application.QueueAsyncCall(PTSimpleDrawing(
    CurrCmd.pcommandrunning.pdwg)^.wa.asyncupdatemouse,0);
  savemode:=PTSimpleDrawing(CurrCmd.pcommandrunning.pdwg)^.DefMouseEditorMode(
    MGet3DPoint or MGet3DPointWoOP,//set mode point of the mouse
    //устанавливаем режим указания точек мышью
    MGetControlpoint or
    MGetSelectionFrame or MGetSelectObject);//reset selection entities  mode
  //сбрасываем режим выбора примитивов мышью
  if prompt<>'' then
    zcUI.TextMessage(prompt,TMWOHistoryOut);
  CurrCmd.pcommandrunning^.IData.GetPointMode:=TGPMWait;
  CurrCmd.pcommandrunning^.IData.PInteractiveData:=PInteractiveData;
  CurrCmd.pcommandrunning^.IData.PInteractiveProc:=InteractiveProc;
  CurrCmd.pcommandrunning^.IData.PInteractiveESP:=ESP;

  while (CurrCmd.pcommandrunning^.IData.GetPointMode=TGPMWait)and
    (not Application.Terminated) do begin
    Application.HandleMessage;
    //Application.ProcessMessages;
    if CurrCmd.pcommandrunning=nil then
      exit(IRCancel);
  end;

  if (CurrCmd.pcommandrunning^.IData.GetPointMode=TGPMPoint)and
    (not Application.Terminated) then begin
    p:=CurrCmd.pcommandrunning^.IData.GetPointValue;
    Result:=IRNormal;
  end else if (CurrCmd.pcommandrunning^.IData.GetPointMode=TGPMId)and
    (not Application.Terminated) then begin
    p:=InfinityVertex;
    Result:=IRId;
  end else if (CurrCmd.pcommandrunning^.IData.GetPointMode=TGPMInput)and
    (not Application.Terminated) then begin
    p:=InfinityVertex;
    Result:=IRInput;
  end else if (CurrCmd.pcommandrunning^.IData.GetPointMode=TGPMCancel)and
    (not Application.Terminated) then begin
    p:=InfinityVertex;
    Result:=IRCancel;
  end else
    Result:=IRAbort;

  if (CurrCmd.pcommandrunning^.IData.GetPointMode<>TGPMCloseDWG) then
    PTSimpleDrawing(CurrCmd.pcommandrunning.pdwg)^.SetMouseEditorMode(savemode);
  //restore editor mode
  //восстанавливаем сохраненный режим редактора
end;

procedure InteractiveConstructRootManipulator(
  const PInteractiveData:Pointer {must be nil, no additional data needed};
  Point:
  TzePoint3d  {new end coord};
  Click:
  boolean {true if lmb presseed});
var
  ir:itrec;
  p:PGDBObjEntity;
  t_matrix:TzeTypedMatrix4d;
  RC:TDrawContext;
begin
  if click then begin
    t_matrix:=CreateTranslationMatrix(Point);
    drawings.GetCurrentDWG^.ConstructObjRoot.transform(t_matrix);
    drawings.GetCurrentDWG^.ConstructObjRoot.ObjMatrix:=OneMatrix;
    p:=drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.beginiterate(ir);
    if p<>nil then
      repeat
        p^.transform(t_matrix);
        p:=drawings.GetCurrentDWG^.ConstructObjRoot.ObjArray.iterate(ir);
      until p=nil;
  end else begin
    drawings.GetCurrentDWG^.ConstructObjRoot.ObjMatrix:=CreateTranslationMatrix(Point);
    RC:=drawings.GetCurrentDWG^.CreateDrawingRC;
    drawings.GetCurrentDWG^.ConstructObjRoot.FormatEntity(drawings.GetCurrentDWG^,RC);
  end;
end;

function GDBcommandmanager.Get3DAndMoveConstructRootTo(prompt:string;
  out p:TzePoint3d):TzcInteractiveResult;
begin
  Result:=Get3DPointInteractive(prompt,p,@InteractiveConstructRootManipulator,nil,nil);
end;

function GDBcommandmanager.MoveConstructRootTo(prompt:string):TzcInteractiveResult;
var
  p:TzePoint3d;
begin
  Result:=Get3DPointInteractive(prompt,p,@InteractiveConstructRootManipulator,nil,nil);
end;

function GDBcommandmanager.GetLastId:TTag;
begin
  if CurrCmd.pcommandrunning<>nil then
    Result:=CurrCmd.pcommandrunning^.IData.Id
  else
    Result:=WrongId;
end;

function GDBcommandmanager.GetLastInput:ansistring;
begin
  if CurrCmd.pcommandrunning<>nil then
    Result:=CurrCmd.pcommandrunning^.IData.Input
  else
    Result:='';
end;

function GDBcommandmanager.GetLastPoint:TzePoint3d;
begin
  if CurrCmd.pcommandrunning<>nil then
    Result:=CurrCmd.pcommandrunning^.IData.GetPointValue
  else
    Result:=NulVertex;
end;

function GDBcommandmanager.ChangeInputMode(incl,excl:TGetInputMode):TGetInputMode;
begin
  if CurrCmd.pcommandrunning<>nil then begin
    Result:=CurrCmd.pcommandrunning^.IData.InputMode;
    CurrCmd.pcommandrunning^.IData.InputMode:=
      CurrCmd.pcommandrunning^.IData.InputMode+incl;
    CurrCmd.pcommandrunning^.IData.InputMode:=
      CurrCmd.pcommandrunning^.IData.InputMode-excl;
  end else
    Result:=[];
end;

function GDBcommandmanager.SetInputMode(NewMode:TGetInputMode):TGetInputMode;
begin
  if CurrCmd.pcommandrunning<>nil then begin
    Result:=CurrCmd.pcommandrunning^.IData.InputMode;
    CurrCmd.pcommandrunning^.IData.InputMode:=NewMode;
  end else
    Result:=[];
end;

function GDBcommandmanager.GetInput(Prompt:string;out Input:string):TzcInteractiveResult;
var
  savemode:byte;//variable to store the current mode of the editor
  //переменная для сохранения текущего режима редактора
begin
  if CurrCmd.pcommandrunning.pdwg<>nil then
    savemode:=PTSimpleDrawing(CurrCmd.pcommandrunning.pdwg)^.DefMouseEditorMode(
      {MGet3DPoint or MGet3DPointWoOP}0,//set mode point of the mouse
      //устанавливаем режим указания точек мышью
      MGetControlpoint or
      MGetSelectionFrame or MGetSelectObject);//reset selection entities  mode
  //сбрасываем режим выбора примитивов мышью
  if prompt<>'' then
    zcUI.TextMessage(prompt,TMWOHistoryOut);
  CurrCmd.pcommandrunning^.IData.GetPointMode:=TGPMWaitInput;
  CurrCmd.pcommandrunning^.IData.PInteractiveData:=nil;
  CurrCmd.pcommandrunning^.IData.PInteractiveProc:=nil;
  CurrCmd.pcommandrunning^.IData.PInteractiveESP:=nil;
  while (CurrCmd.pcommandrunning^.IData.GetPointMode=TGPMWaitInput)and
    (not Application.Terminated) do begin
    Application.HandleMessage;
    //Application.ProcessMessages;
    if CurrCmd.pcommandrunning=nil then
      exit(IRCancel);
  end;
  if (CurrCmd.pcommandrunning^.IData.GetPointMode=TGPMInput)and
    (not Application.Terminated) then begin
    Input:=CurrCmd.pcommandrunning^.IData.Input;
    Result:=IRNormal;
  end else if (CurrCmd.pcommandrunning^.IData.GetPointMode=TGPMId)and
    (not Application.Terminated) then begin
    Input:='';
    Result:=IRId;
  end else if (CurrCmd.pcommandrunning^.IData.GetPointMode=TGPMCancel)and
    (not Application.Terminated) then begin
    Input:='';
    Result:=IRCancel;
  end else begin
    Input:='';
    Result:=IRAbort;
  end;
  if (CurrCmd.pcommandrunning^.IData.GetPointMode<>TGPMCloseDWG) then
    if CurrCmd.pcommandrunning.pdwg<>nil then
      PTSimpleDrawing(CurrCmd.pcommandrunning.pdwg)^.SetMouseEditorMode(savemode);
  //restore editor mode
  //восстанавливаем сохраненный режим редактора
end;

function GDBcommandmanager.Get3DPoint(prompt:string;out p:TzePoint3d):TzcInteractiveResult;
begin
  Result:=Get3DPointInteractive(prompt,p,nil,nil,nil);
end;

function GDBcommandmanager.Get3DPointWithLineFromBase(prompt:string;
  const base:TzePoint3d;out p:TzePoint3d):TzcInteractiveResult;
begin
  CurrCmd.pcommandrunning^.IData.BasePoint:=base;
  CurrCmd.pcommandrunning^.IData.DrawFromBasePoint:=True;
  Result:=Get3DPointInteractive(prompt,p,nil,nil,nil);
  CurrCmd.pcommandrunning^.IData.DrawFromBasePoint:=False;
end;

function GDBcommandmanager.GetEntity(prompt:string;out p:Pointer):TzcInteractiveResult;
var
  savemode:byte;
begin
  savemode:=PTSimpleDrawing(CurrCmd.pcommandrunning.pdwg)^.DefMouseEditorMode(
    MGetSelectObject,MGet3DPoint or MGet3DPointWoOP or MGetSelectionFrame or
                     MGetControlpoint);
  zcUI.TextMessage(prompt,TMWOHistoryOut);
  CurrCmd.pcommandrunning^.IData.GetPointMode:=TGPMWaitEnt;
  CurrCmd.pcommandrunning^.IData.PInteractiveData:=nil;
  CurrCmd.pcommandrunning^.IData.PInteractiveProc:=nil;
  CurrCmd.pcommandrunning^.IData.PInteractiveESP:=nil;
  while (CurrCmd.pcommandrunning^.IData.GetPointMode=TGPMWaitEnt)and
        (not Application.Terminated) do begin
    Application.HandleMessage;
    //Application.ProcessMessages;
  end;
  if (CurrCmd.pcommandrunning<>nil)and
     (CurrCmd.pcommandrunning^.IData.GetPointMode=TGPMEnt)and
     (not Application.Terminated) then begin
    p:=PTSimpleDrawing(CurrCmd.pcommandrunning.pdwg)^.wa.param.SelDesc.LastSelectedObject;
    Result:={True}IRNormal;
  end else begin
    Result:={False}IRCancel;
    //HistoryOutStr('cancel');
  end;
  PTSimpleDrawing(CurrCmd.pcommandrunning.pdwg)^.SetMouseEditorMode(savemode);
  //restore editor mode
  //восстанавливаем сохраненный режим редактора
end;

function GDBcommandmanager.GetValueHeap:integer;
begin
  Result:=varstack.vardescarray.Count;
end;

function GDBcommandmanager.CurrentCommandNotUseCommandLine:boolean;
begin
  if CurrCmd.pcommandrunning<>nil then
    Result:=CurrCmd.pcommandrunning.NotUseCommandLine
  else
    Result:=True;
end;

procedure GDBcommandmanager.PushValue(varname,vartype:string;instance:Pointer);
var
  vd:vardesk;
begin
  vd.Name:=varname;
  //vd.Instance:=instance;
  vd.Data.PTD:=SysUnit.TypeName2PTD(vartype);
  vd.SetInstance(nil);
  //vd.Instance:=nil;
  varstack.createvariable(varname,vd);
  vd.Data.PTD.CopyValueToInstance(instance,vd.Data.Addr.Instance);
end;

function GDBcommandmanager.GetValue:vardesk;
var
  lastelement:pvardesk;
begin
  lastelement:=pvardesk(varstack.vardescarray.getDataMutable(
    varstack.vardescarray.Count-1));
  Result:=lastelement^;
end;

function GDBcommandmanager.PopValue:vardesk;
var
  lastelement:pvardesk;
begin
  lastelement:=pvardesk(varstack.vardescarray.getDataMutable(
    varstack.vardescarray.Count-1));
  Dec(varstack.vardescarray.Count);
  Result:=lastelement^;
  lastelement.Name:='';
  lastelement.username:='';
  lastelement.Data.PTD:=nil;
  lastelement.SetInstance(nil);
  //lastelement.Instance:=nil;
end;

function getcommandmanager:Pointer;
begin
  Result:=@commandmanager;
end;

procedure GDBcommandmanager.DMShow;
begin
  //if assigned(cline) then
  if assigned({CLine.}DMenu) then begin
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
    {CLine.}DMenu.Clear;
end;
{procedure GDBcommandmanager.DMAddProcedure(Text,HText:String;proc:TonClickProc);
begin
     if assigned(cline) then
     if assigned(CLine.DMenu) then
     CLine.DMenu.AddProcedure(Text,HText,Proc);
end;
procedure GDBcommandmanager.DMAddProcedure;
begin
     if assigned(DMenu) then
     DMenu.AddProcedure(Text,HText,FProc);
end;}

procedure GDBcommandmanager.DMAddMethod(Text,HText:string;FMethod:TButtonMethod;
  pcr:PCommandRTEdObjectDef=nil);
begin
  if pcr=nil then
    pcr:=@CurrCmd.Context;
  if assigned(DMenu) then
    DMenu.AddMethod(Text,HText,FMethod,pcr);
end;

procedure GDBcommandmanager.DMAddMethod(Text,HText:string;FMethod:TButtonMethod2;
  pcr:PCommandRTEdObjectDef=nil);
type
  TMethodWithPointer=procedure(pdata:ptrint) of object;
begin
  DMAddMethod(Text,HText,TMethodWithPointer(FMethod),pcr);
end;

procedure GDBcommandmanager.executefile;
var
  sa:TZctnrVectorStrings;
  p:pstring;
  ir:itrec;
  oldlastcomm:string;
  MacrosFile:string;
begin
  MacrosFile:=ExpandPath(fn);
  zcUI.TextMessage(SysUtils.format(rsRunScript,[MacrosFile]),TMWOHistoryOut);
  Inc(busy);

  //DisableCmdLine;
  zcUI.Do_GUIMode({zcMsgUIDisableCMDLine}zcMsgUIDisable);

  oldlastcomm:=lastcommand;
  currMacros:=MacrosFile;
  sa.init(200);
  sa.loadfromfile(MacrosFile);
  //sa.getString(1);
  p:=sa.beginiterate(ir);
  if p<>nil then
    repeat
      if (uppercase(pString(p)^)<>'ABOUT') then
        Execute(
          p^,False,{pdrawing}drawings.GetCurrentDWG,POGLWndParam)
      else begin
        if not
          ZCSysParams.saved.nosplash then
          if
          ZCSysParams.notsaved.preloadedfile='' then
            Execute(
              p^,False,pdrawing,POGLWndParam);
      end;
      p:=sa.iterate(ir);
    until p=nil;
  sa.Done;
  lastcommand:=oldlastcomm;

  currMacros:='';
  //EnableCmdLine;
  zcUI.Do_GUIMode({zcMsgUIEnableCMDLine}zcMsgUIEnable);
  zcUI.Do_GUIMode(zcMsgUICMDLineCheck);
  Dec(busy);
end;

procedure GDBcommandmanager.sendpoint2command;
var
  p:PCommandRTEdObjectDef;
  ir:itrec;
begin
  if CurrCmd.pcommandrunning<>nil then
    if CurrCmd.pcommandrunning^.pdwg={gdb.GetCurrentDWG}@drawing then
      if CurrCmd.pcommandrunning.IsRTECommand then begin
        CurrCmd.pcommandrunning^.MouseMoveCallback(CurrCmd.context,p3d,p2d,mode,osp);
      end else if CurrCmd.pcommandrunning^.IData.GetPointMode=TGPMWait then begin
        if (mode and MZW_LBUTTON)<>0 then begin
          if assigned(
            CurrCmd.pcommandrunning^.IData.PInteractiveProc) then
            CurrCmd.pcommandrunning^.
              IData.PInteractiveProc(CurrCmd.pcommandrunning^.IData.PInteractiveData,p3d,True,
                                     CurrCmd.pcommandrunning^.IData.PInteractiveESP);
          CurrCmd.pcommandrunning^.
            IData.GetPointMode:=TGPMpoint;
          CurrCmd.pcommandrunning^.
            IData.GetPointValue:=p3d;
        end else begin
          CurrCmd.pcommandrunning^.
            IData.currentPointValue:=p3d;
          if assigned(
            CurrCmd.pcommandrunning^.IData.PInteractiveProc) then
            CurrCmd.pcommandrunning^.
              IData.PInteractiveProc(CurrCmd.pcommandrunning^.IData.PInteractiveData,p3d,False,
                                     CurrCmd.pcommandrunning^.IData.PInteractiveESP);
        end;
      end;
  //clearotrack;
  p:=CommandsStack.beginiterate(ir);
  if p<>nil then
    repeat
      if p^.pdwg={gdb.GetCurrentDWG}@drawing then
        if p^.IsRTECommand then begin
          (
            p)^.MouseMoveCallback(CurrCmd.context,p3d,p2d,mode,osp);
        end;

      p:=CommandsStack.iterate(ir);
    until p=nil;
end;

procedure GDBcommandmanager.cleareraseobj;
var
  p:PCommandObjectDef;
  ir:itrec;
begin
  p:=beginiterate(ir);
  if p<>nil then
    repeat
      p^.done;
      if p^.dyn then
        Freemem(Pointer(p));
      p:=iterate(ir);
    until p=nil;
  Count:=0;
end;

function GetCommandContext(pdrawing:PTDrawingDef;POGLWnd:POGLWndtype):TCStartAttr;
begin
  Result:=0;
  if pdrawing<>nil then begin
    Result:=Result or CADWG;
    if pdrawing^.CanRedo then
      Result:=Result or CACanRedo;
    if pdrawing^.CanUndo then
      Result:=Result or CACanUndo;
    if pdrawing^.GetChangeStampt then
      Result:=
        Result or CADWGChanged;
    if pdrawing^.GetConstructEntsCount>0 then
      Result:=Result or CAConstructRootNotEmpty;
  end;
  if POGLWnd<>nil then begin
    if POGLWnd^.SelDesc.Selectedobjcount=1 then
      Result:=
        Result or CASelEnt;
    if POGLWnd^.SelDesc.Selectedobjcount>0 then
      Result:=
        Result or CASelEnts;
  end;
  if commandmanager.CurrCmd.pcommandrunning<>nil then
    Result:=Result or CAOtherCommandRun;
end;

procedure ParseCommand(comm:string;out command,operands:string);
var
  {i,}p1,p2:integer;
begin
  p1:=pos('(',comm);
  if p1<1 then begin
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

function GDBcommandmanager.FindCommand(command:string):PCommandObjectDef;
var
  p:PCommandObjectDef;
  ir:itrec;
begin
  p:=beginiterate(ir);
  if p<>nil then
    repeat
      if uppercase(p^.CommandName)=command then begin
        Result:=p;
        exit;
      end;

      p:=iterate(ir);
    until p=nil;
  Result:=nil;
end;

procedure GDBcommandmanager.run(pc:PCommandObjectDef;operands:string;
  pdrawing:PTDrawingDef);
var
  pd:PTSimpleDrawing;
begin
  pd:={gdb.GetCurrentDWG}PTSimpleDrawing(pdrawing);
  if pd<>nil then
    if not(CEDWGNChanged in pc^.CEndActionAttr) then
      pd.ChangeStampt(True);
  if CurrCmd.pcommandrunning<>nil then begin
    if pc^.overlay then begin
      if
      CommandsStack.IsDataExist(pc)<>-1
      then
        self.executecommandtotalend
      else begin
        CommandsStack.
          pushbackdata(@CurrCmd.pcommandrunning^);
      end;
    end else begin
      if
      EndGetPoint(TGPMOtherCommand) then begin
        LatestRunPC:=pc;
        LatestRunOperands:=
          operands;
        LatestRunPDrawing:=
          pdrawing;

        exit;
      end;
      self.
        executecommandtotalend;

    end;
  end;
  CurrCmd.pcommandrunning:=pointer(pc);
  CurrCmd.context:=TZCADCommandContext.CreateRec(PTZCADDrawing(pdrawing));
  CurrCmd.pcommandrunning^.pdwg:=pd;
  CurrCmd.pcommandrunning^.pcontext:=@CurrCmd.context;
  CurrCmd.pcommandrunning^.CommandStart(CurrCmd.context,operands);
end;

procedure GDBcommandmanager.Execute(const comm:string;silent:boolean;
  pdrawing:PTDrawingDef;POGLWndParam:POGLWndtype);
var //i,p1,p2: Integer;
  command,operands:string;
  cc:TCStartAttr;
  pfoundcommand:PCommandObjectDef;
  //p:pchar;
begin
  if length(comm)>0 then
    if comm[1]<>';' then begin
      ParseCommand(comm,command,operands);

      pfoundcommand:=FindCommand(command);

      if pfoundcommand<>nil then begin
        begin
          cc:=GetCommandContext(pdrawing,POGLWndParam);
          if ((cc xor pfoundcommand^.CStartAttrEnableAttr)and
            pfoundcommand^.CStartAttrEnableAttr)=0 then begin

            //lastcommand := command;

            if silent then begin
              programlog.LogOutFormatStr(
                'GDBCommandManager.ExecuteCommandSilent(%s)',[pfoundcommand^.CommandName],LM_Info);
              Inc(SilentCounter);
            end else begin
              if isBusy then
                zcUI.TextMessage(rsRunCommand+':'+pfoundcommand^.CommandName,[TMWOToLog])
              else
                zcUI.TextMessage(rsRunCommand+':'+pfoundcommand^.CommandName,
                  TMWOHistoryOut);
              lastcommand:=command;
              if not (isBusy) then
                if assigned(OnCommandRun) then
                  OnCommandRun(command);
            end;

            run(pfoundcommand,operands,pdrawing);
            if CurrCmd.pcommandrunning<>nil then
              zcUI.Do_GUIMode(zcMsgUICMDLineRunMode);
                                      {if assigned(SetCommandLineMode) then
                                      SetCommandLineMode(CLCOMMANDRUN);}
          end else begin
            zcUI.TextMessage(format(rsCommandNRInC,[comm]),TMWOHistoryOut);
          end;
        end;
      end else
        zcUI.TextMessage(rsUnknownCommand+':"'+command+'"',TMWOHistoryOut);
    end;
  command:='';
  operands:='';
  if silent then
    Dec(SilentCounter);
end;

procedure GDBcommandmanager.executecommand(const comm:string;
  pdrawing:PTDrawingDef;POGLWndParam:POGLWndtype);
begin
  if not isBusy then
    Execute(comm,False,pdrawing,POGLWndParam)
  else
    zcUI.TextMessage(format(rsCommandNRInC,[comm]),TMWOShowError);
end;

procedure GDBcommandmanager.executecommandsilent{(const comm:pansichar): Integer};
begin
  if not isBusy then
    Execute(comm,True,pdrawing,POGLWndParam);
end;

procedure GDBcommandmanager.PrepairVarStack;
var
  ir:itrec;
  pvd:pvardesk;
  Value:string;
begin
  if self.varstack.vardescarray.Count<>0 then begin
    zcUI.TextMessage(rscmInStackData,TMWOHistoryOut);
    pvd:=self.varstack.vardescarray.beginiterate(ir);
    if pvd<>nil then
      repeat
        Value:=pvd.Data.PTD.GetValueAsString(pvd.Data.Addr.Instance);
        zcUI.TextMessage(pvd.Data.PTD.TypeName+':'+Value,TMWOHistoryOut);

        pvd:=self.varstack.vardescarray.iterate(ir);
      until pvd=nil;
  end;
  varstack.vardescarray.Clear;
  varstack.vararray.Clear;
end;

procedure GDBcommandmanager.DisableExecuteCommandEnd;
begin
  Inc(DisableExecuteCommandEndCounter);
end;

procedure GDBcommandmanager.EnableExecuteCommandEnd;
begin
  Dec(DisableExecuteCommandEndCounter);
end;

function GDBcommandmanager.hasDisabledExecuteCommandEnd:boolean;
begin
  Result:=DisabledExecuteCommandEndCounter>0;
end;

procedure GDBcommandmanager.resetDisabledExecuteCommandEnd;
begin
  DisabledExecuteCommandEndCounter:=0;
end;

function GDBcommandmanager.GetSavedMouseMode:byte;
begin
  if CurrCmd.pcommandrunning<>nil then
    Result:=CurrCmd.pcommandrunning.savemousemode
  else
    Result:=0;
end;

procedure GDBcommandmanager.executecommandend;
var
  temp:PCommandRTEdObjectDef;
  temp2:PCommandObjectDef;
begin
  InverseMouseClick:=False;
  if DisableExecuteCommandEndCounter>0 then begin
    Inc(DisabledExecuteCommandEndCounter);
    exit;
  end;
  DisabledExecuteCommandEndCounter:=0;
  if EndGetPoint(TGPMCancel) then
    exit;
  temp:=CurrCmd.pcommandrunning;
  CurrCmd.pcommandrunning:=nil;
  if temp<>nil then
    temp^.CommandEnd(CurrCmd.Context);
  if CurrCmd.pcommandrunning=nil then
    //if assigned(cline) then
    //                 CLine.SetMode(CLCOMMANDREDY);
    zcUI.Do_GUIMode(zcMsgUICMDLineReadyMode);
  {if assigned(SetCommandLineMode) then
                   SetCommandLineMode(CLCOMMANDREDY);}
  if self.CommandsStack.Count>0 then begin
    CurrCmd.pcommandrunning:=
      ppointer(CommandsStack.getDataMutable(CommandsStack.Count-1))^;
    Dec(CommandsStack.Count);
    CurrCmd.pcommandrunning.CommandContinue(
      CurrCmd.Context);
  end else begin
    self.DMHide;
    self.DMClear;
    PrepairVarStack;
  end;
  ContextCommandParams:=nil;
  if LatestRunPC<>nil then begin
    temp2:=LatestRunPC;
    LatestRunPC:=nil;
    GDBcommandmanager.run(temp2,LatestRunOperands,LatestRunPDrawing);
  end else if CurrCmd.pcommandrunning<>nil then
    if CurrCmd.pcommandrunning^.IData.GetPointMode=TGPMCloseApp then
      Application.QueueAsyncCall(AppCloseProc,0);
end;

procedure GDBcommandmanager.ChangeModeAndEnd(newmode:TGetPointMode);
var
  temp:PCommandRTEdObjectDef;
begin
  if EndGetPoint(newmode) then
    exit;
  self.DMHide;
  self.DMClear;

  temp:=CurrCmd.pcommandrunning;
  CurrCmd.pcommandrunning:=nil;
  if temp<>nil then
    temp^.CommandEnd(CurrCmd.Context);
  if CurrCmd.pcommandrunning=nil then
    zcUI.Do_GUIMode(zcMsgUICMDLineReadyMode);
                             {if assigned(SetCommandLineMode) then
                             SetCommandLineMode(CLCOMMANDREDY);}
  CommandsStack.Clear;
  ContextCommandParams:=nil;
end;

procedure GDBcommandmanager.executecommandtotalend;
begin
  ChangeModeAndEnd(TGPMCancel);
end;

procedure GDBcommandmanager.executelastcommad(pdrawing:PTDrawingDef;
  POGLWndParam:POGLWndtype);
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
  if SavedUnit<>nil then begin
    pint:=SavedUnit.FindValue('DMenuX').Data.Addr.Instance;
    if assigned(pint) then
      DMenu.Left:=pint^;
    pint:=SavedUnit.FindValue('DMenuY').Data.Addr.Instance;
    if assigned(pint) then
      DMenu.Top:=pint^;
  end;
  SilentCounter:=0;
  CommandLinePrompts:=nil;
  busy:=0;
  zcUI.RegisterGetStateFunc(GetState);
end;

function GDBcommandmanager.isBusy:boolean;
begin
  Result:=busy>0;
end;

function GDBcommandmanager.GetState:TzcUIState;
begin
  if isBusy then
    Result:=ZState_Busy
  else
    Result:=zcUI.GetEmptyZState;
end;

procedure GDBcommandmanager.CommandRegister(pc:PCommandObjectDef);
begin
  if Count=max then
    exit;
  PushBackData(pc);
end;

procedure comdeskclear(p:Pointer);
begin
     {pvardesk(p)^.name:='';
     pvardesk(p)^.vartype:=0;
     pvardesk(p)^.vartypecustom:=0;
     Freemem(pvardesk(p)^.pvalue);}
end;

procedure GDBcommandmanager.done;
begin
  cleareraseobj;
  lastcommand:='';
  inherited done;
  CommandsStack.done;
  varstack.Done;
  if Assigned(CommandLinePrompts) then
    CommandLinePrompts.Free;
end;

initialization
  commandmanager.init(1000);
  DefaultMacros.AddMacro(TTransferMacro.Create('CurrentMacrosPath','',
    'Current macros path',
    commandmanager.MacroFuncsCurrentMacrosPath(),[]));
  DefaultMacros.AddMacro(TTransferMacro.Create('CurrentMacrosFile','',
    'Current macros file',
    commandmanager.MacroFuncsCurrentMacrosFile(),[]));

finalization
  ProgramLog.LogOutFormatStr('Unit "%s" finalization',[{$INCLUDE %FILE%}],
    LM_Info,UnitsFinalizeLMId);
  commandmanager.Done;
end.
