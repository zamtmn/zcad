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

unit oglwindow;
{$INCLUDE def.inc}

interface

uses

   uinfoform,ugdbdrawingdef,GDBCamera,zcadsysvars,UGDBLayerArray,zcadstrconsts,{ucxmenumgr,}
  {$IFDEF LCLGTK2}
  //x,xlib,{x11,}{xutil,}
  gtk2,gdk2,{gdk2x,}
  {$ENDIF}
  ugdbabstractdrawing,UGDBOpenArrayOfPV,UGDBSHXFont,
  {$IFNDEF DELPHI}LCLType,InterfaceBase,FileUtil,{$ELSE}windows,{$ENDIF}
  {umytreenode,}menus,Classes,Forms,
  ExtCtrls,Controls,
  GDBGenericSubEntry,gdbasetypes,sysutils,
  {$IFNDEF DELPHI}{GLext,gl,glu,}OpenGLContext,{$ELSE}dglOpenGL,UOpenGLControl,{$ENDIF}
  Math,gdbase,varmandef,varman,UUnitManager,
  oglwindowdef,UGDBSelectedObjArray,

  GDBHelpObj,
  commandline,

  zglline3d,

  sysinfo,
  UGDBVisibleOpenArray,
  UGDBPoint3DArray,
  strproc,OGLSpecFunc,memman,
  log,UGDBEntTree,sltexteditor;
const

  ontracdist=10;
  ontracignoredist=25;
  texturesize=256;
type
  PTOGLWnd = ^TOGLWnd;
  TCameraChangedNotify=procedure of object;

  { TOGLWnd }

  TOGLWnd = class({TPanel}TOpenGLControl)
  private
    OGLContext:TOGLContextDesk;
    {hrc:thandle;
    dc:HDC;
    thdc:HDC;}
  public
    sh:integer;
    OTTimer:TTimer;
    OHTimer:TTimer;
    //OMMTimer:TTimer;
    PolarAxis:GDBPoint3dArray;
    param: OGLWndtype;

    PDWG:PTAbstractDrawing;

    tocommandmcliccount:GDBInteger;

    myscrbuf:tmyscrbuf;
    currentmousemovesnaptogrid:GDBBoolean;

    FastMMShift: TShiftState;
    FastMMX,FastMMY: Integer;
    onCameraChanged:TCameraChangedNotify;
    ShowCXMenu:procedure of object;
    MainMouseMove:procedure of object;
    MainMouseDown:function:boolean of object;

    //SelectedObjectsPLayer:PGDBLayerProp;

    //procedure keydown(var Key: GDBWord; Shift: TShiftState);
    //procedure dock(Sender: TObject; Source: TDragDockObject; X, Y: GDBInteger;State: TDragState; var Accept: GDBBoolean);
    procedure CalcMouseFrustum;
    procedure RestoreMouse;
    procedure init;virtual;
    procedure DrawGrid;
    procedure beforeinit;virtual;
    procedure initogl;
    procedure AddOntrackpoint;
    procedure Project0Axis;

    procedure render(const Root:GDBObjGenericSubEntry;var DC:TDrawContext{subrender:GDBInteger});
    function treerender(var Node:TEntTreeNode;StartTime:TDateTime;var DC:TDrawContext{subrender:GDBInteger}):GDBBoolean;

    function GetOnMouseObjDesc:GDBString;

    procedure getosnappoint({pva: PGDBObjEntityOpenArray;}radius: GDBFloat);
    procedure set3dmouse;
    procedure DISP_ZoomFactor(x: double{; MousePos: TPoint});
    //function mousein(MousePos: TPoint): GDBBoolean;
    procedure mouseunproject(X, Y: integer);
    procedure calcgrid;
    procedure CorrectMouseAfterOS;
    procedure getonmouseobject(pva: PGDBObjEntityOpenArray);
    procedure getonmouseobjectbytree(Node:TEntTreeNode);
    procedure processmousenode(Node:TEntTreeNode;var i:integer);
    function findonmobj(pva: PGDBObjEntityOpenArray;var i: GDBInteger): GDBInteger;
    procedure SetOTrackTimer(Sender: TObject);
    procedure KillOTrackTimer(Sender: TObject);
    procedure ProcOTrackTimer(Sender:TObject);

    procedure SetOHintTimer(Sender: TObject);
    procedure KillOHintTimer(Sender: TObject);
    procedure ProcOHintTimer(Sender:TObject);

    //procedure runonmousemove(Sender:TObject);
    procedure projectaxis;
    procedure create0axis;
    procedure reprojectaxis;
    procedure CalcOptimalMatrix;
    procedure SetOGLMatrix;
    procedure pushmatrix;
    procedure popmatrix;
    procedure ClearOntrackpoint;
    procedure Clear0Ontrackpoint;
    procedure sendmousecoordwop(key: GDBByte);
    procedure sendmousecoord(key: GDBByte);
    procedure sendcoordtocommand(coord:GDBVertex;key: GDBByte);
    procedure sendcoordtocommandTraceOn(coord:GDBVertex;key: GDBByte;pos:pos_record);
    //procedure setvisualprop;
    //procedure addoneobject;
    procedure setdeicevariable;
    procedure SetObjInsp;

    procedure draw;virtual;
    procedure drawdebuggeometry;
    function CreateRC(_maxdetail:GDBBoolean=false):TDrawContext;
    procedure finishdraw(var RC:TDrawContext);virtual;
    procedure SaveBuffers;virtual;
    procedure RestoreBuffers;virtual;
    procedure showcursor;
    procedure LightOn;
    procedure LightOff;
    procedure mypaint(sender:tobject);
    procedure mypaint2(sender:tobject;var f:boolean);

    function ProjectPoint(pntx,pnty,pntz:gdbdouble;var wcsLBN,wcsRTF,dcsLBN,dcsRTF: GDBVertex):gdbvertex;

    //procedure Pre_KeyDown(ch:char; var r:HandledMsg);virtual;
    //procedure Pre_LBMouseDblClk(fwkeys:longint;x,y:GDBInteger; var r:HandledMsg);virtual;

    procedure SetMouseMode(smode:GDBByte);

    procedure _onresize(sender:tobject);virtual;
    destructor Destroy; override;


    procedure delmyscrbuf;
    procedure CreateScrbuf(w,h:integer);

    procedure GDBActivate;
    procedure GDBActivateGLContext;

    procedure PanScreen(oldX,oldY,X,Y:Integer);

    procedure _onMouseMove(sender:tobject;Shift: TShiftState; X, Y: Integer);
    procedure _onFastMouseMove(sender:tobject;Shift: TShiftState; X, Y: Integer);
    procedure asynczoomall(Data: PtrInt);
    procedure ZoomAll;
    procedure SetCameraPosZoom(_pos:gdbvertex;_zoom:gdbdouble;finalcalk:gdbboolean);
    procedure RotTo(x0,y0,z0:GDBVertex);
    procedure myKeyPress(var Key: Word; Shift: TShiftState);

    procedure addaxistootrack(var posr:os_record;const axis:GDBVertex);

    {LCL}
    function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer;MousePos: TPoint): Boolean;override;
    protected
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;X, Y: Integer);override;
    procedure MouseUp(Button: TMouseButton; Shift:TShiftState;X, Y: Integer);override;
    procedure EraseBackground(DC: HDC);{$IFNDEF DELPHI}override;{$ENDIF}

    procedure FormCreate(Sender: TObject);
    procedure MouseEnter;{$IFNDEF DELPHI}override;{$ENDIF}
    procedure MouseLeave;{$IFNDEF DELPHI}override;{$ENDIF}
    procedure doCameraChanged;

  end;
const maxgrid=100;
var
    //pcommandline:PZEditWithProcedure;
    //playercombo:PZComboBoxWithProc;
    //plwcombo:PZComboBoxWithProc;

  {OGLWnd: TOGLWnd;}
   otracktimer: GDBInteger;
  uEventID: UINT;

  uEventIDtimer:cardinal;
  tick:cardinal;
  dt:integer;
  fps:single;
  gridarray:array [0..maxgrid,0..maxgrid] of GDBvertex2S;
  InfoForm:TInfoForm=nil;

//function timeSetEvent(uDelay, uReolution: UINT; lpTimeProc: GDBPointer;dwUser: DWord; fuEvent: UINT): GDBInteger; stdcall; external 'winmm';
//function timeKillEvent(uID: UINT): GDBInteger; stdcall; external 'winmm';

{procedure startup;
procedure finalize;}
function docorrecttogrid(point:GDBVertex;need:GDBBoolean):GDBVertex;
procedure textwrite(s: GDBString);
procedure RunTextEditor(Pobj:GDBPointer;const drawing:TDrawingDef);
//function getsortedindex(cl:integer):integer;
implementation
uses {mainwindow,}UGDBTracePropArray,GDBEntity,{io,}geometry,gdbobjectsconstdef,{UGDBDescriptor,}zcadinterface,
     shared,{cmdline,}GDBText;
procedure creategrid;
var i,j:GDBInteger;
begin
     for i:=0 to maxgrid do
      for j:=0 to maxgrid do
       begin
            //gridarray[i,j].x:=i*stepgrid-(maxgrid+1);//*stepgrid/2;
            //gridarray[i,j].y:=j*stepgrid-(maxgrid+1);//*stepgrid/2;
       end;
end;
procedure TOGLWnd.FormCreate(Sender: TObject);
begin
     sender:=sender;
end;
procedure TOGLWnd.EraseBackground(DC: HDC);
begin
     dc:=0;
end;
procedure TOGLWnd.mypaint;
begin
     param.firstdraw:=true;
     draw;
     inherited;
end;
procedure TOGLWnd.mypaint2(sender:tobject;var f:boolean);
begin
     draw;
     f:=true;
end;

procedure TOGLWnd.init;
begin
     //ControlStyle:=ControlStyle+[csNeedsBorderPaint];
     //FCompStyle:=csNonLCL;
  sh:=0;

  self.Hint:=inttostr(random(100));
  self.ShowHint:=true;

     {$IFNDEF DELPHI}onpaint:=mypaint;{$ENDIF};
     //Application.AddOnIdleHandler(mypaint2);
     //=====-----------------------------------------------------------------------------------------
     //onmousemove:=_onMouseMove;
     onmousemove:=_onFastMouseMove;
     //RGBA:=true;
     //dc:=GetDeviceContext(thdc);
     beforeinit;
     self.Cursor:=crNone;
     programlog.logoutstr('self.Cursor:=crNone;',0);
     OTTimer:=TTimer.create(self);
     OHTimer:=TTimer.create(self);
     programlog.logoutstr('OTTimer:=TTimer.create(self);',0);
     {OMMTimer:=TTimer.create(self);
     OMMTimer.Interval:=10;
     OMMTimer.OnTimer:=runonmousemove;
     OMMTimer.Enabled:=true;}
     //onDragDrop:=FormDragDrop;
     //OnCreate:=formcreate;
end;
procedure TOGLWnd.SetMouseMode(smode:GDBByte);
begin
     param.md.mode := smode;
end;

//procedure ProcTime(uID, msg: UINT; dwUse, dw1, dw2: DWord); stdcall;
procedure TOGLWnd.ProcOTrackTimer(Sender:TObject);
begin
  //timeKillEvent(uEventID);
  otracktimer := 1;
  OTTimer.Interval:=0;
  OTTimer.Enabled:=false;
end;
procedure TOGLWnd.KillOTrackTimer(Sender: TObject);
begin
  if param.otracktimerwork = 0 then exit;
  dec(param.otracktimerwork);
  OTTimer.Interval:=0;
  OTTimer.Enabled:=false;
  //timeKillEvent(uEventID);
end;
procedure TOGLWnd.SetOTrackTimer(Sender: TObject);
begin
  if param.otracktimerwork = 1 then exit;
  inc(param.otracktimerwork);
  if param.otracktimerwork > 0 then
                                   begin
                                        //uEventID := timeSetEvent(500, 250, @ProcTime, 0, 1)
                                        OTTimer.Interval:=500;
                                        OTTimer.OnTimer:=ProcOTrackTimer;
                                        OTTimer.Enabled:=true;

                                   end;
end;
procedure TOGLWnd.ProcOHintTimer(Sender:TObject);
begin
  //timeKillEvent(uEventID);
  //otracktimer := 1;
  {OHTimer.Interval:=0;
  OHTimer.Enabled:=false;

  if sh=0 then
  begin
  self.Hint:=inttostr(random(100));
  self.ShowHint:=true;
  sh:=1;
  end;}
end;
procedure TOGLWnd.KillOHintTimer(Sender: TObject);
begin
  //Application.CancelHint;
  {if self.ShowHint then
   self.ShowHint:=self.ShowHint;
  if sh=1 then
                       begin
                            //self.Hint:='++';
                            //self.ShowHint:=false;
                            sh:=0;
                       end;
  }
  OHTimer.Interval:=0;
  OHTimer.Enabled:=false;
end;

procedure TOGLWnd.SetOHintTimer(Sender: TObject);
begin
    Hint:=GetOnMouseObjDesc;
    ShowHint:=true;
    if hint<>'' then
    Application.ActivateHint(ClientToScreen(Point(param.md.mouse.x,param.md.mouse.y)))
    else
        application.CancelHint;

                                   begin
                                        //uEventID := timeSetEvent(500, 250, @ProcTime, 0, 1)
                                        OHTimer.Interval:=500;
                                        OHTimer.OnTimer:=ProcOHintTimer;
                                        OHTimer.Enabled:=true;

                                   end;
end;
procedure copyospoint(out dest:os_record; source:os_record);
begin
       dest.worldcoord:=source.worldcoord;
       dest.dispcoord:=source.dispcoord;
       dest.ostype:=source.ostype;
       //dest.radius:=source.radius;
       //dest.dmousecoord:=source.dmousecoord;
       //dest.tmouse:=source.tmouse;
       dest.PGDBObject:=source.PGDBObject;
end;

procedure TOGLWnd.AddOntrackpoint;
begin
  if sysvar.dwg.DWG_PolarMode^ = 0 then exit;
  copyospoint(param.ontrackarray.otrackarray[param.ontrackarray.current],param.ospoint);
  param.ontrackarray.otrackarray[param.ontrackarray.current].arrayworldaxis.clear;
  param.ontrackarray.otrackarray[param.ontrackarray.current].arraydispaxis.clear;
  param.ospoint.arrayworldaxis.copyto(@param.ontrackarray.otrackarray[param.ontrackarray.current].arrayworldaxis);
  param.ospoint.arraydispaxis.copyto(@param.ontrackarray.otrackarray[param.ontrackarray.current].arraydispaxis);


  inc(param.ontrackarray.current);
  if param.ontrackarray.current = maxtrackpoint then
  begin
    param.ontrackarray.current := 1;
  end;
  if param.ontrackarray.total < maxtrackpoint then
  begin
    inc(param.ontrackarray.total);
  end;
end;

procedure TOGLWnd.Project0Axis;
var
  tp: traceprop;
  temp: gdbvertex;
  pv: pgdbvertex;
  i: GDBInteger;
begin
  {GDBGetMem(param.ospoint.arrayworldaxis, sizeof(GDBWord) + param.ppolaraxis
    ^.count * sizeof(gdbvertex));
  Move(param.ppolaraxis^, param.ospoint.arrayworldaxis^, sizeof(GDBWord) +
    param.ppolaraxis^.count * sizeof(gdbvertex)); }
  {gdb.GetCurrentDWG^}pdwg.myGluProject2(param.ontrackarray.otrackarray[0
    ].worldcoord,
             param.ontrackarray.otrackarray[0].dispcoord);
  //param.ontrackarray.otrackarray[0].arraydispaxis.init({$IFDEF DEBUGBUILD}'{722A886F-5616-4E8F-B94D-3A1C3D7ADBD4}', {$ENDIF}    param.ontrackarray.otrackarray[0].arrayworldaxis.count);
  param.ontrackarray.otrackarray[0].arraydispaxis.clear;
  //GDBGetMem(param.ospoint.arraydispaxis, sizeof(GDBWord) +param.ospoint.arrayworldaxis.count * sizeof(traceprop));
  //param.ospoint.arraydispaxis.count := param.ospoint.arrayworldaxis.count;
  pv:=param.ontrackarray.otrackarray[0].arrayworldaxis.PArray;
  for i := 0 to param.ontrackarray.otrackarray[0].arrayworldaxis.count - 1 do
  begin
    {gdb.GetCurrentDWG^}pdwg.myGluProject2(createvertex(param.ontrackarray.otrackarray
      [0].worldcoord.x + pv.x, param.ontrackarray.otrackarray[0].worldcoord.y +
      pv.y, param.ontrackarray.otrackarray[0].worldcoord.z + pv.z)
                                    , temp);
    tp.dir.x:=temp.x - param.ontrackarray.otrackarray[0].dispcoord.x;
    tp.dir.y:=(temp.y - param.ontrackarray.otrackarray[0].dispcoord.y);
    tp.dir.z:=temp.z - param.ontrackarray.otrackarray[0].dispcoord.z;
    param.ontrackarray.otrackarray[0].arraydispaxis.add(@tp);
    {param.ospoint.arraydispaxis.arr[i].dir.x := temp.x -
      param.ospoint.dispcoord.x;
    param.ospoint.arraydispaxis.arr[i].dir.y := -(temp.y -
      param.ospoint.dispcoord.y);
    param.ospoint.arraydispaxis.arr[i].dir.z := temp.z -
      param.ospoint.dispcoord.z; }
    inc(pv);
  end
end;

procedure TOGLWnd.ClearOntrackpoint;
var
   i:integer;
begin
    { if param.ontrackarray.total>1 then
     for i := 0 to param.ontrackarray.total-1 do
                                              param.ontrackarray.otrackarray[i].arrayworldaxis.done;}
  param.ontrackarray.current := 1;
  param.ontrackarray.total := 1;
end;
procedure TOGLWnd.Clear0Ontrackpoint;
var
   i:integer;
begin
  {   if param.ontrackarray.total>1 then
     for i := 0 to param.ontrackarray.total-1 do
                                              param.ontrackarray.otrackarray[i].arrayworldaxis.done;}
  param.ontrackarray.current := 1;
  param.ontrackarray.total := 1;
  {mainwindow.OGLwindow1.}tocommandmcliccount:=0;
end;



function ProjectPoint2(pntx,pnty,pntz:gdbdouble; var m:DMatrix4D; var ccsLBN,ccsRTF:GDBVertex):gdbvertex;
begin
     result.x:=pntx;
     result.y:=pnty;
     result.z:=pntz;
     result:=geometry.VectorTransform3D(result,m);

     if result.x<ccsLBN.x then
                              begin
                                   ccsLBN.x:=result.x;
                              end;
                          //else
     if result.y<ccsLBN.y then
                              begin
                                   ccsLBN.y:=result.y;
                              end;
                          //else
     if result.z<ccsLBN.z then
                              begin
                                   ccsLBN.z:=result.z;
                              end;
                          //else
     if result.x>ccsRTF.x then
                              begin
                                   ccsRTF.x:=result.x;
                              end;
                          //else
     if result.y>ccsRTF.y then
                              begin
                                   ccsRTF.y:=result.y;
                              end ;
                          //else
     if result.z>ccsRTF.z then
                              begin
                                   ccsRTF.z:=result.z;
                              end;
end;
procedure TOGLWnd.pushmatrix;
begin
  oglsm.myglMatrixMode(GL_PROJECTION);
  oglsm.myglpushmatrix;
  oglsm.myglMatrixMode(GL_MODELVIEW);
  oglsm.myglpushmatrix;
end;
procedure TOGLWnd.popmatrix;
begin
  oglsm.myglMatrixMode(GL_MODELVIEW);
  oglsm.myglpopmatrix;
  oglsm.myglMatrixMode(GL_PROJECTION);
  oglsm.myglpopmatrix;
  oglsm.myglMatrixMode(GL_MODELVIEW);
end;
procedure TOGLWnd.SetOGLMatrix;
begin
  {$IFDEF PERFOMANCELOG}log.programlog.LogOutStrFast('TOGLWnd.SetOGLMatrix',0);{$ENDIF}
  oglsm.myglViewport(0, 0, clientWidth, clientHeight);
  oglsm.myglGetIntegerv(GL_VIEWPORT, @{gdb.GetCurrentDWG}pdwg.GetPcamera^.viewport);

  oglsm.myglMatrixMode(GL_MODELVIEW);
  oglsm.myglLoadMatrixD(@{gdb.GetCurrentDWG}pdwg.GetPcamera^.modelMatrixLCS);

  oglsm.myglMatrixMode(GL_PROJECTION);
  oglsm.myglLoadMatrixD(@{gdb.GetCurrentDWG}pdwg.GetPcamera^.projMatrixLCS);

  oglsm.myglMatrixMode(GL_MODELVIEW);


  {gdb.GetCurrentDWG}pdwg.GetPcamera^.getfrustum(@{gdb.GetCurrentDWG}pdwg.GetPcamera^.modelMatrix,   @{gdb.GetCurrentDWG}pdwg.GetPcamera^.projMatrix,   {gdb.GetCurrentDWG}pdwg.GetPcamera^.clip,   {gdb.GetCurrentDWG}pdwg.GetPcamera^.frustum);
  {gdb.GetCurrentDWG}pdwg.GetPcamera^.getfrustum(@{gdb.GetCurrentDWG}pdwg.GetPcamera^.modelMatrixLCS,@{gdb.GetCurrentDWG}pdwg.GetPcamera^.projMatrixLCS,{gdb.GetCurrentDWG}pdwg.GetPcamera^.clipLCS,{gdb.GetCurrentDWG}pdwg.GetPcamera^.frustumLCS);

end;
procedure TOGLWnd.CalcOptimalMatrix;
var ccsLBN,ccsRTF:GDBVertex;
    tm:DMatrix4D;
    LBN:GDBvertex;(*'ЛевыйНижнийБлижний'*)
    RTF:GDBvertex;
    tbb,tbb2:GDBBoundingBbox;
    //pdwg:PTDrawing;
    proot:PGDBObjGenericSubEntry;
    pcamera:PGDBObjCamera;
    td:GDBDouble;
