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
unit uzeentline;
{$Mode delphi}{$H+}
{$INCLUDE zengineconfig.inc}

interface

uses
  uzbLogIntf,uzeentityfactory,uzgldrawcontext,uzedrawingdef,uzecamera,
  uzestyleslayers,uzeentsubordinated,UGDBSelectedObjArray,uzeent3d,uzeentity,
  uzctnrVectorBytesStream,uzeTypes,uzeconsts,uzegeometrytypes,
  uzglviewareadata,uzegeometry,uzeffdxfsupport,uzeSnap,uzMVReader,
  uzCtnrVectorpBaseEntity;

type
  PGDBObjLine=^GDBObjLine;

  GDBObjLine=object(GDBObj3d)
    private
    fCoordInWCS:GDBLineProp;
    public
    CoordInOCS:GDBLineProp;

    constructor init(own:Pointer;layeraddres:PGDBLayerProp;
      LW:smallint;p1,p2:TzePoint3d);
    constructor initnul(owner:PGDBObjGenericWithSubordinated);
    procedure LoadFromDXF(var rdr:TZMemReader;ptu:PExtensionData;
      var drawing:TDrawingDef;var context:TIODXFLoadContext);virtual;

    procedure SaveToDXF(var outStream:TZctnrVectorBytes;
      var drawing:TDrawingDef;var IODXFContext:TIODXFSaveContext);virtual;
    function IsStagedFormatEntity:boolean;virtual;
    procedure FormatEntity(var drawing:TDrawingDef;
      var DC:TDrawContext;Stage:TEFStages=EFAllStages);virtual;
    procedure CalcGeometry;virtual;
    procedure DrawGeometry(lw:integer;var DC:TDrawContext;
      const inFrustumState:TInBoundingVolume);virtual;
    function Clone(own:Pointer):PGDBObjEntity;virtual;
    procedure rtsave(refp:Pointer);virtual;
    procedure TransformAt(p:PGDBObjEntity;t_matrix:PzeTypedMatrix4d);virtual;
    function onmouse(var popa:TZctnrVectorPGDBaseEntity;
      const MF:TzeFrustum;InSubEntry:boolean):boolean;virtual;
    function onpoint(var objects:TZctnrVectorPGDBaseEntity;
      const point:TzePoint3d):boolean;virtual;
    function getsnap(var osp:os_record;var pdata:Pointer;
      const param:OGLWndtype;ProjectProc:GDBProjectProc;SnapMode:TGDBOSMode):boolean;virtual;
    function getintersect(var osp:os_record;pobj:PGDBObjEntity;
      const param:OGLWndtype;ProjectProc:GDBProjectProc;SnapMode:TGDBOSMode):boolean;virtual;
    procedure addcontrolpoints(tdesc:Pointer);virtual;
    function beforertmodify:Pointer;virtual;
    procedure clearrtmodify(p:Pointer);virtual;
    procedure rtmodifyonepoint(const rtmod:TRTModifyData);virtual;
    function IsRTNeedModify(const Point:PControlPointDesc;
      p:Pointer):boolean;virtual;
    procedure remaponecontrolpoint(pdesc:pcontrolpointdesc;
      ProjectProc:GDBProjectProc);virtual;
    procedure transform(const t_matrix:TzeTypedMatrix4d);virtual;
    function jointoline(pl:pgdbobjline;
      var drawing:TDrawingDef):boolean;virtual;

    function ObjToString(const prefix,sufix:string):string;virtual;
    function GetObjTypeName:string;virtual;
    function GetCenterPoint:TzePoint3d;virtual;
    procedure getoutbound(var DC:TDrawContext);virtual;
    function CalcInFrustum(const frustum:TzeFrustum;
      const Actuality:TVisActuality;var Counters:TCameraCounters;ProjectProc:GDBProjectProc;
      const zoom,currentdegradationfactor:double):boolean;virtual;
    function CalcTrueInFrustum(
      const frustum:TzeFrustum):TInBoundingVolume;virtual;

    function IsIntersect_Line(lbegin,lend:TzePoint3d):Intercept3DProp;
      virtual;
    procedure AddOnTrackAxis(var posr:os_record;
      const processaxis:taddotrac);virtual;
    function GetTangentInPoint(const point:TzePoint3d):TzePoint3d;virtual;

    class function CreateInstance:PGDBObjLine;static;
    function GetObjType:TObjID;virtual;

    function getCoordInWCS:GDBLineProp;

     property CoordInWCS:GDBLineProp
      read fCoordInWCS write fCoordInWCS;
  end;
  ptlinertmodify=^tlinertmodify;

  tlinertmodify=record
    lbegin,lmidle,lend:boolean;
  end;

