{*************************************************************************** }
{  fpdwg - DWG to ZCAD import context: resolver (Stage 5.x R2)               }
{                                                                            }
{        Copyright (C) 2026 Andrey Zubarev <zamtmn@yandex.ru>                }
{                                                                            }
{  This library is free software, licensed under the terms of the GNU        }
{  General Public License as published by the Free Software Foundation,      }
{  either version 3 of the License, or (at your option) any later version.   }
{*************************************************************************** }

{ Refactor R2 (per TZ_DWG_LOAD_TO_ZCAD_AUDIT §3.2 / TZ §5.4):
  cycle-safe owner / ref resolver. Lives in its own unit so the load context
  no longer carries the resolve algorithm in the same file as the registry
  and pending queues. The resolver depends on the context only through the
  IDWGResolverHost surface (see below): handle map lookup, pending lookup,
  fallback configuration, attach callbacks, warning sink and stats. }

unit uzedwgresolver;

{$mode objfpc}{$H+}
{$modeswitch advancedrecords}

interface

uses
  SysUtils, uzedwgtypes, uzedwgdiagnostics;

type
  { Minimum surface a resolver host must expose. The load context descends
    from this so the resolver can run without seeing the rest of the
    context's state. Keeping it an abstract class (not an interface) avoids
    pulling COM-style refcount semantics into a TObject-managed graph. }
  TDWGResolverHost = class
  public
    function TryGetEntry(AHandle: TDWGZCADHandle;
      out Entry: TDWGZCADHandleEntry): Boolean; virtual; abstract;
    function FindPendingOwner(AEntityHandle: TDWGZCADHandle
      ): PDWGZCADPendingOwner; virtual; abstract;

    function GetFallbackOwner: Pointer; virtual; abstract;
    function FallbackForSlot(ASlot: TDWGZCADRefSlot): Pointer;
      virtual; abstract;

    procedure InvokeOwnerAttach(Entity, Owner: Pointer;
      const Context: TDWGAttachContext); virtual; abstract;
    procedure InvokeRefAttach(Entity, Ref: Pointer;
      const Context: TDWGAttachContext); virtual; abstract;

    procedure RaiseWarning(Severity: TDWGImportSeverity; Code: Integer;
      Handle: TDWGZCADHandle; const Text: String); virtual; abstract;
    function GetStatsRef: PDWGImportStats; virtual; abstract;
  end;

  TDWGRefResolveCacheKey = record
    Slot: TDWGZCADRefSlot;
    ExpectedKind: TDWGZCADObjectKind;
    InlineRef: Boolean;
    Fallback: Pointer;
    RefCount: Integer;
    RefHandles: array[0..DWG_ZCAD_MAX_REF_HANDLE_CANDIDATES - 1]
      of TDWGZCADHandle;
  end;

  TDWGRefResolveCacheValue = record
    Ref: Pointer;
    RefHandle: TDWGZCADHandle;
    State: TDWGAttachState;
    Reason: TDWGAttachReason;
  end;

  TDWGRefResolveCacheEntry = record
    Used: Boolean;
    Hash: QWord;
    Key: TDWGRefResolveCacheKey;
    Value: TDWGRefResolveCacheValue;
  end;

  { Stand-alone resolver state. Holds only the cycle-detection stack so a
    second concurrent resolver (e.g. a future raw-scan pre-resolver) can
    coexist with the main load context. The host supplies pending lookup
    and warning sinks, so this class has no entity-specific knowledge. }
  TDWGZCADResolver = class
  private
    FHost: TDWGResolverHost;
    FResolveStack: array of TDWGZCADHandle;
    FRefCache: array of TDWGRefResolveCacheEntry;
    FRefCacheCount: Integer;
    procedure PushStack(Handle: TDWGZCADHandle);
    procedure PopStack;
    function StackContains(Handle: TDWGZCADHandle): Boolean;
    function RefCacheHash(const Key: TDWGRefResolveCacheKey): QWord;
    function RefCacheKeysEqual(const A, B: TDWGRefResolveCacheKey): Boolean;
    procedure EnsureRefCacheCapacity;
    procedure InsertRefCacheEntry(const Key: TDWGRefResolveCacheKey;
      Hash: QWord; const Value: TDWGRefResolveCacheValue);
    function TryGetRefCache(const Key: TDWGRefResolveCacheKey;
      out Value: TDWGRefResolveCacheValue): Boolean;
    procedure StoreRefCache(const Key: TDWGRefResolveCacheKey;
      const Value: TDWGRefResolveCacheValue);
    procedure FinishOwner(Pending: PDWGZCADPendingOwner; Owner: Pointer;
      State: TDWGAttachState; Reason: TDWGAttachReason);
    procedure FinishRef(Pending: PDWGZCADPendingRef; Ref: Pointer;
      State: TDWGAttachState; Reason: TDWGAttachReason);
  public
    constructor Create(AHost: TDWGResolverHost);
    procedure ResetStack;
    procedure ResolvePending(Pending: PDWGZCADPendingOwner);
    procedure ResolveRef(Pending: PDWGZCADPendingRef);
  end;

