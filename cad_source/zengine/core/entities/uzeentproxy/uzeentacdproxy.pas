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
  Модуль: uzeentacdproxy
  Назначение: Поддержка прокси-объектов AutoCAD (ACAD_PROXY_ENTITY) в ZCAD.

  Архитектура:
  - ProxyEntity наследуется от GDBObjComplex и является контейнером
    подпримитивов (линии, полилинии, окружности, дуги, солиды, текст).
  - Парсинг Proxy Graphic выполняется в FormatEntity через
    TProxyGraphicParser.
  - Каждый тип примитива внутри прокси регистрируется в
    TProxyOpCodeDispatcher в своём модуле.
  - После парсинга контуры преобразуются в подпримитивы и
    добавляются в ConstObjArray.
  - Отрисовка делегируется подпримитивам через механизм
    GDBObjComplex: каждый подпримитив имеет собственную
    Representation, цвет, толщину линии и тип линии.

  Зависимости от модулей-парсеров:
  - uzeentproxyparsercircle    — OpCode=2
  - uzeentproxyparsertext      — OpCode=10, 38
  - uzeentproxyparserarc       — OpCode=4
  - uzeentproxyparserpolyline  — OpCode=6
  - uzeentproxyparserpolylinewithnormals — OpCode=32
  - uzeentproxyparserpolygon   — OpCode=7
  - uzeentproxyparserlwpolyline — OpCode=33
  - uzeentproxyparserellipse   — OpCode=44
  - uzeentproxyparsershell     — OpCode=9
}

unit uzeentacdproxy;
{$Mode delphi}{$H+}
{$INCLUDE zengineconfig.inc}

interface

uses
  uzeentityfactory,
  uzgldrawcontext,
  uzedrawingdef,
  uzedrawingsimple,
  uzeffdxfout,
  uzeentsubordinated,
  uzeentcomplex,
  uzeentity,
  uzctnrVectorBytesStream,
  uzeTypes,
  uzeconsts,
  uzglviewareadata,
  uzegeometrytypes,
  uzegeometry,
  uzeffdxfsupport,
  uzMVReader,
  uzCtnrVectorpBaseEntity,
  uzbLogIntf,
  uzclog,
  uzestyleslayers,
  uzecamera,
  SysUtils,
  Math,
  UGDBObjBlockdefArray,
  uzeblockdef,
  uzeentproxymanager,
  uzeentproxygraphicparser,
  { Подключаем модули-парсеры примитивов. Каждый регистрирует свой
    обработчик в TProxyOpCodeDispatcher при инициализации модуля.
    Чтобы отключить конкретный примитив — закомментировать строку: }
  uzeentproxyparsercircle,
  uzeentproxyparsertext,
  uzeentproxyparserarc,
  uzeentproxyparserpolyline,
  uzeentproxyparserpolylinewithnormals,
  uzeentproxyparserpolygon,
  uzeentproxyparserlwpolyline,
  uzeentproxyparserellipse,
  uzeentproxyparsershell,
  UGDBSelectedObjArray,
  uzesnap,
  gzctnrVectorTypes,
  gzctnrVector,
  UGDBPoint3DArray,
  UGDBVisibleTreeArray,
  UGDBVisibleOpenArray,
  uzeentgenericsubentry,
  uzeentitiesmanager,
  uzepalette,
  uzestyleslinetypes;

const
  { Префикс для уникальных имён блоков, сгенерированных из ProxyEntity.
    "PE" означает "Proxy Entity": позволяет отличать такие блоки
    от обычных пользовательских блоков. }
  ProxyBlockNamePrefix = 'PE';

  { Верхняя граница случайного числа, используемого в имени блока
    (имя имеет вид PE<целое>). Задаёт достаточное пространство
    для практически бесконфликтной генерации имён. }
  ProxyBlockMaxRandom = 1000000000;

