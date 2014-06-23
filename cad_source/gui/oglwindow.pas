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

   uzglabstractdrawer,uzglopengldrawer,gdbdrawcontext,commandlinedef,uinfoform,ugdbdrawingdef,GDBCamera,zcadsysvars,UGDBLayerArray,zcadstrconsts,{ucxmenumgr,}
  {$IFDEF LCLGTK2}
  //x,xlib,{x11,}{xutil,}
  gtk2,gdk2,{gdk2x,}
  {$ENDIF}
  ugdbabstractdrawing,UGDBOpenArrayOfPV,ugdbfont,
  {$IFNDEF DELPHI}LCLType,InterfaceBase,FileUtil,{$ELSE}windows,{$ENDIF}
  {umytreenode,}menus,Classes,Forms,
  ExtCtrls,Controls,
  GDBGenericSubEntry,gdbasetypes,sysutils,
  {$IFNDEF DELPHI}{GLext,gl,glu,}OpenGLContext,{$ELSE}dglOpenGL,UOpenGLControl,{$ENDIF}
  Math,gdbase,varmandef,varman,UUnitManager,
  oglwindowdef,UGDBSelectedObjArray,GDBEntity,

  GDBHelpObj,
  commandline,

  zglline3d,

  sysinfo,
  UGDBVisibleOpenArray,
  UGDBPoint3DArray,
  strproc,OGLSpecFunc,memman,
  log,UGDBEntTree,sltexteditor,abstractviewarea;
const

  {ontracdist=10;
  ontracignoredist=25;}
  texturesize=256;
type
  PTOGLWnd = ^TOGLWnd;


  { TOGLWnd }

  TOGLWnd = class({TPanel}TOpenGLControl)
  private
  public
    OGLContext:TOGLContextDesk;
    wa:TAbstractViewArea;

    procedure draw;virtual;
    procedure finishdraw(var RC:TDrawContext);virtual;
    procedure mypaint(sender:tobject);

    destructor Destroy; override;


    procedure GDBActivate;
    procedure GDBActivateGLContext;

    {LCL}
    protected
    procedure EraseBackground(DC: HDC);{$IFNDEF DELPHI}override;{$ENDIF}
  end;
const maxgrid=100;
var
  testform:tform;


  tick:cardinal;
  dt:integer;

  gridarray:array [0..maxgrid,0..maxgrid] of GDBvertex2S;
  //InfoForm:TInfoForm=nil;

//function timeSetEvent(uDelay, uReolution: UINT; lpTimeProc: GDBPointer;dwUser: DWord; fuEvent: UINT): GDBInteger; stdcall; external 'winmm';
//function timeKillEvent(uID: UINT): GDBInteger; stdcall; external 'winmm';

{procedure startup;
procedure finalize;}
function docorrecttogrid(point:GDBVertex;need:GDBBoolean):GDBVertex;
//function getsortedindex(cl:integer):integer;
implementation
uses {mainwindow,}UGDBTracePropArray,{GDBEntity,}{io,}geometry,gdbobjectsconstdef,{UGDBDescriptor,}zcadinterface,
     shared,{cmdline,}GDBText;
procedure TOGLWnd.EraseBackground(DC: HDC);
begin
     dc:=0;
end;
procedure TOGLWnd.mypaint;
begin
     wa.param.firstdraw:=true;
     draw;
     inherited;
end;
procedure TOGLWnd.GDBActivateGLContext;
begin
                                      MyglMakeCurrent(OGLContext);
                                      isOpenGLError;
end;

procedure TOGLWnd.GDBActivate;
begin
    wa.pdwg.SetCurrentDWG;
    self.wa.param.firstdraw:=true;
    GDBActivateGLContext;
    //paint;
    invalidate;
  if assigned(updatevisibleproc) then updatevisibleproc;
end;
procedure TOGLWnd.finishdraw;
  var
    LPTime:Tdatetime;
