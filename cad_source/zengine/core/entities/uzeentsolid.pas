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
unit uzeentsolid;
{$Mode delphi}{$H+}
{$INCLUDE zengineconfig.inc}

interface

uses
  uzeentityfactory,uzgldrawcontext,uzedrawingdef,uzecamera,uzeentwithlocalcs,
  uzegeometry,uzeffdxfsupport,uzestyleslayers,
  UGDBSelectedObjArray,uzeentsubordinated,uzeentity,SysUtils,uzctnrVectorBytes,
  uzegeometrytypes,uzbtypes,uzeconsts,uzglviewareadata,
  uzMVReader,uzCtnrVectorpBaseEntity;

type

  PGDBObjSolid=^GDBObjSolid;

  GDBObjSolid=object(GDBObjWithLocalCS)
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
    procedure createpoint;virtual;
    procedure DrawGeometry(lw:integer;var DC:TDrawContext;
      const inFrustumState:TInBoundingVolume);virtual;
    function calcinfrustum(const frustum:TzeFrustum;
      const Actuality:TVisActuality;var Counters:TCameraCounters;ProjectProc:GDBProjectProc;
      const zoom,currentdegradationfactor:double):boolean;virtual;
    function onmouse(var popa:TZctnrVectorPGDBaseEntity;
      const MF:TzeFrustum;InSubEntry:boolean):boolean;virtual;
    function CalcTrueInFrustum(
      const frustum:TzeFrustum):TInBoundingVolume;virtual;
    procedure addcontrolpoints(tdesc:Pointer);virtual;
    procedure remaponecontrolpoint(pdesc:pcontrolpointdesc;
      ProjectProc:GDBProjectProc);virtual;
    procedure rtmodifyonepoint(const rtmod:TRTModifyData);virtual;
    function Clone(own:Pointer):PGDBObjEntity;virtual;
    procedure rtsave(refp:Pointer);virtual;
    function GetObjTypeName:string;virtual;
    procedure getoutbound(var DC:TDrawContext);virtual;
    function CreateInstance:PGDBObjSolid;static;
    function GetObjType:TObjID;virtual;
    procedure TransformAt(p:PGDBObjEntity;t_matrix:PDMatrix4d);virtual;
    procedure transform(const t_matrix:DMatrix4d);virtual;
  end;

implementation

procedure GDBObjSolid.TransformAt;
begin
  PInOCS[0]:=uzegeometry.VectorTransform3D(PGDBObjSolid(p)^.PInOCS[0],t_matrix^);
  PInOCS[1]:=uzegeometry.VectorTransform3D(PGDBObjSolid(p)^.PInOCS[1],t_matrix^);
  PInOCS[2]:=uzegeometry.VectorTransform3D(PGDBObjSolid(p)^.PInOCS[2],t_matrix^);
  PInOCS[3]:=uzegeometry.VectorTransform3D(PGDBObjSolid(p)^.PInOCS[3],t_matrix^);
end;

procedure GDBObjSolid.transform;
begin
  PInOCS[0]:=uzegeometry.VectorTransform3D(PInOCS[0],t_matrix);
  PInOCS[1]:=uzegeometry.VectorTransform3D(PInOCS[1],t_matrix);
  PInOCS[2]:=uzegeometry.VectorTransform3D(PInOCS[2],t_matrix);
  PInOCS[3]:=uzegeometry.VectorTransform3D(PInOCS[3],t_matrix);
end;

procedure GDBObjSolid.getoutbound;
var
  i:integer;
begin
  vp.BoundingBox.LBN:=PInWCS[0];
  vp.BoundingBox.RTF:=PInWCS[0];
  for i:=1 to 3 do begin
    concatBBandPoint(vp.BoundingBox,PInWCS[I]);
  end;
end;

procedure GDBObjSolid.FormatEntity(var drawing:TDrawingDef;
  var DC:TDrawContext;Stage:TEFStages=EFAllStages);
