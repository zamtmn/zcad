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

unit abstractviewarea;
{$INCLUDE def.inc}
interface
uses gdbase,gdbasetypes,
     UGDBLayerArray,ugdbltypearray,UGDBTextStyleArray,ugdbdimstylearray,UGDBPoint3DArray,
     oglwindowdef,gdbdrawcontext,UGDBEntTree,
     uinfoform,
     ExtCtrls,classes,Controls;
type
    TAbstractViewArea=class(tcomponent)
                           public
                           param: OGLWndtype;
                           PolarAxis:GDBPoint3dArray;
                           FastMMShift: TShiftState;
                           FastMMX,FastMMY: Integer;

                           procedure showmousecursor;virtual;abstract;
                           procedure hidemousecursor;virtual;abstract;

                           function getviewcontrol:TControl;virtual;abstract;
                           procedure CalcOptimalMatrix;virtual;abstract;
                           procedure draw;virtual;abstract;
                           procedure calcgrid;virtual;abstract;
                           procedure Clear0Ontrackpoint;virtual;abstract;
                           procedure SetMouseMode(smode:GDBByte);virtual;abstract;
                           procedure SetObjInsp;virtual;abstract;
                           procedure sendcoordtocommandTraceOn(coord:GDBVertex;key: GDBByte;pos:pos_record);virtual;abstract;
                           procedure reprojectaxis;virtual;abstract;
                           procedure ZoomToVolume(Volume:GDBBoundingBbox);virtual;abstract;
                           procedure ZoomAll;virtual;abstract;
                           procedure ZoomSel;virtual;abstract;
                           function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer;MousePos: TPoint): Boolean;virtual;abstract;
                           procedure RotTo(x0,y0,z0:GDBVertex);virtual;abstract;
                           procedure PanScreen(oldX,oldY,X,Y:Integer);virtual;abstract;
                           procedure RestoreMouse;virtual;abstract;
                           function CreateRC(_maxdetail:GDBBoolean=false):TDrawContext;virtual;abstract;
                           function treerender(var Node:TEntTreeNode;StartTime:TDateTime;var DC:TDrawContext):GDBBoolean;virtual;abstract;
                           procedure myKeyPress(var Key: Word; Shift: TShiftState);virtual;abstract;
                           procedure finishdraw(var RC:TDrawContext);virtual;abstract;
                           procedure SetCameraPosZoom(_pos:gdbvertex;_zoom:gdbdouble;finalcalk:gdbboolean);virtual;abstract;
                           function ProjectPoint(pntx,pnty,pntz:gdbdouble;var wcsLBN,wcsRTF,dcsLBN,dcsRTF: GDBVertex):gdbvertex;virtual;abstract;
                           procedure mouseunproject(X, Y: integer);virtual;abstract;
                      end;
implementation

begin
  {$IFDEF DEBUGINITSECTION}LogOut('viewareadef.initialization');{$ENDIF}
end.
