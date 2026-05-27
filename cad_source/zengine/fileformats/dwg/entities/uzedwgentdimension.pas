{*************************************************************************** }
{  fpdwg - DWG DIMENSION entity mapper (Stage 6)                            }
{                                                                            }
{        Copyright (C) 2026 Andrey Zubarev <zamtmn@yandex.ru>                }
{                                                                            }
{  This library is free software, licensed under the terms of the GNU        }
{  General Public License as published by the Free Software Foundation,      }
{  either version 3 of the License, or (at your option) any later version.   }
{*************************************************************************** }

unit uzedwgentdimension;

{$Include zengineconfig.inc}
{$Mode delphi}{$H+}
{$ModeSwitch advancedrecords}

interface

uses
  Math, SysUtils,
  dwg, dwgproc, uzedwghandle, uzedwgtext,
  uzedrawingsimple,
  uzegeometry, uzegeometrytypes,
  uzeentityfactory,
  uzeentdimensiongeneric, uzeentdimension, uzeentity,
  uzeentsubordinated,
  uzeconsts,
  uzedwgloadcontext,
  uzedwgentityregistry,
  uzeffmanager,
  uzedwgtypes,
  uzedwgimport;

implementation

type
  PDwg_DIMENSION_common = ^Dwg_DIMENSION_common;
  PDwg_Entity_DIMENSION_ORDINATE = ^Dwg_Entity_DIMENSION_ORDINATE;
  PDwg_Entity_DIMENSION_LINEAR = ^Dwg_Entity_DIMENSION_LINEAR;
  PDwg_Entity_DIMENSION_ALIGNED = ^Dwg_Entity_DIMENSION_ALIGNED;
  PDwg_Entity_DIMENSION_ANG3PT = ^Dwg_Entity_DIMENSION_ANG3PT;
  PDwg_Entity_DIMENSION_ANG2LN = ^Dwg_Entity_DIMENSION_ANG2LN;
  PDwg_Entity_DIMENSION_RADIUS = ^Dwg_Entity_DIMENSION_RADIUS;
  PDwg_Entity_DIMENSION_DIAMETER = ^Dwg_Entity_DIMENSION_DIAMETER;

function Point3BD(const P: BITCODE_3BD): TzePoint3d;
begin
  Result := createvertex(P.x, P.y, P.z);
end;

function Point3RD(const P: BITCODE_3RD): TzePoint3d;
begin
  Result := createvertex(P.x, P.y, P.z);
end;

function Point2DAtElevation(const P: BITCODE_2RD; Elevation: Double
  ): TzePoint3d;
begin
  Result := createvertex(P.x, P.y, Elevation);
end;

procedure ApplyCommonDimension(PObj: PGDBObjGenericDimension;
  PCommon: PDwg_DIMENSION_common);
begin
  if (PObj = nil) or (PCommon = nil) then
    Exit;

  PObj^.DimData.P10InWCS := Point3BD(PCommon^.def_pt);
  PObj^.DimData.P11InOCS := Point2DAtElevation(PCommon^.text_midpt,
    PCommon^.elevation);
  PObj^.DimData.TextMoved := ((PCommon^.flag and 128) <> 0) or
    ((PCommon^.flag1 and 128) <> 0);
  PObj^.a50 := RadToDeg(PCommon^.horiz_dir);
end;

function NewGenericDimension(var ZContext: TZDrawingContext;
  DimType: TDimType; PCommon: PDwg_DIMENSION_common): PGDBObjGenericDimension;
begin
  Result := PGDBObjGenericDimension(CreateInitObjFree(
    GDBGenericDimensionID, nil));
  if Result = nil then
    Exit;
  Result^.PDimStyle := DWGEnsureDimStyle(ZContext.PDrawing^);
  Result^.DimType := DimType;
  ApplyCommonDimension(Result, PCommon);
end;

function ConvertGenericDimension(PObj: PGDBObjGenericDimension;
  var ZContext: TZDrawingContext): PGDBObjEntity;
var
  PostObj: PGDBObjSubordinated;
begin
  Result := nil;
  if PObj = nil then
    Exit;
  PostObj := PObj^.FromDXFPostProcessBeforeAdd(nil, ZContext.PDrawing^);
  if PostObj <> nil then
    Result := PGDBObjEntity(PostObj)
  else
    Result := PGDBObjEntity(PObj);
end;

procedure ApplyDimensionUserText(PObj: PGDBObjEntity;
  PCommon: PDwg_DIMENSION_common; var DWGContext: TDWGCtx);
var
  Value: string;
