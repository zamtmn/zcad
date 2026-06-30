{*************************************************************************** }
{  fpdwg - DWG SPLINE entity mapper (Stage 8)                                }
{                                                                            }
{        Copyright (C) 2026 Andrey Zubarev <zamtmn@yandex.ru>                }
{                                                                            }
{  This library is free software, licensed under the terms of the GNU        }
{  General Public License as published by the Free Software Foundation,      }
{  either version 3 of the License, or (at your option) any later version.   }
{*************************************************************************** }

unit uzedwgentspline;

{$Include zengineconfig.inc}
{$Mode delphi}{$H+}
{$ModeSwitch advancedrecords}

interface

uses
  SysUtils,
  dwg, dwgproc,
  uzedrawingsimple,
  uzeentity, uzeentspline,
  uzeentsubordinated,
  uzegeometrytypes, uzegeometry,
  uzedwgloadcontext,
  uzedwgentityregistry,
  uzeffmanager,
  uzedwgimport;

implementation

function DWGPointToVertex(const P: TDWGPoint3D): TzePoint3d;
begin
  Result.x := P.X;
  Result.y := P.Y;
  Result.z := P.Z;
end;

function ClampSplineDegree(Degree, ControlCount: Integer): Integer;
begin
  Result := Degree;
  if Result < 1 then
    Result := 1;
  if ControlCount > 1 then begin
    if Result >= ControlCount then
      Result := ControlCount - 1;
  end else
    Result := 1;
end;

procedure GenerateOpenUniformKnots(pobj: PGDBObjSpline; ControlCount: Integer);
var
  i, KnotCount, Denom: Integer;
  Value: Double;
  Knot: Single;
begin
  pobj^.Knots.Clear;
  if ControlCount <= 0 then
    Exit;
  KnotCount := ControlCount + pobj^.Degree + 1;
  Denom := ControlCount - pobj^.Degree;
  if Denom < 1 then
    Denom := 1;
  for i := 0 to KnotCount - 1 do begin
    if i <= pobj^.Degree then
      Value := 0
    else if i >= ControlCount then
      Value := 1
    else
      Value := (i - pobj^.Degree) / Denom;
    Knot := Value;
    pobj^.Knots.PushBackData(Knot);
  end;
end;

procedure ApplySplineOpts(pobj: PGDBObjSpline; const Props: TDWGSplineProps);
begin
  pobj^.Opts := [];
  if Props.Closed then
    pobj^.Opts := pobj^.Opts + [SOClosed];
  if Props.Periodic then
    pobj^.Opts := pobj^.Opts + [SOPeriodic];
  if Props.Rational or Props.Weighted then
    pobj^.Opts := pobj^.Opts + [SORational];
  pobj^.Closed := SOClosed in pobj^.Opts;
end;

procedure AddSplineEntity(var ZContext: TZDrawingContext;
  var DWGContext: TDWGCtx; var DWGObject: Dwg_Object;
  PSpline: PDwg_Entity_SPLINE);
var
  pobj: PGDBObjSpline;
  Props: TDWGSplineProps;
  i, PointCount: Integer;
  Knot: Single;
begin
  if PSpline = nil then
    Exit;

  DWGCopySplineProps(PSpline^, Props);
  PointCount := Length(Props.ControlPoints);
  if PointCount = 0 then
    PointCount := Length(Props.FitPoints);
  if PointCount = 0 then
    Exit;

  pobj := AllocAndInitSpline(nil);
  pobj^.VertexArrayInOCS.Clear;
  ApplySplineOpts(pobj, Props);
  pobj^.Degree := ClampSplineDegree(Props.Degree, PointCount);

  if Length(Props.ControlPoints) > 0 then begin
    for i := 0 to High(Props.ControlPoints) do
      pobj^.AddVertex(CreateVertex(Props.ControlPoints[i].X,
        Props.ControlPoints[i].Y, Props.ControlPoints[i].Z));
  end else begin
    for i := 0 to High(Props.FitPoints) do
      pobj^.AddVertex(DWGPointToVertex(Props.FitPoints[i]));
  end;

  pobj^.Knots.Clear;
  if Length(Props.Knots) > 0 then
    for i := 0 to High(Props.Knots) do
    begin
      Knot := Props.Knots[i];
      pobj^.Knots.PushBackData(Knot);
    end;
  if pobj^.Knots.Count = 0 then
    GenerateOpenUniformKnots(pobj, PointCount);

  if GetLoadCtx <> nil then
    DWGRegisterEntityShell(PGDBObjEntity(pobj), DWGObject, False, 0)
  else
    ZContext.PDrawing^.pObjRoot^.AddMi(PGDBObjSubordinated(pobj));
end;

initialization
  RegisterDWGEntityHandler(DWG_TYPE_SPLINE, @AddSplineEntity);
end.
