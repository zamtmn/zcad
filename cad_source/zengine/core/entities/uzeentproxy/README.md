# Модуль ProxyEntity (uzeentproxy)

> Автор: Vladimir Bobrov
> Расположение: `cad_source/zcad/velec/uzeentproxy/`

Модуль реализует поддержку прокси-объектов AutoCAD (`ACAD_PROXY_ENTITY`) в ZCAD: читает бинарный блок Proxy Graphic из DXF, разбирает его на примитивы в формате `AcGiWorldDraw`, применяет состояние атрибутов (цвет, слой, тип линии, матрицы трансформации), а затем превращает каждую распарсенную команду в отдельный подпримитив ZCAD (линия, дуга, окружность, текст, солид и т.д.), который добавляется в `ConstObjArray` прокси-объекта и отрисовывается стандартным механизмом `GDBObjComplex`.

## 1. Назначение и зона ответственности

`ACAD_PROXY_ENTITY` — это сущность, которую AutoCAD использует для представления объектов, созданных сторонними приложениями (ObjectARX), когда родной класс недоступен. В DXF такая сущность несёт бинарный Proxy Graphic (код `310`) — последовательность команд рендеринга, описывающих, как отрисовать объект без знания его исходного класса.

Модуль `uzeentproxy` решает следующие задачи:

1. Принимает бинарные данные Proxy Graphic от загрузчика DXF.
2. Разбирает заголовок и последовательность команд в соответствии с форматом `AcGiWorldDraw` (Proxy Graphic Binary Chunk Interpretation из AutoCAD DevBlog).
3. Определяет BBox объекта и точку вставки (ручку — grip).
4. Преобразует распознанные примитивы в подпримитивы ZCAD.
5. Обеспечивает корректное сохранение прокси-объекта обратно в DXF как `BlockInsert` (с автоматически сгенерированным блоком с уникальным именем `PE<N>`).

Внешние потребители обращаются только к классу `GDBObjAcdProxy` (объявлен в `uzeentacdproxy.pas`) — остальные модули являются частными деталями реализации.

## 2. Архитектура

### 2.1. Общая схема обработки

```
DXF-поток
    │
    ▼
GDBObjAcdProxy.LoadFromDXF  ← код 310 (hex-строка) → FProxyDataBytes (TBytes)
    │
    ▼
GDBObjAcdProxy.FormatEntity
    │
    ▼
GDBObjAcdProxy.BuildSubEntities
    │
    ├─ создаёт TProxyByteStream (с учётом версии DXF: UTF-16 или ANSI)
    │
    ├─ TProxyGraphicParser.Parse
    │     │
    │     ├─ ParseHeader  → ChunkSize, CommandCount
    │     │
    │     └─ Для каждой команды:
    │           ├─ читает [CommandSize: int32][OpCode: int32]
    │           ├─ системные OpCode (Extents, Set*, Push/PopMatrix) —
    │           │   обрабатываются внутри парсера и меняют FState
    │           └─ примитивные OpCode (Circle, Arc, Text и т.д.) —
    │               передаются в TProxyOpCodeDispatcher
    │                     │
    │                     ▼
    │               Зарегистрированный Handler читает данные из потока,
    │               заполняет TProxyHandlerResult (вершины, BBox, TextItem,
    │               CircleItem, ArcItem, флаги Closed/Filled)
    │                     │
    │                     ▼
    │               Парсер применяет текущую матрицу стека PushMatrix,
    │               сливает BBox, сохраняет примитив вместе с текущим
    │               состоянием (цвет, слой, тип линии, LineWeight, LtScale)
    │
    └─ Для каждого сохранённого примитива вызывается
       Builder-процедура соответствующего OpCode, которая создаёт
       конкретный подпримитив ZCAD в ConstObjArray прокси-объекта.
```

### 2.2. Файлы модуля и их роль

