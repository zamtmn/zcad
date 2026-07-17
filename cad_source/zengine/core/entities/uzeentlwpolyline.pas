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
unit uzeentlwpolyline;
{$PointerMath ON}
{$Mode delphi}{$H+}
{$INCLUDE zengineconfig.inc}

interface

uses
  gzctnrVector,uzeentityfactory,uzeentsubordinated,uzgldrawcontext,
  uzedrawingdef,uzecamera,uzglviewareadata,uzeentcurve,UGDBVectorSnapArray,
  uzegeometry,uzestyleslayers,uzeentity,UGDBPoint3DArray,UGDBPolyLine2DArray,
  uzctnrVectorBytesStream,uzeTypes,uzeentwithlocalcs,uzeconsts,Math,
  gzctnrVectorTypes,uzegeometrytypes,uzeffdxfsupport,SysUtils,
  UGDBSelectedObjArray,uzMVReader,uzCtnrVectorpBaseEntity;

const
  CDefaultPolySegmentWidth:TGenSegmentParams=(
  startw:0;
  endw:0;
  hw:false;
  bulge:0;
  );

type

  TSegmentsParams=GZVector<TSegmentParams>;
  TWidth3D_in_WCS_Vector=GZVector<GDBQuad3d>;

  PGDBObjLWPolyline=^GDBObjLWpolyline;

  GDBObjLWPolyline=object(GDBObjWithLocalCS)
    Vertex2D_in_OCS_Array:GDBpolyline2DArray;
    SgmntsParams:TSegmentsParams;

    Vertex3D_in_WCS_Array:GDBPoint3dArray;
    Width3D_in_WCS_Array:TWidth3D_in_WCS_Vector;
    Closed:boolean;
    Plinegen:boolean;
    constructor init(own:Pointer;layeraddres:PGDBLayerProp;LW:smallint;c:boolean);
    constructor initnul;
    procedure LoadFromDXF(var rdr:TZMemReader;ptu:PExtensionData;var drawing:TDrawingDef;
      var context:TIODXFLoadContext);virtual;

    procedure SaveToDXF(var outStream:TZctnrVectorBytes;var drawing:TDrawingDef;
      var IODXFContext:TIODXFSaveContext);virtual;
    procedure DrawGeometry(lw:integer;var DC:TDrawContext;const inFrustumState:TInBoundingVolume);virtual;
    function IsStagedFormatEntity:boolean;virtual;
    procedure FormatEntity(var drawing:TDrawingDef;var DC:TDrawContext;Stage:TEFStages=EFAllStages);virtual;
    function CalcSquare:double;virtual;
    //**попадаетли данная координата внутрь контура
    function isPointInside(const point:TzePoint3d):boolean;virtual;
    procedure createpoint;virtual;
    procedure CalcWidthSegments;virtual;
    procedure CalcWidthSegment(var p1,p2:TzePoint2d;var plw:TSegmentParams);
    destructor done;virtual;
    function GetObjTypeName:string;virtual;
    function Clone(own:Pointer):PGDBObjEntity;virtual;
    procedure addcontrolpoints(tdesc:Pointer);virtual;
    procedure remaponecontrolpoint(pdesc:pcontrolpointdesc;ProjectProc:GDBProjectProc);virtual;
    procedure rtmodifyonepoint(const rtmod:TRTModifyData);virtual;
    procedure rtsave(refp:Pointer);virtual;
    procedure getoutbound(var DC:TDrawContext);virtual;
    function CalcTrueInFrustum(const frustum:TzeFrustum):TInBoundingVolume;virtual;
    function onmouse(var popa:TZctnrVectorPGDBaseEntity;const MF:TzeFrustum;InSubEntry:boolean):boolean;virtual;
    function onpoint(var objects:TZctnrVectorPGDBaseEntity;const point:TzePoint3d):boolean;virtual;
    function getsnap(var osp:os_record;var pdata:Pointer;const param:OGLWndtype;
      ProjectProc:GDBProjectProc;SnapMode:TGDBOSMode):boolean;virtual;
    procedure startsnap(out osp:os_record;out pdata:Pointer);virtual;
    procedure endsnap(out osp:os_record;var pdata:Pointer);virtual;
    procedure AddOnTrackAxis(var posr:os_record;const processaxis:taddotrac);virtual;
    procedure transform(const t_matrix:TzeTypedMatrix4d);virtual;
    procedure TransformAt(p:PGDBObjEntity;t_matrix:PzeTypedMatrix4d);virtual;
    function GetTangentInPoint(const point:TzePoint3d):TzePoint3d;virtual;
    procedure higlight(var DC:TDrawContext);virtual;
    class function CreateInstance:PGDBObjLWPolyline;static;
    function GetObjType:TObjID;virtual;
    property Square:double read CalcSquare;
  end;

