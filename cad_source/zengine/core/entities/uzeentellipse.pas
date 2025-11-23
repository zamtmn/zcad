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
unit uzeentellipse;
{$INCLUDE zengineconfig.inc}
interface

uses
  uzeentityfactory,uzeentsubordinated,uzgldrawcontext,uzedrawingdef,uzecamera,
  uzeentwithlocalcs,uzestyleslayers,
  UGDBSelectedObjArray,uzeentity,UGDBOutbound2DIArray,UGDBPoint3DArray,
  uzegeometrytypes,uzctnrVectorBytes,varman,varmandef,uzbtypes,uzeconsts,
  uzglviewareadata,uzegeometry,uzeffdxfsupport,uzeentplain,
  uzeSnap,Math,uzMVReader,uzCtnrVectorpBaseEntity;

type
  ptEllipsertmodify=^tEllipsertmodify;

  tEllipsertmodify=record
    p1,p2,p3:TzePoint2d;
  end;
  PGDBObjEllipse=^GDBObjEllipse;

  GDBObjEllipse=object(GDBObjPlain)
    RR:double;
    MajorAxis:TzePoint3d;
    Ratio:double;
    StartAngle:double;
    EndAngle:double;
    angle:double;
    Vertex3D_in_WCS_Array:GDBPoint3DArray;
    length:double;
    q0,q1,q2:TzePoint3d;
    constructor init(own:Pointer;layeraddres:PGDBLayerProp;
      LW:smallint;p:TzePoint3d;{RR,}S,E:double;majaxis:TzePoint3d);
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
    procedure FormatEntity(var drawing:TDrawingDef;
      var DC:TDrawContext;Stage:TEFStages=EFAllStages);virtual;
    procedure createpoint;virtual;
    procedure getoutbound(var DC:TDrawContext);virtual;
    procedure projectpoint;virtual;
    function onmouse(var popa:TZctnrVectorPGDBaseEntity;
      const MF:TzeFrustum;InSubEntry:boolean):boolean;virtual;
    function getsnap(var osp:os_record;var pdata:Pointer;
      const param:OGLWndtype;ProjectProc:GDBProjectProc;SnapMode:TGDBOSMode):boolean;virtual;
    function beforertmodify:Pointer;virtual;
    procedure rtmodifyonepoint(const rtmod:TRTModifyData);virtual;
    function IsRTNeedModify(const Point:PControlPointDesc;
      p:Pointer):boolean;virtual;
    function Clone(own:Pointer):PGDBObjEntity;virtual;
    procedure rtsave(refp:Pointer);virtual;
    destructor done;virtual;
    function GetObjTypeName:string;virtual;
    function calcinfrustum(const frustum:TzeFrustum;
      const Actuality:TVisActuality;var Counters:TCameraCounters;ProjectProc:GDBProjectProc;
      const zoom,currentdegradationfactor:double):boolean;virtual;
    function CalcTrueInFrustum(
      const frustum:TzeFrustum):TInBoundingVolume;virtual;
    function CalcObjMatrixWithoutOwner:TzeTypedMatrix4d;virtual;
    procedure transform(const t_matrix:TzeTypedMatrix4d);virtual;
    procedure TransformAt(p:PGDBObjEntity;t_matrix:PzeTypedMatrix4d);virtual;
    procedure ReCalcFromObjMatrix;virtual;
    function CreateInstance:PGDBObjEllipse;static;
    function GetObjType:TObjID;virtual;
  end;

implementation

procedure GDBObjEllipse.TransformAt;
var
  tv:TzeVector4d;
begin
  objmatrix:=uzegeometry.MatrixMultiply(PGDBObjWithLocalCS(p)^.objmatrix,t_matrix^);

  tv:=PzeVector4d(@t_matrix.mtr.v[3])^;
  PzeVector4d(@t_matrix.mtr.v[3])^:=NulVertex4D;
  MajorAxis:=VectorTransform3D(PGDBObjEllipse(p)^.MajorAxis,t_matrix^);
  PzeVector4d(@t_matrix.mtr.v[3])^:=tv;
  ReCalcFromObjMatrix;