begin
     //inc(sysvar.debug.int1);
     wa.CalcOptimalMatrix;
     wa.RestoreBuffers;
     LPTime:=now();
     wa.PDWG.Getpcamera.DRAWNOTEND:=wa.treerender(wa.PDWG.GetCurrentROOT^.ObjArray.ObjTree,lptime,rc);
     wa.SaveBuffers;
     wa.showcursor(rc);
     self.SwapBuffers;
end;
procedure TOGLWnd.draw;
var
  //ps: TPaintStruct;
//  pg:PGDBvertex2S;
  {i,}//a: GDBInteger;
//  fpss:GDBString;
  //scrx,scry,texture{,e}:integer;
//  t:gdbdouble;
  scrollmode:GDBBOOlean;
  LPTime:Tdatetime;
  DC:TDrawContext;
  const msec=1;

begin
  //isOpenGLError;
  if not assigned(wa.pdwg) then exit;
  self.MakeCurrent;
  //if not assigned(GDB.GetCurrentDWG.OGLwindow1) then exit;
  foreground.r:=not(sysvar.RD.RD_BackGroundColor^.r);
  foreground.g:=not(sysvar.RD.RD_BackGroundColor^.g);
  foreground.b:=not(sysvar.RD.RD_BackGroundColor^.b);
LPTime:=now();
dc:=wa.CreateRC;
if wa.param.firstdraw then
                 inc(wa.PDWG.Getpcamera^.DRAWCOUNT);

//wa.param.firstdraw:=true;
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
 if wa.PDWG.GetCurrentROOT.ObjArray.Count=1 then
                                                    tick:=0;

 oglsm.myglStencilFunc(gl_always,0,1);
  oglsm.myglStencilOp(GL_KEEP,GL_KEEP,GL_KEEP);


  if wa.PDWG<>nil then
  begin
  if sysvar.RD.RD_Restore_Mode^=WND_AccumBuffer then
  begin
  if wa.param.firstdraw = true then
  begin
    oglsm.myglClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT or GL_STENCIL_BUFFER_BIT);
    wa.DrawGrid;
    wa.render(wa.PDWG.GetCurrentROOT^,{subrender}dc);
    oglsm.myglaccum(GL_LOAD,1);
    inc(dc.subrender);
    wa.render(wa.PDWG.GetConstructObjRoot^,{subrender}dc);
    wa.PDWG.GetSelObjArray.remappoints(wa.PDWG.GetPcamera.POSCOUNT,wa.param.scrollmode,wa.PDWG.GetPcamera^,wa.PDWG^.myGluProject2);
    wa.PDWG.GetSelObjArray.drawobj({gdb.GetCurrentDWG.pcamera.POSCOUNT,subrender}dc);
    dec(dc.subrender);
    wa.showcursor(dc);
    //wa.param.firstdraw := false;
  end
  else
  begin
    oglsm.myglDisable(GL_DEPTH_TEST);
    oglsm.myglaccum(GL_return,1);
    inc(dc.subrender);
    wa.render(wa.PDWG.GetConstructObjRoot^,dc);
    wa.PDWG.GetSelObjArray.drawobj({gdb.GetCurrentDWG.pcamera.POSCOUNT,subrender}dc);
    dec(dc.subrender);
    wa.showcursor(dc);
    wa.CalcOptimalMatrix;
    oglsm.myglEnable(GL_DEPTH_TEST);
  end;
  end
