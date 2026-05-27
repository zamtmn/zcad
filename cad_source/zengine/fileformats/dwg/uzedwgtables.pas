{*************************************************************************** }
{  fpdwg - DWG style table mappers (Stage 5.x R6)                            }
{                                                                            }
{        Copyright (C) 2026 Andrey Zubarev <zamtmn@yandex.ru>                }
{                                                                            }
{  This library is free software, licensed under the terms of the GNU        }
{  General Public License as published by the Free Software Foundation,      }
{  either version 3 of the License, or (at your option) any later version.   }
{*************************************************************************** }

{ Refactor R6 (per TZ_DWG_LOAD_TO_ZCAD_AUDIT §3.6 / TZ §6.5):
  LAYER, LTYPE, STYLE table mappers extracted from uzefflibredwg2ents.pas.
  Each registers itself through uzedwgentityregistry in the initialization
  section so the orchestration unit (uzefflibredwg.pas) does not need to
  know the individual handler names. Layer-LineType pending refs are
  enqueued here so the ResolveRefs pass can wire them once both shells
  exist (TZ §8.3). }

unit uzedwgtables;

{$Include zengineconfig.inc}
{$Mode delphi}{$H+}
{$ModeSwitch advancedrecords}

interface

uses
  SysUtils,
  dwg, dwgproc, uzedwghandle, uzedwgtext,
  uzedrawingsimple,
  uzestyleslayers, uzestyleslinetypes, uzestylestexts, uzestylesdim,
  uzeTypes,
  uzedwgloadcontext,
  uzedwgentityregistry,
  uzeffmanager,
  uzedwgtypes,
  uzedwgimport;

implementation

uses
  uzedwglog,
  uzedwgstylename;

type
  PDwg_Object_DIMSTYLE = ^Dwg_Object_DIMSTYLE;

function DWGResolveLinetypeTextStyle(Ctx: TDWGZCADLoadContext;
  StyleHandle: QWord): PGDBTextStyle;
var
  Entry: TDWGZCADHandleEntry;
begin
  Result := nil;
  if (Ctx <> nil) and (StyleHandle <> 0) and
     Ctx.TryGetEntry(StyleHandle, Entry) and (Entry.Kind = dokTextStyle) then
    Result := PGDBTextStyle(Entry.Ptr);
end;

procedure DWGResetLineTypePattern(PLType: PGDBLtypeProp;
  const Props: TDWGLinetypeProps);
begin
  if PLType = nil then
    Exit;
  PLType^.LengthDXF := Props.PatternLength;
  PLType^.desk := Props.Description;
  PLType^.FirstStroke := TODIUnknown;
  PLType^.LastStroke := TODIUnknown;
  PLType^.WithoutLines := True;
  PLType^.dasharray.Clear;
  PLType^.strokesarray.Clear;
  PLType^.shapearray.Clear;
  PLType^.Textarray.Clear;
end;

procedure DWGApplyLineTypeStroke(PLType: PGDBLtypeProp; Stroke: Double);
var
  DashInfo: TDashInfo;
begin
  DashInfo := TDIDash;
  PLType^.dasharray.PushBackData(DashInfo);
  PLType^.strokesarray.PushBackData(Stroke);
  PLType^.strokesarray.LengthFact :=
    PLType^.strokesarray.LengthFact + Abs(Stroke);
  if Stroke > 0 then begin
    PLType^.LastStroke := TODILine;
    PLType^.WithoutLines := False;
  end else if Stroke < 0 then
    PLType^.LastStroke := TODIBlank
  else
    PLType^.LastStroke := TODIPoint;
  if PLType^.FirstStroke = TODIUnknown then
    PLType^.FirstStroke := PLType^.LastStroke;
end;

procedure DWGApplyLineTypeDashParams(var Param: shxprop;
  const Dash: TDWGLinetypeDashProps);
begin
  if Dash.Scale <> 0 then
    Param.Height := Dash.Scale;
  Param.Angle := Dash.Rotation;
  Param.X := Dash.XOffset;
  Param.Y := Dash.YOffset;
  if Dash.AbsoluteRotation then
    Param.AD := TACAbs
  else
    Param.AD := TACRel;
