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
unit uzeentcurve;
{$Mode delphi}{$H+}
{$INCLUDE zengineconfig.inc}

interface

uses
  uzgldrawcontext,uzedrawingdef,uzecamera,uzctnrVectorBytes,uzestyleslayers,
  UGDBVectorSnapArray,UGDBSelectedObjArray,uzeent3d,uzeentity,UGDBPoint3DArray,
  uzbtypes,uzegeometry,uzeconsts,uzglviewareadata,uzeffdxfsupport,SysUtils,
  gzctnrVectorTypes,uzegeometrytypes,uzeentsubordinated,uzeSnap,
  uzCtnrVectorpBaseEntity;

type
  PGDBObjCurve=^GDBObjCurve;

  GDBObjCurve=object(GDBObj3d)
    VertexArrayInOCS:GDBPoint3dArray;
    VertexArrayInWCS:GDBPoint3dArray;
    length:double;
    constructor init(own:Pointer;layeraddres:PGDBLayerProp;LW:smallint);
    constructor initnul(owner:PGDBObjGenericWithSubordinated);
    procedure FormatEntity(var drawing:TDrawingDef;
      var DC:TDrawContext;Stage:TEFStages=EFAllStages);virtual;
    procedure FormatWithoutSnapArray;virtual;
    procedure DrawGeometry(lw:integer;var DC:TDrawContext;
      const inFrustumState:TInBoundingVolume);virtual;
    function Clone(own:Pointer):PGDBObjEntity;virtual;
    procedure rtsave(refp:Pointer);virtual;
    function onmouse(var popa:TZctnrVectorPGDBaseEntity;
      const MF:ClipArray;InSubEntry:boolean):boolean;virtual;
    function onpoint(var objects:TZctnrVectorPGDBaseEntity;
      const point:GDBVertex):boolean;virtual;
    procedure rtmodifyonepoint(const rtmod:TRTModifyData);virtual;
    procedure remaponecontrolpoint(pdesc:pcontrolpointdesc;
      ProjectProc:GDBProjectProc);virtual;
    procedure addcontrolpoints(tdesc:Pointer);virtual;
    function getsnap(var osp:os_record;var pdata:Pointer;
      const param:OGLWndtype;ProjectProc:GDBProjectProc;SnapMode:TGDBOSMode):boolean;virtual;
    procedure startsnap(out osp:os_record;out pdata:Pointer);virtual;
    procedure endsnap(out osp:os_record;var pdata:Pointer);virtual;

    destructor done;virtual;
    function GetObjTypeName:string;virtual;
    procedure getoutbound(var DC:TDrawContext);virtual;

    procedure AddVertex(const Vertex:GDBVertex);virtual;

    procedure SaveToDXFfollow(var outStream:TZctnrVectorBytes;
      var drawing:TDrawingDef;var IODXFContext:TIODXFSaveContext);virtual;
    procedure TransformAt(p:PGDBObjEntity;t_matrix:PDMatrix4D);virtual;
    procedure transform(const t_matrix:DMatrix4D);virtual;

    function CalcTrueInFrustum(
      const frustum:ClipArray):TInBoundingVolume;virtual;
    procedure AddOnTrackAxis(var posr:os_record;
      const processaxis:taddotrac);virtual;
    procedure InsertVertex(const PolyData:TPolyData);
    procedure DeleteVertex(const PolyData:TPolyData);

    function GetLength:double;virtual;
  end;

procedure BuildSnapArray(const VertexArrayInWCS:GDBPoint3dArray;
  var snaparray:GDBVectorSnapArray;const closed:boolean);
function GDBPoint3dArraygetsnapWOPProjPoint(const VertexArrayInWCS:GDBPoint3dArray;
  const snaparray:GDBVectorSnapArray;var osp:os_record;
  const closed:boolean;const param:OGLWndtype;
  ProjectProc:GDBProjectProc;SnapMode:TGDBOSMode):boolean;