begin
  {$IFDEF PERFOMANCELOG}log.programlog.LogOutStrFast('TOGLWnd.CalcOptimalMatrix',lp_IncPos);{$ENDIF}
  {Если нет примитивов выходим}
  //pdwg:=gdb.GetCurrentDWG;
  //self.MakeCurrent;
  if pdwg=nil then exit;
  proot:=PDWG.GetCurrentROOT;
  pcamera:=pdwg.getpcamera;

  if (assigned(pdwg))and(assigned(proot))and(assigned(pcamera))then
  begin
  Pcamera^.modelMatrix:=lookat(Pcamera^.prop.point,
                                               Pcamera^.prop.xdir,
                                               Pcamera^.prop.ydir,
                                               Pcamera^.prop.look,@onematrix);
  //glGetDoublev(GL_MODELVIEW_MATRIX, @pdwg.pcamera^.modelMatrix);

  {pdwg.pcamera^.modelMatrix[0][0]:=pdwg.pcamera^.modelMatrix[0][0]/1e5;
  pdwg.pcamera^.modelMatrix[1][1]:=pdwg.pcamera^.modelMatrix[1][1]/1e5;
  pdwg.pcamera^.modelMatrix[2][2]:=pdwg.pcamera^.modelMatrix[2][2]/1e5;

  pdwg.pcamera^.modelMatrix[3][0]:=pdwg.pcamera^.modelMatrix[3][0]/1e5;
  pdwg.pcamera^.modelMatrix[3][1]:=pdwg.pcamera^.modelMatrix[3][1]/1e5;
  pdwg.pcamera^.modelMatrix[3][2]:=pdwg.pcamera^.modelMatrix[3][2]/1e5;

  pdwg.pcamera^.modelMatrix[3][3]:=pdwg.pcamera^.modelMatrix[3][3]*1e5;}

  ccsLBN:=InfinityVertex;
  ccsRTF:=MinusInfinityVertex;
  {ProjectPoint2(proot.vp.BoundingBox.LBN.x,proot.vp.BoundingBox.LBN.y,proot.vp.BoundingBox.LBN.Z,pdwg.pcamera^.modelMatrix,ccsLBN,ccsRTF);
  ProjectPoint2(proot.vp.BoundingBox.RTF.x,proot.vp.BoundingBox.LBN.y,proot.vp.BoundingBox.LBN.Z,pdwg.pcamera^.modelMatrix,ccsLBN,ccsRTF);
  ProjectPoint2(proot.vp.BoundingBox.RTF.x,proot.vp.BoundingBox.RTF.y,proot.vp.BoundingBox.LBN.Z,pdwg.pcamera^.modelMatrix,ccsLBN,ccsRTF);
  ProjectPoint2(proot.vp.BoundingBox.LBN.x,proot.vp.BoundingBox.RTF.y,proot.vp.BoundingBox.LBN.Z,pdwg.pcamera^.modelMatrix,ccsLBN,ccsRTF);
  ProjectPoint2(proot.vp.BoundingBox.LBN.x,proot.vp.BoundingBox.LBN.y,proot.vp.BoundingBox.RTF.Z,pdwg.pcamera^.modelMatrix,ccsLBN,ccsRTF);
  ProjectPoint2(proot.vp.BoundingBox.RTF.x,proot.vp.BoundingBox.LBN.y,proot.vp.BoundingBox.RTF.Z,pdwg.pcamera^.modelMatrix,ccsLBN,ccsRTF);
  ProjectPoint2(proot.vp.BoundingBox.RTF.x,proot.vp.BoundingBox.RTF.y,proot.vp.BoundingBox.RTF.Z,pdwg.pcamera^.modelMatrix,ccsLBN,ccsRTF);
  ProjectPoint2(proot.vp.BoundingBox.LBN.x,proot.vp.BoundingBox.RTF.y,proot.vp.BoundingBox.RTF.Z,pdwg.pcamera^.modelMatrix,ccsLBN,ccsRTF);
  }
  {ProjectPoint2(proot.VisibleOBJBoundingBox.LBN.x,proot.VisibleOBJBoundingBox.LBN.y,proot.VisibleOBJBoundingBox.LBN.Z,pdwg.pcamera^.modelMatrix,ccsLBN,ccsRTF);
  ProjectPoint2(proot.VisibleOBJBoundingBox.RTF.x,proot.VisibleOBJBoundingBox.LBN.y,proot.VisibleOBJBoundingBox.LBN.Z,pdwg.pcamera^.modelMatrix,ccsLBN,ccsRTF);
  ProjectPoint2(proot.VisibleOBJBoundingBox.RTF.x,proot.VisibleOBJBoundingBox.RTF.y,proot.VisibleOBJBoundingBox.LBN.Z,pdwg.pcamera^.modelMatrix,ccsLBN,ccsRTF);
  ProjectPoint2(proot.VisibleOBJBoundingBox.LBN.x,proot.VisibleOBJBoundingBox.RTF.y,proot.VisibleOBJBoundingBox.LBN.Z,pdwg.pcamera^.modelMatrix,ccsLBN,ccsRTF);
  ProjectPoint2(proot.VisibleOBJBoundingBox.LBN.x,proot.VisibleOBJBoundingBox.LBN.y,proot.VisibleOBJBoundingBox.RTF.Z,pdwg.pcamera^.modelMatrix,ccsLBN,ccsRTF);
  ProjectPoint2(proot.VisibleOBJBoundingBox.RTF.x,proot.VisibleOBJBoundingBox.LBN.y,proot.VisibleOBJBoundingBox.RTF.Z,pdwg.pcamera^.modelMatrix,ccsLBN,ccsRTF);
  ProjectPoint2(proot.VisibleOBJBoundingBox.RTF.x,proot.VisibleOBJBoundingBox.RTF.y,proot.VisibleOBJBoundingBox.RTF.Z,pdwg.pcamera^.modelMatrix,ccsLBN,ccsRTF);
  ProjectPoint2(proot.VisibleOBJBoundingBox.LBN.x,proot.VisibleOBJBoundingBox.RTF.y,proot.VisibleOBJBoundingBox.RTF.Z,pdwg.pcamera^.modelMatrix,ccsLBN,ccsRTF);}

  tbb:=proot.vp.BoundingBox;

  if IsBBNul(tbb) then
  begin
       {tbb.LBN:=geometry.VertexAdd(pdwg.tpcamera^.prop.point,MinusOneVertex);
       tbb.RTF:=geometry.VertexAdd(pdwg.tpcamera^.prop.point,OneVertex);}
       concatBBandPoint(tbb,param.CSIcon.CSIconCoord);
       concatBBandPoint(tbb,param.CSIcon.CSIconX);
       concatBBandPoint(tbb,param.CSIcon.CSIconY);
       concatBBandPoint(tbb,param.CSIcon.CSIconZ);
  end;

  if pdwg.GetConstructObjRoot.ObjArray.Count>0 then
                       begin
  pdwg.GetConstructObjRoot.calcbb;
  tbb2:=pdwg.GetConstructObjRoot.vp.BoundingBox;
  ConcatBB(tbb,tbb2);
  end;
  {if param.CSIcon.AxisLen>eps then
  begin
  concatBBandPoint(tbb,param.CSIcon.CSIconCoord);
  concatBBandPoint(tbb,param.CSIcon.CSIconX);
  concatBBandPoint(tbb,param.CSIcon.CSIconY);
  concatBBandPoint(tbb,param.CSIcon.CSIconZ);
  end;}


  if IsBBNul(tbb) then
  begin
       tbb.LBN:=geometry.VertexAdd(pcamera^.prop.point,MinusOneVertex);
       tbb.RTF:=geometry.VertexAdd(pcamera^.prop.point,OneVertex);
  end;

  //if param.CSIcon.AxisLen>eps then
  begin
  //concatBBandPoint(tbb,param.CSIcon.CSIconCoord);
  //concatBBandPoint(tbb,param.CSIcon.CSIconX);
  //concatBBandPoint(tbb,param.CSIcon.CSIconY);
  //concatBBandPoint(tbb,param.CSIcon.CSIconZ);
  end;

  LBN:=tbb.LBN;
  RTF:=tbb.RTF;

  ProjectPoint2(LBN.x,LBN.y,LBN.Z,pcamera^.modelMatrix,ccsLBN,ccsRTF);
  ProjectPoint2(RTF.x,LBN.y,LBN.Z,pcamera^.modelMatrix,ccsLBN,ccsRTF);
  ProjectPoint2(RTF.x,RTF.y,LBN.Z,pcamera^.modelMatrix,ccsLBN,ccsRTF);
  ProjectPoint2(LBN.x,RTF.y,LBN.Z,pcamera^.modelMatrix,ccsLBN,ccsRTF);
  ProjectPoint2(LBN.x,LBN.y,RTF.Z,pcamera^.modelMatrix,ccsLBN,ccsRTF);
  ProjectPoint2(RTF.x,LBN.y,RTF.Z,pcamera^.modelMatrix,ccsLBN,ccsRTF);
  ProjectPoint2(RTF.x,RTF.y,RTF.Z,pcamera^.modelMatrix,ccsLBN,ccsRTF);
  ProjectPoint2(LBN.x,RTF.y,RTF.Z,pcamera^.modelMatrix,ccsLBN,ccsRTF);

  ccsLBN.z:=-ccsLBN.z;
  ccsRTF.z:=-ccsRTF.z;
  td:=(ccsRTF.z-ccsLBN.z)/20;
  ccsLBN.z:=ccsLBN.z-td;
  ccsRTF.z:=ccsRTF.z+td;
  if (ccsLBN.z-ccsRTF.z)<sqreps then
                                 begin
                                      ccsLBN.z:=ccsLBN.z+1;
                                      ccsRTF.z:=ccsRTF.z-1;
                                 end;
  pcamera^.obj_zmAx:=ccsLBN.z;
  pcamera^.obj_zmin:=ccsRTF.z;
  pcamera^.zmax:=pcamera^.obj_zmAx;
  pcamera^.zmin:=pcamera^.obj_zmin;


  {if pdwg.pcamera^.zmax>10000 then
                                                pdwg.pcamera^.zmax:=100000;
  if pdwg.pcamera^.zmin<10000 then
                                                  pdwg.pcamera^.zmin:=-10000;}


  if param.projtype = PROJPerspective then
  begin
       if pcamera^.zmin<pcamera^.zmax/10000 then
                                                  pcamera^.zmin:=pcamera^.zmax/10000;
       if pcamera^.zmin<10 then
                                                  pcamera^.zmin:=10;
       if pcamera^.zmax<pcamera^.zmin then
                                                  pcamera^.zmax:=1000;
  end;



  if param.projtype = ProjParalel then
                                      begin
                                      pcamera^.projMatrix:=ortho(-clientwidth*pcamera^.prop.zoom/2,clientwidth*pcamera^.prop.zoom/2,
                                                                                 -clientheight*pcamera^.prop.zoom/2,clientheight*pcamera^.prop.zoom/2,
                                                                                 pcamera^.zmin, pcamera^.zmax,@onematrix);
                                      end
                                  else
                                      BEGIN
                                           pcamera^.projMatrix:=Perspective(pcamera^.fovy, Width / Height, pcamera^.zmin, pcamera^.zmax,@onematrix);
  //glGetDoublev(GL_PROJECTION_MATRIX, @pdwg.pcamera^.projMatrix);
                                      end;


  ///pdwg.pcamera.getfrustum(@pdwg.pcamera^.modelMatrix,   @pdwg.pcamera^.projMatrix,   pdwg.pcamera^.clip,   pdwg.pcamera^.frustum);



  pcamera^.CamCSOffset:=NulVertex;
  pcamera^.CamCSOffset.z:=(pcamera^.zmax+pcamera^.zmin)/2;
  pcamera^.CamCSOffset.z:=(pcamera^.zmin);


  tm:=pcamera^.modelMatrix;
  //MatrixInvert(tm);
  pcamera^.CamCSOffset:=geometry.VectorTransform3D(pcamera^.CamCSOffset,tm);
  pcamera^.CamCSOffset:=pcamera^.prop.point;

  {получение центра виевфрустума}
  tm:=geometry.CreateTranslationMatrix({minusvertex(pdwg.pcamera^.CamCSOffset)}nulvertex);

  //pdwg.pcamera^.modelMatrixLCS:=tm;
  pcamera^.modelMatrixLCS:=lookat({vertexsub(pdwg.pcamera^.prop.point,pdwg.pcamera^.CamCSOffset)}nulvertex,
                                               pcamera^.prop.xdir,
                                               pcamera^.prop.ydir,
                                               pcamera^.prop.look,{@tm}@onematrix);
  pcamera^.modelMatrixLCS:=geometry.MatrixMultiply(tm,pcamera^.modelMatrixLCS);
  ccsLBN:=InfinityVertex;
  ccsRTF:=MinusInfinityVertex;
  tbb:=proot.VisibleOBJBoundingBox;
  //pdwg.ConstructObjRoot.calcbb;
  tbb2:=pdwg.getConstructObjRoot.vp.BoundingBox;
  ConcatBB(tbb,tbb2);

  //proot.VisibleOBJBoundingBox:=tbb;

  if not IsBBNul(tbb) then
  begin
        LBN:=tbb.LBN;
        LBN:=vertexadd(LBN,pcamera^.CamCSOffset);
        RTF:=tbb.RTF;
        RTF:=vertexadd(RTF,pcamera^.CamCSOffset);
  end
  else
  begin
       LBN:=geometry.VertexMulOnSc(OneVertex,50);
       //LBN:=vertexadd(LBN,pdwg.pcamera^.CamCSOffset);
       RTF:=geometry.VertexMulOnSc(OneVertex,100);
       //RTF:=vertexadd(RTF,pdwg.pcamera^.CamCSOffset);
  end;
  ProjectPoint2(LBN.x,LBN.y,LBN.Z,pcamera^.modelMatrixLCS,ccsLBN,ccsRTF);
  ProjectPoint2(RTF.x,LBN.y,LBN.Z,pcamera^.modelMatrixLCS,ccsLBN,ccsRTF);
  ProjectPoint2(RTF.x,RTF.y,LBN.Z,pcamera^.modelMatrixLCS,ccsLBN,ccsRTF);
  ProjectPoint2(LBN.x,RTF.y,LBN.Z,pcamera^.modelMatrixLCS,ccsLBN,ccsRTF);
  ProjectPoint2(LBN.x,LBN.y,RTF.Z,pcamera^.modelMatrixLCS,ccsLBN,ccsRTF);
  ProjectPoint2(RTF.x,LBN.y,RTF.Z,pcamera^.modelMatrixLCS,ccsLBN,ccsRTF);
  ProjectPoint2(RTF.x,RTF.y,RTF.Z,pcamera^.modelMatrixLCS,ccsLBN,ccsRTF);
  ProjectPoint2(LBN.x,RTF.y,RTF.Z,pcamera^.modelMatrixLCS,ccsLBN,ccsRTF);
  ccsLBN.z:=-ccsLBN.z;
  ccsRTF.z:=-ccsRTF.z;
  td:=(ccsRTF.z-ccsLBN.z)/20;
  ccsLBN.z:=ccsLBN.z-td;
  ccsRTF.z:=ccsRTF.z+td;
  if (ccsLBN.z-ccsRTF.z)<sqreps then
                                 begin
                                      if abs(ccsLBN.z)>eps then
                                      begin
                                      ccsLBN.z:=ccsLBN.z/10;
                                      ccsRTF.z:=ccsRTF.z*10;
                                      end
                                      else
                                      begin
                                      ccsLBN.z:=+1;
                                      ccsRTF.z:=-1;
                                      end
                                 end;
  pcamera^.obj_zmAx:=ccsLBN.z;
  pcamera^.obj_zmin:=ccsRTF.z;
  pcamera^.zmaxLCS:=pcamera^.obj_zmAx;
  pcamera^.zminLCS:=pcamera^.obj_zmin;


  if param.projtype = PROJPerspective then
  begin
       if pcamera^.zminLCS<pcamera^.zmaxLCS/10000 then
                                                  pcamera^.zminLCS:=pcamera^.zmaxLCS/10000;
       if pcamera^.zminLCS<10 then
                                                  pcamera^.zminLCS:=10;
       if pcamera^.zmaxLCS<pcamera^.zminLCS then
                                                  pcamera^.zmaxLCS:=1000;
  end;

  pcamera^.zminLCS:=pcamera^.zminLCS;//-pdwg.pcamera^.CamCSOffset.z;
  pcamera^.zmaxLCS:=pcamera^.zmaxLCS;//+pdwg.pcamera^.CamCSOffset.z;

  //glLoadIdentity;
  //pdwg.pcamera^.projMatrix:=onematrix;
  if param.projtype = ProjParalel then
                                      begin
                                      pcamera^.projMatrixLCS:=ortho(-clientwidth*pcamera^.prop.zoom/2,clientwidth*pcamera^.prop.zoom/2,
                                                                                 -clientheight*pcamera^.prop.zoom/2,clientheight*pcamera^.prop.zoom/2,
                                                                                 pcamera^.zminLCS, pcamera^.zmaxLCS,@onematrix);
                                      end
                                  else
                                      BEGIN
                                           pcamera^.projMatrixLCS:=Perspective(pcamera^.fovy, Width / Height, pcamera^.zminLCS, pcamera^.zmaxLCS,@onematrix);
  //glGetDoublev(GL_PROJECTION_MATRIX, @pdwg.pcamera^.projMatrix);
                                      end;
  if param.projtype = ProjParalel then
                                      begin
                                           //OGLSpecFunc.CurrentCamCSOffset:=pdwg.pcamera^.CamCSOffset;
                                           if geometry.oneVertexlength(pcamera^.CamCSOffset)>1000000 then
                                           begin
                                                OGLSpecFunc.CurrentCamCSOffset:=pcamera^.CamCSOffset;
                                            OGLSpecFunc.notuseLCS:=pcamera^.notuseLCS;
                                           end
                                           else OGLSpecFunc.notuseLCS:=true;
                                      end
                                  else
                                      begin
                                            OGLSpecFunc.notuseLCS:=true;
                                      end;
  if OGLSpecFunc.notuseLCS then
  begin
        pcamera^.projMatrixLCS:=pcamera^.projMatrix;
        pcamera^.modelMatrixLCS:=pcamera^.modelMatrix;
        pcamera^.frustumLCS:=pcamera^.frustum;
        pcamera^.CamCSOffset:=NulVertex;
        OGLSpecFunc.CurrentCamCSOffset:=nulvertex;
  end;


  if {pdwg.pcamera^.notuseLCS}OGLSpecFunc.notuseLCS then
  begin
        pcamera^.projMatrixLCS:=pcamera^.projMatrix;
        pcamera^.modelMatrixLCS:=pcamera^.modelMatrix;
        pcamera^.frustumLCS:=pcamera^.frustum;
        pcamera^.CamCSOffset:=NulVertex;
        OGLSpecFunc.CurrentCamCSOffset:=nulvertex;
  end;
  SetOGLMatrix;
  end;
    {$IFDEF PERFOMANCELOG}log.programlog.LogOutStrFast('TOGLWnd.CalcOptimalMatrix----{end}',lp_DecPos);{$ENDIF}
  //gdb.GetCurrentDWG.pcamera.getfrustum(@gdb.GetCurrentDWG.pcamera^.modelMatrixLCS,@gdb.GetCurrentDWG.pcamera^.projMatrixLCS,gdb.GetCurrentDWG.pcamera^.clipLCS,gdb.GetCurrentDWG.pcamera^.frustumLCS);
end;
procedure TOGLWnd.CorrectMouseAfterOS;
var d,tv1,tv2:GDBVertex;
    b1,b2:GDBBoolean;
begin
     param.md.mouseraywithoutos:=param.md.mouseray;
     if (param.ospoint.ostype <> os_none)or(currentmousemovesnaptogrid) then
     begin

     if param.projtype = ProjParalel then
     begin
          d:=pdwg.getpcamera^.prop.look;
          b1:=PointOfLinePlaneIntersect(param.ospoint.worldcoord,d,pdwg.getpcamera^.frustum[4],tv1);
          b2:=PointOfLinePlaneIntersect(param.ospoint.worldcoord,d,pdwg.getpcamera^.frustum[5],tv2);
          if (b1 and b2) then
                             begin
                                  param.md.mouseray.lbegin:=tv1;
                                  param.md.mouseray.lend:=tv2;
                                  param.md.mouseray.dir:=vertexsub(tv2,tv1);
                             end;
     end
     else
     begin
         d:=VertexSub(param.ospoint.worldcoord,pdwg.getpcamera^.prop.point);
         //d:=gdb.GetCurrentDWG.pcamera^.prop.look;
         b1:=PointOfLinePlaneIntersect(param.ospoint.worldcoord,d,pdwg.getpcamera^.frustum[4],tv1);
         b2:=PointOfLinePlaneIntersect(param.ospoint.worldcoord,d,pdwg.getpcamera^.frustum[5],tv2);
         if (b1 and b2) then
                            begin
                                 param.md.mouseray.lbegin:=tv1;
                                 param.md.mouseray.lend:=tv2;
                                 param.md.mouseray.dir:=vertexsub(tv2,tv1);
                            end;
         pdwg^.myGluUnProject(createvertex(param.ospoint.dispcoord.x, param.ospoint.dispcoord.y, 0),param.md.mouseray.lbegin);
         pdwg^.myGluUnProject(createvertex(param.ospoint.dispcoord.x, param.ospoint.dispcoord.y, 1),param.md.mouseray.lend);
     end;
     end;
end;

procedure TOGLWnd.calcgrid;
var ca, cv: extended;
    tempv,cav: gdbvertex;  ds:GDBString;
    l,u,r,b,maxh,maxv,ph,pv:GDBDouble;
    x,y:integer;
begin
     if pdwg=NIL then exit;


     //BLPoint,CPoint,TRPoint:GDBvertex2D;
     tempv.x:=0;
     tempv.y:=0;
     tempv.z:=0;
     pdwg^.myGluUnProject(tempv,cav);
     param.BLPoint.x:=cav.x;
     param.BLPoint.y:=cav.y;

     tempv.x:=clientwidth/2;
     tempv.y:=clientheight/2;
     tempv.z:=0;
     pdwg^.myGluUnProject(tempv,cav);
     param.CPoint.x:=cav.x;
     param.CPoint.y:=cav.y;

     tempv.x:=clientwidth;
     tempv.y:=clientheight;
     tempv.z:=0;
     pdwg^.myGluUnProject(tempv,cav);
     param.TRPoint.x:=cav.x;
     param.TRPoint.y:=cav.y;

     tempv.x:=0;
     tempv.y:=clientheight;
     tempv.z:=0;
     pdwg^.myGluUnProject(tempv,cav);
     param.ViewHeight:=cav.y-param.BLPoint.y;


     pdwg^.myGluProject2(NulVertex,param.CSIcon.CSIconCoord);

     if (param.CSIcon.CSIconCoord.x>0)and(param.CSIcon.CSIconCoord.y>0)and(param.CSIcon.CSIconCoord.x<clientwidth)and(param.CSIcon.CSIconCoord.y<clientheight)
     then
     begin
          pdwg^.myGluProject2(x_Y_zVertex,
                                  cav);
          cav.x:=param.CSIcon.CSIconCoord.x-cav.x;
          cav.y:=param.CSIcon.CSIconCoord.y-cav.y;
          param.CSIcon.axislen:=sqrt(cav.x*cav.x+cav.y*cav.y);
          param.CSIcon.CSIconCoord.x:=0;
          param.CSIcon.CSIconCoord.y:=0;
          param.CSIcon.CSIconCoord.z:=0;
     end
     else
     begin
     pdwg^.myGluUnProject(createvertex(40, 40, 0.1),
                                 param.CSIcon.CSIconCoord);
          pdwg^.myGluProject2(CreateVertex(param.CSIcon.CSIconCoord.x,param.CSIcon.CSIconCoord.y+1,param.CSIcon.CSIconCoord.z),

                     cav);
          cav.x:=40-cav.x;
          cav.y:=40-cav.y;
          param.CSIcon.axislen:=sqrt(cav.x*cav.x+cav.y*cav.y);

     end;
     if param.CSIcon.axislen>eps then
                                     param.CSIcon.axislen:=100/param.CSIcon.axislen;
     param.CSIcon.CSIconX:=param.CSIcon.CSIconCoord;
     param.CSIcon.CSIconX.x:=param.CSIcon.CSIconX.x+param.CSIcon.axislen;
     param.CSIcon.CSIconY:=param.CSIcon.CSIconCoord;
     param.CSIcon.CSIconY.y:=param.CSIcon.CSIconY.y+param.CSIcon.axislen;
     param.CSIcon.CSIconZ:=param.CSIcon.CSIconCoord;
     param.CSIcon.CSIconZ.z:=param.CSIcon.CSIconZ.z+param.CSIcon.axislen;


     pdwg^.myGluProject2(CreateVertex(param.CSIcon.CSIconCoord.x + sizeaxis * pdwg.getpcamera^.prop.zoom, param.CSIcon.CSIconCoord.y, param.CSIcon.CSIconCoord.z),
                CAV);
     param.CSIcon.csx.x := round(cav.x);
     param.CSIcon.csx.y := round(cav.y);
     pdwg^.myGluProject2(CreateVertex(param.CSIcon.CSIconCoord.x, param.CSIcon.CSIconCoord.y + sizeaxis * pdwg.getpcamera^.prop.zoom, param.CSIcon.CSIconCoord.z),
                CAV);
     param.CSIcon.csy.x := round(cav.x);
     param.CSIcon.csy.y := round(cav.y);
     pdwg^.myGluProject2(CreateVertex(param.CSIcon.CSIconCoord.x, param.CSIcon.CSIconCoord.y, param.CSIcon.CSIconCoord.z + sizeaxis * pdwg.getpcamera^.prop.zoom),
                CAV);
     param.CSIcon.csz.x := round(cav.x);
     param.CSIcon.csz.y := round(cav.y);

     param.md.WPPointLU:=PointOf3PlaneIntersect(pdwg.getpcamera.frustum[0],pdwg.getpcamera.frustum[3],param.md.workplane);
     param.md.WPPointUR:=PointOf3PlaneIntersect(pdwg.getpcamera.frustum[3],pdwg.getpcamera.frustum[1],param.md.workplane);
     param.md.WPPointRB:=PointOf3PlaneIntersect(pdwg.getpcamera.frustum[1],pdwg.getpcamera.frustum[2],param.md.workplane);
     param.md.WPPointBL:=PointOf3PlaneIntersect(pdwg.getpcamera.frustum[2],pdwg.getpcamera.frustum[0],param.md.workplane);
     l:=Vertexlength(param.md.WPPointLU,param.md.WPPointBL);
     r:=Vertexlength(param.md.WPPointUR,param.md.WPPointRB);
     u:=Vertexlength(param.md.WPPointLU,param.md.WPPointUR);
     b:=Vertexlength(param.md.WPPointRB,param.md.WPPointBL);
     if r>l then
                maxv:=r
            else
                maxv:=l;
     if b>u then
                maxh:=b
            else
                maxh:=u;
     ph:={round}(maxh/sysvar.DWG.DWG_StepGrid.y);
     pv:={round}(maxv/sysvar.DWG.DWG_StepGrid.x);
     param.md.WPPointUR.z:=1;
     if (4*ph>clientwidth)or(4*pv>clientheight)then
                                                   begin
                                                        if sysvar.DWG.DWG_DrawGrid<>nil then
                                                        if sysvar.DWG.DWG_DrawGrid^ then
                                                                                        historyoutstr(rsGridTooDensity);
                                                        param.md.WPPointUR.z:=-1;
                                                   end;
     param.md.WPPointLU:=vertexmulonsc(vertexsub(param.md.WPPointLU,param.md.WPPointBL),1/pv);
     param.md.WPPointRB:=vertexmulonsc(vertexsub(param.md.WPPointRB,param.md.WPPointBL),1/ph);

     param.md.WPPointBL.x:=round((param.md.WPPointBL.x-SysVar.DWG.DWG_OriginGrid.x)/SysVar.DWG.DWG_StepGrid.x)*SysVar.DWG.DWG_StepGrid.x+SysVar.DWG.DWG_OriginGrid.x;
     param.md.WPPointBL.y:=round((param.md.WPPointBL.y-SysVar.DWG.DWG_OriginGrid.y)/SysVar.DWG.DWG_StepGrid.y)*SysVar.DWG.DWG_StepGrid.y+SysVar.DWG.DWG_OriginGrid.y;
     param.md.WPPointBL.z:=(-param.md.workplane[3]-param.md.workplane[0]*param.md.WPPointBL.x-param.md.workplane[1]*param.md.WPPointBL.y)/param.md.workplane[2];

     param.md.WPPointUR.x:=ph;
     param.md.WPPointUR.y:=pv;



end;

procedure TOGLWnd.mouseunproject(X, Y: integer);
var ca, cv: extended;cav: gdbvertex;  ds:GDBString;
begin
  if pdwg=NIL then exit;

  //calcgrid;

  pdwg^.myGluUnProject(createvertex(x, y, 0),param.md.mouseray.lbegin);
  pdwg^.myGluUnProject(createvertex(x, y, 1),param.md.mouseray.lend);

  //gdb.GetCurrentDWG^.myGluProject2(CreateVertex(1000, 1000, 1000),cav);
  //param.mouseray.lbegin := param.glmcoord[0];



  param.md.mouseray.dir:=vertexsub(param.md.mouseray.lend,param.md.mouseray.lbegin);
  //param.md.mouseray.dir.x := param.md.mouseray.lend.x - param.md.mouseray.lbegin.x;
  //param.md.mouseray.dir.y := param.md.mouseray.lend.y - param.md.mouseray.lbegin.y;
  //param.md.mouseray.dir.z := param.md.mouseray.lend.z - param.md.mouseray.lbegin.z;

  cav.x := -param.md.mouseray.lbegin.x;
  cav.y := -param.md.mouseray.lbegin.y;
  cav.z := -param.md.workplane{.d}[3] / param.md.workplane{.normal.z}[2] * param.md.mouseray.dir.z - param.md.mouseray.lbegin.z;
  //ca := param.md.workplane.normal.x * cav.x + param.md.workplane.normal.y * cav.y + param.md.workplane.normal.z * cav.z;
  {cv := param.md.workplane.normal.x * param.md.mouseray.dir.x +
        param.md.workplane.normal.y * param.md.mouseray.dir.y +
        param.md.workplane.normal.z * param.md.mouseray.dir.z;}

  cv:=param.md.workplane{.normal.x}[0]*param.md.mouseray.dir.x +
      param.md.workplane{.normal.y}[1]*param.md.mouseray.dir.y +
      param.md.workplane{.normal.z}[2]*param.md.mouseray.dir.z;
  ca:=-param.md.workplane{.d}[3] - param.md.workplane{.normal.x}[0]*param.md.mouseray.lbegin.x -
       param.md.workplane{.normal.y}[1]*param.md.mouseray.lbegin.y -
       param.md.workplane{.normal.z}[2]*param.md.mouseray.lbegin.z;
  if cv = 0 then param.md.mouseonworkplan := false
  else begin
    param.md.mouseonworkplan := true;
    ca := ca / cv;
    param.md.mouseonworkplanecoord.x := param.md.mouseray.lbegin.x + param.md.mouseray.dir.x * ca;
    param.md.mouseonworkplanecoord.y := param.md.mouseray.lbegin.y + param.md.mouseray.dir.y * ca;
    param.md.mouseonworkplanecoord.z := param.md.mouseray.lbegin.z + param.md.mouseray.dir.z * ca;

    ca:=param.md.workplane{.normal.x}[0] * param.md.mouseonworkplanecoord.x +
        param.md.workplane{.normal.y}[1] * param.md.mouseonworkplanecoord.y +
        param.md.workplane{.normal.z}[2] * param.md.mouseonworkplanecoord.z+param.md.workplane{.d}[3];

    if ca<>0 then
    begin
         param.md.mouseonworkplanecoord.x:=param.md.mouseonworkplanecoord.x-param.md.workplane{.normal.x}[0]*ca;
         param.md.mouseonworkplanecoord.y:=param.md.mouseonworkplanecoord.y-param.md.workplane{.normal.y}[1]*ca;
         param.md.mouseonworkplanecoord.z:=param.md.mouseonworkplanecoord.z-param.md.workplane{.normal.z}[2]*ca;
    end;
    ca:=param.md.workplane{.normal.x}[0] * param.md.mouseonworkplanecoord.x +
        param.md.workplane{.normal.y}[1] * param.md.mouseonworkplanecoord.y +
        param.md.workplane{.normal.z}[2] * param.md.mouseonworkplanecoord.z + param.md.workplane{.d}[3];
    str(ca,ds);
  end;
end;
procedure TOGLWnd.RestoreMouse;
var
  fv1: GDBVertex;
begin
  CalcOptimalMatrix;
  mouseunproject(param.md.mouse.x, clientheight-param.md.mouse.y);
  reprojectaxis;
  if param.seldesc.MouseFrameON then
  begin
    pdwg^.myGluProject2(param.seldesc.Frame13d,
               fv1);
    param.seldesc.Frame1.x := round(fv1.x);
    param.seldesc.Frame1.y := clientheight - round(fv1.y);
    if param.seldesc.Frame1.x < 0 then param.seldesc.Frame1.x := 0
    else if param.seldesc.Frame1.x > (clientwidth - 1) then param.seldesc.Frame1.x := clientwidth - 1;
    if param.seldesc.Frame1.y < 0 then param.seldesc.Frame1.y := 1
    else if param.seldesc.Frame1.y > (clientheight - 1) then param.seldesc.Frame1.y := clientheight - 1;
  end;

  //param.zoommode := true;
  //param.scrollmode:=true;
  pdwg.GetCurrentROOT.CalcVisibleByTree(pdwg.getpcamera^.frustum,pdwg.getpcamera.POSCOUNT,pdwg.getpcamera.VISCOUNT,pdwg.GetCurrentROOT.ObjArray.ObjTree,pdwg.getpcamera.totalobj,pdwg.getpcamera.infrustum,pdwg.myGluProject2,pdwg.getpcamera.prop.zoom);
  //gdb.GetCurrentROOT.calcvisible(gdb.GetCurrentDWG.pcamera^.frustum,gdb.GetCurrentDWG.pcamera.POSCOUNT,gdb.GetCurrentDWG.pcamera.VISCOUNT);
  pdwg.GetCurrentROOT.calcvisible(pdwg.getpcamera^.frustum,pdwg.getpcamera.POSCOUNT,pdwg.getpcamera.VISCOUNT,pdwg.getpcamera.totalobj,pdwg.getpcamera.infrustum,pdwg.myGluProject2,pdwg.getpcamera.prop.zoom);
  pdwg.GetSelObjArray.RenderFeedBack(pdwg^.GetPcamera^.POSCOUNT,pdwg^.GetPcamera^,pdwg^.myGluProject2);

  calcmousefrustum;

  if param.lastonmouseobject<>nil then
                                      begin
                                           PGDBObjEntity(param.lastonmouseobject)^.RenderFeedBack(pdwg.GetPcamera^.POSCOUNT,pdwg^.GetPcamera^, pdwg^.myGluProject2);
                                      end;

  Set3dmouse;
  calcgrid;

  {paint;}

  _onFastMouseMove(self,[],param.md.mouse.x,param.md.mouse.y);

end;

function TOGLWnd.DoMouseWheel(Shift: TShiftState; WheelDelta: Integer;
  MousePos: TPoint): Boolean;