else if sysvar.RD.RD_Restore_Mode^=WND_AuxBuffer then
  begin
  if wa.param.firstdraw = true then
  begin
    oglsm.myglDisable(GL_LIGHTING);
    oglsm.myglDrawBuffer(GL_AUX0);
     oglsm.myglClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT or GL_STENCIL_BUFFER_BIT);
    wa.DrawGrid;
    wa.render(wa.PDWG.GetCurrentROOT^,dc);
    wa.PDWG.GetCurrentROOT.DrawBB;
    oglsm.myglDrawBuffer(GL_BACK);
    oglsm.myglReadBuffer(GL_AUX0);
    oglsm.myglcopypixels(0, 0, clientwidth, clientheight, GL_COLOR);
    oglsm.myglDisable(GL_DEPTH_TEST);
    inc(dc.subrender);
    wa.render(wa.PDWG.GetConstructObjRoot^,dc);
    wa.PDWG.GetSelObjArray.remappoints(wa.PDWG.GetPcamera.POSCOUNT,wa.param.scrollmode,wa.PDWG.GetPcamera^,wa.PDWG^.myGluProject2);
    wa.PDWG.GetSelObjArray.drawobj({gdb.GetCurrentDWG.pcamera.POSCOUNT,subrender}dc);
    dec(dc.subrender);
    wa.showcursor(dc);
    //wa.param.firstdraw := false;
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
    wa.render(wa.PDWG.GetConstructObjRoot^,dc);
    wa.PDWG.GetSelObjArray.drawobj({.GetCurrentDWG.pcamera.POSCOUNT,subrender}dc);
    wa.showcursor(dc);
    wa.CalcOptimalMatrix;
    dec(dc.subrender);
    oglsm.myglEnable(GL_DEPTH_TEST);
    oglsm.myglReadBuffer(GL_BACK);
  end;
  end
else if sysvar.RD.RD_Restore_Mode^=WND_DrawPixels then
  begin
  if wa.param.firstdraw = true then
  begin
     oglsm.myglClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT or GL_STENCIL_BUFFER_BIT);
    oglsm.myglDisable(GL_LIGHTING);
    wa.DrawGrid;
    wa.render(wa.PDWG.GetCurrentROOT^,dc);
    oglsm.myglreadpixels(0, 0, clientwidth, clientheight, GL_BGRA_EXT{GL_RGBA}, gl_unsigned_Byte, wa.param.pglscreen);
    inc(dc.subrender);
    wa.render(wa.PDWG.GetConstructObjRoot^,dc);
    wa.PDWG.GetSelObjArray.remappoints(wa.PDWG.GetPcamera.POSCOUNT,wa.param.scrollmode,wa.PDWG.GetPcamera^,wa.PDWG^.myGluProject2);
    wa.PDWG.GetSelObjArray.drawobj({gdb.GetCurrentDWG.pcamera.POSCOUNT,subrender}dc);
    dec(dc.subrender);
    wa.showcursor(dc);
    //wa.param.firstdraw := false;
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
         oglsm.myglDrawPixels(ClientWidth, ClientHeight, GL_BGRA_EXT{GL_RGBA}, GL_UNSIGNED_BYTE, wa.param.pglscreen);
         oglsm.myglPopMatrix;
         oglsm.myglMatrixMode(GL_PROJECTION);
         oglsm.myglPopMatrix;
         oglsm.myglMatrixMode(GL_MODELVIEW);
    end;
    inc(dc.subrender);
    wa.render(wa.PDWG.GetConstructObjRoot^,dc);
    wa.PDWG.GetSelObjArray.drawobj({gdb.GetCurrentDWG.pcamera.POSCOUNT,subrender}dc);
    dec(dc.subrender);
    wa.showcursor(dc);
    wa.CalcOptimalMatrix;
    oglsm.myglEnable(GL_DEPTH_TEST);


  end;
  end
else if sysvar.RD.RD_Restore_Mode^=WND_NewDraw then
  begin
    oglsm.myglDisable(GL_LIGHTING);
     oglsm.myglClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT or GL_STENCIL_BUFFER_BIT);
    wa.DrawGrid;
    inc(dc.subrender);
    wa.render(wa.PDWG.GetCurrentROOT^,dc);
    dec(dc.subrender);
    inc(dc.subrender);
    wa.PDWG.GetSelObjArray.remappoints(wa.PDWG.GetPcamera.POSCOUNT,wa.param.scrollmode,wa.PDWG.GetPcamera^,wa.PDWG^.myGluProject2);
    wa.PDWG.GetSelObjArray.drawobj({gdb.GetCurrentDWG.pcamera.POSCOUNT,subrender}dc);
    dec(dc.subrender);
    wa.showcursor(dc);
    //wa.param.firstdraw := false;
    wa.PDWG.GetSelObjArray.remappoints(wa.PDWG.GetPcamera.POSCOUNT,wa.param.scrollmode,wa.PDWG.GetPcamera^,wa.PDWG^.myGluProject2);
  end
