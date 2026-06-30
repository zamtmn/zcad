{*************************************************************************** }
{  fpdwg - DWG proxy / unknown fallback mapper (Stage 7)                     }
{                                                                            }
{        Copyright (C) 2026 Andrey Zubarev <zamtmn@yandex.ru>                }
{                                                                            }
{  This library is free software, licensed under the terms of the GNU        }
{  General Public License as published by the Free Software Foundation,      }
{  either version 3 of the License, or (at your option) any later version.   }
{*************************************************************************** }

{ Stage 7 (TZ §12.7 / audit §4.2): preserve copyable ACAD_PROXY_ENTITY
  graphics through the existing ZCAD proxy entity, and make unsupported
  unknown/opaque objects visible in diagnostics instead of silently ignoring
  them. Raw LibreDWG pointers are never stored past this mapper call. }

unit uzedwgentproxy;

{$Include zengineconfig.inc}
{$Mode delphi}{$H+}
{$ModeSwitch advancedrecords}

interface

uses
  SysUtils,
  dwg, dwgproc,
  uzedwghandle,
  uzedrawingsimple,
  uzeentity,
  uzeentsubordinated,
  uzeentacdproxy,
  uzedwgentityregistry,
  uzeffmanager,
  uzedwgtypes,
  uzedwgdiagnostics,
  uzedwgimport;

implementation

uses
  uzedwglog;

function Stage7Stats: PDWGImportStats;
begin
  Result := nil;
  if GetLoadCtx <> nil then
    Result := GetLoadCtx.GetStatsRef;
end;

function DWGVersionToDXFFileVersion(Version: DWG_VERSION_TYPE): Integer;
begin
  if Version = R_INVALID then
    Exit(0);
  if Ord(Version) >= Ord(R_2007a) then
    Result := 1021
  else if Ord(Version) >= Ord(R_2004a) then
    Result := 1018
  else
    Result := 1015;
end;

procedure MarkSkipped(Handle: TDWGZCADHandle);
begin
  if (Handle <> 0) and (GetLoadCtx <> nil) then
    GetLoadCtx.MarkShellState(Handle, msSkipped);
end;

procedure Warn(Severity: TDWGImportSeverity; Code: Integer;
  Handle: TDWGZCADHandle; const Text: string);
begin
  if GetLoadCtx <> nil then
    GetLoadCtx.RaiseWarning(Severity, Code, Handle, Text);
end;

procedure ApplyCommonProps(Pobj: PGDBObjEntity; var DWGObject: Dwg_Object);
var
  Props: TDWGEntityCommonProps;
begin
  if (Pobj = nil) or not DWGEntityCommonPropsValue(DWGObject, Props) then
    Exit;
  Pobj^.vp.Color := Props.ColorIndex;
  Pobj^.vp.LineWeight := Props.LineWeight;
  Pobj^.vp.LineTypeScale := Props.LineTypeScale;
end;

function AnsiPtrText(P: PAnsiChar): string;
begin
  if P = nil then
    Result := ''
  else
    Result := string(P);
end;

function DWGObjectProxyDiag(const DWGObject: Dwg_Object): string;
var
  Ent: ^Dwg_Object_Entity;
begin
  Result := Format(' fixedtype=%d name="%s" dxfname="%s"',
    [Ord(DWGObject.fixedtype),
     AnsiPtrText(PAnsiChar(DWGObject.name)),
     AnsiPtrText(PAnsiChar(DWGObject.dxfname))]);
  if DWGObject.klass <> nil then
    Result := Result + Format(
      ' class=%d class_dxf="%s" app="%s" cpp="%s" zombie=%d item_class_id=%d class_dwgver=%d class_maint=%d',
      [Integer(DWGObject.klass^.number),
       AnsiPtrText(PAnsiChar(DWGObject.klass^.dxfname)),
       AnsiPtrText(PAnsiChar(DWGObject.klass^.appname)),
       AnsiPtrText(PAnsiChar(DWGObject.klass^.cppname)),
       Integer(DWGObject.klass^.is_zombie),
       Integer(DWGObject.klass^.item_class_id),
       Integer(DWGObject.klass^.dwg_version),
       Integer(DWGObject.klass^.maint_version)]);
  if (DWGObject.supertype = DWG_SUPERTYPE_ENTITY)
    and (DWGObject.tio.entity <> nil) then begin
    Ent := DWGObject.tio.entity;
    Result := Result + Format(
      ' preview_exists=%d preview_is_proxy=%d preview_size=%s',
      [Integer(Ent^.preview_exists),
       Integer(Ent^.preview_is_proxy),
       IntToStr(Int64(Ent^.preview_size))]);
  end;
  Result := Result + Format(' unknown_bits=%d unknown_rest=%d',
    [Integer(DWGObject.num_unknown_bits), Integer(DWGObject.num_unknown_rest)]);
