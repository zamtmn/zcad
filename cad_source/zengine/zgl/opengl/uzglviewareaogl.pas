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

unit uzglviewareaogl;
{$INCLUDE zengineconfig.inc}
interface
uses
     {$IFDEF LCLGTK2}
     gtk2,gdk2,
     {$ENDIF}
     (*{$IFDEF LCLQT}
     qt4,
     {$ENDIF}*)
     uzglviewareaabstract,uzgldrawerogl,sysutils,
     uzgloglstatemanager,uzbtypes,
     uzglviewareadata,uzgldrawcontext,uzegeometry,LCLType,
     ExtCtrls,classes,Controls,Graphics,uzglviewareageneral,math,uzglbackendmanager,
     uzegeometrytypes,uzbLogIntf,{$IFNDEF DELPHI}OpenGLContext{$ENDIF},GLext;
type
    PTOGLWnd = ^TOGLWnd;
    TOGLWnd = class({TPanel}TOpenGLControl)
    private
    public
      wa:TAbstractViewArea;
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
                      procedure GDBActivateContext; override;
                      function NeedDrawInsidePaintEvent:boolean; override;
                      procedure setdeicevariable; override;
                      function getParam:pointer; override;
                      function getParamTypeName:String; override;
                      function CreateRC(_maxdetail:Boolean=false):TDrawContext;override;
                  end;
const
  maxgrid=100;
var
  gridarray:array [0..maxgrid,0..maxgrid] of TzePoint2s;
implementation
//uses mainwindow;
function TOpenGLViewArea.CreateRC(_maxdetail:Boolean=false):TDrawContext;
begin
  result:=inherited CreateRC(_maxdetail);
  result.MaxWidth:=OpenGLParam.RD_MaxWidth;
end;
procedure TOGLWnd.EraseBackground(DC: HDC);
begin
end;
function TOpenGLViewArea.getParam;
begin
     result:=@OpenGLParam;
end;

function TOpenGLViewArea.getParamTypeName;
begin
     result:='PTOpenglData';
end;
procedure TOpenGLViewArea.GDBActivateContext;
begin
  inherited;
  //MyglMakeCurrent(OpenGLWindow.OGLContext);
  OpenGLWindow.MakeCurrent;
  drawer.delmyscrbuf;
  isOpenGLError;
end;
function TOpenGLViewArea.NeedDrawInsidePaintEvent:boolean;
begin
     result:=false;
end;

procedure TOpenGLViewArea.setdeicevariable;
var tarray:array [0..1] of Double;
    p:pansichar;
begin
  //programlog.logoutstr('TOGLWnd.SetDeiceVariable',lp_IncPos,LM_Debug);
  zDebugLn('{D+}TOGLWnd.SetDeiceVariable');
  oglsm.myglGetDoublev(GL_LINE_WIDTH_RANGE,@tarray[0]);
  //if assigned(sysvar.RD.RD_MaxLineWidth) then   m,.
  OpenGLParam.RD_MaxLineWidth:=tarray[1];
  oglsm.myglGetDoublev(GL_point_size_RANGE,@tarray[0]);
  //if assigned(sysvar.RD.RD_MaxPointSize) then
  OpenGLParam.RD_MaxPointSize:=tarray[1];
  Pointer(p):=oglsm.myglGetString(GL_VENDOR);
  zDebugLn('{I}RD_Vendor:="%s"',[p]);
  //programlog.LogOutFormatStr('RD_Vendor:="%s"',[p],0,LM_Info);
  //if assigned(OpenglParam.RD_Vendor) then
  OpenglParam.RD_Vendor:=p;
  Pointer(p):=oglsm.myglGetString(GL_RENDERER);
  zDebugLn('{I}RD_Renderer:="%s"',[p]);
  //programlog.LogOutFormatStr('RD_Renderer:="%s"',[p],0,LM_Info);
  //if assigned(OpenglParam.RD_Renderer) then
  OpenglParam.RD_Renderer:=p;
  Pointer(p):=oglsm.myglGetString(GL_VERSION);
  zDebugLn('{I}RD_Version:="%s"',[p]);
  //programlog.LogOutFormatStr('RD_Version:="%s"',[p],0,LM_Info);
  //if assigned(OpenglParam.RD_DriverVersion) then
  OpenglParam.RD_DriverVersion:=p;

  Pointer(p):=oglsm.myglGetString(GL_EXTENSIONS);
  zDebugLn('{I}RD_Extensions:="%s"',[p]);
  //programlog.LogOutFormatStr('RD_Extensions:="%s"',[p],0,LM_Info);
  //if assigned(OpenglParam.RD_Extensions) then
  OpenglParam.RD_Extensions:=p;
  //if assigned(sysvar.RD.RD_MaxWidth) and assigned(sysvar.RD.RD_MaxLineWidth) then
  begin
  OpenGLParam.RD_MaxWidth:=round(min(OpenGLParam.RD_MaxPointSize,OpenGLParam.RD_MaxLineWidth));
  zDebugLn('{I}RD_MaxWidth:="%G"',[min(OpenGLParam.RD_MaxPointSize,OpenGLParam.RD_MaxLineWidth)]);
  //programlog.LogOutFormatStr('RD_MaxWidth:="%G"',[min(sysvar.RD.RD_MaxPointSize^,sysvar.RD.RD_MaxLineWidth^)],0,LM_Info);
  end;
  //programlog.logoutstr('end;',lp_DecPos,LM_Debug);
  OpenglParam.RD_UseStencil:=@sysvarRDUseStencil;
  OpenglParam.RD_Light:=@sysvarRDLight;
  OpenglParam.RD_LineSmooth:=@SysVarRDLineSmooth;
  zDebugLn('{D-}TOGLWnd.SetDeiceVariable');