//procedure TOGLWnd.Pre_MouseWheel;
var
//  mpoint: tpoint;
  smallwheel:gdbdouble;
//    glx1, gly1: GDBDouble;
  fv1: GDBVertex;

//  msg : TMsg;

begin
  {$IFDEF PERFOMANCELOG}log.programlog.LogOutStrFast('TOGLWnd.DoMouseWheel',lp_incPos);{$ENDIF}
  smallwheel:=1+(sysvar.DISP.DISP_ZoomFactor^-1)/10;
  //mpoint := point(mousepos.x - clientorigin.X, mousepos.y - clientorigin.y);
  if {mousein(mpoint)}true then
  begin
    //mpoint := point({mpoint.x - left}0, {mpoint.y - top}0);
    if wheeldelta < 0 then
    begin
      if (ssShift in Shift) then
        DISP_ZoomFactor({1.01}smallwheel)
      else
      begin
        ClearOntrackpoint;
        Create0axis;
        DISP_ZoomFactor(sysvar.DISP.DISP_ZoomFactor^);
      end;
      //handled := true;
    end
    else
    begin
      if (ssShift in Shift) then
        DISP_ZoomFactor({0.990099009901}1/smallwheel)
      else
      begin
        ClearOntrackpoint;
        DISP_ZoomFactor(1 / sysvar.DISP.DISP_ZoomFactor^);
      end;
      //handled := true;
    end;
  end;
  //pre_mousemove(0,param.md.mouse.x,param.md.mouse.y,r);
      //param.firstdraw := true;
      //CalcOptimalMatrix;
      //gdb.GetCurrentDWG.ObjRoot.calcvisible;
      //gdb.GetCurrentDWG.ConstructObjRoot.calcvisible;
      //reprojectaxis;
      //draw;
      pdwg.getpcamera^.NextPosition;
      param.firstdraw:=true;
  restoremouse;
  paint;

  {if (PeekMessage(msg,handle,WM_MOUSEWHEEL,0,PM_NOREMOVE)) then
                                                                           param.scrollmode:=true
                                                                       else
                                                                           begin
                                                                           param.scrollmode:=false;
                                                                           paint;
                                                                           end;}

  inherited;
  result:=true;
  _onFastMouseMove(self,[],param.md.mouse.x,param.md.mouse.y);
  {$IFDEF PERFOMANCELOG}log.programlog.LogOutStrFast('TOGLWnd.DoMouseWheel----{end}',lp_decPos);{$ENDIF}
end;
{var
  mpoint: tpoint;
begin
  mpoint := point(param.md.mouse.X,param.md.mouse.y);
  if mousein(mpoint)true then
  begin
    mpoint := point(mpoint.x, mpoint.y);
    if wheeldelta < 0 then
    begin
      if (MK_shift and fwKeys)<>0 then
        DISP_ZoomFactor(1.01, mpoint)
      else
      begin
        DISP_ZoomFactor(varmandef.sysvar.DISP_ZoomFactor^, mpoint);
      end;
    end
    else
    begin
      if (MK_shift and fwKeys)<>0 then
        DISP_ZoomFactor(0.990099009901, mpoint)
      else
      begin
        DISP_ZoomFactor(1 / varmandef.sysvar.DISP_ZoomFactor^, mpoint);
      end;
    end;
  end;
end;}
procedure TOGLWnd.SetObjInsp;
var //p:PGDBOpenArrayOfByte;
    tn:GDBString;
    ptype:PUserTypeDescriptor;
begin

  if param.SelDesc.Selectedobjcount>1 then
    begin
       commandmanager.ExecuteCommandSilent('MultiSelect2ObjIbsp',pdwg);
    end
  else
  begin
  //p:=nil;
  if (param.SelDesc.LastSelectedObject <> nil)and SysVar.DWG.DWG_SelectedObjToInsp^ then
  begin
       tn:=PGDBObjEntity(param.SelDesc.LastSelectedObject)^.GetObjTypeName;
       ptype:=SysUnit.TypeName2PTD(tn);
       if ptype<>nil then
       begin
            If assigned(SetGDBObjInspProc)then
            SetGDBObjInspProc(ptype,param.SelDesc.LastSelectedObject);
       end;
  end
  else
  begin
    If assigned(ReturnToDefaultProc)then
    {GDBobjinsp.}ReturnToDefaultProc;
  end;
  end
end;
procedure TOGLWnd._onFastMouseMove(sender:tobject;Shift: TShiftState; X, Y: Integer);
var dx,dy:integer;
  {$IFDEF LCLGTK2}Widget: PGtkWidget;{$ENDIF}
begin
     (*if FastMMX>0 then
                      begin
                           dx:=x-FastMMX;
                           dy:=y-FastMMY;
                           dx:=dx*dx+dy*dy;
                           if dx>16 then
                                      begin
                                      _onMouseMove(nil,FastMMShift,FastMMX,FastMMY);
                                      {FastMMX:=-1;
                                      FastMMY:=-1;
                                      exit;}
                                      end;
                      end;*)

(*
  {$IFDEF LCLGTK2}
  Widget:=PGtkWidget(PtrUInt(Handle));
  FastMMX:=XPending(GDK_WINDOW_XDISPLAY(PGtkWidget(Widget)^.window));
  if sysvar.debug.memi2<fastmmx then
                                    sysvar.debug.memi2:=fastmmx;
  if FastMMX=0 then{$ENDIF}
*)

     _onMouseMove(nil,shift,X,Y);

     FastMMX:=-1;


     {FastMMShift:=shift;
     FastMMX:=X;
     FastMMY:=Y;}

end;
{procedure  TOGLWnd.runonmousemove(Sender:TObject);
begin
     if FastMMX>0 then
     begin
     _onMouseMove(nil,FastMMShift,FastMMX,FastMMY);
     FastMMX:=-1;

     end;
end;}
procedure TOGLWnd.PanScreen(oldX,oldY,X,Y:Integer);
var
  glmcoord1: gdbpiece;
  tv2:gdbvertex4d;
  ax:gdbvertex;
  ux,uy:GDBDouble;
  htext,htext2:gdbstring;
  key: GDBByte;
  lptime:ttime;
begin
  mouseunproject(oldX, clientheight-oldY);
  glmcoord1:= param.md.mouseraywithoutos;
  mouseunproject(X, clientheight-Y);
  tv2.x:=(x - {param.md.mouse.x}oldX);
  tv2.y:=(y - {param.md.mouse.y}oldY);
  if (abs(tv2.x)>eps)or(abs(tv2.y)>eps) then
  begin
       ax.x:=-(param.md.mouseray.lend.x - glmcoord1.lend.x);
       ax.y:=(param.md.mouseray.lend.y - glmcoord1.lend.y);
       ax.z:=0;
       pdwg.MoveCameraInLocalCSXY(tv2.x,tv2.y,ax);
       {with gdb.GetCurrentDWG.UndoStack.PushCreateTGChangeCommand(gdb.GetCurrentDWG.pcamera^.prop)^ do
       begin
       gdb.GetCurrentDWG.pcamera.moveInLocalCSXY(tv2.x,tv2.y,ax);
       ComitFromObj;
       end;}
       param.firstdraw := true;
       pdwg.Getpcamera^.NextPosition;
       CalcOptimalMatrix;
       calcgrid;
       //gdb.GetCurrentDWG.Changed:=true;
       //-------------CalcOptimalMatrix;
       lptime:=now();
       pdwg.GetCurrentROOT.CalcVisibleByTree(pdwg.Getpcamera^.frustum,pdwg.Getpcamera.POSCOUNT,pdwg.Getpcamera.VISCOUNT,pdwg.GetCurrentROOT.ObjArray.ObjTree,pdwg.getpcamera.totalobj,pdwg.getpcamera.infrustum,pdwg.myGluProject2,pdwg.getpcamera.prop.zoom);
       lptime:=now()-LPTime;
       sysvar.RD.RD_LastCalcVisible:=round(lptime*10e7);
       //gdb.GetCurrentROOT.calcvisible(gdb.GetCurrentDWG.pcamera^.frustum,gdb.GetCurrentDWG.pcamera.POSCOUNT);
       pdwg.GetConstructObjRoot.calcvisible(pdwg.Getpcamera^.frustum,pdwg.Getpcamera.POSCOUNT,pdwg.Getpcamera.VISCOUNT,pdwg.getpcamera.totalobj,pdwg.getpcamera.infrustum,pdwg.myGluProject2,pdwg.getpcamera.prop.zoom);
  end;

end;

procedure TOGLWnd._onMouseMove(sender:tobject;Shift: TShiftState; X, Y: Integer);
//procedure TOGLWnd.Pre_MouseMove;
var
  glmcoord1: gdbpiece;
  tv2:gdbvertex4d;
  ax:gdbvertex;
  ux,uy:GDBDouble;
  htext,htext2:gdbstring;

//  tm2,tm3:dmatrix4d;

//  i:integer;
  key: GDBByte;
  lptime:ttime;
begin
  //if random<0.8 then exit;
  //if   (param.md.mouse.y=y)and(param.md.mouse.x=x)then
  //                                                    exit;
  {$IFDEF PERFOMANCELOG}log.programlog.LogOutStrFast('TOGLWnd.Pre_MouseMove',lp_IncPos);{$ENDIF}
  if assigned(mainmousemove)then
                                mainmousemove;
  KillOHintTimer(self);
  SetOHintTimer(self);
  currentmousemovesnaptogrid:=false;
  key:=0;
  if (ssShift in Shift) then
                            key := key or MZW_SHIFT;
  if (ssCtrl in Shift) then
                                    key := key or MZW_CONTROL;
  if pdwg=nil then
                            begin
                                   param.md.mouse.y := y;
                                   param.md.mouse.x := x;
                                   param.md.glmouse.y := clientheight-y;
                                   param.md.glmouse.x := x;
                                   exit;
                            end;
  glmcoord1:= param.md.mouseraywithoutos;
  //if param.ospoint.ostype<>os_none then
  //                                   glmcoord1.lend := param.ospoint.worldcoord;  //пан при привязке ездит меньше

  if ((param.md.mode) and ((MRotateCamera) or (MMoveCamera)) <> 0) then
    if ((ssCtrl in shift) and ((ssMiddle in shift))) and ((param.md.mode) and (MRotateCamera) <> 0) then
    begin
      uy :=(x - param.md.mouse.x) / 1000;
      ux :=- (y - param.md.mouse.y) / 1000;
      pdwg.RotateCameraInLocalCSXY(ux,uy);
      {with gdb.GetCurrentDWG.UndoStack.CreateTGChangeCommand(gdb.GetCurrentDWG.pcamera^.prop)^ do
      begin
      gdb.GetCurrentDWG.pcamera.RotateInLocalCSXY(ux,uy);
      ComitFromObj;
      end;}
      param.firstdraw := true;
      pdwg.GetPcamera^.NextPosition;
      CalcOptimalMatrix;
      calcgrid;
      //-------------------CalcOptimalMatrix;

      pdwg.GetCurrentROOT.CalcVisibleByTree(pdwg.Getpcamera^.frustum,pdwg.Getpcamera.POSCOUNT,pdwg.Getpcamera.VISCOUNT,pdwg.GetCurrentROOT.ObjArray.ObjTree,pdwg.getpcamera.totalobj,pdwg.getpcamera.infrustum,pdwg.myGluProject2,pdwg.getpcamera.prop.zoom);
      //gdb.GetCurrentROOT.calcalcvisible(gdb.GetCurrentDWG.pcamera^.frustum,gdb.GetCurrentDWG.pcamera.POSCOUNT);
      pdwg.GetConstructObjRoot.calcvisible(pdwg.Getpcamera^.frustum,pdwg.Getpcamera.POSCOUNT,pdwg.Getpcamera.VISCOUNT,pdwg.getpcamera.totalobj,pdwg.getpcamera.infrustum,pdwg.myGluProject2,pdwg.getpcamera.prop.zoom);
      doCameraChanged;
    end
    else
      if ssMiddle in shift then     {MK_Control}
begin
      PanScreen(param.md.mouse.x,param.md.mouse.y,X,Y{,glmcoord1});
      doCameraChanged;
end;

  param.md.mouse.y := y;
  param.md.mouse.x := x;
  param.md.glmouse.y := clientheight-y;
  param.md.glmouse.x := x;

  param.md.mouseglue := param.md.mouse;
  param.gluetocp := false;

  if (param.md.mode and MGetControlpoint) <> 0 then
  begin
    param.nearesttcontrolpoint:=pdwg.GetSelObjArray.getnearesttomouse(param.md.mouse.x,param.height-param.md.mouse.y);
    if (param.nearesttcontrolpoint.pcontrolpoint = nil) or (param.nearesttcontrolpoint.disttomouse > 2 * sysvar.DISP.DISP_CursorSize^) then
    begin
      param.md.mouseglue := param.md.mouse;
      param.gluetocp := false;
    end
    else begin
      param.gluetocp := true;
      param.md.mouseglue := param.nearesttcontrolpoint.pcontrolpoint^.dispcoord;
      param.md.mouseglue.y:=clientheight-param.md.mouseglue.y;
    end;
  end
  else param.md.mouseglue := param.md.mouse;

  //param.md.mouse:=param.md.mouseglue;
  param.md.glmouse.x := param.md.mouseglue.x;
  param.md.glmouse.y := clientheight-param.md.mouseglue.y;

  CalcOptimalMatrix;
  mouseunproject(param.md.glmouse.X, param.md.glmouse.Y);
  CalcMouseFrustum;




  //gdb.GetCurrentDWG.pcamera^.getfrustum();   tyui
  //param.mousefrustum:=gdb.GetCurrentDWG.pcamera^.frustum;

{  for I := 0 to 5 do
    //if param.mousefrustum[0][i]<0 then
                                      begin
                                           param.mousefrustum[i][0]:=-param.mousefrustum[i][0];
                                           param.mousefrustum[i][1]:=-param.mousefrustum[i][1];
                                           param.mousefrustum[i][2]:=-param.mousefrustum[i][2];
                                           param.mousefrustum[i][3]:=-param.mousefrustum[i][3];

                                           param.mousefrustum[i][0]:=param.mousefrustum[i][0]*0.5;
                                           param.mousefrustum[i][1]:=param.mousefrustum[i][1]*0.5;
                                           param.mousefrustum[i][2]:=param.mousefrustum[i][2]*0.5;
                                           param.mousefrustum[i][3]:=param.mousefrustum[i][3]*0.99;
                                      end;

 }
  {param.mousefrustum[0][3]:=-param.mousefrustum[0][3];
  param.mousefrustum[0][0]:=-param.mousefrustum[0][0];

  param.mousefrustum[1][3]:=-param.mousefrustum[1][3];
  param.mousefrustum[1][0]:=-param.mousefrustum[1][0];}

  {param.mousefrustum[1][3]:=-param.mousefrustum[1][3];
  param.mousefrustum[1][0]:=-param.mousefrustum[1][0];}

  {
  param.mousefrustum[1][3]:=-param.mousefrustum[1][3];
  param.mousefrustum[2][3]:=-param.mousefrustum[2][3];
  param.mousefrustum[3][3]:=-param.mousefrustum[3][3];}








  if (param.md.mode and MGetSelectObject) <> 0 then
                                                     getonmouseobjectbytree(PDWG.GetCurrentROOT.ObjArray.ObjTree);
  if (param.md.mode and MGet3DPointWoOP) <> 0 then param.ospoint.ostype := os_none;
  if (param.md.mode and MGet3DPoint) <> 0 then
  begin

      if (param.md.mode and MGetSelectObject) = 0 then
                                                      getonmouseobjectbytree(pdwg.GetCurrentROOT.ObjArray.ObjTree);
      getosnappoint({@gdb.GetCurrentROOT.ObjArray,} 0);
      //create0axis;-------------------------------
    if sysvar.dwg.DWG_OSMode^ <> 0 then
    begin
      if otracktimer = 1 then
      begin
        otracktimer := 0;
        projectaxis;
        project0axis;//-------------------------------
        AddOntrackpoint;
      end;
      if (param.ospoint.ostype <> os_none)and(param.ospoint.ostype <> os_snap)and(param.ospoint.ostype <> os_nearest)and(param.ospoint.ostype<>os_perpendicular) then
      begin
        SetOTrackTimer(@self);
        copyospoint(param.oldospoint,param.ospoint);
      end
      else KillOTrackTimer(@self)
    end
    else param.ospoint.ostype := os_none;

  end
  else param.ospoint.ostype := os_none;




  reprojectaxis;

  if (param.md.mode and (MGet3DPoint or MGet3DPointWoOp)) <> 0 then
     sendmousecoordwop(key);
    {if pcommandrunning <> nil then
    begin
      if param.ospoint.ostype <> os_none then pcommandrunning^.MouseMoveCallback(param.ospoint.worldcoord, param.md.mouse, 0)
      else begin
        if param.mouseonworkplan then
          pcommandrunning^.MouseMoveCallback(param.mouseonworkplanecoord,param.md.mouse, 0)
        else pcommandrunning^.MouseMoveCallback(param.glmcoord[0], param.md.mouse, 0);
      end;
    end;}
     //glGetDoublev(GL_MODELVIEW_MATRIX,@modelMatrix);
  //mouseunproject(param.md.mouse.x, param.md.mouse.y);
  //reprojectaxis;
  if param.seldesc.MouseFrameON then
  begin
    pdwg^.myGluProject2(param.seldesc.Frame13d,
               glmcoord1.lbegin);
    param.seldesc.Frame1.x := round(glmcoord1.lbegin.x);
    param.seldesc.Frame1.y := clientheight - round(glmcoord1.lbegin.y);
    if param.seldesc.Frame1.x < 0 then param.seldesc.Frame1.x := 0
    else if param.seldesc.Frame1.x > (clientwidth - 1) then param.seldesc.Frame1.x := clientwidth - 1;
    if param.seldesc.Frame1.y < 0 then param.seldesc.Frame1.y := 1
    else if param.seldesc.Frame1.y > (clientheight - 1) then param.seldesc.Frame1.y := clientheight - 1;
  end;
     //GDBobjinsp23.reread;
  //CalcOptimalMatrix;
  CalcOptimalMatrix;
  pdwg.GetConstructObjRoot.calcvisible(pdwg.Getpcamera^.frustum,pdwg.Getpcamera.POSCOUNT,pdwg.Getpcamera.VISCOUNT,pdwg.getpcamera.totalobj,pdwg.getpcamera.infrustum,pdwg.myGluProject2,pdwg.getpcamera.prop.zoom);

  //gdb.GetCurrentDWG.ConstructObjRoot.calcvisible(gdb.GetCurrentDWG.OGLwindow1.param.mousefrustum);

  pdwg.GetSelObjArray.calcvisible(pdwg.Getpcamera^.frustum,pdwg.Getpcamera.POSCOUNT,pdwg.Getpcamera.VISCOUNT,pdwg.getpcamera.totalobj,pdwg.getpcamera.infrustum,pdwg.myGluProject2,pdwg.getpcamera.prop.zoom);
  Set3dmouse;



  htext:=FloatToStrf(param.md.mouse3dcoord.x,ffFixed,10,3)+','+FloatToStrf(param.md.mouse3dcoord.y,ffFixed,10,3)+','+FloatToStrf(param.md.mouse3dcoord.z,ffFixed,10,3);
  if {mainwindow.OGLwindow1.}param.polarlinetrace = 1 then
  begin
       htext2:='L='+FloatToStrf(param.ontrackarray.otrackarray[param.pointnum].tmouse,ffFixed,10,3);
       htext:=htext+' '+htext2;
       Hint:=htext2;
       Application.ActivateHint(ClientToScreen(Point(param.md.mouse.x,param.md.mouse.y)));
  end;


if PGDBObjEntity(param.SelDesc.OnMouseObject)<>nil then
                                                       begin
                                                            if PGDBObjEntity(param.SelDesc.OnMouseObject)^.vp.Layer._lock
                                                              then
                                                                  self.Cursor:=crNoDrop
                                                              else
                                                                  self.Cursor:=crNone;
                                                       end
                                                   else
                                                       if not param.scrollmode then
                                                                                   self.Cursor:=crNone;

  //if assigned(GDBobjinsp)then
                               if assigned(GetCurrentObjProc) then
                               if GetCurrentObjProc=@sysvar then
                               If assigned(UpdateObjInspProc)then
                                                                UpdateObjInspProc;
  SBTextOut(htext);
  //param.firstdraw:=true;
  isOpenGLError;
  CorrectMouseAfterOS;
  {repaint;//}draw;//paint;
  inc(sysvar.debug.int1);
  //debugvar(Variables,1);

  {$IFDEF PERFOMANCELOG}log.programlog.LogOutStrFast('TOGLWnd.Pre_MouseMove----{end}',lp_decPos);{$ENDIF}
end;
procedure textwrite(s: GDBString);
var
  psymbol: PGDBByte;
  i, j, k: GDBInteger;
  len: GDBWord;
  matr: {array[0..3, 0..3] of GDBDouble}DMatrix4D;
begin
  exit;
  (*
  {FillChar(matr, sizeof(GDBDouble) * 16, 0);
  matr[0, 0] := 1;
  matr[1, 1] := 1;
  matr[2, 2] := 1;
  matr[3, 3] := 1;}
  matr:=geometry.OneMatrix;
  matr[1, 0] := 1/tan(pi/2-12*pi/180);
     //glscaled(PGDBtext(p)^.wfactor,1,1);
  glrotated(0, 0, 0, 1);
  glscaled(0.65 * 10, 10, 10);
  //exit;
  glMultMatrixd(@matr);
  i := 1;
  while i <= length(s) do
  begin
    psymbol := GDBPointer(GDBPlatformint(pbasefont)+pgdbfont(pbasefont).symbolinfo[GDBByte(s[i])].addr);
    if pgdbfont(pbasefont)^.symbolinfo[GDBByte(s[i])].size <> 0 then
      for j := 1 to pgdbfont(pbasefont)^.symbolinfo[GDBByte(s[i])].size do
      begin
        case GDBByte(psymbol^) of
          2:
            begin
              inc(psymbol, sizeof(GDBLineID));
              oglsm.myglbegin(GL_lines);
              glVertex2fv(GDBPointer(psymbol));
              inc(psymbol, 2 * sizeof(fontfloat));
              glVertex2fv(GDBPointer(psymbol));
              inc(psymbol, 2 * sizeof(fontfloat));
              oglsm.myglend;
            end;
          4:
            begin
              inc(psymbol, sizeof(GDBPolylineID));
              len := GDBWord(psymbol^);
              inc(psymbol, sizeof(GDBWord));
              oglsm.myglbegin(GL_line_strip);
              glVertex2fv(GDBPointer(psymbol));
              inc(psymbol, 2 * sizeof(fontfloat));
              k := 1;
              while k < len do
              begin
                glVertex2fv(GDBPointer(psymbol));
                inc(psymbol, 2 * sizeof(fontfloat));
                inc(k);
              end;
              oglsm.myglend;
            end;
        end;
      end;
    gltranslated(pgdbfont(pbasefont).symbolinfo[GDBByte(s[i])].NextSymX, 0, 0);
    inc(i);
  end;
  *)
end;
procedure TOGLWnd.Set3dmouse;
begin
    if (param.ospoint.ostype <> os_none)or(currentmousemovesnaptogrid)
    then
    begin
         param.md.mouse3dcoord:=param.ospoint.worldcoord;
    end
    else
    begin
        if param.md.mouseonworkplan
        then
            begin
                 param.md.mouse3dcoord:=param.md.mouseonworkplanecoord;
            end
        else
            begin
                 param.md.mouse3dcoord:=param.md.mouseray.lbegin;
            end;
       end;
end;

procedure TOGLWnd.sendmousecoordwop(key: GDBByte);
var
   tv:gdbvertex;
begin
  if commandmanager.pcommandrunning <> nil then
    if param.ospoint.ostype <> os_none
    then
    begin
         begin
              {if (key and MZW_LBUTTON)<>0 then
                                              shared.HistoryOutStr(floattostr(param.ospoint.ostype));}
              tv:=param.ospoint.worldcoord;
              if (key and MZW_SHIFT)<>0 then
                                            begin
                                                 key:=key and (not MZW_SHIFT);
                                                 tv:=Vertexmorphabs(param.lastpoint,param.ospoint.worldcoord,1);
                                            end;
              if (key and MZW_CONTROL)<>0 then
                                            begin
                                                 key:=key and (not MZW_CONTROL);
                                                 tv:=Vertexmorphabs(param.lastpoint,param.ospoint.worldcoord,-1);
                                            end;
              key:=key and (not MZW_CONTROL);
              key:=key and (not MZW_SHIFT);

              {if key=MZW_LBUTTON then
                                     begin
                                          inc(tocommandmcliccount);
                                          param.ontrackarray.otrackarray[0].worldcoord:=tv;
                                     end;
              if (key and MZW_LBUTTON)<>0 then
                                              param.lastpoint:=tv;
              commandmanager.pcommandrunning^.MouseMoveCallback(tv, param.md.mouse, key,@param.ospoint);}

              sendcoordtocommandTraceOn(tv,key,@param.ospoint)
         end;
    end
    else
    begin
        {if key=MZW_LBUTTON then
                               begin
                               inc(tocommandmcliccount);
                               param.ontrackarray.otrackarray[0].worldcoord:=param.md.mouseonworkplanecoord;
                               end;}
        if param.md.mouseonworkplan
        then
            begin
                 if sysvar.DWG.DWG_SnapGrid<>nil then
                 if not sysvar.DWG.DWG_SnapGrid^ then
                 param.ospoint.worldcoord:=param.md.mouseonworkplanecoord;
                 sendcoordtocommandTraceOn({param.md.mouseonworkplanecoord}param.ospoint.worldcoord,key,nil)
                 //if key=MZW_LBUTTON then param.lastpoint:=param.md.mouseonworkplanecoord;
                 //commandmanager.pcommandrunning.MouseMoveCallback(param.md.mouseonworkplanecoord, param.md.mouse, key,nil)
            end
        else
            begin
                 param.ospoint.worldcoord:=param.md.mouseray.lbegin;
                 sendcoordtocommandTraceOn(param.md.mouseray.lbegin,key,nil)
                 //if key=MZW_LBUTTON then param.lastpoint:=param.md.mouseray.lbegin;
                 //commandmanager.pcommandrunning^.MouseMoveCallback(param.md.mouseray.lbegin, param.md.mouse, key,nil);
            end;
    end;
end;

procedure TOGLWnd.sendmousecoord(key: GDBByte);
begin
  if commandmanager.pcommandrunning <> nil then
    if param.md.mouseonworkplan
    then
        begin
             sendcoordtocommand(param.md.mouseonworkplanecoord,key);
             //if key=MZW_LBUTTON then param.lastpoint:=param.md.mouseonworkplanecoord;
             //commandmanager.pcommandrunning^.MouseMoveCallback(param.md.mouseonworkplanecoord, param.md.mouse, key,nil)
        end
    else
        begin
             sendcoordtocommand(param.md.mouseray.lbegin,key);
             //if key=MZW_LBUTTON then param.lastpoint:=param.md.mouseray.lbegin;
             //commandmanager.pcommandrunning^.MouseMoveCallback(param.md.mouseray.lbegin, param.md.mouse, key,nil);
        end;
    //if key=MZW_LBUTTON then param.ontrackarray.otrackarray[0].worldcoord:=param.md.mouseonworkplanecoord;
end;
procedure TOGLWnd.sendcoordtocommand(coord:GDBVertex;key: GDBByte);
begin
     if key=MZW_LBUTTON then param.lastpoint:=coord;
     commandmanager.sendpoint2command(coord, param.md.mouse, key,nil,pdwg^);
end;
procedure TOGLWnd.sendcoordtocommandTraceOn(coord:GDBVertex;key: GDBByte;pos:pos_record);
begin
     //if commandmanager.pcommandrunning<>nil then
     //if commandmanager.pcommandrunning.IsRTECommand then
        commandmanager.sendpoint2command(coord,param.md.mouse,key,pos,pdwg^);

     if (key and MZW_LBUTTON)<>0 then
     if commandmanager.pcommandrunning<>nil then
     begin
           inc(tocommandmcliccount);
           param.ontrackarray.otrackarray[0].worldcoord:=coord;
           param.lastpoint:=coord;
           create0axis;
           project0axis;
     end;
     //end;
end;

procedure TOGLWnd.DrawGrid;
var
  pg:PGDBvertex2S;
  i,j: GDBInteger;
  v,v1:gdbvertex;
begin

    {   ph:=](maxh/sysvar.DWG.DWG_StepGrid.y);
     pv:=](maxv/sysvar.DWG.DWG_StepGrid.x);
     if (2*ph>clientwidth)or(2*pv>clientheight)then
                                                   begin
                                                        historyout('Grid too density')
                                                   end;
     param.md.WPPointLU:=vertexmulonsc(vertexsub(param.md.WPPointLU,param.md.WPPointBL),1/pv);
     param.md.WPPointRB:=vertexmulonsc(vertexsub(param.md.WPPointRB,param.md.WPPointBL),1/ph);

     param.md.WPPointBL.x:=round((param.md.WPPointBL.x-SysVar.DWG.DWG_OriginGrid.x)/SysVar.DWG.DWG_StepGrid.x)*SysVar.DWG.DWG_StepGrid.x+SysVar.DWG.DWG_OriginGrid.x;
     param.md.WPPointBL.y:=round((param.md.WPPointBL.y-SysVar.DWG.DWG_OriginGrid.y)/SysVar.DWG.DWG_StepGrid.y)*SysVar.DWG.DWG_StepGrid.y+SysVar.DWG.DWG_OriginGrid.y;

     param.md.WPPointUR.x:=ph;
     param.md.WPPointUR.z:=pv;}

  if sysvar.DWG.DWG_DrawGrid<>nil then
  if (sysvar.DWG.DWG_DrawGrid^)and(param.md.WPPointUR.z=1) then
  begin
  //CalcOptimalMatrix;
  v:=param.md.WPPointBL;
  oglsm.glcolor3ub(100, 100, 100);
  pg := @gridarray;
  oglsm.myglbegin(gl_points);
  for i := 0 to {maxgrid}round(param.md.WPPointUR.x) do
  begin
       v1:=v;
        for j := 0 to {maxgrid}round(param.md.WPPointUR.y) do
        begin
          oglsm.myglVertex3d({createvertex(i,j,0)}v1);
          //v1:=vertexadd(v1,param.md.WPPointLU);
          //v1.x:=v1.x+sysvar.DWG.DWG_StepGrid.x;
          v1.y:=v1.y+sysvar.DWG.DWG_StepGrid.y;
          inc(pg);
        end;
        //v:=vertexadd(v,param.md.WPPointRB);
        v.x:=v1.x-sysvar.DWG.DWG_StepGrid.x;
  end;
  oglsm.myglend;
  end;
  {oglsm.myglbegin(gl_lines);
  oglsm.myglVertex3d(param.md.WPPointBL);
  oglsm.myglVertex3d(param.md.WPPointUR);
  oglsm.myglVertex3d(param.md.WPPointRB);
  oglsm.myglVertex3d(param.md.WPPointLU);
  oglsm.myglend;}