function AllocAndInitLine(owner:PGDBObjGenericWithSubordinated):PGDBObjLine;

implementation

function GDBObjLine.GetTangentInPoint(const point:TzePoint3d):TzePoint3d;
begin
  Result:=normalizevertex(VertexSub(CoordInWCS.lEnd,CoordInWCS.lBegin));
end;

procedure GDBObjLine.AddOnTrackAxis(var posr:os_record;const processaxis:taddotrac);
var
  tv,dir:TzePoint3d;
begin
  dir:=VertexSub(CoordInWCS.lEnd,CoordInWCS.lBegin);
  processaxis(posr,dir);
  tv:=uzegeometry.vectordot(dir,zwcs);
  processaxis(posr,tv);
end;

function GDBObjLine.IsIntersect_Line(lbegin,lend:TzePoint3d):Intercept3DProp;
begin
  Result:=intercept3d(lbegin,lend,CoordInWCS.lBegin,CoordInWCS.lEnd);
end;

procedure GDBObjLine.getoutbound;
begin
  vp.BoundingBox:=CreateBBFrom2Point(CoordInWCS.lBegin,CoordInWCS.lEnd);
end;

function GDBObjLine.GetCenterPoint;
begin
  Result:=Vertexmorph(CoordInWCS.lbegin,CoordInWCS.lend,0.5);
end;

function GDBObjLine.GetObjTypeName;
begin
  Result:=ObjN_GDBObjLine;
end;

function GDBObjLine.jointoline(pl:pgdbobjline;var drawing:TDrawingDef):boolean;

  function online(w,u:TzePoint3d):boolean;
  var
    ww:double;
    l:double;
  begin
    ww:=scalardot(w,u);
    l:=SqrOneVertexlength(VertexSub(w,VertexMulOnSc(u,ww)));
    if eps>l then
      Result:=True
    else
      Result:=False;
  end;

var
  t1,t2,a1,a2:double;
  q:boolean;
  w,u,dir:TzePoint3d;
  dc:TDrawContext;
begin
  Result:=False;
  if Vertexlength(CoordInWCS.lbegin,CoordInWCS.lend)<Vertexlength(
    pl^.CoordInWCS.lbegin,pl^.CoordInWCS.lend) then begin
    Result:=pl^.jointoline(@self,drawing);
    exit;
  end;
  dir:=VertexSub(CoordInWCS.lEnd,CoordInWCS.lBegin);
  u:=NormalizeVertex(dir);
  w:=VertexSub(pl.CoordInWCS.lbegin,CoordInWCS.lbegin);
  t1:=(scalardot(w,dir))/SqrOneVertexlength(dir);
  q:=online(w,u);
  w:=VertexSub(pl.CoordInWCS.lend,CoordInWCS.lbegin);
  t2:=(scalardot(w,dir))/SqrOneVertexlength(dir);
  q:=q and online(w,u);
  if not q then
    exit;
  a1:=0;
  a2:=1;
  if t1<a1 then
    a1:=t1;
  if t2<a1 then
    a1:=t2;
  if t1>a2 then
    a2:=t1;
  if t2>a2 then
    a2:=t2;
  self.CoordInOCS.lend:=VertexDmorph(self.CoordInOCS.lbegin,dir,a2);
  self.CoordInOCS.lbegin:=VertexDmorph(self.CoordInOCS.lbegin,dir,a1);
  dc:=drawing.CreateDrawingRC;
  FormatEntity(drawing,dc);
  pl^.YouDeleted(drawing);
  Result:=True;
end;

function GDBObjLine.ObjToString(const prefix,sufix:string):string;
begin
  Result:=prefix+inherited ObjToString('GDBObjLine (addr:',')')+sufix;
end;

constructor GDBObjLine.initnul;
begin
  inherited initnul(owner);
  bp.ListPos.Owner:=owner;
  CoordInOCS.lBegin:=NulVertex;
  CoordInOCS.lEnd:=NulVertex;
end;

