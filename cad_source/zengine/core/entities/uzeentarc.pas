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
unit uzeentarc;
{$Mode delphi}{$H+}
{$INCLUDE zengineconfig.inc}
interface

uses
  uzeentityfactory,uzeentsubordinated,uzgldrawcontext,uzedrawingdef,
  uzeentwithlocalcs,uzecamera,uzestyleslayers,UGDBSelectedObjArray,uzeentity,
  UGDBPoint3DArray,uzctnrVectorBytes,uzbtypes,uzegeometrytypes,uzeconsts,
  uzglviewareadata,uzegeometry,uzeffdxfsupport,uzeentplain,uzeSnap,Math,
  uzMVReader,uzCtnrVectorpBaseEntity;

type

  PGDBObjArc=^GDBObjARC;

  GDBObjArc=object(GDBObjPlain)
    R:double;
    StartAngle:double;
    EndAngle:double;
    angle:double;
    Vertex3D_in_WCS_Array:GDBPoint3DArray;
    q0:TzePoint3d;
    q1:TzePoint3d;
    q2:TzePoint3d;
    constructor init(own:Pointer;layeraddres:PGDBLayerProp;
      LW:smallint;p:TzePoint3d;RR,S,E:double);
    constructor initnul;
    procedure LoadFromDXF(var rdr:TZMemReader;ptu:PExtensionData;
      var drawing:TDrawingDef;var context:TIODXFLoadContext);virtual;

    procedure SaveToDXF(var outStream:TZctnrVectorBytes;
      var drawing:TDrawingDef;var IODXFContext:TIODXFSaveContext);virtual;
    procedure DrawGeometry(lw:integer;var DC:TDrawContext;
      const inFrustumState:TInBoundingVolume);virtual;
    procedure addcontrolpoints(tdesc:Pointer);virtual;
    procedure remaponecontrolpoint(pdesc:pcontrolpointdesc;
      ProjectProc:GDBProjectProc);virtual;
    procedure CalcObjMatrix(pdrawing:PTDrawingDef=nil);virtual;
    procedure precalc;
    procedure FormatEntity(var drawing:TDrawingDef;
      var DC:TDrawContext;Stage:TEFStages=EFAllStages);virtual;
    procedure createpoints(var DC:TDrawContext);virtual;
    procedure getoutbound(var DC:TDrawContext);virtual;
    procedure projectpoint;virtual;
    function onmouse(var popa:TZctnrVectorPGDBaseEntity;
      const MF:ClipArray;InSubEntry:boolean):boolean;virtual;
    function getsnap(var osp:os_record;var pdata:Pointer;
      const param:OGLWndtype;ProjectProc:GDBProjectProc;SnapMode:TGDBOSMode):boolean;virtual;
    function beforertmodify:Pointer;virtual;
    procedure rtmodifyonepoint(const rtmod:TRTModifyData);virtual;
    function IsRTNeedModify(const Point:PControlPointDesc;
      p:Pointer):boolean;virtual;
    procedure SetFromClone(_clone:PGDBObjEntity);virtual;
    function Clone(own:Pointer):PGDBObjEntity;virtual;
    procedure rtsave(refp:Pointer);virtual;
    destructor done;virtual;
    function GetObjTypeName:string;virtual;
    function calcinfrustum(const frustum:ClipArray;
      const Actuality:TVisActuality;var Counters:TCameraCounters;ProjectProc:GDBProjectProc;
      const zoom,currentdegradationfactor:double):boolean;virtual;
    function CalcTrueInFrustum(
      const frustum:ClipArray):TInBoundingVolume;virtual;
    procedure ReCalcFromObjMatrix;virtual;
    procedure transform(const t_matrix:DMatrix4d);virtual;
    //function GetTangentInPoint(point:TzePoint3d):TzePoint3d;virtual;
    procedure AddOnTrackAxis(var posr:os_record;
      const processaxis:taddotrac);virtual;
    function onpoint(var objects:TZctnrVectorPGDBaseEntity;
      const point:TzePoint3d):boolean;virtual;
    procedure TransformAt(p:PGDBObjEntity;t_matrix:PDMatrix4d);virtual;
    class function CreateInstance:PGDBObjArc;static;
    function GetObjType:TObjID;virtual;
    function IsStagedFormatEntity:boolean;virtual;
  end;

implementation

function GDBObjARC.IsStagedFormatEntity:boolean;
begin
  Result:=True;
