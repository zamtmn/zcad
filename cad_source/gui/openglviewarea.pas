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
     uinfoform,oglwindow,oglwindowdef,gdbdrawcontext,varmandef,commandline,zcadsysvars,GDBEntity,Varman,zcadinterface,geometry,gdbobjectsconstdef,shared,zcadstrconsts,LCLType,
     ExtCtrls,classes,Controls,generalviewarea,UGDBTracePropArray,math;
type
    TOpenGLViewArea=class(TGeneralViewArea)
                      public
                      OpenGLWindow:TOGLWnd;
                      constructor Create(TheOwner: TComponent); override;

                      procedure showmousecursor;override;
                      procedure hidemousecursor;override;

                      procedure draw;override;
                      procedure ZoomToVolume(Volume:GDBBoundingBbox); override;
                      procedure ZoomAll;override;
                      procedure ZoomSel;override;
                      function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer;MousePos: TPoint): Boolean;override;
                      procedure RotTo(x0,y0,z0:GDBVertex); override;
                      procedure RestoreMouse;override;
                      procedure finishdraw(var RC:TDrawContext); override;
                      Procedure Paint; override;
                      function CreateWorkArea(TheOwner: TComponent):TCADControl; override;
                  end;
implementation
uses mainwindow;
Procedure TOpenGLViewArea.Paint;
begin
     OpenGLWindow.Paint;
end;
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
function TOpenGLViewArea.CreateWorkArea(TheOwner: TComponent):TCADControl;
begin
     result:=TCADControl(TOGLWnd.Create(TheOwner));
end;
constructor TOpenGLViewArea.Create(TheOwner: TComponent);
begin
     inherited;

     OpenGLWindow:=TOGLWnd(WorkArea);
     OpenGLWindow.wa:=self;

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
procedure TOpenGLViewArea.RestoreMouse;
begin
     OpenGLWindow.RestoreMouse;
end;
procedure TOpenGLViewArea.finishdraw(var RC:TDrawContext);
begin
     OpenGLWindow.finishdraw(RC);
end;
begin
  {$IFDEF DEBUGINITSECTION}LogOut('viewareadef.initialization');{$ENDIF}
end.
