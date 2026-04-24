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
  Модуль: uzeentproxymanager
  Назначение: Менеджер регистрации парсеров примитивов внутри Proxy объектов.

  Архитектура по аналогии с uzeentityfactory.pas:
  - Каждый примитив регистрирует обработчик при инициализации своего модуля
  - Регистрация выполняется через RegisterProxyOpCode()
  - Диспетчеризация по числовому OpCode — HandleOpCode()
  - Чтобы отключить примитив, достаточно исключить его .pas из проекта:
    его initialization не выполнится, OpCode не зарегистрируется, парсинг
    этого примитива не произойдёт без изменения главного модуля

  Интерфейс TProxyOpCodeHandler:
    ParseAndCollect — читает бинарные данные из потока, обновляет BBox
                      и возвращает вершины для отрисовки
}

unit uzeentproxymanager;
{$Mode delphi}{$H+}
{$INCLUDE zengineconfig.inc}

interface

uses
  SysUtils,
  uzeentproxystream,
  uzegeometrytypes,
  UGDBPoint3DArray;

const
  { Максимальный OpCode, поддерживаемый таблицей диспетчеризации }
  PROXY_MAX_OPCODE = 255;

type
  { Контекст для построения подпримитивов внутри Proxy объекта.
    Создаётся в GDBObjAcdProxy.BuildSubEntities и передаётся в builder
    каждого зарегистрированного OpCode. Все поля-указатели типизируются
    как Pointer, чтобы исключить циклическую зависимость между модулями
    парсеров и модулем прокси-сущности: парсер приводит их к реальным
    типам в своём implementation (см. uzeentproxyparser*.pas). }
  TProxySubEntityContext = record
    { Указатель на PGDBObjGenericSubEntry — владелец создаваемого подпримитива.
      Обычно это сам GDBObjAcdProxy, приведённый к PGDBObjGenericSubEntry. }
    OwnerEntity: Pointer;
    { Указатель на PGDBObjEntityOpenArray — массив подпримитивов владельца
      (обычно ConstObjArray прокси-объекта), куда добавляется новый
      подпримитив. }
    SubEntitiesArray: Pointer;
    { Указатель на PDrawingDef — текущий чертёж (нужен для FormatEntity
      подпримитивов и для доступа к таблицам стилей/шрифтов). }
    Drawing: Pointer;
    { Указатель на PDrawContext — контекст отрисовки (нужен для
      FormatEntity подпримитивов). }
    DC: Pointer;
    { Слой владельца прокси-объекта (подпримитивам назначается этот слой). }
    OwnerLayer: Pointer;
    { Тип линии владельца прокси-объекта. }
    OwnerLineType: Pointer;
    { Вес линии владельца прокси-объекта (применяется, если в контуре
      задан ByLayer/ByBlock/ByLwDefault). }
    OwnerLineWeight: Integer;
    { Цвет владельца прокси-объекта. }
    OwnerColor: Integer;
    { Вес линии текущего примитива (из Proxy Graphic SetLineweight OpCode=23).
      Значение копируется из FState.LineWeight парсера в момент обработки
      примитива и передаётся построителю подпримитивов. Если вес —
      ByLayer/ByBlock/ByLwDefault, ResolveLineWeight откатится на
      OwnerLineWeight. }
    PrimitiveLineWeight: Integer;
    { Цвет текущего примитива (из Proxy Graphic SetColor OpCode=14).
      Значение копируется из FState.Color парсера в момент обработки
      примитива и передаётся построителю подпримитивов. Семантика
      совпадает с тем, как обрабатываются примитивы внутри BlockInsert:
      ByBlock (0) откатывается на OwnerColor, ByLayer (-1 или 256) —
      на ClByLayer, явный индекс палитры (1..255) — используется как есть.
      См. ResolveColor в uzeentproxysubentitybuilder. }
    PrimitiveColor: Integer;
    { Масштаб типа линии владельца прокси-объекта (DXF group code 48).
      Подпримитивы наследуют этот масштаб, чтобы пунктир/штрих типа линии
      отображался в том же масштабе, что задан в исходном DXF. По умолчанию
      равен 1 (стандартное значение группового кода 48). }
    OwnerLineTypeScale: Double;
    { Масштаб типа линии текущего примитива (из Proxy Graphic SetLtScale
      OpCode=24). Значение копируется из LtScale парсера в момент обработки
      примитива. Применяется к подпримитиву вместе с OwnerLineTypeScale
      (итоговый scale = Owner * Primitive), чтобы Proxy Graphic-состояние
      тоже влияло на отрисовку штрихов. }
    PrimitiveLineTypeScale: Double;
    { Смещение, которое нужно вычитать из координат proxy graphic,
      чтобы получить локальные координаты относительно точки вставки. }
    GripOffset: TzePoint3d;
  end;
  PProxySubEntityContext = ^TProxySubEntityContext;

  { Данные примитива "окружность", переданные обработчиком.
    Используются построителем для создания GDBObjCircle-подпримитива
    без предварительной тесселяции — сама окружность затем сама решает
    вопросы LOD/тесселяции при отрисовке. }
  TProxyCircleItem = record
    { Центр окружности в OCS (после применения Arbitrary Axis) }
    Center: TzePoint3d;
    { Радиус окружности }
    Radius: Double;
    { Нормаль (ось Z локальной СК) }
    Normal: TzePoint3d;
  end;

  { Данные примитива "дуга", переданные обработчиком.
    Используются построителем для создания GDBObjArc-подпримитива
    без предварительной тесселяции. Углы заданы в радианах. }
  TProxyArcItem = record
    { Центр дуги в OCS (после применения Arbitrary Axis) }
    Center: TzePoint3d;
    { Радиус дуги }
    Radius: Double;
    { Начальный угол (рад), отсчитывается от оси X локальной СК }
    StartAngle: Double;
    { Конечный угол (рад) }
    EndAngle: Double;
    { Нормаль (ось Z локальной СК) }
    Normal: TzePoint3d;
  end;

  { Данные одного текстового примитива, переданные обработчиком.
    Используются в FormatEntity для вызова Representation.DrawTextContent. }
  TProxyTextItem = record
    { Точка вставки текста в OCS }
    Insert: TzePoint3d;
    { Строка текста }
    Text: string;
    { Высота символов }
    Height: Double;
    { Масштаб по ширине }
    WidthFactor: Double;
    { Угол поворота текста (радианы) }
    Angle: Double;
    { Имя шрифта (ANSI, может быть пустым — тогда используется Standard) }
    FontName: string;
    { Имя typeface/FontFamily (для OpCode=38 UnicodeText2, содержит
      человекочитаемое имя шрифта, например "Times New Roman").
      Может быть пустым, если текст-примитив не несёт такой информации
      (OpCode=10 Text1 или OpCode=36 UnicodeText). Используется при
      подборе стиля через GDBTextStyleArray.FindStyleByTypeface. }
    TypeFace: string;
    { Имя файла большого шрифта (для OpCode=38). Сохраняется на случай,
      если в будущем потребуется полноценная поддержка BigFont (asian). }
    BigFontName: string;
    { Вес линии, действовавший на момент создания текста }
    LineWeight: Integer;
    { Цвет, действовавший на момент создания текста }
    Color: Integer;
    { Слой, действовавший на момент создания текста }
    Layer: string;
    { Тип линии, действовавший на момент создания текста }
    Linetype: string;
    { Масштаб типа линии, действовавший на момент создания текста }
    LtScale: Double;
    { Толщина, действовавшая на момент создания текста }
    Thickness: Double;
    { TrueColor, действовавший на момент создания текста }
    TrueColor: Integer;
  end;

  { Результат обработки одного OpCode-примитива.
    Хранит геометрию, BBox и текстовые данные, собранные парсером. }
  TProxyHandlerResult = record
    { Флаг: примитив успешно распаршен }
    Valid: Boolean;
    { Вершины контура для отрисовки (могут быть пустыми) }
    Vertices: GDBPoint3DArray;
    { Флаг: вершины заполнены }
    HasVertices: Boolean;
    { Флаг: контур замкнут (круг, полигон, эллипс и т.д.) }
    Closed: Boolean;
    { Флаг: контур заполнен (SOLID заливка) }
    Filled: Boolean;
    { Минимальная точка BBox примитива }
    BBoxMin: TzePoint3d;
    { Максимальная точка BBox примитива }
    BBoxMax: TzePoint3d;
    { Флаг: BBox вычислен }
    HasBBox: Boolean;
    { Данные текстового примитива (заполняются только для OpCode текста) }
    TextItem: TProxyTextItem;
    { Флаг: TextItem заполнен }
    HasTextItem: Boolean;
    { Данные примитива-окружности (заполняется только для OpCode=2) }
    CircleItem: TProxyCircleItem;
    { Флаг: CircleItem заполнен }
    HasCircleItem: Boolean;
    { Данные примитива-дуги (заполняется только для OpCode=4) }
    ArcItem: TProxyArcItem;
    { Флаг: ArcItem заполнен }
    HasArcItem: Boolean;
  end;

  { Процедура-обработчик одного OpCode.
    Читает данные из потока, заполняет Result. }
  TProxyOpCodeHandlerProc = procedure(
    Stream: TProxyByteStream;
    out HandlerResult: TProxyHandlerResult);

  { Процедура-построитель подпримитивов для заданного OpCode.
    Принимает результат парсинга (HandlerResult) и контекст
    (указатели на владельца, массив подпримитивов, чертёж и DC)
    и создаёт в ConstObjArray владельца соответствующие GDB-объекты
    (GDBObjLine, GDBObjSolid, GDBObjMText и т.д.) с пересчётом
    координат в локальную систему через Context.GripOffset.

    Регистрируется вместе с Handler — каждый модуль-парсер сам
    описывает, как его примитив превращается в подпримитивы
    прокси-объекта. }
  TProxyOpCodeBuilderProc = procedure(
    const HandlerResult: TProxyHandlerResult;
    const Context: TProxySubEntityContext);

  { Запись регистрации одного OpCode }
  TProxyOpCodeEntry = record
    { Флаг: запись заполнена }
    Registered: Boolean;
    { Читаемое название команды для логирования }
    Name: string;
    { Обработчик парсинга бинарного потока }
    Handler: TProxyOpCodeHandlerProc;
    { Построитель подпримитивов (может быть nil, если примитив
      не создаёт собственных подпримитивов) }
    Builder: TProxyOpCodeBuilderProc;
  end;

  { Диспетчер OpCode-обработчиков для Proxy Graphic команд.
    Аналог TEntityFactory из uzeentityfactory.pas, но для внутренних
    примитивов прокси-объекта. }
  TProxyOpCodeDispatcher = class
  private
    class var
      { Таблица зарегистрированных обработчиков, индекс = OpCode }
      FTable: array[0..PROXY_MAX_OPCODE] of TProxyOpCodeEntry;
      { Флаг первой инициализации }
      FInitialized: Boolean;

    { Инициализирует таблицу при первом обращении }
    class procedure EnsureInitialized;

  public
    { Регистрирует обработчик для заданного OpCode без построителя.
      Используется для команд, не создающих подпримитивов. }
    class procedure RegisterOpCode(
      const OpCode: Integer;
      const Name: string;
      const Handler: TProxyOpCodeHandlerProc); overload;

    { Регистрирует обработчик и построитель подпримитивов для OpCode.
      Вызывается в секции initialization каждого модуля-парсера. }
    class procedure RegisterOpCode(
      const OpCode: Integer;
      const Name: string;
      const Handler: TProxyOpCodeHandlerProc;
      const Builder: TProxyOpCodeBuilderProc); overload;

    { Обрабатывает команду с заданным OpCode.
      Если обработчик зарегистрирован — вызывает его и возвращает результат.
      Если нет — Result.Valid = False. }
    class function HandleOpCode(
      const OpCode: Integer;
      Stream: TProxyByteStream;
      out HandlerResult: TProxyHandlerResult): Boolean;

    { Строит подпримитивы для заданного OpCode, если для него
      зарегистрирован Builder. Возвращает True, если построение
      было выполнено. }
    class function BuildSubEntities(
      const OpCode: Integer;
      const HandlerResult: TProxyHandlerResult;
      const Context: TProxySubEntityContext): Boolean;

    { Проверяет, зарегистрирован ли обработчик для OpCode }
    class function IsRegistered(const OpCode: Integer): Boolean;

    { Возвращает количество зарегистрированных обработчиков }
    class function GetRegisteredCount: Integer;
  end;

