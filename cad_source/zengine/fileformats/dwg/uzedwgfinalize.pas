{*************************************************************************** }
{  fpdwg - DWG import finalize / post-process (Stage 5.x R7 / Phase 4)       }
{                                                                            }
{        Copyright (C) 2026 Andrey Zubarev <zamtmn@yandex.ru>                }
{                                                                            }
{  This library is free software, licensed under the terms of the GNU        }
{  General Public License as published by the Free Software Foundation,      }
{  either version 3 of the License, or (at your option) any later version.   }
{*************************************************************************** }

{ Refactor R7 (per TZ_DWG_LOAD_TO_ZCAD_AUDIT §3.7 / TZ §4.3, §9.1):
  Phase 4 of the DWG load. After ResolveRefs/ResolveOwners every entity
  owns its parent and its visual-property pointers. Phase 4 is the place
  where we mirror the DXF loader's per-entity post-processing chain that
  Stage 2 deferred:

      BuildGeometry(drawing)
      FormatAfterDXFLoad(drawing, dc)
      FromDXFPostProcessAfterAdd

  The audit spells out the contract:

    procedure FinalizeImport(var Ctx: TDWGZCADLoadContext;
      Drawing: PTSimpleDrawing; const DC: TDrawContext);

  Block-definition contents are deliberately skipped here — the drawing
  already runs BlockDefArray.FormatEntity over the whole table at a higher
  level (see BtnOpenDXFClick / mainform glue). Running per-entity Build
  inside a block-def again would duplicate that work and break the
  "block content форматируется при использовании INSERT или финальной
  formatting-фазе drawing" rule from §12.4.

  Pulling BuildGeometry out of DWGAttachEntity (where Stage 2 left it as a
  workaround) makes attachment idempotent again: refs and owners can be
  re-resolved without geometry being rebuilt as a side effect. }

unit uzedwgfinalize;

{$Include zengineconfig.inc}
{$Mode objfpc}{$H+}
{$ModeSwitch advancedrecords}

interface

uses
  SysUtils,
  uzedrawingsimple,
  uzeentity,
  uzeentblockinsert,
  uzeentgenericsubentry,
  uzeconsts,
  uzgldrawcontext,
  uzedwgtypes,
  uzedwgloadcontext;

{ Phase 4 entry point. Walks every dokEntity entry in Ctx.Handles, looks up
  the resolved owner via the pending-owner queue, and runs the DXF-style
  post-processing chain when the owner is not a block definition. Safe to
  call with a nil Drawing (no-op) or an empty Ctx. }
procedure FinalizeImport(Ctx: TDWGZCADLoadContext;
  Drawing: PTSimpleDrawing; var DC: TDrawContext);

implementation

uses
  uzedwglog,
  uzedwgtimerlog,
  uzeTypes;

{ Stage 4 (TZ §12.4): the legacy FinalizeOwnerIsBlockDef helper used to do
  a linear scan over Ctx.Handles for every entity in the outer loop, which
  is O(N^2). Issue #1198 P5 (АНАЛИЗ_ЗАГРУЗЧИКА_DWG.md §4.5) replaces it with
  a per-Finalize cache: walk the registry once up front and collect the
  block-def / block-insert pointer sets into sorted dynamic arrays, then
  do a binary-search membership check per owner.

  The cache is a local record (built and dropped within FinalizeImport) so
  no state leaks between imports and the existing API surface stays
  unchanged. Pointers are stored as PtrUInt to keep the comparison cheap
  and well-defined across architectures. }
type
  TOwnerPtrCache = record
    BlockDefs: array of PtrUInt;
    BlockInserts: array of PtrUInt;
  end;

function PtrSortedFind(const Arr: array of PtrUInt; AValue: PtrUInt): Boolean;
var
  L, H, M: Integer;
begin
  Result := False;
  L := 0;
  H := High(Arr);
  while L <= H do
  begin
    M := L + (H - L) div 2;
    if Arr[M] = AValue then
      Exit(True)
    else if Arr[M] < AValue then
      L := M + 1
    else
      H := M - 1;
  end;
end;

procedure SortPtrArrayAscending(var Arr: array of PtrUInt);
var
  I, J: Integer;
  Pivot, Tmp: PtrUInt;
begin
  // Insertion sort - cache populations are tiny relative to the entity
  // count (one entry per block def / insert) so the constant factor wins
  // over QuickSort's setup.
  for I := 1 to High(Arr) do
  begin
    Pivot := Arr[I];
    J := I - 1;
    while (J >= 0) and (Arr[J] > Pivot) do
    begin
      Tmp := Arr[J + 1];
      Arr[J + 1] := Arr[J];
      Arr[J] := Tmp;
      Dec(J);
    end;
  end;
end;

procedure BuildOwnerPtrCache(Ctx: TDWGZCADLoadContext;
  out Cache: TOwnerPtrCache);
var
  I, DefCount, InsCount: Integer;
  Entry: PDWGZCADHandleEntry;
