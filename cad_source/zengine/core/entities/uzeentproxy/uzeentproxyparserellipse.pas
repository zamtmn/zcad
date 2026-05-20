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
  Модуль: uzeentproxyparserellipse
  Назначение: Парсер эллипса и эллиптической дуги (OpCode=44, pgcEllipticArc)
              для примитивов внутри Proxy объектов.

  Архитектура:
  - Секция initialization регистрирует HandleEllipse в TProxyOpCodeDispatcher
  - Чтобы отключить парсинг эллипсов — исключить этот файл из проекта
  - При StartParam=0 и EndParam=2*Pi объект является полным эллипсом

  Формат данных (AcGiWorldDraw, OpCode = 44 = pgcEllipticArc):
    Center          — 3 × double (24 байта) — центр эллипса в WCS
    Normal          — 3 × double (24 байта) — нормаль (ось Z локальной СК)
    MajorAxisVector — 3 × double (24 байта) — вектор большой полуоси (длина = MajorRadius)
    MinorAxisRatio  — 1 × double (8 байт)  — соотношение малой оси к большой (0..1)
    StartParam      — 1 × double (8 байт)  — начальный параметр (радианы, 0..2*Pi)
    EndParam        — 1 × double (8 байт)  — конечный параметр (радианы, 0..2*Pi)

  Тесселяция:
  - Эллипс аппроксимируется ELLIPSE_SEGMENT_COUNT отрезками
  - Для дуги — пропорционально углу раствора
  - Тесселяция выполняется параметрически: P(t) = Center + cos(t)*A + sin(t)*B,
    где A — вектор большой оси, B — вектор малой оси
}

unit uzeentproxyparserellipse;
{$Mode delphi}{$H+}
{$INCLUDE zengineconfig.inc}

interface

{ Публичный интерфейс не нужен — регистрация происходит автоматически
  при загрузке модуля через секцию initialization }

implementation

uses
  SysUtils,
  Math,
  uzeentproxystream,
  uzeentproxymanager,
  uzeentproxysubentitybuilder,
  uzegeometrytypes,
  uzegeometry,
  UGDBPoint3DArray,
  gzctnrVectorTypes,
  uzcLog;

const
  { OpCode эллиптической дуги в формате AcGiWorldDraw }
  ELLIPSE_OPCODE = 44;

  { Количество отрезков тесселяции полного эллипса }
  ELLIPSE_SEGMENT_COUNT = 64;

  { Минимальное количество отрезков тесселяции }
  ELLIPSE_MIN_SEGMENT_COUNT = 4;

  { Нормаль по умолчанию совпадает с осью Z WCS }
  ELLIPSE_Z_AXIS: TzePoint3d = (x: 0.0; y: 0.0; z: 1.0);

  { Порог параллельности для выбора вспомогательной оси }
  ELLIPSE_AXIS_THRESHOLD = 0.9;

  { Максимально допустимое соотношение осей }
  ELLIPSE_MIN_AXIS_RATIO = 1e-9;

{ --- Вспомогательные процедуры --- }

{ Проверяет, совпадают ли два вектора с точностью Epsilon }
function VectorsAreEqual(const V1, V2: TzePoint3d;
  const Epsilon: Double = 1e-9): Boolean;
begin
  Result := (Abs(V1.x - V2.x) <= Epsilon)
    and (Abs(V1.y - V2.y) <= Epsilon)
    and (Abs(V1.z - V2.z) <= Epsilon);
end;

{ Преобразует точку Point из WCS в OCS по нормали Normal.
  Использует алгоритм произвольной оси AutoCAD. }
function TransformPointToOCS(const Point, Normal: TzePoint3d): TzePoint3d;
const
  AuxX: TzePoint3d = (x: 1.0; y: 0.0; z: 0.0);
  AuxY: TzePoint3d = (x: 0.0; y: 1.0; z: 0.0);
var
  ZAxis, XAxis, YAxis: TzePoint3d;
begin
  ZAxis := NormalizeVertex(Normal);

  { Выбираем вспомогательную ось для построения OCS }
  if Abs(ZAxis.x) < ELLIPSE_AXIS_THRESHOLD then
    XAxis := NormalizeVertex(AuxX * ZAxis.z - ZAxis * AuxX.z)
  else
    XAxis := NormalizeVertex(AuxY * ZAxis.z - ZAxis * AuxY.z);

  YAxis := NormalizeVertex(ZAxis * XAxis.x - XAxis * ZAxis.x);

  { Проекция точки на оси OCS }
  Result.x := scalarDot(Point, XAxis);
  Result.y := scalarDot(Point, YAxis);
  Result.z := scalarDot(Point, ZAxis);
