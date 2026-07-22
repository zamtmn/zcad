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

unit uzeentleader;
{$Mode delphi}{$H+}
{$INCLUDE zengineconfig.inc}

interface

uses
  uzeentityfactory,uzgldrawcontext,uzedrawingdef,uzecamera,UGDBVectorSnapArray,
  uzestyleslayers,uzeentsubordinated,uzeentcurve,UGDBSelectedObjArray,
  uzeentcomplex,uzeentline,uzeentspline,uzeentblockinsert,uzeentitiesmanager,
  uzeentity,uzctnrVectorBytesStream,uzeTypes,uzeconsts,uzglviewareadata,
  uzegeometrytypes,uzegeometry,uzeffdxfsupport,SysUtils,Math,uzesnap,
  uzepalette,uzestylesdim,uzestyleslinetypes,uzedimblocksregister,UGDBPoint3DArray,gzctnrVectorTypes,
  uzMVReader,uzCtnrVectorpBaseEntity,uzeNURBSTypes,uzeNURBSUtils;

type
  PGDBObjLeader=^GDBObjLeader;

  GDBObjLeader=object(GDBObjComplex)
    VertexArrayInOCS:GDBPoint3dArray;
    VertexArrayInWCS:GDBPoint3dArray;
    length:double;
    DimStyleName:string;
    ArrowHeadFlag:integer;
    PathType:integer;
    AnnotationType:integer;
    HookLineDirectionFlag:integer;
    HookLineFlag:integer;
    TextHeight:double;
    TextWidth:double;
    AnnotationHandle:TDWGHandle;
    NormalVector:TzePoint3d;
    HorizontalDirection:TzePoint3d;
    BlockOffset:TzePoint3d;
    AnnotationOffset:TzePoint3d;
    ArrowStyleIndex:integer;        // индивидуальный индекс стрелки (-1 = из стиля)
    ArrowSize:double;               // индивидуальный масштаб стрелки (0 = из стиля)
    DimLineWeight:TGDBLineWeight;   // индивидуальная толщина линии (сентинел = из стиля)
    DimLineColor:TGDBPaletteColor;  // индивидуальный цвет линии (сентинел = из стиля)

    constructor init(own:Pointer;layeraddres:PGDBLayerProp;LW:smallint);
    constructor initnul(owner:PGDBObjGenericWithSubordinated);
    destructor done;virtual;

    procedure LoadFromDXF(var rdr:TZMemReader;ptu:PExtensionData;
      var drawing:TDrawingDef;var context:TIODXFLoadContext);virtual;
    procedure SaveToDXF(var outStream:TZctnrVectorBytes;
      var drawing:TDrawingDef;var IODXFContext:TIODXFSaveContext);virtual;
    procedure FormatEntity(var drawing:TDrawingDef;
      var DC:TDrawContext;Stage:TEFStages=EFAllStages);virtual;
    procedure FormatWithoutSnapArray;virtual;
    procedure BuildComplexGeometry(var drawing:TDrawingDef;var DC:TDrawContext);virtual;
    procedure DrawGeometry(lw:integer;var DC:TDrawContext;
      const inFrustumState:TInBoundingVolume);virtual;
    function Clone(own:Pointer):PGDBObjEntity;virtual;
    function GetObjTypeName:string;virtual;
    function GetObjType:TObjID;virtual;
    function CalcTrueInFrustum(
      const frustum:TzeFrustum):TInBoundingVolume;virtual;
    procedure AddVertex(const Vertex:TzePoint3d);virtual;
    function GetLength:double;virtual;
    procedure transform(const t_matrix:TzeTypedMatrix4d);virtual;
    procedure TransformAt(p:PGDBObjEntity;t_matrix:PzeTypedMatrix4d);virtual;
    procedure rtsave(refp:Pointer);virtual;
    function onmouse(var popa:TZctnrVectorPGDBaseEntity;
      const MF:TzeFrustum;InSubEntry:boolean):boolean;virtual;
    function onpoint(var objects:TZctnrVectorPGDBaseEntity;
      const point:TzePoint3d):boolean;virtual;
    procedure rtmodifyonepoint(const rtmod:TRTModifyData);virtual;
    procedure remaponecontrolpoint(pdesc:pcontrolpointdesc;
      ProjectProc:GDBProjectProc);virtual;
    procedure addcontrolpoints(tdesc:Pointer);virtual;
    procedure AddOnTrackAxis(var posr:os_record;
      const processaxis:taddotrac);virtual;
    function getsnap(var osp:os_record;var pdata:Pointer;
      const param:OGLWndtype;ProjectProc:GDBProjectProc;SnapMode:TGDBOSMode):boolean;virtual;
    procedure startsnap(out osp:os_record;out pdata:Pointer);virtual;
    procedure endsnap(out osp:os_record;var pdata:Pointer);virtual;
    class function CreateInstance:PGDBObjLeader;static;
  end;