begin
  SetLength(Cache.BlockDefs, 0);
  SetLength(Cache.BlockInserts, 0);
  if Ctx = nil then
    Exit;
  // Pre-size both arrays to the upper bound (Count) so SetLength does not
  // copy through O(N) intermediate sizes; trimming after the fill is cheap.
  SetLength(Cache.BlockDefs, Ctx.Handles.Count);
  SetLength(Cache.BlockInserts, Ctx.Handles.Count);
  DefCount := 0;
  InsCount := 0;
  for I := 0 to Ctx.Handles.Count - 1 do
  begin
    Entry := Ctx.Handles.EntryAt(I);
    if Entry^.Ptr = nil then
      Continue;
    if Entry^.Kind = dokBlockDef then
    begin
      Cache.BlockDefs[DefCount] := PtrUInt(Entry^.Ptr);
      Inc(DefCount);
    end
    else if Entry^.Kind = dokBlockInsert then
    begin
      Cache.BlockInserts[InsCount] := PtrUInt(Entry^.Ptr);
      Inc(InsCount);
    end;
  end;
  SetLength(Cache.BlockDefs, DefCount);
  SetLength(Cache.BlockInserts, InsCount);
  SortPtrArrayAscending(Cache.BlockDefs);
  SortPtrArrayAscending(Cache.BlockInserts);
end;

function FinalizeOwnerIsBlockDef(const Cache: TOwnerPtrCache;
  Owner: Pointer): Boolean;
begin
  if Owner = nil then
    Exit(False);
  Result := PtrSortedFind(Cache.BlockDefs, PtrUInt(Owner));
end;

function FinalizeOwnerIsBlockInsert(const Cache: TOwnerPtrCache;
  Owner: Pointer): Boolean;
begin
  if Owner = nil then
    Exit(False);
  Result := PtrSortedFind(Cache.BlockInserts, PtrUInt(Owner));
end;

procedure FinalizeEntityGeometry(Pobj: PGDBObjEntity;
  Drawing: PTSimpleDrawing; var DC: TDrawContext);
begin
  Pobj^.BuildGeometry(Drawing^);
  Pobj^.FormatAfterDXFLoad(Drawing^, DC);
  Pobj^.FromDXFPostProcessAfterAdd;
end;

procedure AttachDeferredInsertChildren(Ctx: TDWGZCADLoadContext;
  const Cache: TOwnerPtrCache;
  Drawing: PTSimpleDrawing; var DC: TDrawContext; var Processed: Integer);
var
  I: Integer;
  Entry: PDWGZCADHandleEntry;
  Pobj: PGDBObjEntity;
  Pending: PDWGZCADPendingOwner;
  Owner: Pointer;
  Insert: PGDBObjBlockInsert;
  InsertIndex: Integer;
begin
  for I := 0 to Ctx.Handles.Count - 1 do begin
    Entry := Ctx.Handles.EntryAt(I);
    if Entry^.Kind <> dokEntity then
      Continue;
    Pobj := PGDBObjEntity(Entry^.Ptr);
    if Pobj = nil then
      Continue;
    Pending := Ctx.FindPendingOwner(Entry^.Handle);
    if Pending = nil then
      Continue;
    Owner := Pending^.AttachedOwner;
    if Owner = nil then
      Owner := Pending^.FallbackOwner;
    if not FinalizeOwnerIsBlockInsert(Cache, Owner) then
      Continue;

    Insert := PGDBObjBlockInsert(Owner);
    InsertIndex := Insert^.ConstObjArray.AddPEntity(Pobj^);
    Pobj^.correctobjects(PGDBObjEntity(Insert), InsertIndex);
    FinalizeEntityGeometry(Pobj, Drawing, DC);
    Inc(Processed);
  end;
end;

procedure FinalizeImport(Ctx: TDWGZCADLoadContext;
  Drawing: PTSimpleDrawing; var DC: TDrawContext);
var
  I: Integer;
  Entry: PDWGZCADHandleEntry;
  Pobj: PGDBObjEntity;
  Pending: PDWGZCADPendingOwner;
  Owner: Pointer;
  ProcessedEntities, SkippedBlockDef, SkippedInsertChild, SkippedNoOwner,
  VisualWarnings: Integer;
  Cache: TOwnerPtrCache;
  TotalTimer, PhaseTimer: TTimeMeter;