end;
procedure TOGLWnd.GDBActivateGLContext;
begin
                                      MyglMakeCurrent(OGLContext);//wglMakeCurrent(DC, hrc);//initogl;
                                      isOpenGLError;
end;

procedure TOGLWnd.GDBActivate;
begin
     //PTDrawing(self.pdwg)^.DWGUnits.findunit('DrawingVars').AssignToSymbol(SysVar.dwg.DWG_CLayer,'DWG_CLayer');
     //PTDrawing(self.pdwg)^.DWGUnits.findunit('DrawingVars').AssignToSymbol(SysVar.dwg.DWG_CLinew,'DWG_CLinew');

  //if PDWG<>gdb.GetCurrentDWG then
                                 begin
                                      //gdb.SetCurrentDWG(self.pdwg);
                                      pdwg.SetCurrentDWG;
                                      self.param.firstdraw:=true;
                                      GDBActivateGLContext;
                                      //{переделать}size;
                                      paint;
                                 end;
  if assigned(updatevisibleproc) then updatevisibleproc;
end;
procedure TOGLWnd.ZoomAll;
const
     steps=10;
var
  tpz,tzoom: GDBDouble;
  fv1,tp,wcsLBN,wcsRTF,dcsLBN,dcsRTF: GDBVertex;
  camerapos,target:GDBVertex;
  i:integer;
  pucommand:pointer;
  proot:PGDBObjGenericSubEntry;
begin
  if param.projtype = PROJPerspective then
                                          begin
                                               historyout('ZoomAll: Пока только для паралельной проекции!');
                                          end;
  historyout('ZoomAll: Пока корректно только при виде сверху!');


  CalcOptimalMatrix;

  proot:=pdwg.GetCurrentROOT;
  dcsLBN:=InfinityVertex;
  dcsRTF:=MinusInfinityVertex;
  wcsLBN:=InfinityVertex;
  wcsRTF:=MinusInfinityVertex;
  tp:=ProjectPoint(proot.vp.BoundingBox.LBN.x,proot.vp.BoundingBox.LBN.y,proot.vp.BoundingBox.LBN.Z,wcsLBN,wcsRTF,dcsLBN,dcsRTF);
  tp:=ProjectPoint(proot.vp.BoundingBox.RTF.x,proot.vp.BoundingBox.LBN.y,proot.vp.BoundingBox.LBN.Z,wcsLBN,wcsRTF,dcsLBN,dcsRTF);
  tp:=ProjectPoint(proot.vp.BoundingBox.RTF.x,proot.vp.BoundingBox.RTF.y,proot.vp.BoundingBox.LBN.Z,wcsLBN,wcsRTF,dcsLBN,dcsRTF);
  tp:=ProjectPoint(proot.vp.BoundingBox.LBN.x,proot.vp.BoundingBox.RTF.y,proot.vp.BoundingBox.LBN.Z,wcsLBN,wcsRTF,dcsLBN,dcsRTF);
  tp:=ProjectPoint(proot.vp.BoundingBox.LBN.x,proot.vp.BoundingBox.LBN.y,proot.vp.BoundingBox.RTF.Z,wcsLBN,wcsRTF,dcsLBN,dcsRTF);
  tp:=ProjectPoint(proot.vp.BoundingBox.RTF.x,proot.vp.BoundingBox.LBN.y,proot.vp.BoundingBox.RTF.Z,wcsLBN,wcsRTF,dcsLBN,dcsRTF);
  tp:=ProjectPoint(proot.vp.BoundingBox.RTF.x,proot.vp.BoundingBox.RTF.y,proot.vp.BoundingBox.RTF.Z,wcsLBN,wcsRTF,dcsLBN,dcsRTF);
  tp:=ProjectPoint(proot.vp.BoundingBox.LBN.x,proot.vp.BoundingBox.RTF.y,proot.vp.BoundingBox.RTF.Z,wcsLBN,wcsRTF,dcsLBN,dcsRTF);

  dcsLBN.z:=0;
  dcsRTF.z:=0;
  pdwg.myGluUnProject(dcsLBN,wcsLBN);
  pdwg.myGluUnProject(dcsRTF,wcsRTF);

     if wcsRTF.x<wcsLBN.x then
                              begin
                                   tpz:=wcsLBN.x;
                                   wcsLBN.x:=wcsRTF.x;
                                   wcsRTF.x:=tpz;
                              end;
     if wcsRTF.y<wcsLBN.y then
                              begin
                              tpz:=wcsLBN.y;
                              wcsLBN.y:=wcsRTF.y;
                              wcsRTF.y:=tpz;
                              end;
     if wcsRTF.z<wcsLBN.z then
                              begin
                              tpz:=wcsLBN.z;
                              wcsLBN.z:=wcsRTF.z;
                              wcsRTF.z:=tpz;
                              end;
     //param.DebugBoundingBbox.LBN:=wcsLBN;
     //param.DebugBoundingBbox.RTF:=wcsRTF;
     //param.ShowDebugBoundingBbox:=true;
  if (abs(wcsRTF.x-wcsLBN.x)<eps)and(abs(wcsRTF.y-wcsLBN.y)<eps) then
                                                                    begin
                                                                         historyout('MBMouseDblClk: Пустой чертеж?');
                                                                         exit;
                                                                    end;

  //target:=createvertex(-(wcsLBN.x+(wcsRTF.x-wcsLBN.x)/2),-(wcsLBN.y+(wcsRTF.y-wcsLBN.y)/2),pdwg.Getpcamera^.prop.point.z);
  target:=createvertex(-(wcsLBN.x+(wcsRTF.x-wcsLBN.x)/2),-(wcsLBN.y+(wcsRTF.y-wcsLBN.y)/2),-(wcsLBN.z+(wcsRTF.z-wcsLBN.z)/2));
  camerapos:=pdwg.Getpcamera^.prop.point;
  target:=vertexsub(target,camerapos);

  tzoom:=abs((wcsRTF.x-wcsLBN.x){*pdwg.GetPcamera.prop.xdir.x}/clientwidth);
  tpz:=abs((wcsRTF.y-wcsLBN.y){*pdwg.GetPcamera.prop.ydir.y}/clientheight);

  //-------with gdb.GetCurrentDWG.UndoStack.PushCreateTGChangeCommand(gdb.GetCurrentDWG.pcamera^.prop)^ do
  pucommand:=PDWG^.StoreOldCamerapPos;
  begin

  if tpz>tzoom then tzoom:=tpz;

  tzoom:=tzoom-PDWG.Getpcamera^.prop.zoom;

  for i:=1 to steps do
  begin
  SetCameraPosZoom(vertexadd(camerapos,geometry.VertexMulOnSc(target,i/steps)),PDWG.Getpcamera^.prop.zoom+tzoom{*i}/steps,i=steps);
  if sysvar.RD.RD_LastRenderTime^<30 then
                                        sleep(30-sysvar.RD.RD_LastRenderTime^);
  end;
  PDWG^.StoreNewCamerapPos(pucommand);
  calcgrid;

  draw;
  doCameraChanged;
  end;
end;
procedure TOGLWnd.SetCameraPosZoom(_pos:gdbvertex;_zoom:gdbdouble;finalcalk:gdbboolean);
var
  fv1: GDBVertex;
begin
    PDWG.Getpcamera^.prop.point:=_pos;
    PDWG.Getpcamera^.prop.zoom:=_zoom;
    param.firstdraw := true;
    PDWG.Getpcamera^.NextPosition;

    CalcOptimalMatrix;
    mouseunproject(param.md.mouse.x,param.md.mouse.y);
    reprojectaxis;
    PDWG.GetCurrentROOT.CalcVisibleByTree(PDWG.Getpcamera^.frustum,PDWG.Getpcamera.POSCOUNT,PDWG.Getpcamera.VISCOUNT,PDWG.GetCurrentRoot.ObjArray.ObjTree,pdwg.getpcamera.totalobj,pdwg.getpcamera.infrustum,pdwg.myGluProject2,pdwg.getpcamera.prop.zoom);
    PDWG.GetConstructObjRoot.calcvisible(PDWG.Getpcamera^.frustum,PDWG.Getpcamera.POSCOUNT,PDWG.Getpcamera.VISCOUNT,pdwg.getpcamera.totalobj,pdwg.getpcamera.infrustum,pdwg.myGluProject2,pdwg.getpcamera.prop.zoom);

  if finalcalk then
    begin
  if param.seldesc.MouseFrameON then
  begin
    pdwg.myGluProject2(param.seldesc.Frame13d,
               fv1);
    param.seldesc.Frame1.x := round(fv1.x);
    param.seldesc.Frame1.y := clientheight - round(fv1.y);
    if param.seldesc.Frame1.x < 0 then param.seldesc.Frame1.x := 0
    else if param.seldesc.Frame1.x > (clientwidth - 1) then param.seldesc.Frame1.x := clientwidth - 1;
    if param.seldesc.Frame1.y < 0 then param.seldesc.Frame1.y := 1
    else if param.seldesc.Frame1.y > (clientheight - 1) then param.seldesc.Frame1.y := clientheight - 1;
  end;
  end;
  _onMouseMove(nil,[],param.md.mouse.x,param.md.mouse.y);
end;

procedure TOGLWnd.RotTo(x0,y0,z0:GDBVertex);
const
     steps=10;
var
  tpz,tzoom: GDBDouble;
  fv1,tp,wcsLBN,wcsRTF,dcsLBN,dcsRTF: GDBVertex;
  camerapos,target:GDBVertex;
  i:integer;
  pucommand:pointer;
  q1,q2,q:GDBQuaternion;
  pcam:PGDBBaseCamera;

  mat1,mat2,mat : DMatrix4D;
begin
  pcam:=PDWG.Getpcamera;
  mat1:=CreateMatrixFromBasis(pcam.prop.xdir,pcam.prop.ydir,pcam.prop.look);
  mat2:=CreateMatrixFromBasis(x0,y0,z0);

  q1:=QuaternionFromMatrix(mat1);
  q2:=QuaternionFromMatrix(mat2);
  pucommand:=PDWG^.StoreOldCamerapPos;
  for i:=1 to steps do
  begin
  q:=QuaternionSlerp(q1,q2,i/steps);
  mat:=QuaternionToMatrix(q);
  CreateBasisFromMatrix(mat,pcam.prop.xdir,pcam.prop.ydir,pcam.prop.look);

  //PDWG.Getpcamera^.prop.point:=vertexadd(camerapos,geometry.VertexMulOnSc(target,i/steps));
  //PDWG.Getpcamera^.prop.zoom:=PDWG.Getpcamera^.prop.zoom+tzoom{*i}/steps;
  param.firstdraw := true;
  PDWG.Getpcamera^.NextPosition;
  //RestoreMouse;
  {}CalcOptimalMatrix;
  mouseunproject(param.md.mouse.x,param.md.mouse.y);
  reprojectaxis;
  PDWG.GetCurrentROOT.CalcVisibleByTree(PDWG.Getpcamera^.frustum,PDWG.Getpcamera.POSCOUNT,PDWG.Getpcamera.VISCOUNT,PDWG.GetCurrentRoot.ObjArray.ObjTree,pdwg.getpcamera.totalobj,pdwg.getpcamera.infrustum,pdwg.myGluProject2,pdwg.getpcamera.prop.zoom);
  PDWG.GetConstructObjRoot.calcvisible(PDWG.Getpcamera^.frustum,PDWG.Getpcamera.POSCOUNT,PDWG.Getpcamera.VISCOUNT,pdwg.getpcamera.totalobj,pdwg.getpcamera.infrustum,pdwg.myGluProject2,pdwg.getpcamera.prop.zoom);
  _onMouseMove(nil,[],param.md.mouse.x,param.md.mouse.y);
  if i=steps then
    begin
  if param.seldesc.MouseFrameON then
  begin
    pdwg.myGluProject2(param.seldesc.Frame13d,
               fv1);
    param.seldesc.Frame1.x := round(fv1.x);
    param.seldesc.Frame1.y := clientheight - round(fv1.y);
    if param.seldesc.Frame1.x < 0 then param.seldesc.Frame1.x := 0
    else if param.seldesc.Frame1.x > (clientwidth - 1) then param.seldesc.Frame1.x := clientwidth - 1;
    if param.seldesc.Frame1.y < 0 then param.seldesc.Frame1.y := 1
    else if param.seldesc.Frame1.y > (clientheight - 1) then param.seldesc.Frame1.y := clientheight - 1;
  end;
  end;{}
  //----ComitFromObj;

  if sysvar.RD.RD_LastRenderTime^<30 then
                                        sleep(30-sysvar.RD.RD_LastRenderTime^);
  end;
  pcam.prop.xdir:=x0;
  pcam.prop.ydir:=y0;
  pcam.prop.look:=z0;
  PDWG^.StoreNewCamerapPos(pucommand);
  calcgrid;

  draw;

end;
procedure TOGLWnd.asynczoomall(Data: PtrInt);
begin
     ZoomAll();
end;
procedure RunTextEditor(Pobj:GDBPointer;const drawing:TDrawingDef);
var
   op:gdbstring;
   size,modalresult:integer;
   us:unicodestring;
   u8s:UTF8String;
   astring:ansistring;
   pint:PGDBInteger;
begin
     astring:=ConvertFromDxfString(PGDBObjText(pobj)^.Template);


     if PGDBObjText(pobj)^.vp.ID=GDBMTextID then
     begin
     if not assigned(InfoForm) then
     begin
     InfoForm:=TInfoForm.createnew(application.MainForm);
     pint:=SavedUnit.FindValue('TEdWND_Left');
     if assigned(pint)then
                          InfoForm.Left:=pint^;
     pint:=SavedUnit.FindValue('TEdWND_Top');
     if assigned(pint)then
                          InfoForm.Top:=pint^;
     pint:=SavedUnit.FindValue('TEdWND_Width');
     if assigned(pint)then
                          InfoForm.Width:=pint^;
     pint:=SavedUnit.FindValue('TEdWND_Height');
     if assigned(pint)then
                          InfoForm.Height:=pint^;

     end;
     //InfoForm.DialogPanel.ShowButtons:=[pbOK, pbCancel{, pbClose, pbHelp}];
     InfoForm.caption:=(rsMTextEditor);

     InfoForm.memo.text:=astring;
     modalresult:=DOShowModal(InfoForm);
     if modalresult=MrOk then
                         begin
                              PGDBObjText(pobj)^.Template:=ConvertToDxfString(InfoForm.memo.text);
                         end;
     end
     else
     begin
     if not assigned(sltexteditor1) then
     Application.CreateForm(Tsltexteditor1, sltexteditor1);
     sltexteditor1.caption:=(rsTextEditor);

     sltexteditor1.helptext.Caption:=rsTextEdCaption;
     sltexteditor1.EditField.TEXT:=astring;

     modalresult:=DOShowModal(sltexteditor1);

     if modalresult=MrOk then
                         begin
                              PGDBObjText(pobj)^.Template:=ConvertToDxfString(sltexteditor1.EditField.text);
                         end;
     end;
     if modalresult=MrOk then
                         begin
                              PGDBObjText(pobj)^.YouChanged(drawing);
                              //gdb.GetCurrentROOT.FormatAfterEdit;
                              if assigned(redrawoglwndproc) then redrawoglwndproc;
                         end;

end;
procedure TOGLWnd.MouseEnter;
begin
     param.md.mousein:=true;
     inherited;
end;
procedure TOGLWnd.doCameraChanged;
begin
     if assigned(onCameraChanged) then onCameraChanged;
end;

procedure TOGLWnd.MouseLeave;
begin
     param.md.mousein:=false;
     inherited;
     draw;
end;
procedure TOGLWnd.MouseDown(Button: TMouseButton; Shift: TShiftState;X, Y: Integer);
var key: GDBByte;
    NeedRedraw:boolean;
    //menu:TmyPopupMenu;
begin
  if assigned(MainmouseDown)then
  if mainmousedown then
                       exit;
  //if (cxmenumgr.ismenupopup)or(ActivePopupMenu<>nil) then
  //                                                       exit;
  if @SetCurrentDWGProc<>nil then
                                SetCurrentDWGProc(pdwg);
  //ActivePopupMenu:=ActivePopupMenu;
  NeedRedraw:=false;
  if ssDouble in shift then
                           begin
                                if mbMiddle=button then
                                  begin
                                       {$IFNDEF DELPHI}
                                       Application.QueueAsyncCall(asynczoomall, 0);
                                       {$ENDIF}
                                       //Pre_MBMouseDblClk(Button,Shift,X, Y);
                                       {exclude(shift,ssdouble);
                                       exclude(shift,ssMiddle);}
                                       inherited;
                                       exit;
                                  end;
                                if mbLeft=button then
                                  begin
                                       if assigned(param.SelDesc.OnMouseObject) then
                                         if (PGDBObjEntity(param.SelDesc.OnMouseObject).vp.ID=GDBtextID)
                                         or (PGDBObjEntity(param.SelDesc.OnMouseObject).vp.ID=GDBMTextID) then
                                           begin
                                                 RunTextEditor(param.SelDesc.OnMouseObject,self.PDWG^);
                                           end;
                                       exit;
                                  end;

                           end;
  if ssRight in shift then
                           begin
                                if assigned(ShowCXMenu)then
                                                           ShowCXMenu;
                                exit;
                           end;
  (*if PDWG<>pointer(gdb.GetCurrentDWG) then
                                 begin
                                      //r.handled:=true;
                                      gdb.SetCurrentDWG(pdwg);
                                      self.param.firstdraw:=true;
                                      paint;
                                      MyglMakeCurrent(OGLContext);//wglMakeCurrent(DC, hrc);//initogl;

                                 end
                              else*)

  begin
  //r.handled:=true;
  if pdwg=nil then exit;
  key := 0;
  if (ssLeft in shift) then
                           key := key or MZW_LBUTTON;
  if (ssShift in shift) then key := key or MZW_SHIFT;
  if (ssCtrl in shift) then key := key or MZW_CONTROL;
  if (ssMiddle in shift) then
  begin
    cursor := crHandPoint;
    param.scrollmode:=true;
    param.lastonmouseobject := nil;
  end;
  param.md.mouse.x := x;
  param.md.mouse.y := y;
  if (ssLeft in shift) then
    if commandmanager.pcommandrunning = nil then
    begin
      if (param.md.mode and MGetControlpoint) <> 0 then

        if param.gluetocp then
        begin
          PDWG.GetSelObjArray.selectcurrentcontrolpoint(key,param.md.mouseglue.x,param.md.mouseglue.y,param.height);
          needredraw:=true;
          if (key and MZW_SHIFT) = 0 then
          begin
            param.startgluepoint:=param.nearesttcontrolpoint.pcontrolpoint;
            commandmanager.ExecuteCommandSilent('OnDrawingEd',pdwg);
            //param.lastpoint:=param.nearesttcontrolpoint.pcontrolpoint^.worldcoord;
            //sendmousecoord{wop}(key);  bnmbnm
            if commandmanager.pcommandrunning <> nil then
            begin
              if key=MZW_LBUTTON then
                                     param.lastpoint:=param.nearesttcontrolpoint.pcontrolpoint^.worldcoord;
              commandmanager.pcommandrunning^.MouseMoveCallback(param.nearesttcontrolpoint.pcontrolpoint^.worldcoord,
                                                                param.md.mouseglue, key,nil)
            end;
          end;
        end

        else
        begin
          getonmouseobjectbytree(PDWG.GetCurrentROOT.ObjArray.ObjTree);
          //getonmouseobject(@gdb.GetCurrentROOT.ObjArray);
          if (key and MZW_CONTROL)<>0 then
          begin
               commandmanager.ExecuteCommandSilent('SelectOnMouseObjects',pdwg);
          end
          else
          begin
          param.SelDesc.LastSelectedObject := param.SelDesc.OnMouseObject;

          {//Выделение всех объектов под мышью
          if gdb.GetCurrentDWG.OnMouseObj.Count >0 then
          begin
               pobj:=gdb.GetCurrentDWG.OnMouseObj.beginiterate(ir);
               if pobj<>nil then
               repeat
                     pobj^.select;
                     param.SelDesc.LastSelectedObject := pobj;
                     pobj:=gdb.GetCurrentDWG.OnMouseObj.iterate(ir);
               until pobj=nil;
            addoneobject;
            SetObjInsp;
          end}

          //Выделение одного объекта под мышью
          if param.SelDesc.OnMouseObject <> nil then
          begin
               if (key and MZW_SHIFT)=0
               then
                   begin
                        if PGDBObjEntity(param.SelDesc.OnMouseObject)^.select(PDWG^.GetSelObjArray,param.SelDesc.Selectedobjcount) then
                          begin
                        param.SelDesc.LastSelectedObject := param.SelDesc.OnMouseObject;
                        if assigned(addoneobjectproc) then addoneobjectproc;
                        SetObjInsp;
                        if assigned(updatevisibleproc) then updatevisibleproc;
                          end;
                   end
               else
                   begin
                        PGDBObjEntity(param.SelDesc.OnMouseObject)^.DeSelect(PDWG^.GetSelObjArray,param.SelDesc.Selectedobjcount);
                        param.SelDesc.LastSelectedObject := nil;
                        //addoneobject;
                        SetObjInsp;
                        if assigned(updatevisibleproc) then updatevisibleproc;
                   end;
               NeedRedraw:=true;
          end

          else if ((param.md.mode and MGetSelectionFrame) <> 0) and ((key and MZW_LBUTTON)<>0) then
          begin
          { TODO : Добавить возможность выбора объектов без секрамки во время выполнения команды }
            commandmanager.ExecuteCommandSilent('SelectFrame',pdwg);
            sendmousecoord(MZW_LBUTTON);
          end;
        end;
        end;
        needredraw:=true;
    end
    else
    begin
      if (param.md.mode and (MGet3DPoint or MGet3DPointWoOP)) <> 0 then
      begin
        sendmousecoordwop(key);
        //GDBFreeMem(GDB.PObjPropArray^.propertyarray[0].pobject);
      end
      else if ((param.md.mode and MGetSelectionFrame) <> 0) and ((key and MZW_LBUTTON)<>0) then
          begin
            commandmanager.ExecuteCommandSilent('SelectFrame',pdwg);
            sendmousecoord(MZW_LBUTTON);
          end;
      needredraw:=true;
    end;
    If assigned(UpdateObjInspProc)then
    UpdateObjInspProc;
  end;
  inherited;
  if needredraw then
                    if assigned(redrawoglwndproc) then redrawoglwndproc;
end;
procedure TOGLWnd.DISP_ZoomFactor;
var
  glx1, gly1: GDBDouble;
  pucommand:pointer;
//  fv1: GDBVertex;
begin
  {$IFDEF PERFOMANCELOG}log.programlog.LogOutStrFast('TOGLWnd.DISP_ZoomFactor',lp_incPos);{$ENDIF}
  //gdb.GetCurrentDWG.UndoStack.PushChangeCommand(@gdb.GetCurrentDWG.pcamera^.prop,sizeof(GDBCameraBaseProp));
  //with gdb.GetCurrentDWG.UndoStack.PushCreateTGChangeCommand(gdb.GetCurrentDWG.pcamera^.prop)^ do
  pucommand:=PDWG^.StoreOldCamerapPos;
  begin
        CalcOptimalMatrix;
        if not param.md.mousein then
                                    mouseunproject(clientwidth div 2, clientheight div 2);
        glx1 := param.md.mouseray.lbegin.x;
        gly1 := param.md.mouseray.lbegin.y;
        if param.projtype = ProjParalel then
          PDWG.Getpcamera^.prop.zoom := PDWG.Getpcamera^.prop.zoom * x
        else
        begin
          PDWG.Getpcamera^.prop.point.x := PDWG.Getpcamera^.prop.point.x + (PDWG.Getpcamera^.prop.look.x *
          (PDWG.Getpcamera^.zmax - PDWG.Getpcamera^.zmin) * sign(x - 1) / 10);
          PDWG.Getpcamera^.prop.point.y := PDWG.Getpcamera^.prop.point.y + (PDWG.Getpcamera^.prop.look.y *
          (PDWG.Getpcamera^.zmax - PDWG.Getpcamera^.zmin) * sign(x - 1) / 10);
          PDWG.Getpcamera^.prop.point.z := PDWG.Getpcamera^.prop.point.z + (PDWG.Getpcamera^.prop.look.z *
          (PDWG.Getpcamera^.zmax - PDWG.Getpcamera^.zmin) * sign(x - 1) / 10);
        end;

        CalcOptimalMatrix;
        if param.md.mousein then
                                mouseunproject(param.md.mouse.x, clientheight-param.md.mouse.y)
                            else
                                mouseunproject(clientwidth div 2, clientheight div 2);
        if param.projtype = ProjParalel then
        begin
        PDWG.Getpcamera^.prop.point.x := PDWG.Getpcamera^.prop.point.x - (glx1 - param.md.mouseray.lbegin.x);
        PDWG.Getpcamera^.prop.point.y := PDWG.Getpcamera^.prop.point.y - (gly1 - param.md.mouseray.lbegin.y);
        end;
        PDWG^.StoreNewCamerapPos(pucommand);
        //ComitFromObj;
  end;
  doCameraChanged;
  {$IFDEF PERFOMANCELOG}log.programlog.LogOutStrFast('TOGLWnd.DISP_ZoomFactor----{end}',lp_decPos);{$ENDIF}
end;
procedure TOGLWnd.MouseUp(Button: TMouseButton; Shift:TShiftState;X, Y: Integer);
//procedure TOGLWnd.Pre_MouseUp;
begin
  inherited;
  if button = mbMiddle then
  begin
    cursor := crnone;
    param.scrollmode:=false;
    param.firstdraw:=true;
    paint;
  end;
end;
procedure drawtick(uID, msg: UINT; dwUse, dw1, dw2: DWord); stdcall;
begin
     inc(tick);
end;
procedure TOGLWnd.LightOn;
var
   p:GDBvertex4F;