constructor GDBObjLine.init;
begin
  inherited init(own,layeraddres,lw);
  CoordInOCS.lBegin:=p1;
  CoordInOCS.lEnd:=p2;
end;

function GDBObjLine.GetObjType;
begin
  Result:=GDBlineID;
end;

procedure GDBObjLine.LoadFromDXF;
var
  byt:integer;
begin
  byt:=rdr.ParseInteger;
  while byt<>0 do begin
    if not LoadFromDXFObjShared(rdr,byt,ptu,drawing,context) then
      if not dxfLoadGroupCodeVertex(rdr,10,byt,CoordInOCS.lBegin) then
        if not dxfLoadGroupCodeVertex(rdr,11,byt,CoordInOCS.lEnd) then
          {s := }rdr.SkipString;
    byt:=rdr.ParseInteger;
  end;
end;

function GDBObjLine.getCoordInWCS:GDBLineProp;
var
  m:TzeTypedMatrix4d;
begin
  if bp.ListPos.owner<>nil then begin
    if bp.ListPos.owner^.GetHandle=H_Root then begin
      Result.lbegin:=CoordInOCS.lbegin;
      Result.lend:=CoordInOCS.lend;
    end else begin
      m:=bp.ListPos.owner^.GetMatrix^;
      Result.lbegin:=VectorTransform3D(CoordInOCS.lbegin,m);
      Result.lend:=VectorTransform3D(CoordInOCS.lend,m);
    end;
  end else begin
    Result.lbegin:=CoordInOCS.lbegin;
    Result.lend:=CoordInOCS.lend;
  end;
end;

procedure GDBObjLine.CalcGeometry;
var
  m:TzeTypedMatrix4d;
  tlp:GDBLineProp;
begin
  if bp.ListPos.owner<>nil then begin
    if bp.ListPos.owner^.GetHandle=H_Root then begin
      CoordInWCS:=CoordInOCS;
    end else begin
      m:=bp.ListPos.owner^.GetMatrix^;

      tlp.lbegin:=VectorTransform3D(CoordInOCS.lbegin,m);
      tlp.lend:=VectorTransform3D(CoordInOCS.lend,m);
      CoordInWCS:=tlp;
    end;
  end else begin
    CoordInWCS:=CoordInOCS;
  end;
end;

function GDBObjLine.IsStagedFormatEntity:boolean;
begin
  Result:=True;
end;

procedure GDBObjLine.FormatEntity(var drawing:TDrawingDef;
  var DC:TDrawContext;Stage:TEFStages=EFAllStages);
begin
  if EFCalcEntityCS in stage then begin
    if assigned(EntExtensions) then
      EntExtensions.RunOnBeforeEntityFormat(@self,drawing,DC);

    calcgeometry;
    calcbb(dc);
  end;
  CalcActualVisible(dc.DrawingContext.VActuality);
  if EFDraw in stage then begin
    if (not (ESTemp in State))and(DCODrawable in DC.Options) then begin
      Representation.Clear;
      if assigned(EntExtensions) then begin
        if EntExtensions.NeedStandardDraw(@self,drawing,DC) then
          Representation.DrawLineByConstRefLinePropWithLT(
            self,getmatrix^,dc,CoordInOCS,vp,True);
      end else
        Representation.DrawLineByConstRefLinePropWithLT(
          self,getmatrix^,dc,CoordInOCS,vp,True);
    end;
    Representation.Shrink;
    if assigned(EntExtensions) then
      EntExtensions.RunOnAfterEntityFormat(@self,drawing,DC);
  end;
end;

function GDBObjLine.CalcInFrustum;
var
  i:integer;
begin
  if CalcAABBInFrustum(vp.BoundingBox,frustum)<>IREmpty then
    Result:=
      True
  else
    Result:=
      False;
  exit;
  Result:=True;
  for i:=0 to 5 do begin
    if (frustum.v[i].v[0]*CoordInWCS.lbegin.x+frustum.v[i].v[1]*
      CoordInWCS.lbegin.y+frustum.v[i].v[2]*CoordInWCS.lbegin.z+
      frustum.v[i].v[3]<0)  and(frustum.v[i].v[0]*CoordInWCS.lend.x+
      frustum.v[i].v[1]*CoordInWCS.lend.y+frustum.v[i].v[2]*
      CoordInWCS.lend.z+frustum.v[i].v[3]<0) then begin
      Result:=False;
      system.break;
    end;
  end;
