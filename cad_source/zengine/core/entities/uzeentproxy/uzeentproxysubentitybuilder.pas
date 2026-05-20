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
  Модуль: uzeentproxysubentitybuilder
  Назначение: Вспомогательные процедуры общего назначения для построителей
              подпримитивов внутри Proxy объектов.

  Предоставляет общие примитивы сборки:
  - Перевод WCS-точки прокси-графики в локальные координаты подпримитива
  - Создание GDBObjLine между двумя точками контура
  - Создание GDBObjSolid из многоугольного контура (триангуляция веером)
  - Подстановка веса линии контура с учётом ByLayer/ByBlock/ByLwDefault

  Используется модулями-парсерами (uzeentproxyparser*.pas) для построения
  подпримитивов в ConstObjArray прокси-объекта. Каждый парсер отвечает
  за создание своих подпримитивов; этот модуль лишь инкапсулирует общую
  логику, чтобы не дублировать её в каждом парсере.

  Зависимости:
  - uzeentproxymanager — описание TProxySubEntityContext
  - uzeentityfactory   — фабрики ENTF_CreateLine/ENTF_CreateSolid
  - uzeentsubordinated, uzeentgenericsubentry — базовые типы подпримитивов

  Примечание: этот модуль намеренно НЕ знает о GDBObjAcdProxy, чтобы не
  создавать циклическую зависимость. Все данные владельца передаются
  через TProxySubEntityContext в виде типизированных Pointer-ов.
}

unit uzeentproxysubentitybuilder;
{$Mode delphi}{$H+}
{$INCLUDE zengineconfig.inc}

interface

uses
  uzeentproxymanager,
  uzegeometrytypes,
  UGDBPoint3DArray,
  uzeentity;

{ Переводит точку прокси-графики в локальные координаты подпримитива,
  вычитая Context.GripOffset. Используется всеми парсерами для
  корректного позиционирования подпримитивов относительно ручки
  прокси-объекта. }
function ProxyToLocalPoint(const Context: TProxySubEntityContext;
  const Pt: TzePoint3d): TzePoint3d;

{ Вес линии, который следует применить к подпримитиву.
  Если ContourLineWeight — одно из специальных значений (ByLayer/
  ByBlock/ByLwDefault), возвращает OwnerLineWeight из контекста,
  иначе — возвращает исходный вес линии контура. }
function ResolveLineWeight(const Context: TProxySubEntityContext;
  const ContourLineWeight: Integer): Integer;

{ Цвет, который следует применить к подпримитиву прокси-объекта.
  Повторяет поведение примитивов внутри BlockInsert:
    - ByBlock (ClByBlock = 0) — подпримитив наследует цвет владельца
      (OwnerColor), чтобы при изменении цвета прокси-объекта поменялся
      и цвет "блочных" примитивов;
    - ByLayer (ClByLayer = 256 или PROXY_DEFAULT_COLOR = -1) — подпримитив
      получает значение ClByLayer, чтобы реально отображаться цветом
      своего слоя, а не цветом контейнера (прокси-объекта);
    - явный индекс палитры (1..255) — используется как есть.
  ContourColor — цвет, зафиксированный парсером на момент обработки
  примитива (FState.Color, см. uzeentproxygraphicparser). }
function ResolveColor(const Context: TProxySubEntityContext;
  const ContourColor: Integer): Integer;

{ Итоговый масштаб типа линии для подпримитива:
  OwnerLineTypeScale (DXF group code 48 владельца) умножается на
  PrimitiveLineTypeScale (Proxy Graphic OpCode=24 для текущего примитива).
  Нули и отрицательные значения трактуются как 1, чтобы не
  «обнулить» пунктир при повреждённых данных. }
function ResolveLineTypeScale(
  const Context: TProxySubEntityContext): Double;

{ Применяет вычисленный масштаб типа линии к созданному подпримитиву.
  Вызывается после ENTF_CreateLine/ENTF_CreateSolid и перед
  FormatEntity, чтобы подпримитив использовал корректный масштаб
  при отрисовке штрихов. }
procedure ApplyLineTypeScale(
  SubEnt: PGDBObjEntity;
  const Context: TProxySubEntityContext);

