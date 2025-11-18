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
     ExtCtrls,Controls,Classes,{$IFDEF DELPHI}Types,Messages,Graphics,{$ENDIF}{$IFNDEF DELPHI}LCLType,{$ENDIF}uzeentity,
     uzepalette,uzeconsts;

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
    TZKeys=Byte;
    TCameraChangedNotify=procedure of object;
    TAbstractViewArea=class;
    TOnWaMouseDown=function (Sender:TAbstractViewArea;ZC:TZKeys;X,Y:Integer;OnMouseEntity:Pointer;var NeedRedraw:Boolean):boolean of object;
    TOnWaMouseUp=function (Sender:TAbstractViewArea;ZC:TZKeys;X,Y:Integer;OnMouseEntity:Pointer;var NeedRedraw:Boolean):boolean of object;
    TOnWaMouseMove=procedure (Sender:TAbstractViewArea;ZC:TZKeys;X,Y:Integer) of object;
    TOnWaMouseSelect=procedure (Sender:TAbstractViewArea;SelectedEntity:Pointer) of object;
    TOnWaKeyPress=procedure (Sender:TAbstractViewArea;var Key: Word; Shift: TShiftState) of object;
    TOnGetEntsDesc=function (ents:PGDBObjOpenArrayOfPV):String of object;
    TOnWaShowCursor=procedure (Sender:TAbstractViewArea;var DC:TDrawContext) of object;
    TAbstractViewArea=class(tcomponent)
                           public
                           Drawer:TZGLAbstractDrawer;
                           param: OGLWndtype;
                           PolarAxis:GDBPoint3dArray;
                           PDWG:PTAbstractDrawing;
                           onCameraChanged:TCameraChangedNotify;
                           ShowCXMenu:procedure of object;
                           MainMouseMove:procedure of object;
                           MainMouseDown:function(Sender:TAbstractViewArea):boolean of object;
                           MainMouseUp:procedure of object;
                           tocommandmcliccount:Integer;
                           currentmousemovesnaptogrid:Boolean;
                           OnWaMouseDown:TOnWaMouseDown;
                           OnWaMouseUp:TOnWaMouseUp;
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
                           procedure RotTo(x0,y0,z0:TzePoint3d);virtual;abstract;
                           procedure PanScreen(oldX,oldY,X,Y:Integer);virtual;abstract;
                           procedure RestoreMouse;virtual;abstract;
                           procedure myKeyPress(var Key: Word; Shift: TShiftState);virtual;abstract;
                           procedure finishdraw(var RC:TDrawContext);virtual;abstract;
                            procedure SetCameraPosZoom(const _pos:TzePoint3d;_zoom:Double;finalcalk:Boolean);virtual;abstract;

                           procedure showmousecursor;virtual;abstract;
                           procedure hidemousecursor;virtual;abstract;
                           Procedure Paint; virtual;abstract;
                           function CreateRC(_maxdetail:Boolean=false):TDrawContext;virtual;abstract;
                           function CreateFaceRC:TDrawContext;virtual;abstract;
                           function ProjectPoint(pntx,pnty,pntz:Double;var wcsLBN,wcsRTF,dcsLBN,dcsRTF: TzePoint3d):TzePoint3d;virtual;abstract;
                           procedure mouseunproject(X, Y: integer);virtual;abstract;
                           procedure CalcMouseFrustum;virtual;abstract;
                           procedure ClearOntrackpoint;virtual;abstract;
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
                           function treerender(var Node:TEntTreeNode;StartTime:TDateTime;var DC:TDrawContext;LODDeep:integer=0):Boolean;virtual;abstract;
                           procedure partailtreerender(var Node:TEntTreeNode;const part:TBoundingBox; var DC:TDrawContext;LODDeep:integer=0);virtual;abstract;
                           function startpaint:boolean;virtual;abstract;
                           procedure endpaint;virtual;abstract;
                           procedure asyncupdatemouse(Data: PtrInt);virtual;abstract;
                           procedure asyncsendmouse(Data: PtrInt);virtual;abstract;
                           function getParam:pointer;virtual;abstract;
                           function getParamTypeName:String;virtual;abstract;
                           procedure setdeicevariable;virtual;abstract;
                           procedure ZoomIn; virtual;abstract;
                           procedure ZoomOut; virtual;abstract;
                           procedure asynczoomsel(Data: PtrInt); virtual;abstract;
                           procedure asynczoomall(Data: PtrInt); virtual;abstract;
                      end;
