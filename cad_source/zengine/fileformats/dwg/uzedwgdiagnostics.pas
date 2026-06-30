{*************************************************************************** }
{  fpdwg - DWG to ZCAD import context: diagnostics (Stage 5.x R2)            }
{                                                                            }
{        Copyright (C) 2026 Andrey Zubarev <zamtmn@yandex.ru>                }
{                                                                            }
{  This library is free software, licensed under the terms of the GNU        }
{  General Public License as published by the Free Software Foundation,      }
{  either version 3 of the License, or (at your option) any later version.   }
{*************************************************************************** }

{ Refactor R2 (per TZ_DWG_LOAD_TO_ZCAD_AUDIT §3.2 / TZ §6.5):
  the warning collector and resolver counters that used to live inline in
  TDWGZCADLoadContext. Pulling them into a dedicated unit keeps the load
  context focused on shell registry + pending queues, and gives the resolver
  a small, tested surface to push warnings to without touching the context's
  private state.

  Issue #1198 P4 (per АНАЛИЗ_ЗАГРУЗЧИКА_DWG.md §P4): the warning list also
  tracks per-code totals, the first sample observed for each code, and a
  dedup set keyed on (Code, Handle). The dedup set is used by the import
  side (DWGAttachRef / DWGAttachEntity) to suppress repeat per-entity
  DWG log detail lines once the same code+handle has already been logged. The
  per-code total feeds the import-summary line emitted at end-of-import,
  so a reader sees the first occurrence in full, plus an aggregate
  «and N more like this» footer instead of thousands of identical lines. }

unit uzedwgdiagnostics;

{$mode objfpc}{$H+}
{$modeswitch advancedrecords}

interface

uses
  SysUtils, uzedwgtypes;

const
  { Issue #1198 P4: how many per-entity detail lines are written to the
    main log for the same (Code, Handle) pair before the dedup tracker
    starts swallowing them. Set to 1 so the first occurrence always shows
    in the log and subsequent identical occurrences only contribute to
    the end-of-import summary line for that code. }
  DWG_DEFAULT_MAX_DETAIL_PER_KEY = 1;

type
  { Issue #1198 P4: per-code aggregation entry. Tracks total occurrences
    and the number of distinct handles seen so the summary can report
    "code 1410 (ref kind mismatch): 1234 occurrences across 87 handles"
    without keeping every single warning text in memory. }
  TDWGImportCodeAggregate = record
    Code: Integer;
    TotalCount: Integer;
    DistinctHandles: Integer;
    HasFirstSample: Boolean;
    FirstSample: TDWGImportWarning;
  end;
  PDWGImportCodeAggregate = ^TDWGImportCodeAggregate;

  { Sequential append-only warning log produced during a single import.
    Backed by a dynamic array so consumers can iterate via WarningCount /
    WarningAt without exposing the internal storage.

    Issue #1198 P4: the list also maintains a (Code, Handle) dedup set
    and per-code aggregates. Resolver fallbacks come through Add and feed
    both views; the import-side DWG log gates query ShouldEmitDetail to
    suppress per-entity repetition in the main log. }
  { Tracking entry for a (Code, Handle) dedup key. Stored sorted by Key
    in TDWGImportWarningList.FEmittedKeys so lookups stay O(log N) as
    the import accumulates thousands of fallback events. }
  TDWGImportEmittedKey = record
    Key: QWord;
    Hits: Integer;
  end;
  PDWGImportEmittedKey = ^TDWGImportEmittedKey;

  TDWGImportWarningList = class
  private
    FItems: array of TDWGImportWarning;
    FAggregates: array of TDWGImportCodeAggregate;
    FEmittedKeys: array of TDWGImportEmittedKey;
    FEmittedKeysCount: Integer;
    FMaxDetailPerKey: Integer;
    function FindAggregateIndex(Code: Integer; out Index: Integer): Boolean;
    function AggregateFor(Code: Integer): PDWGImportCodeAggregate;
    function PackKey(Code: Integer; Handle: TDWGZCADHandle): QWord;
    function FindEmittedKey(Key: QWord;
      out Index: Integer): Boolean;
    procedure InsertEmittedKey(Index: Integer; Key: QWord; Hits: Integer);
  public
    constructor Create;
    procedure Add(Severity: TDWGImportSeverity; Code: Integer;
      Handle: TDWGZCADHandle; const Text: String);
    function Count: Integer;
    function Item(Index: Integer): TDWGImportWarning;
    procedure Clear;
    { Issue #1198 P4: return True the first MaxDetailPerKey times for a
      given (Code, Handle) pair, False after that. Callers wrap their
      per-entity DWG log detail in this so the main log only shows the first
      occurrence and the EndDWGImport summary covers the rest. }
    function ShouldEmitDetail(Code: Integer;
      Handle: TDWGZCADHandle): Boolean;
    function AggregateCount: Integer;
    function AggregateAt(Index: Integer): TDWGImportCodeAggregate;
    function TotalForCode(Code: Integer): Integer;
    function DistinctHandlesForCode(Code: Integer): Integer;
    property MaxDetailPerKey: Integer
      read FMaxDetailPerKey write FMaxDetailPerKey;
  end;

  { Resolver counters: one slot per attach outcome. Kept as a plain record
    so the load context can expose them as read-only properties without
    re-implementing the increment logic in three places. }
  TDWGImportStats = record
    AttachCount: Integer;
    FallbackCount: Integer;
    CycleCount: Integer;
    RefAttachCount: Integer;
    RefFallbackCount: Integer;
    RefCacheHits: Integer;
    RefCacheMisses: Integer;
    RefCacheKeys: Integer;
    UnknownEntities: Integer;
    UnknownObjects: Integer;
    ProxiesLoaded: Integer;
    ProxiesFailed: Integer;
    DroppedDueToFreedRaw: Integer;
    procedure Clear;
  end;
  PDWGImportStats = ^TDWGImportStats;