{ Создаёт подпримитив GDBObjLine между двумя точками контура.
  Точки P1 и P2 задаются в координатах прокси-графики — внутри
  процедуры они пересчитываются в локальную систему через
  ProxyToLocalPoint. ContourLineWeight — вес линии для данного
  контура (см. ResolveLineWeight).

  Созданный подпримитив добавляется в Context.SubEntitiesArray и
  получает атрибуты владельца (слой/тип линии/цвет). После
  создания выполняется FormatEntity, чтобы подпримитив был готов
  к отрисовке. }
procedure BuildLineSubEntity(const Context: TProxySubEntityContext;
  const P1, P2: TzePoint3d; const ContourLineWeight: Integer);

{ Создаёт серию GDBObjLine по всем рёбрам контура Vertices.
  Если IsClosed = True и количество вершин >= 3 — замыкает контур
  отрезком последняя→первая. ContourLineWeight применяется ко
  всем создаваемым отрезкам. }
procedure BuildLinesFromVertices(const Context: TProxySubEntityContext;
  const Vertices: GDBPoint3DArray;
  const IsClosed: Boolean;
  const ContourLineWeight: Integer);

{ Создаёт подпримитивы GDBObjSolid из заполненного многоугольного
  контура (заливка полигона/шелла/штриховки). Многоугольник
  триангулируется веером от вершины 0. Для 3 вершин создаётся
  один треугольник, для N >= 4 — (N - 2) треугольников.

  Все точки Vertices — в координатах прокси-графики и пересчитываются
  в локальную систему через ProxyToLocalPoint внутри процедуры. }
procedure BuildSolidFromVertices(const Context: TProxySubEntityContext;
  const Vertices: GDBPoint3DArray;
  const ContourLineWeight: Integer);

implementation

uses
  uzeentitiesmanager,
  uzgldrawcontext,
  uzedrawingdef,
  uzeentsubordinated,
  uzeentgenericsubentry,
  UGDBVisibleOpenArray,
  uzegeometry,
  uzestyleslayers,
  uzestyleslinetypes,
  uzepalette,
  uzeconsts,
  gzctnrVectorTypes,
  uzbLogIntf,
  uzclog;

{ --- Локальные утилиты --- }

function ProxyToLocalPoint(const Context: TProxySubEntityContext;
  const Pt: TzePoint3d): TzePoint3d;
begin
  Result := VertexSub(Pt, Context.GripOffset);
end;

function ResolveLineWeight(const Context: TProxySubEntityContext;
  const ContourLineWeight: Integer): Integer;
begin
  Result := ContourLineWeight;
  if (Result = LnWtByLayer)
    or (Result = LnWtByBlock)
    or (Result = LnWtByLwDefault) then
    Result := Context.OwnerLineWeight;
end;

function ResolveColor(const Context: TProxySubEntityContext;
  const ContourColor: Integer): Integer;
begin
  { ByBlock (0): подпримитив должен рендериться цветом владельца —
    то же поведение, что у примитивов внутри BlockInsert. }
  if ContourColor = ClByBlock then
  begin
    Result := Context.OwnerColor;
    Exit;
  end;
  { ByLayer: AutoCAD пишет 256 в DXF; внутренний парсер прокси-графики
    хранит -1 (см. PROXY_DEFAULT_COLOR). Любое из этих значений означает
    "взять цвет из слоя подпримитива", поэтому возвращаем ClByLayer
    независимо от того, какое из двух представлений попало в поток. }
  if (ContourColor = ClByLayer) or (ContourColor < 0) then
  begin
    Result := ClByLayer;
    Exit;
  end;
  { Явный цвет 1..255 — применяется как есть. }
  Result := ContourColor;
end;

function ResolveLineTypeScale(
  const Context: TProxySubEntityContext): Double;
var
  Owner, Primitive: Double;
begin
  Owner := Context.OwnerLineTypeScale;
  if Owner <= 0 then
    Owner := 1.0;
  Primitive := Context.PrimitiveLineTypeScale;
  if Primitive <= 0 then
    Primitive := 1.0;
  Result := Owner;
end;

procedure ApplyLineTypeScale(
  SubEnt: PGDBObjEntity;
  const Context: TProxySubEntityContext);
begin
  if SubEnt = nil then
    Exit;
  SubEnt^.vp.LineTypeScale := ResolveLineTypeScale(Context);
end;

{ --- Построители подпримитивов --- }

procedure BuildLineSubEntity(const Context: TProxySubEntityContext;
  const P1, P2: TzePoint3d; const ContourLineWeight: Integer);
var
  LocalP1, LocalP2: TzePoint3d;
  SubEnt: PGDBObjEntity;
  ActualLW: Integer;
  ActualColor: Integer;
