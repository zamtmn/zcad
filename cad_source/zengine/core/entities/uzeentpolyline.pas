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
unit uzeentpolyline;
{$Mode delphi}{$H+}
{$INCLUDE zengineconfig.inc}

interface

uses
  uzeentityfactory,uzgldrawcontext,uzedrawingdef,uzecamera,UGDBVectorSnapArray,
  uzestyleslayers,uzeentsubordinated,uzeentcurve,UGDBSelectedObjArray,
  uzeentity,uzctnrVectorBytes,uzbtypes,uzeconsts,uzglviewareadata,
  uzegeometrytypes,uzegeometry,uzeffdxfsupport,SysUtils,uzesnap,
  uzMVReader,uzCtnrVectorpBaseEntity;

type
  PGDBObjPolyline=^GDBObjPolyline;

  GDBObjPolyline=object(GDBObjCurve)
    Closed:boolean;
    constructor init(own:Pointer;layeraddres:PGDBLayerProp;
      LW:smallint;c:boolean);
    procedure LoadFromDXF(var rdr:TZMemReader;ptu:PExtensionData;
      var drawing:TDrawingDef;var context:TIODXFLoadContext);virtual;

    procedure FormatEntity(var drawing:TDrawingDef;
      var DC:TDrawContext;Stage:TEFStages=EFAllStages);virtual;
    procedure startsnap(out osp:os_record;out pdata:Pointer);virtual;
    function getsnap(var osp:os_record;var pdata:Pointer;
      const param:OGLWndtype;ProjectProc:GDBProjectProc;SnapMode:TGDBOSMode):boolean;virtual;

    procedure SaveToDXF(var outStream:TZctnrVectorBytes;
      var drawing:TDrawingDef;var IODXFContext:TIODXFSaveContext);virtual;
    procedure DrawGeometry(lw:integer;var DC:TDrawContext;
      const inFrustumState:TInBoundingVolume);virtual;
    function Clone(own:Pointer):PGDBObjEntity;virtual;
    function GetObjTypeName:string;virtual;
    function onmouse(var popa:TZctnrVectorPGDBaseEntity;
      const MF:TzeFrustum;InSubEntry:boolean):boolean;virtual;
    function onpoint(var objects:TZctnrVectorPGDBaseEntity;
      const point:TzePoint3d):boolean;virtual;
    procedure AddOnTrackAxis(var posr:os_record;
      const processaxis:taddotrac);virtual;
    function GetLength:double;virtual;
    class function CreateInstance:PGDBObjPolyline;static;
    function GetObjType:TObjID;virtual;
    function CalcTrueInFrustum(
      const frustum:TzeFrustum):TInBoundingVolume;virtual;
    procedure addcontrolpoints(tdesc:Pointer);virtual;
    procedure rtmodifyonepoint(const rtmod:TRTModifyData);virtual;
    procedure remaponecontrolpoint(pdesc:pcontrolpointdesc;
      ProjectProc:GDBProjectProc);virtual;
  end;

  function AllocAndInitPolyline(owner:PGDBObjGenericWithSubordinated):PGDBObjPolyline;
implementation

function GDBObjPolyline.CalcTrueInFrustum;
begin
  Result:=VertexArrayInWCS.CalcTrueInFrustum(frustum,closed);
end;

function GDBObjPolyline.GetLength:double;
var
  ptpv0,ptpv1:PzePoint3d;
begin
  Result:=inherited;
  if closed then begin
    ptpv0:=VertexArrayInWCS.GetParrayAsPointer;
    ptpv1:=VertexArrayInWCS.getDataMutable(VertexArrayInWCS.Count-1);
    Result:=Result+uzegeometry.Vertexlength(ptpv0^,ptpv1^);
  end;
end;

procedure GDBObjPolyline.AddOnTrackAxis(var posr:os_record;const processaxis:taddotrac);
begin
  GDBPoint3dArrayAddOnTrackAxis(VertexArrayInWCS,posr,processaxis,closed);
end;

function GDBObjPolyline.onmouse;
begin
  if VertexArrayInWCS.Count<2 then begin
    Result:=False;
    exit;
  end;
  Result:=VertexArrayInWCS.onmouse(mf,closed);
end;

function GDBObjPolyline.onpoint(var objects:TZctnrVectorPGDBaseEntity;
  const point:TzePoint3d):boolean;
begin
  if VertexArrayInWCS.onpoint(point,closed) then begin
    Result:=True;
    objects.PushBackData(@self);
  end else
    Result:=False;
end;

