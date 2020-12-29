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

unit uzglviewareadata;
{$INCLUDE def.inc}

interface
uses
  uzegeometry,uzeconsts,uzbgeomtypes,uzbtypesbase,uzbtypes, UGDBPoint3DArray,
  UGDBTracePropArray,uzgldrawcontext;
const
MZW_LBUTTON=1;
MZW_SHIFT=128;
MZW_CONTROL=64;
type
  TShowCursorHandler=procedure (var DC:TDrawContext) of object;
{Export+}
  pmousedesc = ^mousedesc;
  {REGISTERRECORDTYPE mousedesc}
  mousedesc = record
    mode: GDBByte;
    mouse, mouseglue: GDBvertex2DI;
    glmouse:GDBvertex2DI;
    workplane: {GDBplane}DVector4D;
    WPPointLU,WPPointUR,WPPointRB,WPPointBL:GDBvertex;
    mouseraywithoutOS: GDBPiece;
    mouseray: GDBPiece;
    mouseonworkplanecoord: GDBvertex;
    mouse3dcoord: GDBvertex;
    mouseonworkplan: GDBBoolean;
    mousein: GDBBoolean;
  end;

  PSelectiondesc = ^Selectiondesc;
  {REGISTERRECORDTYPE Selectiondesc}
  Selectiondesc = record
    OnMouseObject,LastSelectedObject:GDBPointer;
    Selectedobjcount:GDBInteger;
    MouseFrameON: GDBBoolean;
    MouseFrameInverse:GDBBoolean;
    Frame1, Frame2: GDBvertex2DI;
    Frame13d, Frame23d: GDBVertex;
    BigMouseFrustum:ClipArray;
  end;
  {REGISTERRECORDTYPE tcpdist}
  tcpdist = record
    cpnum: GDBInteger;
    cpdist: GDBInteger;
  end;
  {REGISTERRECORDTYPE traceprop2}
  traceprop2 = record
    tmouse: GDBDouble;
    dmouse: GDBInteger;
    dir: GDBVertex;
    dispraycoord: GDBVertex;
    worldraycoord: GDBVertex;
  end;
  arrtraceprop = packed array[0..0] of traceprop;
  {REGISTERRECORDTYPE GDBArraytraceprop_GDBWord}
  GDBArraytraceprop_GDBWord = record
    count: GDBWord;
    arr: arrtraceprop;
  end;
  {REGISTERRECORDTYPE objcontrolpoint}
  objcontrolpoint = record
    objnum: GDBInteger;
    newobjnum: GDBInteger;
    ostype: real;
    worldcoord: gdbvertex;
    dispcoord: GDBvertex2DI;
    selected: GDBBoolean;
  end;
  arrayobjcontrolpoint = packed array[0..0] of objcontrolpoint;
  popenarrayobjcontrolpoint_GDBWordwm = ^openarrayobjcontrolpoint_GDBWordwm;
  {REGISTERRECORDTYPE openarrayobjcontrolpoint_GDBWordwm}
  openarrayobjcontrolpoint_GDBWordwm = record
    count, max: GDBWord;
    arraycp: arrayobjcontrolpoint;
  end;

  PGDBOpenArraytraceprop_GDBWord = ^GDBArraytraceprop_GDBWord;
  pos_record=^os_record;
  {REGISTERRECORDTYPE os_record}
  os_record = record
    worldcoord: GDBVertex;
    dispcoord: GDBVertex;
    dmousecoord: GDBVertex;
    tmouse: GDBDouble;
    arrayworldaxis:GDBPoint3DArray;
    arraydispaxis:GDBtracepropArray;
    ostype: GDBFloat;
    radius: GDBFloat;
    PGDBObject:GDBPointer;
  end;
  {REGISTERRECORDTYPE totrackarray}
  totrackarray = record
    otrackarray: packed array[0..3] of os_record;
    total, current: GDBInteger;
  end;
  {REGISTERRECORDTYPE TCSIcon}
  TCSIcon=record
               CSIconCoord: GDBvertex;
               CSIconX,CSIconY,CSIconZ: GDBvertex;
               CSX, CSY, CSZ: GDBvertex2DI;
               AxisLen:GDBDouble;
         end;

  POGLWndtype = ^OGLWndtype;
  OGLWndtype = object(GDBaseObject)
    polarlinetrace: GDBInteger;
    pointnum, axisnum: GDBInteger;
    CSIcon:TCSIcon;
    BLPoint,CPoint,TRPoint:GDBvertex2D;
    ViewHeight:GDBDouble;
    projtype: GDBInteger;
    firstdraw: GDBBoolean;
    md: mousedesc;
    gluetocp: GDBBoolean;
    cpdist: tcpdist;
    ospoint, oldospoint: os_record;
    height, width: GDBInteger;
    SelDesc: Selectiondesc;
    otracktimerwork: GDBInteger;
    scrollmode:GDBBoolean;
    lastcp3dpoint,lastpoint: GDBVertex;
    lastonmouseobject:GDBPointer;
    nearesttcontrolpoint:tcontrolpointdist;
    startgluepoint:pcontrolpointdesc;
    ontrackarray: totrackarray;
    mouseclipmatrix:Dmatrix4D;
    mousefrustum,mousefrustumLCS:ClipArray;
    ShowDebugFrustum:GDBBoolean;
    debugfrustum:ClipArray;
    ShowDebugBoundingBbox:GDBBoolean;
    DebugBoundingBbox:TBoundingBox;
    processObjConstruct:GDBBoolean;
    constructor init;
    destructor done;virtual;
  end;
{Export-}
//ppolaraxis: PGDBOpenArrayVertex_GDBWord;