begin
    if SysVar.RD.RD_Light^ then
    begin
    oglsm.myglEnable(GL_LIGHTING);
    oglsm.myglEnable(GL_LIGHT0);
    oglsm.myglEnable (GL_COLOR_MATERIAL);

    p.x:=PDWG.Getpcamera^.prop.point.x;
    p.y:=PDWG.Getpcamera^.prop.point.y;
    p.z:=PDWG.Getpcamera^.prop.point.z;
    p.w:=0;
    oglsm.myglLightfv(GL_LIGHT0,GL_POSITION,@p) ;
    oglsm.myglMaterialf(GL_FRONT_AND_BACK,GL_SHININESS,50.000000);
    p.x:=0;
    p.y:=0;
    p.z:=0;
    p.w:=1;
  oglsm.myglMaterialfv(GL_FRONT_AND_BACK,GL_SPECULAR,@p);
  oglsm.myglLightModeli(GL_LIGHT_MODEL_TWO_SIDE,1);
  oglsm.myglColorMaterial(GL_FRONT_AND_BACK,GL_AMBIENT_AND_DIFFUSE);
  oglsm.myglEnable(GL_COLOR_MATERIAL);
    end
       else LightOff;
    //oglsm.myglDisable(GL_LIGHTING);
    //oglsm.myglDisable(GL_LIGHT0);
    //oglsm.myglDisable(GL_COLOR_MATERIAL);
end;
procedure TOGLWnd.LightOff;
var
   p:GDBvertex4F;
begin
    oglsm.myglDisable(GL_LIGHTING);
    oglsm.myglDisable(GL_LIGHT0);
    oglsm.myglDisable(GL_COLOR_MATERIAL);
end;
procedure drawfrustustum(frustum:ClipArray);
var
tv1,tv2,tv3,tv4,sv1{,sv2,sv3,sv4},d1{,d2,d3,d4}:gdbvertex;
Tempplane:DVector4D;

begin
  Tempplane:=frustum[5];
  tempplane[3]:=(tempplane[3]-frustum[4][3])/2;
  begin
  tv1:=PointOf3PlaneIntersect(frustum[0],frustum[3],Tempplane);
  tv2:=PointOf3PlaneIntersect(frustum[1],frustum[3],Tempplane);
  tv3:=PointOf3PlaneIntersect(frustum[1],frustum[2],Tempplane);
  tv4:=PointOf3PlaneIntersect(frustum[0],frustum[2],Tempplane);
  oglsm.myglbegin(GL_LINES{_loop});
                 oglsm.myglVertex3dv(@tv1);
                 oglsm.myglVertex3dv(@tv2);
                 oglsm.myglVertex3dv(@tv2);
                 oglsm.myglVertex3dv(@tv3);
                 oglsm.myglVertex3dv(@tv3);
                 oglsm.myglVertex3dv(@tv4);
                 oglsm.myglVertex3dv(@tv4);
                 oglsm.myglVertex3dv(@tv1);
  oglsm.myglend;
  end;
end;

procedure TOGLWnd.showcursor;
  var
    i, j: GDBInteger;
    pt:ptraceprop;
//      ir:itrec;
//  ptp:ptraceprop;
  mvertex,dvertex,tv1,tv2,tv3,tv4,sv1{,sv2,sv3,sv4},d1{,d2,d3,d4}:gdbvertex;
  Tempplane,plx,ply,plz:DVector4D;
    a: GDBInteger;
    scrx,scry,texture{,e}:integer;
    scrollmode:GDBBOOlean;
    LPTime:Tdatetime;

    i2d,i2dresult:intercept2dprop;
    td,td2,td22:gdbdouble;
    _NotUseLCS:boolean;


  begin
    if param.scrollmode then
                            exit;
    CalcOptimalMatrix;
    if PDWG.GetSelObjArray.Count<>0 then PDWG.GetSelObjArray.drawpoint;
    //oglsm.mytotalglend;
    //isOpenGLError;
    oglsm.glcolor3ub(255, 255, 255);

    oglsm.myglEnable(GL_COLOR_LOGIC_OP);
    oglsm.myglLogicOp(GL_OR);

    if param.ShowDebugFrustum then
                            drawfrustustum(param.debugfrustum);
    if param.ShowDebugBoundingBbox then
                                DrawAABB(param.DebugBoundingBbox);

    Tempplane:=param.mousefrustumLCS[5];
    tempplane[3]:=(tempplane[3]-param.mousefrustumLCS[4][3])/2;
    {курсор фрустума выделения}
    if param.md.mousein then
    if (param.md.mode and MGetSelectObject) <> 0 then
    begin
    drawfrustustum(param.mousefrustumLCS);
    {tv1:=PointOf3PlaneIntersect(param.mousefrustumLCS[0],param.mousefrustumLCS[3],Tempplane);
    tv2:=PointOf3PlaneIntersect(param.mousefrustumLCS[1],param.mousefrustumLCS[3],Tempplane);
    tv3:=PointOf3PlaneIntersect(param.mousefrustumLCS[1],param.mousefrustumLCS[2],Tempplane);
    tv4:=PointOf3PlaneIntersect(param.mousefrustumLCS[0],param.mousefrustumLCS[2],Tempplane);
    oglsm.myglbegin(GL_LINES);
                   glVertex3dv(@tv1);
                   glVertex3dv(@tv2);
                   glVertex3dv(@tv2);
                   glVertex3dv(@tv3);
                   glVertex3dv(@tv3);
                   glVertex3dv(@tv4);
                   glVertex3dv(@tv4);
                   glVertex3dv(@tv1);
    oglsm.myglend;}
    end;
    //oglsm.mytotalglend;
    //isOpenGLError;
    {оси курсора}

    {myglbegin(GL_LINES);
     glVertex3d(0,0,0);
     glVertex3d(param.md.mouse3dcoord.x,param.md.mouse3dcoord.y,param.md.mouse3dcoord.z);
    myglend;

    param.md.mouse3dcoord:=geometry.NulVertex;}
    _NotUseLCS:=NotUseLCS;
    NotUseLCS:=true;
    if param.md.mousein then
    if param.md.mode <> MGetSelectObject then
    begin
    //sv1:=VertexAdd(param.md.mouse3dcoord,gdb.GetCurrentDWG.pcamera.look);
    //sv1:=gdb.GetCurrentDWG.pcamera.point;
    sv1:=param.md.mouseray.lbegin;
    sv1:=vertexadd(sv1,PDWG.Getpcamera^.CamCSOffset);

    PointOfLinePlaneIntersect(VertexAdd(param.md.mouseray.lbegin,PDWG.Getpcamera^.CamCSOffset),param.md.mouseray.dir,tempplane,mvertex);
    //mvertex:=vertexadd(mvertex,gdb.GetCurrentDWG.pcamera^.CamCSOffset);

    plx:=PlaneFrom3Pont(sv1,vertexadd(param.md.mouse3dcoord,PDWG.Getpcamera^.CamCSOffset),
                        vertexadd(VertexAdd(param.md.mouse3dcoord,xWCS{VertexMulOnSc(xWCS,oneVertexlength(param.md.mouse3dcoord))}),PDWG.Getpcamera^.CamCSOffset));
    //oglsm.mytotalglend;
    //isOpenGLError;
    oglsm.myglbegin(GL_LINES);
    if sysvar.DISP.DISP_ColorAxis^ then oglsm.glColor3ub(255, 0, 0);
    tv1:=PointOf3PlaneIntersect(PDWG.Getpcamera.frustumLCS[0],plx,Tempplane);
    //tv1:=sv1;
    tv2:=PointOf3PlaneIntersect(PDWG.Getpcamera.frustumLCS[1],plx,Tempplane);
    dvertex:=geometry.VertexSub(tv2,tv1);
    dvertex:=geometry.VertexMulOnSc(dvertex,SysVar.DISP.DISP_CrosshairSize^);
    tv1:=VertexSub(mvertex,dvertex);
    tv2:=VertexAdd(mvertex,dvertex);

    oglsm.myglVertex3dv(@tv1);
    oglsm.myglVertex3dv(@tv2);
    oglsm.myglend;

    ply:=PlaneFrom3Pont(sv1,vertexadd(param.md.mouse3dcoord,PDWG.Getpcamera^.CamCSOffset),
                        vertexadd(VertexAdd(param.md.mouse3dcoord,yWCS{VertexMulOnSc(xWCS,oneVertexlength(param.md.mouse3dcoord))}),PDWG.Getpcamera^.CamCSOffset));
   if sysvar.DISP.DISP_ColorAxis^ then oglsm.glColor3ub(0, 255, 0);
    oglsm.myglbegin(GL_LINES);
    tv1:=PointOf3PlaneIntersect(PDWG.Getpcamera.frustumLCS[2],ply,Tempplane);
    tv2:=PointOf3PlaneIntersect(PDWG.Getpcamera.frustumLCS[3],ply,Tempplane);
    dvertex:=geometry.VertexSub(tv2,tv1);
    dvertex:=geometry.VertexMulOnSc(dvertex,SysVar.DISP.DISP_CrosshairSize^*{gdb.GetCurrentDWG.OGLwindow1.}ClientWidth/{gdb.GetCurrentDWG.OGLwindow1.}ClientHeight);
    tv1:=VertexSub(mvertex,dvertex);
    tv2:=VertexAdd(mvertex,dvertex);
    oglsm.myglVertex3dv(@tv1);
    oglsm.myglVertex3dv(@tv2);
    oglsm.myglend;

    if sysvar.DISP.DISP_DrawZAxis^ then
    begin
    plz:=PlaneFrom3Pont(sv1,vertexadd(param.md.mouse3dcoord,PDWG.Getpcamera^.CamCSOffset),
                        vertexadd(VertexAdd(param.md.mouse3dcoord,zWCS{VertexMulOnSc(xWCS,oneVertexlength(param.md.mouse3dcoord))}),PDWG.Getpcamera^.CamCSOffset));
    if sysvar.DISP.DISP_ColorAxis^ then oglsm.glColor3ub(0, 0, 255);
    oglsm.myglbegin(GL_LINES);
    tv1:=PointOf3PlaneIntersect(PDWG.Getpcamera.frustumLCS[0],plz,Tempplane);
    tv2:=PointOf3PlaneIntersect(PDWG.Getpcamera.frustumLCS[1],plz,Tempplane);
    dvertex:=geometry.VertexSub(tv2,tv1);
    dvertex:=geometry.VertexMulOnSc(dvertex,SysVar.DISP.DISP_CrosshairSize^);
    tv1:=VertexSub(mvertex,dvertex);
    tv2:=VertexAdd(mvertex,dvertex);
    oglsm.myglVertex3dv(@tv1);
    oglsm.myglVertex3dv(@tv2);
    oglsm.myglend;
    end;
    end;



    //if param.scrollmode then exit;

    oglsm.glColor3ub(255, 255, 255);


    {sv1:=geometry.Vertexmorph(tv1,tv2,1/3);
    sv2:=geometry.Vertexmorph(tv2,tv3,1/3);
    sv3:=geometry.Vertexmorph(tv3,tv4,1/3);
    sv4:=geometry.Vertexmorph(tv4,tv1,1/3);

    myglbegin(GL_LINES);
                   glVertex3d(sv1.x,sv1.y,sv1.z);
                   glVertex3d(sv1.x+10*param.mousefrustum[2][0],sv1.y+10*param.mousefrustum[2][1],sv1.z+10*param.mousefrustum[2][2]);
                   glVertex3d(sv2.x,sv2.y,sv2.z);
                   glVertex3d(sv2.x+10*param.mousefrustum[1][0],sv2.y+10*param.mousefrustum[1][1],sv2.z+10*param.mousefrustum[1][2]);
                   glVertex3d(sv3.x,sv3.y,sv3.z);
                   glVertex3d(sv3.x+10*param.mousefrustum[3][0],sv3.y+10*param.mousefrustum[3][1],sv3.z+10*param.mousefrustum[3][2]);
                   glVertex3d(sv4.x,sv4.y,sv4.z);
                   glVertex3d(sv4.x+10*param.mousefrustum[0][0],sv4.y+10*param.mousefrustum[0][1],sv4.z+10*param.mousefrustum[0][2]);

    myglend;}












    d1:=geometry.VertexAdd(param.md.mouseray.lbegin,param.md.mouseray.lend);
    d1:=geometry.VertexMulOnSc(d1,0.5);

    {PointOfLinePlaneIntersect(d1,XWCS,gdb.GetCurrentDWG.pcamera.frustum[0],sv1);
    PointOfLinePlaneIntersect(d1,XWCS,gdb.GetCurrentDWG.pcamera.frustum[1],sv2);

    myglbegin(GL_LINES);
                   glVertex3d(sv1.x,sv1.y,sv1.z);
                   glVertex3d(sv2.x,sv2.y,sv2.z);
    myglend;}

    {PointOfLinePlaneIntersect(d1,yWCS,gdb.GetCurrentDWG.pcamera.frustum[2],sv1);
    PointOfLinePlaneIntersect(d1,yWCS,gdb.GetCurrentDWG.pcamera.frustum[3],sv2);

    myglbegin(GL_LINES);
                   glVertex3d(sv1.x,sv1.y,sv1.z);
                   glVertex3d(sv2.x,sv2.y,sv2.z);
    myglend;}

    {PointOfLinePlaneIntersect(d1,XWCS,gdb.GetCurrentDWG.pcamera.frustum[4],sv1);
    PointOfLinePlaneIntersect(d1,XWCS,gdb.GetCurrentDWG.pcamera.frustum[5],sv2);

    myglbegin(GL_LINES);
                   glVertex3d(sv1.x,sv1.y,sv1.z);
                   glVertex3d(sv2.x,sv2.y,sv2.z);
    myglend;}




    //oglsm.mytotalglend;
    //isOpenGLError;

    oglsm.myglMatrixMode(GL_PROJECTION);
    oglsm.myglLoadIdentity;
    oglsm.myglOrtho(0.0, clientwidth, clientheight, 0.0, -1.0, 1.0);
    oglsm.myglMatrixMode(GL_MODELVIEW);
    oglsm.myglLoadIdentity;
    oglsm.myglscalef(1, -1, 1);
    oglsm.myglpushmatrix;
    oglsm.mygltranslated(0, -clientheight, 0);

    if param.lastonmouseobject<>nil then
                                        pGDBObjEntity(param.lastonmouseobject)^.higlight;
    //oglsm.mytotalglend;

    oglsm.myglpopmatrix;
    oglsm.glColor3ub(0, 100, 100);
    oglsm.myglpushmatrix;
    oglsm.mygltranslated(param.CSIcon.csx.x + 2, -clientheight + param.CSIcon.csx.y - 10, 0);
    textwrite('X');
    oglsm.myglpopmatrix;
    oglsm.myglpushmatrix;
    oglsm.mygltranslated(param.CSIcon.csy.x + 2, -clientheight + param.CSIcon.csy.y - 10, 0);
    textwrite('Y');
    oglsm.myglpopmatrix;
    oglsm.myglpushmatrix;
    oglsm.mygltranslated(param.CSIcon.csz.x + 2, -clientheight + param.CSIcon.csz.y - 10, 0);
    textwrite('Z');
    oglsm.myglpopmatrix;
    oglsm.myglLoadIdentity;
    //glColor3ub(255, 255, 255);
    oglsm.glColor3ubv(foreground{not(sysvar.RD.RD_BackGroundColor^.r),not(sysvar.RD.RD_BackGroundColor^.g),not(sysvar.RD.RD_BackGroundColor^.b)});

    //oglsm.mytotalglend;
    //isOpenGLError;

    if not param.seldesc.MouseFrameON then
    begin
      {Курсор в DCS
      myglbegin(GL_lines);
      glVertex3f(0, param.md.mouseglue.y, 0);
      glVertex3f(clientwidth, param.md.mouseglue.y, 0);
      glVertex3f(param.md.mouseglue.x, 0, 0);
      glVertex3f(param.md.mouseglue.x, clientheight, 0);
      myglend;
      }
    end;
    {
    курсор в DCS
    if (param.md.mode and MGetSelectObject) <> 0 then
    begin
    myglbegin(GL_line_LOOP);
    glVertex3f((param.md.mouseglue.x - sysvar.DISP.DISP_CursorSize^), (param.md.mouseglue.y + sysvar.DISP.DISP_CursorSize^), 0);
    glVertex3f((param.md.mouseglue.x - sysvar.DISP.DISP_CursorSize^), (param.md.mouseglue.y - sysvar.DISP.DISP_CursorSize^), 0);
    glVertex3f((param.md.mouseglue.x + sysvar.DISP.DISP_CursorSize^), (param.md.mouseglue.y - sysvar.DISP.DISP_CursorSize^), 0);
    glVertex3f((param.md.mouseglue.x + sysvar.DISP.DISP_CursorSize^), (param.md.mouseglue.y + sysvar.DISP.DISP_CursorSize^), 0);
    myglend;
    end;
    }

    //oglsm.mytotalglend;
    //isOpenGLError;

    if param.seldesc.MouseFrameON then
    begin
      if param.seldesc.MouseFrameInverse then
      begin
      oglsm.myglLogicOp(GL_XOR);
      oglsm.myglLineStipple(1, $F0F0);
      oglsm.myglEnable(GL_LINE_STIPPLE);
      end;
      oglsm.myglbegin(GL_line_loop);
      oglsm.myglVertex2i(param.seldesc.Frame1.x, param.seldesc.Frame1.y);
      oglsm.myglVertex2i(param.seldesc.Frame2.x, param.seldesc.Frame1.y);
      oglsm.myglVertex2i(param.seldesc.Frame2.x, param.seldesc.Frame2.y);
      oglsm.myglVertex2i(param.seldesc.Frame1.x, param.seldesc.Frame2.y);
      oglsm.myglend;
      {myglbegin(GL_lines);
      glVertex2i(param.seldesc.Frame1.x, param.seldesc.Frame1.y);
      glVertex2i(param.seldesc.Frame2.x, param.seldesc.Frame2.y);
      myglend;}
      if param.seldesc.MouseFrameInverse then oglsm.myglDisable(GL_LINE_STIPPLE);
      oglsm.myglDisable(GL_TEXTURE_2D);
    end;

    //oglsm.mytotalglend;
    //isOpenGLError;

    if PDWG<>nil then

    //if gdb.GetCurrentDWG.SelObjArray.Count<>0 then gdb.GetCurrentDWG.SelObjArray.drawpoint;
    if tocommandmcliccount=0 then a:=1
                             else a:=0;
    if param.ontrackarray.total <> 0 then
    begin
      oglsm.myglLogicOp(GL_XOR);
      for i := a to param.ontrackarray.total - 1 do
      begin
       oglsm.myglbegin(GL_LINES);
       oglsm.glcolor3ub(255,255, 0);
        oglsm.myglvertex2d(param.ontrackarray.otrackarray[i].dispcoord.x,
                   clientheight - param.ontrackarray.otrackarray[i].dispcoord.y + marksize);
        oglsm.myglvertex2d(param.ontrackarray.otrackarray[i].dispcoord.x,
                   clientheight - param.ontrackarray.otrackarray[i].dispcoord.y - marksize);
        oglsm.myglvertex2d(param.ontrackarray.otrackarray[i].dispcoord.x + marksize,
                   clientheight - param.ontrackarray.otrackarray[i].dispcoord.y);
        oglsm.myglvertex2d(param.ontrackarray.otrackarray[i].dispcoord.x - marksize,
                   clientheight - param.ontrackarray.otrackarray[i].dispcoord.y);
        {ptp:=param.ontrackarray.otrackarray[i].arraydispaxis.beginiterate(ir);
        if ptp<>nil then
        repeat

        glvertex2d(param.ontrackarray.otrackarray[i].dispcoord.x,
                   clientheight - param.ontrackarray.otrackarray[i].dispcoord.y);
         glvertex2d(param.ontrackarray.otrackarray[i].dispcoord.x+ptp^.dir.x,clientheight - (param.ontrackarray.otrackarray[i].dispcoord.y+ptp^.dir.y));


              ptp:=param.ontrackarray.otrackarray[i].arraydispaxis.iterate(ir);
        until ptp=nil;}



        oglsm.myglend;

        //oglsm.mytotalglend;
        //isOpenGLError;

        oglsm.myglLineStipple(1, $3333);
        oglsm.myglEnable(GL_LINE_STIPPLE);
        oglsm.myglbegin(GL_LINES);
        oglsm.glcolor3ub(80,80, 80);
        if param.ontrackarray.otrackarray[i].arraydispaxis.Count <> 0 then
        begin;
        pt:=param.ontrackarray.otrackarray[i].arraydispaxis.PArray;
        for j := 0 to param.ontrackarray.otrackarray[i].arraydispaxis.count - 1 do
          begin
            if pt.trace then
            begin
                 //i2d,i2dresult
              i2dresult:=intercept2dmy(CreateVertex2D(0,0),CreateVertex2D(0,clientheight),PGDBVertex2D(@param.ontrackarray.otrackarray[i].dispcoord)^,PGDBVertex2D(@pt.dispraycoord)^);
              i2d:=intercept2dmy(CreateVertex2D(0,clientheight),CreateVertex2D(clientwidth,clientheight),PGDBVertex2D(@param.ontrackarray.otrackarray[i].dispcoord)^,PGDBVertex2D(@pt.dispraycoord)^);
              if not i2dresult.isintercept then
                                               i2dresult:=i2d;
              if i2d.isintercept then
              if i2d.t2>0 then
              if (i2d.t2<i2dresult.t2)or(i2dresult.t2<0) then
                                              i2dresult:=i2d;
              i2d:=intercept2dmy(CreateVertex2D(clientwidth,clientheight),CreateVertex2D(clientwidth,0),PGDBVertex2D(@param.ontrackarray.otrackarray[i].dispcoord)^,PGDBVertex2D(@pt.dispraycoord)^);
              if not i2dresult.isintercept then
                                               i2dresult:=i2d;
              if i2d.isintercept then
              if i2d.t2>0 then
              if (i2d.t2<i2dresult.t2)or(i2dresult.t2<0) then
                                              i2dresult:=i2d;
              i2d:=intercept2dmy(CreateVertex2D(clientwidth,0),CreateVertex2D(0,0),PGDBVertex2D(@param.ontrackarray.otrackarray[i].dispcoord)^,PGDBVertex2D(@pt.dispraycoord)^);
              if not i2dresult.isintercept then
                                               i2dresult:=i2d;
              if i2d.isintercept then
              if i2d.t2>0 then
              if (i2d.t2<i2dresult.t2)or(i2dresult.t2<0) then
                                              i2dresult:=i2d;

              //geometry.
              oglsm.myglvertex2d(param.ontrackarray.otrackarray[i].dispcoord.x, clientheight - param.ontrackarray.otrackarray[i].dispcoord.y);
              oglsm.myglvertex2d(i2dresult.interceptcoord.x, clientheight - i2dresult.interceptcoord.y);
              //glvertex2d(pt.dispraycoord.x, clientheight - pt.dispraycoord.y);
            end;
            inc(pt);
          end;
        end;
        oglsm.myglend;
        //oglsm.mytotalglend;
        //isOpenGLError;
        oglsm.myglDisable(GL_LINE_STIPPLE);
      end;
    end;

    //oglsm.mytotalglend;
    //isOpenGLError;

    //{$REGION 'snap'}
    if param.ospoint.ostype <> os_none then
    begin
     oglsm.glcolor3ub(255,255, 0);
      oglsm.mygltranslated(param.ospoint.dispcoord.x, clientheight - param.ospoint.dispcoord.y,0);
      oglsm.mygllinewidth(2);
        oglsm.myglscalef(sysvar.DISP.DISP_OSSize^,sysvar.DISP.DISP_OSSize^,sysvar.DISP.DISP_OSSize^);
        if (param.ospoint.ostype = os_begin)or(param.ospoint.ostype = os_end) then
        begin oglsm.myglbegin(GL_line_loop);
              oglsm.myglVertex2f(-1, 1);
              oglsm.myglVertex2f(1, 1);
              oglsm.myglVertex2f(1, -1);
              oglsm.myglVertex2f(-1, -1);
              oglsm.myglend;
        end
        else
        if (param.ospoint.ostype = os_midle) then
        begin oglsm.myglbegin(GL_lines{_loop});
                  oglsm.myglVertex2f(0, -1);
                  oglsm.myglVertex2f(0.8660254037844, 0.5);
                  oglsm.myglVertex2f(0.8660254037844, 0.5);
                  oglsm.myglVertex2f(-0.8660254037844,0.5);
                  oglsm.myglVertex2f(-0.8660254037844,0.5);
                  oglsm.myglVertex2f(0, -1);
              oglsm.myglend;end
        else
        if (param.ospoint.ostype = os_1_4)or(param.ospoint.ostype = os_3_4) then
        begin oglsm.myglbegin(GL_lines);
                                       oglsm.myglVertex2f(-0.5, 1);
                                       oglsm.myglVertex2f(-0.5, -1);
                                       oglsm.myglVertex2f(-0.2, -1);
                                       oglsm.myglVertex2f(0.15, 1);
                                       oglsm.myglVertex2f(0.5, -1);
                                       oglsm.myglVertex2f(0.15, 1);
              oglsm.myglend;end
        else
        if (param.ospoint.ostype = os_center)then
                                                 circlepointoflod[8].DrawGeometry
        else
        if (param.ospoint.ostype = os_q0)or(param.ospoint.ostype = os_q1)
         or(param.ospoint.ostype = os_q2)or(param.ospoint.ostype = os_q3) then
        begin oglsm.myglbegin(GL_lines{_loop});
                                            oglsm.myglVertex2f(-1, 0);
                                            oglsm.myglVertex2f(0, 1);
                                            oglsm.myglVertex2f(0, 1);
                                            oglsm.myglVertex2f(1, 0);
                                            oglsm.myglVertex2f(1, 0);
                                            oglsm.myglVertex2f(0, -1);
                                            oglsm.myglVertex2f(0, -1);
                                            oglsm.myglVertex2f(-1, 0);
              oglsm.myglend;end
        else
        if (param.ospoint.ostype = os_1_3)or(param.ospoint.ostype = os_2_3) then
        begin oglsm.myglbegin(GL_lines);
                                        oglsm.myglVertex2f(-0.5, 1);
                                        oglsm.myglVertex2f(-0.5, -1);
                                        oglsm.myglVertex2f(0, 1);
                                        oglsm.myglVertex2f(0, -1);
                                        oglsm.myglVertex2f(0.5, 1);
                                        oglsm.myglVertex2f(0.5, -1);
              oglsm.myglend;end
        else
        if (param.ospoint.ostype = os_point) then
        begin oglsm.myglbegin(GL_lines);
                                        oglsm.myglVertex2f(-1, 1);
                                        oglsm.myglVertex2f(1, -1);
                                        oglsm.myglVertex2f(-1, -1);
                                        oglsm.myglVertex2f(1, 1);
              oglsm.myglend;end
        else
        if (param.ospoint.ostype = os_intersection) then
        begin oglsm.myglbegin(GL_lines);
                                        oglsm.myglVertex2f(-1, 1);
                                        oglsm.myglVertex2f(1, -1);
                                        oglsm.myglVertex2f(-1, -1);
                                        oglsm.myglVertex2f(1, 1);
              oglsm.myglend;end
        else
        if (param.ospoint.ostype = os_apparentintersection) then
        begin oglsm.myglbegin(GL_lines);
                                        oglsm.myglVertex2f(-1, 1);
                                        oglsm.myglVertex2f(1, -1);
                                        oglsm.myglVertex2f(-1, -1);
                                        oglsm.myglVertex2f(1, 1);
              oglsm.myglend;oglsm.myglbegin(GL_lines{_loop});
                                        oglsm.myglVertex2f(-1, 1);
                                        oglsm.myglVertex2f(1, 1);
                                        oglsm.myglVertex2f(1, 1);
                                        oglsm.myglVertex2f(1, -1);
                                        oglsm.myglVertex2f(1, -1);
                                        oglsm.myglVertex2f(-1, -1);
                                        oglsm.myglVertex2f(-1, -1);
                                        oglsm.myglVertex2f(-1, 1);
              oglsm.myglend;end
        else
        if (param.ospoint.ostype = os_textinsert) then
        begin oglsm.myglbegin(GL_lines);
                                        oglsm.myglVertex2f(-1, 0);
                                        oglsm.myglVertex2f(1, 0);
                                        oglsm.myglVertex2f(0, 1);
                                        oglsm.myglVertex2f(0, -1);
               oglsm.myglend;end
        else
        if (param.ospoint.ostype = os_perpendicular) then
        begin oglsm.myglbegin(GL_LINES{_STRIP});
                                            oglsm.myglVertex2f(-1, -1);
                                            oglsm.myglVertex2f(-1, 1);
                                            oglsm.myglVertex2f(-1, 1);
                                            oglsm.myglVertex2f(1,1);
              oglsm.myglend;
              oglsm.myglbegin(GL_LINES{_STRIP});
                                            oglsm.myglVertex2f(-1, 0);
                                            oglsm.myglVertex2f(0, 0);
                                            oglsm.myglVertex2f(0, 0);
                                            oglsm.myglVertex2f(0,1);
              oglsm.myglend;end
        else
        if (param.ospoint.ostype = os_trace) then
        begin
             oglsm.myglbegin(GL_LINES);
                       oglsm.myglVertex2f(-1, -0.5);oglsm.myglVertex2f(1, -0.5);
                       oglsm.myglVertex2f(-1,  0.5);oglsm.myglVertex2f(1,  0.5);
              oglsm.myglend;
        end
        else if (param.ospoint.ostype = os_nearest) then
        begin oglsm.myglbegin(GL_lines{_loop});
                                            oglsm.myglVertex2d(-1, 1);
                                            oglsm.myglVertex2d(1, 1);
                                            oglsm.myglVertex2d(1, 1);
                                            oglsm.myglVertex2d(-1, -1);
                                            oglsm.myglVertex2d(-1, -1);
                                            oglsm.myglVertex2d(1, -1);
                                            oglsm.myglVertex2d(1, -1);
                                            oglsm.myglVertex2d(-1, 1);
              oglsm.myglend;end;
      oglsm.mygllinewidth(1);
    end;

    //oglsm.mytotalglend;
    //isOpenGLError;

   //{$ENDREGION}
   NotUseLCS:=_NotUseLCS;
    oglsm.myglMatrixMode(GL_PROJECTION);
    //glLoadIdentity;
    //gdb.GetCurrentDWG.pcamera^.projMatrix:=onematrix;
    if PDWG<>nil then
    begin
{    if param.projtype = Projparalel then
    begin
      gdb.GetCurrentDWG.pcamera^.projMatrix:=ortho(-clientwidth * param.zoom / 2, clientwidth * param.zoom / 2,
              -clientheight * param.zoom / 2, clientheight * param.zoom / 2,
               gdb.GetCurrentDWG.pcamera^.zmin, gdb.GetCurrentDWG.pcamera^.zmax,@onematrix);
    end;
    if param.projtype = Projperspective then
      gdb.GetCurrentDWG.pcamera^.projMatrix:=Perspective(gdb.GetCurrentDWG.pcamera^.fovy, Width / Height, gdb.GetCurrentDWG.pcamera^.zmin, gdb.GetCurrentDWG.pcamera^.zmax,@onematrix);
      glLoadMatrixD(@gdb.GetCurrentDWG.pcamera^.projMatrix);
     glulookat(-gdb.GetCurrentDWG.pcamera^.point.x, -gdb.GetCurrentDWG.pcamera^.point.y, -gdb.GetCurrentDWG.pcamera^.point.z,
               -gdb.GetCurrentDWG.pcamera^.point.x + gdb.GetCurrentDWG.pcamera^.look.x,
               -gdb.GetCurrentDWG.pcamera^.point.y + gdb.GetCurrentDWG.pcamera^.look.y,
               -gdb.GetCurrentDWG.pcamera^.point.z + gdb.GetCurrentDWG.pcamera^.look.z,
                gdb.GetCurrentDWG.pcamera^.ydir.x, gdb.GetCurrentDWG.pcamera^.ydir.y, gdb.GetCurrentDWG.pcamera^.ydir.z);
    gltranslated(0, 0, -500);
    oglsm.myglMatrixMode(GL_MODELVIEW);
    glLoadIdentity;
    oglsm.myglDisable(GL_LIGHTING);
}
    oglsm.myglDisable(GL_COLOR_LOGIC_OP);
    CalcOptimalMatrix;
    if param.CSIcon.axislen<>0 then {переделать}
    begin
    td:=param.CSIcon.axislen;
    td2:=td/5;
    td22:=td2/3;
    oglsm.myglbegin(GL_lines);
    oglsm.glColor3ub(255, 0, 0);

    oglsm.myglVertex3d(param.CSIcon.CSIconCoord);
    oglsm.myglVertex3d(param.CSIcon.CSIconX);

    oglsm.myglVertex3d(param.CSIcon.CSIconX);
    oglsm.myglVertex3d(createvertex(param.CSIcon.CSIconCoord.x + td-td2, param.CSIcon.CSIconCoord.y-td22 , param.CSIcon.CSIconCoord.z));

    oglsm.myglVertex3d(param.CSIcon.CSIconX);
    oglsm.myglVertex3d(createvertex(param.CSIcon.CSIconCoord.x + td-td2, param.CSIcon.CSIconCoord.y+td22 , param.CSIcon.CSIconCoord.z));

    oglsm.glColor3ub(0, 255, 0);

    oglsm.myglVertex3d(param.CSIcon.CSIconCoord);
    oglsm.myglVertex3d(param.CSIcon.CSIconY);

    oglsm.myglVertex3d(param.CSIcon.CSIconY);
    oglsm.myglVertex3d(createvertex(param.CSIcon.CSIconCoord.x-td22, param.CSIcon.CSIconCoord.y + td-td2, param.CSIcon.CSIconCoord.z));

    oglsm.myglVertex3d(param.CSIcon.CSIconY);
    oglsm.myglVertex3d(createvertex(param.CSIcon.CSIconCoord.x+td22, param.CSIcon.CSIconCoord.y + td-td2, param.CSIcon.CSIconCoord.z));

    oglsm.glColor3ub(0, 0, 255);

    oglsm.myglVertex3d(param.CSIcon.CSIconCoord);
    oglsm.myglVertex3d(param.CSIcon.CSIconZ);

    oglsm.myglend;
    if IsVectorNul(vectordot(pdwg.GetPcamera.prop.look,ZWCS)) then
    begin
    oglsm.myglbegin(GL_lines);
    oglsm.glColor3ub(255, 255, 255);
    oglsm.myglVertex3d(createvertex(param.CSIcon.CSIconCoord.x + td2, param.CSIcon.CSIconCoord.y , param.CSIcon.CSIconCoord.z));
    oglsm.myglVertex3d(createvertex(param.CSIcon.CSIconCoord.x + td2, param.CSIcon.CSIconCoord.y+ td2 , param.CSIcon.CSIconCoord.z));
    oglsm.myglVertex3d(createvertex(param.CSIcon.CSIconCoord.x + td2, param.CSIcon.CSIconCoord.y+ td2 , param.CSIcon.CSIconCoord.z));
    oglsm.myglVertex3d(createvertex(param.CSIcon.CSIconCoord.x, param.CSIcon.CSIconCoord.y+ td2 , param.CSIcon.CSIconCoord.z));
    oglsm.myglend;
    end;
    end;
    //oglsm.mytotalglend;
    //isOpenGLError;
    //oglsm.myglDisable(GL_COLOR_LOGIC_OP);
  end;