function AllocAndInitLWpolyline(owner:PGDBObjGenericWithSubordinated):PGDBObjLWPolyline;

implementation

var
  lwtv:GDBpolyline2DArray;

procedure GDBObjLWpolyline.higlight(var DC:TDrawContext);
begin
end;

function GDBObjLWpolyline.GetTangentInPoint(const point:TzePoint3d):TzePoint3d;
var
  ptv,ppredtv:PzePoint3d;
  ir:itrec;
  found:integer;
begin
  if not closed then begin
    ppredtv:=Vertex3D_in_WCS_Array.beginiterate(ir);
    ptv:=Vertex3D_in_WCS_Array.iterate(ir);
  end else begin
    if Vertex3D_in_WCS_Array.Count<3 then
      exit;
    ptv:=Vertex3D_in_WCS_Array.beginiterate(ir);
    ppredtv:=
      Vertex3D_in_WCS_Array.getDataMutable(Vertex3D_in_WCS_Array.Count-1);
  end;
  found:=0;
  if (ptv<>nil)and(ppredtv<>nil) then
    repeat
      if (abs(ptv^.x-point.x)<eps)  and (abs(ptv^.y-point.y)<eps)  and
        (abs(ptv^.z-point.z)<eps) then begin
        found:=2;
      end
      else if (found=0)and(SQRdist_Point_to_Segment(point,ppredtv^,ptv^)<bigeps) then begin
        found:=1;
      end;

      if found>0 then begin
        Result:=vertexsub(ptv^,ppredtv^);
        Result.Normalize;
        exit;
        Dec(found);
      end;

      ppredtv:=ptv;
      ptv:=Vertex3D_in_WCS_Array.iterate(ir);
    until ptv=nil;
end;

procedure GDBObjLWpolyline.TransformAt;
begin
  inherited;
  Vertex2D_in_OCS_Array.Clear;
  pGDBObjLWpolyline(p)^.Vertex2D_in_OCS_Array.copyto(Vertex2D_in_OCS_Array);
  Vertex2D_in_OCS_Array.transform(t_matrix^);
end;

procedure GDBObjLWpolyline.transform;
begin
  inherited;
  Vertex2D_in_OCS_Array.transform(t_matrix);
end;

procedure GDBObjLWpolyline.AddOnTrackAxis(var posr:os_record;
  const processaxis:taddotrac);
begin
  GDBPoint3dArrayAddOnTrackAxis(Vertex3D_in_WCS_Array,posr,processaxis,closed);
end;

procedure GDBObjLWpolyline.startsnap(out osp:os_record;out pdata:Pointer);
begin
  inherited;
  Getmem(pdata,sizeof(GDBVectorSnapArray));
  PGDBVectorSnapArray(pdata).init(Vertex3D_in_WCS_Array.Max);
  BuildSnapArray(Vertex3D_in_WCS_Array,PGDBVectorSnapArray(pdata)^,closed);
end;

procedure GDBObjLWpolyline.endsnap(out osp:os_record;var pdata:Pointer);
begin
  if pdata<>nil then begin
    PGDBVectorSnapArray(pdata)^.Done;
    Freemem(pdata);
  end;
  inherited;
end;

function GDBObjLWpolyline.getsnap;
begin
  Result:=GDBPoint3dArraygetsnapWOPProjPoint(Vertex3D_in_WCS_Array,
    {snaparray}PGDBVectorSnapArray(pdata)^,osp,closed,param,ProjectProc,snapmode);
end;

function GDBObjLWpolyline.onpoint(var objects:TZctnrVectorPGDBaseEntity;
  const point:TzePoint3d):boolean;
begin
  if Vertex3D_in_WCS_Array.onpoint(point,closed) then begin
    Result:=True;
    objects.PushBackData(@self);
  end else
    Result:=False;
end;

function GDBObjLWpolyline.onmouse;
var
  ie,i:integer;
  q3d:PGDBQuad3d;
  p3d,p3dold:PzePoint3d;
  subresult:TInBoundingVolume;