end;

procedure DWGApplyLineTypeText(PLType: PGDBLtypeProp;
  const Dash: TDWGLinetypeDashProps; Ctx: TDWGZCADLoadContext);
var
  PTP: PTextProp;
  PStyle: PGDBTextStyle;
  DashInfo: TDashInfo;
begin
  PStyle := DWGResolveLinetypeTextStyle(Ctx, Dash.StyleHandle);
  if PStyle = nil then
    Exit;
  Pointer(PTP) := PLType^.Textarray.CreateObject;
  PTP^.initnul;
  PTP^.param.PStyle := PStyle;
  PTP^.param.PstyleIsHandle := False;
  DWGApplyLineTypeDashParams(PTP^.param, Dash);
  PTP^.Text := Dash.Text;
  PTP^.Style := PStyle^.Name;
  DashInfo := TDIText;
  PLType^.dasharray.PushBackData(DashInfo);
end;

procedure DWGApplyLineTypeShape(PLType: PGDBLtypeProp;
  const Dash: TDWGLinetypeDashProps; Ctx: TDWGZCADLoadContext);
var
  PSP: PShapeProp;
  PStyle: PGDBTextStyle;
  DashInfo: TDashInfo;
begin
  PStyle := DWGResolveLinetypeTextStyle(Ctx, Dash.StyleHandle);
  if PStyle = nil then
    Exit;
  Pointer(PSP) := PLType^.shapearray.CreateObject;
  PSP^.initnul;
  PSP^.param.PStyle := PStyle;
  PSP^.param.PstyleIsHandle := False;
  DWGApplyLineTypeDashParams(PSP^.param, Dash);
  PSP^.ShapeNum := Dash.ShapeCode;
  PSP^.FontName := PStyle^.FontFile;
  if Assigned(PStyle^.pfont) then begin
    PSP^.Psymbol := PStyle^.pfont^.GetOrReplaceSymbolInfo(Dash.ShapeCode);
    if PSP^.Psymbol <> nil then
      PSP^.SymbolName := PSP^.Psymbol^.Name;
  end;
  DashInfo := TDIShape;
  PLType^.dasharray.PushBackData(DashInfo);
end;

procedure DWGApplyLineTypePattern(PLType: PGDBLtypeProp;
  const Props: TDWGLinetypeProps; Ctx: TDWGZCADLoadContext);
var
  I: Integer;
begin
  if PLType = nil then
    Exit;
  DWGResetLineTypePattern(PLType, Props);
  for I := 0 to High(Props.Dashes) do begin
    DWGApplyLineTypeStroke(PLType, Props.Dashes[I].Length);
    case Props.Dashes[I].Kind of
      dldText:
        DWGApplyLineTypeText(PLType, Props.Dashes[I], Ctx);
      dldShape:
        DWGApplyLineTypeShape(PLType, Props.Dashes[I], Ctx);
      dldDash:
        begin
        end;
    end;
  end;
  if (PLType^.LengthDXF = 0) and (PLType^.strokesarray.LengthFact <> 0) then
    PLType^.LengthDXF := PLType^.strokesarray.LengthFact;
end;

procedure AddLayer(var ZContext: TZDrawingContext; var DWGContext: TDWGCtx;
  var DWGObject: Dwg_Object; PDWGLayer: PDwg_Object_LAYER);
var
  player: PGDBLayerProp;
  name: string;
  LayerProps: TDWGLayerVisualProps;
  Handle: QWord;
  LtCandidates: TDWGRefHandleCandidates;
  ContinuousLT: PGDBLtypeProp;
  Ctx: TDWGZCADLoadContext;
