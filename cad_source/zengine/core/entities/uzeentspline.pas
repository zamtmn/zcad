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
unit uzeEntSpline;
{$Mode delphi}{$H+}
{$INCLUDE zengineconfig.inc}

interface

uses
  uzegluinterface,uzeentityfactory,uzgldrawcontext,uzgloglstatemanager,
  UGDBPoint3DArray,uzedrawingdef,uzecamera,UGDBVectorSnapArray,
  uzestyleslayers,uzeentsubordinated,uzeentcurve,
  uzeentity,uzctnrVectorBytes,uzbtypes,uzeconsts,uzglviewareadata,
  gzctnrVectorTypes,uzegeometrytypes,uzegeometry,uzeffdxfsupport,SysUtils,
  uzMVReader,uzCtnrVectorpBaseEntity,uzeNURBSTypes,uzbLogIntf,Math,
  uzeNURBSUtils;

type
  TSplineOpt=(SOClosed,SOPeriodic,SORational,SOPlanar,SOLinear);
  TSplineOpts=set of TSplineOpt;
  TPointsType=(PTControl,PTOnCurve);

  PGDBObjSpline=^GDBObjSpline;

  GDBObjSpline=object(GDBObjCurve)
    ControlArrayInOCS:GDBPoint3dArray;
    ControlArrayInWCS:GDBPoint3dArray;
    Knots:TKnotsVector;
    AproxPointInWCS:GDBPoint3dArray;
    Closed:boolean;
    Degree:integer;
    Opts:TSplineOpts;
    constructor init(own:Pointer;layeraddres:PGDBLayerProp;LW:smallint;c:boolean);
    constructor initnul(owner:PGDBObjGenericWithSubordinated);
    destructor done;virtual;
    procedure LoadFromDXF(var rdr:TZMemReader;ptu:PExtensionData;
      var drawing:TDrawingDef;var context:TIODXFLoadContext);virtual;

    procedure FormatEntity(var drawing:TDrawingDef;
      var DC:TDrawContext;Stage:TEFStages=EFAllStages);virtual;
    procedure startsnap(out osp:os_record;out pdata:Pointer);virtual;
    function getsnap(var osp:os_record;var pdata:Pointer;const param:OGLWndtype;
      ProjectProc:GDBProjectProc;SnapMode:TGDBOSMode):boolean;virtual;

    procedure SaveToDXF(var outStream:TZctnrVectorBytes;var drawing:TDrawingDef;
      var IODXFContext:TIODXFSaveContext);virtual;
    procedure SaveToDXFfollow(var outStream:TZctnrVectorBytes;
      var drawing:TDrawingDef;var IODXFContext:TIODXFSaveContext);virtual;
    procedure DrawGeometry(lw:integer;var DC:TDrawContext;
      const inFrustumState:TInBoundingVolume);virtual;
    function Clone(own:Pointer):PGDBObjEntity;virtual;
    function GetObjTypeName:string;virtual;
    function FromDXFPostProcessBeforeAdd(ptu:PExtensionData;
      const drawing:TDrawingDef):PGDBObjSubordinated;virtual;
    function onmouse(var popa:TZctnrVectorPGDBaseEntity;
      const MF:ClipArray;InSubEntry:boolean):boolean;virtual;
    function onpoint(var objects:TZctnrVectorPGDBaseEntity;
      const point:GDBVertex):boolean;virtual;
    procedure AddOnTrackAxis(var posr:os_record;const processaxis:taddotrac);virtual;
    procedure getoutbound(var DC:TDrawContext);virtual;

    function CreateInstance:PGDBObjSpline;static;
    function GetObjType:TObjID;virtual;
  end;

implementation

type
  PTempSplineData=^TTempSplineData;

  TTempSplineData=record
    tv0:gdbvertex;
    PAproxPointInWCS:PGDBPoint3dArray;
  end;

procedure GDBObjSpline.getoutbound;
begin
  if AproxPointInWCS.Count>0 then
    vp.BoundingBox:=AproxPointInWCS.getoutbound
  else
    vp.BoundingBox:=VertexArrayInWCS.getoutbound;
end;

procedure GDBObjSpline.AddOnTrackAxis(var posr:os_record;const processaxis:taddotrac);
begin
  GDBPoint3dArrayAddOnTrackAxis(VertexArrayInWCS,posr,processaxis,closed);
end;