procedure GDBObjPolyline.startsnap(out osp:os_record;out pdata:Pointer);
begin
  GDBObjEntity.startsnap(osp,pdata);
  Getmem(pdata,sizeof(GDBVectorSnapArray));
  PGDBVectorSnapArray(pdata).init(VertexArrayInWCS.Max);
  BuildSnapArray(VertexArrayInWCS,PGDBVectorSnapArray(pdata)^,closed);
end;

function GDBObjPolyline.getsnap;
begin
  Result:=GDBPoint3dArraygetsnapWOPProjPoint(VertexArrayInWCS,
    PGDBVectorSnapArray(pdata)^,osp,closed,param,ProjectProc,snapmode);
end;

procedure GDBObjPolyline.FormatEntity(var drawing:TDrawingDef;
  var DC:TDrawContext;Stage:TEFStages=EFAllStages);
begin
  if assigned(EntExtensions) then
    EntExtensions.RunOnBeforeEntityFormat(@self,drawing,DC);
  FormatWithoutSnapArray;
  calcbb(dc);
  CalcActualVisible(dc.DrawingContext.VActuality);
  if (not (ESTemp in State))and(DCODrawable in DC.Options) then
    Representation.Clear;
    if VertexArrayInWCS.Count>1 then
      Representation.DrawPolyLineWithLT(dc,VertexArrayInWCS,vp,closed,False);


  if assigned(EntExtensions) then
    EntExtensions.RunOnAfterEntityFormat(@self,drawing,DC);
end;

function GDBObjPolyline.GetObjTypeName;
begin
  Result:=ObjN_GDBObjPolyLine;
end;

constructor GDBObjPolyline.init;
begin
  closed:=c;
  inherited init(own,layeraddres,lw);
end;

function GDBObjPolyline.GetObjType;
begin
  Result:=GDBPolylineID;
end;

procedure GDBObjPolyline.DrawGeometry;
begin
  self.Representation.DrawGeometry(DC,VP.BoundingBox,inFrustumState);
end;

function GDBObjPolyline.Clone;
var
  tpo:PGDBObjPolyLine;
begin
  Getmem(Pointer(tpo),sizeof(GDBObjPolyline));
  tpo^.init(own,vp.Layer,vp.LineWeight,closed);
  CopyVPto(tpo^);
  CopyExtensionsTo(tpo^);
  tpo^.vertexarrayinocs.SetSize(vertexarrayinocs.Count);
  vertexarrayinocs.copyto(tpo^.vertexarrayinocs);
  tpo^.bp.ListPos.owner:=own;
  Result:=tpo;
end;

procedure GDBObjPolyline.SaveToDXF;
begin
  SaveToDXFObjPrefix(outStream,'POLYLINE','AcDb3dPolyline',IODXFContext);
  dxfIntegerout(outStream,66,1);
  dxfvertexout(outStream,10,uzegeometry.NulVertex);
  if closed then
    dxfIntegerout(outStream,70,9)
  else
    dxfIntegerout(outStream,70,8);
end;

procedure GDBObjPolyline.LoadFromDXF;
var
  s:string;
  byt:integer;
  hlGDBWord:integer;
  vertexgo:boolean;
  tv:TzePoint3d;
begin
  closed:=False;
  vertexgo:=False;
  hlGDBWord:=0;
  tv:=NulVertex;
  byt:=rdr.ParseInteger;
  while True do begin
    s:='';
    if not LoadFromDXFObjShared(rdr,byt,ptu,drawing,context) then
      if dxfLoadGroupCodeVertex(rdr,10,byt,tv) then begin
        if byt=30 then
          if vertexgo then
            context.GDBVertexLoadCache.PushBackData(tv);
      end
      else if dxfLoadGroupCodeInteger(rdr,70,byt,hlGDBWord) then begin
        if (hlGDBWord and 1)=1 then
          closed:=True;
      end
      else if dxfLoadGroupCodeString(rdr,0,byt,s) then begin
        if s='VERTEX' then
          vertexgo:=True;
        if s='SEQEND' then
          system.Break;
      end else
        s:=rdr.ParseString;
    byt:=rdr.ParseInteger;
  end;

  vertexarrayinocs.SetSize(context.GDBVertexLoadCache.Count);
  context.GDBVertexLoadCache.copyto(vertexarrayinocs);
  context.GDBVertexLoadCache.Clear;
end;

function AllocPolyline:PGDBObjPolyline;
begin
  Getmem(pointer(Result),sizeof(GDBObjPolyline));
end;

function AllocAndInitPolyline(owner:PGDBObjGenericWithSubordinated):PGDBObjPolyline;
begin
  Result:=AllocPolyline;
  Result.initnul(owner);
  Result.bp.ListPos.Owner:=owner;