end;

function GDBObjLine.CalcTrueInFrustum;
begin
  Result:=Representation.CalcTrueInFrustum(frustum,True);
end;

function GDBObjLine.onpoint(var objects:TZctnrVectorPGDBaseEntity;
  const point:TzePoint3d):boolean;
begin
  if SQRdist_Point_to_Segment(point,self.CoordInWCS.lBegin,self.CoordInWCS.lEnd)<
    bigeps then begin
    Result:=
      True;
    objects.
      PushBackData(@self);
  end else
    Result:=
      False;
end;

function GDBObjLine.onmouse;
begin
  if Representation.CalcTrueInFrustum(mf,False)<>IREmpty
  then
    Result:=True
  else
    Result:=False;
end;

procedure GDBObjLine.DrawGeometry;
begin
  Representation.DrawGeometry(DC,VP.BoundingBox,inFrustumState);
end;

function GDBObjLine.getsnap;
var
  t,d,e:double;
  tv,n,v,dir:TzePoint3d;
begin
  if onlygetsnapcount=9 then begin
    Result:=False;
    exit;
  end;
  Result:=True;
  dir:=VertexSub(CoordInWCS.lEnd,CoordInWCS.lBegin);
  case onlygetsnapcount of
    0:begin
      if (SnapMode and osm_endpoint)<>0 then begin
        osp.worldcoord:=CoordInWCS.lend;
        ProjectProc(osp.worldcoord,osp.dispcoord);
        osp.ostype:=os_end;
      end else
        osp.ostype:=os_none;
    end;
    1:begin
      if (SnapMode and osm_4)<>0 then begin
        osp.worldcoord:=Vertexmorph(CoordInWCS.lbegin,CoordInWCS.lend,1/4);
        ProjectProc(osp.worldcoord,osp.dispcoord);
        osp.ostype:=os_1_4;
      end else
        osp.ostype:=os_none;
    end;
    2:begin
      if (SnapMode and osm_3)<>0 then begin
        osp.worldcoord:=Vertexmorph(CoordInWCS.lbegin,CoordInWCS.lend,1/3);
        ProjectProc(osp.worldcoord,osp.dispcoord);
        osp.ostype:=os_1_3;
      end else
        osp.ostype:=os_none;
    end;
    3:begin
      if (SnapMode and osm_midpoint)<>0 then begin
        osp.worldcoord:=Vertexmorph(CoordInWCS.lbegin,CoordInWCS.lend,1/2);
        ProjectProc(osp.worldcoord,osp.dispcoord);
        osp.ostype:=os_midle;
      end else
        osp.ostype:=os_none;
    end;
    4:begin
      if (SnapMode and osm_3)<>0 then begin
        osp.worldcoord:=Vertexmorph(CoordInWCS.lbegin,CoordInWCS.lend,2/3);
        ProjectProc(osp.worldcoord,osp.dispcoord);
        osp.ostype:=os_2_3;
      end else
        osp.ostype:=os_none;
    end;
    5:begin
      if (SnapMode and osm_4)<>0 then begin
        osp.worldcoord:=Vertexmorph(CoordInWCS.lbegin,CoordInWCS.lend,3/4);
        ProjectProc(osp.worldcoord,osp.dispcoord);
        osp.ostype:=os_3_4;
      end else
        osp.ostype:=os_none;
    end;
    6:begin
      if (SnapMode and osm_endpoint)<>0 then begin
        osp.worldcoord:=CoordInWCS.lbegin;
        ProjectProc(osp.worldcoord,osp.dispcoord);
        osp.ostype:=os_begin;
      end else
        osp.ostype:=os_none;
    end;
    7:begin
      if (SnapMode and osm_perpendicular)<>0 then begin
        tv:=vectordot(dir,param.md.mouseray.dir);
        t:=-((CoordInWCS.lbegin.x-param.lastpoint.x)*dir.x+
          (CoordInWCS.lbegin.y-param.lastpoint.y)*dir.y+
          (CoordInWCS.lbegin.z-param.lastpoint.z)*dir.z)/
          (SqrVertexlength(self.CoordInWCS.lBegin,self.CoordInWCS.lEnd));
        if (t>=0) and (t<=1) then begin
          osp.worldcoord.x:=CoordInWCS.lbegin.x+t*dir.x;
          osp.worldcoord.y:=CoordInWCS.lbegin.y+t*dir.y;
          osp.worldcoord.z:=CoordInWCS.lbegin.z+t*dir.z;
          ProjectProc(osp.worldcoord,tv);
          osp.dispcoord:=tv;
          osp.ostype:=os_perpendicular;
        end else
          osp.ostype:=os_none;
      end else
        osp.ostype:=os_none;
    end;
    8:begin
      if (SnapMode and osm_nearest)<>0 then begin
        tv:=vectordot(dir,param.md.mouseray.dir);
        n:=vectordot(param.md.mouseray.dir,tv);
        n:=NormalizeVertex(n);
        v.x:=param.md.mouseray.lbegin.x-CoordInWCS.lbegin.x;
        v.y:=param.md.mouseray.lbegin.y-CoordInWCS.lbegin.y;
        v.z:=param.md.mouseray.lbegin.z-CoordInWCS.lbegin.z;
        d:=scalardot(n,v);
        e:=scalardot(n,dir);
        if e<eps then
          osp.ostype:=os_none
        else begin
          if d<eps then
            osp.ostype:=os_none
          else begin
            t:=d/e;
            if (t>1)or(t<0) then
              osp.ostype:=os_none
            else begin
              osp.worldcoord.x:=CoordInWCS.lbegin.x+t*dir.x;
              osp.worldcoord.y:=CoordInWCS.lbegin.y+t*dir.y;
              osp.worldcoord.z:=CoordInWCS.lbegin.z+t*dir.z;
              ProjectProc(osp.worldcoord,tv);
              osp.dispcoord:=tv;
              osp.ostype:=os_nearest;
            end;
          end;

        end;
      end else
        osp.ostype:=os_none;
    end;
  end;
  Inc(onlygetsnapcount);
