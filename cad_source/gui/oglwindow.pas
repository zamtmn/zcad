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


  {$IFDEF LCLGTK2}
  //x,xlib,{x11,}{xutil,}
  gtk2,gdk2,{gdk2x,}
  {$ENDIF}

  UGDBOpenArrayOfPV,UGDBSHXFont,LCLType,InterfaceBase,
  umytreenode,menus,Classes,{ SysUtils,} FileUtil,{ LResources,LMessages,} Forms,
  {stdctrls,} ExtCtrls, ComCtrls,{Toolwin,} Controls, {Graphics, Dialogs,}
  GDBGenericSubEntry,gdbasetypes,{Windows,}sysutils,
  gl,glu,{glx,}OpenGLContext,
  Math,gdbase,varmandef,varman,UUnitManager,
  oglwindowdef,

  GDBHelpObj,
  commandline,

  zglline3d,

  sysinfo,
  //strmy,
  UGDBVisibleOpenArray,
  UGDBPoint3DArray,
  strproc,{GDBCamera,UGDBOpenArrayOfPV,}OGLSpecFunc{,zoglforms,ZEditsWithProcedure,ZComboBoxsWithProc,ZStaticSText}{,zbasicvisible},memman,
  log{,zguisct}{,TypeDescriptors,UGDBOpenArrayOfByte,ZTabControlsGeneric},UGDBEntTree;
const

  ontracdist=10;
  ontracignoredist=25;
  texturesize=128;
  maxmybufer=99;
type
  tmyscrbuf = array [0..maxmybufer] of GLuint;
  PTOGLWnd = ^TOGLWnd;

  { TOGLWnd }

  TOGLWnd = class({TPanel}TOpenGLControl)
  private
    OGLContext:TOGLContextDesk;
    {hrc:thandle;
    dc:HDC;
    thdc:HDC;}
    procedure CalcMouseFrustum;
  public
    OTTimer:TTimer;
    //OMMTimer:TTimer;
    PolarAxis:GDBPoint3dArray;
    param: OGLWndtype;

    PDWG:GDBPointer;

    tocommandmcliccount:GDBInteger;

    myscrbuf:tmyscrbuf;

    FastMMShift: TShiftState;
    FastMMX,FastMMY: Integer;

    //procedure keydown(var Key: GDBWord; Shift: TShiftState);
    //procedure dock(Sender: TObject; Source: TDragDockObject; X, Y: GDBInteger;State: TDragState; var Accept: GDBBoolean);

    procedure init;virtual;
    procedure DrawGrid;
    procedure beforeinit;virtual;
    procedure initogl;
    procedure AddOntrackpoint;
    procedure Project0Axis;

    procedure render(const Root:GDBObjGenericSubEntry);
    function treerender(var Node:TEntTreeNode;StartTime:TDateTime):GDBBoolean;

    procedure getosnappoint(pva: PGDBObjEntityOpenArray;radius: GDBFloat);
    procedure set3dmouse;
    procedure DISP_ZoomFactor(x: double{; MousePos: TPoint});
    //function mousein(MousePos: TPoint): GDBBoolean;
    procedure mouseunproject(X, Y: glint);
    procedure CorrectMouseAfterOS;
    procedure getonmouseobject(pva: PGDBObjEntityOpenArray);
    procedure getonmouseobjectbytree(Node:TEntTreeNode);
    procedure processmousenode(Node:TEntTreeNode;var i:integer);
    function findonmobj(pva: PGDBObjEntityOpenArray;var i: GDBInteger): GDBInteger;
    procedure SetOTrackTimer(Sender: TObject);
    procedure KillOTrackTimer(Sender: TObject);
    procedure ProcOTrackTimer(Sender:TObject);
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
    procedure setvisualprop;
    procedure addoneobject;
    procedure setdeicevariable;
    procedure SetObjInsp;

    procedure draw;virtual;
    procedure drawdebuggeometry;
    procedure finishdraw;virtual;
    procedure SaveBuffers;virtual;
    procedure RestoreBuffers;virtual;
    procedure showcursor;
    procedure LightOn;
    procedure LightOff;
    procedure startrender;
    procedure endrender;
    procedure mypaint(sender:tobject);
    procedure mypaint2(sender:tobject;var f:boolean);

    //procedure Pre_KeyDown(ch:char; var r:HandledMsg);virtual;
    //procedure Pre_LBMouseDblClk(fwkeys:longint;x,y:GDBInteger; var r:HandledMsg);virtual;

    procedure SetMouseMode(smode:GDBByte);

    procedure _onresize(sender:tobject);virtual;
    destructor Destroy; override;


    procedure delmyscrbuf;
    procedure CreateScrbuf(w,h:integer);

    procedure GDBActivate;

    procedure _onMouseMove(sender:tobject;Shift: TShiftState; X, Y: Integer);
    procedure _onFastMouseMove(sender:tobject;Shift: TShiftState; X, Y: Integer);
    procedure asynczoomall(Data: PtrInt);
    procedure ZoomAll;
    procedure myKeyPress(var Key: Word; Shift: TShiftState);

    procedure addaxistootrack(var posr:os_record;const axis:GDBVertex);

    {LCL}
    protected
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;X, Y: Integer);override;
    procedure MouseUp(Button: TMouseButton; Shift:TShiftState;X, Y: Integer);override;
    function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer;MousePos: TPoint): Boolean;override;
    procedure EraseBackground(DC: HDC);override;

    procedure FormCreate(Sender: TObject);

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
  fps:single;
  gridarray:array [0..maxgrid,0..maxgrid] of GDBvertex2S;
//function timeSetEvent(uDelay, uReolution: UINT; lpTimeProc: GDBPointer;dwUser: DWord; fuEvent: UINT): GDBInteger; stdcall; external 'winmm';
//function timeKillEvent(uID: UINT): GDBInteger; stdcall; external 'winmm';

{procedure startup;
procedure finalize;}

function ProjectPoint(pntx,pnty,pntz:gdbdouble;var wcsLBN,wcsRTF,dcsLBN,dcsRTF: GDBVertex):gdbvertex;
procedure textwrite(s: GDBString);
implementation
uses GDBText,mainwindow,UGDBTracePropArray,GDBEntity,io,geometry,gdbobjectsconstdef,UGDBDescriptor,
     {GDBCommandsBase,}Objinsp{,Tedit_form, MTedit_form},shared,sharedgdb,UGDBLayerArray,cmdline;
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
procedure TOGLWnd.startrender;
begin
     middlepoint:=nulvertex;
     pointcount:=0;
     primcount:=0;
     bathcount:=0;
end;
procedure TOGLWnd.endrender;
begin
    //sysvar.debug.renderdeb.middlepoint:=middlepoint;
    sysvar.debug.renderdeb.pointcount:=pointcount;
    sysvar.debug.renderdeb.primcount:=primcount;
    sysvar.debug.renderdeb.bathcount:=bathcount;
     if pointcount<>0 then
                          sysvar.debug.renderdeb.middlepoint:=geometry.VertexMulOnSc(middlepoint,1/pointcount);
end;

procedure TOGLWnd.EraseBackground(DC: HDC);
begin
     dc:=0;
