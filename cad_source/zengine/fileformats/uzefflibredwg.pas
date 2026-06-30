{
*****************************************************************************
*                                                                           *
*  This file is part of the ZCAD                                            *
*                                                                           *
*  See the file GPL-3.0.txt, included in this distribution,                 *
*  for details about the copyright.                                         *
*                                                                           *
*  This program is distributed in the hope that it will be useful,          *
*  but WITHOUT ANY WARRANTY; without even the implied warranty of           *
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                     *
*                                                                           *
*****************************************************************************
}
{
@author(Andrey Zubarev <zamtmn@yandex.ru>)
}

unit uzeffLibreDWG;
{$Include zengineconfig.inc}
{$Mode objfpc}{$H+}
{$ModeSwitch advancedrecords}
interface
uses
  SysUtils,
  dwg,dwgproc,
  uzeffmanager,
  uzelongprocesssupport,{uzgldrawcontext,}forms,
  uzcstrconsts,uzeLogIntf,
  uzedrawingsimple,
  uzedwgentityregistry,
  uzedwgimport,
  LazUTF8;

// Re-exported alias kept for callers that referenced the type previously
// defined in this unit (the actual definition now lives in
// uzedwgentityregistry.pas — see TZ_DWG_LOAD_TO_ZCAD_AUDIT R5).
type
  TZCADDWGParser = uzedwgentityregistry.TZCADDWGParser;

procedure addfromdwg(const filename:String;var ZCDCtx:TZDrawingContext;const LogProc:TZELogProc=nil);
procedure addfromdxf(const filename:String;var ZCDCtx:TZDrawingContext;const LogProc:TZELogProc=nil);

implementation

uses
  uzeffLibreDWG2Ents,
  uzedwglog,
  uzedwgtimerlog,
  uzeTypes;

procedure DebugDWG(dwg:PDwg_Data);
begin
  DWGLogInfoFormatStr('header.version: %s',
    [DWG_V2Str(dwg^.header.version)]);
  DWGLogInfoFormatStr('header.from_version: %s',
    [DWG_V2Str(dwg^.header.from_version)]);
  DWGLogInfoFormatStr('header.is_maint: %s',
    [IntToStr(dwg^.header.is_maint)]);
  DWGLogInfoFormatStr('header.zero_one_or_three: %s',
    [IntToStr(dwg^.header.zero_one_or_three)]);
  DWGLogInfoFormatStr('header.numheader_vars: %s',
    [IntToStr(dwg^.header.numheader_vars)]);
  DWGLogInfoFormatStr('header.thumbnail_address: %s',
    [IntToStr(dwg^.header.thumbnail_address)]);
  DWGLogInfoFormatStr('header.dwg_version: %s',
    [IntToStr(dwg^.header.dwg_version)]);
  DWGLogInfoFormatStr('header.maint_version: %s',
    [IntToStr(dwg^.header.maint_version)]);
  DWGLogInfoFormatStr('header.codepage: %s',
    [IntToStr(dwg^.header.codepage)]);
  DWGLogInfoFormatStr(
    'dwg.counts: classes=%d, objects=%d, alloced_objects=%d, entities=%d, object_refs=%d',
    [Integer(dwg^.num_classes), Integer(dwg^.num_objects),
     Integer(dwg^.num_alloced_objects), Integer(dwg^.num_entities),
     Integer(dwg^.num_object_refs)]);
end;

procedure PLP(const Data:TData;const Counter:TCounter);
begin
 lps.ProgressLongProcess(TLPSHandle(Data),Counter);
end;

procedure DWGTimerLogDone(var Timer: TTimeMeter; const Phase, Detail: String);
begin
  Timer.EndMeasure;
  DWGTimerLogTiming(Phase, Timer.ElapsedMiliSec, Detail);
end;

procedure addfromdwg(const filename:String;var ZCDCtx:TZDrawingContext;const LogProc:TZELogProc=nil);
var
  dwg:Dwg_Data;
  Success:integer;
  ObjectsRead: Integer;
  lph:TLPSHandle;
  Loaded:Boolean;
  TotalTimer, PhaseTimer: TTimeMeter;