implementation

constructor TDWGZCADResolver.Create(AHost: TDWGResolverHost);
begin
  inherited Create;
  FHost := AHost;
end;

procedure TDWGZCADResolver.PushStack(Handle: TDWGZCADHandle);
begin
  SetLength(FResolveStack, Length(FResolveStack) + 1);
  FResolveStack[High(FResolveStack)] := Handle;
end;

procedure TDWGZCADResolver.PopStack;
begin
  if Length(FResolveStack) > 0 then
    SetLength(FResolveStack, Length(FResolveStack) - 1);
end;

function TDWGZCADResolver.StackContains(Handle: TDWGZCADHandle): Boolean;
var
  I: Integer;
begin
  for I := 0 to High(FResolveStack) do
    if FResolveStack[I] = Handle then
      Exit(True);
  Result := False;
end;

procedure TDWGZCADResolver.ResetStack;
begin
  SetLength(FResolveStack, 0);
end;

function TDWGZCADResolver.RefCacheHash(
  const Key: TDWGRefResolveCacheKey): QWord;
var
  I: Integer;

  procedure Mix(Value: QWord);
  begin
    Result := ((Result shl 7) or (Result shr 57)) xor Value
      xor QWord($9E3779B9);
  end;
begin
  Result := QWord(Ord(Key.Slot)) + 1;
  Mix(QWord(Ord(Key.ExpectedKind)));
  if Key.InlineRef then
    Mix(1)
  else
    Mix(0);
  Mix(QWord(PtrUInt(Key.Fallback)));
  Mix(QWord(Key.RefCount));
  for I := 0 to High(Key.RefHandles) do
    Mix(Key.RefHandles[I]);
  if Result = 0 then
    Result := 1;
end;

function TDWGZCADResolver.RefCacheKeysEqual(
  const A, B: TDWGRefResolveCacheKey): Boolean;
var
  I: Integer;
begin
  Result := (A.Slot = B.Slot)
    and (A.ExpectedKind = B.ExpectedKind)
    and (A.InlineRef = B.InlineRef)
    and (A.Fallback = B.Fallback)
    and (A.RefCount = B.RefCount);
  if not Result then
    Exit;
  for I := 0 to High(A.RefHandles) do
    if A.RefHandles[I] <> B.RefHandles[I] then
      Exit(False);
end;

procedure TDWGZCADResolver.EnsureRefCacheCapacity;
var
  OldCache: array of TDWGRefResolveCacheEntry;
  I, NewCapacity: Integer;