begin
  if (Ctx = nil) or (Drawing = nil) then
    Exit;

  TotalTimer := TTimeMeter.StartMeasure;
  ProcessedEntities := 0;
  SkippedBlockDef := 0;
  SkippedInsertChild := 0;
  SkippedNoOwner := 0;
  VisualWarnings := 0;
  SetLength(Cache.BlockDefs, 0);
  SetLength(Cache.BlockInserts, 0);
  try
    // Issue #1198 P5: pre-build the (BlockDef, BlockInsert) pointer cache so
    // the per-entity FinalizeOwnerIs* checks below are O(log N) instead of
    // O(N), turning the whole finalize pass from O(N^2) into O(N log N).
    PhaseTimer := TTimeMeter.StartMeasure;
    try
      BuildOwnerPtrCache(Ctx, Cache);
    finally
      PhaseTimer.EndMeasure;
      DWGTimerLogTiming('dwg-finalize.owner-cache', PhaseTimer.ElapsedMiliSec,
        Format('handles=%d blockdefs=%d inserts=%d',
          [Ctx.Handles.Count, Length(Cache.BlockDefs),
           Length(Cache.BlockInserts)]));
    end;

    PhaseTimer := TTimeMeter.StartMeasure;
    try
      for I := 0 to Ctx.Handles.Count - 1 do begin
        Entry := Ctx.Handles.EntryAt(I);
        if not (Entry^.Kind in [dokEntity, dokBlockInsert]) then
          Continue;
        Pobj := PGDBObjEntity(Entry^.Ptr);
        if Pobj = nil then
          Continue;

        // Lookup the resolved owner via the pending-owner queue. The queue is
        // not cleared by ResolveOwners so we can use it as a post-resolve index
        // without keeping a parallel list. An entity that never made it through
        // resolve still has the pending row but with AttachedOwner=nil — we use
        // the FallbackOwner (model-space root) the same way DWGAttachEntity
        // would have done.
        Pending := Ctx.FindPendingOwner(Entry^.Handle);
        if Pending = nil then begin
          Inc(SkippedNoOwner);
          DWGLogWarningFormatStr('DWG finalize skip entity %s: no pending owner row',
            [DWGHandleLogText(Entry^.Handle)]);
          Continue;
        end;
        Owner := Pending^.AttachedOwner;
        if Owner = nil then
          Owner := Pending^.FallbackOwner;
        if Owner = nil then begin
          Inc(SkippedNoOwner);
          DWGLogWarningFormatStr(
            'DWG finalize skip entity %s: no resolved or fallback owner',
            [DWGHandleLogText(Entry^.Handle)]);
          Continue;
        end;

        // Block-def contents stay deferred (TZ §12.4). Counting them so the
        // diagnostic line below can show how the registry was split.
        if FinalizeOwnerIsBlockDef(Cache, Owner) then begin
          Inc(SkippedBlockDef);
          Continue;
        end;
        if FinalizeOwnerIsBlockInsert(Cache, Owner) then begin
          Inc(SkippedInsertChild);
          Continue;
        end;

        if Pobj^.vp.Layer = nil then begin
          Inc(VisualWarnings);
          DWGLogWarningFormatStr(
            'DWG finalize entity %s has nil layer after ref resolve',
            [DWGHandleLogText(Entry^.Handle)]);
        end else if not Pobj^.vp.Layer^._on then begin
          Inc(VisualWarnings);
          DWGLogWarningFormatStr(
            'DWG finalize entity %s is on disabled layer %s',
            [DWGHandleLogText(Entry^.Handle), Pobj^.vp.Layer^.Name]);
        end;
        if Pobj^.vp.LineType = nil then begin
          Inc(VisualWarnings);
          DWGLogWarningFormatStr(
            'DWG finalize entity %s has nil linetype after ref resolve',
            [DWGHandleLogText(Entry^.Handle)]);
        end;

        FinalizeEntityGeometry(Pobj, Drawing, DC);
        Inc(ProcessedEntities);
      end;
    finally
      PhaseTimer.EndMeasure;
      DWGTimerLogTiming('dwg-finalize.entity-loop', PhaseTimer.ElapsedMiliSec,
        Format('handles=%d built=%d skipped_blockdef=%d skipped_insert_child=%d no_owner=%d visual_warnings=%d',
          [Ctx.Handles.Count, ProcessedEntities, SkippedBlockDef,
           SkippedInsertChild, SkippedNoOwner, VisualWarnings]));
    end;

    PhaseTimer := TTimeMeter.StartMeasure;
    try
      AttachDeferredInsertChildren(Ctx, Cache, Drawing, DC, ProcessedEntities);
    finally
      PhaseTimer.EndMeasure;
      DWGTimerLogTiming('dwg-finalize.insert-children', PhaseTimer.ElapsedMiliSec,
        Format('built_total=%d', [ProcessedEntities]));
    end;

    DWGLogInfoFormatStr(
      'DWG finalize: built=%d, deferred_blockdef=%d, deferred_insert_child=%d, no_owner=%d, visual_warnings=%d',
      [ProcessedEntities, SkippedBlockDef, SkippedInsertChild, SkippedNoOwner,
       VisualWarnings]);
  finally
    TotalTimer.EndMeasure;
    DWGTimerLogTiming('dwg-finalize.total', TotalTimer.ElapsedMiliSec,
      Format('handles=%d built=%d', [Ctx.Handles.Count, ProcessedEntities]));
  end;
end;

end.
