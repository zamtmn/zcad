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
  Модуль: uzeentproxyparserlwpolyline
  Назначение: Парсер 2D полилинии (OpCode=33, pgcLwPolyline) для примитивов
              внутри Proxy объектов. Соответствует примитиву LWPOLYLINE в DXF.

  Архитектура:
  - Секция initialization регистрирует HandleLwPolyline в TProxyOpCodeDispatcher
  - Чтобы отключить парсинг LWPOLYLINE — исключить этот файл из проекта

  Формат данных (AcGiWorldDraw, OpCode = 33 = pgcLwPolyline):
    Внутри команды LWPOLYLINE данные хранятся в DWG-подобной бит-упакованной
    форме (Open Design Specification, раздел 20.4.85 «LWPLINE»). Используем
    TProxyBitStream и читаем поля в строгом порядке:
      RL  num_data_bytes — длина бит-упакованной части в байтах;
      BS  flag           — битовые флаги (см. ниже);
      BD  const_width    — если flag & 4;
      BD  elevation      — если flag & 8;
      BD  thickness      — если flag & 2;
      3×BD extrusion     — если flag & 1;
      BL  num_points     — количество вершин;
      BL  num_bulges     — если flag & 16;
      (только для R2010+: BL num_vertex_ids — если flag & 1024,
                          BL num_widths     — если flag & 32);
      RD,RD первая вершина (без сжатия);
      BDD x,y остальных вершин (delta-кодирование от предыдущей);
      BD  bulges[num_bulges];
      BL  vertex_ids[num_vertex_ids];
      (BD,BD) widths[num_widths];
    Замкнутость определяется битом 9 (flag & 512).

  Текущая реализация:
  - Выпуклость (Bulge) не тесселируется — сегменты рисуются прямыми
  - Z всех вершин устанавливается из поля Elevation
  - BBox вычисляется по всем вершинам
}

unit uzeentproxyparserlwpolyline;
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
  { OpCode 2D полилинии в формате AcGiWorldDraw }
  LWPOLYLINE_OPCODE = 33;

  { Минимальное допустимое количество вершин }
  LWPOLYLINE_MIN_VERTEX_COUNT = 2;

  { Максимально допустимое количество вершин (защита от повреждённых данных) }
  LWPOLYLINE_MAX_VERTEX_COUNT = 100000;

  { Битовые флаги формата LWPLINE (Open Design Specification 20.4.85) }
  LWPLINE_FLAG_EXTRUSION   = 1;     { бит 0: задана нормаль }
  LWPLINE_FLAG_THICKNESS   = 2;     { бит 1: задана толщина }
  LWPLINE_FLAG_CONST_WIDTH = 4;     { бит 2: постоянная ширина }
  LWPLINE_FLAG_ELEVATION   = 8;     { бит 3: задана высота }
  LWPLINE_FLAG_HAS_BULGES  = 16;    { бит 4: заданы выпуклости }
  LWPLINE_FLAG_HAS_WIDTHS  = 32;    { бит 5: заданы ширины (R2010+) }
  LWPLINE_FLAG_CLOSED      = 512;   { бит 9: замкнутая полилиния }
  LWPLINE_FLAG_HAS_VIDS    = 1024;  { бит 10: заданы vertex IDs (R2010+) }

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

{ Читает данные 2D полилинии из потока, заполняет вершины и BBox.
  Регистрируется в TProxyOpCodeDispatcher как обработчик OpCode=33.

  Данные команды LWPOLYLINE в Proxy Graphic хранятся в бит-упакованной
  DWG-форме (см. описание формата в шапке модуля). Чтобы не ломать общий
  байтовый указатель FStream основного потока, читаем оставшиеся байты
  команды в локальный TBytes и парсим их через TProxyBitStream. }
procedure HandleLwPolyline(
  Stream: TProxyByteStream;
  out HandlerResult: TProxyHandlerResult);