end;

function line2dintercep(var x11,y11,x12,y12,x21,y21,x22,y22:double;
  out t1,t2:double):boolean;
var
  d,d1,d2,dx1,dy1,dx2,dy2:double;
begin
  t1:=0;
  t2:=0;
  Result:=False;
  dy1:=(y12-y11);
  dx2:=(x21-x22);
  dy2:=(y21-y22);
  dx1:=(x12-x11);
  D:=dy1*dx2-dy2*dx1;
  if abs(d)>sqreps then begin
    D1:=(y12-y11)*(x21-x11)-(y21-y11)*(x12-x11);
    D2:=(y21-y11)*(x21-x22)-(y21-y22)*(x21-x11);
    t2:=D1/D;
    t1:=D2/D;
    if ((t1<=1) and (t1>=0) and (t2>=0) and (t2<=1)) then begin
      Result:=True;
    end;
  end;
end;

function GDBObjLine.getintersect;
var
  t1,t2,dist:double;
  l1b,l1e,l2b,l2e,tv1,tv2,dir,dir2:TzePoint3d;
begin
  if (onlygetsnapcount=1)or(pobj^.getobjtype<>gdblineid) then
    exit(False);

  Result:=True;
  ProjectProc(CoordInWCS.lbegin,l1b);
  ProjectProc(CoordInWCS.lEnd,l1e);
  ProjectProc(pgdbobjline(pobj)^.CoordInWCS.lbegin,l2b);
  ProjectProc(pgdbobjline(pobj)^.CoordInWCS.lEnd,l2e);

  case onlygetsnapcount of
    0:begin
      if ((SnapMode and osm_apparentintersection)<>0)or
        ((SnapMode and osm_intersection)<>0) then begin
        if line2dintercep(l1b.x,l1b.y,l1e.x,l1e.y,l2b.x,l2b.y,l2e.x,l2e.y,t1,t2) then
        begin
          dir:=VertexSub(CoordInWCS.lEnd,CoordInWCS.lBegin);
          dir2:=VertexSub(pgdbobjline(pobj)^.CoordInWCS.lEnd,pgdbobjline(
            pobj)^.CoordInWCS.lBegin);
          tv1.x:=CoordInWCS.lbegin.x+dir.x*t1;
          tv1.y:=CoordInWCS.lbegin.y+dir.y*t1;
          tv1.z:=CoordInWCS.lbegin.z+dir.z*t1;
          tv2.x:=pgdbobjline(pobj)^.CoordInWCS.lbegin.x+dir2.x*t2;
          tv2.y:=pgdbobjline(pobj)^.CoordInWCS.lbegin.y+dir2.y*t2;
          tv2.z:=pgdbobjline(pobj)^.CoordInWCS.lbegin.z+dir2.z*t2;
          dist:=Vertexlength(tv1,tv2);
          if dist<bigeps then begin
            if (SnapMode and osm_intersection)<>0 then begin
              osp.worldcoord:=tv1;
              ProjectProc(osp.worldcoord,osp.dispcoord);
              osp.ostype:=os_intersection;
            end else
              osp.ostype:=os_none;
          end else begin
            if (SnapMode and osm_apparentintersection)<>0 then begin
              osp.worldcoord:=tv1;
              line2dintercep(l1b.x,l1b.y,l1e.x,l1e.y,l2b.x,l2b.y,l2e.x,l2e.y,t1,t2);
              ProjectProc(osp.worldcoord,osp.dispcoord);
              osp.ostype:=os_apparentintersection;
            end else
              osp.ostype:=os_none;
          end;
        end;
      end else
        osp.ostype:=os_none;
    end;
  end;
  Inc(onlygetsnapcount);
