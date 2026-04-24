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
  Модуль: uzeentproxygraphicparser
  Назначение: Парсер бинарного блока Proxy Graphic (AcGiWorldDraw формат).

  Структура данных Proxy Graphic:
    [ChunkSize: int32] [CommandCount: int32]
    Повтор CommandCount раз:
      [CommandSize: int32] [OpCode: int32] [Данные...]

  Диспетчеризация:
  - Системные команды (Extents, SetColor, SetLayer, Push/PopMatrix)
    обрабатываются непосредственно в этом модуле (они изменяют
    состояние парсера, а не создают подпримитивы).
  - Примитивные команды (Circle, Text, Polyline и т.д.) обрабатываются
    через TProxyOpCodeDispatcher — менеджер, куда каждый модуль-парсер
    регистрирует свой обработчик в секции initialization.
  - Если примитив не зарегистрирован — команда пропускается.

  Результат парсинга (TProxyGraphicParseResult):
  - BBoxMin, BBoxMax — суммарный BBox всех успешно распаршенных примитивов
  - Primitives       — распаршенные примитивы (OpCode + результат обработчика)
                       в порядке появления в потоке. Сбор подпримитивов
                       происходит в GDBObjAcdProxy.BuildSubEntities: для
                       каждого примитива вызывается Builder соответствующего
                       OpCode через TProxyOpCodeDispatcher.BuildSubEntities.
  - PrimitiveCount   — количество успешно обработанных примитивов

  Важно: промежуточные структуры «контуры» и «текстовые элементы» намеренно
  удалены. Вместо этого парсер хранит для каждого примитива результат
  обработчика целиком (вершины, флаги, текст, состояние атрибутов). Решение
  о том, какие GDB-сущности создать из данных — принимает Builder из
  модуля-парсера, а не центральный код прокси-объекта. Это выполняет
  требование: «файл, в котором происходит расшифровка примитива, создаёт
  и соответствующий подпримитив».
}

unit uzeentproxygraphicparser;
{$Mode delphi}{$H+}
{$INCLUDE zengineconfig.inc}

interface

uses
  SysUtils,
  uzeentproxystream,
  uzeentproxymanager,
  uzeentproxytypes,
  uzegeometrytypes,
  uzegeometry,
  gzctnrVectorTypes,
  UGDBPoint3DArray;