const
  LeaderTypeIndexLinearNoArrow=0;
  LeaderTypeIndexSplineNoArrow=1;
  LeaderTypeIndexLinearWithArrow=2;
  LeaderTypeIndexSplineWithArrow=3;

  // Сентинелы "наследовать значение из размерного стиля выноски"
  LeaderArrowStyleInherit=-1;     // индекс стрелки берётся из размерного стиля
  LeaderArrowSizeInherit=0;       // масштаб стрелки берётся из размерного стиля
  LeaderLineWeightInherit=-1000;  // толщина линии берётся из размерного стиля
  LeaderColorInherit=-1;          // цвет линии берётся из размерного стиля

  function AllocAndInitLeader(owner:PGDBObjGenericWithSubordinated):PGDBObjLeader;
  function LeaderTypeToEnumIndex(const Leader:GDBObjLeader):integer;
  procedure ApplyLeaderTypeEnumIndex(var Leader:GDBObjLeader;EnumIndex:integer);
  function GetLeaderEffectiveDimStyle(const Leader:GDBObjLeader;
    DimStyles:PGDBDimStyleArray):PGDBDimStyle;
  function ResolveLeaderArrowStyleIndex(const Leader:GDBObjLeader;
    PDimStyle:PGDBDimStyle):integer;
  function ResolveLeaderArrowSize(const Leader:GDBObjLeader;
    PDimStyle:PGDBDimStyle):double;
  function ResolveLeaderDimLineWeight(const Leader:GDBObjLeader;
    PDimStyle:PGDBDimStyle):TGDBLineWeight;
  function ResolveLeaderDimLineColor(const Leader:GDBObjLeader;
    PDimStyle:PGDBDimStyle):TGDBPaletteColor;

implementation

const
  LeaderGeometryEpsilon=1e-9;

procedure InitLeaderDefaults(var Leader:GDBObjLeader);
begin
  Leader.DimStyleName:='';
  Leader.ArrowHeadFlag:=1;
  Leader.PathType:=0;
  Leader.AnnotationType:=3;
  Leader.HookLineDirectionFlag:=0;
  Leader.HookLineFlag:=0;
  Leader.TextHeight:=0;
  Leader.TextWidth:=0;
  Leader.AnnotationHandle:=0;
  Leader.NormalVector:=CreateVertex(0,0,1);
  Leader.HorizontalDirection:=CreateVertex(1,0,0);
  Leader.BlockOffset:=NulPoint;
  Leader.AnnotationOffset:=NulPoint;
  Leader.ArrowStyleIndex:=LeaderArrowStyleInherit;
  Leader.ArrowSize:=LeaderArrowSizeInherit;
  Leader.DimLineWeight:=LeaderLineWeightInherit;
  Leader.DimLineColor:=LeaderColorInherit;
end;

function GetLeaderEffectiveDimStyle(const Leader:GDBObjLeader;
  DimStyles:PGDBDimStyleArray):PGDBDimStyle;
begin
  Result:=nil;
  if DimStyles=nil then
    exit;
  if Leader.DimStyleName<>'' then
    Result:=PGDBDimStyle(DimStyles^.getAddres(Leader.DimStyleName));
  if (Result=nil)and(DimStyles^.Count>0) then
    Result:=PGDBDimStyle(DimStyles^.getDataMutable(0));
end;

function ResolveLeaderDimStyle(const Leader:GDBObjLeader;
  var drawing:TDrawingDef):PGDBDimStyle;
begin
  Result:=GetLeaderEffectiveDimStyle(Leader,drawing.GetDimStyleTable);
end;

function GetLeaderDimScale(PDimStyle:PGDBDimStyle):double;
begin
  if (PDimStyle<>nil)and(PDimStyle^.Units.DIMSCALE>0) then
    Result:=PDimStyle^.Units.DIMSCALE
  else
    Result:=1;
end;

// Возвращает индекс стрелки: индивидуальный либо из размерного стиля
function ResolveLeaderArrowStyleIndex(const Leader:GDBObjLeader;
  PDimStyle:PGDBDimStyle):integer;
begin
  if Leader.ArrowStyleIndex<>LeaderArrowStyleInherit then
    Result:=Leader.ArrowStyleIndex
  else if PDimStyle<>nil then
    Result:=ord(PDimStyle^.Arrows.DIMLDRBLK)
  else
    Result:=ord(TSClosedFilled);
end;

// Возвращает масштаб блока стрелки: индивидуальный либо из размерного стиля
function ResolveLeaderArrowSize(const Leader:GDBObjLeader;
  PDimStyle:PGDBDimStyle):double;
begin
  if Leader.ArrowSize>LeaderArrowSizeInherit then
    Result:=Leader.ArrowSize
  else if PDimStyle<>nil then
    Result:=PDimStyle^.Arrows.DIMASZ*GetLeaderDimScale(PDimStyle)
  else
    Result:=1;
end;

// Возвращает толщину размерной линии: индивидуальную либо из стиля
function ResolveLeaderDimLineWeight(const Leader:GDBObjLeader;
  PDimStyle:PGDBDimStyle):TGDBLineWeight;