end;

procedure GDBObjARC.TransformAt;
var
  tv:TzeVector4d;
begin
  objmatrix:=uzegeometry.MatrixMultiply(PGDBObjWithLocalCS(p)^.objmatrix,t_matrix^);

  tv:=PTzeVector4d(@t_matrix.mtr[3])^;
  PTzeVector4d(@t_matrix.mtr[3])^:=NulVertex4D;
  PTzeVector4d(@t_matrix.mtr[3])^:=tv;
  ReCalcFromObjMatrix;
end;

function GDBObjARC.onpoint(var objects:TZctnrVectorPGDBaseEntity;
  const point:TzePoint3d):boolean;
begin
  if Vertex3D_in_WCS_Array.onpoint(point,False) then begin
    Result:=
      True;
    objects.
      PushBackData(@self);
  end else
    Result:=
      False;
end;

procedure GDBObjARC.AddOnTrackAxis(var posr:os_record;const processaxis:taddotrac);
var
  m1:DMatrix4d;
  dir,tv:TzePoint3d;
begin
  m1:=GetMatrix^;
  MatrixInvert(m1);
  dir:=VectorTransform3D(posr.worldcoord,m1);

  processaxis(posr,dir);
  tv:=uzegeometry.vectordot(dir,zwcs);
  processaxis(posr,tv);
end;

procedure GDBObjARC.transform;
var
  sav,eav,pins:TzePoint3d;
begin
  precalc;
  if t_matrix.mtr[0].v[0]*t_matrix.mtr[1].v[1]*t_matrix.mtr[2].v[2]<eps then begin
    sav:=q2;
    eav:=q0;
  end else begin
    sav:=q0;
    eav:=q2;
  end;
  pins:=P_insert_in_WCS;
  sav:=VectorTransform3D(sav,t_matrix);
  eav:=VectorTransform3D(eav,t_matrix);
  pins:=VectorTransform3D(pins,t_matrix);
  inherited;
  sav:=NormalizeVertex(VertexSub(sav,pins));
  eav:=NormalizeVertex(VertexSub(eav,pins));

  StartAngle:=TwoVectorAngle(_X_yzVertex,sav);
  if sav.y<eps then
    StartAngle:=2*pi-StartAngle;

  EndAngle:=TwoVectorAngle(_X_yzVertex,eav);
  if eav.y<eps then
    EndAngle:=2*pi-EndAngle;
end;

procedure GDBObjARC.ReCalcFromObjMatrix;
var
  ox,oy:TzePoint3d;
  m:DMatrix4d;
begin
  inherited;

  ox:=GetXfFromZ(Local.basis.oz);
  oy:=NormalizeVertex(VectorDot(Local.basis.oz,Local.basis.ox));
  m:=CreateMatrixFromBasis(ox,oy,Local.basis.oz);

  Local.P_insert:=VectorTransform3D(PzePoint3d(@objmatrix.mtr[3])^,m);
  self.R:=PzePoint3d(@objmatrix.mtr[0])^.x/local.basis.OX.x;
end;

function GDBObjARC.CalcTrueInFrustum;
var
  i:integer;
  rad:double;
begin
  rad:=abs(ObjMatrix.mtr[0].v[0]);
  for i:=0 to 5 do
    if (frustum[i].v[0]*P_insert_in_WCS.x+frustum[i].v[1]*
      P_insert_in_WCS.y+frustum[i].v[2]*P_insert_in_WCS.z+
      frustum[i].v[3]+rad{+GetLTCorrectH}<0) then
      exit(IREmpty);
  Result:=Vertex3D_in_WCS_Array.CalcTrueInFrustum(frustum,False);
end;

function GDBObjARC.calcinfrustum;
var
  i:integer;
begin
  Result:=True;
  for i:=0 to 4 do begin
    if (frustum[i].v[0]*outbound[0].x+frustum[i].v[1]*outbound[0].y+
        frustum[i].v[2]*outbound[0].z+frustum[i].v[3]<0)  and
       (frustum[i].v[0]*outbound[1].x+frustum[i].v[1]*outbound[1].y+
        frustum[i].v[2]*outbound[1].z+frustum[i].v[3]<0)  and
       (frustum[i].v[0]*outbound[2].x+frustum[i].v[1]*outbound[2].y+
        frustum[i].v[2]*outbound[2].z+frustum[i].v[3]<0)  and
       (frustum[i].v[0]*outbound[3].x+frustum[i].v[1]*outbound[3].y+
        frustum[i].v[2]*outbound[3].z+frustum[i].v[3]<0) then begin
      Result:=False;
      system.break;
    end;
  end;
