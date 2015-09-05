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

unit uzglgdiviewarea;
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
     varmandef,commandline,zcadsysvars,geometry,shared,LCLType,
     ExtCtrls,classes,Controls,Graphics,generalviewarea,log,backendmanager,
     {$IFNDEF DELPHI}OpenGLContext{$ENDIF},uzglgeneralcanvasviewarea;
type
    TGDIViewArea=class(TGeneralCanvasViewArea)
                      public
                      GDIData:TGDIData;
                      procedure CreateDrawer; override;
                      function getParam:pointer; override;
                      function getParamTypeName:GDBString; override;
                      procedure setdeicevariable; override;
                  end;
const
  maxgrid=100;
var
  gridarray:array [0..maxgrid,0..maxgrid] of GDBvertex2S;
implementation
//uses mainwindow;
procedure TGDIViewArea.CreateDrawer;
begin
     drawer:=TZGLGDIDrawer.Create;
     TZGLGDIDrawer(drawer).wa:=self;
     TZGLGDIDrawer(drawer).canvas:=TCADControl(getviewcontrol).canvas;
     TZGLGDIDrawer(drawer).panel:=TCADControl(getviewcontrol);
end;

procedure TGDIViewArea.setdeicevariable;
begin
     GDIData.RD_TextRendering:=TRT_System;
     GDIData.RD_DrawDebugGeometry:=false;
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
function TGDIViewArea.getParam:pointer;
begin
     result:=@GDIData;
end;
function TGDIViewArea.getParamTypeName:GDBString;
begin
     result:='PTGDIData';
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('viewareadef.initialization');{$ENDIF}
  RegisterBackend(TGDIViewArea,'GDI');
end.
