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
uses geometry,varmandef,gdbasetypes,gdbase,commandlinedef,commandline,oglwindowdef,UGDBDescriptor
  {,UGDBLayerArray},memman,shared,sharedgdb;
const cmd_ok=-1;
const cmd_cancel=-2;
const ZCMD_OK_NOEND=-10;
type
  comproc=procedure;
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
    commanddata:TTypedData;(*'Параметры команды'*)
    procedure CommandStart(Operands:pansichar); virtual;
    procedure CommandEnd; virtual;
    procedure CommandCancel; virtual;
    procedure CommandInit; virtual;
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
    constructor init(ocs:comfuncwithoper;oce,occ,ocf:comproc;obc,oac:commousefunc;name:pansichar);
    procedure CommandStart(Operands:pansichar); virtual;
    procedure CommandEnd; virtual;
    procedure CommandCancel; virtual;
    procedure Format;virtual;
    function BeforeClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger; virtual;
    function AfterClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record): GDBInteger; virtual;
    procedure DrawHeplGeometry;virtual;
  end;
{Export-}
function CreateCommandRTEdObjectPlugin(ocs:comfuncwithoper;oce,occ,ocf:comproc;obc,oac:commousefunc;ohgd:comdrawfunc;name:pansichar;SA,DA:TCStartAttr):pCommandRTEdObjectPlugin;export;
function CreateCommandFastObjectPlugin(ocs:comfuncwithoper;name:pansichar;SA,DA:TCStartAttr):pCommandFastObjectPlugin;export;
implementation
uses {mainwindow,}{GDBCommandsDraw,}GDBCommandsBase,{oglwindow,}{GDBCommandsElectrical,}UGDBOpenArrayOfUCommands,Objinsp,varman,log;
constructor CommandRTEdObject.init;
begin
  CommandInit;
  CommandName := cn;
  CommandGDBString := '';
  CStartAttrEnableAttr:=SA or CADWG;
  CStartAttrDisableAttr:=DA;
  overlay:=false;
  CEndActionAttr:=CEDeSelect;

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

  gdb.GetCurrentDWG.OGLwindow1.Clear0Ontrackpoint;
  gdb.GetCurrentDWG.ConstructObjRoot.ObjArray.cleareraseobj;
  gdb.GetCurrentDWG.ConstructObjRoot.ObjMatrix:=onematrix;
  gdb.GetCurrentDWG.OGLwindow1.param.lastonmouseobject:=nil;
  //poglwnd^.md.mode := savemousemode;
  OSModeEditor.GetState;
  redrawoglwnd;
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

  gdb.GetCurrentDWG.OGLwindow1.Clear0Ontrackpoint;
  gdb.GetCurrentDWG.ConstructObjRoot.ObjArray.cleareraseobj;
  gdb.GetCurrentDWG.ConstructObjRoot.ObjMatrix:=onematrix;
  gdb.GetCurrentDWG.OGLwindow1.SetMouseMode(savemousemode);
  sysvar.dwg.DWG_OSMode^ := saveosmode;

  if commandline.commandmanager.CommandsStack.Count=0 then
                                                           gdb.GetCurrentDWG.OGLwindow1.setobjinsp;
  //-------------------------------gdb.GetCurrentDWG.OGLwindow1.param.lastonmouseobject:=nil;
  OSModeEditor.GetState;
  redrawoglwnd;
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
     p^.init(ocs,oce,occ,ocf,obc,oac,name);
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
                                     onFormat;
end;
function CommandRTEdObjectPlugin.BeforeClick;
begin
     if assigned(onBeforeClick) then
                                     onBeforeClick(wc,mc,button,osp,mouseclic);
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
                                        onCommandEnd;
                                   end;
     inherited CommandEnd;
end;
procedure CommandRTEdObjectPlugin.CommandCancel;
begin
     inherited CommandCancel;
     if assigned(onCommandCancel) then
                                     onCommandCancel;
end;

procedure CommandFastObject.CommandEnd;
begin
end;

procedure CommandRTEdObject.CommandStart;
begin
  savemousemode := gdb.GetCurrentDWG.OGLwindow1.param.md.mode;
  saveosmode := sysvar.dwg.DWG_OSMode^;
  mouseclic := 0;
  UndoTop:=gdb.GetCurrentDWG.UndoStack.CurrentCommand;

  if (commanddata.Instance<>nil)
  and(commanddata.PTD<>nil) then
                                begin
                                     SetGDBObjInsp(SysUnit.TypeName2PTD('CommandRTEdObject'),@self);
                                end; 

end;

procedure CommandRTEdObject.CommandCancel;
begin
  gdb.GetCurrentDWG.ConstructObjRoot.ObjArray.cleareraseobj;
  gdb.GetCurrentDWG.ConstructObjRoot.ObjMatrix:=onematrix;
  gdb.GetCurrentDWG.OGLwindow1.SetMouseMode(savemousemode);
  redrawoglwnd;
end;

procedure CommandFastObject.CommandInit;
begin
end;

procedure CommandRTEdObject.CommandInit;
begin
  savemousemode := 0;
  mouseclic := 0;
end;
begin
     {$IFDEF DEBUGINITSECTION}LogOut('commanddefinternal.initialization');{$ENDIF}
end.