begin

  Result:=False;
  if closed then
    ie:=Width3D_in_WCS_Array.Count
  else
    ie:=Width3D_in_WCS_Array.Count-1;


  q3d:=Width3D_in_WCS_Array.GetParrayAsPointer;
  p3d:=Vertex3D_in_WCS_Array.GetParrayAsPointer;
  p3dold:=p3d;
  Inc(p3d);
  for i:=1 to ie do begin
    begin
      if i=Vertex3D_in_WCS_Array.Count then
        p3d:=Vertex3D_in_WCS_Array.GetParrayAsPointer;

      subresult:=CalcOutBound4VInFrustum(q3d^,mf);
      if subresult=IRFully then begin
        Result:=True;
        exit;
      end else if subresult=IRPartially then begin
        if uzegeometry.CalcTrueInFrustum
          (q3d^[0],q3d^[1],mf)<>irempty then begin
          Result:=
            True;
          exit;
        end;
        if uzegeometry.CalcTrueInFrustum
          (q3d^[1],q3d^[2],mf)<>irempty then begin
          Result:=
            True;
          exit;
        end;
        if uzegeometry.CalcTrueInFrustum
          (q3d^[2],q3d^[3],mf)<>irempty then begin
          Result:=
            True;
          exit;
        end;
        if uzegeometry.CalcTrueInFrustum
          (q3d^[3],q3d^[0],mf)<>irempty then begin
          Result:=
            True;
          exit;
        end;
      end;
      if uzegeometry.CalcTrueInFrustum(p3d^,p3dold^,mf)<>irempty then begin
        Result:=True;
        exit;
      end;

      Inc(q3d);
      Inc(p3dold);
      Inc(p3d);
    end;
  end;
end;

function GDBObjLWpolyline.CalcTrueInFrustum;
begin
  Result:=Vertex3D_in_WCS_Array.CalcTrueInFrustum(frustum,closed);
end;

procedure GDBObjLWpolyline.getoutbound;
var
  t,b,l,r,n,f:double;
  ptv:PzePoint3d;
  ir:itrec;
begin
  l:=Infinity;
  b:=Infinity;
  n:=Infinity;
  r:=NegInfinity;
  t:=NegInfinity;
  f:=NegInfinity;
  ptv:=Vertex3D_in_WCS_Array.beginiterate(ir);
  if ptv<>nil then begin
    repeat
      if ptv.x<l then
        l:=ptv.x;
      if ptv.x>r then
        r:=ptv.x;
      if ptv.y<b then
        b:=ptv.y;
      if ptv.y>t then
        t:=ptv.y;
      if ptv.z<n then
        n:=ptv.z;
      if ptv.z>f then
        f:=ptv.z;
      ptv:=Vertex3D_in_WCS_Array.iterate(ir);
    until ptv=nil;
    vp.BoundingBox.LBN:=CreateVertex(l,B,n);
    vp.BoundingBox.RTF:=CreateVertex(r,T,f);

  end else begin
    vp.BoundingBox.LBN:=CreateVertex(-1,-1,-1);
    vp.BoundingBox.RTF:=CreateVertex(1,1,1);
  end;
end;

procedure GDBObjLWpolyline.rtsave;
var
  p,pold:pzePoint2d;
  i:integer;
begin
  inherited;
  p:=Vertex2D_in_OCS_Array.GetParrayAsPointer;
  pold:=PGDBObjLWPolyline(refp)^.Vertex2D_in_OCS_Array.GetParrayAsPointer;
  for i:=0 to Vertex2D_in_OCS_Array.Count-1 do begin
    pold^:=p^;
    Inc(pold);
    Inc(p);
  end;
end;

procedure GDBObjLWpolyline.rtmodifyonepoint(const rtmod:TRTModifyData);
var
  vertexnumber:integer;
  tv,wwc:TzePoint3d;

  M:TzeTypedMatrix4d;
begin
  vertexnumber:=rtmod.point.vertexnum;

  m:=self.ObjMatrix;
  uzegeometry.MatrixInvert(m);


  tv:=rtmod.dist;
  wwc:=rtmod.point.worldcoord;
  wwc:=wwc+tv;
  wwc:=uzegeometry.VectorTransform3D(wwc,m);


  GDBPolyline2DArray.PTArr(Vertex2D_in_OCS_Array.parray)^[vertexnumber].x:=wwc.x;
  GDBPolyline2DArray.PTArr(Vertex2D_in_OCS_Array.parray)^[vertexnumber].y:=wwc.y;
end;

procedure GDBObjLWpolyline.remaponecontrolpoint(pdesc:pcontrolpointdesc;
  ProjectProc:GDBProjectProc);
var
  vertexnumber:integer;
  tv:TzePoint3d;
begin
  vertexnumber:=pdesc^.vertexnum;
  pdesc.worldcoord:=GDBPoint3dArray.PTArr(Vertex3D_in_WCS_Array.parray)^
    [vertexnumber];
  ProjectProc(pdesc.worldcoord,tv);
  pdesc.dispcoord:=ToTzePoint2i(tv);
