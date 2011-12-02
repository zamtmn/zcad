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

unit oglwindowdef;
{$INCLUDE def.inc}

interface
uses gdbasetypes,gdbase{,gdbobjectsconstdef}, UGDBPoint3DArray,UGDBTracePropArray{,GDBCamera};
const
MZW_LBUTTON=1;
MZW_SHIFT=128;
MZW_CONTROL=64;
type
{Export+}
  pmousedesc = ^mousedesc;
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
  end;

  PSelectiondesc = ^Selectiondesc;
  Selectiondesc = record
    OnMouseObject,LastSelectedObject:GDBPointer;
    Selectedobjcount:GDBInteger;
    MouseFrameON: GDBBoolean;
    MouseFrameInverse:GDBBoolean;
    Frame1, Frame2: GDBvertex2DI;
    Frame13d, Frame23d: GDBVertex;
    BigMouseFrustum:ClipArray;
  end;
type
  tcpdist = record
    cpnum: GDBInteger;
    cpdist: GDBInteger;
  end;
  traceprop2 = record
    tmouse: GDBDouble;
    dmouse: GDBInteger;
    dir: GDBVertex;
    dispraycoord: GDBVertex;
    worldraycoord: GDBVertex;
  end;
  arrtraceprop = array[0..0] of traceprop;
  GDBArraytraceprop_GDBWord = record
    count: GDBWord;
    arr: arrtraceprop;
  end;
  objcontrolpoint = record
    objnum: GDBInteger;
    newobjnum: GDBInteger;
    ostype: real;
    worldcoord: gdbvertex;
    dispcoord: GDBvertex2DI;
    selected: GDBBoolean;
  end;
  arrayobjcontrolpoint = array[0..0] of objcontrolpoint;
  popenarrayobjcontrolpoint_GDBWordwm = ^openarrayobjcontrolpoint_GDBWordwm;
  openarrayobjcontrolpoint_GDBWordwm = record
    count, max: GDBWord;
    arraycp: arrayobjcontrolpoint;
  end;

  PGDBOpenArraytraceprop_GDBWord = ^GDBArraytraceprop_GDBWord;
  pos_record=^os_record;
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
  totrackarray = record
    otrackarray: array[0..3] of os_record;
    total, current: GDBInteger;
  end;
  POGLWndtype = ^OGLWndtype;
  OGLWndtype = record
    polarlinetrace: GDBInteger;
    pointnum, axisnum: GDBInteger;
    CSIconCoord: GDBvertex;
    CSX, CSY, CSZ: GDBvertex2DI;
    projtype: GDBInteger;
    clipx, clipy: GDBDouble;
    firstdraw: GDBBoolean;
    md: mousedesc;
    gluetocp: GDBBoolean;
    cpdist: tcpdist;
    ospoint, oldospoint: os_record;
    height, width: GDBInteger;
    SelDesc: Selectiondesc;
    pglscreen: GDBPointer;
    subrender, otracktimerwork: GDBInteger;
    scrollmode:GDBBoolean;
    lastcp3dpoint,lastpoint: GDBVertex;
    cslen:GDBDouble;
    lastonmouseobject:GDBPointer;
    nearesttcontrolpoint:tcontrolpointdist;
    startgluepoint:pcontrolpointdesc;
    ontrackarray: totrackarray;
    mouseclipmatrix:Dmatrix4D;
    mousefrustum,mousefrustumLCS:ClipArray;
  end;
{Export-}
//ppolaraxis: PGDBOpenArrayVertex_GDBWord;


implementation

end.
