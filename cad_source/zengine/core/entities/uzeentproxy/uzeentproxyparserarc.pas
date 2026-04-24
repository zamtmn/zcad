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
  Модуль: uzeentproxyparserarc
  Назначение: Парсер дуги (OpCode=4, pgcCircularArc) для примитивов внутри
              Proxy объектов.

  Архитектура:
  - Секция initialization регистрирует HandleArc в TProxyOpCodeDispatcher
  - Чтобы отключить парсинг дуг — исключить этот файл из проекта

  Формат данных (AcGiWorldDraw, OpCode = 4 = pgcCircularArc):
    Center      — 3 × double (24 байта) — центр дуги в WCS
    Radius      — 1 × double (8 байт)  — радиус
    Normal      — 3 × double (24 байта) — нормаль (ось Z локальной СК)
    StartVector — 3 × double (24 байта) — вектор начала дуги (в плоскости OCS)
    SweepAngle  — 1 × double (8 байт)  — угол раствора дуги (радианы)
    ArcType     — 1 × int32 (4 байта)  — тип дуги (0 — обычная)

  Построение подпримитива:
  - Вместо тесселяции в набор отрезков создаётся один GDBObjArc
    (по аналогии с uzeentproxyparsertext.pas, где создаётся GDBObjMText).
  - Дуга сама решает вопросы LOD/тесселяции/трансформации при отрисовке.
}

unit uzeentproxyparserarc;
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
  uzeentity,
  uzeentarc,
  uzeentgenericsubentry,
  UGDBVisibleOpenArray,
  uzedrawingdef,
  uzgldrawcontext,
  uzepalette,
  uzestyleslayers,
  uzestyleslinetypes,
  uzegeometrytypes,
  uzegeometry,
  uzeconsts,
  uzcLog;

const
  { OpCode дуги в формате AcGiWorldDraw }
  ARC_OPCODE = 4;

  { Нормаль по умолчанию совпадает с осью Z WCS }
  ARC_Z_AXIS: TzePoint3d = (x: 0.0; y: 0.0; z: 1.0);

  { Порог параллельности для выбора вспомогательной оси }
  ARC_AXIS_THRESHOLD = 0.9;

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
  if Abs(ZAxis.x) < ARC_AXIS_THRESHOLD then
    XAxis := NormalizeVertex(AuxX * ZAxis.z - ZAxis * AuxX.z)
  else
    XAxis := NormalizeVertex(AuxY * ZAxis.z - ZAxis * AuxY.z);

  YAxis := NormalizeVertex(ZAxis * XAxis.x - XAxis * ZAxis.x);

  { Проекция точки на оси OCS }
  Result.x := scalarDot(Point, XAxis);
  Result.y := scalarDot(Point, YAxis);
  Result.z := scalarDot(Point, ZAxis);
end;

{ Вычисляет BBox дуги приблизительно: как BBox круга с тем же центром
  и радиусом. Это заведомо включает любую часть дуги. }
procedure CalcArcBBox(const Center: TzePoint3d; const Radius: Double;
  out BBoxMin, BBoxMax: TzePoint3d);
begin
  BBoxMin.x := Center.x - Radius;
  BBoxMin.y := Center.y - Radius;
  BBoxMin.z := Center.z;
  BBoxMax.x := Center.x + Radius;
  BBoxMax.y := Center.y + Radius;
  BBoxMax.z := Center.z;
end;

{ Нормализует угол в диапазон [0, 2*Pi) }
function NormalizeAngle(Angle: Double): Double;
begin
  Result := Angle;
  while Result < 0 do
    Result := Result + 2 * Pi;
  while Result >= 2 * Pi do
    Result := Result - 2 * Pi;
end;

{ --- Обработчик OpCode --- }

{ Читает данные дуги из потока, вычисляет BBox и сохраняет параметры
  дуги в HandlerResult.ArcItem — без тесселяции.
  Регистрируется в TProxyOpCodeDispatcher как обработчик OpCode=4. }
procedure HandleArc(
  Stream: TProxyByteStream;
  out HandlerResult: TProxyHandlerResult);
var
  Center: TzePoint3d;
  Radius: Double;
  Normal: TzePoint3d;
  StartVector: TzePoint3d;
  SweepAngle: Double;
  StartAngle, EndAngle: Double;