end;

function ProxyGraphicHeaderForLog(const Graphic: TBytes): string;
var
  ChunkSize, CommandCount: Cardinal;
begin
  if Length(Graphic) < 8 then
    Exit(' proxy_header_size=0 proxy_commands=0');

  Move(Graphic[0], ChunkSize, SizeOf(ChunkSize));
  Move(Graphic[4], CommandCount, SizeOf(CommandCount));
  Result := Format(' proxy_header_size=%d proxy_commands=%d',
    [ChunkSize, CommandCount]);
end;

procedure AddProxyEntityFromPayload(var ZContext: TZDrawingContext;
  var DWGContext: TDWGCtx; var DWGObject: Dwg_Object;
  const Payload: TDWGProxyEntityPayload; const SourceLabel: string);
var
  Handle: TDWGZCADHandle;
  Proxy: PGDBObjAcdProxy;
  Pobj: PGDBObjEntity;
  Stats: PDWGImportStats;
begin
  Handle := DWGObjectHandleValue(DWGObject);
  Stats := Stage7Stats;

  Proxy := AllocAndInitAcdProxy(nil);
  Proxy^.SetProxyGraphicData(Payload.Graphic,
    Payload.ProxyID, Payload.ClassID, Payload.EntityDataSize, 0,
    Payload.DWGVersions, Payload.FromDXF,
    DWGVersionToDXFFileVersion(DWGContext.DWGVer));
  Pobj := PGDBObjEntity(Proxy);
  ApplyCommonProps(Pobj, DWGObject);

  if Stats <> nil then
    Inc(Stats^.ProxiesLoaded);
  DWGLogInfoFormatStr(
    '%s handle=%s graphic_bytes=%d proxy_class=%s app_class=%s entity_data=%s drawing_format=%s original_format=%s%s dwgver=%s%s',
    [SourceLabel, DWGHandleLogText(Handle), Length(Payload.Graphic),
     IntToStr(Payload.ProxyID), IntToStr(Payload.ClassID),
     IntToStr(Payload.EntityDataSize), IntToStr(Payload.DWGVersions),
     IntToStr(Payload.FromDXF), ProxyGraphicHeaderForLog(Payload.Graphic),
     DWG_V2Str(DWGContext.DWGVer), DWGObjectProxyDiag(DWGObject)]);

  if GetLoadCtx <> nil then
    DWGRegisterEntityShell(Pobj, DWGObject, False, 0)
  else
    ZContext.PDrawing^.pObjRoot^.AddMi(PGDBObjSubordinated(Pobj));
end;

function TryAddPreviewProxyEntity(var ZContext: TZDrawingContext;
  var DWGContext: TDWGCtx; var DWGObject: Dwg_Object;
  const SourceLabel: string): Boolean;
var
  Payload: TDWGProxyEntityPayload;
begin
  Result := DWGCopyEntityPreviewProxyPayload(DWGObject, Payload);
  if Result then
    AddProxyEntityFromPayload(ZContext, DWGContext, DWGObject, Payload,
      SourceLabel);
end;

procedure AddProxyEntity(var ZContext: TZDrawingContext;
  var DWGContext: TDWGCtx; var DWGObject: Dwg_Object;
  PProxy: PDwg_Entity_PROXY_ENTITY);
var
  Handle: TDWGZCADHandle;
  Payload: TDWGProxyEntityPayload;
  Stats: PDWGImportStats;
  UsedPreview: Boolean;
  SourceLabel: string;