begin
  if Leader.DimLineWeight<>LeaderLineWeightInherit then
    Result:=Leader.DimLineWeight
  else if PDimStyle<>nil then
    Result:=PDimStyle^.Lines.DIMLWD
  else
    Result:=Leader.vp.LineWeight;
end;

// Возвращает цвет размерной линии: индивидуальный либо из стиля
function ResolveLeaderDimLineColor(const Leader:GDBObjLeader;
  PDimStyle:PGDBDimStyle):TGDBPaletteColor;
begin
  if Leader.DimLineColor<>LeaderColorInherit then
    Result:=Leader.DimLineColor
  else if PDimStyle<>nil then
    Result:=PDimStyle^.Lines.DIMCLRD
  else
    Result:=Leader.vp.Color;
end;

function LeaderArrowLineType(const Leader:GDBObjLeader;
  PDimStyle:PGDBDimStyle):PGDBLtypeProp;
begin
  if (PDimStyle<>nil)and(PDimStyle^.Lines.DIMLTYPE<>nil) then
    Result:=PDimStyle^.Lines.DIMLTYPE
  else
    Result:=Leader.vp.LineType;
end;

function LeaderDistancesEqual(Left,Right:double):boolean;
var
  Scale:double;
begin
  Scale:=Max(1.0,Max(Abs(Left),Abs(Right)));
  Result:=Abs(Left-Right)<=LeaderGeometryEpsilon*Scale;
end;

function LeaderSegmentLength(const Leader:GDBObjLeader;
  SegmentIndex:integer):double;
var
  p1,p2:PzePoint3d;
begin
  Result:=0;
  if (SegmentIndex<0)or(SegmentIndex>=Leader.VertexArrayInOCS.Count-1) then
    exit;
  p1:=Leader.VertexArrayInOCS.getDataMutable(SegmentIndex);
  p2:=Leader.VertexArrayInOCS.getDataMutable(SegmentIndex+1);
  Result:=p1^.LengthTo(p2^);
end;

function LeaderHasTextTailSegment(const Leader:GDBObjLeader;
  LeaderArrowSize:double):boolean;
begin
  Result:=False;
  if (Leader.VertexArrayInOCS.Count<3)or(LeaderArrowSize<=0) then
    exit;
  Result:=LeaderDistancesEqual(LeaderSegmentLength(Leader,
    Leader.VertexArrayInOCS.Count-2),LeaderArrowSize);
end;

function LeaderArrowAngleFromDirection(const Direction,FallbackStart,
  FallbackEnd:TzePoint3d):double;
begin
  if Direction.Length>LeaderGeometryEpsilon then
    Result:=VertexAngle(CreateVertex2D(0,0),CreateVertex2D(Direction.x,Direction.y))-pi
  else
    Result:=VertexAngle(CreateVertex2D(FallbackStart.x,FallbackStart.y),CreateVertex2D(FallbackEnd.x,FallbackEnd.y))-pi;
end;

function LeaderSplineStartDirection(Spline:PGDBObjSpline;
  const FallbackStart,FallbackEnd:TzePoint3d):TzePoint3d;
var
  i:integer;
  pFirst,pNext:PzePoint3d;
begin
  Result:=VertexSub(FallbackEnd,FallbackStart);
  if (Spline=nil)or(Spline^.VertexArrayInOCS.Count<2) then
    exit;

  pFirst:=Spline^.VertexArrayInOCS.getDataMutable(0);
  for i:=1 to Spline^.VertexArrayInOCS.Count-1 do begin
    pNext:=Spline^.VertexArrayInOCS.getDataMutable(i);
    Result:=VertexSub(pNext^,pFirst^);
    if Result.Length>LeaderGeometryEpsilon then
      exit;
  end;

  Result:=VertexSub(FallbackEnd,FallbackStart);
end;

// Выбирает степень сплайна по числу точек участка.
function ClampLeaderSplineDegree(PointCount:integer):integer;
begin
  if PointCount>=4 then
    Result:=3
  else if PointCount=3 then
    Result:=2
  else
    Result:=1;
end;

// Возвращает среднюю контрольную точку квадратичного сплайна.
function CreateQuadraticLeaderMiddleControl(const First,Middle,Last:TzePoint3d):
  TzePoint3d;
begin
  Result.x:=2*Middle.x-(First.x+Last.x)/2;
  Result.y:=2*Middle.y-(First.y+Last.y)/2;
  Result.z:=2*Middle.z-(First.z+Last.z)/2;
end;

// Строит резервный открытый равномерный вектор узлов.
procedure GenerateOpenUniformLeaderSplineKnots(Spline:PGDBObjSpline);
var
  i,KnotCount,Denom,ControlCount:integer;
  Value:double;
  Knot:single;
