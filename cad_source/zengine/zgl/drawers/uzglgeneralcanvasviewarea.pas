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

unit uzglgeneralcanvasviewarea;
{$INCLUDE def.inc}
interface
uses
     {$IFDEF LCLGTK2}
     gtk2,gdk2,
     {$ENDIF}
     {$IFDEF LCLQT}
     qtwidgets,qt4,qtint,
     {$ENDIF}
     uzglgdidrawer,abstractviewarea,uzglopengldrawer,sysutils,memman,glstatemanager,gdbase,
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
    TGeneralCanvasViewArea=class(TGeneralViewArea)
                      public
                      function CreateWorkArea(TheOwner: TComponent):TCADControl; override;
                      procedure SetupWorkArea; override;
                      procedure getareacaps; override;
                      procedure GDBActivateGLContext; override;
                      function startpaint:boolean;override;
                      function NeedDrawInsidePaintEvent:boolean; override;
                  end;
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
procedure TGeneralCanvasViewArea.GDBActivateGLContext;
begin
     inherited;
end;
function TGeneralCanvasViewArea.CreateWorkArea(TheOwner: TComponent):TCADControl;
begin
     result:=TCADControl(TGDIPanel.Create(TheOwner));
     TCADControl(result).Caption:='123';
     //TGDIPanel(result).DoubleBuffered:=false;
end;
procedure TGeneralCanvasViewArea.SetupWorkArea;
begin
  //self.getviewcontrol.Color:=clHighlight;
  //TGDIPanel(getviewcontrol).BorderStyle:=bsNone;
  //TGDIPanel(getviewcontrol).BevelWidth:=0;
  TCADControl(getviewcontrol).onpaint:=mypaint;
end;
procedure TGeneralCanvasViewArea.getareacaps;
begin
  {$IFDEF LCLQT}
  TQtWidget(getviewcontrol.Handle).setAttribute(QtWA_PaintOutsidePaintEvent);
  //TQtWidget(getviewcontrol.Handle).setAttribute(QtWA_PaintOnScreen);
  //TQtWidget(getviewcontrol.Handle).setAttribute(QtWA_OpaquePaintEvent);
  //TQtWidget(getviewcontrol.Handle).setAttribute(QtWA_NoSystemBackground);
  {$ENDIF}
  setdeicevariable;
end;
function TGeneralCanvasViewArea.startpaint;
begin
     if assigned(WorkArea) then
                                   TZGLGDIDrawer(drawer).canvas:=WorkArea.canvas;
     result:=inherited;
end;
function TGeneralCanvasViewArea.NeedDrawInsidePaintEvent:boolean;
begin
     result:={$IFDEF LCLQT}True{$ELSE}False{$ENDIF};
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('uzglgeneralcanvasviewarea.initialization');{$ENDIF}
end.