end;
procedure TOGLWnd.mypaint;
begin
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

     onpaint:=mypaint;
     //Application.AddOnIdleHandler(mypaint2);
     //=====-----------------------------------------------------------------------------------------
     //onmousemove:=_onMouseMove;
     onmousemove:=_onFastMouseMove;
     //RGBA:=true;
     //dc:=GetDeviceContext(thdc);
     beforeinit;
     self.Cursor:=crNone;
     OTTimer:=TTimer.create(self);
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
  gdb.GetCurrentDWG^.myGluProject2(param.ontrackarray.otrackarray[0
    ].worldcoord,
             param.ontrackarray.otrackarray[0].dispcoord);
  //param.ontrackarray.otrackarray[0].arraydispaxis.init({$IFDEF DEBUGBUILD}'{722A886F-5616-4E8F-B94D-3A1C3D7ADBD4}', {$ENDIF}    param.ontrackarray.otrackarray[0].arrayworldaxis.count);
  param.ontrackarray.otrackarray[0].arraydispaxis.clear;
  //GDBGetMem(param.ospoint.arraydispaxis, sizeof(GDBWord) +param.ospoint.arrayworldaxis.count * sizeof(traceprop));
  //param.ospoint.arraydispaxis.count := param.ospoint.arrayworldaxis.count;
  pv:=param.ontrackarray.otrackarray[0].arrayworldaxis.PArray;
  for i := 0 to param.ontrackarray.otrackarray[0].arrayworldaxis.count - 1 do
  begin
    gdb.GetCurrentDWG^.myGluProject2(createvertex(param.ontrackarray.otrackarray
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
  glViewport(0, 0, clientWidth, clientHeight);
  glGetIntegerv(GL_VIEWPORT, @gdb.GetCurrentDWG.pcamera^.viewport);

  oglsm.myglMatrixMode(GL_MODELVIEW);
  glLoadMatrixD(@gdb.GetCurrentDWG.pcamera^.modelMatrixLCS);

  oglsm.myglMatrixMode(GL_PROJECTION);
  glLoadMatrixD(@gdb.GetCurrentDWG.pcamera^.projMatrixLCS);

  oglsm.myglMatrixMode(GL_MODELVIEW);


  gdb.GetCurrentDWG.pcamera.getfrustum(@gdb.GetCurrentDWG.pcamera^.modelMatrix,   @gdb.GetCurrentDWG.pcamera^.projMatrix,   gdb.GetCurrentDWG.pcamera^.clip,   gdb.GetCurrentDWG.pcamera^.frustum);
  gdb.GetCurrentDWG.pcamera.getfrustum(@gdb.GetCurrentDWG.pcamera^.modelMatrixLCS,@gdb.GetCurrentDWG.pcamera^.projMatrixLCS,gdb.GetCurrentDWG.pcamera^.clipLCS,gdb.GetCurrentDWG.pcamera^.frustumLCS);

end;
procedure TOGLWnd.CalcOptimalMatrix;
var ccsLBN,ccsRTF:GDBVertex;
    tm:DMatrix4D;
    LBN:GDBvertex;(*'ЛевыйНижнийБлижний'*)
    RTF:GDBvertex;
    tbb,tbb2:GDBBoundingBbox;
    pdwg:PTDrawing;
    proot:PGDBObjGenericSubEntry;
begin
  {$IFDEF PERFOMANCELOG}log.programlog.LogOutStrFast('TOGLWnd.CalcOptimalMatrix',lp_IncPos);{$ENDIF}
  {Если нет примитивов выходим}
  pdwg:=gdb.GetCurrentDWG;
  proot:=gdb.GetCurrentROOT;

  if (assigned(pdwg))and(assigned(proot))then
  begin
  pdwg.pcamera^.modelMatrix:=lookat(pdwg.pcamera^.prop.point,
                                               pdwg.pcamera^.prop.xdir,
                                               pdwg.pcamera^.prop.ydir,
                                               pdwg.pcamera^.prop.look,@onematrix);
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
  if pdwg.ConstructObjRoot.ObjArray.Count>0 then
                       begin
  pdwg.ConstructObjRoot.calcbb;
  tbb2:=pdwg.ConstructObjRoot.vp.BoundingBox;
  ConcatBB(tbb,tbb2);
  end;

  if IsBBNul(tbb) then
  begin
       tbb.LBN:=geometry.VertexAdd(pdwg.pcamera^.prop.point,MinusOneVertex);
       tbb.RTF:=geometry.VertexAdd(pdwg.pcamera^.prop.point,OneVertex);
  end;

  LBN:=tbb.LBN;
  RTF:=tbb.RTF;

  ProjectPoint2(LBN.x,LBN.y,LBN.Z,pdwg.pcamera^.modelMatrix,ccsLBN,ccsRTF);
  ProjectPoint2(RTF.x,LBN.y,LBN.Z,pdwg.pcamera^.modelMatrix,ccsLBN,ccsRTF);
  ProjectPoint2(RTF.x,RTF.y,LBN.Z,pdwg.pcamera^.modelMatrix,ccsLBN,ccsRTF);
  ProjectPoint2(LBN.x,RTF.y,LBN.Z,pdwg.pcamera^.modelMatrix,ccsLBN,ccsRTF);
  ProjectPoint2(LBN.x,LBN.y,RTF.Z,pdwg.pcamera^.modelMatrix,ccsLBN,ccsRTF);
  ProjectPoint2(RTF.x,LBN.y,RTF.Z,pdwg.pcamera^.modelMatrix,ccsLBN,ccsRTF);
  ProjectPoint2(RTF.x,RTF.y,RTF.Z,pdwg.pcamera^.modelMatrix,ccsLBN,ccsRTF);
  ProjectPoint2(LBN.x,RTF.y,RTF.Z,pdwg.pcamera^.modelMatrix,ccsLBN,ccsRTF);

  ccsLBN.z:=-ccsLBN.z;
  ccsRTF.z:=-ccsRTF.z;

  if (ccsLBN.z-ccsRTF.z)<eps then
                                 begin
                                      ccsLBN.z:=ccsLBN.z+1;
                                      ccsRTF.z:=ccsRTF.z-1;
                                 end;
  pdwg.pcamera^.obj_zmAx:=ccsLBN.z;
  pdwg.pcamera^.obj_zmin:=ccsRTF.z;
  pdwg.pcamera^.zmax:=pdwg.pcamera^.obj_zmAx;
  pdwg.pcamera^.zmin:=pdwg.pcamera^.obj_zmin;

  {if pdwg.pcamera^.zmax>10000 then
                                                pdwg.pcamera^.zmax:=100000;
  if pdwg.pcamera^.zmin<10000 then
                                                  pdwg.pcamera^.zmin:=-10000;}


  if param.projtype = PROJPerspective then
  begin
       if pdwg.pcamera^.zmin<pdwg.pcamera^.zmax/10000 then
                                                  pdwg.pcamera^.zmin:=pdwg.pcamera^.zmax/10000;
       if pdwg.pcamera^.zmin<10 then
                                                  pdwg.pcamera^.zmin:=10;
       if pdwg.pcamera^.zmax<pdwg.pcamera^.zmin then
                                                  pdwg.pcamera^.zmax:=1000;
  end;



  if param.projtype = ProjParalel then
                                      begin
                                      pdwg.pcamera^.projMatrix:=ortho(-clientwidth*pdwg.pcamera^.prop.zoom/2,clientwidth*pdwg.pcamera^.prop.zoom/2,
                                                                                 -clientheight*pdwg.pcamera^.prop.zoom/2,clientheight*pdwg.pcamera^.prop.zoom/2,
                                                                                 pdwg.pcamera^.zmin, pdwg.pcamera^.zmax,@onematrix);
                                      end
                                  else
                                      BEGIN
                                           pdwg.pcamera^.projMatrix:=Perspective(pdwg.pcamera^.fovy, Width / Height, pdwg.pcamera^.zmin, pdwg.pcamera^.zmax,@onematrix);
  //glGetDoublev(GL_PROJECTION_MATRIX, @pdwg.pcamera^.projMatrix);
                                      end;


  ///pdwg.pcamera.getfrustum(@pdwg.pcamera^.modelMatrix,   @pdwg.pcamera^.projMatrix,   pdwg.pcamera^.clip,   pdwg.pcamera^.frustum);



  pdwg.pcamera^.CamCSOffset:=NulVertex;
  pdwg.pcamera^.CamCSOffset.z:=(pdwg.pcamera^.zmax+pdwg.pcamera^.zmin)/2;
  pdwg.pcamera^.CamCSOffset.z:=(pdwg.pcamera^.zmin);


  tm:=pdwg.pcamera^.modelMatrix;
  //MatrixInvert(tm);
  pdwg.pcamera^.CamCSOffset:=geometry.VectorTransform3D(pdwg.pcamera^.CamCSOffset,tm);
  pdwg.pcamera^.CamCSOffset:=pdwg.pcamera^.prop.point;

  {получение центра виевфрустума}
  tm:=geometry.CreateTranslationMatrix({minusvertex(pdwg.pcamera^.CamCSOffset)}nulvertex);

  //pdwg.pcamera^.modelMatrixLCS:=tm;
  pdwg.pcamera^.modelMatrixLCS:=lookat({vertexsub(pdwg.pcamera^.prop.point,pdwg.pcamera^.CamCSOffset)}nulvertex,
                                               pdwg.pcamera^.prop.xdir,
                                               pdwg.pcamera^.prop.ydir,
                                               pdwg.pcamera^.prop.look,{@tm}@onematrix);
  pdwg.pcamera^.modelMatrixLCS:=geometry.MatrixMultiply(tm,pdwg.pcamera^.modelMatrixLCS);
  ccsLBN:=InfinityVertex;
  ccsRTF:=MinusInfinityVertex;
  tbb:=proot.VisibleOBJBoundingBox;
  //pdwg.ConstructObjRoot.calcbb;
  tbb2:=pdwg.ConstructObjRoot.vp.BoundingBox;
  ConcatBB(tbb,tbb2);

  //proot.VisibleOBJBoundingBox:=tbb;

  if not IsBBNul(tbb) then
  begin
        LBN:=tbb.LBN;
        LBN:=vertexadd(LBN,pdwg.pcamera^.CamCSOffset);
        RTF:=tbb.RTF;
        RTF:=vertexadd(RTF,pdwg.pcamera^.CamCSOffset);
  end
  else
  begin
       LBN:=geometry.VertexMulOnSc(OneVertex,50);
       //LBN:=vertexadd(LBN,pdwg.pcamera^.CamCSOffset);
       RTF:=geometry.VertexMulOnSc(OneVertex,100);
       //RTF:=vertexadd(RTF,pdwg.pcamera^.CamCSOffset);
  end;
  ProjectPoint2(LBN.x,LBN.y,LBN.Z,pdwg.pcamera^.modelMatrixLCS,ccsLBN,ccsRTF);
  ProjectPoint2(RTF.x,LBN.y,LBN.Z,pdwg.pcamera^.modelMatrixLCS,ccsLBN,ccsRTF);
  ProjectPoint2(RTF.x,RTF.y,LBN.Z,pdwg.pcamera^.modelMatrixLCS,ccsLBN,ccsRTF);
  ProjectPoint2(LBN.x,RTF.y,LBN.Z,pdwg.pcamera^.modelMatrixLCS,ccsLBN,ccsRTF);
  ProjectPoint2(LBN.x,LBN.y,RTF.Z,pdwg.pcamera^.modelMatrixLCS,ccsLBN,ccsRTF);
  ProjectPoint2(RTF.x,LBN.y,RTF.Z,pdwg.pcamera^.modelMatrixLCS,ccsLBN,ccsRTF);
  ProjectPoint2(RTF.x,RTF.y,RTF.Z,pdwg.pcamera^.modelMatrixLCS,ccsLBN,ccsRTF);
  ProjectPoint2(LBN.x,RTF.y,RTF.Z,pdwg.pcamera^.modelMatrixLCS,ccsLBN,ccsRTF);
  ccsLBN.z:=-ccsLBN.z;
  ccsRTF.z:=-ccsRTF.z;

  if (ccsLBN.z-ccsRTF.z)<eps then
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
  pdwg.pcamera^.obj_zmAx:=ccsLBN.z;
  pdwg.pcamera^.obj_zmin:=ccsRTF.z;
  pdwg.pcamera^.zmaxLCS:=pdwg.pcamera^.obj_zmAx;
  pdwg.pcamera^.zminLCS:=pdwg.pcamera^.obj_zmin;


  if param.projtype = PROJPerspective then
  begin
       if pdwg.pcamera^.zminLCS<pdwg.pcamera^.zmaxLCS/10000 then
                                                  pdwg.pcamera^.zminLCS:=pdwg.pcamera^.zmaxLCS/10000;
       if pdwg.pcamera^.zminLCS<10 then
                                                  pdwg.pcamera^.zminLCS:=10;
       if pdwg.pcamera^.zmaxLCS<pdwg.pcamera^.zminLCS then
                                                  pdwg.pcamera^.zmaxLCS:=1000;
  end;

  pdwg.pcamera^.zminLCS:=pdwg.pcamera^.zminLCS;//-pdwg.pcamera^.CamCSOffset.z;
  pdwg.pcamera^.zmaxLCS:=pdwg.pcamera^.zmaxLCS;//+pdwg.pcamera^.CamCSOffset.z;


  //glLoadIdentity;
  //pdwg.pcamera^.projMatrix:=onematrix;
  if param.projtype = ProjParalel then
                                      begin
                                      pdwg.pcamera^.projMatrixLCS:=ortho(-clientwidth*pdwg.pcamera^.prop.zoom/2,clientwidth*pdwg.pcamera^.prop.zoom/2,
                                                                                 -clientheight*pdwg.pcamera^.prop.zoom/2,clientheight*pdwg.pcamera^.prop.zoom/2,
                                                                                 pdwg.pcamera^.zminLCS, pdwg.pcamera^.zmaxLCS,@onematrix);
                                      end
                                  else
                                      BEGIN
                                           pdwg.pcamera^.projMatrixLCS:=Perspective(pdwg.pcamera^.fovy, Width / Height, pdwg.pcamera^.zminLCS, pdwg.pcamera^.zmaxLCS,@onematrix);
  //glGetDoublev(GL_PROJECTION_MATRIX, @pdwg.pcamera^.projMatrix);
                                      end;
  if param.projtype = ProjParalel then
                                      begin
                                            OGLSpecFunc.CurrentCamCSOffset:=pdwg.pcamera^.CamCSOffset;
                                            OGLSpecFunc.notuseLCS:=pdwg.pcamera^.notuseLCS;
                                      end
                                  else
                                      begin
                                            OGLSpecFunc.notuseLCS:=true;
                                      end;
  if {pdwg.pcamera^.notuseLCS}OGLSpecFunc.notuseLCS then
  begin
        pdwg.pcamera^.projMatrixLCS:=pdwg.pcamera^.projMatrix;
        pdwg.pcamera^.modelMatrixLCS:=pdwg.pcamera^.modelMatrix;
        pdwg.pcamera^.frustumLCS:=pdwg.pcamera^.frustum;
        pdwg.pcamera^.CamCSOffset:=NulVertex;
        OGLSpecFunc.CurrentCamCSOffset:=nulvertex;
  end;


  SetOGLMatrix;

  if {pdwg.pcamera^.notuseLCS}OGLSpecFunc.notuseLCS then
  begin
        pdwg.pcamera^.projMatrixLCS:=pdwg.pcamera^.projMatrix;
        pdwg.pcamera^.modelMatrixLCS:=pdwg.pcamera^.modelMatrix;
        pdwg.pcamera^.frustumLCS:=pdwg.pcamera^.frustum;
        pdwg.pcamera^.CamCSOffset:=NulVertex;
        OGLSpecFunc.CurrentCamCSOffset:=nulvertex;
  end;

  end;
    {$IFDEF PERFOMANCELOG}log.programlog.LogOutStrFast('TOGLWnd.CalcOptimalMatrix----{end}',lp_DecPos);{$ENDIF}
  //gdb.GetCurrentDWG.pcamera.getfrustum(@gdb.GetCurrentDWG.pcamera^.modelMatrixLCS,@gdb.GetCurrentDWG.pcamera^.projMatrixLCS,gdb.GetCurrentDWG.pcamera^.clipLCS,gdb.GetCurrentDWG.pcamera^.frustumLCS);
end;
procedure TOGLWnd.CorrectMouseAfterOS;
var d,tv1,tv2:GDBVertex;
    b1,b2:GDBBoolean;
begin
     if param.ospoint.ostype <> os_none then
     begin

     if param.projtype = ProjParalel then
     begin
          d:=gdb.GetCurrentDWG.pcamera^.prop.look;
          b1:=PointOfLinePlaneIntersect(param.ospoint.worldcoord,d,gdb.GetCurrentDWG.pcamera^.frustum[4],tv1);
          b2:=PointOfLinePlaneIntersect(param.ospoint.worldcoord,d,gdb.GetCurrentDWG.pcamera^.frustum[5],tv2);
          if (b1 and b2) then
                             begin
                                  param.md.mouseray.lbegin:=tv1;
                                  param.md.mouseray.lend:=tv2;
                                  param.md.mouseray.dir:=vertexsub(tv2,tv1);
                             end;
     end
     else
     begin
         d:=VertexSub(param.ospoint.worldcoord,gdb.GetCurrentDWG.pcamera^.prop.point);
         //d:=gdb.GetCurrentDWG.pcamera^.prop.look;
         b1:=PointOfLinePlaneIntersect(param.ospoint.worldcoord,d,gdb.GetCurrentDWG.pcamera^.frustum[4],tv1);
         b2:=PointOfLinePlaneIntersect(param.ospoint.worldcoord,d,gdb.GetCurrentDWG.pcamera^.frustum[5],tv2);
         if (b1 and b2) then
                            begin
                                 param.md.mouseray.lbegin:=tv1;
                                 param.md.mouseray.lend:=tv2;
                                 param.md.mouseray.dir:=vertexsub(tv2,tv1);
                            end;
         gdb.GetCurrentDWG^.myGluUnProject(createvertex(param.ospoint.dispcoord.x, param.ospoint.dispcoord.y, 0),param.md.mouseray.lbegin);
         gdb.GetCurrentDWG^.myGluUnProject(createvertex(param.ospoint.dispcoord.x, param.ospoint.dispcoord.y, 1),param.md.mouseray.lend);
     end;
     end;
end;


procedure TOGLWnd.mouseunproject(X, Y: glint);
var ca, cv: extended;cav: gdbvertex;  ds:GDBString;
begin
  if gdb.GetCurrentDWG=NIL then exit;
  gdb.GetCurrentDWG^.myGluProject2(NulVertex,
                   param.CSIconCoord);
  if (param.CSIconCoord.x>0)and(param.CSIconCoord.y>0)and(param.CSIconCoord.x<clientwidth)and(param.CSIconCoord.y<clientheight)
  then
  begin
       gdb.GetCurrentDWG^.myGluProject2(x_Y_zVertex,
                               cav);
       cav.x:=param.CSIconCoord.x-cav.x;
       cav.y:=param.CSIconCoord.y-cav.y;
       param.cslen:=sqrt(cav.x*cav.x+cav.y*cav.y);
       param.CSIconCoord.x:=0;
       param.CSIconCoord.y:=0;
       param.CSIconCoord.z:=0;
  end
  else
  begin
  gdb.GetCurrentDWG^.myGluUnProject(createvertex(40, 40, 0.1),
                              param.CSIconCoord);
       gdb.GetCurrentDWG^.myGluProject2(CreateVertex(param.CSIconCoord.x,param.CSIconCoord.y+1,param.CSIconCoord.z),

                  cav);
       cav.x:=40-cav.x;
       cav.y:=40-cav.y;
       param.cslen:=sqrt(cav.x*cav.x+cav.y*cav.y);

  end;

  gdb.GetCurrentDWG^.myGluUnProject(createvertex(x, y, 0),param.md.mouseray.lbegin);
  gdb.GetCurrentDWG^.myGluUnProject(createvertex(x, y, 1),param.md.mouseray.lend);
  //param.md.mouseray.lbegin:=vertexsub(param.md.mouseray.lbegin,gdb.GetCurrentDWG.pcamera^.CamCSOffset);
  //param.md.mouseray.lend:=vertexsub(param.md.mouseray.lend,gdb.GetCurrentDWG.pcamera^.CamCSOffset);




  gdb.GetCurrentDWG^.myGluProject2(CreateVertex(param.CSIconCoord.x + sizeaxis * gdb.GetCurrentDWG.pcamera^.prop.zoom, param.CSIconCoord.y, param.CSIconCoord.z),
             CAV);
  param.csx.x := round(cav.x);
  param.csx.y := round(cav.y);
  gdb.GetCurrentDWG^.myGluProject2(CreateVertex(param.CSIconCoord.x, param.CSIconCoord.y + sizeaxis * gdb.GetCurrentDWG.pcamera^.prop.zoom, param.CSIconCoord.z),
             CAV);
  param.csy.x := round(cav.x);
  param.csy.y := round(cav.y);
  gdb.GetCurrentDWG^.myGluProject2(CreateVertex(param.CSIconCoord.x, param.CSIconCoord.y, param.CSIconCoord.z + sizeaxis * gdb.GetCurrentDWG.pcamera^.prop.zoom),
             CAV);
  param.csz.x := round(cav.x);
  param.csz.y := round(cav.y);


  gdb.GetCurrentDWG^.myGluProject2(CreateVertex(1000, 1000, 1000),
            cav);
  //param.mouseray.lbegin := param.glmcoord[0];



  param.md.mouseray.dir:=vertexsub(param.md.mouseray.lend,param.md.mouseray.lbegin);
  //param.md.mouseray.dir.x := param.md.mouseray.lend.x - param.md.mouseray.lbegin.x;
  //param.md.mouseray.dir.y := param.md.mouseray.lend.y - param.md.mouseray.lbegin.y;
  //param.md.mouseray.dir.z := param.md.mouseray.lend.z - param.md.mouseray.lbegin.z;

  cav.x := -param.md.mouseray.lbegin.x;
  cav.y := -param.md.mouseray.lbegin.y;
  cav.z := -param.md.workplane.d / param.md.workplane.normal.z * param.md.mouseray.dir.z - param.md.mouseray.lbegin.z;
  //ca := param.md.workplane.normal.x * cav.x + param.md.workplane.normal.y * cav.y + param.md.workplane.normal.z * cav.z;
  {cv := param.md.workplane.normal.x * param.md.mouseray.dir.x +
        param.md.workplane.normal.y * param.md.mouseray.dir.y +
        param.md.workplane.normal.z * param.md.mouseray.dir.z;}

  cv:=param.md.workplane.normal.x*param.md.mouseray.dir.x +
      param.md.workplane.normal.y*param.md.mouseray.dir.y +
      param.md.workplane.normal.z*param.md.mouseray.dir.z;
  ca:=-param.md.workplane.d - param.md.workplane.normal.x*param.md.mouseray.lbegin.x -
       param.md.workplane.normal.y*param.md.mouseray.lbegin.y -
       param.md.workplane.normal.z*param.md.mouseray.lbegin.z;
  if cv = 0 then param.md.mouseonworkplan := false
  else begin
    param.md.mouseonworkplan := true;
    ca := ca / cv;
    param.md.mouseonworkplanecoord.x := param.md.mouseray.lbegin.x + param.md.mouseray.dir.x * ca;
    param.md.mouseonworkplanecoord.y := param.md.mouseray.lbegin.y + param.md.mouseray.dir.y * ca;
    param.md.mouseonworkplanecoord.z := param.md.mouseray.lbegin.z + param.md.mouseray.dir.z * ca;

    ca:=param.md.workplane.normal.x * param.md.mouseonworkplanecoord.x +
        param.md.workplane.normal.y * param.md.mouseonworkplanecoord.y +
        param.md.workplane.normal.z * param.md.mouseonworkplanecoord.z+param.md.workplane.d;

    if ca<>0 then
    begin
         param.md.mouseonworkplanecoord.x:=param.md.mouseonworkplanecoord.x-param.md.workplane.normal.x*ca;
         param.md.mouseonworkplanecoord.y:=param.md.mouseonworkplanecoord.y-param.md.workplane.normal.y*ca;
         param.md.mouseonworkplanecoord.z:=param.md.mouseonworkplanecoord.z-param.md.workplane.normal.z*ca;
    end;
    ca:=param.md.workplane.normal.x * param.md.mouseonworkplanecoord.x +
        param.md.workplane.normal.y * param.md.mouseonworkplanecoord.y +
        param.md.workplane.normal.z * param.md.mouseonworkplanecoord.z + param.md.workplane.d;
    str(ca,ds);
  end;
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
  smallwheel:=1+(varmandef.sysvar.DISP.DISP_ZoomFactor^-1)/10;
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
        DISP_ZoomFactor(varmandef.sysvar.DISP.DISP_ZoomFactor^);
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
        DISP_ZoomFactor(1 / varmandef.sysvar.DISP.DISP_ZoomFactor^);
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

  CalcOptimalMatrix;
  mouseunproject(param.md.mouse.x, clientheight-param.md.mouse.y);
  reprojectaxis;
  if param.seldesc.MouseFrameON then
  begin
    gdb.GetCurrentDWG^.myGluProject2(param.seldesc.Frame13d,
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
  gdb.GetCurrentDWG.pcamera^.NextPosition;
  param.firstdraw:=true;
  gdb.GetCurrentROOT.CalcVisibleByTree(gdb.GetCurrentDWG.pcamera^.frustum,gdb.GetCurrentDWG.pcamera.POSCOUNT,gdb.GetCurrentDWG.pcamera.VISCOUNT,gdb.GetCurrentDWG.pObjRoot.ObjArray.ObjTree);
  //gdb.GetCurrentROOT.calcvisible(gdb.GetCurrentDWG.pcamera^.frustum,gdb.GetCurrentDWG.pcamera.POSCOUNT,gdb.GetCurrentDWG.pcamera.VISCOUNT);
  gdb.GetCurrentDWG.ConstructObjRoot.calcvisible(gdb.GetCurrentDWG.pcamera^.frustum,gdb.GetCurrentDWG.pcamera.POSCOUNT,gdb.GetCurrentDWG.pcamera.VISCOUNT);
  gdb.GetCurrentDWG.SelObjArray.RenderFeedBack;

  calcmousefrustum;

  if param.lastonmouseobject<>nil then
                                      begin
                                           PGDBObjEntity(param.lastonmouseobject)^.RenderFeedBack;
                                      end;

  Set3dmouse;

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
       commandmanager.ExecuteCommandSilent('MultiSelect2ObjIbsp');
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
            SetGDBObjInsp(ptype,param.SelDesc.LastSelectedObject);
       end;
  end
  else
  begin
    {GDBobjinsp.}ReturnToDefault;
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

procedure TOGLWnd._onMouseMove(sender:tobject;Shift: TShiftState; X, Y: Integer);
//procedure TOGLWnd.Pre_MouseMove;
var
  glmcoord1: gdbpiece;
  tv2:gdbvertex4d;
  ax:gdbvertex;
  ux,uy:GDBDouble;
  htext:gdbstring;

//  tm2,tm3:dmatrix4d;

//  i:integer;
  key: GDBByte;
begin
  //if random<0.8 then exit;
  //if   (param.md.mouse.y=y)and(param.md.mouse.x=x)then
  //                                                    exit;
  {$IFDEF PERFOMANCELOG}log.programlog.LogOutStrFast('TOGLWnd.Pre_MouseMove',lp_IncPos);{$ENDIF}



  key:=0;
  if (ssShift in Shift) then
                            key := key or MZW_SHIFT;
  if (ssCtrl in Shift) then
                                    key := key or MZW_CONTROL;
  if gdb.GetCurrentDWG=nil then
                            begin
                                   param.md.mouse.y := y;
                                   param.md.mouse.x := x;
                                   param.md.glmouse.y := clientheight-y;
                                   param.md.glmouse.x := x;
                                   exit;
                            end;
  glmcoord1 := param.md.mouseray;

  if ((param.md.mode) and ((MRotateCamera) or (MMoveCamera)) <> 0) then
    if ((ssCtrl in shift) and ((ssMiddle in shift))) and ((param.md.mode) and (MRotateCamera) <> 0) then
    begin
      uy :=(x - param.md.mouse.x) / 1000;
      ux :=- (y - param.md.mouse.y) / 1000;
      with gdb.GetCurrentDWG.UndoStack.CreateTGChangeCommand(gdb.GetCurrentDWG.pcamera^.prop)^ do
      begin
      //gdb.GetCurrentDWG.UndoStack.PushChangeCommand(gdb.GetCurrentDWG.pcamera,(ptrint(@gdb.GetCurrentDWG.pcamera^.prop)-ptrint(gdb.GetCurrentDWG.pcamera)),sizeof(GDBCameraBaseProp));
      gdb.GetCurrentDWG.pcamera.RotateInLocalCSXY(ux,uy);
      ComitFromObj;
      end;
      param.firstdraw := true;
      gdb.GetCurrentDWG.pcamera^.NextPosition;
      CalcOptimalMatrix;
      //-------------------CalcOptimalMatrix;

      gdb.GetCurrentROOT.CalcVisibleByTree(gdb.GetCurrentDWG.pcamera^.frustum,gdb.GetCurrentDWG.pcamera.POSCOUNT,gdb.GetCurrentDWG.pcamera.VISCOUNT,gdb.GetCurrentDWG.pObjRoot.ObjArray.ObjTree);
      //gdb.GetCurrentROOT.calcalcvisible(gdb.GetCurrentDWG.pcamera^.frustum,gdb.GetCurrentDWG.pcamera.POSCOUNT);
      gdb.GetCurrentDWG.ConstructObjRoot.calcvisible(gdb.GetCurrentDWG.pcamera^.frustum,gdb.GetCurrentDWG.pcamera.POSCOUNT,gdb.GetCurrentDWG.pcamera.VISCOUNT);
    end
    else
      if ssMiddle in shift then     {MK_Control}
begin
      mouseunproject(X, clientheight-Y);
      tv2.x:=(x - param.md.mouse.x);
      tv2.y:=(y - param.md.mouse.y);
      if (abs(tv2.x)>eps)or(abs(tv2.y)>eps) then
      begin
           ax.x:=-(param.md.mouseray.lend.x - glmcoord1.lend.x);
           ax.y:= (param.md.mouseray.lend.y - glmcoord1.lend.y);
           ax.z:= (param.md.mouseray.lend.z - glmcoord1.lend.z);
           with gdb.GetCurrentDWG.UndoStack.PushCreateTGChangeCommand(gdb.GetCurrentDWG.pcamera^.prop)^ do
           begin
           gdb.GetCurrentDWG.pcamera.moveInLocalCSXY(tv2.x,tv2.y,ax);
           ComitFromObj;
           end;
           param.firstdraw := true;
           gdb.GetCurrentDWG.pcamera^.NextPosition;
           CalcOptimalMatrix;
           //-------------CalcOptimalMatrix;

           gdb.GetCurrentROOT.CalcVisibleByTree(gdb.GetCurrentDWG.pcamera^.frustum,gdb.GetCurrentDWG.pcamera.POSCOUNT,gdb.GetCurrentDWG.pcamera.VISCOUNT,gdb.GetCurrentDWG.pObjRoot.ObjArray.ObjTree);
           //gdb.GetCurrentROOT.calcvisible(gdb.GetCurrentDWG.pcamera^.frustum,gdb.GetCurrentDWG.pcamera.POSCOUNT);
           gdb.GetCurrentDWG.ConstructObjRoot.calcvisible(gdb.GetCurrentDWG.pcamera^.frustum,gdb.GetCurrentDWG.pcamera.POSCOUNT,gdb.GetCurrentDWG.pcamera.VISCOUNT);
      end;
end;

  param.md.mouse.y := y;
  param.md.mouse.x := x;
  param.md.glmouse.y := clientheight-y;
  param.md.glmouse.x := x;

  param.md.mouseglue := param.md.mouse;
  param.gluetocp := false;

  if (param.md.mode and MGetControlpoint) <> 0 then
  begin
    param.nearesttcontrolpoint:=gdb.GetCurrentDWG.SelObjArray.getnearesttomouse;
    if (param.nearesttcontrolpoint.pcontrolpoint = nil) or (param.nearesttcontrolpoint.disttomouse > 2 * sysvar.DISP.DISP_CursorSize^) then
    begin
      param.md.mouseglue := param.md.mouse;
      param.gluetocp := false;
    end
    else begin
      param.gluetocp := true;
      param.md.mouseglue := param.nearesttcontrolpoint.pcontrolpoint^.dispcoord;
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
                                                     getonmouseobjectbytree(gdb.GetCurrentROOT.ObjArray.ObjTree);
  if (param.md.mode and MGet3DPointWoOP) <> 0 then param.ospoint.ostype := os_none;
  if (param.md.mode and MGet3DPoint) <> 0 then
  begin

      if (param.md.mode and MGetSelectObject) = 0 then
                                                      getonmouseobjectbytree(gdb.GetCurrentROOT.ObjArray.ObjTree);
      getosnappoint(@gdb.GetCurrentROOT.ObjArray, 0);
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
    gdb.GetCurrentDWG^.myGluProject2(param.seldesc.Frame13d,
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
  gdb.GetCurrentDWG.ConstructObjRoot.calcvisible(gdb.GetCurrentDWG.pcamera^.frustum,gdb.GetCurrentDWG.pcamera.POSCOUNT,gdb.GetCurrentDWG.pcamera.VISCOUNT);

  //gdb.GetCurrentDWG.ConstructObjRoot.calcvisible(gdb.GetCurrentDWG.OGLwindow1.param.mousefrustum);

  gdb.GetCurrentDWG.SelObjArray.calcvisible(gdb.GetCurrentDWG.pcamera^.frustum,gdb.GetCurrentDWG.pcamera.POSCOUNT,gdb.GetCurrentDWG.pcamera.VISCOUNT);
  Set3dmouse;



  htext:=FloatToStrf(param.md.mouse3dcoord.x,ffFixed,10,3)+','+FloatToStrf(param.md.mouse3dcoord.y,ffFixed,10,3)+','+FloatToStrf(param.md.mouse3dcoord.z,ffFixed,10,3);
  if {mainwindow.OGLwindow1.}param.polarlinetrace = 1 then
  begin
       htext:=htext+' L='+FloatToStrf(param.ontrackarray.otrackarray[param.pointnum].tmouse,ffFixed,10,3);
  end;


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
    gltranslated(pgdbfont(pbasefont).symbolinfo[GDBByte(s[i])].dx, 0, 0);
    inc(i);
  end;
end;
procedure TOGLWnd.Set3dmouse;
begin
    if param.ospoint.ostype <> os_none
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
                 param.ospoint.worldcoord:=param.md.mouseonworkplanecoord;
                 sendcoordtocommandTraceOn(param.md.mouseonworkplanecoord,key,nil)
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
     commandmanager.pcommandrunning^.MouseMoveCallback(coord, param.md.mouse, key,nil);
end;
procedure TOGLWnd.sendcoordtocommandTraceOn(coord:GDBVertex;key: GDBByte;pos:pos_record);
begin
     commandmanager.pcommandrunning^.MouseMoveCallback(coord,param.md.mouse,key,pos);
     if (key and MZW_LBUTTON)<>0 then
     if commandmanager.pcommandrunning<>nil then
     begin
           inc(tocommandmcliccount);
           param.ontrackarray.otrackarray[0].worldcoord:=coord;
           param.lastpoint:=coord;
           create0axis;
           project0axis;
     end;
end;

procedure TOGLWnd.DrawGrid;
var
  pg:PGDBvertex2S;
  i,j: GDBInteger;
begin
  if sysvar.DWG.DWG_DrawGrid^ then
  begin
  //CalcOptimalMatrix;
  glcolor3b(100, 100, 100);
  pg := @gridarray;
  oglsm.myglbegin(gl_points);
  for i := 0 to maxgrid do
  for j := 0 to maxgrid do
  begin
    //glVertex2fv(@pg^);
    oglsm.myglVertex3d(createvertex(i,j,0));
    inc(pg);
  end;
  oglsm.myglend;
  end;
end;
procedure TOGLWnd.GDBActivate;
begin
  //if PDWG<>gdb.GetCurrentDWG then
                                 begin
                                      gdb.SetCurrentDWG(self.pdwg);
                                      self.param.firstdraw:=true;
                                      MyglMakeCurrent(OGLContext);//wglMakeCurrent(DC, hrc);//initogl;
                                      isOpenGLError;
                                      //{переделать}size;
                                      paint;
                                 end;
  updatevisible;
end;
procedure TOGLWnd.ZoomAll;
const
     steps=5;
var
  tpz,tzoom: GDBDouble;
  fv1,tp,wcsLBN,wcsRTF,dcsLBN,dcsRTF: GDBVertex;
  camerapos,target:GDBVertex;
  i:integer;
begin
  if param.projtype = PROJPerspective then
                                          begin
                                               historyout('MBMouseDblClk: Пока только для паралельной проекции!');
                                          end;
  historyout('MBMouseDblClk: Пока корректно только при виде сверху!');


  CalcOptimalMatrix;


  dcsLBN:=InfinityVertex;
  dcsRTF:=MinusInfinityVertex;
  wcsLBN:=InfinityVertex;
  wcsRTF:=MinusInfinityVertex;
  tp:=ProjectPoint(gdb.GetCurrentROOT.vp.BoundingBox.LBN.x,gdb.GetCurrentROOT.vp.BoundingBox.LBN.y,gdb.GetCurrentROOT.vp.BoundingBox.LBN.Z,wcsLBN,wcsRTF,dcsLBN,dcsRTF);
  tp:=ProjectPoint(gdb.GetCurrentROOT.vp.BoundingBox.RTF.x,gdb.GetCurrentROOT.vp.BoundingBox.LBN.y,gdb.GetCurrentROOT.vp.BoundingBox.LBN.Z,wcsLBN,wcsRTF,dcsLBN,dcsRTF);
  tp:=ProjectPoint(gdb.GetCurrentROOT.vp.BoundingBox.RTF.x,gdb.GetCurrentROOT.vp.BoundingBox.RTF.y,gdb.GetCurrentROOT.vp.BoundingBox.LBN.Z,wcsLBN,wcsRTF,dcsLBN,dcsRTF);
  tp:=ProjectPoint(gdb.GetCurrentROOT.vp.BoundingBox.LBN.x,gdb.GetCurrentROOT.vp.BoundingBox.RTF.y,gdb.GetCurrentROOT.vp.BoundingBox.LBN.Z,wcsLBN,wcsRTF,dcsLBN,dcsRTF);
  tp:=ProjectPoint(gdb.GetCurrentROOT.vp.BoundingBox.LBN.x,gdb.GetCurrentROOT.vp.BoundingBox.LBN.y,gdb.GetCurrentROOT.vp.BoundingBox.RTF.Z,wcsLBN,wcsRTF,dcsLBN,dcsRTF);
  tp:=ProjectPoint(gdb.GetCurrentROOT.vp.BoundingBox.RTF.x,gdb.GetCurrentROOT.vp.BoundingBox.LBN.y,gdb.GetCurrentROOT.vp.BoundingBox.RTF.Z,wcsLBN,wcsRTF,dcsLBN,dcsRTF);
  tp:=ProjectPoint(gdb.GetCurrentROOT.vp.BoundingBox.RTF.x,gdb.GetCurrentROOT.vp.BoundingBox.RTF.y,gdb.GetCurrentROOT.vp.BoundingBox.RTF.Z,wcsLBN,wcsRTF,dcsLBN,dcsRTF);
  tp:=ProjectPoint(gdb.GetCurrentROOT.vp.BoundingBox.LBN.x,gdb.GetCurrentROOT.vp.BoundingBox.RTF.y,gdb.GetCurrentROOT.vp.BoundingBox.RTF.Z,wcsLBN,wcsRTF,dcsLBN,dcsRTF);

  if (abs(wcsRTF.x-wcsLBN.x)<eps)and(abs(wcsRTF.y-wcsLBN.y)<eps) then
                                                                    begin
                                                                         historyout('MBMouseDblClk: Пустой чертеж?');
                                                                         exit;
                                                                    end;

  target:=createvertex(-(wcsLBN.x+(wcsRTF.x-wcsLBN.x)/2),-(wcsLBN.y+(wcsRTF.y-wcsLBN.y)/2),gdb.GetCurrentDWG.pcamera^.prop.point.z);
  camerapos:=gdb.GetCurrentDWG.pcamera^.prop.point;
  target:=vertexsub(target,camerapos);

  tzoom:=(wcsRTF.x-wcsLBN.x)/clientwidth;
  tpz:=(wcsRTF.y-wcsLBN.y)/clientheight;

  with gdb.GetCurrentDWG.UndoStack.PushCreateTGChangeCommand(gdb.GetCurrentDWG.pcamera^.prop)^ do
  begin

  if tpz>tzoom then tzoom:=tpz;

  tzoom:=tzoom-gdb.GetCurrentDWG.pcamera^.prop.zoom;

  for i:=1 to steps do
  begin
  gdb.GetCurrentDWG.pcamera^.prop.point:=vertexadd(camerapos,geometry.VertexMulOnSc(target,i/steps));
  //gdb.GetCurrentDWG.pcamera^.point.x:=-(wcsLBN.x+(wcsRTF.x-wcsLBN.x)/2);
  //gdb.GetCurrentDWG.pcamera^.point.y:=-(wcsLBN.y+(wcsRTF.y-wcsLBN.y)/2);


  {param.zoom:=(wcsRTF.x-wcsLBN.x)/clientwidth;
  tpz:=(wcsRTF.y-wcsLBN.y)/clientheight;
  if tpz>param.zoom then param.zoom:=tpz;}

  gdb.GetCurrentDWG.pcamera^.prop.zoom:=gdb.GetCurrentDWG.pcamera^.prop.zoom+tzoom{*i}/steps;

  CalcOptimalMatrix;
  mouseunproject(param.md.mouse.x,param.md.mouse.y);
  reprojectaxis;
  param.firstdraw := true;
  //gdb.GetCurrentDWG.pcamera^.getfrustum(@gdb.GetCurrentDWG.pcamera^.modelMatrix,@gdb.GetCurrentDWG.pcamera^.projMatrix,gdb.GetCurrentDWG.pcamera^.clipLCS,gdb.GetCurrentDWG.pcamera^.frustum);
  //gdb.GetCurrentROOT.Format;

  gdb.GetCurrentDWG.pcamera^.NextPosition;
//  param.firstdraw:=true;
  gdb.GetCurrentROOT.CalcVisibleByTree(gdb.GetCurrentDWG.pcamera^.frustum,gdb.GetCurrentDWG.pcamera.POSCOUNT,gdb.GetCurrentDWG.pcamera.VISCOUNT,gdb.GetCurrentDWG.pObjRoot.ObjArray.ObjTree);
  //gdb.GetCurrentROOT.calcvisible(gdb.GetCurrentDWG.pcamera^.frustum);

  gdb.GetCurrentDWG.ConstructObjRoot.calcvisible(gdb.GetCurrentDWG.pcamera^.frustum,gdb.GetCurrentDWG.pcamera.POSCOUNT,gdb.GetCurrentDWG.pcamera.VISCOUNT);

  _onMouseMove(nil,[],param.md.mouse.x,param.md.mouse.y);

  if i=steps then
    begin

  if param.seldesc.MouseFrameON then
  begin
    gdb.GetCurrentDWG^.myGluProject2(param.seldesc.Frame13d,
               fv1);
    param.seldesc.Frame1.x := round(fv1.x);
    param.seldesc.Frame1.y := clientheight - round(fv1.y);
    if param.seldesc.Frame1.x < 0 then param.seldesc.Frame1.x := 0
    else if param.seldesc.Frame1.x > (clientwidth - 1) then param.seldesc.Frame1.x := clientwidth - 1;
    if param.seldesc.Frame1.y < 0 then param.seldesc.Frame1.y := 1
    else if param.seldesc.Frame1.y > (clientheight - 1) then param.seldesc.Frame1.y := clientheight - 1;
  end;
  end;
  ComitFromObj;
  end;
  //paint;
  draw;

  end;
end;
procedure TOGLWnd.asynczoomall(Data: PtrInt);
begin
     ZoomAll();
end;
procedure RunTextEditor(Pobj:PGDBObjText);
var
   op:gdbstring;
   size,modalresult:integer;
   InfoForm:TInfoForm;
   us:unicodestring;
   u8s:UTF8String;
   astring:ansistring;
begin
     astring:=ConvertFromDxfString(pobj^.Template);

     InfoForm:=TInfoForm.create(application.MainForm);
     //InfoForm.DialogPanel.ShowButtons:=[pbOK, pbCancel{, pbClose, pbHelp}];
     InfoForm.caption:=('Редактор текста');

     InfoForm.memo.text:=astring;
     modalresult:=InfoForm.ShowModal;
     if modalresult=MrOk then
                         begin
                              pobj^.Template:=ConvertToDxfString(InfoForm.memo.text);
                              pobj^.YouChanged;
                              gdb.GetCurrentROOT.FormatAfterEdit;
                              redrawoglwnd;
                         end;
     InfoForm.Free;

end;

procedure TOGLWnd.MouseDown(Button: TMouseButton; Shift: TShiftState;X, Y: Integer);
var key: GDBByte;
    NeedRedraw:boolean;
begin
  NeedRedraw:=false;
  if ssDouble in shift then
                           begin
                                if mbMiddle=button then
                                  begin
                                       Application.QueueAsyncCall(asynczoomall, 0);
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
                                                 RunTextEditor(param.SelDesc.OnMouseObject);
                                           end;
                                       exit;
                                  end;

                           end;
  if PDWG<>gdb.GetCurrentDWG then
                                 begin
                                      //r.handled:=true;
                                      gdb.SetCurrentDWG(pdwg);
                                      self.param.firstdraw:=true;
                                      paint;
                                      MyglMakeCurrent(OGLContext);//wglMakeCurrent(DC, hrc);//initogl;

                                 end
                              else

  begin
  //r.handled:=true;
  if gdb.GetCurrentDWG=nil then exit;
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
          gdb.GetCurrentDWG.SelObjArray.selectcurrentcontrolpoint(key);
          if (key and MZW_SHIFT) = 0 then
          begin
            commandmanager.ExecuteCommandSilent('OnDrawingEd');
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
          getonmouseobjectbytree(gdb.GetCurrentROOT.ObjArray.ObjTree);
          //getonmouseobject(@gdb.GetCurrentROOT.ObjArray);
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
                        PGDBObjEntity(param.SelDesc.OnMouseObject)^.select;
                        param.SelDesc.LastSelectedObject := param.SelDesc.OnMouseObject;
                        addoneobject;
                        SetObjInsp;
                   end
               else
                   begin
                        PGDBObjEntity(param.SelDesc.OnMouseObject)^.DeSelect;
                        param.SelDesc.LastSelectedObject := nil;
                        //addoneobject;
                        SetObjInsp;
                   end;
               NeedRedraw:=true;
          end
          else if ((param.md.mode and MGetSelectionFrame) <> 0) and (key = MZW_LBUTTON) then
          begin
            commandmanager.ExecuteCommandSilent('SelectFrame');
            sendmousecoord(MZW_LBUTTON);
          end;
        end;

    end
    else
    begin
      if (param.md.mode and (MGet3DPoint or MGet3DPointWoOP)) <> 0 then
      begin
        sendmousecoordwop(key);
        //GDBFreeMem(GDB.PObjPropArray^.propertyarray[0].pobject);
      end
      else if ((param.md.mode and MGetSelectionFrame) <> 0) and (key = MZW_LBUTTON) then
          begin
            commandmanager.ExecuteCommandSilent('SelectFrame');
            sendmousecoord(MZW_LBUTTON);
          end;
    end;
    UpdateObjInsp;
  end;
  inherited;
  if needredraw then
                    redrawoglwnd;
end;
procedure TOGLWnd.DISP_ZoomFactor;
var
  glx1, gly1: GDBDouble;
//  fv1: GDBVertex;
begin
  {$IFDEF PERFOMANCELOG}log.programlog.LogOutStrFast('TOGLWnd.DISP_ZoomFactor',lp_incPos);{$ENDIF}
  //gdb.GetCurrentDWG.UndoStack.PushChangeCommand(@gdb.GetCurrentDWG.pcamera^.prop,sizeof(GDBCameraBaseProp));
  with gdb.GetCurrentDWG.UndoStack.PushCreateTGChangeCommand(gdb.GetCurrentDWG.pcamera^.prop)^ do
  begin
        CalcOptimalMatrix;
        glx1 := param.md.mouseray.lbegin.x;
        gly1 := param.md.mouseray.lbegin.y;
        if param.projtype = ProjParalel then
          gdb.GetCurrentDWG.pcamera^.prop.zoom := gdb.GetCurrentDWG.pcamera^.prop.zoom * x
        else
        begin
          gdb.GetCurrentDWG.pcamera^.prop.point.x := gdb.GetCurrentDWG.pcamera^.prop.point.x + (gdb.GetCurrentDWG.pcamera^.prop.look.x *
          (gdb.GetCurrentDWG.pcamera^.zmax - gdb.GetCurrentDWG.pcamera^.zmin) * sign(x - 1) / 100);
          gdb.GetCurrentDWG.pcamera^.prop.point.y := gdb.GetCurrentDWG.pcamera^.prop.point.y + (gdb.GetCurrentDWG.pcamera^.prop.look.y *
          (gdb.GetCurrentDWG.pcamera^.zmax - gdb.GetCurrentDWG.pcamera^.zmin) * sign(x - 1) / 100);
          gdb.GetCurrentDWG.pcamera^.prop.point.z := gdb.GetCurrentDWG.pcamera^.prop.point.z + (gdb.GetCurrentDWG.pcamera^.prop.look.z *
          (gdb.GetCurrentDWG.pcamera^.zmax - gdb.GetCurrentDWG.pcamera^.zmin) * sign(x - 1) / 100);
        end;

        CalcOptimalMatrix;
        mouseunproject(param.md.mouse.x, clientheight-param.md.mouse.y);
        if param.projtype = ProjParalel then
        begin
        gdb.GetCurrentDWG.pcamera^.prop.point.x := gdb.GetCurrentDWG.pcamera^.prop.point.x - (glx1 - param.md.mouseray.lbegin.x);
        gdb.GetCurrentDWG.pcamera^.prop.point.y := gdb.GetCurrentDWG.pcamera^.prop.point.y - (gly1 - param.md.mouseray.lbegin.y);
        end;

        ComitFromObj;
  end;
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

    p.x:=gdb.GetCurrentDWG.pcamera^.prop.point.x;
    p.y:=gdb.GetCurrentDWG.pcamera^.prop.point.y;
    p.z:=gdb.GetCurrentDWG.pcamera^.prop.point.z;
    p.w:=0;
    glLightfv(GL_LIGHT0,
              GL_POSITION,
              @p) ;
  glMaterialf(GL_FRONT_AND_BACK,GL_SHININESS,50.000000);
    p.x:=0;
    p.y:=0;
    p.z:=0;
    p.w:=1;
  glMaterialfv(GL_FRONT_AND_BACK,GL_SPECULAR,@p);
  glLightModeli(GL_LIGHT_MODEL_TWO_SIDE,1);
  glColorMaterial(GL_FRONT_AND_BACK,GL_AMBIENT_AND_DIFFUSE);
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

procedure TOGLWnd.showcursor;
  var
    i, j: GDBInteger;
    pt:ptraceprop;
//      ir:itrec;
//  ptp:ptraceprop;
  tv1,tv2,tv3,tv4,sv1{,sv2,sv3,sv4},d1{,d2,d3,d4}:gdbvertex;
  Tempplane,plx,ply,plz:DVector4D;
    a: GDBInteger;
    scrx,scry,texture{,e}:integer;
    scrollmode:GDBBOOlean;
    LPTime:Tdatetime;

  begin
    if param.scrollmode then
                            exit;
    CalcOptimalMatrix;
    if gdb.GetCurrentDWG.SelObjArray.Count<>0 then gdb.GetCurrentDWG.SelObjArray.drawpoint;
    //oglsm.mytotalglend;
    //isOpenGLError;
    glColor3f(255, 255, 255);

    oglsm.myglEnable(GL_COLOR_LOGIC_OP);
    oglsm.myglLogicOp(GL_OR);


    Tempplane:=param.mousefrustumLCS[5];
    tempplane[3]:=(tempplane[3]-param.mousefrustumLCS[4][3])/2;
    {курсор фрустума выделения}
    if (param.md.mode and MGetSelectObject) <> 0 then
    begin
    tv1:=PointOf3PlaneIntersect(param.mousefrustumLCS[0],param.mousefrustumLCS[3],Tempplane);
    tv2:=PointOf3PlaneIntersect(param.mousefrustumLCS[1],param.mousefrustumLCS[3],Tempplane);
    tv3:=PointOf3PlaneIntersect(param.mousefrustumLCS[1],param.mousefrustumLCS[2],Tempplane);
    tv4:=PointOf3PlaneIntersect(param.mousefrustumLCS[0],param.mousefrustumLCS[2],Tempplane);
    oglsm.myglbegin(GL_LINES{_loop});
                   glVertex3dv(@tv1);
                   glVertex3dv(@tv2);
                   glVertex3dv(@tv2);
                   glVertex3dv(@tv3);
                   glVertex3dv(@tv3);
                   glVertex3dv(@tv4);
                   glVertex3dv(@tv4);
                   glVertex3dv(@tv1);
    oglsm.myglend;
    end;
    //oglsm.mytotalglend;
    //isOpenGLError;
    {оси курсора}

    {myglbegin(GL_LINES);
     glVertex3d(0,0,0);
     glVertex3d(param.md.mouse3dcoord.x,param.md.mouse3dcoord.y,param.md.mouse3dcoord.z);
    myglend;

    param.md.mouse3dcoord:=geometry.NulVertex;}

    if param.md.mode <> MGetSelectObject then
    begin
    //sv1:=VertexAdd(param.md.mouse3dcoord,gdb.GetCurrentDWG.pcamera.look);
    //sv1:=gdb.GetCurrentDWG.pcamera.point;
    sv1:=param.md.mouseray.lbegin;
    sv1:=vertexadd(sv1,gdb.GetCurrentDWG.pcamera^.CamCSOffset);

    plx:=PlaneFrom3Pont(sv1,vertexadd(param.md.mouse3dcoord,gdb.GetCurrentDWG.pcamera^.CamCSOffset),
                        vertexadd(VertexAdd(param.md.mouse3dcoord,xWCS{VertexMulOnSc(xWCS,oneVertexlength(param.md.mouse3dcoord))}),gdb.GetCurrentDWG.pcamera^.CamCSOffset));
    //oglsm.mytotalglend;
    //isOpenGLError;
    oglsm.myglbegin(GL_LINES);
    if sysvar.DISP.DISP_ColorAxis^ then glColor3f(255, 0, 0);
    tv1:=PointOf3PlaneIntersect(gdb.GetCurrentDWG.pcamera.frustumLCS[0],plx,Tempplane);
    //tv1:=sv1;
    tv2:=PointOf3PlaneIntersect(gdb.GetCurrentDWG.pcamera.frustumLCS[1],plx,Tempplane);
     glVertex3dv(@tv1);
     glVertex3dv(@tv2);
    oglsm.myglend;

    ply:=PlaneFrom3Pont(sv1,vertexadd(param.md.mouse3dcoord,gdb.GetCurrentDWG.pcamera^.CamCSOffset),
                        vertexadd(VertexAdd(param.md.mouse3dcoord,yWCS{VertexMulOnSc(xWCS,oneVertexlength(param.md.mouse3dcoord))}),gdb.GetCurrentDWG.pcamera^.CamCSOffset));
   if sysvar.DISP.DISP_ColorAxis^ then glColor3f(0, 255, 0);
    oglsm.myglbegin(GL_LINES);
    tv1:=PointOf3PlaneIntersect(gdb.GetCurrentDWG.pcamera.frustumLCS[2],ply,Tempplane);
    tv2:=PointOf3PlaneIntersect(gdb.GetCurrentDWG.pcamera.frustumLCS[3],ply,Tempplane);
     glVertex3dv(@tv1);
     glVertex3dv(@tv2);
    oglsm.myglend;

    if sysvar.DISP.DISP_DrawZAxis^ then
    begin
    plz:=PlaneFrom3Pont(sv1,vertexadd(param.md.mouse3dcoord,gdb.GetCurrentDWG.pcamera^.CamCSOffset),
                        vertexadd(VertexAdd(param.md.mouse3dcoord,zWCS{VertexMulOnSc(xWCS,oneVertexlength(param.md.mouse3dcoord))}),gdb.GetCurrentDWG.pcamera^.CamCSOffset));
    if sysvar.DISP.DISP_ColorAxis^ then glColor3f(0, 0, 255);
    oglsm.myglbegin(GL_LINES);
    tv1:=PointOf3PlaneIntersect(gdb.GetCurrentDWG.pcamera.frustumLCS[0],plz,Tempplane);
    tv2:=PointOf3PlaneIntersect(gdb.GetCurrentDWG.pcamera.frustumLCS[1],plz,Tempplane);
     glVertex3dv(@tv1);
     glVertex3dv(@tv2);
    oglsm.myglend;
    end;
    end;



    //if param.scrollmode then exit;

    glColor3f(255, 255, 255);


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
    glLoadIdentity;
    glOrtho(0.0, clientwidth, clientheight, 0.0, -1.0, 1.0);
    oglsm.myglMatrixMode(GL_MODELVIEW);
    glLoadIdentity;
    glscalef(1, -1, 1);
    oglsm.myglpushmatrix;
    gltranslated(0, -clientheight, 0);

    if param.lastonmouseobject<>nil then
                                        pGDBObjEntity(param.lastonmouseobject)^.higlight;
    //oglsm.mytotalglend;

    oglsm.myglpopmatrix;
    glColor3ub(0, 100, 100);
    oglsm.myglpushmatrix;
    gltranslated(param.csx.x + 2, -clientheight + param.csx.y - 10, 0);
    textwrite('X');
    oglsm.myglpopmatrix;
    oglsm.myglpushmatrix;
    gltranslated(param.csy.x + 2, -clientheight + param.csy.y - 10, 0);
    textwrite('Y');
    oglsm.myglpopmatrix;
    oglsm.myglpushmatrix;
    gltranslated(param.csz.x + 2, -clientheight + param.csz.y - 10, 0);
    textwrite('Z');
    oglsm.myglpopmatrix;
    glLoadIdentity;
    //glColor3ub(255, 255, 255);
    glcolor3ub(not(sysvar.RD.RD_BackGroundColor^.r),not(sysvar.RD.RD_BackGroundColor^.g),not(sysvar.RD.RD_BackGroundColor^.b));

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

    oglsm.myglLogicOp(GL_XOR);

    //oglsm.mytotalglend;
    //isOpenGLError;

    if param.seldesc.MouseFrameON then
    begin
      if param.seldesc.MouseFrameInverse then
      begin
      oglsm.myglLineStipple(1, $F0F0);
      oglsm.myglEnable(GL_LINE_STIPPLE);
      end;
      oglsm.myglbegin(GL_line_loop);
      glVertex2i(param.seldesc.Frame1.x, param.seldesc.Frame1.y);
      glVertex2i(param.seldesc.Frame2.x, param.seldesc.Frame1.y);
      glVertex2i(param.seldesc.Frame2.x, param.seldesc.Frame2.y);
      glVertex2i(param.seldesc.Frame1.x, param.seldesc.Frame2.y);
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

    if gdb.GetCurrentDWG<>nil then

    //if gdb.GetCurrentDWG.SelObjArray.Count<>0 then gdb.GetCurrentDWG.SelObjArray.drawpoint;
    if tocommandmcliccount=0 then a:=1
                             else a:=0;
    if param.ontrackarray.total <> 0 then
    begin
      for i := a to param.ontrackarray.total - 1 do
      begin
       oglsm.myglbegin(GL_LINES);
       glcolor3f(1, 1, 0);
        glvertex2d(param.ontrackarray.otrackarray[i].dispcoord.x,
                   clientheight - param.ontrackarray.otrackarray[i].dispcoord.y + marksize);
        glvertex2d(param.ontrackarray.otrackarray[i].dispcoord.x,
                   clientheight - param.ontrackarray.otrackarray[i].dispcoord.y - marksize);
        glvertex2d(param.ontrackarray.otrackarray[i].dispcoord.x + marksize,
                   clientheight - param.ontrackarray.otrackarray[i].dispcoord.y);
        glvertex2d(param.ontrackarray.otrackarray[i].dispcoord.x - marksize,
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
        glcolor3f(1, 1, 1);
        if param.ontrackarray.otrackarray[i].arraydispaxis.Count <> 0 then
        begin;
        pt:=param.ontrackarray.otrackarray[i].arraydispaxis.PArray;
        for j := 0 to param.ontrackarray.otrackarray[i].arraydispaxis.count - 1 do
          begin
            if pt.trace then
            begin
              glvertex2d(param.ontrackarray.otrackarray[i].dispcoord.x, clientheight - param.ontrackarray.otrackarray[i].dispcoord.y);
              glvertex2d(pt.dispraycoord.x, clientheight - pt.dispraycoord.y);
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
      glcolor3f(1, 1, 0);
      gltranslated(param.ospoint.dispcoord.x, clientheight - param.ospoint.dispcoord.y,0);
      oglsm.mygllinewidth(2);
        glscaled(sysvar.DISP.DISP_OSSize^,sysvar.DISP.DISP_OSSize^,sysvar.DISP.DISP_OSSize^);
        if (param.ospoint.ostype = os_begin)or(param.ospoint.ostype = os_end) then
        begin oglsm.myglbegin(GL_line_loop);
              glVertex2d(-1, 1);
              glVertex2d(1, 1);
              glVertex2d(1, -1);
              glVertex2d(-1, -1);
              oglsm.myglend;
        end
        else
        if (param.ospoint.ostype = os_midle) then
        begin oglsm.myglbegin(GL_lines{_loop});
                  glVertex2f(0, -1);
                  glVertex2f(0.8660254037844, 0.5);
                  glVertex2f(0.8660254037844, 0.5);
                  glVertex2f(-0.8660254037844,0.5);
                  glVertex2f(-0.8660254037844,0.5);
                  glVertex2f(0, -1);
              oglsm.myglend;end
        else
        if (param.ospoint.ostype = os_1_4)or(param.ospoint.ostype = os_3_4) then
        begin oglsm.myglbegin(GL_lines);
                                       glVertex2f(-0.5, 1);
                                       glVertex2f(-0.5, -1);
                                       glVertex2f(-0.2, -1);
                                       glVertex2f(0.15, 1);
                                       glVertex2f(0.5, -1);
                                       glVertex2f(0.15, 1);
              oglsm.myglend;end
        else
        if (param.ospoint.ostype = os_center)then
                                                 circlepointoflod[8].DrawGeometry
        else
        if (param.ospoint.ostype = os_q0)or(param.ospoint.ostype = os_q1)
         or(param.ospoint.ostype = os_q2)or(param.ospoint.ostype = os_q3) then
        begin oglsm.myglbegin(GL_lines{_loop});
                                            glVertex2f(-1, 0);
                                            glVertex2f(0, 1);
                                            glVertex2f(0, 1);
                                            glVertex2f(1, 0);
                                            glVertex2f(1, 0);
                                            glVertex2f(0, -1);
                                            glVertex2f(0, -1);
                                            glVertex2f(-1, 0);
              oglsm.myglend;end
        else
        if (param.ospoint.ostype = os_1_3)or(param.ospoint.ostype = os_2_3) then
        begin oglsm.myglbegin(GL_lines);
                                        glVertex2f(-0.5, 1);
                                        glVertex2f(-0.5, -1);
                                        glVertex2f(0, 1);
                                        glVertex2f(0, -1);
                                        glVertex2f(0.5, 1);
                                        glVertex2f(0.5, -1);
              oglsm.myglend;end
        else
        if (param.ospoint.ostype = os_point) then
        begin oglsm.myglbegin(GL_lines);
                                        glVertex2f(-1, 1);
                                        glVertex2f(1, -1);
                                        glVertex2f(-1, -1);
                                        glVertex2f(1, 1);
              oglsm.myglend;end
        else
        if (param.ospoint.ostype = os_intersection) then
        begin oglsm.myglbegin(GL_lines);
                                        glVertex2f(-1, 1);
                                        glVertex2f(1, -1);
                                        glVertex2f(-1, -1);
                                        glVertex2f(1, 1);
              oglsm.myglend;end
        else
        if (param.ospoint.ostype = os_apparentintersection) then
        begin oglsm.myglbegin(GL_lines);
                                        glVertex2f(-1, 1);
                                        glVertex2f(1, -1);
                                        glVertex2f(-1, -1);
                                        glVertex2f(1, 1);
              oglsm.myglend;oglsm.myglbegin(GL_lines{_loop});
                                        glVertex2f(-1, 1);
                                        glVertex2f(1, 1);
                                        glVertex2f(1, 1);
                                        glVertex2f(1, -1);
                                        glVertex2f(1, -1);
                                        glVertex2f(-1, -1);
                                        glVertex2f(-1, -1);
                                        glVertex2f(-1, 1);
              oglsm.myglend;end
        else
        if (param.ospoint.ostype = os_textinsert) then
        begin oglsm.myglbegin(GL_lines);
                                        glVertex2f(-1, 0);
                                        glVertex2f(1, 0);
                                        glVertex2f(0, 1);
                                        glVertex2f(0, -1);
               oglsm.myglend;end
        else
        if (param.ospoint.ostype = os_perpendicular) then
        begin oglsm.myglbegin(GL_LINES{_STRIP});
                                            glVertex2f(-1, -1);
                                            glVertex2f(-1, 1);
                                            glVertex2f(-1, 1);
                                            glVertex2f(1,1);
              oglsm.myglend;
              oglsm.myglbegin(GL_LINES{_STRIP});
                                            glVertex2f(-1, 0);
                                            glVertex2f(0, 0);
                                            glVertex2f(0, 0);
                                            glVertex2f(0,1);
              oglsm.myglend;end
        else
        if (param.ospoint.ostype = os_trace) then
        begin
             oglsm.myglbegin(GL_LINES);
                       glVertex2f(-1, -0.5);glVertex2f(1, -0.5);
                       glVertex2f(-1,  0.5);glVertex2f(1,  0.5);
              oglsm.myglend;
        end
        else if (param.ospoint.ostype = os_nearest) then
        begin oglsm.myglbegin(GL_lines{_loop});
                                            glVertex2d(-1, 1);
                                            glVertex2d(1, 1);
                                            glVertex2d(1, 1);
                                            glVertex2d(-1, -1);
                                            glVertex2d(-1, -1);
                                            glVertex2d(1, -1);
                                            glVertex2d(1, -1);
                                            glVertex2d(-1, 1);
              oglsm.myglend;end;
      oglsm.mygllinewidth(1);
    end;

    //oglsm.mytotalglend;
    //isOpenGLError;

   //{$ENDREGION}
    oglsm.myglMatrixMode(GL_PROJECTION);
    //glLoadIdentity;
    //gdb.GetCurrentDWG.pcamera^.projMatrix:=onematrix;
    if gdb.GetCurrentDWG<>nil then
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
    CalcOptimalMatrix;
    if param.cslen<>0 then {переделать}
    begin
    oglsm.myglbegin(GL_lines);
    oglsm.myglColor3ub(255, 0, 0);
    oglsm.myglVertex3d(param.CSIconCoord);
    oglsm.myglVertex3d(createvertex(param.CSIconCoord.x + 100/param.cslen, param.CSIconCoord.y , param.CSIconCoord.z));
    oglsm.myglColor3ub(0, 255, 0);
    oglsm.myglVertex3d(param.CSIconCoord);
    oglsm.myglVertex3d(createvertex(param.CSIconCoord.x, param.CSIconCoord.y + 100/param.cslen, param.CSIconCoord.z));
    oglsm.myglColor3ub(0, 0, 255);
    oglsm.myglVertex3d(param.CSIconCoord);
    oglsm.myglVertex3d(createvertex(param.CSIconCoord.x, param.CSIconCoord.y, param.CSIconCoord.z + 100/param.cslen));
    oglsm.myglend;
    end;
    end;
    //oglsm.mytotalglend;
    //isOpenGLError;
    oglsm.myglDisable(GL_COLOR_LOGIC_OP);
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
               glbindtexture(GL_TEXTURE_2D,myscrbuf[texture]);
               //isOpenGLError;
               glCopyTexSubImage2D(GL_TEXTURE_2D,0,0,0,scrx,scry,texturesize,texturesize);
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
begin
  {$IFDEF PERFOMANCELOG}log.programlog.LogOutStrFast('TOGLWnd.RestoreBuffers',lp_incPos);{$ENDIF};
  oglsm.myglEnable(GL_TEXTURE_2D);
  oglsm.myglDisable(GL_DEPTH_TEST);
       oglsm.myglMatrixMode(GL_PROJECTION);
       oglsm.myglPushMatrix;
       glLoadIdentity;
       glOrtho(0.0, ClientWidth, 0.0, ClientHeight, -10.0, 10.0);
       oglsm.myglMatrixMode(GL_MODELVIEW);
       oglsm.myglPushMatrix;
       glLoadIdentity;
  begin
   scrx:=0;
   scry:=0;
   texture:=0;
   repeat
   repeat
         glbindtexture(GL_TEXTURE_2D,myscrbuf[texture]);
         //isOpenGLError;
         glColor3f(1, 1, 1);
         oglsm.myglbegin(GL_quads);
                 glTexCoord2d(0,0);
                 glVertex3d(scrx,scry,0);
                 glTexCoord2d(1,0);
                 glVertex3d(scrx+texturesize,scry,0);
                 glTexCoord2d(1,1);
                 glVertex3d(scrx+texturesize,scry+texturesize,0);
                 glTexCoord2d(0,1);
                 glVertex3d(scrx,scry+texturesize,0);
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
     gdb.GetCurrentDWG.pcamera.DRAWNOTEND:=treerender(gdb.GetCurrentROOT^.ObjArray.ObjTree,lptime);
     self.SaveBuffers;
     self.showcursor;
     self.SwapBuffers;
end;
procedure TOGLWnd.drawdebuggeometry;
begin



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

  const msec=1;
begin
  //isOpenGLError;
  if not assigned(gdb.GetCurrentDWG) then exit;
LPTime:=now();
if param.firstdraw then
                 inc(gdb.GetCurrentDWG.pcamera^.DRAWCOUNT);

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
  glClearColor(sysvar.RD.RD_BackGroundColor^.r/255,
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
                                       oglsm.myglEnable( GL_BLEND );
                                       glBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );
                                       oglsm.myglEnable(GL_LINE_SMOOTH);
                                       glHint(GL_LINE_SMOOTH_HINT,GL_NICEST);
                                  end
                              else
                                  begin
                                       oglsm.myglDisable(GL_BLEND);
                                       oglsm.myglDisable(GL_LINE_SMOOTH);
                                  end;
 if gdb.GetCurrentROOT.ObjArray.Count=1 then
                                                    tick:=0;

 oglsm.myglStencilFunc(gl_always,0,1);
 oglsm.myglStencilOp(GL_KEEP,GL_KEEP,GL_KEEP);


  if gdb.GetCurrentDWG<>nil then
  begin
  if sysvar.RD.RD_Restore_Mode^=WND_AccumBuffer then
  begin
  if param.firstdraw = true then
  begin
    glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT or GL_STENCIL_BUFFER_BIT);
    DrawGrid;
    render(gdb.GetCurrentROOT^);
    glaccum(GL_LOAD,1);
    inc(param.subrender);
    render(gdb.GetCurrentDWG.ConstructObjRoot);
    gdb.GetCurrentDWG.SelObjArray.remappoints;
    gdb.GetCurrentDWG.SelObjArray.drawobj(gdb.GetCurrentDWG.pcamera.POSCOUNT);
    dec(param.subrender);
    showcursor;
    //param.firstdraw := false;
  end
  else
  begin
    oglsm.myglDisable(GL_DEPTH_TEST);
    glaccum(GL_return,1);
    inc(param.subrender);
    render(gdb.GetCurrentDWG.ConstructObjRoot);
    gdb.GetCurrentDWG.SelObjArray.drawobj(gdb.GetCurrentDWG.pcamera.POSCOUNT);
    dec(param.subrender);
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
    glDrawBuffer(GL_AUX0);
     glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT or GL_STENCIL_BUFFER_BIT);
    DrawGrid;
    render(gdb.GetCurrentROOT^);
    gdb.GetCurrentROOT.DrawBB;
    glDrawBuffer(GL_BACK);
    glReadBuffer(GL_AUX0);
    glcopypixels(0, 0, clientwidth, clientheight, GL_COLOR);
    oglsm.myglDisable(GL_DEPTH_TEST);
    inc(param.subrender);
    render(gdb.GetCurrentDWG.ConstructObjRoot);
    gdb.GetCurrentDWG.SelObjArray.remappoints;
    gdb.GetCurrentDWG.SelObjArray.drawobj(gdb.GetCurrentDWG.pcamera.POSCOUNT);
    dec(param.subrender);
    showcursor;
    //param.firstdraw := false;
  end
  else
  begin
    oglsm.myglDisable(GL_DEPTH_TEST);
    begin
         glDrawBuffer(GL_BACK);
         glReadBuffer(GL_AUX0);
         glcopypixels(0, 0, clientwidth, clientheight, GL_COLOR);
    end;
    inc(param.subrender);
    render(gdb.GetCurrentDWG.ConstructObjRoot);
    gdb.GetCurrentDWG.SelObjArray.drawobj(gdb.GetCurrentDWG.pcamera.POSCOUNT);
    showcursor;
    CalcOptimalMatrix;
    dec(param.subrender);
    oglsm.myglEnable(GL_DEPTH_TEST);
    glReadBuffer(GL_BACK);
  end;
  end
else if sysvar.RD.RD_Restore_Mode^=WND_DrawPixels then
  begin
  if param.firstdraw = true then
  begin
     glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT or GL_STENCIL_BUFFER_BIT);
    oglsm.myglDisable(GL_LIGHTING);
    DrawGrid;
    render(gdb.GetCurrentROOT^);
    glreadpixels(0, 0, clientwidth, clientheight, GL_BGRA_EXT, gl_unsigned_Byte, param.pglscreen);
    inc(param.subrender);
    render(gdb.GetCurrentDWG.ConstructObjRoot);
    gdb.GetCurrentDWG.SelObjArray.remappoints;
    gdb.GetCurrentDWG.SelObjArray.drawobj(gdb.GetCurrentDWG.pcamera.POSCOUNT);
    dec(param.subrender);
    showcursor;
    //param.firstdraw := false;
  end
  else
  begin


    oglsm.myglDisable(GL_DEPTH_TEST);
    begin
         oglsm.myglMatrixMode(GL_PROJECTION);
         oglsm.myglPushMatrix;
         glLoadIdentity;
         glOrtho(0.0, ClientWidth, 0.0, ClientHeight, -10.0, 1.0);
         oglsm.myglMatrixMode(GL_MODELVIEW);
         oglsm.myglPushMatrix;
         glLoadIdentity;
         glRasterPos2i(0, 0);
         oglsm.myglDisable(GL_DEPTH_TEST);
         glDrawPixels(ClientWidth, ClientHeight, GL_BGRA_EXT, GL_UNSIGNED_Byte, param.pglscreen);
         oglsm.myglPopMatrix;
         oglsm.myglMatrixMode(GL_PROJECTION);
         oglsm.myglPopMatrix;
         oglsm.myglMatrixMode(GL_MODELVIEW);
    end;
    inc(param.subrender);
    render(gdb.GetCurrentDWG.ConstructObjRoot);
    gdb.GetCurrentDWG.SelObjArray.drawobj(gdb.GetCurrentDWG.pcamera.POSCOUNT);
    dec(param.subrender);
    showcursor;
    CalcOptimalMatrix;
    oglsm.myglEnable(GL_DEPTH_TEST);


  end;
  end
else if sysvar.RD.RD_Restore_Mode^=WND_NewDraw then
  begin
    oglsm.myglDisable(GL_LIGHTING);
     glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT or GL_STENCIL_BUFFER_BIT);
    DrawGrid;
    inc(param.subrender);
    render(gdb.GetCurrentROOT^);
    dec(param.subrender);
    inc(param.subrender);
    gdb.GetCurrentDWG.SelObjArray.remappoints;
    gdb.GetCurrentDWG.SelObjArray.drawobj(gdb.GetCurrentDWG.pcamera.POSCOUNT);
    dec(param.subrender);
    showcursor;
    //param.firstdraw := false;
    gdb.GetCurrentDWG.SelObjArray.remappoints;
  end
else if sysvar.RD.RD_Restore_Mode^=WND_Texture then
  begin
  if param.firstdraw = true then
  begin
    //isOpenGLError;
    oglsm.mytotalglend;

    glReadBuffer(GL_back);
     glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT or GL_STENCIL_BUFFER_BIT);

    //oglsm.myglEnable(GL_STENCIL_TEST);
    CalcOptimalMatrix;
    if sysvar.RD.RD_UseStencil<>nil then
    if sysvar.RD.RD_UseStencil^ then
    begin
    oglsm.myglStencilFunc(GL_NEVER, 1, 0); // значение mask не используется
    oglsm.myglStencilOp(GL_REPLACE, GL_KEEP, GL_KEEP);
    gdb.GetCurrentDWG.SelObjArray.drawobject(gdb.GetCurrentDWG.pcamera.POSCOUNT);

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
                                               gdb.GetCurrentROOT^.ObjArray.ObjTree.draw;
                                           //else
                                              begin
                                              startrender;
                                              gdb.GetCurrentDWG.pcamera.DRAWNOTEND:=treerender(gdb.GetCurrentROOT^.ObjArray.ObjTree,lptime);
                                              //oglsm.mytotalglend;
                                              //isOpenGLError;
                                              //render(gdb.GetCurrentROOT^);
                                              endrender;
                                              end;



                                                  //oglsm.mytotalglend;


    gdb.GetCurrentROOT.DrawBB;

        oglsm.mytotalglend;


    self.SaveBuffers;

    oglsm.myglDisable(GL_DEPTH_TEST);
    inc(param.subrender);
    if commandmanager.pcommandrunning<>nil then
                                               commandmanager.pcommandrunning^.DrawHeplGeometry;

    scrollmode:=GDB.GetCurrentDWG^.OGLwindow1.param.scrollmode;
    GDB.GetCurrentDWG.OGLwindow1.param.scrollmode:=true;

    render(gdb.GetCurrentDWG.ConstructObjRoot);


        //oglsm.mytotalglend;


    GDB.GetCurrentDWG.OGLwindow1.param.scrollmode:=scrollmode;
    gdb.GetCurrentDWG.ConstructObjRoot.DrawBB;

        //oglsm.mytotalglend;


    gdb.GetCurrentDWG.SelObjArray.remappoints;
    oglsm.myglDisable(GL_STENCIL_TEST);
    gdb.GetCurrentDWG.SelObjArray.drawobj(gdb.GetCurrentDWG.pcamera.POSCOUNT);
    dec(param.subrender);
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
    inc(param.subrender);
    if gdb.GetCurrentDWG.ConstructObjRoot.ObjArray.Count>0 then
                                                    gdb.GetCurrentDWG.ConstructObjRoot.ObjArray.Count:=gdb.GetCurrentDWG.ConstructObjRoot.ObjArray.Count;
    if commandmanager.pcommandrunning<>nil then
                                               commandmanager.pcommandrunning^.DrawHeplGeometry;
    scrollmode:=GDB.GetCurrentDWG.OGLwindow1.param.scrollmode;
    GDB.GetCurrentDWG.OGLwindow1.param.scrollmode:=true;
    render(gdb.GetCurrentDWG.ConstructObjRoot);

        //oglsm.mytotalglend;


    GDB.GetCurrentDWG.OGLwindow1.param.scrollmode:=scrollmode;
    gdb.GetCurrentDWG.ConstructObjRoot.DrawBB;

        //oglsm.mytotalglend;



    oglsm.myglDisable(GL_STENCIL_TEST);
    gdb.GetCurrentDWG.SelObjArray.drawobj(gdb.GetCurrentDWG.pcamera.POSCOUNT);

        //oglsm.mytotalglend;


    showcursor;

        //oglsm.mytotalglend;


    dec(param.subrender);
    oglsm.myglEnable(GL_DEPTH_TEST);
  end;
  end
  end
     else begin
               glClearColor(0.6,0.6,0.6,1);
               glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
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
  param.firstdraw := false;
  {$IFDEF PERFOMANCELOG}log.programlog.LogOutStrFast('TOGLWnd.draw---{end}',lp_DecPos);{$ENDIF}
