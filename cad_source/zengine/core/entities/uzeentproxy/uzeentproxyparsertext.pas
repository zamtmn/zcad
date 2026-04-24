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
  Модуль: uzeentproxyparsertext
  Назначение: Парсер текстовых примитивов для прокси-объектов.
              Обрабатывает три вида текста:
              - OpCode = 10 (pgcText)   — ANSI строка (kAcGiOpText1)
              - OpCode = 11 (pgcText2)  — расширенный текст с шрифтом
                (DXF 2000/2004, AC1015/AC1018)
              - OpCode = 38 (pgcUnicodeText2) — Unicode строка с расширенными
                атрибутами (DXF 2007+, AC1021+)

  Архитектура:
  - Секция initialization регистрирует обработчики в TProxyOpCodeDispatcher
  - Для отключения парсинга текста достаточно исключить этот файл из проекта

  Формат OpCode=10 (Text1):
    Position  — 3 × double (позиция вставки)
    Normal    — 3 × double (нормаль)
    Direction — 3 × double (направление текста)
    Height    — double (высота символов)
    WidthFactor — double (масштаб по ширине)
    ObliqueAngle — double (угол наклона, радианы)
    Text      — null-terminated ANSI строка

  Формат OpCode=11 (Text2) — расширенный текст в DXF 2000/2004:
    Position  — 3 × double
    Normal    — 3 × double
    Direction — 3 × double
    Text      — null-terminated ANSI строка (выровнена по 4 байтам)
    Length    — int32
    Raw       — int32
    Height    — double
    WidthFactor — double
    ObliqueAngle — double
    TrackingPercentage — double
    IsBackward, IsUpsideDown, IsVertical, IsUnderlined, IsOverlined — uint32
    FontName   — null-terminated ANSI (выровнена по 4 байтам)
    BigFontName — null-terminated ANSI (выровнена по 4 байтам)

  Формат OpCode=38 (UnicodeText2):
    Position  — 3 × double
    Normal    — 3 × double
    Direction — 3 × double
    Text      — UTF-16 null-terminated строка (выровнена по 4 байтам)
    IgnoreLen — int32
    Raw       — int32
    Height    — double
    WidthFactor — double
    ObliqueAngle — double
    TrackingPercentage — double
    IsBackward, IsUpsideDown, IsVertical, IsUnderlined, IsOverlined — uint32
    IsBold, IsItalic, Charset, Pitch — uint32 (отсутствуют в OpCode=11)
    TypeFace  — null-terminated Unicode (отсутствует в OpCode=11)
    FontName  — null-terminated Unicode
    BigFontName — null-terminated Unicode

  Текущая реализация:
  - BBox вычисляется аппроксимационно: ширина = len(text) × height × wfactor
  - Рендер текста: TextItem заполняется и передаётся в GDBObjAcdProxy.DrawTextItems,
    которая вызывает Representation.DrawTextContent с шрифтом из таблицы стилей чертежа
  - HandlerResult.HasVertices = False (текст не тесселируется в полилинию)
}

unit uzeentproxyparsertext;
{$Mode delphi}{$H+}
{$INCLUDE zengineconfig.inc}

interface

{ Регистрация происходит автоматически в секции initialization }

implementation

uses
  SysUtils,
  Math,
  uzeentproxystream,
  uzeentproxymanager,
  uzeentproxysubentitybuilder,
  { uzeentmtext,  — оставлено для возможного возврата к MTEXT, см. BuildTextSubEntitiesMText ниже }
  uzeenttext,
  uzeentity,
  uzeentgenericsubentry,
  UGDBVisibleOpenArray,
  uzestyleslayers,
  uzestyleslinetypes,
  uzestylestexts,
  uzedrawingdef,
  uzgldrawcontext,
  uzepalette,
  uzeTypes,
  uzegeometrytypes,
  uzegeometry,
  uzeconsts,
  uzeentabstracttext,
  UGDBPoint3DArray,
  uzcLog;

