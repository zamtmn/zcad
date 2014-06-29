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

unit openglviewarea;
{$INCLUDE def.inc}
interface
uses
     {$IFDEF LCLGTK2}
     gtk2,gdk2,
     {$ENDIF}
     {$IFDEF LCLQT}
     qtwidgets,qt4,
     {$ENDIF}
     abstractviewarea,uzglopengldrawer,sysutils,UGDBEntTree,GDBGenericSubEntry,GDBHelpObj,memman,OGLSpecFunc,gdbase,gdbasetypes,
     UGDBLayerArray,ugdbltypearray,UGDBTextStyleArray,ugdbdimstylearray,
     uinfoform,oglwindow,oglwindowdef,gdbdrawcontext,varmandef,commandline,zcadsysvars,GDBEntity,Varman,zcadinterface,geometry,gdbobjectsconstdef,shared,zcadstrconsts,LCLType,
     ExtCtrls,classes,Controls,Graphics,generalviewarea,UGDBTracePropArray,math,uzglabstractdrawer,log;
type
    TOpenGLViewArea=class(TGeneralViewArea)
                      public
                      OpenGLWindow:TOGLWnd;
                      function CreateWorkArea(TheOwner: TComponent):TCADControl; override;
                      procedure CreateDrawer; override;
                      procedure SetupWorkArea; override;
                      procedure WaResize(sender:tobject); override;

                      procedure SwapBuffers(var DC:TDrawContext); override;
                      procedure LightOn(var DC:TDrawContext); override;
                      procedure LightOff(var DC:TDrawContext); override;
                      procedure DrawGrid(var DC:TDrawContext); override;
                      procedure getareacaps; override;
                      procedure GDBActivateGLContext; override;

                  end;
    TCanvasViewArea=class(TGeneralViewArea)
                      public
                      function CreateWorkArea(TheOwner: TComponent):TCADControl; override;
                      procedure CreateDrawer; override;
                      procedure SetupWorkArea; override;
                      procedure getareacaps; override;
                      procedure GDBActivateGLContext; override;
                      procedure startpaint;override;
                  end;

implementation
uses mainwindow;
procedure TOpenGLViewArea.GDBActivateGLContext;
begin
                                      MyglMakeCurrent(OpenGLWindow.OGLContext);
                                      OpenGLWindow.MakeCurrent;
                                      isOpenGLError;
end;
procedure setdeicevariable;
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
  GDBPointer(p):=oglsm.mygluGetString(GLU_VERSION);
  programlog.logoutstr('RD_GLUVersion:='+p,0);
  sysvar.RD.RD_GLUVersion^:=p;
  GDBPointer(p):=oglsm.mygluGetString(GLU_EXTENSIONS);
  programlog.logoutstr('RD_GLUExtensions:='+p,0);
  sysvar.RD.RD_GLUExtensions^:=p;
  GDBPointer(p):=oglsm.myglGetString(GL_EXTENSIONS);
  programlog.logoutstr('RD_Extensions:='+p,0);
  sysvar.RD.RD_Extensions^:=p;
  sysvar.RD.RD_MaxWidth^:=round(min(sysvar.RD.RD_MaxPointSize^,sysvar.RD.RD_MaxLineWidth^));
  programlog.logoutstr('RD_MaxWidth:='+inttostr(sysvar.RD.RD_MaxWidth^),0);
  programlog.logoutstr('end;',lp_DecPos);
end;

procedure TOpenGLViewArea.getareacaps;
{$IFDEF LCLGTK2}
var
   Widget:PGtkWidget;
{$ENDIF}
begin
  programlog.logoutstr('TOGLWnd.InitOGL',lp_IncPos);

  {$IFDEF LCLGTK2}
  Widget:=PGtkWidget(PtrUInt(OpenGLWindow.Handle));
  gtk_widget_add_events (Widget,GDK_POINTER_MOTION_HINT_MASK);
  {$ENDIF}

  MywglDeleteContext(OpenGLWindow.OGLContext);//wglDeleteContext(hrc);

  SetDCPixelFormat(OpenGLWindow.OGLContext);//SetDCPixelFormat(dc);
  MywglCreateContext(OpenGLWindow.OGLContext);//hrc := wglCreateContext(DC);
  MyglMakeCurrent(OpenGLWindow.OGLContext);//wglMakeCurrent(DC, hrc);
  OpenGLWindow.MakeCurrent();
  setdeicevariable;

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
  programlog.logoutstr('end;',lp_DecPos)
end;
procedure TOpenGLViewArea.DrawGrid;
var
  pg:PGDBvertex2S;
  i,j: GDBInteger;
  v,v1:gdbvertex;