procedure GDBPoint3dArrayAddOnTrackAxis(const VertexArrayInWCS:GDBPoint3dArray;
  var posr:os_record;const processaxis:taddotrac;const closed:boolean);
function GetDirInPoint(const VertexArrayInWCS:GDBPoint3dArray;
  point:GDBVertex;closed:boolean):GDBVertex;

implementation

procedure GDBObjCurve.InsertVertex(const PolyData:TPolyData);
begin
  vertexarrayinocs.InsertElement(PolyData.index,PolyData.wc);
end;

procedure GDBObjCurve.DeleteVertex(const PolyData:TPolyData);
begin
  vertexarrayinocs.deleteelement(PolyData.index);
end;

function GetDirInPoint(const VertexArrayInWCS:GDBPoint3dArray;
  point:GDBVertex;closed:boolean):GDBVertex;
var
  ptv,ppredtv:pgdbvertex;
  ir:itrec;
  found:integer;
begin
  if not closed then begin
    ppredtv:=VertexArrayInWCS.beginiterate(ir);
    ptv:=VertexArrayInWCS.iterate(ir);
  end else begin
    if VertexArrayInWCS.Count<3 then
      exit;
    ptv:=VertexArrayInWCS.beginiterate(ir);
    ppredtv:=
      VertexArrayInWCS.getDataMutable(VertexArrayInWCS.Count-1);
  end;
  found:=0;
  if (ptv<>nil)and(ppredtv<>nil) then
    repeat
      if (abs(ptv^.x-point.x)<eps)  and (abs(ptv^.y-point.y)<eps)
      and(abs(ptv^.z-point.z)<eps) then begin
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
      ptv:=VertexArrayInWCS.iterate(ir);
    until ptv=nil;
end;

procedure GDBPoint3dArrayAddOnTrackAxis(const VertexArrayInWCS:GDBPoint3dArray;
  var posr:os_record;const processaxis:taddotrac;const closed:boolean);
var
  tv:gdbvertex;
  ptv,ppredtv:pgdbvertex;
  ir:itrec;
  found:integer;
begin
  if not closed then begin
    ppredtv:=VertexArrayInWCS.beginiterate(ir);
    ptv:=VertexArrayInWCS.iterate(ir);
  end else begin
    if VertexArrayInWCS.Count<3 then
      exit;
    ptv:=VertexArrayInWCS.beginiterate(ir);
    ppredtv:=VertexArrayInWCS.getDataMutable(VertexArrayInWCS.Count-1);
  end;
  found:=0;
  if (ptv<>nil)and(ppredtv<>nil) then
    repeat
      if (abs(ptv^.x-posr.worldcoord.x)<eps)  and
        (abs(ptv^.y-posr.worldcoord.y)<eps)  and (abs(ptv^.z-posr.worldcoord.z)<eps)
      then begin
        found:=2;
      end
      else if (found=0)and(SQRdist_Point_to_Segment(posr.worldcoord,ppredtv^,ptv^)<
        bigeps) then
      begin
        found:=1;
      end;

      if found>0 then begin
        tv:=vertexsub(ptv^,ppredtv^);
        tv:=uzegeometry.NormalizeVertex(tv);
        processaxis(posr,tv);
        tv:=uzegeometry.VectorDot(tv,zwcs);
        processaxis(posr,tv);
        Dec(found);
      end;

      ppredtv:=ptv;
      ptv:=VertexArrayInWCS.iterate(ir);
    until ptv=nil;
end;

procedure GDBObjCurve.AddOnTrackAxis(var posr:os_record;const processaxis:taddotrac);
begin
  GDBPoint3dArrayAddOnTrackAxis(VertexArrayInWCS,posr,processaxis,False);
end;

function GDBObjCurve.CalcTrueInFrustum;
begin
  Result:=VertexArrayInWCS.CalcTrueInFrustum(frustum,False);
end;

procedure GDBObjCurve.SaveToDXFFollow;
var
  ptv:pgdbvertex;
  ir:itrec;