type
  PGDBObjAcdProxy = ^GDBObjAcdProxy;

  { Прокси-объект AutoCAD (ACAD_PROXY_ENTITY).

    Наследуется от GDBObjComplex — составной примитив с контейнером
    подпримитивов. Парсит бинарный Proxy Graphic из DXF, создаёт
    подпримитивы (линии, окружности, дуги, солиды, многострочный текст)
    и добавляет их в ConstObjArray. Отрисовка делегируется подпримитивам. }
  GDBObjAcdProxy = object(GDBObjComplex)
  public
    { Параметры трансформации (по образцу GDBObjBlockInsert).
      Поддерживают перемещение/масштабирование/поворот/зеркализацию
      прокси-объекта. Хранятся отдельно, чтобы пережить пересборку
      матрицы objmatrix в CalcObjMatrix. }
    scale: TzePoint3d;
    rotate: double;
  private
    { Сырые байты Proxy Graphic (код 310 из DXF) }
    FProxyDataBytes: TBytes;

    { Метаданные ACAD_PROXY_ENTITY из DXF }
    FProxyClassID: Integer;
    FAppClassID: Integer;
    FEntityDataSize: Integer;
    FObjectDataSize: Integer;
    FDrawingFormat: Integer;
    FOriginalDataFormat: Integer;

    { Версия DXF-файла, из которого загружен прокси-объект (код $ACADVER
      в заголовке). Значения соответствуют iVersion в TDXFHeaderInfo:
      1015 = DXF 2000, 1018 = DXF 2004, 1021 = DXF 2007, и т.д.
      Используется для правильной декодировки текстовых строк в
      бинарных Proxy Graphic данных (см. uzeentproxystream):
      - DXF 2007+ (>= 1021): UTF-16 (2 байта на символ);
      - DXF 2000/2004 (< 1021): ANSI (1 байт на символ).
      Если значение не задано (0), считаем формат DXF 2007+. }
    FDXFFileVersion: Integer;

    { Флаг: подпримитивы уже построены }
    FSubEntitiesBuilt: Boolean;

    { BBox, рассчитанный из Proxy Graphic, до пересчёта подпримитивов }
    FProxyBBoxLoaded: Boolean;
    FProxyBBoxMin: TzePoint3d;
    FProxyBBoxMax: TzePoint3d;
    FProxyGripOffset: TzePoint3d;

    { Имя уникального блока (PE<N>), сгенерированное для сохранения
      прокси-объекта как BlockInsert. Пустая строка означает, что
      конвертация в блок ещё не выполнена. Заполняется в
      EnsureConvertedBlockDef. }
    FConvertedBlockName: string;

    { Разбирает FProxyDataBytes и создаёт подпримитивы в ConstObjArray.
      Фактическое создание подпримитивов делегируется зарегистрированным
      в TProxyOpCodeDispatcher построителям (по одному на OpCode) из
      модулей-парсеров uzeentproxyparser*.pas. }
    procedure BuildSubEntities(var drawing: TDrawingDef;
      var DC: TDrawContext);

    { Формирует контекст (владелец, массив подпримитивов, слой/цвет/вес,
      грип-смещение) для передачи в Builder-процедуру каждого OpCode. }
    function MakeBuilderContext(var drawing: TDrawingDef;
      var DC: TDrawContext): TProxySubEntityContext;

  public
    constructor init(own: Pointer; layeraddres: PGDBLayerProp;
      LW: smallint);
    constructor initnul(owner: PGDBObjGenericWithSubordinated);
    destructor done; virtual;

    { Загружает данные объекта из DXF-потока }
    procedure LoadFromDXF(var rdr: TZMemReader;
      ptu: PExtensionData;
      var drawing: TDrawingDef;
      var context: TIODXFLoadContext); virtual;

    { Сохраняет данные объекта в DXF-поток }
    procedure SaveToDXF(var outStream: TZctnrVectorBytes;
      var drawing: TDrawingDef;
      var IODXFContext: TIODXFSaveContext); virtual;

    { Строит подпримитивы и делегирует форматирование GDBObjComplex }
    procedure FormatEntity(var drawing: TDrawingDef;
      var DC: TDrawContext;
      Stage: TEFStages = EFAllStages); virtual;

    { Отрисовка через подпримитивы (наследуется от GDBObjComplex) }
    procedure DrawGeometry(lw: integer; var DC: TDrawContext;
      const inFrustumState: TInBoundingVolume); virtual;

    { Пересчитывает objmatrix с учётом scale и rotate }
    procedure CalcObjMatrix(pdrawing: PTDrawingDef = nil); virtual;

    { Декомпозиция objmatrix обратно в Local.p_insert/scale/rotate,
      чтобы параметры трансформации пережили повторный CalcObjMatrix. }
    procedure ReCalcFromObjMatrix; virtual;

    { Применяет матрицу трансформации (move/scale/rotate/mirror) }
    procedure TransformAt(p: PGDBObjEntity;
      t_matrix: PzeTypedMatrix4d); virtual;

    { Возвращает тип объекта в виде строки }
    function GetObjTypeName: string; virtual;

    { Возвращает числовой идентификатор типа объекта }
    function GetObjType: TObjID; virtual;

    { Создаёт копию объекта }
    function Clone(own: Pointer): PGDBObjEntity; virtual;

    { Геометрический центр proxy graphic для ручки/точки вставки }
    function GetCenterPoint: TzePoint3d; virtual;

    { Устанавливает ручку (grip) в геометрический центр BBox proxy graphic }
    procedure addcontrolpoints(tdesc: Pointer); virtual;

    { Обновляет экранные координаты ручки из геометрического центра BBox }
    procedure remaponecontrolpoint(pdesc: pcontrolpointdesc;
      ProjectProc: GDBProjectProc); virtual;

    { Создаёт новый инициализированный экземпляр }
    class function CreateInstance: PGDBObjAcdProxy; static;

    { Создаёт (если ещё не создан) блок с уникальным именем PE<N>
      в BlockDefArray чертежа, заполняя его подпримитивами прокси-объекта.
      Возвращает имя сгенерированного блока. При повторных вызовах
      возвращает ранее сгенерированное имя без создания новых блоков. }
    function EnsureConvertedBlockDef(var drawing: TDrawingDef): string;

    { Возвращает имя уже сгенерированного блока или пустую строку,
      если конвертация ещё не выполнялась. Предназначено для тестов. }
    function GetConvertedBlockName: string;
  end;

{ Выделяет память для нового прокси-объекта }
function AllocAcdProxy: Pointer;

{ Выделяет и инициализирует новый прокси-объект }
function AllocAndInitAcdProxy(
  owner: PGDBObjGenericWithSubordinated): PGDBObjAcdProxy;

{ Генерирует уникальное имя блока вида PE<N>, где N — случайное
  целое в диапазоне [0..ProxyBlockMaxRandom]. Имя гарантированно
  отсутствует в BlockDefArray чертежа. }
function GenerateUniqueProxyBlockName(
  var drawing: TDrawingDef): string;

