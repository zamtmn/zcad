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

type

  PGLLWWidth=^GLLWWidth;

  GLLWWidth=record
    startw:double;
    endw:double;
    hw:boolean;
    quad:GDBQuad2d;
  end;

  GDBLineWidthArray=object(GZVector<GLLWWidth>)
  end;

  TWidth3D_in_WCS_Vector=object(GZVector<GDBQuad3d>)
  end;
  PGDBObjLWPolyline=^GDBObjLWpolyline;

  GDBObjLWPolyline=object(GDBObjWithLocalCS)
    Closed:boolean;
    Vertex2D_in_OCS_Array:GDBpolyline2DArray;
    Vertex3D_in_WCS_Array:GDBPoint3dArray;
    Width2D_in_OCS_Array:GDBLineWidthArray;
    Width3D_in_WCS_Array:TWidth3D_in_WCS_Vector;
    Square:double;
    constructor init(own:Pointer;layeraddres:PGDBLayerProp;
      LW:smallint;c:boolean);
    constructor initnul;
    procedure LoadFromDXF(var rdr:TZMemReader;ptu:PExtensionData;
      var drawing:TDrawingDef;var context:TIODXFLoadContext);virtual;

    procedure SaveToDXF(var outStream:TZctnrVectorBytes;
      var drawing:TDrawingDef;var IODXFContext:TIODXFSaveContext);virtual;
    procedure DrawGeometry(lw:integer;var DC:TDrawContext;
      const inFrustumState:TInBoundingVolume);virtual;
    procedure FormatEntity(var drawing:TDrawingDef;
      var DC:TDrawContext;Stage:TEFStages=EFAllStages);virtual;
    function CalcSquare:double;virtual;
    //**попадаетли данная координата внутрь контура
    function isPointInside(const point:TzePoint3d):boolean;virtual;
    procedure createpoint;virtual;
    procedure CalcWidthSegment;virtual;
    destructor done;virtual;
    function GetObjTypeName:string;virtual;
    function Clone(own:Pointer):PGDBObjEntity;virtual;
    procedure addcontrolpoints(tdesc:Pointer);virtual;
    procedure remaponecontrolpoint(pdesc:pcontrolpointdesc;
      ProjectProc:GDBProjectProc);virtual;
    procedure rtmodifyonepoint(const rtmod:TRTModifyData);virtual;
    procedure rtsave(refp:Pointer);virtual;
    procedure getoutbound(var DC:TDrawContext);virtual;
    function CalcTrueInFrustum(
      const frustum:TzeFrustum):TInBoundingVolume;virtual;
    function onmouse(var popa:TZctnrVectorPGDBaseEntity;
      const MF:TzeFrustum;InSubEntry:boolean):boolean;virtual;
    function onpoint(var objects:TZctnrVectorPGDBaseEntity;
      const point:TzePoint3d):boolean;virtual;
    function getsnap(var osp:os_record;var pdata:Pointer;
      const param:OGLWndtype;ProjectProc:GDBProjectProc;SnapMode:TGDBOSMode):boolean;virtual;
    procedure startsnap(out osp:os_record;out pdata:Pointer);virtual;
    procedure endsnap(out osp:os_record;var pdata:Pointer);virtual;
    procedure AddOnTrackAxis(var posr:os_record;
      const processaxis:taddotrac);virtual;
    procedure transform(const t_matrix:TzeTypedMatrix4d);virtual;
    procedure TransformAt(p:PGDBObjEntity;t_matrix:PzeTypedMatrix4d);virtual;
    function GetTangentInPoint(const point:TzePoint3d):TzePoint3d;virtual;
    procedure higlight(var DC:TDrawContext);virtual;
    class function CreateInstance:PGDBObjLWPolyline;static;
    function GetObjType:TObjID;virtual;
  end;

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
        Result:=uzegeometry.NormalizeVertex(Result);
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
  wwc:=VertexAdd(wwc,tv);
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
  CopyVPto(tpo^);
  CopyExtensionsTo(tpo^);
  tpo^.Local:=local;
  tpo^.Vertex2D_in_OCS_Array.SetSize(Vertex2D_in_OCS_Array.Count);
  Vertex2D_in_OCS_Array.copyto(tpo^.Vertex2D_in_OCS_Array);
  tpo^.Width2D_in_OCS_Array.SetSize(Width2D_in_OCS_Array.Count);
  Width2D_in_OCS_Array.copyto(tpo^.Width2D_in_OCS_Array);
  Result:=tpo;
