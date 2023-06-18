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

unit uzglviewareaabstract;
{$INCLUDE zengineconfig.inc}
interface
uses
     UGDBOpenArrayOfPV,uzgldrawerabstract,uzeentgenericsubentry,uzbtypes,
     uzglviewareadata,uzgldrawcontext,UGDBPoint3DArray,uzeentitiestree,uzegeometry,uzedrawingabstract,
     uzegeometrytypes,sysutils,
     ExtCtrls,Controls,Classes,{$IFDEF DELPHI}Types,Messages,Graphics,{$ENDIF}{$IFNDEF DELPHI}LCLType,{$ENDIF}Forms,uzeentity;

type
{NEEDFIXFORDELPHI}
    TCADControl=class({$IFNDEF DELPHI}TCustomControl{$ENDIF}{$IFDEF DELPHI}{TForm}TCustomControl{$ENDIF})
                private
                {$IFDEF DELPHI}
                FOnPaint: TNotifyEvent;
                {$ENDIF}
                protected
                {$IFDEF DELPHI}
                procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
                {$ENDIF}
                public
                function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean; override;
                property OnMouseUp;
                property onmousedown;
                property onmousemove;
                property onmousewheel;
                property onmouseenter;
                property onmouseleave;
                property onresize;
                property OnPaint{$IFDEF DELPHI}:TNotifyEvent read FOnPaint write FOnPaint{$ENDIF};
                property Canvas;
                end;
    TCameraChangedNotify=procedure of object;
    TAbstractViewArea=class;
    TOnWaMouseDown=function (Sender:TAbstractViewArea;Button:TMouseButton;Shift:TShiftState;X,Y:Integer;OnMouseEntity:Pointer;var NeedRedraw:Boolean):boolean of object;
    TOnWaMouseMove=procedure (Sender:TAbstractViewArea;Shift:TShiftState;X,Y:Integer) of object;
    TOnWaMouseSelect=procedure (Sender:TAbstractViewArea;SelectedEntity:Pointer) of object;
    TOnWaKeyPress=procedure (Sender:TAbstractViewArea;var Key: Word; Shift: TShiftState) of object;
    TOnGetEntsDesc=function (ents:PGDBObjOpenArrayOfPV):String of object;
    TOnWaShowCursor=procedure (Sender:TAbstractViewArea;var DC:TDrawContext) of object;
    TAbstractViewArea=class(tcomponent)
                           public
                           Drawer:TZGLAbstractDrawer;
                           param: OGLWndtype;
                           PolarAxis:GDBPoint3dArray;
                           OTTimer:TTimer;
                           OHTimer:TTimer;
                           PDWG:PTAbstractDrawing;
                           onCameraChanged:TCameraChangedNotify;
                           ShowCXMenu:procedure of object;
                           MainMouseMove:procedure of object;
                           MainMouseDown:function(Sender:TAbstractViewArea):boolean of object;
                           MainMouseUp:procedure of object;
                           tocommandmcliccount:Integer;
                           currentmousemovesnaptogrid:Boolean;
                           OnWaMouseDown:TOnWaMouseDown;
                           OnWaMouseSelect:TOnWaMouseSelect;
                           OnWaMouseMove:TOnWaMouseMove;
                           OnWaKeyPress:TOnWaKeyPress;
                           OnGetEntsDesc:TOnGetEntsDesc;
                           OnWaShowCursor:TOnWaShowCursor;

                           procedure GDBActivate;virtual;abstract;
                           procedure GDBActivateContext;virtual;abstract;

                           function getviewcontrol:TCADControl;virtual;abstract;
                           procedure getareacaps;virtual;abstract;
                           procedure CalcOptimalMatrix;virtual;abstract;
                           procedure calcgrid;virtual;abstract;
                           procedure draw;virtual;abstract;
                           procedure DrawOrInvalidate;virtual;abstract;
                           procedure Clear0Ontrackpoint;virtual;abstract;
                           procedure SetMouseMode(smode:Byte);virtual;abstract;
                           //procedure sendcoordtocommandTraceOn(coord:GDBVertex;key: Byte;pos:pos_record);virtual;abstract;
                           procedure reprojectaxis;virtual;abstract;
                           procedure Project0Axis;virtual;abstract;
                           procedure create0axis;virtual;abstract;
                           procedure ZoomToVolume(Volume:TBoundingBox);virtual;abstract;
                           procedure ZoomAll;virtual;abstract;
                           procedure ZoomSel;virtual;abstract;
                           function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer;MousePos: TPoint): Boolean;virtual;abstract;
                           procedure RotTo(x0,y0,z0:GDBVertex);virtual;abstract;
                           procedure PanScreen(oldX,oldY,X,Y:Integer);virtual;abstract;
                           procedure RestoreMouse;virtual;abstract;
                           procedure myKeyPress(var Key: Word; Shift: TShiftState);virtual;abstract;
                           procedure finishdraw(var RC:TDrawContext);virtual;abstract;
                            procedure SetCameraPosZoom(_pos:gdbvertex;_zoom:Double;finalcalk:Boolean);virtual;abstract;

                           procedure showmousecursor;virtual;abstract;
                           procedure hidemousecursor;virtual;abstract;
                           Procedure Paint; virtual;abstract;
                           function CreateRC(_maxdetail:Boolean=false):TDrawContext;virtual;abstract;
                           function CreateFaceRC:TDrawContext;virtual;abstract;
                           function ProjectPoint(pntx,pnty,pntz:Double;var wcsLBN,wcsRTF,dcsLBN,dcsRTF: GDBVertex):gdbvertex;virtual;abstract;
                           procedure mouseunproject(X, Y: integer);virtual;abstract;
                           procedure CalcMouseFrustum;virtual;abstract;
                           procedure ClearOntrackpoint;virtual;abstract;
                           procedure ProcOTrackTimer(Sender:TObject);virtual;abstract;
                           procedure KillOTrackTimer(Sender: TObject);virtual;abstract;
                           procedure SetOTrackTimer(Sender: TObject);virtual;abstract;
                           procedure KillOHintTimer(Sender: TObject);virtual;abstract;
                           procedure SetOHintTimer(Sender: TObject);virtual;abstract;
                           procedure getonmouseobjectbytree(var Node:TEntTreeNode;InSubEntry:Boolean);virtual;abstract;
                           procedure getosnappoint(radius: Single);virtual;abstract;
                           procedure projectaxis;virtual;abstract;
                           procedure AddOntrackpoint;virtual;abstract;
                           procedure CorrectMouseAfterOS;virtual;abstract;
                           //procedure sendmousecoordwop(key: Byte);virtual;abstract;
                           //procedure sendmousecoord(key: Byte);virtual;abstract;
                           function SelectRelatedObjects(pent:PGDBObjEntity):Integer;virtual;abstract;
                           procedure doCameraChanged;virtual;abstract;
                           procedure set3dmouse;virtual;abstract;
                           procedure WaMouseMove(sender:tobject;Shift: TShiftState; X, Y: Integer);virtual;abstract;
                           procedure WaResize(sender:tobject);virtual;abstract;
                           procedure idle(Sender: TObject; var Done: Boolean);virtual;abstract;
                           procedure SwapBuffers(var DC:TDrawContext); virtual;abstract;
                           procedure LightOn(var DC:TDrawContext); virtual;abstract;
                           procedure LightOff(var DC:TDrawContext); virtual;abstract;
                           procedure DrawGrid(var DC:TDrawContext); virtual;abstract;
                           procedure showcursor(var DC:TDrawContext); virtual;abstract;
                           procedure render(const Root:GDBObjGenericSubEntry;var DC:TDrawContext); virtual;abstract;
                           function treerender(var Node:TEntTreeNode;StartTime:TDateTime;var DC:TDrawContext):Boolean;virtual;abstract;
                           procedure partailtreerender(var Node:TEntTreeNode;const part:TBoundingBox; var DC:TDrawContext);virtual;abstract;
                           function startpaint:boolean;virtual;abstract;
                           procedure endpaint;virtual;abstract;
                           procedure asyncupdatemouse(Data: PtrInt);virtual;abstract;
                           function getParam:pointer;virtual;abstract;
                           function getParamTypeName:String;virtual;abstract;
                           procedure setdeicevariable;virtual;abstract;
                           procedure ZoomIn; virtual;abstract;
                           procedure ZoomOut; virtual;abstract;
                           procedure asynczoomsel(Data: PtrInt); virtual;abstract;
                           procedure asynczoomall(Data: PtrInt); virtual;abstract;
                      end;
