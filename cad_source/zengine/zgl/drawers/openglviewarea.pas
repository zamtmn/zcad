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
     qtwidgets,qt4,qtint,
     {$ENDIF}
     uzglgdidrawer,abstractviewarea,uzglopengldrawer,sysutils,memman,glstatemanager,gdbase,gdbasetypes,
     UGDBLayerArray,ugdbdimstylearray,
     oglwindow,oglwindowdef,gdbdrawcontext,varmandef,commandline,zcadsysvars,geometry,shared,LCLType,
     ExtCtrls,classes,Controls,Graphics,generalviewarea,math,log,backendmanager,
     {$IFNDEF DELPHI}OpenGLContext{$ENDIF};
type
    PTOGLWnd = ^TOGLWnd;
    TOGLWnd = class({TPanel}TOpenGLControl)
    private
    public
      wa:TAbstractViewArea;
      protected
      procedure EraseBackground(DC: HDC);{$IFNDEF DELPHI}override;{$ENDIF}
    end;

    TOpenGLViewArea=class(TGeneralViewArea)
                      public
                      OpenGLWindow:TOGLWnd;
                      OpenGLParam:TOpenglData;
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
                      function NeedDrawInsidePaintEvent:boolean; override;
                      procedure setdeicevariable;
                      function getParam:pointer; override;
                      function getParamTypeName:GDBString; override;

                  end;
    TCanvasViewArea=class(TGeneralViewArea)
                      public
                      GDIData:TGDIData;
                      function CreateWorkArea(TheOwner: TComponent):TCADControl; override;
                      procedure CreateDrawer; override;
                      procedure SetupWorkArea; override;
                      procedure getareacaps; override;
                      procedure GDBActivateGLContext; override;
                      function startpaint:boolean;override;
                      function NeedDrawInsidePaintEvent:boolean; override;
                      function getParam:pointer; override;
                      function getParamTypeName:GDBString; override;
                      procedure setdeicevariable;
                  end;
const
  maxgrid=100;
var
  gridarray:array [0..maxgrid,0..maxgrid] of GDBvertex2S;
implementation
//uses mainwindow;
procedure TOGLWnd.EraseBackground(DC: HDC);
begin
     dc:=0;
end;
function TOpenGLViewArea.getParam;
begin
     result:=@OpenGLParam;
end;

function TOpenGLViewArea.getParamTypeName;
begin
     result:='PTOpenglData';
end;
procedure TOpenGLViewArea.GDBActivateGLContext;
begin
                                      //MyglMakeCurrent(OpenGLWindow.OGLContext);
                                      OpenGLWindow.MakeCurrent;
                                      isOpenGLError;
end;
function TOpenGLViewArea.NeedDrawInsidePaintEvent:boolean;
begin
     result:=false;
end;

procedure TOpenGLViewArea.setdeicevariable;
var a:array [0..1] of GDBDouble;
    p:pansichar;
begin
  programlog.logoutstr('TOGLWnd.SetDeiceVariable',lp_IncPos,LM_Debug);
  oglsm.myglGetDoublev(GL_LINE_WIDTH_RANGE,@a);
  if assigned(sysvar.RD.RD_MaxLineWidth) then
  sysvar.RD.RD_MaxLineWidth^:=a[1];
  oglsm.myglGetDoublev(GL_point_size_RANGE,@a);
  if assigned(sysvar.RD.RD_MaxPointSize) then
  sysvar.RD.RD_MaxPointSize^:=a[1];
  GDBPointer(p):=oglsm.myglGetString(GL_VENDOR);
  programlog.LogOutFormatStr('RD_Vendor:="%s"',[p],0,LM_Info);
  //if assigned(OpenglParam.RD_Vendor) then
  OpenglParam.RD_Vendor:=p;
  GDBPointer(p):=oglsm.myglGetString(GL_RENDERER);
  programlog.LogOutFormatStr('RD_Renderer:="%s"',[p],0,LM_Info);
  //if assigned(OpenglParam.RD_Renderer) then
  OpenglParam.RD_Renderer:=p;
  GDBPointer(p):=oglsm.myglGetString(GL_VERSION);
  programlog.LogOutFormatStr('RD_Version:="%s"',[p],0,LM_Info);
  //if assigned(OpenglParam.RD_Version) then
  OpenglParam.RD_Version:=p;

  GDBPointer(p):=oglsm.myglGetString(GL_EXTENSIONS);
  programlog.LogOutFormatStr('RD_Extensions:="%s"',[p],0,LM_Info);
  //if assigned(OpenglParam.RD_Extensions) then
  OpenglParam.RD_Extensions:=p;
  if assigned(sysvar.RD.RD_MaxWidth) and assigned(sysvar.RD.RD_MaxLineWidth) then
  begin
  sysvar.RD.RD_MaxWidth^:=round(min(sysvar.RD.RD_MaxPointSize^,sysvar.RD.RD_MaxLineWidth^));
  programlog.LogOutFormatStr('RD_MaxWidth:="%G"',[min(sysvar.RD.RD_MaxPointSize^,sysvar.RD.RD_MaxLineWidth^)],0,LM_Info);
  end;
  programlog.logoutstr('end;',lp_DecPos,LM_Debug);
