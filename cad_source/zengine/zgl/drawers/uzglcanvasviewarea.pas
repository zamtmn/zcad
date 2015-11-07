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
     {$IFDEF LCLQT}
     qt4,
     {$ENDIF}
     uzglcanvasdrawer,uzglabstractviewarea,uzglopengldrawer,sysutils,memman,glstatemanager,gdbase,gdbasetypes,
     UGDBLayerArray,ugdbdimstylearray,
     varmandef,commandline,zcadsysvars,geometry,shared,LCLType,
     ExtCtrls,classes,Controls,Graphics,generalviewarea,log,backendmanager,
     {$IFNDEF DELPHI}OpenGLContext{$ENDIF},uzglgeneralcanvasviewarea;
type
    TCanvasViewArea=class(TGeneralCanvasViewArea)
                      public
                      CanvasData:TCanvasData;
                      procedure CreateDrawer; override;
                      function getParam:pointer; override;
                      function getParamTypeName:GDBString; override;
                      procedure setdeicevariable; override;
                      function NeedDrawInsidePaintEvent:boolean; override;
                  end;
implementation
procedure TCanvasViewArea.CreateDrawer;
begin
     drawer:=TZGLCanvasDrawer.Create;
     TZGLCanvasDrawer(drawer).wa:=self;
     TZGLCanvasDrawer(drawer).canvas:=TCADControl(getviewcontrol).canvas;
     TZGLCanvasDrawer(drawer).panel:=TCADControl(getviewcontrol);
end;
function TCanvasViewArea.NeedDrawInsidePaintEvent:boolean;
begin
     result:=True;
end;
procedure TCanvasViewArea.setdeicevariable;
begin
     CanvasData.RD_Renderer:='LCL Canvas';
end;
function TCanvasViewArea.getParam:pointer;
begin
     result:=@CanvasData;
end;
function TCanvasViewArea.getParamTypeName:GDBString;
begin
     result:='PTCanvasData';
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('uzglcanvasviewarea.initialization');{$ENDIF}
  RegisterBackend(TCanvasViewArea,'LCLCanvas');
end.