const
  { OpCode ANSI-текста }
  TEXT_OPCODE         = 10;
  { OpCode расширенного текста (DXF 2000/2004) — аналог UnicodeText2,
    но без TypeFace и Bold/Italic/Charset/Pitch, все строки однобайтовые. }
  TEXT2_OPCODE        = 11;
  { OpCode расширенного Unicode-текста }
  UNICODE_TEXT2_OPCODE = 38;

  { Порог параллельности для алгоритма произвольной оси }
  TEXT_AXIS_THRESHOLD = 0.9;

  { Нормаль WCS по оси Z }
  TEXT_Z_AXIS: TzePoint3d = (x: 0.0; y: 0.0; z: 1.0);

{ --- Вспомогательные процедуры --- }

function VectorsAreEqual(const V1, V2: TzePoint3d;
  const Epsilon: Double = 1e-9): Boolean;
begin
  Result := (Abs(V1.x - V2.x) <= Epsilon)
    and (Abs(V1.y - V2.y) <= Epsilon)
    and (Abs(V1.z - V2.z) <= Epsilon);
end;

{ Переводит точку из WCS в OCS по нормали Normal }
function TransformPointToOCS(const Point, Normal: TzePoint3d): TzePoint3d;
const
  AuxX: TzePoint3d = (x: 1.0; y: 0.0; z: 0.0);
  AuxY: TzePoint3d = (x: 0.0; y: 1.0; z: 0.0);
var
  ZAxis, XAxis, YAxis: TzePoint3d;
begin
  ZAxis := NormalizeVertex(Normal);

  if Abs(ZAxis.x) < TEXT_AXIS_THRESHOLD then
    XAxis := NormalizeVertex(AuxX * ZAxis.z - ZAxis * AuxX.z)
  else
    XAxis := NormalizeVertex(AuxY * ZAxis.z - ZAxis * AuxY.z);

  YAxis := NormalizeVertex(ZAxis * XAxis.x - XAxis * ZAxis.x);

  Result.x := scalarDot(Point, XAxis);
  Result.y := scalarDot(Point, YAxis);
  Result.z := scalarDot(Point, ZAxis);
end;

{ Вычисляет аппроксимационный BBox текста.
  Ширина = количество символов × высота × коэффициент ширины. }
procedure CalcTextBBox(const Insert: TzePoint3d;
  const Text: string; const Height, WidthFactor: Double;
  out BBoxMin, BBoxMax: TzePoint3d);
var
  TextWidth: Double;
begin
  TextWidth := Length(Text) * Height * WidthFactor;
  BBoxMin.x := Insert.x;
  BBoxMin.y := Insert.y;
  BBoxMin.z := Insert.z;
  BBoxMax.x := Insert.x + TextWidth;
  BBoxMax.y := Insert.y + Height;
  BBoxMax.z := Insert.z + Height;
end;

{ --- Обработчики OpCode --- }

{ Читает текстовый примитив формата OpCode=10 (ANSI Text1).
  Возвращает BBox и TextItem для отрисовки через DrawTextContent. }
procedure HandleText(
  Stream: TProxyByteStream;
  out HandlerResult: TProxyHandlerResult);
var
  Insert, Normal, Direction: TzePoint3d;
  Height, WidthFactor: Double;
  Text: string;
  Angle: Double;
