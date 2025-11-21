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
unit uzeent3dface;
{$Mode delphi}{$H+}
{$INCLUDE zengineconfig.inc}

interface

uses
  uzeentityfactory,uzgldrawcontext,uzedrawingdef,uzecamera,uzegeometry,
  uzeffdxfsupport,uzestyleslayers,UGDBSelectedObjArray,uzeentsubordinated,
  uzegeometrytypes,uzeent3d,uzeentity,SysUtils,uzctnrVectorBytes,uzbtypes,
  uzeconsts,uzglviewareadata,uzMVReader,uzCtnrVectorpBaseEntity;

type

  PGDBObj3DFace=^GDBObj3DFace;

  GDBObj3DFace=object(GDBObj3d)
    PInOCS:OutBound4V;
    PInWCS:OutBound4V;
    normal:TzePoint3d;
    triangle:boolean;
    n,p1,p2,p3:TzePoint3s;
    constructor init(own:Pointer;layeraddres:PGDBLayerProp;
      LW:smallint;p:TzePoint3d);
    constructor initnul(owner:PGDBObjGenericWithSubordinated);
    procedure LoadFromDXF(var rdr:TZMemReader;ptu:PExtensionData;
      var drawing:TDrawingDef;var context:TIODXFLoadContext);virtual;
    procedure SaveToDXF(var outStream:TZctnrVectorBytes;
      var drawing:TDrawingDef;var IODXFContext:TIODXFSaveContext);virtual;
    procedure FormatEntity(var drawing:TDrawingDef;
      var DC:TDrawContext;Stage:TEFStages=EFAllStages);virtual;

    procedure DrawGeometry(lw:integer;var DC:TDrawContext;
      const inFrustumState:TInBoundingVolume);virtual;
    function calcinfrustum(const frustum:ClipArray;
      const Actuality:TVisActuality;var Counters:TCameraCounters;ProjectProc:GDBProjectProc;
      const zoom,currentdegradationfactor:double):boolean;virtual;
    function onmouse(var popa:TZctnrVectorPGDBaseEntity;
      const MF:ClipArray;InSubEntry:boolean):boolean;virtual;
    function CalcTrueInFrustum(
      const frustum:ClipArray):TInBoundingVolume;virtual;
    procedure addcontrolpoints(tdesc:Pointer);virtual;
    procedure remaponecontrolpoint(pdesc:pcontrolpointdesc;
      ProjectProc:GDBProjectProc);virtual;
    procedure rtmodifyonepoint(const rtmod:TRTModifyData);virtual;
    function Clone(own:Pointer):PGDBObjEntity;virtual;
    procedure rtsave(refp:Pointer);virtual;
    function GetObjTypeName:string;virtual;
    procedure getoutbound(var DC:TDrawContext);virtual;
    procedure TransformAt(p:PGDBObjEntity;t_matrix:PDMatrix4d);virtual;
    procedure transform(const t_matrix:DMatrix4d);virtual;
    class function CreateInstance:PGDBObj3DFace;static;
    function GetObjType:TObjID;virtual;
  end;

implementation

procedure GDBObj3DFace.TransformAt;
var
  i:integer;
begin
  for i:=0 to 3 do
    PInOCS[I]:=VectorTransform3D(PGDBObj3DFace(p)^.PInOCS[I],t_matrix^);
end;

procedure GDBObj3DFace.transform(const t_matrix:DMatrix4d);
var
  i:integer;
begin
  for i:=0 to 3 do
    PInOCS[I]:=VectorTransform3D(PInOCS[I],t_matrix);
end;

procedure GDBObj3DFace.getoutbound;
var
  i:integer;
begin
  vp.BoundingBox.LBN:=PInWCS[0];
  vp.BoundingBox.RTF:=PInWCS[0];
  for i:=1 to 3 do
    concatBBandPoint(vp.BoundingBox,PInWCS[I]);
end;

procedure GDBObj3DFace.FormatEntity(var drawing:TDrawingDef;
  var DC:TDrawContext;Stage:TEFStages=EFAllStages);
var
  i:integer;
  v:TzePoint3d;