end;

function GDBObjARC.GetObjTypeName;
begin
  Result:=ObjN_GDBObjArc;
end;

destructor GDBObjARC.done;
begin
  inherited done;
  Vertex3D_in_WCS_Array.Done;
end;

constructor GDBObjARC.initnul;
begin
  inherited initnul(nil);
  r:=1;
  startangle:=0;
  endangle:=pi/2;
  Vertex3D_in_WCS_Array.init(3);
end;

constructor GDBObjARC.init;
begin
  inherited init(own,layeraddres,lw);
  Local.p_insert:=p;
  r:=rr;
  startangle:=s;
  endangle:=e;
  Vertex3D_in_WCS_Array.init(3);
end;

function GDBObjArc.GetObjType;
begin
  Result:=GDBArcID;
end;

procedure GDBObjArc.SaveToDXF;
begin
  SaveToDXFObjPrefix(outStream,'ARC','AcDbCircle',IODXFContext);
  dxfvertexout(outStream,10,Local.p_insert);
  dxfDoubleout(outStream,40,r);
  SaveToDXFObjPostfix(outStream);

  dxfStringout(outStream,100,'AcDbArc');
  dxfDoubleout(outStream,50,startangle*180/pi);
  dxfDoubleout(outStream,51,endangle*180/pi);
end;

procedure GDBObjARC.CalcObjMatrix;
var
  m1:DMatrix4d;
  v:TzeVector4d;
begin
  inherited CalcObjMatrix;
  m1:=CreateScaleMatrix(r);
  objmatrix:=matrixmultiply(m1,objmatrix);

  PzePoint3d(@v)^:=local.p_insert;
  v.z:=0;
  v.w:=1;
  m1:=objMatrix;
  MatrixInvert(m1);
  v:=VectorTransform(v,m1);
end;

procedure GDBObjARC.precalc;
var
  v:TzeVector4d;
begin
  angle:=endangle-startangle;
  if angle<0 then
    angle:=2*pi+angle;
  SinCos(startangle,v.y,v.x);
  v.z:=0;
  v.w:=1;
  v:=VectorTransform(v,objMatrix);
  q0:=PzePoint3d(@v)^;
  SinCos(startangle+angle/2,v.y,v.x);
  v.z:=0;
  v.w:=1;
  v:=VectorTransform(v,objMatrix);
  q1:=PzePoint3d(@v)^;
  SinCos(endangle,v.y,v.x);
  v.z:=0;
  v.w:=1;
  v:=VectorTransform(v,objMatrix);
  q2:=PzePoint3d(@v)^;
end;

procedure GDBObjARC.FormatEntity(var drawing:TDrawingDef;
  var DC:TDrawContext;Stage:TEFStages=EFAllStages);
begin
  if EFCalcEntityCS in stage then begin
    if assigned(EntExtensions) then
      EntExtensions.RunOnBeforeEntityFormat(@self,drawing,DC);

    calcObjMatrix;
    precalc;

    calcbb(dc);
    createpoints(dc);
  end;
  CalcActualVisible(dc.DrawingContext.VActuality);
  if EFDraw in stage then begin
    Representation.Clear;
    if not (ESTemp in State)and(DCODrawable in DC.Options) then
      Representation.DrawPolyLineWithLT(dc,Vertex3D_in_WCS_Array,vp,False,False);
    if assigned(EntExtensions) then
      EntExtensions.RunOnAfterEntityFormat(@self,drawing,DC);
  end;
end;

procedure GDBObjARC.getoutbound;

  function getQuadrant(a:double):integer;
  {
  2|1
  ---
  3|4
  }
  begin
    if a<pi/2 then
      Result:=0
    else if a<pi then
      Result:=1
    else if a<3*pi/2 then
      Result:=2
    else
      Result:=3;
  end;

  function AxisIntersect(q1,q2:integer):integer;
  {
    2
   2|1
  4---1
   3|4
    8
  }
  begin
    Result:=0;
    while q1<>q2 do begin
      Inc(q1);
      q1:=q1 and 3;
      Result:=Result or (1 shl q1);
    end;
  end;

var
  sx,sy,ex,ey,minx,miny,maxx,maxy:double;
  sq,eq,q:integer;
