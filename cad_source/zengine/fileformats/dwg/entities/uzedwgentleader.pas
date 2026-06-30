{*************************************************************************** }
{  fpdwg - DWG LEADER entity mapper                                          }
{                                                                            }
{        Copyright (C) 2026 Andrey Zubarev <zamtmn@yandex.ru>                }
{                                                                            }
{  This library is free software, licensed under the terms of the GNU        }
{  General Public License as published by the Free Software Foundation,      }
{  either version 3 of the License, or (at your option) any later version.   }
{*************************************************************************** }

{ DWG LEADER entity mapper. The DXF loader for the same entity lives in
  uzeentleader.pas (GDBObjLeader.LoadFromDXF); this unit reproduces the same
  field mapping from the LibreDWG Dwg_Entity_LEADER record so a LEADER opened
  from a DWG file builds the identical GDBObjLeader the DXF path would.

  Field correspondence (DWG record -> DXF group -> GDBObjLeader):
    arrowhead_on   (71)  -> ArrowHeadFlag
    path_type      (72)  -> PathType
    annot_type     (73)  -> AnnotationType
    hookline_dir   (74)  -> HookLineDirectionFlag
    hookline_on    (75)  -> HookLineFlag
    num_points/points(76/10) -> VertexArrayInOCS
    box_height     (40)  -> TextHeight
    box_width      (41)  -> TextWidth
    extrusion      (210) -> NormalVector
    x_direction    (211) -> HorizontalDirection
    inspt_offset   (212) -> BlockOffset
    endptproj      (213) -> AnnotationOffset
    dimstyle       (3/340)-> DimStyleName (resolved via the ref queue) }

unit uzedwgentleader;

{$Include zengineconfig.inc}
{$Mode delphi}{$H+}
{$ModeSwitch advancedrecords}

interface

uses
  SysUtils,
  dwg, dwgproc, uzedwghandle,
  uzedrawingsimple,
  uzeentity, uzeentleader,
  uzeentsubordinated,
  uzegeometrytypes, uzegeometry,
  uzedwgloadcontext,
  uzedwgentityregistry,
  uzeffmanager,
  uzedwgtypes,
  uzedwgimport;

implementation

type
  PDwg_Entity_LEADER = ^Dwg_Entity_LEADER;

function Point3DP(const P: BITCODE_3DPOINT): TzePoint3d;
begin
  Result := CreateVertex(P.x, P.y, P.z);
end;

{ LibreDWG counts are unsigned 32-bit (BITCODE_BL); clamp to a signed Integer
  the way dwgproc.DWGBLToInt does (that helper is implementation-private). }
function LeaderCountToInt(Value: BITCODE_BL): Integer;
begin
  if Value > BITCODE_BL(High(Integer)) then
    Result := High(Integer)
  else
    Result := Integer(Value);
end;

procedure ApplyLeaderVertices(pobj: PGDBObjLeader;
  PLeader: PDwg_Entity_LEADER);
type
  PBitcode3DPoint = ^BITCODE_3DPOINT;
var
  i, n: Integer;
  pPoint: PBitcode3DPoint;
begin
  pobj^.VertexArrayInOCS.Clear;
  n := LeaderCountToInt(PLeader^.num_points);
  if (n <= 0) or (PLeader^.points = nil) then
    Exit;
  pPoint := PBitcode3DPoint(PLeader^.points);
  for i := 0 to n - 1 do begin
    pobj^.AddVertex(Point3DP(pPoint^));
    Inc(pPoint);
  end;
  pobj^.VertexArrayInOCS.Shrink;
end;

procedure QueueLeaderDimStyle(pobj: PGDBObjLeader;
  var DWGObject: Dwg_Object; PLeader: PDwg_Entity_LEADER);
var
  Ctx: TDWGZCADLoadContext;
  EntityHandle: QWord;
  DimStyleCandidates: TDWGRefHandleCandidates;
begin
  Ctx := GetLoadCtx;
  if Ctx = nil then
    Exit;
  EntityHandle := DWGObjectHandleValue(DWGObject);
  if not DWGRefHandleCandidatesValue(PLeader^.dimstyle, DimStyleCandidates) then
    FillChar(DimStyleCandidates, SizeOf(DimStyleCandidates), 0);
  Ctx.QueueRefResolveCandidates(PGDBObjEntity(pobj), EntityHandle,
    DimStyleCandidates.Values, DimStyleCandidates.Count,
    dokDimStyle, rsDimStyle, nil);
end;

procedure AddLeaderEntity(var ZContext: TZDrawingContext;
  var DWGContext: TDWGCtx; var DWGObject: Dwg_Object;
  PLeader: PDwg_Entity_LEADER);
var
  pobj: PGDBObjLeader;
begin
  if PLeader = nil then
    Exit;

  pobj := AllocAndInitLeader(nil);

  pobj^.ArrowHeadFlag := Ord(PLeader^.arrowhead_on <> 0);
  pobj^.PathType := PLeader^.path_type;
  pobj^.AnnotationType := PLeader^.annot_type;
  pobj^.HookLineDirectionFlag := Ord(PLeader^.hookline_dir <> 0);
  pobj^.HookLineFlag := Ord(PLeader^.hookline_on <> 0);
  pobj^.TextHeight := PLeader^.box_height;
  pobj^.TextWidth := PLeader^.box_width;
  pobj^.NormalVector := Point3DP(PLeader^.extrusion);
  pobj^.HorizontalDirection := Point3DP(PLeader^.x_direction);
  pobj^.BlockOffset := Point3DP(PLeader^.inspt_offset);
  pobj^.AnnotationOffset := Point3DP(PLeader^.endptproj);

  ApplyLeaderVertices(pobj, PLeader);

  if GetLoadCtx <> nil then begin
    DWGRegisterEntityShell(PGDBObjEntity(pobj), DWGObject, False, 0);
    QueueLeaderDimStyle(pobj, DWGObject, PLeader);
  end else
    ZContext.PDrawing^.pObjRoot^.AddMi(PGDBObjSubordinated(pobj));
end;

initialization
  RegisterDWGEntityHandler(DWG_TYPE_LEADER, @AddLeaderEntity);
end.