begin
  ptv:=vertexarrayinocs.beginiterate(ir);
  if ptv<>nil then
    repeat
      SaveToDXFObjPrefix(outStream,'VERTEX','AcDbVertex',IODXFContext,True);
      dxfStringout(outStream,100,'AcDb3dPolylineVertex');
      dxfvertexout(outStream,10,ptv^);

      ptv:=vertexarrayinocs.iterate(ir);
    until ptv=nil;
  SaveToDXFObjPrefix(outStream,'SEQEND','',IODXFContext,True);
end;

procedure GDBObjCurve.AddVertex(const Vertex:GDBVertex);
begin
  vertexarrayinocs.PushBackData(vertex);
end;

procedure GDBObjCurve.getoutbound;
begin
  vp.BoundingBox:=VertexArrayInWCS.getoutbound;
end;

function GDBObjCurve.GetObjTypeName;
begin
  Result:=ObjN_GDBObjCurve;
end;

destructor GDBObjCurve.done;
begin
  VertexArrayInWCS.done;
  vertexarrayinocs.done;
  inherited;
end;

constructor GDBObjCurve.init;
begin
  inherited init(own,layeraddres,lw);
  VertexArrayInWCS.init(10);
  vertexarrayinocs.init(10);
end;

constructor GDBObjCurve.initnul;
begin
  inherited initnul(nil);
  bp.ListPos.Owner:=owner;
  VertexArrayInWCS.init(10);
  vertexarrayinocs.init(10);
end;

procedure GDBObjCurve.DrawGeometry;
begin
  DC.drawer.DrawContour3DInModelSpace(VertexArrayInWCS,DC.DrawingContext.matrixs);
  inherited;
end;

procedure BuildSnapArray(const VertexArrayInWCS:GDBPoint3dArray;
  var snaparray:GDBVectorSnapArray;const closed:boolean);
var
  ptv,ptvprev:pgdbvertex;
  vs:VectorSnap;
  ir:itrec;
begin
  snaparray.Clear;
  ptvprev:=VertexArrayInWCS.beginiterate(ir);
  ptv:=VertexArrayInWCS.iterate(ir);
  if ptv<>nil then
    repeat
      vs.l_1_4:=vertexmorph(ptvprev^,ptv^,1/4);
      vs.l_1_3:=vertexmorph(ptvprev^,ptv^,1/3);
      vs.l_1_2:=vertexmorph(ptvprev^,ptv^,1/2);
      vs.l_2_3:=vertexmorph(ptvprev^,ptv^,2/3);
      vs.l_3_4:=vertexmorph(ptvprev^,ptv^,3/4);
      snaparray.PushBackData(vs);
      ptvprev:=ptv;
      ptv:=VertexArrayInWCS.iterate(ir);
    until ptv=nil;
  if closed then begin
    ptv:=VertexArrayInWCS.beginiterate(ir);
    vs.l_1_4:=vertexmorph(ptvprev^,ptv^,1/4);
    vs.l_1_3:=vertexmorph(ptvprev^,ptv^,1/3);
    vs.l_1_2:=vertexmorph(ptvprev^,ptv^,1/2);
    vs.l_2_3:=vertexmorph(ptvprev^,ptv^,2/3);
    vs.l_3_4:=vertexmorph(ptvprev^,ptv^,3/4);
    snaparray.PushBackData(vs);
  end;
  snaparray.Shrink;
end;

function GDBObjCurve.GetLength:double;
var
  ptv,ptvprev:pgdbvertex;
  ir:itrec;
begin
  Result:=0;
  ptvprev:=VertexArrayInWCS.beginiterate(ir);
  ptv:=VertexArrayInWCS.iterate(ir);
  if ptv<>nil then
    repeat
      Result:=Result+uzegeometry.Vertexlength(ptv^,ptvprev^);
      ptvprev:=ptv;
      ptv:=VertexArrayInWCS.iterate(ir);
    until ptv=nil;
end;