{ Pre-save обработчик: обходит дерево объектов чертежа и для каждого
  ProxyEntity создаёт блок в BlockDefArray. Регистрируется в
  initialization через RegisterBeforeSaveDxfProc. }
procedure ConvertProxyEntitiesToBlocks(var drawing: TSimpleDrawing);

implementation

uses
  uzeutils;

{ --- Вспомогательные функции --- }

{ Конвертирует hex-строку в массив байт }
function HexStringToBytes(const HexStr: string): TBytes;
var
  I, Len: Integer;
begin
  Len := Length(HexStr) div 2;
  SetLength(Result, Len);
  for I := 0 to Len - 1 do
    Result[I] := Lo(
      StrToIntDef('$' + Copy(HexStr, I * 2 + 1, 2), 0));
end;

{ Конвертирует массив байт в hex-строку }
function BytesToHexString(const Data: TBytes): string;
var
  I: Integer;
begin
  Result := '';
  for I := 0 to High(Data) do
    Result := Result + IntToHex(Data[I], 2);
end;

{ === GDBObjAcdProxy === }

constructor GDBObjAcdProxy.init;
begin
  inherited init(own, layeraddres, LW);
  FSubEntitiesBuilt := False;
  FProxyBBoxLoaded := False;
  FProxyGripOffset := NulVertex;
  FProxyClassID := 498;
  FAppClassID := 499;
  FEntityDataSize := 0;
  FObjectDataSize := 0;
  FDrawingFormat := 15;
  FOriginalDataFormat := 0;
  FDXFFileVersion := 0;
  scale := ScaleOne;
  rotate := 0;
  FConvertedBlockName := '';
end;

constructor GDBObjAcdProxy.initnul;
begin
  inherited initnul;
  bp.ListPos.Owner := owner;
  FSubEntitiesBuilt := False;
  FProxyBBoxLoaded := False;
  FProxyGripOffset := NulVertex;
  FProxyClassID := 498;
  FAppClassID := 499;
  FEntityDataSize := 0;
  FObjectDataSize := 0;
  FDrawingFormat := 15;
  FOriginalDataFormat := 0;
  FDXFFileVersion := 0;
  scale := ScaleOne;
  rotate := 0;
  FConvertedBlockName := '';
end;

destructor GDBObjAcdProxy.done;
begin
  SetLength(FProxyDataBytes, 0);
  FConvertedBlockName := '';
  inherited done;
end;

{ Загружает данные объекта из DXF-потока }
procedure GDBObjAcdProxy.LoadFromDXF(var rdr: TZMemReader;
  ptu: PExtensionData;
  var drawing: TDrawingDef; var context: TIODXFLoadContext);
var
  HexAccum: string;
  Code: Integer;
begin
  HexAccum := '';
  { Запоминаем версию DXF-файла. Она нужна при разборе бинарной
    Proxy Graphic, чтобы выбрать правильную кодировку строк:
    DXF 2007+ — UTF-16, DXF 2000/2004 — ANSI. }
  FDXFFileVersion := context.Header.iVersion;
  Code := rdr.ParseInteger;
  while Code <> 0 do
  begin
    if not LoadFromDXFObjShared(
      rdr, Code, ptu, drawing, context) then
      case Code of
        90:
          FProxyClassID := StrToIntDef(rdr.ParseString, 498);
        91:
          FAppClassID := StrToIntDef(rdr.ParseString, 499);
        92, 160:
          rdr.SkipString;
        93:
          FEntityDataSize := StrToIntDef(rdr.ParseString, 0);
        94:
          FObjectDataSize := StrToIntDef(rdr.ParseString, 0);
        95:
          FDrawingFormat := StrToIntDef(rdr.ParseString, 15);
        70:
          FOriginalDataFormat := StrToIntDef(
            rdr.ParseString, 0);
        310:
          HexAccum := HexAccum + rdr.ParseString;
      else
        rdr.SkipString;
      end;
    Code := rdr.ParseInteger;
  end;

  if Length(HexAccum) > 0 then
  begin
    FProxyDataBytes := HexStringToBytes(HexAccum);
    programlog.LogOutFormatStr(
      'uzeentacdproxy: LoadFromDXF loaded %d bytes',
      [Length(FProxyDataBytes)], LM_Info);
  end
  else
  begin
    SetLength(FProxyDataBytes, 0);
    programlog.LogOutFormatStr(
      'uzeentacdproxy: LoadFromDXF no proxy data',
      [], LM_Info);
  end;

  FSubEntitiesBuilt := False;
  FProxyBBoxLoaded := False;
end;

{ Сохраняет данные объекта в DXF-поток как INSERT (BlockInsert).

  Концепция: прокси-объект сохраняется не как ACAD_PROXY_ENTITY, а
  как ссылка на блок BLOCK с уникальным именем PE<N>. Сам блок
  добавляется в BlockDefArray чертежа через ConvertProxyEntitiesToBlocks
  до начала записи DXF (см. initialization и uzeffdxfout). Это
  приводит к тому, что при повторном открытии файла прокси-объектов
  уже нет — остаются только BlockInsert'ы.

  Формат записи совпадает с GDBObjBlockInsert.SaveToDXF:
  - код 0: INSERT
  - код 100: AcDbBlockReference
  - код 2: имя блока (PE<N>)
  - код 10: точка вставки
  - код 41/42/43: масштаб
  - код 50: угол поворота (в градусах) }