end;

{ Вычисляет количество отрезков тесселяции пропорционально параметрическому
  диапазону дуги. }
function CalcEllipseSegmentCount(const StartParam, EndParam: Double): Integer;
var
  ParamRange: Double;
begin
  ParamRange := Abs(EndParam - StartParam);
  Result := Round(ELLIPSE_SEGMENT_COUNT * ParamRange / (2 * Pi));
  if Result < ELLIPSE_MIN_SEGMENT_COUNT then
    Result := ELLIPSE_MIN_SEGMENT_COUNT;
  if Result > ELLIPSE_SEGMENT_COUNT then
    Result := ELLIPSE_SEGMENT_COUNT;
end;

{ Тесселирует эллипс/эллиптическую дугу в массив вершин.
  Использует параметрическое уравнение: P(t) = Center + cos(t)*MajorAxis + sin(t)*MinorAxis }
procedure TessellateEllipse(const Center, MajorAxis, MinorAxis: TzePoint3d;
  const StartParam, EndParam: Double; var Vertices: GDBPoint3DArray);
var
  SegmentCount: Integer;
  I: Integer;
  Param: Double;
  Pt: TzePoint3d;
begin
  SegmentCount := CalcEllipseSegmentCount(StartParam, EndParam);
  Vertices.init(SegmentCount + 1);

  { Тесселируем параметрически — SegmentCount+1 вершин (включая конечную) }
  for I := 0 to SegmentCount do
  begin
    Param := StartParam + (EndParam - StartParam) * I / SegmentCount;
    Pt.x := Center.x + Cos(Param) * MajorAxis.x + Sin(Param) * MinorAxis.x;
    Pt.y := Center.y + Cos(Param) * MajorAxis.y + Sin(Param) * MinorAxis.y;
    Pt.z := Center.z + Cos(Param) * MajorAxis.z + Sin(Param) * MinorAxis.z;
    Vertices.PushBackData(Pt);
  end;
end;

{ Вычисляет BBox эллипса по тесселированным вершинам }
procedure CalcEllipseBBoxFromVertices(const Vertices: GDBPoint3DArray;
  out BBoxMin, BBoxMax: TzePoint3d);
var
  Iter: itrec;
  Pt: PzePoint3d;
  Initialized: Boolean;
begin
  BBoxMin.x := 0; BBoxMin.y := 0; BBoxMin.z := 0;
  BBoxMax := BBoxMin;
  Initialized := False;

  Pt := Vertices.beginiterate(Iter);
  while Pt <> nil do
  begin
    if not Initialized then
    begin
      BBoxMin := Pt^;
      BBoxMax := Pt^;
      Initialized := True;
    end
    else
    begin
      if Pt^.x < BBoxMin.x then BBoxMin.x := Pt^.x;
      if Pt^.y < BBoxMin.y then BBoxMin.y := Pt^.y;
      if Pt^.z < BBoxMin.z then BBoxMin.z := Pt^.z;
      if Pt^.x > BBoxMax.x then BBoxMax.x := Pt^.x;
      if Pt^.y > BBoxMax.y then BBoxMax.y := Pt^.y;
      if Pt^.z > BBoxMax.z then BBoxMax.z := Pt^.z;
    end;
    Pt := Vertices.iterate(Iter);
  end;
end;

{ --- Обработчик OpCode --- }

{ Читает данные эллипса/эллиптической дуги из потока, тесселирует контур.
  Регистрируется в TProxyOpCodeDispatcher как обработчик OpCode=44. }
procedure HandleEllipse(
  Stream: TProxyByteStream;
  out HandlerResult: TProxyHandlerResult);
var
  Center: TzePoint3d;
  Normal: TzePoint3d;
  MajorAxisVector: TzePoint3d;
  MinorAxisRatio: Double;
  StartParam: Double;
  EndParam: Double;
  MajorRadius: Double;
  MinorAxis: TzePoint3d;
  PerpendicularAxis: TzePoint3d;
