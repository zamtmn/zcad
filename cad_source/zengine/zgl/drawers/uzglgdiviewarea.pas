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
     ExtCtrls,classes,Controls,Graphics,generalviewarea,log,backendmanager,LMessages,
     {$IFNDEF DELPHI}OpenGLContext{$ENDIF};
type
    TGDIPanel=class(TCustomControl)
                protected
                procedure WMPaint(var Message: TLMPaint); message LM_PAINT;
                procedure EraseBackground(DC: HDC); override;
    end;
    TGDIViewArea=class(TGeneralViewArea)
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

procedure TGDIPanel.EraseBackground(DC: HDC);
begin
     // everything is painted, so erasing the background is not needed
end;
procedure TGDIPanel.WMPaint(var Message: TLMPaint);
begin
     //Include(FControlState, csCustomPaint);
     //inherited WMPaint(Message);
     //if assigned(onpaint) then
     //                         onpaint(nil);
     inherited WMPaint(Message);
     //Exclude(FControlState, csCustomPaint);
end;
function TGDIViewArea.CreateWorkArea(TheOwner: TComponent):TCADControl;
begin
     result:=TCADControl(TGDIPanel.Create(TheOwner));
     TCADControl(result).Caption:='123';
     //TGDIPanel(result).DoubleBuffered:=false;
end;
procedure TGDIViewArea.CreateDrawer;
begin
     drawer:=TZGLGDIDrawer.Create;
     TZGLGDIDrawer(drawer).wa:=self;
     TZGLGDIDrawer(drawer).canvas:=TCADControl(getviewcontrol).canvas;
     TZGLGDIDrawer(drawer).panel:=TCADControl(getviewcontrol);
end;

procedure TGDIViewArea.SetupWorkArea;
begin
  //self.getviewcontrol.Color:=clHighlight;
  //TGDIPanel(getviewcontrol).BorderStyle:=bsNone;
  //TGDIPanel(getviewcontrol).BevelWidth:=0;
  TCADControl(getviewcontrol).onpaint:=mypaint;
end;
procedure TGDIViewArea.setdeicevariable;
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
procedure TGDIViewArea.getareacaps;
begin
  {$IFDEF LCLQT}
  TQtWidget(getviewcontrol.Handle).setAttribute(QtWA_PaintOutsidePaintEvent);
  //TQtWidget(getviewcontrol.Handle).setAttribute(QtWA_PaintOnScreen);
  //TQtWidget(getviewcontrol.Handle).setAttribute(QtWA_OpaquePaintEvent);
  //TQtWidget(getviewcontrol.Handle).setAttribute(QtWA_NoSystemBackground);
  {$ENDIF}
  setdeicevariable;
end;
procedure TGDIViewArea.GDBActivateGLContext;
begin
end;
function TGDIViewArea.startpaint;
begin
     if assigned(WorkArea) then
                                   TZGLGDIDrawer(drawer).canvas:=WorkArea.canvas;
     result:=inherited;
end;
function TGDIViewArea.NeedDrawInsidePaintEvent:boolean;
begin
     result:={$IFDEF LCLQT}True{$ELSE}False{$ENDIF};
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