end;

procedure GDBObjLWpolyline.AddControlpoints;
var
  pdesc:controlpointdesc;
  i:integer;
  pv:PzePoint3d;
begin
  PSelectedObjDesc(tdesc)^.pcontrolpoint^.init(Vertex3D_in_WCS_Array.Count);
  pv:=Vertex3D_in_WCS_Array.GetParrayAsPointer;
  pdesc.selected:=False;
  pdesc.PDrawable:=nil;

  for i:=0 to Vertex3D_in_WCS_Array.Count-1 do begin
    pdesc.vertexnum:=i;
    pdesc.attr:=[CPA_Strech];
    pdesc.worldcoord:=pv^;
    PSelectedObjDesc(tdesc)^.pcontrolpoint^.PushBackData(pdesc);
    Inc(pv);
  end;
end;

function GDBObjLWpolyline.Clone;
var
  tpo:PGDBObjLWPolyline;
begin
  Getmem(Pointer(tpo),sizeof(GDBObjLWPolyline));
  tpo^.init(own,vp.Layer,vp.LineWeight,closed);
  tpo^.Plinegen:=Plinegen;
  CopyVPto(tpo^);
  CopyExtensionsTo(tpo^);
  tpo^.Local:=local;
  tpo^.Vertex2D_in_OCS_Array.SetSize(Vertex2D_in_OCS_Array.Count);
  Vertex2D_in_OCS_Array.copyto(tpo^.Vertex2D_in_OCS_Array);
  tpo^.SgmntsParams.SetSize(SgmntsParams.Count);
  SgmntsParams.copyto(tpo^.SgmntsParams);
  Result:=tpo;
end;

function GDBObjLWpolyline.GetObjTypeName;
begin
  Result:=ObjN_GDBObjLWPolyLine;
end;

destructor GDBObjLWpolyline.done;
begin
  Vertex2D_in_OCS_Array.done;
  SgmntsParams.done;
  Vertex3D_in_WCS_Array.done;
  Width3D_in_WCS_Array.done;
  inherited done;
end;

constructor GDBObjLWpolyline.init;
begin
  inherited init(own,layeraddres,lw);
  closed:=c;
  Plinegen:=false;
  Vertex2D_in_OCS_Array.init(4,c);
  SgmntsParams.init(4);
  Vertex3D_in_WCS_Array.init(4);
  Width3D_in_WCS_Array.init(4);
end;

constructor GDBObjLWpolyline.initnul;
begin
  inherited initnul(nil);
  Closed:=false;
  Plinegen:=false;
  Vertex2D_in_OCS_Array.init(4,False);
  SgmntsParams.init(4);
  Vertex3D_in_WCS_Array.init(4);
  Width3D_in_WCS_Array.init(4);
end;

function GDBObjLWpolyline.GetObjType;
begin
  Result:=GDBLWPolylineID;
end;

procedure GDBObjLWpolyline.DrawGeometry;
var
  i,ie:integer;
  q3d:PGDBQuad3d;
  plw:PSegmentParams;
  v:TzePoint3d;
  simplydraw:boolean;