end;

function GDBObjLine.Clone;
var
  tvo:PGDBObjLine;
begin
  Getmem(Pointer(tvo),sizeof(GDBObjLine));
  tvo^.init(bp.ListPos.owner,vp.Layer,vp.LineWeight,CoordInOCS.lBegin,
    CoordInOCS.lEnd);
  CopyVPto(tvo^);
  CopyExtensionsTo(tvo^);
  tvo^.CoordInOCS.lBegin.y:=tvo^.CoordInOCS.lBegin.y;
  tvo^.bp.ListPos.Owner:=own;
  Result:=tvo;
end;

procedure GDBObjLine.SaveToDXF;
begin
  SaveToDXFObjPrefix(outStream,dxfName_Line,dxfName_AcDbLine,IODXFContext);
  dxfvertexout(outStream,10,CoordInOCS.lbegin);
  dxfvertexout(outStream,11,CoordInOCS.lend);
end;

procedure GDBObjLine.rtsave;
begin
  pgdbobjline(refp)^.CoordInOCS.lBegin:=CoordInOCS.lbegin;
  pgdbobjline(refp)^.CoordInOCS.lEnd:=CoordInOCS.lend;
end;

procedure GDBObjLine.TransformAt;
begin
  CoordInOCS.lbegin:=uzegeometry.VectorTransform3D(
    pgdbobjline(p)^.CoordInOCS.lBegin,t_matrix^);
  CoordInOCS.lend:=VectorTransform3D(pgdbobjline(p)^.CoordInOCS.lend,t_matrix^);
end;

function GDBObjLine.beforertmodify;
begin
  Getmem(Result,sizeof(tlinertmodify));
  clearrtmodify(Result);
end;

procedure GDBObjLine.clearrtmodify(p:Pointer);
begin
  fillchar(p^,sizeof(tlinertmodify),0);
end;

function GDBObjLine.IsRTNeedModify(const Point:PControlPointDesc;p:Pointer):boolean;
begin
  Result:=False;
  if point.pointtype=os_begin then begin
    if not ptlinertmodify(p)^.lbegin then
      Result:=True;
    ptlinertmodify(p)^.lbegin:=True;
  end else if point.pointtype=os_end then begin
    if not ptlinertmodify(p)^.lend then
      Result:=True;
    ptlinertmodify(p)^.lend:=True;
  end else if point.pointtype=os_midle then begin
    if (not ptlinertmodify(p)^.lbegin)  and (not ptlinertmodify(p)^.lend) then
      Result:=True;
    ptlinertmodify(p)^.lbegin:=True;
    ptlinertmodify(p)^.lend:=True;
  end;

end;

procedure GDBObjLine.rtmodifyonepoint(const rtmod:TRTModifyData);
var
  tv,tv2:TzePoint3d;
begin
  if rtmod.point.pointtype=os_begin then begin
    CoordInOCS.lbegin:=VertexAdd(rtmod.point.worldcoord,rtmod.dist);
  end else if rtmod.point.pointtype=os_end then begin
    CoordInOCS.lend:=VertexAdd(rtmod.point.worldcoord,rtmod.dist);
  end else if rtmod.point.pointtype=os_midle then begin
    tv:=uzegeometry.VertexSub(CoordInOCS.lend,CoordInOCS.lbegin);
    tv:=uzegeometry.VertexMulOnSc(tv,0.5);
    tv2:=VertexAdd(rtmod.point.worldcoord,rtmod.dist);
    CoordInOCS.lbegin:=VertexSub(tv2,tv);
    CoordInOCS.lend:=VertexAdd(tv2,tv);
  end;
