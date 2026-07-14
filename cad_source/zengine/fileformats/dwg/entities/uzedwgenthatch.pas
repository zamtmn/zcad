{*************************************************************************** }
{  fpdwg - DWG HATCH entity mapper (Stage 8)                                 }
{                                                                            }
{        Copyright (C) 2026 Andrey Zubarev <zamtmn@yandex.ru>                }
{                                                                            }
{  This library is free software, licensed under the terms of the GNU        }
{  General Public License as published by the Free Software Foundation,      }
{  either version 3 of the License, or (at your option) any later version.   }
{*************************************************************************** }

unit uzedwgenthatch;

{$Include zengineconfig.inc}
{$Mode delphi}{$H+}
{$ModeSwitch advancedrecords}

interface

uses
  SysUtils, Math,
  dwg, dwgproc,
  uzedrawingsimple,
  uzeentity, uzeenthatch,
  uzeentsubordinated,
  uzegeometrytypes, uzegeometry,
  UGDBPolyLine2DArray,
  uzeStylesHatchPatterns,
  uzedwgloadcontext,
  uzedwgentityregistry,
  uzeffmanager,
  uzedwgimport;

implementation

type
  PHatchPath = ^Dwg_HATCH_Path;
  PHatchPathSeg = ^Dwg_HATCH_PathSeg;
  PHatchControlPoint = ^Dwg_HATCH_ControlPoint;
  PBitcode2RD = ^BITCODE_2RD;

function BLToInt(Value: BITCODE_BL): Integer;
begin
  if Value > BITCODE_BL(High(Integer)) then
    Result := High(Integer)
  else
    Result := Integer(Value);
end;

function Point2D(X, Y: Double): TzePoint2d;
begin
  Result.x := X;
  Result.y := Y;
end;

function RawPoint2D(const P: BITCODE_2RD): TzePoint2d;
begin
  Result.x := P.x;
  Result.y := P.y;
end;

function HatchPoint2D(const P: TDWGHatchPolylinePoint): TzePoint2d;
begin
  Result.x := P.X;
  Result.y := P.Y;
end;

function DWGPointToVertex(const P: TDWGPoint3D): TzePoint3d;
begin
  Result.x := P.X;
  Result.y := P.Y;
  Result.z := P.Z;
end;

function DWGNormalOrDefault(const P: TDWGPoint3D): TzePoint3d;
begin
  Result := DWGPointToVertex(P);
  if IsVectorNul(Result.asVector3d) then
    Result := ZWCS.asPoint3d;
end;

function SamePoint2D(const A, B: TzePoint2d): Boolean;
const
  Eps = 1e-9;
begin
  Result := (Abs(A.x - B.x) <= Eps) and (Abs(A.y - B.y) <= Eps);
end;

procedure PushPoint(var Path: GDBPolyline2DArray; const P: TzePoint2d;
  Unique: Boolean = True);
var
  Last: PzePoint2d;
begin
  if Unique and (Path.Count > 0) then begin
    Last := Path.getDataMutable(Path.Count - 1);
    if (Last <> nil) and SamePoint2D(Last^, P) then
      Exit;
  end;
  Path.PushBackData(P);
end;

procedure AppendPolylineBoundary(var Path: GDBPolyline2DArray;
  const HPath: TDWGHatchPathProps);
var
  i, PointCount: Integer;

  procedure AppendBulgedSegment(const P1, P2: TzePoint2d;
    Bulge: Double; DivCount: Integer);
  const
    Eps = 1e-12;
  var
    DX, DY, Len, H, NextBulge: Double;
    Mid, ArcPoint, Normal: TzePoint2d;
  begin
    if Abs(Bulge) <= Eps then begin
      PushPoint(Path, P1);
      PushPoint(Path, P2);
      Exit;
    end;

    DX := P2.x - P1.x;
    DY := P2.y - P1.y;
    Len := Sqrt(DX * DX + DY * DY);
    if Len <= Eps then begin
      PushPoint(Path, P1);
      Exit;
    end;

    H := Len * Bulge / 2;
    Mid.x := (P1.x + P2.x) / 2;
    Mid.y := (P1.y + P2.y) / 2;
    Normal.x := -DY / Len;
    Normal.y := DX / Len;
    ArcPoint.x := Mid.x - Normal.x * H;
    ArcPoint.y := Mid.y - Normal.y * H;

    if DivCount < 0 then begin
      DivCount := Abs(Integer(Round(Bulge * 2)));
      if DivCount < 2 then
        DivCount := 2
      else if DivCount > 5 then
        DivCount := 5;
    end;
    if DivCount = 0 then begin
      PushPoint(Path, P1);
      PushPoint(Path, ArcPoint);
      PushPoint(Path, P2);
    end else begin
      Dec(DivCount);
      NextBulge := Bulge / (1 + Sqrt(1 + Bulge * Bulge));
      AppendBulgedSegment(P1, ArcPoint, NextBulge, DivCount);
      AppendBulgedSegment(ArcPoint, P2, NextBulge, DivCount);
    end;
  end;
