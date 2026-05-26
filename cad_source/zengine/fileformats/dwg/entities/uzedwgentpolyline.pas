{*************************************************************************** }
{  fpdwg - DWG old POLYLINE entity mappers (Stage 8)                         }
{                                                                            }
{        Copyright (C) 2026 Andrey Zubarev <zamtmn@yandex.ru>                }
{                                                                            }
{  This library is free software, licensed under the terms of the GNU        }
{  General Public License as published by the Free Software Foundation,      }
{  either version 3 of the License, or (at your option) any later version.   }
{*************************************************************************** }

unit uzedwgentpolyline;

{$Include zengineconfig.inc}
{$Mode delphi}{$H+}
{$ModeSwitch advancedrecords}

interface

uses
  SysUtils,
  dwg, dwgproc,
  uzedrawingsimple,
  uzeentity, uzeentpolyline, uzeentpolyfacemesh,
  uzeentsubordinated,
  uzegeometrytypes, uzegeometry,
  uzedwgtypes,
  uzedwgloadcontext,
  uzedwgentityregistry,
  uzeffmanager,
  uzedwgimport;

implementation

type
  PDWGObject = ^Dwg_Object;
  TVertexArray = array of TzePoint3d;
  TFaceArray = array of TFaceIndices;

function RawObjectByHandle(const DWGContext: TDWGCtx; Handle: QWord;
  out Obj: PDWGObject): Boolean;
var
  Entry: TDWGZCADHandleEntry;
begin
  Obj := nil;
  Result := False;
  if (Handle = 0) or (GetLoadCtx = nil) then
    Exit;
  if not GetLoadCtx.TryGetEntry(Handle, Entry) then
    Exit;
  if (Entry.RawIndex < 0) or
     (BITCODE_BL(Entry.RawIndex) >= DWGContext.DWG.num_objects) then
    Exit;
  Obj := @DWGContext.DWG.&object[Entry.RawIndex];
  Result := Obj <> nil;
end;

function RawEntityObjectByHandle(const DWGContext: TDWGCtx; Handle: QWord;
  out Obj: PDWGObject): Boolean;
begin
  Result := RawObjectByHandle(DWGContext, Handle, Obj);
  if not Result then
    Exit;
  Result := (Obj^.supertype = DWG_SUPERTYPE_ENTITY) and
    (Obj^.tio.entity <> nil);
end;

function VertexFrom2D(PVertex: PDwg_Entity_VERTEX_2D;
  Elevation: Double): TzePoint3d;
begin
  Result := NulVertex;
  if PVertex = nil then
    Exit;
  Result.x := PVertex^.point.x;
  Result.y := PVertex^.point.y;
  Result.z := PVertex^.point.z;
  if Result.z = 0 then
    Result.z := Elevation;
end;

function VertexFrom3DPoint(const P: BITCODE_3BD): TzePoint3d;
begin
  Result.x := P.x;
  Result.y := P.y;
  Result.z := P.z;
end;

function FaceFromVertex(PVertex: PDwg_Entity_VERTEX_PFACE_FACE): TFaceIndices;
var
  i: Integer;
begin
  FillChar(Result, SizeOf(Result), 0);
  if PVertex = nil then
    Exit;
  Result.Vertex1 := PVertex^.vertind[0];
  Result.Vertex2 := PVertex^.vertind[1];
  Result.Vertex3 := PVertex^.vertind[2];
  Result.Vertex4 := PVertex^.vertind[3];
  Result.VertexCount := 0;
  for i := 0 to 3 do
    if PVertex^.vertind[i] <> 0 then
      Inc(Result.VertexCount);
end;

function CollectPolylineVertices(const DWGContext: TDWGCtx;
  const Props: TDWGPolylineRefProps; ExpectedType: DWG_OBJECT_TYPE;
  out Vertices: TVertexArray): Integer;
var
  i: Integer;
  Obj: PDWGObject;
  P: TzePoint3d;
begin
  SetLength(Vertices, 0);
  for i := 0 to High(Props.VertexHandles) do begin
    if not RawEntityObjectByHandle(DWGContext, Props.VertexHandles[i], Obj) then
      Continue;
    if Obj^.fixedtype <> ExpectedType then
      Continue;
    case ExpectedType of
      DWG_TYPE_VERTEX_2D:
        begin
          if Obj^.tio.entity^.tio.VERTEX_2D = nil then
            Continue;
          P := VertexFrom2D(Obj^.tio.entity^.tio.VERTEX_2D, Props.Elevation);
        end;
      DWG_TYPE_VERTEX_3D:
        begin
          if Obj^.tio.entity^.tio.VERTEX_3D = nil then
            Continue;
          P := VertexFrom3DPoint(Obj^.tio.entity^.tio.VERTEX_3D^.point);
        end;
      DWG_TYPE_VERTEX_MESH:
        begin
          if Obj^.tio.entity^.tio.VERTEX_MESH = nil then
            Continue;
          P := VertexFrom3DPoint(Obj^.tio.entity^.tio.VERTEX_MESH^.point);
        end;
    else
      Continue;
    end;
    SetLength(Vertices, Length(Vertices) + 1);
    Vertices[High(Vertices)] := P;
  end;
  Result := Length(Vertices);