begin
  Spline^.Knots.Clear;
  ControlCount:=Spline^.VertexArrayInOCS.Count;
  if ControlCount<=0 then
    exit;

  KnotCount:=ControlCount+Spline^.Degree+1;
  Denom:=ControlCount-Spline^.Degree;
  if Denom<1 then
    Denom:=1;

  for i:=0 to KnotCount-1 do begin
    if i<=Spline^.Degree then
      Value:=0
    else if i>=ControlCount then
      Value:=1
    else
      Value:=(i-Spline^.Degree)/Denom;
    Knot:=Value;
    Spline^.Knots.PushBackData(Knot);
  end;
end;

// Применяет к дочернему примитиву свойства линии выноски.
procedure ApplyLeaderPathVP(Leader:PGDBObjLeader;Entity:PGDBObjEntity;
  PDimStyle:PGDBDimStyle);
begin
  Leader^.CopyVPto(Entity^);
  Entity^.vp.LineWeight:=ResolveLeaderDimLineWeight(Leader^,PDimStyle);
  Entity^.vp.Color:=ResolveLeaderDimLineColor(Leader^,PDimStyle);
end;

// Создаёт прямой участок выноски.
function CreateLeaderLineSegment(Leader:PGDBObjLeader;var drawing:TDrawingDef;
  var DC:TDrawContext;PDimStyle:PGDBDimStyle;
  const p1,p2:TzePoint3d):PGDBObjLine;
begin
  Result:=pointer(Leader^.ConstObjArray.CreateInitObj(GDBlineID,Leader));
  if Result=nil then
    exit;

  ApplyLeaderPathVP(Leader,PGDBObjEntity(Result),PDimStyle);
  Result^.CoordInOCS.lBegin:=p1;
  Result^.CoordInOCS.lEnd:=p2;
  Result^.FormatEntity(drawing,DC);
end;

// Создаёт сплайновую часть через заданные точки.
function CreateLeaderSplinePath(Leader:PGDBObjLeader;var drawing:TDrawingDef;
  var DC:TDrawContext;PDimStyle:PGDBDimStyle;
  SplinePointCount:integer):PGDBObjSpline;
var
  i:integer;
  FitPoints:array of TzePoint3d;
  ControlPoints:TControlPointsArray;
begin
  Result:=nil;
  if SplinePointCount<2 then
    exit;

  Result:=pointer(Leader^.ConstObjArray.CreateInitObj(GDBSplineID,Leader));
  if Result=nil then
    exit;

  ApplyLeaderPathVP(Leader,PGDBObjEntity(Result),PDimStyle);
  Result^.Closed:=False;
  Result^.Opts:=[SOPlanar];
  Result^.Degree:=ClampLeaderSplineDegree(SplinePointCount);

  SetLength(FitPoints,SplinePointCount);
  for i:=0 to SplinePointCount-1 do
    FitPoints[i]:=Leader^.VertexArrayInOCS.getDataMutable(i)^;

  if Result^.Degree=1 then begin
    for i:=0 to High(FitPoints) do
      Result^.AddVertex(FitPoints[i]);
    Result^.Opts:=Result^.Opts+[SOLinear];
  end else if (Result^.Degree=2)and(SplinePointCount=3) then begin
    Result^.AddVertex(FitPoints[0]);
    Result^.AddVertex(CreateQuadraticLeaderMiddleControl(
      FitPoints[0],FitPoints[1],FitPoints[2]));
    Result^.AddVertex(FitPoints[2]);
    GenerateOpenUniformLeaderSplineKnots(Result);
  end else begin
    ControlPoints:=ConvertOnCurvePointsToControlPointsArray(
      Result^.Degree,FitPoints,Result^.Knots);
    if Length(ControlPoints)>0 then begin
      for i:=0 to High(ControlPoints) do
        Result^.AddVertex(ControlPoints[i]);
    end else begin
      for i:=0 to High(FitPoints) do
        Result^.AddVertex(FitPoints[i]);
    end;
    if Result^.Knots.Count=0 then
      GenerateOpenUniformLeaderSplineKnots(Result);
  end;

  Result^.FormatEntity(drawing,DC);
end;

function IsZeroVertex(const Vertex:TzePoint3d):boolean;
begin
  Result:=(Vertex.x=0)and(Vertex.y=0)and(Vertex.z=0);
end;

function IsSameVertex(const Left,Right:TzePoint3d):boolean;
begin
  Result:=(Left.x=Right.x)and(Left.y=Right.y)and(Left.z=Right.z);
end;

function LeaderTypeToEnumIndex(const Leader:GDBObjLeader):integer;
begin
  if Leader.PathType=1 then begin
    if Leader.ArrowHeadFlag=0 then
      Result:=LeaderTypeIndexSplineNoArrow
    else
      Result:=LeaderTypeIndexSplineWithArrow;
  end else begin
    if Leader.ArrowHeadFlag=0 then
      Result:=LeaderTypeIndexLinearNoArrow
    else
      Result:=LeaderTypeIndexLinearWithArrow;
  end;
end;