begin
  HandlerResult.Valid := False;
  HandlerResult.HasVertices := False;
  HandlerResult.HasBBox := False;
  HandlerResult.HasTextItem := False;

  { Читаем геометрию }
  Insert := Stream.ReadVertex;
  Normal := Stream.ReadVector;
  Direction := Stream.ReadVector;

  Height := Stream.ReadDouble;
  WidthFactor := Stream.ReadDouble;
  Stream.ReadDouble;    { ObliqueAngle — пока не используется }

  Text := Stream.ReadString(TEncoding.ANSI);

  programlog.LogOutFormatStr(
    'uzeentproxyparsertext: Text1 Insert=(%.3f,%.3f,%.3f) H=%.3f Text="%s"',
    [Insert.x, Insert.y, Insert.z, Height, Text], LM_Info);

  if (Height <= 0) or (Text = '') then
    Exit;

  { Переводим в OCS если нормаль не совпадает с Z }
  if not VectorsAreEqual(Normal, TEXT_Z_AXIS) then
    Insert := TransformPointToOCS(Insert, Normal);

  { Угол поворота текста из вектора Direction (проекция на плоскость XY) }
  if (Abs(Direction.x) > 1e-9) or (Abs(Direction.y) > 1e-9) then
    Angle := ArcTan2(Direction.y, Direction.x)
  else
    Angle := 0.0;

  { Аппроксимационный BBox }
  CalcTextBBox(Insert, Text, Height, WidthFactor,
    HandlerResult.BBoxMin, HandlerResult.BBoxMax);
  HandlerResult.HasBBox := True;

  { Заполняем данные текстового примитива для отрисовки }
  HandlerResult.TextItem.Insert := Insert;
  HandlerResult.TextItem.Text := Text;
  HandlerResult.TextItem.Height := Height;
  HandlerResult.TextItem.WidthFactor := WidthFactor;
  HandlerResult.TextItem.Angle := Angle;
  HandlerResult.TextItem.FontName := '';
  HandlerResult.TextItem.TypeFace := '';
  HandlerResult.TextItem.BigFontName := '';
  HandlerResult.HasTextItem := True;

  HandlerResult.Valid := True;

  programlog.LogOutFormatStr(
    'uzeentproxyparsertext: Text1 OK, angle=%.3f rad, TextItem filled',
    [Angle], LM_Info);
end;

{ Читает расширенный Unicode-текст формата OpCode=38 (UnicodeText2).
  Возвращает BBox и TextItem для отрисовки через DrawTextContent.
  Структура полей шрифта соответствует AcGiWorldDraw/ezdxf:
  - TypeFace   — читаемое имя шрифта ("Times New Roman"), хранится в
                 FontFamily стиля текста ZCAD (расширенные данные 1000
                 группы ACAD в STYLE-записи DXF).
  - FontFile   — имя файла шрифта ("times.ttf", "txt.shx"), хранится в
                 FontFile стиля текста.
  - BigFont    — имя файла большого (Asian) шрифта, редко используется.
  Эти три поля нужны для корректного подбора стиля (текст в разных
  ячейках таблицы может использовать разные стили). }
procedure HandleUnicodeText2(
  Stream: TProxyByteStream;
  out HandlerResult: TProxyHandlerResult);
var
  Insert, Normal, Direction: TzePoint3d;
  Height, WidthFactor: Double;
  Text, FontName, TypeFace, BigFont: string;
  Angle: Double;