begin

  Representation.DrawGeometry(DC,VP.BoundingBox,inFrustumState);
  exit;

  if dc.lod=LODCalculatedDetail then begin
    v:=uzegeometry.VertexSub(vp.BoundingBox.RTF,vp.BoundingBox.LBN);
    simplydraw:=not SqrCanSimplyDrawInWCS(DC,uzegeometry.SqrOneVertexlength(v.asVector3d),49);
  end else
    simplydraw:=dc.lod=LODLowDetail;

  if simplydraw then begin
    q3d:=Width3D_in_WCS_Array.GetParrayAsPointer;
    if q3d<>nil then begin
      if Width3D_in_WCS_Array.Count>15 then begin
        if Width3D_in_WCS_Array.parray<>nil then begin
          ie:=(Width3D_in_WCS_Array.Count div 4)+4;
          for i:=0 to (Width3D_in_WCS_Array.Count-2)div ie do begin
            dc.drawer.DrawLine3DInModelSpace(
              q3d^[0],q3d^[1],dc.DrawingContext.matrixs);
            Inc(q3d,ie);
          end;
        end;
      end else if Width3D_in_WCS_Array.Count>2 then begin
        dc.drawer.DrawLine3DInModelSpace(vp.BoundingBox.LBN,vp.BoundingBox.RTF,
          dc.DrawingContext.matrixs);
      end else begin
        dc.drawer.DrawLine3DInModelSpace(q3d^[0],q3d^[1],
          dc.DrawingContext.matrixs);
      end;
    end;
    exit;
  end;

  if closed then
    ie:=Width3D_in_WCS_Array.Count-1
  else
    ie:=Width3D_in_WCS_Array.Count-2;
  q3d:=Width3D_in_WCS_Array.GetParrayAsPointer;
  plw:=SgmntsParams.GetParrayAsPointer;
  for i:=0 to ie do begin
    begin
      if plw^.data.hw then
        dc.drawer.DrawQuad3DInModelSpace(q3d^[0],q3d^[1],q3d^[2],
          q3d^[3],dc.DrawingContext.matrixs);
      Inc(plw);
      Inc(q3d);
    end;
  end;
  q3d:=Width3D_in_WCS_Array.GetParrayAsPointer;
  plw:=SgmntsParams.GetParrayAsPointer;
  for i:=0 to ie do begin
    begin
      dc.drawer.DrawLine3DInModelSpace(q3d^[0],q3d^[1],dc.DrawingContext.matrixs);
      if plw^.data.hw then begin
        dc.drawer.DrawLine3DInModelSpace(q3d^[1],q3d^[2],dc.DrawingContext.matrixs);
        dc.drawer.DrawLine3DInModelSpace(q3d^[2],q3d^[3],dc.DrawingContext.matrixs);
        dc.drawer.DrawLine3DInModelSpace(q3d^[3],q3d^[0],dc.DrawingContext.matrixs);
      end;
      Inc(plw);
      Inc(q3d);
    end;
  end;
  inherited;
end;

function EnsureWidthInicialized(var AWidths:TSegmentsParams;AIdx:Integer):PSegmentParams;
var
  c:Integer;
begin
  if AWidths.Count<=AIdx then begin
    c:=AWidths.Count;
    AWidths.SetCount(AIdx+1);
    Result:=AWidths.getDataMutable(c);
    Result^.data:=CDefaultPolySegmentWidth;
    while c<AIdx do begin
      inc(c);
      Inc(Result);
      Result^.data:=CDefaultPolySegmentWidth;
    end;
    {Result:=AWidths.getDataMutable(AIdx);
    Result^.data:=CDefaultPolySegmentWidth;}
  end else
    Result:=AWidths.getDataMutable(AIdx);
end;

procedure GDBObjLWpolyline.LoadFromDXF;
var
  p:TzePoint2d;
  byt,i:integer;
  hlGDBWord,flags:longword;
  numv:integer;
  widthload:boolean;
  globalwidth:double;
begin
  hlGDBWord:=0;
  numv:=0;
  globalwidth:=0;
  widthload:=False;
  closed:=False;
  if bp.ListPos.owner<>nil then
    local.p_insert:=bp.ListPos.owner^.GetMatrix^.mtr.v[3].Slice.asPoint3d
  else
    local.P_insert:=NulPoint;

  byt:=rdr.ParseInteger;
  while byt<>0 do begin
    if not LoadFromDXFObjShared(rdr,byt,ptu,drawing,context) then
      case byt of
        8:vp.Layer:=drawing.getlayertable.getAddres(rdr.ParseShortString);
        62:vp.color:=rdr.ParseInteger;
        90:begin
          numv:=rdr.ParseInteger;
          SgmntsParams.SetSize(numv);
          hlGDBWord:=0;
        end;
        10:p.x:=rdr.ParseDouble;
        20:begin
          p.y:=rdr.ParseDouble;
          lwtv.PushBackData(p);
          EnsureWidthInicialized(SgmntsParams,hlGDBWord);
          Inc(hlGDBWord);
        end;
        38:local.p_insert.z:=rdr.ParseDouble;
        40:begin
          EnsureWidthInicialized(SgmntsParams,hlGDBWord-1)^.data.startw:=rdr.ParseDouble;
          {SgmntsParams.SetCount(numv);
          PSegmentParams(SgmntsParams.getDataMutable(hlGDBWord-1)).data.startw:=rdr.ParseDouble;}
          widthload:=True;
        end;
        41:begin
          EnsureWidthInicialized(SgmntsParams,hlGDBWord-1)^.data.endw:=rdr.ParseDouble;
          {SgmntsParams.SetCount(numv);
          PSegmentParams(SgmntsParams.getDataMutable(hlGDBWord-1)).data.endw:=rdr.ParseDouble;}
          widthload:=True;
        end;
        42:begin
          EnsureWidthInicialized(SgmntsParams,hlGDBWord-1)^.data.bulge:=rdr.ParseDouble;
          {SgmntsParams.SetCount(numv);
          PSegmentParams(SgmntsParams.getDataMutable(hlGDBWord-1)).data.bulge:=rdr.ParseDouble;}
        end;
        43:globalwidth:=rdr.ParseDouble;
        70:begin
          flags:=rdr.ParseInteger;
          closed:=(flags and 1)<>0;
          Plinegen:=(flags and 128)<>0;
        end;
        210:Local.basis.oz.x:=rdr.ParseDouble;
        220:Local.basis.oz.y:=rdr.ParseDouble;
        230:Local.basis.oz.z:=rdr.ParseDouble;
        370:vp.lineweight:=rdr.ParseInteger;
        else
          rdr.SkipString;
      end;
    byt:=rdr.ParseInteger;
  end;
  if not widthload then begin
    SgmntsParams.SetCount(numv);
    for i:=0 to numv-1 do begin
      PSegmentParams(SgmntsParams.getDataMutable(i)).data.endw:=globalwidth;
      PSegmentParams(SgmntsParams.getDataMutable(i)).data.startw:=globalwidth;
    end;
  end;
  Vertex2D_in_OCS_Array.SetSize(lwtv.Count);
  lwtv.copyto(Vertex2D_in_OCS_Array);
  lwtv.Clear;
  SgmntsParams.Shrink;
