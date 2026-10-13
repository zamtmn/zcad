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
  Модуль: uzestylestablesdxfnod
  Назначение: NOD-обработчик словаря ACAD_TABLESTYLE — чтение и запись
  стилей таблиц (TABLESTYLE) через реестр uzeffdxfnodregistry.
  ТЗ cad_source/zengine/TZ_NOD_NamedObjectDictionary.md, этап 5.

  Чтение (LoadProc, DXF 2000+, до ENTITIES): каждая запись 3/350 словаря
  ACAD_TABLESTYLE — объект TABLESTYLE модели NOD, поля разбираются из его
  пар (TZDXFRawObject) без повторного текстового сканирования секции
  OBJECTS. Имя стиля — ключ словаря, DXFHandle — исходный хэндл объекта
  (по нему ACAD_TABLE находит стиль по группе 342), XDictHandle — хэндл
  расширенного словаря. Объект стиля, его расширенный словарь и
  CELLSTYLEMAP помечаются «забранными». Из CELLSTYLEMAP берутся поля ячеек
  (CELLMARGIN) стилей _TITLE/_HEADER/_DATA, сам объект не хранится: при
  записи он строится заново по параметрам стиля (issues #1409, #1465).
  Стиль с именем, которое уже есть в чертеже (вставка/слияние чертежей),
  не меняется.

  Значения по умолчанию (EnsureDefaultsProc, любая версия DXF): если после
  загрузки стилей нет — создаётся 'Standard' с параметрами стиля
  Standard из savetemplate2007.dxf.

  Запись (DXF 2000+): ReserveHandlesProc — хэндлы словаря-ветки и на
  каждый стиль TABLESTYLE + расширенный словарь + CELLSTYLEMAP, карта
  TableStyleNameHandleMap (по ней ACAD_TABLE пишет 342); SaveProc —
  словарь-ветка и объекты; ClassesProc — классы TABLESTYLE и CELLSTYLEMAP,
  если их нет в шаблоне. Если стилей в чертеже нет, ветка шаблона
  копируется как есть.

  ExtractTableStyleDictionaryFromNOD (этап 1) — карта хэндл → имя по
  словарю ACAD_TABLESTYLE; берёт ключ только из корневого словаря.
}
unit uzestylestablesdxfnod;
{$Mode delphi}{$H+}
{$INCLUDE zengineconfig.inc}
interface

uses
  Classes,
  uzeTypes,
  uzctnrVectorBytesStream,
  usimplegenerics,
  uzedrawingsimple,
  uzeffdxfsupport,
  uzeffdxfobjects,
  uzeffdxfnod,
  uzeffdxfnodregistry,
  uzestylestablesdxf;

