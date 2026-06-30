{*************************************************************************** }
{  fpdwg - DWG raw object scan (Stage 5.x R4 / Phase 1)                      }
{                                                                            }
{        Copyright (C) 2026 Andrey Zubarev <zamtmn@yandex.ru>                }
{                                                                            }
{  This library is free software, licensed under the terms of the GNU        }
{  General Public License as published by the Free Software Foundation,      }
{  either version 3 of the License, or (at your option) any later version.   }
{*************************************************************************** }

{ Refactor R4 (per TZ_DWG_LOAD_TO_ZCAD_AUDIT §3.4 / TZ §4.3, §5.3):
  Phase 1 raw scan over `Raw.&object[i]` carried out before any allocation
  takes place. The scan does three things, all of which used to be tangled
  with mapper allocation in `parseDwg_Data`:

    * register handle -> raw index in TDWGZCADHandleEntry.RawIndex (the
      field has existed since R2 but mappers always passed -1);
    * detect duplicate handles up front so DWG_WARN_DUPLICATE_HANDLE is
      raised exactly once per duplicate, not every time a mapper tries to
      RegisterShell the same handle later;
    * record supertype/fixedtype on the placeholder entry so future
      routing decisions (Stages 6-8: INSERT, HATCH, DIM) can branch on the
      raw type without re-walking the LibreDWG array.

  After ScanRawObjects every well-formed handle is present in the registry
  with kind=dokUnknown and ptr=nil. Mapper-side RegisterShell upgrades the
  placeholder to its real kind / pointer; a duplicate now means the mapper
  saw the same handle twice for real, which is what the warning is for. }

unit uzedwgrawscan;

{$Include zengineconfig.inc}
{$Mode objfpc}{$H+}
{$ModeSwitch advancedrecords}

interface

uses
  SysUtils,
  dwg,
  uzedwgtypes,
  uzedwghandle,
  uzedwgloadcontext,
  uzedwgentityregistry,
  uzedwgtargetedlog;

type
  { Per-object metadata captured by the raw scan so callers can branch on the
    DWG supertype/fixedtype without dereferencing the LibreDWG array a second
    time. The record is intentionally small — it is stored alongside the
    handle map entry, not as a separate parallel array. }
  TDWGRawObjectInfo = record
    Handle:    TDWGZCADHandle;
    RawIndex:  Integer;
    Supertype: DWG_OBJECT_SUPERTYPE;
    FixedType: DWG_OBJECT_TYPE;
  end;

{ Phase 1 entry point. Iterates every Raw.&object[i] and pre-registers the
  handle map. Safe to call with an empty Raw (num_objects=0) or with a Ctx
  that already holds entries — existing entries are left alone, the scan
  only fills in placeholders for handles that have not been registered yet
  (this keeps unit tests that pre-seed the registry working without change). }
procedure ScanRawObjects(var Raw: Dwg_Data; Ctx: TDWGZCADLoadContext);

{ Issue #1206: format one raw LibreDWG object for trace logging. The line
  includes both hex and decimal handles so values copied from dwgread JSON
  can be searched directly in the ZCAD log. }
function DWGRawObjectTraceLine(const Obj: Dwg_Object;
  AIndex: Integer): String;

implementation

uses
  uzedwglog,
  uzedwgsidefiles;

function DWGHandleDecText(Value: TDWGZCADHandle): String;
var
  Digit: Integer;
begin
  if Value = 0 then
    Exit('0');
  Result := '';
  while Value > 0 do begin
    Digit := Integer(Value mod 10);
    Result := Chr(Ord('0') + Digit) + Result;
    Value := Value div 10;
  end;
end;

function DWGHandleTraceText(Value: TDWGZCADHandle): String;
begin
  if Value = 0 then
    Result := '0/0'
  else
    Result := IntToHex(Value, 1) + '/' + DWGHandleDecText(Value);
end;

function DWGHandleCandidatesTraceText(
  const Candidates: TDWGRefHandleCandidates): String;
var
  I: Integer;
begin
  if Candidates.Count <= 0 then
    Exit('(none)');
  Result := '';
  for I := 0 to Candidates.Count - 1 do begin
    if I > 0 then
      Result := Result + ',';
    Result := Result + DWGHandleTraceText(Candidates.Values[I]);
  end;
end;

function DWGRawObjectEntMode(const Obj: Dwg_Object): Integer;
begin
  Result := -1;
  if (Obj.supertype = DWG_SUPERTYPE_ENTITY) and
     (Obj.tio.entity <> nil) then
    Result := Obj.tio.entity^.entmode;
end;

function DWGRawObjectTraceLine(const Obj: Dwg_Object;
  AIndex: Integer): String;
var
  Handle: TDWGZCADHandle;
  OwnerCandidates: TDWGRefHandleCandidates;
  OwnerText: String;
begin
  Handle := DWGObjectHandleValue(Obj);
  if DWGObjectOwnerHandleCandidatesValue(Obj, OwnerCandidates) then
    OwnerText := DWGHandleCandidatesTraceText(OwnerCandidates)
  else
    OwnerText := '(none)';
  Result :=
    'DWG raw object trace: index=' + IntToStr(AIndex) +
    ' handle_hex=' + IntToHex(Handle, 1) +
    ' handle_dec=' + DWGHandleDecText(Handle) +
    ' supertype=' + IntToStr(Ord(Obj.supertype)) +
    ' fixedtype=' + DWGFixedTypeToText(Obj.fixedtype) +
    ' fixedtype_ord=' + IntToStr(Ord(Obj.fixedtype)) +
    ' has_handler=' + BoolToStr(HasHandlerFor(Obj.fixedtype), True) +
    ' entmode=' + IntToStr(DWGRawObjectEntMode(Obj)) +
    ' owner_candidates=' + OwnerText;
