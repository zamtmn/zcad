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

unit uzglviewareacanvas;
{$INCLUDE zengineconfig.inc}
interface
uses
     (*{$IFDEF LCLQT}
     qt4,
     {$ENDIF}*)
     uzgldrawercanvas,uzglviewareaabstract,sysutils,
     
     uzsbVarmanDef,uzccommandsmanager,uzcsysvars,uzegeometry,LCLType,
     ExtCtrls,classes,Controls,Graphics,uzglbackendmanager,
     uzglviewareacanvasgeneral;
type
    PTCanvasData=^TCanvasData;
    TCanvasData=record
              RD_Renderer:String;(*'Device'*)(*oi_readonly*)
        end;
    TCanvasViewArea=class(TGeneralCanvasViewArea)
                      public
                      CanvasData:TCanvasData;
                      procedure CreateDrawer; override;
                      function getParam:pointer; override;
                      function getParamTypeName:String; override;
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
function TCanvasViewArea.getParamTypeName:String;
begin
     result:='PTCanvasData';
end;
begin
  RegisterBackend(TCanvasViewArea,'LCLCanvas');
end.