procedure ApplyLeaderTypeEnumIndex(var Leader:GDBObjLeader;EnumIndex:integer);
begin
  case EnumIndex of
    LeaderTypeIndexLinearNoArrow:begin
      Leader.ArrowHeadFlag:=0;
      Leader.PathType:=0;
    end;
    LeaderTypeIndexSplineNoArrow:begin
      Leader.ArrowHeadFlag:=0;
      Leader.PathType:=1;
    end;
    LeaderTypeIndexSplineWithArrow:begin
      Leader.ArrowHeadFlag:=1;
      Leader.PathType:=1;
    end;
  else
    Leader.ArrowHeadFlag:=1;
    Leader.PathType:=0;
  end;
end;

constructor GDBObjLeader.init(own:Pointer;layeraddres:PGDBLayerProp;LW:smallint);
begin
  inherited init(own,layeraddres,lw);
  VertexArrayInWCS.init(10);
  VertexArrayInOCS.init(10);
  InitLeaderDefaults(self);
end;

constructor GDBObjLeader.initnul(owner:PGDBObjGenericWithSubordinated);
begin
  inherited initnul;
  bp.ListPos.Owner:=owner;
  VertexArrayInWCS.init(10);
  VertexArrayInOCS.init(10);
  InitLeaderDefaults(self);
end;

destructor GDBObjLeader.done;
begin
  VertexArrayInWCS.done;
  VertexArrayInOCS.done;
  DimStyleName:='';
  inherited;
end;

procedure GDBObjLeader.LoadFromDXF(var rdr:TZMemReader;ptu:PExtensionData;
  var drawing:TDrawingDef;var context:TIODXFLoadContext);
var
  DXFGroupCode:integer;
  CurrentVertex:TzePoint3d;
  HasCurrentVertex:boolean;
  VertexCount:integer;

  procedure PushCurrentVertex;
  begin
    if HasCurrentVertex then begin
      VertexArrayInOCS.PushBackData(CurrentVertex);
      CurrentVertex:=NulPoint;
      HasCurrentVertex:=False;
    end;
  end;

begin
  VertexArrayInOCS.Clear;
  CurrentVertex:=NulPoint;
  HasCurrentVertex:=False;
  VertexCount:=0;

  DXFGroupCode:=rdr.ParseInteger;
  while DXFGroupCode<>0 do begin
    if dxfLoadGroupCodeVertex(rdr,210,DXFGroupCode,NormalVector) then
    else if not LoadFromDXFObjShared(rdr,DXFGroupCode,ptu,drawing,context) then
      if dxfLoadGroupCodeString(rdr,3,DXFGroupCode,DimStyleName,context.Header) then
      else if dxfLoadGroupCodeInteger(rdr,71,DXFGroupCode,ArrowHeadFlag) then
      else if dxfLoadGroupCodeInteger(rdr,72,DXFGroupCode,PathType) then
      else if dxfLoadGroupCodeInteger(rdr,73,DXFGroupCode,AnnotationType) then
      else if dxfLoadGroupCodeInteger(rdr,74,DXFGroupCode,HookLineDirectionFlag) then
      else if dxfLoadGroupCodeInteger(rdr,75,DXFGroupCode,HookLineFlag) then
      else if dxfLoadGroupCodeInteger(rdr,76,DXFGroupCode,VertexCount) then
      else if dxfLoadGroupCodeDouble(rdr,40,DXFGroupCode,TextHeight) then
      else if dxfLoadGroupCodeDouble(rdr,41,DXFGroupCode,TextWidth) then
      else if dxfLoadGroupCodeVertex(rdr,211,DXFGroupCode,HorizontalDirection) then
      else if dxfLoadGroupCodeVertex(rdr,212,DXFGroupCode,BlockOffset) then
      else if dxfLoadGroupCodeVertex(rdr,213,DXFGroupCode,AnnotationOffset) then
      else begin
        case DXFGroupCode of
          10:begin
            PushCurrentVertex;
            CurrentVertex:=NulPoint;
            CurrentVertex.x:=rdr.ParseDouble;
            HasCurrentVertex:=True;
          end;
          20:begin
            CurrentVertex.y:=rdr.ParseDouble;
            HasCurrentVertex:=True;
          end;
          30:begin
            CurrentVertex.z:=rdr.ParseDouble;
            HasCurrentVertex:=True;
            PushCurrentVertex;
          end;
          340:begin
            AnnotationHandle:=DXFHandle(rdr.ParseShortString);
          end;
        else
          rdr.SkipString;
        end;
      end;
    DXFGroupCode:=rdr.ParseInteger;
  end;

  PushCurrentVertex;
  VertexArrayInOCS.Shrink;
end;

procedure GDBObjLeader.SaveToDXF(var outStream:TZctnrVectorBytes;
  var drawing:TDrawingDef;var IODXFContext:TIODXFSaveContext);
var
  i:integer;