type
  { Один распаршенный примитив: OpCode + результат обработчика + состояние
    атрибутов парсера на момент обработки. Сохраняется в результате парсинга
    до вызова Builder-процедуры соответствующего модуля-парсера. }
  TProxyParsedPrimitive = record
    { OpCode команды в потоке (см. uzeentproxytypes.TProxyGraphicCommand) }
    OpCode: Integer;
    { Результат обработчика (вершины, BBox, текст, флаги) }
    HandlerResult: TProxyHandlerResult;
    { Вес линии, действовавший на момент обработки }
    LineWeight: Integer;
    { Цвет, действовавший на момент обработки }
    Color: Integer;
    { Слой, действовавший на момент обработки }
    Layer: string;
    { Тип линии, действовавший на момент обработки }
    Linetype: string;
    { Масштаб типа линии }
    LtScale: Double;
    { Толщина }
    Thickness: Double;
    { True color }
    TrueColor: Integer;
  end;

  { Итоговый результат разбора одного Proxy Graphic блока }
  TProxyGraphicParseResult = record
    { Суммарный BBox всех примитивов }
    BBoxMin: TzePoint3d;
    BBoxMax: TzePoint3d;
    { Флаг: BBox вычислен хотя бы одним примитивом }
    BBoxLoaded: Boolean;
    { Распаршенные примитивы (в порядке появления).
      Фактическое создание подпримитивов происходит позже — через
      Builder-процедуру, зарегистрированную в TProxyOpCodeDispatcher. }
    Primitives: array of TProxyParsedPrimitive;
    { Общее число успешно обработанных примитивов }
    PrimitiveCount: Integer;
  end;

  { Парсер Proxy Graphic.
    Создаётся для каждого прокси-объекта отдельно. }
  TProxyGraphicParser = class
  private
    FStream: TProxyByteStream;
    FResult: TProxyGraphicParseResult;
    FState: TProxyGraphicState;

    { Текущее состояние заливки (SetFill OpCode=20).
      Устанавливается командой SetFill(1), сбрасывается после
      каждого графического примитива (как в ezdxf). }
    FFillActive: Boolean;

    { Стек матриц трансформации для PushMatrix/PopMatrix.
      Когда PushMatrix встречается — матрица читается и помещается
      в стек. Все последующие вершины примитивов трансформируются
      через текущую матрицу (вершина стека). PopMatrix убирает
      матрицу из стека, возвращая предыдущую. }
    FMatrixStack: array of TzeTypedMatrix4d;
    FMatrixStackDepth: Integer;

    { Разбирает заголовок блока; возвращает количество команд }
    function ParseHeader(out CommandCount: Integer): Boolean;

    { Разбирает одну команду; пропускает неизвестные }
    procedure ParseCommand;

    { Системные обработчики — не модульные, так как изменение их поведения
      требует изменения архитектуры всего прокси-объекта }
    procedure HandleExtents;
    procedure HandleSetColor;
    procedure HandleSetLayer;
    procedure HandlePushMatrix;
    procedure HandlePopMatrix;
    procedure HandleSetLinetype;
    procedure HandleSetMarker;
    procedure HandleSetFill;
    procedure HandleSetTrueColor;
    procedure HandleSetLineweight;
    procedure HandleSetLtScale;
    procedure HandleSetThickness;
    procedure SkipDataBytes(const CommandSize: Integer);

    { Добавляет распаршенный примитив в результат: сохраняет OpCode,
      HandlerResult целиком (включая вершины), и текущее состояние
      атрибутов парсера. HandlerResult при этом «передаёт» владение
      данными — внешний код не должен вызывать HandlerResult.Vertices.done. }
    procedure AppendPrimitive(const OpCode: Integer;
      const HandlerResult: TProxyHandlerResult);

    { Расширяет суммарный BBox данными из одного примитива }
    procedure MergeHandlerBBox(const HandlerResult: TProxyHandlerResult);

    { Применяет текущую матрицу из стека к вершинам результата
      обработчика (если стек не пуст). }
    procedure TransformHandlerVertices(
      var HandlerResult: TProxyHandlerResult);

    { Проверяет, является ли текущая матрица в стеке единичной }
    function HasActiveTransform: Boolean;

  public
    { AUnicodeText=True — «широкие» строки внутри прокси-графики
      декодируются как UTF-16 (DXF 2007+). False — как ANSI (DXF 2000/2004).
      Значение передаётся в TProxyByteStream. }
    constructor Create(const Data: TBytes;
      AUnicodeText: Boolean = True);
    destructor Destroy; override;

    { Разбирает весь блок Proxy Graphic; возвращает суммарный результат.
      Вершины внутри Primitives[i].HandlerResult.Vertices принадлежат
      результату и освобождаются вызывающей стороной через FreeParseResult. }
    function Parse: TProxyGraphicParseResult;
  end;

{ Освобождает память, занятую вершинами всех распаршенных примитивов.
  Должна вызываться после того, как все Builder-процедуры завершены. }
procedure FreeParseResult(var ParseResult: TProxyGraphicParseResult);

implementation

uses
  uzcLog;

const
  { Системные OpCode, обрабатываемые напрямую в этом модуле }
  OPCODE_EXTENTS          = 1;
  OPCODE_SET_COLOR        = 14;
  OPCODE_SET_LAYER        = 16;
  OPCODE_SET_LINETYPE     = 18;
  OPCODE_SET_MARKER       = 19;
  OPCODE_SET_FILL         = 20;
  OPCODE_SET_TRUE_COLOR   = 22;
  OPCODE_SET_LINEWEIGHT   = 23;
  OPCODE_SET_LTSCALE      = 24;
  OPCODE_SET_THICKNESS    = 25;
  OPCODE_PUSH_MATRIX      = 29;
  OPCODE_PUSH_MATRIX2     = 30;
  OPCODE_POP_MATRIX       = 31;

  { Размер заголовка одной команды: [CommandSize: int32] + [OpCode: int32] }
  COMMAND_HEADER_SIZE = 8;

  { Максимально разумное количество команд в одном блоке }
  MAX_COMMAND_COUNT = 100000;

{ === Вспомогательные функции уровня модуля === }

procedure FreeParseResult(var ParseResult: TProxyGraphicParseResult);
var
  I: Integer;
