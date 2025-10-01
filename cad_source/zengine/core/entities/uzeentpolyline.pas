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
  uzestyleslayers,uzeentsubordinated,uzeentcurve,
  uzeentity,uzctnrVectorBytes,uzbtypes,uzeconsts,uzglviewareadata,
  uzegeometrytypes,uzegeometry,uzeffdxfsupport,SysUtils,
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
      const MF:ClipArray;InSubEntry:boolean):boolean;virtual;
    function onpoint(var objects:TZctnrVectorPGDBaseEntity;
      const point:GDBVertex):boolean;virtual;
    procedure AddOnTrackAxis(var posr:os_record;
      const processaxis:taddotrac);virtual;
    function GetLength:double;virtual;
    class function CreateInstance:PGDBObjPolyline;static;
    function GetObjType:TObjID;virtual;
    function CalcTrueInFrustum(
      const frustum:ClipArray):TInBoundingVolume;virtual;
  end;

implementation

function GDBObjPolyline.CalcTrueInFrustum;
begin
  Result:=VertexArrayInWCS.CalcTrueInFrustum(frustum,closed);
end;

function GDBObjPolyline.GetLength:double;
var
  ptpv0,ptpv1:PGDBVertex;
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
  const point:GDBVertex):boolean;
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
  Representation.Clear;
  if (not (ESTemp in State))and(DCODrawable in DC.Options) then
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
  tv:gdbvertex;
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
            FastAddVertex(tv);
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

  vertexarrayinocs.SetSize(curveVertexArrayInWCS.Count);
  curveVertexArrayInWCS.copyto(vertexarrayinocs);
  curveVertexArrayInWCS.Clear;
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

begin
  RegisterDXFEntity(GDBPolylineID,'POLYLINE','3DPolyLine',@AllocPolyline,@AllocAndInitPolyline);
end.
