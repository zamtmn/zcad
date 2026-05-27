{*************************************************************************** }
{  fpdwg - DWG LINE entity mapper (Stage 5.x R6)                             }
{                                                                            }
{        Copyright (C) 2026 Andrey Zubarev <zamtmn@yandex.ru>                }
{                                                                            }
{  This library is free software, licensed under the terms of the GNU        }
{  General Public License as published by the Free Software Foundation,      }
{  either version 3 of the License, or (at your option) any later version.   }
{*************************************************************************** }

{ Refactor R6 (per TZ_DWG_LOAD_TO_ZCAD_AUDIT §3.6 / TZ §6.5):
  AddLineEntity extracted from uzefflibredwg2ents.pas. Self-registers
  through uzedwgentityregistry; fallback path (LoadCtx=nil) attaches to
  pObjRoot directly so an experimental host that bypasses BeginDWGImport
  still yields a visible entity. }

unit uzedwgentline;

{$Include zengineconfig.inc}
{$Mode delphi}{$H+}
{$ModeSwitch advancedrecords}

interface

uses
  SysUtils,
  dwg, dwgproc, uzedwghandle,
  uzedrawingsimple,
  uzeentline, uzeentity,
  uzeentsubordinated,
  uzedwgentityregistry,
  uzeffmanager,
  uzedwgtypes,
  uzedwgtargetedlog,
  uzedwgimport;

implementation

uses
  uzedwglog;

procedure AddLineEntity(var ZContext: TZDrawingContext;
  var DWGContext: TDWGCtx; var DWGObject: Dwg_Object; PLine: PDwg_Entity_LINE);
var
  pobj: PGDBObjEntity;
  Endpoints: TDWGLineEndpoints;
  LineHandle: QWord;
begin
  // Stage 2 (TZ §12.2): validate geometry before allocating a ZCAD line, then
  // register the shell + pending owner. The actual AddMi happens in
  // DWGAttachEntity when ResolveOwners runs after parseDwg_Data. The line is
  // *never* added to pObjRoot here — that was the original bug that caused
  // entities to attach to the model-space root before their block-def owner
  // was visible.
  LineHandle := DWGObjectHandleValue(DWGObject);
  // Issue #1203: точечный лог входа в mapper LINE. Содержит длину сегмента,
  // чтобы было понятно, скипнется ли объект из-за нулевой геометрии.
  TargetedLog('parse-line', LineHandle, '');
  DWGCopyLineEndpoints(PLine^, Endpoints);
  if DWGLineEndpointsAreZeroLength(Endpoints) then begin
    DWGLogWarningFormatStr('DWG LINE %s skipped: zero-length geometry',
      [DWGHandleLogText(LineHandle)]);
    // Issue #1203: явно отметим в целевом логе, что объект отсеян здесь —
    // частая причина «исчезновения» вырожденных LINE-сущностей.
    TargetedLog('skip-zero-line', LineHandle, 'zero-length geometry');
    if GetLoadCtx <> nil then
      GetLoadCtx.MarkShellState(LineHandle, msSkipped);
    Exit;
  end;

  pobj := AllocAndInitLine(nil);
  PGDBObjLine(pobj)^.CoordInOCS.lBegin.x := Endpoints.StartX;
  PGDBObjLine(pobj)^.CoordInOCS.lBegin.y := Endpoints.StartY;
  PGDBObjLine(pobj)^.CoordInOCS.lBegin.z := Endpoints.StartZ;
  PGDBObjLine(pobj)^.CoordInOCS.lEnd.x := Endpoints.EndX;
  PGDBObjLine(pobj)^.CoordInOCS.lEnd.y := Endpoints.EndY;
  PGDBObjLine(pobj)^.CoordInOCS.lEnd.z := Endpoints.EndZ;

  //DWGLogInfoFormatStr(
  //  'DWG LINE geometry handle=%s start=(%s,%s,%s) end=(%s,%s,%s)',
  //  [DWGHandleLogText(LineHandle), FloatToStr(Endpoints.StartX),
  //   FloatToStr(Endpoints.StartY), FloatToStr(Endpoints.StartZ),
  //   FloatToStr(Endpoints.EndX), FloatToStr(Endpoints.EndY),
  //   FloatToStr(Endpoints.EndZ)]);

  if GetLoadCtx <> nil then
    DWGRegisterEntityShell(pobj, DWGObject, False, 0)
  else begin
    // Compatibility fallback: if BeginDWGImport was not called the loader
    // still works (legacy single-pass behaviour). New callers always go
    // through Begin/End, so this branch is exercised only by future
    // experimental hosts that bypass the standard pipeline.
    ZContext.PDrawing^.pObjRoot^.AddMi(PGDBObjSubordinated(pobj));
  end;
end;

initialization
  RegisterDWGEntityHandler(DWG_TYPE_LINE, @AddLineEntity);
end.