begin
  HandlerResult.Valid := False;
  HandlerResult.HasVertices := False;
  HandlerResult.HasBBox := False;

  { Читаем: Center + Normal + MajorAxisVector + MinorAxisRatio
            + StartParam + EndParam }
  Center := Stream.ReadVertex;
  Normal := Stream.ReadVector;
  MajorAxisVector := Stream.ReadVector;
  MinorAxisRatio := Stream.ReadDouble;
  StartParam := Stream.ReadDouble;
  EndParam := Stream.ReadDouble;

  programlog.LogOutFormatStr(
    'uzeentproxyparserellipse: Center=(%.4f,%.4f,%.4f) Ratio=%.4f' +
    ' Start=%.4f End=%.4f',
    [Center.x, Center.y, Center.z, MinorAxisRatio,
     StartParam, EndParam], LM_Info);

  { Соотношение осей должно быть положительным }
  if MinorAxisRatio < ELLIPSE_MIN_AXIS_RATIO then
  begin
    programlog.LogOutFormatStr(
      'uzeentproxyparserellipse: MinorAxisRatio=%.9f is invalid, skipping',
      [MinorAxisRatio], LM_Info);
    Exit;
  end;

  { Если нормаль отличается от Z, переводим центр в OCS }
  if not VectorsAreEqual(Normal, ELLIPSE_Z_AXIS) then
  begin
    Center := TransformPointToOCS(Center, Normal);
    MajorAxisVector := TransformPointToOCS(MajorAxisVector, Normal);
  end;

  { Длина большой полуоси = длина вектора MajorAxisVector }
  MajorRadius := Sqrt(
    MajorAxisVector.x * MajorAxisVector.x +
    MajorAxisVector.y * MajorAxisVector.y +
    MajorAxisVector.z * MajorAxisVector.z);

  { Вычисляем вектор малой полуоси через перпендикуляр к Normal × MajorAxisVector }
  PerpendicularAxis := NormalizeVertex(Normal * MajorAxisVector.x
    - MajorAxisVector * Normal.x);

  MinorAxis.x := PerpendicularAxis.x * MajorRadius * MinorAxisRatio;
  MinorAxis.y := PerpendicularAxis.y * MajorRadius * MinorAxisRatio;
  MinorAxis.z := PerpendicularAxis.z * MajorRadius * MinorAxisRatio;

  { Тесселируем эллипс/эллиптическую дугу }
  TessellateEllipse(Center, MajorAxisVector, MinorAxis,
    StartParam, EndParam, HandlerResult.Vertices);
  HandlerResult.HasVertices := True;

  { Полный эллипс замкнут (параметры от 0 до 2π) }
  HandlerResult.Closed := Abs(EndParam - StartParam - 2 * Pi) < 1e-6;

  { Вычисляем BBox по тесселированным вершинам }
  CalcEllipseBBoxFromVertices(HandlerResult.Vertices,
    HandlerResult.BBoxMin, HandlerResult.BBoxMax);
  HandlerResult.HasBBox := True;

  HandlerResult.Valid := True;

  programlog.LogOutFormatStr(
    'uzeentproxyparserellipse: OK, %d vertices, BBox=(%.3f,%.3f)-(%.3f,%.3f)',
    [HandlerResult.Vertices.Count,
     HandlerResult.BBoxMin.x, HandlerResult.BBoxMin.y,
     HandlerResult.BBoxMax.x, HandlerResult.BBoxMax.y], LM_Info);
end;

{ --- Построитель подпримитивов --- }

{ Создаёт подпримитивы-отрезки (GDBObjLine) из тесселированных вершин
  эллипса или эллиптической дуги. Для замкнутого эллипса добавляется
  замыкающий отрезок. Заливка, если активна, приводит к созданию
  солидов через триангуляцию веером. }
procedure BuildEllipseSubEntities(
  const HandlerResult: TProxyHandlerResult;
  const Context: TProxySubEntityContext);
begin
  if not HandlerResult.HasVertices then
    Exit;

  if HandlerResult.Filled and HandlerResult.Closed then
    BuildSolidFromVertices(Context,
      HandlerResult.Vertices,
      Context.PrimitiveLineWeight);

  BuildLinesFromVertices(Context,
    HandlerResult.Vertices,
    HandlerResult.Closed,
    Context.PrimitiveLineWeight);
end;

initialization
  { Регистрируем обработчик OpCode=44 (EllipticArc) и построитель
    подпримитивов. Если этот файл исключён из проекта — регистрация не
    происходит, эллипсы и эллиптические дуги внутри прокси-объектов
    перестают парситься. }
  TProxyOpCodeDispatcher.RegisterOpCode(
    ELLIPSE_OPCODE,
    'EllipticArc',
    @HandleEllipse,
    @BuildEllipseSubEntities);

end.