| Файл | Роль |
|------|------|
| `uzeentacdproxy.pas` | Класс `GDBObjAcdProxy` — прокси-объект, наследник `GDBObjComplex`. Парсит DXF (коды 90/91/92/93/94/95/70/310), хранит бинарные Proxy Graphic данные, создаёт подпримитивы в `FormatEntity`, сохраняет прокси в DXF как `BlockInsert` с именем `PE<N>`. |
| `uzeentproxytypes.pas` | Перечисление всех OPCODE (`TProxyGraphicCommand`), описание состояния парсера (`TProxyGraphicState`), структуры данных примитивов (`TProxyCircleData`, `TProxyArcData`, `TProxyTextData`, `TProxyPolylineData`, `TProxyShellData` и т.д.). |
| `uzeentproxystream.pas` | Класс `TProxyByteStream` — низкоуровневое чтение little-endian бинарных данных: `ReadInt32`, `ReadDouble`, `ReadVertex`, `ReadString`, `ReadUnicodeString`, `ReadPaddedUnicodeString`. Поддерживает выбор между UTF-16 (DXF 2007+) и ANSI (DXF 2000/2004). |
| `uzeentproxymanager.pas` | Диспетчер `TProxyOpCodeDispatcher` — таблица из 256 записей `TProxyOpCodeEntry`. Каждый модуль-парсер регистрирует свой обработчик (`Handler`) и построитель подпримитивов (`Builder`) через `RegisterOpCode`. Также содержит `TProxySubEntityContext` — контекст, передаваемый в построители, и вспомогательные процедуры `ExpandBBox`/`MergeBBox`. |
| `uzeentproxygraphicparser.pas` | Класс `TProxyGraphicParser` — верхний уровень парсера: читает заголовок, итерирует команды, обрабатывает системные OpCode (Extents, SetColor, SetLayer, SetLinetype, SetMarker, SetFill, SetTrueColor, SetLineweight, SetLtScale, SetThickness, PushMatrix, PushMatrix2, PopMatrix), передаёт примитивные OpCode в диспетчер, применяет текущую матрицу трансформации, собирает суммарный BBox. |
| `uzeentproxybaseparser.pas` | Базовый класс `TProxyBaseParser` для парсеров-потомков. Реализует интерфейс `IProxyPrimitiveParser`, предоставляет общие утилиты: `TransformToOCS` (перевод WCS → OCS по нормали), `NormalizeAngle`, `VectorIsClose`, `VectorNormalize`, `CrossProduct`. |
| `uzeentproxysubentitybuilder.pas` | Общие процедуры для построителей подпримитивов: `ProxyToLocalPoint` (вычитание grip-offset), `ResolveLineWeight` (учёт ByLayer/ByBlock/ByLwDefault), `ResolveColor` (учёт ByBlock/ByLayer/палитры 1..255), `ResolveLineTypeScale`, `ApplyLineTypeScale`, `BuildLineSubEntity`, `BuildLinesFromVertices`, `BuildSolidFromVertices` (триангуляция веером из вершины 0). |
| `uzeentproxyparsercircle.pas` | Парсер OpCode = 2 (Circle). Создаёт подпримитив `GDBObjCircle` без тесселяции. |
| `uzeentproxyparserarc.pas` | Парсер OpCode = 4 (CircularArc). Создаёт подпримитив `GDBObjArc` без тесселяции. |
| `uzeentproxyparserpolyline.pas` | Парсер OpCode = 6 (Polyline). Разбивает многовершинный контур на `GDBObjLine`. Отрезок (LINE) — частный случай при `VertexCount = 2`. |
| `uzeentproxyparserpolygon.pas` | Парсер OpCode = 7 (Polygon). Замкнутый контур: линии + `GDBObjSolid` (при активной заливке — `SetFill(1)`). |
| `uzeentproxyparsershell.pas` | Парсер OpCode = 9 (Shell / PolyFaceMesh). Грани отрисовываются замкнутыми полилиниями. |
| `uzeentproxyparsertext.pas` | Парсер OpCode = 10 / 11 / 38 (Text1, Text2, UnicodeText2). Создаёт подпримитив `GDBObjText` с учётом высоты, ширины, угла наклона, TypeFace. |
| `uzeentproxyparserpolylinewithnormals.pas` | Парсер OpCode = 32 (PolylineWithNormals). Нормаль используется для BBox и OCS; геометрия строится как обычная полилиния. |
| `uzeentproxyparserlwpolyline.pas` | Парсер OpCode = 33 (LWPolyline). 2D-полилиния с постоянным Elevation, поддержкой Closed-флага и `ConstWidth`. Bulge игнорируется (сегменты всегда прямые). |
| `uzeentproxyparserellipse.pas` | Парсер OpCode = 44 (EllipticArc). Тесселяция параметрически: `P(t) = Center + cos(t)·MajorAxis + sin(t)·MinorAxis` (64 отрезка для полного эллипса). |