begin
  SaveToDXFObjPrefix(outStream,'LEADER','AcDbLeader',IODXFContext);
  if DimStyleName<>'' then
    dxfStringout(outStream,3,DimStyleName,IODXFContext.Header);
  dxfIntegerout(outStream,71,ArrowHeadFlag);
  dxfIntegerout(outStream,72,PathType);
  dxfIntegerout(outStream,73,AnnotationType);
  dxfIntegerout(outStream,74,HookLineDirectionFlag);
  dxfIntegerout(outStream,75,HookLineFlag);
  if TextHeight<>0 then
    dxfDoubleout(outStream,40,TextHeight);
  if TextWidth<>0 then
    dxfDoubleout(outStream,41,TextWidth);
  dxfIntegerout(outStream,76,VertexArrayInOCS.Count);
  for i:=0 to VertexArrayInOCS.Count-1 do
    dxfvertexout(outStream,10,VertexArrayInOCS.Items[i]);
  if AnnotationHandle<>0 then
    dxfStringWithoutEncodeOut(outStream,340,IntToHex(AnnotationHandle,0));
  if not IsSameVertex(NormalVector,CreateVertex(0,0,1)) then
    dxfvertexout(outStream,210,NormalVector);
  if not IsSameVertex(HorizontalDirection,CreateVertex(1,0,0)) then
    dxfvertexout(outStream,211,HorizontalDirection);
  if not IsZeroVertex(BlockOffset) then
    dxfvertexout(outStream,212,BlockOffset);
  if not IsZeroVertex(AnnotationOffset) then
    dxfvertexout(outStream,213,AnnotationOffset);
end;

procedure GDBObjLeader.FormatEntity(var drawing:TDrawingDef;
  var DC:TDrawContext;Stage:TEFStages=EFAllStages);
begin
  if assigned(EntExtensions) then
    EntExtensions.RunOnBeforeEntityFormat(@self,drawing,DC);

  FormatWithoutSnapArray;
  BuildComplexGeometry(drawing,DC);
  inherited FormatEntity(drawing,DC,Stage);

  if assigned(EntExtensions) then
    EntExtensions.RunOnAfterEntityFormat(@self,drawing,DC);
end;

procedure GDBObjLeader.FormatWithoutSnapArray;
var
  ptv:PzePoint3d;
  tv:TzePoint3d;
  ir:itrec;
  OwnerMatrix:TzeTypedMatrix4d;
begin
  VertexArrayInWCS.Clear;
  VertexArrayInWCS.SetSize(VertexArrayInOCS.Count);
  if bp.ListPos.Owner<>nil then
    OwnerMatrix:=bp.ListPos.Owner^.GetMatrix^
  else
    OwnerMatrix:=OneMatrix;
  ptv:=VertexArrayInOCS.beginiterate(ir);
  if ptv<>nil then
    repeat
      tv:=VectorTransform3D(ptv^,OwnerMatrix);
      VertexArrayInWCS.PushBackData(tv);
      ptv:=VertexArrayInOCS.iterate(ir);
    until ptv=nil;

  VertexArrayInOCS.Shrink;
  VertexArrayInWCS.Shrink;
  length:=GetLength;
end;

procedure GDBObjLeader.BuildComplexGeometry(var drawing:TDrawingDef;
  var DC:TDrawContext);
var
  i:integer;
  p1,p2:PzePoint3d;
  PDimStyle:PGDBDimStyle;
  ArrowParam:TDimArrowBlockParam;
  LeaderArrowSize:double;
  ArrowAngle:double;
  ArrowDirection:TzePoint3d;
  SplinePath:PGDBObjSpline;
  SplinePointCount:integer;
  HasTextTail,ArrowEnabled:boolean;
  pv:PGDBObjBlockInsert;