procedure GDBObjCurve.FormatWithoutSnapArray;
var
  ptv:pgdbvertex;
  tv:gdbvertex;
  ir:itrec;
begin
  VertexArrayInWCS.Clear;
  VertexArrayInWCS.SetSize(VertexArrayInOCS.Count);
  ptv:=VertexArrayInOCS.beginiterate(ir);
  if ptv<>nil then
    repeat
      tv:=VectorTransform3D(ptv^,bp.ListPos.owner^.GetMatrix^);
      VertexArrayInWCS.PushBackData(tv);
      ptv:=vertexarrayinocs.iterate(ir);
    until ptv=nil;

  VertexArrayInOCS.Shrink;
  VertexArrayInWCS.Shrink;
  length:=GetLength;
end;

procedure GDBObjCurve.FormatEntity(var drawing:TDrawingDef;
  var DC:TDrawContext;Stage:TEFStages=EFAllStages);
begin
  FormatWithoutSnapArray;
  calcbb(dc);
  CalcActualVisible(dc.DrawingContext.VActuality);
end;

procedure GDBObjCurve.TransformAt(p:PGDBObjEntity;t_matrix:PDMatrix4D);
var
  ptv,ptv2:pgdbvertex;
  ir,ir2:itrec;
begin
  ptv:=VertexArrayInOCS.beginiterate(ir);
  ptv2:=PGDBObjCurve(p)^.VertexArrayInOCS.beginiterate(ir2);
  if (ptv<>nil)and(ptv2<>nil) then
    repeat
      ptv^:=VectorTransform3D(ptv2^,t_matrix^);
      ptv:=vertexarrayinocs.iterate(ir);
      ptv2:=PGDBObjCurve(p)^.VertexArrayInOCS.iterate(ir2);
    until (ptv=nil)or(ptv2=nil);
end;

procedure GDBObjCurve.transform(const t_matrix:DMatrix4D);
var
  ptv:pgdbvertex;
  ir:itrec;
begin
  ptv:=VertexArrayInOCS.beginiterate(ir);
  if (ptv<>nil) then
    repeat
      ptv^:=VectorTransform3D(ptv^,t_matrix);
      ptv:=vertexarrayinocs.iterate(ir);
    until (ptv=nil);
end;

function GDBObjCurve.Clone;
var
  tpo:PGDBObjCurve;
  p:pgdbvertex;
  i:integer;
begin
  Getmem(Pointer(tpo),sizeof(GDBObjCurve));
  tpo^.init(bp.ListPos.owner,vp.Layer,vp.LineWeight);
  CopyExtensionsTo(tpo^);
  p:=vertexarrayinocs.GetParrayAsPointer;
  for i:=0 to VertexArrayInWCS.Count-1 do begin
    tpo^.vertexarrayinocs.PushBackData(p^);
    Inc(p);
  end;
  Result:=tpo;
end;

procedure GDBObjCurve.rtsave;
var
  p,pold:pgdbvertex;
  i:integer;
begin
  p:=vertexarrayinocs.GetParrayAsPointer;
  pold:=pgdbobjcurve(refp)^.vertexarrayinocs.GetParrayAsPointer;
  for i:=0 to vertexarrayinocs.Count-1 do begin
    pold^:=p^;
    Inc(pold);
    Inc(p);
  end;
end;

function GDBObjCurve.onmouse;
begin
  if VertexArrayInWCS.Count<2 then begin
    Result:=False;
    exit;
  end;
  Result:=VertexArrayInWCS.onmouse(mf,False);
end;

function GDBObjCurve.onpoint(var objects:TZctnrVectorPGDBaseEntity;
  const point:GDBVertex):boolean;
begin
  if VertexArrayInWCS.onpoint(point,False) then begin
    Result:=True;
    objects.PushBackData(@self);
  end else
    Result:=False;
end;

procedure GDBObjCurve.rtmodifyonepoint(const rtmod:TRTModifyData);
var
  vertexnumber:integer;