begin
  BITCODE_T2Text(PDWGLayer^.name, DWGContext, name);
  DWGLogInfoFormatStr('Layer: %s', [name]);
  name := DWGDecodedTextForZCAD(name);
  player := ZContext.PDrawing^.LayerTable.MergeItem(name, ZContext.LoadMode);
  if player <> nil then begin
    player^.init(name);
    DWGLayerVisualPropsValue(PDWGLayer, LayerProps);
    player^.color := LayerProps.ColorIndex;
    player^.lineweight := LayerProps.LineWeight;
    player^._on := LayerProps.On;
    player^._lock := LayerProps.Locked;
    player^._print := LayerProps.Plot;
    DWGLogInfoFormatStr(
      'layer %s visual color=%d, lineweight=%d, on=%s, raw_off=%s, locked=%s, plot=%s, color.index=%s, color.raw=%s, color.rgb=$%s, color.method=%s($%s), color.flag=%s',
      [name, player^.color, player^.lineweight,
       BoolToStr(player^._on, True), BoolToStr(PDWGLayer^.off <> 0, True),
       BoolToStr(player^._lock, True), BoolToStr(player^._print, True),
       IntToStr(PDWGLayer^.color.index), IntToStr(PDWGLayer^.color.raw),
       IntToHex(PDWGLayer^.color.rgb, 8),
       DWGColorMethodToText(PDWGLayer^.color.method),
       IntToHex(Ord(PDWGLayer^.color.method), 2),
       IntToStr(PDWGLayer^.color.flag)]);
    if DWGColorLooksLikeLostACI(PDWGLayer^.color) then
      DWGLogWarningFormatStr(
        'layer %s color diagnostic: LibreDWG reported ACI white without raw index; original DWG layer ACI may be unavailable after RGB normalization',
        [name]);
    //desk:AnsiString;
  end;
  Ctx := GetLoadCtx;
  if Ctx <> nil then begin
    Handle := DWGObjectHandleValue(DWGObject);
    if Handle <> 0 then
      Ctx.RegisterShell(Handle, dokLayer, player, -1);
    // Stage 3 (TZ §8.3): defer the layer.LT assignment until all LTYPE shells
    // have been registered. Issue #1122: this uses a layer-specific ref slot
    // because the target pointer is PGDBLayerProp, not PGDBObjEntity.
    if (player <> nil) and (Handle <> 0) then begin
      if not DWGLayerLineTypeHandleCandidatesValue(PDWGLayer,
        LtCandidates) then
        FillChar(LtCandidates, SizeOf(LtCandidates), 0);
      ContinuousLT := PGDBLtypeProp(ZContext.PDrawing^.LTypeStyleTable.getAddres(
        'Continuous'));
      if ContinuousLT = nil then
        ContinuousLT := ZContext.PDrawing^.LTypeStyleTable.GetSystemLT(
          TLTContinous);
      Ctx.QueueRefResolveCandidates(player, Handle, LtCandidates.Values,
        LtCandidates.Count, dokLineType, rsLayerLineType, ContinuousLT);
    end;
  end;
end;

procedure AddLineType(var ZContext: TZDrawingContext; var DWGContext: TDWGCtx;
  var DWGObject: Dwg_Object; PDWGLType: PDwg_Object_LTYPE);
var
  pltype: PGDBLtypeProp;
  Props: TDWGLinetypeProps;
  name: string;
  I: Integer;
  Handle: QWord;
  Ctx: TDWGZCADLoadContext;
begin
  if not DWGLinetypePropsValue(PDWGLType, DWGContext.DWGVer,
    DWGContext.DWGCodePage, Props) then
    Exit;
  name := Props.Name;
  DWGLogInfoFormatStr('LineType: %s', [name]);
  name := DWGDecodedTextForZCAD(name);
  Props.Description := DWGDecodedTextForZCAD(Props.Description);
  for I := 0 to High(Props.Dashes) do
    Props.Dashes[I].Text := DWGDecodedTextForZCAD(Props.Dashes[I].Text);
  // Stage 3 (TZ §12.3): create the linetype in the table so refs can resolve
  // to a real pointer. We mirror the DXF loader semantics — a name collision
  // with a previously-loaded entry is left alone (TLOMerge respected).
  pltype := PGDBLtypeProp(ZContext.PDrawing^.LTypeStyleTable.MergeItem(name,
    ZContext.LoadMode));
  Ctx := GetLoadCtx;
  if pltype <> nil then begin
    if pltype^.Name = '' then
      pltype^.init(name);
    DWGApplyLineTypePattern(pltype, Props, Ctx);
    DWGLogInfoFormatStr('linetype %s pattern_len=%s, dashes=%d',
      [name, FloatToStr(pltype^.LengthDXF), Length(Props.Dashes)]);
  end;
  if Ctx <> nil then begin
    Handle := DWGObjectHandleValue(DWGObject);
    if Handle <> 0 then
      Ctx.RegisterShell(Handle, dokLineType, pltype, -1);
  end;