end;

function GDBObjLWpolyline.GetObjTypeName;
begin
  Result:=ObjN_GDBObjLWPolyLine;
end;

destructor GDBObjLWpolyline.done;
begin
  Vertex2D_in_OCS_Array.done;
  Width2D_in_OCS_Array.done;
  Vertex3D_in_WCS_Array.done;
  Width3D_in_WCS_Array.done;
  inherited done;
end;

constructor GDBObjLWpolyline.init;
begin
  inherited init(own,layeraddres,lw);
  closed:=c;
  Vertex2D_in_OCS_Array.init(4,c);
  Width2D_in_OCS_Array.init(4);
  Vertex3D_in_WCS_Array.init(4);
  Width3D_in_WCS_Array.init(4);
end;

constructor GDBObjLWpolyline.initnul;
begin
  inherited initnul(nil);
  Vertex2D_in_OCS_Array.init(4,False);
  Width2D_in_OCS_Array.init(4);
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
  plw:PGLlwwidth;
  v:TzePoint3d;
  simplydraw:boolean;
begin

  if dc.lod=LODCalculatedDetail then begin
    v:=uzegeometry.VertexSub(vp.BoundingBox.RTF,vp.BoundingBox.LBN);
    simplydraw:=not SqrCanSimplyDrawInWCS(DC,uzegeometry.SqrOneVertexlength(v),49);
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
  plw:=Width2D_in_OCS_Array.GetParrayAsPointer;
  for i:=0 to ie do begin
    begin
      if plw^.hw then
        dc.drawer.DrawQuad3DInModelSpace(q3d^[0],q3d^[1],q3d^[2],
          q3d^[3],dc.DrawingContext.matrixs);
      Inc(plw);
      Inc(q3d);
    end;
  end;
  q3d:=Width3D_in_WCS_Array.GetParrayAsPointer;
  plw:=Width2D_in_OCS_Array.GetParrayAsPointer;
  for i:=0 to ie do begin
    begin
      dc.drawer.DrawLine3DInModelSpace(q3d^[0],q3d^[1],dc.DrawingContext.matrixs);
      if plw^.hw then begin
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

procedure GDBObjLWpolyline.LoadFromDXF;
var
  p:TzePoint2d;
  byt,i:integer;
  hlGDBWord:longword;
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
    local.p_insert:=PzePoint3d(@bp.ListPos.owner^.GetMatrix^.mtr.v[3])^
  else
    local.P_insert:=nulvertex;

  byt:=rdr.ParseInteger;
  while byt<>0 do begin
    if not LoadFromDXFObjShared(rdr,byt,ptu,drawing,context) then
      case byt of
        8:vp.Layer:=drawing.getlayertable.getAddres(rdr.ParseShortString);
        62:vp.color:=rdr.ParseInteger;
        90:begin
          numv:=rdr.ParseInteger;
          Width2D_in_OCS_Array.SetSize(numv);
          hlGDBWord:=0;
        end;
        10:p.x:=rdr.ParseDouble;
        20:begin
          p.y:=rdr.ParseDouble;
          lwtv.PushBackData(p);
          Inc(hlGDBWord);
        end;
        38:local.p_insert.z:=rdr.ParseDouble;
        40:begin
          Width2D_in_OCS_Array.SetCount(numv);
          PGLLWWidth(Width2D_in_OCS_Array.getDataMutable(hlGDBWord-1)).startw:=
            rdr.ParseDouble;
          widthload:=True;
        end;
        41:begin
          Width2D_in_OCS_Array.SetCount(numv);
          PGLLWWidth(Width2D_in_OCS_Array.getDataMutable(hlGDBWord-1)).endw:=
            rdr.ParseDouble;
          widthload:=True;
        end;
        43:globalwidth:=rdr.ParseDouble;
        70:closed:=(rdr.ParseInteger and 1)=1;
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
    Width2D_in_OCS_Array.SetCount(numv);
    for i:=0 to numv-1 do begin
      PGLLWWidth(Width2D_in_OCS_Array.getDataMutable(i)).endw:=globalwidth;
      PGLLWWidth(Width2D_in_OCS_Array.getDataMutable(i)).startw:=globalwidth;
    end;
  end;
  Vertex2D_in_OCS_Array.SetSize(lwtv.Count);
  lwtv.copyto(Vertex2D_in_OCS_Array);
  lwtv.Clear;
  Width2D_in_OCS_Array.Shrink;
