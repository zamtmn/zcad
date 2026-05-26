{*************************************************************************** }
{  fpdwg - DWG to ZCAD import context: shared types (Stage 5.x R2)           }
{                                                                            }
{        Copyright (C) 2026 Andrey Zubarev <zamtmn@yandex.ru>                }
{                                                                            }
{  This library is free software, licensed under the terms of the GNU        }
{  General Public License as published by the Free Software Foundation,      }
{  either version 3 of the License, or (at your option) any later version.   }
{*************************************************************************** }

{ Refactor R2 (per TZ_DWG_LOAD_TO_ZCAD_AUDIT §3.2 / TZ §6.5):
  shared enums, records, pointer aliases, callback signatures and diagnostic
  codes used by the import context, the resolver and the diagnostics unit.
  Keeping them here lets the resolver and diagnostics live in their own
  units without dragging the full TDWGZCADLoadContext class into their
  uses clause. }

unit uzedwgtypes;

{$mode objfpc}{$H+}
{$modeswitch advancedrecords}

interface

uses
  SysUtils,
  dwg;

type
  TDWGZCADHandle = QWord;

const
  DWG_ZCAD_MAX_REF_HANDLE_CANDIDATES = 3;

type
  TDWGZCADRefHandleCandidates = record
    Count: Integer;
    Values: array[0..DWG_ZCAD_MAX_REF_HANDLE_CANDIDATES - 1] of TDWGZCADHandle;
  end;

  { Section 7 of TZ: object kinds the import context recognizes. The kind is
    used by the resolver to decide whether a handle is a valid container
    target. The set is intentionally small; new kinds get added as new entity
    units come online. }
  TDWGZCADObjectKind = (
    dokUnknown,
    dokLayer,
    dokLineType,
    dokTextStyle,
    dokDimStyle,
    dokBlockDef,
    dokModelSpace,
    dokPaperSpace,
    dokContainer,
    dokBlockInsert,
    dokEntity,
    { Issue #1198 P2 (TZ §5): table-control objects (LAYER_CONTROL, LTYPE_CONTROL,
      BLOCK_CONTROL, STYLE_CONTROL, DIMSTYLE_CONTROL, VIEW_CONTROL,
      UCS_CONTROL, VPORT_CONTROL, APPID_CONTROL, VX_CONTROL). The control
      objects own the table records but do not need a ZCAD-side allocation;
      promoting them out of dokUnknown lets the resolver classify references
      to them deterministically instead of treating them as missing kinds.
      Auxiliary objects such as DICTIONARY / XRECORD / GROUP / MLINESTYLE
      also land here for the same reason. }
    dokControlObject
  );

  TDWGShellState = (
    msUnseen,
    msCreating,
    msCreated,
    msSkipped,
    msFailed
  );

  TDWGAttachState = (
    asPending,
    asResolving,
    asAttached,
    asFallback,
    asSkipped
  );

  TDWGAttachReason = (
    arResolved,
    arNullOwner,
    arOwnerNotFound,
    arOwnerNotContainer,
    arSelfOwnerCycle,
    arOwnerChainCycle,
    arOwnerSkipped,
    arPending,
    { Stage 3: ref-only outcomes. The owner queue never produces these. }
    arRefNull,
    arRefNotFound,
    arRefKindMismatch
  );

  TDWGZCADHandleEntry = record
    Handle: TDWGZCADHandle;
    Kind: TDWGZCADObjectKind;
    Ptr: Pointer;
    RawIndex: Integer;
    ShellState: TDWGShellState;
    { Issue #1198 P2 (TZ §5): captured by ScanRawObjects from
      Raw.&object[i].fixedtype so the histogram diagnostic and the resolver's
      "is this a known control object" check do not need a second walk over
      the LibreDWG array. DWG_TYPE_UNUSED (0) means "raw scan did not see this
      handle" (mapper-side RegisterShell calls that pre-date Phase 1, unit
      tests that pre-seed the registry by hand). }
    FixedType: DWG_OBJECT_TYPE;
  end;
  PDWGZCADHandleEntry = ^TDWGZCADHandleEntry;

  TDWGZCADPendingOwner = record
    Entity: Pointer;
    EntityHandle: TDWGZCADHandle;
    OwnerHandle: TDWGZCADHandle;
    OwnerCandidates: TDWGZCADRefHandleCandidates;
    FallbackOwner: Pointer;
    RawIndex: Integer;
    AttachState: TDWGAttachState;
    AttachReason: TDWGAttachReason;
    AttachedOwner: Pointer;
  end;
  PDWGZCADPendingOwner = ^TDWGZCADPendingOwner;

  { Stage 3 (TZ §12.3 / §8.2-8.3): queued visual reference. The owner queue
    handles "where does this entity attach". This queue handles "which
    layer / linetype / textstyle / dimstyle pointer does the entity get".
    Refs are resolved separately from owners because they come from
    different ZCAD tables and have a different fallback policy: a missing
    layer falls back to the system layer, a missing entity linetype falls
    back to the ByLayer entry. The Slot field tells the attach callback
    which target field to write so the loader does not need a separate
    callback per reference kind. }
  TDWGZCADRefSlot = (
    rsLayer,
    rsLineType,
    rsTextStyle,
    rsDimStyle,
    rsBlockDef,
    { Issue #1122: layer.LT refs target a PGDBLayerProp, not an entity vp
      record. Keep this as a distinct slot so the callback cannot write the
      resolved LTYPE pointer into entity memory when the target is a layer. }
    rsLayerLineType,
    { Issue #1250: DIMSTYLE.DIMTXSTY refs target a PGDBDimStyle, not a
      text entity. Resolve them through their own slot so dimension text can
      honor a fixed-height text style before falling back to DIMTXT. }
    rsDimStyleTextStyle
  );

  { Attach callback context supplied by the resolver from the exact pending
    queue item being finished. TargetHandle is the owner handle for owner
    attachment and the resolved/fallback reference handle for ref attachment.
    Slot is meaningful for reference callbacks only. }
  TDWGAttachContext = record
    EntityHandle: TDWGZCADHandle;
    TargetHandle: TDWGZCADHandle;
    Slot: TDWGZCADRefSlot;
    Reason: TDWGAttachReason;
  end;

  TDWGZCADPendingRef = record
    Entity: Pointer;
    EntityHandle: TDWGZCADHandle;
    RefHandle: TDWGZCADHandle;
    RefCandidates: TDWGZCADRefHandleCandidates;
    ExpectedKind: TDWGZCADObjectKind;
    Slot: TDWGZCADRefSlot;
    Fallback: Pointer;
    InlineRef: Boolean;
    AttachState: TDWGAttachState;
    AttachReason: TDWGAttachReason;
    AttachedRef: Pointer;
  end;
  PDWGZCADPendingRef = ^TDWGZCADPendingRef;

  TDWGImportSeverity = (wsInfo, wsWarning, wsError);

  TDWGImportWarning = record
    Severity: TDWGImportSeverity;
    Code: Integer;
    Handle: TDWGZCADHandle;
    Text: String;
  end;

  { Callback used by ResolveOwners to perform the actual ZCAD AddMi attachment.
    Owner is either the resolved owner pointer or FallbackOwner. The callback
    is allowed to be nil during pure-context unit tests; in that case the
    resolver still tracks the AttachState so tests can assert routing. }
  TDWGAttachProc = procedure(Entity: Pointer; Owner: Pointer;
    Reason: TDWGAttachReason; Data: Pointer);

  { Extended owner callback used by the DWG production importer. It avoids
    reconstructing diagnostic handles by scanning the global pending queue. }
  TDWGAttachProcEx = procedure(Entity: Pointer; Owner: Pointer;
    const Context: TDWGAttachContext; Data: Pointer);

  { Stage 3 callback used by ResolveRefs to write the resolved reference
    pointer (PGDBLayerProp / PGDBLtypeProp / PGDBTextStyle / ...) back into
    the entity's vp record. Slot tells the production code which field to
    update; Reason carries diagnostic context for fallback cases. As with
    TDWGAttachProc, the callback is optional so tests can assert routing
    without a real ZCAD entity. }
  TDWGRefAttachProc = procedure(Entity: Pointer; Ref: Pointer;
    Slot: TDWGZCADRefSlot; Reason: TDWGAttachReason; Data: Pointer);

  { Extended ref callback used by the DWG production importer. It carries the
    pending queue context directly, so attach logging is O(1) per ref. }
  TDWGRefAttachProcEx = procedure(Entity: Pointer; Ref: Pointer;
    const Context: TDWGAttachContext; Data: Pointer);

  EDWGLoadContext = class(Exception);

