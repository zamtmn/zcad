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
  Модуль: uzeentproxytypes
  Назначение: Типы данных для парсера Proxy Graphic (AcGiWorldDraw формат)
  На основе анализа ezdxf и AutoCAD DevBlog
}

unit uzeentproxytypes;
{$Mode delphi}{$H+}
{$INCLUDE zengineconfig.inc}

interface

uses
  uzeTypes,
  uzeGeometryTypes,
  SysUtils,
  uzeentity,
  uzedrawingdef;

type
  { OPCODE команд Proxy Graphic (AcGiWorldDraw формат)
    Источник: AutoCAD DevBlog - Proxy Graphic Binary Chunk Interpretation }
  TProxyGraphicCommand = (
    pgcExtents = 1,              // Границы объекта (BBox)
    pgcCircle = 2,               // Круг
    pgcCircle3P = 3,             // Круг по 3 точкам
    pgcCircularArc = 4,          // Дуга
    pgcCircularArc3P = 5,        // Дуга по 3 точкам
    pgcPolyline = 6,             // Полилиния
    pgcPolygon = 7,              // Полигон
    pgcMesh = 8,                 // Меш (сетка)
    pgcShell = 9,                // Оболочка
    pgcText = 10,                // Текст
    pgcText2 = 11,               // Текст (расширенный)
    pgcXLine = 12,               // Конструкционная линия
    pgcRay = 13,                 // Луч
    pgcAttributeColor = 14,      // Установить цвет
    pgcUnused15 = 15,            // Не используется
    pgcAttributeLayer = 16,      // Установить слой
    pgcUnused17 = 17,            // Не используется
    pgcAttributeLinetype = 18,   // Установить тип линии
    pgcAttributeMarker = 19,     // Маркер выбора
    pgcAttributeFill = 20,       // Заполнение
    pgcUnused21 = 21,            // Не используется
    pgcAttributeTrueColor = 22,  // True цвет (RGB)
    pgcAttributeLineWeight = 23, // Вес линии
    pgcAttributeLtScale = 24,    // Масштаб типа линии
    pgcAttributeThickness = 25,  // Толщина
    pgcAttributePlotStyle = 26,  // Стиль печати
    pgcPushClip = 27,            // Начать клипирование
    pgcPopClip = 28,             // Закончить клипирование
    pgcPushMatrix = 29,          // Начать трансформацию (матрица)
    pgcPushMatrix2 = 30,         // Начать трансформацию (v2)
    pgcPopMatrix = 31,           // Закончить трансформацию
    pgcPolylineWithNormals = 32, // Полилиния с нормалями
    pgcLwPolyline = 33,          // 2D полилиния (LWPOLYLINE)
    pgcAttributeMaterial = 34,   // Материал
    pgcAttributeMapper = 35,     // Mapper
    pgcUnicodeText = 36,         // Текст Unicode
    pgcUnknown37 = 37,           // Неизвестно
    pgcUnicodeText2 = 38,        // Текст Unicode (расширенный)
    pgcEllipticArc = 44          // Эллиптическая дуга
  );

  { Типы примитивов для конвертации в сущности ZCAD }
  TProxyPrimitiveType = (
    pptUnknown,
    pptCircle,        // Круг → PGDBObjCircle
    pptArc,           // Дуга → PGDBObjArc
    pptPolyline,      // Полилиния → PGDBObjPolyline / PGDBObjLWPolyline
    pptPolygon,       // Полигон → PGDBObjPolyline (closed) + Hatch
    pptText,          // Текст → PGDBObjText
    pptMText,         // Многострочный текст → PGDBObjMText
    pptLine,          // Линия → PGDBObjLine
    pptPoint,         // Точка → PGDBObjPoint
    pptSpline,        // Сплайн → PGDBObjSpline
    pptEllipse,       // Эллипс → PGDBObjEllipse
    pptSolid,         // Заполненная область → PGDBObjSolid
    pptHatch,         // Штриховка → PGDBObjHatch
    pptMesh           // Меш → PGDBObjPolyFaceMesh
  );

  { Состояние парсера (атрибуты, применяемые к сущностям) }
  TProxyGraphicState = record
    Color: Integer;           // BYLAYER = -1, BYBLOCK = 0, 1-255
    Layer: string;            // Имя слоя (по умолчанию "0")
    Linetype: string;         // Тип линии (по умолчанию "BYLAYER")
    LineWeight: Integer;      // Вес линии (-2 = BYLAYER)
    LtScale: Double;          // Масштаб типа линии (1.0)
    Thickness: Double;        // Толщина (0.0)
    Fill: Boolean;            // Заполнение (false)
    TrueColor: Integer;       // True цвет (0 = none, >0 = RGB)
    MatrixCount: Integer;     // Количество матриц в стеке
  end;

  { Данные круга }
  TProxyCircleData = record
    Center: TzePoint3d;
    Radius: Double;
    Normal: TzePoint3d;
  end;

  { Данные дуги }
  TProxyArcData = record
    Center: TzePoint3d;
    Radius: Double;
    Normal: TzePoint3d;
    StartVector: TzePoint3d;
    SweepAngle: Double;  // радианы
    ArcType: Integer;
  end;

  { Данные дуги по 3 точкам }
  TProxyArc3PData = record
    Point1: TzePoint3d;
    Point2: TzePoint3d;
    Point3: TzePoint3d;
    ArcType: Integer;
  end;

  { Данные полилинии }
  TProxyPolylineData = record
    VertexCount: Integer;
    Vertices: array of TzePoint3d;
    HasBulge: Boolean;
    Bulges: array of Double;
    Closed: Boolean;
  end;

  { Данные полигона }
  TProxyPolygonData = record
    VertexCount: Integer;
    Vertices: array of TzePoint3d;
  end;

  { Данные текста }
  TProxyTextData = record
    Insert: TzePoint3d;
    Normal: TzePoint3d;
    Direction: TzePoint3d;
    Height: Double;
    WidthFactor: Double;
    ObliqueAngle: Double;
    Text: string;
    Length: Integer;
    Raw: Boolean;
    TextStyle: string;
    FontName: string;
    BigFontName: string;
    IsBackward: Boolean;
    IsUpsideDown: Boolean;
    IsVertical: Boolean;
    IsUnderlined: Boolean;
    IsOverlined: Boolean;
    TrackingPercentage: Double;
  end;

  { Данные эллиптической дуги }
  TProxyEllipticArcData = record
    Center: TzePoint3d;
    Extrusion: TzePoint3d;
    MajorAxisLength: Double;
    MinorAxisLength: Double;
    MajorAxisDirection: TzePoint3d;  // Направление большой оси
    MajorAxisAngle: Double;          // Угол направления большой оси (в радианах)
    StartParam: Double;
    EndParam: Double;
  end;

  { Данные меша }
  TProxyMeshData = record
    Rows: Integer;
    Columns: Integer;
    VertexCount: Integer;
    Vertices: array of TzePoint3d;
    EdgeFlags: Integer;
    FaceFlags: Integer;
    VertexFlags: Integer;
  end;

  { Данные оболочки (SHELL) }
  TProxyShellData = record
    VertexCount: Integer;
    Vertices: array of TzePoint3d;
    FaceCount: Integer;
    Faces: array of array of Integer;  // Индексы вершин
  end;

  { Результат парсинга команды }
  TProxyCommandResult = record
    PrimitiveType: TProxyPrimitiveType;
    Valid: Boolean;
    ErrorMsg: string;
    // Данные примитива (заполняются в зависимости от типа)
    CircleData: TProxyCircleData;
    ArcData: TProxyArcData;
    Arc3PData: TProxyArc3PData;
    PolylineData: TProxyPolylineData;
    PolygonData: TProxyPolygonData;
    TextData: TProxyTextData;
    EllipticArcData: TProxyEllipticArcData;
    MeshData: TProxyMeshData;
    ShellData: TProxyShellData;
  end;

  { Заголовок Proxy Graphic }
  TProxyGraphicHeader = record
    ChunkSize: Integer;      // Общий размер данных
    CommandCount: Integer;   // Количество команд
  end;

  { Заголовок команды }
  TProxyCommandHeader = record
    Size: Integer;           // Размер пакета команды
    OpCode: TProxyGraphicCommand;
  end;