var
  NumDataBytes, I: Integer;
  Flag: Integer;
  ConstWidth, Elevation, Thickness: Double;
  ExtrX, ExtrY, ExtrZ: Double;
  NumPoints, NumBulges, NumVertexIds, NumWidths: Integer;
  IsClosed: Boolean;
  Payload: TBytes;
  Bits: TProxyBitStream;
  PrevX, PrevY, X, Y: Double;
  Vertex: TzePoint3d;
  BBoxInitialized: Boolean;
begin
  HandlerResult.Valid := False;
  HandlerResult.HasVertices := False;
  HandlerResult.HasBBox := False;
  ConstWidth := 0.0;
  Elevation := 0.0;
  Thickness := 0.0;
  ExtrX := 0.0;
  ExtrY := 0.0;
  ExtrZ := 1.0;
  NumBulges := 0;
  NumVertexIds := 0;
  NumWidths := 0;

  { Бит-упакованная часть команды LWPOLYLINE имеет вид:
      [RL: NumDataBytes — длина бит-упакованного блока в байтах]
      [BitPacked: NumDataBytes байт]
    После них в команде может оставаться padding/traits, который
    пропустит ParseCommand по ExpectedEnd. Поэтому handler читает
    ровно (4 + NumDataBytes) байт основного потока. }
  if Stream.RemainingBytes < 4 then
  begin
    programlog.LogOutFormatStr(
      'uzeentproxyparserlwpolyline: too few bytes for length prefix',
      [], LM_Info);
    Exit;
  end;

  NumDataBytes := Stream.ReadInt32;
  if (NumDataBytes <= 0) or (NumDataBytes > Stream.RemainingBytes) then
  begin
    programlog.LogOutFormatStr(
      'uzeentproxyparserlwpolyline: NumDataBytes=%d does not fit in stream ' +
      '(remaining=%d), skipping',
      [NumDataBytes, Stream.RemainingBytes], LM_Info);
    Exit;
  end;
  SetLength(Payload, NumDataBytes);
  for I := 0 to NumDataBytes - 1 do
    Payload[I] := Stream.ReadByte;

  Bits := TProxyBitStream.Create(Payload);
  try
    try
      Flag := Bits.ReadBitShort;

      programlog.LogOutFormatStr(
        'uzeentproxyparserlwpolyline: bitpacked numDataBytes=%d flag=0x%x',
        [NumDataBytes, Flag], LM_Info);

      if (Flag and LWPLINE_FLAG_CONST_WIDTH) <> 0 then
        ConstWidth := Bits.ReadBitDouble;
      if (Flag and LWPLINE_FLAG_ELEVATION) <> 0 then
        Elevation := Bits.ReadBitDouble;
      if (Flag and LWPLINE_FLAG_THICKNESS) <> 0 then
        Thickness := Bits.ReadBitDouble;
      if (Flag and LWPLINE_FLAG_EXTRUSION) <> 0 then
      begin
        ExtrX := Bits.ReadBitDouble;
        ExtrY := Bits.ReadBitDouble;
        ExtrZ := Bits.ReadBitDouble;
      end;

      IsClosed := (Flag and LWPLINE_FLAG_CLOSED) <> 0;
      NumPoints := Bits.ReadBitLong;

      if (NumPoints < LWPOLYLINE_MIN_VERTEX_COUNT)
        or (NumPoints > LWPOLYLINE_MAX_VERTEX_COUNT) then
      begin
        programlog.LogOutFormatStr(
          'uzeentproxyparserlwpolyline: NumPoints=%d invalid, skipping',
          [NumPoints], LM_Info);
        Exit;
      end;

      if (Flag and LWPLINE_FLAG_HAS_BULGES) <> 0 then
        NumBulges := Bits.ReadBitLong;

      { Поля vertex_ids и widths появились в формате R2010+ (AC1024).
        Для DXF 2007 (AC1021) их нет. Поскольку версия здесь не известна,
        читаем их только если соответствующие биты выставлены и в потоке
        достаточно данных — иначе пропускаем. }
      if (Flag and LWPLINE_FLAG_HAS_VIDS) <> 0 then
        NumVertexIds := Bits.ReadBitLong;
      if (Flag and LWPLINE_FLAG_HAS_WIDTHS) <> 0 then
        NumWidths := Bits.ReadBitLong;

      programlog.LogOutFormatStr(
        'uzeentproxyparserlwpolyline: numPoints=%d closed=%s bulges=%d ' +
        'vids=%d widths=%d',
        [NumPoints, BoolToStr(IsClosed, True), NumBulges,
         NumVertexIds, NumWidths], LM_Info);

      HandlerResult.Vertices.init(NumPoints);
      BBoxInitialized := False;

      { Первая вершина: 2 raw double }
      PrevX := Bits.ReadRawDouble;
      PrevY := Bits.ReadRawDouble;
      Vertex.x := PrevX;
      Vertex.y := PrevY;
      Vertex.z := Elevation;
      HandlerResult.Vertices.PushBackData(Vertex);
      UpdateBBoxWithVertex(Vertex,
        HandlerResult.BBoxMin, HandlerResult.BBoxMax, BBoxInitialized);

      { Остальные вершины — delta от предыдущей }
      for I := 1 to NumPoints - 1 do
      begin
        X := Bits.ReadBitDoubleDefault(PrevX);
        Y := Bits.ReadBitDoubleDefault(PrevY);
        PrevX := X;
        PrevY := Y;
        Vertex.x := X;
        Vertex.y := Y;
        Vertex.z := Elevation;
        HandlerResult.Vertices.PushBackData(Vertex);
        UpdateBBoxWithVertex(Vertex,
          HandlerResult.BBoxMin, HandlerResult.BBoxMax, BBoxInitialized);
      end;

      { Bulge / vertex_ids / widths далее в потоке игнорируем —
        их чтение влияет только на оставшийся хвост, который пропустит
        ParseCommand по ExpectedEnd. }

      HandlerResult.HasVertices := True;
      HandlerResult.Closed := IsClosed;
      HandlerResult.HasBBox := BBoxInitialized;
      HandlerResult.Valid := True;

      programlog.LogOutFormatStr(
        'uzeentproxyparserlwpolyline: OK, %d vertices, closed=%s, ' +
        'BBox=(%.3f,%.3f)-(%.3f,%.3f)',
        [HandlerResult.Vertices.Count, BoolToStr(IsClosed, True),
         HandlerResult.BBoxMin.x, HandlerResult.BBoxMin.y,
         HandlerResult.BBoxMax.x, HandlerResult.BBoxMax.y], LM_Info);
    except
      on E: Exception do
      begin
        programlog.LogOutFormatStr(
          'uzeentproxyparserlwpolyline: bit-stream parse error: %s',
          [E.Message], LM_Info);
        if HandlerResult.HasVertices then
        begin
          HandlerResult.Vertices.done;
          HandlerResult.HasVertices := False;
        end;
        HandlerResult.Valid := False;
      end;
    end;
  finally
    Bits.Free;
    SetLength(Payload, 0);
  end;
end;

{ --- Построитель подпримитивов --- }

{ Создаёт подпримитивы-отрезки (GDBObjLine) из вершин LWPOLYLINE.
  Если полилиния замкнута (Flags бит 9) — строится замыкающий отрезок. }
procedure BuildLwPolylineSubEntities(
  const HandlerResult: TProxyHandlerResult;
  const Context: TProxySubEntityContext);
begin
  if not HandlerResult.HasVertices then
    Exit;
  if HandlerResult.Vertices.Count < LWPOLYLINE_MIN_VERTEX_COUNT then
    Exit;

  BuildLinesFromVertices(Context,
    HandlerResult.Vertices,
    HandlerResult.Closed,
    Context.PrimitiveLineWeight);
end;

initialization
  { Регистрируем обработчик OpCode=33 (LwPolyline) и построитель подпримитивов.
    Если этот файл исключён из проекта — регистрация не происходит,
    LWPOLYLINE внутри прокси-объектов перестают парситься. }
  TProxyOpCodeDispatcher.RegisterOpCode(
    LWPOLYLINE_OPCODE,
    'LwPolyline',
    @HandleLwPolyline,
    @BuildLwPolylineSubEntities);

end.