end;
procedure TOGLWnd.SaveBuffers;
  var
    scrx,scry,texture{,e}:integer;
begin
  {$IFDEF PERFOMANCELOG}log.programlog.LogOutStrFast('TOGLWnd.SaveBuffers',lp_incPos);{$ENDIF};
  oglsm.myglEnable(GL_TEXTURE_2D);
  //isOpenGLError;

   scrx:=0;
   scry:=0;
   texture:=0;
   repeat
         repeat
               oglsm.myglbindtexture(GL_TEXTURE_2D,myscrbuf[texture]);
               //isOpenGLError;
               oglsm.myglCopyTexSubImage2D(GL_TEXTURE_2D,0,0,0,scrx,scry,texturesize,texturesize);
               //isOpenGLError;
               scrx:=scrx+texturesize;
               inc(texture);
         until scrx>clientwidth;
   scrx:=0;
   scry:=scry+texturesize;
   until scry>clientheight;


  oglsm.myglDisable(GL_TEXTURE_2D);
  {$IFDEF PERFOMANCELOG}log.programlog.LogOutStrFast('TOGLWnd.SaveBuffers----{end}',lp_decPos);{$ENDIF}
end;
procedure TOGLWnd.RestoreBuffers;
  var
    scrx,scry,texture{,e}:integer;
    _NotUseLCS:boolean;
begin
  {$IFDEF PERFOMANCELOG}log.programlog.LogOutStrFast('TOGLWnd.RestoreBuffers',lp_incPos);{$ENDIF};
  _NotUseLCS:=NotUseLCS;
  oglsm.myglEnable(GL_TEXTURE_2D);
  oglsm.myglDisable(GL_DEPTH_TEST);
       oglsm.myglMatrixMode(GL_PROJECTION);
       oglsm.myglPushMatrix;
       oglsm.myglLoadIdentity;
       oglsm.myglOrtho(0.0, ClientWidth, 0.0, ClientHeight, -10.0, 10.0);
       oglsm.myglMatrixMode(GL_MODELVIEW);
       oglsm.myglPushMatrix;
       oglsm.myglLoadIdentity;
  begin
   scrx:=0;
   scry:=0;
   texture:=0;
   repeat
   repeat
         oglsm.myglbindtexture(GL_TEXTURE_2D,myscrbuf[texture]);
         //isOpenGLError;
         oglsm.glcolor3ub(255,255,255);
         oglsm.myglbegin(GL_quads);
                 oglsm.myglTexCoord2d(0,0);
                 oglsm.myglVertex2d(scrx,scry);
                 oglsm.myglTexCoord2d(1,0);
                 oglsm.myglVertex2d(scrx+texturesize,scry);
                 oglsm.myglTexCoord2d(1,1);
                 oglsm.myglVertex2d(scrx+texturesize,scry+texturesize);
                 oglsm.myglTexCoord2d(0,1);
                 oglsm.myglVertex2d(scrx,scry+texturesize);
         oglsm.myglend;
         oglsm.mytotalglend;
         //isOpenGLError;
         scrx:=scrx+texturesize;
         inc(texture);
   until scrx>clientwidth;
   scrx:=0;
   scry:=scry+texturesize;
   until scry>clientheight;
  end;
  oglsm.myglDisable(GL_TEXTURE_2D);
       oglsm.myglPopMatrix;
       oglsm.myglMatrixMode(GL_PROJECTION);
       oglsm.myglPopMatrix;
       oglsm.myglMatrixMode(GL_MODELVIEW);
   NotUseLCS:=_NotUseLCS;
  {$IFDEF PERFOMANCELOG}log.programlog.LogOutStrFast('TOGLWnd.RestoreBuffers----{end}',lp_decPos);{$ENDIF}
end;
procedure TOGLWnd.finishdraw;
  var
    LPTime:Tdatetime;
begin
     inc(sysvar.debug.int1);
     CalcOptimalMatrix;
     self.RestoreBuffers;
     LPTime:=now();
     PDWG.Getpcamera.DRAWNOTEND:=treerender(PDWG.GetCurrentROOT^.ObjArray.ObjTree,lptime,rc);
     self.SaveBuffers;
     self.showcursor;
     self.SwapBuffers;
end;
procedure TOGLWnd.drawdebuggeometry;
begin



end;
function TOGLWnd.CreateRC(_maxdetail:GDBBoolean=false):TDrawContext;
begin
  result.Subrender:=0;
  result.Selected:=false;
  result.VisibleActualy:=PDWG.Getpcamera.POSCOUNT;
  result.InfrustumActualy:=PDWG.Getpcamera.POSCOUNT;
  result.DRAWCOUNT:=PDWG.Getpcamera.DRAWCOUNT;
  result.SysLayer:=PDWG.GetLayerTable.GetSystemLayer;
  result.MaxDetail:=_maxdetail;

  if sysvar.dwg.DWG_DrawMode<>nil then
                                      result.DrawMode:=sysvar.dwg.DWG_DrawMode^
                                  else
                                      result.DrawMode:=1;
  result.OwnerLineWeight:=-3;
  result.OwnerColor:=ClWhite;
  result.MaxWidth:=sysvar.RD.RD_MaxWidth^;
  result.ScrollMode:=param.scrollmode;
  result.Zoom:=PDWG.GetPcamera.prop.zoom;
end;

procedure TOGLWnd.draw;
var
  //ps: TPaintStruct;
//  pg:PGDBvertex2S;
  {i,}a: GDBInteger;
//  fpss:GDBString;
  scrx,scry,texture{,e}:integer;
//  t:gdbdouble;
  scrollmode:GDBBOOlean;
  LPTime:Tdatetime;
  DC:TDrawContext;
  const msec=1;

begin
  //isOpenGLError;
  if not assigned(pdwg) then exit;
  self.MakeCurrent;
  //if not assigned(GDB.GetCurrentDWG.OGLwindow1) then exit;
  foreground.r:=not(sysvar.RD.RD_BackGroundColor^.r);
  foreground.g:=not(sysvar.RD.RD_BackGroundColor^.g);
  foreground.b:=not(sysvar.RD.RD_BackGroundColor^.b);
LPTime:=now();
dc:=CreateRC;
if param.firstdraw then
                 inc(PDWG.Getpcamera^.DRAWCOUNT);

//param.firstdraw:=true;
{$IFDEF TOTALYLOG}programlog.logoutstr('TOGLWnd.draw',0);{$ENDIF}
if (clientwidth=0)or(clientheight=0) then
                                         exit;
///self.SwapBuffers;
 {$IFDEF PERFOMANCELOG}log.programlog.LogOutStrFast('TOGLWnd.draw',lp_IncPos);{$ENDIF}
 tick:=0;

  //-------------------------------uEventIDtimer := timeSetEvent(msec, 0, @drawtick, 0, 1);
  //sysvar.RD.Restore_Mode^:=WND_NewDraw;
  //wglMakeCurrent(DC, hrc);
  //BeginPaint(Handle, ps);
  //glGetIntegerv(GL_LINE_WIDTH, @i);
  oglsm.myglClearColor(sysvar.RD.RD_BackGroundColor^.r/255,
               sysvar.RD.RD_BackGroundColor^.g/255,
               sysvar.RD.RD_BackGroundColor^.b/255,
               sysvar.RD.RD_BackGroundColor^.a/255);


  {oglsm.myglEnable(GL_DEPTH_TEST);
  oglsm.myglDisable(GL_LIGHTING);}
  //isOpenGLError;
  oglsm.myglEnable(GL_DEPTH_TEST);
  oglsm.myglEnable(GL_STENCIL_TEST);

  if SysVar.RD.RD_LineSmooth^ then
                                  begin
                                       oglsm.myglEnable(GL_BLEND);
                                       oglsm.myglBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );
                                       oglsm.myglEnable(GL_LINE_SMOOTH);
                                       oglsm.myglHint(GL_LINE_SMOOTH_HINT,GL_NICEST);
                                  end
                              else
                                  begin
                                       oglsm.myglDisable(GL_BLEND);
                                       oglsm.myglDisable(GL_LINE_SMOOTH);
                                  end;
 if PDWG.GetCurrentROOT.ObjArray.Count=1 then
                                                    tick:=0;

 oglsm.myglStencilFunc(gl_always,0,1);
 oglsm.myglStencilOp(GL_KEEP,GL_KEEP,GL_KEEP);


  if PDWG<>nil then
  begin
  if sysvar.RD.RD_Restore_Mode^=WND_AccumBuffer then
  begin
  if param.firstdraw = true then
  begin
    oglsm.myglClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT or GL_STENCIL_BUFFER_BIT);
    DrawGrid;
    render(PDWG.GetCurrentROOT^,{subrender}dc);
    oglsm.myglaccum(GL_LOAD,1);
    inc(dc.subrender);
    render(PDWG.GetConstructObjRoot^,{subrender}dc);
    PDWG.GetSelObjArray.remappoints(PDWG.GetPcamera.POSCOUNT,param.scrollmode,PDWG.GetPcamera^,PDWG^.myGluProject2);
    PDWG.GetSelObjArray.drawobj({gdb.GetCurrentDWG.pcamera.POSCOUNT,subrender}dc);
    dec(dc.subrender);
    showcursor;
    //param.firstdraw := false;
  end
  else
  begin
    oglsm.myglDisable(GL_DEPTH_TEST);
    oglsm.myglaccum(GL_return,1);
    inc(dc.subrender);
    render(PDWG.GetConstructObjRoot^,dc);
    PDWG.GetSelObjArray.drawobj({gdb.GetCurrentDWG.pcamera.POSCOUNT,subrender}dc);
    dec(dc.subrender);
    showcursor;
    CalcOptimalMatrix;
    oglsm.myglEnable(GL_DEPTH_TEST);
  end;
  end
else if sysvar.RD.RD_Restore_Mode^=WND_AuxBuffer then
  begin
  if param.firstdraw = true then
  begin
    oglsm.myglDisable(GL_LIGHTING);
    oglsm.myglDrawBuffer(GL_AUX0);
     oglsm.myglClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT or GL_STENCIL_BUFFER_BIT);
    DrawGrid;
    render(PDWG.GetCurrentROOT^,dc);
    PDWG.GetCurrentROOT.DrawBB;
    oglsm.myglDrawBuffer(GL_BACK);
    oglsm.myglReadBuffer(GL_AUX0);
    oglsm.myglcopypixels(0, 0, clientwidth, clientheight, GL_COLOR);
    oglsm.myglDisable(GL_DEPTH_TEST);
    inc(dc.subrender);
    render(PDWG.GetConstructObjRoot^,dc);
    PDWG.GetSelObjArray.remappoints(PDWG.GetPcamera.POSCOUNT,param.scrollmode,PDWG.GetPcamera^,PDWG^.myGluProject2);
    PDWG.GetSelObjArray.drawobj({gdb.GetCurrentDWG.pcamera.POSCOUNT,subrender}dc);
    dec(dc.subrender);
    showcursor;
    //param.firstdraw := false;
  end
  else
  begin
    oglsm.myglDisable(GL_DEPTH_TEST);
    begin
         oglsm.myglDrawBuffer(GL_BACK);
         oglsm.myglReadBuffer(GL_AUX0);
         oglsm.myglcopypixels(0, 0, clientwidth, clientheight, GL_COLOR);
    end;
    inc(dc.subrender);
    render(PDWG.GetConstructObjRoot^,dc);
    PDWG.GetSelObjArray.drawobj({.GetCurrentDWG.pcamera.POSCOUNT,subrender}dc);
    showcursor;
    CalcOptimalMatrix;
    dec(dc.subrender);
    oglsm.myglEnable(GL_DEPTH_TEST);
    oglsm.myglReadBuffer(GL_BACK);
  end;
  end
else if sysvar.RD.RD_Restore_Mode^=WND_DrawPixels then
  begin
  if param.firstdraw = true then
  begin
     oglsm.myglClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT or GL_STENCIL_BUFFER_BIT);
    oglsm.myglDisable(GL_LIGHTING);
    DrawGrid;
    render(PDWG.GetCurrentROOT^,dc);
    oglsm.myglreadpixels(0, 0, clientwidth, clientheight, GL_BGRA_EXT{GL_RGBA}, gl_unsigned_Byte, param.pglscreen);
    inc(dc.subrender);
    render(PDWG.GetConstructObjRoot^,dc);
    PDWG.GetSelObjArray.remappoints(PDWG.GetPcamera.POSCOUNT,param.scrollmode,PDWG.GetPcamera^,PDWG^.myGluProject2);
    PDWG.GetSelObjArray.drawobj({gdb.GetCurrentDWG.pcamera.POSCOUNT,subrender}dc);
    dec(dc.subrender);
    showcursor;
    //param.firstdraw := false;
  end
  else
  begin


    oglsm.myglDisable(GL_DEPTH_TEST);
    begin
         oglsm.myglMatrixMode(GL_PROJECTION);
         oglsm.myglPushMatrix;
         oglsm.myglLoadIdentity;
         oglsm.myglOrtho(0.0, ClientWidth, 0.0, ClientHeight, -10.0, 1.0);
         oglsm.myglMatrixMode(GL_MODELVIEW);
         oglsm.myglPushMatrix;
         oglsm.myglLoadIdentity;
         oglsm.myglRasterPos2i(0, 0);
         oglsm.myglDisable(GL_DEPTH_TEST);
         oglsm.myglDrawPixels(ClientWidth, ClientHeight, GL_BGRA_EXT{GL_RGBA}, GL_UNSIGNED_BYTE, param.pglscreen);
         oglsm.myglPopMatrix;
         oglsm.myglMatrixMode(GL_PROJECTION);
         oglsm.myglPopMatrix;
         oglsm.myglMatrixMode(GL_MODELVIEW);
    end;
    inc(dc.subrender);
    render(PDWG.GetConstructObjRoot^,dc);
    PDWG.GetSelObjArray.drawobj({gdb.GetCurrentDWG.pcamera.POSCOUNT,subrender}dc);
    dec(dc.subrender);
    showcursor;
    CalcOptimalMatrix;
    oglsm.myglEnable(GL_DEPTH_TEST);


  end;
  end
else if sysvar.RD.RD_Restore_Mode^=WND_NewDraw then
  begin
    oglsm.myglDisable(GL_LIGHTING);
     oglsm.myglClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT or GL_STENCIL_BUFFER_BIT);
    DrawGrid;
    inc(dc.subrender);
    render(PDWG.GetCurrentROOT^,dc);
    dec(dc.subrender);
    inc(dc.subrender);
    PDWG.GetSelObjArray.remappoints(PDWG.GetPcamera.POSCOUNT,param.scrollmode,PDWG.GetPcamera^,PDWG^.myGluProject2);
    PDWG.GetSelObjArray.drawobj({gdb.GetCurrentDWG.pcamera.POSCOUNT,subrender}dc);
    dec(dc.subrender);
    showcursor;
    //param.firstdraw := false;
    PDWG.GetSelObjArray.remappoints(PDWG.GetPcamera.POSCOUNT,param.scrollmode,PDWG.GetPcamera^,PDWG^.myGluProject2);
  end
else if sysvar.RD.RD_Restore_Mode^=WND_Texture then
  begin
  if param.firstdraw = true then
  begin
    //isOpenGLError;
    oglsm.mytotalglend;

    oglsm.myglReadBuffer(GL_back);
    oglsm.myglClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT or GL_STENCIL_BUFFER_BIT);

    //oglsm.myglEnable(GL_STENCIL_TEST);
    CalcOptimalMatrix;
    if sysvar.RD.RD_UseStencil<>nil then
    if sysvar.RD.RD_UseStencil^ then
    begin
    oglsm.myglStencilFunc(GL_NEVER, 1, 0); // значение mask не используется
    oglsm.myglStencilOp(GL_REPLACE, GL_KEEP, GL_KEEP);
    PDWG.GetSelObjArray.drawobject(dc{gdb.GetCurrentDWG.pcamera.POSCOUNT,0});

    //oglsm.mytotalglend;

    end;
    //oglsm.myglDisable(GL_LINE_SMOOTH);
    oglsm.mygllinewidth(1);
    oglsm.myglpointsize(1);
    oglsm.myglDisable(gl_point_smooth);

    oglsm.myglStencilFunc(GL_EQUAL,0,1);
    oglsm.myglStencilOp(GL_KEEP, GL_KEEP, GL_KEEP);

    //isOpenGLError;
    DrawGrid;
    drawdebuggeometry;

    //oglsm.mytotalglend;

    LightOn;

    if (sysvar.DWG.DWG_SystmGeometryDraw^) then
                                               begin
                                               oglsm.glcolor3ubv(palette[sysvar.SYS.SYS_SystmGeometryColor^+2]);
                                               PDWG.GetCurrentROOT^.ObjArray.ObjTree.draw;
                                               end;
                                           //else
                                              begin
                                              OGLSM.startrender;
                                              PDWG.Getpcamera.DRAWNOTEND:=treerender(PDWG.GetCurrentROOT^.ObjArray.ObjTree,lptime,dc);
                                              //oglsm.mytotalglend;
                                              //isOpenGLError;
                                              //render(gdb.GetCurrentROOT^);
                                              OGLSM.endrender;
                                              end;



                                                  //oglsm.mytotalglend;


    PDWG.GetCurrentROOT.DrawBB;

        oglsm.mytotalglend;


    self.SaveBuffers;

    oglsm.myglDisable(GL_DEPTH_TEST);
    inc(dc.subrender);
    if commandmanager.pcommandrunning<>nil then
                                               commandmanager.pcommandrunning^.DrawHeplGeometry;

    scrollmode:={GDB.GetCurrentDWG^.OGLwindow1.}param.scrollmode;
    {GDB.GetCurrentDWG.OGLwindow1.}param.scrollmode:=true;

    render(PDWG.GetConstructObjRoot^,dc);


        //oglsm.mytotalglend;


    {GDB.GetCurrentDWG.OGLwindow1.}param.scrollmode:=scrollmode;
    PDWG.GetConstructObjRoot.DrawBB;

        //oglsm.mytotalglend;


    PDWG.GetSelObjArray.remappoints(PDWG.GetPcamera.POSCOUNT,param.scrollmode,PDWG.GetPcamera^,PDWG^.myGluProject2);
    oglsm.myglDisable(GL_STENCIL_TEST);
    dc.MaxDetail:=true;
    PDWG.GetSelObjArray.drawobj({gdb.GetCurrentDWG.pcamera.POSCOUNT,subrender}dc);
    dec(dc.subrender);
    LightOff;
    showcursor;

        //oglsm.mytotalglend;
        //isOpenGLError;


    //param.firstdraw := false;
  end
  else
  begin

      //oglsm.mytotalglend;

    LightOff;
    self.RestoreBuffers;
    //oglsm.mytotalglend;
    inc(dc.subrender);
    if PDWG.GetConstructObjRoot.ObjArray.Count>0 then
                                                    PDWG.GetConstructObjRoot.ObjArray.Count:=PDWG.GetConstructObjRoot.ObjArray.Count;
    if commandmanager.pcommandrunning<>nil then
                                               commandmanager.pcommandrunning^.DrawHeplGeometry;
    scrollmode:={GDB.GetCurrentDWG.OGLwindow1.}param.scrollmode;
    {GDB.GetCurrentDWG.OGLwindow1.}param.scrollmode:=true;
    render(PDWG.GetConstructObjRoot^,dc);

        //oglsm.mytotalglend;


    {GDB.GetCurrentDWG.OGLwindow1.}param.scrollmode:=scrollmode;
    PDWG.GetConstructObjRoot.DrawBB;

        //oglsm.mytotalglend;



    oglsm.myglDisable(GL_STENCIL_TEST);
    dc.MaxDetail:=true;
    PDWG.GetSelObjArray.drawobj({gdb.GetCurrentDWG.pcamera.POSCOUNT,subrender}dc);

        //oglsm.mytotalglend;

    showcursor;

        //oglsm.mytotalglend;


    dec(dc.subrender);
    oglsm.myglEnable(GL_DEPTH_TEST);
  end;
  end
  end
     else begin
               oglsm.myglClearColor(0.6,0.6,0.6,1);
               oglsm.myglClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
          end;



  //------------------------------------------------------------------MySwapBuffers(OGLContext);//SwapBuffers(DC);

  oglsm.mytotalglend;
  isOpenGLError;
  {glFlush;
  glFinish;}
  self.SwapBuffers;
  //isOpenGLError;


  //EndPaint(Handle, ps);
  //------------------------------------------------------------------timeKillEvent(uEventIDtimer);
  lptime:=now()-LPTime;
  tick:=round(lptime*10e7);
  //tick:=FrameDiffTimeInMSecs;
  //sysvar.RD.RD_LastRenderTime^:=tick;
  {if tick<>0 then begin
                       if param.firstdraw then
                                        sysvar.RD.RD_LastRenderTime^:=tick*msec;
                  end
              else begin
                       if param.firstdraw then
                                              sysvar.RD.RD_LastRenderTime^:=0
                                          else
                                              sysvar.RD.RD_LastRenderTime^:=-abs(sysvar.RD.RD_LastRenderTime^);
                  end;}
  if param.firstdraw then
                         sysvar.RD.RD_LastRenderTime^:=tick*msec
                     else
                         sysvar.RD.RD_LastUpdateTime^:=tick*msec;
  {$IFDEF PERFOMANCELOG}
                       if param.firstdraw then
                                              log.programlog.LogOutStrFast('Draw time='+inttostr(sysvar.RD.RD_LastRenderTime^),0)
                                          else
                                              log.programlog.LogOutStrFast('ReDraw time='+inttostr(sysvar.RD.RD_LastUpdateTime^),0);
  {$ENDIF}
  //title:=title+fpss;
  if param.firstdraw then
  if   SysVar.RD.RD_ImageDegradation.RD_ID_Enabled^ then
  begin
  dt:=sysvar.RD.RD_LastRenderTime^-SysVar.RD.RD_ImageDegradation.RD_ID_PrefferedRenderTime^;
  if dt<0 then
                                         SysVar.RD.RD_ImageDegradation.RD_ID_CurrentDegradationFactor:=SysVar.RD.RD_ImageDegradation.RD_ID_CurrentDegradationFactor+{0.5}dt/5
                                     else
                                         SysVar.RD.RD_ImageDegradation.RD_ID_CurrentDegradationFactor:=SysVar.RD.RD_ImageDegradation.RD_ID_CurrentDegradationFactor+{0.5}dt/10;
  if SysVar.RD.RD_ImageDegradation.RD_ID_CurrentDegradationFactor>SysVar.RD.RD_ImageDegradation.RD_ID_MaxDegradationFactor^ then
                                                 SysVar.RD.RD_ImageDegradation.RD_ID_CurrentDegradationFactor:=SysVar.RD.RD_ImageDegradation.RD_ID_MaxDegradationFactor^;
  if SysVar.RD.RD_ImageDegradation.RD_ID_CurrentDegradationFactor<0 then
                                                 SysVar.RD.RD_ImageDegradation.RD_ID_CurrentDegradationFactor:=0;
  end;
  param.firstdraw := false;
  {$IFDEF PERFOMANCELOG}log.programlog.LogOutStrFast('TOGLWnd.draw---{end}',lp_DecPos);{$ENDIF}