implementation
constructor OGLWndtype.init;
var
  i:integer;
begin
  projtype := Projparalel;
  firstdraw := true;
  SelDesc.OnMouseObject := nil;
  lastonmouseobject:=nil;
  SelDesc.LastSelectedObject := nil;
  gluetocp := false;
  cpdist.cpnum := -1;
  cpdist.cpdist := 99999;

  seldesc.MouseFrameON := false;
  otracktimerwork := 0;
  ontrackarray.total := 1;
  ontrackarray.current := 1;
  md.workplane{.normal.x}[0] := 0;
  md.workplane{.normal.y}[1] := {sqrt(0.1)}0;
  md.workplane{.normal.z}[2] := {sqrt(0.9)}1;
  md.workplane{.d}[3] := 0;
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

  ontrackarray.otrackarray[0].arrayworldaxis.init({$IFDEF DEBUGBUILD}'{8BE71BAA-507B-4D6B-BE2C-63693022090C}',{$ENDIF}10);
  ontrackarray.otrackarray[0].arraydispaxis.init({$IFDEF DEBUGBUILD}'{722A886F-5616-4E8F-B94D-3A1C3D7ADBD4}',{$ENDIF}10);


       for i := 0 to 3 do
                       begin
                       ontrackarray.otrackarray[i].arrayworldaxis.init({$IFDEF DEBUGBUILD}'{722A886F-5616-4E8F-B94D-3A1C3D7ADBD4}',{$ENDIF}10);
                       ontrackarray.otrackarray[i].arrayworldaxis.CreateArray;
                       ontrackarray.otrackarray[i].arraydispaxis.init({$IFDEF DEBUGBUILD}'{722A886F-5616-4E8F-B94D-3A1C3D7ADBD4}',{$ENDIF}10);
                       ontrackarray.otrackarray[i].arraydispaxis.CreateArray;
                       end;


       ospoint.arraydispaxis.init({$IFDEF DEBUGBUILD}'{722A886F-5616-4E8F-B94D-3A1C3D7ADBD4}',{$ENDIF}10);
       ospoint.arrayworldaxis.init({$IFDEF DEBUGBUILD}'{722A886F-5616-4E8F-B94D-3A1C3D7ADBD4}',{$ENDIF}10);
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