begin
  if (PObj = nil) or (PCommon = nil) then
    Exit;
  case PObj^.GetObjType of
    GDBAlignedDimensionID,
    GDBRotatedDimensionID,
    GDBDiametricDimensionID,
    GDBRadialDimensionID:
      ;
  else
    Exit;
  end;
  DWGSafeDecodeText(PCommon^.user_text, DWGContext.DWGVer,
    DWGContext.DWGCodePage, Value);
  if Value <> '' then
    PGDBObjDimension(PObj)^.dimtext := DWGDecodedTextToZCADString(Value);
end;

procedure RegisterDimensionShell(PObj: PGDBObjEntity;
  var ZContext: TZDrawingContext; var DWGObject: Dwg_Object;
  PCommon: PDwg_DIMENSION_common);
var
  Ctx: TDWGZCADLoadContext;
  EntityHandle: QWord;
  DimStyleCandidates, BlockCandidates: TDWGRefHandleCandidates;
begin
  if (PObj = nil) or (PCommon = nil) then
    Exit;
  if GetLoadCtx <> nil then begin
    DWGRegisterEntityShell(PObj, DWGObject, False, 0);
    Ctx := GetLoadCtx;
    EntityHandle := DWGObjectHandleValue(DWGObject);
    if not DWGRefHandleCandidatesValue(PCommon^.dimstyle,
      DimStyleCandidates) then
      FillChar(DimStyleCandidates, SizeOf(DimStyleCandidates), 0);
    if not DWGRefHandleCandidatesValue(PCommon^.block, BlockCandidates) then
      FillChar(BlockCandidates, SizeOf(BlockCandidates), 0);
    Ctx.QueueRefResolveCandidates(PObj, EntityHandle,
      DimStyleCandidates.Values, DimStyleCandidates.Count,
      dokDimStyle, rsDimStyle, nil);
    Ctx.QueueRefResolveCandidates(PObj, EntityHandle,
      BlockCandidates.Values, BlockCandidates.Count,
      dokBlockDef, rsBlockDef, nil);
  end else
    ZContext.PDrawing^.pObjRoot^.AddMi(PGDBObjSubordinated(PObj));
end;

procedure FinishDimension(PGen: PGDBObjGenericDimension;
  var ZContext: TZDrawingContext; var DWGContext: TDWGCtx;
  var DWGObject: Dwg_Object; PCommon: PDwg_DIMENSION_common);
var
  PObj: PGDBObjEntity;
begin
  PObj := ConvertGenericDimension(PGen, ZContext);
  ApplyDimensionUserText(PObj, PCommon, DWGContext);
  RegisterDimensionShell(PObj, ZContext, DWGObject, PCommon);
end;

procedure AddLinearDimension(var ZContext: TZDrawingContext;
  var DWGContext: TDWGCtx; var DWGObject: Dwg_Object;
  PDim: PDwg_Entity_DIMENSION_LINEAR);
var
  PGen: PGDBObjGenericDimension;
begin
  if PDim = nil then
    Exit;
  PGen := NewGenericDimension(ZContext, DTRotated,
    PDwg_DIMENSION_common(PDim));
  if PGen <> nil then begin
    PGen^.DimData.P13InWCS := Point3BD(PDim^.xline1_pt);
    PGen^.DimData.P14InWCS := Point3BD(PDim^.xline2_pt);
    PGen^.a50 := RadToDeg(PDim^.dim_rotation);
  end;
  FinishDimension(PGen, ZContext, DWGContext, DWGObject,
    PDwg_DIMENSION_common(PDim));
end;

procedure AddAlignedDimension(var ZContext: TZDrawingContext;
  var DWGContext: TDWGCtx; var DWGObject: Dwg_Object;
  PDim: PDwg_Entity_DIMENSION_ALIGNED);
var
  PGen: PGDBObjGenericDimension;
begin
  if PDim = nil then
    Exit;
  PGen := NewGenericDimension(ZContext, DTAligned,
    PDwg_DIMENSION_common(PDim));
  if PGen <> nil then begin
    PGen^.DimData.P13InWCS := Point3BD(PDim^.xline1_pt);
    PGen^.DimData.P14InWCS := Point3BD(PDim^.xline2_pt);
  end;
  FinishDimension(PGen, ZContext, DWGContext, DWGObject,
    PDwg_DIMENSION_common(PDim));
end;

procedure AddRadiusDimension(var ZContext: TZDrawingContext;
  var DWGContext: TDWGCtx; var DWGObject: Dwg_Object;
  PDim: PDwg_Entity_DIMENSION_RADIUS);
var
  PGen: PGDBObjGenericDimension;