end;

procedure AddTextStyle(var ZContext: TZDrawingContext; var DWGContext: TDWGCtx;
  var DWGObject: Dwg_Object; PDWGStyle: PDwg_Object_STYLE);
var
  pstyle: PGDBTextStyle;
  Props: TDWGTextStyleProps;
  TextProp: GDBTextStyleProp;
  name, BaseName, StyleName, FontFile, FontFamily: string;
  Handle: QWord;
  Ctx: TDWGZCADLoadContext;
  UsedInLType: Boolean;
  WasRenamed: Boolean;
begin
  if not DWGTextStylePropsValue(PDWGStyle, DWGContext.DWGVer,
    DWGContext.DWGCodePage, Props) then
    Exit;
  name := Props.Name;
  DWGLogInfoFormatStr('TextStyle: %s', [name]);
  FontFile := Props.FontFile;
  FontFamily := '';
  name := DWGDecodedTextForZCAD(name);
  FontFile := DWGDecodedTextForZCAD(FontFile);
  UsedInLType := Props.IsShape;
  Handle := DWGObjectHandleValue(DWGObject);
  // P6: pick the base name first (without forcing 'Standard' when the decode
  // produced no usable string — fall back to handle-derived 'dwg_<hex>').
  BaseName := DWGTextStyleBaseName(name, FontFile, UsedInLType, Handle);
  StyleName := BaseName;
  // Track whether we ended up substituting a synthetic name so the warning
  // logged below carries useful context (caller may have asked for "Standard"
  // and got a different name, or had a real name that collided).
  WasRenamed := (name = '') and (not (UsedInLType and (FontFile <> '')))
                and (Handle <> 0);

  TextProp.size := Props.TextSize;
  TextProp.wfactor := Props.WidthFactor;
  TextProp.oblique := Props.ObliqueAngle;

  Ctx := GetLoadCtx;
  pstyle := ZContext.PDrawing^.TextStyleTable.FindStyle(StyleName,
    UsedInLType);
  // P6: if the name we picked already exists and its pstyle is owned by a
  // different DWG handle, the legacy code would either reuse it (and let
  // the next RegisterShell fail with DWG_WARN_DUPLICATE_HANDLE — issue
  // #1198 §4.4) or, in TLOLoad mode, overwrite the other handle's props in
  // place. Both behaviours lose information. We instead bump the name to
  // '<base>_dwg<hex>' so the second handle gets its own pstyle.
  if (pstyle <> nil) and (Handle <> 0) and
     DWGTextStylePtrOwnedByAnotherHandle(Ctx, pstyle, Handle) then begin
    StyleName := DWGTextStyleUniquifyName(BaseName, Handle);
    WasRenamed := True;
    pstyle := ZContext.PDrawing^.TextStyleTable.FindStyle(StyleName,
      UsedInLType);
  end;

  if pstyle <> nil then begin
    if ZContext.LoadMode = TLOLoad then
      pstyle := ZContext.PDrawing^.TextStyleTable.setstyle(StyleName,
        FontFile, FontFamily, TextProp, UsedInLType);
  end else
    pstyle := ZContext.PDrawing^.TextStyleTable.addstyle(StyleName,
      FontFile, FontFamily, TextProp, UsedInLType);

  if Ctx <> nil then begin
    if Handle <> 0 then
      Ctx.RegisterShell(Handle, dokTextStyle, pstyle, -1);
    if WasRenamed then
      Ctx.RaiseWarning(wsWarning, DWG_WARN_TEXTSTYLE_RENAMED, Handle,
        'textstyle renamed: "' + name + '" -> "' + StyleName + '"');
    if (pstyle <> nil) and (not UsedInLType) and
       ((Ctx.FallbackTextStyle = nil) or
        (CompareText(StyleName, 'Standard') = 0)) then
      Ctx.SetFallbackTextStyle(pstyle);
  end;
  if (pstyle <> nil) and (not UsedInLType) and
     (ZContext.PDrawing^.CurrentTextStyle = nil) then
    ZContext.PDrawing^.CurrentTextStyle := pstyle;
