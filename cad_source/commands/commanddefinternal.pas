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

unit commanddefinternal;
{$INCLUDE def.inc}


interface
uses gdbobjectsconstdef,zcadsysvars,geometry,varmandef,gdbasetypes,gdbase,commandlinedef,commandline,oglwindowdef,UGDBDescriptor
  {,UGDBLayerArray},memman,shared;
const cmd_ok=-1;
const cmd_cancel=-2;
const ZCMD_OK_NOEND=-10;
type
  comproc=procedure(_self:pointer);
  commousefunc=function(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record;mclick:GDBInteger):GDBInteger;
  comdrawfunc=function(mclick:GDBInteger):GDBInteger;
  comfunc=function:GDBInteger;
  comfuncwithoper=function(operands:pansichar):GDBInteger;
{Export+}
  CommandFastObject = object(CommandFastObjectDef)
    procedure CommandInit; virtual;
    procedure CommandEnd; virtual;
  end;
  PCommandFastObjectPlugin=^CommandFastObjectPlugin;
  CommandFastObjectPlugin = object(CommandFastObjectDef)
    onCommandStart:comfuncwithoper;
    constructor Init(name:pansichar;func:comfuncwithoper);
    procedure CommandStart(Operands:pansichar); virtual;
    procedure CommandCancel; virtual;
    procedure CommandEnd; virtual;
  end;
  pCommandRTEdObject=^CommandRTEdObject;
  CommandRTEdObject = object(CommandRTEdObjectDef)
    saveosmode:GDBInteger;(*hidden_in_objinsp*)
    UndoTop:TArrayIndex;(*hidden_in_objinsp*)
    commanddata:TTypedData;(*'Command options'*)
    procedure CommandStart(Operands:pansichar); virtual;
    procedure CommandEnd; virtual;
    procedure CommandCancel; virtual;
    procedure CommandInit; virtual;
    procedure Prompt(msg:GDBString);
    procedure Error(msg:GDBString);
    constructor init(cn:GDBString;SA,DA:TCStartAttr);
    //function BeforeClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger; virtual; abstract;
    //function AfterClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger; virtual; abstract;
  end;
  pCommandRTEdObjectPlugin=^CommandRTEdObjectPlugin;
  CommandRTEdObjectPlugin = object(CommandRTEdObject)
    onCommandStart:comfuncwithoper;
    onCommandEnd,onCommandCancel,onFormat:comproc;(*hidden_in_objinsp*)
    onBeforeClick,onAfterClick:commousefunc;(*hidden_in_objinsp*)
    onHelpGeometryDraw:comdrawfunc;
    onCommandContinue:comproc;
    constructor init(ocs:comfuncwithoper;oce,occ,ocf:comproc;obc,oac:commousefunc;onCCont:comproc;name:pansichar);
    procedure CommandStart(Operands:pansichar); virtual;
    procedure CommandEnd; virtual;
    procedure CommandCancel; virtual;
    procedure Format;virtual;
    procedure CommandContinue; virtual;
    function BeforeClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger; virtual;
    function AfterClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger; virtual;
    procedure DrawHeplGeometry;virtual;
  end;
  TOSModeEditor=object(GDBaseObject)
              osm:TOSMode;(*'Snap'*)
              trace:TTraceMode;(*'Trace'*)
              procedure Format;virtual;
              procedure GetState;
             end;
{Export-}
var
     OSModeEditor:TOSModeEditor;
function CreateCommandRTEdObjectPlugin(ocs:comfuncwithoper;oce,occ,ocf:comproc;obc,oac:commousefunc;ohgd:comdrawfunc;occont:comproc;name:pansichar;SA,DA:TCStartAttr):pCommandRTEdObjectPlugin;export;
function CreateCommandFastObjectPlugin(ocs:comfuncwithoper;name:pansichar;SA,DA:TCStartAttr):pCommandFastObjectPlugin;export;
implementation
uses {GDBCommandsBase,}UGDBOpenArrayOfUCommands,zcadinterface,varman,log;
procedure  TOSModeEditor.Format;
var
   i,c:integer;
   v:gdbvertex;

