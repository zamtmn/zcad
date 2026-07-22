{*************************************************************************** }
{  fpdwg - DWG SOLID entity mapper (Stage 8)                                 }
{                                                                            }
{        Copyright (C) 2026 Andrey Zubarev <zamtmn@yandex.ru>                }
{                                                                            }
{  This library is free software, licensed under the terms of the GNU        }
{  General Public License as published by the Free Software Foundation,      }
{  either version 3 of the License, or (at your option) any later version.   }
{*************************************************************************** }

unit uzedwgentsolid;

{$Include zengineconfig.inc}
{$Mode delphi}{$H+}
{$ModeSwitch advancedrecords}

interface

uses
  SysUtils,
  dwg, dwgproc,
  uzedrawingsimple,
  uzeentity, uzeentsolid,
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
  if IsVectorNul(Result.asVector) then
    Result := ZWCS.asPoint3d;
end;

procedure AddSolidEntity(var ZContext: TZDrawingContext;
  var DWGContext: TDWGCtx; var DWGObject: Dwg_Object;
  PSolid: PDwg_Entity_SOLID);
var
  pobj: PGDBObjSolid;
  Props: TDWGSolidProps;
  i: Integer;
begin
  if PSolid = nil then
    Exit;

  pobj := GDBObjSolid.CreateInstance;
  DWGCopySolidProps(PSolid^, Props);
  for i := 0 to 3 do
    pobj^.PInOCS[i] := DWGPointToVertex(Props.Corners[i]);
  pobj^.Local.basis.oz := DWGNormalOrDefault(Props.Extrusion).asVector;

  if GetLoadCtx <> nil then
    DWGRegisterEntityShell(PGDBObjEntity(pobj), DWGObject, False, 0)
  else
    ZContext.PDrawing^.pObjRoot^.AddMi(PGDBObjSubordinated(pobj));
end;

initialization
  RegisterDWGEntityHandler(DWG_TYPE_SOLID, @AddSolidEntity);
end.
