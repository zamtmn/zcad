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
  uzgeomline3d,uzgeomproxy,uzctnrVectorTzePoint2d;

type
  PTZEntityRepresentation=^TZEntityRepresentation;

  TZEntityRepresentation=object(GDBaseObject)
  private
    procedure CreatePolyLineInternal(var DC:TDrawContext;var Ent:GDBObjDrawable;const vp:GDBObjVisualProp;const pts:array of TzePoint3d;const closed,ltgen:boolean);virtual;
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
    procedure CreatePolyLine     (var DC:TDrawContext;var Ent:GDBObjDrawable;const vp:GDBObjVisualProp;const Mtx:TzeTypedMatrix4d;const pts:array of TzePoint3d;const closed,ltgen:boolean);virtual;
    procedure CreatePolyLine2D   (var DC:TDrawContext;var Ent:GDBObjDrawable;const vp:GDBObjVisualProp;const Mtx:TzeTypedMatrix4d;const pts:array of TzePoint2d;const closed,ltgen:boolean);virtual;
    procedure CreateLWPolyLine   (var DC:TDrawContext;var Ent:GDBObjDrawable;const vp:GDBObjVisualProp;const Mtx:TzeTypedMatrix4d;const pts:array of TzePoint2d;const Segments:array of TSegmentParams;const closed,ltgen:boolean);virtual;
    procedure CreatePoint        (var DC:TDrawContext;var Ent:GDBObjDrawable;const vp:GDBObjVisualProp;const Mtx:TzeTypedMatrix4d;const point:TzePoint3d);
    procedure StartSurface;
    procedure EndSurface;
  end;

implementation

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


procedure TZEntityRepresentation.CreatePolyLine(var DC:TDrawContext;var Ent:GDBObjDrawable;
  const vp:GDBObjVisualProp;const Mtx:TzeTypedMatrix4d;const pts:array of TzePoint3d;
  const closed,ltgen:boolean);
  procedure CreateTransformedPolylyne;
  var
    i:integer;
    tpts:array of TzePoint3d;
  begin
    SetLength(tpts,Length(pts));
    for i:={low(pts)}0 to High(pts) do
      tpts[i]:=VectorTransform3D(pts[i],Mtx);
    CreatePolyLineInternal(DC,Ent,vp,tpts,closed,ltgen);
  end;
begin
  if mtx.IsIdentity then
    CreatePolyLineInternal(DC,Ent,vp,pts,closed,ltgen)
  else
    CreateTransformedPolylyne;
end;

procedure TZEntityRepresentation.CreatePolyLine2d(var DC:TDrawContext;var Ent:GDBObjDrawable;
  const vp:GDBObjVisualProp;const Mtx:TzeTypedMatrix4d;const pts:array of TzePoint2d;
  const closed,ltgen:boolean);
  procedure _CreateTransformedPolylyne;
  var
    i:integer;
    tpts:array of TzePoint3d;
  begin
    SetLength(tpts,Length(pts));
    for i:={low(pts)}0 to High(pts) do
      tpts[i]:=VectorTransform2D(pts[i],Mtx);
    CreatePolyLineInternal(DC,Ent,vp,tpts,closed,ltgen);
  end;
  procedure _CreatePolylyne;
  var
    i:integer;
    tpts:array of TzePoint3d;
  begin
    SetLength(tpts,Length(pts));
    for i:={low(pts)}0 to High(pts) do
      tpts[i]:=CreateVertex(pts[i].x,pts[i].y,0);
    CreatePolyLineInternal(DC,Ent,vp,tpts,closed,ltgen);
  end;
begin
  if mtx.IsIdentity then
    _CreatePolylyne
  else
    _CreateTransformedPolylyne;
end;


procedure TZEntityRepresentation.CreateLWPolyLine(var DC:TDrawContext;var Ent:GDBObjDrawable;
  const vp:GDBObjVisualProp;const Mtx:TzeTypedMatrix4d;
  const pts:array of TzePoint2d;const Segments:array of TSegmentParams;
  const closed,ltgen:boolean);
type
  TSegmentParamCheck=set of (SPHasBulge,SPHasWidth);
var
  i:integer;
  spc:TSegmentParamCheck;
begin
  spc:=[];
  for i:=low(Segments)to high(Segments) do begin
    if abs(Segments[i].data.bulge)>eps then
      Include(spc,SPHasBulge);
    if Segments[i].data.hw then
      Include(spc,SPHasWidth);
    if spc=[SPHasBulge,SPHasWidth] then
      Break;
  end;
  if spc=[] then
    CreatePolyLine2d(DC,Ent,vp,Mtx,pts,closed,ltgen);
end;

procedure TZEntityRepresentation.StartSurface;
begin
end;

procedure TZEntityRepresentation.EndSurface;
begin
end;

begin
end.