begin
  for I := 0 to High(ParseResult.Primitives) do
    if ParseResult.Primitives[I].HandlerResult.HasVertices then
      ParseResult.Primitives[I].HandlerResult.Vertices.done;
  SetLength(ParseResult.Primitives, 0);
  ParseResult.PrimitiveCount := 0;
  ParseResult.BBoxLoaded := False;
end;

{ === TProxyGraphicParser === }

constructor TProxyGraphicParser.Create(const Data: TBytes;
  AUnicodeText: Boolean);
begin
  inherited Create;
  FStream := TProxyByteStream.Create(Data, AUnicodeText);
  FillChar(FResult, SizeOf(FResult), 0);
  InitProxyState(FState);
  FFillActive := False;
  FMatrixStackDepth := 0;
  SetLength(FMatrixStack, 0);
end;

destructor TProxyGraphicParser.Destroy;
begin
  FStream.Free;
  inherited Destroy;
end;

{ Добавляет распаршенный примитив в результат парсера.
  Сохраняет OpCode, результат обработчика и текущее состояние
  атрибутов (слой, цвет, тип линии и т.д.) для последующей передачи
  в Builder-процедуру этого OpCode. }
procedure TProxyGraphicParser.AppendPrimitive(const OpCode: Integer;
  const HandlerResult: TProxyHandlerResult);
var
  Idx: Integer;
begin
  Idx := Length(FResult.Primitives);
  SetLength(FResult.Primitives, Idx + 1);
  FResult.Primitives[Idx].OpCode := OpCode;
  FResult.Primitives[Idx].HandlerResult := HandlerResult;
  FResult.Primitives[Idx].LineWeight := FState.LineWeight;
  FResult.Primitives[Idx].Color := FState.Color;
  FResult.Primitives[Idx].Layer := FState.Layer;
  FResult.Primitives[Idx].Linetype := FState.Linetype;
  FResult.Primitives[Idx].LtScale := FState.LtScale;
  FResult.Primitives[Idx].Thickness := FState.Thickness;
  FResult.Primitives[Idx].TrueColor := FState.TrueColor;

  programlog.LogOutFormatStr(
    'uzeentproxygraphicparser: AppendPrimitive[%d] OpCode=%d' +
    ' vertices=%d closed=%s filled=%s hasText=%s' +
    ' lineweight=%d color=%d trueColor=%d layer="%s" linetype="%s"' +
    ' ltScale=%.3f thickness=%.3f',
    [Idx, OpCode,
     HandlerResult.Vertices.Count,
     BoolToStr(HandlerResult.Closed, True),
     BoolToStr(HandlerResult.Filled, True),
     BoolToStr(HandlerResult.HasTextItem, True),
     FState.LineWeight, FState.Color, FState.TrueColor,
     FState.Layer, FState.Linetype,
     FState.LtScale, FState.Thickness], LM_Info);
end;

{ Расширяет суммарный BBox данными из результата обработчика }
procedure TProxyGraphicParser.MergeHandlerBBox(
  const HandlerResult: TProxyHandlerResult);
begin
  if not HandlerResult.HasBBox then
    Exit;
  MergeBBox(
    HandlerResult.BBoxMin, HandlerResult.BBoxMax,
    FResult.BBoxMin, FResult.BBoxMax,
    FResult.BBoxLoaded);
end;

{ Разбирает заголовок блока: [ChunkSize][CommandCount] }
function TProxyGraphicParser.ParseHeader(out CommandCount: Integer): Boolean;
var
  ChunkSize: Integer;
begin
  Result := False;
  CommandCount := 0;
  try
    ChunkSize := FStream.ReadInt32;
    CommandCount := FStream.ReadInt32;
    programlog.LogOutFormatStr(
      'uzeentproxygraphicparser: Header ChunkSize=%d CommandCount=%d',
      [ChunkSize, CommandCount], LM_Info);
    Result := (ChunkSize > 0)
      and (CommandCount > 0)
      and (CommandCount < MAX_COMMAND_COUNT);
  except
    on E: Exception do
      programlog.LogOutFormatStr(
        'uzeentproxygraphicparser: ParseHeader error: %s', [E.Message], LM_Info);
  end;
end;

{ Пропускает байты данных команды (всё, что идёт после заголовка) }
procedure TProxyGraphicParser.SkipDataBytes(const CommandSize: Integer);
var
  DataSize: Integer;
begin
  DataSize := CommandSize - COMMAND_HEADER_SIZE;
  if DataSize > 0 then
  begin
    programlog.LogOutFormatStr(
      'uzeentproxygraphicparser: SkipDataBytes %d bytes', [DataSize], LM_Info);
    FStream.Skip(DataSize);
  end;
