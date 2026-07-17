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
unit uzeenrepresentation;
{$MODE OBJFPC}{$H+}
{$INCLUDE zengineconfig.inc}
interface

uses
  uzgldrawcontext,uzgldrawerabstract,uzglvectorobject,SysUtils,uzegeometrytypes,
  uzegeometry,uzglgeometry,uzefont,uzeentitiesprop,
  uzeentsubordinated,uzegeomentitiestree,uzeTypes,
  uzgeomline3d,uzgeomproxy,uzctnrVectorTzePoint2d,math;

type
  PTZEntityRepresentation=^TZEntityRepresentation;

  TZEntityRepresentation=object(GDBaseObject)
  private
    procedure _CreatePolyLine             (var DC:TDrawContext;var Ent:GDBObjDrawable;const vp:GDBObjVisualProp;const pts:array of TzePoint3d;const closed,ltgen:boolean);virtual;
    procedure _CreateTransformedPolyLine  (var DC:TDrawContext;var Ent:GDBObjDrawable;const vp:GDBObjVisualProp;const Mtx:TzeTypedMatrix4d;const pts:array of TzePoint3d;const closed,ltgen:boolean);virtual;
    procedure _CreateTransformedPolyLine2D(var DC:TDrawContext;var Ent:GDBObjDrawable;const vp:GDBObjVisualProp;const Mtx:TzeTypedMatrix4d;const pts:array of TzePoint2d;const closed,ltgen:boolean;OverrideStartPt:boolean=false;StartPt:PzePoint2d=nil);virtual;
    procedure _CreatePolyLine2D           (var DC:TDrawContext;var Ent:GDBObjDrawable;const vp:GDBObjVisualProp;const pts:array of TzePoint2d;const closed,ltgen:boolean);virtual;

    procedure CreatePolyLine2D            (var DC:TDrawContext;var Ent:GDBObjDrawable;const vp:GDBObjVisualProp;const Mtx:TzeTypedMatrix4d;const pts:array of TzePoint2d;const closed,ltgen:boolean);
    procedure CreateBulgedPolyLine2D      (var DC:TDrawContext;var Ent:GDBObjDrawable;const vp:GDBObjVisualProp;const Mtx:TzeTypedMatrix4d;const pts:array of TzePoint2d;const Segments:array of TSegmentParams;const closed,ltgen:boolean;BulgedSegmentsCount:integer=-1);

    procedure CreateBulgedLWPolyLineWdh   (var DC:TDrawContext;var Ent:GDBObjDrawable;const vp:GDBObjVisualProp;const Mtx:TzeTypedMatrix4d;const pts:array of TzePoint2d;const Segments:array of TSegmentParams;const closed,ltgen:boolean);
    procedure CreateBulgedLWPolyLineVariableWdh
                                          (var DC:TDrawContext;var Ent:GDBObjDrawable;const vp:GDBObjVisualProp;const Mtx:TzeTypedMatrix4d;const pts:array of TzePoint2d;const Segments:array of TSegmentParams;const closed,ltgen:boolean);
    procedure CreateLWPolyLineWdh         (var DC:TDrawContext;var Ent:GDBObjDrawable;const vp:GDBObjVisualProp;const Mtx:TzeTypedMatrix4d;const pts:array of TzePoint2d;const Segments:array of TSegmentParams;const closed,ltgen:boolean);

  public
    Graphix:ZGLGraphix;
    Geometry:TGeomEntTreeNode;
  public
    constructor init();
    destructor done;virtual;

    function CalcTrueInFrustum(const frustum:TzeFrustum;FullCheck:boolean):TInBoundingVolume;
    procedure DrawGeometry(var rc:TDrawContext;const aabb:TBoundingBox;
      const inFrustumState:TInBoundingVolume);virtual;
    procedure Clear;virtual;
    procedure Shrink;virtual;

    function GetGraphix:PZGLGraphix;

    {Команды которыми создает свое представление}
    procedure CreateTextContent(drawer:TZGLAbstractDrawer;content:TDXFEntsInternalStringType;
      _pfont:PGDBfont;const DrawMatrix,objmatrix:TzeTypedMatrix4d;const textprop_size:double;
      var Outbound:OutBound4V);

    procedure CreateLine         (var DC:TDrawContext;var Ent:GDBObjDrawable;const vp:GDBObjVisualProp;const Mtx:TzeTypedMatrix4d;const StartPointOCS,EndPointOCS:TzePoint3d;OnlyOne:boolean=False);
    procedure CreateLineByConstRefLineProp
                                 (var DC:TDrawContext;var Ent:GDBObjDrawable;const vp:GDBObjVisualProp;const Mtx:TzeTypedMatrix4d;constref LP:GDBLineProp;OnlyOne:boolean=False);
    procedure CreateWCSLineWithoutLT
                                 (var DC:TDrawContext;var Ent:GDBObjDrawable;const startpoint,endpoint:TzePoint3d);overload;
    procedure CreateLineWithoutLT(var DC:TDrawContext;var Ent:GDBObjDrawable;const Mtx:TzeTypedMatrix4d;const startpoint,endpoint:TzePoint3d);overload;
    procedure CreatePoint        (var DC:TDrawContext;var Ent:GDBObjDrawable;const vp:GDBObjVisualProp;const Mtx:TzeTypedMatrix4d;const point:TzePoint3d);
    procedure CreatePolyLine     (var DC:TDrawContext;var Ent:GDBObjDrawable;const vp:GDBObjVisualProp;const Mtx:TzeTypedMatrix4d;const pts:array of TzePoint3d;const closed,ltgen:boolean);

    procedure CreateLWPolyLine   (var DC:TDrawContext;var Ent:GDBObjDrawable;const vp:GDBObjVisualProp;const Mtx:TzeTypedMatrix4d;const pts:array of TzePoint2d;const Segments:array of TSegmentParams;const closed:boolean;ltgen:boolean);

    procedure StartSurface;
    procedure EndSurface;
  end;