end;

procedure GDBObjLWpolyline.SaveToDXF;
var
  j,flags:integer;
  tv:TzePoint3d;
begin
  SaveToDXFObjPrefix(outStream,'LWPOLYLINE','AcDbPolyline',IODXFContext);
  dxfStringWithoutEncodeOut(outStream,90,IntToStr(Vertex2D_in_OCS_Array.Count));

  if Closed then
    flags:=1
  else
    flags:=0;

  if Plinegen then
    flags:=flags or 128;

  if flags<>0 then
    dxfIntegerout(outStream,70,flags);

  dxfDoubleout(outStream,38,local.p_insert.z);

  {m:=}CalcObjMatrixWithoutOwner;
  //наверно это ненужно. надо проверить
  //MatrixTranspose(m);

  for j:=0 to (Vertex2D_in_OCS_Array.Count-1) do begin
    tv.x:=GDBPolyline2DArray.PTArr(Vertex2D_in_OCS_Array.PArray)^[j].x;
    tv.y:=GDBPolyline2DArray.PTArr(Vertex2D_in_OCS_Array.PArray)^[j].y;
    tv.z:=0;
    dxfvertex2dout(outStream,10,PzePoint2d(@tv)^);
    dxfDoubleout(outStream,40,PSegmentParams(SgmntsParams.getDataMutable(j)).data.startw);
    dxfDoubleout(outStream,41,PSegmentParams(SgmntsParams.getDataMutable(j)).data.endw);
    dxfDoubleout(outStream,42,PSegmentParams(SgmntsParams.getDataMutable(j)).data.bulge);
  end;
  SaveToDXFObjPostfix(outStream);
end;

function GDBObjLWpolyline.isPointInside(const point:TzePoint3d):boolean;
var
  m:TzeTypedMatrix4d;
  p:TzePoint2d;
begin
  m:=self.getmatrix^;
  uzegeometry.MatrixInvert(m);
  with VectorTransform3D(point,m) do begin
    p.x:=x;
    p.y:=y;
  end;
  Result:=Vertex2D_in_OCS_Array.ispointinside(p);
end;

function GDBObjLWpolyline.CalcSquare:double;
var
  pv,pvnext:PzePoint2d;
  i:integer;
begin
  Result:=0;
  if Vertex2D_in_OCS_Array.Count<2 then
    exit;

  pv:=Vertex2D_in_OCS_Array.GetParrayAsPointer;
  pvnext:=pv;
  Inc(pvnext);
  for i:=1 to Vertex2D_in_OCS_Array.Count do begin
    if i=Vertex2D_in_OCS_Array.Count then
      pvnext:=
        Vertex2D_in_OCS_Array.GetParrayAsPointer;
    Result:=Result+(pv.x+pvnext.x)*(pv.y-pvnext.y);
    Inc(pv);
    Inc(pvnext);
  end;
  Result:=Result/2;
end;

function GDBObjLWpolyline.IsStagedFormatEntity:boolean;
begin
  Result:=True;
end;


procedure GDBObjLWpolyline.FormatEntity(var drawing:TDrawingDef;var DC:TDrawContext;
                                        Stage:TEFStages=EFAllStages);