begin
  if assigned(EntExtensions) then
    EntExtensions.RunOnBeforeEntityFormat(@self,drawing,DC);

  for i:=0 to 3 do begin
    PInWCS[I]:=VectorTransform3D(
      PInOCS[I],bp.ListPos.owner^.GetMatrix^);
  end;
  v:=vectordot(VertexSub(PInWCS[0],PInWCS[1])
    ,VertexSub(PInWCS[2],PInWCS[1]));
  if IsVectorNul(v) then
    normal:=xy_Z_Vertex
  else
    normal:=normalizevertex(v);
  if IsPointEqual(PInOCS[2],PInOCS[3],sqreps) then
    triangle:=True
  else
    triangle:=False;
  calcbb(dc);
  p1.x:=PInWCS[0].x;
  p1.y:=PInWCS[0].y;
  p1.z:=PInWCS[0].z;

  p2.x:=PInWCS[2].x;
  p2.y:=PInWCS[2].y;
  p2.z:=PInWCS[2].z;

  p3.x:=PInWCS[3].x;
  p3.y:=PInWCS[3].y;
  p3.z:=PInWCS[3].z;

  n.x:=normal.x;
  n.y:=normal.y;
  n.z:=normal.z;
  CalcActualVisible(dc.DrawingContext.VActuality);
  if assigned(EntExtensions) then
    EntExtensions.RunOnAfterEntityFormat(@self,drawing,DC);
end;

function GDBObj3DFace.GetObjTypeName;
begin
  Result:=ObjN_GDBObj3DFace;
end;

constructor GDBObj3DFace.init;
begin
  inherited init(own,layeraddres,lw);
  PInOCS[0]:=p;
end;

constructor GDBObj3DFace.initnul;
begin
  inherited initnul(owner);
  bp.ListPos.Owner:=owner;
  PInOCS[1]:=NulVertex;
end;

function GDBObj3DFace.GetObjType;
begin
  Result:=GDB3DfaceID;
end;

procedure GDBObj3DFace.LoadFromDXF;
var
  byt:integer;
begin
  byt:=rdr.ParseInteger;
  while byt<>0 do begin
    if not LoadFromDXFObjShared(rdr,byt,ptu,drawing,context) then
      if not dxfLoadGroupCodeVertex(rdr,10,byt,PInOCS[0]) then
        if not dxfLoadGroupCodeVertex(rdr,11,byt,PInOCS[1]) then
          if not dxfLoadGroupCodeVertex(rdr,12,byt,PInOCS[2]) then
            if not dxfLoadGroupCodeVertex(rdr,13,byt,PInOCS[3]) then
              rdr.SkipString;
    byt:=rdr.ParseInteger;
  end;
end;

procedure GDBObj3DFace.SaveToDXF;
begin
  SaveToDXFObjPrefix(outStream,'3DFACE','AcDbFace',IODXFContext);
  dxfvertexout(outStream,10,PInOCS[0]);
  dxfvertexout(outStream,11,PInOCS[1]);
  dxfvertexout(outStream,12,PInOCS[2]);
  dxfvertexout(outStream,13,PInOCS[3]);
end;

procedure GDBObj3DFace.DrawGeometry;
begin
  if triangle then
    dc.drawer.DrawTriangle3DInModelSpace(normal,PInwCS[0],PInwCS[1],
      PInwCS[2],dc.DrawingContext.matrixs)
  else
    dc.drawer.DrawQuad3DInModelSpace(normal,PInwCS[0],PInwCS[1],
      PInwCS[2],PInwCS[3],dc.DrawingContext.matrixs);
  inherited;
end;

function GDBObj3DFace.CalcInFrustum;
var
  i:integer;
begin
  Result:=True;
  for i:=0 to 4 do begin
    if (frustum[i].v[0]*PInWCS[0].x+frustum[i].v[1]*PInWCS[0].y+
        frustum[i].v[2]*PInWCS[0].z+frustum[i].v[3]<0)
   and (frustum[i].v[0]*PInWCS[1].x+frustum[i].v[1]*PInWCS[1].y+
        frustum[i].v[2]*PInWCS[1].z+frustum[i].v[3]<0)
   and (frustum[i].v[0]*PInWCS[2].x+frustum[i].v[1]*PInWCS[2].y+
        frustum[i].v[2]*PInWCS[2].z+frustum[i].v[3]<0)
   and (frustum[i].v[0]*PInWCS[3].x+frustum[i].v[1]*PInWCS[3].y+
        frustum[i].v[2]*PInWCS[3].z+frustum[i].v[3]<0) then begin
      Result:=False;
      system.break;
    end;
  end;
end;

function GDBObj3DFace.onmouse;
var
  subresult:TInBoundingVolume;
begin
  Result:=False;
  subresult:=CalcOutBound4VInFrustum(PInWCS,mf);
  if subresult<>IRPartially then
    if subresult=irempty then
      exit
    else begin
      Result:=True;
      exit;
    end;
  if uzegeometry.CalcTrueInFrustum(PInwCS[0],PInwCS[1],mf)<>IREmpty
  then
    exit(True);
  if uzegeometry.CalcTrueInFrustum(PInwCS[1],PInwCS[2],mf)<>IREmpty
  then
    exit(True);
  if triangle then begin
    if uzegeometry.CalcTrueInFrustum(PInwCS[2],PInwCS[0],mf)<>IREmpty then
      exit(True);
  end else begin
    if uzegeometry.CalcTrueInFrustum(PInwCS[2],PInwCS[3],mf)<>IREmpty then
      exit(True);
    if uzegeometry.CalcTrueInFrustum(PInwCS[3],PInwCS[0],mf)<>IREmpty then
      exit(True);
  end;