begin
  HandlerResult.Valid := False;
  HandlerResult.HasVertices := False;
  HandlerResult.HasBBox := False;
  HandlerResult.HasTextItem := False;

  { Геометрия }
  Insert := Stream.ReadVertex;
  Normal := Stream.ReadVector;
  Direction := Stream.ReadVector;

  { Текст (UTF-16, выровнен по 4 байтам) }
  try
    Text := Stream.ReadPaddedUnicodeString;
  except
    Text := '';
  end;

  { Пропускаем IgnoreLength и Raw }
  Stream.ReadInt32;
  Stream.ReadInt32;

  Height := Stream.ReadDouble;
  WidthFactor := Stream.ReadDouble;

  { Пропускаем: ObliqueAngle, TrackingPercentage }
  Stream.ReadDouble;
  Stream.ReadDouble;

  { Пропускаем флаги: IsBackward, IsUpsideDown, IsVertical,
    IsUnderlined, IsOverlined }
  Stream.ReadUInt32;
  Stream.ReadUInt32;
  Stream.ReadUInt32;
  Stream.ReadUInt32;
  Stream.ReadUInt32;

  { Дополнительные поля OpCode=38: IsBold, IsItalic, Charset, Pitch }
  Stream.ReadUInt32;
  Stream.ReadUInt32;
  Stream.ReadUInt32;
  Stream.ReadUInt32;

  { TypeFace, FontFilename, BigFontFilename — Unicode-строки с паддингом.
    В разных ячейках таблицы значения могут быть разные:
    - "newtext" стиль:  TypeFace="Times New Roman", FontFile="" (ttf)
    - "Standard" стиль: TypeFace="",               FontFile="txt.shx"
    Поэтому сохраняем оба значения — подбор стиля выполняется в
    BuildTextSubEntities с fallback TypeFace -> FontFile -> style name. }
  TypeFace := Stream.ReadPaddedUnicodeString;
  FontName := Stream.ReadPaddedUnicodeString;
  BigFont := Stream.ReadPaddedUnicodeString;

  programlog.LogOutFormatStr(
    'uzeentproxyparsertext: UnicodeText2 Insert=(%.3f,%.3f,%.3f) H=%.3f' +
    ' Text="%s" TypeFace="%s" Font="%s" BigFont="%s"',
    [Insert.x, Insert.y, Insert.z, Height, Text, TypeFace, FontName, BigFont],
    LM_Info);

  if (Height <= 0) or (Text = '') then
    Exit;

  { Переводим в OCS если нормаль не совпадает с Z }
  if not VectorsAreEqual(Normal, TEXT_Z_AXIS) then
    Insert := TransformPointToOCS(Insert, Normal);

  { Угол поворота текста из вектора Direction (проекция на плоскость XY) }
  if (Abs(Direction.x) > 1e-9) or (Abs(Direction.y) > 1e-9) then
    Angle := ArcTan2(Direction.y, Direction.x)
  else
    Angle := 0.0;

  { Аппроксимационный BBox }
  CalcTextBBox(Insert, Text, Height, WidthFactor,
    HandlerResult.BBoxMin, HandlerResult.BBoxMax);
  HandlerResult.HasBBox := True;

  { Заполняем данные текстового примитива для отрисовки }
  HandlerResult.TextItem.Insert := Insert;
  HandlerResult.TextItem.Text := Text;
  HandlerResult.TextItem.Height := Height;
  HandlerResult.TextItem.WidthFactor := WidthFactor;
  HandlerResult.TextItem.Angle := Angle;
  HandlerResult.TextItem.FontName := FontName;
  HandlerResult.TextItem.TypeFace := TypeFace;
  HandlerResult.TextItem.BigFontName := BigFont;
  HandlerResult.HasTextItem := True;

  HandlerResult.Valid := True;

  programlog.LogOutFormatStr(
    'uzeentproxyparsertext: UnicodeText2 OK, angle=%.3f rad, TextItem filled',
    [Angle], LM_Info);
end;

{ Читает расширенный текст формата OpCode=11 (Text2).
  Используется в DXF 2000/2004 (AC1015/AC1018) вместо OpCode=38: все строки
  однобайтовые (ANSI), а поля TypeFace и Bold/Italic/Charset/Pitch
  отсутствуют. Остальная структура совпадает с OpCode=38.
  Возвращает BBox и TextItem для отрисовки через DrawTextContent. }
procedure HandleText2(
  Stream: TProxyByteStream;
  out HandlerResult: TProxyHandlerResult);
var
  Insert, Normal, Direction: TzePoint3d;
  Height, WidthFactor: Double;
  Text, FontName, BigFont: string;
  Angle: Double;
  SavedUnicodeText: Boolean;