const
  { Значения по умолчанию для состояния }
  PROXY_DEFAULT_LAYER = '0';
  PROXY_DEFAULT_LINETYPE = 'BYLAYER';
  PROXY_DEFAULT_COLOR = -1;      // BYLAYER
  PROXY_DEFAULT_LINEWEIGHT = -1; // BYLAYER
  PROXY_DEFAULT_LTSCALE = 1.0;
  PROXY_DEFAULT_THICKNESS = 0.0;
  PROXY_DEFAULT_FILL = False;

  { Минимальный размер заголовка }
  PROXY_HEADER_SIZE = 8;  // 2 × Int32
  PROXY_COMMAND_HEADER_SIZE = 8;  // 2 × Int32

{ Инициализация результата парсинга }
procedure InitCommandResult(var Result: TProxyCommandResult);
{ Инициализация состояния по умолчанию }
procedure InitProxyState(var State: TProxyGraphicState);

implementation

{ Инициализация состояния по умолчанию }
procedure InitProxyState(var State: TProxyGraphicState);
begin
  State.Color := PROXY_DEFAULT_COLOR;
  State.Layer := PROXY_DEFAULT_LAYER;
  State.Linetype := PROXY_DEFAULT_LINETYPE;
  State.LineWeight := PROXY_DEFAULT_LINEWEIGHT;
  State.LtScale := PROXY_DEFAULT_LTSCALE;
  State.Thickness := PROXY_DEFAULT_THICKNESS;
  State.Fill := PROXY_DEFAULT_FILL;
  State.TrueColor := 0;
  State.MatrixCount := 0;
end;

{ Инициализация результата парсинга }
procedure InitCommandResult(var Result: TProxyCommandResult);
begin
  Result.PrimitiveType := pptUnknown;
  Result.Valid := False;
  Result.ErrorMsg := '';
  SetLength(Result.PolylineData.Vertices, 0);
  SetLength(Result.PolygonData.Vertices, 0);
  SetLength(Result.MeshData.Vertices, 0);
end;

end.