### 2.3. Принцип «каждый примитив сам себя регистрирует»

Архитектура повторяет идею `TEntityFactory` из `uzeentityfactory.pas`:

- В секции `initialization` каждого модуля-парсера вызывается `TProxyOpCodeDispatcher.RegisterOpCode(OpCode, Name, @Handler, @Builder)`.
- Диспетчер хранит массив `[0..255] of TProxyOpCodeEntry` — по одной ячейке на OpCode.
- При парсинге команды с нерегистрированным OpCode данные пропускаются по полю `CommandSize`, парсинг продолжается со следующей команды.

Благодаря этому, чтобы отключить поддержку конкретного примитива, достаточно исключить его `.pas` из проекта — в главном модуле `uzeentacdproxy.pas` ничего менять не нужно. Регистрация просто не произойдёт.

## 3. Бинарный формат Proxy Graphic

### 3.1. Заголовок блока

```
[ChunkSize:    int32 little-endian]   — общий размер данных
[CommandCount: int32 little-endian]   — количество команд
```

### 3.2. Заголовок каждой команды

```
[CommandSize: int32]   — размер команды вместе с заголовком (8 байт минимум)
[OpCode:      int32]   — код операции (см. табл. в разделе 4)
[Данные ...]           — CommandSize - 8 байт данных, формат зависит от OpCode
```

Если `CommandSize < 8`, команда считается невалидной и пропускается.

После обработки команды парсер гарантирует, что курсор потока установлен ровно на `StartIndex + CommandSize` — это защищает следующую команду от того, что обработчик прочитал на несколько байт меньше ожидаемого (например, пропустил traits в Shell).

### 3.3. Кодировка строк

DXF-файл несёт версию в переменной `$ACADVER`:

| Версия DXF | $ACADVER | iVersion | Кодировка Unicode-строк |
|------------|----------|----------|-------------------------|
| 2000 | AC1015 | 1015 | ANSI (1 байт/символ) |
| 2004 | AC1018 | 1018 | ANSI (1 байт/символ) |
| 2007+ | AC1021+ | ≥ 1021 | UTF-16 LE (2 байта/символ) |

`GDBObjAcdProxy.LoadFromDXF` сохраняет `iVersion` в поле `FDXFFileVersion` и передаёт соответствующий флаг `AUnicodeText` в конструктор `TProxyByteStream`. Флаг управляет методами `ReadUnicodeString` и `ReadPaddedUnicodeString`.

Строки в AcGiWorldDraw обычно выравниваются по границе 4 байт (паддинг до DWORD) — это делает `ReadPaddedUnicodeString`.

## 4. Расшифрованные OPCODE

Полный набор известных значений перечислен в `TProxyGraphicCommand` (файл `uzeentproxytypes.pas`). Таблица ниже описывает, какие из них реализованы в модуле.

### 4.1. Системные команды (реализованы в `uzeentproxygraphicparser.pas`)