end;

procedure AddVerticesToPolyline(pobj: PGDBObjPolyline;
  const Vertices: TVertexArray);
var
  i: Integer;
begin
  pobj^.VertexArrayInOCS.Clear;
  for i := 0 to High(Vertices) do
    pobj^.AddVertex(Vertices[i]);
end;

procedure AddVerticesToPolyFaceMesh(pobj: PGDBObjPolyFaceMesh;
  const Vertices: TVertexArray);
var
  i: Integer;
begin
  pobj^.VertexArrayInOCS.Clear;
  for i := 0 to High(Vertices) do
    pobj^.AddVertex(Vertices[i]);
end;

procedure RegisterOrAttachPolyline(var ZContext: TZDrawingContext;
  var DWGObject: Dwg_Object; pobj: PGDBObjPolyline);
begin
  if GetLoadCtx <> nil then
    DWGRegisterEntityShell(PGDBObjEntity(pobj), DWGObject, False, 0)
  else
    ZContext.PDrawing^.pObjRoot^.AddMi(PGDBObjSubordinated(pobj));
end;

procedure RegisterOrAttachPolyFaceMesh(var ZContext: TZDrawingContext;
  var DWGObject: Dwg_Object; pobj: PGDBObjPolyFaceMesh);
begin
  if GetLoadCtx <> nil then
    DWGRegisterEntityShell(PGDBObjEntity(pobj), DWGObject, False, 0)
  else
    ZContext.PDrawing^.pObjRoot^.AddMi(PGDBObjSubordinated(pobj));
end;

procedure AddPolyline2DEntity(var ZContext: TZDrawingContext;
  var DWGContext: TDWGCtx; var DWGObject: Dwg_Object;
  PPolyline: PDwg_Entity_POLYLINE_2D);
var
  Props: TDWGPolylineRefProps;
  Vertices: TVertexArray;
  pobj: PGDBObjPolyline;
begin
  if PPolyline = nil then
    Exit;
  DWGCopyPolyline2DRefProps(PPolyline^, Props);
  if CollectPolylineVertices(DWGContext, Props, DWG_TYPE_VERTEX_2D, Vertices) = 0 then
    Exit;
  pobj := AllocAndInitPolyline(nil);
  pobj^.Closed := Props.Closed;
  AddVerticesToPolyline(pobj, Vertices);
  RegisterOrAttachPolyline(ZContext, DWGObject, pobj);
end;

procedure AddPolyline3DEntity(var ZContext: TZDrawingContext;
  var DWGContext: TDWGCtx; var DWGObject: Dwg_Object;
  PPolyline: PDwg_Entity_POLYLINE_3D);
var
  Props: TDWGPolylineRefProps;
  Vertices: TVertexArray;
  pobj: PGDBObjPolyline;
begin
  if PPolyline = nil then
    Exit;
  DWGCopyPolyline3DRefProps(PPolyline^, Props);
  if CollectPolylineVertices(DWGContext, Props, DWG_TYPE_VERTEX_3D, Vertices) = 0 then
    Exit;
  pobj := AllocAndInitPolyline(nil);
  pobj^.Closed := Props.Closed;
  AddVerticesToPolyline(pobj, Vertices);
  RegisterOrAttachPolyline(ZContext, DWGObject, pobj);
end;

function MeshIndex(M, N, NCount: Integer): Integer;
begin
  Result := M * NCount + N + 1;
end;

procedure AddMeshFaces(pobj: PGDBObjPolyFaceMesh; MCount, NCount: Integer;
  ClosedM, ClosedN: Boolean);
var
  m, n, NextM, NextN, MMax, NMax: Integer;
  Face: TFaceIndices;
begin
  if (MCount < 2) or (NCount < 2) then
    Exit;
  if ClosedM then
    MMax := MCount - 1
  else
    MMax := MCount - 2;
  if ClosedN then
    NMax := NCount - 1
  else
    NMax := NCount - 2;
  for m := 0 to MMax do
    for n := 0 to NMax do begin
      NextM := m + 1;
      if NextM >= MCount then
        NextM := 0;
      NextN := n + 1;
      if NextN >= NCount then
        NextN := 0;
      Face.Vertex1 := MeshIndex(m, n, NCount);
      Face.Vertex2 := MeshIndex(NextM, n, NCount);
      Face.Vertex3 := MeshIndex(NextM, NextN, NCount);
      Face.Vertex4 := MeshIndex(m, NextN, NCount);
      Face.VertexCount := 4;
      pobj^.AddFace(Face);
    end;
