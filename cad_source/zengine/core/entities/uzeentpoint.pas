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
unit uzeentpoint;
{$Mode delphi}{$H+}
{$INCLUDE zengineconfig.inc}

interface

uses
  uzeentityfactory,uzgldrawcontext,uzeffdxfsupport,uzedrawingdef,uzecamera,
  uzestyleslayers,UGDBSelectedObjArray,uzeentsubordinated,uzeent3d,uzeentity,
  SysUtils,uzctnrVectorBytesStream,uzegeometrytypes,uzeTypes,uzeconsts,
  uzglviewareadata,uzegeometry,uzeSnap,uzMVReader,uzCtnrVectorpBaseEntity;

type
  PGDBObjPoint=^GDBObjPoint;

  GDBObjPoint=object(GDBObj3d)
    P_insertInOCS:TzePoint3d;
    P_insertInWCS:TzePoint3d;
    constructor init(own:Pointer;layeraddres:PGDBLayerProp;
      LW:smallint;p:TzePoint3d);
    constructor initnul(owner:PGDBObjGenericWithSubordinated);
    procedure LoadFromDXF(var rdr:TZMemReader;ptu:PExtensionData;
      var drawing:TDrawingDef;var context:TIODXFLoadContext);virtual;
    procedure SaveToDXF(var outStream:TZctnrVectorBytes;var drawing:TDrawingDef;
      var IODXFContext:TIODXFSaveContext);virtual;
    procedure FormatEntity(var drawing:TDrawingDef;
      var DC:TDrawContext;Stage:TEFStages=EFAllStages);virtual;

    procedure DrawGeometry(lw:integer;
      var DC:TDrawContext;const inFrustumState:TInBoundingVolume);virtual;
    function calcinfrustum(const frustum:TzeFrustum;const Actuality:TVisActuality;
      var Counters:TCameraCounters;ProjectProc:GDBProjectProc;
      const zoom,currentdegradationfactor:double):boolean;virtual;
    function getsnap(var osp:os_record;
      var pdata:Pointer;const param:OGLWndtype;ProjectProc:GDBProjectProc;
      SnapMode:TGDBOSMode):boolean;virtual;
    function onmouse(var popa:TZctnrVectorPGDBaseEntity;
      const MF:TzeFrustum;InSubEntry:boolean):boolean;virtual;
    function CalcTrueInFrustum(const frustum:TzeFrustum):TInBoundingVolume;virtual;
    procedure addcontrolpoints(tdesc:Pointer);virtual;
    procedure remaponecontrolpoint(pdesc:pcontrolpointdesc;
      ProjectProc:GDBProjectProc);virtual;
    procedure rtmodifyonepoint(const rtmod:TRTModifyData);virtual;
    function Clone(own:Pointer):PGDBObjEntity;virtual;
    procedure rtsave(refp:Pointer);virtual;
    function GetObjTypeName:string;virtual;
    procedure getoutbound(var DC:TDrawContext);virtual;

    procedure TransformAt(p:PGDBObjEntity;t_matrix:PzeTypedMatrix4d);virtual;

    function CreateInstance:PGDBObjPoint;static;
    function GetObjType:TObjID;virtual;
  end;

implementation

procedure GDBObjPoint.TransformAt;
begin
  P_insertInOCS:=uzegeometry.VectorTransform3D(PGDBObjPoint(p)^.P_insertInOCS,t_matrix^);
end;

procedure GDBObjPoint.getoutbound;
begin
  vp.BoundingBox.LBN:=P_insertInWCS;
  vp.BoundingBox.RTF:=P_insertInWCS;
  vp.BoundingBox.LBN.x:=vp.BoundingBox.LBN.x-0.1;
  vp.BoundingBox.LBN.y:=vp.BoundingBox.LBN.y-0.1;
  vp.BoundingBox.LBN.z:=vp.BoundingBox.LBN.z-0.1;
  vp.BoundingBox.RTF.x:=vp.BoundingBox.RTF.x+0.1;
  vp.BoundingBox.RTF.y:=vp.BoundingBox.RTF.y+0.1;
  vp.BoundingBox.RTF.z:=vp.BoundingBox.RTF.z+0.1;
end;

procedure GDBObjPoint.FormatEntity(var drawing:TDrawingDef;
  var DC:TDrawContext;Stage:TEFStages=EFAllStages);
begin
  if assigned(EntExtensions) then
    EntExtensions.RunOnBeforeEntityFormat(@self,drawing,DC);

  P_insertInWCS:=VectorTransform3D(P_insertInOCS,bp.ListPos.owner^.GetMatrix^);
  calcbb(dc);
  CalcActualVisible(dc.DrawingContext.VActuality);
  if assigned(EntExtensions) then
    EntExtensions.RunOnAfterEntityFormat(@self,drawing,DC);
end;

function GDBObjPoint.GetObjTypeName;
begin
  Result:=ObjN_GDBObjPoint;
end;

constructor GDBObjPoint.init;
begin
  inherited init(own,layeraddres,lw);
  P_insertInOCS:=p;
end;

constructor GDBObjPoint.initnul;
begin
  inherited initnul(owner);
  bp.ListPos.Owner:=owner;
  P_insertInOCS:=NulVertex;
end;

function GDBObjPoint.GetObjType;
begin
  Result:=GDBPointID;
end;