begin
  if assigned(EntExtensions) then
    EntExtensions.RunOnBeforeEntityFormat(@self,drawing,DC);
  calcObjMatrix;
  createpoint;
  normal:=normalizevertex(vectordot(
    uzegeometry.VertexSub(PInWCS[0],PInWCS[1])
    ,
    uzegeometry.VertexSub(
    PInWCS[2],PInWCS[1])));
  if uzegeometry.IsPointEqual(PInOCS[2],PInOCS[3],sqreps) then
    triangle:=True
  else
    triangle:=False;
  calcbb(dc);
  CalcActualVisible(dc.DrawingContext.VActuality);
  if assigned(EntExtensions) then
    EntExtensions.RunOnAfterEntityFormat(@self,drawing,DC);
end;

procedure GDBObjSolid.createpoint;
begin
  PInWCS[0]:=VectorTransform3D(PInOCS[0],objmatrix);
  PInWCS[1]:=VectorTransform3D(PInOCS[1],objmatrix);
  PInWCS[2]:=VectorTransform3D(PInOCS[2],objmatrix);
  PInWCS[3]:=VectorTransform3D(PInOCS[3],objmatrix);
end;

function GDBObjSolid.GetObjTypeName;
begin
  Result:=ObjN_GDBObjSolid;
end;

constructor GDBObjSolid.init;
begin
  inherited init(own,layeraddres,lw);
  PInOCS[0]:=p;
end;

constructor GDBObjSolid.initnul;
begin
  inherited initnul(owner);
  bp.ListPos.Owner:=owner;
  PInOCS[1]:=NulVertex;
end;

function GDBObjSolid.GetObjType;
begin
  Result:=GDBSolidID;
end;

procedure GDBObjSolid.LoadFromDXF;
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
              rdr.ParseString;
    byt:=rdr.ParseInteger;
  end;
end;

procedure GDBObjSolid.SaveToDXF;
begin
  SaveToDXFObjPrefix(outStream,'SOLID','AcDbTrace',IODXFContext);
  dxfvertexout(outStream,10,PInOCS[0]);
  dxfvertexout(outStream,11,PInOCS[1]);
  dxfvertexout(outStream,12,PInOCS[2]);
  dxfvertexout(outStream,13,PInOCS[3]);
  SaveToDXFObjPostfix(outStream);
end;

procedure GDBObjSolid.DrawGeometry;
begin
  if triangle then
    dc.drawer.DrawTriangle3DInModelSpace(normal,PInwCS[0],PInwCS[1],
      PInwCS[2],dc.DrawingContext.matrixs)
  else
    dc.drawer.DrawQuad3DInModelSpace(normal,PInwCS[0],PInwCS[1],PInwCS[2],
      PInwCS[3],dc.DrawingContext.matrixs);
  inherited;
end;

function GDBObjSolid.CalcInFrustum;
var
  i:integer;
begin
  Result:=True;
  for i:=0 to 4 do begin
    if (frustum.v[i].v[0]*PInWCS[0].x+frustum.v[i].v[1]*PInWCS[0].y+
      frustum.v[i].v[2]*PInWCS[0].z+frustum.v[i].v[3]<0)  and
      (frustum.v[i].v[0]*PInWCS[1].x+frustum.v[i].v[1]*PInWCS[1].y+
      frustum.v[i].v[2]*PInWCS[1].z+frustum.v[i].v[3]<0)  and
      (frustum.v[i].v[0]*PInWCS[2].x+frustum.v[i].v[1]*PInWCS[2].y+
      frustum.v[i].v[2]*PInWCS[2].z+frustum.v[i].v[3]<0)  and
      (frustum.v[i].v[0]*PInWCS[3].x+frustum.v[i].v[1]*PInWCS[3].y+
      frustum.v[i].v[2]*PInWCS[3].z+frustum.v[i].v[3]<0) then begin
      Result:=False;
      system.break;
    end;
  end;