begin
  if PDim = nil then
    Exit;
  PGen := NewGenericDimension(ZContext, DTRadius,
    PDwg_DIMENSION_common(PDim));
  if PGen <> nil then
    PGen^.DimData.P15InWCS := Point3BD(PDim^.first_arc_pt);
  FinishDimension(PGen, ZContext, DWGContext, DWGObject,
    PDwg_DIMENSION_common(PDim));
end;

procedure AddDiameterDimension(var ZContext: TZDrawingContext;
  var DWGContext: TDWGCtx; var DWGObject: Dwg_Object;
  PDim: PDwg_Entity_DIMENSION_DIAMETER);
var
  PGen: PGDBObjGenericDimension;
begin
  if PDim = nil then
    Exit;
  PGen := NewGenericDimension(ZContext, DTDiameter,
    PDwg_DIMENSION_common(PDim));
  if PGen <> nil then
    PGen^.DimData.P15InWCS := Point3BD(PDim^.first_arc_pt);
  FinishDimension(PGen, ZContext, DWGContext, DWGObject,
    PDwg_DIMENSION_common(PDim));
end;

procedure AddAngular2LineDimension(var ZContext: TZDrawingContext;
  var DWGContext: TDWGCtx; var DWGObject: Dwg_Object;
  PDim: PDwg_Entity_DIMENSION_ANG2LN);
var
  PGen: PGDBObjGenericDimension;
begin
  if PDim = nil then
    Exit;
  PGen := NewGenericDimension(ZContext, DTAngular,
    PDwg_DIMENSION_common(PDim));
  if PGen <> nil then begin
    PGen^.DimData.P13InWCS := Point3BD(PDim^.xline1start_pt);
    PGen^.DimData.P14InWCS := Point3BD(PDim^.xline1end_pt);
    PGen^.DimData.P15InWCS := Point3BD(PDim^.xline2end_pt);
    PGen^.DimData.P16InOCS := Point3BD(PDim^.xline2start_pt);
  end;
  FinishDimension(PGen, ZContext, DWGContext, DWGObject,
    PDwg_DIMENSION_common(PDim));
end;

procedure AddAngular3PointDimension(var ZContext: TZDrawingContext;
  var DWGContext: TDWGCtx; var DWGObject: Dwg_Object;
  PDim: PDwg_Entity_DIMENSION_ANG3PT);
var
  PGen: PGDBObjGenericDimension;
begin
  if PDim = nil then
    Exit;
  PGen := NewGenericDimension(ZContext, DTAngular3P,
    PDwg_DIMENSION_common(PDim));
  if PGen <> nil then begin
    PGen^.DimData.P10InWCS := Point3BD(PDim^.center_pt);
    PGen^.DimData.P13InWCS := Point3BD(PDim^.xline1_pt);
    PGen^.DimData.P14InWCS := Point3BD(PDim^.xline2_pt);
    PGen^.DimData.P15InWCS := Point3RD(PDim^.xline2end_pt);
  end;
  FinishDimension(PGen, ZContext, DWGContext, DWGObject,
    PDwg_DIMENSION_common(PDim));
end;

procedure AddOrdinateDimension(var ZContext: TZDrawingContext;
  var DWGContext: TDWGCtx; var DWGObject: Dwg_Object;
  PDim: PDwg_Entity_DIMENSION_ORDINATE);
var
  PGen: PGDBObjGenericDimension;
begin
  if PDim = nil then
    Exit;
  PGen := NewGenericDimension(ZContext, DTOrdinate,
    PDwg_DIMENSION_common(PDim));
  if PGen <> nil then begin
    PGen^.DimData.P13InWCS := Point3BD(PDim^.feature_location_pt);
    PGen^.DimData.P14InWCS := Point3BD(PDim^.leader_endpt);
  end;
  FinishDimension(PGen, ZContext, DWGContext, DWGObject,
    PDwg_DIMENSION_common(PDim));
end;

initialization
  RegisterDWGEntityHandler(DWG_TYPE_DIMENSION_LINEAR, @AddLinearDimension);
  RegisterDWGEntityHandler(DWG_TYPE_DIMENSION_ALIGNED, @AddAlignedDimension);
  RegisterDWGEntityHandler(DWG_TYPE_DIMENSION_RADIUS, @AddRadiusDimension);
  RegisterDWGEntityHandler(DWG_TYPE_DIMENSION_DIAMETER, @AddDiameterDimension);
  RegisterDWGEntityHandler(DWG_TYPE_DIMENSION_ANG2LN,
    @AddAngular2LineDimension);
  RegisterDWGEntityHandler(DWG_TYPE_DIMENSION_ANG3PT,
    @AddAngular3PointDimension);
  RegisterDWGEntityHandler(DWG_TYPE_DIMENSION_ORDINATE,
    @AddOrdinateDimension);
end.
