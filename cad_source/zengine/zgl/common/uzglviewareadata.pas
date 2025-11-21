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

unit uzglviewareadata;
{$Mode delphi}{$H+}
{$INCLUDE zengineconfig.inc}

interface
uses
  uzegeometry,uzeconsts,uzegeometrytypes,uzbtypes, UGDBPoint3DArray,
  UGDBTracePropArray,uzgldrawcontext,uzeentsubordinated,uzeSnap;
const
MZW_LBUTTON=1;
MZW_MBUTTON=2;
MZW_RBUTTON=4;
MZW_DOUBLE=8;
MZW_ALT=32;
MZW_CONTROL=64;
MZW_SHIFT=128;
type
  TBUTTONSTATE=(BSUP,BSDOWN);
  TShowCursorHandler=procedure (var DC:TDrawContext) of object;
{Export+}
pcontrolpointdesc=^controlpointdesc;
{REGISTERRECORDTYPE controlpointdesc}
controlpointdesc=record
                   pt:TSnapType;
                   vn:Integer;

                       attr:TControlPointAttrs;
                       PDrawable:PGDBObjDrawable;
                       worldcoord:TzePoint3d;
                       dcoord:TzePoint3d;
                       dispcoord:TzePoint2i;
                       selected:Boolean;
                   {-}function gvnum:Integer;{//}
                   {-}procedure svnum(AVertexNum:Integer);{//}
                   {-}property pointtype:TSnapType read pt write pt;{//}
                   {-}property vertexnum:Integer read gvnum write svnum;{//}
                 end;
{REGISTERRECORDTYPE TRTModifyData}
TRTModifyData=record
                   point:controlpointdesc;
                   dist,wc:TzePoint3d;
             end;
{REGISTERRECORDTYPE tcontrolpointdist}
tcontrolpointdist=record
  pcontrolpoint:pcontrolpointdesc;
  disttomouse:Integer;
end;

  pmousedesc = ^mousedesc;
  {REGISTERRECORDTYPE mousedesc}
  mousedesc = record
    mode: Byte;
    mouse, mouseglue: TzePoint2i;
    glmouse:TzePoint2i;
    workplane:TzeVector4d;
    WPPointLU,WPPointUR,WPPointRB,WPPointBL:TzePoint3d;
    mouseraywithoutOS: GDBPiece;
    mouseray: GDBPiece;
    mouseonworkplanecoord: TzePoint3d;
    mouse3dcoord: TzePoint3d;
    mouseonworkplan: Boolean;
    mousein: Boolean;
  end;

  PSelectiondesc = ^Selectiondesc;
  {REGISTERRECORDTYPE Selectiondesc}
  Selectiondesc = record
    OnMouseObject,LastSelectedObject:Pointer;
    Selectedobjcount:Integer;
    MouseFrameON: Boolean;
    MouseFrameInverse:Boolean;
    Frame1, Frame2: TzePoint2i;
    Frame13d, Frame23d: TzePoint3d;
    BigMouseFrustum:ClipArray;
  end;
  {REGISTERRECORDTYPE tcpdist}
  tcpdist = record
    cpnum: Integer;
    cpdist: Integer;
  end;
  {REGISTERRECORDTYPE objcontrolpoint}
  objcontrolpoint = record
    objnum: Integer;
    newobjnum: Integer;
    ostype: real;
    worldcoord: TzePoint3d;
    dispcoord: TzePoint2i;
    selected: Boolean;
  end;
  pos_record=^os_record;
  {REGISTERRECORDTYPE os_record}
  os_record = record
    worldcoord: TzePoint3d;
    dispcoord: TzePoint3d;
    dmousecoord: TzePoint3d;
    tmouse: Double;
    arrayworldaxis:GDBPoint3DArray;
    arraydispaxis:GDBtracepropArray;
    ostype:TSnapType;
    radius: Single;
    PGDBObject:Pointer;
  end;
  {REGISTERRECORDTYPE totrackarray}
  totrackarray = record
    otrackarray: packed array[0..3] of os_record;
    total, current: Integer;
  end;
  {REGISTERRECORDTYPE TCSIcon}
  TCSIcon=record
               CSIconCoord: TzePoint3d;
               CSIconX,CSIconY,CSIconZ: TzePoint3d;
               CS0: TzePoint2d;
               CSX, CSY, CSZ: TzePoint2d;
               AxisLen:Double;
         end;
  TForceRedrawVolume=record
   ForceRedraw:Boolean;
   Volume:TBoundingBox;
  end;

  POGLWndtype = ^OGLWndtype;
  OGLWndtype = object(GDBaseObject)
    polarlinetrace: Integer;
    pointnum, axisnum: Integer;
    CSIcon:TCSIcon;
    BLPoint,CPoint,TRPoint:TzePoint2d;
    ViewHeight:Double;
    projtype: Integer;
    firstdraw: Boolean;
    md: mousedesc;
    gluetocp: Boolean;
    cpdist: tcpdist;
    ospoint, oldospoint: os_record;
    height, width: Integer;
    SelDesc: Selectiondesc;
    scrollmode:Boolean;
    lastcp3dpoint,lastpoint: TzePoint3d;
    lastonmouseobject:Pointer;
    nearesttcontrolpoint:tcontrolpointdist;
    startgluepoint:pcontrolpointdesc;
    ontrackarray: totrackarray;
    mouseclipmatrix:DMatrix4d;
    mousefrustum,mousefrustumLCS:ClipArray;
    ShowDebugFrustum:Boolean;
    debugfrustum:ClipArray;
    ShowDebugBoundingBbox:Boolean;
    DebugBoundingBbox:TBoundingBox;
    processObjConstruct:Boolean;
    ForceRedrawVolume:TForceRedrawVolume;
    constructor init;
    destructor done;virtual;
  end;
{Export-}
//ppolaraxis: PGDBOpenArrayVertex_GDBWord;


implementation

function controlpointdesc.gvnum:Integer;
begin
  result:=vn;
end;

procedure controlpointdesc.svnum(AVertexNum:Integer);
begin
  vn:=AVertexNum;
  pt:=os_polymin;
end;

constructor OGLWndtype.init;
var
  i:integer;
begin
  projtype := Projparallel;
  firstdraw := true;
  SelDesc.OnMouseObject := nil;
  lastonmouseobject:=nil;
  SelDesc.LastSelectedObject := nil;
  gluetocp := false;
  cpdist.cpnum := -1;
  cpdist.cpdist := 99999;

  seldesc.MouseFrameON := false;
  ontrackarray.total := 1;
  ontrackarray.current := 1;
  md.workplane.v[0] := 0;
  md.workplane.v[1] := 0;
  md.workplane.v[2] := 1;
  md.workplane.v[3] := 0;
  scrollmode:=false;

  md.mousein:=false;
  processObjConstruct:=false;
  ShowDebugBoundingBbox:=false;
  ShowDebugFrustum:=false;
  CSIcon.AxisLen:=0;

  CSIcon.CSIconCoord:=nulvertex;
  CSIcon.CSIconX:=nulvertex;
  CSIcon.CSIconY:=nulvertex;

  CSIcon.CSIconZ:=nulvertex;

  ontrackarray.otrackarray[0].arrayworldaxis.init(10);
  ontrackarray.otrackarray[0].arraydispaxis.init(10);


       for i := 0 to 3 do
                       begin
                       ontrackarray.otrackarray[i].arrayworldaxis.init(10);
                       ontrackarray.otrackarray[i].arrayworldaxis.CreateArray;
                       ontrackarray.otrackarray[i].arraydispaxis.init(10);
                       ontrackarray.otrackarray[i].arraydispaxis.CreateArray;
                       end;


       ospoint.arraydispaxis.init(10);
       ospoint.arrayworldaxis.init(10);
  ForceRedrawVolume.ForceRedraw:=false;
end;

destructor OGLWndtype.done;
var
  i:integer;
begin
  ospoint.arraydispaxis.done;
  ospoint.arrayworldaxis.done;
  for i := 0 to 3 do
                   begin
                     ontrackarray.otrackarray[i].arrayworldaxis.done;
                     ontrackarray.otrackarray[i].arraydispaxis.done;
                   end;

end;

end.