end;

procedure GDBObjEllipse.transform;
var
  tv2:TzeVector4d;
begin
  inherited;
  tv2:=PzeVector4d(@t_matrix.mtr.v[3])^;
  PzeVector4d(@t_matrix.mtr.v[3])^:=NulVertex4D;
  MajorAxis:=VectorTransform3D(MajorAxis,t_matrix);
  PzeVector4d(@t_matrix.mtr.v[3])^:=tv2;
  ReCalcFromObjMatrix;
end;

procedure GDBObjEllipse.ReCalcFromObjMatrix;
begin
  inherited;
  Local.P_insert:=PzePoint3d(@objmatrix.mtr.v[3])^;
end;

function GDBObjEllipse.CalcObjMatrixWithoutOwner;
var
  rotmatr,dispmatr:TzeTypedMatrix4d;
begin
  Local.basis.ox:=MajorAxis;
  Local.basis.oy:=VectorDot(Local.basis.oz,Local.basis.ox);

  Local.basis.ox:=NormalizeVertex(Local.basis.ox);
  Local.basis.oy:=NormalizeVertex(Local.basis.oy);
  Local.basis.oz:=NormalizeVertex(Local.basis.oz);
  rotmatr:=CreateMatrixFromBasis(Local.basis.ox,Local.basis.oy,Local.basis.oz);
  dispmatr:=CreateTranslationMatrix(Local.p_insert);

  Result:=MatrixMultiply({dispmatr,}rotmatr,dispmatr);
end;

function GDBObjEllipse.CalcTrueInFrustum;
var
  i:integer;
begin
  for i:=0 to 5 do begin
    if (frustum.v[i].v[0]*P_insert_in_WCS.x+frustum.v[i].v[1]*
      P_insert_in_WCS.y+frustum.v[i].v[2]*P_insert_in_WCS.z+frustum.v[i].v[3]+rr<0)
    then begin
      Result:=IREmpty;
      exit;
    end;
  end;
  Result:=Vertex3D_in_WCS_Array.CalcTrueInFrustum(frustum,False);
end;

function GDBObjEllipse.calcinfrustum;
var
  i:integer;
begin
  Result:=True;
  for i:=0 to 4 do begin
    if (frustum.v[i].v[0]*outbound[0].x+frustum.v[i].v[1]*outbound[0].y+
      frustum.v[i].v[2]*outbound[0].z+frustum.v[i].v[3]<0)  and
      (frustum.v[i].v[0]*outbound[1].x+frustum.v[i].v[1]*outbound[1].y+
      frustum.v[i].v[2]*outbound[1].z+frustum.v[i].v[3]<0)  and
      (frustum.v[i].v[0]*outbound[2].x+frustum.v[i].v[1]*outbound[2].y+
      frustum.v[i].v[2]*outbound[2].z+frustum.v[i].v[3]<0)  and
      (frustum.v[i].v[0]*outbound[3].x+frustum.v[i].v[1]*outbound[3].y+
      frustum.v[i].v[2]*outbound[3].z+frustum.v[i].v[3]<0) then begin
      Result:=False;
      system.break;
    end;
  end;
end;

function GDBObjEllipse.GetObjTypeName;
begin
  Result:=ObjN_GDBObjEllipse;
end;

destructor GDBObjEllipse.done;
begin
  inherited done;
  Vertex3D_in_WCS_Array.Done;
end;

constructor GDBObjEllipse.initnul;
begin
  startangle:=0;
  endangle:=2*pi;
  majoraxis:=onevertex;
  inherited initnul(nil);
  Vertex3D_in_WCS_Array.init(4);
end;

constructor GDBObjEllipse.init;
begin
  inherited init(own,layeraddres,lw);
  Local.p_insert:=p;
  startangle:=s;
  endangle:=e;
  majoraxis:=majaxis;
  Vertex3D_in_WCS_Array.init(4);
end;

function GDBObjEllipse.GetObjType;
begin
  Result:=GDBEllipseID;
end;