end;

procedure TOpenGLViewArea.getareacaps;
{$IFDEF LCLGTK2}
var
   Widget:PGtkWidget;
{$ENDIF}
begin
  programlog.logoutstr('TOGLWnd.InitOGL',lp_IncPos,LM_Debug);
  {$IFDEF LCLGTK2}
  Widget:=PGtkWidget(PtrUInt(OpenGLWindow.Handle));
  gtk_widget_add_events (Widget,GDK_POINTER_MOTION_HINT_MASK);
  {$ENDIF}

  //MywglDeleteContext(OpenGLWindow.OGLContext);//wglDeleteContext(hrc);

  //SetDCPixelFormat(OpenGLWindow.OGLContext);//SetDCPixelFormat(dc);
  //MywglCreateContext(OpenGLWindow.OGLContext);//hrc := wglCreateContext(DC);
  //MyglMakeCurrent(OpenGLWindow.OGLContext);//wglMakeCurrent(DC, hrc);
  OpenGLWindow.MakeCurrent();
  setdeicevariable;

  {$IFDEF WINDOWS}
  //if assigned(OpenglParam.RD_VSync) then
  if OpenglParam.RD_VSync<>T3SB_Default then
  begin
       Pointer(@wglSwapIntervalEXT) := wglGetProcAddress('wglSwapIntervalEXT');
       if @wglSwapIntervalEXT<>nil then
                                           begin
                                                if OpenglParam.RD_VSync=T3SB_True then
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
  programlog.logoutstr('end;{TOGLWnd.InitOGL}',lp_DecPos,LM_Debug);
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
    if assigned(SysVar.RD.RD_Light) then
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
end;
procedure TOpenGLViewArea.LightOff;
begin
    oglsm.myglDisable(GL_LIGHTING);
    oglsm.myglDisable(GL_LIGHT0);
    oglsm.myglDisable(GL_COLOR_MATERIAL);
end;
procedure TOpenGLViewArea.SwapBuffers(var DC:TDrawContext);
begin
     inherited;
     OpenGLWindow.SwapBuffers;
end;
function TCanvasViewArea.CreateWorkArea(TheOwner: TComponent):TCADControl;
begin
     result:=TCADControl(TGDIPanel.Create(TheOwner));
     TCADControl(result).Caption:='123';
     //TGDIPanel(result).DoubleBuffered:=false;
end;
procedure TCanvasViewArea.CreateDrawer;
begin
     drawer:=TZGLGDIDrawer.Create;
     TZGLGDIDrawer(drawer).wa:=self;
     TZGLGDIDrawer(drawer).canvas:=TCADControl(getviewcontrol).canvas;
     TZGLGDIDrawer(drawer).panel:=TCADControl(getviewcontrol);
end;

procedure TCanvasViewArea.SetupWorkArea;
begin
  //self.getviewcontrol.Color:=clHighlight;
  //TGDIPanel(getviewcontrol).BorderStyle:=bsNone;
  //TGDIPanel(getviewcontrol).BevelWidth:=0;
  TCADControl(getviewcontrol).onpaint:=mypaint;