begin
    SysVar.dwg.DWG_OSMode^:=0;
    if osm.kosm_inspoint then inc(SysVar.dwg.DWG_OSMode^,osm_inspoint);
    if osm.kosm_endpoint then inc(SysVar.dwg.DWG_OSMode^,osm_endpoint);
    if osm.kosm_midpoint then inc(SysVar.dwg.DWG_OSMode^,osm_midpoint);
    if osm.kosm_3 then inc(SysVar.dwg.DWG_OSMode^,osm_3);
    if osm.kosm_4 then inc(SysVar.dwg.DWG_OSMode^,osm_4);
    if osm.kosm_center then inc(SysVar.dwg.DWG_OSMode^,osm_center);
    if osm.kosm_quadrant then inc(SysVar.dwg.DWG_OSMode^,osm_quadrant);
    if osm.kosm_point then inc(SysVar.dwg.DWG_OSMode^,osm_point);
    if osm.kosm_intersection then inc(SysVar.dwg.DWG_OSMode^,osm_intersection);
    if osm.kosm_perpendicular then inc(SysVar.dwg.DWG_OSMode^,osm_perpendicular);
    if osm.kosm_tangent then inc(SysVar.dwg.DWG_OSMode^,osm_tangent);
    if osm.kosm_nearest then inc(SysVar.dwg.DWG_OSMode^,osm_nearest);
    if osm.kosm_apparentintersection then inc(SysVar.dwg.DWG_OSMode^,osm_apparentintersection);
    if osm.kosm_paralel then inc(SysVar.dwg.DWG_OSMode^,osm_paralel);

    case self.trace.Angle of
         TTA90:c:=2;
         TTA45:c:=4;
         TTA30:c:=6;
    end;

  gdb.GetCurrentDWG.oglwindow1.PolarAxis.clear;
  for i := 0 to c - 1 do
  begin
    v.x:=cos(pi * i / c);
    v.y:=sin(pi * i / c);
    v.z:=0;
    gdb.GetCurrentDWG.oglwindow1.PolarAxis.add(@v);
  end;
  if self.trace.ZAxis then
  begin
    v.x:=0;
    v.y:=0;
    v.z:=1;
    gdb.GetCurrentDWG.oglwindow1.PolarAxis.add(@v);
  end;
end;
procedure TOSModeEditor.GetState;
begin
    if (SysVar.dwg.DWG_OSMode^ and osm_inspoint)=0 then
                                                       osm.kosm_inspoint:=false
                                                   else
                                                       osm.kosm_inspoint:=true;
    if (SysVar.dwg.DWG_OSMode^ and osm_endpoint)=0 then
                                                       osm.kosm_endpoint:=false
                                                   else
                                                       osm.kosm_endpoint:=true;
    if (SysVar.dwg.DWG_OSMode^ and osm_midpoint)=0 then
                                                       osm.kosm_midpoint:=false
                                                   else
                                                       osm.kosm_midpoint:=true;
    if (SysVar.dwg.DWG_OSMode^ and osm_3)=0 then
                                                       osm.kosm_3:=false
                                                   else
                                                       osm.kosm_3:=true;
    if (SysVar.dwg.DWG_OSMode^ and osm_4)=0 then
                                                       osm.kosm_4:=false
                                                   else
                                                       osm.kosm_4:=true;
    if (SysVar.dwg.DWG_OSMode^ and osm_center)=0 then
                                                       osm.kosm_center:=false
                                                   else
                                                       osm.kosm_center:=true;
    if (SysVar.dwg.DWG_OSMode^ and osm_quadrant)=0 then
                                                       osm.kosm_quadrant:=false
                                                   else
                                                       osm.kosm_quadrant:=true;
    if (SysVar.dwg.DWG_OSMode^ and osm_point)=0 then
                                                       osm.kosm_point:=false
                                                   else
                                                       osm.kosm_point:=true;
    if (SysVar.dwg.DWG_OSMode^ and osm_intersection)=0 then
                                                       osm.kosm_intersection:=false
                                                   else
                                                       osm.kosm_intersection:=true;
    if (SysVar.dwg.DWG_OSMode^ and osm_perpendicular)=0 then
                                                       osm.kosm_perpendicular:=false
                                                   else
                                                       osm.kosm_perpendicular:=true;
    if (SysVar.dwg.DWG_OSMode^ and osm_tangent)=0 then
                                                       osm.kosm_tangent:=false
                                                   else
                                                       osm.kosm_tangent:=true;
    if (SysVar.dwg.DWG_OSMode^ and osm_nearest)=0 then
                                                       osm.kosm_nearest:=false
                                                   else
                                                       osm.kosm_nearest:=true;
    if (SysVar.dwg.DWG_OSMode^ and osm_apparentintersection)=0 then
                                                       osm.kosm_apparentintersection:=false
                                                   else
                                                       osm.kosm_apparentintersection:=true;
    if (SysVar.dwg.DWG_OSMode^ and osm_paralel)=0 then
                                                       osm.kosm_paralel:=false
                                                   else
                                                       osm.kosm_paralel:=true;