begin
  vertexnumber:=rtmod.point.vertexnum;
  GDBPoint3dArray.PTArr(vertexarrayinocs.parray)^[vertexnumber]:=
    VertexAdd(rtmod.point.worldcoord,rtmod.dist);
end;

procedure GDBObjCurve.remaponecontrolpoint(pdesc:pcontrolpointdesc;
  ProjectProc:GDBProjectProc);
var
  vertexnumber:integer;
  tv:GDBvertex;
begin
  vertexnumber:=pdesc^.vertexnum;
  pdesc.worldcoord:=GDBPoint3dArray.PTArr(VertexArrayInWCS.parray)^[vertexnumber];
  ProjectProc(pdesc.worldcoord,tv);
  pdesc.dispcoord:=ToVertex2DI(tv);
end;

procedure GDBObjCurve.addcontrolpoints;
var
  pdesc:controlpointdesc;
  i:integer;
  pv:pGDBvertex;
begin
  PSelectedObjDesc(tdesc)^.pcontrolpoint^.init(VertexArrayInWCS.Count);
  pv:=VertexArrayInWCS.GetParrayAsPointer;
  pdesc.selected:=False;
  pdesc.PDrawable:=nil;

  for i:=0 to VertexArrayInWCS.Count-1 do begin
    pdesc.vertexnum:=i;
    pdesc.attr:=[CPA_Strech];
    pdesc.worldcoord:=pv^;
    PSelectedObjDesc(tdesc)^.pcontrolpoint^.PushBackData(pdesc);
    Inc(pv);
  end;
end;

function GDBPoint3dArraygetsnapWOPProjPoint(const VertexArrayInWCS:GDBPoint3dArray;
  const snaparray:GDBVectorSnapArray;var osp:os_record;
  const closed:boolean;const param:OGLWndtype;
  ProjectProc:GDBProjectProc;SnapMode:TGDBOSMode):boolean;
const
  pnum=8;
var
  t,d,e:double;
  tv,n,v,dir:gdbvertex;
  mode,vertexnum,tc:integer;
  pv1:PGDBVertex;
  pv2:PGDBVertex;