begin
  vp.BoundingBox:=CreateBBFrom2Point(q0,q2);
  sq:=getQuadrant(self.StartAngle);
  eq:=getQuadrant(self.EndAngle);
  q:=AxisIntersect(sq,eq);
  if (self.StartAngle>self.EndAngle)and(q=0) then
    q:=q xor 15;
  SinCos(self.StartAngle,sy,sx);
  SinCos(self.EndAngle,ey,ex);
  if sx>ex then begin
    minx:=ex;
    maxx:=sx;
  end else begin
    minx:=sx;
    maxx:=ex;
  end;
  if sy>ey then begin
    miny:=ey;
    maxy:=sy;
  end else begin
    miny:=sy;
    maxy:=ey;
  end;
  if (q and 1)>0 then begin
    concatBBandPoint(vp.BoundingBox,VectorTransform3d(
      CreateVertex(1,0,0),objMatrix));
    maxx:=1;
  end;
  if (q and 4)>0 then begin
    concatBBandPoint(vp.BoundingBox,VectorTransform3d(
      CreateVertex(-1,0,0),objMatrix));
    minx:=-1;
  end;
  if (q and 2)>0 then begin
    concatBBandPoint(vp.BoundingBox,VectorTransform3d(
      CreateVertex(0,1,0),objMatrix));
    maxy:=1;
  end;
  if (q and 8)>0 then begin
    concatBBandPoint(vp.BoundingBox,VectorTransform3d(
      CreateVertex(0,-1,0),objMatrix));
    miny:=-1;
  end;
   outbound[0]:=VectorTransform3d(CreateVertex(minx,maxy,0),objMatrix);
  outbound[1]:=VectorTransform3d(CreateVertex(maxx,maxy,0),objMatrix);
  outbound[2]:=VectorTransform3d(CreateVertex(maxx,miny,0),objMatrix);
  outbound[3]:=VectorTransform3d(CreateVertex(minx,miny,0),objMatrix);
end;

procedure GDBObjARC.createpoints(var DC:TDrawContext);
var
  i:integer;
  l:double;
  v:TzePoint3d;
  pv:TzePoint3d;
  maxlod:integer;
begin
  angle:=endangle-startangle;
  if angle<0 then
    angle:=2*pi+angle;

  if dc.MaxDetail then
    maxlod:=100
  else
    maxlod:=60;

  l:=r*angle/(dc.DrawingContext.zoom*10);
  if (l>maxlod)or dc.MaxDetail then
    lod:=maxlod
  else begin
    lod:=round(l);
    if lod<5 then
      lod:=5;
  end;
  Vertex3D_in_WCS_Array.SetSize(lod+1);

  Vertex3D_in_WCS_Array.Clear;
  SinCos(startangle,v.y,v.x);
  v.z:=0;
  pv:=VectorTransform3D(v,objmatrix);
  Vertex3D_in_WCS_Array.PushBackData(pv);

  for i:=1 to lod do begin
    SinCos(startangle+i/lod*angle,v.y,v.x);
    v.z:=0;
    pv:=VectorTransform3D(v,objmatrix);
    Vertex3D_in_WCS_Array.PushBackData(pv);
  end;
  Vertex3D_in_WCS_Array.Shrink;
end;

procedure GDBObjARC.DrawGeometry;
begin
  Representation.DrawGeometry(DC,VP.BoundingBox,inFrustumState);
  inherited;
end;

procedure GDBObjARC.projectpoint;
begin

end;

procedure GDBObjARC.LoadFromDXF;
var
  byt:integer;
  dc:TDrawContext;
begin
  byt:=rdr.ParseInteger;
  while byt<>0 do begin
    if not LoadFromDXFObjShared(rdr,byt,ptu,drawing,context) then
      if not dxfLoadGroupCodeVertex(rdr,10,byt,Local.P_insert) then
        if not dxfLoadGroupCodeDouble(rdr,40,byt,r) then
          if not dxfLoadGroupCodeDouble(rdr,50,byt,startangle) then
            if not dxfLoadGroupCodeDouble(rdr,51,byt,endangle) then
              rdr.SkipString;
    byt:=rdr.ParseInteger;
  end;
  startangle:=startangle*pi/180;
  endangle:=endangle*pi/180;
  dc:=drawing.createdrawingrc;
  if vp.Layer=nil then
    vp.Layer:=nil;
  FormatEntity(drawing,dc);