begin
  HandlerResult.Valid := False;
  HandlerResult.HasVertices := False;
  HandlerResult.HasBBox := False;
  HandlerResult.HasTextItem := False;

  { Геометрия }
  Insert := Stream.ReadVertex;
  Normal := Stream.ReadVector;
  Direction := Stream.ReadVector;

  { Все строки в OpCode=11 — однобайтовые (ANSI), независимо от версии
    DXF-файла и значения Stream.UnicodeText. Временно переключаем поток
    в ANSI-режим, чтобы ReadPaddedUnicodeString корректно читал строки
    в формате DXF 2000. }
  SavedUnicodeText := Stream.UnicodeText;
  Stream.UnicodeText := False;
  try
    { Текст (ANSI, выровнен по 4 байтам) }
    try
      Text := Stream.ReadPaddedUnicodeString;
    except
      Text := '';
    end;

    { Пропускаем Length и Raw }
    Stream.ReadInt32;
    Stream.ReadInt32;

    Height := Stream.ReadDouble;
    WidthFactor := Stream.ReadDouble;

    { Пропускаем: ObliqueAngle, TrackingPercentage }
    Stream.ReadDouble;
    Stream.ReadDouble;

    { Пропускаем флаги: IsBackward, IsUpsideDown, IsVertical,
      IsUnderlined, IsOverlined.
      В OpCode=11 (в отличие от OpCode=38) нет полей
      IsBold, IsItalic, Charset, Pitch и нет TypeFace. }
    Stream.ReadUInt32;
    Stream.ReadUInt32;
    Stream.ReadUInt32;
    Stream.ReadUInt32;
    Stream.ReadUInt32;

    { FontFilename, BigFontFilename — ANSI-строки с паддингом. }
    FontName := Stream.ReadPaddedUnicodeString;
    BigFont := Stream.ReadPaddedUnicodeString;
  finally
    Stream.UnicodeText := SavedUnicodeText;
  end;

  programlog.LogOutFormatStr(
    'uzeentproxyparsertext: Text2 Insert=(%.3f,%.3f,%.3f) H=%.3f' +
    ' Text="%s" Font="%s" BigFont="%s"',
    [Insert.x, Insert.y, Insert.z, Height, Text, FontName, BigFont],
    LM_Info);

  if (Height <= 0) or (Text = '') then
    Exit;

  { Переводим в OCS если нормаль не совпадает с Z }
  if not VectorsAreEqual(Normal, TEXT_Z_AXIS) then
    Insert := TransformPointToOCS(Insert, Normal);

  { Угол поворота текста из вектора Direction (проекция на плоскость XY) }
  if (Abs(Direction.x) > 1e-9) or (Abs(Direction.y) > 1e-9) then
    Angle := ArcTan2(Direction.y, Direction.x)
  else
    Angle := 0.0;

  { Аппроксимационный BBox }
  CalcTextBBox(Insert, Text, Height, WidthFactor,
    HandlerResult.BBoxMin, HandlerResult.BBoxMax);
  HandlerResult.HasBBox := True;

  { Заполняем данные текстового примитива для отрисовки.
    TypeFace в OpCode=11 отсутствует — оставляем пустым. }
  HandlerResult.TextItem.Insert := Insert;
  HandlerResult.TextItem.Text := Text;
  HandlerResult.TextItem.Height := Height;
  HandlerResult.TextItem.WidthFactor := WidthFactor;
  HandlerResult.TextItem.Angle := Angle;
  HandlerResult.TextItem.FontName := FontName;
  HandlerResult.TextItem.TypeFace := '';
  HandlerResult.TextItem.BigFontName := BigFont;
  HandlerResult.HasTextItem := True;

  HandlerResult.Valid := True;

  programlog.LogOutFormatStr(
    'uzeentproxyparsertext: Text2 OK, angle=%.3f rad, TextItem filled',
    [Angle], LM_Info);
end;

{ --- Построитель подпримитивов --- }

const
  { Префикс имён стилей, создаваемых при расчленении MTEXT на TEXT.
    Совпадает с поведением AutoCAD (EXPLODE MTEXT создаёт MtXpl_<Font>). }
  MTEXT_EXPLODE_STYLE_PREFIX = 'MtXpl_';

{ Формирует имя стиля из имени шрифта по правилу AutoCAD:
  - удаляет расширение файла (".shx", ".ttf"),
  - заменяет пробелы на символ "_",
  - добавляет префикс MtXpl_.
  Источник имени: TypeFace имеет приоритет над FontName, т.к. именно он
  содержит читаемое имя шрифта ("Verdana", "ISOCPEUR"). Если пуст, то
  используется имя файла шрифта без расширения ("txt" из "txt.shx"). }
function BuildMtXplStyleName(const FontName, TypeFace: String): String;
var
  BaseName: String;
begin
  if TypeFace <> '' then
    BaseName := TypeFace
  else
    BaseName := ChangeFileExt(FontName, '');
  BaseName := StringReplace(BaseName, ' ', '_', [rfReplaceAll]);
  Result := MTEXT_EXPLODE_STYLE_PREFIX + BaseName;
end;

{ Создаёт в таблице стилей чертежа новый стиль текста для шрифта,
  который встретился в proxy-графике, но ни одного соответствующего
  стиля в таблице нет. Имя создаваемого стиля формируется через
  BuildMtXplStyleName. Свойства (высота/ширина/наклон) берутся по
  умолчанию, как при EXPLODE MTEXT в AutoCAD.

  Если стиль с таким именем уже существует (например, мы уже создавали
  его для предыдущего примитива), он возвращается без повторного
  добавления. }
