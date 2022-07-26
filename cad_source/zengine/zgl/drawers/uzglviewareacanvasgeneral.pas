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

unit uzglviewareacanvasgeneral;
{$INCLUDE zengineconfig.inc}
interface
uses
     {$IFDEF LCLQT}
     qtwidgets,qt4,
     {$ENDIF}
     {$IFDEF LCLQT5}
     qtwidgets,qt5,
     {$ENDIF}
     uzgldrawergdi,uzglviewareaabstract,sysutils,
     uzegeometry,{$IFNDEF DELPHI}LCLType,LMessages,{$ENDIF}{$IFDEF DELPHI}windows,messages,{$ENDIF}
     ExtCtrls,classes,Controls,Graphics,uzglviewareageneral,uzglbackendmanager;
type
    TGDIPanel=class({TCustomControl}TCADControl)
                protected
                procedure WMPaint(var Message: {$IFNDEF DELPHI}TLMPaint{$ENDIF}{$IFDEF DELPHI}TWMPaint{$ENDIF}); message {$IFNDEF DELPHI}LM_PAINT{$ENDIF}{$IFDEF DELPHI}WM_PAINT{$ENDIF};
                public
                procedure EraseBackground(DC: HDC); {$IFNDEF DELPHI}override;{$ENDIF}
    end;
    TGeneralCanvasViewArea=class(TGeneralViewArea)
                      public
                      function CreateWorkArea(TheOwner: TComponent):TCADControl; override;
                      procedure SetupWorkArea; override;
                      procedure getareacaps; override;
                      function startpaint:boolean;override;
                      function NeedDrawInsidePaintEvent:boolean; override;
                  end;
implementation
//uses mainwindow;
procedure TGDIPanel.EraseBackground(DC: HDC);
begin
     // everything is painted, so erasing the background is not needed
end;
procedure TGDIPanel.WMPaint(var Message: {$IFNDEF DELPHI}TLMPaint{$ENDIF}{$IFDEF DELPHI}TWMPaint{$ENDIF});
begin
     //Include(FControlState, csCustomPaint);
     //inherited WMPaint(Message);
     //if assigned(onpaint) then
     //                         onpaint(nil);

     inherited WMPaint(Message);

     //Exclude(FControlState, csCustomPaint);
end;
function TGeneralCanvasViewArea.CreateWorkArea(TheOwner: TComponent):TCADControl;
begin
     result:=TCADControl(TGDIPanel.Create(TheOwner));
     //TCADControl(result).Caption:='123';
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
  {$if DEFINED(LCLQt)}
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
     result:={$if DEFINED(LCLQt) OR DEFINED(LCLQt5)}True{$ELSE}False{$ENDIF};
end;
begin
end.