begin
  if Length(FRefCache) = 0 then
  begin
    SetLength(FRefCache, 256);
    Exit;
  end;
  if (FRefCacheCount + 1) * 10 < Length(FRefCache) * 7 then
    Exit;

  OldCache := FRefCache;
  NewCapacity := Length(FRefCache) * 2;
  SetLength(FRefCache, 0);
  SetLength(FRefCache, NewCapacity);
  FRefCacheCount := 0;
  for I := 0 to High(OldCache) do
    if OldCache[I].Used then
      InsertRefCacheEntry(OldCache[I].Key, OldCache[I].Hash,
        OldCache[I].Value);
end;

procedure TDWGZCADResolver.InsertRefCacheEntry(
  const Key: TDWGRefResolveCacheKey; Hash: QWord;
  const Value: TDWGRefResolveCacheValue);
var
  Index, Mask: Integer;
begin
  Mask := Length(FRefCache) - 1;
  Index := Integer(Hash and QWord(Mask));
  while FRefCache[Index].Used do
    Index := (Index + 1) and Mask;
  FRefCache[Index].Used := True;
  FRefCache[Index].Hash := Hash;
  FRefCache[Index].Key := Key;
  FRefCache[Index].Value := Value;
  Inc(FRefCacheCount);
end;

function TDWGZCADResolver.TryGetRefCache(
  const Key: TDWGRefResolveCacheKey;
  out Value: TDWGRefResolveCacheValue): Boolean;
var
  Hash: QWord;
  Index, Mask: Integer;
begin
  Result := False;
  if Length(FRefCache) = 0 then
    Exit;
  Hash := RefCacheHash(Key);
  Mask := Length(FRefCache) - 1;
  Index := Integer(Hash and QWord(Mask));
  while FRefCache[Index].Used do
  begin
    if (FRefCache[Index].Hash = Hash)
      and RefCacheKeysEqual(FRefCache[Index].Key, Key) then
    begin
      Value := FRefCache[Index].Value;
      Exit(True);
    end;
    Index := (Index + 1) and Mask;
  end;
end;

procedure TDWGZCADResolver.StoreRefCache(
  const Key: TDWGRefResolveCacheKey;
  const Value: TDWGRefResolveCacheValue);
var
  Hash: QWord;
  Index, Mask: Integer;
  Stats: PDWGImportStats;
begin
  EnsureRefCacheCapacity;
  Hash := RefCacheHash(Key);
  Mask := Length(FRefCache) - 1;
  Index := Integer(Hash and QWord(Mask));
  while FRefCache[Index].Used do
  begin
    if (FRefCache[Index].Hash = Hash)
      and RefCacheKeysEqual(FRefCache[Index].Key, Key) then
    begin
      FRefCache[Index].Value := Value;
      Exit;
    end;
    Index := (Index + 1) and Mask;
  end;
  FRefCache[Index].Used := True;
  FRefCache[Index].Hash := Hash;
  FRefCache[Index].Key := Key;
  FRefCache[Index].Value := Value;
  Inc(FRefCacheCount);
  Stats := FHost.GetStatsRef;
  Inc(Stats^.RefCacheKeys);
end;

procedure TDWGZCADResolver.FinishOwner(Pending: PDWGZCADPendingOwner;
  Owner: Pointer; State: TDWGAttachState; Reason: TDWGAttachReason);
var
  Stats: PDWGImportStats;
  Context: TDWGAttachContext;
begin
  Pending^.AttachState := State;
  Pending^.AttachedOwner := Owner;
  Pending^.AttachReason := Reason;
  Stats := FHost.GetStatsRef;
  if State = asAttached then
    Inc(Stats^.AttachCount)
  else if State = asFallback then
    Inc(Stats^.FallbackCount);
  if Reason in [arSelfOwnerCycle, arOwnerChainCycle] then
    Inc(Stats^.CycleCount);
  if Owner <> nil then
  begin
    Context.EntityHandle := Pending^.EntityHandle;
    Context.TargetHandle := Pending^.OwnerHandle;
    Context.Slot := Low(TDWGZCADRefSlot);
    Context.Reason := Reason;
    FHost.InvokeOwnerAttach(Pending^.Entity, Owner, Context);
  end;
