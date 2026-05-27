{*************************************************************************** }
{  fpdwg - DWG CIRCLE entity mapper (Stage 5.x R6)                           }
{                                                                            }
{        Copyright (C) 2026 Andrey Zubarev <zamtmn@yandex.ru>                }
{                                                                            }
{  This library is free software, licensed under the terms of the GNU        }
{  General Public License as published by the Free Software Foundation,      }
{  either version 3 of the License, or (at your option) any later version.   }
{*************************************************************************** }

unit uzedwgentcircle;

{$Include zengineconfig.inc}
{$Mode delphi}{$H+}
{$ModeSwitch advancedrecords}

interface

uses
  SysUtils,
  dwg, dwgproc,
  uzedrawingsimple,
  uzeentcircle, uzeentity,
  uzeentsubordinated,
  uzedwgloadcontext,
  uzedwgentityregistry,
  uzeffmanager,
  uzedwgimport;

implementation

procedure AddCircleEntity(var ZContext: TZDrawingContext;
  var DWGContext: TDWGCtx; var DWGObject: Dwg_Object;
  PCircle: PDwg_Entity_CIRCLE);
var
  pobj: PGDBObjCircle;
  Props: TDWGCircleProps;
begin
  pobj := AllocAndInitCircle(nil);
  DWGCopyCircleProps(PCircle^, Props);
  pobj^.Local.p_insert.x := Props.CenterX;
  pobj^.Local.p_insert.y := Props.CenterY;
  pobj^.Local.p_insert.z := Props.CenterZ;
  pobj^.Radius := Props.Radius;
  if GetLoadCtx <> nil then
    DWGRegisterEntityShell(PGDBObjEntity(pobj), DWGObject, False, 0)
  else
    ZContext.PDrawing^.pObjRoot^.AddMi(PGDBObjSubordinated(pobj));
end;

initialization
  RegisterDWGEntityHandler(DWG_TYPE_CIRCLE, @AddCircleEntity);
end.
