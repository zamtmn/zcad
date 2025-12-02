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

unit uzeSnap;
{$Mode delphi}{$H+}
{$ModeSwitch advancedrecords}
{$INCLUDE zengineconfig.inc}

interface

uses
  uzbnamedhandles,uzbnamedhandleswithdata,uzgldrawcontext,uzegeometrytypes,uzepalette,
  Classes;
const
  SOVeryLow=5;
  SOLow=10;
  SONormal=100;
  SOHigh=200;
  SOVeryHigh=250;

type
  TDefaultSnatIconDrawer=class
    class procedure EndIcon(var DC:TDrawContext);
    class procedure MidleIcon(var DC:TDrawContext);

    class procedure _1_4_3_4Icon(var DC:TDrawContext);
    class procedure CenterIcon(var DC:TDrawContext);
    class procedure q0123Icon(var DC:TDrawContext);
    class procedure _1_3_2_3Icon(var DC:TDrawContext);
    class procedure PointIcon(var DC:TDrawContext);
    class procedure IntersectionIcon(var DC:TDrawContext);
    class procedure ApparentIntersectionIcon(var DC:TDrawContext);
    class procedure TextInsertIcon(var DC:TDrawContext);
    class procedure PerpendicularIcon(var DC:TDrawContext);
    class procedure TraceIcon(var DC:TDrawContext);
    class procedure NearestIcon(var DC:TDrawContext);
  end;
  TSetupSnapIconProc=procedure (var DC:TDrawContext;ViewPortRect:TRect;Coord:TzePoint2d;SSize:single;SLW:Integer;SColor:TRGB) of object;
  TDrawSnapIcinProc=procedure (var DC:TDrawContext) of object;
  TSnapInternalType=Integer;
  TSnapNameType=String;
  PTSnapLincedData=^TSnapLincedData;
  TSnapLincedData=record
    Order:Byte;
    SetupIconProc:TSetupSnapIconProc;
    DrawIconProc:TDrawSnapIcinProc;
    constructor Create(AOrder:Byte;SP:TSetupSnapIconProc;DP:TDrawSnapIcinProc);
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
  osm_parallel=8192;

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

constructor TSnapLincedData.Create(AOrder:Byte;SP:TSetupSnapIconProc;DP:TDrawSnapIcinProc);
begin
  Order:=AOrder;
  DrawIconProc:=DP;
  SetupIconProc:=SP;
end;

class procedure TDefaultSnatIconDrawer.EndIcon(var DC:TDrawContext);
begin
  dc.drawer.DrawClosedPolyLine2DInDCS([-1,  1,
                                        1,  1,
                                        1, -1,
                                       -1, -1]);
end;
class procedure TDefaultSnatIconDrawer.MidleIcon(var DC:TDrawContext);
begin
  dc.drawer.DrawClosedPolyLine2DInDCS([ 0,              -1,
                                        0.8660254037844, 0.5,
                                       -0.8660254037844, 0.5]);
end;

class procedure TDefaultSnatIconDrawer._1_4_3_4Icon(var DC:TDrawContext);
begin
  dc.drawer.DrawLine2DInDCS(-0.5,  1,-0.5, -1);
  dc.drawer.DrawLine2DInDCS(-0.2, -1, 0.15, 1);
  dc.drawer.DrawLine2DInDCS( 0.5, -1, 0.15, 1);
end;

class procedure TDefaultSnatIconDrawer.CenterIcon(var DC:TDrawContext);
begin
  dc.drawer.DrawClosedPolyLine2DInDCS([-1,     0,
                                       -0.707, 0.707,
                                        0,     1,
                                        0.707, 0.707,
                                        1,     0,
                                        0.707,-0.707,
                                        0,    -1,
                                       -0.707,-0.707
                                        ]);
end;

class procedure TDefaultSnatIconDrawer.q0123Icon(var DC:TDrawContext);
begin
  dc.drawer.DrawClosedPolyLine2DInDCS([-1,  0,
                                        0,  1,
                                        1,  0,
                                        0, -1,
                                       -1,  0]);
end;

class procedure TDefaultSnatIconDrawer._1_3_2_3Icon(var DC:TDrawContext);
begin
  dc.drawer.DrawLine2DInDCS(-0.5, 1,-0.5, -1);
  dc.drawer.DrawLine2DInDCS(0, 1,0, -1);
  dc.drawer.DrawLine2DInDCS(0.5, 1,0.5, -1);
end;

class procedure TDefaultSnatIconDrawer.PointIcon(var DC:TDrawContext);
begin
  dc.drawer.DrawLine2DInDCS(-1, 1,1, -1);
  dc.drawer.DrawLine2DInDCS(-1, -1,1, 1);