end;

procedure GDBObjLine.remaponecontrolpoint(pdesc:pcontrolpointdesc;
  ProjectProc:GDBProjectProc);
var
  tv:TzePoint3d;
begin
  if pdesc^.pointtype=os_begin then begin
    pdesc.worldcoord:=CoordInWCS.lbegin;
    ProjectProc(pdesc.worldcoord,tv);
    pdesc.dispcoord:=ToTzePoint2i(tv);
  end else if pdesc^.pointtype=os_end then begin
    pdesc.worldcoord:=CoordInWCS.lend;
    ProjectProc(pdesc.worldcoord,tv);
    pdesc.dispcoord:=ToTzePoint2i(tv);
  end else if pdesc^.pointtype=os_midle then begin
    pdesc.worldcoord:=Vertexmorph(CoordInWCS.lbegin,CoordInWCS.lend,1/2);
    ProjectProc(pdesc.worldcoord,tv);
    pdesc.dispcoord:=ToTzePoint2i(tv);
  end;
end;

procedure GDBObjLine.addcontrolpoints(tdesc:Pointer);
var
  pdesc:controlpointdesc;
begin
  PSelectedObjDesc(tdesc)^.pcontrolpoint^.init(3);

  pdesc.selected:=False;
  pdesc.PDrawable:=nil;

  pdesc.pointtype:=os_midle;
  pdesc.attr:=[];
  pdesc.worldcoord:=Vertexmorph(CoordInWCS.lbegin,CoordInWCS.lend,1/2);
  PSelectedObjDesc(tdesc)^.pcontrolpoint^.PushBackData(pdesc);

  pdesc.pointtype:=os_begin;
  pdesc.attr:=[CPA_Strech];
  pdesc.worldcoord:=CoordInWCS.lbegin;
  PSelectedObjDesc(tdesc)^.pcontrolpoint^.PushBackData(pdesc);

  pdesc.pointtype:=os_end;
  pdesc.attr:=[CPA_Strech];
  pdesc.worldcoord:=CoordInWCS.lend;
  PSelectedObjDesc(tdesc)^.pcontrolpoint^.PushBackData(pdesc);
end;

procedure GDBObjLine.transform;
var
  tv:TzeVector4d;
begin
  PzePoint3d(@tv)^:=CoordInOCS.lbegin;
  tv.w:=1;
  tv:=vectortransform(tv,t_matrix);
  CoordInOCS.lbegin:=PzePoint3d(@tv)^;

  PzePoint3d(@tv)^:=CoordInOCS.lend;
  tv.w:=1;
  tv:=vectortransform(tv,t_matrix);
  CoordInOCS.lend:=PzePoint3d(@tv)^;
end;

function AllocLine:PGDBObjLine;
begin
  Getmem(pointer(Result),sizeof(GDBObjLine));
end;

function AllocAndInitLine(owner:PGDBObjGenericWithSubordinated):PGDBObjLine;
begin
  Result:=AllocLine;
  Result.initnul(owner);
  Result.bp.ListPos.Owner:=owner;
end;

procedure SetLineGeomProps(Pline:PGDBObjLine;const args:array of const);
var
  counter:integer;
begin
  counter:=low(args);
  Pline.CoordInOCS.lBegin:=CreateVertexFromArray(counter,args);
  Pline.CoordInOCS.lEnd:=CreateVertexFromArray(counter,args);
end;

function AllocAndCreateLine(owner:PGDBObjGenericWithSubordinated;
  const args:array of const):PGDBObjLine;
begin
  Result:=AllocAndInitLine(owner);
  SetLineGeomProps(Result,args);
end;

class function GDBObjLine.CreateInstance:PGDBObjLine;
begin
  Result:=AllocAndInitLine(nil);
end;

begin
  RegisterDXFEntity(GDBlineID,'LINE','Line',@AllocLine,@AllocAndInitLine,@SetLineGeomProps,@AllocAndCreateLine);
end.