implementation

type
  TQuadData=record
    Quad:GDBQuad2d;
    hasStartWidth,hasEndWidth:boolean;
    joinedWithNext,joinedWithPrew:boolean;
  end;
  TQtype=(QTWrong,QTStrip,QTLine);

function TZEntityRepresentation.GetGraphix:PZGLGraphix;
begin
  Result:=@Graphix;
end;

constructor TZEntityRepresentation.init;
begin
  inherited;
  Graphix.init();
  Geometry.initnul;
end;

destructor TZEntityRepresentation.done;
begin
  Graphix.done;
  Geometry.done;
  inherited;
end;

function SqrCanSimplyDrawInWCS(const DC:TDrawContext;
  const ParamSize,TargetSize:double):boolean;
var
  templod:double;
begin
  if dc.maxdetail then
    exit(True);
  templod:=(ParamSize)/(dc.DrawingContext.zoom*dc.DrawingContext.zoom);
  if templod>TargetSize then
    exit(True)
  else
    exit(False);
end;

procedure TZEntityRepresentation.DrawGeometry(var rc:TDrawContext;
  const aabb:TBoundingBox;const inFrustumState:TInBoundingVolume);
var
  v:TzeVector3d;
  simplydraw:boolean;
begin
  if rc.lod=LODCalculatedDetail then begin
    v:={uzegeometry.VertexSub}(aabb.RTF-aabb.LBN).asVector3d;
    simplydraw:=not SqrCanSimplyDrawInWCS(rc,uzegeometry.SqrOneVertexlength(v),49);
  end else
    simplydraw:=rc.lod=LODLowDetail;
  Graphix.DrawGeometry(rc,inFrustumState,simplydraw);
end;

function TZEntityRepresentation.CalcTrueInFrustum(const frustum:TzeFrustum;
  FullCheck:boolean):TInBoundingVolume;
begin
  Result:=Graphix.CalcTrueInFrustum(frustum,FullCheck);
end;

procedure TZEntityRepresentation.Clear;
begin
  Graphix.Clear;
  Geometry.ClearSub;
end;

procedure TZEntityRepresentation.Shrink;
begin
  Graphix.Shrink;
  Geometry.Shrink;
end;

procedure TZEntityRepresentation.CreateTextContent(drawer:TZGLAbstractDrawer;
  content:TDXFEntsInternalStringType;_pfont:PGDBfont;
  const DrawMatrix,objmatrix:TzeTypedMatrix4d;const textprop_size:double;var Outbound:OutBound4V);
begin
  Graphix.DrawTextContent(drawer,content,_pfont,DrawMatrix,objmatrix,
    textprop_size,Outbound);
end;

procedure TZEntityRepresentation.CreateLine(var DC:TDrawContext;var Ent:GDBObjDrawable;
  const vp:GDBObjVisualProp;const Mtx:TzeTypedMatrix4d;const StartPointOCS,EndPointOCS:TzePoint3d;
  OnlyOne:boolean=False);