end;

{ Системный обработчик: ExtentsCommand — BBox объекта из файла }
procedure TProxyGraphicParser.HandleExtents;
var
  MinPt, MaxPt: TzePoint3d;
begin
  try
    MinPt := FStream.ReadVertex;
    MaxPt := FStream.ReadVertex;
    programlog.LogOutFormatStr(
      'uzeentproxygraphicparser: Extents Min=(%.3f,%.3f,%.3f) Max=(%.3f,%.3f,%.3f)',
      [MinPt.x, MinPt.y, MinPt.z, MaxPt.x, MaxPt.y, MaxPt.z], LM_Info);
    { Extents из файла используем только как начальный BBox,
      если реальные примитивы ещё не дали своего }
    if not FResult.BBoxLoaded then
      MergeBBox(MinPt, MaxPt, FResult.BBoxMin, FResult.BBoxMax, FResult.BBoxLoaded);
  except
    on E: Exception do
      programlog.LogOutFormatStr(
        'uzeentproxygraphicparser: HandleExtents error: %s', [E.Message], LM_Info);
  end;
end;

{ Системный обработчик: SetColor — читает и сохраняет значение цвета }
procedure TProxyGraphicParser.HandleSetColor;
var
  Color: Integer;
begin
  try
    Color := FStream.ReadInt32;
    FState.Color := Color;
    programlog.LogOutFormatStr(
      'uzeentproxygraphicparser: SetColor value=%d', [Color], LM_Info);
  except
    on E: Exception do
      programlog.LogOutFormatStr(
        'uzeentproxygraphicparser: HandleSetColor error: %s', [E.Message], LM_Info);
  end;
end;

{ Системный обработчик: SetLayer — читает и сохраняет индекс слоя }
procedure TProxyGraphicParser.HandleSetLayer;
var
  LayerIndex: Integer;
begin
  try
    LayerIndex := FStream.ReadInt32;
    FState.Layer := IntToStr(LayerIndex);
    programlog.LogOutFormatStr(
      'uzeentproxygraphicparser: SetLayer index=%d', [LayerIndex], LM_Info);
  except
    on E: Exception do
      programlog.LogOutFormatStr(
        'uzeentproxygraphicparser: HandleSetLayer error: %s', [E.Message], LM_Info);
  end;
end;

{ Системный обработчик: PushMatrix — читает матрицу трансформации (16 double)
  и помещает её в стек. Все последующие примитивы будут трансформированы
  через эту матрицу до вызова PopMatrix. }
procedure TProxyGraphicParser.HandlePushMatrix;
var
  I, Row, Col: Integer;
  MatrixData: array[0..15] of Double;
  NewMatrix: TzeTypedMatrix4d;
begin
  try
    { Читаем 16 чисел double из потока (4×4 матрица, построчно) }
    for I := 0 to 15 do
      MatrixData[I] := FStream.ReadDouble;

    { Заполняем матрицу ZCAD.
      Формат proxy: построчно data[row*4 + col], translation в col 3.
      Формат ZCAD: .mtr.v[row].v[col], translation в row 3.
      Транспонируем: mtr.v[Row].v[Col] := data[Col * 4 + Row]. }
    for Row := 0 to 3 do
      for Col := 0 to 3 do
        NewMatrix.mtr.v[Row].v[Col] := MatrixData[Col * 4 + Row];

    { Явно устанавливаем тип матрицы «общая трансформация».
      Без этого поле t содержит мусор из стека, и если он совпадает
      с CMTIdentity, то VectorTransform3D пропускает умножение. }
    NewMatrix.t := CMTTransform;

    { Добавляем матрицу в стек }
    Inc(FMatrixStackDepth);
    if FMatrixStackDepth > Length(FMatrixStack) then
      SetLength(FMatrixStack, FMatrixStackDepth);
    FMatrixStack[FMatrixStackDepth - 1] := NewMatrix;

    programlog.LogOutFormatStr(
      'uzeentproxygraphicparser: PushMatrix depth=%d ' +
      'translation=(%.3f, %.3f, %.3f)',
      [FMatrixStackDepth,
       NewMatrix.mtr.v[3].v[0],
       NewMatrix.mtr.v[3].v[1],
       NewMatrix.mtr.v[3].v[2]],
      LM_Info);
  except
    on E: Exception do
      programlog.LogOutFormatStr(
        'uzeentproxygraphicparser: HandlePushMatrix error: %s',
        [E.Message], LM_Info);
  end;
