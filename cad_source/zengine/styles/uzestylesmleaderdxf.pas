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
  Модуль: uzestylesmleaderdxf
  Назначение: типы стилей мультивыносок (MLEADERSTYLE) для DXF-обмена.
  Реализован по аналогии с uzestylestablesdxf.pas для стилей таблиц.

  Стили мультивыносок в DXF хранятся в секции OBJECTS в виде
  объектов MLEADERSTYLE, связанных через словарь ACAD_MLEADERSTYLE.
  Чтение и запись — NOD-обработчик uzestylesmleaderdxfnod (этап 6 ТЗ
  cad_source/zengine/TZ_NOD_NamedObjectDictionary.md); прежний разбор и
  запись по сырому тексту секции OBJECTS удалены.

  Зависимости: UGDBNamedObjectsArray, gzctnrVectorTypes, uzeNamedObject
}
unit uzestylesmleaderdxf;
{$Mode delphi}{$H+}
{$INCLUDE zengineconfig.inc}
interface
uses
  UGDBNamedObjectsArray,
  uzeNamedObject,
  gzctnrVectorTypes;

{ === Типы данных для DXF-стилей мультивыносок === }

type
  { Пара «код группы / значение» DXF, которую модель стиля не разбирает }
  TGDBDXFMLeaderStylePair = record
    Code: Integer;
    Value: string;
  end;
  TGDBDXFMLeaderStylePairs = array of TGDBDXFMLeaderStylePair;

  { Стиль мультивыноски для DXF-обмена — именованный объект.
    Содержит все параметры, необходимые для записи/чтения
    MLEADERSTYLE в DXF. Параметры соответствуют group codes
    из спецификации DXF для объекта AcDbMLeaderStyle. }
  TGDBDXFMLeaderStyle = object(GDBNamedObject)
    { Тип линии выноски: 0=прямая, 1=сплайн, 2=нет (код 170) }
    LeaderLineType: Integer;
    { Цвет линии выноски (код 91) }
    LeaderLineColor: Integer;
    { Тип стрелки выноски (код 171) }
    LeaderLineTypeId: Integer;
    { Ограничение первого сегмента (код 172) }
    FirstSegAngleConstraint: Integer;
    { Ограничение второго сегмента (код 173) }
    SecondSegAngleConstraint: Integer;
    { Тип содержимого: 0=нет, 1=блок, 2=мтекст (код 90) }
    ContentType: Integer;
    { Угол первого сегмента (код 40) }
    FirstSegAngle: Double;
    { Угол второго сегмента (код 41) }
    SecondSegAngle: Double;
    { Хэндл типа линии выноски (код 340, LTYPE) }
    LeaderLinetypeHandle: string;
    { Имя типа линии выноски (разрешённое из хэндла) }
    LeaderLinetypeName: string;
    { Тип присоединения текста слева (код 174) }
    TextAttachmentLeft: Integer;
    { Тип присоединения текста справа (код 178) }
    TextAttachmentRight: Integer;
    { Выравнивание текста по горизонтали (код 175) }
    TextAngleType: Integer;
    { Режим выравнивания (код 176) }
    TextAlignmentType: Integer;
    { Режим соединения (код 177) }
    TextAttachmentDirection: Integer;
    { Цвет линии соединения (код 92) }
    LeaderLineWeight: Integer;
    { Наличие площадки (код 290) }
    EnableDogleg: Boolean;
    { Расстояние площадки (код 42) }
    DoglegLength: Double;
    { Наличие рамки текста (код 291) }
    EnableLanding: Boolean;
    { Длина площадки (код 43) }
    LandingGap: Double;
    { Имя стиля мультивыноски (код 3) }
    Description: string;
    { Хэндл блока стрелки (код 341, BLOCK_RECORD) }
    ArrowHeadBlockHandle: string;
    { Имя блока стрелки (разрешённое из хэндла) }
    ArrowHeadBlockName: string;
    { Масштаб содержимого (код 44) }
    TextHeight: Double;
    { Имя текстового стиля по умолчанию (код 300) }
    DefaultTextContent: string;
    { Хэндл текстового стиля (код 342, STYLE) }
    TextStyleHandle: string;
    { Имя текстового стиля (разрешённое из хэндла) }
    TextStyleName: string;
    { Цвет текста мультивыноски (код 93) }
    TextColor: Integer;
    { Расстояние от площадки (код 45) }
    ArrowHeadSize: Double;
    { Наличие выравнивания текста сверху/снизу (код 292) }
    TextAlignAlwaysLeft: Boolean;
    { Выравнивание по направлению (код 297) }
    AlignSpace: Boolean;
    { Масштаб блока (код 46) }
    BlockContentScale: Double;
    { Хэндл блока содержимого (код 343, BLOCK_RECORD) }
    BlockContentHandle: string;
    { Имя блока содержимого (разрешённое из хэндла) }
    BlockContentName: string;
    { Цвет блока содержимого (код 94) }
    BlockContentColor: Integer;
    { Множитель масштаба (код 47) }
    BlockContentScaleX: Double;
    { Масштаб Y (код 49) }
    BlockContentScaleY: Double;
    { Общий масштаб (код 140) }
    OverallScale: Double;
    { Аннотативный (код 293) }
    Annotative: Boolean;
    { Расстояние от точки разрыва (код 141) }
    BreakGapSize: Double;
    { Текст по направлению (код 294) }
    TextDirectionNegative: Boolean;
    { Присоединение сверху/снизу (код 295) }
    IsBlockContent: Boolean;
    { Содержимое: мультитекст (код 296) }
    IsMTextContent: Boolean;
    { Масштаб блока Z (код 142) }
    BlockContentScaleZ: Double;
    { Флаг поворота блока (код 143) }
    BlockContentRotation: Double;
    { Хэндл расширенного словаря (блок 102/ACAD_XDICTIONARY) }
    XDictHandle: string;
    { Версия ACAD_MLEADERVER (xdata код 1070) }
    MLeaderVersion: Integer;
    { Группы тела AcDbMLeaderStyle, которые модель не разбирает (например,
      из новых версий AutoCAD), — в исходном порядке; при записи выводятся
      после известных групп, до расширенных данных. Ссылки на объекты
      (коды 320-369, 390-399, 480-481) сюда не попадают. }
    ExtraPairs: TGDBDXFMLeaderStylePairs;
    constructor init(const StyleName: string);
    destructor Done; virtual;
    { Копирует параметры стиля из ASource (создание стиля «на основе»).
      Имя стиля не меняется. Хэндл расширенного словаря не копируется:
      словарь принадлежит объекту ASource. }
    procedure CopyPropertiesFrom(const ASource: TGDBDXFMLeaderStyle);
  end;
  PTGDBDXFMLeaderStyle = ^TGDBDXFMLeaderStyle;

  { Массив стилей мультивыносок для DXF-обмена }
  GDBDXFMLeaderStyleArray = object(
    GDBNamedObjectsArray<PTGDBDXFMLeaderStyle,
                         TGDBDXFMLeaderStyle>)
    constructor init(InitialCapacity: Integer);
    constructor initnul;
    { Добавляет стиль или возвращает существующий }
    function AddStyle(
      const StyleName: string): PTGDBDXFMLeaderStyle;
  end;
  PGDBDXFMLeaderStyleArray = ^GDBDXFMLeaderStyleArray;

