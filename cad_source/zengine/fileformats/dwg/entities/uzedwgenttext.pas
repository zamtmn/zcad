{*************************************************************************** }
{  fpdwg - DWG TEXT entity mapper (Stage 5.x R6)                             }
{                                                                            }
{        Copyright (C) 2026 Andrey Zubarev <zamtmn@yandex.ru>                }
{                                                                            }
{  This library is free software, licensed under the terms of the GNU        }
{  General Public License as published by the Free Software Foundation,      }
{  either version 3 of the License, or (at your option) any later version.   }
{*************************************************************************** }

unit uzedwgenttext;

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
  uzedwgloadcontext,
  uzedwgentityregistry,
  uzeffmanager,
  uzedwgimport;

implementation

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

procedure AddTextEntity(var ZContext: TZDrawingContext;
  var DWGContext: TDWGCtx; var DWGObject: Dwg_Object; PText: PDwg_Entity_TEXT);
var
  pobj: PGDBObjText;
  Props: TDWGTextProps;
  TextX, TextY, TextZ: Double;
begin
  pobj := AllocAndInitText(nil);
  DWGCopyTextProps(PText^, DWGContext.DWGVer, DWGContext.DWGCodePage, Props);
  DWGTextEffectiveInsertPoint(Props, TextX, TextY, TextZ);
  pobj^.Local.p_insert.x := TextX;
  pobj^.Local.p_insert.y := TextY;
  pobj^.Local.p_insert.z := TextZ;
  pobj^.P_drawInOCS := cP3d__0__0__0;
  pobj^.textprop.size := Props.Height;
  if Props.WidthFactor <> 0 then
    pobj^.textprop.wfactor := Props.WidthFactor
  else
    pobj^.textprop.wfactor := 1;
  pobj^.textprop.oblique := Props.Oblique;
  pobj^.textprop.justify := DWGTextJustify(Props.HorizAlignment,
    Props.VertAlignment);
  pobj^.textprop.backward := (Props.Generation and 2) <> 0;
  pobj^.textprop.upsidedown := (Props.Generation and 4) <> 0;
  pobj^.Template := DWGDecodedTextToZCADTemplate(Props.Value);
  pobj^.Content := pobj^.Template;
  ApplyTextRotation(pobj, Props.Rotation);
  if GetLoadCtx <> nil then
    DWGRegisterEntityShellWithTextStyleRef(PGDBObjEntity(pobj), DWGObject,
      PText^.style)
  else
    ZContext.PDrawing^.pObjRoot^.AddMi(PGDBObjSubordinated(pobj));
end;

initialization
  RegisterDWGEntityHandler(DWG_TYPE_TEXT, @AddTextEntity);
end.