procedure GDBObjAcdProxy.SaveToDXF(
  var outStream: TZctnrVectorBytes;
  var drawing: TDrawingDef;
  var IODXFContext: TIODXFSaveContext);
var
  BlockName: string;
begin
  BlockName := EnsureConvertedBlockDef(drawing);

  SaveToDXFObjPrefix(outStream, 'INSERT', 'AcDbBlockReference',
    IODXFContext);
  dxfStringout(outStream, 2, BlockName, IODXFContext.Header);
  dxfvertexout(outStream, 10, Local.p_insert);
  dxfvertexout1(outStream, 41, scale);
  dxfDoubleout(outStream, 50, rotate * 180 / pi);
  SaveToDXFObjPostfix(outStream);

  programlog.LogOutFormatStr(
    'uzeentacdproxy: SaveToDXF wrote INSERT of block "%s"',
    [BlockName], LM_Info);
end;

{ Строит контекст для передачи в Builder-процедуру примитива.
  Все данные владельца (слой, цвет, грипп, массив подпримитивов)
  упаковываются в typed Pointer-ы, чтобы исключить циклическую
  зависимость между модулями парсеров и этим модулем. }
function GDBObjAcdProxy.MakeBuilderContext(
  var drawing: TDrawingDef; var DC: TDrawContext): TProxySubEntityContext;
begin
  Result.OwnerEntity      := @Self;
  Result.SubEntitiesArray := @ConstObjArray;
  Result.Drawing          := @drawing;
  Result.DC               := @DC;
  Result.OwnerLayer       := vp.Layer;
  Result.OwnerLineType    := vp.LineType;
  Result.OwnerLineWeight  := vp.LineWeight;
  Result.OwnerColor       := Integer(vp.Color);
  { По умолчанию — вес владельца; реальный вес каждого примитива
    подставляется в BuildSubEntities на каждой итерации цикла. }
  Result.PrimitiveLineWeight := vp.LineWeight;
  { По умолчанию — ByBlock: если в потоке Proxy Graphic нет команды
    SetColor (OpCode=14), подпримитив ведёт себя как внутри BlockInsert
    с цветом ByBlock, то есть наследует цвет владельца. Реальное значение
    PrimitiveColor подставляется в BuildSubEntities на каждой итерации
    цикла из ParseResult.Primitives[I].Color. }
  Result.PrimitiveColor := ClByBlock;
  { Масштаб типа линии владельца (DXF group code 48). Берётся
    непосредственно из vp.LineTypeScale, заполненного
    LoadFromDXFObjShared при чтении DXF. Используется, чтобы
    подпримитивы унаследовали этот масштаб и отображали штрихи
    типа линии в правильном масштабе. }
  Result.OwnerLineTypeScale := vp.LineTypeScale;
  { По умолчанию — 1 (идентичный множитель); реальное значение
    PrimitiveLineTypeScale подставляется в BuildSubEntities на каждой
    итерации цикла из LtScale парсера. }
  Result.PrimitiveLineTypeScale := 1.0;
  Result.GripOffset       := FProxyGripOffset;
end;

{ Разбирает FProxyDataBytes и создаёт подпримитивы.
  Сам модуль не знает, как именно строить GDB-объекты из каждого
  примитива: построением занимаются Builder-процедуры, зарегистрированные
  в TProxyOpCodeDispatcher соответствующими модулями-парсерами
  uzeentproxyparser*.pas. Этот метод лишь организует проход по
  результату парсинга и вызывает диспетчер. }
procedure GDBObjAcdProxy.BuildSubEntities(
  var drawing: TDrawingDef; var DC: TDrawContext);
var
  Parser: TProxyGraphicParser;
  ParseResult: TProxyGraphicParseResult;
  Context: TProxySubEntityContext;
  I: Integer;
  BuiltCount: Integer;
  UnicodeText: Boolean;
