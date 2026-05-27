{*************************************************************************** }
{  fpdwg - DWG import diagnostic log module                                  }
{                                                                            }
{        Copyright (C) 2026 Andrey Zubarev <zamtmn@yandex.ru>                }
{                                                                            }
{  This library is free software, licensed under the terms of the GNU        }
{  General Public License as published by the Free Software Foundation,      }
{  either version 3 of the License, or (at your option) any later version.   }
{*************************************************************************** }

unit uzedwglog;

{$mode objfpc}{$H+}
{$modeswitch advancedrecords}

interface

uses
  SysUtils,
  uzbLogTypes,
  uzedwgtypes;

const
  { High-volume resolved attach traces are diagnostic-only. Keep disabled for
    normal imports so resolving 100k+ refs/owners does not spend time
    formatting per-entity info lines. Targeted and fallback diagnostics remain
    active through their dedicated gates. }
  DWG_VERBOSE_ATTACH_LOG = False;

var
  { Dedicated DWG loader diagnostics module. It is registered without
    EEnable, so normal imports stay quiet unless the user enables it with
    the regular programlog module switches, for example "lem DWG". }
  DWGLogModuleId: TModuleDesk;

function DWGObjectKindToLogText(Kind: TDWGZCADObjectKind): String;
function DWGRefSlotToLogText(Slot: TDWGZCADRefSlot): String;
function DWGShellStateToLogText(State: TDWGShellState): String;
function DWGAttachStateToLogText(State: TDWGAttachState): String;
function DWGImportSeverityToLogText(Severity: TDWGImportSeverity): String;
function DWGWarningCodePhaseText(Code: Integer): String;
function DWGHandleLogText(Value: TDWGZCADHandle): String;
function DWGHandleArrayLogText(const Handles: array of TDWGZCADHandle;
  Count: Integer): String;
function DWGHandleCandidatesLogText(
  const Candidates: TDWGZCADRefHandleCandidates): String;

procedure DWGLogInfoFormatStr(const Fmt: String; const Args: array of const);
procedure DWGLogWarningFormatStr(const Fmt: String; const Args: array of const);
procedure DWGLogErrorFormatStr(const Fmt: String; const Args: array of const);

implementation

uses
  uzclog;

function DWGObjectKindToLogText(Kind: TDWGZCADObjectKind): String;
begin
  case Kind of
    dokUnknown:       Result := 'unknown';
    dokLayer:         Result := 'layer';
    dokLineType:      Result := 'linetype';
    dokTextStyle:     Result := 'textstyle';
    dokDimStyle:      Result := 'dimstyle';
    dokBlockDef:      Result := 'block-def';
    dokModelSpace:    Result := 'model-space';
    dokPaperSpace:    Result := 'paper-space';
    dokContainer:     Result := 'container';
    dokBlockInsert:   Result := 'block-insert';
    dokEntity:        Result := 'entity';
    dokControlObject: Result := 'control-object';
  else
    Result := 'kind-' + IntToStr(Ord(Kind));
  end;
end;

function DWGRefSlotToLogText(Slot: TDWGZCADRefSlot): String;
begin
  case Slot of
    rsLayer:         Result := 'layer';
    rsLineType:      Result := 'linetype';
    rsTextStyle:     Result := 'textstyle';
    rsDimStyle:          Result := 'dimstyle';
    rsBlockDef:          Result := 'block-def';
    rsDimStyleTextStyle: Result := 'dimstyle-textstyle';
    rsLayerLineType:     Result := 'layer-linetype';
  else
    Result := 'slot-' + IntToStr(Ord(Slot));
  end;
end;

function DWGShellStateToLogText(State: TDWGShellState): String;
begin
  case State of
    msUnseen:   Result := 'unseen';
    msCreating: Result := 'creating';
    msCreated:  Result := 'created';
    msSkipped:  Result := 'skipped';
    msFailed:   Result := 'failed';
  else
    Result := 'shell-state-' + IntToStr(Ord(State));
  end;
end;

function DWGAttachStateToLogText(State: TDWGAttachState): String;
begin
  case State of
    asPending:   Result := 'pending';
    asResolving: Result := 'resolving';
    asAttached:  Result := 'attached';
    asFallback:  Result := 'fallback';
    asSkipped:   Result := 'skipped';
  else
    Result := 'attach-state-' + IntToStr(Ord(State));
  end;
end;

function DWGImportSeverityToLogText(Severity: TDWGImportSeverity): String;
begin
  case Severity of
    wsInfo:    Result := 'info';
    wsWarning: Result := 'warning';
    wsError:   Result := 'error';
  else
    Result := 'severity-' + IntToStr(Ord(Severity));
  end;
end;

function DWGWarningCodePhaseText(Code: Integer): String;
begin
  case Code of
    DWG_WARN_OWNER_NULL,
    DWG_WARN_OWNER_NOT_FOUND,
    DWG_WARN_OWNER_NOT_CONTAINER,
    DWG_WARN_OWNER_SELF_CYCLE,
    DWG_WARN_OWNER_CHAIN_CYCLE,
    DWG_WARN_OWNER_SKIPPED:
      Result := 'owner-resolution-error';
    DWG_WARN_REF_NULL,
    DWG_WARN_REF_NOT_FOUND,
    DWG_WARN_REF_KIND_MISMATCH:
      Result := 'ref-resolution-error';
    DWG_WARN_DUPLICATE_HANDLE:
      Result := 'handle-resolution-warning';
  else
    Result := 'diagnostic-warning';
  end;
end;

function DWGHandleLogText(Value: TDWGZCADHandle): String;
begin
  Result := IntToHex(Value, 1);
end;

function DWGHandleArrayLogText(const Handles: array of TDWGZCADHandle;
  Count: Integer): String;
var
  I, Limit: Integer;
begin
  Limit := Count;
  if Limit < 0 then
    Limit := 0;
  if Limit > Length(Handles) then
    Limit := Length(Handles);
  if Limit <= 0 then
    Exit('(none)');
  Result := '';
  for I := 0 to Limit - 1 do begin
    if I > 0 then
      Result := Result + ',';
    Result := Result + DWGHandleLogText(Handles[I]);
  end;
end;

function DWGHandleCandidatesLogText(
  const Candidates: TDWGZCADRefHandleCandidates): String;
begin
  Result := DWGHandleArrayLogText(Candidates.Values, Candidates.Count);
end;

procedure DWGLogInfoFormatStr(const Fmt: String; const Args: array of const);
begin
  programlog.LogOutFormatStr(Fmt, Args, LM_Info, DWGLogModuleId);
end;

procedure DWGLogWarningFormatStr(const Fmt: String;
  const Args: array of const);
begin
  programlog.LogOutFormatStr(Fmt, Args, LM_Warning, DWGLogModuleId);
end;

procedure DWGLogErrorFormatStr(const Fmt: String; const Args: array of const);
begin
  programlog.LogOutFormatStr(Fmt, Args, LM_Error, DWGLogModuleId);
end;

initialization
  DWGLogModuleId := programlog.RegisterModule('DWG');
end.