begin
  Handle := DWGObjectHandleValue(DWGObject);
  Stats := Stage7Stats;

  if PProxy = nil then begin
    if Stats <> nil then begin
      Inc(Stats^.ProxiesFailed);
      Inc(Stats^.DroppedDueToFreedRaw);
    end;
    DWGLogErrorFormatStr(
      'DWG PROXY_ENTITY missing LibreDWG payload handle=%s%s',
      [DWGHandleLogText(Handle), DWGObjectProxyDiag(DWGObject)]);
    Warn(wsError, DWG_WARN_PROXY_CORRUPT, Handle,
      Format('ACAD_PROXY_ENTITY %s has no LibreDWG proxy payload; skipped',
        [IntToHex(Handle, 1)]));
    MarkSkipped(Handle);
    Exit;
  end;

  DWGCopyProxyEntityPayloadOrPreview(PProxy, DWGObject, Payload, UsedPreview);
  if not Payload.HasGraphic then begin
    if Stats <> nil then
      Inc(Stats^.ProxiesFailed);
    if not DWGProxyEntityPayloadLooksSane(PProxy) then begin
      DWGLogWarningFormatStr(
        'DWG PROXY_ENTITY corrupt payload handle=%s proxy_class=%s app_class=%s from_dxf=%s declared_bytes=%s%s',
        [DWGHandleLogText(Handle), IntToStr(Payload.ProxyID),
         IntToStr(Payload.ClassID), IntToStr(Payload.FromDXF),
         IntToStr(PProxy^.proxy_data_size), DWGObjectProxyDiag(DWGObject)]);
      Warn(wsWarning, DWG_WARN_PROXY_CORRUPT, Handle,
        Format('ACAD_PROXY_ENTITY %s has corrupt proxy graphic metadata; skipped',
          [IntToHex(Handle, 1)]));
    end else begin
      DWGLogWarningFormatStr(
        'DWG PROXY_ENTITY no graphics handle=%s proxy_class=%s app_class=%s declared_bytes=%s%s',
        [DWGHandleLogText(Handle), IntToStr(Payload.ProxyID),
         IntToStr(Payload.ClassID), IntToStr(PProxy^.proxy_data_size),
         DWGObjectProxyDiag(DWGObject)]);
      Warn(wsWarning, DWG_WARN_PROXY_NO_GRAPHICS, Handle,
        Format('ACAD_PROXY_ENTITY %s has no proxy graphic bytes; skipped',
          [IntToHex(Handle, 1)]));
    end;
    MarkSkipped(Handle);
    Exit;
  end;

  if UsedPreview then
    SourceLabel := 'DWG PROXY_ENTITY proxy-preview'
  else
    SourceLabel := 'DWG PROXY_ENTITY';
  AddProxyEntityFromPayload(ZContext, DWGContext, DWGObject, Payload,
    SourceLabel);
end;

procedure AddProxyObject(var ZContext: TZDrawingContext;
  var DWGContext: TDWGCtx; var DWGObject: Dwg_Object; PObject: Pointer);
var
  Handle: TDWGZCADHandle;
  Stats: PDWGImportStats;
begin
  Handle := DWGObjectHandleValue(DWGObject);
  Stats := Stage7Stats;
  if Stats <> nil then begin
    Inc(Stats^.UnknownObjects);
    Inc(Stats^.ProxiesFailed);
  end;
  //DWGLogWarningFormatStr('DWG PROXY_OBJECT skipped handle=%s%s',
  //  [DWGHandleLogText(Handle), DWGObjectProxyDiag(DWGObject)]);
  Warn(wsInfo, DWG_WARN_PROXY_NO_GRAPHICS, Handle,
    Format('ACAD_PROXY_OBJECT %s is non-graphical; skipped',
      [IntToHex(Handle, 1)]));
  MarkSkipped(Handle);
end;

procedure AddUnknownEntity(var ZContext: TZDrawingContext;
  var DWGContext: TDWGCtx; var DWGObject: Dwg_Object; PEntity: Pointer);
var
  Handle: TDWGZCADHandle;
  Stats: PDWGImportStats;