end;

{ Системный обработчик: PopMatrix — убирает матрицу из стека }
procedure TProxyGraphicParser.HandlePopMatrix;
begin
  if FMatrixStackDepth > 0 then
  begin
    Dec(FMatrixStackDepth);
    programlog.LogOutFormatStr(
      'uzeentproxygraphicparser: PopMatrix depth=%d',
      [FMatrixStackDepth], LM_Info);
  end
  else
    programlog.LogOutFormatStr(
      'uzeentproxygraphicparser: PopMatrix on empty stack',
      [], LM_Info);
end;

{ Проверяет, есть ли активная (не единичная) матрица в стеке }
function TProxyGraphicParser.HasActiveTransform: Boolean;
begin
  Result := FMatrixStackDepth > 0;
end;

{ Применяет текущую матрицу из стека к вершинам и BBox результата.
  Если стек пуст — ничего не делает.
  Используется после каждого успешного вызова обработчика примитива.

  Для текстовых примитивов (HasTextItem) матрица применяется также к
  высоте и ширине символов (issue #978). Высота в Proxy Graphic задаётся
  в системе координат контейнера, поэтому после PushMatrix с масштабом
  она должна быть промасштабирована — иначе текст отображается
  мелко (или крупно) относительно окружающих его графических
  элементов. Алгоритм повторяет поведение GDBObjAbstractText.transform:
  переводится единичный отрезок длиной Height вдоль оси Y (матрица без
  translation), новая длина и становится масштабированной высотой. }
procedure TProxyGraphicParser.TransformHandlerVertices(
  var HandlerResult: TProxyHandlerResult);
var
  ir: itrec;
  pV: PzePoint3d;
  CurrentMatrix, LinearMatrix: TzeTypedMatrix4d;
  ScaledVec: TzePoint3d;
  NewHeight: Double;
begin
  if not HasActiveTransform then
    Exit;

  { Берём верхнюю матрицу из стека }
  CurrentMatrix := FMatrixStack[FMatrixStackDepth - 1];

  { Трансформируем вершины контура }
  if HandlerResult.HasVertices and (HandlerResult.Vertices.Count > 0) then
  begin
    pV := HandlerResult.Vertices.beginiterate(ir);
    while pV <> nil do
    begin
      pV^ := VectorTransform3D(pV^, CurrentMatrix);
      pV := HandlerResult.Vertices.iterate(ir);
    end;
  end;

  { Трансформируем BBox }
  if HandlerResult.HasBBox then
  begin
    HandlerResult.BBoxMin :=
      VectorTransform3D(HandlerResult.BBoxMin, CurrentMatrix);
    HandlerResult.BBoxMax :=
      VectorTransform3D(HandlerResult.BBoxMax, CurrentMatrix);
  end;

  { Трансформируем точку вставки и высоту текста.
    Для корректного масштабирования высоты нужна линейная часть
    матрицы (без translation), иначе длина отрезка (0, Height, 0)
    поплывёт из-за сдвига координат. }
  if HandlerResult.HasTextItem then
  begin
    HandlerResult.TextItem.Insert :=
      VectorTransform3D(HandlerResult.TextItem.Insert, CurrentMatrix);

    if HandlerResult.TextItem.Height > 0 then
    begin
      LinearMatrix := CurrentMatrix;
      PzePoint3d(@LinearMatrix.mtr.v[3])^ := NulVertex;
      LinearMatrix.t := CMTTransform;
      ScaledVec := VectorTransform3D(
        CreateVertex(0, HandlerResult.TextItem.Height, 0),
        LinearMatrix);
      NewHeight := oneVertexlength(ScaledVec);
      if NewHeight > 0 then
        HandlerResult.TextItem.Height := NewHeight;
    end;
  end;

  { Трансформируем центр круга }
  if HandlerResult.HasCircleItem then
    HandlerResult.CircleItem.Center :=
      VectorTransform3D(HandlerResult.CircleItem.Center, CurrentMatrix);

  { Трансформируем центр дуги }
  if HandlerResult.HasArcItem then
    HandlerResult.ArcItem.Center :=
      VectorTransform3D(HandlerResult.ArcItem.Center, CurrentMatrix);
end;

{ Системный обработчик: SetLinetype — читает индекс типа линии }
procedure TProxyGraphicParser.HandleSetLinetype;
var
  LinetypeIndex: Integer;
begin
  try
    LinetypeIndex := FStream.ReadInt32;
    FState.Linetype := IntToStr(LinetypeIndex);
    programlog.LogOutFormatStr(
      'uzeentproxygraphicparser: SetLinetype index=%d',
      [LinetypeIndex], LM_Info);
  except
    on E: Exception do
      programlog.LogOutFormatStr(
        'uzeentproxygraphicparser: HandleSetLinetype error: %s',
        [E.Message], LM_Info);
  end;
end;

{ Системный обработчик: SetMarker — читает индекс маркера выбора }
procedure TProxyGraphicParser.HandleSetMarker;
begin
  try
    FStream.ReadInt32;
  except
    on E: Exception do
      programlog.LogOutFormatStr(
        'uzeentproxygraphicparser: HandleSetMarker error: %s',
        [E.Message], LM_Info);
  end;
end;

{ Системный обработчик: SetFill — читает и сохраняет флаг заливки.
  Значение 1 = заливка включена, 0 = выключена.
  Флаг сбрасывается после каждого графического примитива. }
procedure TProxyGraphicParser.HandleSetFill;
var
  FillValue: Integer;
begin
  try
    FillValue := FStream.ReadInt32;
    FFillActive := (FillValue = 1);
    programlog.LogOutFormatStr(
      'uzeentproxygraphicparser: SetFill value=%d active=%s',
      [FillValue, BoolToStr(FFillActive, True)], LM_Info);
  except
    on E: Exception do
      programlog.LogOutFormatStr(
        'uzeentproxygraphicparser: HandleSetFill error: %s',
        [E.Message], LM_Info);
  end;
end;

{ Системный обработчик: SetTrueColor — читает значение RGB цвета }
procedure TProxyGraphicParser.HandleSetTrueColor;
var
  TrueColor: Integer;
begin
  try
    TrueColor := FStream.ReadInt32;
    FState.TrueColor := TrueColor;
    programlog.LogOutFormatStr(
      'uzeentproxygraphicparser: SetTrueColor value=%d',
      [TrueColor], LM_Info);
  except
    on E: Exception do
      programlog.LogOutFormatStr(
        'uzeentproxygraphicparser: HandleSetTrueColor error: %s',
        [E.Message], LM_Info);
  end;
end;

{ Системный обработчик: SetLineweight — читает вес линии }
procedure TProxyGraphicParser.HandleSetLineweight;
var
  LineWeight: Integer;
begin
  try
    LineWeight := FStream.ReadInt32;
    FState.LineWeight := LineWeight;
    programlog.LogOutFormatStr(
      'uzeentproxygraphicparser: SetLineweight value=%d',
      [LineWeight], LM_Info);
  except
    on E: Exception do
      programlog.LogOutFormatStr(
        'uzeentproxygraphicparser: HandleSetLineweight error: %s',
        [E.Message], LM_Info);
  end;
end;

{ Системный обработчик: SetLtScale — читает масштаб типа линии }
procedure TProxyGraphicParser.HandleSetLtScale;
var
  LtScale: Double;
begin
  try
    LtScale := FStream.ReadDouble;
    FState.LtScale := LtScale;
    programlog.LogOutFormatStr(
      'uzeentproxygraphicparser: SetLtScale value=%.3f',
      [LtScale], LM_Info);
  except
    on E: Exception do
      programlog.LogOutFormatStr(
        'uzeentproxygraphicparser: HandleSetLtScale error: %s',
        [E.Message], LM_Info);
  end;
end;

{ Системный обработчик: SetThickness — читает толщину }
procedure TProxyGraphicParser.HandleSetThickness;
var
  Thickness: Double;
begin
  try
    Thickness := FStream.ReadDouble;
    FState.Thickness := Thickness;
    programlog.LogOutFormatStr(
      'uzeentproxygraphicparser: SetThickness value=%.3f',
      [Thickness], LM_Info);
  except
    on E: Exception do
      programlog.LogOutFormatStr(
        'uzeentproxygraphicparser: HandleSetThickness error: %s',
        [E.Message], LM_Info);
  end;
end;

{ Разбирает одну команду.
  Системные OpCode обрабатываются напрямую.
  Остальные передаются в TProxyOpCodeDispatcher.
  После обработки команды указатель потока устанавливается на начало
  следующей команды (по CommandSize), даже если обработчик не прочитал
  все данные. Это необходимо для корректного разбора команд с
  дополнительными данными (traits), которые обработчик может пропустить. }
procedure TProxyGraphicParser.ParseCommand;
var
  CommandSize: Integer;
  OpCode: Integer;
  HandlerResult: TProxyHandlerResult;
  StartIndex: Integer;
  ExpectedEnd: Integer;
  BytesRemaining: Integer;
begin
  { Запоминаем позицию начала команды (до чтения заголовка) }
  StartIndex := FStream.Index;

  CommandSize := FStream.ReadInt32;
  OpCode := FStream.ReadInt32;

  { Позиция, на которой должна закончиться обработка команды }
  ExpectedEnd := StartIndex + CommandSize;

  { База для выравнивания строковых полей в handler'е. Паддинг в
    Proxy Graphic считается относительно начала payload (позиции сразу
    после заголовка команды), а не абсолютного индекса в потоке. Без
    этой установки после команды с размером не кратным 4 (например,
    бит-упакованная LWPOLYLINE размером 53 байта в DXF 2007) все
    строковые поля в последующих командах читаются со сдвигом 1–3
    байта, и height текста (и другие поля) становятся мусором.
    См. issue #1014 и ezdxf.proxygraphic, где ByteStream создаётся
    заново для payload каждой команды. }
  FStream.PaddingBase := FStream.Index;

  programlog.LogOutFormatStr(
    'uzeentproxygraphicparser: Command OpCode=%d Size=%d',
    [OpCode, CommandSize], LM_Info);

  { Слишком маленький размер команды — пропускаем }
  if CommandSize < COMMAND_HEADER_SIZE then
    Exit;

  { Обёртываем диспетчеризацию в try..finally, чтобы любая ошибка
    внутри обработчика (например, бит-упакованный формат LWPOLYLINE
    или повреждённые данные) не оставила FStream посреди команды:
    позиция гарантированно будет сдвинута на ExpectedEnd, и парсер
    продолжит разбор следующей команды. До этой защиты единичная
    ошибка в одном примитиве (например, LWPOLYLINE в DXF 2007,
    issue #1012) теряла все последующие сегменты выноски. }
  try
    { Сначала проверяем системные OpCode }
    case OpCode of
      OPCODE_EXTENTS:
        HandleExtents;

      OPCODE_SET_COLOR:
        HandleSetColor;

      OPCODE_SET_LAYER:
        HandleSetLayer;

      OPCODE_SET_LINETYPE:
        HandleSetLinetype;

      OPCODE_SET_MARKER:
        HandleSetMarker;

      OPCODE_SET_FILL:
        HandleSetFill;

      OPCODE_SET_TRUE_COLOR:
        HandleSetTrueColor;

      OPCODE_SET_LINEWEIGHT:
        HandleSetLineweight;

      OPCODE_SET_LTSCALE:
        HandleSetLtScale;

      OPCODE_SET_THICKNESS:
        HandleSetThickness;

      OPCODE_PUSH_MATRIX, OPCODE_PUSH_MATRIX2:
        HandlePushMatrix;

      OPCODE_POP_MATRIX:
        HandlePopMatrix;

    else
      { Передаём в диспетчер — каждый зарегистрированный модуль-парсер
        получит вызов своего обработчика }
      if TProxyOpCodeDispatcher.IsRegistered(OpCode) then
      begin
        if TProxyOpCodeDispatcher.HandleOpCode(OpCode, FStream, HandlerResult) then
        begin
          { Применяем матрицу трансформации из стека (если есть) }
          TransformHandlerVertices(HandlerResult);

          { Обновляем суммарный BBox }
          MergeHandlerBBox(HandlerResult);

          { Определяем заливку: флаг FFillActive применяется
            к замкнутым контурам (Polygon, Shell и др.).
            Аналогично ezdxf: SetFill(1) → Polygon/Shell = SOLID. }
          if HandlerResult.HasVertices and (HandlerResult.Vertices.Count > 0)
            and FFillActive and HandlerResult.Closed then
            HandlerResult.Filled := True;

          { Сохраняем примитив — владение данными (Vertices) переходит к
            результату парсера и будет освобождено через FreeParseResult. }
          AppendPrimitive(OpCode, HandlerResult);
          Inc(FResult.PrimitiveCount);

          { Сбрасываем флаг заливки после каждого примитива
            (аналогично ezdxf: fill auto-reset после entity) }
          FFillActive := False;
        end
        else
        begin
          programlog.LogOutFormatStr(
            'uzeentproxygraphicparser: Handler for OpCode=%d returned invalid result',
            [OpCode], LM_Info);
          { Handler вернул invalid — на всякий случай освобождаем вершины,
            если они были инициализированы. }
          if HandlerResult.HasVertices then
            HandlerResult.Vertices.done;
          SkipDataBytes(CommandSize);
        end;
      end
      else
      begin
        programlog.LogOutFormatStr(
          'uzeentproxygraphicparser: OpCode=%d not registered, skipping %d bytes',
          [OpCode, CommandSize - COMMAND_HEADER_SIZE], LM_Info);
        SkipDataBytes(CommandSize);
      end;
    end;
  finally
    { Корректируем позицию потока: если обработчик не прочитал все
      данные команды (например, traits у Shell), пропускаем остаток.
      Это гарантирует, что следующая команда будет прочитана с верной
      позиции — даже если выше произошло исключение. }
    BytesRemaining := ExpectedEnd - FStream.Index;
    if BytesRemaining > 0 then
    begin
      programlog.LogOutFormatStr(
        'uzeentproxygraphicparser: Skipping %d trailing bytes for OpCode=%d',
        [BytesRemaining, OpCode], LM_Info);
      FStream.Skip(BytesRemaining);
    end
    else if BytesRemaining < 0 then
    begin
      { Обработчик прочитал больше, чем размер команды (битая команда).
        В этом случае возвращаемся к ExpectedEnd, иначе следующая
        команда будет прочитана с неверной позиции. Пропускать назад
        TProxyByteStream не умеет — это поможет лишь обнаружить
        проблему в логах. }
      programlog.LogOutFormatStr(
        'uzeentproxygraphicparser: WARNING OpCode=%d overran by %d bytes',
        [OpCode, -BytesRemaining], LM_Info);
    end;
  end;
end;

{ Главный метод: разбирает весь блок Proxy Graphic }
function TProxyGraphicParser.Parse: TProxyGraphicParseResult;
var
  CommandCount, I: Integer;
begin
  SetLength(FResult.Primitives, 0);
  FResult.BBoxLoaded := False;
  FResult.PrimitiveCount := 0;

  programlog.LogOutFormatStr(
    'uzeentproxygraphicparser: Parse START (registered handlers: %d)',
    [TProxyOpCodeDispatcher.GetRegisteredCount], LM_Info);

  try
    if not ParseHeader(CommandCount) then
    begin
      programlog.LogOutFormatStr(
        'uzeentproxygraphicparser: ParseHeader failed', [], LM_Info);
      Result := FResult;
      Exit;
    end;

    for I := 0 to CommandCount - 1 do
    begin
      if FStream.EndOfStream then
        Break;
      try
        ParseCommand;
      except
        on E: Exception do
        begin
          { Одиночное исключение в обработчике (например, из-за
            бит-упакованного формата команды или повреждённых данных)
            не должно прерывать разбор всего блока Proxy Graphic.
            Иначе все последующие команды теряются — именно это
            ломает мультивыноску в DXF 2007 (issue #1012): после
            попытки разобрать LWPOLYLINE стримом байтов остальные
            сегменты выноски просто не доходили до построителей.

            ParseCommand уже сдвигает FStream на ExpectedEnd при
            обычном выходе; здесь мы обрабатываем случай аварийного
            выхода — продолжаем со следующей команды по тому же
            принципу: ищем границу команды и сбрасываем флаги
            заливки/состояния как при штатной обработке. }
          programlog.LogOutFormatStr(
            'uzeentproxygraphicparser: Command %d exception (continuing): %s',
            [I, E.Message], LM_Info);
          FFillActive := False;
        end;
      end;
    end;

    programlog.LogOutFormatStr(
      'uzeentproxygraphicparser: Parse DONE: primitives=%d bbox=%s',
      [FResult.PrimitiveCount,
       BoolToStr(FResult.BBoxLoaded, True)], LM_Info);

  except
    on E: Exception do
      programlog.LogOutFormatStr(
        'uzeentproxygraphicparser: Parse exception: %s', [E.Message], LM_Info);
  end;

  Result := FResult;
end;

end.