end;

procedure TDWGZCADResolver.ResolvePending(Pending: PDWGZCADPendingOwner);
var
  OwnerEntry: TDWGZCADHandleEntry;
  OwnerPending: PDWGZCADPendingOwner;
  Fallback: Pointer;
  Candidates: TDWGZCADRefHandleCandidates;
  I: Integer;
  FailureCode: Integer;
  FailureSeverity: TDWGImportSeverity;
  FailureReason: TDWGAttachReason;
  FailureHandle: TDWGZCADHandle;
  FailureText: String;
  HaveFailure: Boolean;

  procedure AddLocalCandidate(AHandle: TDWGZCADHandle);
  var
    J: Integer;
  begin
    if AHandle = 0 then
      Exit;
    for J := 0 to Candidates.Count - 1 do
      if Candidates.Values[J] = AHandle then
        Exit;
    if Candidates.Count > High(Candidates.Values) then
      Exit;
    Candidates.Values[Candidates.Count] := AHandle;
    Inc(Candidates.Count);
  end;

  procedure RememberFailure(ACode: Integer; ASeverity: TDWGImportSeverity;
    AReason: TDWGAttachReason; AHandle: TDWGZCADHandle;
    const AText: String);
  begin
    if HaveFailure then
      Exit;
    HaveFailure := True;
    FailureCode := ACode;
    FailureSeverity := ASeverity;
    FailureReason := AReason;
    FailureHandle := AHandle;
    FailureText := AText;
  end;