{ Issue #1198 P4: helper used by EndDWGImport to turn a numeric code
  into a short human-readable label for the summary line. Kept here so
  log filters and tests can reuse it without duplicating the case. }
function DWGWarningCodeToShortName(Code: Integer): String;

{ Issue #1198 P4: pick the diagnostic code that matches an attach
  reason. The resolver already calls RaiseWarning with the correct code
  when a fallback fires; the import-side attach callbacks only see the
  reason enum, so this helper bridges the two so the import-side
  dedup/aggregate logic stays in sync with the resolver. }
function DWGCodeForAttachReason(Reason: TDWGAttachReason): Integer;

implementation

function DWGWarningCodeToShortName(Code: Integer): String;
begin
  case Code of
    DWG_WARN_OWNER_NULL:          Result := 'owner null';
    DWG_WARN_OWNER_NOT_FOUND:     Result := 'owner not found';
    DWG_WARN_OWNER_NOT_CONTAINER: Result := 'owner not container';
    DWG_WARN_OWNER_SELF_CYCLE:    Result := 'owner self-cycle';
    DWG_WARN_OWNER_CHAIN_CYCLE:   Result := 'owner chain cycle';
    DWG_WARN_OWNER_SKIPPED:       Result := 'owner skipped';
    DWG_WARN_DUPLICATE_HANDLE:    Result := 'duplicate handle';
    DWG_WARN_REF_NULL:            Result := 'ref null';
    DWG_WARN_REF_NOT_FOUND:       Result := 'ref not found';
    DWG_WARN_REF_KIND_MISMATCH:   Result := 'ref kind mismatch';
    DWG_WARN_PROXY_NO_GRAPHICS:   Result := 'proxy without graphics';
    DWG_WARN_PROXY_CORRUPT:       Result := 'proxy corrupt';
    DWG_WARN_UNKNOWN_ENTITY:      Result := 'unknown entity';
    DWG_WARN_UNKNOWN_OBJECT:      Result := 'unknown object';
    DWG_WARN_UNKNOWN_NO_COPY:     Result := 'unknown without copy';
  else
    Result := 'code ' + IntToStr(Code);
  end;
end;