begin
  HandlerResult.Valid := False;
  HandlerResult.HasVertices := False;
  HandlerResult.HasBBox := False;
  HandlerResult.HasArcItem := False;

  { Читаем: Center (24 байта) + Radius (8 байт) + Normal (24 байта)
            + StartVector (24 байта) + SweepAngle (8 байт) + ArcType (4 байта) }
  Center := Stream.ReadVertex;
  Radius := Stream.ReadDouble;
  Normal := Stream.ReadVector;
  StartVector := Stream.ReadVector;
  SweepAngle := Stream.ReadDouble;
  Stream.ReadInt32; { ArcType — тип дуги, пока не используется }

  programlog.LogOutFormatStr(
    'uzeentproxyparserarc: Center=(%.4f,%.4f,%.4f) R=%.4f Sweep=%.4f rad',
    [Center.x, Center.y, Center.z, Radius, SweepAngle], LM_Info);

  { Радиус должен быть положительным }
  if Radius <= 0 then
  begin
    programlog.LogOutFormatStr(
      'uzeentproxyparserarc: Radius=%.4f is invalid, skipping', [Radius], LM_Info);
    Exit;
  end;

  { Если нормаль отличается от Z, переводим центр в OCS }
  if not VectorsAreEqual(Normal, ARC_Z_AXIS) then
  begin
    Center := TransformPointToOCS(Center, Normal);
    StartVector := TransformPointToOCS(StartVector, Normal);
  end;

  { Вычисляем начальный и конечный угол из вектора StartVector и SweepAngle.
    GDBObjArc ожидает StartAngle/EndAngle от оси X локальной СК в радианах. }
  StartAngle := NormalizeAngle(ArcTan2(StartVector.y, StartVector.x));
  EndAngle   := NormalizeAngle(StartAngle + SweepAngle);

  { Вычисляем BBox (грубое приближение — полный круг) }
  CalcArcBBox(Center, Radius, HandlerResult.BBoxMin, HandlerResult.BBoxMax);
  HandlerResult.HasBBox := True;

  { Заполняем параметры дуги для построителя подпримитива }
  HandlerResult.ArcItem.Center := Center;
  HandlerResult.ArcItem.Radius := Radius;
  HandlerResult.ArcItem.StartAngle := StartAngle;
  HandlerResult.ArcItem.EndAngle := EndAngle;
  HandlerResult.ArcItem.Normal := Normal;
  HandlerResult.HasArcItem := True;

  HandlerResult.Valid := True;

  programlog.LogOutFormatStr(
    'uzeentproxyparserarc: OK, ArcItem filled, Start=%.4f End=%.4f BBox=(%.3f,%.3f)-(%.3f,%.3f)',
    [StartAngle, EndAngle,
     HandlerResult.BBoxMin.x, HandlerResult.BBoxMin.y,
     HandlerResult.BBoxMax.x, HandlerResult.BBoxMax.y], LM_Info);
end;

{ --- Построитель подпримитивов --- }

{ Создаёт подпримитив GDBObjArc из TProxyArcItem.
  По аналогии с парсером текста (uzeentproxyparsertext.pas), который
  создаёт GDBObjMText через CreateInitObj(GDBMTextID, ...). }
procedure BuildArcSubEntities(
  const HandlerResult: TProxyHandlerResult;
  const Context: TProxySubEntityContext);
var
  pArc: PGDBObjArc;
  Drawing: PTDrawingDef;
  DC: PTDrawContext;
  LocalCenter: TzePoint3d;
  ActualLW: Integer;
begin
  if not HandlerResult.HasArcItem then
    Exit;
  if (Context.OwnerEntity = nil) or (Context.SubEntitiesArray = nil) then
    Exit;
  if (Context.Drawing = nil) or (Context.DC = nil) then
    Exit;

  Drawing := PTDrawingDef(Context.Drawing);
  DC := PTDrawContext(Context.DC);

  { Пересчитываем центр в локальную систему подпримитива (с учётом
    смещения ручки прокси-объекта) }
  LocalCenter := ProxyToLocalPoint(Context, HandlerResult.ArcItem.Center);

  pArc := pointer(
    PGDBObjEntityOpenArray(Context.SubEntitiesArray)^.CreateInitObj(
      GDBArcID, Context.OwnerEntity));
  if pArc = nil then
    Exit;

  pArc^.Local.p_insert := LocalCenter;
  pArc^.R := HandlerResult.ArcItem.Radius;
  pArc^.StartAngle := HandlerResult.ArcItem.StartAngle;
  pArc^.EndAngle := HandlerResult.ArcItem.EndAngle;
  { Нормаль (ось Z локальной СК) — из примитива; ox/oy восстановит
    CalcObjMatrixWithoutOwner через алгоритм Arbitrary Axis. }
  pArc^.Local.basis.oz := NormalizeVertex(HandlerResult.ArcItem.Normal);

  ActualLW := ResolveLineWeight(Context, Context.PrimitiveLineWeight);

  pArc^.vp.Layer := PGDBLayerProp(Context.OwnerLayer);
  pArc^.vp.LineType := PGDBLtypeProp(Context.OwnerLineType);
  pArc^.vp.LineWeight := ActualLW;
  pArc^.vp.Color := TGDBPaletteColor(
    ResolveColor(Context, Context.PrimitiveColor));
  ApplyLineTypeScale(PGDBObjEntity(pArc), Context);

  pArc^.FormatEntity(Drawing^, DC^);

  programlog.LogOutFormatStr(
    'uzeentproxyparserarc: BuildArcSubEntities ARC at (%.3f,%.3f,%.3f)' +
    ' R=%.4f S=%.4f E=%.4f',
    [LocalCenter.x, LocalCenter.y, LocalCenter.z,
     HandlerResult.ArcItem.Radius,
     HandlerResult.ArcItem.StartAngle,
     HandlerResult.ArcItem.EndAngle], LM_Info);
end;

initialization
  { Регистрируем обработчик OpCode=4 (CircularArc) и построитель
    подпримитивов. Если этот файл исключён из проекта — регистрация не
    происходит, дуги внутри прокси-объектов перестают парситься. }
  TProxyOpCodeDispatcher.RegisterOpCode(
    ARC_OPCODE,
    'CircularArc',
    @HandleArc,
    @BuildArcSubEntities);

end.
