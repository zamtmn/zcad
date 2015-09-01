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

unit uzglcanvasviewarea;
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
                      CanvasData:TCanvasData;
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
     CanvasData.RD_Renderer:='LCL Canvas';
end;
function TGDIViewArea.getParam:pointer;
begin
     result:=@CanvasData;
end;
function TGDIViewArea.getParamTypeName:GDBString;
begin
     result:='PTCanvasData';
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('uzglcanvasviewarea.initialization');{$ENDIF}
  RegisterBackend(TGDIViewArea,'LCLCanvas');
end.