procedure GDBObjPoint.SaveToDXF;
begin
  SaveToDXFObjPrefix(outStream,'POINT','AcDbPoint',IODXFContext);
  dxfvertexout(outStream,10,P_insertInOCS);
end;

procedure GDBObjPoint.LoadFromDXF;
var
  byt:integer;
begin
  P_insertInOCS:=NulVertex;
  byt:=rdr.ParseInteger;
  while byt<>0 do begin
    case byt of
      8:vp.Layer:=drawing.GetLayerTable.getaddres(rdr.ParseString);
      10:P_insertInOCS.x:=rdr.ParseDouble;
      20:P_insertInOCS.y:=rdr.ParseDouble;
      30:P_insertInOCS.z:=rdr.ParseDouble;
      370:vp.lineweight:=rdr.ParseInteger;
      else
        rdr.SkipString;
    end;
    byt:=rdr.ParseInteger;
  end;
end;

procedure GDBObjPoint.DrawGeometry;
begin
  dc.drawer.DrawPoint3DInModelSpace(P_insertInWCS,dc.DrawingContext.matrixs);
  inherited;
end;

function GDBObjPoint.CalcInFrustum;
var
  i:integer;
begin
  Result:=True;
  for i:=0 to 4 do begin
    if (frustum.v[i].v[0]*P_insertInWCS.x+frustum.v[i].v[1]*
      P_insertInWCS.y+frustum.v[i].v[2]*P_insertInWCS.z+frustum.v[i].v[3]<0) then begin
      Result:=False;
      system.break;
    end;
  end;
end;

function GDBObjPoint.getsnap;
begin
  if onlygetsnapcount=1 then begin
    Result:=False;
    exit;
  end;
  Result:=True;
  case onlygetsnapcount of
    0:begin
      if (SnapMode and osm_point)<>0 then begin
        osp.worldcoord:=P_insertInWCS;
        ProjectProc(osp.worldcoord,osp.dispcoord);
        osp.ostype:=os_point;
      end else
        osp.ostype:=os_none;
    end;
  end;
  Inc(onlygetsnapcount);
end;

function GDBObjPoint.onmouse;
var
  d1:double;
  i:integer;
begin
  for i:=0 to 5 do begin
    d1:=MF.v[i].v[0]*P_insertInWCS.x+MF.v[i].v[1]*P_insertInWCS.y+
      MF.v[i].v[2]*P_insertInWCS.z+MF.v[i].v[3];
    if d1<0 then begin
      Result:=False;
      exit;
    end;
  end;
  Result:=True;
end;

function GDBObjPoint.CalcTrueInFrustum;
var
  d1:double;
  i:integer;
begin
  for i:=0 to 5 do begin
    d1:=frustum.v[i].v[0]*P_insertInWCS.x+frustum.v[i].v[1]*
      P_insertInWCS.y+frustum.v[i].v[2]*P_insertInWCS.z+frustum.v[i].v[3];
    if d1<0 then begin
      Result:=IREmpty;
      exit;
    end;
  end;
  Result:=IRFully;
end;

procedure GDBObjPoint.remaponecontrolpoint(pdesc:pcontrolpointdesc;
  ProjectProc:GDBProjectProc);
var
  tv:TzePoint3d;
begin
  if pdesc^.pointtype=os_point then begin
    pdesc.worldcoord:=P_insertInOCS;
    ProjectProc(pdesc.worldcoord,tv);
    pdesc.dispcoord:=ToTzePoint2i(tv);
  end;
end;

procedure GDBObjPoint.addcontrolpoints(tdesc:Pointer);
var
  pdesc:controlpointdesc;
begin
  PSelectedObjDesc(tdesc)^.pcontrolpoint^.init(1);
  pdesc.selected:=False;
  pdesc.PDrawable:=nil;

  pdesc.pointtype:=os_point;
  pdesc.attr:=[CPA_Strech];
  pdesc.worldcoord:=P_insertInOCS;
  PSelectedObjDesc(tdesc)^.pcontrolpoint^.PushBackData(pdesc);
end;

procedure GDBObjPoint.rtmodifyonepoint(const rtmod:TRTModifyData);
begin
  if rtmod.point.pointtype=os_point then begin
    P_insertInOCS:=VertexAdd(rtmod.point.worldcoord,rtmod.dist);
  end;
end;

function GDBObjPoint.Clone;
var
  tvo:PGDBObjPoint;
begin
  Getmem(Pointer(tvo),sizeof(GDBObjPoint));
  tvo^.init(bp.ListPos.owner,vp.Layer,vp.LineWeight,P_insertInOCS);
  CopyVPto(tvo^);
  CopyExtensionsTo(tvo^);
  Result:=tvo;
end;

procedure GDBObjPoint.rtsave;
begin
  pgdbobjpoint(refp)^.P_insertInOCS:=P_insertInOCS;
end;

function AllocPoint:PGDBObjPoint;
begin
  Getmem(Result,sizeof(GDBObjPoint));
end;

function AllocAndInitPoint(owner:PGDBObjGenericWithSubordinated):PGDBObjPoint;
begin
  Result:=AllocPoint;
  Result.initnul(owner);
  Result.bp.ListPos.Owner:=owner;
end;

function GDBObjPoint.CreateInstance:PGDBObjPoint;
begin
  Result:=AllocAndInitPoint(nil);
end;

begin
  RegisterDXFEntity(GDBPointID,'POINT','Point',@AllocPoint,@AllocAndInitPoint)
end.