function GDBObjSpline.onmouse;
begin
  if AproxPointInWCS.Count<2 then begin
    Result:=False;
    exit;
  end;
  Result:=AproxPointInWCS.onmouse(mf,closed);
end;

function GDBObjSpline.onpoint(var objects:TZctnrVectorPGDBaseEntity;
  const point:GDBVertex):boolean;
begin
  if VertexArrayInWCS.onpoint(point,closed) then begin
    Result:=True;
    objects.PushBackData(@self);
  end else
    Result:=False;
end;

procedure GDBObjSpline.startsnap(out osp:os_record;out pdata:Pointer);
begin
  GDBObjEntity.startsnap(osp,pdata);
  Getmem(pdata,sizeof(GDBVectorSnapArray));
  PGDBVectorSnapArray(pdata).init(VertexArrayInWCS.Max);
  BuildSnapArray(VertexArrayInWCS,PGDBVectorSnapArray(pdata)^,closed);
end;

function GDBObjSpline.getsnap;
begin
  Result:=GDBPoint3dArraygetsnapWOPProjPoint(VertexArrayInWCS,
    PGDBVectorSnapArray(pdata)^,osp,closed,param,ProjectProc,snapmode);
end;

procedure NurbsVertexCallBack(const v:PGDBvertex3S;
  const Data:Pointer);{$IFDEF Windows}stdcall{$ELSE}cdecl{$ENDIF};
var
  tv:gdbvertex;
begin
  tv.x:=v^.x+PTempSplineData(Data)^.tv0.x;
  tv.y:=v^.y+PTempSplineData(Data)^.tv0.y;
  tv.z:=v^.z+PTempSplineData(Data)^.tv0.z;
  PTempSplineData(Data)^.PAproxPointInWCS^.PushBackData(tv);
  tv.x:=0;
end;

procedure NurbsErrorCallBack(const v:GLenum);
  {$IFDEF Windows}stdcall{$ELSE}cdecl{$ENDIF};
begin
  zDebugLn('{E}'+GLUIntrf.ErrorString(v));
end;

procedure GDBObjSpline.FormatEntity(var drawing:TDrawingDef;
  var DC:TDrawContext;Stage:TEFStages=EFAllStages);
var
  ptv:pgdbvertex;
  ir:itrec;
  nurbsobj:GLUnurbsObj;
  CP:TCPVector;
  tfv:GDBvertex4D;
  tfvs:GDBvertex4S;
  TSD:TTempSplineData;
  tv:GDBvertex;
begin
  if assigned(EntExtensions) then
    EntExtensions.RunOnBeforeEntityFormat(@self,drawing,DC);
  FormatWithoutSnapArray;
  if (not(SOLinear in Opts))and(not (ESTemp in State))and(DCODrawable in DC.Options) then
  begin
    CP.init(VertexArrayInWCS.Count);
    ptv:=VertexArrayInWCS.beginiterate(ir);
    if ptv<>nil then begin
      TSD.tv0:=ptv^;
      repeat

        tfvs.x:=ptv.x-TSD.tv0.x;
        tfvs.y:=ptv.y-TSD.tv0.y;
        tfvs.z:=ptv.z-TSD.tv0.z;
        tfvs.w:=1;

        CP.PushBackData(tfvs);

        ptv:=VertexArrayInWCS.iterate(ir);
      until ptv=nil;
    end;

    AproxPointInWCS.Clear;
    TSD.PAproxPointInWCS:=@AproxPointInWCS;

    //попытка расчета масштаба при невыставленых матрицах вида, при загрузке dxf
    //по идее наверно надо матрицы выставлять, а не тут заниматься херней
    tv:=VectorTransform3D(OneVertex,{m}getmatrix^);
    tv:=VectorTransform3D(tv,DC.DrawingContext.matrixs.pmodelMatrix^);
    tv:=VectorTransform3D(tv,DC.DrawingContext.matrixs.pprojMatrix^);

    nurbsobj:=GLUIntrf.NewNurbsRenderer;

    GLUIntrf.SetupNurbsRenderer(nurbsobj,max(1,50/tv.Length),
      DC.DrawingContext.matrixs.pmodelMatrix^,
      DC.DrawingContext.matrixs.pprojMatrix^,DC.DrawingContext.matrixs.pviewport^,
      nil,nil,@NurbsVertexCallBack,@NurbsErrorCallBack,
      @TSD);
    GLUIntrf.BeginCurve(nurbsobj);
    GLUIntrf.NurbsCurve(nurbsobj,Knots.Count,Knots.GetParrayAsPointer,
      {CP.Count}4,CP.GetParrayAsPointer,degree+1,GL_MAP1_VERTEX_4);
    GLUIntrf.EndCurve(nurbsobj);


    GLUIntrf.DeleteNurbsRenderer(nurbsobj);

    CP.done;
  end;
  AproxPointInWCS.Shrink;
  CalcActualVisible(dc.DrawingContext.VActuality);
  if (not (ESTemp in State))and(DCODrawable in DC.Options) then begin
    Representation.Clear;
    if SOLinear in Opts then
      Representation.DrawLineWithLT(self,getmatrix^,dc,VertexArrayInOCS.getFirst,
        VertexArrayInOCS.getLast,vp)
    else
      Representation.DrawPolyLineWithLT(dc,AproxPointInWCS,vp,False,False);
  end;
  calcbb(dc);
  if assigned(EntExtensions) then
    EntExtensions.RunOnAfterEntityFormat(@self,drawing,DC);