function DWGCodeForAttachReason(Reason: TDWGAttachReason): Integer;
begin
  case Reason of
    arNullOwner:          Result := DWG_WARN_OWNER_NULL;
    arOwnerNotFound:      Result := DWG_WARN_OWNER_NOT_FOUND;
    arOwnerNotContainer:  Result := DWG_WARN_OWNER_NOT_CONTAINER;
    arSelfOwnerCycle:     Result := DWG_WARN_OWNER_SELF_CYCLE;
    arOwnerChainCycle:    Result := DWG_WARN_OWNER_CHAIN_CYCLE;
    arOwnerSkipped:       Result := DWG_WARN_OWNER_SKIPPED;
    arRefNull:            Result := DWG_WARN_REF_NULL;
    arRefNotFound:        Result := DWG_WARN_REF_NOT_FOUND;
    arRefKindMismatch:    Result := DWG_WARN_REF_KIND_MISMATCH;
  else
    { arResolved / arPending: there is no warning code because no
      fallback fired. Callers must guard against this case before
      using the result. }
    Result := 0;
  end;
end;

constructor TDWGImportWarningList.Create;
begin
  inherited Create;
  FMaxDetailPerKey := DWG_DEFAULT_MAX_DETAIL_PER_KEY;
end;

function TDWGImportWarningList.PackKey(Code: Integer;
  Handle: TDWGZCADHandle): QWord;
begin
  { Pack (Code, Handle) into a single QWord. Codes live in 1401..1499
    (16-bit easily), handles are full 64-bit DWG handles; shift the
    code into the high 16 bits so equal handles with different codes
    don't collide. The dedup set keeps everything in a flat dynamic
    array — typical imports stay well under 10k unique keys, so a
    linear scan is cheaper than dragging in FCL generics. }
  Result := (QWord(Code) shl 48) or (Handle and $0000FFFFFFFFFFFF);
end;

function TDWGImportWarningList.FindEmittedKey(Key: QWord;
  out Index: Integer): Boolean;
var
  Lo, Hi, Mid: Integer;
  K: QWord;
begin
  Result := False;
  Lo := 0;
  Hi := FEmittedKeysCount - 1;
  while Lo <= Hi do
  begin
    Mid := Lo + (Hi - Lo) div 2;
    K := FEmittedKeys[Mid].Key;
    if K = Key then
    begin
      Index := Mid;
      Exit(True);
    end
    else if K < Key then
      Lo := Mid + 1
    else
      Hi := Mid - 1;
  end;
  Index := Lo;
end;

procedure TDWGImportWarningList.InsertEmittedKey(Index: Integer; Key: QWord;
  Hits: Integer);
var
  I: Integer;
begin
  if FEmittedKeysCount >= Length(FEmittedKeys) then
    SetLength(FEmittedKeys, FEmittedKeysCount * 2 + 16);
  for I := FEmittedKeysCount downto Index + 1 do
    FEmittedKeys[I] := FEmittedKeys[I - 1];
  FEmittedKeys[Index].Key := Key;
  FEmittedKeys[Index].Hits := Hits;
  Inc(FEmittedKeysCount);
end;

function TDWGImportWarningList.FindAggregateIndex(Code: Integer;
  out Index: Integer): Boolean;
var
  I: Integer;
begin
  { Aggregate list is small (one entry per diagnostic code = ~15 max)
    so a linear scan is fine and keeps the ordering insertion order,
    which makes test assertions deterministic. }
  for I := 0 to High(FAggregates) do
    if FAggregates[I].Code = Code then
    begin
      Index := I;
      Exit(True);
    end;
  Index := Length(FAggregates);
  Result := False;
end;

function TDWGImportWarningList.AggregateFor(Code: Integer
  ): PDWGImportCodeAggregate;
var
  Index: Integer;
  Empty: TDWGImportCodeAggregate;
begin
  if not FindAggregateIndex(Code, Index) then
  begin
    FillChar(Empty, SizeOf(Empty), 0);
    Empty.Code := Code;
    SetLength(FAggregates, Length(FAggregates) + 1);
    FAggregates[High(FAggregates)] := Empty;
    Index := High(FAggregates);
  end;
  Result := @FAggregates[Index];