begin
  if Length(FProxyDataBytes) = 0 then
    Exit;

  { Очищаем предыдущие подпримитивы }
  ConstObjArray.Free;
  ConstObjArray.init(8);

  { Выбор кодировки текста в Proxy Graphic по версии DXF-файла:
    DXF 2007+ (AC1021+, iVersion >= 1021) — UTF-16,
    DXF 2000/2004 (AC1015/AC1018)         — ANSI.
    Если версия неизвестна (0), считаем формат DXF 2007+. }
  UnicodeText := (FDXFFileVersion = 0) or (FDXFFileVersion >= 1021);
  programlog.LogOutFormatStr(
    'uzeentacdproxy: BuildSubEntities dxfVersion=%d unicodeText=%s',
    [FDXFFileVersion, BoolToStr(UnicodeText, True)], LM_Info);

  Parser := TProxyGraphicParser.Create(FProxyDataBytes, UnicodeText);
  try
    ParseResult := Parser.Parse;

    { Вычисляем BBox и смещение ДО создания подпримитивов,
      чтобы Builder-процедуры корректно переводили координаты
      в локальную систему подпримитивов }
    if ParseResult.BBoxLoaded then
    begin
      FProxyBBoxMin := ParseResult.BBoxMin;
      FProxyBBoxMax := ParseResult.BBoxMax;
      FProxyBBoxLoaded := True;
      FProxyGripOffset := Vertexmorph(
        FProxyBBoxMin, FProxyBBoxMax, 0.5);
      if IsVectorNul(Local.P_insert) then
        Local.P_insert := FProxyGripOffset;
      vp.BoundingBox.LBN := FProxyBBoxMin;
      vp.BoundingBox.RTF := FProxyBBoxMax;

      programlog.LogOutFormatStr(
        'uzeentacdproxy: BuildSubEntities gripOffset='
        + '(%.3f,%.3f,%.3f)',
        [FProxyGripOffset.x, FProxyGripOffset.y,
         FProxyGripOffset.z], LM_Info);
    end;

    { Формируем контекст построителей только один раз — указатели на
      массив подпримитивов, слой/тип линии/вес/цвет владельца и грип
      неизменны в пределах построения. }
    Context := MakeBuilderContext(drawing, DC);

    { Делегируем создание подпримитивов модулям-парсерам.
      Каждый примитив в порядке появления в Proxy Graphic передаётся
      в Builder, зарегистрированный для его OpCode. }
    BuiltCount := 0;
    for I := 0 to High(ParseResult.Primitives) do
    begin
      { Подставляем вес линии, зафиксированный парсером для конкретного
        примитива (SetLineweight OpCode=23 из потока Proxy Graphic).
        Без этого все подпримитивы получали бы одинаковый вес владельца
        прокси-объекта, игнорируя значения, заданные внутри графики. }
      Context.PrimitiveLineWeight := ParseResult.Primitives[I].LineWeight;
      { Подставляем масштаб типа линии, зафиксированный парсером для
        конкретного примитива (SetLtScale OpCode=24 из потока Proxy
        Graphic). При построении подпримитива он умножается на
        OwnerLineTypeScale (DXF code 48 владельца), чтобы отражался и
        масштаб самого прокси-объекта, и внутренний масштаб графики. }
      Context.PrimitiveLineTypeScale := ParseResult.Primitives[I].LtScale;
      { Подставляем цвет, зафиксированный парсером для конкретного
        примитива (SetColor OpCode=14 из потока Proxy Graphic). Без
        этого все подпримитивы всегда получали цвет владельца (прокси-
        объекта), что ломало инвариант BlockInsert: примитивы с ByLayer
        должны использовать цвет слоя, с явным цветом — свой цвет, и
        только ByBlock — унаследовать цвет контейнера. См. ResolveColor
        в uzeentproxysubentitybuilder. }
      Context.PrimitiveColor := ParseResult.Primitives[I].Color;
      programlog.LogOutFormatStr(
        'uzeentacdproxy: BuildSubEntities[%d] OpCode=%d lineweight=%d ltScale=%.3f color=%d',
        [I, ParseResult.Primitives[I].OpCode,
         ParseResult.Primitives[I].LineWeight,
         ParseResult.Primitives[I].LtScale,
         ParseResult.Primitives[I].Color], LM_Info);
      if TProxyOpCodeDispatcher.BuildSubEntities(
        ParseResult.Primitives[I].OpCode,
        ParseResult.Primitives[I].HandlerResult,
        Context) then
        Inc(BuiltCount);
    end;

    programlog.LogOutFormatStr(
      'uzeentacdproxy: BuildSubEntities built %d/%d primitives',
      [BuiltCount, Length(ParseResult.Primitives)], LM_Info);

  finally
    { Освобождаем вершины всех примитивов результата и сам парсер }
    FreeParseResult(ParseResult);
    Parser.Free;
  end;

  FSubEntitiesBuilt := True;
end;

{ Строит подпримитивы и делегирует форматирование GDBObjComplex.
  Подпримитивы создаются один раз при первом вызове или при
  необходимости перестроения. }
procedure GDBObjAcdProxy.FormatEntity(var drawing: TDrawingDef;
  var DC: TDrawContext; Stage: TEFStages);
begin
  if Assigned(EntExtensions) then
    EntExtensions.RunOnBeforeEntityFormat(@self, drawing, DC);

  if not FSubEntitiesBuilt then
    BuildSubEntities(drawing, DC);

  { Пересчитываем objmatrix с учётом scale/rotate ДО форматирования
    подпримитивов, чтобы подпримитивы унаследовали полную матрицу
    владельца через bp.ListPos.owner.GetMatrix. }
  CalcObjMatrix(@drawing);

  { Форматируем подпримитивы и вычисляем BBox из них: так BBox
    получается в мировых координатах с учётом трансформации. }
  ConstObjArray.FormatEntity(drawing, DC);
  calcbb(DC);
  self.BuildGeometry(drawing);
  CalcActualVisible(DC.DrawingContext.VActuality);

  if FProxyBBoxLoaded then
    { Выводим в лог координаты BBox и ручки (grip) для диагностики }
    programlog.LogOutFormatStr(
      'uzeentacdproxy: FormatEntity bbox min=(%.3f,%.3f,%.3f)'
      + ' max=(%.3f,%.3f,%.3f) grip=(%.3f,%.3f,%.3f)',
      [vp.BoundingBox.LBN.x, vp.BoundingBox.LBN.y, vp.BoundingBox.LBN.z,
       vp.BoundingBox.RTF.x, vp.BoundingBox.RTF.y, vp.BoundingBox.RTF.z,
       GetCenterPoint.x, GetCenterPoint.y, GetCenterPoint.z], LM_Info);

  if Assigned(EntExtensions) then
    EntExtensions.RunOnAfterEntityFormat(@self, drawing, DC);
end;

{ Отрисовка через подпримитивы — делегируется GDBObjComplex }
procedure GDBObjAcdProxy.DrawGeometry(lw: integer;
  var DC: TDrawContext;
  const inFrustumState: TInBoundingVolume);