var
  gl:TGeomLine3D;
  gp:TGeomProxy;
  dr:TLLDrawResult;
  StartPointWCS,EndPointWCS:TzePoint3d;
begin
  StartPointWCS:=VectorTransform3D(StartPointOCS,Mtx);
  EndPointWCS:=VectorTransform3D(EndPointOCS,Mtx);
  dr:=Graphix.DrawLineWithLT(DC,StartPointWCS,EndPointWCS,vp);
  Geometry.Lock;
  if dr.Appearance<>TAMatching then begin
    gp.init(dr.LLPStart,dr.LLPEndi-1,dr.BB);
    Geometry.AddObjectToNodeTree(gp);
  end;
  gl.init(StartPointWCS,EndPointWCS,0);
  Geometry.AddObjectToNodeTree(gl);
  Geometry.UnLock;
end;

procedure TZEntityRepresentation.CreateLineByConstRefLineProp(var DC:TDrawContext;
  var Ent:GDBObjDrawable;const vp:GDBObjVisualProp;const Mtx:TzeTypedMatrix4d;
  constref LP:GDBLineProp;OnlyOne:boolean=False);
var
  gpl:TGeomPLine3D;
  gp:TGeomProxy;
  dr:TLLDrawResult;
begin
  if Mtx.IsIdentity then begin
    dr:=Graphix.DrawLineWithLT(DC,LP.lBegin,LP.lEnd,vp,OnlyOne);
    Geometry.Lock;
    if dr.Appearance<>TAMatching then begin
      gp.init(dr.LLPStart,dr.LLPEndi-1,dr.BB);
      Geometry.AddObjectToNodeTree(gp);
    end;
    gpl.init(LP,0);
    Geometry.AddObjectToNodeTree(gpl);
    Geometry.UnLock;
  end else
    CreateLine(DC,Ent,vp,Mtx,LP.lBegin,LP.lEnd,OnlyOne);
end;

procedure TZEntityRepresentation.CreateWCSLineWithoutLT(var DC:TDrawContext;var Ent:GDBObjDrawable;
  const startpoint,endpoint:TzePoint3d);
var
  gl:TGeomLine3D;
  gp:TGeomProxy;
  dr:TLLDrawResult;
begin
  Graphix.DrawLineWithoutLT(DC,startpoint,endpoint,dr);
  Geometry.Lock;
  if dr.Appearance<>TAMatching then begin
    gp.init(dr.LLPStart,dr.LLPEndi-1,dr.BB);
    Geometry.AddObjectToNodeTree(gp);
  end;
  gl.init(startpoint,endpoint,0);
  Geometry.AddObjectToNodeTree(gl);
  Geometry.UnLock;
end;
procedure TZEntityRepresentation.CreateLineWithoutLT(var DC:TDrawContext;var Ent:GDBObjDrawable;
  const Mtx:TzeTypedMatrix4d;const startpoint,endpoint:TzePoint3d);
begin
  if Mtx.IsIdentity then
    CreateWCSLineWithoutLT(DC,Ent,startpoint,endpoint)
  else
    CreateWCSLineWithoutLT(DC,Ent,VectorTransform3D(startpoint,Mtx),VectorTransform3D(endpoint,Mtx));
end;

procedure TZEntityRepresentation.CreatePoint(var DC:TDrawContext;var Ent:GDBObjDrawable;
  const vp:GDBObjVisualProp;const Mtx:TzeTypedMatrix4d;const point:TzePoint3d);
var
  //gl:TGeomLine3D;
  gp:TGeomProxy;
  dr:TLLDrawResult;
begin
  Graphix.DrawPointWithoutLT(DC,VectorTransform3D(point,Mtx),dr);
  Geometry.Lock;
  if dr.Appearance<>TAMatching then begin
    gp.init(dr.LLPStart,dr.LLPEndi-1,dr.BB);
    Geometry.AddObjectToNodeTree(gp);
  end;
  //gl.init(startpoint,endpoint,0);
  //Geometry.AddObjectToNodeTree(gl);
  Geometry.UnLock;
end;

procedure TZEntityRepresentation._CreatePolyLine(var DC:TDrawContext;var Ent:GDBObjDrawable;
  const vp:GDBObjVisualProp;const pts:array of TzePoint3d;const closed,ltgen:boolean);
var
  ptv,ptvprev,ptvfisrt:PzePoint3d;
  i:integer;
  gl:TGeomLine3D;
  segcounter:integer;