begin
  vertexnum:=(VertexArrayInWCS.Count)*pnum;
  if onlygetsnapcount>vertexnum then begin
    Result:=False;
    exit;
  end;
  tc:=VertexArrayInWCS.Count;
  if not closed then
    tc:=tc-1;
  Result:=True;
  mode:=onlygetsnapcount mod pnum;
  vertexnum:=onlygetsnapcount div pnum;
  osp.ostype:=os_none;
  case mode of
    0:if (SnapMode and osm_endpoint)<>0 then begin
        osp.worldcoord:=
          GDBPoint3dArray.PTArr(VertexArrayInWCS.parray)^[vertexnum];
        ProjectProc(osp.worldcoord,osp.dispcoord);
        osp.ostype:=os_begin;
      end;
    1:begin
      if ((SnapMode and osm_4)<>0)and(vertexnum<>tc) then begin
        osp.worldcoord:=PVectotSnap(snaparray.getDataMutable(vertexnum))^.l_1_4;
        ProjectProc(osp.worldcoord,osp.dispcoord);
        osp.ostype:=os_1_4;
      end;
    end;
    2:begin
      if ((SnapMode and osm_3)<>0)and(vertexnum<>tc) then begin
        osp.worldcoord:=PVectotSnap(snaparray.getDataMutable(vertexnum))^.l_1_3;
        ProjectProc(osp.worldcoord,osp.dispcoord);
        osp.ostype:=os_1_3;
      end;
    end;
    3:if ((SnapMode and osm_midpoint)<>0)and(vertexnum<>tc) then
      begin
        osp.worldcoord:=PVectotSnap(snaparray.getDataMutable(vertexnum))^.l_1_2;
        ProjectProc(osp.worldcoord,osp.dispcoord);
        osp.ostype:=os_midle;
      end;
    4:begin
      if ((SnapMode and osm_3)<>0)and(vertexnum<>tc) then begin
        osp.worldcoord:=PVectotSnap(snaparray.getDataMutable(vertexnum))^.l_2_3;
        ProjectProc(osp.worldcoord,osp.dispcoord);
        osp.ostype:=os_2_3;
      end;
    end;
    5:begin
      if ((SnapMode and osm_4)<>0)and(vertexnum<>tc) then begin
        osp.worldcoord:=PVectotSnap(snaparray.getDataMutable(vertexnum))^.l_3_4;
        ProjectProc(osp.worldcoord,osp.dispcoord);
        osp.ostype:=os_3_4;
      end;
    end;
    6:begin
      if (SnapMode and osm_perpendicular)<>0 then
        if vertexnum<(tc) then begin
          pv1:=VertexArrayInWCS.getDataMutable(vertexnum);
          if vertexnum<VertexArrayInWCS.Count-1 then
            pv2:=
              VertexArrayInWCS.getDataMutable(vertexnum+1)
          else begin
            if not closed then
              exit;
            pv2:=VertexArrayInWCS.getDataMutable(0);
          end;
          dir:=uzegeometry.VertexSub(pv2^,pv1^);
          tv:=vectordot(dir,param.md.mouseray.dir);
          t:=-((pv1.x-param.lastpoint.x)*dir.x+
            (pv1.y-param.lastpoint.y)*dir.y+(pv1.z-param.lastpoint.z)*dir.z)/
            (SqrVertexlength(pv2^,pv1^));
          if (t>=0) and (t<=1) then begin
            osp.worldcoord.x:=pv1^.x+t*dir.x;
            osp.worldcoord.y:=pv1^.y+t*dir.y;
            osp.worldcoord.z:=pv1^.z+t*dir.z;
            ProjectProc(osp.worldcoord,tv);
            osp.dispcoord:=tv;
            osp.ostype:=os_perpendicular;
          end else
            osp.ostype:=os_none;
        end;
    end;
    7:begin
      if ((SnapMode and osm_nearest)<>0) then
        if ((vertexnum<(tc))) then begin
          pv1:=VertexArrayInWCS.getDataMutable(vertexnum);
          if vertexnum<VertexArrayInWCS.Count-1 then
            pv2:=
              VertexArrayInWCS.getDataMutable(vertexnum+1)
          else begin
            if not closed then
              exit;
            pv2:=VertexArrayInWCS.getDataMutable(0);
          end;
          dir:=uzegeometry.VertexSub(pv2^,pv1^);
          tv:=vectordot(dir,param.md.mouseray.dir);
          n:=vectordot(param.md.mouseray.dir,tv);
          n:=NormalizeVertex(n);
          v.x:=param.md.mouseray.lbegin.x-pv1^.x;
          v.y:=param.md.mouseray.lbegin.y-pv1^.y;
          v.z:=param.md.mouseray.lbegin.z-pv1^.z;
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
                osp.worldcoord.x:=pv1^.x+t*dir.x;
                osp.worldcoord.y:=pv1^.y+t*dir.y;
                osp.worldcoord.z:=pv1^.z+t*dir.z;
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

procedure GDBObjCurve.startsnap(out osp:os_record;out pdata:Pointer);
begin
  inherited;
  Getmem(pdata,sizeof(GDBVectorSnapArray));
  PGDBVectorSnapArray(pdata).init(VertexArrayInWCS.Max);
  BuildSnapArray(VertexArrayInWCS,PGDBVectorSnapArray(pdata)^,False);
end;

procedure GDBObjCurve.endsnap(out osp:os_record;var pdata:Pointer);
begin
  if pdata<>nil then begin
    PGDBVectorSnapArray(pdata)^.Done;
    Freemem(pdata);
  end;
  inherited;
end;

function GDBObjCurve.getsnap;
begin
  Result:=GDBPoint3dArraygetsnapWOPProjPoint(VertexArrayInWCS,
    PGDBVectorSnapArray(pdata)^,osp,False,param,ProjectProc,snapmode);
end;

initialization

finalization

end.
