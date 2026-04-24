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
  Модуль: uzeentproxyparsercircle
  Назначение: Парсер круга (OpCode=2) для примитивов внутри Proxy объектов.

  Архитектура:
  - Секция initialization регистрирует HandleCircle в TProxyOpCodeDispatcher
  - Чтобы отключить парсинг кругов — исключить этот файл из проекта
  - Изменений в главном модуле uzeentacdproxy.pas не требуется

  Формат данных (AcGiWorldDraw, OpCode = 2 = pgcCircle):
    Center  — 3 × double (24 байта) — центр в WCS
    Radius  — 1 × double (8 байт)  — радиус
    Normal  — 3 × double (24 байта) — нормаль (ось Z локальной СК)

  Построение подпримитива:
  - Вместо тесселяции в набор отрезков создаётся один GDBObjCircle
    (по аналогии с uzeentproxyparsertext.pas, где создаётся GDBObjMText).
  - Круг сам решает вопросы LOD/тесселяции/трансформации при отрисовке.
}

unit uzeentproxyparsercircle;
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
  uzeentcircle,
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
  { OpCode круга в формате AcGiWorldDraw }
  CIRCLE_OPCODE = 2;

  { Нормаль по умолчанию совпадает с осью Z WCS }
  CIRCLE_Z_AXIS: TzePoint3d = (x: 0.0; y: 0.0; z: 1.0);

  { Порог параллельности для выбора вспомогательной оси }
  CIRCLE_AXIS_THRESHOLD = 0.9;

{ --- Вспомогательные процедуры --- }

{ Проверяет, совпадают ли два вектора с точностью Epsilon }
function VectorsAreEqual(const V1, V2: TzePoint3d;
  const Epsilon: Double = 1e-9): Boolean;
begin
  Result := (Abs(V1.x - V2.x) <= Epsilon)
    and (Abs(V1.y - V2.y) <= Epsilon)
    and (Abs(V1.z - V2.z) <= Epsilon);
end;

{ Вычисляет BBox круга в плоскости XY с учётом позиции Center и Radius }
procedure CalcCircleBBox(const Center: TzePoint3d; const Radius: Double;
  out BBoxMin, BBoxMax: TzePoint3d);
begin
  BBoxMin.x := Center.x - Radius;
  BBoxMin.y := Center.y - Radius;
  BBoxMin.z := Center.z;
  BBoxMax.x := Center.x + Radius;
  BBoxMax.y := Center.y + Radius;
  BBoxMax.z := Center.z;
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
  if Abs(ZAxis.x) < CIRCLE_AXIS_THRESHOLD then
    XAxis := NormalizeVertex(AuxX * ZAxis.z - ZAxis * AuxX.z)
  else
    XAxis := NormalizeVertex(AuxY * ZAxis.z - ZAxis * AuxY.z);

  YAxis := NormalizeVertex(ZAxis * XAxis.x - XAxis * ZAxis.x);

  { Проекция точки на оси OCS }
  Result.x := scalarDot(Point, XAxis);
  Result.y := scalarDot(Point, YAxis);
  Result.z := scalarDot(Point, ZAxis);
end;

{ --- Обработчик OpCode --- }

{ Читает данные круга из потока, вычисляет BBox и сохраняет параметры
  круга в HandlerResult.CircleItem — без тесселяции.
  Регистрируется в TProxyOpCodeDispatcher как обработчик OpCode=2. }
procedure HandleCircle(
  Stream: TProxyByteStream;
  out HandlerResult: TProxyHandlerResult);
var
  Center: TzePoint3d;
  Radius: Double;
  Normal: TzePoint3d;
