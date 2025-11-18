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

unit uzglviewareagdi;
{$INCLUDE zengineconfig.inc}
interface
uses
     {$IFDEF LCLGTK2}
     gtk2,
     {$ENDIF}
     {$IFDEF LCLQT}
     qt4,qtint,
     {$ENDIF}
     {$IFDEF LCLQT5}
     qt5,qtint,
     {$ENDIF}
     uzgldrawergdi,uzglviewareaabstract,sysutils,
     uzegeometrytypes,uzegeometry,{$IFNDEF DELPHI}LCLType,{$ENDIF}{$IFDEF DELPHI}Types,{$ENDIF}
     ExtCtrls,classes,Controls,Graphics,uzglviewareageneral,uzglbackendmanager,uzglviewareacanvasgeneral;
type
    TGDIViewArea=class(TGeneralCanvasViewArea)
                      public
                      GDIData:TGDIData;
                      procedure CreateDrawer; override;
                      function getParam:pointer; override;
                      function getParamTypeName:String; override;
                      procedure setdeicevariable; override;
                  end;
const
  maxgrid=100;
var
  gridarray:array [0..maxgrid,0..maxgrid] of TzePoint2s;
implementation
//uses mainwindow;
procedure TGDIViewArea.CreateDrawer;
begin
     drawer:=TZGLGDIDrawer.Create;
     TZGLGDIDrawer(drawer).wa:=self;
     TZGLGDIDrawer(drawer).canvas:=TCADControl(getviewcontrol).canvas;
     tobject(TZGLGDIDrawer(drawer).panel):={TCADControl}tobject(getviewcontrol);
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
     {$IF DEFINED(LCLQt) OR DEFINED(LCLQt5)}
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
function TGDIViewArea.getParamTypeName:String;
begin
     result:='PTGDIData';
end;
begin
  RegisterBackend(TGDIViewArea,'GDI');
end.