begin
  if sysvar.DWG.DWG_DrawGrid<>nil then
  if (sysvar.DWG.DWG_DrawGrid^)and(param.md.WPPointUR.z=1) then
  begin
  v:=param.md.WPPointBL;
  dc.drawer.SetColor(100, 100, 100, 100);
  pg := @gridarray;
  oglsm.myglbegin(gl_points);
  for i := 0 to round(param.md.WPPointUR.x) do
  begin
       v1:=v;
        for j := 0 to round(param.md.WPPointUR.y) do
        begin
          oglsm.myglVertex3d(v1);
          v1.y:=v1.y+sysvar.DWG.DWG_GridSpacing.y;
          inc(pg);
        end;
        v.x:=v1.x-sysvar.DWG.DWG_GridSpacing.x;
  end;
  oglsm.myglend;
  end;
end;

procedure TOpenGLViewArea.LightOn;
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
       else LightOff(dc);
end;
procedure TOpenGLViewArea.LightOff;
begin
    oglsm.myglDisable(GL_LIGHTING);
    oglsm.myglDisable(GL_LIGHT0);
    oglsm.myglDisable(GL_COLOR_MATERIAL);
end;
procedure TOpenGLViewArea.SwapBuffers(var DC:TDrawContext);
begin
     OpenGLWindow.SwapBuffers;
end;
function TCanvasViewArea.CreateWorkArea(TheOwner: TComponent):TCADControl;
begin
     result:=TCADControl(TPanel.Create(TheOwner));
end;
procedure TCanvasViewArea.CreateDrawer;
begin
     drawer:=TZGLCanvasDrawer.Create;
     TZGLCanvasDrawer(drawer).canvas:=TPanel(getviewcontrol).canvas;
     TZGLCanvasDrawer(drawer).panel:=TPanel(getviewcontrol);
end;

procedure TCanvasViewArea.SetupWorkArea;
begin
  //self.getviewcontrol.Color:=clHighlight;
  TPanel(getviewcontrol).BorderStyle:=bsNone;
  TPanel(getviewcontrol).BevelWidth:=0;
  TPanel(getviewcontrol).onpaint:=mypaint;
end;
procedure TCanvasViewArea.getareacaps;
begin
  {$IFDEF LCLQT}
  TQtWidget(getviewcontrol.Handle).setAttribute(QtWA_PaintOutsidePaintEvent);
  //TQtWidget(getviewcontrol.Handle).setAttribute(QtWA_PaintOnScreen);
  //TQtWidget(getviewcontrol.Handle).setAttribute(QtWA_OpaquePaintEvent);
  //TQtWidget(getviewcontrol.Handle).setAttribute(QtWA_NoSystemBackground);
  {$ENDIF}
end;
procedure TCanvasViewArea.GDBActivateGLContext;
begin
end;
procedure TCanvasViewArea.startpaint;
begin
     if assigned(WorkArea) then
                                   TZGLCanvasDrawer(drawer).canvas:=WorkArea.canvas;
     inherited;
end;

function TOpenGLViewArea.CreateWorkArea(TheOwner: TComponent):TCADControl;
begin
     result:=TCADControl(TOGLWnd.Create(TheOwner));
end;
procedure TOpenGLViewArea.CreateDrawer;
begin
     drawer:=TZGLOpenGLDrawer.Create;
end;
procedure TOpenGLViewArea.SetupWorkArea;
begin
     OpenGLWindow:=TOGLWnd(WorkArea);
     OpenGLWindow.wa:=self;
     OpenGLWindow.Cursor:=crNone;
     OpenGLWindow.ShowHint:=true;
     //fillchar(myscrbuf,sizeof(tmyscrbuf),0);

     {$if FPC_FULlVERSION>=20701}
     OpenGLWindow.AuxBuffers:=0;
     OpenGLWindow.StencilBits:=8;
     //OpenGLWindow.ColorBits:=24;
     OpenGLWindow.DepthBits:=24;
     {$ENDIF}
     OpenGLWindow.onpaint:=mypaint;
end;
procedure TOpenGLViewArea.WaResize(sender:tobject);
begin
     OpenGLWindow.MakeCurrent(false);
     param.lastonmouseobject:=nil;

     //self.MakeCurrent(false);
     //isOpenGLError;

     calcoptimalmatrix;
     calcgrid;

     {переделать}//inherited size{(fwSizeType,nWidth,nHeight)};

     drawer.WorkAreaResize(getviewcontrol.clientwidth,getviewcontrol.clientheight);

     {wa.param.md.glmouse.y := clientheight-wa.param.md.mouse.y;
     CalcOptimalMatrix;
     mouseunproject(wa.param.md.GLmouse.x, wa.param.md.GLmouse.y);
     CalcMouseFrustum;}

     if param.pglscreen <> nil then
     GDBFreeMem(param.pglscreen);
     GDBGetMem({$IFDEF DEBUGBUILD}'ScreenBuf',{$ENDIF}param.pglscreen, getviewcontrol.clientwidth * getviewcontrol.clientheight * 4);

     param.height := getviewcontrol.clientheight;
     param.width := getviewcontrol.clientwidth;
     param.firstdraw := true;
     //draw;
     //paint;
     getviewcontrol.Invalidate;
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('viewareadef.initialization');{$ENDIF}
end.