end;


function TOGLWnd.treerender(var Node:TEntTreeNode;StartTime:TDateTime):GDBboolean;
var
   currtime:TDateTime;
   Hour,Minute,Second,MilliSecond:word;
   q1,q2:gdbboolean;
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
     q1:=false;
     q2:=false;

  if Node.infrustum=gdb.GetCurrentDWG.pcamera.POSCOUNT then
  begin
       if assigned(node.pminusnode)then
                                       if node.minusdrawpos<>gdb.GetCurrentDWG.pcamera.DRAWCOUNT then
                                       begin
                                       if not treerender(node.pminusnode^,StartTime) then
                                           node.minusdrawpos:=gdb.GetCurrentDWG.pcamera.DRAWCOUNT
                                                                                     else
                                                                                         q1:=true;
                                       end;
       if assigned(node.pplusnode)then
                                      if node.plusdrawpos<>gdb.GetCurrentDWG.pcamera.DRAWCOUNT then
                                      begin
                                       if not treerender(node.pplusnode^,StartTime) then
                                           node.plusdrawpos:=gdb.GetCurrentDWG.pcamera.DRAWCOUNT
                                                                                    else
                                                                                        q2:=true;
                                      end;
       if node.nuldrawpos<>gdb.GetCurrentDWG.pcamera.DRAWCOUNT then
       begin
        Node.nul.DrawWithattrib(gdb.GetCurrentDWG.pcamera.POSCOUNT);
        node.nuldrawpos:=gdb.GetCurrentDWG.pcamera.DRAWCOUNT;
       end;
  end;
  result:=(q1) or (q2);
  //Node.drawpos:=gdb.GetCurrentDWG.pcamera.DRAWCOUNT;

  //root.DrawWithattrib(gdb.GetCurrentDWG.pcamera.POSCOUNT);
