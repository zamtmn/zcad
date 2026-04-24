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
@author(Vladimir Bobrov)
}

{
  Модуль: uzeentproxyparserpolyline
  Назначение: Парсер полилинии (OpCode=6, pgcPolyline) для примитивов внутри
              Proxy объектов. Покрывает как многовершинные полилинии, так и
              отрезки (LINE) — последние являются полилинией из двух точек.

  Архитектура:
  - Секция initialization регистрирует HandlePolyline в TProxyOpCodeDispatcher
  - Чтобы отключить парсинг полилиний — исключить этот файл из проекта

  Формат данных (AcGiWorldDraw, OpCode = 6 = pgcPolyline):
    VertexCount — int32   — количество вершин (>= 2)
    Vertices    — VertexCount × 3 double (по 24 байта каждая) — точки в WCS

  Особенности:
  - Линия (LINE) — частный случай: VertexCount = 2
  - Вершины передаются без флагов выпуклости (bulge) — отличие от LWPOLYLINE
  - BBox вычисляется по всем вершинам
  - Тесселяция не нужна — вершины являются готовым контуром
}

unit uzeentproxyparserpolyline;
{$Mode delphi}{$H+}
{$INCLUDE zengineconfig.inc}

interface

{ Публичный интерфейс не нужен — регистрация происходит автоматически
  при загрузке модуля через секцию initialization }

implementation

uses
  SysUtils,
  uzeentproxystream,
  uzeentproxymanager,
  uzeentproxysubentitybuilder,
  uzegeometrytypes,
  UGDBPoint3DArray,
  uzcLog;

const
  { OpCode полилинии (и линии как частного случая) в формате AcGiWorldDraw }
  POLYLINE_OPCODE = 6;

  { Минимальное допустимое количество вершин полилинии }
  POLYLINE_MIN_VERTEX_COUNT = 2;

  { Максимально допустимое количество вершин (защита от повреждённых данных) }
  POLYLINE_MAX_VERTEX_COUNT = 100000;

{ --- Вспомогательные процедуры --- }

{ Расширяет BBox точкой Vertex, обновляя BBoxMin и BBoxMax.
  При первом вызове (Initialized = False) инициализирует BBox. }
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

{ --- Обработчик OpCode --- }

{ Читает полилинию (или линию) из потока, заполняет вершины и BBox.
  Регистрируется в TProxyOpCodeDispatcher как обработчик OpCode=6. }
procedure HandlePolyline(
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

  { Читаем количество вершин }
  VertexCount := Stream.ReadInt32;

  programlog.LogOutFormatStr(
    'uzeentproxyparserpolyline: VertexCount=%d', [VertexCount], LM_Info);

  { Проверяем корректность количества вершин }
  if (VertexCount < POLYLINE_MIN_VERTEX_COUNT)
    or (VertexCount > POLYLINE_MAX_VERTEX_COUNT) then
  begin
    programlog.LogOutFormatStr(
      'uzeentproxyparserpolyline: VertexCount=%d is invalid, skipping',
      [VertexCount], LM_Info);
    Exit;
  end;

  HandlerResult.Vertices.init(VertexCount);
  BBoxInitialized := False;

  { Читаем все вершины и попутно вычисляем BBox }
  for I := 0 to VertexCount - 1 do
  begin
    Vertex := Stream.ReadVertex;
    HandlerResult.Vertices.PushBackData(Vertex);
    UpdateBBoxWithVertex(Vertex,
      HandlerResult.BBoxMin, HandlerResult.BBoxMax, BBoxInitialized);
  end;

  HandlerResult.HasVertices := True;
  HandlerResult.HasBBox := BBoxInitialized;
  HandlerResult.Valid := True;

  programlog.LogOutFormatStr(
    'uzeentproxyparserpolyline: OK, %d vertices, BBox=(%.3f,%.3f)-(%.3f,%.3f)',
    [HandlerResult.Vertices.Count,
     HandlerResult.BBoxMin.x, HandlerResult.BBoxMin.y,
     HandlerResult.BBoxMax.x, HandlerResult.BBoxMax.y], LM_Info);
end;

{ --- Построитель подпримитивов --- }

{ Создаёт подпримитивы-отрезки (GDBObjLine) из вершин полилинии.
  Каждая пара соседних вершин превращается в отдельный GDBObjLine
  с локальными координатами относительно ручки прокси-объекта.
  Если контур замкнут — добавляется замыкающий отрезок. }
procedure BuildPolylineSubEntities(
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
  { Регистрируем обработчик OpCode=6 (Polyline / Line) и построитель
    подпримитивов. Если этот файл исключён из проекта — регистрация не
    происходит, полилинии и линии внутри прокси-объектов перестают
    парситься, а подпримитивы из них не создаются. }
  TProxyOpCodeDispatcher.RegisterOpCode(
    POLYLINE_OPCODE,
    'Polyline/Line',
    @HandlePolyline,
    @BuildPolylineSubEntities);

end.