begin
  Graphix.DrawPolyLineWithLT(DC,pts,vp,closed,ltgen);
  Geometry.Lock;
  Geometry.SetSize(length(pts)*sizeof(TGeomLine3D));
  ptv:=@pts[0];
  ptvfisrt:=ptv;
  segcounter:=0;
  for i:=low(pts) to High(pts) do begin
    ptvprev:=ptv;
    if i<High(pts)then begin
      ptv:=@pts[i+1];
      gl.init(ptv^,ptvprev^,segcounter);
      Geometry.AddObjectToNodeTree(gl);
      Inc(segcounter);
    end;
  end;
  if closed then begin
    gl.init(ptvprev^,ptvfisrt^,segcounter);
    Geometry.AddObjectToNodeTree(gl);
  end;
  Geometry.UnLock;
end;

procedure TZEntityRepresentation._CreateTransformedPolyLine(var DC:TDrawContext;
  var Ent:GDBObjDrawable;const vp:GDBObjVisualProp;const Mtx:TzeTypedMatrix4d;
  const pts:array of TzePoint3d;const closed,ltgen:boolean);
var
  i:integer;
  tpts:array of TzePoint3d;
begin
  SetLength(tpts,Length(pts));
  for i:={low(pts)}0 to High(pts) do
    tpts[i]:=VectorTransform3D(pts[i],Mtx);
  _CreatePolyLine(DC,Ent,vp,tpts,closed,ltgen);
end;

procedure TZEntityRepresentation.CreatePolyLine(var DC:TDrawContext;var Ent:GDBObjDrawable;
  const vp:GDBObjVisualProp;const Mtx:TzeTypedMatrix4d;const pts:array of TzePoint3d;
  const closed,ltgen:boolean);
begin
  if mtx.IsIdentity then
    _CreatePolyLine(DC,Ent,vp,pts,closed,ltgen)
  else
    _CreateTransformedPolyLine(DC,Ent,vp,Mtx,pts,closed,ltgen);
end;

procedure TZEntityRepresentation._CreateTransformedPolyLine2D(var DC:TDrawContext;
  var Ent:GDBObjDrawable;const vp:GDBObjVisualProp;const Mtx:TzeTypedMatrix4d;
  const pts:array of TzePoint2d;const closed,ltgen:boolean;OverrideStartPt:boolean=false;
  StartPt:PzePoint2d=nil);
var
  i:integer;
  tpts:array of TzePoint3d;
begin
  if OverrideStartPt then
    SetLength(tpts,Length(pts)+1)
  else
    SetLength(tpts,Length(pts));
  for i:={low(pts)}0 to High(pts) do
    tpts[i]:=VectorTransform2D(pts[i],Mtx);
  if OverrideStartPt then
    tpts[High(tpts)]:=VectorTransform2D(StartPt^,Mtx);
  _CreatePolyLine(DC,Ent,vp,tpts,closed,ltgen);
end;

procedure TZEntityRepresentation._CreatePolyLine2D(var DC:TDrawContext;var Ent:GDBObjDrawable;
  const vp:GDBObjVisualProp;const pts:array of TzePoint2d;const closed,ltgen:boolean);
var
  i:integer;
  tpts:array of TzePoint3d;
begin
  SetLength(tpts,Length(pts));
  for i:={low(pts)}0 to High(pts) do
    tpts[i]:=CreateVertex(pts[i].x,pts[i].y,0);
  _CreatePolyLine(DC,Ent,vp,tpts,closed,ltgen);
end;

procedure TZEntityRepresentation.CreatePolyLine2d(var DC:TDrawContext;var Ent:GDBObjDrawable;
  const vp:GDBObjVisualProp;const Mtx:TzeTypedMatrix4d;const pts:array of TzePoint2d;
  const closed,ltgen:boolean);
begin
  if mtx.IsIdentity then
    _CreatePolyLine2D(DC,Ent,vp,pts,closed,ltgen)
  else
    _CreateTransformedPolyLine2D(DC,Ent,vp,Mtx,pts,closed,ltgen);
end;

procedure DrawLWPLLinearQSegmentsInternal(var DC:TDrawContext;var Graphix:ZGLGraphix;
  const quads:array of TQuadData;const Mtx:TzeTypedMatrix4d;var pts3d:array of TzePoint3d);inline;
var
  i,j:integer;