begin
  if Pending = nil then
    Exit;

  // Section 5.4: idempotency. A second call must not double-attach.
  if Pending^.AttachState in [asAttached, asFallback, asSkipped] then
    Exit;

  // Section 5.4: detect re-entry (cycle through the resolve stack).
  if Pending^.AttachState = asResolving then
  begin
    FHost.RaiseWarning(wsWarning, DWG_WARN_OWNER_CHAIN_CYCLE,
      Pending^.EntityHandle,
      Format('Owner chain cycle for entity %s, breaking',
        [IntToHex(Pending^.EntityHandle, 1)]));
    Fallback := Pending^.FallbackOwner;
    if Fallback = nil then
      Fallback := FHost.GetFallbackOwner;
    FinishOwner(Pending, Fallback, asFallback, arOwnerChainCycle);
    Exit;
  end;

  Pending^.AttachState := asResolving;
  PushStack(Pending^.EntityHandle);
  try
    Fallback := Pending^.FallbackOwner;
    if Fallback = nil then
      Fallback := FHost.GetFallbackOwner;

    Candidates := Pending^.OwnerCandidates;
    if Candidates.Count > High(Candidates.Values) + 1 then
      Candidates.Count := High(Candidates.Values) + 1;
    if (Candidates.Count = 0) and (Pending^.OwnerHandle <> 0) then
      AddLocalCandidate(Pending^.OwnerHandle);

    if Candidates.Count = 0 then
    begin
      FHost.RaiseWarning(wsInfo, DWG_WARN_OWNER_NULL, Pending^.EntityHandle,
        Format('Entity %s has null owner; using fallback root',
          [IntToHex(Pending^.EntityHandle, 1)]));
      FinishOwner(Pending, Fallback, asFallback, arNullOwner);
      Exit;
    end;

    HaveFailure := False;
    for I := 0 to Candidates.Count - 1 do
    begin
      Pending^.OwnerHandle := Candidates.Values[I];

      if Pending^.OwnerHandle = Pending^.EntityHandle then
      begin
        RememberFailure(DWG_WARN_OWNER_SELF_CYCLE, wsWarning,
          arSelfOwnerCycle, Pending^.OwnerHandle,
          Format('Self-owner cycle on entity %s; using fallback root',
            [IntToHex(Pending^.EntityHandle, 1)]));
        Continue;
      end;

      if not FHost.TryGetEntry(Pending^.OwnerHandle, OwnerEntry) then
      begin
        RememberFailure(DWG_WARN_OWNER_NOT_FOUND, wsWarning,
          arOwnerNotFound, Pending^.OwnerHandle,
          Format('Owner %s not found for entity %s; using fallback root',
            [IntToHex(Pending^.OwnerHandle, 1),
             IntToHex(Pending^.EntityHandle, 1)]));
        Continue;
      end;

      if not (OwnerEntry.Kind in
          [dokBlockDef, dokModelSpace, dokPaperSpace, dokContainer,
           dokBlockInsert]) then
      begin
        RememberFailure(DWG_WARN_OWNER_NOT_CONTAINER, wsWarning,
          arOwnerNotContainer, Pending^.OwnerHandle,
          Format('Owner %s for entity %s is not a container (kind=%d); '+
                 'using fallback root',
            [IntToHex(Pending^.OwnerHandle, 1),
             IntToHex(Pending^.EntityHandle, 1),
             Ord(OwnerEntry.Kind)]));
        Continue;
      end;

      // Section 5.3: ensure owner itself is resolved before attaching child.
      OwnerPending := FHost.FindPendingOwner(Pending^.OwnerHandle);
      if OwnerPending <> nil then
      begin
        if OwnerPending^.AttachState = asResolving then
        begin
          RememberFailure(DWG_WARN_OWNER_CHAIN_CYCLE, wsWarning,
            arOwnerChainCycle, Pending^.OwnerHandle,
            Format('Owner chain cycle %s -> %s detected; using fallback root',
              [IntToHex(Pending^.EntityHandle, 1),
               IntToHex(Pending^.OwnerHandle, 1)]));
          Continue;
        end;
        ResolvePending(OwnerPending);
        if OwnerPending^.AttachState = asSkipped then
        begin
          RememberFailure(DWG_WARN_OWNER_SKIPPED, wsWarning, arOwnerSkipped,
            Pending^.OwnerHandle,
            Format('Owner %s for entity %s was skipped; using fallback root',
              [IntToHex(Pending^.OwnerHandle, 1),
               IntToHex(Pending^.EntityHandle, 1)]));
          Continue;
        end;
      end;

      if StackContains(Pending^.OwnerHandle) then
      begin
        RememberFailure(DWG_WARN_OWNER_CHAIN_CYCLE, wsWarning,
          arOwnerChainCycle, Pending^.OwnerHandle,
          Format('Owner chain cycle reaches %s through %s; using fallback root',
            [IntToHex(Pending^.OwnerHandle, 1),
             IntToHex(Pending^.EntityHandle, 1)]));
        Continue;
      end;

      FinishOwner(Pending, OwnerEntry.Ptr, asAttached, arResolved);
      Exit;
    end;

    if not HaveFailure then
    begin
      FailureCode := DWG_WARN_OWNER_NULL;
      FailureSeverity := wsInfo;
      FailureReason := arNullOwner;
      FailureHandle := 0;
      FailureText := Format('Entity %s has null owner; using fallback root',
        [IntToHex(Pending^.EntityHandle, 1)]);
    end;

    Pending^.OwnerHandle := FailureHandle;
    FHost.RaiseWarning(FailureSeverity, FailureCode, Pending^.EntityHandle,
      FailureText);
    FinishOwner(Pending, Fallback, asFallback, FailureReason);
  finally
    PopStack;
    if Pending^.AttachState = asResolving then
      Pending^.AttachState := asSkipped;
  end;
end;

procedure TDWGZCADResolver.FinishRef(Pending: PDWGZCADPendingRef;
  Ref: Pointer; State: TDWGAttachState; Reason: TDWGAttachReason);
var
  Stats: PDWGImportStats;
  Context: TDWGAttachContext;
