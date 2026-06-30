{*************************************************************************** }
{  fpdwg - DWG control / table-control object mappers (Issue #1198 P2)        }
{                                                                            }
{        Copyright (C) 2026 Andrey Zubarev <zamtmn@yandex.ru>                }
{                                                                            }
{  This library is free software, licensed under the terms of the GNU        }
{  General Public License as published by the Free Software Foundation,      }
{  either version 3 of the License, or (at your option) any later version.   }
{*************************************************************************** }

{ Issue #1198 P2 (TZ_DWG_LOAD_TO_ZCAD_AUDIT §5):
  Lightweight handlers for DWG table-control objects (LAYER_CONTROL,
  LTYPE_CONTROL, BLOCK_CONTROL, STYLE_CONTROL, DIMSTYLE_CONTROL,
  VIEW_CONTROL, UCS_CONTROL, VPORT_CONTROL, APPID_CONTROL, VX_CONTROL) and
  for auxiliary objects (DICTIONARY, XRECORD, GROUP, MLINESTYLE,
  PLACEHOLDER, LAYOUT).

  These objects own/describe data that ZCAD does not directly mirror, but
  they DO get referenced by other handles (entity ownership chains, dictionary
  entries, etc.). Before this unit existed, those references resolved to a
  dokUnknown placeholder, which produced a "ref kind mismatch" warning per
  reference. Promoting them to dokControlObject lets the diagnostic
  histogram report "known control object" instead of "unhandled type", and
  gives future resolver tweaks a stable kind to branch on.

  The mappers do not allocate ZCAD objects: they only call RegisterShell with
  Ptr=nil. This is intentional and matches the spec's lightweight-mapper
  option. }

unit uzedwgcontrolobjects;

{$Include zengineconfig.inc}
{$Mode delphi}{$H+}
{$ModeSwitch advancedrecords}

interface

uses
  SysUtils,
  dwg, dwgproc,
  uzedwghandle,
  uzeffmanager,
  uzedrawingsimple,
  uzedwgloadcontext,
  uzedwgentityregistry,
  uzedwgtypes,
  uzedwgimport;

implementation

{ The mapper signature carries a 4th parameter typed to whatever LibreDWG
  exposes for that fixedtype. Each control object has its own struct
  (Dwg_Object_LAYER_CONTROL, Dwg_Object_BLOCK_CONTROL, ...) — we do not need
  to touch the payload, so the parameter is taken as a raw Pointer. Pascal
  routine-pointer compatibility ignores the payload type because
  parseDwg_Data casts through TDWGObjectLoadProc. }

procedure PromoteToControl(var ZContext: TZDrawingContext;
  var DWGContext: TDWGCtx; var DWGObject: Dwg_Object; Payload: Pointer);
var
  Ctx: TDWGZCADLoadContext;
  Handle: TDWGZCADHandle;
begin
  Ctx := GetLoadCtx;
  if Ctx = nil then
    Exit;
  Handle := DWGObjectHandleValue(DWGObject);
  if Handle = 0 then
    Exit;
  // RegisterShell upgrades the dokUnknown placeholder left by the raw scan
  // (or inserts a fresh entry if the placeholder is missing for some reason).
  // Ptr stays nil — the control object has no ZCAD-side allocation.
  Ctx.RegisterShell(Handle, dokControlObject, nil, -1);
end;

initialization
  // Table-control objects. Each holds a list of table records (e.g.
  // LAYER_CONTROL.layers[] -> LAYER handles). The records themselves are
  // mapped by uzedwgtables / uzedwgblocks; this entry only ensures the
  // control handle itself is classified.
  RegisterDWGObjectHandler(DWG_TYPE_BLOCK_CONTROL,    @PromoteToControl);
  RegisterDWGObjectHandler(DWG_TYPE_LAYER_CONTROL,    @PromoteToControl);
  RegisterDWGObjectHandler(DWG_TYPE_STYLE_CONTROL,    @PromoteToControl);
  RegisterDWGObjectHandler(DWG_TYPE_LTYPE_CONTROL,    @PromoteToControl);
  RegisterDWGObjectHandler(DWG_TYPE_VIEW_CONTROL,     @PromoteToControl);
  RegisterDWGObjectHandler(DWG_TYPE_UCS_CONTROL,      @PromoteToControl);
  RegisterDWGObjectHandler(DWG_TYPE_VPORT_CONTROL,    @PromoteToControl);
  RegisterDWGObjectHandler(DWG_TYPE_APPID_CONTROL,    @PromoteToControl);
  RegisterDWGObjectHandler(DWG_TYPE_DIMSTYLE_CONTROL, @PromoteToControl);
  RegisterDWGObjectHandler(DWG_TYPE_VX_CONTROL,       @PromoteToControl);

  // Auxiliary objects referenced through dictionary chains. None of these
  // become ZCAD objects, but they DO show up as ref/owner targets in real
  // DWG files (DICTIONARY entries chain through XRECORD; SEQEND closes
  // POLYLINE/INSERT runs; MLINESTYLE is referenced from MLINE).
  RegisterDWGObjectHandler(DWG_TYPE_DICTIONARY,       @PromoteToControl);
  RegisterDWGObjectHandler(DWG_TYPE_XRECORD,          @PromoteToControl);
  RegisterDWGObjectHandler(DWG_TYPE_GROUP,            @PromoteToControl);
  RegisterDWGObjectHandler(DWG_TYPE_MLINESTYLE,       @PromoteToControl);
  RegisterDWGObjectHandler(DWG_TYPE_PLACEHOLDER,      @PromoteToControl);
  RegisterDWGObjectHandler(DWG_TYPE_LAYOUT,           @PromoteToControl);

  // VX_TABLE_RECORD and APPID / VIEW / UCS table records: their CONTROL
  // owns them but they are not currently mapped to ZCAD styles. Classifying
  // them as control objects prevents "owner is not a container" warnings
  // when something references them.
  RegisterDWGObjectHandler(DWG_TYPE_VX_TABLE_RECORD,  @PromoteToControl);
  RegisterDWGObjectHandler(DWG_TYPE_APPID,            @PromoteToControl);
  RegisterDWGObjectHandler(DWG_TYPE_VIEW,             @PromoteToControl);
  RegisterDWGObjectHandler(DWG_TYPE_UCS,              @PromoteToControl);

  // SEQEND / ENDBLK terminate entity runs (polyline vertex chain, block
  // body). They are entities (DWG_SUPERTYPE_ENTITY) so they need the
  // entity-handler API. Promoting them to dokControlObject is good enough
  // for the histogram and stops the resolver from warning when an INSERT
  // owner chain walks through them.
  RegisterDWGEntityHandler(DWG_TYPE_SEQEND,           @PromoteToControl);
  RegisterDWGEntityHandler(DWG_TYPE_ENDBLK,           @PromoteToControl);

end.