end;

procedure ApplyDimStyleScalars(PDimStyle: PGDBDimStyle;
  PDWGDimStyle: PDwg_Object_DIMSTYLE);
begin
  if (PDimStyle = nil) or (PDWGDimStyle = nil) then
    Exit;
  if PDWGDimStyle^.DIMEXE <> 0 then
    PDimStyle^.Lines.DIMEXE := PDWGDimStyle^.DIMEXE;
  if PDWGDimStyle^.DIMEXO <> 0 then
    PDimStyle^.Lines.DIMEXO := PDWGDimStyle^.DIMEXO;
  if PDWGDimStyle^.DIMDLE <> 0 then
    PDimStyle^.Lines.DIMDLE := PDWGDimStyle^.DIMDLE;
  if PDWGDimStyle^.DIMCEN <> 0 then
    PDimStyle^.Lines.DIMCEN := PDWGDimStyle^.DIMCEN;
  if PDWGDimStyle^.DIMLWD <> 0 then
    PDimStyle^.Lines.DIMLWD := PDWGDimStyle^.DIMLWD;
  if PDWGDimStyle^.DIMLWE <> 0 then
    PDimStyle^.Lines.DIMLWE := PDWGDimStyle^.DIMLWE;
  if PDWGDimStyle^.DIMCLRD_N <> 0 then
    PDimStyle^.Lines.DIMCLRD := PDWGDimStyle^.DIMCLRD_N;
  if PDWGDimStyle^.DIMCLRE_N <> 0 then
    PDimStyle^.Lines.DIMCLRE := PDWGDimStyle^.DIMCLRE_N;

  if PDWGDimStyle^.DIMSCALE <> 0 then
    PDimStyle^.Units.DIMSCALE := PDWGDimStyle^.DIMSCALE;
  if PDWGDimStyle^.DIMLFAC <> 0 then
    PDimStyle^.Units.DIMLFAC := PDWGDimStyle^.DIMLFAC;
  if PDWGDimStyle^.DIMRND <> 0 then
    PDimStyle^.Units.DIMRND := PDWGDimStyle^.DIMRND;
  if PDWGDimStyle^.DIMDEC <> 0 then
    PDimStyle^.Units.DIMDEC := PDWGDimStyle^.DIMDEC;
  if PDWGDimStyle^.DIMZIN <> 0 then
    PDimStyle^.Units.DIMZIN := PDWGDimStyle^.DIMZIN;

  if PDWGDimStyle^.DIMASZ <> 0 then
    PDimStyle^.Arrows.DIMASZ := PDWGDimStyle^.DIMASZ;

  if PDWGDimStyle^.DIMTXT <> 0 then
    PDimStyle^.Text.DIMTXT := PDWGDimStyle^.DIMTXT;
  if PDWGDimStyle^.DIMGAP <> 0 then
    PDimStyle^.Text.DIMGAP := PDWGDimStyle^.DIMGAP;
  if PDWGDimStyle^.DIMCLRT_N <> 0 then
    PDimStyle^.Text.DIMCLRT := PDWGDimStyle^.DIMCLRT_N;
  PDimStyle^.Text.DIMTIH := PDWGDimStyle^.DIMTIH <> 0;
  PDimStyle^.Text.DIMTOH := PDWGDimStyle^.DIMTOH <> 0;
