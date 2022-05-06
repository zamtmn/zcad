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

unit uzeSnap;
{$INCLUDE zengineconfig.inc}

interface

uses
  {uzbhandles,}uzbnamedhandles,uzbnamedhandleswithdata;

type
  TSnapInternalType=Integer;
  TSnapNameType=String;
  TSnapLincedData=record
  end;
  TTSnapType=GTNamedHandlesWithData<TSnapInternalType,GTLinearIncHandleManipulator<TSnapInternalType>,TSnapNameType,GTStringNamesUPPERCASE<TSnapNameType>,TSnapLincedData>;
  TSnapType=TSnapInternalType;{(
  os_p1,
  os_p2,
  os_p3,
  os_p4,
  os_p5,
  os_p6,
  os_p7,
  os_p8,
  os_p9,
  os_p10,
  os_p11,
  os_p12,
  os_p13,
  os_p14,
  os_p15,
  os_p16,

  os_snap,
  os_none,
  os_polar,
  os_nearest,
  os_perpendicular,
  os_midle,
  os_begin,
  os_1_3,
  os_2_3,
  os_1_4,
  os_3_4,
  os_end,
  os_center,
  os_q0,
  os_q1,
  os_q2,
  os_q3,
  os_point,
  os_textinsert,
  os_mtextinsert,
  os_mtextwidth,
  os_blockinsert,
  os_insert,
  os_intersection,
  os_apparentintersection,
  os_trace,
  os_polymin);}

  {const
  os_p1= -1001;
  os_p2= -1002;
  os_p3= -1003;
  os_p4= -1004;
  os_p5= -1005;
  os_p6= -1006;
  os_p7= -1007;
  os_p8= -1008;
  os_p9= -1009;
  os_p10= -1010;
  os_p11= -1011;
  os_p12= -1012;
  os_p13= -1013;
  os_p14= -1014;
  os_p15= -1015;
  os_p16= -1016;

  os_snap = -998;
  os_none = -999;
  os_perpendicular = -1000;
  os_midle = -1001;
  os_begin= -1002;
  os_1_3 = -1003;
  os_2_3 = -1004;
  os_1_4 = -1005;
  os_3_4 = -1006;
  os_end = -1007;
  os_center = -1008;
  os_q0 = -1012;
  os_q1 = -1011;
  os_q2 = -1010;
  os_q3 = -1009;
  os_point = -1013;
  os_textinsert = -1014;
  os_mtextinsert = -1015;
  os_mtextwidth = -1016;
  os_blockinsert = -1017;
  os_polar = -1018;
  os_nearest = -1019;
  os_insert = -1020;
  os_intersection = -1021;
  os_apparentintersection = -1022;
  os_trace = -1023;
  os_polymin =  -3000;}

const
  osm_inspoint=1;
  osm_endpoint=2;
  osm_midpoint=4;
  osm_3=8;
  osm_4=16;
  osm_center=32;
  osm_quadrant=64;
  osm_point=128;
  osm_intersection=256;
  osm_perpendicular=512;
  osm_tangent=1024;
  osm_nearest=2048;
  osm_apparentintersection=4096;
  osm_paralel=8192;

var
    os_p1,
    os_p2,
    os_p3,
    os_p4,
    os_p5,
    os_p6,
    os_p7,
    os_p8,
    os_p9,
    os_p10,
    os_p11,
    os_p12,
    os_p13,
    os_p14,
    os_p15,
    os_p16,

    os_snap,
    os_none,
    os_polar,
    os_nearest,
    os_perpendicular,
    os_midle,
    os_begin,
    os_1_3,
    os_2_3,
    os_1_4,
    os_3_4,
    os_end,
    os_center,
    os_q0,
    os_q1,
    os_q2,
    os_q3,
    os_point,
    os_textinsert,
    os_mtextinsert,
    os_mtextwidth,
    os_blockinsert,
    os_insert,
    os_intersection,
    os_apparentintersection,
    os_trace,
    os_polymin:TSnapType;

var
  SnapHandles:TTSnapType;

implementation

initialization
SnapHandles.init;
os_p1:=SnapHandles.CreateHandle;
os_p2:=SnapHandles.CreateHandle;
os_p3:=SnapHandles.CreateHandle;
os_p4:=SnapHandles.CreateHandle;
os_p5:=SnapHandles.CreateHandle;
os_p6:=SnapHandles.CreateHandle;
os_p7:=SnapHandles.CreateHandle;
os_p8:=SnapHandles.CreateHandle;
os_p9:=SnapHandles.CreateHandle;
os_p10:=SnapHandles.CreateHandle;
os_p11:=SnapHandles.CreateHandle;
os_p12:=SnapHandles.CreateHandle;
os_p13:=SnapHandles.CreateHandle;
os_p14:=SnapHandles.CreateHandle;
os_p15:=SnapHandles.CreateHandle;
os_p16:=SnapHandles.CreateHandle;

os_snap:=SnapHandles.CreateHandle;
os_none:=SnapHandles.CreateHandle;
os_polar:=SnapHandles.CreateHandle;
os_nearest:=SnapHandles.CreateHandle;
os_perpendicular:=SnapHandles.CreateHandle;
os_midle:=SnapHandles.CreateHandle;
os_begin:=SnapHandles.CreateHandle;
os_1_3:=SnapHandles.CreateHandle;
os_2_3:=SnapHandles.CreateHandle;
os_1_4:=SnapHandles.CreateHandle;
os_3_4:=SnapHandles.CreateHandle;
os_end:=SnapHandles.CreateHandle;
os_center:=SnapHandles.CreateHandle;
os_q0:=SnapHandles.CreateHandle;
os_q1:=SnapHandles.CreateHandle;
os_q2:=SnapHandles.CreateHandle;
os_q3:=SnapHandles.CreateHandle;
os_point:=SnapHandles.CreateHandle;
os_textinsert:=SnapHandles.CreateHandle;
os_mtextinsert:=SnapHandles.CreateHandle;
os_mtextwidth:=SnapHandles.CreateHandle;
os_blockinsert:=SnapHandles.CreateHandle;
os_insert:=SnapHandles.CreateHandle;
os_intersection:=SnapHandles.CreateHandle;
os_apparentintersection:=SnapHandles.CreateHandle;
os_trace:=SnapHandles.CreateHandle;
os_polymin:=SnapHandles.CreateHandle;

finalization
SnapHandles.done;

end.