else if sysvar.RD.RD_Restore_Mode^=WND_Texture then
  begin
  if wa.param.firstdraw = true then
  begin
    //isOpenGLError;
    oglsm.mytotalglend;

    oglsm.myglReadBuffer(GL_back);
    oglsm.myglClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT or GL_STENCIL_BUFFER_BIT);

    //oglsm.myglEnable(GL_STENCIL_TEST);
    wa.CalcOptimalMatrix;
    if sysvar.RD.RD_UseStencil<>nil then
    if sysvar.RD.RD_UseStencil^ then
    begin
    oglsm.myglStencilFunc(GL_NEVER, 1, 0); // значение mask не используется
    oglsm.myglStencilOp(GL_REPLACE, GL_KEEP, GL_KEEP);
    wa.PDWG.GetSelObjArray.drawobject(dc{gdb.GetCurrentDWG.pcamera.POSCOUNT,0});

    //oglsm.mytotalglend;

    end;
    //oglsm.myglDisable(GL_LINE_SMOOTH);
    oglsm.mygllinewidth(1);
    oglsm.myglpointsize(1);
    oglsm.myglDisable(gl_point_smooth);

    oglsm.myglStencilFunc(GL_EQUAL,0,1);
    oglsm.myglStencilOp(GL_KEEP, GL_KEEP, GL_KEEP);

    //isOpenGLError;
    wa.DrawGrid;

    //oglsm.mytotalglend;

    wa.LightOn;

    if (sysvar.DWG.DWG_SystmGeometryDraw^) then
                                               begin
                                               oglsm.glcolor3ubv(palette[sysvar.SYS.SYS_SystmGeometryColor^+2].RGB);
                                               wa.PDWG.GetCurrentROOT^.ObjArray.ObjTree.draw;
                                               end;
                                           //else
                                              begin
                                              OGLSM.startrender;
                                              dc.drawer.startrender;
                                              wa.PDWG.Getpcamera.DRAWNOTEND:=wa.treerender(wa.PDWG.GetCurrentROOT^.ObjArray.ObjTree,lptime,dc);
                                              //oglsm.mytotalglend;
                                              //isOpenGLError;
                                              //render(gdb.GetCurrentROOT^);
                                              OGLSM.endrender;
                                              dc.drawer.endrender;
                                              end;



                                                  //oglsm.mytotalglend;


    wa.PDWG.GetCurrentROOT.DrawBB;

        oglsm.mytotalglend;


    wa.SaveBuffers;

    oglsm.myglDisable(GL_DEPTH_TEST);
    inc(dc.subrender);
    if commandmanager.pcommandrunning<>nil then
                                               commandmanager.pcommandrunning^.DrawHeplGeometry;

    scrollmode:={GDB.GetCurrentDWG^.OGLwindow1.}wa.param.scrollmode;
    {GDB.GetCurrentDWG.OGLwindow1.}wa.param.scrollmode:=true;

    wa.render(wa.PDWG.GetConstructObjRoot^,dc);


        //oglsm.mytotalglend;


    {GDB.GetCurrentDWG.OGLwindow1.}wa.param.scrollmode:=scrollmode;
    wa.PDWG.GetConstructObjRoot.DrawBB;

        //oglsm.mytotalglend;


    wa.PDWG.GetSelObjArray.remappoints(wa.PDWG.GetPcamera.POSCOUNT,wa.param.scrollmode,wa.PDWG.GetPcamera^,wa.PDWG^.myGluProject2);
    oglsm.myglDisable(GL_STENCIL_TEST);
    dc.MaxDetail:=true;
    wa.PDWG.GetSelObjArray.drawobj({gdb.GetCurrentDWG.pcamera.POSCOUNT,subrender}dc);
    dec(dc.subrender);
    wa.LightOff;
    wa.showcursor(dc);

        //oglsm.mytotalglend;
        //isOpenGLError;


    //wa.param.firstdraw := false;
  end
  else
  begin

      //oglsm.mytotalglend;

    wa.LightOff;
    wa.RestoreBuffers;
    //oglsm.mytotalglend;
    inc(dc.subrender);
    if wa.PDWG.GetConstructObjRoot.ObjArray.Count>0 then
                                                    wa.PDWG.GetConstructObjRoot.ObjArray.Count:=wa.PDWG.GetConstructObjRoot.ObjArray.Count;
    if commandmanager.pcommandrunning<>nil then
                                               commandmanager.pcommandrunning^.DrawHeplGeometry;
    scrollmode:={GDB.GetCurrentDWG.OGLwindow1.}wa.param.scrollmode;
    {GDB.GetCurrentDWG.OGLwindow1.}wa.param.scrollmode:=true;
    wa.render(wa.PDWG.GetConstructObjRoot^,dc);

        //oglsm.mytotalglend;


    {GDB.GetCurrentDWG.OGLwindow1.}wa.param.scrollmode:=scrollmode;
    wa.PDWG.GetConstructObjRoot.DrawBB;

        //oglsm.mytotalglend;



    oglsm.myglDisable(GL_STENCIL_TEST);
    dc.MaxDetail:=true;
    wa.PDWG.GetSelObjArray.drawobj({gdb.GetCurrentDWG.pcamera.POSCOUNT,subrender}dc);

        //oglsm.mytotalglend;

    wa.showcursor(dc);

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
                       if wa.param.firstdraw then
                                        sysvar.RD.RD_LastRenderTime^:=tick*msec;
                  end
              else begin
                       if wa.param.firstdraw then
                                              sysvar.RD.RD_LastRenderTime^:=0
                                          else
                                              sysvar.RD.RD_LastRenderTime^:=-abs(sysvar.RD.RD_LastRenderTime^);
                  end;}
  if wa.param.firstdraw then
                         sysvar.RD.RD_LastRenderTime^:=tick*msec
                     else
                         sysvar.RD.RD_LastUpdateTime^:=tick*msec;
  {$IFDEF PERFOMANCELOG}
                       if wa.param.firstdraw then
                                              log.programlog.LogOutStrFast('Draw time='+inttostr(sysvar.RD.RD_LastRenderTime^),0)
                                          else
                                              log.programlog.LogOutStrFast('ReDraw time='+inttostr(sysvar.RD.RD_LastUpdateTime^),0);
  {$ENDIF}
  //title:=title+fpss;
  if wa.param.firstdraw then
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
  wa.param.firstdraw := false;
  {$IFDEF PERFOMANCELOG}log.programlog.LogOutStrFast('TOGLWnd.draw---{end}',lp_DecPos);{$ENDIF}
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
                               result:=correcttogrid(point);
                               {result.x:=round((point.x-SysVar.DWG.DWG_Snap.Base.x)/SysVar.DWG.DWG_Snap.Spacing.x)*SysVar.DWG.DWG_Snap.Spacing.x+SysVar.DWG.DWG_Snap.Spacing.x;
                               result.y:=round((point.y-SysVar.DWG.DWG_Snap.Base.y)/SysVar.DWG.DWG_Snap.Spacing.y)*SysVar.DWG.DWG_Snap.Spacing.y+SysVar.DWG.DWG_Snap.Spacing.y;
                               result.z:=point.z;}
                          end
                      else
                          result:=point;
end;
destructor TOGLWnd.Destroy;
var
   i:integer;
begin
     wa.delmyscrbuf;
     if wa.param.pglscreen <> nil then
     GDBFreeMem(wa.param.pglscreen);
     MywglDeleteContext(OGLContext);//wglDeleteContext(hrc);
     wa.PolarAxis.done;
     if wa.param.pglscreen<>nil then
     gdbfreemem(wa.param.pglscreen);
     wa.param.ospoint.arraydispaxis.done;
     wa.param.ospoint.arrayworldaxis.done;
     for i := 0 to {wa.param.ontrackarray.total-1}3 do
                                              begin
                                              wa.param.ontrackarray.otrackarray[i].arrayworldaxis.done;
                                              wa.param.ontrackarray.otrackarray[i].arraydispaxis.done;
                                              end;
     {переделать}//inherited done;
     inherited;
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('oglwindow.initialization');{$ENDIF}
end.