begin
  Pending^.AttachState := State;
  Pending^.AttachedRef := Ref;
  Pending^.AttachReason := Reason;
  Stats := FHost.GetStatsRef;
  if State = asAttached then
    Inc(Stats^.RefAttachCount)
  else if State = asFallback then
    Inc(Stats^.RefFallbackCount);
  Context.EntityHandle := Pending^.EntityHandle;
  Context.TargetHandle := Pending^.RefHandle;
  Context.Slot := Pending^.Slot;
  Context.Reason := Reason;
  FHost.InvokeRefAttach(Pending^.Entity, Ref, Context);
end;

procedure TDWGZCADResolver.ResolveRef(Pending: PDWGZCADPendingRef);
var
  Entry: TDWGZCADHandleEntry;
  Fallback: Pointer;
  Candidates: TDWGZCADRefHandleCandidates;
  I: Integer;
  FailureCode: Integer;
  FailureSeverity: TDWGImportSeverity;
  FailureReason: TDWGAttachReason;
  FailureHandle: TDWGZCADHandle;
  FailureText: String;
  HaveFailure: Boolean;
  CacheKey: TDWGRefResolveCacheKey;
  CacheValue: TDWGRefResolveCacheValue;
  Stats: PDWGImportStats;

  procedure AddLocalCandidate(AHandle: TDWGZCADHandle);
  var
    J: Integer;
  begin
    if AHandle = 0 then
      Exit;
    for J := 0 to Candidates.Count - 1 do
      if Candidates.Values[J] = AHandle then
        Exit;
    if Candidates.Count > High(Candidates.Values) then
      Exit;
    Candidates.Values[Candidates.Count] := AHandle;
    Inc(Candidates.Count);
  end;

  procedure RememberFailure(ACode: Integer; ASeverity: TDWGImportSeverity;
    AReason: TDWGAttachReason; AHandle: TDWGZCADHandle;
    const AText: String);
  begin
    if HaveFailure then
      Exit;
    HaveFailure := True;
    FailureCode := ACode;
    FailureSeverity := ASeverity;
    FailureReason := AReason;
    FailureHandle := AHandle;
    FailureText := AText;
  end;

  procedure BuildCacheKey;
  var
    J: Integer;
  begin
    FillChar(CacheKey, SizeOf(CacheKey), 0);
    CacheKey.Slot := Pending^.Slot;
    CacheKey.ExpectedKind := Pending^.ExpectedKind;
    CacheKey.InlineRef := Pending^.InlineRef;
    CacheKey.Fallback := Fallback;
    CacheKey.RefCount := Candidates.Count;
    for J := 0 to Candidates.Count - 1 do
      CacheKey.RefHandles[J] := Candidates.Values[J];
  end;

  procedure StoreResolvedRef(ARef: Pointer; ARefHandle: TDWGZCADHandle);
  begin
    CacheValue.Ref := ARef;
    CacheValue.RefHandle := ARefHandle;
    CacheValue.State := asAttached;
    CacheValue.Reason := arResolved;
    StoreRefCache(CacheKey, CacheValue);
  end;