end;


function TOGLWnd.treerender;
var
   currtime:TDateTime;
   Hour,Minute,Second,MilliSecond:word;
   q1,q2:gdbboolean;
   //currd:PTDrawing;
begin //currd:=gdb.GetCurrentDWG;
    if (sysvar.RD.RD_MaxRenderTime^<>0) then
    begin
     currtime:=now;
     decodetime(currtime-StartTime,Hour,Minute,Second,MilliSecond);
     if assigned(sysvar.RD.RD_MaxRenderTime) then
     if (sysvar.RD.RD_MaxRenderTime^<>0) then
     if (sysvar.RD.RD_MaxRenderTime^-MilliSecond)<0 then
                            begin
                                  result:=true;
                                  exit;
                            end;
     end;
     q1:=false;
     q2:=false;

  if Node.infrustum={gdb.GetCurrentDWG}PDWG.Getpcamera.POSCOUNT then
  begin
       if (Node.FulDraw)or(Node.nul.count=0) then
       begin
       if assigned(node.pminusnode)then
                                       if node.minusdrawpos<>PDWG.Getpcamera.DRAWCOUNT then
                                       begin
                                       if not treerender(node.pminusnode^,StartTime,dc) then
                                           node.minusdrawpos:=PDWG.Getpcamera.DRAWCOUNT
                                                                                     else
                                                                                         q1:=true;
                                       end;
       if assigned(node.pplusnode)then
                                      if node.plusdrawpos<>PDWG.Getpcamera.DRAWCOUNT then
                                      begin
                                       if not treerender(node.pplusnode^,StartTime,dc) then
                                           node.plusdrawpos:=PDWG.Getpcamera.DRAWCOUNT
                                                                                    else
                                                                                        q2:=true;
                                      end;
       end;
       if node.nuldrawpos<>PDWG.Getpcamera.DRAWCOUNT then
       begin
        Node.nul.DrawWithattrib(dc{gdb.GetCurrentDWG.pcamera.POSCOUNT,subrender});
        node.nuldrawpos:=PDWG.Getpcamera.DRAWCOUNT;
       end;
  end;
  result:=(q1) or (q2);
  //Node.drawpos:=gdb.GetCurrentDWG.pcamera.DRAWCOUNT;

  //root.DrawWithattrib(gdb.GetCurrentDWG.pcamera.POSCOUNT);
end;

procedure TOGLWnd.render;
begin
  if dc.subrender = 0 then
  begin
    PDWG.Getpcamera^.obj_zmax:=-nan;
    PDWG.Getpcamera^.obj_zmin:=-1000000;
    PDWG.Getpcamera^.totalobj:=0;
    PDWG.Getpcamera^.infrustum:=0;
    //gdb.pcamera.getfrustum;
    //pva^.calcvisible;
//    if not param.scrollmode then
//                                PVA.renderfeedbac;
    //if not param.scrollmode then 56RenderOsnapstart(pva);
    CalcOptimalMatrix;
    //Clearcparray;
  end;
  //if param.subrender=0 then
  //pva^.DeSelect;
  //if pva^.Count>0 then
  //                       pva^.Count:=pva^.Count;
  root.{ObjArray.}DrawWithattrib({gdb.GetCurrentDWG.pcamera.POSCOUNT,0}dc);
end;
function TOGLWnd.findonmobj(pva: PGDBObjEntityOpenArray; var i: GDBInteger): GDBInteger;
var
  pp:PGDBObjEntity;
  ir:itrec;
  _total,_visible,_isonmouse:integer;
begin
  {$IFDEF PERFOMANCELOG}log.programlog.LogOutStrFast('TOGLWnd.findonmobj',lp_IncPos);{$ENDIF}
  if not param.scrollmode then
  begin
  _total:=0;
  _visible:=0;
  _isonmouse:=0;
  pp:=pva^.beginiterate(ir);
  if pp<>nil then
  repeat
       inc(_total);
       if pp^.visible=PDWG.Getpcamera.VISCOUNT then
       begin
       inc(_visible);
       if pp^.isonmouse(PDWG.GetOnMouseObj^,param.mousefrustum)
       then
           begin
                inc(_isonmouse);
                pp:=pp.ReturnLastOnMouse;
                param.SelDesc.OnMouseObject:=pp;
                PDWG.GetOnMouseObj.add(addr(pp));
           end;

       end;
  pp:=pva^.iterate(ir);
  until pp=nil;
  {$IFDEF PERFOMANCELOG}log.programlog.LogOutStrFast('Total:='+inttostr(_total)+'; Visible:='+inttostr(_visible)+'; IsOnMouse:='+inttostr(_isonmouse),0);{$ENDIF}
  end
  else {$IFDEF PERFOMANCELOG}log.programlog.LogOutStrFast('param.scrollmode=true. exit',0);{$ENDIF}
  {$IFDEF PERFOMANCELOG}log.programlog.LogOutStrFast('TOGLWnd.findonmobj-----{end}',lp_DecPos);{$ENDIF}
end;
procedure TOGLWnd.processmousenode(Node:TEntTreeNode;var i:integer);
var
  pp:PGDBObjEntity;
  ir:itrec;
  inr:TINRect;
begin
     if CalcAABBInFrustum (Node.BoundingBox,param.mousefrustum)<>IREmpty then
     begin
          findonmobj(@node.nul, i);
          if assigned(node.pminusnode) then
                                           processmousenode(node.pminusnode^,i);
          if assigned(node.pplusnode) then
                                           processmousenode(node.pplusnode^,i);
     end;
end;

procedure TOGLWnd.getonmouseobjectbytree(Node:TEntTreeNode);
var
  i: GDBInteger;
  pp:PGDBObjEntity;
  ir:itrec;
  inr:TINRect;
begin
  {$IFDEF PERFOMANCELOG}log.programlog.LogOutStrFast('TOGLWnd.getonmouseobjectbytree',lp_IncPos);{$ENDIF}
  i := 0;
  PDWG.GetOnMouseObj.clear;
  param.SelDesc.OnMouseObject := nil;


  processmousenode(Node,i);
  if param.processObjConstruct then
                                   findonmobj(@PDWG.GetConstructObjRoot.ObjArray,i);

  pp:=PDWG.GetOnMouseObj.beginiterate(ir);
  if pp<>nil then
                 begin
                      param.lastonmouseobject:=pp;
                      repeat
                            if pp^.vp.LastCameraPos<>PDWG.Getpcamera^.POSCOUNT then
                            pp^.RenderFeedback(PDWG.Getpcamera^.POSCOUNT,PDWG.Getpcamera^,PDWG.myGluProject2);


                            pp:=PDWG.GetOnMouseObj.iterate(ir);
                      until pp=nil;
                 end;

  {gdb.GetCurrentDWG.OnMouseObj.clear;
  param.SelDesc.OnMouseObject := nil;
  param.lastonmouseobject:=nil;}

  {$IFDEF PERFOMANCELOG}log.programlog.LogOutStrFast('TOGLWnd.getonmouseobjectbytree------{end}',lp_DecPos);{$ENDIF}
end;
function TOGLWnd.GetOnMouseObjDesc:GDBString;
var
  i: GDBInteger;
  pp:PGDBObjEntity;
  ir:itrec;
  inr:TINRect;
  line:GDBString;
  pvd:pvardesk;
begin
     result:='';
     i:=0;
     pp:=PDWG.GetOnMouseObj.beginiterate(ir);
     if pp<>nil then
                    begin
                         repeat
                         pvd:=pp.ou.FindVariable('NMO_Name');
                         if pvd<>nil then
                                         begin
                                         if i=20 then
                                         begin
                                              result:=result+#13#10+'...';
                                              exit;
                                         end;
                                         line:=pp^.GetObjName+' Layer='+pp^.vp.Layer.GetFullName;
                                         line:=line+' Name='+pvd.data.PTD.GetValueAsString(pvd.data.Instance);
                                         if result='' then
                                                          result:=line
                                                      else
                                                          result:=result+#13#10+line;
                                         inc(i);
                                         end;
                               pp:=PDWG.GetOnMouseObj.iterate(ir);
                         until pp=nil;
                    end;
end;

procedure TOGLWnd.getonmouseobject;
var
  i: GDBInteger;
  pp:PGDBObjEntity;
      ir:itrec;
begin
  {$IFDEF PERFOMANCELOG}log.programlog.LogOutStrFast('TOGLWnd.getonmouseobject',lp_IncPos);{$ENDIF}
  i := 0;
  PDWG.GetOnMouseObj.clear;
  param.SelDesc.OnMouseObject := nil;
  findonmobj(pva, i);
  pp:=PDWG.GetOnMouseObj.beginiterate(ir);
  if pp<>nil then
                 begin
                      param.lastonmouseobject:=pp;
                      repeat
                            if pp^.vp.LastCameraPos<>PDWG.Getpcamera^.POSCOUNT then
                            pp^.RenderFeedback(PDWG.Getpcamera^.POSCOUNT,PDWG.Getpcamera^,PDWG.myGluProject2);


                            pp:=PDWG.GetOnMouseObj.iterate(ir);
                      until pp=nil;
                 end;

  {gdb.GetCurrentDWG.OnMouseObj.clear;
  param.SelDesc.OnMouseObject := nil;
  param.lastonmouseobject:=nil;}

  {$IFDEF PERFOMANCELOG}log.programlog.LogOutStrFast('TOGLWnd.getonmouseobject------{end}',lp_DecPos);{$ENDIF}
end;
procedure TOGLWnd.addaxistootrack(var posr:os_record;const axis:GDBVertex);
begin
     posr.arrayworldaxis.Add(@axis);

     if @posr<>@param.ontrackarray.otrackarray[0] then
     if (SysVar.dwg.DWG_OSMode^ and osm_paralel)<>0 then
     begin
          param.ontrackarray.otrackarray[0].arrayworldaxis.Add(@axis);
     end;
end;

procedure TOGLWnd.projectaxis;
var
  i: GDBInteger;
  temp: gdbvertex;
  pv:pgdbvertex;
  tp:traceprop;

  Objects:GDBObjOpenArrayOfPV;
  pobj:pGDBObjEntity;
  ir:itrec;
begin
  PDWG.myGluProject2(param.ospoint.worldcoord,
             param.ospoint.dispcoord);
  if sysvar.dwg.DWG_PolarMode^ = 0 then exit;
  //param.ospoint.arrayworldaxis.init({$IFDEF DEBUGBUILD}'{8BE71BAA-507B-4D6B-BE2C-63693022090C}',{$ENDIF}4);
  param.ospoint.arrayworldaxis.clear;
  pv:=polaraxis.PArray;
  for i:=0 to polaraxis.Count-1 do
  begin
       param.ospoint.arrayworldaxis.add(@pv^);
       inc(pv);
  end;
  //if param.ospoint.PGDBObject<>nil then
  begin
  objects.init({$IFDEF DEBUGBUILD}'{8BE71BAA-507B-4D6B-BE2C-63693022090C}',{$ENDIF}100);
  if PDWG.GetCurrentROOT.FindObjectsInPoint(param.ospoint.worldcoord,Objects) then
  begin
                       pobj:=objects.beginiterate(ir);
                       if pobj<>nil then
                       repeat
                             pgdbobjentity(pobj)^.AddOnTrackAxis(param.ospoint,addaxistootrack);
                             pobj:=objects.iterate(ir);
                       until pobj=nil;
  end;
  {if param.ospoint.PGDBObject<>nil then
  begin
       pgdbobjentity(param.ospoint.PGDBObject)^.AddOnTrackAxis(@param.ospoint);   fghfgh
  end;}
  objects.ClearAndDone;
  if param.processObjConstruct then
  begin
  objects.init({$IFDEF DEBUGBUILD}'{8BE71BAA-507B-4D6B-BE2C-63693022090C}',{$ENDIF}100);
  if PDWG.GetConstructObjRoot.FindObjectsInPointSlow(param.ospoint.worldcoord,Objects) then
  begin
                       pobj:=objects.beginiterate(ir);
                       if pobj<>nil then
                       repeat
                             pgdbobjentity(pobj)^.AddOnTrackAxis(param.ospoint,addaxistootrack);
                             pobj:=objects.iterate(ir);
                       until pobj=nil;
  end;
  objects.ClearAndDone;
  end;
  end;
  project0axis;
  {GDBGetMem(param.ospoint.arrayworldaxis, sizeof(GDBWord) + param.ppolaraxis^.count * sizeof(gdbvertex));
  Move(param.ppolaraxis^, param.ospoint.arrayworldaxis^, sizeof(GDBWord) + param.ppolaraxis^.count * sizeof(gdbvertex));}
  PDWG.myGluProject2(param.ospoint.worldcoord,
             param.ospoint.dispcoord);
  //param.ospoint.arraydispaxis.init({$IFDEF DEBUGBUILD}'{722A886F-5616-4E8F-B94D-3A1C3D7ADBD4}',{$ENDIF}param.ospoint.arrayworldaxis.count);
  param.ospoint.arraydispaxis.clear;
  //GDBGetMem(param.ospoint.arraydispaxis, sizeof(GDBWord) + param.ospoint.arrayworldaxis.count * sizeof(traceprop));
  //param.ospoint.arraydispaxis.count := param.ospoint.arrayworldaxis.count;
  pv:=param.ospoint.arrayworldaxis.PArray;
  for i := 0 to param.ospoint.arrayworldaxis.count - 1 do
  begin
    PDWG.myGluProject2(createvertex(param.ospoint.worldcoord.x + pv.x, param.ospoint.worldcoord.y + pv.y, param.ospoint.worldcoord.z + pv.z),
                                     temp);
    tp.dir.x:=temp.x - param.ospoint.dispcoord.x;
    tp.dir.y:=(temp.y - param.ospoint.dispcoord.y);
    tp.dir.z:=temp.z - param.ospoint.dispcoord.z;
    param.ospoint.arraydispaxis.add(@tp);
    {param.ospoint.arraydispaxis.arr[i].dir.x := temp.x - param.ospoint.dispcoord.x;
    param.ospoint.arraydispaxis.arr[i].dir.y := -(temp.y - param.ospoint.dispcoord.y);
    param.ospoint.arraydispaxis.arr[i].dir.z := temp.z - param.ospoint.dispcoord.z;}
    inc(pv);
  end
end;
procedure TOGLWnd.create0axis;
var
  i: GDBInteger;
  pv:pgdbvertex;
  Objects:GDBObjOpenArrayOfPV;
  pobj:pGDBObjEntity;
  ir:itrec;
begin
  PDWG.myGluProject2(param.ospoint.worldcoord,
             param.ospoint.dispcoord);
  if sysvar.dwg.DWG_PolarMode^ = 0 then exit;
  //param.ontrackarray.otrackarray[0].arrayworldaxis.init({$IFDEF DEBUGBUILD}'{8BE71BAA-507B-4D6B-BE2C-63693022090C}',{$ENDIF}4);
  param.ontrackarray.otrackarray[0].arrayworldaxis.clear;
  pv:=polaraxis.PArray;
  for i:=0 to polaraxis.Count-1 do
  begin
       param.ontrackarray.otrackarray[0].arrayworldaxis.add(@pv^);
       inc(pv);
  end;

  if tocommandmcliccount>0 then
  begin
  objects.init({$IFDEF DEBUGBUILD}'{8BE71BAA-507B-4D6B-BE2C-63693022090C}',{$ENDIF}100);
  if PDWG.GetCurrentROOT.FindObjectsInPoint(param.ontrackarray.otrackarray[0].worldcoord,Objects) then
  begin
                       pobj:=objects.beginiterate(ir);
                       if pobj<>nil then
                       repeat
                             pgdbobjentity(pobj)^.AddOnTrackAxis(param.ontrackarray.otrackarray[0],addaxistootrack);
                             pobj:=objects.iterate(ir);
                       until pobj=nil;
  end;
  objects.ClearAndDone;
                       if param.processObjConstruct then
                       begin
  objects.init({$IFDEF DEBUGBUILD}'{8BE71BAA-507B-4D6B-BE2C-63693022090C}',{$ENDIF}100);
  if PDWG.GetConstructObjRoot.FindObjectsInPointSlow(param.ontrackarray.otrackarray[0].worldcoord,Objects) then
  begin
                       pobj:=objects.beginiterate(ir);
                       if pobj<>nil then
                       repeat
                             pgdbobjentity(pobj)^.AddOnTrackAxis(param.ontrackarray.otrackarray[0],addaxistootrack);
                             pobj:=objects.iterate(ir);
                       until pobj=nil;
  end;
  objects.ClearAndDone;
  end;
  end;


  Project0Axis;
end;

procedure TOGLWnd.reprojectaxis;
var
  i, j, a: GDBInteger;
  temp: gdbvertex;
  pv:pgdbvertex;
  pt,pt2:ptraceprop;
  ir,ir2:itrec;
  ip:intercept3dprop;
  lastontracdist,currentontracdist,tx,ty,tz:gdbdouble;
  test:gdbboolean;
  pobj:pgdbobjentity;
//  dispraylen:double;
begin
  if param.ontrackarray.total = 0 then exit;
  param.polarlinetrace := 0;

    if tocommandmcliccount=0 then
                                 a:=1
                             else
                                 a:=0;
    for j := a to param.ontrackarray.total - 1 do
    begin
      PDWG.myGluProject2(param.ontrackarray.otrackarray[j].worldcoord,
                 param.ontrackarray.otrackarray[j].dispcoord);
    end;
    if sysvar.dwg.DWG_PolarMode^ = 0 then exit;
  for j := a to param.ontrackarray.total - 1 do
  begin
    {gdb.GetCurrentDWG^.myGluProject2(param.ontrackarray.otrackarray[j].worldcoord,
               param.ontrackarray.otrackarray[j].dispcoord);}
    param.ontrackarray.otrackarray[j].dispcoord.z:=0;
    param.ontrackarray.otrackarray[j].dmousecoord.x :=
    param.md.glmouse.x - param.ontrackarray.otrackarray[j].dispcoord.x;
    param.ontrackarray.otrackarray[j].dmousecoord.y :=
    //-(clientheight - param.md.glmouse.y - param.ontrackarray.otrackarray[j].dispcoord.y);
    param.md.glmouse.y -  param.ontrackarray.otrackarray[j].dispcoord.y;
    param.ontrackarray.otrackarray[j].dmousecoord.z := 0;
     //caption:=floattostr(ontrackarray.otrackarray[j].dmousecoord.x)+';'+floattostr(ontrackarray.otrackarray[j].dmousecoord.y);
     //caption:='' ;
    param.ontrackarray.otrackarray[j].dmousecoord.z := 0;
    lastontracdist:=infinity;
    pt2:=nil;
    if param.ontrackarray.otrackarray[j].arrayworldaxis.Count <> 0 then
    begin
      pv:=param.ontrackarray.otrackarray[j].arrayworldaxis.PArray;
      pt:=param.ontrackarray.otrackarray[j].arraydispaxis.PArray;
      for i := 0 to param.ontrackarray.otrackarray[j].arrayworldaxis.count - 1 do
      begin
        PDWG.myGluProject2(createvertex(param.ontrackarray.otrackarray[j].worldcoord.x + pv.x,
                   param.ontrackarray.otrackarray[j].worldcoord.y + pv.y,
                   param.ontrackarray.otrackarray[j].worldcoord.z + pv.z),
                   temp);
        pt.dir.x := temp.x - param.ontrackarray.otrackarray[j].dispcoord.x;
        pt.dir.y := (temp.y - param.ontrackarray.otrackarray[j].dispcoord.y);
        pt.dir.z := temp.z - param.ontrackarray.otrackarray[j].dispcoord.z;

        pt.trace:=false;

        if (pt.dir.x*pt.dir.x+pt.dir.y*pt.dir.y)>sqreps then

        begin
        pt.tmouse :=
          (pt.dir.x *
          param.ontrackarray.otrackarray[j].dmousecoord.x +
          pt.dir.y *
          param.ontrackarray.otrackarray[j].dmousecoord.y)
          / (sqr(pt.dir.x) + sqr(pt.dir.y));
        //dispraylen:=

        tx:=pt.tmouse * pv.x;
        ty:=pt.tmouse * pv.y;
        tz:=pt.tmouse * pv.z;

        pt.dispraycoord.x := param.ontrackarray.otrackarray[j].dispcoord.x + pt.tmouse * pt.dir.x;
        pt.dispraycoord.y := param.ontrackarray.otrackarray[j].dispcoord.y + pt.tmouse * pt.dir.y;
        pt.dispraycoord.z:=0;
        pt.worldraycoord.x := param.ontrackarray.otrackarray[j].worldcoord.x + {pt.tmouse * pv.x}tx;
        pt.worldraycoord.y := param.ontrackarray.otrackarray[j].worldcoord.y + {pt.tmouse * pv.y}ty;
        pt.worldraycoord.z := param.ontrackarray.otrackarray[j].worldcoord.z + {pt.tmouse * pv.z}tz;
          //temp.x:=ontrackarray.otrackarray[j].dmousecoord.x-ontrackarray.otrackarray[j].arraydispaxis.arr[i].dispraycoord.x;
          //temp.y:=ontrackarray.otrackarray[j].dmousecoord.y-ontrackarray.otrackarray[j].arraydispaxis.arr[i].dispraycoord.y;
        temp.x := param.md.glmouse.x - pt.dispraycoord.x;
        temp.y := param.md.glmouse.y - pt.dispraycoord.y {clientheight - param.md.glmouse.y - pt.dispraycoord.y};




        pt.dmouse := round(sqrt(temp.x * temp.x + temp.y * temp.y));
        pt.trace:=false;
        if pt.dmouse < ontracdist then
        begin
        //currentontracdist:=pt.dmouse;
        if (pt.dmouse<lastontracdist) then
        if (param.ospoint.ostype=os_blockinsert)or(param.ospoint.ostype=os_insert)or(param.ospoint.ostype=os_textinsert)or(param.ospoint.ostype=os_none)or(param.ospoint.ostype={os_intersection}os_trace) then
        begin
        if geometry.vertexlen2df(param.ontrackarray.otrackarray[j].dispcoord.x,
                                 param.ontrackarray.otrackarray[j].dispcoord.y,
                                 param.md.glmouse.x,
                                 param.md.glmouse.y)>ontracignoredist then

        begin
          if param.polarlinetrace=0 then
                                        test:=true
                                    else
                                        test:=false;
          if not(test) then
                           begin
                                if not geometry.vertexeq(pt.worldraycoord,param.ospoint.worldcoord)
                                then test:=true;
                           end;
          if test then

          begin
          lastontracdist:=pt.dmouse;
          if pt2<>nil then
                          pt2.trace:=false;
          pt2:=pt;
          pt.trace:=true;
          param.ospoint.worldcoord := pt.worldraycoord;
          param.ospoint.dispcoord := pt.dispraycoord;
          param.ospoint.ostype := {os_polar}{os_midle}{os_intersection}os_trace;
          param.pointnum := j;
          param.axisnum := i;
          //param.ospoint.tmouse:=pt.dmouse;
          inc(param.polarlinetrace);

          param.ontrackarray.otrackarray[j].tmouse:=sqrt(tx*tx+ty*ty+tz*tz);
          end;
        end;
        end;
        end;
        end;
        inc(pt);
        inc(pv);
      end;
   end;
  end;

  lastontracdist:=infinity;
  if param.polarlinetrace>0 then
  for i := a to param.ontrackarray.total - 1 do
  begin
       pt:=param.ontrackarray.otrackarray[i].arraydispaxis.beginiterate(ir2);
       if pt<>nil then
       begin
       repeat
            if pt^.trace then
            begin
            pobj:=PDWG.GetOnMouseObj.beginiterate(ir);
            if pobj<>nil then
            repeat
                  ip:=pobj.IsIntersect_Line(param.ontrackarray.otrackarray[i].worldcoord,pt.worldraycoord);

                  if ip.isintercept then
                  begin
                   PDWG.myGluProject2(ip.interceptcoord,temp);
                  currentontracdist:=vertexlen2df(temp.x, temp.y,param.md.glmouse.x,param.md.glmouse.y);
                  if currentontracdist<lastontracdist then
                  //if currentontracdist<sysvar.DISP.DISP_CursorSize^*sysvar.DISP.DISP_CursorSize^+1 then
                  begin
                  param.ospoint.worldcoord := ip.interceptcoord;
                  param.ospoint.dispcoord := temp;
                  param.ospoint.ostype := {os_polar}os_apparentintersection;
                  lastontracdist:=currentontracdist;
                  end;
                  end;



                  pobj:=PDWG.GetOnMouseObj.iterate(ir);
            until pobj=nil;
            end;
            pt:=param.ontrackarray.otrackarray[i].arraydispaxis.iterate(ir2);
      until pt=nil;
       end;
  end;



  if param.polarlinetrace<2 then exit;
    //lastontracdist:=infinity;

  for i := a to param.ontrackarray.total - 1 do
  for j := i+1 to param.ontrackarray.total - 1 do
  begin
       pt:=param.ontrackarray.otrackarray[i].arraydispaxis.beginiterate(ir);
       if pt<>nil then
       repeat
                     lastontracdist:=infinity;
                     pt2:=param.ontrackarray.otrackarray[j].arraydispaxis.beginiterate(ir2);
                     if pt2<>nil then
                     repeat
                           if (pt.trace)and(pt2.trace) then
                           if SqrOneVertexlength(vectordot(pt.dir,pt2.dir))>sqreps then
                           begin
                           ip:=ip;
                           ip.isintercept:=false;
                           ip:=intercept3dmy2(param.ontrackarray.otrackarray[i].worldcoord,pt.worldraycoord,param.ontrackarray.otrackarray[j].worldcoord,pt2.worldraycoord);
                           //ip:=intercept3dmy(createvertex(0,0,0),createvertex(0,2,0),createvertex(-1,1,0),createvertex(1,1,0));
                                    begin
                                      if ip.isintercept then
                                      begin
                                      PDWG.myGluProject2(ip.interceptcoord,
                                                                       temp);

                                      currentontracdist:=vertexlen2df(temp.x, temp.y,param.md.glmouse.x,param.md.glmouse.y);
                                      if currentontracdist<lastontracdist then
                                      if currentontracdist<sysvar.DISP.DISP_CursorSize^*sysvar.DISP.DISP_CursorSize^+1 then
                                      begin
                                      param.ospoint.worldcoord := ip.interceptcoord;
                                      param.ospoint.dispcoord := temp;
                                      param.ospoint.ostype := {os_polar}os_apparentintersection;
                                      lastontracdist:=currentontracdist;
                                      end;
                                      end;
                                      //param.pointnum := j;
                                      //param.axisnum := i;
                                      //inc(param.polarlinetrace);
                                    end;

                           end;

                           pt2:=param.ontrackarray.otrackarray[j].arraydispaxis.iterate(ir2);
                     until pt2=nil;



             pt:=param.ontrackarray.otrackarray[i].arraydispaxis.iterate(ir);
       until pt=nil;

  end;
end;
function correcttogrid(point:GDBVertex):GDBVertex;
begin
  result.x:=round((point.x-SysVar.DWG.DWG_OriginGrid.x)/SysVar.DWG.DWG_StepGrid.x)*SysVar.DWG.DWG_StepGrid.x+SysVar.DWG.DWG_OriginGrid.x;
  result.y:=round((point.y-SysVar.DWG.DWG_OriginGrid.y)/SysVar.DWG.DWG_StepGrid.y)*SysVar.DWG.DWG_StepGrid.y+SysVar.DWG.DWG_OriginGrid.y;
  result.z:=point.z;
end;
function docorrecttogrid(point:GDBVertex;need:GDBBoolean):GDBVertex;
var
   gr:GDBBoolean;
begin
     gr:=false;
     if SysVar.DWG.DWG_SnapGrid<>nil then
     if SysVar.DWG.DWG_SnapGrid^ then
                                     gr:=true;
     if (need and gr) then
                          begin
                               result.x:=round((point.x-SysVar.DWG.DWG_OriginGrid.x)/SysVar.DWG.DWG_StepGrid.x)*SysVar.DWG.DWG_StepGrid.x+SysVar.DWG.DWG_OriginGrid.x;
                               result.y:=round((point.y-SysVar.DWG.DWG_OriginGrid.y)/SysVar.DWG.DWG_StepGrid.y)*SysVar.DWG.DWG_StepGrid.y+SysVar.DWG.DWG_OriginGrid.y;
                               result.z:=point.z;
                          end
                      else
                          result:=point;
