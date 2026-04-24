{
*****************************************************************************
*                                                                           *
*  This file is part of the ZCAD                                            *
*                                                                           *
*  See the file COPYING.txt, included in this distribution,                 *
*  for details about the copyright.                                         *
*                                                                           *
*  This program is distributed in the hope that it will be useful,          *
*  but WITHOUT ANY WARRANTY; without even the implied warranty of           *
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                     *
*                                                                           *
*****************************************************************************
}
{
  Модуль: uzeentproxyparserpolylinewithnormals
  Назначение: Парсер полилинии с общей нормалью (OpCode=32) для примитивов
              внутри Proxy объектов.

  Формат данных (AcGiWorldDraw, OpCode = 32 = pgcPolylineWithNormals):
    VertexCount — int32
    Vertices    — VertexCount × 3 double
    Normal      — 3 double

  Нормаль в текущем рендеринге не требуется: как и ezdxf, ZCAD использует
  вершины как обычную полилинию и игнорирует общий вектор нормали.
}

unit uzeentproxyparserpolylinewithnormals;
{$Mode delphi}{$H+}
{$INCLUDE zengineconfig.inc}

interface

implementation

uses
  SysUtils,
  uzeentproxystream,
  uzeentproxymanager,
  uzeentproxysubentitybuilder,
  uzegeometrytypes,
  uzcLog;

const
  POLYLINE_WITH_NORMALS_OPCODE = 32;
  POLYLINE_MIN_VERTEX_COUNT = 2;
  POLYLINE_MAX_VERTEX_COUNT = 100000;

procedure UpdateBBoxWithVertex(const Vertex: TzePoint3d;
  var BBoxMin, BBoxMax: TzePoint3d; var Initialized: Boolean);
begin
  if not Initialized then
  begin
    BBoxMin := Vertex;
    BBoxMax := Vertex;
    Initialized := True;
    Exit;
  end;
  if Vertex.x < BBoxMin.x then BBoxMin.x := Vertex.x;
  if Vertex.y < BBoxMin.y then BBoxMin.y := Vertex.y;
  if Vertex.z < BBoxMin.z then BBoxMin.z := Vertex.z;
  if Vertex.x > BBoxMax.x then BBoxMax.x := Vertex.x;
  if Vertex.y > BBoxMax.y then BBoxMax.y := Vertex.y;
  if Vertex.z > BBoxMax.z then BBoxMax.z := Vertex.z;
end;

procedure HandlePolylineWithNormals(
  Stream: TProxyByteStream;
  out HandlerResult: TProxyHandlerResult);
var
  VertexCount: Integer;
  I: Integer;
  Vertex: TzePoint3d;
  BBoxInitialized: Boolean;
begin
  HandlerResult.Valid := False;
  HandlerResult.HasVertices := False;
  HandlerResult.HasBBox := False;

  VertexCount := Stream.ReadInt32;

  programlog.LogOutFormatStr(
    'uzeentproxyparserpolylinewithnormals: VertexCount=%d',
    [VertexCount], LM_Info);

  if (VertexCount < POLYLINE_MIN_VERTEX_COUNT)
    or (VertexCount > POLYLINE_MAX_VERTEX_COUNT) then
  begin
    programlog.LogOutFormatStr(
      'uzeentproxyparserpolylinewithnormals: VertexCount=%d is invalid, skipping',
      [VertexCount], LM_Info);
    Exit;
  end;

  HandlerResult.Vertices.init(VertexCount);
  BBoxInitialized := False;

  for I := 0 to VertexCount - 1 do
  begin
    Vertex := Stream.ReadVertex;
    HandlerResult.Vertices.PushBackData(Vertex);
    UpdateBBoxWithVertex(Vertex,
      HandlerResult.BBoxMin, HandlerResult.BBoxMax, BBoxInitialized);
  end;

  Stream.ReadVector; { Общая нормаль примитива. Пока не используется. }

  HandlerResult.HasVertices := True;
  HandlerResult.HasBBox := BBoxInitialized;
  HandlerResult.Valid := True;

  programlog.LogOutFormatStr(
    'uzeentproxyparserpolylinewithnormals: OK, %d vertices, BBox=(%.3f,%.3f)-(%.3f,%.3f)',
    [HandlerResult.Vertices.Count,
     HandlerResult.BBoxMin.x, HandlerResult.BBoxMin.y,
     HandlerResult.BBoxMax.x, HandlerResult.BBoxMax.y], LM_Info);
end;

{ --- Построитель подпримитивов --- }

{ Создаёт подпримитивы-отрезки (GDBObjLine) из вершин полилинии с общей
  нормалью. Полилиния рассматривается как незамкнутая, пока явно не указано
  обратное (нормаль на замкнутость не влияет). }
procedure BuildPolylineWithNormalsSubEntities(
  const HandlerResult: TProxyHandlerResult;
  const Context: TProxySubEntityContext);
begin
  if not HandlerResult.HasVertices then
    Exit;
  if HandlerResult.Vertices.Count < POLYLINE_MIN_VERTEX_COUNT then
    Exit;

  BuildLinesFromVertices(Context,
    HandlerResult.Vertices,
    HandlerResult.Closed,
    Context.PrimitiveLineWeight);
end;

initialization
  TProxyOpCodeDispatcher.RegisterOpCode(
    POLYLINE_WITH_NORMALS_OPCODE,
    'PolylineWithNormals',
    @HandlePolylineWithNormals,
    @BuildPolylineWithNormalsSubEntities);

end.