begin
  inherited DrawGeometry(lw, DC, inFrustumState);
end;

{ Пересчёт objmatrix: базовая матрица (translate(Local.p_insert)*basis) из
  предка, затем поворот вокруг Z на угол rotate и масштабирование scale.
  Та же последовательность, что и в GDBObjBlockInsert.CalcObjMatrix;
  сохраняется параметры трансформации в матрице, чтобы их нельзя было
  "потерять" при повторном форматировании. }
procedure GDBObjAcdProxy.CalcObjMatrix(pdrawing: PTDrawingDef = nil);
var
  m1: TzeTypedMatrix4d;
begin
  inherited CalcObjMatrix(pdrawing);

  if not IsZero(rotate) then
  begin
    m1 := CreateRotationMatrixZ(rotate);
    objMatrix := MatrixMultiply(m1, objMatrix);
  end;

  if (not SameValue(scale.x, 1.0))
    or (not SameValue(scale.y, 1.0))
    or (not SameValue(scale.z, 1.0)) then
  begin
    m1 := CreateScaleMatrix(scale);
    objMatrix := MatrixMultiply(m1, objMatrix);
  end;

  P_insert_in_WCS := VectorTransform3D(NulVertex, objMatrix);
end;

{ Декомпозиция objMatrix в Local.p_insert/basis/scale/rotate, чтобы после
  внешней трансформации (TransformAt) параметры пережили последующий вызов
  CalcObjMatrix. По образцу GDBObjBlockInsert.ReCalcFromObjMatrix. }
procedure GDBObjAcdProxy.ReCalcFromObjMatrix;
var
  ox, tv: TzePoint3d;
begin
  inherited ReCalcFromObjMatrix;
  Local := GetPInsertInOCSBymatrix(objMatrix, scale);

  ox := GetXfFromZ(Local.basis.oz);
  tv := Local.basis.ox;
  if scale.x < -eps then
    tv := VertexMulOnSc(tv, -1);
  rotate := scalardot(tv, ox);
  if rotate > 1.0 then
    rotate := 1.0
  else if rotate < -1.0 then
    rotate := -1.0;
  rotate := arccos(rotate);
  if scalardot(tv, VectorDot(Local.basis.oz,
    GetXfFromZ(Local.basis.oz))) < -eps then
    rotate := 2 * pi - rotate;
end;

procedure GDBObjAcdProxy.TransformAt(p: PGDBObjEntity;
  t_matrix: PzeTypedMatrix4d);
begin
  inherited TransformAt(p, t_matrix);
  ReCalcFromObjMatrix;
end;

function GDBObjAcdProxy.GetObjTypeName: string;
begin
  Result := 'ACAD_PROXY_ENTITY';
end;

function GDBObjAcdProxy.GetObjType: TObjID;
begin
  Result := GDBAcdProxyID;
end;

function GDBObjAcdProxy.GetCenterPoint: TzePoint3d;
begin
  Result := P_insert_in_WCS;
end;

{ Устанавливает ручку управления (grip) в геометрический центр BBox.
  Базовый GDBObjComplex использует P_insert_in_WCS, который для прокси
  всегда равен (0,0,0). Переопределяем, чтобы ручка совпадала с центром
  объекта. }
procedure GDBObjAcdProxy.addcontrolpoints(tdesc: Pointer);
var
  pdesc: controlpointdesc;
  GripCenter: TzePoint3d;
begin
  GripCenter := GetCenterPoint;
  PSelectedObjDesc(tdesc)^.pcontrolpoint^.init(1);
  pdesc.selected := False;
  pdesc.PDrawable := nil;
  pdesc.pointtype := os_point;
  pdesc.worldcoord := GripCenter;
  PSelectedObjDesc(tdesc)^.pcontrolpoint^.PushBackData(pdesc);

  programlog.LogOutFormatStr(
    'uzeentacdproxy: addcontrolpoints grip=(%.3f,%.3f,%.3f)',
    [GripCenter.x, GripCenter.y, GripCenter.z], LM_Info);
end;

{ Пересчитывает экранные координаты ручки из геометрического центра BBox.
  Базовый GDBObjComplex читает P_insert_in_WCS, что для прокси даёт (0,0,0).
  Переопределяем, чтобы ручка всегда следовала за реальным центром объекта. }
procedure GDBObjAcdProxy.remaponecontrolpoint(pdesc: pcontrolpointdesc;
  ProjectProc: GDBProjectProc);
var
  tv: TzePoint3d;
begin
  if pdesc^.pointtype = os_point then
  begin
    pdesc.worldcoord := GetCenterPoint;
    ProjectProc(pdesc.worldcoord, tv);
    pdesc.dispcoord := ToTzePoint2i(tv);
  end;
end;

{ Создаёт копию прокси-объекта }
function GDBObjAcdProxy.Clone(own: Pointer): PGDBObjEntity;
var
  ClonePtr: PGDBObjAcdProxy;