Изменяют внутреннее состояние парсера (`FState: TProxyGraphicState` или стек матриц), но не создают подпримитивов.

| OPCODE | Имя | Описание |
|:------:|-----|----------|
| 1 | `pgcExtents` | Границы объекта в WCS: `[MinPt: 3×double][MaxPt: 3×double]`. Используется как начальный BBox, если ни один примитив ещё не дал своего. |
| 14 | `pgcAttributeColor` | `SetColor`: читает `int32` и сохраняет в `FState.Color` (BYLAYER = -1, BYBLOCK = 0, 1..255 — индекс палитры). |
| 16 | `pgcAttributeLayer` | `SetLayer`: читает `int32` индекс слоя и сохраняет его строковое представление в `FState.Layer`. |
| 18 | `pgcAttributeLinetype` | `SetLinetype`: читает `int32` индекс типа линии. |
| 19 | `pgcAttributeMarker` | `SetMarker`: читает `int32` маркер выбора и игнорирует его. |
| 20 | `pgcAttributeFill` | `SetFill`: читает `int32`, `1 = ON` / `0 = OFF`. Флаг автоматически сбрасывается после каждого графического примитива — совпадает с поведением `ezdxf`. |
| 22 | `pgcAttributeTrueColor` | `SetTrueColor`: читает `int32` RGB-значение. |
| 23 | `pgcAttributeLineWeight` | `SetLineweight`: читает `int32` вес линии. |
| 24 | `pgcAttributeLtScale` | `SetLtScale`: читает `double` масштаб типа линии. |
| 25 | `pgcAttributeThickness` | `SetThickness`: читает `double` толщину. |
| 29 | `pgcPushMatrix` | Читает 4×4 матрицу (16 × `double`, построчно) и добавляет её в стек. Все последующие примитивы трансформируются через эту матрицу до `PopMatrix`. При добавлении матрица транспонируется из формата `data[row*4 + col]` в формат ZCAD `mtr.v[row].v[col]`, тип явно устанавливается в `CMTTransform`. |
| 30 | `pgcPushMatrix2` | Синоним `PushMatrix` (версионный OpCode). Обрабатывается тем же кодом. |
| 31 | `pgcPopMatrix` | Убирает верхнюю матрицу из стека. |

Для текстовых примитивов активная матрица применяется также к высоте символов — высота пересчитывается по длине вектора `(0, Height, 0)`, трансформированного линейной частью матрицы (без translation). Это реплицирует поведение `GDBObjAbstractText.transform` и было введено для фикса issue #978.

### 4.2. Графические команды (реализованы в отдельных модулях-парсерах)

