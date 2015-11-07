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

unit uzglabstractviewarea;
{$INCLUDE def.inc}
interface
uses {gdbase,gdbasetypes,
     UGDBLayerArray,ugdbltypearray,UGDBTextStyleArray,ugdbdimstylearray,UGDBPoint3DArray,
     oglwindowdef,gdbdrawcontext,UGDBEntTree,ugdbabstractdrawing,
     uinfoform,}
     UGDBOpenArrayOfPV,uzglabstractdrawer,GDBGenericSubEntry,gdbase,gdbasetypes,
     oglwindowdef,gdbdrawcontext,varmandef,{Varman,}UGDBPoint3DArray,UGDBEntTree,geometry,ugdbabstractdrawing,
     {shared,}sysutils,
     ExtCtrls,Controls,Classes,LCLType,Forms,zcadsysvars,GDBEntity;

type
    TCADControl=class(TCustomControl)
                public
                function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean; overload;
                property OnMouseUp;
                property onmousedown;
                property onmousemove;
                property onmousewheel;
                property onmouseenter;
                property onmouseleave;
                property onresize;
                property onpaint;
                end;
    TCameraChangedNotify=procedure of object;
    TAbstractViewArea=class;
    TOnWaMouseDown=function (Sender:TAbstractViewArea;Button:TMouseButton;Shift:TShiftState;X,Y:Integer;OnMouseEntity:GDBPointer):boolean of object;
    TOnWaMouseSelect=procedure (Sender:TAbstractViewArea;SelectedEntity:GDBPointer) of object;
    TOnGetEntsDesc=function (ents:PGDBObjOpenArrayOfPV):GDBString of object;
    TWAGeneralMethod=procedure (Sender:TAbstractViewArea) of object;
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
                           MainMouseDown:function:boolean of object;
                           tocommandmcliccount:GDBInteger;
                           currentmousemovesnaptogrid:GDBBoolean;
                           OnWaMouseDown:TOnWaMouseDown;
                           OnWaMouseSelect:TOnWaMouseSelect;
                           OnGetEntsDesc:TOnGetEntsDesc;
                           OnSetObjInsp:TWAGeneralMethod;

                           procedure GDBActivate;virtual;abstract;
                           procedure GDBActivateGLContext;virtual;abstract;

                           function getviewcontrol:TCADControl;virtual;abstract;
                           procedure getareacaps;virtual;abstract;
                           procedure CalcOptimalMatrix;virtual;abstract;
                           procedure calcgrid;virtual;abstract;
                           procedure draw;virtual;abstract;
                           procedure DrawOrInvalidate;virtual;abstract;
                           procedure Clear0Ontrackpoint;virtual;abstract;
                           procedure SetMouseMode(smode:GDBByte);virtual;abstract;
                           procedure SetObjInsp;virtual;abstract;
                           procedure sendcoordtocommandTraceOn(coord:GDBVertex;key: GDBByte;pos:pos_record);virtual;abstract;
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
                            procedure SetCameraPosZoom(_pos:gdbvertex;_zoom:gdbdouble;finalcalk:gdbboolean);virtual;abstract;

                           procedure showmousecursor;virtual;abstract;
                           procedure hidemousecursor;virtual;abstract;
                           Procedure Paint; virtual;abstract;
                           function CreateRC(_maxdetail:GDBBoolean=false):TDrawContext;virtual;abstract;
                           function CreateFaceRC:TDrawContext;virtual;abstract;
                           function ProjectPoint(pntx,pnty,pntz:gdbdouble;var wcsLBN,wcsRTF,dcsLBN,dcsRTF: GDBVertex):gdbvertex;virtual;abstract;
                           procedure mouseunproject(X, Y: integer);virtual;abstract;
                           procedure CalcMouseFrustum;virtual;abstract;
                           procedure ClearOntrackpoint;virtual;abstract;
                           procedure ProcOTrackTimer(Sender:TObject);virtual;abstract;
                           procedure KillOTrackTimer(Sender: TObject);virtual;abstract;
                           procedure SetOTrackTimer(Sender: TObject);virtual;abstract;
                           procedure KillOHintTimer(Sender: TObject);virtual;abstract;
                           procedure SetOHintTimer(Sender: TObject);virtual;abstract;
                           procedure getonmouseobjectbytree(Node:TEntTreeNode;InSubEntry:GDBBoolean);virtual;abstract;
                           procedure getosnappoint(radius: GDBFloat);virtual;abstract;
                           procedure projectaxis;virtual;abstract;
                           procedure AddOntrackpoint;virtual;abstract;
                           procedure CorrectMouseAfterOS;virtual;abstract;
                           procedure sendmousecoordwop(key: GDBByte);virtual;abstract;
                           procedure sendmousecoord(key: GDBByte);virtual;abstract;
                           function SelectRelatedObjects(pent:PGDBObjEntity):GDBInteger;virtual;abstract;
                           procedure doCameraChanged;virtual;abstract;
                           procedure set3dmouse;virtual;abstract;
                           procedure WaMouseMove(sender:tobject;Shift: TShiftState; X, Y: Integer);virtual;abstract;
                           procedure WaResize(sender:tobject);virtual;abstract;
                           procedure SwapBuffers(var DC:TDrawContext); virtual;abstract;
                           procedure LightOn(var DC:TDrawContext); virtual;abstract;
                           procedure LightOff(var DC:TDrawContext); virtual;abstract;
                           procedure DrawGrid(var DC:TDrawContext); virtual;abstract;
                           procedure showcursor(var DC:TDrawContext); virtual;abstract;
                           procedure render(const Root:GDBObjGenericSubEntry;var DC:TDrawContext); virtual;abstract;
                           function treerender(var Node:TEntTreeNode;StartTime:TDateTime;var DC:TDrawContext):GDBBoolean; virtual;abstract;
                           function startpaint:boolean;virtual;abstract;
                           procedure endpaint;virtual;abstract;
                           procedure asyncupdatemouse(Data: PtrInt);virtual;abstract;
                           function getParam:pointer;virtual;abstract;
                           function getParamTypeName:GDBString;virtual;abstract;
                           procedure setdeicevariable;virtual;abstract;
                           procedure ZoomIn; virtual;abstract;
                           procedure ZoomOut; virtual;abstract;
                      end;