end;

procedure TOGLWnd.render;
begin
  if param.subrender = 0 then
  begin
    gdb.GetCurrentDWG.pcamera^.obj_zmax:=-nan;
    gdb.GetCurrentDWG.pcamera^.obj_zmin:=-1000000;
    gdb.GetCurrentDWG.pcamera^.totalobj:=0;
    gdb.GetCurrentDWG.pcamera^.infrustum:=0;
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
  root.{ObjArray.}DrawWithattrib(gdb.GetCurrentDWG.pcamera.POSCOUNT);
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
       if pp^.visible=gdb.GetCurrentDWG.pcamera.VISCOUNT then
       begin
       inc(_visible);
       if pp^.isonmouse(gdb.GetCurrentDWG.OnMouseObj)
       then
           begin
                inc(_isonmouse);
                pp:=pp.ReturnLastOnMouse;
                param.SelDesc.OnMouseObject:=pp;
                gdb.GetCurrentDWG.OnMouseObj.add(addr(pp));
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
  gdb.GetCurrentDWG.OnMouseObj.clear;
  param.SelDesc.OnMouseObject := nil;


  processmousenode(Node,i);

  pp:=gdb.GetCurrentDWG.OnMouseObj.beginiterate(ir);
  if pp<>nil then
                 begin
                      param.lastonmouseobject:=pp;
                      repeat
                            if pp^.vp.LastCameraPos<>gdb.GetCurrentDWG.pcamera^.POSCOUNT then
                            pp^.RenderFeedback;


                            pp:=gdb.GetCurrentDWG.OnMouseObj.iterate(ir);
                      until pp=nil;
                 end;

  {gdb.GetCurrentDWG.OnMouseObj.clear;
  param.SelDesc.OnMouseObject := nil;
  param.lastonmouseobject:=nil;}

  {$IFDEF PERFOMANCELOG}log.programlog.LogOutStrFast('TOGLWnd.getonmouseobjectbytree------{end}',lp_DecPos);{$ENDIF}