end;

procedure AddDimStyle(var ZContext: TZDrawingContext; var DWGContext: TDWGCtx;
  var DWGObject: Dwg_Object; PDWGDimStyle: PDwg_Object_DIMSTYLE);
var
  PDimStyle: PGDBDimStyle;
  Name: string;
  Handle: QWord;
  TextStyleCandidates: TDWGRefHandleCandidates;
  FallbackTextStyle: PGDBTextStyle;
  Ctx: TDWGZCADLoadContext;
begin
  BITCODE_T2Text(PDWGDimStyle^.name, DWGContext, Name);
  Name := DWGDecodedTextForZCAD(Name);
  if Name = '' then
    Name := 'Standard';
  DWGLogInfoFormatStr('DimStyle: %s', [Name]);

  PDimStyle := PGDBDimStyle(ZContext.PDrawing^.DimStyleTable.getAddres(Name));
  if PDimStyle = nil then begin
    PDimStyle := PGDBDimStyle(ZContext.PDrawing^.DimStyleTable.MergeItem(Name,
      ZContext.LoadMode));
    if PDimStyle <> nil then begin
      PDimStyle^.init(Name);
      PDimStyle^.SetDefaultValues;
    end;
  end;
  if PDimStyle = nil then
    PDimStyle := DWGEnsureDimStyle(ZContext.PDrawing^);
  ApplyDimStyleScalars(PDimStyle, PDWGDimStyle);
  FallbackTextStyle := nil;
  if PDimStyle <> nil then begin
    if PDimStyle^.Text.DIMTXSTY = nil then
      PDimStyle^.Text.DIMTXSTY := ZContext.PDrawing^.TextStyleTable.FindStyle(
        'Standard', False);
    FallbackTextStyle := PDimStyle^.Text.DIMTXSTY;
  end;
  if (PDimStyle <> nil) and (ZContext.PDrawing^.CurrentDimStyle = nil) then
    ZContext.PDrawing^.CurrentDimStyle := PDimStyle;

  Ctx := GetLoadCtx;
  if Ctx <> nil then begin
    Handle := DWGObjectHandleValue(DWGObject);
    if Handle <> 0 then begin
      Ctx.RegisterShell(Handle, dokDimStyle, PDimStyle, -1);
      if (PDimStyle <> nil) and
         DWGRefHandleCandidatesValue(PDWGDimStyle^.DIMTXSTY,
           TextStyleCandidates) then
        Ctx.QueueRefResolveCandidates(PDimStyle, Handle,
          TextStyleCandidates.Values, TextStyleCandidates.Count, dokTextStyle,
          rsDimStyleTextStyle, FallbackTextStyle);
    end;
  end;
end;

procedure AddVPort(var ZContext: TZDrawingContext; var DWGContext: TDWGCtx;
  var DWGObject: Dwg_Object; PDWGVPort: PDwg_Object_VPORT);
var
  Name: string;
  Props: TDWGViewProps;
begin
  if PDWGVPort = nil then
    Exit;
  BITCODE_T2Text(PDWGVPort^.name, DWGContext, Name);
  Name := DWGDecodedTextForZCAD(Name);
  DWGLogInfoFormatStr('VPort: %s', [Name]);
  if CompareText(Name, '*ACTIVE') <> 0 then
    Exit;

  if DWGVPortViewPropsValue(PDWGVPort, Props) then
    DWGCaptureActiveVPortView(Props)
  else
    DWGLogWarningFormatStr('DWG active VPORT has no usable view size', []);
end;

initialization
  RegisterDWGObjectHandler(DWG_TYPE_LAYER, @AddLayer);
  RegisterDWGObjectHandler(DWG_TYPE_LTYPE, @AddLineType);
  RegisterDWGObjectHandler(DWG_TYPE_STYLE, @AddTextStyle);
  RegisterDWGObjectHandler(DWG_TYPE_DIMSTYLE, @AddDimStyle);
  RegisterDWGObjectHandler(DWG_TYPE_VPORT, @AddVPort);
end.