begin
  if Pending = nil then
    Exit;

  // Idempotency (TZ §5.4): a second ResolveRefs call must not re-attach.
  if Pending^.AttachState in [asAttached, asFallback, asSkipped] then
    Exit;

  Fallback := Pending^.Fallback;
  if Fallback = nil then
    Fallback := FHost.FallbackForSlot(Pending^.Slot);

  Candidates := Pending^.RefCandidates;
  if Candidates.Count > High(Candidates.Values) + 1 then
    Candidates.Count := High(Candidates.Values) + 1;
  if (Candidates.Count = 0) and (Pending^.RefHandle <> 0) then
    AddLocalCandidate(Pending^.RefHandle);
  BuildCacheKey;

  Stats := FHost.GetStatsRef;
  if TryGetRefCache(CacheKey, CacheValue) then
  begin
    Inc(Stats^.RefCacheHits);
    Pending^.RefHandle := CacheValue.RefHandle;
    FinishRef(Pending, CacheValue.Ref, CacheValue.State,
      CacheValue.Reason);
    Exit;
  end;
  Inc(Stats^.RefCacheMisses);

  if Pending^.InlineRef and (Fallback <> nil) then
  begin
    StoreResolvedRef(Fallback, Pending^.RefHandle);
    FinishRef(Pending, Fallback, asAttached, arResolved);
    Exit;
  end;

  if Candidates.Count = 0 then
  begin
    FHost.RaiseWarning(wsInfo, DWG_WARN_REF_NULL, Pending^.EntityHandle,
      Format('Entity %s has null ref in slot %d; using fallback',
        [IntToHex(Pending^.EntityHandle, 1), Ord(Pending^.Slot)]));
    FinishRef(Pending, Fallback, asFallback, arRefNull);
    Exit;
  end;

  HaveFailure := False;
  for I := 0 to Candidates.Count - 1 do
  begin
    Pending^.RefHandle := Candidates.Values[I];

    if not FHost.TryGetEntry(Pending^.RefHandle, Entry) then
    begin
      RememberFailure(DWG_WARN_REF_NOT_FOUND, wsWarning, arRefNotFound,
        Pending^.RefHandle,
        Format('Ref %s (slot %d) not found for entity %s; using fallback',
          [IntToHex(Pending^.RefHandle, 1), Ord(Pending^.Slot),
           IntToHex(Pending^.EntityHandle, 1)]));
      Continue;
    end;

    if (Pending^.Slot = rsBlockDef) and
       (Entry.Kind in [dokBlockDef, dokModelSpace, dokPaperSpace]) then
    begin
      if Entry.Ptr = nil then
      begin
        RememberFailure(DWG_WARN_REF_NOT_FOUND, wsWarning, arRefNotFound,
          Pending^.RefHandle,
          Format('Block ref %s for entity %s registered with nil ptr; using fallback',
            [IntToHex(Pending^.RefHandle, 1),
             IntToHex(Pending^.EntityHandle, 1)]));
        Continue;
      end;
      StoreResolvedRef(Entry.Ptr, Pending^.RefHandle);
      FinishRef(Pending, Entry.Ptr, asAttached, arResolved);
      Exit;
    end;

    if Entry.Kind <> Pending^.ExpectedKind then
    begin
      RememberFailure(DWG_WARN_REF_KIND_MISMATCH, wsWarning, arRefKindMismatch,
        Pending^.RefHandle,
        Format('Ref %s for entity %s has kind %d, expected %d; using fallback',
          [IntToHex(Pending^.RefHandle, 1),
           IntToHex(Pending^.EntityHandle, 1),
           Ord(Entry.Kind), Ord(Pending^.ExpectedKind)]));
      Continue;
    end;

    if Entry.Ptr = nil then
    begin
      // Shell registered without a backing object: treat as not found so the
      // entity still ends up with a usable reference rather than nil.
      RememberFailure(DWG_WARN_REF_NOT_FOUND, wsWarning, arRefNotFound,
        Pending^.RefHandle,
        Format('Ref %s for entity %s registered with nil ptr; using fallback',
          [IntToHex(Pending^.RefHandle, 1),
           IntToHex(Pending^.EntityHandle, 1)]));
      Continue;
    end;

    StoreResolvedRef(Entry.Ptr, Pending^.RefHandle);
    FinishRef(Pending, Entry.Ptr, asAttached, arResolved);
    Exit;
  end;

  if not HaveFailure then
  begin
    FailureCode := DWG_WARN_REF_NULL;
    FailureSeverity := wsInfo;
    FailureReason := arRefNull;
    FailureHandle := 0;
    FailureText := Format('Entity %s has null ref in slot %d; using fallback',
      [IntToHex(Pending^.EntityHandle, 1), Ord(Pending^.Slot)]);
  end;

  Pending^.RefHandle := FailureHandle;
  FHost.RaiseWarning(FailureSeverity, FailureCode, Pending^.EntityHandle,
    FailureText);
  FinishRef(Pending, Fallback, asFallback, FailureReason);
end;

end.
