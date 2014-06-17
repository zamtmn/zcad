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
uses gdbase,gdbasetypes,
     UGDBLayerArray,ugdbltypearray,UGDBTextStyleArray,ugdbdimstylearray,
     uinfoform,oglwindow,oglwindowdef,gdbdrawcontext,
     ExtCtrls,classes,Controls,abstractviewarea;
type
    TOpenGLViewArea=class(TAbstractViewArea)
                      public
                      OpenGLWindow:TOGLWnd;
                      constructor Create(TheOwner: TComponent); override;

                      procedure showmousecursor;override;
                      procedure hidemousecursor;override;

                      function getviewcontrol:TControl; override;
                      procedure CalcOptimalMatrix; override;
                      procedure draw;override;
                      procedure calcgrid;override;
                      procedure Clear0Ontrackpoint; override;
                      procedure SetMouseMode(smode:GDBByte); override;
                      procedure SetObjInsp; override;
                      procedure sendcoordtocommandTraceOn(coord:GDBVertex;key: GDBByte;pos:pos_record); override;
                      procedure reprojectaxis; override;
                      procedure ZoomToVolume(Volume:GDBBoundingBbox); override;
                      procedure ZoomAll;override;
                      procedure ZoomSel;override;
                      function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer;MousePos: TPoint): Boolean;override;
                      procedure RotTo(x0,y0,z0:GDBVertex); override;
                      procedure PanScreen(oldX,oldY,X,Y:Integer); override;
                      procedure RestoreMouse;override;
                      function CreateRC(_maxdetail:GDBBoolean=false):TDrawContext; override;
                      procedure myKeyPress(var Key: Word; Shift: TShiftState); override;
                      procedure finishdraw(var RC:TDrawContext); override;
                      procedure SetCameraPosZoom(_pos:gdbvertex;_zoom:gdbdouble;finalcalk:gdbboolean); override;
                      function ProjectPoint(pntx,pnty,pntz:gdbdouble;var wcsLBN,wcsRTF,dcsLBN,dcsRTF: GDBVertex):gdbvertex; override;
                      procedure mouseunproject(X, Y: integer);override;
                  end;
implementation
uses mainwindow;
procedure TOpenGLViewArea.showmousecursor;
begin
     if assigned(OpenGLWindow) then
     OpenGLWindow.Cursor:=crDefault;
end;

procedure TOpenGLViewArea.hidemousecursor;
begin
     if assigned(OpenGLWindow) then
     OpenGLWindow.Cursor:=crNone;
end;
procedure TOpenGLViewArea.CalcOptimalMatrix;
begin
     OpenGLWindow.CalcOptimalMatrix;
end;

function TOpenGLViewArea.getviewcontrol:TControl;
begin
     result:=OpenGLWindow;
end;

constructor TOpenGLViewArea.Create(TheOwner: TComponent);
begin
     inherited;

     OpenGLWindow:=TOGLWnd.Create(TheOwner);
     OpenGLWindow.wa:=self;
     OpenGLWindow.onCameraChanged:=MainFormN.correctscrollbars;
     OpenGLWindow.ShowCXMenu:=MainFormN.ShowCXMenu;
     OpenGLWindow.MainMouseMove:=MainFormN.MainMouseMove;
     OpenGLWindow.MainMouseDown:=MainFormN.MainMouseDown;
     {$if FPC_FULlVERSION>=20701}
     OpenGLWindow.AuxBuffers:=0;
     OpenGLWindow.StencilBits:=8;
     //OpenGLWindow.ColorBits:=24;
     OpenGLWindow.DepthBits:=24;
     {$ENDIF}
end;
procedure TOpenGLViewArea.draw;
begin
     OpenGLWindow.draw;
end;
procedure TOpenGLViewArea.calcgrid;
begin
     OpenGLWindow.calcgrid;
end;
procedure TOpenGLViewArea.Clear0Ontrackpoint;
begin
     OpenGLWindow.Clear0Ontrackpoint;
end;
procedure TOpenGLViewArea.SetMouseMode(smode:GDBByte);
begin
     OpenGLWindow.SetMouseMode(smode);
end;
procedure TOpenGLViewArea.SetObjInsp;
begin
     OpenGLWindow.SetObjInsp;
end;
procedure TOpenGLViewArea.sendcoordtocommandTraceOn(coord:GDBVertex;key: GDBByte;pos:pos_record);
begin
     OpenGLWindow.sendcoordtocommandTraceOn(coord,key,pos);
end;
procedure TOpenGLViewArea.reprojectaxis;
begin
     OpenGLWindow.reprojectaxis;
end;
procedure TOpenGLViewArea.ZoomToVolume(Volume:GDBBoundingBbox);
begin
     OpenGLWindow.ZoomToVolume(Volume);
end;
procedure TOpenGLViewArea.ZoomAll;
begin
     OpenGLWindow.ZoomAll;
end;
procedure TOpenGLViewArea.ZoomSel;
begin
     OpenGLWindow.ZoomSel;
end;
function TOpenGLViewArea.DoMouseWheel(Shift: TShiftState; WheelDelta: Integer;MousePos: TPoint): Boolean;
begin
     result:=OpenGLWindow.DoMouseWheel(Shift,WheelDelta,MousePos);
end;
procedure TOpenGLViewArea.RotTo(x0,y0,z0:GDBVertex);
begin
     OpenGLWindow.RotTo(x0,y0,z0);
end;
procedure TOpenGLViewArea.PanScreen(oldX,oldY,X,Y:Integer);
begin
     OpenGLWindow.PanScreen(oldX,oldY,X,Y);
end;
procedure TOpenGLViewArea.RestoreMouse;
begin
     OpenGLWindow.RestoreMouse;
end;
function TOpenGLViewArea.CreateRC(_maxdetail:GDBBoolean=false):TDrawContext;
begin
     result:=OpenGLWindow.CreateRC(_maxdetail);
end;
procedure TOpenGLViewArea.myKeyPress(var Key: Word; Shift: TShiftState);
begin
     OpenGLWindow.myKeyPress(Key,Shift);
end;
procedure TOpenGLViewArea.finishdraw(var RC:TDrawContext);
begin
     OpenGLWindow.finishdraw(RC);
end;
procedure TOpenGLViewArea.SetCameraPosZoom(_pos:gdbvertex;_zoom:gdbdouble;finalcalk:gdbboolean);
begin
     OpenGLWindow.SetCameraPosZoom(_pos,_zoom,finalcalk);
end;
function TOpenGLViewArea.ProjectPoint(pntx,pnty,pntz:gdbdouble;var wcsLBN,wcsRTF,dcsLBN,dcsRTF: GDBVertex):gdbvertex;
begin
     result:=OpenGLWindow.ProjectPoint(pntx,pnty,pntz,wcsLBN,wcsRTF,dcsLBN,dcsRTF);
end;
procedure TOpenGLViewArea.mouseunproject(X, Y: integer);
begin
     OpenGLWindow.mouseunproject(X, Y)
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('viewareadef.initialization');{$ENDIF}
end.
