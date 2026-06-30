{*************************************************************************** }
{  fpdwg - DWG POINT entity mapper (Stage 5.x R6)                            }
{                                                                            }
{        Copyright (C) 2026 Andrey Zubarev <zamtmn@yandex.ru>                }
{                                                                            }
{  This library is free software, licensed under the terms of the GNU        }
{  General Public License as published by the Free Software Foundation,      }
{  either version 3 of the License, or (at your option) any later version.   }
{*************************************************************************** }

unit uzedwgentpoint;

{$Include zengineconfig.inc}
{$Mode delphi}{$H+}
{$ModeSwitch advancedrecords}

interface

uses
  SysUtils,
  dwg, dwgproc,
  uzedrawingsimple,
  uzeentpoint, uzeentity,
  uzeentsubordinated,
  uzedwgloadcontext,
  uzedwgentityregistry,
  uzeffmanager,
  uzedwgimport;

implementation

procedure AddPointEntity(var ZContext: TZDrawingContext;
  var DWGContext: TDWGCtx; var DWGObject: Dwg_Object;
  PPoint: PDwg_Entity_POINT);
var
  pobj: PGDBObjPoint;
  Props: TDWGPointProps;
begin
  pobj := AllocAndInitPoint(nil);
  DWGCopyPointProps(PPoint^, Props);
  pobj^.P_insertInOCS.x := Props.X;
  pobj^.P_insertInOCS.y := Props.Y;
  pobj^.P_insertInOCS.z := Props.Z;
  if GetLoadCtx <> nil then
    DWGRegisterEntityShell(PGDBObjEntity(pobj), DWGObject, False, 0)
  else
    ZContext.PDrawing^.pObjRoot^.AddMi(PGDBObjSubordinated(pobj));
end;

initialization
  RegisterDWGEntityHandler(DWG_TYPE_POINT, @AddPointEntity);
end.