{ Вспомогательная функция: расширяет BBox точкой Pt.
  Если BBoxInitialized = False — инициализирует BBox этой точкой. }
procedure ExpandBBox(const Pt: TzePoint3d;
  var BBoxMin, BBoxMax: TzePoint3d; var BBoxInitialized: Boolean);

{ Расширяет BBox другим BBox (MinB, MaxB).
  Если BBoxInitialized = False — копирует MinB/MaxB как начальное значение. }
procedure MergeBBox(
  const MinB, MaxB: TzePoint3d;
  var BBoxMin, BBoxMax: TzePoint3d;
  var BBoxInitialized: Boolean);

implementation

uses
  uzcLog;

{ === Вспомогательные функции === }

procedure ExpandBBox(const Pt: TzePoint3d;
  var BBoxMin, BBoxMax: TzePoint3d; var BBoxInitialized: Boolean);
begin
  if not BBoxInitialized then
  begin
    BBoxMin := Pt;
    BBoxMax := Pt;
    BBoxInitialized := True;
  end
  else
  begin
    if Pt.x < BBoxMin.x then BBoxMin.x := Pt.x;
    if Pt.y < BBoxMin.y then BBoxMin.y := Pt.y;
    if Pt.z < BBoxMin.z then BBoxMin.z := Pt.z;
    if Pt.x > BBoxMax.x then BBoxMax.x := Pt.x;
    if Pt.y > BBoxMax.y then BBoxMax.y := Pt.y;
    if Pt.z > BBoxMax.z then BBoxMax.z := Pt.z;
  end;