end;

procedure GDBObjLWpolyline.SaveToDXF;
var
  j:integer;
  tv:TzePoint3d;
begin
  SaveToDXFObjPrefix(outStream,'LWPOLYLINE','AcDbPolyline',IODXFContext);
  dxfStringWithoutEncodeOut(outStream,90,IntToStr(Vertex2D_in_OCS_Array.Count));
  if closed then
    dxfStringWithoutEncodeOut(outStream,70,'1')
  else
    dxfStringWithoutEncodeOut(outStream,70,'0');


  dxfDoubleout(outStream,38,local.p_insert.z);

  {m:=}CalcObjMatrixWithoutOwner;
  //наверно это ненужно. надо проверить
  //MatrixTranspose(m);

  for j:=0 to (Vertex2D_in_OCS_Array.Count-1) do begin
    tv.x:=GDBPolyline2DArray.PTArr(Vertex2D_in_OCS_Array.PArray)^[j].x;
    tv.y:=GDBPolyline2DArray.PTArr(Vertex2D_in_OCS_Array.PArray)^[j].y;
    tv.z:=0;
    dxfvertex2dout(outStream,10,PzePoint2d(@tv)^);
    dxfDoubleout(outStream,40,PGLLWWidth(Width2D_in_OCS_Array.getDataMutable(j)).startw);
    dxfDoubleout(outStream,41,PGLLWWidth(Width2D_in_OCS_Array.getDataMutable(j)).endw);
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

procedure GDBObjLWpolyline.FormatEntity(var drawing:TDrawingDef;
  var DC:TDrawContext;Stage:TEFStages=EFAllStages);
begin
  if assigned(EntExtensions) then
    EntExtensions.RunOnBeforeEntityFormat(@self,drawing,DC);
  Vertex2D_in_OCS_Array.Shrink;
  Width2D_in_OCS_Array.Shrink;
  inherited FormatEntity(drawing,dc);
  createpoint;
  CalcWidthSegment;
  Square:=CalcSquare;
  calcbb(dc);
  if assigned(EntExtensions) then
    EntExtensions.RunOnAfterEntityFormat(@self,drawing,DC);
end;

procedure GDBObjLWpolyline.createpoint;
var
  i:integer;
  v:TzeVector4d;
  v3d:TzePoint3d;
  pv:PzePoint2d;
begin
  Vertex3D_in_WCS_Array.Clear;
  pv:=Vertex2D_in_OCS_Array.GetParrayAsPointer;
  for i:=0 to Vertex2D_in_OCS_Array.Count-1 do begin
    v.x:=pv.x;
    v.y:=pv.y;
    v.z:=0;
    v.w:=1;
    v:=VectorTransform(v,objMatrix);
    v3d:=PzePoint3d(@v)^;
    Vertex3D_in_WCS_Array.PushBackData(v3d);
    Inc(pv);
  end;
  Vertex3D_in_WCS_Array.Shrink;
end;

procedure GDBObjLWpolyline.CalcWidthSegment;
var
  i,j,k:integer;
  dx,dy,nx,ny,l:double;
  v2di,v2dj:PzePoint2d;
  plw,plw2:PGLlwwidth;
  q3d:GDBQuad3d;
  pq3d,pq3dnext:pGDBQuad3d;
  v:TzeVector4d;
  v2:PzePoint3d;
  ip,ip2:Intercept3DProp;