end;

class procedure TDefaultSnatIconDrawer.IntersectionIcon(var DC:TDrawContext);
begin
  dc.drawer.DrawLine2DInDCS(-1, 1,1, -1);
  dc.drawer.DrawLine2DInDCS(-1, -1,1, 1);
end;

class procedure TDefaultSnatIconDrawer.ApparentIntersectionIcon(var DC:TDrawContext);
begin
  dc.drawer.DrawLine2DInDCS(-1, 1,1, -1);
  dc.drawer.DrawLine2DInDCS(-1, -1,1, 1);
  dc.drawer.DrawClosedPolyLine2DInDCS([-1,  1,
                                        1,  1,
                                        1, -1,
                                       -1, -1]);
end;

class procedure TDefaultSnatIconDrawer.TextInsertIcon(var DC:TDrawContext);
begin
  dc.drawer.DrawLine2DInDCS(-1, 0, 1, 0);
  dc.drawer.DrawLine2DInDCS( 0, 1, 0,-1);
end;

class procedure TDefaultSnatIconDrawer.PerpendicularIcon(var DC:TDrawContext);
begin
  dc.drawer.DrawLine2DInDCS(-1,-1,-1, 1);
  dc.drawer.DrawLine2DInDCS(-1, 1, 1, 1);
  dc.drawer.DrawLine2DInDCS(-1, 0, 0, 0);
  dc.drawer.DrawLine2DInDCS( 0, 0, 0, 1);
end;

class procedure TDefaultSnatIconDrawer.TraceIcon(var DC:TDrawContext);
begin
  dc.drawer.DrawLine2DInDCS(-1, -0.5,1, -0.5);
  dc.drawer.DrawLine2DInDCS(-1,  0.5,1,  0.5);
end;

class procedure TDefaultSnatIconDrawer.NearestIcon(var DC:TDrawContext);
begin
  dc.drawer.DrawClosedPolyLine2DInDCS([-1, 1,
                                        1, 1,
                                       -1,-1,
                                        1,-1]);
end;