end;

function GDBObjSpline.FromDXFPostProcessBeforeAdd;
begin
  Result:=nil;
end;

function GDBObjSpline.GetObjTypeName;
begin
  Result:=ObjN_GDBObjSpline;
end;

constructor GDBObjSpline.init;
begin
  closed:=c;
  inherited init(own,layeraddres,lw);
  ControlArrayInWCS.init(1000);
  ControlArrayInOCS.init(1000);
  Knots.init(1000);
  AproxPointInWCS.init(1000);
  Opts:=[];
end;

constructor GDBObjSpline.initnul;
begin
  inherited initnul(owner);
  ControlArrayInWCS.init(1000);
  ControlArrayInOCS.init(1000);
  Knots.init(1000);
  AproxPointInWCS.init(1000);
  Opts:=[];
end;

function GDBObjSpline.GetObjType;
begin
  Result:=GDBSplineID;
end;

destructor GDBObjSpline.done;
begin
  ControlArrayInWCS.done;
  ControlArrayInOCS.done;
  Knots.done;
  AproxPointInWCS.done;
  inherited;
end;

procedure GDBObjSpline.DrawGeometry;
begin
  self.Representation.DrawGeometry(DC,VP.BoundingBox,inFrustumState);
  drawbb(dc);
end;

function GDBObjSpline.Clone;
var
  tpo:PGDBObjSpline;
begin
  Getmem(Pointer(tpo),sizeof(GDBObjSpline));
  tpo^.init(own,vp.Layer,vp.LineWeight,closed);
  CopyVPto(tpo^);
  CopyExtensionsTo(tpo^);
  vertexarrayinocs.copyto(tpo^.vertexarrayinocs);
  Knots.copyto(tpo^.Knots);
  tpo^.degree:=degree;
  Result:=tpo;
end;

function DXFFlag2SplineOpts(AFlag:integer):TSplineOpts;
begin
  if (AFlag and 1)<>0 then
    Result:=[SOClosed]
  else
    Result:=[];
  if (AFlag and 2)<>0 then
    Result:=Result+[SOPeriodic];
  if (AFlag and 4)<>0 then
    Result:=Result+[SORational];
  if (AFlag and 8)<>0 then
    Result:=Result+[SOPlanar];
  if (AFlag and 16)<>0 then
    Result:=Result+[SOLinear];
end;

function SplineOpts2DXFFlag(AOpts:TSplineOpts):integer;
begin
  if SOClosed in AOpts then
    Result:=1
  else
    Result:=0;
  if SOPeriodic in AOpts then
    Result:=Result+2;
  if SORational in AOpts then
    Result:=Result+4;
  if SOPlanar in AOpts then
    Result:=Result+8;
  if SOLinear in AOpts then
    Result:=Result+16;
end;

procedure GDBObjSpline.SaveToDXF;
var
  ir:itrec;
  fl:PSingle;
  ptv:pgdbvertex;