end;

procedure ScanRawObjects(var Raw: Dwg_Data; Ctx: TDWGZCADLoadContext);
var
  I: BITCODE_BL;
  Handle: TDWGZCADHandle;
  Existing: TDWGZCADHandleEntry;
  MutEntry: PDWGZCADHandleEntry;
  OwnerCandidates: TDWGRefHandleCandidates;
  OwnerKnown: Boolean;
  HasHandler: Boolean;
  TraceRawObjects: Boolean;
begin
  if Ctx = nil then
    Exit;
  if Raw.num_objects = 0 then
    Exit;
  DWGNormalizeObjectHandles(Raw);
  TraceRawObjects := DWGDiagModeFromConst = dmTrace;
  // Walking the array via &object[i] mirrors parseDwg_Data so any pointer
  // arithmetic mistake in the binding would surface in both places at once.
  I := 0;
  while I < Raw.num_objects do begin
    Handle := DWGObjectHandleValue(Raw.&object[I]);
    OwnerKnown := DWGObjectOwnerHandleCandidatesValue(Raw.&object[I],
      OwnerCandidates);
    if not OwnerKnown then
      FillChar(OwnerCandidates, SizeOf(OwnerCandidates), 0);
    HasHandler := HasHandlerFor(Raw.&object[I].fixedtype);
    DWGLogInfoFormatStr(
      'DWG [read] raw_index=%d handle=%s supertype=%d fixedtype=%s fixedtype_ord=%d has_handler=%s entmode=%d',
      [Integer(I), DWGHandleLogText(Handle), Ord(Raw.&object[I].supertype),
       DWGFixedTypeToText(Raw.&object[I].fixedtype),
       Ord(Raw.&object[I].fixedtype), BoolToStr(HasHandler, True),
       DWGRawObjectEntMode(Raw.&object[I])]);
    DWGLogInfoFormatStr(
      'DWG [decode] raw_index=%d handle=%s owner_candidates=%s owner_known=%s',
      [Integer(I), DWGHandleLogText(Handle),
       DWGHandleArrayLogText(OwnerCandidates.Values, OwnerCandidates.Count),
       BoolToStr(OwnerKnown, True)]);
    // Issue #1206: optional full raw-object trace. This logs every object
    // LibreDWG returned before the loader filters handle=0 or missing mapper
    // cases, so it can prove whether a dwgread handle reached ZCAD at all.
    if TraceRawObjects then
      DWGLogInfoFormatStr('%s',
        [DWGRawObjectTraceLine(Raw.&object[I], Integer(I))]);
    // Handle 0 is reserved for the model-space root (registered in
    // BeginDWGImport) and for raw entries LibreDWG could not decode. Skipping
    // them here keeps the duplicate detector from firing on every truncated
    // object in a partial-read scenario.
    if Handle <> 0 then begin
      // Issue #1203: точечный лог Phase 1. Если интересующий handle отсюда
      // не виден — значит, LibreDWG вообще не вернул объект из dwg.&object[i],
      // и проблема лежит не в загрузчике ZCAD, а в декодировании DWG.
      // Дополнительно сообщаем, зарегистрирован ли mapper для данного
      // fixedtype: если has_handler=False, parseDwg_Data молча пропустит
      // объект и до фаз register/attach дело не дойдёт.
      TargetedLog('scan', Handle,
        Format('index=%d supertype=%d fixedtype=%d has_handler=%s',
          [Integer(I), Ord(Raw.&object[I].supertype),
           Ord(Raw.&object[I].fixedtype),
           BoolToStr(HasHandler, True)]));
      if Ctx.Handles.TryGet(Handle, Existing) then begin
        // A real duplicate at the raw level: two LibreDWG entries claim the
        // same handle. Only warn if the existing entry was not itself a raw
        // placeholder (RawIndex >= 0 means the placeholder slot is taken).
        if Existing.RawIndex >= 0 then
          Ctx.RaiseWarning(wsWarning, DWG_WARN_DUPLICATE_HANDLE, Handle,
            Format('Raw scan: duplicate handle %s at index %d (first seen at %d)',
              [IntToHex(Handle, 1), I, Existing.RawIndex]));
      end else begin
        // Place a kind=dokUnknown, ptr=nil placeholder. Mappers running later
        // will upgrade it; if no mapper claims the handle the placeholder
        // still records the raw index, which is what TZ §6.5 asks for.
        Ctx.RegisterShell(Handle, dokUnknown, nil, Integer(I));
      end;
      // Issue #1198 P2 (TZ §5): capture fixedtype on every placeholder so
      // the histogram diagnostic can enumerate raw-object kinds without a
      // second walk. The write goes through TryGetMutable so the duplicate
      // branch above still records the type (LibreDWG sometimes emits the
      // same handle twice in proxy/zombie blocks; we want the count to
      // reflect both entries).
      if Ctx.Handles.TryGetMutable(Handle, MutEntry) and (MutEntry <> nil) then
        MutEntry^.FixedType := Raw.&object[I].fixedtype;
    end;
    Inc(I);
  end;
end;

end.
