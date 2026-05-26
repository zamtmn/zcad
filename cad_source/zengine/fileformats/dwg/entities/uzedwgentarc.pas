{*************************************************************************** }
{  fpdwg - DWG ARC entity mapper (Stage 5.x R6)                              }
{                                                                            }
{        Copyright (C) 2026 Andrey Zubarev <zamtmn@yandex.ru>                }
{                                                                            }
{  This library is free software, licensed under the terms of the GNU        }
{  General Public License as published by the Free Software Foundation,      }
{  either version 3 of the License, or (at your option) any later version.   }
{*************************************************************************** }

unit uzedwgentarc;

{$Include zengineconfig.inc}
{$Mode delphi}{$H+}
{$ModeSwitch advancedrecords}

interface

uses
  SysUtils,
  dwg, dwgproc,
  uzedrawingsimple,
  uzeentarc, uzeentity,
  uzeentsubordinated,
  uzedwgloadcontext,
  uzedwgentityregistry,
  uzeffmanager,
  uzedwgimport;

implementation

procedure AddArcEntity(var ZContext: TZDrawingContext;
  var DWGContext: TDWGCtx; var DWGObject: Dwg_Object; PArc: PDwg_Entity_ARC);
var
  pobj: PGDBObjArc;
  Props: TDWGArcProps;
begin
  pobj := AllocAndInitArc(nil);
  DWGCopyArcProps(PArc^, Props);
  pobj^.Local.p_insert.x := Props.CenterX;
  pobj^.Local.p_insert.y := Props.CenterY;
  pobj^.Local.p_insert.z := Props.CenterZ;
  pobj^.r := Props.Radius;
  pobj^.startangle := Props.StartAngle;
  pobj^.endangle := Props.EndAngle;
  if GetLoadCtx <> nil then
    DWGRegisterEntityShell(PGDBObjEntity(pobj), DWGObject, False, 0)
  else
    ZContext.PDrawing^.pObjRoot^.AddMi(PGDBObjSubordinated(pobj));
end;

initialization
  RegisterDWGEntityHandler(DWG_TYPE_ARC, @AddArcEntity);
end.