begin
  pts3d[0]:=VectorTransform2D(quads[0].Quad[3],mtx);
  pts3d[1]:=VectorTransform2D(quads[0].Quad[0],mtx);
  pts3d[2]:=VectorTransform2D(quads[0].Quad[2],mtx);
  pts3d[3]:=VectorTransform2D(quads[0].Quad[1],mtx);
  j:=4;
  for i:=low(quads)+1 to High(quads) do begin
    pts3d[j]:=VectorTransform2D(quads[i].Quad[2],mtx);
    inc(j);
    pts3d[j]:=VectorTransform2D(quads[i].Quad[1],mtx);
    inc(j);
  end;
  Graphix.AddTriangleStrip(DC,pts3d[0..j-1]);
end;

procedure DrawLWPLLinearLSegmentsInternal(var DC:TDrawContext;var Graphix:ZGLGraphix;
  const quads:array of TQuadData;const Mtx:TzeTypedMatrix4d;var pts3d:array of TzePoint3d);inline;
var
  i,j:integer;
begin
  pts3d[0]:=VectorTransform2D(quads[0].Quad[0],mtx);
  pts3d[1]:=VectorTransform2D(quads[0].Quad[1],mtx);
  j:=2;
  for i:=low(quads)+1 to High(quads) do begin
    pts3d[j]:=VectorTransform2D(quads[i].Quad[1],mtx);
    inc(j);
  end;
  Graphix.AddPolyLine(DC,false,pts3d[0..j-1]);
end;

procedure TZEntityRepresentation.CreateBulgedLWPolyLineWdh(var DC:TDrawContext;var Ent:GDBObjDrawable;
  const vp:GDBObjVisualProp;const Mtx:TzeTypedMatrix4d;const pts:array of TzePoint2d;
  const Segments:array of TSegmentParams;const closed,ltgen:boolean);
begin
  //CreateLWPolyLineWdh(DC,Ent,vp,Mtx,pts,Segments,closed,ltgen);
end;

procedure TZEntityRepresentation.CreateBulgedLWPolyLineVariableWdh(var DC:TDrawContext;
  var Ent:GDBObjDrawable;const vp:GDBObjVisualProp;const Mtx:TzeTypedMatrix4d;
  const pts:array of TzePoint2d;const Segments:array of TSegmentParams;const closed,ltgen:boolean);
begin

end;


