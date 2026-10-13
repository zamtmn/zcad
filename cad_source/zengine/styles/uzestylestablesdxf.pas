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
  Модуль: uzestylestablesdxf
  Назначение: типы данных стилей таблиц (TABLESTYLE) для обмена с DXF.

  Стили таблиц в DXF хранятся в секции OBJECTS в виде объектов TABLESTYLE,
  связанных через словарь ACAD_TABLESTYLE. В отличие от DIMSTYLE (который
  находится в секции TABLES), TABLESTYLE является объектом секции OBJECTS.

  Чтение и запись стилей выполняет NOD-обработчик ACAD_TABLESTYLE
  (uzestylestablesdxfnod, ТЗ NOD, этап 5 — issue #1452); прежний разбор
  сырого текста секции OBJECTS (ReadTableStylesFromDXFObjects,
  WriteTableStylesToDXFObjects) удалён.

  Модуль полностью самодостаточен: все необходимые типы данных определены
  внутри. Не зависит от uzestylestables.

  Зависимости: UGDBNamedObjectsArray, gzctnrVector, uzeNamedObject,
               gzctnrVectorTypes, sysutils
}
unit uzestylestablesdxf;
{$Mode delphi}{$H+}
{$INCLUDE zengineconfig.inc}
interface
uses
  UGDBNamedObjectsArray,
  gzctnrVector,
  uzeNamedObject,
  gzctnrVectorTypes,
  sysutils;

{ === Типы данных для DXF-стилей таблиц === }