function CreateMtXplStyle(var Drawing: TDrawingDef;
  const FontName, TypeFace: String): PGDBTextStyle;
var
  StyleName: String;
  tp: GDBTextStyleProp;
begin
  Result := nil;
  if (FontName = '') and (TypeFace = '') then
    Exit;

  StyleName := BuildMtXplStyleName(FontName, TypeFace);

  { Стиль мог быть создан ранее для той же пары (FontName,TypeFace). }
  Result := Drawing.GetTextStyleTable^.FindStyle(StyleName, False);
  if Result <> nil then
    Exit;

  tp.size := 0;
  tp.wfactor := 1;
  tp.oblique := 0;

  Result := Drawing.GetTextStyleTable^.addstyle(
    StyleName, FontName, TypeFace, tp, False);

  if Result <> nil then
    programlog.LogOutFormatStr(
      'uzeentproxyparsertext: Created MtXpl style "%s"'
      + ' (FontFile="%s", TypeFace="%s")',
      [StyleName, FontName, TypeFace], LM_Info);
end;

{ Подбирает стиль текста для TextItem.

  Порядок поиска (сначала удачный вариант возвращается):
  1. По TypeFace — сравнение с FontFamily стилей таблицы.
     TypeFace хранится в OpCode=38 (UnicodeText2) как читаемое имя шрифта
     ("Times New Roman"). В ZCAD это поле FontFamily, заполняемое из
     расширенных данных STYLE-записи DXF (код 1000 в секции ACAD).
  2. По FontName — сравнение с FontFile стилей (точное и без расширения).
     FontName хранится в OpCode=10 (Text1) как имя файла шрифта
     ("times.ttf", "txt.shx").
  3. По FontName как имени стиля (если имя стиля совпадает с именем файла).
  4. Если соответствующий стиль не найден — создаётся новый стиль с
     именем "MtXpl_<TypeFace или FontName>" (пробелы заменяются на "_").
     Это повторяет поведение AutoCAD при расчленении MTEXT на TEXT:
     если в чертеже нет стиля с нужным шрифтом, команда EXPLODE создаёт
     новый стиль с префиксом "MtXpl_".
  5. Fallback: стиль "Standard".
  6. Fallback: первый стиль таблицы.

  Такой порядок важен: в одном proxy-графике разные примитивы могут
  содержать разные комбинации полей (см. ezdxf proxygraphic.unicode_text2),
  например строка с TypeFace="Times New Roman" + FontName="" должна
  резолвиться в стиль newtext, а строка с TypeFace="" + FontName="txt.shx"
  — в стиль Standard. Эти стили имеют разные fontfile/fontfamily. }
function ResolveTextStyle(var Drawing: TDrawingDef;
  const FontName, TypeFace: String): PGDBTextStyle;
begin
  Result := nil;
  if TypeFace <> '' then
    Result := Drawing.GetTextStyleTable^.FindStyleByTypeface(TypeFace);
  if (Result = nil) and (FontName <> '') then
  begin
    Result := Drawing.GetTextStyleTable^.FindStyleByFont(FontName);
    if Result = nil then
      Result := Drawing.GetTextStyleTable^.FindStyle(FontName, False);
  end;
  if (Result = nil) and ((FontName <> '') or (TypeFace <> '')) then
    Result := CreateMtXplStyle(Drawing, FontName, TypeFace);
  if Result = nil then
    Result := Drawing.GetTextStyleTable^.FindStyle('Standard', False);
  if Result = nil then
    Result := PGDBTextStyle(Drawing.GetTextStyleTable^.getDataMutable(0));
end;

{ Создаёт подпримитив GDBObjText (однострочный TEXT) из TProxyTextItem.
  Стиль подбирается внутри парсера (а не в прокси-объекте), чтобы
  сохранить принцип: модуль-парсер примитива отвечает и за создание
  соответствующего подпримитива.

  Тесты показали, что прокси-графика текстовых примитивов должна
  отрисовываться как однострочный TEXT (GDBObjText), а не MTEXT.
  Реализация MTEXT сохранена в виде закомментированной процедуры
  BuildTextSubEntitiesMText ниже — её можно вернуть, если в будущих
  форматах понадобится многострочный текст. }