begin
  PointCount := Length(HPath.PolylinePoints);
  if PointCount = 0 then
    Exit;
  if PointCount = 1 then begin
    PushPoint(Path, HatchPoint2D(HPath.PolylinePoints[0]));
    Exit;
  end;
  for i := 0 to PointCount - 2 do
    AppendBulgedSegment(HatchPoint2D(HPath.PolylinePoints[i]),
      HatchPoint2D(HPath.PolylinePoints[i + 1]),
      HPath.PolylinePoints[i].Bulge, -1);
  if HPath.Closed then
    AppendBulgedSegment(HatchPoint2D(HPath.PolylinePoints[PointCount - 1]),
      HatchPoint2D(HPath.PolylinePoints[0]),
      HPath.PolylinePoints[PointCount - 1].Bulge, -1)
  else
    PushPoint(Path, HatchPoint2D(HPath.PolylinePoints[PointCount - 1]));
end;

procedure AppendArc(var Path: GDBPolyline2DArray;
  const Center: BITCODE_2RD; Radius, StartAngle, EndAngle: Double;
  IsCCW: Boolean);
var
  k, Segments: Integer;
  A: Double;
begin
  if Radius <= 0 then
    Exit;
  Segments := 16;
  for k := 1 to Segments do begin
    A := DWGHatchArcSampleAngle(StartAngle, EndAngle, IsCCW, k, Segments);
    PushPoint(Path, Point2D(Center.x + Cos(A) * Radius,
      Center.y + Sin(A) * Radius));
  end;
end;

procedure AppendSplineEdge(var Path: GDBPolyline2DArray;
  const Seg: Dwg_HATCH_PathSeg);
var
  i, Count: Integer;
  pFit: PBitcode2RD;
  pControl: PHatchControlPoint;
begin
  Count := BLToInt(Seg.num_fitpts);
  if (Count > 0) and (Seg.fitpts <> nil) then begin
    pFit := PBitcode2RD(Seg.fitpts);
    for i := 0 to Count - 1 do begin
      PushPoint(Path, RawPoint2D(pFit^));
      Inc(pFit);
    end;
    Exit;
  end;

  Count := BLToInt(Seg.num_control_points);
  if (Count > 0) and (Seg.control_points <> nil) then begin
    pControl := PHatchControlPoint(Seg.control_points);
    for i := 0 to Count - 1 do begin
      PushPoint(Path, RawPoint2D(pControl^.point));
      Inc(pControl);
    end;
  end;
end;

procedure AppendSegmentBoundary(var Path: GDBPolyline2DArray;
  const HPath: Dwg_HATCH_Path);
var
  i, Count: Integer;
  pSeg: PHatchPathSeg;
begin
  Count := BLToInt(HPath.num_segs_or_paths);
  if (Count <= 0) or (HPath.segs = nil) then
    Exit;
  pSeg := PHatchPathSeg(HPath.segs);
  for i := 0 to Count - 1 do begin
    case pSeg^.curve_type of
      1:
        begin
          PushPoint(Path, RawPoint2D(pSeg^.first_endpoint));
          PushPoint(Path, RawPoint2D(pSeg^.second_endpoint));
        end;
      2:
        AppendArc(Path, pSeg^.center, pSeg^.radius,
          pSeg^.start_angle, pSeg^.end_angle, pSeg^.is_ccw <> 0);
      4:
        AppendSplineEdge(Path, pSeg^);
    end;
    Inc(pSeg);
  end;
end;

procedure AddPathIfNotEmpty(pobj: PGDBObjHatch; var Path: GDBPolyline2DArray);
begin
  if Path.Count = 0 then begin
    Path.done;
    Exit;
  end;
  Path.Shrink;
  pobj^.Path.paths.PushBackData(Path);