end;

function GDBObjSolid.onmouse;
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
  Result:=True;
end;

function GDBObjSolid.CalcTrueInFrustum;
begin
  Result:=CalcOutBound4VInFrustum(PInWCS,frustum);
end;

procedure GDBObjSolid.remaponecontrolpoint(pdesc:pcontrolpointdesc;
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

procedure GDBObjSolid.addcontrolpoints(tdesc:Pointer);
var
  pdesc:controlpointdesc;
  i:integer;
begin
  PSelectedObjDesc(tdesc)^.pcontrolpoint^.init(1);
  pdesc.selected:=False;
  pdesc.PDrawable:=nil;

  for i:=0 to 3 do begin
    pdesc.vertexnum:=i;
    pdesc.attr:=[CPA_Strech];
    pdesc.worldcoord:=PInWCS[i];
    PSelectedObjDesc(tdesc)^.pcontrolpoint^.PushBackData(pdesc);
  end;
end;

procedure GDBObjSolid.rtmodifyonepoint(const rtmod:TRTModifyData);
var
  vertexnumber:integer;
  tv,wwc:TzePoint3d;
  M:DMatrix4d;
begin
  vertexnumber:=rtmod.point.vertexnum;

  m:=self.ObjMatrix;
  uzegeometry.MatrixInvert(m);


  tv:=rtmod.dist;
  wwc:=rtmod.point.worldcoord;

  wwc:=VertexAdd(wwc,tv);
  wwc:=uzegeometry.VectorTransform3D(wwc,m);

  PInOCS[vertexnumber]:=wwc;
end;

function GDBObjSolid.Clone;
var
  tvo:PGDBObjSolid;
begin
  Getmem(Pointer(tvo),sizeof(GDBObjSolid));
  tvo^.init(bp.ListPos.owner,vp.Layer,vp.LineWeight,nulvertex);
  tvo^.Local:=local;
  CopyVPto(tvo^);
  CopyExtensionsTo(tvo^);
  tvo^.bp.ListPos.Owner:=own;
  tvo^.PInOCS:=PInOCS;
  tvo^.PInWCS:=PInWCS;
  Result:=tvo;
end;

procedure GDBObjSolid.rtsave;
begin
  pGDBObjSolid(refp)^.PInOCS:=PInOCS;
end;

function AllocSolid:PGDBObjSolid;
begin
  Getmem(Result,sizeof(GDBObjSolid));
end;

function AllocAndInitSolid(owner:PGDBObjGenericWithSubordinated):PGDBObjSolid;
begin
  Result:=AllocSolid;
  Result.initnul(owner);
  Result.bp.ListPos.Owner:=owner;
end;

procedure SetSolidGeomProps(PSolid:PGDBObjSolid;const args:array of const);
var
  counter:integer;
begin
  counter:=low(args);
  PSolid^.PInOCS[0]:=CreateVertexFromArray(counter,args);
  PSolid^.PInOCS[1]:=CreateVertexFromArray(counter,args);
  PSolid^.PInOCS[2]:=CreateVertexFromArray(counter,args);
  if counter>=high(args) then
    PSolid^.PInOCS[3]:=PSolid^.PInOCS[2]
  else
    PSolid^.PInOCS[3]:=CreateVertexFromArray(counter,args);
end;

function AllocAndCreateSolid(owner:PGDBObjGenericWithSubordinated;
  const args:array of const):PGDBObjSolid;
begin
  Result:=AllocAndInitSolid(owner);
  SetSolidGeomProps(Result,args);
end;

function GDBObjSolid.CreateInstance:PGDBObjSolid;
begin
  Result:=AllocAndInitSolid(nil);
end;

begin
  RegisterDXFEntity(GDBSolidID,'SOLID','Solid',@AllocSolid,@AllocAndInitSolid,
    @SetSolidGeomProps,@AllocAndCreateSolid);
end.