procedure TZEntityRepresentation.CreateLWPolyLineWdh(var DC:TDrawContext;var Ent:GDBObjDrawable;
  const vp:GDBObjVisualProp;const Mtx:TzeTypedMatrix4d;const pts:array of TzePoint2d;
  const Segments:array of TSegmentParams;const closed,ltgen:boolean);

  procedure CalcSegment(const p1,p2:TzePoint2d;const plw:TSegmentParams;var quad:TQuadData);
  var
    vtangent,vnormal,vtemp:TzePoint2d;
  begin
    vtangent:=p2-p1;
    vnormal.x:=-vtangent.y;
    vnormal.y:=vtangent.x;
    vnormal:=vnormal.Normalized;

    quad.hasStartWidth:=abs(plw.data.startw)>eps;
    quad.hasEndWidth:=abs(plw.data.endw)>eps;

    if quad.hasStartWidth then begin
      vtemp:=vnormal*plw.data.startw/2;
      quad.quad[0]:=p1+vtemp;
      quad.quad[3]:=p1-vtemp;
    end else begin
      quad.quad[0]:=p1;
      quad.quad[3]:=p1;
    end;

    if quad.hasEndWidth then begin
      vtemp:=vnormal*plw.data.endw/2;
      quad.quad[1]:=p2+vtemp;
      quad.quad[2]:=p2-vtemp;
    end else begin
      quad.quad[1]:=p2;
      quad.quad[2]:=p2;
    end;

    {for k:=0 to 3 do begin
      v.x:=plw.quad[k].x;
      v.y:=plw.quad[k].y;
      v.z:=0;
      v.w:=1;
      v:=VectorTransform(v,objMatrix);
      q3d[k]:=PzePoint3d(@v)^;
    end;

    Width3D_in_WCS_Array.PushBackData(q3d);}
  end;

  procedure JoinSegment(const p:TzePoint2d;const sp1,sp2:TSegmentParams;var q1,q2:TQuadData);
  var
    l:double;
    ip,ip2:Intercept2DProp;
  begin

    if q1.hasEndWidth and q2.hasStartWidth then begin
      if sp1.data.endw>sp2.data.startw then
        l:=sp1.data.endw
      else
        l:=sp2.data.startw;
      l:=4*l*l;//(2l)^2
      ip:=intercept2dmy(q1.Quad[0],q1.Quad[1],q2.Quad[1],q2.Quad[0]);
      ip2:=intercept2dmy(q1.Quad[3],q1.Quad[2],q2.Quad[2],q2.Quad[3]);

      if ip.isintercept and ip2.isintercept then
        if (ip.t1>0) and (ip.t2>0) then
          if (ip2.t1>0) and (ip2.t2>0) then begin
            if SqrVertexlength(p,ip.interceptcoord)<l then
              if SqrVertexlength(p,ip2.interceptcoord)<l then begin
                q1.Quad[1]:=ip.interceptcoord;
                q1.Quad[2]:=ip2.interceptcoord;
                q2.Quad[0]:=ip.interceptcoord;
                q2.Quad[3]:=ip2.interceptcoord;
                q1.joinedWithNext:=true;
                q2.joinedWithPrew:=true;
              end else begin
                q1.joinedWithNext:=false;
                q2.joinedWithPrew:=false;
              end;
          end;
    end;
  end;

  function Segment2QType(var q:TQuadData;var needbreak:boolean):TQtype;
  begin
    if q.hasStartWidth or q.hasEndWidth then begin
      result:=QTStrip;
      //needbreak:=(not q.hasEndWidth)or(not q.joinedWithNext);
      needbreak:=not (q.hasEndWidth and q.joinedWithNext);
    end else
      result:=QTLine;
  end;

  procedure DrawLWPLLinearSegments(AType:TQtype;const quads:array of TQuadData);
    const
      PointsOnStackCount=100;
    var
      pts3d:array[0..PointsOnStackCount-1]of TzePoint3d;
      dynpts3d:array of TzePoint3d;
      ptscount:integer;
    begin
      case AType of
        QTStrip:begin
          ptscount:=(length(quads)+1)*2;
          if ptscount<=PointsOnStackCount then
            DrawLWPLLinearQSegmentsInternal(DC,Graphix,quads,Mtx,pts3d)
          else begin
            SetLength(dynpts3d,ptscount);
            DrawLWPLLinearQSegmentsInternal(DC,Graphix,quads,Mtx,dynpts3d);
          end;
        end;
        QTLine:begin
          ptscount:=length(quads)+1;
          if ptscount<=PointsOnStackCount then
            DrawLWPLLinearLSegmentsInternal(DC,Graphix,quads,Mtx,pts3d)
          else begin
            SetLength(dynpts3d,ptscount);
            DrawLWPLLinearLSegmentsInternal(DC,Graphix,quads,Mtx,dynpts3d);
          end;
        end;
        QTWrong:
          Raise Exception.Create('Unknown LPPolyLineSeg (QTWrong)');
      end;
    end;

var
  Quads:array of TQuadData=nil;
  i,j:integer;

  needbreak:boolean;
  thisqtypestart:integer;
  testqtype:TQtype;
  qtype:TQtype=QTWrong;
begin
  //толстая полилиния без дуг
  //длина Segments уже с учетом closed
  SetLength(Quads,Length(Segments));

  //считаем ширины сегментов
  for i:=low(Segments) to high(Segments) do begin
    if i=high(pts) then
      j:=0
    else
      j:=i+1;
    CalcSegment(pts[i],pts[j],segments[i],quads[i]);
  end;

  //пытается объеденить сегменты
  for i:=low(Segments) to high(Segments)-1 do begin
    j:=i+1;
    JoinSegment(pts[j],segments[i],segments[j],quads[i],quads[j]);
  end;
  if closed then
    JoinSegment(pts[0],segments[high(Segments)],segments[0],quads[high(Segments)],quads[0]);

  needbreak:=true;
  thisqtypestart:=-1;
  for i:=low(Segments) to high(Segments)-1 do begin
    if needbreak then begin
      if thisqtypestart<>-1 then begin
        DrawLWPLLinearSegments(qtype,quads[thisqtypestart..i-1]);
      end;
      thisqtypestart:=i;
      qtype:=Segment2QType(quads[i],needbreak);
    end else begin
      testqtype:=Segment2QType(quads[i],needbreak);
      if qtype<>testqtype then begin
        DrawLWPLLinearSegments(qtype,quads[thisqtypestart..i]);
        thisqtypestart:=i;
        qtype:=testqtype;
      end;
    end;
  end;
  if thisqtypestart=-1 then begin
    thisqtypestart:=low(Segments);
    qtype:=Segment2QType(quads[thisqtypestart],needbreak);
  end;
  if needbreak then begin
    DrawLWPLLinearSegments(qtype,quads[thisqtypestart..high(Segments)-1]);
    qtype:=Segment2QType(quads[high(Segments)],needbreak);
    DrawLWPLLinearSegments(qtype,quads[high(Segments)..high(Segments)])
  end else
    DrawLWPLLinearSegments(qtype,quads[thisqtypestart..high(Segments)])
