{*************************************************************************** }
{  fpdwg - DWG 3DFACE entity mapper (Stage 8)                                }
{                                                                            }
{        Copyright (C) 2026 Andrey Zubarev <zamtmn@yandex.ru>                }
{                                                                            }
{  This library is free software, licensed under the terms of the GNU        }
{  General Public License as published by the Free Software Foundation,      }
{  either version 3 of the License, or (at your option) any later version.   }
{*************************************************************************** }

unit uzedwgent3dface;

{$Include zengineconfig.inc}
{$Mode delphi}{$H+}
{$ModeSwitch advancedrecords}

interface

uses
  SysUtils,
  dwg, dwgproc,
  uzedrawingsimple,
  uzeentity, uzeent3dface,
  uzeentsubordinated,
  uzegeometrytypes,
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

procedure Add3DFaceEntity(var ZContext: TZDrawingContext;
  var DWGContext: TDWGCtx; var DWGObject: Dwg_Object;
  PFace: PDwg_Entity__3DFACE);
var
  pobj: PGDBObj3DFace;
  Props: TDWG3DFaceProps;
  i: Integer;
begin
  if PFace = nil then
    Exit;

  pobj := GDBObj3DFace.CreateInstance;
  DWGCopy3DFaceProps(PFace^, Props);
  for i := 0 to 3 do
    pobj^.PInOCS[i] := DWGPointToVertex(Props.Corners[i]);

  if GetLoadCtx <> nil then
    DWGRegisterEntityShell(PGDBObjEntity(pobj), DWGObject, False, 0)
  else
    ZContext.PDrawing^.pObjRoot^.AddMi(PGDBObjSubordinated(pobj));
end;

initialization
  RegisterDWGEntityHandler(DWG_TYPE__3DFACE, @Add3DFaceEntity);
end.