begin
  Handle := DWGObjectHandleValue(DWGObject);
  Stats := Stage7Stats;
  if TryAddPreviewProxyEntity(ZContext, DWGContext, DWGObject,
    'DWG UNKNOWN_ENT proxy-preview') then
    Exit;
  if Stats <> nil then begin
    Inc(Stats^.UnknownEntities);
    Inc(Stats^.DroppedDueToFreedRaw);
  end;
  DWGLogWarningFormatStr('DWG UNKNOWN_ENT skipped handle=%s%s',
    [DWGHandleLogText(Handle), DWGObjectProxyDiag(DWGObject)]);
  Warn(wsWarning, DWG_WARN_UNKNOWN_ENTITY, Handle,
    Format('Unknown DWG entity type %d at handle %s has no stable copied fallback; skipped',
      [Ord(DWGObject.fixedtype), IntToHex(Handle, 1)]));
  MarkSkipped(Handle);
end;

procedure AddOpaqueEntityWithoutProxy(var ZContext: TZDrawingContext;
  var DWGContext: TDWGCtx; var DWGObject: Dwg_Object; PEntity: Pointer);
var
  Handle: TDWGZCADHandle;
  Stats: PDWGImportStats;
begin
  Handle := DWGObjectHandleValue(DWGObject);
  Stats := Stage7Stats;
  if TryAddPreviewProxyEntity(ZContext, DWGContext, DWGObject,
    'DWG OPAQUE_ENTITY proxy-preview') then
    Exit;
  if Stats <> nil then begin
    Inc(Stats^.UnknownEntities);
    Inc(Stats^.DroppedDueToFreedRaw);
  end;
  DWGLogWarningFormatStr('DWG OPAQUE_ENTITY skipped handle=%s%s',
    [DWGHandleLogText(Handle), DWGObjectProxyDiag(DWGObject)]);
  Warn(wsWarning, DWG_WARN_UNKNOWN_NO_COPY, Handle,
    Format('Unsupported opaque DWG entity type %d at handle %s has no proxy graphic fallback; skipped',
      [Ord(DWGObject.fixedtype), IntToHex(Handle, 1)]));
  MarkSkipped(Handle);
end;

procedure AddUnknownObject(var ZContext: TZDrawingContext;
  var DWGContext: TDWGCtx; var DWGObject: Dwg_Object; PObject: Pointer);
var
  Handle: TDWGZCADHandle;
  Stats: PDWGImportStats;
begin
  Handle := DWGObjectHandleValue(DWGObject);
  Stats := Stage7Stats;
  if Stats <> nil then begin
    Inc(Stats^.UnknownObjects);
    Inc(Stats^.DroppedDueToFreedRaw);
  end;
  //DWGLogWarningFormatStr('DWG UNKNOWN_OBJ skipped handle=%s%s',
  //  [DWGHandleLogText(Handle), DWGObjectProxyDiag(DWGObject)]);
  Warn(wsWarning, DWG_WARN_UNKNOWN_OBJECT, Handle,
    Format('Unknown DWG object type %d at handle %s has no ZCAD object fallback; skipped',
      [Ord(DWGObject.fixedtype), IntToHex(Handle, 1)]));
  MarkSkipped(Handle);
end;

initialization
  RegisterDWGEntityHandler(DWG_TYPE_PROXY_ENTITY, @AddProxyEntity);
  RegisterDWGObjectHandler(DWG_TYPE_PROXY_OBJECT, @AddProxyObject);
  RegisterDWGEntityHandler(DWG_TYPE_UNKNOWN_ENT, @AddUnknownEntity);
  RegisterDWGObjectHandler(DWG_TYPE_UNKNOWN_OBJ, @AddUnknownObject);
  RegisterDWGEntityHandler(DWG_TYPE__3DSOLID, @AddOpaqueEntityWithoutProxy);
  RegisterDWGEntityHandler(DWG_TYPE_REGION, @AddOpaqueEntityWithoutProxy);
  RegisterDWGEntityHandler(DWG_TYPE_BODY, @AddOpaqueEntityWithoutProxy);
end.