end;

procedure TZEntityRepresentation.CreateBulgedPolyLine2d(var DC:TDrawContext;var Ent:GDBObjDrawable;
  const vp:GDBObjVisualProp;const Mtx:TzeTypedMatrix4d;const pts:array of TzePoint2d;
  const Segments:array of TSegmentParams;const closed,ltgen:boolean;BulgedSegmentsCount:integer=-1);

const
  MaxArcDiv=5;

  function NextIdx(CurrIdx:integer):integer;inline;
  begin
    if CurrIdx=high(pts) then
      result:=0
    else
      result:=CurrIdx+1;
  end;

  function PrevIdx(CurrIdx:integer):integer;inline;
  begin
    if CurrIdx=0 then
      result:=high(pts)
    else
      result:=CurrIdx-1;
  end;

type
  TLastSegType=(LSTLine,LSTArc,LSTUnknown);
var
  i,j,StartLineSegmentIndex:integer;
  LastLineSegment:TLastSegType;
  currpath:TZctnrVectorTzePoint2d;
  pathpointsize,ActualArcDiv:integer;
begin
  StartLineSegmentIndex:=low(Segments);
  LastLineSegment:=LSTUnknown;
  if ltgen then begin
    if BulgedSegmentsCount>0 then
      currpath.init(BulgedSegmentsCount*(1 shl MaxArcDiv)+1+length(segments))
    else
      currpath.init((1 shl MaxArcDiv)+1+length(segments));
    if closed then begin
      //замкнутую полилинию автокад начинает рисовать с 1 сегмента (нумерация с 0)
      for i:=low(Segments)+1 to high(segments) do begin
        if abs(Segments[i].data.bulge)>eps then begin
          j:=NextIdx(i);
          pathpointsize:=PreCalcBulgeToArcSegment(pts[i],pts[j],Segments[i].data.bulge,MaxArcDiv,ActualArcDiv);
          currpath.AllocData(pathpointsize);
          CalcBulgeToArcSegment(pts[i],pts[j],Segments[i].data.bulge,currpath.getPFirst[currpath.count-pathpointsize..currpath.count-1],ActualArcDiv);
          currpath.getPLast^:=pts[j];
        end else begin
          currpath.PushBackData(pts[i]);
        end;
      end;
      if abs(Segments[0].data.bulge)>eps then begin
        pathpointsize:=PreCalcBulgeToArcSegment(pts[0],pts[1],Segments[0].data.bulge,MaxArcDiv,ActualArcDiv);
        currpath.AllocData(pathpointsize);
        CalcBulgeToArcSegment(pts[0],pts[1],Segments[0].data.bulge,currpath.getPFirst[currpath.count-pathpointsize..currpath.count-1],ActualArcDiv);
        currpath.getPLast^:=pts[1];
      end else begin
        currpath.PushBackData(pts[0]);
      end;
    end else
      //разомкнутую полилинию автокад рисовует как и ожидается с нулевого сегмента
      for i:=low(Segments)to high(segments) do begin
        if abs(Segments[i].data.bulge)>eps then begin
          j:=NextIdx(i);
          pathpointsize:=PreCalcBulgeToArcSegment(pts[i],pts[j],Segments[i].data.bulge,MaxArcDiv,ActualArcDiv);
          currpath.AllocData(pathpointsize);
          CalcBulgeToArcSegment(pts[i],pts[j],Segments[i].data.bulge,currpath.getPFirst[currpath.count-pathpointsize..currpath.count-1],ActualArcDiv);
          currpath.getPLast^:=pts[j];
        end else begin
          j:=NextIdx(i);
          currpath.PushBackData(pts[j]);
        end;
      end;

    _CreateTransformedPolyLine2D(DC,Ent,vp,Mtx,currpath.getPFirst[0..currpath.GetLastIndex],closed,true);

    currpath.destroy;
  end else begin
    currpath.init((1 shl MaxArcDiv)+1);
    for i:=low(Segments)to high(segments) do begin
      if abs(Segments[i].data.bulge)>eps then begin
        if LastLineSegment=LSTLine then begin
          _CreateTransformedPolyLine2D(DC,Ent,vp,Mtx,pts[StartLineSegmentIndex..i],false,false);
        end;
        LastLineSegment:=LSTArc;
        j:=NextIdx(i);
        pathpointsize:=PreCalcBulgeToArcSegment(pts[i],pts[j],Segments[i].data.bulge,MaxArcDiv,ActualArcDiv);
        currpath.AllocData(pathpointsize);
        CalcBulgeToArcSegment(pts[i],pts[j],Segments[i].data.bulge,currpath.getPFirst[currpath.count-pathpointsize..currpath.count-1],ActualArcDiv);
        currpath.getPLast^:=pts[j];
        _CreateTransformedPolyLine2D(DC,Ent,vp,Mtx,currpath.getPFirst[0..currpath.GetLastIndex],false,false);
        currpath.Clear;
      end else begin
        if LastLineSegment<>LSTLine then
          StartLineSegmentIndex:=i;
        LastLineSegment:=LSTLine;
      end;
    end;
    if LastLineSegment=LSTLine then begin
      if closed then begin
        if StartLineSegmentIndex=0 then
          _CreateTransformedPolyLine2D(DC,Ent,vp,Mtx,pts[StartLineSegmentIndex..high(pts)],true,false)
        else
          _CreateTransformedPolyLine2D(DC,Ent,vp,Mtx,pts[StartLineSegmentIndex..high(pts)],false,false,true,@pts[0])
      end else
        _CreateTransformedPolyLine2D(DC,Ent,vp,Mtx,pts[StartLineSegmentIndex..high(pts)],false,false);
    end;
    currpath.destroy;
  end;