end;

procedure TOGLWND.getosnappoint({pva: PGDBObjEntityOpenArray; }radius: GDBFloat);
var
  pv,pv2:PGDBObjEntity;
  osp:os_record;
  dx,dy:GDBDouble;
//  oldit:itrec;
      ir,ir2:itrec;
  pdata:GDBPointer;
begin
  param.ospoint.radius:=sysvar.DISP.DISP_CursorSize^*sysvar.DISP.DISP_CursorSize^+1;
  param.ospoint.ostype:=os_none;
      if param.md.mouseonworkplan
      then
          begin
               param.ospoint.worldcoord:=param.md.mouseonworkplanecoord;
               if SysVar.DWG.DWG_SnapGrid<>nil then
               if SysVar.DWG.DWG_SnapGrid^ then
               begin
                    param.ospoint.worldcoord:=correcttogrid(param.ospoint.worldcoord);
                    //param.ospoint.worldcoord.x:=round((param.md.mouseonworkplanecoord.x-SysVar.DWG.DWG_OriginGrid.x)/SysVar.DWG.DWG_StepGrid.x)*SysVar.DWG.DWG_StepGrid.x+SysVar.DWG.DWG_OriginGrid.x;
                    //param.ospoint.worldcoord.y:=round((param.md.mouseonworkplanecoord.y-SysVar.DWG.DWG_OriginGrid.y)/SysVar.DWG.DWG_StepGrid.y)*SysVar.DWG.DWG_StepGrid.y+SysVar.DWG.DWG_OriginGrid.y;
                    param.ospoint.ostype:=os_snap;
                    currentmousemovesnaptogrid:=true;
               end;
          end
      else
          begin
               param.ospoint.worldcoord:=param.md.mouseray.lbegin;
          end;

  param.ospoint.PGDBObject:=nil;
  if (param.scrollmode)or(PDWG.GetOnMouseObj.Count=0)then exit;
  if PDWG.GetOnMouseObj.Count>0 then
     begin
     pv:=PDWG.GetOnMouseObj.beginiterate(ir);
     if pv<>nil then
     repeat
     begin
       pv.startsnap(osp,pdata);
       while pv.getsnap(osp,pdata,param,pdwg.myGluProject2) do
       begin
            if osp.ostype<>os_none then
            begin
            dx:=osp.dispcoord.x-param.md.glmouse.x;
            dy:=osp.dispcoord.y-param.md.glmouse.y;
            osp.radius:=dx*dx+dy*dy;
            if osp.ostype<>os_nearest
            then
            begin
                 if param.ospoint.ostype=os_nearest then
                 begin
                      if (osp.radius<sysvar.DISP.DISP_CursorSize^*sysvar.DISP.DISP_CursorSize^+1) then copyospoint(param.ospoint,osp);
                 end
                 else
                 if (osp.radius<=param.ospoint.radius)or(osp.ostype=os_textinsert) then
                                                                                       begin
                                                                                            if (osp.radius<param.ospoint.radius) then
                                                                                                                                     begin
                                                                                                                                     if osp.ostype<param.ospoint.ostype then
                                                                                                                                          copyospoint(param.ospoint,osp)

                                                                                                                                     end
                                                                                       else
                                                                                           if (osp.ostype<>os_perpendicular) then
                                                                                                                                     copyospoint(param.ospoint,osp)
                                                                                       end;
            end
            else
            begin
                 if (osp.radius<sysvar.DISP.DISP_CursorSize^*sysvar.DISP.DISP_CursorSize^+1)and(param.ospoint.ostype=os_none) then copyospoint(param.ospoint,osp)
                 else if param.ospoint.ostype=os_nearest then
                                                            if {(osp.radius<sysvar.DISP.DISP_CursorSize^*sysvar.DISP.DISP_CursorSize^+1)and}(osp.radius<param.ospoint.radius) then
                                                                                                   copyospoint(param.ospoint,osp);
            end;
            end;
       end;
       pv.endsnap(osp,pdata);
     end;
     pv:=PDWG.GetOnMouseObj.iterate(ir);
     until pv=nil;
     end;
  if ((sysvar.dwg.DWG_OSMode^ and osm_apparentintersection)<>0)or((sysvar.dwg.DWG_OSMode^ and osm_intersection)<>0)then
  begin
  if (PDWG.GetOnMouseObj.Count>1)and(PDWG.GetOnMouseObj.Count<10) then
  begin
  pv:=PDWG.GetOnMouseObj.beginiterate(ir);
  repeat
  if pv<>nil then
  begin
  pv2:=PDWG.GetOnMouseObj.beginiterate(ir2);
  if pv2<>nil then
  repeat
  if pv<>pv2 then
  begin
       pv.startsnap(osp,pdata);
       while pv.getintersect(osp,pv2,param,PDWG.myGluProject2) do
       begin
            if osp.ostype<>os_none then
            begin
            dx:=osp.dispcoord.x-param.md.glmouse.x;
            dy:=osp.dispcoord.y-param.md.glmouse.y;
            osp.radius:=dx*dx+dy*dy;
            begin
                 if param.ospoint.ostype=os_nearest then
                 begin
                      if (osp.radius<sysvar.DISP.DISP_CursorSize^*sysvar.DISP.DISP_CursorSize^+1) then copyospoint(param.ospoint,osp);
                 end
                 else
                 //if (osp.radius<param.ospoint.radius) then copyospoint(param.ospoint,osp);
                 if param.ospoint.ostype=os_none        then copyospoint(param.ospoint,osp);

            end
            end;
       end;
       pv.endsnap(osp,pdata);
  end;
  pv2:=PDWG.GetOnMouseObj.iterate(ir2);
  until pv2=nil;
  end;
  pv:=PDWG.GetOnMouseObj.iterate(ir);
  until pv=nil;
  end;
  end;
end;
procedure TOGLWND.delmyscrbuf;
var i:integer;
begin
     for I := 0 to high(tmyscrbuf) do
       begin
             if myscrbuf[i]<>0 then
                                   oglsm.mygldeletetextures(1,@myscrbuf[i]);
             myscrbuf[i]:=0;
       end;

end;
procedure TOGLWND.CreateScrbuf(w,h:integer);
var scrx,scry,texture{,e}:integer;
begin
     //oglsm.mytotalglend;

     oglsm.myglEnable(GL_TEXTURE_2D);
     scrx:=0;  { TODO : Сделать генер текстур пакетом }
     scry:=0;
     texture:=0;
     repeat
           repeat
                 //if texture>80 then texture:=0;

                 oglsm.myglGenTextures(1, @myscrbuf[texture]);
                 //isOpenGLError;
                 oglsm.myglbindtexture(GL_TEXTURE_2D,myscrbuf[texture]);
                 //isOpenGLError;
                 oglsm.myglTexImage2D(GL_TEXTURE_2D,0,GL_RGB,texturesize,texturesize,0,GL_RGB,GL_UNSIGNED_BYTE,@TOGLWND.CreateScrbuf);
                 //isOpenGLError;
                 oglsm.myglTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
                 //isOpenGLError;
                 oglsm.myglTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
                 //isOpenGLError;
                 scrx:=scrx+texturesize;
                 inc(texture);
           until scrx>w;
           scrx:=0;
           scry:=scry+texturesize;
     until scry>h;
     oglsm.myglDisable(GL_TEXTURE_2D);
end;

procedure TOGLWnd._onresize;
begin
  {if  (param.height<>clientheight)
    or(param.width<>clientwidth)
  then}
  begin

  self.MakeCurrent(false);
  param.lastonmouseobject:=nil;

  //self.MakeCurrent(false);
  //isOpenGLError;

  delmyscrbuf;
  calcoptimalmatrix;
  calcgrid;

  {переделать}//inherited size{(fwSizeType,nWidth,nHeight)};

  CreateScrbuf(clientwidth,clientheight);

  {param.md.glmouse.y := clientheight-param.md.mouse.y;
  CalcOptimalMatrix;
  mouseunproject(param.md.GLmouse.x, param.md.GLmouse.y);
  CalcMouseFrustum;}

  if param.pglscreen <> nil then
  GDBFreeMem(param.pglscreen);
  GDBGetMem({$IFDEF DEBUGBUILD}'ScreenBuf',{$ENDIF}param.pglscreen, clientwidth * clientheight * 4);

  param.height := clientheight;
  param.width := clientwidth;
  param.firstdraw := true;
  //draw;
  //paint;
  self.Invalidate;

  end;
end;
destructor TOGLWnd.Destroy;
var
   i:integer;
begin
     delmyscrbuf;
     if param.pglscreen <> nil then
     GDBFreeMem(param.pglscreen);
     MywglDeleteContext(OGLContext);//wglDeleteContext(hrc);
     PolarAxis.done;
     if param.pglscreen<>nil then
     gdbfreemem(param.pglscreen);
     param.ospoint.arraydispaxis.done;
     param.ospoint.arrayworldaxis.done;
     for i := 0 to {param.ontrackarray.total-1}3 do
                                              begin
                                              param.ontrackarray.otrackarray[i].arrayworldaxis.done;
                                              param.ontrackarray.otrackarray[i].arraydispaxis.done;
                                              end;
     {переделать}//inherited done;
     inherited;
end;
procedure TOGLWnd.BeforeInit;
var i: GDBInteger;
    v:gdbvertex;
begin
  self.OnResize:=_onresize;

  PDWG:=nil;

  fillchar(myscrbuf,sizeof(tmyscrbuf),0);

  //PDWG.Getpcamera^.prop.zoom := 0.1;
  param.projtype := Projparalel;
  //param.subrender := 0;
  param.firstdraw := true;
  param.SelDesc.OnMouseObject := nil;
  param.lastonmouseobject:=nil;
  param.SelDesc.LastSelectedObject := nil;
  param.pglscreen := nil;
  param.gluetocp := false;
  param.cpdist.cpnum := -1;
  param.cpdist.cpdist := 99999;
  SetMouseMode((MGetControlpoint) or (MGetSelectObject) or (MMoveCamera) or (MRotateCamera) or (MGetSelectionFrame));
  param.seldesc.MouseFrameON := false;
  param.otracktimerwork := 0;
  param.ontrackarray.total := 1;
  param.ontrackarray.current := 1;
  param.md.workplane{.normal.x}[0] := 0;
  param.md.workplane{.normal.y}[1] := {sqrt(0.1)}0;
  param.md.workplane{.normal.z}[2] := {sqrt(0.9)}1;
  param.md.workplane{.d}[3] := 0;
  param.scrollmode:=false;
  param.md.mousein:=false;
  param.processObjConstruct:=false;
  param.ShowDebugBoundingBbox:=false;
  param.ShowDebugFrustum:=false;
  param.CSIcon.AxisLen:=0;
  param.CSIcon.CSIconCoord:=nulvertex;
  param.CSIcon.CSIconX:=nulvertex;
  param.CSIcon.CSIconY:=nulvertex;
  param.CSIcon.CSIconZ:=nulvertex;
  //UGDBDescriptor.POGLWnd := @param;

  {gdb.GetCurrentDWG.pcamera.initnul;
  gdb.GetCurrentDWG.pcamera.fovy:=35.0;
  gdb.GetCurrentDWG.pcamera.point.x:=0.0;
  gdb.GetCurrentDWG.pcamera.point.y:=0.0;
  gdb.GetCurrentDWG.pcamera.point.z:=50.0;
  gdb.GetCurrentDWG.pcamera.look.x:=0.0;
  gdb.GetCurrentDWG.pcamera.look.y:=0.0;
  gdb.GetCurrentDWG.pcamera.look.z:=-1.0;
  gdb.GetCurrentDWG.pcamera.ydir.x:=0.0;
  gdb.GetCurrentDWG.pcamera.ydir.y:=1.0;
  gdb.GetCurrentDWG.pcamera.ydir.z:=0.0;
  gdb.GetCurrentDWG.pcamera.xdir.x:=-1.0;
  gdb.GetCurrentDWG.pcamera.xdir.y:=0.0;
  gdb.GetCurrentDWG.pcamera.xdir.z:=0.0;
  gdb.GetCurrentDWG.pcamera.anglx:=-3.14159265359;
  gdb.GetCurrentDWG.pcamera.angly:=-1.570796326795;
  gdb.GetCurrentDWG.pcamera.zmin:=1.0;
  gdb.GetCurrentDWG.pcamera.zmax:=100000.0;
  gdb.GetCurrentDWG.pcamera.fovy:=35.0;}


  PolarAxis.init({$IFDEF DEBUGBUILD}'{5AD9927A-0312-4844-8C2D-9498647CCECB}',{$ENDIF}10);

  for i := 0 to 4 - 1 do
  begin
    v.x:=cos(pi * i / 4);
    v.y:=sin(pi * i / 4);
    v.z:=0;
    PolarAxis.add(@v);
  end;

  param.ontrackarray.otrackarray[0].arrayworldaxis.init({$IFDEF DEBUGBUILD}'{8BE71BAA-507B-4D6B-BE2C-63693022090C}',{$ENDIF}10);
  param.ontrackarray.otrackarray[0].arraydispaxis.init({$IFDEF DEBUGBUILD}'{722A886F-5616-4E8F-B94D-3A1C3D7ADBD4}',{$ENDIF}10);
  tocommandmcliccount:=0;


  for i := 0 to 3 do
                  begin
                  param.ontrackarray.otrackarray[i].arrayworldaxis.init({$IFDEF DEBUGBUILD}'{722A886F-5616-4E8F-B94D-3A1C3D7ADBD4}',{$ENDIF}10);
                  param.ontrackarray.otrackarray[i].arrayworldaxis.CreateArray;
                  param.ontrackarray.otrackarray[i].arraydispaxis.init({$IFDEF DEBUGBUILD}'{722A886F-5616-4E8F-B94D-3A1C3D7ADBD4}',{$ENDIF}10);
                  param.ontrackarray.otrackarray[i].arraydispaxis.CreateArray;
                  end;
  

  param.ospoint.arraydispaxis.init({$IFDEF DEBUGBUILD}'{722A886F-5616-4E8F-B94D-3A1C3D7ADBD4}',{$ENDIF}10);
  param.ospoint.arrayworldaxis.init({$IFDEF DEBUGBUILD}'{722A886F-5616-4E8F-B94D-3A1C3D7ADBD4}',{$ENDIF}10);

  if PDWG<>nil then
  begin
  PDWG.Getpcamera^.obj_zmax:=-1;
  PDWG.Getpcamera^.obj_zmin:=100000;
  //CalcOptimalMatrix;
  end;
  initogl;
end;

procedure TOGLWnd.setdeicevariable;
var a:array [0..1] of GDBDouble;
    p:pansichar;
begin
  programlog.logoutstr('TOGLWnd.SetDeiceVariable',lp_IncPos);
  oglsm.myglGetDoublev(GL_LINE_WIDTH_RANGE,@a);
  sysvar.RD.RD_MaxLineWidth^:=a[1];
  oglsm.myglGetDoublev(GL_point_size_RANGE,@a);
  sysvar.RD.RD_MaxPointSize^:=a[1];
  GDBPointer(p):=oglsm.myglGetString(GL_VENDOR);
  programlog.logoutstr('RD_Vendor:='+p,0);
  sysvar.RD.RD_Vendor^:=p;
  GDBPointer(p):=oglsm.myglGetString(GL_RENDERER);
  programlog.logoutstr('RD_Renderer:='+p,0);
  sysvar.RD.RD_Renderer^:=p;
  GDBPointer(p):=oglsm.myglGetString(GL_VERSION);
  programlog.logoutstr('RD_Version:='+p,0);
  sysvar.RD.RD_Version^:=p;
  sysvar.RD.RD_MaxWidth^:=round(min(sysvar.RD.RD_MaxPointSize^,sysvar.RD.RD_MaxLineWidth^));
  programlog.logoutstr('RD_MaxWidth:='+inttostr(sysvar.RD.RD_MaxWidth^),0);
  programlog.logoutstr('end;',lp_DecPos);
end;

procedure TOGLWnd.initogl;
{$IFDEF LCLGTK2}var Widget: PGtkWidget;{$ENDIF}
begin
  programlog.logoutstr('TOGLWnd.InitOGL',lp_IncPos);

  {$IFDEF LCLGTK2}
  Widget:=PGtkWidget(PtrUInt(Handle));
  gtk_widget_add_events (Widget,GDK_POINTER_MOTION_HINT_MASK);


  {FastMMX:=XPending(GDK_WINDOW_XDISPLAY(PGtkWidget(Widget)^.window));
  if sysvar.debug.memi2<fastmmx then
                                    sysvar.debug.memi2:=fastmmx;
  if FastMMX=0 then}{$ENDIF}




  //------------------------------------------------------------------------releaseDC(dc,self.Handle{handle}{thdc});
  MywglDeleteContext(OGLContext);//wglDeleteContext(hrc);

  //------------------------------------------------------------------------
  //------------------------------------------------------------------------OGLcontext.DC := {GetDC(Handle)}canvas.handle;
  //------------------------------------------------------------------------

  SetDCPixelFormat(OGLContext);//SetDCPixelFormat(dc);
  MywglCreateContext(OGLContext);//hrc := wglCreateContext(DC);
  MyglMakeCurrent(OGLContext);//wglMakeCurrent(DC, hrc);
  self.MakeCurrent();
  setdeicevariable;


  //Pointer(@wglSwapIntervalEXT) := wglGetProcAddress('wglSwapIntervalEXT');
  //wglSwapIntervalEXT(0);

  {$IFDEF WINDOWS}
  if SysVar.RD.RD_VSync^<>TVSDefault then
  begin
       Pointer(@wglSwapIntervalEXT) := wglGetProcAddress('wglSwapIntervalEXT');
       if @wglSwapIntervalEXT<>nil then
                                           begin
                                                if SysVar.RD.RD_VSync^=TVSOn then
                                                                                 wglSwapIntervalEXT(1)
                                                                             else
                                                                                 wglSwapIntervalEXT(0);
                                           end
                                       else
                                           begin
                                                shared.LogError('wglSwapIntervalEXT not supported by your video driver. Please set the VSync in the defaul');
                                           end;
  end;
  {$ENDIF}
  //CalcOptimalMatrix;
  programlog.logoutstr('end;',lp_DecPos)
end;
{function TOGLWnd.mousein;
begin
  mousein := true;
  if (MousePos.x > clientwidth)
    or (MousePos.y > clientheight)
    or (MousePos.x < 0)
    or (MousePos.y < 0) then
    mousein := false;
end;}
function getsortedindex(cl:integer):integer;
var i:integer;
    s:string;
begin
     {s:=(pGDBLayerProp(gdb.GetCurrentDWG.LayerTable.getelement(cl))^.GetFullName);
     for i:=0 to layerbox.ItemsCount-1 do
     if layerbox.Item[i].Name=s then
     begin
          result:=i;
          exit;
     end;
     result:=0;}
end;

{procedure TOGLWnd.Pre_KeyDown;
begin
if ch = #46 then
  begin
    commandmanager.ExecuteCommand('Erase');
    r.handled:=true;
  end
end;}
procedure TOGLWnd.myKeyPress(var Key: Word; Shift: TShiftState);
{$IFDEF DELPHI}
const
     VK_V=$56;
{$ENDIF}
begin
      if Key=VK_ESCAPE then
      begin
        if assigned(ReStoreGDBObjInspProc)then
        begin
        if not ReStoreGDBObjInspProc then
        begin
        ClearOntrackpoint;
        if commandmanager.pcommandrunning=nil then
          begin
          PDWG.GetCurrentROOT.ObjArray.DeSelect(PDWG^.GetSelObjArray,param.SelDesc.Selectedobjcount);
          param.SelDesc.LastSelectedObject := nil;
          param.SelDesc.OnMouseObject := nil;
          param.seldesc.Selectedobjcount:=0;
          param.firstdraw := TRUE;
          PDWG.GetSelObjArray.clearallobjects;
          CalcOptimalMatrix;
          paint;
          if assigned(SetVisuaProplProc) then SetVisuaProplProc;
          setobjinsp;
          end
        else
          begin
               commandmanager.pcommandrunning.CommandCancel;
               commandmanager.executecommandend;
          end;
        end;
        end;
        Key:=0;
      end
 {else if (Key = VK_A) and (shift=[ssCtrl]) then
      begin
        commandmanager.ExecuteCommand('SelectAll');
        Key:=00;
      end}
 {else if (Key = VK_Z) and (shift=[ssCtrl]) then
      begin
        commandmanager.ExecuteCommand('Undo');
        Key:=00;
      end}
  {else if (Key = VK_Z) and (shift=[ssCtrl,ssShift]) then
      begin
        commandmanager.ExecuteCommand('Redo');
        Key:=00;
      end}
 {else if (Key = VK_DELETE) then
      begin
        commandmanager.ExecuteCommand('Erase');
        Key:=00;
      end}
 else if Key = VK_RETURN then
      begin
           commandmanager.executelastcommad(pdwg);
           Key:=00;
      end
 else if (Key=VK_V)and(shift=[ssctrl]) then
                    begin
                         commandmanager.executecommand('PasteClip',pdwg);
                         key:=00;
                    end
 (*else if (Key=VK_TAB)and(shift=[ssctrl,ssShift]) then
                          begin
                               //if assigned(MainFormN.PageControl)then
                               //   if MainFormN.PageControl.PageCount>1 then
                                  begin
                                       commandmanager.executecommandsilent('PrevDrawing');
                                       key:=00;
                                  end;
                          end
 else if (Key=VK_TAB)and(shift=[ssctrl]) then
                          begin
                               //if assigned(MainFormN.PageControl)then
                               //   if MainFormN.PageControl.PageCount>1 then
                                  begin
                                       commandmanager.executecommandsilent('NextDrawing');
                                       key:=00;
                                  end;
                          end*)
end;
function TOGLWnd.ProjectPoint(pntx,pnty,pntz:gdbdouble;var wcsLBN,wcsRTF,dcsLBN,dcsRTF: GDBVertex):gdbvertex;
begin
     PDWG.myGluProject2(CreateVertex(pntx,pnty,pntz),
     result);


     if result.x<dcsLBN.x then
                              begin
                                   dcsLBN.x:=result.x;
                                   wcsLBN.x:=pntx;
                              end;
     if result.y<dcsLBN.y then
                              begin
                                   dcsLBN.y:=result.y;
                                   wcsLBN.y:=pnty;
                              end;
     if result.z<dcsLBN.z then
                              begin
                                   dcsLBN.z:=result.z;
                                   wcsLBN.z:=pntz;
                              end;
     if result.x>dcsRTF.x then
                              begin
                                   dcsRTF.x:=result.x;
                                   wcsRTF.x:=pntx;
                              end;
     if result.y>dcsRTF.y then
                              begin
                                   dcsRTF.y:=result.y;
                                   wcsRTF.y:=pnty;
                              end;
     if result.z>dcsRTF.z then
                              begin
                                   dcsRTF.z:=result.z;
                                   wcsRTF.z:=pntz;
                              end;
end;
(*procedure TOGLWnd.Pre_LBMouseDblClk;
//var s:GDBString;
begin
     r.handled:=true;
     if (param.seldesc.Selectedobjcount<>1)or(param.SelDesc.OnMouseObject=nil)  then exit;
     if (PGDBObjEntity(param.SelDesc.OnMouseObject)^.vp.ID=GDBtextID) then
     begin
          {Tedform.all_ok:=false;
          Tedform.EditTemplate.Text:= PGDBObjText(param.SelDesc.OnMouseObject)^.Template;
          Tedform.EditTemplate.SelectAll;
          //Tedform.EditTemplate.SetFocus;
          Tedform.showmodal;
          if Tedform.all_ok then
          begin
               PGDBObjText(param.SelDesc.OnMouseObject)^.Template:=Tedform.EditTemplate.Text;
               PGDBObjText(param.SelDesc.OnMouseObject)^.Format;
               param.firstdraw := TRUE;
               loadmatrix;
               paint;
          end}
     end
else if (PGDBObjEntity(param.SelDesc.OnMouseObject)^.vp.ID=GDBMtextID) then
     begin
          {MTedform.all_ok:=false;
          s:=PGDBObjMText(param.SelDesc.OnMouseObject)^.Template;
          replaceeqlen(s,'\P',#$D#$A);
          MTedform.RichEdit1.Text:=s;
          //MTedform.RichEdit1.SelectAll;
          //Tedform.EditTemplate.SetFocus;
          MTedform.showmodal;
          if MTedform.all_ok then
          begin
               s:=MTedform.RichEdit1.Text;
               replaceeqlen(s,#$D#$A,'\P');
               PGDBObjText(param.SelDesc.OnMouseObject)^.Template:=s;
               PGDBObjText(param.SelDesc.OnMouseObject)^.Format;
               param.firstdraw := TRUE;
               loadmatrix;
               paint;
          end}
     end;
end;*)
procedure TOGLWnd.CalcMouseFrustum;
var
  tm: DMatrix4D;
  td:gdbdouble;
begin
  td:=sysvar.DISP.DISP_CursorSize^*2;
  param.mousefrustum   :=CalcDisplaySubFrustum(param.md.glmouse.x,param.md.glmouse.y,td,td,PDWG.Getpcamera.modelMatrix,PDWG.Getpcamera.projMatrix,PDWG.Getpcamera.viewport);
  param.mousefrustumLCS:=CalcDisplaySubFrustum(param.md.glmouse.x,param.md.glmouse.y,td,td,PDWG.Getpcamera.modelMatrixLCS,PDWG.Getpcamera.projMatrixLCS,PDWG.Getpcamera.viewport);
  exit;
  {
  tm:=lookat(param.md.mouseray.lbegin,
             gdb.GetCurrentDWG.pcamera^.xdir,
             gdb.GetCurrentDWG.pcamera^.ydir,
             normalizevertex(param.md.mouseray.dir),@onematrix);
  if param.projtype = ProjParalel then
                                      begin

                                      param.mouseclipmatrix:=ortho(-sysvar.DISP.DISP_CursorSize^*param.zoom*2,sysvar.DISP.DISP_CursorSize^*param.zoom*2,
                                                                   -sysvar.DISP.DISP_CursorSize^*param.zoom*2,sysvar.DISP.DISP_CursorSize^*param.zoom*2,
                                                                   gdb.GetCurrentDWG.pcamera^.zmin, gdb.GetCurrentDWG.pcamera^.zmax,@onematrix);
                                      param.mouseclipmatrix:=MatrixMultiply(tm,param.mouseclipmatrix);
                                      param.mousefrustum:=calcfrustum(@param.mouseclipmatrix);
                                      end;

}
  oglsm.myglMatrixMode(GL_Projection);
  oglsm.myglpushmatrix;
  oglsm.myglLoadIdentity;
  oglsm.mygluPickMatrix(param.md.glmouse.x, {gdb.GetCurrentDWG.pcamera^.viewport[3]-} param.md.glmouse.y, sysvar.DISP.DISP_CursorSize^ * 2, sysvar.DISP.DISP_CursorSize^ * 2, PTViewPortArray(@PDWG.Getpcamera^.viewport)^);
  {if param.projtype = ProjParalel then
                                      begin
                                      gdb.GetCurrentDWG.pcamera^.projMatrix:=ortho(-clientwidth*param.zoom/2,clientwidth*param.zoom/2,
                                                                                 -clientheight*param.zoom/2,clientheight*param.zoom/2,
                                                                                 gdb.GetCurrentDWG.pcamera^.zmin, gdb.GetCurrentDWG.pcamera^.zmax,@onematrix);
                                      end
                                  else
                                      BEGIN
                                           if gdb.GetCurrentDWG.pcamera^.zmin<eps then gdb.GetCurrentDWG.pcamera^.zmin:=10;
                                           gdb.GetCurrentDWG.pcamera^.projMatrix:=Perspective(gdb.GetCurrentDWG.pcamera^.fovy, Width / Height, gdb.GetCurrentDWG.pcamera^.zmin, gdb.GetCurrentDWG.pcamera^.zmax,@onematrix);
                                        end;}
  oglsm.myglGetDoublev(GL_PROJECTION_MATRIX, @tm);
  param.mouseclipmatrix := MatrixMultiply(PDWG.Getpcamera^.projMatrix, tm);
  param.mouseclipmatrix := MatrixMultiply(PDWG.Getpcamera^.modelMatrix, param.mouseclipmatrix);
  param.mousefrustum := calcfrustum(@param.mouseclipmatrix);
  oglsm.myglpopmatrix;
  oglsm.myglMatrixMode(GL_MODELVIEW);
end;
{procedure startup;
begin
  creategrid;
  readpalette;
end;
procedure finalize;
begin
end;}
begin
  {$IFDEF DEBUGINITSECTION}LogOut('oglwindow.initialization');{$ENDIF}
  creategrid;
  //readpalette;
end.