begin
  HandlerResult.Valid := False;
  HandlerResult.HasVertices := False;
  HandlerResult.HasBBox := False;
  HandlerResult.HasCircleItem := False;

  { Читаем: Center (24 байта) + Radius (8 байт) + Normal (24 байта) }
  Center := Stream.ReadVertex;
  Radius := Stream.ReadDouble;
  Normal := Stream.ReadVector;

  programlog.LogOutFormatStr(
    'uzeentproxyparsercircle: Center=(%.4f,%.4f,%.4f) Radius=%.4f',
    [Center.x, Center.y, Center.z, Radius], LM_Info);

  { Радиус должен быть положительным }
  if Radius <= 0 then
  begin
    programlog.LogOutFormatStr(
      'uzeentproxyparsercircle: Radius=%.4f is invalid, skipping',
      [Radius], LM_Info);
    Exit;
  end;

  { Если нормаль отличается от Z, переводим центр в OCS }
  if not VectorsAreEqual(Normal, CIRCLE_Z_AXIS) then
    Center := TransformPointToOCS(Center, Normal);

  { Вычисляем BBox (аппроксимационно, в плоскости XY OCS) }
  CalcCircleBBox(Center, Radius, HandlerResult.BBoxMin, HandlerResult.BBoxMax);
  HandlerResult.HasBBox := True;

  { Заполняем параметры круга для построителя подпримитива }
  HandlerResult.CircleItem.Center := Center;
  HandlerResult.CircleItem.Radius := Radius;
  HandlerResult.CircleItem.Normal := Normal;
  HandlerResult.HasCircleItem := True;
  HandlerResult.Closed := True;

  HandlerResult.Valid := True;

  programlog.LogOutFormatStr(
    'uzeentproxyparsercircle: OK, CircleItem filled, BBox=(%.3f,%.3f)-(%.3f,%.3f)',
    [HandlerResult.BBoxMin.x, HandlerResult.BBoxMin.y,
     HandlerResult.BBoxMax.x, HandlerResult.BBoxMax.y], LM_Info);
end;

{ --- Построитель подпримитивов --- }

{ Создаёт подпримитив GDBObjCircle из TProxyCircleItem.
  По аналогии с парсером текста (uzeentproxyparsertext.pas), который
  создаёт GDBObjMText через CreateInitObj(GDBMTextID, ...). }
procedure BuildCircleSubEntities(
  const HandlerResult: TProxyHandlerResult;
  const Context: TProxySubEntityContext);
var
  pCircle: PGDBObjCircle;
  Drawing: PTDrawingDef;
  DC: PTDrawContext;
  LocalCenter: TzePoint3d;
  ActualLW: Integer;
begin
  if not HandlerResult.HasCircleItem then
    Exit;
  if (Context.OwnerEntity = nil) or (Context.SubEntitiesArray = nil) then
    Exit;
  if (Context.Drawing = nil) or (Context.DC = nil) then
    Exit;

  Drawing := PTDrawingDef(Context.Drawing);
  DC := PTDrawContext(Context.DC);

  { Пересчитываем центр в локальную систему подпримитива (с учётом
    смещения ручки прокси-объекта) }
  LocalCenter := ProxyToLocalPoint(Context, HandlerResult.CircleItem.Center);

  pCircle := pointer(
    PGDBObjEntityOpenArray(Context.SubEntitiesArray)^.CreateInitObj(
      GDBCircleID, Context.OwnerEntity));
  if pCircle = nil then
    Exit;

  pCircle^.Local.p_insert := LocalCenter;
  pCircle^.Radius := HandlerResult.CircleItem.Radius;
  { Нормаль (ось Z локальной СК) — из примитива; ox/oy восстановит
    CalcObjMatrixWithoutOwner через алгоритм Arbitrary Axis. }
  pCircle^.Local.basis.oz := NormalizeVertex(HandlerResult.CircleItem.Normal);

  ActualLW := ResolveLineWeight(Context, Context.PrimitiveLineWeight);

  pCircle^.vp.Layer := PGDBLayerProp(Context.OwnerLayer);
  pCircle^.vp.LineType := PGDBLtypeProp(Context.OwnerLineType);
  pCircle^.vp.LineWeight := ActualLW;
  pCircle^.vp.Color := TGDBPaletteColor(
    ResolveColor(Context, Context.PrimitiveColor));
  ApplyLineTypeScale(PGDBObjEntity(pCircle), Context);

  pCircle^.FormatEntity(Drawing^, DC^);

  programlog.LogOutFormatStr(
    'uzeentproxyparsercircle: BuildCircleSubEntities CIRCLE at (%.3f,%.3f,%.3f) R=%.4f',
    [LocalCenter.x, LocalCenter.y, LocalCenter.z,
     HandlerResult.CircleItem.Radius], LM_Info);
end;

initialization
  { Регистрируем обработчик OpCode=2 (Circle) и построитель подпримитивов.
    Если этот файл исключён из проекта — регистрация не происходит,
    круги внутри прокси-объектов перестают парситься без изменений в
    главном модуле. }
  TProxyOpCodeDispatcher.RegisterOpCode(
    CIRCLE_OPCODE,
    'Circle',
    @HandleCircle,
    @BuildCircleSubEntities);

end.
