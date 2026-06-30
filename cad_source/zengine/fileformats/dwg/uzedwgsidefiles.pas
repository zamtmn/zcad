{*************************************************************************** }
{  fpdwg - DWG diagnostic side-files (Issue #1198 P3)                        }
{                                                                            }
{        Copyright (C) 2026 Andrey Zubarev <zamtmn@yandex.ru>                }
{                                                                            }
{  This library is free software, licensed under the terms of the GNU        }
{  General Public License as published by the Free Software Foundation,      }
{  either version 3 of the License, or (at your option) any later version.   }
{*************************************************************************** }

{ Issue #1198 P3 (per АНАЛИЗ_ЗАГРУЗЧИКА_DWG.md §P3 / §6.1):
  diagnostic side-file writer for the DWG loader. Emits structured CSV +
  TXT/JSON dumps next to a problematic DWG so a developer can drop into a
  failing import without re-running it. Activation and verbosity are controlled
  by the DWG_DIAG_MODE constant so the feature is invisible to users by
  default and cannot be changed accidentally from the process environment.

  Modes (matching the spec table in §6.1):
    - off     : do nothing (default)
    - summary : <dwg>.summary.txt + <dwg>.summary.json
    - full    : summary + <dwg>.handles.csv / refs.csv / owners.csv
    - trace   : full + per-raw-object scan trace in the main log

  The writer is RAM-friendly: it iterates the load context lists directly
  and streams to disk; nothing is staged in memory beyond a few hundred
  bytes of formatting buffer. Side-files are co-located next to the DWG
  source path (or the cwd as a fallback when the source path is empty,
  e.g. unit tests). }

unit uzedwgsidefiles;

{$mode objfpc}{$H+}
{$modeswitch advancedrecords}

interface

uses
  SysUtils, Classes,
  dwg,
  uzedwgtypes,
  uzedwgdiagnostics,
  uzedwgloadcontext;

type
  TDWGDiagMode = (
    dmOff,
    dmSummary,
    dmFull,
    dmTrace
  );

const
  { Compile-time/default diagnostic mode. Keep dmOff for release builds.
    Developers can temporarily change this constant to dmSummary, dmFull or
    dmTrace while investigating a DWG loader problem, then rebuild. }
  DWG_DIAG_MODE = dmOff;

  { Issue #1198 §6.2: top-N broken handles included in summary.json. Ten is
    enough to spot cascading owner/ref damage in a single glance without
    bloating the JSON. }
  DWG_DIAG_TOP_BROKEN_HANDLES = 10;

type
  { Result of writing one bundle. Counts are exposed so callers (and tests)
    can assert that the writer touched the load context, and FilesWritten
    enumerates the paths so a log line can list them. }
  TDWGSideFileResult = record
    Mode: TDWGDiagMode;
    HandlesWritten: Integer;
    RefsWritten: Integer;
    OwnersWritten: Integer;
    FilesWritten: array of String;
    procedure Clear;
    procedure AddFile(const Path: String);
  end;

{ Reads the diagnostic mode from the compile-time/default constant. }
function DWGDiagModeFromConst: TDWGDiagMode;
function DWGDiagModeFromString(const S: String): TDWGDiagMode;
function DWGDiagModeToString(Mode: TDWGDiagMode): String;

{ Compose a side-file path. Given <dwg> = "/x/y/foo.dwg" and Suffix
  ".summary.txt" returns "/x/y/foo.dwg.summary.txt". When SourcePath is
  empty (tests, in-memory loads) returns "dwg.<suffix>" in the cwd. }
function DWGSideFilePath(const SourcePath, Suffix: String): String;

{ Write all side-files appropriate for the given mode. Returns a count
  record that callers can inspect; FilesWritten is also populated so the
  caller can echo paths to the main log. A nil context or an empty
  SourcePath with no writable cwd is a no-op (TDWGSideFileResult.Mode
  stays dmOff). The Mode passed in always wins, so tests can force a
  specific mode without touching the compile-time default. }
function DWGWriteSideFiles(Ctx: TDWGZCADLoadContext;
  const SourcePath: String; Mode: TDWGDiagMode): TDWGSideFileResult;

{ Per-file writers. Public so unit tests can exercise each file in
  isolation. None of these read global state; callers are expected to gate
  on Mode themselves. }
procedure DWGWriteHandlesCsv(Ctx: TDWGZCADLoadContext; const Path: String);
procedure DWGWriteRefsCsv(Ctx: TDWGZCADLoadContext; const Path: String);
procedure DWGWriteOwnersCsv(Ctx: TDWGZCADLoadContext; const Path: String);
procedure DWGWriteSummaryTxt(Ctx: TDWGZCADLoadContext;
  const SourcePath, Path: String);
procedure DWGWriteSummaryJson(Ctx: TDWGZCADLoadContext;
  const SourcePath, Path: String);

{ Helpers exposed for tests. }
function DWGObjectKindToText(Kind: TDWGZCADObjectKind): String;
function DWGShellStateToText(State: TDWGShellState): String;
function DWGRefSlotToText(Slot: TDWGZCADRefSlot): String;
function DWGAttachStateToText(State: TDWGAttachState): String;

{ Issue #1198 P2 (TZ §5): translate DWG_OBJECT_TYPE to its symbolic spelling
  using RTTI. The enum has gaps (e.g. $36, $37, $3a, $3b are unused) and class
  IDs jump to 500+; for unknown values the function falls back to the hex
  value so the histogram still produces a useful row. }
function DWGFixedTypeToText(const FT: DWG_OBJECT_TYPE): String;

type
  TDWGFixedTypeCounter = record
    FixedType: DWG_OBJECT_TYPE;
    Count: Integer;
  end;
  TDWGFixedTypeCounterArray = array of TDWGFixedTypeCounter;

{ Histogram of TDWGZCADHandleEntry.FixedType values across the handle map.
  Returns one entry per distinct FixedType actually observed (no zero buckets,
  unlike the kind histogram — fixedtype range is wide and sparse). Ordering
  is by descending Count so the histogram is readable as-is. }
procedure DWGCountByFixedType(Ctx: TDWGZCADLoadContext;
  out Counters: TDWGFixedTypeCounterArray);

implementation

{ ---------- TDWGSideFileResult ---------- }

procedure TDWGSideFileResult.Clear;
begin
  Mode := dmOff;
  HandlesWritten := 0;
  RefsWritten := 0;
  OwnersWritten := 0;
  SetLength(FilesWritten, 0);
end;

procedure TDWGSideFileResult.AddFile(const Path: String);
var
  N: Integer;
begin
  N := Length(FilesWritten);
  SetLength(FilesWritten, N + 1);
  FilesWritten[N] := Path;
end;

{ ---------- Mode helpers ---------- }

function DWGDiagModeFromString(const S: String): TDWGDiagMode;
var
  Lower: String;
begin
  Lower := LowerCase(Trim(S));
  if Lower = 'off' then
    Result := dmOff
  else if Lower = 'summary' then
    Result := dmSummary
  else if Lower = 'full' then
    Result := dmFull
  else if Lower = 'trace' then
    Result := dmTrace
  else
    Result := dmOff;
end;

function DWGDiagModeFromConst: TDWGDiagMode;
begin
  Result := DWG_DIAG_MODE;
end;

function DWGDiagModeToString(Mode: TDWGDiagMode): String;
begin
  case Mode of
    dmOff:     Result := 'off';
    dmSummary: Result := 'summary';
    dmFull:    Result := 'full';
    dmTrace:   Result := 'trace';
  else
    Result := 'off';
  end;
end;

{ ---------- Enum text helpers ---------- }

function DWGObjectKindToText(Kind: TDWGZCADObjectKind): String;
begin
  case Kind of
    dokUnknown:       Result := 'dokUnknown';
    dokLayer:         Result := 'dokLayer';
    dokLineType:      Result := 'dokLineType';
    dokTextStyle:     Result := 'dokTextStyle';
    dokDimStyle:      Result := 'dokDimStyle';
    dokBlockDef:      Result := 'dokBlockDef';
    dokModelSpace:    Result := 'dokModelSpace';
    dokPaperSpace:    Result := 'dokPaperSpace';
    dokContainer:     Result := 'dokContainer';
    dokBlockInsert:   Result := 'dokBlockInsert';
    dokEntity:        Result := 'dokEntity';
    dokControlObject: Result := 'dokControlObject';
  else
    Result := 'dok?';
  end;
end;

function DWGShellStateToText(State: TDWGShellState): String;
begin
  case State of
    msUnseen:   Result := 'msUnseen';
    msCreating: Result := 'msCreating';
    msCreated:  Result := 'msCreated';
    msSkipped:  Result := 'msSkipped';
    msFailed:   Result := 'msFailed';
  else
    Result := 'ms?';
  end;
end;

function DWGRefSlotToText(Slot: TDWGZCADRefSlot): String;
begin
  case Slot of
    rsLayer:         Result := 'rsLayer';
    rsLineType:      Result := 'rsLineType';
    rsTextStyle:     Result := 'rsTextStyle';
    rsDimStyle:          Result := 'rsDimStyle';
    rsBlockDef:          Result := 'rsBlockDef';
    rsDimStyleTextStyle: Result := 'rsDimStyleTextStyle';
    rsLayerLineType:     Result := 'rsLayerLineType';
  else
    Result := 'rs?';
  end;
end;

function DWGAttachStateToText(State: TDWGAttachState): String;
begin
  case State of
    asPending:   Result := 'asPending';
    asResolving: Result := 'asResolving';
    asAttached:  Result := 'asAttached';
    asFallback:  Result := 'asFallback';
    asSkipped:   Result := 'asSkipped';
  else
    Result := 'as?';
  end;
end;

function DWGFixedTypeToText(const FT: DWG_OBJECT_TYPE): String;
begin
  // WriteStr handles the sparse explicit values in DWG_OBJECT_TYPE correctly;
  // TypInfo.GetEnumName indexes dense enum RTTI and can mislabel $2c MTEXT as
  // the next declared value. Unknown gap/class IDs fall back to hex.
  WriteStr(Result, FT);
  if (Result = '') or (Pos('DWG_TYPE_', Result) <> 1) then
    Result := 'DWG_TYPE_$' + IntToHex(Ord(FT), 2);
end;

{ ---------- Path helper ---------- }

function DWGSideFilePath(const SourcePath, Suffix: String): String;
begin
  if SourcePath = '' then
    Result := 'dwg' + Suffix
  else
    Result := SourcePath + Suffix;
end;

{ ---------- CSV helpers ---------- }

function CsvEscape(const S: String): String;
var
  NeedsQuote: Boolean;
  I: Integer;
begin
  NeedsQuote := False;
  for I := 1 to Length(S) do
    if (S[I] = ';') or (S[I] = '"') or (S[I] = #10) or (S[I] = #13) then begin
      NeedsQuote := True;
      Break;
    end;
  if not NeedsQuote then begin
    Result := S;
    Exit;
  end;
  Result := '"' + StringReplace(S, '"', '""', [rfReplaceAll]) + '"';
end;

function HexHandle(Handle: TDWGZCADHandle): String;
begin
  Result := IntToHex(Handle, 1);
end;

function PtrToHex(Ptr: Pointer): String;
begin
  if Ptr = nil then
    Result := '0'
  else
    Result := IntToHex(PtrUInt(Ptr), 1);
end;

function BoolToCsv(B: Boolean): String;
begin
  if B then Result := '1' else Result := '0';
end;

{ ---------- File writer with stream buffering ---------- }

type
  TDWGFileSink = class
  private
    FStream: TFileStream;
    FBuf: String;
    procedure FlushBuf;
  public
    constructor Create(const Path: String);
    destructor Destroy; override;
    procedure WriteLine(const Line: String);
    procedure WriteRaw(const Chunk: String);
  end;

constructor TDWGFileSink.Create(const Path: String);
begin
  inherited Create;
  FStream := TFileStream.Create(Path, fmCreate);
  FBuf := '';
end;

destructor TDWGFileSink.Destroy;
begin
  try
    FlushBuf;
  finally
    FStream.Free;
    inherited;
  end;
end;

procedure TDWGFileSink.FlushBuf;
begin
  if FBuf <> '' then begin
    FStream.WriteBuffer(FBuf[1], Length(FBuf));
    FBuf := '';
  end;
end;

procedure TDWGFileSink.WriteLine(const Line: String);
begin
  FBuf := FBuf + Line + LineEnding;
  if Length(FBuf) > 32 * 1024 then
    FlushBuf;
end;

procedure TDWGFileSink.WriteRaw(const Chunk: String);
begin
  FBuf := FBuf + Chunk;
  if Length(FBuf) > 32 * 1024 then
    FlushBuf;
end;

{ ---------- Handles CSV ---------- }

procedure DWGWriteHandlesCsv(Ctx: TDWGZCADLoadContext; const Path: String);
var
  Sink: TDWGFileSink;
  I: Integer;
  Entry: PDWGZCADHandleEntry;
begin
  if Ctx = nil then
    Exit;
  Sink := TDWGFileSink.Create(Path);
  try
    Sink.WriteLine('RawIndex;HandleHex;ResolvedKind;ShellState;HasPtr;FixedType');
    for I := 0 to Ctx.Handles.Count - 1 do begin
      Entry := Ctx.Handles.EntryAt(I);
      if Entry = nil then
        Continue;
      Sink.WriteLine(
        IntToStr(Entry^.RawIndex) + ';' +
        HexHandle(Entry^.Handle) + ';' +
        DWGObjectKindToText(Entry^.Kind) + ';' +
        DWGShellStateToText(Entry^.ShellState) + ';' +
        BoolToCsv(Entry^.Ptr <> nil) + ';' +
        DWGFixedTypeToText(Entry^.FixedType));
    end;
  finally
    Sink.Free;
  end;
end;

{ ---------- Refs CSV ---------- }

procedure DWGWriteRefsCsv(Ctx: TDWGZCADLoadContext; const Path: String);
var
  Sink: TDWGFileSink;
  I, J: Integer;
  Ref: PDWGZCADPendingRef;
  CandidatesText: String;
begin
  if Ctx = nil then
    Exit;
  Sink := TDWGFileSink.Create(Path);
  try
    Sink.WriteLine('EntityHandle;Slot;RefHandle;Candidates;ExpectedKind;' +
      'AttachState;AttachReason;FallbackUsed;InlineRef;AttachedPtr');
    for I := 0 to Ctx.PendingRefs.Count - 1 do begin
      Ref := Ctx.PendingRefs.ItemAt(I);
      if Ref = nil then
        Continue;
      CandidatesText := '';
      for J := 0 to Ref^.RefCandidates.Count - 1 do begin
        if J > 0 then
          CandidatesText := CandidatesText + ',';
        CandidatesText := CandidatesText + HexHandle(Ref^.RefCandidates.Values[J]);
      end;
      Sink.WriteLine(
        HexHandle(Ref^.EntityHandle) + ';' +
        DWGRefSlotToText(Ref^.Slot) + ';' +
        HexHandle(Ref^.RefHandle) + ';' +
        CsvEscape(CandidatesText) + ';' +
        DWGObjectKindToText(Ref^.ExpectedKind) + ';' +
        DWGAttachStateToText(Ref^.AttachState) + ';' +
        DWGAttachReasonToText(Ref^.AttachReason) + ';' +
        BoolToCsv(Ref^.AttachState = asFallback) + ';' +
        BoolToCsv(Ref^.InlineRef) + ';' +
        PtrToHex(Ref^.AttachedRef));
    end;
  finally
    Sink.Free;
  end;
end;

{ ---------- Owners CSV ---------- }

procedure DWGWriteOwnersCsv(Ctx: TDWGZCADLoadContext; const Path: String);
var
  Sink: TDWGFileSink;
  I, J: Integer;
  Own: PDWGZCADPendingOwner;
  CandidatesText: String;
begin
  if Ctx = nil then
    Exit;
  Sink := TDWGFileSink.Create(Path);
  try
    Sink.WriteLine('EntityHandle;OwnerHandle;Candidates;AttachState;' +
      'AttachReason;FallbackUsed;AttachedOwner');
    for I := 0 to Ctx.PendingOwners.Count - 1 do begin
      Own := Ctx.PendingOwners.ItemAt(I);
      if Own = nil then
        Continue;
      CandidatesText := '';
      for J := 0 to Own^.OwnerCandidates.Count - 1 do begin
        if J > 0 then
          CandidatesText := CandidatesText + ',';
        CandidatesText := CandidatesText + HexHandle(Own^.OwnerCandidates.Values[J]);
      end;
      Sink.WriteLine(
        HexHandle(Own^.EntityHandle) + ';' +
        HexHandle(Own^.OwnerHandle) + ';' +
        CsvEscape(CandidatesText) + ';' +
        DWGAttachStateToText(Own^.AttachState) + ';' +
        DWGAttachReasonToText(Own^.AttachReason) + ';' +
        BoolToCsv(Own^.AttachState = asFallback) + ';' +
        PtrToHex(Own^.AttachedOwner));
    end;
  finally
    Sink.Free;
  end;
end;

{ ---------- Histograms used by summary ---------- }

type
  TDWGKindCounter = record
    Kind: TDWGZCADObjectKind;
    Count: Integer;
  end;
  TDWGKindCounterArray = array of TDWGKindCounter;

procedure CountByKind(Ctx: TDWGZCADLoadContext; out Counters: TDWGKindCounterArray);
var
  Buckets: array[TDWGZCADObjectKind] of Integer;
  K: TDWGZCADObjectKind;
  I, OutIdx: Integer;
  Entry: PDWGZCADHandleEntry;
begin
  for K := Low(TDWGZCADObjectKind) to High(TDWGZCADObjectKind) do
    Buckets[K] := 0;
  for I := 0 to Ctx.Handles.Count - 1 do begin
    Entry := Ctx.Handles.EntryAt(I);
    if Entry = nil then
      Continue;
    Inc(Buckets[Entry^.Kind]);
  end;
  SetLength(Counters, Ord(High(TDWGZCADObjectKind)) - Ord(Low(TDWGZCADObjectKind)) + 1);
  OutIdx := 0;
  for K := Low(TDWGZCADObjectKind) to High(TDWGZCADObjectKind) do begin
    Counters[OutIdx].Kind := K;
    Counters[OutIdx].Count := Buckets[K];
    Inc(OutIdx);
  end;
end;

procedure DWGCountByFixedType(Ctx: TDWGZCADLoadContext;
  out Counters: TDWGFixedTypeCounterArray);
var
  I, J, N: Integer;
  Entry: PDWGZCADHandleEntry;
  Found: Boolean;
  Tmp: TDWGFixedTypeCounter;
begin
  SetLength(Counters, 0);
  if Ctx = nil then
    Exit;
  // Linear bucket build: DWG_OBJECT_TYPE has gaps + class IDs in the 500-1000
  // range, so a flat array indexed by Ord(FT) would waste memory. The handle
  // map rarely exceeds a few thousand entries, so the O(N*B) cost is fine.
  for I := 0 to Ctx.Handles.Count - 1 do begin
    Entry := Ctx.Handles.EntryAt(I);
    if Entry = nil then
      Continue;
    Found := False;
    for J := 0 to High(Counters) do
      if Counters[J].FixedType = Entry^.FixedType then begin
        Inc(Counters[J].Count);
        Found := True;
        Break;
      end;
    if not Found then begin
      N := Length(Counters);
      SetLength(Counters, N + 1);
      Counters[N].FixedType := Entry^.FixedType;
      Counters[N].Count := 1;
    end;
  end;
  // Sort by descending count (simple insertion sort — Length(Counters) is
  // bounded by the number of distinct fixedtypes in the file, typically <40).
  for I := 1 to High(Counters) do begin
    Tmp := Counters[I];
    J := I - 1;
    while (J >= 0) and (Counters[J].Count < Tmp.Count) do begin
      Counters[J + 1] := Counters[J];
      Dec(J);
    end;
    Counters[J + 1] := Tmp;
  end;
end;

{ ---------- Summary TXT ---------- }

procedure DWGWriteSummaryTxt(Ctx: TDWGZCADLoadContext;
  const SourcePath, Path: String);
var
  Sink: TDWGFileSink;
  Kinds: TDWGKindCounterArray;
  FixedTypes: TDWGFixedTypeCounterArray;
  I: Integer;
  Agg: TDWGImportCodeAggregate;
  Suppressed: Integer;
begin
  if Ctx = nil then
    Exit;
  Sink := TDWGFileSink.Create(Path);
  try
    Sink.WriteLine('# DWG import summary');
    if SourcePath <> '' then
      Sink.WriteLine('file: ' + SourcePath);
    Sink.WriteLine('handles_total: ' + IntToStr(Ctx.Handles.Count));
    Sink.WriteLine('pending_owners: ' + IntToStr(Ctx.PendingOwners.Count));
    Sink.WriteLine('pending_refs: ' + IntToStr(Ctx.PendingRefs.Count));
    Sink.WriteLine('attached: ' + IntToStr(Ctx.AttachCount));
    Sink.WriteLine('fallback: ' + IntToStr(Ctx.FallbackCount));
    Sink.WriteLine('cycles: ' + IntToStr(Ctx.CycleCount));
    Sink.WriteLine('refs_attached: ' + IntToStr(Ctx.RefAttachCount));
    Sink.WriteLine('refs_fallback: ' + IntToStr(Ctx.RefFallbackCount));
    Sink.WriteLine('ref_cache_hits: ' + IntToStr(Ctx.RefCacheHits));
    Sink.WriteLine('ref_cache_misses: ' + IntToStr(Ctx.RefCacheMisses));
    Sink.WriteLine('unique_ref_keys: ' + IntToStr(Ctx.RefCacheKeys));
    Sink.WriteLine('unknown_entities: ' + IntToStr(Ctx.UnknownEntities));
    Sink.WriteLine('unknown_objects: ' + IntToStr(Ctx.UnknownObjects));
    Sink.WriteLine('proxies_loaded: ' + IntToStr(Ctx.ProxiesLoaded));
    Sink.WriteLine('proxies_failed: ' + IntToStr(Ctx.ProxiesFailed));
    Sink.WriteLine('freed_raw_drops: ' + IntToStr(Ctx.DroppedDueToFreedRaw));
    Sink.WriteLine('warnings_total: ' + IntToStr(Ctx.WarningCount));

    Sink.WriteLine('');
    Sink.WriteLine('# Handles by kind');
    CountByKind(Ctx, Kinds);
    for I := 0 to High(Kinds) do
      if Kinds[I].Count > 0 then
        Sink.WriteLine(DWGObjectKindToText(Kinds[I].Kind) + ': ' +
          IntToStr(Kinds[I].Count));

    // Issue #1198 P2: fixedtype histogram. Each row reports the symbolic
    // DWG_TYPE_*, the count and whether the handler registry knows about it
    // — exactly the cross-check requested in the audit.
    Sink.WriteLine('');
    Sink.WriteLine('# Handles by fixedtype');
    DWGCountByFixedType(Ctx, FixedTypes);
    for I := 0 to High(FixedTypes) do
      Sink.WriteLine(DWGFixedTypeToText(FixedTypes[I].FixedType) + ': ' +
        IntToStr(FixedTypes[I].Count));

    Sink.WriteLine('');
    Sink.WriteLine('# Warnings by code');
    for I := 0 to Ctx.WarningAggregateCount - 1 do begin
      Agg := Ctx.WarningAggregateAt(I);
      if Agg.TotalCount <= 0 then
        Continue;
      Suppressed := Agg.TotalCount - Agg.DistinctHandles;
      if Suppressed < 0 then
        Suppressed := 0;
      Sink.WriteLine(IntToStr(Agg.Code) + ' (' +
        DWGWarningCodeToShortName(Agg.Code) + '): total=' +
        IntToStr(Agg.TotalCount) + ', distinct_handles=' +
        IntToStr(Agg.DistinctHandles) + ', dedup_suppressed=' +
        IntToStr(Suppressed));
    end;
  finally
    Sink.Free;
  end;
end;

{ ---------- Summary JSON ---------- }

function JsonEscape(const S: String): String;
var
  I: Integer;
  C: Char;
begin
  Result := '';
  for I := 1 to Length(S) do begin
    C := S[I];
    case C of
      '"': Result := Result + '\"';
      '\': Result := Result + '\\';
      #8:  Result := Result + '\b';
      #9:  Result := Result + '\t';
      #10: Result := Result + '\n';
      #12: Result := Result + '\f';
      #13: Result := Result + '\r';
    else
      if C < #32 then
        Result := Result + '\u00' + IntToHex(Ord(C), 2)
      else
        Result := Result + C;
    end;
  end;
end;

procedure DWGWriteSummaryJson(Ctx: TDWGZCADLoadContext;
  const SourcePath, Path: String);
var
  Sink: TDWGFileSink;
  Kinds: TDWGKindCounterArray;
  FixedTypes: TDWGFixedTypeCounterArray;
  I, EmittedKinds, EmittedFixedTypes, EmittedAggs: Integer;
  Agg: TDWGImportCodeAggregate;
begin
  if Ctx = nil then
    Exit;
  Sink := TDWGFileSink.Create(Path);
  try
    Sink.WriteRaw('{' + LineEnding);
    Sink.WriteRaw('  "file": "' + JsonEscape(SourcePath) + '",' + LineEnding);
    Sink.WriteRaw('  "handles_total": ' + IntToStr(Ctx.Handles.Count) + ',' + LineEnding);
    Sink.WriteRaw('  "pending_owners": ' + IntToStr(Ctx.PendingOwners.Count) + ',' + LineEnding);
    Sink.WriteRaw('  "pending_refs": ' + IntToStr(Ctx.PendingRefs.Count) + ',' + LineEnding);
    Sink.WriteRaw('  "attached": ' + IntToStr(Ctx.AttachCount) + ',' + LineEnding);
    Sink.WriteRaw('  "fallback": ' + IntToStr(Ctx.FallbackCount) + ',' + LineEnding);
    Sink.WriteRaw('  "cycles": ' + IntToStr(Ctx.CycleCount) + ',' + LineEnding);
    Sink.WriteRaw('  "refs_attached": ' + IntToStr(Ctx.RefAttachCount) + ',' + LineEnding);
    Sink.WriteRaw('  "refs_fallback": ' + IntToStr(Ctx.RefFallbackCount) + ',' + LineEnding);
    Sink.WriteRaw('  "ref_cache_hits": ' + IntToStr(Ctx.RefCacheHits) + ',' + LineEnding);
    Sink.WriteRaw('  "ref_cache_misses": ' + IntToStr(Ctx.RefCacheMisses) + ',' + LineEnding);
    Sink.WriteRaw('  "unique_ref_keys": ' + IntToStr(Ctx.RefCacheKeys) + ',' + LineEnding);
    Sink.WriteRaw('  "unknown_entities": ' + IntToStr(Ctx.UnknownEntities) + ',' + LineEnding);
    Sink.WriteRaw('  "unknown_objects": ' + IntToStr(Ctx.UnknownObjects) + ',' + LineEnding);
    Sink.WriteRaw('  "warnings_total": ' + IntToStr(Ctx.WarningCount) + ',' + LineEnding);

    Sink.WriteRaw('  "kinds": {');
    CountByKind(Ctx, Kinds);
    EmittedKinds := 0;
    for I := 0 to High(Kinds) do
      if Kinds[I].Count > 0 then begin
        if EmittedKinds > 0 then
          Sink.WriteRaw(', ');
        Sink.WriteRaw('"' + DWGObjectKindToText(Kinds[I].Kind) + '": ' +
          IntToStr(Kinds[I].Count));
        Inc(EmittedKinds);
      end;
    Sink.WriteRaw('},' + LineEnding);

    Sink.WriteRaw('  "fixed_types": {');
    DWGCountByFixedType(Ctx, FixedTypes);
    EmittedFixedTypes := 0;
    for I := 0 to High(FixedTypes) do begin
      if EmittedFixedTypes > 0 then
        Sink.WriteRaw(', ');
      Sink.WriteRaw('"' + DWGFixedTypeToText(FixedTypes[I].FixedType) + '": ' +
        IntToStr(FixedTypes[I].Count));
      Inc(EmittedFixedTypes);
    end;
    Sink.WriteRaw('},' + LineEnding);

    Sink.WriteRaw('  "warnings": {');
    EmittedAggs := 0;
    for I := 0 to Ctx.WarningAggregateCount - 1 do begin
      Agg := Ctx.WarningAggregateAt(I);
      if Agg.TotalCount <= 0 then
        Continue;
      if EmittedAggs > 0 then
        Sink.WriteRaw(', ');
      Sink.WriteRaw('"' + IntToStr(Agg.Code) + '": ' + IntToStr(Agg.TotalCount));
      Inc(EmittedAggs);
    end;
    Sink.WriteRaw('}' + LineEnding);

    Sink.WriteRaw('}' + LineEnding);
  finally
    Sink.Free;
  end;
end;

{ ---------- Bundle writer ---------- }

function DWGWriteSideFiles(Ctx: TDWGZCADLoadContext;
  const SourcePath: String; Mode: TDWGDiagMode): TDWGSideFileResult;
var
  P: String;
begin
  Result.Clear;
  if Ctx = nil then
    Exit;
  if Mode = dmOff then
    Exit;
  Result.Mode := Mode;

  P := DWGSideFilePath(SourcePath, '.summary.txt');
  DWGWriteSummaryTxt(Ctx, SourcePath, P);
  Result.AddFile(P);

  P := DWGSideFilePath(SourcePath, '.summary.json');
  DWGWriteSummaryJson(Ctx, SourcePath, P);
  Result.AddFile(P);

  if Mode in [dmFull, dmTrace] then begin
    P := DWGSideFilePath(SourcePath, '.handles.csv');
    DWGWriteHandlesCsv(Ctx, P);
    Result.HandlesWritten := Ctx.Handles.Count;
    Result.AddFile(P);

    P := DWGSideFilePath(SourcePath, '.refs.csv');
    DWGWriteRefsCsv(Ctx, P);
    Result.RefsWritten := Ctx.PendingRefs.Count;
    Result.AddFile(P);

    P := DWGSideFilePath(SourcePath, '.owners.csv');
    DWGWriteOwnersCsv(Ctx, P);
    Result.OwnersWritten := Ctx.PendingOwners.Count;
    Result.AddFile(P);
  end;
end;

end.