end;

constructor CommandRTEdObject.init;
begin
  inherited;
  CommandInit;
  CommandName := cn;
  CommandGDBString := '';
  commandmanager.CommandRegister(@self);
end;
constructor CommandFastObjectPlugin.Init;
begin
         CommandName:=name;
         onCommandStart:=func;
         overlay:=false;
end;
procedure CommandFastObjectPlugin.CommandStart;
var
   rez:integer;
begin
     if assigned(onCommandStart) then rez:=onCommandStart(Operands);
     if rez<>ZCMD_OK_NOEND then commandmanager.executecommandend;
end;
procedure CommandFastObjectPlugin.CommandCancel;
begin
end;
procedure CommandFastObjectPlugin.CommandEnd;
begin
    //inherited;
    if gdb.currentdwg<>nil then
    begin
    if (self.CEndActionAttr and CEDeSelect)<>0 then
    //if (@self<>pfindcom)and(@self<>@OnDrawingEd)and(@self<>selframecommand)and(@self<>ms2objinsp)and(@self<>csel)and(@self<>selall) then
    begin
    gdb.GetCurrentROOT.ObjArray.DeSelect;
    gdb.GetCurrentDWG.OGLwindow1.param.SelDesc.LastSelectedObject := nil;
    gdb.GetCurrentDWG.OGLwindow1.param.SelDesc.OnMouseObject := nil;
    gdb.GetCurrentDWG.OGLwindow1.param.seldesc.Selectedobjcount:=0;
    gdb.GetCurrentDWG.SelObjArray.clearallobjects;
    end;
    if gdb.GetCurrentDWG.OGLwindow1<>nil then
    if not overlay then
  gdb.GetCurrentDWG.OGLwindow1.Clear0Ontrackpoint;
  if not overlay then
                     begin
                          gdb.GetCurrentDWG.ConstructObjRoot.ObjArray.cleareraseobj;
                          gdb.GetCurrentDWG.ConstructObjRoot.ObjCasheArray.Clear;
                          //gdb.GetCurrentDWG.ConstructObjRoot.ObjToConnectedArray.Clear;
                          gdb.GetCurrentDWG.ConstructObjRoot.ObjMatrix:=onematrix;
                     end;
  if gdb.GetCurrentDWG.OGLwindow1<>nil then
  gdb.GetCurrentDWG.OGLwindow1.param.lastonmouseobject:=nil;
  gdb.GetCurrentDWG.OnMouseObj.Clear;
  //poglwnd^.md.mode := savemousemode;
  OSModeEditor.GetState;
  if assigned(redrawoglwndproc) then redrawoglwndproc;
    end;
end;
procedure CommandRTEdObject.CommandEnd;
begin
    //inherited;
    if (self.CEndActionAttr and CEDeSelect)<>0 then
    //if (@self<>pfindcom)and(@self<>@OnDrawingEd)and(@self<>selframecommand) then
    begin
    gdb.GetCurrentROOT.ObjArray.DeSelect;
    gdb.GetCurrentDWG.OGLwindow1.param.SelDesc.LastSelectedObject := nil;
    gdb.GetCurrentDWG.OGLwindow1.param.SelDesc.OnMouseObject := nil;
    gdb.GetCurrentDWG.OGLwindow1.param.seldesc.Selectedobjcount:=0;
    gdb.GetCurrentDWG.SelObjArray.clearallobjects;
    end;
  gdb.GetCurrentDWG.OGLwindow1.param.lastonmouseobject:=nil;
  gdb.GetCurrentDWG.OnMouseObj.Clear;
  if commandline.commandmanager.CommandsStack.Count=0 then
  begin
  gdb.GetCurrentDWG.OGLwindow1.Clear0Ontrackpoint;
  gdb.GetCurrentDWG.ConstructObjRoot.ObjArray.cleareraseobj;
  gdb.GetCurrentDWG.ConstructObjRoot.ObjCasheArray.Clear;
  //gdb.GetCurrentDWG.ConstructObjRoot.ObjToConnectedArray.Clear;
  gdb.GetCurrentDWG.ConstructObjRoot.ObjMatrix:=onematrix;
  end;
  gdb.GetCurrentDWG.OGLwindow1.SetMouseMode(savemousemode);
  sysvar.dwg.DWG_OSMode^ := saveosmode;

  if commandline.commandmanager.CommandsStack.Count=0 then
                                                           gdb.GetCurrentDWG.OGLwindow1.setobjinsp;
  //-------------------------------gdb.GetCurrentDWG.OGLwindow1.param.lastonmouseobject:=nil;
  OSModeEditor.GetState;
  if assigned(redrawoglwndproc) then redrawoglwndproc;