end;

function GDBObjARC.onmouse;
var
  i:integer;
  rad:double;
begin
  rad:=abs(ObjMatrix.mtr[0].v[0]);
  for i:=0 to 5 do begin
    if (mf[i].v[0]*P_insert_in_WCS.x+mf[i].v[1]*P_insert_in_WCS.y+
        mf[i].v[2]*P_insert_in_WCS.z+mf[i].v[3]+rad<0) then
      exit(False);
  end;
  Result:=Vertex3D_in_WCS_Array.onmouse(mf,False);
  if not Result then
    if CalcPointTrueInFrustum(P_insert_in_WCS,mf)=IRFully then
      Result:=True;
end;

procedure GDBObjARC.remaponecontrolpoint(pdesc:pcontrolpointdesc;
  ProjectProc:GDBProjectProc);
var
  tv:TzePoint3d;
begin
  if pdesc^.pointtype=os_begin then begin
    pdesc.worldcoord:=q0;
    ProjectProc(pdesc.worldcoord,tv);
    pdesc.dispcoord:=ToVertex2DI(tv);
  end else if pdesc^.pointtype=os_midle then begin
    pdesc.worldcoord:=q1;
    ProjectProc(pdesc.worldcoord,tv);
    pdesc.dispcoord:=ToVertex2DI(tv);
  end else if pdesc^.pointtype=os_end then begin
    pdesc.worldcoord:=q2;
    ProjectProc(pdesc.worldcoord,tv);
    pdesc.dispcoord:=ToVertex2DI(tv);
  end;
end;

procedure GDBObjARC.addcontrolpoints(tdesc:Pointer);
var
  pdesc:controlpointdesc;
begin
  PSelectedObjDesc(tdesc)^.pcontrolpoint^.init(3);
  pdesc.selected:=False;
  pdesc.PDrawable:=nil;

  pdesc.pointtype:=os_begin;
  pdesc.attr:=[CPA_Strech];
  pdesc.worldcoord:=q0;
  PSelectedObjDesc(tdesc)^.pcontrolpoint^.PushBackData(pdesc);

  pdesc.pointtype:=os_midle;
  pdesc.attr:=[];
  pdesc.worldcoord:=q1;
  PSelectedObjDesc(tdesc)^.pcontrolpoint^.PushBackData(pdesc);

  pdesc.pointtype:=os_end;
  pdesc.attr:=[CPA_Strech];
  pdesc.worldcoord:=q1;
  PSelectedObjDesc(tdesc)^.pcontrolpoint^.PushBackData(pdesc);
end;

function GDBObjARC.getsnap;
begin
  if onlygetsnapcount=4 then begin
    Result:=False;
    exit;
  end;
  Result:=True;
  case onlygetsnapcount of
    0:begin
      if (SnapMode and osm_center)<>0 then begin
        osp.worldcoord:=P_insert_in_WCS;
        ProjectProc(osp.worldcoord,osp.dispcoord);
        osp.ostype:=os_center;
      end else
        osp.ostype:=os_none;
    end;
    1:begin
      if (SnapMode and osm_endpoint)<>0 then begin
        osp.worldcoord:=q0;
        ProjectProc(osp.worldcoord,osp.dispcoord);
        osp.ostype:=os_begin;
      end else
        osp.ostype:=os_none;
    end;
    2:begin
      if (SnapMode and osm_midpoint)<>0 then begin
        osp.worldcoord:=q1;
        ProjectProc(osp.worldcoord,osp.dispcoord);
        osp.ostype:=os_midle;
      end else
        osp.ostype:=os_none;
    end;
    3:begin
      if (SnapMode and osm_endpoint)<>0 then begin
        osp.worldcoord:=q2;
        ProjectProc(osp.worldcoord,osp.dispcoord);
        osp.ostype:=os_end;
      end else
        osp.ostype:=os_none;
    end;
  end;
  Inc(onlygetsnapcount);
end;

function GDBObjARC.beforertmodify;
begin
  Getmem(Result,sizeof(tarcrtmodify));
  tarcrtmodify(Result^).p1.x:=q0.x;
  tarcrtmodify(Result^).p1.y:=q0.y;
  tarcrtmodify(Result^).p2.x:=q1.x;
  tarcrtmodify(Result^).p2.y:=q1.y;
  tarcrtmodify(Result^).p3.x:=q2.x;
  tarcrtmodify(Result^).p3.y:=q2.y;