begin
  ConstObjArray.Free;
  if VertexArrayInOCS.Count<2 then
    exit;

  PDimStyle:=ResolveLeaderDimStyle(self,drawing);
  LeaderArrowSize:=ResolveLeaderArrowSize(self,PDimStyle);
  ArrowParam:=DimArrows[TArrowStyle(ResolveLeaderArrowStyleIndex(self,PDimStyle))];
  // Стрелка (ArrowStyle) отображается только тогда, когда длина первого
  // участка выноски не меньше удвоенного размера стрелки (пункт 2 задачи):
  // на более коротком участке стрелка не помещается и не строится.
  ArrowEnabled:=(ArrowHeadFlag<>0)and(ArrowParam.Name<>'')and
    (LeaderArrowSize<>0)and
    (LeaderSegmentLength(self,0)>=LeaderArrowSize*2);
  SplinePath:=nil;

  if (PathType=1)and(VertexArrayInOCS.Count>2) then begin
    HasTextTail:=LeaderHasTextTailSegment(self,LeaderArrowSize);
    SplinePointCount:=VertexArrayInOCS.Count;
    if HasTextTail then
      Dec(SplinePointCount);

    SplinePath:=CreateLeaderSplinePath(@self,drawing,DC,PDimStyle,
      SplinePointCount);
    if HasTextTail then begin
      p1:=VertexArrayInOCS.getDataMutable(VertexArrayInOCS.Count-2);
      p2:=VertexArrayInOCS.getDataMutable(VertexArrayInOCS.Count-1);
      CreateLeaderLineSegment(@self,drawing,DC,PDimStyle,p1^,p2^);
    end;
  end else begin
    for i:=0 to VertexArrayInOCS.Count-2 do begin
      p1:=VertexArrayInOCS.getDataMutable(i);
      p2:=VertexArrayInOCS.getDataMutable(i+1);
      CreateLeaderLineSegment(@self,drawing,DC,PDimStyle,p1^,p2^);
    end;
  end;

  if ArrowEnabled then begin
    p1:=VertexArrayInOCS.getDataMutable(0);
    p2:=VertexArrayInOCS.getDataMutable(1);
    drawing.CreateBlockDef(ArrowParam.Name);
    if (PathType=1)and(SplinePath<>nil) then
      ArrowDirection:=LeaderSplineStartDirection(SplinePath,p1^,p2^)
    else
      ArrowDirection:=VertexSub(p2^,p1^);
    ArrowAngle:=LeaderArrowAngleFromDirection(ArrowDirection,p1^,p2^);
    pointer(pv):=ENTF_CreateBlockInsert(@self,@self.ConstObjArray,
      vp.Layer,LeaderArrowLineType(self,PDimStyle),
      ResolveLeaderDimLineWeight(self,PDimStyle),
      ResolveLeaderDimLineColor(self,PDimStyle),
      ArrowParam.Name,p1^,LeaderArrowSize,ArrowAngle);
    if pv<>nil then begin
      pv^.BuildGeometry(drawing);
      pv^.FormatEntity(drawing,DC);
    end;
  end;
end;

procedure GDBObjLeader.DrawGeometry(lw:integer;var DC:TDrawContext;
  const inFrustumState:TInBoundingVolume);
begin
  inherited DrawGeometry(lw,DC,inFrustumState);
end;

function GDBObjLeader.Clone(own:Pointer):PGDBObjEntity;
var
  Leader:PGDBObjLeader;
begin
  Leader:=AllocAndInitLeader(PGDBObjGenericWithSubordinated(own));
  Leader^.DimStyleName:=DimStyleName;
  Leader^.ArrowHeadFlag:=ArrowHeadFlag;
  Leader^.PathType:=PathType;
  Leader^.AnnotationType:=AnnotationType;
  Leader^.HookLineDirectionFlag:=HookLineDirectionFlag;
  Leader^.HookLineFlag:=HookLineFlag;
  Leader^.TextHeight:=TextHeight;
  Leader^.TextWidth:=TextWidth;
  Leader^.AnnotationHandle:=AnnotationHandle;
  Leader^.NormalVector:=NormalVector;
  Leader^.HorizontalDirection:=HorizontalDirection;
  Leader^.BlockOffset:=BlockOffset;
  Leader^.AnnotationOffset:=AnnotationOffset;
  Leader^.ArrowStyleIndex:=ArrowStyleIndex;
  Leader^.ArrowSize:=ArrowSize;
  Leader^.DimLineWeight:=DimLineWeight;
  Leader^.DimLineColor:=DimLineColor;
  Leader^.Local:=Local;
  Leader^.P_insert_in_WCS:=P_insert_in_WCS;
  CopyVPto(Leader^);
  CopyExtensionsTo(Leader^);
  Leader^.VertexArrayInOCS.SetSize(VertexArrayInOCS.Count);
  VertexArrayInOCS.copyto(Leader^.VertexArrayInOCS);
  Leader^.bp.ListPos.Owner:=own;
  Result:=Leader;
end;

function GDBObjLeader.GetObjTypeName:string;
begin
  Result:=ObjN_GDBObjLeader;
end;

function GDBObjLeader.GetObjType:TObjID;
begin
  Result:=GDBLeaderID;
end;

function GDBObjLeader.CalcTrueInFrustum(
  const frustum:TzeFrustum):TInBoundingVolume;
begin
  Result:=inherited CalcTrueInFrustum(frustum);
end;

procedure GDBObjLeader.AddVertex(const Vertex:TzePoint3d);
begin
  VertexArrayInOCS.PushBackData(Vertex);
end;

function GDBObjLeader.GetLength:double;
var
  ptv,ptvprev:PzePoint3d;
  ir:itrec;
begin
  Result:=0;
  ptvprev:=VertexArrayInWCS.beginiterate(ir);
  ptv:=VertexArrayInWCS.iterate(ir);
  if ptv<>nil then
    repeat
      Result:=Result+ptv^.LengthTo(ptvprev^);
      ptvprev:=ptv;
      ptv:=VertexArrayInWCS.iterate(ir);
    until ptv=nil;
end;

procedure GDBObjLeader.TransformAt(p:PGDBObjEntity;t_matrix:PzeTypedMatrix4d);
var
  ptv,ptv2:PzePoint3d;
  ir,ir2:itrec;