var
   otracktimer: Integer;
procedure copyospoint(var dest:os_record; source:os_record);
function correcttogrid(point:GDBVertex;const grid:GDBSnap2D):GDBVertex;
function CreateFaceRC:TDrawContext;
implementation
function CreateFaceRC:TDrawContext;
begin
  result.Subrender:=0;
  result.Selected:=false;
  result.DrawingContext.VisibleActualy:=-1;
  result.DrawingContext.InfrustumActualy:=-1;
  result.DrawingContext.DRAWCOUNT:=-1;
  result.DrawingContext.SysLayer:=nil;
  result.MaxDetail:=false;
  result.DrawMode:=true;
  result.OwnerLineWeight:=-3;
  result.OwnerColor:=7;
  result.MaxWidth:=1;
  result.ScrollMode:=true;
  result.DrawingContext.Zoom:=100000000;
  result.drawer:=nil;
  result.DrawingContext.matrixs.pmodelMatrix:=nil;
  result.DrawingContext.matrixs.pprojMatrix:=nil;
  result.DrawingContext.matrixs.pviewport:=nil;
  result.DrawingContext.pcamera:=nil;
  result.Options:=[];
end;

function TCADControl.DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean;
begin
     result:=inherited;
end;
{$IFDEF DELPHI}
procedure TCADControl.WMPaint(var Message: TWMPaint);
begin
     if assigned(FOnPaint) then
                               FOnPaint(self)
                           else
                               inherited;
end;
{$ENDIF}
function correcttogrid(point:GDBVertex;const grid:GDBSnap2D):GDBVertex;
begin
  result.x:=round((point.x-grid.Base.x)/grid.Spacing.x)*grid.Spacing.x+grid.Base.x;
  result.y:=round((point.y-grid.Base.y)/grid.Spacing.y)*grid.Spacing.y+grid.Base.y;
  result.z:=point.z;
end;
procedure copyospoint(var dest:os_record; source:os_record);
begin
       dest.worldcoord:=source.worldcoord;
       dest.dispcoord:=source.dispcoord;
       dest.ostype:=source.ostype;
       //dest.radius:=source.radius;
       //dest.dmousecoord:=source.dmousecoord;
       //dest.tmouse:=source.tmouse;
       dest.PGDBObject:=source.PGDBObject;
end;
begin
end.
