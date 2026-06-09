{*************************************************************************** }
{  fpdwg - DWG LWPOLYLINE entity mapper (Stage 5.x R6)                       }
{                                                                            }
{        Copyright (C) 2026 Andrey Zubarev <zamtmn@yandex.ru>                }
{                                                                            }
{  This library is free software, licensed under the terms of the GNU        }
{  General Public License as published by the Free Software Foundation,      }
{  either version 3 of the License, or (at your option) any later version.   }
{*************************************************************************** }

unit uzedwgentlwpolyline;

{$Include zengineconfig.inc}
{$Mode delphi}{$H+}
{$ModeSwitch advancedrecords}

interface

uses
  SysUtils,
  dwg, dwgproc,
  uzedrawingsimple,
  uzeentlwpolyline, uzeentity, uzeentitiesprop,
  uzeentsubordinated,
  UGDBPolyLine2DArray,
  uzegeometrytypes,
  uzedwgloadcontext,
  uzedwgentityregistry,
  uzeffmanager,
  uzedwgimport;

implementation

procedure AddLWPolylineEntity(var ZContext: TZDrawingContext;
  var DWGContext: TDWGCtx; var DWGObject: Dwg_Object;
  PLWP: PDwg_Entity_LWPOLYLINE);
var
  pobj: PGDBObjLWPolyline;
  Props: TDWGLWPolylineProps;
  i, n, wcount: Integer;
  pp: PzePoint2d;
  pw: PGLLWWidth;
begin
  pobj := AllocAndInitLWpolyline(nil);
  DWGCopyLWPolylineProps(PLWP^, Props);
  pobj^.Closed := Props.Closed;
  pobj^.Local.p_insert.x := 0;
  pobj^.Local.p_insert.y := 0;
  pobj^.Local.p_insert.z := Props.Elevation;
  n := Length(Props.Vertices);
  pobj^.Vertex2D_in_OCS_Array.SetCount(n);
  // GDBObjLWPolyline expects one width record per vertex. Open polylines ignore
  // the trailing generated segment during draw, but CalcWidthSegment still
  // reads the last width slot while building its cached geometry.
  wcount := DWGLWPolylineWidthRecordCount(Props);
  pobj^.Width2D_in_OCS_Array.SetCount(wcount);
  for i := 0 to n - 1 do begin
    pp := pobj^.Vertex2D_in_OCS_Array.getDataMutable(i);
    pp^.x := Props.Vertices[i].X;
    pp^.y := Props.Vertices[i].Y;
    if i < wcount then begin
      pw := pobj^.Width2D_in_OCS_Array.getDataMutable(i);
      pw^.data.startw := Props.Vertices[i].StartWidth;
      pw^.data.endw := Props.Vertices[i].EndWidth;
      pw^.data.hw := (pw^.data.startw <> 0) or (pw^.data.endw <> 0);
    end;
  end;
  if GetLoadCtx <> nil then
    DWGRegisterEntityShell(PGDBObjEntity(pobj), DWGObject, False, 0)
  else
    ZContext.PDrawing^.pObjRoot^.AddMi(PGDBObjSubordinated(pobj));
end;

initialization
  RegisterDWGEntityHandler(DWG_TYPE_LWPOLYLINE, @AddLWPolylineEntity);
end.