implementation

{ === Конструктор и деструктор TGDBDXFMLeaderStyle === }

{ Инициализирует стиль мультивыноски значениями по умолчанию,
  соответствующими AutoCAD Standard MLEADERSTYLE }
constructor TGDBDXFMLeaderStyle.init(
  const StyleName: string);
begin
  inherited Init(StyleName);
  LeaderLineType := 2;
  LeaderLineColor := -1056964608;
  LeaderLineTypeId := 1;
  FirstSegAngleConstraint := 0;
  SecondSegAngleConstraint := 1;
  ContentType := 2;
  FirstSegAngle := 0.0;
  SecondSegAngle := 0.0;
  { Инициализируем строки через nil для raw memory }
  pointer(LeaderLinetypeHandle) := nil;
  pointer(LeaderLinetypeName) := nil;
  TextAttachmentLeft := 1;
  TextAttachmentRight := 1;
  TextAngleType := 1;
  TextAlignmentType := 0;
  TextAttachmentDirection := 0;
  LeaderLineWeight := -2;
  EnableDogleg := True;
  DoglegLength := 0.09;
  EnableLanding := True;
  LandingGap := 0.36;
  pointer(Description) := nil;
  pointer(ArrowHeadBlockHandle) := nil;
  pointer(ArrowHeadBlockName) := nil;
  TextHeight := 0.18;
  pointer(DefaultTextContent) := nil;
  pointer(TextStyleHandle) := nil;
  pointer(TextStyleName) := nil;
  TextColor := -1056964608;
  ArrowHeadSize := 0.18;
  TextAlignAlwaysLeft := False;
  AlignSpace := False;
  BlockContentScale := 0.18;
  pointer(BlockContentHandle) := nil;
  pointer(BlockContentName) := nil;
  BlockContentColor := -1056964608;
  BlockContentScaleX := 1.0;
  BlockContentScaleY := 1.0;
  OverallScale := 1.0;
  Annotative := True;
  BreakGapSize := 0.0;
  TextDirectionNegative := True;
  IsBlockContent := False;
  IsMTextContent := False;
  BlockContentScaleZ := 1.0;
  BlockContentRotation := 0.125;
  pointer(XDictHandle) := nil;
  MLeaderVersion := 2;
  pointer(ExtraPairs) := nil;