initialization
  SnapHandles.init;
  os_p1:=SnapHandles.CreateHandleWithData('p1',TSnapLincedData.Create(SONormal,nil,nil));
  os_p2:=SnapHandles.CreateHandleWithData('p2',TSnapLincedData.Create(SONormal,nil,nil));
  os_p3:=SnapHandles.CreateHandleWithData('p3',TSnapLincedData.Create(SONormal,nil,nil));
  os_p4:=SnapHandles.CreateHandleWithData('p4',TSnapLincedData.Create(SONormal,nil,nil));
  os_p5:=SnapHandles.CreateHandleWithData('p5',TSnapLincedData.Create(SONormal,nil,nil));
  os_p6:=SnapHandles.CreateHandleWithData('p6',TSnapLincedData.Create(SONormal,nil,nil));
  os_p7:=SnapHandles.CreateHandleWithData('p7',TSnapLincedData.Create(SONormal,nil,nil));
  os_p8:=SnapHandles.CreateHandleWithData('p8',TSnapLincedData.Create(SONormal,nil,nil));
  os_p9:=SnapHandles.CreateHandleWithData('p9',TSnapLincedData.Create(SONormal,nil,nil));
  os_p10:=SnapHandles.CreateHandleWithData('p10',TSnapLincedData.Create(SONormal,nil,nil));
  os_p11:=SnapHandles.CreateHandleWithData('p11',TSnapLincedData.Create(SONormal,nil,nil));
  os_p12:=SnapHandles.CreateHandleWithData('p12',TSnapLincedData.Create(SONormal,nil,nil));
  os_p13:=SnapHandles.CreateHandleWithData('p13',TSnapLincedData.Create(SONormal,nil,nil));
  os_p14:=SnapHandles.CreateHandleWithData('p14',TSnapLincedData.Create(SONormal,nil,nil));
  os_p15:=SnapHandles.CreateHandleWithData('p15',TSnapLincedData.Create(SONormal,nil,nil));
  os_p16:=SnapHandles.CreateHandleWithData('p16',TSnapLincedData.Create(SONormal,nil,nil));

  os_snap:=SnapHandles.CreateHandleWithData('Snap',TSnapLincedData.Create(SOLow,nil,nil));
  os_none:=SnapHandles.CreateHandleWithData('None',TSnapLincedData.Create(SOVeryLow,nil,nil));
  os_polar:=SnapHandles.CreateHandleWithData('Polar',TSnapLincedData.Create(SONormal,nil,nil));
  os_nearest:=SnapHandles.CreateHandleWithData('Nearest',TSnapLincedData.Create(SONormal,nil,TDefaultSnatIconDrawer.NearestIcon));
  os_perpendicular:=SnapHandles.CreateHandleWithData('Perpendicular',TSnapLincedData.Create(SONormal,nil,TDefaultSnatIconDrawer.PerpendicularIcon));
  os_midle:=SnapHandles.CreateHandleWithData('midle',TSnapLincedData.Create(SONormal,nil,TDefaultSnatIconDrawer.MidleIcon));
  os_begin:=SnapHandles.CreateHandleWithData('begin',TSnapLincedData.Create(SONormal,nil,TDefaultSnatIconDrawer.EndIcon));
  os_1_3:=SnapHandles.CreateHandleWithData('1/3',TSnapLincedData.Create(SONormal,nil,TDefaultSnatIconDrawer._1_3_2_3Icon));
  os_2_3:=SnapHandles.CreateHandleWithData('2/3',TSnapLincedData.Create(SONormal,nil,TDefaultSnatIconDrawer._1_3_2_3Icon));
  os_1_4:=SnapHandles.CreateHandleWithData('1/4',TSnapLincedData.Create(SONormal,nil,TDefaultSnatIconDrawer._1_4_3_4Icon));
  os_3_4:=SnapHandles.CreateHandleWithData('3/4',TSnapLincedData.Create(SONormal,nil,TDefaultSnatIconDrawer._1_4_3_4Icon));
  os_end:=SnapHandles.CreateHandleWithData('End',TSnapLincedData.Create(SONormal,nil,TDefaultSnatIconDrawer.EndIcon));
  os_center:=SnapHandles.CreateHandleWithData('Center',TSnapLincedData.Create(SONormal,nil,TDefaultSnatIconDrawer.CenterIcon));
  os_q0:=SnapHandles.CreateHandleWithData('q0',TSnapLincedData.Create(SONormal,nil,TDefaultSnatIconDrawer.q0123Icon));
  os_q1:=SnapHandles.CreateHandleWithData('q1',TSnapLincedData.Create(SONormal,nil,TDefaultSnatIconDrawer.q0123Icon));
  os_q2:=SnapHandles.CreateHandleWithData('q2',TSnapLincedData.Create(SONormal,nil,TDefaultSnatIconDrawer.q0123Icon));
  os_q3:=SnapHandles.CreateHandleWithData('q3',TSnapLincedData.Create(SONormal,nil,TDefaultSnatIconDrawer.q0123Icon));
  os_point:=SnapHandles.CreateHandleWithData('Point',TSnapLincedData.Create(SONormal,nil,TDefaultSnatIconDrawer.PointIcon));
  os_textinsert:=SnapHandles.CreateHandleWithData('TextInsert',TSnapLincedData.Create(SOLow,nil,TDefaultSnatIconDrawer.TextInsertIcon));
  os_mtextinsert:=SnapHandles.CreateHandleWithData('MtextInsert',TSnapLincedData.Create(SONormal,nil,TDefaultSnatIconDrawer.TextInsertIcon));
  os_mtextwidth:=SnapHandles.CreateHandleWithData('MtextWidth',TSnapLincedData.Create(SONormal,nil,TDefaultSnatIconDrawer.TextInsertIcon));
  os_blockinsert:=SnapHandles.CreateHandleWithData('BlockInsert',TSnapLincedData.Create(SONormal,nil,TDefaultSnatIconDrawer.TextInsertIcon));
  os_insert:=SnapHandles.CreateHandleWithData('Insert',TSnapLincedData.Create(SONormal,nil,TDefaultSnatIconDrawer.TextInsertIcon));
  os_intersection:=SnapHandles.CreateHandleWithData('Intersection',TSnapLincedData.Create(SONormal,nil,TDefaultSnatIconDrawer.IntersectionIcon));
  os_apparentintersection:=SnapHandles.CreateHandleWithData('ApparentIntersection',TSnapLincedData.Create(SONormal,nil,TDefaultSnatIconDrawer.ApparentIntersectionIcon));
  os_trace:=SnapHandles.CreateHandleWithData('Trace',TSnapLincedData.Create(SONormal,nil,TDefaultSnatIconDrawer.TraceIcon));
  os_polymin:=SnapHandles.CreateHandleWithData('Polymin',TSnapLincedData.Create(SONormal,nil,{TDefaultSnatIconDrawer.EndIcon}nil));
finalization
  SnapHandles.done;
end.