| OPCODE | Имя | Модуль-парсер | Формат данных | Создаваемые подпримитивы |
|:------:|-----|---------------|---------------|--------------------------|
| 2 | `pgcCircle` | `uzeentproxyparsercircle.pas` | `Center: 3×double`, `Radius: double`, `Normal: 3×double` | `GDBObjCircle` (без тесселяции) |
| 4 | `pgcCircularArc` | `uzeentproxyparserarc.pas` | `Center: 3×double`, `Radius: double`, `Normal: 3×double`, `StartVector: 3×double`, `SweepAngle: double`, `ArcType: int32` | `GDBObjArc` (без тесселяции) |
| 6 | `pgcPolyline` | `uzeentproxyparserpolyline.pas` | `VertexCount: int32`, `VertexCount × (3×double)` | Набор `GDBObjLine` между последовательными вершинами. При `VertexCount = 2` — одна линия (LINE). |
| 7 | `pgcPolygon` | `uzeentproxyparserpolygon.pas` | `VertexCount: int32` (≥ 3), `VertexCount × (3×double)` | Замкнутые `GDBObjLine` + (при активном `SetFill(1)`) `GDBObjSolid` через триангуляцию веером |
| 9 | `pgcShell` | `uzeentproxyparsershell.pas` | `VertexCount: int32`, `Vertices`, `FaceEntryCount: int32`, список граней `[EdgeCount: int32][Index0..N: uint32]`, traits (edge/face/vertex) | Замкнутые `GDBObjLine` по контурам каждой грани |
| 10 | `pgcText` | `uzeentproxyparsertext.pas` | `Position: 3×double`, `Normal: 3×double`, `Direction: 3×double`, `Height`, `WidthFactor`, `ObliqueAngle: double`, `Text`: null-terminated ANSI | `GDBObjText` |
| 11 | `pgcText2` | `uzeentproxyparsertext.pas` | Расширенный ANSI-текст (DXF 2000/2004): `Position/Normal/Direction`, `Text: ANSI z-terminated (выравнено)`, `Length`, `Raw`, `Height`, `WidthFactor`, `ObliqueAngle`, `TrackingPercentage`, флаги `IsBackward/IsUpsideDown/IsVertical/IsUnderlined/IsOverlined`, `FontName`, `BigFontName` | `GDBObjText` |
| 32 | `pgcPolylineWithNormals` | `uzeentproxyparserpolylinewithnormals.pas` | `VertexCount: int32`, вершины, `Normal: 3×double` | Полилиния как набор `GDBObjLine` (нормаль используется для BBox) |
| 33 | `pgcLwPolyline` | `uzeentproxyparserlwpolyline.pas` | `Flags: int32` (бит 0 — замкнута), `ConstWidth`, `Elevation`, `Thickness`, `Normal: 3×double`, `VertexCount`, на каждую вершину `Point2D + Bulge + StartWidth + EndWidth` | Набор `GDBObjLine` с подстановкой `Z = Elevation`. Bulge не тесселируется (прямые сегменты). |
| 38 | `pgcUnicodeText2` | `uzeentproxyparsertext.pas` | Unicode-текст (DXF 2007+): `Position/Normal/Direction`, `Text: UTF-16 z-terminated (выравнено)`, `IgnoreLen`, `Raw`, `Height`, `WidthFactor`, `ObliqueAngle`, `TrackingPercentage`, флаги, `IsBold/IsItalic/Charset/Pitch`, `TypeFace`, `FontName`, `BigFontName` | `GDBObjText` со стилем, подобранным по `TypeFace` через `GDBTextStyleArray.FindStyleByTypeface` |
| 44 | `pgcEllipticArc` | `uzeentproxyparserellipse.pas` | `Center: 3×double`, `Normal: 3×double`, `MajorAxisVector: 3×double` (длина = MajorRadius), `MinorAxisRatio: double` (0..1), `StartParam: double`, `EndParam: double` | `GDBObjLine` (64 отрезка на полный эллипс; пропорционально для дуги) |

### 4.3. Известные, но не реализованные OPCODE

Эти значения определены в `TProxyGraphicCommand`, но в модуле пока не регистрируются. При встрече таких команд парсер пропускает их данные по `CommandSize`:

| OPCODE | Имя | Комментарий |
|:------:|-----|-------------|
| 3 | `pgcCircle3P` | Круг по трём точкам |
| 5 | `pgcCircularArc3P` | Дуга по трём точкам |
| 8 | `pgcMesh` | Меш (сетка) — `Rows`, `Columns`, массив вершин |
| 12 | `pgcXLine` | Конструкционная линия (бесконечная) |
| 13 | `pgcRay` | Луч |
| 15, 17, 21 | `pgcUnused*` | Зарезервированы и не используются в AcGiWorldDraw |
| 26 | `pgcAttributePlotStyle` | Стиль печати |
| 27 | `pgcPushClip` | Начало клипирования |
| 28 | `pgcPopClip` | Конец клипирования |
| 34 | `pgcAttributeMaterial` | Материал |
| 35 | `pgcAttributeMapper` | UV Mapper |
| 36 | `pgcUnicodeText` | Unicode-текст без расширенных атрибутов |
| 37 | `pgcUnknown37` | Не задокументирован в AutoCAD DevBlog |