begin
  if EFCalcEntityCS in stage then begin
    if assigned(EntExtensions) then
      EntExtensions.RunOnBeforeEntityFormat(@self,drawing,DC);
    inherited FormatEntity(drawing,dc);
    createpoint;
    calcbb(dc);
    Vertex2D_in_OCS_Array.Shrink;
    SgmntsParams.Shrink;
  end;

  CalcActualVisible(dc.DrawingContext.VActuality);

  if EFDraw in stage then begin
    if (not (ESTemp in State))and(DCODrawable in DC.Options) then begin
      Representation.Clear;
      CalcWidthSegments;
      if assigned(EntExtensions) then begin
        if EntExtensions.NeedStandardDraw(@self,drawing,DC) then
          Representation.CreateLWPolyLine(dc,self,vp,GetMatrix^,
          Vertex2D_in_OCS_Array.getPFirst[0..Vertex2D_in_OCS_Array.GetLastIndex],
          SgmntsParams.getPFirst[0..SgmntsParams.GetLastIndex],Closed,Plinegen);
      end else
        Representation.CreateLWPolyLine(dc,self,vp,GetMatrix^,
        Vertex2D_in_OCS_Array.getPFirst[0..Vertex2D_in_OCS_Array.GetLastIndex],
        SgmntsParams.getPFirst[0..SgmntsParams.GetLastIndex],Closed,Plinegen);
    end;
    Representation.Shrink;
    if assigned(EntExtensions) then
      EntExtensions.RunOnAfterEntityFormat(@self,drawing,DC);
  end;
end;

procedure GDBObjLWpolyline.createpoint;
var
  i:integer;
  v:TzeVector4d;
  v3d:TzeVector3d;
  pv:PzeVector2d;
begin
  Vertex3D_in_WCS_Array.Clear;
  pv:=Vertex2D_in_OCS_Array.GetParrayAsPointer;
  for i:=0 to Vertex2D_in_OCS_Array.Count-1 do begin
    v.Slice.Slice:=pv^;
    {v.x:=pv.x;
    v.y:=pv.y;}
    v.Slice.CutOff:=0;
    //v.z:=0;
    v.CutOff:=0;
    //v.w:=1;
    v:=VectorTransform(v,objMatrix);
    v3d:=v.Slice;
    Vertex3D_in_WCS_Array.PushBackData(v3d.asPoint3d);
    Inc(pv);
  end;
  Vertex3D_in_WCS_Array.Shrink;
end;
procedure GDBObjLWpolyline.CalcWidthSegment(var p1,p2:TzePoint2d;var plw:TSegmentParams);
var
  k:integer;
  vtangent,vnormal,vtemp:TzeVector2d;
  q3d:GDBQuad3d;
  v:TzeVector4d;
begin
  vtangent:=p2-p1;
  vnormal:=vtangent.Turned90L;
  {vnormal.x:=-vtangent.y;
  vnormal.y:=vtangent.x;}
  vnormal.Normalize;

  if (plw.data.startw=0) and (plw.data.endw=0) then
    plw.data.hw:=False
  else begin
    plw.data.hw:=True;
  end;

  vtemp:=vnormal*plw.data.startw/2;
  plw.quad[0]:=p1+vtemp;
  plw.quad[3]:=p1-vtemp;
  vtemp:=vnormal*plw.data.endw/2;
  plw.quad[1]:=p2+vtemp;
  plw.quad[2]:=p2-vtemp;

  for k:=0 to 3 do begin
    v.Slice.Slice:=plw.quad[k].asVector2d;
    //v.x:=plw.quad[k].x;
    //v.y:=plw.quad[k].y;
    v.Slice.CutOff:=0;
    //v.z:=0;
    v.CutOff:=1;
    //v.w:=1;
    v:=VectorTransform(v,objMatrix);
    q3d[k]:=v.Slice.asPoint3d;
  end;

  Width3D_in_WCS_Array.PushBackData(q3d);
end;

procedure GDBObjLWpolyline.CalcWidthSegments;
var
  i,j,k:integer;
  l:double;
  pv1,pv2:PzePoint2d;
  plw,plw2:PSegmentParams;
  pq3d,pq3dnext:pGDBQuad3d;
  v2:PzePoint3d;
  ip,ip2:Intercept3DProp;