end;

procedure CopyHatchBoundaries(pobj: PGDBObjHatch; const Props: TDWGHatchProps;
  PHatch: PDwg_Entity_HATCH);
var
  i: Integer;
  Path: GDBPolyline2DArray;
  pRawPath: PHatchPath;
begin
  for i := 0 to High(Props.Paths) do begin
    Path.init(Max(Length(Props.Paths[i].PolylinePoints), 8), True);
    if Props.Paths[i].IsPolyline then
      AppendPolylineBoundary(Path, Props.Paths[i])
    else if (PHatch <> nil) and (PHatch^.paths <> nil) then begin
      pRawPath := PHatchPath(PHatch^.paths);
      Inc(pRawPath, i);
      AppendSegmentBoundary(Path, pRawPath^);
    end;
    AddPathIfNotEmpty(pobj, Path);
  end;
end;

procedure CopyHatchPattern(pobj: PGDBObjHatch; const Props: TDWGHatchProps);
var
  i, j: Integer;
  MainAngleRad, SinA, CosA: Double;
  PatLine: PTPatStrokesArray;
begin
  if Props.IsSolidFill or (Length(Props.PatternLines) = 0) then
    Exit;

  pobj^.PPattern := GetMem(SizeOf(THatchPattern));
  pobj^.PPattern^.init(Length(Props.PatternLines));

  MainAngleRad := DegToRad(pobj^.Angle);
  SinCos(-MainAngleRad, SinA, CosA);
  for i := 0 to High(Props.PatternLines) do begin
    PatLine := pobj^.PPattern^.CreateObject;
    PatLine^.init(Length(Props.PatternLines[i].Dashes));
    PatLine^.Angle := RadToDeg(Props.PatternLines[i].Angle) - pobj^.Angle;
    PatLine^.Base.x := Props.PatternLines[i].Base.X / pobj^.Scale;
    PatLine^.Base.y := Props.PatternLines[i].Base.Y / pobj^.Scale;
    PatLine^.Offset.x := (Props.PatternLines[i].Offset.X * CosA -
      Props.PatternLines[i].Offset.Y * SinA) / pobj^.Scale;
    PatLine^.Offset.y := (Props.PatternLines[i].Offset.Y * CosA +
      Props.PatternLines[i].Offset.X * SinA) / pobj^.Scale;
    for j := 0 to High(Props.PatternLines[i].Dashes) do
      PatLine^.PushBackData(Props.PatternLines[i].Dashes[j] / pobj^.Scale);
    PatLine^.format;
  end;
end;

procedure AddHatchEntity(var ZContext: TZDrawingContext;
  var DWGContext: TDWGCtx; var DWGObject: Dwg_Object;
  PHatch: PDwg_Entity_HATCH);
var
  pobj: PGDBObjHatch;
  Props: TDWGHatchProps;
begin
  if PHatch = nil then
    Exit;

  DWGCopyHatchProps(PHatch^, DWGContext.DWGVer, DWGContext.DWGCodePage,
    Props);
  pobj := GDBObjHatch.CreateInstance;
  pobj^.Local.p_insert := CreateVertex(0, 0, Props.Elevation);
  pobj^.Local.basis.oz := DWGNormalOrDefault(Props.Extrusion).asVector3d;
  pobj^.PatternName := Props.PatternName;
  if (pobj^.PatternName = '') and Props.IsSolidFill then
    pobj^.PatternName := 'SOLID';
  pobj^.Angle := RadToDeg(Props.Angle);
  pobj^.Scale := Props.Scale;
  if pobj^.Scale = 0 then
    pobj^.Scale := 1;
  case Props.Style of
    1: pobj^.IslandDetection := HID_Outer;
    2: pobj^.IslandDetection := HID_Ignore;
  else
    pobj^.IslandDetection := HID_Normal;
  end;
  CopyHatchPattern(pobj, Props);
  CopyHatchBoundaries(pobj, Props, PHatch);

  if GetLoadCtx <> nil then
    DWGRegisterEntityShell(PGDBObjEntity(pobj), DWGObject, False, 0)
  else
    ZContext.PDrawing^.pObjRoot^.AddMi(PGDBObjSubordinated(pobj));
end;

initialization
  RegisterDWGEntityHandler(DWG_TYPE_HATCH, @AddHatchEntity);
end.