procedure BuildTextSubEntities(
  const HandlerResult: TProxyHandlerResult;
  const Context: TProxySubEntityContext);
var
  pText: PGDBObjText;
  TxtStyle: PGDBTextStyle;
  InsertPt: TzePoint3d;
  Drawing: PTDrawingDef;
  DC: PTDrawContext;
begin
  if not HandlerResult.HasTextItem then
    Exit;
  if (Context.OwnerEntity = nil) or (Context.SubEntitiesArray = nil) then
    Exit;
  if (Context.Drawing = nil) or (Context.DC = nil) then
    Exit;

  Drawing := PTDrawingDef(Context.Drawing);
  DC := PTDrawContext(Context.DC);

  TxtStyle := ResolveTextStyle(Drawing^,
    HandlerResult.TextItem.FontName,
    HandlerResult.TextItem.TypeFace);
  if TxtStyle = nil then
  begin
    programlog.LogOutFormatStr(
      'uzeentproxyparsertext: BuildTextSubEntities no style, skipping',
      [], LM_Info);
    Exit;
  end;

  InsertPt := ProxyToLocalPoint(Context, HandlerResult.TextItem.Insert);

  pText := pointer(
    PGDBObjEntityOpenArray(Context.SubEntitiesArray)^.CreateInitObj(
      GDBtextID, Context.OwnerEntity));
  if pText = nil then
    Exit;

  pText^.vp.Layer := PGDBLayerProp(Context.OwnerLayer);
  pText^.vp.LineType := PGDBLtypeProp(Context.OwnerLineType);
  { Применяем вес линии текущего примитива (с откатом на вес владельца
    для значений ByLayer/ByBlock/ByLwDefault). }
  pText^.vp.LineWeight :=
    ResolveLineWeight(Context, Context.PrimitiveLineWeight);
  { Применяем цвет текущего примитива (ByBlock → цвет владельца,
    ByLayer → цвет слоя, явный индекс → как есть). Соответствует
    поведению примитивов внутри BlockInsert. }
  pText^.vp.Color := TGDBPaletteColor(
    ResolveColor(Context, Context.PrimitiveColor));
  ApplyLineTypeScale(PGDBObjEntity(pText), Context);

  { Template — шаблон с форматированием, при пустом Content он будет
    использован как исходный текст в FormatEntity. }
  pText^.Template := HandlerResult.TextItem.Text;
  pText^.TXTStyle := TxtStyle;
  pText^.Local.P_insert := InsertPt;
  pText^.textprop.size := HandlerResult.TextItem.Height;
  pText^.textprop.wfactor := HandlerResult.TextItem.WidthFactor;
  pText^.textprop.oblique := 0;
  pText^.textprop.justify := jsbl;

  { Поворот через базис OX }
  if Abs(HandlerResult.TextItem.Angle) > 1e-10 then
  begin
    pText^.Local.basis.ox.x := Cos(HandlerResult.TextItem.Angle);
    pText^.Local.basis.ox.y := Sin(HandlerResult.TextItem.Angle);
    pText^.Local.basis.ox.z := 0;
  end;

  pText^.FormatEntity(Drawing^, DC^);

  programlog.LogOutFormatStr(
    'uzeentproxyparsertext: BuildTextSubEntities TEXT "%s" at (%.3f,%.3f)' +
    ' typeface="%s" font="%s" style="%s"',
    [HandlerResult.TextItem.Text, InsertPt.x, InsertPt.y,
     HandlerResult.TextItem.TypeFace,
     HandlerResult.TextItem.FontName, TxtStyle^.Name], LM_Info);
end;

