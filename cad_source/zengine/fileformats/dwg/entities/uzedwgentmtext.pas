{*************************************************************************** }
{  fpdwg - DWG MTEXT entity mapper (Stage 5.x R6)                            }
{                                                                            }
{        Copyright (C) 2026 Andrey Zubarev <zamtmn@yandex.ru>                }
{                                                                            }
{  This library is free software, licensed under the terms of the GNU        }
{  General Public License as published by the Free Software Foundation,      }
{  either version 3 of the License, or (at your option) any later version.   }
{*************************************************************************** }

unit uzedwgentmtext;

{$Include zengineconfig.inc}
{$Mode delphi}{$H+}
{$ModeSwitch advancedrecords}

interface

uses
  SysUtils,
  dwg, dwgproc, uzedwghandle, uzedwgtext,
  uzedrawingsimple,
  uzeentmtext, uzeentabstracttext, uzeentity,
  uzegeometry,uzegeometrytypes,
  uzeentsubordinated,
  uzedwgloadcontext,
  uzedwgentityregistry,
  uzedwgtargetedlog,
  uzeffmanager,
  uzedwgimport;

implementation

const
  DWGMTextJustifyToZCAD: array[TDWGMTextJustify] of TTextJustify =
    (jstl, jstc, jstr, jsml, jsmc, jsmr, jsbl, jsbc, jsbr);

function DWGMTextAttachmentToZCADJustify(Attachment: Integer): TTextJustify;
begin
  Result := DWGMTextJustifyToZCAD[DWGMTextAttachmentToJustify(Attachment)];
end;

procedure ApplyMTextRotation(PObj: PGDBObjMText; Rotation: Double);
begin
  if Rotation = 0 then
    Exit;
  PObj^.Local.basis.ox := GetXfFromZ(PObj^.Local.basis.oz);
  PObj^.Local.basis.ox := VectorTransform3D(PObj^.Local.basis.ox.asPoint3d,
    CreateAffineRotationMatrix(PObj^.Local.basis.oz, -Rotation)).asVector3d;
end;

procedure AddMTextEntity(var ZContext: TZDrawingContext;
  var DWGContext: TDWGCtx; var DWGObject: Dwg_Object;
  PMText: PDwg_Entity_MTEXT);
var
  pobj: PGDBObjMText;
  Props: TDWGMTextProps;
begin
  // Issue #1203: точечный лог входа в mapper MTEXT. Если этого сообщения
  // нет в логе для интересующего handle — значит, parseDwg_Data не дошёл
  // до MTEXT обработчика (LibreDWG не отдал объект или fixedtype не
  // соответствует DWG_TYPE_MTEXT).
  TargetedLog('parse-mtext', DWGObjectHandleValue(DWGObject), '');
  pobj := AllocAndInitMText(nil);
  DWGCopyMTextProps(PMText^, DWGContext.DWGVer, DWGContext.DWGCodePage,
    Props);
  pobj^.Local.p_insert.x := Props.InsertX;
  pobj^.Local.p_insert.y := Props.InsertY;
  pobj^.Local.p_insert.z := Props.InsertZ;
  pobj^.textprop.size := Props.TextHeight;
  pobj^.textprop.justify := DWGMTextAttachmentToZCADJustify(Props.Attachment);
  pobj^.Width := Props.RectWidth;
  if Props.LineSpaceFactor <> 0 then
    pobj^.linespacef := Props.LineSpaceFactor
  else
    pobj^.linespacef := 1;
  pobj^.Template := DWGDecodedTextToZCADTemplate(Props.Value);
  pobj^.Content := pobj^.Template;
  ApplyMTextRotation(pobj, Props.Rotation);
  if GetLoadCtx <> nil then
    DWGRegisterEntityShellWithTextStyleRef(PGDBObjEntity(pobj), DWGObject,
      PMText^.style)
  else
    ZContext.PDrawing^.pObjRoot^.AddMi(PGDBObjSubordinated(pobj));
end;

initialization
  RegisterDWGEntityHandler(DWG_TYPE_MTEXT, @AddMTextEntity);
end.