begin
  TotalTimer := TTimeMeter.StartMeasure;
  dwg:=default(Dwg_Data);
  dwg.opts:=0;
  Success:=0;
  ObjectsRead:=0;
  Loaded:=False;
  try
    DWGLogInfoFormatStr('%s', [rsNotYetImplemented]);
    PhaseTimer := TTimeMeter.StartMeasure;
    try
      try
        LoadLibreDWG;
      except
        on E : Exception do begin
          DWGLogErrorFormatStr('LibreDWG: %s', [E.Message]);
          exit;
        end;
      end;
    finally
      DWGTimerLogDone(PhaseTimer, 'addfromdwg.load-libredwg',
        Format('filename="%s"', [filename]));
    end;

    DWGLogInfoFormatStr('try load file: %s', [filename]);
    PhaseTimer := TTimeMeter.StartMeasure;
    lph:=LPSHEmpty;
    lph:=lps.StartLongProcess('LibreDWG.dwg_read_file',nil);
    try
      {$IFDEF WINDOWS}
      Success:=dwg_read_file(pchar(UTF8ToWinCP(filename)),@dwg);
      {$ELSE WINDOWS}
      Success:=dwg_read_file(pchar(ansistring(filename)),@dwg);
      {$ENDIF}
      ObjectsRead:=Integer(dwg.num_objects);
      Loaded:=True;
    finally
      if lph<>LPSHEmpty then
        lps.EndLongProcess(lph);
      DWGTimerLogDone(PhaseTimer, 'addfromdwg.read-file',
        Format('filename="%s" loaded=%s code=%d objects=%d',
          [filename, BoolToStr(Loaded, True), Success, ObjectsRead]));
    end;
    DWGLogInfoFormatStr('LibreDWG read code: %d (%s)',
      [Success, DWGReadCodeToText(Success)]);
    DebugDWG(@dwg);
    if DWGReadCodeIsCritical(Success) then begin
      DWGLogErrorFormatStr(
        'LibreDWG: critical read error code %d (%s), aborting parse',
        [Success, DWGReadCodeToText(Success)]);
      exit;
    end;
    PhaseTimer := TTimeMeter.StartMeasure;
    lph:=LPSHEmpty;
    lph:=lps.StartLongProcess('Parse DWG data',nil,dwg.num_objects);
    try
      // Stage 2 (TZ §12.2): wrap parseDwg_Data with the load context so the
      // LINE handler can register shells + pending owners and the resolver
      // attaches everything in dependency order after parseDwg_Data returns.
      // R4 (TZ §3.4): ScanDWGImport runs the Phase 1 raw scan between Begin
      // and parseDwg_Data so duplicate-handle detection and raw-index capture
      // happen once, before any mapper allocation.
      // Issue #1198 P3: forward the source path so EndDWGImport can emit
      // diagnostic side-files next to the DWG when DWG_DIAG_MODE enables them.
      BeginDWGImport(ZCDCtx, filename);
      try
        ScanDWGImport(dwg);
        GetDWGParser.parseDwg_Data(ZCDCtx,dwg,@PLP,TData(lph));
      finally
        EndDWGImport(ZCDCtx);
      end;
    finally
      if lph<>LPSHEmpty then
        lps.EndLongProcess(lph);
      DWGTimerLogDone(PhaseTimer, 'addfromdwg.parse-data',
        Format('filename="%s" objects=%d',
          [filename, ObjectsRead]));
    end;
  finally
    if Loaded and Assigned(dwg_free) then begin
      PhaseTimer := TTimeMeter.StartMeasure;
      try
        dwg_free(@dwg);
      finally
        DWGTimerLogDone(PhaseTimer, 'addfromdwg.free-data',
          Format('filename="%s" objects=%d',
            [filename, ObjectsRead]));
      end;
    end;
    DWGTimerLogDone(TotalTimer, 'addfromdwg.total',
      Format('filename="%s" loaded=%s code=%d objects=%d',
        [filename, BoolToStr(Loaded, True), Success, ObjectsRead]));
  end;