procedure GDBObjEllipse.CalcObjMatrix;
var
  m1:TzeTypedMatrix4d;
  v:TzeVector4d;
  l:double;
begin
  inherited CalcObjMatrix;
  l:=onevertexlength(majoraxis);
  m1:=CreateScaleMatrix(l,ratio*l,1);
  objmatrix:=matrixmultiply(m1,objmatrix);
  PzePoint3d(@v)^:=local.p_insert;
  v.z:=0;
  v.w:=1;
  m1:=objMatrix;
  MatrixInvert(m1);
  v:=VectorTransform(v,m1);
end;

procedure GDBObjEllipse.FormatEntity(var drawing:TDrawingDef;
  var DC:TDrawContext;Stage:TEFStages=EFAllStages);
var
  v:TzeVector4d;
begin
  if assigned(EntExtensions) then
    EntExtensions.RunOnBeforeEntityFormat(@self,drawing,DC);

  if self.Ratio<=1 then
    rr:=uzegeometry.oneVertexlength(majoraxis)
  else
    rr:=uzegeometry.oneVertexlength(majoraxis)*ratio;

  calcObjMatrix;
  angle:=endangle-startangle;
  if angle<0 then
    angle:=2*pi+angle;
  length:=abs(angle)*rr;
  //---------------------------------------------------------------
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

  calcbb(dc);
  createpoint;
  CalcActualVisible(dc.DrawingContext.VActuality);
  if assigned(EntExtensions) then
    EntExtensions.RunOnAfterEntityFormat(@self,drawing,DC);
end;

procedure GDBObjEllipse.getoutbound;
var
  t,b,l,rrr,n,f:double;
  i:integer;
begin
  outbound[0]:=VectorTransform3d(CreateVertex(-1,1,0),objMatrix);
  outbound[1]:=VectorTransform3d(CreateVertex(1,1,0),objMatrix);
  outbound[2]:=VectorTransform3d(CreateVertex(1,-1,0),objMatrix);
  outbound[3]:=VectorTransform3d(CreateVertex(-1,-1,0),objMatrix);
  l:=outbound[0].x;
  rrr:=outbound[0].x;
  t:=outbound[0].y;
  b:=outbound[0].y;
  n:=outbound[0].z;
  f:=outbound[0].z;
  for i:=1 to 3 do begin
    if outbound[i].x<l then
      l:=outbound[i].x;
    if outbound[i].x>rrr then
      rrr:=outbound[i].x;
    if outbound[i].y<b then
      b:=outbound[i].y;
    if outbound[i].y>t then
      t:=outbound[i].y;
    if outbound[i].z<n then
      n:=outbound[i].z;
    if outbound[i].z>f then
      f:=outbound[i].z;
  end;

  vp.BoundingBox.LBN:=CreateVertex(l,B,n);
  vp.BoundingBox.RTF:=CreateVertex(rrr,T,f);
end;

procedure GDBObjEllipse.createpoint;
var
  i:integer;
  v:TzePoint3d;
  pv:TzePoint3d;
begin
  angle:=endangle-startangle;
  if angle<0 then
    angle:=2*pi+angle;

  lod:=100;  { TODO : А кто лод считать будет? }
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

procedure GDBObjEllipse.DrawGeometry;
begin
  DC.drawer.DrawContour3DInModelSpace(Vertex3D_in_WCS_Array,
    DC.DrawingContext.matrixs,False);
  inherited;
end;

procedure GDBObjEllipse.projectpoint;
begin

end;

procedure GDBObjEllipse.SaveToDXF;
begin
  SaveToDXFObjPrefix(outStream,'ELLIPSE','AcDbEllipse',IODXFContext);
  dxfvertexout(outStream,10,Local.p_insert);
  dxfvertexout(outStream,11,majoraxis);
  SaveToDXFObjPostfix(outStream);
  dxfDoubleout(outStream,40,ratio);
  dxfDoubleout(outStream,41,startangle);
  dxfDoubleout(outStream,42,endangle);
end;

procedure GDBObjEllipse.LoadFromDXF;
var
  byt:integer;