end;

function GDBObjARC.IsRTNeedModify(const Point:PControlPointDesc;p:Pointer):boolean;
begin
  Result:=True;
end;

procedure GDBObjARC.SetFromClone(_clone:PGDBObjEntity);
begin
  q0:=PGDBObjARC(_clone)^.q0;
  q1:=PGDBObjARC(_clone)^.q1;
  q2:=PGDBObjARC(_clone)^.q2;
end;

procedure GDBObjARC.rtmodifyonepoint(const rtmod:TRTModifyData);
var
  tv3d:TzePoint3d;
  tq0,tq1,tq2:TzePoint3d;
  ptdata:tarcrtmodify;
  ad:TArcData;
  m:DMatrix4d;
begin
  m:=ObjMatrix;
  MatrixInvert(m);
  m.mtr[3]:=NulVector4D;

  tq0:=VectorTransform3D(q0*R,m);
  tq1:=VectorTransform3D(q1*R,m);
  tq2:=VectorTransform3D(q2*R,m);
  tv3d:=VectorTransform3D(rtmod.wc*R,m);

  ptdata.p1.x:=tq0.x;
  ptdata.p1.y:=tq0.y;
  ptdata.p2.x:=tq1.x;
  ptdata.p2.y:=tq1.y;
  ptdata.p3.x:=tq2.x;
  ptdata.p3.y:=tq2.y;

  if rtmod.point.pointtype=os_begin then begin
    ptdata.p1.x:=tv3d.x;
    ptdata.p1.y:=tv3d.y;
  end else if rtmod.point.pointtype=os_midle then begin
    ptdata.p2.x:=tv3d.x;
    ptdata.p2.y:=tv3d.y;
  end else if rtmod.point.pointtype=os_end then begin
    ptdata.p3.x:=tv3d.x;
    ptdata.p3.y:=tv3d.y;
  end;

  if GetArcParamFrom3Point2D(ptdata,ad) then begin
    Local.p_insert.x:=ad.p.x;
    Local.p_insert.y:=ad.p.y;
    Local.p_insert.z:=0;
    startangle:=ad.startangle;
    endangle:=ad.endangle;
    r:=ad.r;
  end;
end;

function GDBObjARC.Clone;
var
  tvo:PGDBObjArc;
begin
  Getmem(Pointer(tvo),sizeof(GDBObjArc));
  tvo^.init(CalcOwner(own),vp.Layer,vp.LineWeight,Local.p_insert,
    r,startangle,endangle);
  tvo^.Local.basis.oz:=Local.basis.oz;
  CopyVPto(tvo^);
  CopyExtensionsTo(tvo^);
  Result:=tvo;
end;

procedure GDBObjARC.rtsave;
begin
  pgdbobjarc(refp)^.Local.p_insert:=Local.p_insert;
  pgdbobjarc(refp)^.startangle:=startangle;
  pgdbobjarc(refp)^.endangle:=endangle;
  pgdbobjarc(refp)^.r:=r;
end;

function AllocArc:PGDBObjArc;
begin
  Getmem(pointer(Result),sizeof(GDBObjArc));
end;

function AllocAndInitArc(owner:PGDBObjGenericWithSubordinated):PGDBObjArc;
begin
  Result:=AllocArc;
  Result.initnul;
  Result.bp.ListPos.Owner:=owner;
end;

procedure SetArcGeomProps(AArc:PGDBObjArc;const args:array of const);
var
  counter:integer;
begin
  counter:=low(args);
  AArc^.Local.P_insert:=CreateVertexFromArray(counter,args);
  AArc^.R:=CreateDoubleFromArray(counter,args);
  AArc^.StartAngle:=CreateDoubleFromArray(counter,args);
  AArc^.EndAngle:=CreateDoubleFromArray(counter,args);
end;

function AllocAndCreateArc(owner:PGDBObjGenericWithSubordinated;
  const args:array of const):PGDBObjArc;
begin
  Result:=AllocAndInitArc(owner);
  SetArcGeomProps(Result,args);
end;

class function GDBObjARC.CreateInstance:PGDBObjArc;
begin
  Result:=AllocAndInitArc(nil);
end;

begin
  RegisterDXFEntity(GDBArcID,'ARC','Arc',@AllocArc,@AllocAndInitArc,@SetArcGeomProps,@AllocAndCreateArc);
end.
