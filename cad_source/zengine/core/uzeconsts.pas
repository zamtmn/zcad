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

unit uzeconsts;
{$INCLUDE zengineconfig.inc}

interface
//uses gdbasetypes;
const {as_normal=0;
      as_point=1;
      as_line=2;}

  SHXLine=$01;
  SHXPoly=$02;
  SHXCountur=$08;
  SHXCounturCCW=$0C;
  SHXCounturCW=$0D;

  GDBRootId = 30001;
  GDBcameraID = 0;
  GDBPointID = 1;
  GDBLineID = 2;
  GDBCircleID = 3;
  GDBPolyLineID = 4;
  GDBtextID = 5;
  GDBarcID = 6;
  GDBBlockInsertID = 7;
  GDBMTextID = 8;
  GDBLWPolylineID = 9;
  GDB3DfaceID = 10;
  GDBSolidID = 11;
  GDBEllipseID = 12;
  GDBSplineID = 13;
  GDBGenericDimensionID = 14;
  GDBBlockDefID = 15;
  GDBHatchID = 16;

  GDBNetID = 100;
  GDBDeviceID = 101;
  GDBCableID = 102;
  GDBTableID = 103;
  GDBElLeaderID = 104;
  GDBZCadEntsMinID=GDBNetID;
  GDBZCadEntsMaxID=GDBElLeaderID;

  GDBAlignedDimensionID = 105;
  GDBRotatedDimensionID = 106;
  GDBDiametricDimensionID = 107;
  GDBRadialDimensionID = 108;
  GDBSuperLineID = 109;

  PROJParallel = 1;
  PROJPerspective = 2;

  DXFjstl = 1;
  DXFjstm = 2;
  DXFjstr = 3;
  DXFjsml = 4;
  DXFjsmc = 5;
  DXFjsmr = 6;
  DXFjsbl = 7;
  DXFjsbc = 8;
  DXFjsbr = 9;
  DXFjsbtl = 10;
  DXFjsbtc = 11;
  DXFjsbtr = 12;


  LnWt000 = 0;
  LnWt005 = 5;
  LnWt009 = 9;
  LnWt013 = 13;
  LnWt015 = 15;
  LnWt018 = 18;
  LnWt020 = 20;
  LnWt025 = 25;
  LnWt030 = 30;
  LnWt035 = 35;
  LnWt040 = 40;
  LnWt050 = 50;
  LnWt053 = 53;
  LnWt060 = 60;
  LnWt070 = 70;
  LnWt080 = 80;
  LnWt090 = 90;
  LnWt100 = 100;
  LnWt106 = 106;
  LnWt120 = 120;
  LnWt140 = 140;
  LnWt158 = 158;
  LnWt200 = 200;
  LnWt211 = 211;
  LnWtByLayer = -1;
  LnWtByBlock = -2;
  LnWtByLwDefault = -3;
  LnWtNormalizeOffset = 3;

  CGDBWhile = 7;
  CGDBGreen = 3;
  lwgdbdefault = -3;

  se_Abstract=0;
  se_ModelRoot=1;
  se_ElectricalWires=2;

  maxtrackpoint = 3;
  numofcp = 65535;
  marksize = 10;
  nNumPoints = 5;
  sizeaxis = 50;

  MNone = 0;
  MMoveCamera = 1;
  MRotateCamera = 2;
  MGet3DPoint = 4;
  MGet3DPointWoOP = 8;
  MGetControlpoint = 16;
  MGetSelectObject = 32;
  MGetSelectionFrame = 64;

  ObjN_GDBObjText='GDBObjText';
  ObjN_GDBObjMText='GDBObjMText';
  ObjN_GDBObjLine='GDBObjLine';
  ObjN_GDBObjSuperLine='GDBObjSuperLine';
  ObjN_GDBObjCircle='GDBObjCircle';
  ObjN_GDBObjArc='GDBObjArc';
  ObjN_GDBObjEllipse='GDBObjEllipse';
  ObjN_GDBObjPoint='GDBObjPoint';
  ObjN_GDBObj3DFace='GDBObj3DFace';
  ObjN_GDBObjSolid='GDBObjSolid';
  ObjN_GDBObjCurve='GDBObjCurve';
  ObjN_GDBObjPolyLine='GDBObjPolyLine';
  ObjN_GDBObjSpline='GDBObjSpline';
  ObjN_ObjAlignedDimension='GDBObjAlignedDimension';
  ObjN_ObjRotatedDimension='GDBObjRotatedDimension';
  ObjN_ObjDiametricDimension='GDBObjDiametricDimension';
  ObjN_ObjRadialDimension='GDBObjRadialDimension';
  ObjN_GDBObjLWPolyLine='GDBObjLWPolyLine';
  ObjN_GDBObjBlockInsert='GDBObjBlockInsert';
  ObjN_GDBObjDevice='GDBObjDevice';
  ObjN_GDBObjNet='GDBObjNet';
  ObjN_GDBObjCable='GDBObjCable';
  ObjN_GDBObjElLeader='GDBObjElLeader';
  ObjN_GDBObjHatch='GDBObjHatch';

  DevicePrefix='DEVICE_';
  DrawingDeviceBaseUnitName='drawingdevicebase';

  LNSysLayerName='0';
  LNSysDefpoints='DEFPOINTS';
  LNMetricLayerName='SYS_METRIC';

  TSNStandardStyleName='STANDARD';

  ZCADAppNameInDXF='DSTP_XDATA';

  H_Root=100;
  H_Trash=110;

  {Upgrade объектов DXF}
  UD_LineToLeader=1;
  UD_LineToNet=2;

  UD_LineToSuperLine=10;
  UD_BlockInsertToTable=11;

  ClByBlock=0;
  ClByLayer=256;
  ClDifferent=258;
  ClSelColor=257;
  ClWhite=7;
  ClBlack=0;
  ClCanalMin=20;

  str_empty='**EMPTY STRING**';

implementation

end.