begin
  SaveToDXFObjPrefix(outStream,'SPLINE','AcDbSpline',IODXFContext);
  dxfIntegerout(outStream,70,SplineOpts2DXFFlag(Opts));
  dxfIntegerout(outStream,71,degree);
  dxfIntegerout(outStream,72,Knots.Count);
  dxfIntegerout(outStream,73,VertexArrayInOCS.Count);

  dxfDoubleout(outStream,42,0.0000000001);
  dxfDoubleout(outStream,43,0.0000000001);

  fl:=Knots.beginiterate(ir);
  if fl<>nil then
    repeat
      dxfDoubleout(outStream,40,fl^);
      fl:=Knots.iterate(ir);
    until fl=nil;

  ptv:=VertexArrayInOCS.beginiterate(ir);
  if ptv<>nil then
    repeat
      dxfvertexout(outStream,10,ptv^);
      ptv:=VertexArrayInOCS.iterate(ir);
    until ptv=nil;
end;

procedure GDBObjSpline.SaveToDXFfollow(var outStream:TZctnrVectorBytes;
  var drawing:TDrawingDef;var IODXFContext:TIODXFSaveContext);
begin
end;

procedure GDBObjSpline.LoadFromDXF;
var
  DXFGroupCode:integer;
  tmpFlag:integer;
  tmpVertex:GDBvertex;
  tmpKnot:single;
  pt:TPointsType;
  startTangent,endTangent:TNulableVetrex;
  vcp:TControlPointsArray;
begin
  Closed:=False;
  tmpVertex:=NulVertex;
  tmpKnot:=0;
  tmpFlag:=0;
  pt:=TPointsType.PTControl;

  DXFGroupCode:=rdr.ParseInteger;
  while DXFGroupCode<>0 do begin
    if not LoadFromDXFObjShared(rdr,DXFGroupCode,ptu,drawing,context) then
      if dxfLoadGroupCodeVertex(rdr,10,DXFGroupCode,tmpVertex) then begin
        if DXFGroupCode=30 then
          context.GDBVertexLoadCache.PushBackData(tmpVertex);
      end else if dxfLoadGroupCodeVertex(rdr,11,DXFGroupCode,tmpVertex) then begin
          if DXFGroupCode=31 then begin
            context.GDBVertexLoadCache.PushBackData(tmpVertex);
            pt:=TPointsType.PTOnCurve;
          end;
      end else if dxfLoadGroupCodeVertex(rdr,12,DXFGroupCode,tmpVertex) then begin
          if DXFGroupCode=32 then
            startTangent:=tmpVertex;
      end else if dxfLoadGroupCodeVertex(rdr,13,DXFGroupCode,tmpVertex) then begin
          if DXFGroupCode=33 then
            ENDTangent:=tmpVertex;
      end else if dxfLoadGroupCodeFloat(rdr,40,DXFGroupCode,tmpKnot) then
        Knots.PushBackData(tmpKnot)
      else if dxfLoadGroupCodeInteger(rdr,70,DXFGroupCode,tmpFlag) then begin
        Opts:=DXFFlag2SplineOpts(tmpFlag);
        Closed:=SOClosed in Opts;
      end else if dxfLoadGroupCodeInteger(rdr,71,DXFGroupCode,Degree) then begin
        Degree:=Degree;
      end else
        rdr.SkipString;
    DXFGroupCode:=rdr.ParseInteger;
  end;

  //vertexarrayinocs.Shrink;
  if pt=TPointsType.PTControl then begin
    vertexarrayinocs.SetSize(context.GDBVertexLoadCache.Count);
    context.GDBVertexLoadCache.copyto(vertexarrayinocs);
  end else begin
    //vcp:=ConvertOnCurvePointsToControlPointsArray(Degree,context.GDBVertexLoadCache,Knots.);

    //for i:=low(vcp) to high(vcp) do
    //  ASpleneEntity.AddVertex(vcp[i]);
  end;
  context.GDBVertexLoadCache.Clear;

  Knots.Shrink;
end;

function AllocSpline:PGDBObjSpline;
begin
  Getmem(Result,sizeof(GDBObjSpline));
end;

function AllocAndInitSpline(owner:PGDBObjGenericWithSubordinated):PGDBObjSpline;
begin
  Result:=AllocSpline;
  Result.initnul(owner);
  Result.bp.ListPos.Owner:=owner;
end;

function GDBObjSpline.CreateInstance:PGDBObjSpline;
begin
  Result:=AllocAndInitSpline(nil);
end;

begin
  RegisterDXFEntity(GDBSplineID,'SPLINE','Spline',@AllocSpline,@AllocAndInitSpline);
end.