begin
  Width3D_in_WCS_Array.Clear;
  for i:=0 to Vertex2D_in_OCS_Array.Count-1 do begin
    if i<>Vertex2D_in_OCS_Array.Count-1 then
      j:=i+1
    else
      j:=0;
    pv2:=Vertex2D_in_OCS_Array.getDataMutable(j);
    pv1:=Vertex2D_in_OCS_Array.getDataMutable(i);
    plw:=PSegmentParams(SgmntsParams.getDataMutable(i));
    CalcWidthSegment(pv1^,pv2^,plw^);

  end;
  SgmntsParams.Shrink;
  Width3D_in_WCS_Array.Shrink;

  if closed then
    k:=Width3D_in_WCS_Array.Count-1
  else
    k:=Width3D_in_WCS_Array.Count-2;
  for i:=0 to k do
    if (i<>k)or closed then begin
      if i<>Width3D_in_WCS_Array.Count-1 then
        j:=i+1
      else
        j:=0;
      plw:=PSegmentParams(SgmntsParams.getDataMutable(i));
      plw2:=PSegmentParams(SgmntsParams.getDataMutable(j));
      if plw.data.hw and plw2.data.hw then begin
        if plw.data.endw>plw2.data.startw then
          l:=plw.data.endw
        else
          l:=plw2.data.startw;
        l:=4*l*l;
        pq3d:=Width3D_in_WCS_Array.getDataMutable(i);
        pq3dnext:=Width3D_in_WCS_Array.getDataMutable(j);
        ip:=intercept3dmy2(pq3d^[0],pq3d^[1],pq3dnext^[1],pq3dnext^[0]);
        ip2:=intercept3dmy2(pq3d^[3],pq3d^[2],pq3dnext^[2],pq3dnext^[3]);

        if ip.isintercept and ip2.isintercept then
          if (ip.t1>0) and (ip.t2>0) then
            if (ip2.t1>0) and (ip2.t2>0) then begin
              v2:=Vertex3D_in_WCS_Array.getDataMutable(j);
              if SqrVertexlength(v2^,ip.interceptcoord)<l then
                if SqrVertexlength(v2^,ip2.interceptcoord)<l then begin
                  pq3d^[1]:=ip.interceptcoord;
                  pq3d^[2]:=ip2.interceptcoord;
                  pq3dnext^[0]:=ip.interceptcoord;
                  pq3dnext^[3]:=ip2.interceptcoord;
                end;
            end;
      end;

    end;
end;

function AllocLWpolyline:PGDBObjLWpolyline;
begin
  Getmem(pointer(Result),sizeof(GDBObjLWpolyline));
end;

function AllocAndInitLWpolyline(owner:PGDBObjGenericWithSubordinated):PGDBObjLWpolyline;
begin
  Result:=AllocLWpolyline;
  Result.initnul;
  Result.bp.ListPos.Owner:=owner;
end;

class function GDBObjLWpolyline.CreateInstance:PGDBObjLWpolyline;
begin
  Result:=AllocAndInitLWpolyline(nil);
end;

procedure SetLWpolylineGeomProps(ALWpolyLine:PGDBObjLWpolyline;
  const args:array of const);
var
  counter:integer;
  i,c:integer;
  pw:PSegmentParams;
  pp:PzePoint2d;
begin
  counter:=low(args);
  ALWpolyLine.Closed:=CreateBooleanFromArray(counter,args);
  c:=(high(args)-low(args))div 5;
  if ((high(args)-low(args))mod 5)>1 then
    Inc(c);
  if ALWpolyLine.Closed then
    ALWpolyLine.SgmntsParams.SetCount(c)
  else
    ALWpolyLine.SgmntsParams.SetCount(c{-1});
  ALWpolyLine.Vertex2D_in_OCS_Array.SetCount(c);
  for i:=0 to c-1 do begin
    pp:=ALWpolyLine.Vertex2D_in_OCS_Array.getDataMutable(i);
    pp^:=CreateVertex2DFromArray(counter,args);
    if (ALWpolyLine.Closed)or(i<(c-1)) then begin
      CreateDoubleFromArray(counter,args);
      pw:=ALWpolyLine.SgmntsParams.getDataMutable(i);
      pw.data.startw:=CreateDoubleFromArray(counter,args);
      pw.data.endw:=CreateDoubleFromArray(counter,args);
      pw.data.hw:=IsDoubleNotEqual(pw.data.startw,0) or IsDoubleNotEqual(pw.data.endw,0);
    end;
  end;
end;

function AllocAndCreateLWpolyline(owner:PGDBObjGenericWithSubordinated;
  const args:array of const):PGDBObjLWPolyline;
begin
  Result:=AllocAndInitLWpolyline(owner);
  SetLWpolylineGeomProps(Result,args);
end;

initialization
  lwtv.init(200,False);
  RegisterDXFEntity(GDBLWPolylineID,'LWPOLYLINE','LWPolyline',@AllocLWpolyline,@AllocAndInitLWpolyline,@SetLWpolylineGeomProps,@AllocAndCreateLWpolyline);

finalization
  lwtv.done;
end.