end;

procedure MergeBBox(
  const MinB, MaxB: TzePoint3d;
  var BBoxMin, BBoxMax: TzePoint3d;
  var BBoxInitialized: Boolean);
begin
  ExpandBBox(MinB, BBoxMin, BBoxMax, BBoxInitialized);
  ExpandBBox(MaxB, BBoxMin, BBoxMax, BBoxInitialized);
end;

{ === TProxyOpCodeDispatcher === }

class procedure TProxyOpCodeDispatcher.EnsureInitialized;
var
  I: Integer;
begin
  if FInitialized then
    Exit;

  { Обнуляем таблицу }
  for I := 0 to PROXY_MAX_OPCODE do
  begin
    FTable[I].Registered := False;
    FTable[I].Name := '';
    FTable[I].Handler := nil;
    FTable[I].Builder := nil;
  end;
  FInitialized := True;
end;

class procedure TProxyOpCodeDispatcher.RegisterOpCode(
  const OpCode: Integer;
  const Name: string;
  const Handler: TProxyOpCodeHandlerProc);
begin
  RegisterOpCode(OpCode, Name, Handler, nil);
end;

class procedure TProxyOpCodeDispatcher.RegisterOpCode(
  const OpCode: Integer;
  const Name: string;
  const Handler: TProxyOpCodeHandlerProc;
  const Builder: TProxyOpCodeBuilderProc);