end;
procedure addfromdxf(const filename:String;var ZCDCtx:TZDrawingContext;const LogProc:TZELogProc=nil);
var
  dwg:Dwg_Data;
  Success:integer;
  ObjectsRead: Integer;
  lph:TLPSHandle;
  Loaded:Boolean;
  TotalTimer, PhaseTimer: TTimeMeter;
begin
  TotalTimer := TTimeMeter.StartMeasure;
  dwg:=default(Dwg_Data);
  dwg.opts:=0;
  Success:=0;
  ObjectsRead:=0;
  Loaded:=False;
  try
    DWGLogInfoFormatStr('%s', [rsNotYetImplemented]);
    PhaseTimer := TTimeMeter.StartMeasure;
    try
      try
        LoadLibreDWG;
      except
        on E : Exception do begin
          DWGLogErrorFormatStr('LibreDWG: %s', [E.Message]);
          exit;
        end;
      end;
    finally
      DWGTimerLogDone(PhaseTimer, 'addfromdxf.load-libredwg',
        Format('filename="%s"', [filename]));
    end;

    DWGLogInfoFormatStr('try load file: %s', [filename]);
    PhaseTimer := TTimeMeter.StartMeasure;
    lph:=LPSHEmpty;
    lph:=lps.StartLongProcess('LibreDWG.dxf_read_file',nil);
    try
      Success:=dxf_read_file(pchar(ansistring(filename)),@dwg);
      ObjectsRead:=Integer(dwg.num_objects);
      Loaded:=True;
    finally
      if lph<>LPSHEmpty then
        lps.EndLongProcess(lph);
      DWGTimerLogDone(PhaseTimer, 'addfromdxf.read-file',
        Format('filename="%s" loaded=%s code=%d objects=%d',
          [filename, BoolToStr(Loaded, True), Success, ObjectsRead]));
    end;
    DWGLogInfoFormatStr('LibreDWG read code: %d (%s)',
      [Success, DWGReadCodeToText(Success)]);
    DebugDWG(@dwg);
    if DWGReadCodeIsCritical(Success) then begin
      DWGLogErrorFormatStr(
        'LibreDWG: critical dxf read error code %d (%s), aborting parse',
        [Success, DWGReadCodeToText(Success)]);
      exit;
    end;
    PhaseTimer := TTimeMeter.StartMeasure;
    lph:=LPSHEmpty;
    lph:=lps.StartLongProcess('Parse DWG data',nil,dwg.num_objects);
    try
      // Issue #1198 P3: forward the source path so EndDWGImport can emit
      // diagnostic side-files next to the DXF when DWG_DIAG_MODE enables them.
      BeginDWGImport(ZCDCtx, filename);
      try
        ScanDWGImport(dwg);
        GetDWGParser.parseDwg_Data(ZCDCtx,dwg,@PLP,TData(lph));
      finally
        EndDWGImport(ZCDCtx);
      end;
    finally
      if lph<>LPSHEmpty then
        lps.EndLongProcess(lph);
      DWGTimerLogDone(PhaseTimer, 'addfromdxf.parse-data',
        Format('filename="%s" objects=%d',
          [filename, ObjectsRead]));
    end;
  finally
    if Loaded and Assigned(dwg_free) then begin
      PhaseTimer := TTimeMeter.StartMeasure;
      try
        dwg_free(@dwg);
      finally
        DWGTimerLogDone(PhaseTimer, 'addfromdxf.free-data',
          Format('filename="%s" objects=%d',
            [filename, ObjectsRead]));
      end;
    end;
    DWGTimerLogDone(TotalTimer, 'addfromdxf.total',
      Format('filename="%s" loaded=%s code=%d objects=%d',
        [filename, BoolToStr(Loaded, True), Success, ObjectsRead]));
  end;
end;

end.