end;

procedure TOpenGLViewArea.getareacaps;
{$IFDEF LCLGTK2}
var
   Widget:PGtkWidget;
{$ENDIF}
begin
  zTraceLn('{D+}TOpenGLViewArea.getareacaps');
  {$IFDEF LCLGTK2}
  Widget:=PGtkWidget(PtrUInt(OpenGLWindow.Handle));
  gtk_widget_add_events (Widget,GDK_POINTER_MOTION_HINT_MASK);
  {$ENDIF}
  OpenGLWindow.MakeCurrent();
  setdeicevariable;

  {$IFDEF WINDOWS}

  if Load_GL_version_1_2 then
    OpenGLParam.RD_DraverVersion:=GLV_1_2
  else
    OpenGLParam.RD_DraverVersion:=GLV_1_0;

  //if assigned(OpenglParam.RD_VSync) then
  if OpenglParam.RD_VSync<>T3SB_Default then
  begin
    Pointer(@wglSwapIntervalEXT) := wglGetProcAddress('wglSwapIntervalEXT');
    if @wglSwapIntervalEXT<>nil then begin
      if OpenglParam.RD_VSync=T3SB_True then
        wglSwapIntervalEXT(1)
      else
        wglSwapIntervalEXT(0);
    end else begin
      zDebugLn('{EH}wglSwapIntervalEXT not supported by your video driver. Please set the VSync in the defaul');
    end;
  end;
  {$ENDIF}
  zTraceLn('{D-}end;{TOGLWnd.InitOGL}');
  //programlog.logoutstr('end;{TOGLWnd.InitOGL}',lp_DecPos,LM_Debug);
end;
procedure TOpenGLViewArea.DrawGrid;
var
  pg:PzePoint2s;
  i,j: Integer;
  v,v1:TzePoint3d;
begin
  //if sysvar.DWG.DWG_DrawGrid<>nil then
  if (pdwg^.DrawGrid)and(param.md.WPPointUR.z=1) then
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
          v1.y:=v1.y+pdwg^.GridSpacing.y;
          inc(pg);
        end;
        v.x:=v1.x-pdwg^.GridSpacing.x;
  end;
  oglsm.myglend;
  end;
end;

procedure TOpenGLViewArea.LightOn;
var
   p:GDBvertex4F;
begin
    if sysvarRDLight
    then
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
    else
        LightOff(dc);
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
     {if assigned(sysvar.RD.RD_RemoveSystemCursorFromWorkArea) then}
                                                                  RemoveCursorIfNeed(OpenGLWindow,SysVarDISPRemoveSystemCursorFromWorkArea);
                                                              {else
                                                                  RemoveCursorIfNeed(OpenGLWindow,true);}
     OpenGLWindow.ShowHint:=true;
     //fillchar(myscrbuf,sizeof(tmyscrbuf),0);

     OpenGLWindow.AuxBuffers:=0;
     OpenGLWindow.StencilBits:=8;
     //OpenGLWindow.ColorBits:=24;
     OpenGLWindow.DepthBits:=24;
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

     //if param.pglscreen <> nil then
     //Freemem(param.pglscreen);
     //Getmem(param.pglscreen, getviewcontrol.clientwidth * getviewcontrol.clientheight * 4);

     param.firstdraw := true;
     //draw;
     //paint;
     getviewcontrol.Invalidate;
end;
begin
  RegisterBackend(TOpenGLViewArea,'OpenGL');
end.
