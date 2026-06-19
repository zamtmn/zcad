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
  uzegeometry,uzglgeometry,uzefont,uzeentitiesprop,UGDBPoint3DArray,
  uzeentsubordinated,uzegeomentitiestree,uzeTypes,gzctnrVectorTypes,
  uzgeomline3d,uzgeomproxy,uzctnrVectorTzePoint2d,math;

type
  PTZEntityRepresentation=^TZEntityRepresentation;

  TZEntityRepresentation=object(GDBaseObject)
  private
    procedure CreatePolyLineInternal(var DC:TDrawContext;var Ent:GDBObjDrawable;const vp:GDBObjVisualProp;const pts:array of TzePoint3d;const closed,ltgen:boolean);virtual;
    procedure CreateTransformedPolylyneInternal(var DC:TDrawContext;var Ent:GDBObjDrawable;const vp:GDBObjVisualProp;const Mtx:TzeTypedMatrix4d;const pts:array of TzePoint3d;const closed,ltgen:boolean);virtual;
    procedure CreateTransformedPolylyne2DInternal(var DC:TDrawContext;var Ent:GDBObjDrawable;const vp:GDBObjVisualProp;const Mtx:TzeTypedMatrix4d;const pts:array of TzePoint2d;const closed,ltgen:boolean);virtual;
    procedure CreatePolylyne2DInternal(var DC:TDrawContext;var Ent:GDBObjDrawable;const vp:GDBObjVisualProp;const pts:array of TzePoint2d;const closed,ltgen:boolean);virtual;

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
    procedure CreateLineWithoutLT(var DC:TDrawContext;var Ent:GDBObjDrawable;const startpoint,endpoint:TzePoint3d);overload;
    procedure CreateLineWithoutLT(var DC:TDrawContext;var Ent:GDBObjDrawable;const Mtx:TzeTypedMatrix4d;const startpoint,endpoint:TzePoint3d);overload;
    procedure CreatePolyLine     (var DC:TDrawContext;var Ent:GDBObjDrawable;const vp:GDBObjVisualProp;const Mtx:TzeTypedMatrix4d;const pts:array of TzePoint3d;const closed,ltgen:boolean);
    procedure CreatePolyLine2D   (var DC:TDrawContext;var Ent:GDBObjDrawable;const vp:GDBObjVisualProp;const Mtx:TzeTypedMatrix4d;const pts:array of TzePoint2d;const closed,ltgen:boolean);
    procedure CreateBulgedPolyLine2D
                                 (var DC:TDrawContext;var Ent:GDBObjDrawable;const vp:GDBObjVisualProp;const Mtx:TzeTypedMatrix4d;const pts:array of TzePoint2d;const Segments:array of TSegmentParams;const closed,ltgen:boolean);
    procedure CreateLWPolyLine   (var DC:TDrawContext;var Ent:GDBObjDrawable;const vp:GDBObjVisualProp;const Mtx:TzeTypedMatrix4d;const pts:array of TzePoint2d;const Segments:array of TSegmentParams;const closed,ltgen:boolean);
    procedure CreateLWPolyLineWdh(var DC:TDrawContext;var Ent:GDBObjDrawable;const vp:GDBObjVisualProp;const Mtx:TzeTypedMatrix4d;const pts:array of TzePoint2d;const Segments:array of TSegmentParams;const closed:boolean);
    procedure CreatePoint        (var DC:TDrawContext;var Ent:GDBObjDrawable;const vp:GDBObjVisualProp;const Mtx:TzeTypedMatrix4d;const point:TzePoint3d);
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
  v:TzePoint3d;
  simplydraw:boolean;
begin
  if rc.lod=LODCalculatedDetail then begin
    v:=uzegeometry.VertexSub(aabb.RTF,aabb.LBN);
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