type
  { Стиль одной строки ячейки таблицы (для DXF-обмена).
    Содержит только value types — безопасно для GZVector (raw memory). }
  TGDBDXFTableCellStyle = record
    { Высота текста строки (группа DXF 140) }
    TextHeight: Double;
    { Выравнивание текста в ячейке (группа DXF 170) }
    Alignment: Integer;
    { Цвет текста (группа DXF 62) }
    TextColor: Integer;
    { Цвет фона ячейки (группа DXF 63) }
    BackgroundColor: Integer;
    { Признак включения цвета фона (группа DXF 283) }
    BackgroundColorEnabled: Boolean;
    { Поля ячейки из CELLSTYLEMAP (блок CELLMARGIN_BEGIN, шесть групп 40):
      верх, право, низ, лево, горизонтальный и вертикальный интервалы.
      По ним AutoCAD 2008+ раскладывает ячейки (issue #1465). }
    Margins: array[0..5] of Double;
    { Margins прочитаны из CELLSTYLEMAP. Если False — при записи берутся
      отступы стиля таблицы (группы 40/41 TABLESTYLE). }
    MarginsLoaded: Boolean;
  end;
  PTGDBDXFTableCellStyle = ^TGDBDXFTableCellStyle;

  GDBDXFCellFormatArray = GZVector<TGDBDXFTableCellStyle>;

  { Стиль таблицы для DXF-обмена — именованный объект.
    Содержит все параметры, необходимые для записи/чтения TABLESTYLE в DXF.
    Намеренно не зависит от uzestylestables. }
  TGDBDXFTableStyle = object(GDBNamedObject)
    { Массив стилей ячеек: 0=data, 1=title, 2=header (порядок блоков в DXF TABLESTYLE) }
    CellFormats: GDBDXFCellFormatArray;
    { Флаги стиля таблицы (группа DXF 70) }
    Flags70: Integer;
    { Направление потока / версия (группа DXF 71) }
    Flags71: Integer;
    { Горизонтальный отступ ячейки (группа DXF 40) }
    HorzCellMargin: Double;
    { Вертикальный отступ ячейки (группа DXF 41) }
    VertCellMargin: Double;
    { Признак подавления строки заголовка (группа DXF 280) }
    TitleSuppressed: Boolean;
    { Признак подавления строки имён колонок (группа DXF 281) }
    ColumnHeadingSuppressed: Boolean;
    { Имена текстовых стилей для трёх типов строк: title, header, data
      (группа DXF 7). Массив строк хранится отдельно от record-а ячейки,
      так как string в GZVector небезопасен (raw memory). }
    CellTextStyleName: array[0..2] of string;
    { Хэндл расширенного словаря объекта (блок 102/ACAD_XDICTIONARY).
      Сохраняется при чтении и восстанавливается при записи, чтобы AutoCAD
      не считал файл повреждённым из-за отсутствия XDICTIONARY-ссылок. }
    XDictHandle: string;
    { Хэндл самого объекта TABLESTYLE в DXF (группа 5).
      Используется для сопоставления со ссылкой из ACAD_TABLE (группа 342). }
    DXFHandle: string;
    constructor init(const StyleName: string);
    destructor Done; virtual;
  end;
  PTGDBDXFTableStyle = ^TGDBDXFTableStyle;

  { Массив стилей таблиц для DXF-обмена }
  GDBDXFTableStyleArray = object(GDBNamedObjectsArray<PTGDBDXFTableStyle,
                                                      TGDBDXFTableStyle>)
    constructor init(InitialCapacity: Integer);
    constructor initnul;
    { Добавляет стиль с заданным именем или возвращает существующий }
    function AddStyle(const StyleName: string): PTGDBDXFTableStyle;
    { Ищет стиль по DXF-хэндлу объекта TABLESTYLE (группа 5).
      Возвращает nil если стиль с таким хэндлом не найден. }
    function GetStyleByHandle(const AHandle: string): PTGDBDXFTableStyle;
  end;
  PGDBDXFTableStyleArray = ^GDBDXFTableStyleArray;

implementation

{ === Конструктор и деструктор TGDBDXFTableStyle === }

constructor TGDBDXFTableStyle.init(const StyleName: string);
var
  I: Integer;
begin
  inherited Init(StyleName);
  CellFormats.Init(3);
  Flags70 := 0;
  Flags71 := 0;
  HorzCellMargin := 1.5;
  VertCellMargin := 1.5;
  TitleSuppressed := False;
  ColumnHeadingSuppressed := False;
  { Инициализируем указатели строк через nil для корректной работы с AnsiString }
  for I := 0 to 2 do
    pointer(CellTextStyleName[I]) := nil;
  pointer(XDictHandle) := nil;
  pointer(DXFHandle) := nil;
end;

destructor TGDBDXFTableStyle.Done;
var
  I: Integer;
begin
  inherited Done;
  CellFormats.Done;
  { Явно освобождаем строки — необходимо при использовании object с GZVector }
  for I := 0 to 2 do
    CellTextStyleName[I] := '';
  XDictHandle := '';
  DXFHandle := '';
end;

{ === Методы GDBDXFTableStyleArray === }

constructor GDBDXFTableStyleArray.init(InitialCapacity: Integer);
begin
  inherited init(InitialCapacity);
end;

constructor GDBDXFTableStyleArray.initnul;
begin
  inherited initnul;
end;

function GDBDXFTableStyleArray.AddStyle(const StyleName: string): PTGDBDXFTableStyle;
var
  StylePtr: PTGDBDXFTableStyle;
begin
  case AddItem(StyleName, pointer(StylePtr)) of
    IsFounded:
      { Стиль уже существует — возвращаем указатель без изменений };
    IsCreated:
      { Новый стиль — инициализируем }
      StylePtr^.init(StyleName);
    IsError:
      { Ошибка добавления — возвращаем nil }
      StylePtr := nil;
  end;
  Result := StylePtr;
end;

{ Ищет стиль по DXF-хэндлу объекта TABLESTYLE.
  Перебирает все стили и возвращает тот, чей DXFHandle совпадает с AHandle.
  Сравнение ведётся без учёта регистра. Возвращает nil если не найден. }
function GDBDXFTableStyleArray.GetStyleByHandle(
  const AHandle: string): PTGDBDXFTableStyle;
var
  IterRec: itrec;
  StylePtr: PTGDBDXFTableStyle;
  UpperHandle: string;
begin
  Result := nil;
  if AHandle = '' then
    Exit;
  UpperHandle := UpperCase(AHandle);
  StylePtr := beginiterate(IterRec);
  while StylePtr <> nil do
  begin
    if UpperCase(StylePtr^.DXFHandle) = UpperHandle then
    begin
      Result := StylePtr;
      Exit;
    end;
    StylePtr := iterate(IterRec);
  end;
end;

end.