end;

{ Освобождает ресурсы строковых полей }
destructor TGDBDXFMLeaderStyle.Done;
begin
  inherited Done;
  LeaderLinetypeHandle := '';
  LeaderLinetypeName := '';
  Description := '';
  ArrowHeadBlockHandle := '';
  ArrowHeadBlockName := '';
  DefaultTextContent := '';
  TextStyleHandle := '';
  TextStyleName := '';
  BlockContentHandle := '';
  BlockContentName := '';
  XDictHandle := '';
  ExtraPairs := nil;
end;

{ Копирует все параметры, кроме имени и хэндла расширенного словаря }
procedure TGDBDXFMLeaderStyle.CopyPropertiesFrom(
  const ASource: TGDBDXFMLeaderStyle);
begin
  LeaderLineType := ASource.LeaderLineType;
  LeaderLineColor := ASource.LeaderLineColor;
  LeaderLineTypeId := ASource.LeaderLineTypeId;
  FirstSegAngleConstraint := ASource.FirstSegAngleConstraint;
  SecondSegAngleConstraint := ASource.SecondSegAngleConstraint;
  ContentType := ASource.ContentType;
  FirstSegAngle := ASource.FirstSegAngle;
  SecondSegAngle := ASource.SecondSegAngle;
  LeaderLinetypeHandle := ASource.LeaderLinetypeHandle;
  LeaderLinetypeName := ASource.LeaderLinetypeName;
  TextAttachmentLeft := ASource.TextAttachmentLeft;
  TextAttachmentRight := ASource.TextAttachmentRight;
  TextAngleType := ASource.TextAngleType;
  TextAlignmentType := ASource.TextAlignmentType;
  TextAttachmentDirection := ASource.TextAttachmentDirection;
  LeaderLineWeight := ASource.LeaderLineWeight;
  EnableDogleg := ASource.EnableDogleg;
  DoglegLength := ASource.DoglegLength;
  EnableLanding := ASource.EnableLanding;
  LandingGap := ASource.LandingGap;
  Description := ASource.Description;
  ArrowHeadBlockHandle := ASource.ArrowHeadBlockHandle;
  ArrowHeadBlockName := ASource.ArrowHeadBlockName;
  TextHeight := ASource.TextHeight;
  DefaultTextContent := ASource.DefaultTextContent;
  TextStyleHandle := ASource.TextStyleHandle;
  TextStyleName := ASource.TextStyleName;
  TextColor := ASource.TextColor;
  ArrowHeadSize := ASource.ArrowHeadSize;
  TextAlignAlwaysLeft := ASource.TextAlignAlwaysLeft;
  AlignSpace := ASource.AlignSpace;
  BlockContentScale := ASource.BlockContentScale;
  BlockContentHandle := ASource.BlockContentHandle;
  BlockContentName := ASource.BlockContentName;
  BlockContentColor := ASource.BlockContentColor;
  BlockContentScaleX := ASource.BlockContentScaleX;
  BlockContentScaleY := ASource.BlockContentScaleY;
  OverallScale := ASource.OverallScale;
  Annotative := ASource.Annotative;
  BreakGapSize := ASource.BreakGapSize;
  TextDirectionNegative := ASource.TextDirectionNegative;
  IsBlockContent := ASource.IsBlockContent;
  IsMTextContent := ASource.IsMTextContent;
  BlockContentScaleZ := ASource.BlockContentScaleZ;
  BlockContentRotation := ASource.BlockContentRotation;
  MLeaderVersion := ASource.MLeaderVersion;
  { Отдельная копия массива: динамические массивы общие по ссылке }
  ExtraPairs := Copy(ASource.ExtraPairs);
end;

{ === Методы GDBDXFMLeaderStyleArray === }

constructor GDBDXFMLeaderStyleArray.init(
  InitialCapacity: Integer);
begin
  inherited init(InitialCapacity);
end;

constructor GDBDXFMLeaderStyleArray.initnul;
begin
  inherited initnul;
end;

{ Добавляет стиль с заданным именем или возвращает
  существующий }
function GDBDXFMLeaderStyleArray.AddStyle(
  const StyleName: string): PTGDBDXFMLeaderStyle;
var
  StylePtr: PTGDBDXFMLeaderStyle;
begin
  case AddItem(StyleName, pointer(StylePtr)) of
    IsFounded:
      { Стиль уже существует — возвращаем без изменений };
    IsCreated:
      StylePtr^.init(StyleName);
    IsError:
      StylePtr := nil;
  end;
  Result := StylePtr;
end;

end.