end;
procedure TCanvasViewArea.setdeicevariable;
begin
     GDIData.RD_TextRendering:=TRT_System;
     {$IFDEF LCLWIN32}
     GDIData.RD_Renderer:='Windows GDI';
     if Win32CSDVersion<>'' then
                                GDIData.RD_Version:=inttostr(Win32MajorVersion)+'.'+inttostr(Win32MinorVersion)+' build '+inttostr(Win32BuildNumber)+' '+Win32CSDVersion
                            else
                                GDIData.RD_Version:=inttostr(Win32MajorVersion)+'.'+inttostr(Win32MinorVersion)+' build '+inttostr(Win32BuildNumber);
     {$ENDIF}
     {$IFDEF LCLQt}
     GDIData.RD_Renderer:='Qt';
     GDIData.RD_Version:=inttostr(QtVersionMajor)+'.'+inttostr(QtVersionMinor)+'.'+inttostr(QtVersionMicro);
     {$ENDIF}
     {$IFDEF LCLGTK2}
     GDIData.RD_Renderer:='GTK+';
     GDIData.RD_Version:=inttostr(gtk_major_version)+'.'+inttostr(gtk_minor_version)+'.'+inttostr(gtk_micro_version);
     {$ENDIF}
end;
procedure TCanvasViewArea.getareacaps;
begin
  {$IFDEF LCLQT}
  TQtWidget(getviewcontrol.Handle).setAttribute(QtWA_PaintOutsidePaintEvent);
  //TQtWidget(getviewcontrol.Handle).setAttribute(QtWA_PaintOnScreen);
  //TQtWidget(getviewcontrol.Handle).setAttribute(QtWA_OpaquePaintEvent);
  //TQtWidget(getviewcontrol.Handle).setAttribute(QtWA_NoSystemBackground);
  {$ENDIF}
  setdeicevariable;
end;
procedure TCanvasViewArea.GDBActivateGLContext;
begin
end;
function TCanvasViewArea.startpaint;
begin
     if assigned(WorkArea) then
                                   TZGLGDIDrawer(drawer).canvas:=WorkArea.canvas;
     result:=inherited;
end;
function TCanvasViewArea.NeedDrawInsidePaintEvent:boolean;
begin
     result:={$IFDEF LCLQT}True{$ELSE}False{$ENDIF};
end;
function TCanvasViewArea.getParam:pointer;
begin
     result:=@GDIData;
end;
function TCanvasViewArea.getParamTypeName:GDBString;
begin
     result:='PTGDIData';
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
     if assigned(sysvar.RD.RD_RemoveSystemCursorFromWorkArea) then
                                                                  RemoveCursorIfNeed(OpenGLWindow,sysvar.RD.RD_RemoveSystemCursorFromWorkArea^)
                                                              else
                                                                  RemoveCursorIfNeed(OpenGLWindow,true);
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
     inherited;
     OpenGLWindow.MakeCurrent(false);
     param.lastonmouseobject:=nil;

     //self.MakeCurrent(false);
     //isOpenGLError;

     calcoptimalmatrix;
     calcgrid;

     {переделать}//inherited size{(fwSizeType,nWidth,nHeight)};

     //drawer.WorkAreaResize(getviewcontrol.clientwidth,getviewcontrol.clientheight);

     {wa.param.md.glmouse.y := clientheight-wa.param.md.mouse.y;
     CalcOptimalMatrix;
     mouseunproject(wa.param.md.GLmouse.x, wa.param.md.GLmouse.y);
     CalcMouseFrustum;}

     if param.pglscreen <> nil then
     GDBFreeMem(param.pglscreen);
     GDBGetMem({$IFDEF DEBUGBUILD}'ScreenBuf',{$ENDIF}param.pglscreen, getviewcontrol.clientwidth * getviewcontrol.clientheight * 4);

     param.firstdraw := true;
     //draw;
     //paint;
     getviewcontrol.Invalidate;
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('viewareadef.initialization');{$ENDIF}
  RegisterBackend(TOpenGLViewArea,'OpenGL');
  RegisterBackend(TCanvasViewArea,'GDI');
end.