begin
  byt:=rdr.ParseInteger;
  while byt<>0 do begin
    if not LoadFromDXFObjShared(rdr,byt,ptu,drawing,context) then
      if not dxfLoadGroupCodeVertex(rdr,10,byt,Local.P_insert) then
        if not dxfLoadGroupCodeVertex(rdr,11,byt,MajorAxis) then
          if not dxfLoadGroupCodeDouble(rdr,40,byt,ratio) then
            if not dxfLoadGroupCodeDouble(rdr,41,byt,startangle) then
              if not dxfLoadGroupCodeDouble(rdr,42,byt,endangle) then
                rdr.SkipString;
    byt:=rdr.ParseInteger;
  end;
  startangle:=startangle;
  endangle:=endangle;
end;

function GDBObjEllipse.onmouse;
var
  i:integer;
begin
  for i:=0 to 5 do begin
    if (mf.v[i].v[0]*P_insert_in_WCS.x+mf.v[i].v[1]*P_insert_in_WCS.y+
        mf.v[i].v[2]*P_insert_in_WCS.z+mf.v[i].v[3]+RR<0) then begin
      Result:=False;
      exit;
    end;
  end;
  Result:=Vertex3D_in_WCS_Array.onmouse(mf,False);
end;

procedure GDBObjEllipse.remaponecontrolpoint(pdesc:pcontrolpointdesc;
  ProjectProc:GDBProjectProc);
var
  tv:TzePoint3d;
begin
  if pdesc^.pointtype=os_begin then begin
    pdesc.worldcoord:=q0;
    ProjectProc(pdesc.worldcoord,tv);
    pdesc.dispcoord:=ToTzePoint2i(tv);
  end else if pdesc^.pointtype=os_midle then begin
    pdesc.worldcoord:=q1;
    ProjectProc(pdesc.worldcoord,tv);
    pdesc.dispcoord:=ToTzePoint2i(tv);
  end else if pdesc^.pointtype=os_end then begin
    pdesc.worldcoord:=q2;
    ProjectProc(pdesc.worldcoord,tv);
    pdesc.dispcoord:=ToTzePoint2i(tv);
  end;
end;

procedure GDBObjEllipse.addcontrolpoints(tdesc:Pointer);
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

function GDBObjEllipse.getsnap;
begin
  if onlygetsnapcount=3 then begin
    Result:=False;
    exit;
  end;
  Result:=True;
  case onlygetsnapcount of
    0:begin
      if (SnapMode and osm_endpoint)<>0 then begin
        osp.worldcoord:=q0;
        ProjectProc(osp.worldcoord,osp.dispcoord);
        osp.ostype:=os_begin;
      end else
        osp.ostype:=os_none;
    end;
    1:begin
      if (SnapMode and osm_midpoint)<>0 then begin
        osp.worldcoord:=q1;
        ProjectProc(osp.worldcoord,osp.dispcoord);
        osp.ostype:=os_midle;
      end else
        osp.ostype:=os_none;
    end;
    2:begin
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

function GDBObjEllipse.beforertmodify;
begin
  Getmem(Result,sizeof(tellipsertmodify));
  tellipsertmodify(Result^).p1.x:=q0.x;
  tellipsertmodify(Result^).p1.y:=q0.y;
  tellipsertmodify(Result^).p2.x:=q1.x;
  tellipsertmodify(Result^).p2.y:=q1.y;
  tellipsertmodify(Result^).p3.x:=q2.x;
  tellipsertmodify(Result^).p3.y:=q2.y;
end;

function GDBObjEllipse.IsRTNeedModify(const Point:PControlPointDesc;p:Pointer):boolean;
begin
  Result:=True;
end;

procedure GDBObjEllipse.rtmodifyonepoint(const rtmod:TRTModifyData);
var
  a,b,c,d,e,f,g,p_x,p_y,rrr:double;
  tv:TzePoint2d;
  ptdata:tellipsertmodify;