end;

procedure TZEntityRepresentation.CreateLWPolyLine(var DC:TDrawContext;var Ent:GDBObjDrawable;
  const vp:GDBObjVisualProp;const Mtx:TzeTypedMatrix4d;
  const pts:array of TzePoint2d;const Segments:array of TSegmentParams;
  const closed:boolean;ltgen:boolean);
var
  i,c:integer;
  BulgedSegmentsCount,WidthSegmentsCount,VariableWidthSegmentsCount:integer;
begin
  //последний сегмент имеет смысл только для замкнутой полилинии
  if closed then
    c:=high(Segments)
  else
    c:=high(Segments)-1;
  BulgedSegmentsCount:=0;
  WidthSegmentsCount:=0;
  VariableWidthSegmentsCount:=0;
  //проверяем есть ли в полилинии дуговые и широкие сегменты
  for i:=low(Segments)to c do begin
    with Segments[i] do begin
      if abs(data.bulge)>eps then
        inc(BulgedSegmentsCount);
      if data.hw then begin
        inc(WidthSegmentsCount);
        if IsDoubleNotEqual(data.startw,data.endw) then
          inc(VariableWidthSegmentsCount);
      end;
    end;
  end;
  if WidthSegmentsCount=0 then begin
    //тонкая полилиния
    if BulgedSegmentsCount=0 then
      //тонкая полилиния без дуг
      CreatePolyLine2d(DC,Ent,vp,Mtx,pts,closed,ltgen)
    else
      //тонкая полилиния с дугами
      CreateBulgedPolyLine2d(DC,Ent,vp,Mtx,pts,Segments[0..c],closed,ltgen,BulgedSegmentsCount);
  end {дальше идут неработающие варианты с толщиной} else if BulgedSegmentsCount=0 then begin
    //толстая полилиния без дуг, отправляем Segments уже с учетом closed
    CreateLWPolyLineWdh(DC,Ent,vp,Mtx,pts,Segments[0..c],closed,ltgen);
  end else begin
    //автокад не делает генерацию типа линии на полилиниях с переменной толщиной сегмента
    ltgen:=ltgen and (VariableWidthSegmentsCount=0);
    //толстая полилиния с дугами
    if VariableWidthSegmentsCount=0 then
      //CreateBulgedLWPolyLineWdh(DC,Ent,vp,Mtx,pts,Segments[0..c],closed,ltgen)
      CreateBulgedPolyLine2d(DC,Ent,vp,Mtx,pts,Segments[0..c],closed,ltgen,BulgedSegmentsCount)
    else
      //CreateBulgedLWPolyLineVariableWdh(DC,Ent,vp,Mtx,pts,Segments[0..c],closed,ltgen)
      CreateBulgedPolyLine2d(DC,Ent,vp,Mtx,pts,Segments[0..c],closed,ltgen,BulgedSegmentsCount);
  end
end;

procedure TZEntityRepresentation.StartSurface;
begin
end;

procedure TZEntityRepresentation.EndSurface;
begin
end;

begin
end.