begin
  if (Context.OwnerEntity = nil) or (Context.SubEntitiesArray = nil) then
    Exit;

  LocalP1 := ProxyToLocalPoint(Context, P1);
  LocalP2 := ProxyToLocalPoint(Context, P2);
  ActualLW := ResolveLineWeight(Context, ContourLineWeight);
  ActualColor := ResolveColor(Context, Context.PrimitiveColor);

  SubEnt := ENTF_CreateLine(
    PGDBObjGenericSubEntry(Context.OwnerEntity),
    PGDBObjEntityOpenArray(Context.SubEntitiesArray),
    PGDBLayerProp(Context.OwnerLayer),
    PGDBLtypeProp(Context.OwnerLineType),
    ActualLW,
    TGDBPaletteColor(ActualColor),
    LocalP1, LocalP2);

  ApplyLineTypeScale(SubEnt, Context);

  if (SubEnt <> nil)
    and (Context.Drawing <> nil) and (Context.DC <> nil) then
    SubEnt^.FormatEntity(
      PTDrawingDef(Context.Drawing)^,
      PTDrawContext(Context.DC)^);
end;

procedure BuildLinesFromVertices(const Context: TProxySubEntityContext;
  const Vertices: GDBPoint3DArray;
  const IsClosed: Boolean;
  const ContourLineWeight: Integer);
var
  ir: itrec;
  pV, pVNext: PzePoint3d;
  FirstV, LastV: TzePoint3d;
  HasFirst: Boolean;
begin
  if Vertices.Count < 2 then
    Exit;

  HasFirst := False;
  FirstV := NulVertex;
  LastV := NulVertex;

  pV := Vertices.beginiterate(ir);
  if pV = nil then
    Exit;

  if not HasFirst then
  begin
    FirstV := pV^;
    HasFirst := True;
  end;
  LastV := pV^;

  pVNext := Vertices.iterate(ir);
  while pVNext <> nil do
  begin
    BuildLineSubEntity(Context, pV^, pVNext^, ContourLineWeight);
    LastV := pVNext^;
    pV := pVNext;
    pVNext := Vertices.iterate(ir);
  end;

  { Замыкаем контур отрезком последняя → первая точка,
    если это требуется для замкнутых примитивов. }
  if IsClosed and HasFirst and (Vertices.Count >= 3) then
    BuildLineSubEntity(Context, LastV, FirstV, ContourLineWeight);
end;

procedure BuildSolidFromVertices(const Context: TProxySubEntityContext;
  const Vertices: GDBPoint3DArray;
  const ContourLineWeight: Integer);
var
  ir: itrec;
  pV: PzePoint3d;
  Points: array of TzePoint3d;
  PointCount, I: Integer;
  SubEnt: PGDBObjEntity;
  ActualLW: Integer;
  ActualColor: Integer;
begin
  if Vertices.Count < 3 then
    Exit;
  if (Context.OwnerEntity = nil) or (Context.SubEntitiesArray = nil) then
    Exit;

  PointCount := Vertices.Count;
  SetLength(Points, PointCount);
  I := 0;
  pV := Vertices.beginiterate(ir);
  while pV <> nil do
  begin
    Points[I] := ProxyToLocalPoint(Context, pV^);
    Inc(I);
    pV := Vertices.iterate(ir);
  end;

  ActualLW := ResolveLineWeight(Context, ContourLineWeight);
  ActualColor := ResolveColor(Context, Context.PrimitiveColor);

  { Триангуляция веером: вершина 0 — общая для всех треугольников }
  for I := 1 to PointCount - 2 do
  begin
    SubEnt := ENTF_CreateSolid(
      PGDBObjGenericSubEntry(Context.OwnerEntity),
      PGDBObjEntityOpenArray(Context.SubEntitiesArray),
      PGDBLayerProp(Context.OwnerLayer),
      PGDBLtypeProp(Context.OwnerLineType),
      ActualLW,
      TGDBPaletteColor(ActualColor),
      Points[0], Points[I], Points[I + 1]);

    ApplyLineTypeScale(SubEnt, Context);

    if (SubEnt <> nil)
      and (Context.Drawing <> nil) and (Context.DC <> nil) then
      SubEnt^.FormatEntity(
        PTDrawingDef(Context.Drawing)^,
        PTDrawContext(Context.DC)^);
  end;
end;

end.