var
   otracktimer: GDBInteger;
procedure copyospoint(out dest:os_record; source:os_record);
function docorrecttogrid(point:GDBVertex;need:GDBBoolean):GDBVertex;
function correcttogrid(point:GDBVertex):GDBVertex;
function CreateFaceRC:TDrawContext;
implementation
function CreateFaceRC:TDrawContext;
begin
  result.Subrender:=0;
  result.Selected:=false;
  result.VisibleActualy:=-1;
  result.InfrustumActualy:=-1;
  result.DRAWCOUNT:=-1;
  result.SysLayer:=nil;
  result.MaxDetail:=false;
  result.DrawMode:=true;
  result.OwnerLineWeight:=-3;
  result.OwnerColor:=7;
  result.MaxWidth:=1;
  result.ScrollMode:=true;
  result.Zoom:=100000000;
  result.drawer:=nil;
  result.matrixs.pmodelMatrix:=nil;
  result.matrixs.pprojMatrix:=nil;
  result.matrixs.pviewport:=nil;
  result.pcamera:=nil;
end;

function TCADControl.DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean;
begin
     inherited;
end;
function docorrecttogrid(point:GDBVertex;need:GDBBoolean):GDBVertex;
var
   gr:GDBBoolean;
begin
     gr:=false;
     if SysVar.DWG.DWG_SnapGrid<>nil then
     if SysVar.DWG.DWG_SnapGrid^ then
                                     gr:=true;
     if (need and gr) then
                          begin
                               result:=correcttogrid(point);
                               {result.x:=round((point.x-SysVar.DWG.DWG_Snap.Base.x)/SysVar.DWG.DWG_Snap.Spacing.x)*SysVar.DWG.DWG_Snap.Spacing.x+SysVar.DWG.DWG_Snap.Spacing.x;
                               result.y:=round((point.y-SysVar.DWG.DWG_Snap.Base.y)/SysVar.DWG.DWG_Snap.Spacing.y)*SysVar.DWG.DWG_Snap.Spacing.y+SysVar.DWG.DWG_Snap.Spacing.y;
                               result.z:=point.z;}
                          end
                      else
                          result:=point;
end;
function correcttogrid(point:GDBVertex):GDBVertex;
begin
  result.x:=round((point.x-SysVar.DWG.DWG_Snap.Base.x)/SysVar.DWG.DWG_Snap.Spacing.x)*SysVar.DWG.DWG_Snap.Spacing.x+SysVar.DWG.DWG_Snap.Base.x;
  result.y:=round((point.y-SysVar.DWG.DWG_Snap.Base.y)/SysVar.DWG.DWG_Snap.Spacing.y)*SysVar.DWG.DWG_Snap.Spacing.y+SysVar.DWG.DWG_Snap.Base.y;
  result.z:=point.z;
end;
procedure copyospoint(out dest:os_record; source:os_record);
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
  {$IFDEF DEBUGINITSECTION}LogOut('abstractviewarea.initialization');{$ENDIF}
end.