end;

procedure TOGLWnd.getonmouseobject;
var
  i: GDBInteger;
  pp:PGDBObjEntity;
      ir:itrec;
begin
  {$IFDEF PERFOMANCELOG}log.programlog.LogOutStrFast('TOGLWnd.getonmouseobject',lp_IncPos);{$ENDIF}
  i := 0;
  gdb.GetCurrentDWG.OnMouseObj.clear;
  param.SelDesc.OnMouseObject := nil;
  findonmobj(pva, i);
  pp:=gdb.GetCurrentDWG.OnMouseObj.beginiterate(ir);
  if pp<>nil then
                 begin
                      param.lastonmouseobject:=pp;
                      repeat
                            if pp^.vp.LastCameraPos<>gdb.GetCurrentDWG.pcamera^.POSCOUNT then
                            pp^.RenderFeedback;


                            pp:=gdb.GetCurrentDWG.OnMouseObj.iterate(ir);
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
  gdb.GetCurrentDWG^.myGluProject2(param.ospoint.worldcoord,
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
  objects.init(100);
  if gdb.GetCurrentROOT.FindObjectsInPoint(param.ospoint.worldcoord,Objects) then
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
  end;
  project0axis;
  {GDBGetMem(param.ospoint.arrayworldaxis, sizeof(GDBWord) + param.ppolaraxis^.count * sizeof(gdbvertex));
  Move(param.ppolaraxis^, param.ospoint.arrayworldaxis^, sizeof(GDBWord) + param.ppolaraxis^.count * sizeof(gdbvertex));}
  gdb.GetCurrentDWG^.myGluProject2(param.ospoint.worldcoord,
             param.ospoint.dispcoord);
  //param.ospoint.arraydispaxis.init({$IFDEF DEBUGBUILD}'{722A886F-5616-4E8F-B94D-3A1C3D7ADBD4}',{$ENDIF}param.ospoint.arrayworldaxis.count);
  param.ospoint.arraydispaxis.clear;
  //GDBGetMem(param.ospoint.arraydispaxis, sizeof(GDBWord) + param.ospoint.arrayworldaxis.count * sizeof(traceprop));
  //param.ospoint.arraydispaxis.count := param.ospoint.arrayworldaxis.count;
  pv:=param.ospoint.arrayworldaxis.PArray;
  for i := 0 to param.ospoint.arrayworldaxis.count - 1 do
  begin
    gdb.GetCurrentDWG^.myGluProject2(createvertex(param.ospoint.worldcoord.x + pv.x, param.ospoint.worldcoord.y + pv.y, param.ospoint.worldcoord.z + pv.z),
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
  gdb.GetCurrentDWG^.myGluProject2(param.ospoint.worldcoord,
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
  objects.init(100);
  if gdb.GetCurrentROOT.FindObjectsInPoint(param.ontrackarray.otrackarray[0].worldcoord,Objects) then
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
  if sysvar.dwg.DWG_PolarMode^ = 0 then exit;
  if param.ontrackarray.total = 0 then exit;
  param.polarlinetrace := 0;

    if tocommandmcliccount=0 then a:=1
                             else a:=0;

  for j := a to param.ontrackarray.total - 1 do
  begin
    gdb.GetCurrentDWG^.myGluProject2(param.ontrackarray.otrackarray[j].worldcoord,
               param.ontrackarray.otrackarray[j].dispcoord);
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
        gdb.GetCurrentDWG^.myGluProject2(createvertex(param.ontrackarray.otrackarray[j].worldcoord.x + pv.x,
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
        if (param.ospoint.ostype=os_none)or(param.ospoint.ostype={os_intersection}os_trace) then
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
            pobj:=gdb.GetCurrentDWG.OnMouseObj.beginiterate(ir);
            if pobj<>nil then
            repeat
                  ip:=pobj.IsIntersect_Line(param.ontrackarray.otrackarray[i].worldcoord,pt.worldraycoord);

                  if ip.isintercept then
                  begin
                   gdb.GetCurrentDWG^.myGluProject2(ip.interceptcoord,temp);
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



                  pobj:=gdb.GetCurrentDWG.OnMouseObj.iterate(ir);
            until pobj=nil;
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
                                      gdb.GetCurrentDWG^.myGluProject2(ip.interceptcoord,
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

procedure TOGLWND.getosnappoint(pva: PGDBObjEntityOpenArray; radius: GDBFloat);
var
  pv,pv2:PGDBObjEntity;
  osp:os_record;
  dx,dy:GDBDouble;
//  oldit:itrec;
      ir,ir2:itrec;
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
                    param.ospoint.worldcoord.x:=round((param.md.mouseonworkplanecoord.x-SysVar.DWG.DWG_OriginGrid.x)/SysVar.DWG.DWG_StepGrid.x)*SysVar.DWG.DWG_StepGrid.x+SysVar.DWG.DWG_OriginGrid.x;
                    param.ospoint.worldcoord.y:=round((param.md.mouseonworkplanecoord.y-SysVar.DWG.DWG_OriginGrid.y)/SysVar.DWG.DWG_StepGrid.y)*SysVar.DWG.DWG_StepGrid.y+SysVar.DWG.DWG_OriginGrid.y;
                    param.ospoint.ostype:=os_snap;
               end;
          end
      else
          begin
               param.ospoint.worldcoord:=param.md.mouseray.lbegin;
          end;

  param.ospoint.PGDBObject:=nil;
  if (param.scrollmode)or(gdb.GetCurrentDWG.OnMouseObj.Count=0)then exit;
  if gdb.GetCurrentDWG.OnMouseObj.Count>0 then
     begin
     pv:=gdb.GetCurrentDWG.OnMouseObj.beginiterate(ir);
     if pv<>nil then
     repeat
     begin
       pv.startsnap(osp);
       while pv.getsnap(osp) do
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
     end;
     pv:=gdb.GetCurrentDWG.OnMouseObj.iterate(ir);
     until pv=nil;
     end;
  if ((sysvar.dwg.DWG_OSMode^ and osm_apparentintersection)<>0)or((sysvar.dwg.DWG_OSMode^ and osm_intersection)<>0)then
  begin
  if (gdb.GetCurrentDWG.OnMouseObj.Count>1)and(gdb.GetCurrentDWG.OnMouseObj.Count<10) then
  begin
  pv:=gdb.GetCurrentDWG.OnMouseObj.beginiterate(ir);
  repeat
  if pv<>nil then
  begin
  pv2:=gdb.GetCurrentDWG.OnMouseObj.beginiterate(ir2);
  if pv2<>nil then
  repeat
  if pv<>pv2 then
  begin
       pv.startsnap(osp);
       while pv.getintersect(osp,pv2) do
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
  end;
  pv2:=gdb.GetCurrentDWG.OnMouseObj.iterate(ir2);
  until pv2=nil;
  end;
  pv:=gdb.GetCurrentDWG.OnMouseObj.iterate(ir);
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
                                   gldeletetextures(1,@myscrbuf[i]);
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

                 glGenTextures(1, @myscrbuf[texture]);
                 //isOpenGLError;
                 glbindtexture(GL_TEXTURE_2D,myscrbuf[texture]);
                 //isOpenGLError;
                 glTexImage2D(GL_TEXTURE_2D,0,GL_RGB,texturesize,texturesize,0,GL_RGB,GL_UNSIGNED_BYTE,@TOGLWND.CreateScrbuf);
                 //isOpenGLError;
                 glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
                 //isOpenGLError;
                 glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
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

  gdb.GetCurrentDWG.pcamera^.prop.zoom := 0.1;
  param.projtype := Projparalel;
  param.subrender := 0;
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
  param.md.workplane.normal.x := 0;
  param.md.workplane.normal.y := {sqrt(0.1)}0;
  param.md.workplane.normal.z := {sqrt(0.9)}1;
  param.md.workplane.d := 0;
  param.scrollmode:=false;
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

  if gdb.GetCurrentDWG<>nil then
  begin
  gdb.GetCurrentDWG.pcamera^.obj_zmax:=-1;
  gdb.GetCurrentDWG.pcamera^.obj_zmin:=100000;
  initogl;
  //CalcOptimalMatrix;
  end;
end;

procedure TOGLWnd.setdeicevariable;
var a:array [0..1] of GDBDouble;
    p:pansichar;
begin
  programlog.logoutstr('TOGLWnd.SetDeiceVariable',lp_IncPos);
  glGetDoublev(GL_LINE_WIDTH_RANGE,@a);
  sysvar.RD.RD_MaxLineWidth^:=a[1];
  glGetDoublev(GL_point_size_RANGE,@a);
  sysvar.RD.RD_MaxPointSize^:=a[1];
  GDBPointer(p):=glGetString(GL_VENDOR);
  programlog.logoutstr('RD_Vendor:='+p,0);
  sysvar.RD.RD_Vendor^:=p;
  GDBPointer(p):=glGetString(GL_RENDERER);
  programlog.logoutstr('RD_Renderer:='+p,0);
  sysvar.RD.RD_Renderer^:=p;
  GDBPointer(p):=glGetString(GL_VERSION);
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
procedure TOGLWnd.setvisualprop;
const pusto=-1000;
      lpusto=pointer(0);
      different=-10001;
      ldifferent=pointer(1);
var lw:GDBInteger;
    layer:pgdblayerprop;
    //i,se:GDBInteger;
    pv:pgdbobjEntity;
        ir:itrec;
begin
  if param.seldesc.Selectedobjcount=0
  then
      begin
           if assigned(LinewBox) then
           if sysvar.dwg.DWG_CLinew^<0 then LineWbox.ItemIndex:=(sysvar.dwg.DWG_CLinew^+3)
                                       else LinewBox.ItemIndex:=((sysvar.dwg.DWG_CLinew^ div 10)+3);
           if assigned(LayerBox) then
           LayerBox.ItemIndex:=(sysvar.dwg.DWG_CLayer^);
      end
  else
      begin
           //se:=param.seldesc.Selectedobjcount;
           lw:=pusto;
           layer:=lpusto;
           pv:=gdb.GetCurrentROOT.ObjArray.beginiterate(ir);
           if pv<>nil then
           repeat
           //for i:=0 to gdb.ObjRoot.ObjArray.Count-1 do
           begin
                if pv^.Selected
                then
                    begin
                         if lw=pusto then lw:=pv^.vp.LineWeight
                                      else if lw<> pv^.vp.LineWeight then lw:=different;
                         if layer=lpusto then layer:=pv^.vp.layer
                                      else if layer<> pv^.vp.layer then layer:=ldifferent;
                    end;
                if (layer=ldifferent)and(lw=different) then system.Break;
           end;
           pv:=gdb.GetCurrentROOT.ObjArray.iterate(ir);
           until pv=nil;
           if assigned(LinewBox)then
           if lw=different then
                               LinewBox.ItemIndex:=(LinewBox.Items.Count-1)
                           else
                               begin
                                    if lw<0 then LinewBox.ItemIndex:=(lw+3)
                                            else LinewBox.ItemIndex:=((lw div 10)+3)
                               end;
           if assigned(LayerBox)then
           if layer=ldifferent then
                                  LayerBox.ItemIndex:=(LayerBox.Items.Count-1)
                           else
                               begin
                                    LayerBox.ItemIndex:=(gdb.GetCurrentDWG.LayerTable.GetIndexByPointer(layer));
                               end;
      end;
end;
procedure TOGLWnd.addoneobject;
//const //pusto=-1000;
      //different=-10001;
var lw,layer:GDBInteger;
begin
  lw:=PGDBObjEntity(param.SelDesc.LastSelectedObject)^.vp.LineWeight;
  layer:=gdb.GetCurrentDWG.LayerTable.GetIndexByPointer(PGDBObjEntity(param.SelDesc.LastSelectedObject)^.vp.layer);
  if param.seldesc.Selectedobjcount=1
  then
      begin
           if assigned(LinewBox)then
           begin
           if lw<0 then
                       begin
                            LinewBox.ItemIndex:=(lw+3)
                       end
                   else LinewBox.ItemIndex:=((lw div 10)+3);
           end;
           if assigned(LayerBox)then
           LayerBox.ItemIndex:=(layer);
      end
  else
      begin
           if assigned(LayerBox)then
           if LayerBox.ItemIndex<>layer then LayerBox.ItemIndex:=(LayerBox.Items.Count-1);
           if lw<0 then lw:=lw+3
                   else lw:=(lw div 10)+3;
           if assigned(LinewBox)then
           if LinewBox.ItemIndex<>lw then LinewBox.ItemIndex:=(LinewBox.Items.Count-1);
      end;
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
begin
      if Key=VK_ESCAPE then
      begin
        ClearOntrackpoint;
        if commandmanager.pcommandrunning=nil then
          begin
          gdb.GetCurrentROOT.ObjArray.DeSelect;
          param.SelDesc.LastSelectedObject := nil;
          param.SelDesc.OnMouseObject := nil;
          param.seldesc.Selectedobjcount:=0;
          param.firstdraw := TRUE;
          gdb.GetCurrentDWG.SelObjArray.clearallobjects;
          CalcOptimalMatrix;
          paint;
          setvisualprop;
          setobjinsp;
          end
        else
          begin
               commandmanager.pcommandrunning.CommandCancel;
               commandmanager.executecommandend;
          end;
        Key:=0;
      end
 else if (Key = VK_A) and (shift=[ssCtrl]) then
      begin
        commandmanager.ExecuteCommand('SelectAll');
        Key:=00;
      end
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
           commandmanager.executelastcommad;
           Key:=00;
      end
 else if (Key=VK_V)and(shift=[ssctrl]) then
                    begin
                         commandmanager.executecommand('PasteClip');
                         key:=00;
                    end
end;
function ProjectPoint(pntx,pnty,pntz:gdbdouble;var wcsLBN,wcsRTF,dcsLBN,dcsRTF: GDBVertex):gdbvertex;
begin
     gdb.GetCurrentDWG^.myGluProject2(CreateVertex(pntx,pnty,pntz),
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
  param.mousefrustum   :=CalcDisplaySubFrustum(param.md.glmouse.x,param.md.glmouse.y,td,td,gdb.getcurrentdwg.pcamera.modelMatrix,gdb.getcurrentdwg.pcamera.projMatrix);;
  param.mousefrustumLCS:=CalcDisplaySubFrustum(param.md.glmouse.x,param.md.glmouse.y,td,td,gdb.getcurrentdwg.pcamera.modelMatrixLCS,gdb.getcurrentdwg.pcamera.projMatrixLCS);;
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
  glLoadIdentity;
  gluPickMatrix(param.md.glmouse.x, {gdb.GetCurrentDWG.pcamera^.viewport[3]-} param.md.glmouse.y, sysvar.DISP.DISP_CursorSize^ * 2, sysvar.DISP.DISP_CursorSize^ * 2, PTViewPortArray(@gdb.GetCurrentDWG.pcamera^.viewport)^);
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
  glGetDoublev(GL_PROJECTION_MATRIX, @tm);
  param.mouseclipmatrix := MatrixMultiply(gdb.GetCurrentDWG.pcamera^.projMatrix, tm);
  param.mouseclipmatrix := MatrixMultiply(gdb.GetCurrentDWG.pcamera^.modelMatrix, param.mouseclipmatrix);
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
  readpalette;
end.