## 5. Состояние парсера (`TProxyGraphicState`)

Парсер поддерживает текущие значения атрибутов, которые применяются к следующему за ними графическому примитиву. На момент сохранения распарсенного примитива в `TProxyParsedPrimitive` эти значения копируются в запись — это позволяет Builder-у сохранить корректные цвет/слой/вес/тип линии, даже если после этого в потоке придёт `SetColor(BYLAYER)` или другая смена состояния.

| Поле | Значение по умолчанию | Источник |
|------|------------------------|----------|
| `Color` | `-1` (BYLAYER) | `SetColor` (OpCode 14) |
| `Layer` | `'0'` | `SetLayer` (OpCode 16) |
| `Linetype` | `'BYLAYER'` | `SetLinetype` (OpCode 18) |
| `LineWeight` | `-1` (BYLAYER) | `SetLineweight` (OpCode 23) |
| `LtScale` | `1.0` | `SetLtScale` (OpCode 24) |
| `Thickness` | `0.0` | `SetThickness` (OpCode 25) |
| `Fill` | `False` | `SetFill` (OpCode 20); автоматически сбрасывается после каждого графического примитива |
| `TrueColor` | `0` | `SetTrueColor` (OpCode 22) |
| `MatrixCount` | `0` | Глубина стека `PushMatrix` / `PushMatrix2` / `PopMatrix` |

## 6. Создаваемые подпримитивы ZCAD

Для каждого распарсенного примитива вызывается Builder, зарегистрированный вместе с Handler. В качестве параметров Builder получает:

- `TProxyHandlerResult` — вершины, BBox, флаги `Closed`/`Filled`, и опциональные структуры `CircleItem` / `ArcItem` / `TextItem`.
- `TProxySubEntityContext` — указатели на владельца (`GDBObjAcdProxy`), массив подпримитивов (`ConstObjArray`), текущий `TDrawingDef` и `TDrawContext`, атрибуты владельца (Layer/LineType/LineWeight/Color/LineTypeScale), атрибуты текущего примитива из `FState`, смещение `GripOffset` (ручка).

Итоговая таблица создаваемых ZCAD-сущностей:

| OPCODE | Результирующие подпримитивы |
|:------:|-----------------------------|
| 2 | `GDBObjCircle` |
| 4 | `GDBObjArc` |
| 6 | `GDBObjLine` × (N-1) |
| 7 | `GDBObjLine` × N (замкнутый контур) + `GDBObjSolid` × (N-2) при `Fill = ON` |
| 9 | `GDBObjLine` по контурам каждой грани |
| 10, 11, 38 | `GDBObjText` |
| 32 | `GDBObjLine` × (N-1) |
| 33 | `GDBObjLine` × (N-1) + опциональный замыкающий отрезок при флаге Closed |
| 44 | `GDBObjLine` (результат тесселяции в 64 отрезка) |

### 6.1. Правила разрешения атрибутов (`uzeentproxysubentitybuilder.pas`)

- `ResolveLineWeight`: если вес контура — `ByLayer`/`ByBlock`/`ByLwDefault`, подставляется `OwnerLineWeight`.
- `ResolveColor`: `ByBlock (0)` → `OwnerColor`; `ByLayer (256 или -1)` → `ClByLayer`; явные индексы `1..255` применяются как есть.
- `ResolveLineTypeScale`: `OwnerLineTypeScale × PrimitiveLineTypeScale`, нули и отрицательные значения трактуются как `1`.
- `ProxyToLocalPoint`: координаты примитива приводятся к локальной системе относительно `GripOffset`, чтобы подпримитивы правильно перемещались при перемещении прокси-объекта.

## 7. Сохранение в DXF (конвертация в BlockInsert)

Прокси-объект нельзя сохранить как `ACAD_PROXY_ENTITY` без знания его оригинального DWG-класса, поэтому при сохранении в DXF:

1. Вызывается `ConvertProxyEntitiesToBlocks` (зарегистрирована через `RegisterBeforeSaveDxfProc`).
2. Эта процедура обходит дерево чертежа и для каждого `GDBObjAcdProxy` создаёт в `BlockDefArray` блок с уникальным именем вида `PE<N>` (где `N` — случайное число из диапазона `[0 .. 1 000 000 000]`, гарантированно отсутствующее в таблице блоков).
3. Имя сгенерированного блока запоминается в поле `FConvertedBlockName` прокси-объекта.
4. Подпримитивы (Lines/Arcs/Circles/Text/Solids, созданные через `BuildSubEntities`) копируются в созданный блок.
5. При сохранении прокси-объекта как `BlockInsert` используется это имя блока.

Префикс `PE` (Proxy Entity) выбран как короткий маркер, позволяющий в DXF-файле легко отличать «блоки, сгенерированные из прокси-объектов» от обычных пользовательских блоков.

## 8. Логирование

Модуль широко использует `uzcLog.programlog.LogOutFormatStr(..., LM_Info)` на всех ключевых этапах (парсинг заголовка, каждая команда, каждый примитив, регистрация Handler-ов, ошибки). Это существенно облегчает диагностику некорректных DXF-файлов: по логу видно, на каком OpCode произошёл сбой и какие байты прочитаны.

## 9. Известные ограничения

- **Bulge в LWPOLYLINE (OpCode = 33)** не тесселируется — дуги внутри 2D-полилиний отображаются как прямые сегменты.
- **Заполнение (Hatch)** поддерживается через триангуляцию полигона в набор `GDBObjSolid` — сложные паттерны штриховки (ISO/ANSI линиями) не рисуются.
- **Меш (OpCode = 8)**, **Circle3P (3)**, **CircularArc3P (5)**, **XLine (12)**, **Ray (13)**, **Material (34)**, **Mapper (35)**, **PushClip (27)** / **PopClip (28)** — данные пропускаются по размеру команды, примитив не строится.
- **Traits** у `Shell` (`EdgeTraitFlags`, `FaceTraitFlags`, `VertexTraitFlags`) читаются, но не используются при отрисовке.
- **Unicode-текст без расширенных атрибутов (OpCode = 36)** не реализован — ожидается, что DXF 2007+ файлы используют `UnicodeText2` (OpCode = 38).

## 10. Как добавить поддержку нового OpCode

1. Создать файл `uzeentproxyparser<имя>.pas` в текущей папке.
2. В секции `implementation` подключить `uzeentproxymanager`, `uzeentproxystream`, `uzeentproxysubentitybuilder`.
3. Реализовать:
   - `procedure HandleXxx(Stream: TProxyByteStream; out HandlerResult: TProxyHandlerResult);`
   - `procedure BuildXxxSubEntities(const HandlerResult: TProxyHandlerResult; const Context: TProxySubEntityContext);`
4. В секции `initialization` вызвать:
   ```pascal
   TProxyOpCodeDispatcher.RegisterOpCode(
     XXX_OPCODE, 'Xxx', @HandleXxx, @BuildXxxSubEntities);
   ```
5. Добавить `uses uzeentproxyparser<имя>` в `uzeentacdproxy.pas` (в список модулей-парсеров под комментарием «Подключаем модули-парсеры примитивов»).

Главный модуль (`uzeentacdproxy.pas`) не содержит знаний о конкретных OpCode — вся диспетчеризация построена на таблице регистрации.

## 11. Ссылки и источники

- AutoCAD DevBlog — *Proxy Graphic Binary Chunk Interpretation*.
- `ezdxf` (Python) — `ezdxf.proxygraphic.ProxyGraphic`: референсная реализация парсера, с которой сверялись форматы команд и поведение `SetFill`.
- `uzeentityfactory.pas` — образец архитектуры регистрации обработчиков через диспетчер в ZCAD, по которому построен `TProxyOpCodeDispatcher`.