{ === Реализация MTEXT (закомментирована, сохранена для истории) =============
  Ниже — прежняя реализация BuildTextSubEntities, создающая подпримитив
  GDBObjMText. По требованию issue #976 вместо MTEXT теперь используется
  однострочный TEXT (см. процедуру BuildTextSubEntities выше). Если
  возникнет необходимость вернуться к MTEXT — раскомментируйте код ниже,
  подключите uzeentmtext в секции uses и зарегистрируйте эту процедуру
  вместо текущей BuildTextSubEntities.

procedure BuildTextSubEntitiesMText(
  const HandlerResult: TProxyHandlerResult;
  const Context: TProxySubEntityContext);
var
  pMText: PGDBObjMText;
  TxtStyle: PGDBTextStyle;
  InsertPt: TzePoint3d;
  Drawing: PTDrawingDef;
  DC: PTDrawContext;
begin
  if not HandlerResult.HasTextItem then
    Exit;
  if (Context.OwnerEntity = nil) or (Context.SubEntitiesArray = nil) then
    Exit;
  if (Context.Drawing = nil) or (Context.DC = nil) then
    Exit;

  Drawing := PTDrawingDef(Context.Drawing);
  DC := PTDrawContext(Context.DC);

  TxtStyle := ResolveTextStyle(Drawing^,
    HandlerResult.TextItem.FontName,
    HandlerResult.TextItem.TypeFace);
  if TxtStyle = nil then
  begin
    programlog.LogOutFormatStr(
      'uzeentproxyparsertext: BuildTextSubEntitiesMText no style, skipping',
      [], LM_Info);
    Exit;
  end;

  InsertPt := ProxyToLocalPoint(Context, HandlerResult.TextItem.Insert);

  pMText := pointer(
    PGDBObjEntityOpenArray(Context.SubEntitiesArray)^.CreateInitObj(
      GDBMTextID, Context.OwnerEntity));
  if pMText = nil then
    Exit;

  pMText^.vp.Layer := PGDBLayerProp(Context.OwnerLayer);
  pMText^.vp.LineType := PGDBLtypeProp(Context.OwnerLineType);
  pMText^.vp.LineWeight :=
    ResolveLineWeight(Context, Context.PrimitiveLineWeight);
  pMText^.vp.Color := TGDBPaletteColor(
    ResolveColor(Context, Context.PrimitiveColor));
  ApplyLineTypeScale(PGDBObjEntity(pMText), Context);

  pMText^.Template := HandlerResult.TextItem.Text;
  pMText^.TXTStyle := TxtStyle;
  pMText^.Local.P_insert := InsertPt;
  pMText^.textprop.size := HandlerResult.TextItem.Height;
  pMText^.textprop.wfactor := HandlerResult.TextItem.WidthFactor;
  pMText^.textprop.oblique := 0;
  pMText^.textprop.justify := jsbl;
  pMText^.Width := 0;
  pMText^.linespacef := 1;
  pMText^.WrapMode := mwmByWord;

  if Abs(HandlerResult.TextItem.Angle) > 1e-10 then
  begin
    pMText^.Local.basis.ox.x := Cos(HandlerResult.TextItem.Angle);
    pMText^.Local.basis.ox.y := Sin(HandlerResult.TextItem.Angle);
    pMText^.Local.basis.ox.z := 0;
  end;

  pMText^.FormatEntity(Drawing^, DC^);

  programlog.LogOutFormatStr(
    'uzeentproxyparsertext: BuildTextSubEntitiesMText "%s" at (%.3f,%.3f)' +
    ' typeface="%s" font="%s" style="%s"',
    [HandlerResult.TextItem.Text, InsertPt.x, InsertPt.y,
     HandlerResult.TextItem.TypeFace,
     HandlerResult.TextItem.FontName, TxtStyle^.Name], LM_Info);
end;
============================================================================== }

initialization
  { Регистрируем обработчики текста с общим построителем подпримитивов.
    Исключение этого файла из проекта полностью отключает парсинг
    текстовых примитивов внутри прокси-объектов. }
  TProxyOpCodeDispatcher.RegisterOpCode(
    TEXT_OPCODE,
    'Text1 (ANSI)',
    @HandleText,
    @BuildTextSubEntities);

  TProxyOpCodeDispatcher.RegisterOpCode(
    TEXT2_OPCODE,
    'Text2 (ANSI, DXF 2000)',
    @HandleText2,
    @BuildTextSubEntities);

  TProxyOpCodeDispatcher.RegisterOpCode(
    UNICODE_TEXT2_OPCODE,
    'UnicodeText2',
    @HandleUnicodeText2,
    @BuildTextSubEntities);

end.