end;

class function GDBObjPolyline.CreateInstance:PGDBObjPolyline;
begin
  Result:=AllocAndInitPolyline(nil);
end;

procedure GDBObjPolyline.addcontrolpoints(tdesc:Pointer);
var
  pdesc:controlpointdesc;
  i:integer;
  pv,pvnext:PzePoint3d;
  segmentCount:integer;
begin
  if closed then
    segmentCount:=VertexArrayInWCS.Count
  else
    segmentCount:=VertexArrayInWCS.Count-1;

  PSelectedObjDesc(tdesc)^.pcontrolpoint^.init(VertexArrayInWCS.Count+segmentCount);

  pdesc.selected:=False;
  pdesc.PDrawable:=nil;

  for i:=0 to VertexArrayInWCS.Count-1 do begin
    pv:=VertexArrayInWCS.getDataMutable(i);
    pdesc.vertexnum:=i;
    pdesc.attr:=[CPA_Strech];
    pdesc.worldcoord:=pv^;
    PSelectedObjDesc(tdesc)^.pcontrolpoint^.PushBackData(pdesc);
  end;

  pdesc.attr:=[];
  for i:=0 to segmentCount-1 do begin
    pv:=VertexArrayInWCS.getDataMutable(i);
    if i<VertexArrayInWCS.Count-1 then
      pvnext:=VertexArrayInWCS.getDataMutable(i+1)
    else
      pvnext:=VertexArrayInWCS.getDataMutable(0);

    pdesc.vertexnum:=-(i+1);
    pdesc.pointtype:=os_midle;
    pdesc.worldcoord:=Vertexmorph(pv^,pvnext^,0.5);
        // Store segment direction in dcoord for oriented grip drawing
    pdesc.dcoord:=VertexSub(pvnext^,pv^);
    PSelectedObjDesc(tdesc)^.pcontrolpoint^.PushBackData(pdesc);
  end;
end;

procedure GDBObjPolyline.rtmodifyonepoint(const rtmod:TRTModifyData);
var
  segmentIndex:integer;
  v1,v2:PzePoint3d;
  offset:TzePoint3d;
  halfVector,newCenter:TzePoint3d;
begin
  if rtmod.point.vertexnum>=0 then begin
    inherited rtmodifyonepoint(rtmod);
  end else begin
    segmentIndex:=-(rtmod.point.vertexnum+1);
    v1:=vertexarrayinocs.getDataMutable(segmentIndex);
    if segmentIndex<VertexArrayInWCS.Count-1 then
      v2:=vertexarrayinocs.getDataMutable(segmentIndex+1)
    else
      v2:=vertexarrayinocs.getDataMutable(0);
       // Calculate half-vector (from center to each endpoint)
    halfVector:=uzegeometry.VertexSub(v2^,v1^);
    halfVector:=uzegeometry.VertexMulOnSc(halfVector,0.5);

    // Calculate new center position
    newCenter:=VertexAdd(rtmod.point.worldcoord,rtmod.dist);

    // Set both vertices relative to new center
    v1^:=VertexSub(newCenter,halfVector);
    v2^:=VertexAdd(newCenter,halfVector);
    //offset:=rtmod.dist;
    //v1^:=VertexAdd(v1^,offset);
    //v2^:=VertexAdd(v2^,offset);
  end;
end;

procedure GDBObjPolyline.remaponecontrolpoint(pdesc:pcontrolpointdesc;
  ProjectProc:GDBProjectProc);
var
  segmentIndex:integer;
  v1,v2:PzePoint3d;
  tv:TzePoint3d;
begin
  if pdesc^.vertexnum>=0 then begin
    inherited remaponecontrolpoint(pdesc,ProjectProc);
  end else begin
    segmentIndex:=-(pdesc^.vertexnum+1);
    v1:=VertexArrayInWCS.getDataMutable(segmentIndex);
    if segmentIndex<VertexArrayInWCS.Count-1 then
      v2:=VertexArrayInWCS.getDataMutable(segmentIndex+1)
    else
      v2:=VertexArrayInWCS.getDataMutable(0);

    pdesc.worldcoord:=Vertexmorph(v1^,v2^,0.5);
    ProjectProc(pdesc.worldcoord,tv);
    pdesc.dispcoord:=ToTzePoint2i(tv);
  end;
end;

begin
  RegisterDXFEntity(GDBPolylineID,'POLYLINE','3DPolyLine',@AllocPolyline,@AllocAndInitPolyline);
end.