begin
  ClonePtr := CreateInstance;

  { Копируем свойства слоя/типа линии/веса/цвета и LineTypeScale владельца.
    Без этого vp.LineTypeScale в клоне останется равным 1, и подпримитивы
    клона (построенные при первом FormatEntity) получат масштаб 1 вместо
    считанного из DXF code 48. }
  CopyVPto(ClonePtr^);

  { Копируем бинарные данные proxy graphic }
  SetLength(ClonePtr^.FProxyDataBytes, Length(FProxyDataBytes));
  if Length(FProxyDataBytes) > 0 then
    Move(FProxyDataBytes[0], ClonePtr^.FProxyDataBytes[0],
      Length(FProxyDataBytes));

  { Копируем метаданные DXF }
  ClonePtr^.FProxyClassID := FProxyClassID;
  ClonePtr^.FAppClassID := FAppClassID;
  ClonePtr^.FEntityDataSize := FEntityDataSize;
  ClonePtr^.FObjectDataSize := FObjectDataSize;
  ClonePtr^.FDrawingFormat := FDrawingFormat;
  ClonePtr^.FOriginalDataFormat := FOriginalDataFormat;
  ClonePtr^.FDXFFileVersion := FDXFFileVersion;

  { Подпримитивы будут построены при первом FormatEntity }
  ClonePtr^.FSubEntitiesBuilt := False;
  ClonePtr^.FProxyBBoxLoaded := FProxyBBoxLoaded;
  ClonePtr^.FProxyBBoxMin := FProxyBBoxMin;
  ClonePtr^.FProxyBBoxMax := FProxyBBoxMax;
  ClonePtr^.FProxyGripOffset := FProxyGripOffset;

  { Копируем параметры трансформации }
  ClonePtr^.Local := Local;
  ClonePtr^.scale := scale;
  ClonePtr^.rotate := rotate;

  { Не копируем FConvertedBlockName — клон должен получить собственное
    уникальное имя блока при следующем сохранении. }
  ClonePtr^.FConvertedBlockName := '';

  ClonePtr^.bp.ListPos.Owner := own;
  Result := PGDBObjEntity(ClonePtr);
end;

class function GDBObjAcdProxy.CreateInstance: PGDBObjAcdProxy;
begin
  Result := AllocAcdProxy;
  Result^.initnul(nil);
end;

function AllocAcdProxy: Pointer;
begin
  GetMem(Result, SizeOf(GDBObjAcdProxy));
end;

function AllocAndInitAcdProxy(
  owner: PGDBObjGenericWithSubordinated): PGDBObjAcdProxy;
begin
  Result := AllocAcdProxy;
  Result^.initnul(owner);
end;

{ Генерирует уникальное имя блока вида PE<N>. Перебирает случайные
  имена, пока не найдётся отсутствующее в BlockDefArray чертежа. }
function GenerateUniqueProxyBlockName(
  var drawing: TDrawingDef): string;
var
  Attempt: Integer;
  Candidate: string;
  BlockArr: PGDBObjBlockdefArray;
begin
  BlockArr := PGDBObjBlockdefArray(drawing.GetBlockDefArraySimple);
  { В подавляющем большинстве случаев хватает одной попытки: диапазон
    в миллиард значений даёт пренебрежимо малую вероятность коллизии.
    Цикл с запасом защищает от маловероятного совпадения. }
  for Attempt := 0 to 1024 do
  begin
    Candidate := ProxyBlockNamePrefix
      + IntToStr(Random(ProxyBlockMaxRandom + 1));
    if BlockArr^.getindex(Candidate) < 0 then
      Exit(Candidate);
  end;
  { Крайне маловероятный случай: не смогли подобрать имя за 1025
    попыток. Падаем явно, чтобы не записать блок с дублирующимся именем. }
  raise Exception.Create(
    'GenerateUniqueProxyBlockName: failed to generate unique name');
end;

function GDBObjAcdProxy.GetConvertedBlockName: string;
begin
  Result := FConvertedBlockName;
end;

{ Создаёт (если ещё не создан) блок с уникальным именем в
  BlockDefArray чертежа и копирует в него подпримитивы прокси-объекта.
  Имя генерируется один раз на экземпляр прокси и кэшируется в
  FConvertedBlockName — повторные вызовы возвращают то же имя без
  повторного создания блока. }
function GDBObjAcdProxy.EnsureConvertedBlockDef(
  var drawing: TDrawingDef): string;
var
  BlockArr: PGDBObjBlockdefArray;
  BlockDef: PGDBObjBlockdef;
  SubEnt, ClonedEnt: PGDBObjEntity;
  IR: itrec;
  DC: TDrawContext;
begin
  if FConvertedBlockName <> '' then
  begin
    { Имя уже сгенерировано — блок также должен существовать.
      Если его нет (редкий случай, например после очистки
      BlockDefArray), создаём заново с тем же именем. }
    BlockArr := PGDBObjBlockdefArray(drawing.GetBlockDefArraySimple);
    if BlockArr^.getindex(FConvertedBlockName) >= 0 then
      Exit(FConvertedBlockName);
  end
  else
    FConvertedBlockName := GenerateUniqueProxyBlockName(drawing);

  { Подпримитивы могли ещё не быть построены (если прокси не
    форматировался после загрузки). Строим их здесь, чтобы блок
    получил все геометрические элементы. }
  if (not FSubEntitiesBuilt) and (Length(FProxyDataBytes) > 0) then
  begin
    DC := drawing.CreateDrawingRC;
    BuildSubEntities(drawing, DC);
  end;

  BlockArr := PGDBObjBlockdefArray(drawing.GetBlockDefArraySimple);
  BlockDef := BlockArr^.create(FConvertedBlockName);
  BlockDef^.Base := NulVertex;

  { Копируем подпримитивы из ConstObjArray в ObjArray блока.
    Каждый подпримитив клонируется — владелец клона теперь BlockDef. }
  SubEnt := ConstObjArray.beginiterate(IR);
  if SubEnt <> nil then
    repeat
      ClonedEnt := SubEnt^.Clone(BlockDef);
      BlockDef^.ObjArray.AddPEntity(ClonedEnt^);
      SubEnt := ConstObjArray.iterate(IR);
    until SubEnt = nil;

  programlog.LogOutFormatStr(
    'uzeentacdproxy: EnsureConvertedBlockDef created "%s" with %d entities',
    [FConvertedBlockName, BlockDef^.ObjArray.Count], LM_Info);

  Result := FConvertedBlockName;
