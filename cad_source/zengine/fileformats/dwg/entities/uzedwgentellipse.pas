{*************************************************************************** }
{  fpdwg - DWG ELLIPSE entity mapper (Stage 8)                               }
{                                                                            }
{        Copyright (C) 2026 Andrey Zubarev <zamtmn@yandex.ru>                }
{                                                                            }
{  This library is free software, licensed under the terms of the GNU        }
{  General Public License as published by the Free Software Foundation,      }
{  either version 3 of the License, or (at your option) any later version.   }
{*************************************************************************** }

unit uzedwgentellipse;

{$Include zengineconfig.inc}
{$Mode delphi}{$H+}
{$ModeSwitch advancedrecords}

interface

uses
  SysUtils,
  dwg, dwgproc,
  uzedrawingsimple,
  uzeentity, uzeentellipse,
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

function DWGNormalOrDefault(const P: TDWGPoint3D): TzePoint3d;
begin
  Result := DWGPointToVertex(P);
  if IsVectorNul(Result) then
    Result := ZWCS;
end;

procedure AddEllipseEntity(var ZContext: TZDrawingContext;
  var DWGContext: TDWGCtx; var DWGObject: Dwg_Object;
  PEllipse: PDwg_Entity_ELLIPSE);
var
  pobj: PGDBObjEllipse;
  Props: TDWGEllipseProps;
begin
  if PEllipse = nil then
    Exit;

  pobj := GDBObjEllipse.CreateInstance;
  DWGCopyEllipseProps(PEllipse^, Props);
  pobj^.Local.p_insert := DWGPointToVertex(Props.Center);
  pobj^.Local.basis.oz := DWGNormalOrDefault(Props.Extrusion);
  pobj^.MajorAxis := DWGPointToVertex(Props.MajorAxis);
  pobj^.Ratio := Props.AxisRatio;
  pobj^.StartAngle := Props.StartAngle;
  pobj^.EndAngle := Props.EndAngle;

  if GetLoadCtx <> nil then
    DWGRegisterEntityShell(PGDBObjEntity(pobj), DWGObject, False, 0)
  else
    ZContext.PDrawing^.pObjRoot^.AddMi(PGDBObjSubordinated(pobj));
end;

initialization
  RegisterDWGEntityHandler(DWG_TYPE_ELLIPSE, @AddEllipseEntity);
end.