procedure copyospoint(var dest:os_record; source:os_record);
function correcttogrid(const point:TzePoint3d;const grid:GDBSnap2D):TzePoint3d;
function CreateFaceRC:TDrawContext;
var
  sysvarDISPOSSize:double=10;
  sysvarDISPCursorSize:integer=10;
  SysVarDISPCrosshairSize:double=0.05;
  sysvarDISPBackGroundColor:TRGB=(r:0;g:0;b:0;a:255);
  sysvarRDMaxRenderTime:integer=0;
  sysvarDISPZoomFactor:double=1.624;
  sysvarDISPSystmGeometryDraw:boolean=false;
  sysvarDISPShowCSAxis:boolean=true;
  sysvarDISPSystmGeometryColor:TGDBPaletteColor=1;
  sysvarDISPHotGripColor:TGDBPaletteColor=2;
  sysvarDISPSelGripColor:TGDBPaletteColor=3;
  sysvarDISPUnSelGripColor:TGDBPaletteColor=4;
  sysvarDWGOSMode:TGDBOSMode=0;
  sysvarDWGOSModeControl:Boolean=True;
  sysvarDISPGripSize:Integer=5;
  sysvarDISPColorAxis:boolean=true;
  sysvarDISPDrawZAxis:boolean=true;
  sysvarDrawInsidePaintMessage:TGDB3StateBool=T3SB_Default;
  sysvarDWGPolarMode:Boolean=false;
  SysVarRDLineSmooth:Boolean=false;
  sysvarRDUseStencil:Boolean=false;
  sysvarRDLastRenderTime:integer=0;
  sysvarRDLastUpdateTime:integer=0;
  sysvarRDEnableAnimation:boolean=true;
  SysVarRDImageDegradationEnabled:boolean=false;
  SysVarRDImageDegradationPrefferedRenderTime:integer=0;
  SysVarRDImageDegradationCurrentDegradationFactor:Double=0;
  SysVarRDImageDegradationMaxDegradationFactor:Double=0;
  SysVarDISPRemoveSystemCursorFromWorkArea:Boolean=true;
  sysvarDSGNSelNew:Boolean=false;
  sysvarDWGEditInSubEntry:Boolean=false;
  sysvarDSGNOTrackTimerInterval:Integer=500;
  sysvarRDLastCalcVisible:Integer=0;
  sysvarRDLight:boolean=false;
  sysvarDISPLWDisplayScale:Integer=10;
  sysvarDISPmaxLWDisplayScale:Integer=20;
  sysvarDISPDefaultLW:TGDBLineWeight=LnWt025;
  sysvarDSGNEntityMoveStartTimerInterval:Integer=300;
  sysvarDSGNEntityMoveStartOffset:Integer=-30;
  sysvarDSGNEntityMoveByMouseUp:Boolean=True;
  sysvarDSGNMaxSelectEntsCountWithObjInsp:Integer=25000;
  sysvarDSGNMaxSelectEntsCountWithGrips:Integer=100;
implementation
function CreateFaceRC:TDrawContext;
begin
  result.Subrender:=0;
  result.Selected:=false;
  result.DrawingContext.VActuality.VisibleActualy:=NotActual;
  result.DrawingContext.VActuality.InfrustumActualy:=NotActual;
  result.DrawingContext.DRAWCOUNT:=NotActual;
  result.DrawingContext.SysLayer:=nil;
  result.MaxDetail:=false;
  result.LOD:=LODCalculatedDetail;
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
function correcttogrid(const point:TzePoint3d;const grid:GDBSnap2D):TzePoint3d;
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