const
  { Ключ NOD словаря стилей таблиц }
  CNODTableStyleKey = 'ACAD_TABLESTYLE';
  { Тип объекта стиля таблицы }
  CDXFTableStyleObjType = 'TABLESTYLE';
  { Ключ CELLSTYLEMAP в расширенном словаре стиля таблицы (issue #1409) }
  CDXFCellStyleMapKey = 'ACAD_ROUNDTRIP_2008_TABLESTYLE_CELLSTYLEMAP';
  { Тип объекта карты стилей ячеек }
  CDXFCellStyleMapObjType = 'CELLSTYLEMAP';
  { Имя обязательного стиля таблицы }
  CDefaultTableStyleName = 'Standard';

{ Заполняет StyleNameByHandle по словарю NOD/ACAD_TABLESTYLE:
  имя — хэндл объекта записи (DXFHandleToStr: верхний регистр, без
  ведущих нулей), значение — имя стиля (ключ словаря).
  Формат тот же, что у удалённой ExtractTableStyleDictionary.
  OutDictHandle — хэндл словаря ACAD_TABLESTYLE ('' если не найден).
  Возвращает False, если NOD нет, в нём нет ключа ACAD_TABLESTYLE или
  ключ ссылается не на словарь. Записи с битыми ссылками (объекта нет)
  пропускаются. }
function ExtractTableStyleDictionaryFromNOD(
  AModel: TZNODModel;
  StyleNameByHandle: TStringList;
  out OutDictHandle: string): Boolean;

{ Заполняет AStyle по парам объекта TABLESTYLE (перенос
  ParseTableStyleObject): 70/71 — флаги, 40/41 — отступы ячейки,
  280/281 — подавление заголовка и имён колонок; каждая группа 7
  начинает блок ячейки (0=data, 1=title, 2=header), в нём
  140/170/62/63/283. Блоки 102 пропускаются, XDictHandle берётся из
  AObj.XDictHandle. Блоки ячеек добавляются к AStyle.CellFormats. }
procedure ParseTableStyleRawObject(AObj: TZDXFRawObject;
  var AStyle: TGDBDXFTableStyle);

{ Загружает стили словаря ADict (ветка ACAD_TABLESTYLE) в ATable и
  помечает забранными хэндлы объектов стилей, их расширенных словарей и
  CELLSTYLEMAP. Возвращает количество добавленных стилей. }
function LoadTableStylesFromDictionary(AModel: TZNODModel;
  ADict: TZDXFDictionary; var ATable: GDBDXFTableStyleArray): Integer;

{ То же по ключу ACAD_TABLESTYLE в NOD модели (0 — ключа нет) }
function LoadTableStylesFromNOD(AModel: TZNODModel;
  var ATable: GDBDXFTableStyleArray): Integer;

{ Параметры стиля Standard из savetemplate2007.dxf (AStyle уже init) }
procedure FillDefaultTableStyle(var AStyle: TGDBDXFTableStyle);

{ Если в ATable нет стилей — создаёт 'Standard' (FillDefaultTableStyle)
  и возвращает его, иначе nil. }
function EnsureDefaultTableStyle(
  var ATable: GDBDXFTableStyleArray): PTGDBDXFTableStyle;

{ Регистрирует NOD-обработчик ACAD_TABLESTYLE (вызывается в
  initialization модуля) }
procedure RegisterTableStyleNODHandler;

implementation

uses
  SysUtils,
  gzctnrVectorTypes,
  uzeffdxfnodlog;

var
  { Формат вещественных чисел DXF: десятичная точка независимо от локали }
  DXFFormat: TFormatSettings;

{ Преобразует вещественное число в строку DXF с гарантией десятичной точки }
function DXFFloatStr(Value: Double): string;
begin
  Result := FloatToStr(Value, DXFFormat);
  if Pos('.', Result) = 0 then
    Result := Result + '.0';
end;

function ExtractTableStyleDictionaryFromNOD(
  AModel: TZNODModel;
  StyleNameByHandle: TStringList;
  out OutDictHandle: string): Boolean;
var
  Dict: TZDXFDictionary;
  I: Integer;
  Entry: TZDXFDictEntry;
  Obj: TZDXFRawObject;
begin
  StyleNameByHandle.Clear;
  OutDictHandle := '';
  Dict := AModel.ResolveDictionary(CNODTableStyleKey);
  if Dict = nil then
    Exit(False);
  OutDictHandle := DXFHandleToStr(Dict.Handle);
  for I := 0 to Dict.Count - 1 do begin
    Entry := Dict[I];
    Obj := AModel.FindObject(Entry.TargetHandle);
    if Obj = nil then begin
      NODLogTraceFormatStr(
        'uzestylestablesdxfnod: %s/%s: object %s not found, skipped',
        [CNODTableStyleKey, Entry.Key, DXFHandleToStr(Entry.TargetHandle)]);
      Continue;
    end;
    if not SameText(Obj.ObjType, CDXFTableStyleObjType) then
      NODLogTraceFormatStr(
        'uzestylestablesdxfnod: %s/%s: object %s is %s, not %s',
        [CNODTableStyleKey, Entry.Key, Obj.HandleStr, Obj.ObjType,
         CDXFTableStyleObjType]);
    StyleNameByHandle.Values[DXFHandleToStr(Entry.TargetHandle)] := Entry.Key;
  end;
  Result := True;
end;

{ === Чтение === }

procedure ParseTableStyleRawObject(AObj: TZDXFRawObject;
  var AStyle: TGDBDXFTableStyle);
var
  I, Code, IntVal: Integer;
  Value: string;
  CellStyle: TGDBDXFTableCellStyle;
  { Индекс текущего блока ячейки: 0=data, 1=title, 2=header (порядок DXF) }
  CellIdx: Integer;
  { Внутри блока 102 (реакторы, расширенный словарь) }
  In102: Boolean;
begin
  if AObj.XDictHandle <> 0 then
    AStyle.XDictHandle := DXFHandleToStr(AObj.XDictHandle);
  CellIdx := -1;
  In102 := False;
  FillChar(CellStyle, SizeOf(CellStyle), 0);
  for I := 0 to AObj.PairCount - 1 do begin
    Code := AObj.Pairs[I].Code;
    Value := Trim(AObj.Pairs[I].Value);
    if Code = 102 then begin
      In102 := (Value <> '') and (Value[1] = '{') and (Value <> '{}');
      Continue;
    end;
    if In102 then
      Continue;
    case Code of
      70:
        { Флаги стиля таблицы }
        if TryStrToInt(Value, IntVal) then
          AStyle.Flags70 := IntVal;
      71:
        { Направление потока / версия стиля таблицы }
        if TryStrToInt(Value, IntVal) then
          AStyle.Flags71 := IntVal;
      40:
        { Горизонтальный отступ ячейки }
        AStyle.HorzCellMargin := StrToFloatDef(Value, 1.5, DXFFormat);
      41:
        { Вертикальный отступ ячейки }
        AStyle.VertCellMargin := StrToFloatDef(Value, 1.5, DXFFormat);
      280:
        { Признак подавления строки заголовка таблицы }
        if TryStrToInt(Value, IntVal) then
          AStyle.TitleSuppressed := IntVal <> 0;
      281:
        { Признак подавления строки имён колонок }
        if TryStrToInt(Value, IntVal) then
          AStyle.ColumnHeadingSuppressed := IntVal <> 0;
      7:
        begin
          { Группа 7 (имя текстового стиля) начинает следующий блок ячейки }
          if CellIdx >= 0 then
            AStyle.CellFormats.PushBackData(CellStyle);
          FillChar(CellStyle, SizeOf(CellStyle), 0);
          Inc(CellIdx);
          if CellIdx <= 2 then
            AStyle.CellTextStyleName[CellIdx] := Value;
        end;
      140:
        { Высота текста }
        if CellIdx >= 0 then
          CellStyle.TextHeight := StrToFloatDef(Value, 2.5, DXFFormat);
      170:
        { Выравнивание текста в ячейке }
        if (CellIdx >= 0) and TryStrToInt(Value, IntVal) then
          CellStyle.Alignment := IntVal;
      62:
        { Цвет текста }
        if (CellIdx >= 0) and TryStrToInt(Value, IntVal) then
          CellStyle.TextColor := IntVal;
      63:
        { Цвет фона }
        if (CellIdx >= 0) and TryStrToInt(Value, IntVal) then
          CellStyle.BackgroundColor := IntVal;
      283:
        { Признак использования цвета фона }
        if (CellIdx >= 0) and TryStrToInt(Value, IntVal) then
          CellStyle.BackgroundColorEnabled := IntVal <> 0;
    end;
  end;
  { Последний блок ячейки }
  if CellIdx >= 0 then
    AStyle.CellFormats.PushBackData(CellStyle);
end;

{ Переносит поля ячеек (CELLMARGIN) из объекта CELLSTYLEMAP в стиль.

  Блок карты: 300|CELLSTYLE, TABLEFORMAT_BEGIN ... 1|CELLMARGIN_BEGIN,
  шесть групп 40, 309|CELLMARGIN_END ... TABLEFORMAT_END, затем
  1|CELLSTYLE_BEGIN, 90|<id> (1=_TITLE, 2=_HEADER, 3=_DATA).
  AutoCAD 2008+ берёт поля ячеек именно отсюда, а не из групп 40/41
  TABLESTYLE; если при записи подставить другие значения, AutoCAD
  пересчитает ширины колонок и высоты строк таблицы (issue #1465). }
procedure ParseCellStyleMapMargins(AMap: TZDXFRawObject;
  var AStyle: TGDBDXFTableStyle);
var
  I, Code, IntVal, MarginCount, CellIdx: Integer;
  Value: string;
  InMargin, InCellStyle, HaveMargins: Boolean;
  Margins: array[0..5] of Double;
  PCellStyle: PTGDBDXFTableCellStyle;
begin
  InMargin := False;
  InCellStyle := False;
  HaveMargins := False;
  MarginCount := 0;
  FillChar(Margins, SizeOf(Margins), 0);
  for I := 0 to AMap.PairCount - 1 do begin
    Code := AMap.Pairs[I].Code;
    Value := Trim(AMap.Pairs[I].Value);
    if (Code = 300) and (Value = 'CELLSTYLE') then begin
      { Начало очередного стиля ячейки }
      HaveMargins := False;
      InCellStyle := False;
      Continue;
    end;
    if Code = 1 then begin
      if Value = 'CELLMARGIN_BEGIN' then begin
        InMargin := True;
        MarginCount := 0;
        FillChar(Margins, SizeOf(Margins), 0);
      end else if Value = 'CELLSTYLE_BEGIN' then
        InCellStyle := True;
      Continue;
    end;
    if Code = 309 then begin
      if Value = 'CELLMARGIN_END' then begin
        InMargin := False;
        HaveMargins := MarginCount = Length(Margins);
      end else if Value = 'CELLSTYLE_END' then
        InCellStyle := False;
      Continue;
    end;
    if InMargin and (Code = 40) then begin
      if MarginCount <= High(Margins) then
        Margins[MarginCount] := StrToFloatDef(Value, 0, DXFFormat);
      Inc(MarginCount);
      Continue;
    end;
    if InCellStyle and (Code = 90) and HaveMargins
       and TryStrToInt(Value, IntVal) then begin
      { Порядок блоков ячеек в TABLESTYLE: 0=data, 1=title, 2=header }
      case IntVal of
        1: CellIdx := 1;
        2: CellIdx := 2;
        3: CellIdx := 0;
      else
        CellIdx := -1;
      end;
      if (CellIdx >= 0) and (CellIdx < AStyle.CellFormats.Count) then begin
        PCellStyle := AStyle.CellFormats.getDataMutable(CellIdx);
        Move(Margins, PCellStyle^.Margins, SizeOf(Margins));
        PCellStyle^.MarginsLoaded := True;
        NODLogTraceFormatStr(
          'uzestylestablesdxfnod: style "%s": cell style %d margins %s/%s/%s/%s/%s/%s',
          [AStyle.Name, IntVal, DXFFloatStr(Margins[0]),
           DXFFloatStr(Margins[1]), DXFFloatStr(Margins[2]),
           DXFFloatStr(Margins[3]), DXFFloatStr(Margins[4]),
           DXFFloatStr(Margins[5])]);
      end;
      HaveMargins := False;
    end;
  end;
end;

{ Поля стиля ячеек _DATA (если прочитаны) согласованы с группами 40/41
  стиля таблицы: верх/низ = 41, право/лево = 40. Так во всех файлах
  AutoCAD (cad_source/test, cad_source/testacadtable). }
function CellStyleMapMatchesStyle(const AStyle: TGDBDXFTableStyle): Boolean;
const
  Eps = 1e-9;
var
  M: array[0..5] of Double;
  PCellStyle: PTGDBDXFTableCellStyle;
begin
  Result := True;
  if AStyle.CellFormats.Count = 0 then
    Exit;
  PCellStyle := AStyle.CellFormats.getDataMutable(0);
  if not PCellStyle^.MarginsLoaded then
    Exit;
  Move(PCellStyle^.Margins, M, SizeOf(M));
  Result := (Abs(M[0] - AStyle.VertCellMargin) < Eps)
        and (Abs(M[2] - AStyle.VertCellMargin) < Eps)
        and (Abs(M[1] - AStyle.HorzCellMargin) < Eps)
        and (Abs(M[3] - AStyle.HorzCellMargin) < Eps);
end;

{ Находит CELLSTYLEMAP в расширенном словаре стиля и переносит из него
  поля ячеек в стиль (issue #1465). Карта, не согласованная с группами
  40/41 стиля (запись ZCAD до исправления), не используется. }
procedure LoadTableStyleCellStyleMap(AModel: TZNODModel; AObj: TZDXFRawObject;
  var AStyle: TGDBDXFTableStyle);
var
  XDict: TZDXFDictionary;
  I: Integer;
  Entry: TZDXFDictEntry;
  MapObj: TZDXFRawObject;
begin
  if AObj.XDictHandle = 0 then
    Exit;
  XDict := AModel.FindDictionary(AObj.XDictHandle);
  if XDict = nil then
    Exit;
  for I := 0 to XDict.Count - 1 do begin
    Entry := XDict[I];
    if not SameText(Entry.Key, CDXFCellStyleMapKey) then
      Continue;
    MapObj := AModel.FindObject(Entry.TargetHandle);
    if (MapObj <> nil)
       and SameText(MapObj.ObjType, CDXFCellStyleMapObjType) then
      ParseCellStyleMapMargins(MapObj, AStyle);
  end;
  if not CellStyleMapMatchesStyle(AStyle) then begin
    { AutoCAD держит поля _DATA равными группам 40/41 стиля таблицы.
      Расхождение — карта прежней записи ZCAD (жёстко 1.5): ей не верим,
      при записи поля берутся из групп 40/41 (issue #1465). }
    NODLogTraceFormatStr(
      'uzestylestablesdxfnod: style "%s": CELLSTYLEMAP margins differ from 40/41, ignored',
      [AStyle.Name]);
    for I := 0 to AStyle.CellFormats.Count - 1 do
      AStyle.CellFormats.getDataMutable(I)^.MarginsLoaded := False;
  end;
end;

{ Помечает забранными расширенный словарь стиля и его CELLSTYLEMAP:
  карта при записи строится заново по параметрам стиля (поля ячеек
  переносит LoadTableStyleCellStyleMap). Другие записи расширенного
  словаря не переносятся (в лог — предупреждение). }
procedure ClaimTableStyleXDict(AModel: TZNODModel; AObj: TZDXFRawObject;
  const AStyleName: string);
var
  XDict: TZDXFDictionary;
  I: Integer;
  Entry: TZDXFDictEntry;
  MapObj: TZDXFRawObject;
begin
  if AObj.XDictHandle = 0 then
    Exit;
  XDict := AModel.FindDictionary(AObj.XDictHandle);
  if XDict = nil then begin
    NODLogTraceFormatStr(
      'uzestylestablesdxfnod: style "%s": extension dictionary %s not found',
      [AStyleName, DXFHandleToStr(AObj.XDictHandle)]);
    Exit;
  end;
  AModel.ClaimHandle(XDict.Handle);
  for I := 0 to XDict.Count - 1 do begin
    Entry := XDict[I];
    MapObj := AModel.FindObject(Entry.TargetHandle);
    if SameText(Entry.Key, CDXFCellStyleMapKey) and (MapObj <> nil)
       and SameText(MapObj.ObjType, CDXFCellStyleMapObjType) then
      AModel.ClaimHandle(MapObj.Handle)
    else
      NODLogWarningFormatStr(
        'uzestylestablesdxfnod: style "%s": extension dictionary entry "%s" (%s) is not kept',
        [AStyleName, Entry.Key, DXFHandleToStr(Entry.TargetHandle)]);
  end;
end;

function LoadTableStylesFromDictionary(AModel: TZNODModel;
  ADict: TZDXFDictionary; var ATable: GDBDXFTableStyleArray): Integer;
var
  I: Integer;
  Entry: TZDXFDictEntry;
  Obj: TZDXFRawObject;
  Style: PTGDBDXFTableStyle;
begin
  Result := 0;
  if (AModel = nil) or (ADict = nil) then
    Exit;
  for I := 0 to ADict.Count - 1 do begin
    Entry := ADict[I];
    Obj := AModel.FindObject(Entry.TargetHandle);
    if (Obj = nil) or not SameText(Obj.ObjType, CDXFTableStyleObjType) then begin
      NODLogWarningFormatStr(
        'uzestylestablesdxfnod: %s/%s: %s is not a %s object, skipped',
        [CNODTableStyleKey, Entry.Key, DXFHandleToStr(Entry.TargetHandle),
         CDXFTableStyleObjType]);
      Continue;
    end;
    if Entry.Key = '' then begin
      NODLogWarningFormatStr(
        'uzestylestablesdxfnod: %s: %s %s without name, skipped',
        [CNODTableStyleKey, CDXFTableStyleObjType, Obj.HandleStr]);
      Continue;
    end;
    AModel.ClaimHandle(Obj.Handle);
    ClaimTableStyleXDict(AModel, Obj, Entry.Key);
    if ATable.getAddres(Entry.Key) <> nil then begin
      { Стиль с таким именем уже есть (вставка/слияние чертежей или
        повтор имени в словаре) — существующий не меняется }
      NODLogTraceFormatStr(
        'uzestylestablesdxfnod: style "%s" (%s) already exists, kept',
        [Entry.Key, Obj.HandleStr]);
      Continue;
    end;
    Style := ATable.AddStyle(Entry.Key);
    if Style = nil then
      Continue;
    ParseTableStyleRawObject(Obj, Style^);
    LoadTableStyleCellStyleMap(AModel, Obj, Style^);
    { Исходный хэндл — по нему ACAD_TABLE находит стиль (группа 342) }
    Style^.DXFHandle := Obj.HandleStr;
    Inc(Result);
    NODLogTraceFormatStr(
      'uzestylestablesdxfnod: стиль "%s" загружен (хэндл %s)',
      [Style^.Name, Style^.DXFHandle]);
  end;
end;

function LoadTableStylesFromNOD(AModel: TZNODModel;
  var ATable: GDBDXFTableStyleArray): Integer;
begin
  Result := 0;
  if AModel <> nil then
    Result := LoadTableStylesFromDictionary(AModel,
      AModel.ResolveDictionary(CNODTableStyleKey), ATable);
end;

procedure FillDefaultTableStyle(var AStyle: TGDBDXFTableStyle);
const
  { Блоки ячеек TABLESTYLE Standard шаблона: data, title, header }
  CHeights: array[0..2] of Double = (0.18, 0.25, 0.18);
  CAlignments: array[0..2] of Integer = (2, 5, 5);
var
  CellIdx: Integer;
  CellStyle: TGDBDXFTableCellStyle;
begin
  AStyle.Flags70 := 0;
  AStyle.Flags71 := 0;
  AStyle.HorzCellMargin := 0.06;
  AStyle.VertCellMargin := 0.06;
  AStyle.TitleSuppressed := False;
  AStyle.ColumnHeadingSuppressed := False;
  AStyle.CellFormats.Clear;
  for CellIdx := 0 to 2 do begin
    FillChar(CellStyle, SizeOf(CellStyle), 0);
    CellStyle.TextHeight := CHeights[CellIdx];
    CellStyle.Alignment := CAlignments[CellIdx];
    CellStyle.TextColor := 0;
    CellStyle.BackgroundColor := 7;
    CellStyle.BackgroundColorEnabled := False;
    AStyle.CellFormats.PushBackData(CellStyle);
    AStyle.CellTextStyleName[CellIdx] := 'Standard';
  end;
end;

function EnsureDefaultTableStyle(
  var ATable: GDBDXFTableStyleArray): PTGDBDXFTableStyle;
begin
  Result := nil;
  if ATable.Count > 0 then
    Exit;
  Result := ATable.AddStyle(CDefaultTableStyleName);
  if Result = nil then
    Exit;
  FillDefaultTableStyle(Result^);
  NODLogTraceFormatStr(
    'uzestylestablesdxfnod: стилей таблиц нет, создан "%s"',
    [CDefaultTableStyleName]);
end;

{ LoadProc обработчика }
procedure TableStyleNODLoad(const AModel: TZNODModel;
  const ADict: TZDXFDictionary; var ADrawing: TSimpleDrawing);
begin
  LoadTableStylesFromDictionary(AModel, ADict, ADrawing.DXFTableStyleTable);
end;

{ EnsureDefaultsProc обработчика }
procedure TableStyleNODEnsureDefaults(var ADrawing: TSimpleDrawing);
begin
  EnsureDefaultTableStyle(ADrawing.DXFTableStyleTable);
end;

{ === Запись === }

{ Записывает блок границ ячейки в поток (коды 274-279, 284-289, 64-69).
  Значения по умолчанию: тип линии = -2, видимость = 1, цвет = 0 }
procedure WriteCellBordersToStream(
  var outstream: TZctnrVectorBytes);
var
  BorderCode, VisCode, ColorCode: Integer;
begin
  for BorderCode := 274 to 279 do
  begin
    VisCode := BorderCode + 10;
    ColorCode := BorderCode - 210;
    outstream.TXTAddStringEOL(dxfGroupCode(BorderCode));
    outstream.TXTAddStringEOL('-2');
    outstream.TXTAddStringEOL(dxfGroupCode(VisCode));
    outstream.TXTAddStringEOL('1');
    outstream.TXTAddStringEOL(dxfGroupCode(ColorCode));
    outstream.TXTAddStringEOL('0');
  end;
end;

{ Записывает один блок стиля ячейки (title/header/data) в поток }
procedure WriteCellStyleToStream(
  var outstream: TZctnrVectorBytes;
  const CS: TGDBDXFTableCellStyle;
  const TextStyleName: string);
begin
  outstream.TXTAddStringEOL(dxfGroupCode(7));
  if TextStyleName <> '' then
    outstream.TXTAddStringEOL(TextStyleName)
  else
    outstream.TXTAddStringEOL('Standard');
  outstream.TXTAddStringEOL(dxfGroupCode(140));
  outstream.TXTAddStringEOL(DXFFloatStr(CS.TextHeight));
  outstream.TXTAddStringEOL(dxfGroupCode(170));
  outstream.TXTAddStringEOL(IntToStr(CS.Alignment));
  outstream.TXTAddStringEOL(dxfGroupCode(62));
  outstream.TXTAddStringEOL(IntToStr(CS.TextColor));
  outstream.TXTAddStringEOL(dxfGroupCode(63));
  outstream.TXTAddStringEOL(IntToStr(CS.BackgroundColor));
  outstream.TXTAddStringEOL(dxfGroupCode(283));
  if CS.BackgroundColorEnabled then
    outstream.TXTAddStringEOL('1')
  else
    outstream.TXTAddStringEOL('0');
  outstream.TXTAddStringEOL(dxfGroupCode(90));
  outstream.TXTAddStringEOL('512');
  outstream.TXTAddStringEOL(dxfGroupCode(91));
  outstream.TXTAddStringEOL('0');
  outstream.TXTAddStringEOL(dxfGroupCode(1));
  outstream.TXTAddStringEOL('');
  WriteCellBordersToStream(outstream);
end;

{ Пара «код/значение» в поток (сокращение для читаемости кода ниже) }
procedure dxfPairOut(var outstream: TZctnrVectorBytes;
                     const Code: Integer; const Value: string); inline;
begin
  outstream.TXTAddStringEOL(dxfGroupCode(Code));
  outstream.TXTAddStringEOL(Value);
end;

type
  { Поля ячейки CELLMARGIN: верх, право, низ, лево, интервалы }
  TCellStyleMargins = array[0..5] of Double;

{ Поля ячейки для CELLSTYLEMAP: прочитанные из исходной карты или, если
  их нет, построенные по отступам стиля (верх/низ — вертикальный отступ
  41, право/лево — горизонтальный 40; интервалы — 0.18, как у AutoCAD). }
function CellStyleMargins(const CS: TGDBDXFTableCellStyle;
  Style: PTGDBDXFTableStyle): TCellStyleMargins;
var
  I: Integer;
begin
  if CS.MarginsLoaded then begin
    for I := 0 to High(Result) do
      Result[I] := CS.Margins[I];
    Exit;
  end;
  Result[0] := Style^.VertCellMargin;
  Result[1] := Style^.HorzCellMargin;
  Result[2] := Style^.VertCellMargin;
  Result[3] := Style^.HorzCellMargin;
  Result[4] := 0.18;
  Result[5] := 0.18;
end;

{ Записывает один блок CELLSTYLE карты стилей ячеек (AcDbCellStyleMap).

  Именно этот объект даёт смысл идентификаторам стиля ячейки (90) внутри
  TABLECELL_BEGIN объекта TABLECONTENT: без CELLSTYLEMAP AutoCAD отбрасывает
  индивидуальные стили ячеек и применяет встроенное правило «строка 1 — Title,
  строка 2 — Header, остальные — Data» (issue #1409).

  AStyleId  — 1=_TITLE, 2=_HEADER, 3=_DATA
  AStyleName— '_TITLE' / '_HEADER' / '_DATA'
  AStyleType— 1 для заголовочных строк (title/header), 2 для данных
  AFlags92  — 32768 для _TITLE (признак строки заголовка таблицы), иначе 0 }
procedure WriteCellStyleMapEntryToStream(
  var outstream: TZctnrVectorBytes;
  const CS: TGDBDXFTableCellStyle;
  const AStyleId, AStyleType, AFlags92: Integer;
  const AStyleName: string;
  const ATextStyleHandle: string;
  const AMargins: TCellStyleMargins);
var
  GridBit, I: Integer;
begin
  dxfPairOut(outstream, 300, 'CELLSTYLE');
  dxfPairOut(outstream, 1, 'TABLEFORMAT_BEGIN');
  dxfPairOut(outstream, 90, '5');
  dxfPairOut(outstream, 170, '1');
  dxfPairOut(outstream, 91, '0');
  dxfPairOut(outstream, 92, IntToStr(AFlags92));
  dxfPairOut(outstream, 62, '257');
  dxfPairOut(outstream, 93, '1');

  { Формат содержимого ячейки: выравнивание (94) и высота текста (144) }
  dxfPairOut(outstream, 300, 'CONTENTFORMAT');
  dxfPairOut(outstream, 1, 'CONTENTFORMAT_BEGIN');
  dxfPairOut(outstream, 90, '0');
  dxfPairOut(outstream, 91, '0');
  dxfPairOut(outstream, 92, '512');
  dxfPairOut(outstream, 93, '0');
  dxfPairOut(outstream, 300, '');
  dxfPairOut(outstream, 40, '0.0');
  dxfPairOut(outstream, 140, '1.0');
  dxfPairOut(outstream, 94, IntToStr(CS.Alignment));
  dxfPairOut(outstream, 62, IntToStr(CS.TextColor));
  { 340 = хэндл текстового стиля. AutoCAD пишет реальную ссылку STYLE в
    каждом CONTENTFORMAT карты; 0 оставляет определение CELLSTYLE неполным,
    после чего индивидуальные стили ячеек игнорируются (issue #1409). }
  dxfPairOut(outstream, 340, ATextStyleHandle);
  dxfPairOut(outstream, 144, DXFFloatStr(CS.TextHeight));
  dxfPairOut(outstream, 309, 'CONTENTFORMAT_END');

  { Поля ячейки. AutoCAD 2008+ раскладывает таблицу по ним, а не по
    группам 40/41 TABLESTYLE: прежние жёсткие 1.5 вместо 0.06 заставляли
    AutoCAD расширять колонки и строки (issue #1465). }
  dxfPairOut(outstream, 171, '1');
  dxfPairOut(outstream, 301, 'MARGIN');
  dxfPairOut(outstream, 1, 'CELLMARGIN_BEGIN');
  for I := 0 to High(AMargins) do
    dxfPairOut(outstream, 40, DXFFloatStr(AMargins[I]));
  dxfPairOut(outstream, 309, 'CELLMARGIN_END');

  { Шесть описаний линий сетки ячейки (горизонтальные/вертикальные/рамка) }
  dxfPairOut(outstream, 94, '6');
  GridBit := 1;
  while GridBit <= 32 do
  begin
    dxfPairOut(outstream, 95, IntToStr(GridBit));
    dxfPairOut(outstream, 302, 'GRIDFORMAT');
    dxfPairOut(outstream, 1, 'GRIDFORMAT_BEGIN');
    dxfPairOut(outstream, 90, '0');
    dxfPairOut(outstream, 91, '1');
    dxfPairOut(outstream, 62, '0');
    dxfPairOut(outstream, 92, '-2');
    dxfPairOut(outstream, 340, '0');
    dxfPairOut(outstream, 93, '0');
    dxfPairOut(outstream, 40, '0.045');
    dxfPairOut(outstream, 309, 'GRIDFORMAT_END');
    GridBit := GridBit * 2;
  end;
  dxfPairOut(outstream, 309, 'TABLEFORMAT_END');

  dxfPairOut(outstream, 1, 'CELLSTYLE_BEGIN');
  dxfPairOut(outstream, 90, IntToStr(AStyleId));
  dxfPairOut(outstream, 91, IntToStr(AStyleType));
  dxfPairOut(outstream, 300, AStyleName);
  dxfPairOut(outstream, 309, 'CELLSTYLE_END');
end;

{ Записывает расширенный словарь стиля таблицы и объект CELLSTYLEMAP.

  Цепочка ссылок, которую ожидает AutoCAD (issue #1409):
    TABLESTYLE --102{ACAD_XDICTIONARY/360--> DICTIONARY
      --(ключ ACAD_ROUNDTRIP_2008_TABLESTYLE_CELLSTYLEMAP)--> CELLSTYLEMAP

  DictHandle/MapHandle — заранее выделенные хэндлы этих двух объектов. }
procedure WriteCellStyleMapObjectsToStream(
  var outstream: TZctnrVectorBytes;
  Style: PTGDBDXFTableStyle;
  const StyleHandle, DictHandle, MapHandle: TDWGHandle;
  TextStyleNameHandleMap: TString2StringDictionary);
var
  CS: array[0..2] of TGDBDXFTableCellStyle;
  TextStyleHandles: array[0..2] of string;
  PCellStyle: PTGDBDXFTableCellStyle;
  CellIdx: Integer;
  Iter: itrec;
  DefaultAlignments: array[0..2] of Integer;

  function ResolveTextStyleHandle(const StyleName: string): string;
  begin
    Result := '0';
    if (StyleName <> '')
       and TextStyleNameHandleMap.MyGetValue(StyleName, Result) then
      Exit;
    { Старые/неполные TABLESTYLE могут не содержать группу 7. В таком случае
      используем реальный хэндл Standard, как делает AutoCAD. }
    TextStyleNameHandleMap.MyGetValue('Standard', Result);
  end;
begin
  { Порядок блоков ячеек в TABLESTYLE: 0=data, 1=title, 2=header }
  DefaultAlignments[0] := 2;
  DefaultAlignments[1] := 5;
  DefaultAlignments[2] := 5;
  for CellIdx := 0 to 2 do
  begin
    FillChar(CS[CellIdx], SizeOf(CS[CellIdx]), 0);
    CS[CellIdx].TextHeight := 2.5;
    CS[CellIdx].Alignment := DefaultAlignments[CellIdx];
    TextStyleHandles[CellIdx] :=
      ResolveTextStyleHandle(Style^.CellTextStyleName[CellIdx]);
  end;
  CellIdx := 0;
  PCellStyle := Style^.CellFormats.beginiterate(Iter);
  while (PCellStyle <> nil) and (CellIdx < 3) do
  begin
    CS[CellIdx] := PCellStyle^;
    Inc(CellIdx);
    PCellStyle := Style^.CellFormats.iterate(Iter);
  end;

  { Словарь-расширение стиля таблицы }
  dxfPairOut(outstream, 0, 'DICTIONARY');
  dxfPairOut(outstream, 5, inttohex(DictHandle, 0));
  dxfPairOut(outstream, 330, inttohex(StyleHandle, 0));
  dxfPairOut(outstream, 100, 'AcDbDictionary');
  { 280|1 — жёсткое владение записями словаря. AutoCAD пишет этот флаг для
    словаря-расширения стиля таблицы; без него CELLSTYLEMAP считается
    «одолженным» объектом (issue #1409). }
  dxfPairOut(outstream, 280, '1');
  dxfPairOut(outstream, 281, '1');
  dxfPairOut(outstream, 3, 'ACAD_ROUNDTRIP_2008_TABLESTYLE_CELLSTYLEMAP');
  dxfPairOut(outstream, 360, inttohex(MapHandle, 0));

  { Сама карта стилей ячеек: _TITLE=1, _HEADER=2, _DATA=3 }
  dxfPairOut(outstream, 0, 'CELLSTYLEMAP');
  dxfPairOut(outstream, 5, inttohex(MapHandle, 0));
  dxfPairOut(outstream, 102, '{ACAD_REACTORS');
  dxfPairOut(outstream, 330, inttohex(DictHandle, 0));
  dxfPairOut(outstream, 102, '}');
  dxfPairOut(outstream, 330, inttohex(DictHandle, 0));
  dxfPairOut(outstream, 100, 'AcDbCellStyleMap');
  dxfPairOut(outstream, 90, '3');
  WriteCellStyleMapEntryToStream(
    outstream, CS[1], 1, 1, 32768, '_TITLE', TextStyleHandles[1],
    CellStyleMargins(CS[1], Style));
  WriteCellStyleMapEntryToStream(
    outstream, CS[2], 2, 1, 0, '_HEADER', TextStyleHandles[2],
    CellStyleMargins(CS[2], Style));
  WriteCellStyleMapEntryToStream(
    outstream, CS[0], 3, 2, 0, '_DATA', TextStyleHandles[0],
    CellStyleMargins(CS[0], Style));
end;

{ Записывает один объект TABLESTYLE в выходной поток DXF.
  StyleHandle — заранее назначенный хэндл объекта.
  OwnerHandle — хэндл словаря ACAD_TABLESTYLE (владелец).
  DictHandle/MapHandle — хэндлы расширенного словаря и CELLSTYLEMAP;
  если оба равны 0, карта стилей ячеек не записывается. }
procedure WriteTableStyleObjectToStream(
  var outstream: TZctnrVectorBytes;
  Style: PTGDBDXFTableStyle;
  const StyleHandle: TDWGHandle;
  const OwnerHandle: TDWGHandle;
  TextStyleNameHandleMap: TString2StringDictionary;
  const AHeader: TDXFHeaderInfo;
  const DictHandle: TDWGHandle = 0;
  const MapHandle: TDWGHandle = 0);
var
  PCellStyle: PTGDBDXFTableCellStyle;
  DefaultCS: TGDBDXFTableCellStyle;
  DefaultAlignments: array[0..2] of Integer;
  CellIdx: Integer;
  Iter: itrec;
begin
  DefaultAlignments[0] := 2;
  DefaultAlignments[1] := 5;
  DefaultAlignments[2] := 5;

  outstream.TXTAddStringEOL(dxfGroupCode(0));
  outstream.TXTAddStringEOL('TABLESTYLE');
  outstream.TXTAddStringEOL(dxfGroupCode(5));
  outstream.TXTAddStringEOL(inttohex(StyleHandle, 0));

  { Блок ACAD_XDICTIONARY со старым хэндлом Style^.XDictHandle не пишем
    (issue #1339): такая ссылка указывала бы на несуществующий объект.
    Но если для стиля выделены хэндлы под словарь и CELLSTYLEMAP, эти
    объекты записываются нами ниже, и ссылка 360 корректна (issue #1409). }
  if (DictHandle > 0) and (MapHandle > 0) then
  begin
    outstream.TXTAddStringEOL(dxfGroupCode(102));
    outstream.TXTAddStringEOL('{ACAD_XDICTIONARY');
    outstream.TXTAddStringEOL(dxfGroupCode(360));
    outstream.TXTAddStringEOL(inttohex(DictHandle, 0));
    outstream.TXTAddStringEOL(dxfGroupCode(102));
    outstream.TXTAddStringEOL('}');
  end;

  { Блок ACAD_REACTORS — принадлежность словарю }
  outstream.TXTAddStringEOL(dxfGroupCode(102));
  outstream.TXTAddStringEOL('{ACAD_REACTORS');
  outstream.TXTAddStringEOL(dxfGroupCode(330));
  outstream.TXTAddStringEOL(inttohex(OwnerHandle, 0));
  outstream.TXTAddStringEOL(dxfGroupCode(102));
  outstream.TXTAddStringEOL('}');
  outstream.TXTAddStringEOL(dxfGroupCode(330));
  outstream.TXTAddStringEOL(inttohex(OwnerHandle, 0));

  { AcDbTableStyle }
  outstream.TXTAddStringEOL(dxfGroupCode(100));
  outstream.TXTAddStringEOL('AcDbTableStyle');
  outstream.TXTAddStringEOL(dxfGroupCode(3));
  outstream.TXTAddStringEOL(dxfEnCodeString(Style^.Name, AHeader));
  outstream.TXTAddStringEOL(dxfGroupCode(70));
  outstream.TXTAddStringEOL(IntToStr(Style^.Flags70));
  outstream.TXTAddStringEOL(dxfGroupCode(71));
  outstream.TXTAddStringEOL(IntToStr(Style^.Flags71));
  outstream.TXTAddStringEOL(dxfGroupCode(40));
  outstream.TXTAddStringEOL(DXFFloatStr(Style^.HorzCellMargin));
  outstream.TXTAddStringEOL(dxfGroupCode(41));
  outstream.TXTAddStringEOL(DXFFloatStr(Style^.VertCellMargin));
  outstream.TXTAddStringEOL(dxfGroupCode(280));
  if Style^.TitleSuppressed then
    outstream.TXTAddStringEOL('1')
  else
    outstream.TXTAddStringEOL('0');
  outstream.TXTAddStringEOL(dxfGroupCode(281));
  if Style^.ColumnHeadingSuppressed then
    outstream.TXTAddStringEOL('1')
  else
    outstream.TXTAddStringEOL('0');

  { Записываем блоки ячеек (title, header, data) }
  CellIdx := 0;
  PCellStyle := Style^.CellFormats.beginiterate(Iter);
  while (PCellStyle <> nil) and (CellIdx < 3) do
  begin
    WriteCellStyleToStream(outstream, PCellStyle^,
      Style^.CellTextStyleName[CellIdx]);
    Inc(CellIdx);
    PCellStyle := Style^.CellFormats.iterate(Iter);
  end;
  { Добиваем до трёх блоков значениями по умолчанию }
  while CellIdx < 3 do
  begin
    FillChar(DefaultCS, SizeOf(DefaultCS), 0);
    DefaultCS.TextHeight := 2.5;
    DefaultCS.Alignment := DefaultAlignments[CellIdx];
    DefaultCS.BackgroundColor := 7;
    WriteCellStyleToStream(outstream, DefaultCS, 'Standard');
    Inc(CellIdx);
  end;

  { Карта стилей ячеек — без неё AutoCAD игнорирует индивидуальные стили
    ячеек в TABLECONTENT (issue #1409). }
  if (DictHandle > 0) and (MapHandle > 0) then
    WriteCellStyleMapObjectsToStream(outstream, Style,
      StyleHandle, DictHandle, MapHandle, TextStyleNameHandleMap);

  NODLogTraceFormatStr(
    'uzestylestablesdxfnod: записан TABLESTYLE "%s" handle=%s',
    [Style^.Name, inttohex(StyleHandle, 0)]);
end;

{ Хэндлы, выделенные ReserveHandlesProc, хранятся до SaveProc того же
  сохранения (savedxf20XX не реентерабельна). }
var
  TSNODStyles:array of PTGDBDXFTableStyle;
  TSNODHandles:array of TDWGHandle;
  TSNODXDictHandles:array of TDWGHandle;
  TSNODMapHandles:array of TDWGHandle;

function TableStyleNODReserveHandles(var ADrawing:TSimpleDrawing;
  var AIODXFContext:TIODXFSaveContext):TDWGHandle;
var
  style:PTGDBDXFTableStyle;
  iter:itrec;
  n:integer;
begin
  SetLength(TSNODStyles,0);
  SetLength(TSNODHandles,0);
  SetLength(TSNODXDictHandles,0);
  SetLength(TSNODMapHandles,0);
  if ADrawing.DXFTableStyleTable.Count=0 then
    Exit(0);
  { Словарь-ветка, затем на каждый стиль: TABLESTYLE, его расширенный
    словарь и CELLSTYLEMAP (issue #1409) }
  Result:=AIODXFContext.handle;
  Inc(AIODXFContext.handle);
  SetLength(TSNODStyles,ADrawing.DXFTableStyleTable.Count);
  SetLength(TSNODHandles,Length(TSNODStyles));
  SetLength(TSNODXDictHandles,Length(TSNODStyles));
  SetLength(TSNODMapHandles,Length(TSNODStyles));
  n:=0;
  style:=ADrawing.DXFTableStyleTable.beginiterate(iter);
  while (style<>nil) and (n<Length(TSNODStyles)) do begin
    if AIODXFContext.TableStyleNameHandleMap.MyContans(style^.Name) then
      NODLogWarningFormatStr(
        'uzestylestablesdxfnod: table style "%s" is duplicated, skipped',[style^.Name])
    else begin
      TSNODStyles[n]:=style;
      TSNODHandles[n]:=AIODXFContext.handle;
      TSNODXDictHandles[n]:=AIODXFContext.handle+1;
      TSNODMapHandles[n]:=AIODXFContext.handle+2;
      Inc(AIODXFContext.handle,3);
      AIODXFContext.TableStyleNameHandleMap.Add(
        style^.Name,inttohex(TSNODHandles[n],0));
      Inc(n);
    end;
    style:=ADrawing.DXFTableStyleTable.iterate(iter);
  end;
  SetLength(TSNODStyles,n);
  SetLength(TSNODHandles,n);
  SetLength(TSNODXDictHandles,n);
  SetLength(TSNODMapHandles,n);
  NODLogTraceFormatStr(
    'uzestylestablesdxfnod: выделены хэндлы для %d стилей таблиц (словарь %s)',
    [n,inttohex(Result,0)]);
end;

procedure TableStyleNODSave(var AOutStream:TZctnrVectorBytes;
  var ADrawing:TSimpleDrawing;var AIODXFContext:TIODXFSaveContext;
  ADictHandle,ANODHandle:TDWGHandle);
var
  i:integer;
begin
  if ADictHandle=0 then
    Exit;
  if ANODHandle=0 then
    NODLogWarningFormatStr(
      'uzestylestablesdxfnod: ACAD_TABLESTYLE dictionary %s is written without NOD',
      [inttohex(ADictHandle,0)]);
  { Словарь-ветка — как в шаблоне 2007: владелец и реактор — NOD }
  AOutStream.TXTAddStringEOL(dxfGroupCode(0));
  AOutStream.TXTAddStringEOL('DICTIONARY');
  AOutStream.TXTAddStringEOL(dxfGroupCode(5));
  AOutStream.TXTAddStringEOL(inttohex(ADictHandle,0));
  AOutStream.TXTAddStringEOL(dxfGroupCode(102));
  AOutStream.TXTAddStringEOL('{ACAD_REACTORS');
  AOutStream.TXTAddStringEOL(dxfGroupCode(330));
  AOutStream.TXTAddStringEOL(inttohex(ANODHandle,0));
  AOutStream.TXTAddStringEOL(dxfGroupCode(102));
  AOutStream.TXTAddStringEOL('}');
  AOutStream.TXTAddStringEOL(dxfGroupCode(330));
  AOutStream.TXTAddStringEOL(inttohex(ANODHandle,0));
  AOutStream.TXTAddStringEOL(dxfGroupCode(100));
  AOutStream.TXTAddStringEOL('AcDbDictionary');
  AOutStream.TXTAddStringEOL(dxfGroupCode(281));
  AOutStream.TXTAddStringEOL('1');
  for i:=0 to High(TSNODStyles) do begin
    AOutStream.TXTAddStringEOL(dxfGroupCode(3));
    AOutStream.TXTAddStringEOL(dxfEnCodeString(TSNODStyles[i]^.Name,AIODXFContext.Header));
    AOutStream.TXTAddStringEOL(dxfGroupCode(350));
    AOutStream.TXTAddStringEOL(inttohex(TSNODHandles[i],0));
  end;
  for i:=0 to High(TSNODStyles) do
    WriteTableStyleObjectToStream(AOutStream,TSNODStyles[i],TSNODHandles[i],
      ADictHandle,AIODXFContext.TextStyleNameHandleMap,AIODXFContext.Header,
      TSNODXDictHandles[i],TSNODMapHandles[i]);
  { Указатели на стили чертежа после записи не нужны }
  SetLength(TSNODStyles,0);
end;

{ Запись одного объявления класса секции CLASSES. Группа 91 (число
  экземпляров) — с DXF 2004. }
procedure WriteClassRecord(var AOutStream: TZctnrVectorBytes;
  var AIODXFContext: TIODXFSaveContext;
  const ADXFName, ACppName: string; AProxyFlags, AInstanceCount: Integer);
begin
  AOutStream.TXTAddStringEOL(dxfGroupCode(0));
  AOutStream.TXTAddStringEOL('CLASS');
  AOutStream.TXTAddStringEOL(dxfGroupCode(1));
  AOutStream.TXTAddStringEOL(ADXFName);
  AOutStream.TXTAddStringEOL(dxfGroupCode(2));
  AOutStream.TXTAddStringEOL(ACppName);
  AOutStream.TXTAddStringEOL(dxfGroupCode(3));
  AOutStream.TXTAddStringEOL('ObjectDBX Classes');
  AOutStream.TXTAddStringEOL(dxfGroupCode(90));
  AOutStream.TXTAddStringEOL(IntToStr(AProxyFlags));
  if AIODXFContext.Header.Version>=AC1018 then begin
    AOutStream.TXTAddStringEOL(dxfGroupCode(91));
    AOutStream.TXTAddStringEOL(IntToStr(AInstanceCount));
  end;
  AOutStream.TXTAddStringEOL(dxfGroupCode(280));
  AOutStream.TXTAddStringEOL('0');
  AOutStream.TXTAddStringEOL(dxfGroupCode(281));
  AOutStream.TXTAddStringEOL('0');
end;

{ Классы TABLESTYLE и CELLSTYLEMAP (на каждый стиль пишется своя карта
  стилей ячеек, issue #1409) — если стили есть, а в CLASSES шаблона
  класса нет. }
procedure TableStyleNODClasses(var AOutStream:TZctnrVectorBytes;
  var ADrawing:TSimpleDrawing;var AIODXFContext:TIODXFSaveContext);
begin
  if ADrawing.DXFTableStyleTable.Count=0 then
    Exit;
  if AIODXFContext.TemplateClassNames.IndexOf(CDXFTableStyleObjType)<0 then
    WriteClassRecord(AOutStream,AIODXFContext,CDXFTableStyleObjType,
      'AcDbTableStyle',4095,ADrawing.DXFTableStyleTable.Count);
  if AIODXFContext.TemplateClassNames.IndexOf(CDXFCellStyleMapObjType)<0 then
    WriteClassRecord(AOutStream,AIODXFContext,CDXFCellStyleMapObjType,
      'AcDbCellStyleMap',1152,ADrawing.DXFTableStyleTable.Count);
end;

{ Новый хэндл стиля таблицы по имени — для ссылок других объектов шаблона
  на пропущенные объекты ветки ACAD_TABLESTYLE шаблона }
function TableStyleNODFindObjectHandle(const AName:string;
  var AIODXFContext:TIODXFSaveContext):TDWGHandle;
var
  hs:string;
begin
  Result:=0;
  if AIODXFContext.TableStyleNameHandleMap.MyGetValue(AName,hs) then
    Result:=StrToQWord('$'+hs);
end;

procedure RegisterTableStyleNODHandler;
var
  h:TZNODHandler;
begin
  h:=Default(TZNODHandler);
  h.Key:=CNODTableStyleKey;
  h.ObjectType:=CDXFTableStyleObjType;
  { R4: стили таблиц пишутся и в DXF 2000 }
  h.MinVersion:=AC1015;
  h.DefaultName:=CDefaultTableStyleName;
  h.LoadProc:=TableStyleNODLoad;
  h.ReserveHandlesProc:=TableStyleNODReserveHandles;
  h.SaveProc:=TableStyleNODSave;
  h.ClassesProc:=TableStyleNODClasses;
  h.FindObjectHandleProc:=TableStyleNODFindObjectHandle;
  h.EnsureDefaultsProc:=TableStyleNODEnsureDefaults;
  RegisterNODHandler(h);
end;

initialization
  DXFFormat := DefaultFormatSettings;
  DXFFormat.DecimalSeparator := '.';
  DXFFormat.ThousandSeparator := #0;
  RegisterTableStyleNODHandler;
end.