end;

procedure AddPolylineMeshEntity(var ZContext: TZDrawingContext;
  var DWGContext: TDWGCtx; var DWGObject: Dwg_Object;
  PPolyline: PDwg_Entity_POLYLINE_MESH);
var
  Props: TDWGPolylineRefProps;
  Vertices: TVertexArray;
  pMesh: PGDBObjPolyFaceMesh;
  pLine: PGDBObjPolyline;
  MCount, NCount: Integer;
begin
  if PPolyline = nil then
    Exit;
  DWGCopyPolylineMeshRefProps(PPolyline^, Props);
  if CollectPolylineVertices(DWGContext, Props, DWG_TYPE_VERTEX_MESH, Vertices) = 0 then
    Exit;

  MCount := PPolyline^.num_m_verts;
  NCount := PPolyline^.num_n_verts;
  if (MCount >= 2) and (NCount >= 2) then begin
    pMesh := AllocAndInitPolyFaceMesh(nil);
    AddVerticesToPolyFaceMesh(pMesh, Vertices);
    AddMeshFaces(pMesh, MCount, NCount, (PPolyline^.flag and 1) <> 0,
      (PPolyline^.flag and $20) <> 0);
    RegisterOrAttachPolyFaceMesh(ZContext, DWGObject, pMesh);
  end else begin
    pLine := AllocAndInitPolyline(nil);
    pLine^.Closed := Props.Closed;
    AddVerticesToPolyline(pLine, Vertices);
    RegisterOrAttachPolyline(ZContext, DWGObject, pLine);
  end;
end;

procedure AddPolylinePFaceEntity(var ZContext: TZDrawingContext;
  var DWGContext: TDWGCtx; var DWGObject: Dwg_Object;
  PPolyline: PDwg_Entity_POLYLINE_PFACE);
var
  Props: TDWGPolylineRefProps;
  Vertices: TVertexArray;
  Faces: TFaceArray;
  Obj: PDWGObject;
  i, FaceCount: Integer;
  Face: TFaceIndices;
  pobj: PGDBObjPolyFaceMesh;
begin
  if PPolyline = nil then
    Exit;
  DWGCopyPolylinePFaceRefProps(PPolyline^, Props);
  SetLength(Vertices, 0);
  SetLength(Faces, 0);
  for i := 0 to High(Props.VertexHandles) do begin
    if not RawEntityObjectByHandle(DWGContext, Props.VertexHandles[i], Obj) then
      Continue;
    case Obj^.fixedtype of
      DWG_TYPE_VERTEX_PFACE:
        begin
          if Obj^.tio.entity^.tio.VERTEX_PFACE = nil then
            Continue;
          SetLength(Vertices, Length(Vertices) + 1);
          Vertices[High(Vertices)] :=
            VertexFrom3DPoint(Obj^.tio.entity^.tio.VERTEX_PFACE^.point);
        end;
      DWG_TYPE_VERTEX_PFACE_FACE:
        begin
          if Obj^.tio.entity^.tio.VERTEX_PFACE_FACE = nil then
            Continue;
          Face := FaceFromVertex(Obj^.tio.entity^.tio.VERTEX_PFACE_FACE);
          if Face.VertexCount >= 3 then begin
            SetLength(Faces, Length(Faces) + 1);
            Faces[High(Faces)] := Face;
          end;
        end;
    end;
  end;
  if (Length(Vertices) = 0) and (Length(Faces) = 0) then
    Exit;
  pobj := AllocAndInitPolyFaceMesh(nil);
  AddVerticesToPolyFaceMesh(pobj, Vertices);
  for FaceCount := 0 to High(Faces) do
    pobj^.AddFace(Faces[FaceCount]);
  RegisterOrAttachPolyFaceMesh(ZContext, DWGObject, pobj);
end;

initialization
  RegisterDWGEntityHandler(DWG_TYPE_POLYLINE_2D, @AddPolyline2DEntity);
  RegisterDWGEntityHandler(DWG_TYPE_POLYLINE_3D, @AddPolyline3DEntity);
  RegisterDWGEntityHandler(DWG_TYPE_POLYLINE_MESH, @AddPolylineMeshEntity);
  RegisterDWGEntityHandler(DWG_TYPE_POLYLINE_PFACE, @AddPolylinePFaceEntity);
end.