begin
  ptdata.p1.x:=q0.x;
  ptdata.p1.y:=q0.y;
  ptdata.p2.x:=q1.x;
  ptdata.p2.y:=q1.y;
  ptdata.p3.x:=q2.x;
  ptdata.p3.y:=q2.y;

  if rtmod.point.pointtype=os_begin then begin
    ptdata.p1.x:=q0.x+rtmod.dist.x;
    ptdata.p1.y:=q0.y+rtmod.dist.y;
  end else if rtmod.point.pointtype=os_midle then begin
    ptdata.p2.x:=q1.x+rtmod.dist.x;
    ptdata.p2.y:=q1.y+rtmod.dist.y;
  end else if rtmod.point.pointtype=os_end then begin
    ptdata.p3.x:=q2.x+rtmod.dist.x;
    ptdata.p3.y:=q2.y+rtmod.dist.y;
  end;
  A:=ptdata.p2.x-ptdata.p1.x;
  B:=ptdata.p2.y-ptdata.p1.y;
  C:=ptdata.p3.x-ptdata.p1.x;
  D:=ptdata.p3.y-ptdata.p1.y;

  E:=A*(ptdata.p1.x+ptdata.p2.x)+B*(ptdata.p1.y+ptdata.p2.y);
  F:=C*(ptdata.p1.x+ptdata.p3.x)+D*(ptdata.p1.y+ptdata.p3.y);

  G:=2*(A*(ptdata.p3.y-ptdata.p2.y)-B*(ptdata.p3.x-ptdata.p2.x));
  if abs(g)>eps then begin
    p_x:=(D*E-B*F)/G;
    p_y:=(A*F-C*E)/G;
    rrr:=sqrt(sqr(ptdata.p1.x-p_x)+sqr(ptdata.p1.y-p_y));
    rr:=rrr;
    Local.p_insert.x:=p_x;
    Local.p_insert.y:=p_y;
    Local.p_insert.z:=0;
    tv.x:=p_x;
    tv.y:=p_y;
    startangle:=vertexangle(tv,ptdata.p1);
    endangle:=vertexangle(tv,ptdata.p3);
    if startangle>endangle then begin
      rrr:=
        startangle;
      startangle:=
        endangle;
      endangle:=rrr;
    end;
    rrr:=vertexangle(tv,ptdata.p2);
    if (rrr>startangle) and (rrr<endangle) then begin
    end
    else begin
      rrr:=
        startangle;
      startangle:=
        endangle;
      endangle:=rrr;
    end;
  end;

end;

function GDBObjEllipse.Clone;
var
  tvo:PGDBObjEllipse;
begin
  Getmem(Pointer(tvo),sizeof(GDBObjEllipse));
  tvo^.init(CalcOwner(own),vp.Layer,vp.LineWeight,Local.p_insert,
    {r,}startangle,endangle,majoraxis);
  CopyVPto(tvo^);
  CopyExtensionsTo(tvo^);
  tvo^.Local:=local;
  tvo^.RR:=RR;
  tvo^.MajorAxis:=MajorAxis;
  tvo^.Ratio:=Ratio;
  Result:=tvo;
end;

procedure GDBObjEllipse.rtsave;
begin
  PGDBObjEllipse(refp)^.Local.p_insert:=Local.p_insert;
  PGDBObjEllipse(refp)^.startangle:=startangle;
  PGDBObjEllipse(refp)^.endangle:=endangle;
  PGDBObjEllipse(refp)^.RR:=RR;
  PGDBObjEllipse(refp)^.MajorAxis:=MajorAxis;
  PGDBObjEllipse(refp)^.Ratio:=Ratio;
end;

function AllocEllipse:PGDBObjEllipse;
begin
  Getmem(Result,sizeof(GDBObjEllipse));
end;

function AllocAndInitEllipse(owner:PGDBObjGenericWithSubordinated):PGDBObjEllipse;
begin
  Result:=AllocEllipse;
  Result.initnul;
  Result.bp.ListPos.Owner:=owner;
end;

function GDBObjEllipse.CreateInstance:PGDBObjEllipse;
begin
  Result:=AllocAndInitEllipse(nil);
end;

begin
  RegisterDXFEntity(GDBEllipseID,'ELLIPSE','Ellipse',@AllocEllipse,@AllocAndInitEllipse);
end.