end;

procedure TDWGImportWarningList.Add(Severity: TDWGImportSeverity;
  Code: Integer; Handle: TDWGZCADHandle; const Text: String);
var
  W: TDWGImportWarning;
  Agg: PDWGImportCodeAggregate;
  Key: QWord;
  Index: Integer;
  IsNewKey: Boolean;
begin
  W.Severity := Severity;
  W.Code := Code;
  W.Handle := Handle;
  W.Text := Text;
  SetLength(FItems, Length(FItems) + 1);
  FItems[High(FItems)] := W;

  { Distinct-handle tracking lives in the same sorted FEmittedKeys store
    as the detail-emit gate: a missing entry counts as a fresh (Code,
    Handle) pair (and gets seeded with Hits=0 so ShouldEmitDetail still
    fires once). The emit gate only checks/increments Hits, so seeding
    here doesn't change downstream emit behaviour. }
  Key := PackKey(Code, Handle);
  IsNewKey := not FindEmittedKey(Key, Index);
  if IsNewKey then
    InsertEmittedKey(Index, Key, 0);

  Agg := AggregateFor(Code);
  Inc(Agg^.TotalCount);
  if IsNewKey then
    Inc(Agg^.DistinctHandles);
  if not Agg^.HasFirstSample then
  begin
    Agg^.HasFirstSample := True;
    Agg^.FirstSample := W;
  end;
end;

function TDWGImportWarningList.Count: Integer;
begin
  Result := Length(FItems);
end;

function TDWGImportWarningList.Item(Index: Integer): TDWGImportWarning;
begin
  if (Index < 0) or (Index > High(FItems)) then
    raise EDWGLoadContext.CreateFmt('Warning index %d out of range', [Index]);
  Result := FItems[Index];
end;

procedure TDWGImportWarningList.Clear;
begin
  SetLength(FItems, 0);
  SetLength(FAggregates, 0);
  SetLength(FEmittedKeys, 0);
  FEmittedKeysCount := 0;
end;

function TDWGImportWarningList.ShouldEmitDetail(Code: Integer;
  Handle: TDWGZCADHandle): Boolean;
var
  Key: QWord;
  Index: Integer;
begin
  if FMaxDetailPerKey <= 0 then
    Exit(False);
  Key := PackKey(Code, Handle);
  if FindEmittedKey(Key, Index) then
  begin
    if FEmittedKeys[Index].Hits >= FMaxDetailPerKey then
      Exit(False);
    Inc(FEmittedKeys[Index].Hits);
    Result := True;
  end
  else
  begin
    InsertEmittedKey(Index, Key, 1);
    Result := True;
  end;
end;

function TDWGImportWarningList.AggregateCount: Integer;
begin
  Result := Length(FAggregates);
end;

function TDWGImportWarningList.AggregateAt(Index: Integer
  ): TDWGImportCodeAggregate;
begin
  if (Index < 0) or (Index > High(FAggregates)) then
    raise EDWGLoadContext.CreateFmt(
      'Warning aggregate index %d out of range', [Index]);
  Result := FAggregates[Index];
end;

function TDWGImportWarningList.TotalForCode(Code: Integer): Integer;
var
  Index: Integer;
begin
  if FindAggregateIndex(Code, Index) then
    Result := FAggregates[Index].TotalCount
  else
    Result := 0;
end;

function TDWGImportWarningList.DistinctHandlesForCode(Code: Integer): Integer;
var
  Index: Integer;
begin
  if FindAggregateIndex(Code, Index) then
    Result := FAggregates[Index].DistinctHandles
  else
    Result := 0;
end;

procedure TDWGImportStats.Clear;
begin
  AttachCount := 0;
  FallbackCount := 0;
  CycleCount := 0;
  RefAttachCount := 0;
  RefFallbackCount := 0;
  RefCacheHits := 0;
  RefCacheMisses := 0;
  RefCacheKeys := 0;
  UnknownEntities := 0;
  UnknownObjects := 0;
  ProxiesLoaded := 0;
  ProxiesFailed := 0;
  DroppedDueToFreedRaw := 0;
end;

end.