procedure TZEntityRepresentation.CreateLineWithoutLT(var DC:TDrawContext;var Ent:GDBObjDrawable;
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
  CreateLineWithoutLT(DC,Ent,VectorTransform3D(startpoint,Mtx),VectorTransform3D(endpoint,Mtx));
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

procedure TZEntityRepresentation.CreatePolyLineInternal(var DC:TDrawContext;var Ent:GDBObjDrawable;
  const vp:GDBObjVisualProp;const pts:array of TzePoint3d;const closed,ltgen:boolean);
var
  ptv,ptvprev,ptvfisrt:PzePoint3d;
  ir:itrec;
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

procedure TZEntityRepresentation.CreateTransformedPolylyneInternal(var DC:TDrawContext;
  var Ent:GDBObjDrawable;const vp:GDBObjVisualProp;const Mtx:TzeTypedMatrix4d;
  const pts:array of TzePoint3d;const closed,ltgen:boolean);
var
  i:integer;
  tpts:array of TzePoint3d;
begin
  SetLength(tpts,Length(pts));
  for i:={low(pts)}0 to High(pts) do
    tpts[i]:=VectorTransform3D(pts[i],Mtx);
  CreatePolyLineInternal(DC,Ent,vp,tpts,closed,ltgen);
end;

procedure TZEntityRepresentation.CreatePolyLine(var DC:TDrawContext;var Ent:GDBObjDrawable;
  const vp:GDBObjVisualProp;const Mtx:TzeTypedMatrix4d;const pts:array of TzePoint3d;
  const closed,ltgen:boolean);
begin
  if mtx.IsIdentity then
    CreatePolyLineInternal(DC,Ent,vp,pts,closed,ltgen)
  else
    CreateTransformedPolylyneInternal(DC,Ent,vp,Mtx,pts,closed,ltgen);
end;

procedure TZEntityRepresentation.CreateTransformedPolylyne2DInternal(var DC:TDrawContext;
  var Ent:GDBObjDrawable;const vp:GDBObjVisualProp;const Mtx:TzeTypedMatrix4d;
  const pts:array of TzePoint2d;const closed,ltgen:boolean);
var
  i:integer;
  tpts:array of TzePoint3d;
begin
  SetLength(tpts,Length(pts));
  for i:={low(pts)}0 to High(pts) do
    tpts[i]:=VectorTransform2D(pts[i],Mtx);
  CreatePolyLineInternal(DC,Ent,vp,tpts,closed,ltgen);
end;

procedure TZEntityRepresentation.CreatePolylyne2DInternal(var DC:TDrawContext;var Ent:GDBObjDrawable;
  const vp:GDBObjVisualProp;const pts:array of TzePoint2d;const closed,ltgen:boolean);
var
  i:integer;
  tpts:array of TzePoint3d;
begin
  SetLength(tpts,Length(pts));
  for i:={low(pts)}0 to High(pts) do
    tpts[i]:=CreateVertex(pts[i].x,pts[i].y,0);
  CreatePolyLineInternal(DC,Ent,vp,tpts,closed,ltgen);
end;

procedure TZEntityRepresentation.CreatePolyLine2d(var DC:TDrawContext;var Ent:GDBObjDrawable;
  const vp:GDBObjVisualProp;const Mtx:TzeTypedMatrix4d;const pts:array of TzePoint2d;
  const closed,ltgen:boolean);
begin
  if mtx.IsIdentity then
    CreatePolylyne2DInternal(DC,Ent,vp,pts,closed,ltgen)
  else
    CreateTransformedPolylyne2DInternal(DC,Ent,vp,Mtx,pts,closed,ltgen);
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

procedure TZEntityRepresentation.CreateLWPolyLineWdh(var DC:TDrawContext;var Ent:GDBObjDrawable;
  const vp:GDBObjVisualProp;const Mtx:TzeTypedMatrix4d;const pts:array of TzePoint2d;
  const Segments:array of TSegmentParams;const closed:boolean);

  procedure CalcSegment(const p1,p2:TzePoint2d;const plw:TSegmentParams;var quad:TQuadData);
  var
    k:integer;
    vtangent,vnormal,vtemp:TzePoint2d;
    q3d:GDBQuad3d;
    v:TzeVector4d;
  begin
    vtangent:=p2-p1;
    vnormal.x:=-vtangent.y;
    vnormal.y:=vtangent.x;
    vnormal:=vnormal.NormalizeVertex;

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
    if q.hasEndWidth or q.hasEndWidth then begin
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
  if needbreak then begin
    DrawLWPLLinearSegments(qtype,quads[thisqtypestart..high(Segments)-1]);
    qtype:=Segment2QType(quads[high(Segments)],needbreak);
    DrawLWPLLinearSegments(qtype,quads[high(Segments)..high(Segments)])
  end else
    DrawLWPLLinearSegments(qtype,quads[thisqtypestart..high(Segments)])
end;

procedure DrawArc(constref p1,p2:TzePoint2d;const bulge:double;var currpath:TZctnrVectorTzePoint2d;divcount:integer);//inline;  dg
var
  d,pc,pac,n:TzePoint2d;
  l,h,nextbulge:double;
begin
  d:=p2-p1;
  l:=d.Length;
  h:=l*bulge/2;
  pc:=(p1+p2)/2;
  n.x:=-d.y;
  n.y:=d.x;
  n:=n.NormalizeVertex;
  pac:=pc-n*h;
  if divcount=-1 then begin
    //пытаемся сделать лод. вариантов не много
    divcount:=min(max(2,abs(round(bulge*2))),5);
    {if abs(h)*2>l then
      divcount:=3
    else
      divcount:=2}
  end;
  if divcount=0 then begin
    currpath.PushBackData(p1);
    currpath.PushBackData(pac);
  end else begin
    Dec(divcount);
    nextbulge:=bulge/(1+sqrt(1+bulge*bulge));
    DrawArc(p1,pac,nextbulge,currpath,divcount);
    DrawArc(pac,p2,nextbulge,currpath,divcount);
  end;
end;


procedure TZEntityRepresentation.CreateBulgedPolyLine2d(var DC:TDrawContext;var Ent:GDBObjDrawable;
  const vp:GDBObjVisualProp;const Mtx:TzeTypedMatrix4d;const pts:array of TzePoint2d;
  const Segments:array of TSegmentParams;const closed,ltgen:boolean);
type
  TLastSegType=(LSTLine,LSTArc,LSTUnknown);
var
  i,StartLineSegmentIndex:integer;
  LastLineSegment:TLastSegType;
  currpath:TZctnrVectorTzePoint2d;
begin
  currpath.init(10);
  StartLineSegmentIndex:=low(Segments);
  LastLineSegment:=LSTUnknown;
  if ltgen then begin

  end else begin
    for i:=low(Segments)to high(segments) do begin
      if abs(Segments[i].data.bulge)>eps then begin
        if LastLineSegment=LSTLine then begin
          CreateTransformedPolylyne2DInternal(DC,Ent,vp,Mtx,pts[StartLineSegmentIndex..i],false,false);
        end;
        LastLineSegment:=LSTArc;
        DrawArc(pts[i],pts[i+1],Segments[i].data.bulge,currpath,3);
        currpath.PushBackData(pts[i+1]);
        CreateTransformedPolylyne2DInternal(DC,Ent,vp,Mtx,currpath.getPFirst[0..currpath.GetLastIndex],false,false);
        currpath.Clear;
      end else begin
        if LastLineSegment<>LSTLine then
          StartLineSegmentIndex:=i;
        LastLineSegment:=LSTLine;
      end;
    end;
  end;
  currpath.destroy;
end;

procedure TZEntityRepresentation.CreateLWPolyLine(var DC:TDrawContext;var Ent:GDBObjDrawable;
  const vp:GDBObjVisualProp;const Mtx:TzeTypedMatrix4d;
  const pts:array of TzePoint2d;const Segments:array of TSegmentParams;
  const closed,ltgen:boolean);
type
  TSegmentParamCheck=set of (SPHasBulge,SPHasWidth);
var
  i,c:integer;
  spc:TSegmentParamCheck=[];
begin
  //последний сегмент имеет смысл только ждя замкнутой полилинии
  if closed then
    c:=high(Segments)
  else
    c:=high(Segments)-1;
  //проверяем есть ли в полилинии дуговые и широкие сегменты
  for i:=low(Segments)to c do begin
    if abs(Segments[i].data.bulge)>eps then
      Include(spc,SPHasBulge);
    if Segments[i].data.hw then
      Include(spc,SPHasWidth);
    if spc=[SPHasBulge,SPHasWidth] then
      Break;
  end;
  if spc=[] then
    //тонкая полилиния без дуг
    CreatePolyLine2d(DC,Ent,vp,Mtx,pts,closed,ltgen)
  else if spc=[SPHasWidth] then begin
    //толстая полилиния без дуг, отправляем Segments уже с учетом closed
    CreateLWPolyLineWdh(DC,Ent,vp,Mtx,pts,Segments[0..c],closed);
  end else if spc=[SPHasBulge] then begin
    //тонкая полилиния с дугами
    CreateBulgedPolyLine2d(DC,Ent,vp,Mtx,pts,Segments[0..c],closed,ltgen);
  end else if spc=[SPHasWidth,SPHasBulge] then begin
    //толстая полилиния с дугами
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