begin
  Width3D_in_WCS_Array.Clear;
  for i:=0 to Vertex2D_in_OCS_Array.Count-1 do begin
    if i<>Vertex2D_in_OCS_Array.Count-1 then
      j:=i+1
    else
      j:=0;
    v2dj:=Vertex2D_in_OCS_Array.getDataMutable(j);
    v2di:=Vertex2D_in_OCS_Array.getDataMutable(i);
    dx:=v2dj^.x-v2di^.x;
    dy:=v2dj^.y-v2di^.y;
    nx:=-dy;
    ny:=dx;
    l:=sqrt(nx*nx+ny*ny);
    if abs(l)>eps then begin
      nx:=nx/l;
      ny:=ny/l;
    end else begin
      nx:=0;
      ny:=0;
    end;

    plw:=PGLlwwidth(Width2D_in_OCS_Array.getDataMutable(i));

    if (plw^.startw=0) and (plw^.endw=0) then
      plw^.hw:=False
    else
      plw^.hw:=True;
    plw^.quad[0].x:=v2di^.x+nx*plw^.startw/2;
    plw^.quad[0].y:=v2di^.y+ny*plw^.startw/2;

    plw^.quad[1].x:=v2dj^.x+nx*plw^.endw/2;
    plw^.quad[1].y:=v2dj^.y+ny*plw^.endw/2;

    plw^.quad[2].x:=v2dj^.x-nx*plw^.endw/2;
    plw^.quad[2].y:=v2dj^.y-ny*plw^.endw/2;

    plw^.quad[3].x:=v2di^.x-nx*plw^.startw/2;
    plw^.quad[3].y:=v2di^.y-ny*plw^.startw/2;

    for k:=0 to 3 do begin
      v.x:=plw^.quad[k].x;
      v.y:=plw^.quad[k].y;
      v.z:=0;
      v.w:=1;
      v:=VectorTransform(v,objMatrix);
      q3d[k]:=PzePoint3d(@v)^;
    end;
    Width3D_in_WCS_Array.PushBackData(q3d);
  end;
  Width2D_in_OCS_Array.Shrink;
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
      plw:=PGLlwwidth(Width2D_in_OCS_Array.getDataMutable(i));
      plw2:=PGLlwwidth(Width2D_in_OCS_Array.getDataMutable(j));
      if plw.hw and plw2.hw then begin
        if plw.endw>plw2.startw then
          l:=plw.endw
        else
          l:=plw2.startw;
        l:=4*l*l;
        pq3d:=Width3D_in_WCS_Array.getDataMutable(i);
        pq3dnext:=Width3D_in_WCS_Array.getDataMutable(j);
        ip:=intercept3dmy2(pq3d^[0],pq3d^[1],pq3dnext^[1],pq3dnext^[0]);
        ip2:=intercept3dmy2(pq3d^[3],pq3d^[2],pq3dnext^[2],pq3dnext^[3]);

        if ip.isintercept and ip2.isintercept then
          if (ip.t1>0) and (ip.t2>0) then
            if (ip2.t1>0) and (ip2.t2>0) then begin
              v2:=PzePoint3d(Vertex3D_in_WCS_Array.getDataMutable(j));
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
  pw:PGLLWWidth;
  pp:PzePoint2d;
begin
  counter:=low(args);
  ALWpolyLine.Closed:=CreateBooleanFromArray(counter,args);
  c:=(high(args)-low(args))div 5;
  if ((high(args)-low(args))mod 5)>1 then
    Inc(c);
  if ALWpolyLine.Closed then
    ALWpolyLine.Width2D_in_OCS_Array.SetCount(c)
  else
    ALWpolyLine.Width2D_in_OCS_Array.SetCount(c{-1});
  ALWpolyLine.Vertex2D_in_OCS_Array.SetCount(c);
  for i:=0 to c-1 do begin
    pp:=ALWpolyLine.Vertex2D_in_OCS_Array.getDataMutable(i);
    pp^:=CreateVertex2DFromArray(counter,args);
    if (ALWpolyLine.Closed)or(i<(c-1)) then begin
      CreateDoubleFromArray(counter,args);
      pw:=ALWpolyLine.Width2D_in_OCS_Array.getDataMutable(i);
      pw.startw:=CreateDoubleFromArray(counter,args);
      pw.endw:=CreateDoubleFromArray(counter,args);
      pw.hw:=IsDoubleNotEqual(pw.startw,0) or IsDoubleNotEqual(pw.endw,0);
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