end;

function GDBObj3DFace.CalcTrueInFrustum;
var
  i:integer;
begin
  Result:=CalcOutBound4VInFrustum(PInWCS,frustum);
  if Result<>IRPartially then
    exit;
  i:=0;
  if uzegeometry.CalcPointTrueInFrustum(PInwCS[0],frustum)<>IREmpty then begin
    Inc(i);
  end;
  if uzegeometry.CalcPointTrueInFrustum(PInwCS[1],frustum)<>IREmpty then begin
    Inc(i);
  end;
  if uzegeometry.CalcPointTrueInFrustum(PInwCS[2],frustum)<>IREmpty then begin
    Inc(i);
  end;
  if not triangle then begin
    if uzegeometry.CalcPointTrueInFrustum(PInwCS[3],frustum)<>IREmpty then begin
      Inc(i);
    end;
    if i=4 then
      exit(IRFully);
  end else begin
    if i=3 then
      exit(IRFully);
  end;
  if uzegeometry.CalcTrueInFrustum(PInwCS[0],PInwCS[1],frustum)<>IREmpty then begin
    exit;
  end;
  if uzegeometry.CalcTrueInFrustum(PInwCS[1],PInwCS[2],frustum)<>IREmpty then begin
    exit;
  end;
  if triangle then begin
    if uzegeometry.CalcTrueInFrustum(PInwCS[2],PInwCS[0],frustum)<>IREmpty then
      exit;
  end else begin
    if uzegeometry.CalcTrueInFrustum(PInwCS[2],PInwCS[3],frustum)<>IREmpty then
      exit;
    if uzegeometry.CalcTrueInFrustum(PInwCS[3],PInwCS[0],frustum)<>IREmpty then
      exit;
  end;
  Result:=IRempty;
end;

procedure GDBObj3DFace.remaponecontrolpoint(pdesc:pcontrolpointdesc;
  ProjectProc:GDBProjectProc);
var
  vertexnumber:integer;
  tv:TzePoint3d;
begin
  vertexnumber:=pdesc^.vertexnum;
  pdesc.worldcoord:=PInWCS[vertexnumber];
  ProjectProc(pdesc.worldcoord,tv);
  pdesc.dispcoord:=ToTzePoint2i(tv);
end;

procedure GDBObj3DFace.addcontrolpoints(tdesc:Pointer);
var
  pdesc:controlpointdesc;
  i:integer;
begin
  PSelectedObjDesc(tdesc)^.pcontrolpoint^.init(1);
  pdesc.PDrawable:=nil;
  for i:=0 to 3 do begin
    pdesc.selected:=False;
    pdesc.vertexnum:=i;
    pdesc.attr:=[CPA_Strech];
    pdesc.worldcoord:=PInWCS[i];
    PSelectedObjDesc(tdesc)^.pcontrolpoint^.PushBackData(pdesc);
  end;
end;

procedure GDBObj3DFace.rtmodifyonepoint(const rtmod:TRTModifyData);
var
  vertexnumber:integer;
begin
  vertexnumber:=rtmod.point.vertexnum;
  PInOCS[vertexnumber]:=VertexAdd(rtmod.point.worldcoord,rtmod.dist);
end;

function GDBObj3DFace.Clone;
var
  tvo:PGDBObj3DFace;
begin
  Getmem(Pointer(tvo),sizeof(GDBObj3DFace));
  tvo^.init(bp.ListPos.owner,vp.Layer,vp.LineWeight,nulvertex);
  CopyVPto(tvo^);
  CopyExtensionsTo(tvo^);
  tvo^.bp.ListPos.Owner:=own;
  tvo^.PInOCS:=PInOCS;
  tvo^.PInWCS:=PInWCS;
  Result:=tvo;
end;

procedure GDBObj3DFace.rtsave;
begin
  pGDBObj3DFace(refp)^.PInOCS:=PInOCS;
end;

function Alloc3DFace:PGDBObj3DFace;
begin
  Getmem(pointer(Result),sizeof(GDBObj3DFace));
end;

function AllocAndInit3DFace(owner:PGDBObjGenericWithSubordinated):PGDBObj3DFace;
begin
  Result:=Alloc3DFace;
  Result.initnul(owner);
  Result.bp.ListPos.Owner:=owner;
end;

class function GDBObj3DFace.CreateInstance:PGDBObj3DFace;
begin
  Result:=AllocAndInit3DFace(nil);
end;

begin
  RegisterDXFEntity(GDB3DFaceID,'3DFACE','3DFace',@Alloc3DFace,@AllocAndInit3DFace);
end.
