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

unit uzccommandsimpl;
{$INCLUDE zengineconfig.inc}


interface
uses uzcutils,uzgldrawcontext,uzglviewareageneral,uzeconsts,uzcsysvars,uzegeometry,
     varmandef,uzbtypes,uzccommandsabstract,uzccommandsmanager,
     uzegeometrytypes,uzglviewareadata,uzcdrawings,
     uzcinterface,varman,uzclog,uzeSnap;
type
  comproc=procedure(const Context:TZCADCommandContext;_self:pointer);
  commousefunc=function(const Context:TZCADCommandContext;wc: GDBvertex; mc: GDBvertex2DI; var button: Byte;osp:pos_record;mclick:Integer):Integer;
  comdrawfunc=function(mclick:Integer):TCommandResult;
  comfuncwithoper=function(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;

  TZCADBaseCommand=function(const Context:TZCADCommandContext; Operands:TCommandOperands):TCommandResult;
{Export+}
  PCommandFastObjectPlugin=^CommandFastObjectPlugin;
  {REGISTEROBJECTTYPE CommandFastObjectPlugin}
  CommandFastObjectPlugin =  object(CommandFastObjectDef)
    onCommandStart:TZCADBaseCommand;
    constructor Init(name:pansichar;func:TZCADBaseCommand);
    procedure CommandStart(const Context:TZCADCommandContext;Operands:TCommandOperands); virtual;
    procedure CommandCancel(const Context:TZCADCommandContext); virtual;
    procedure CommandEnd(const Context:TZCADCommandContext); virtual;
  end;
  pCommandRTEdObject=^CommandRTEdObject;
  {REGISTEROBJECTTYPE CommandRTEdObject}
  CommandRTEdObject =  object(CommandRTEdObjectDef)
    saveosmode:Integer;(*hidden_in_objinsp*)
    commanddata:THardTypedData;(*'Command options'*)
    ShowParams:Boolean;(*hidden_in_objinsp*)
    procedure CommandStart(const Context:TZCADCommandContext;Operands:TCommandOperands); virtual;
    procedure CommandEnd(const Context:TZCADCommandContext); virtual;
    procedure CommandCancel(const Context:TZCADCommandContext); virtual;
    procedure CommandInit; virtual;
    procedure Prompt(msg:String);
    procedure Error(msg:String);
    procedure SetCommandParam(PTypedTata:pointer;TypeName:string;AShowParams:Boolean=true);
    constructor init(cn:String;SA,DA:TCStartAttr);
    //function BeforeClick(wc: GDBvertex; mc: GDBvertex2DI; button: Byte;osp:pos_record): Integer; virtual; abstract;
    //function AfterClick(wc: GDBvertex; mc: GDBvertex2DI; button: Byte;osp:pos_record): Integer; virtual; abstract;
  end;
  pCommandRTEdObjectPlugin=^CommandRTEdObjectPlugin;
  {REGISTEROBJECTTYPE CommandRTEdObjectPlugin}
  CommandRTEdObjectPlugin =  object(CommandRTEdObject)
    onCommandStart:comfuncwithoper;
    onCommandEnd,onCommandCancel,onFormat:comproc;(*hidden_in_objinsp*)
    onBeforeClick,onAfterClick:commousefunc;(*hidden_in_objinsp*)
    onHelpGeometryDraw:comdrawfunc;
    onCommandContinue:comproc;
    constructor init(ocs:comfuncwithoper;oce,occ,ocf:comproc;obc,oac:commousefunc;onCCont:comproc;name:pansichar);
    procedure CommandStart(const Context:TZCADCommandContext;Operands:TCommandOperands); virtual;
    procedure CommandEnd(const Context:TZCADCommandContext); virtual;
    procedure CommandCancel(const Context:TZCADCommandContext); virtual;
    procedure Format;virtual;
    procedure FormatAfterFielfmod(PField,PTypeDescriptor:Pointer);virtual;
    procedure CommandContinue(const Context:TZCADCommandContext); virtual;
    function BeforeClick(const Context:TZCADCommandContext;wc: GDBvertex; mc: GDBvertex2DI; var button: Byte;osp:pos_record): Integer; virtual;
    function AfterClick(const Context:TZCADCommandContext;wc: GDBvertex; mc: GDBvertex2DI; var button: Byte;osp:pos_record): Integer; virtual;
    procedure DrawHeplGeometry;virtual;
  end;
  {REGISTEROBJECTTYPE TOSModeEditor}
  TOSModeEditor= object(GDBaseObject)
              osm:TOSMode;(*'Snap'*)
              trace:TTraceMode;(*'Trace'*)
              procedure Format;virtual;
              procedure GetState;
             end;
{Export-}
var
     OSModeEditor:TOSModeEditor;
function CreateCommandRTEdObjectPlugin(ocs:comfuncwithoper;oce,occ,ocf:comproc;obc,oac:commousefunc;ohgd:comdrawfunc;occont:comproc;name:pansichar;SA,DA:TCStartAttr):pCommandRTEdObjectPlugin;export;
function CreateZCADCommand(ACommandFunc:TZCADBaseCommand;ACommandName:string;SA,DA:TCStartAttr):pCommandFastObjectPlugin;export;
implementation
procedure  TOSModeEditor.Format;
var
   i,c:integer;
   v:gdbvertex;

begin
    sysvarDWGOSMode:=0;
    if osm.kosm_inspoint then inc(sysvarDWGOSMode,osm_inspoint);
    if osm.kosm_endpoint then inc(sysvarDWGOSMode,osm_endpoint);
    if osm.kosm_midpoint then inc(sysvarDWGOSMode,osm_midpoint);
    if osm.kosm_3 then inc(sysvarDWGOSMode,osm_3);
    if osm.kosm_4 then inc(sysvarDWGOSMode,osm_4);
    if osm.kosm_center then inc(sysvarDWGOSMode,osm_center);
    if osm.kosm_quadrant then inc(sysvarDWGOSMode,osm_quadrant);
    if osm.kosm_point then inc(sysvarDWGOSMode,osm_point);
    if osm.kosm_intersection then inc(sysvarDWGOSMode,osm_intersection);
    if osm.kosm_perpendicular then inc(sysvarDWGOSMode,osm_perpendicular);
    if osm.kosm_tangent then inc(sysvarDWGOSMode,osm_tangent);
    if osm.kosm_nearest then inc(sysvarDWGOSMode,osm_nearest);
    if osm.kosm_apparentintersection then inc(sysvarDWGOSMode,osm_apparentintersection);
    if osm.kosm_paralel then inc(sysvarDWGOSMode,osm_paralel);

    case self.trace.Angle of
         TTA90:c:=2;
         TTA45:c:=4;
         TTA30:c:=6;
    end;

  drawings.GetCurrentDWG.wa.PolarAxis.clear;
  for i := 0 to c - 1 do
  begin
    v.x:=cos(pi * i / c);
    v.y:=sin(pi * i / c);
    v.z:=0;
    drawings.GetCurrentDWG.wa.PolarAxis.PushBackData(v);
  end;
  if self.trace.ZAxis then
  begin
    v.x:=0;
    v.y:=0;
    v.z:=1;
    drawings.GetCurrentDWG.wa.PolarAxis.PushBackData(v);
  end;
end;
procedure TOSModeEditor.GetState;
begin
    if (sysvarDWGOSMode and osm_inspoint)=0 then
                                                       osm.kosm_inspoint:=false
                                                   else
                                                       osm.kosm_inspoint:=true;
    if (sysvarDWGOSMode and osm_endpoint)=0 then
                                                       osm.kosm_endpoint:=false
                                                   else
                                                       osm.kosm_endpoint:=true;
    if (sysvarDWGOSMode and osm_midpoint)=0 then
                                                       osm.kosm_midpoint:=false
                                                   else
                                                       osm.kosm_midpoint:=true;
    if (sysvarDWGOSMode and osm_3)=0 then
                                                       osm.kosm_3:=false
                                                   else
                                                       osm.kosm_3:=true;
    if (sysvarDWGOSMode and osm_4)=0 then
                                                       osm.kosm_4:=false
                                                   else
                                                       osm.kosm_4:=true;
    if (sysvarDWGOSMode and osm_center)=0 then
                                                       osm.kosm_center:=false
                                                   else
                                                       osm.kosm_center:=true;
    if (sysvarDWGOSMode and osm_quadrant)=0 then
                                                       osm.kosm_quadrant:=false
                                                   else
                                                       osm.kosm_quadrant:=true;
    if (sysvarDWGOSMode and osm_point)=0 then
                                                       osm.kosm_point:=false
                                                   else
                                                       osm.kosm_point:=true;
    if (sysvarDWGOSMode and osm_intersection)=0 then
                                                       osm.kosm_intersection:=false
                                                   else
                                                       osm.kosm_intersection:=true;
    if (sysvarDWGOSMode and osm_perpendicular)=0 then
                                                       osm.kosm_perpendicular:=false
                                                   else
                                                       osm.kosm_perpendicular:=true;
    if (sysvarDWGOSMode and osm_tangent)=0 then
                                                       osm.kosm_tangent:=false
                                                   else
                                                       osm.kosm_tangent:=true;
    if (sysvarDWGOSMode and osm_nearest)=0 then
                                                       osm.kosm_nearest:=false
                                                   else
                                                       osm.kosm_nearest:=true;
    if (sysvarDWGOSMode and osm_apparentintersection)=0 then
                                                       osm.kosm_apparentintersection:=false
                                                   else
                                                       osm.kosm_apparentintersection:=true;
    if (sysvarDWGOSMode and osm_paralel)=0 then
                                                       osm.kosm_paralel:=false
                                                   else
                                                       osm.kosm_paralel:=true;

end;

constructor CommandRTEdObject.init;
begin
  inherited;
  commanddata.Instance:=nil;
  commanddata.PTD:=nil;
  ShowParams:=False;
  CommandInit;
  CommandName := cn;
  CommandString := '';
  commandmanager.CommandRegister(@self);
end;
constructor CommandFastObjectPlugin.Init;
begin
         CommandName:=name;
         onCommandStart:=func;
         overlay:=false;
         IData.GetPointMode:=TGPMCancel;
         IData.PossibleResult:=[Low(TGetPossibleResult)..High(TGetPossibleResult)];
         IData.InputMode:=[];
end;
procedure CommandFastObjectPlugin.CommandStart;
var
   rez:integer;
begin
  if assigned(drawings.GetCurrentDWG)then
    UndoTop:=drawings.GetCurrentDWG.GetUndoTop{UndoStack.CurrentCommand};
  if assigned(onCommandStart) then rez:=onCommandStart(Context,Operands);
  if rez<>ZCMD_OK_NOEND then commandmanager.executecommandend;
end;
procedure CommandFastObjectPlugin.CommandCancel;
begin
end;
procedure CommandFastObjectPlugin.CommandEnd;
begin
    //inherited;
    if drawings.currentdwg<>nil then
    begin
    if CEDeSelect in self.CEndActionAttr then
    //if (@self<>pfindcom)and(@self<>@OnDrawingEd)and(@self<>selframecommand)and(@self<>ms2objinsp)and(@self<>csel)and(@self<>selall) then
    begin
    drawings.GetCurrentROOT.ObjArray.DeSelect(drawings.GetCurrentDWG.wa.param.SelDesc.Selectedobjcount,drawings.GetCurrentDWG^.deselector);
    drawings.GetCurrentDWG.wa.param.SelDesc.LastSelectedObject := nil;
    drawings.GetCurrentDWG.wa.param.SelDesc.OnMouseObject := nil;
    drawings.GetCurrentDWG.wa.param.seldesc.Selectedobjcount:=0;
    drawings.GetCurrentDWG.SelObjArray.Free;
    end;
    if drawings.GetCurrentDWG.wa<>nil then
    if not overlay then
  drawings.GetCurrentDWG.wa.Clear0Ontrackpoint;
  if not overlay then
                     begin
                          drawings.GetCurrentDWG.FreeConstructionObjects;
                          {drawings.GetCurrentDWG.ConstructObjRoot.ObjArray.cleareraseobj;
                          drawings.GetCurrentDWG.ConstructObjRoot.ObjCasheArray.Clear;
                          //drawings.GetCurrentDWG.ConstructObjRoot.ObjToConnectedArray.Clear;
                          drawings.GetCurrentDWG.ConstructObjRoot.ObjMatrix:=onematrix;}
                     end;
  if drawings.GetCurrentDWG.wa.getviewcontrol<>nil then
  drawings.GetCurrentDWG.wa.param.lastonmouseobject:=nil;
  drawings.GetCurrentDWG.OnMouseObj.Clear;
  //poglwnd^.md.mode := savemousemode;
  OSModeEditor.GetState;
  zcRedrawCurrentDrawing;
  ZCMsgCallBackInterface.Do_GUIaction(nil,ZMsgID_GUIActionRedraw);
  //if assigned(UpdateVisibleProc) then UpdateVisibleProc(ZMsgID_GUIActionRedraw);
    end;
end;
procedure CommandRTEdObject.CommandEnd;
begin
    //inherited;
    if CEDeSelect in self.CEndActionAttr then
    //if (@self<>pfindcom)and(@self<>@OnDrawingEd)and(@self<>selframecommand) then
    begin
    drawings.GetCurrentROOT.ObjArray.DeSelect(drawings.GetCurrentDWG.wa.param.SelDesc.Selectedobjcount,drawings.GetCurrentDWG^.deselector);
    drawings.GetCurrentDWG.wa.param.SelDesc.LastSelectedObject := nil;
    drawings.GetCurrentDWG.wa.param.SelDesc.OnMouseObject := nil;
    drawings.GetCurrentDWG.wa.param.seldesc.Selectedobjcount:=0;
    drawings.GetCurrentDWG.SelObjArray.Free;
    end;
  drawings.GetCurrentDWG.wa.param.lastonmouseobject:=nil;
  drawings.GetCurrentDWG.OnMouseObj.Clear;
  if uzccommandsmanager.commandmanager.CommandsStack.Count=0 then
  begin
  drawings.GetCurrentDWG.wa.Clear0Ontrackpoint;
  drawings.GetCurrentDWG.ConstructObjRoot.ObjArray.free;
  drawings.GetCurrentDWG.ConstructObjRoot.ObjCasheArray.Clear;
  //drawings.GetCurrentDWG.ConstructObjRoot.ObjToConnectedArray.Clear;
  drawings.GetCurrentDWG.ConstructObjRoot.ObjMatrix:=onematrix;
  end;
  drawings.GetCurrentDWG.wa.SetMouseMode(savemousemode);
  sysvarDWGOSMode := saveosmode;

  if uzccommandsmanager.commandmanager.CommandsStack.Count=0 then
    ZCMsgCallBackInterface.Do_GUIaction(drawings.GetCurrentDWG.wa,ZMsgID_GUIActionSelectionChanged);
  //-------------------------------drawings.GetCurrentDWG.OGLwindow1.param.lastonmouseobject:=nil;
  OSModeEditor.GetState;
  zcRedrawCurrentDrawing;
end;
function CreateZCADCommand;
var p:pCommandFastObjectPlugin;
begin
     p:=nil;
     Getmem(Pointer(p),sizeof(CommandFastObjectPlugin));
     p^.init(pchar(ACommandName),ACommandFunc);
     p^.dyn:=true;
     p^.CStartAttrEnableAttr:=SA;
     p^.CStartAttrDisableAttr:=DA;
     p^.NotUseCommandLine:=true;
     commandmanager.CommandRegister(p);
     result:=p;
end;
function CreateCommandRTEdObjectPlugin;
var p:pCommandRTEdObjectPlugin;
begin
     p:=nil;
     Getmem(Pointer(p),sizeof(CommandRTEdObjectPlugin));
     p^.init(ocs,oce,occ,ocf,obc,oac,occont,name);
     p^.onHelpGeometryDraw:=@ohgd;
     p^.dyn:=true;

     p^.CStartAttrEnableAttr:=SA or CADWG;
     p^.CStartAttrDisableAttr:=DA;

     commandmanager.CommandRegister(p);
     result:=p;
end;
constructor CommandRTEdObjectPlugin.init;
begin
     onCommandStart:=ocs;
     onCommandEnd:=oce;
     onCommandCancel:=occ;
     onFormat:=ocf;
     onBeforeClick:=obc;
     onAfterClick:=oac;
     onCommandContinue:=onCCont;
     CommandName:=name;
     overlay:=false;
     NotUseCommandLine:=true;
     IData.GetPointMode:=TGPMCancel;
     IData.PossibleResult:=[Low(TGetPossibleResult)..High(TGetPossibleResult)];
     IData.InputMode:=[];
end;

function CommandRTEdObjectPlugin.AfterClick;
var a:integer;
   dc:TDrawContext;
begin
     if assigned(onAfterClick) then
                                   begin
//                                        if mouseclic=1 then
//                                                           mouseclic:=mouseclic;

                                        a:=onAfterClick(context,wc,mc,button,osp,mouseclic);
                                        mouseclic:=a;
                                        dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
                                        drawings.GetCurrentROOT.getoutbound(dc);
                                        result:=a;
                                        if (mouseclic=1)and(commandmanager.CurrCmd.pcommandrunning<>nil) then BeforeClick(context,wc,mc,button,osp);
                                        //if mouseclic=0 then
                                        //                   mouseclic:=0;
                                   end;
end;
procedure CommandRTEdObjectPlugin.DrawHeplGeometry;
begin
     if assigned(onHelpGeometryDraw) then
                                   begin
                                        onHelpGeometryDraw(mouseclic);
                                   end;
end;
procedure CommandRTEdObjectPlugin.FormatAfterFielfmod(PField,PTypeDescriptor:Pointer);
begin
  if assigned(self.onFormat) then
    onFormat(PTZCADCommandContext(pcontext)^,PField);
end;
procedure CommandRTEdObjectPlugin.Format;
begin
  if assigned(self.onFormat) then
    onFormat(PTZCADCommandContext(pcontext)^,nil);
end;
function CommandRTEdObjectPlugin.BeforeClick;
begin
     if assigned(onBeforeClick) then
                                     result:=onBeforeClick(context,wc,mc,button,osp,mouseclic);
end;
procedure CommandRTEdObjectPlugin.CommandStart;
begin
     inherited CommandStart(context,'');
     if assigned(onCommandStart) then
                                     begin
                                          onCommandStart(Context,operands);
                                     end;
end;
procedure CommandRTEdObjectPlugin.CommandEnd;
begin
     if assigned(onCommandEnd) then
                                   begin
                                        onCommandEnd(Context,@self);
                                   end;
     inherited CommandEnd(context);
end;
procedure CommandRTEdObjectPlugin.CommandCancel;
begin
     //inherited CommandCancel;
     if assigned(onCommandCancel) then
                                     onCommandCancel(Context,@self);
     inherited CommandCancel(context);
end;
procedure CommandRTEdObjectPlugin.CommandContinue;
begin
     if assigned(onCommandContinue) then
                                     onCommandContinue(context,@self);
end;

procedure CommandRTEdObject.CommandStart;
begin
  savemousemode := drawings.GetCurrentDWG.wa.param.md.mode;
  saveosmode := sysvarDWGOSMode;
  mouseclic := 0;
  UndoTop:=drawings.GetCurrentDWG.GetUndoTop{UndoStack.CurrentCommand};

  if ShowParams then
    if (commanddata.Instance<>nil)and(commanddata.PTD<>nil) then
      ZCMsgCallBackInterface.Do_PrepareObject(nil,drawings.GetUnitsFormat,SysUnit.TypeName2PTD('CommandRTEdObject'),@self,drawings.GetCurrentDWG);

end;

procedure CommandRTEdObject.CommandCancel;
begin
  drawings.GetCurrentDWG.ConstructObjRoot.ObjArray.free;
  drawings.GetCurrentDWG.wa.param.lastonmouseobject:=nil;
  drawings.GetCurrentDWG.ConstructObjRoot.ObjMatrix:=onematrix;
  drawings.GetCurrentDWG.wa.SetMouseMode(savemousemode);
  zcRedrawCurrentDrawing;
end;

procedure CommandRTEdObject.CommandInit;
begin
  savemousemode := 0;
  mouseclic := 0;
end;
procedure CommandRTEdObject.Prompt(msg:String);
begin
     ZCMsgCallBackInterface.TextMessage(self.CommandName+':'+msg,TMWOHistoryOut);
end;
procedure CommandRTEdObject.Error(msg:String);
begin
     ZCMsgCallBackInterface.TextMessage(self.CommandName+':'+msg,TMWOShowError);
end;
procedure CommandRTEdObject.SetCommandParam(PTypedTata:pointer;TypeName:string;AShowParams:Boolean=true);
begin
  SetTypedDataVariable(commanddata,pTypedTata,TypeName);
  ShowParams:=AShowParams;
end;

begin
  OSModeEditor.initnul;
  OSModeEditor.trace.ZAxis:=false;
  OSModeEditor.trace.Angle:=TTA45;
end.