begin
  EnsureInitialized;

  { Проверяем диапазон OpCode }
  if (OpCode < 0) or (OpCode > PROXY_MAX_OPCODE) then
  begin
    programlog.LogOutFormatStr(
      'uzeentproxymanager: RegisterOpCode - OpCode %d out of range [0..%d]',
      [OpCode, PROXY_MAX_OPCODE], LM_Info);
    Exit;
  end;

  FTable[OpCode].Registered := True;
  FTable[OpCode].Name := Name;
  FTable[OpCode].Handler := Handler;
  FTable[OpCode].Builder := Builder;

  programlog.LogOutFormatStr(
    'uzeentproxymanager: Registered OpCode %d (%s), builder=%s',
    [OpCode, Name, BoolToStr(Assigned(Builder), True)], LM_Info);
end;

class function TProxyOpCodeDispatcher.BuildSubEntities(
  const OpCode: Integer;
  const HandlerResult: TProxyHandlerResult;
  const Context: TProxySubEntityContext): Boolean;
begin
  Result := False;
  EnsureInitialized;

  if (OpCode < 0) or (OpCode > PROXY_MAX_OPCODE) then
    Exit;

  if FTable[OpCode].Registered and Assigned(FTable[OpCode].Builder) then
  begin
    try
      FTable[OpCode].Builder(HandlerResult, Context);
      Result := True;
    except
      on E: Exception do
        programlog.LogOutFormatStr(
          'uzeentproxymanager: BuildSubEntities %d (%s) exception: %s',
          [OpCode, FTable[OpCode].Name, E.Message], LM_Info);
    end;
  end;
end;

class function TProxyOpCodeDispatcher.HandleOpCode(
  const OpCode: Integer;
  Stream: TProxyByteStream;
  out HandlerResult: TProxyHandlerResult): Boolean;
begin
  Result := False;
  HandlerResult.Valid := False;
  HandlerResult.HasVertices := False;
  HandlerResult.Closed := False;
  HandlerResult.Filled := False;
  HandlerResult.HasBBox := False;
  HandlerResult.HasTextItem := False;
  HandlerResult.HasCircleItem := False;
  HandlerResult.HasArcItem := False;

  EnsureInitialized;

  { Проверяем диапазон }
  if (OpCode < 0) or (OpCode > PROXY_MAX_OPCODE) then
    Exit;

  { Вызываем зарегистрированный обработчик }
  if FTable[OpCode].Registered and Assigned(FTable[OpCode].Handler) then
  begin
    try
      FTable[OpCode].Handler(Stream, HandlerResult);
      Result := HandlerResult.Valid;
    except
      on E: Exception do
      begin
        programlog.LogOutFormatStr(
          'uzeentproxymanager: HandleOpCode %d (%s) exception: %s',
          [OpCode, FTable[OpCode].Name, E.Message], LM_Info);
        Result := False;
      end;
    end;
  end;
end;

class function TProxyOpCodeDispatcher.IsRegistered(const OpCode: Integer): Boolean;
begin
  EnsureInitialized;
  Result := (OpCode >= 0) and (OpCode <= PROXY_MAX_OPCODE)
    and FTable[OpCode].Registered;
end;

class function TProxyOpCodeDispatcher.GetRegisteredCount: Integer;
var
  I: Integer;
begin
  EnsureInitialized;
  Result := 0;
  for I := 0 to PROXY_MAX_OPCODE do
    if FTable[I].Registered then
      Inc(Result);
end;

initialization
  TProxyOpCodeDispatcher.EnsureInitialized;

end.