end;

{ Обходит массив сущностей и запускает для всех proxy-объектов
  EnsureConvertedBlockDef. Сбор указателей выполняется отдельным
  проходом, потому что EnsureConvertedBlockDef вызывает create()
  у BlockDefArray — это может привести к grow() и перевыделению
  parray. GDBObjBlockdef хранится там по значению, поэтому
  существующие BlockDef'ы меняют адрес, и указатель на любой из их
  ObjArray становится невалидным. Сами PGDBObjAcdProxy
  аллоцируются отдельно (AllocAcdProxy) и при grow() не
  перемещаются, поэтому собранные указатели остаются валидными. }
procedure ConvertProxyEntitiesInArray(
  pArray: PGDBObjEntityOpenArray; var drawing: TSimpleDrawing);
var
  Ent: PGDBObjEntity;
  I, N, ProxyCount: Integer;
  Proxies: array of PGDBObjAcdProxy;
begin
  if pArray = nil then
    Exit;
  N := pArray^.Count;
  SetLength(Proxies, N);
  ProxyCount := 0;
  for I := 0 to N - 1 do
  begin
    Ent := PGDBObjEntity(pArray^.GetData(I));
    if (Ent <> nil) and (Ent^.GetObjType = GDBAcdProxyID) then
    begin
      Proxies[ProxyCount] := PGDBObjAcdProxy(Ent);
      Inc(ProxyCount);
    end;
  end;
  for I := 0 to ProxyCount - 1 do
    Proxies[I]^.EnsureConvertedBlockDef(drawing);
end;

procedure ConvertProxyEntitiesToBlocks(var drawing: TSimpleDrawing);
var
  BlockArr: PGDBObjBlockdefArray;
  I, InitialBlockCount, ProxyCount, J: Integer;
  BlockDef: PGDBObjBlockdef;
  Ent: PGDBObjEntity;
  Proxies: array of PGDBObjAcdProxy;
begin
  if drawing.pObjRoot <> nil then
    ConvertProxyEntitiesInArray(
      @drawing.pObjRoot^.ObjArray, drawing);

  { Proxy-объекты могут лежать не только в корневом ObjArray, но и
    внутри определений блоков (например, когда INSERT в .dxf
    ссылается на блок, содержащий proxy-сущности). Для таких
    proxy-объектов также нужно создать PE<N>-блок, иначе при
    повторном открытии INSERT не найдёт своего определения и
    uzeentblockinsert.pas:321 упадёт с assert на getindex < 0.

    Сначала собираем все proxy-указатели в локальный список, и
    только затем вызываем EnsureConvertedBlockDef. Причина:
    EnsureConvertedBlockDef вызывает create() у BlockDefArray,
    которое может привести к grow() и перевыделению parray. Так
    как GDBObjBlockdef хранится в parray по значению, существующие
    BlockDef'ы меняют свой адрес, и @BlockDef^.ObjArray перестаёт
    быть валидным указателем. Сами PGDBObjAcdProxy аллоцируются
    отдельно и при grow() не перемещаются. }
  BlockArr := PGDBObjBlockdefArray(drawing.GetBlockDefArraySimple);
  if BlockArr = nil then
    Exit;
  InitialBlockCount := BlockArr^.Count;

  ProxyCount := 0;
  SetLength(Proxies, 0);
  for I := 0 to InitialBlockCount - 1 do
  begin
    BlockDef := BlockArr^.getDataMutable(I);
    if BlockDef = nil then
      Continue;
    for J := 0 to BlockDef^.ObjArray.Count - 1 do
    begin
      Ent := PGDBObjEntity(BlockDef^.ObjArray.GetData(J));
      if (Ent <> nil) and (Ent^.GetObjType = GDBAcdProxyID) then
      begin
        SetLength(Proxies, ProxyCount + 1);
        Proxies[ProxyCount] := PGDBObjAcdProxy(Ent);
        Inc(ProxyCount);
      end;
    end;
  end;

  for I := 0 to ProxyCount - 1 do
    Proxies[I]^.EnsureConvertedBlockDef(drawing);
end;

initialization
  RegisterDXFEntity(
    GDBAcdProxyID,
    'ACAD_PROXY_ENTITY',
    'ProxyEntity',
    @AllocAcdProxy,
    @AllocAndInitAcdProxy);

  { Регистрируем pre-save callback, чтобы перед записью DXF все
    ProxyEntity были конвертированы в BlockInsert'ы с уникальными
    именами блоков (префикс "PE"). }
  RegisterBeforeSaveDxfProc(@ConvertProxyEntitiesToBlocks);

  { Инициализируем генератор случайных чисел один раз при старте.
    Используется для генерации имён PE<N>. }
  Randomize;

  programlog.LogOutFormatStr(
    'uzeentacdproxy: Registered ACAD_PROXY_ENTITY, handlers: %d',
    [TProxyOpCodeDispatcher.GetRegisteredCount], LM_Info);

end.