const
  { Diagnostic codes; kept as integer constants so log filters can use them
    without importing this unit's enum. Numbering picks up where the inspector
    logger left off (1300 range used for resolver). }
  DWG_WARN_OWNER_NULL          = 1401;
  DWG_WARN_OWNER_NOT_FOUND     = 1402;
  DWG_WARN_OWNER_NOT_CONTAINER = 1403;
  DWG_WARN_OWNER_SELF_CYCLE    = 1404;
  DWG_WARN_OWNER_CHAIN_CYCLE   = 1405;
  DWG_WARN_OWNER_SKIPPED       = 1406;
  DWG_WARN_DUPLICATE_HANDLE    = 1407;
  { Stage 3 (TZ §12.3 / §13): visual-reference resolution diagnostics. The
    spec calls for separate codes per failure mode so a log filter can spot
    e.g. layer-not-found independently of linetype-kind-mismatch. }
  DWG_WARN_REF_NULL            = 1408;
  DWG_WARN_REF_NOT_FOUND       = 1409;
  DWG_WARN_REF_KIND_MISMATCH   = 1410;
  { Stage 7 (TZ §12.7 / audit §4.2): unsupported/proxy fallback diagnostics.
    These separate corrupt proxy data from intentionally skipped opaque objects
    so import logs can show whether graphics were preserved or only counted. }
  DWG_WARN_PROXY_NO_GRAPHICS    = 1411;
  DWG_WARN_PROXY_CORRUPT        = 1412;
  DWG_WARN_UNKNOWN_ENTITY       = 1413;
  DWG_WARN_UNKNOWN_OBJECT       = 1414;
  DWG_WARN_UNKNOWN_NO_COPY      = 1415;
  { Issue #1198 P6 (АНАЛИЗ_ЗАГРУЗЧИКА_DWG.md §4.4/§P6): AddTextStyle emits this
    when an empty-named or colliding STYLE record is re-registered under a
    handle-derived synthetic name ('dwg_<hex>' or '<orig>_dwg<hex>'). Distinct
    from DWG_WARN_DUPLICATE_HANDLE (1407): the duplicate-handle warning fires
    after the aliasing happened, this one is logged at the moment we *prevent*
    the alias by choosing a different name. }
  DWG_WARN_TEXTSTYLE_RENAMED    = 1416;

function DWGAttachReasonToText(Reason: TDWGAttachReason): String;

implementation

function DWGAttachReasonToText(Reason: TDWGAttachReason): String;
begin
  case Reason of
    arResolved:           Result := 'resolved';
    arNullOwner:          Result := 'null owner';
    arOwnerNotFound:      Result := 'owner not found';
    arOwnerNotContainer:  Result := 'owner is not a container';
    arSelfOwnerCycle:     Result := 'self owner cycle';
    arOwnerChainCycle:    Result := 'owner chain cycle';
    arOwnerSkipped:       Result := 'owner skipped';
    arPending:            Result := 'pending';
    arRefNull:            Result := 'null ref';
    arRefNotFound:        Result := 'ref not found';
    arRefKindMismatch:    Result := 'ref kind mismatch';
  else
    Result := 'unknown';
  end;
end;

end.