end;
function CreateCommandFastObjectPlugin;
var p:pCommandFastObjectPlugin;
begin
     p:=nil;
     GDBGetMem({$IFDEF DEBUGBUILD}'{8F72364A-04F8-46BA-A5DC-0178CF78FC27}',{$ENDIF}GDBPointer(p),sizeof(CommandFastObjectPlugin));
     p^.init(name,ocs);
     p^.dyn:=true;
     p^.CStartAttrEnableAttr:=SA;
     p^.CStartAttrDisableAttr:=DA;
     commandmanager.CommandRegister(p);
     result:=p;
end;
function CreateCommandRTEdObjectPlugin;
var p:pCommandRTEdObjectPlugin;
begin
     p:=nil;
     GDBGetMem({$IFDEF DEBUGBUILD}'{8F72364A-04F8-46BA-A5DC-0178CF78FC27}',{$ENDIF}GDBPointer(p),sizeof(CommandRTEdObjectPlugin));
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
end;

function CommandRTEdObjectPlugin.AfterClick;
var a:integer;
begin
     if assigned(onAfterClick) then
                                   begin
                                        if mouseclic=1 then
                                                           mouseclic:=mouseclic;

                                        a:=onAfterClick(wc,mc,button,osp,mouseclic);
                                        mouseclic:=a;
                                        gdb.GetCurrentROOT.getoutbound;
                                        result:=a;
                                        if (mouseclic=1)and(commandmanager.pcommandrunning<>nil) then BeforeClick(wc,mc,button,osp);
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
procedure CommandRTEdObjectPlugin.Format;
begin
     if assigned(self.onFormat) then
                                     onFormat(@self);
end;
function CommandRTEdObjectPlugin.BeforeClick;
begin
     if assigned(onBeforeClick) then
                                     result:=onBeforeClick(wc,mc,button,osp,mouseclic);
end;
procedure CommandRTEdObjectPlugin.CommandStart;
begin
     inherited CommandStart('');
     if assigned(onCommandStart) then
                                     begin
                                          onCommandStart(operands);
                                     end;
end;
procedure CommandRTEdObjectPlugin.CommandEnd;
begin
     if assigned(onCommandEnd) then
                                   begin
                                        onCommandEnd(@self);
                                   end;
     inherited CommandEnd;
end;
procedure CommandRTEdObjectPlugin.CommandCancel;
begin
     //inherited CommandCancel;
     if assigned(onCommandCancel) then
                                     onCommandCancel(@self);
     inherited CommandCancel;
end;
procedure CommandRTEdObjectPlugin.CommandContinue;
begin
     if assigned(onCommandContinue) then
                                     onCommandContinue(@self);
end;
procedure CommandFastObject.CommandEnd;
begin
end;

procedure CommandRTEdObject.CommandStart;
begin
  savemousemode := gdb.GetCurrentDWG.OGLwindow1.param.md.mode;
  saveosmode := sysvar.dwg.DWG_OSMode^;
  mouseclic := 0;
  UndoTop:=gdb.GetCurrentDWG.GetUndoTop{UndoStack.CurrentCommand};

  if (commanddata.Instance<>nil)
  and(commanddata.PTD<>nil) then
                                begin
                                     if assigned(SetGDBObjInspProc)then
                                                                       SetGDBObjInspProc(SysUnit.TypeName2PTD('CommandRTEdObject'),@self);
                                end; 

end;

procedure CommandRTEdObject.CommandCancel;
begin
  gdb.GetCurrentDWG.ConstructObjRoot.ObjArray.cleareraseobj;
  gdb.GetCurrentDWG.OGLwindow1.param.lastonmouseobject:=nil;
  gdb.GetCurrentDWG.ConstructObjRoot.ObjMatrix:=onematrix;
  gdb.GetCurrentDWG.OGLwindow1.SetMouseMode(savemousemode);
  if assigned(redrawoglwndproc) then redrawoglwndproc;
end;

procedure CommandFastObject.CommandInit;
begin
end;

procedure CommandRTEdObject.CommandInit;
begin
  savemousemode := 0;
  mouseclic := 0;
end;
procedure CommandRTEdObject.Prompt(msg:GDBString);
begin
     HistoryOutStr(self.CommandName+':'+msg);
end;
procedure CommandRTEdObject.Error(msg:GDBString);
begin
     ShowError(self.CommandName+':'+msg);
end;

begin
     {$IFDEF DEBUGINITSECTION}LogOut('commanddefinternal.initialization');{$ENDIF}
end.