begin
  ptv:=VertexArrayInOCS.beginiterate(ir);
  ptv2:=PGDBObjLeader(p)^.VertexArrayInOCS.beginiterate(ir2);
  if (ptv<>nil)and(ptv2<>nil) then
    repeat
      ptv^:=VectorTransform3D(ptv2^,t_matrix^);
      ptv:=VertexArrayInOCS.iterate(ir);
      ptv2:=PGDBObjLeader(p)^.VertexArrayInOCS.iterate(ir2);
    until (ptv=nil)or(ptv2=nil);
end;

procedure GDBObjLeader.transform(const t_matrix:TzeTypedMatrix4d);
var
  ptv:PzePoint3d;
  ir:itrec;
begin
  ptv:=VertexArrayInOCS.beginiterate(ir);
  if ptv<>nil then
    repeat
      ptv^:=VectorTransform3D(ptv^,t_matrix);
      ptv:=VertexArrayInOCS.iterate(ir);
    until ptv=nil;
end;

procedure GDBObjLeader.rtsave(refp:Pointer);
var
  p,pold:PzePoint3d;
  i:integer;
begin
  p:=VertexArrayInOCS.GetParrayAsPointer;
  pold:=PGDBObjLeader(refp)^.VertexArrayInOCS.GetParrayAsPointer;
  for i:=0 to VertexArrayInOCS.Count-1 do begin
    pold^:=p^;
    Inc(pold);
    Inc(p);
  end;
end;

function GDBObjLeader.onmouse(var popa:TZctnrVectorPGDBaseEntity;
  const MF:TzeFrustum;InSubEntry:boolean):boolean;
begin
  Result:=inherited onmouse(popa,MF,InSubEntry);
end;

function GDBObjLeader.onpoint(var objects:TZctnrVectorPGDBaseEntity;
  const point:TzePoint3d):boolean;
begin
  Result:=inherited onpoint(objects,point);
end;

procedure GDBObjLeader.rtmodifyonepoint(const rtmod:TRTModifyData);
var
  VertexNumber:integer;
begin
  VertexNumber:=rtmod.point.vertexnum;
  GDBPoint3dArray.PTArr(VertexArrayInOCS.parray)^[VertexNumber]:=
    rtmod.point.worldcoord+rtmod.dist.asVector;
end;

procedure GDBObjLeader.remaponecontrolpoint(pdesc:pcontrolpointdesc;
  ProjectProc:GDBProjectProc);
var
  VertexNumber:integer;
  tv:TzePoint3d;
begin
  VertexNumber:=pdesc^.vertexnum;
  pdesc^.worldcoord:=
    GDBPoint3dArray.PTArr(VertexArrayInWCS.parray)^[VertexNumber];
  ProjectProc(pdesc^.worldcoord,tv);
  pdesc^.dispcoord:={ToTzePoint2i}(tv.Slice.asPoint2i);
end;

procedure GDBObjLeader.addcontrolpoints(tdesc:Pointer);
var
  pdesc:controlpointdesc;
  i:integer;
  pv:PzePoint3d;
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

procedure GDBObjLeader.AddOnTrackAxis(var posr:os_record;
  const processaxis:taddotrac);
begin
  GDBPoint3dArrayAddOnTrackAxis(VertexArrayInWCS,posr,processaxis,False);
end;

procedure GDBObjLeader.startsnap(out osp:os_record;out pdata:Pointer);
begin
  inherited;
  Getmem(pdata,sizeof(GDBVectorSnapArray));
  PGDBVectorSnapArray(pdata)^.init(VertexArrayInWCS.Max);
  BuildSnapArray(VertexArrayInWCS,PGDBVectorSnapArray(pdata)^,False);
end;

procedure GDBObjLeader.endsnap(out osp:os_record;var pdata:Pointer);
begin
  if pdata<>nil then begin
    PGDBVectorSnapArray(pdata)^.Done;
    Freemem(pdata);
  end;
  inherited;
end;

function GDBObjLeader.getsnap(var osp:os_record;var pdata:Pointer;
  const param:OGLWndtype;ProjectProc:GDBProjectProc;
  SnapMode:TGDBOSMode):boolean;
begin
  Result:=GDBPoint3dArraygetsnapWOPProjPoint(VertexArrayInWCS,
    PGDBVectorSnapArray(pdata)^,osp,False,param,ProjectProc,SnapMode);
end;

function AllocLeader:PGDBObjLeader;
begin
  Getmem(pointer(Result),sizeof(GDBObjLeader));
  FillChar(Result^,sizeof(GDBObjLeader),0);
end;

function AllocAndInitLeader(owner:PGDBObjGenericWithSubordinated):PGDBObjLeader;
begin
  Result:=AllocLeader;
  Result^.initnul(owner);
  Result^.bp.ListPos.Owner:=owner;
end;

class function GDBObjLeader.CreateInstance:PGDBObjLeader;
begin
  Result:=AllocAndInitLeader(nil);
end;

begin
  RegisterDXFEntity(GDBLeaderID,'LEADER','Leader',@AllocLeader,@AllocAndInitLeader);
end.
