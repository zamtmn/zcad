{*************************************************************************** }
{  fpdwg - DWG ATTRIB / ATTDEF entity mapper (Stage 6)                      }
{                                                                            }
{        Copyright (C) 2026 Andrey Zubarev <zamtmn@yandex.ru>                }
{                                                                            }
{  This library is free software, licensed under the terms of the GNU        }
{  General Public License as published by the Free Software Foundation,      }
{  either version 3 of the License, or (at your option) any later version.   }
{*************************************************************************** }

unit uzedwgentattrib;

{$Include zengineconfig.inc}
{$Mode delphi}{$H+}
{$ModeSwitch advancedrecords}

interface

uses
  SysUtils,
  dwg, dwgproc, uzedwghandle, uzedwgtext,
  uzedrawingsimple,
  uzegeometry,uzegeometrytypes,
  uzeenttext, uzeentabstracttext, uzeentity,
  uzeentsubordinated,
  uzedwgentityregistry,
  uzeffmanager,
  uzedwgimport;

implementation

type
  PDwg_Entity_ATTRIB = ^Dwg_Entity_ATTRIB;
  PDwg_Entity_ATTDEF = ^Dwg_Entity_ATTDEF;

function DWGTextJustify(Horiz, Vert: Integer): TTextJustify;
const
  DWGTextJustifyToZCAD: array[TDWGTextJustifyKind] of TTextJustify =
    (jstl, jstc, jstr, jsml, jsmc, jsmr, jsbl, jsbc, jsbr, jsbtl, jsbtc,
      jsbtr);
begin
  Result := DWGTextJustifyToZCAD[DWGTextAlignmentToJustifyKind(Horiz, Vert)];
end;

procedure ApplyTextRotation(PObj: PGDBObjText; Rotation: Double);
begin
  if Rotation = 0 then
    Exit;
  PObj^.Local.basis.ox := GetXfFromZ(PObj^.Local.basis.oz);
  PObj^.Local.basis.ox := VectorTransform3D(PObj^.Local.basis.ox.asPoint3d,
    CreateAffineRotationMatrix(PObj^.Local.basis.oz, -Rotation)).asVector;
end;

procedure ApplyAttribText(PObj: PGDBObjText; var DWGContext: TDWGCtx;
  const InsertPoint, AlignPoint: BITCODE_2DPOINT; Elevation, Height,
  WidthFactor, Oblique, Rotation: Double; Generation, HorizAlignment,
  VertAlignment: Integer; TextValue: BITCODE_T);
var
  Value: string;
begin
  if DWGTextUsesAlignmentPoint(0, HorizAlignment, VertAlignment) then begin
    PObj^.Local.p_insert.x := AlignPoint.x;
    PObj^.Local.p_insert.y := AlignPoint.y;
  end else begin
    PObj^.Local.p_insert.x := InsertPoint.x;
    PObj^.Local.p_insert.y := InsertPoint.y;
  end;
  PObj^.Local.p_insert.z := Elevation;
  PObj^.P_drawInOCS := cP3d__0__0__0;
  PObj^.textprop.size := Height;
  if WidthFactor <> 0 then
    PObj^.textprop.wfactor := WidthFactor
  else
    PObj^.textprop.wfactor := 1;
  PObj^.textprop.oblique := Oblique;
  PObj^.textprop.justify := DWGTextJustify(HorizAlignment, VertAlignment);
  PObj^.textprop.backward := (Generation and 2) <> 0;
  PObj^.textprop.upsidedown := (Generation and 4) <> 0;
  DWGSafeDecodeText(TextValue, DWGContext.DWGVer, DWGContext.DWGCodePage,
    Value);
  PObj^.Template := DWGDecodedTextToZCADTemplate(Value);
  PObj^.Content := PObj^.Template;
  ApplyTextRotation(PObj, Rotation);
end;

procedure RegisterAttribShell(PObj: PGDBObjText; var ZContext: TZDrawingContext;
  var DWGObject: Dwg_Object; StyleRef: BITCODE_H);
begin
  if GetLoadCtx <> nil then
    DWGRegisterEntityShellWithTextStyleRef(PGDBObjEntity(PObj), DWGObject,
      StyleRef)
  else
    ZContext.PDrawing^.pObjRoot^.AddMi(PGDBObjSubordinated(PObj));
end;

procedure AddAttribEntity(var ZContext: TZDrawingContext;
  var DWGContext: TDWGCtx; var DWGObject: Dwg_Object;
  PAttrib: PDwg_Entity_ATTRIB);
var
  PObj: PGDBObjText;
begin
  if PAttrib = nil then
    Exit;

  PObj := AllocAndInitText(nil);
  ApplyAttribText(PObj, DWGContext, PAttrib^.ins_pt,
    PAttrib^.alignment_pt, PAttrib^.elevation, PAttrib^.height,
    PAttrib^.width_factor, PAttrib^.oblique_angle, PAttrib^.rotation,
    PAttrib^.generation, PAttrib^.horiz_alignment,
    PAttrib^.vert_alignment, PAttrib^.text_value);
  RegisterAttribShell(PObj, ZContext, DWGObject, PAttrib^.style);
end;

procedure AddAttDefEntity(var ZContext: TZDrawingContext;
  var DWGContext: TDWGCtx; var DWGObject: Dwg_Object;
  PAttDef: PDwg_Entity_ATTDEF);
var
  PObj: PGDBObjText;
begin
  if PAttDef = nil then
    Exit;

  PObj := AllocAndInitText(nil);
  ApplyAttribText(PObj, DWGContext, PAttDef^.ins_pt,
    PAttDef^.alignment_pt, PAttDef^.elevation, PAttDef^.height,
    PAttDef^.width_factor, PAttDef^.oblique_angle, PAttDef^.rotation,
    PAttDef^.generation, PAttDef^.horiz_alignment,
    PAttDef^.vert_alignment, PAttDef^.default_value);
  { ATTDEF.prompt is optional UI text and is not needed for the imported
    entity. Some R2007+ files expose an unstable prompt pointer through
    LibreDWG, so avoid dereferencing it only for diagnostics. }
  RegisterAttribShell(PObj, ZContext, DWGObject, PAttDef^.style);
end;

initialization
  RegisterDWGEntityHandler(DWG_TYPE_ATTRIB, @AddAttribEntity);
  RegisterDWGEntityHandler(DWG_TYPE_ATTDEF, @AddAttDefEntity);
end.
