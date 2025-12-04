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
{$mode objfpc}{$H+}

{
  Модуль: ucvrtdata
  Назначение: Определение структур данных для восстановления таблиц
  Описание: Содержит типы и константы, используемые во всех модулях
            подсистемы восстановления таблиц. Модуль не содержит
            визуальных компонентов и не зависит от FPSpreadsheet.
  Зависимости: gzctnrVectorTypes, gvector, uzegeometry, uzegeometrytypes
}
unit ucvrtdata;

{$INCLUDE zengineconfig.inc}

interface

uses
  gzctnrVectorTypes,
  gvector,
  uzegeometry,
  uzegeometrytypes;

const
  // Минимальные размеры ячейки таблицы в единицах чертежа
  MIN_CELL_WIDTH = 1.0;
  MIN_CELL_HEIGHT = 1.0;

  // Допуск при сравнении координат (для группировки линий)
  COORDINATE_TOLERANCE = 0.5;

  // Максимальное количество строк и столбцов
  MAX_TABLE_ROWS = 1000;
  MAX_TABLE_COLUMNS = 100;

type
  // Тип примитива, который может быть частью таблицы
  TRtPrimitiveType = (
    rtptLine,         // Отрезок
    rtptPolyline,     // Полилиния
    rtptText,         // Однострочный текст
    rtptMText,        // Многострочный текст
    rtptUnknown       // Неизвестный тип
  );

  // Структура для хранения базовых данных о примитиве
  PRtPrimitiveItem = ^TRtPrimitiveItem;
  TRtPrimitiveItem = record
    primitiveType: TRtPrimitiveType;      // Тип примитива
    objectPointer: Pointer;               // Указатель на объект в ZCAD
    boundingBox: TBoundingBox;            // Габаритный прямоугольник
    startPoint: TzePoint3d;               // Начальная точка (для линий)
    endPoint: TzePoint3d;                 // Конечная точка (для линий)
    textContent: string;                  // Текстовое содержимое (для текста)
    processed: Boolean;                   // Флаг обработки
  end;

  // Список примитивов
  TRtPrimitiveList = specialize TVector<TRtPrimitiveItem>;

  // Выравнивание текста в ячейке
  TRtCellAlignment = (
    rtcaLeft,         // По левому краю
    rtcaCenter,       // По центру
    rtcaRight,        // По правому краю
    rtcaTop,          // По верхнему краю
    rtcaMiddle,       // По середине (вертикально)
    rtcaBottom        // По нижнему краю
  );

  // Границы ячейки (какие линии видимы)
  TRtCellBorders = record
    topBorder: Boolean;       // Верхняя граница
    bottomBorder: Boolean;    // Нижняя граница
    leftBorder: Boolean;      // Левая граница
    rightBorder: Boolean;     // Правая граница
  end;

  // Структура ячейки таблицы
  PRtTableCell = ^TRtTableCell;
  TRtTableCell = record
    rowIndex: Integer;                    // Индекс строки
    columnIndex: Integer;                 // Индекс столбца
    bounds: TBoundingBox;                 // Границы ячейки
    textContent: string;                  // Текстовое содержимое
    horizontalAlign: TRtCellAlignment;    // Горизонтальное выравнивание
    verticalAlign: TRtCellAlignment;      // Вертикальное выравнивание
    borders: TRtCellBorders;              // Видимые границы
    isMerged: Boolean;                    // Объединена ли ячейка
    mergeRowSpan: Integer;                // Количество объединенных строк
    mergeColSpan: Integer;                // Количество объединенных столбцов
  end;

  // Список ячеек
  TRtTableCellList = specialize TVector<TRtTableCell>;

  // Информация о строке таблицы
  PRtTableRow = ^TRtTableRow;
  TRtTableRow = record
    rowIndex: Integer;        // Индекс строки
    topPosition: Double;      // Y-координата верхней границы
    bottomPosition: Double;   // Y-координата нижней границы
    height: Double;           // Высота строки
  end;

  // Список строк
  TRtTableRowList = specialize TVector<TRtTableRow>;

  // Информация о столбце таблицы
  PRtTableColumn = ^TRtTableColumn;
  TRtTableColumn = record
    columnIndex: Integer;     // Индекс столбца
    leftPosition: Double;     // X-координата левой границы
    rightPosition: Double;    // X-координата правой границы
    width: Double;            // Ширина столбца
  end;

  // Список столбцов
  TRtTableColumnList = specialize TVector<TRtTableColumn>;

  // Основная структура таблицы (модель данных)
  PRtTableModel = ^TRtTableModel;
  TRtTableModel = record
    rows: TRtTableRowList;           // Список строк
    columns: TRtTableColumnList;     // Список столбцов
    cells: TRtTableCellList;         // Список ячеек
    rowCount: Integer;               // Количество строк
    columnCount: Integer;            // Количество столбцов
    tableBounds: TBoundingBox;       // Общие границы таблицы
    isValid: Boolean;                // Валидна ли структура таблицы
  end;

  // Статус обработки таблицы
  TRtProcessStatus = (
    rtpsNotStarted,    // Обработка не начата
    rtpsReading,       // Чтение примитивов
    rtpsAnalyzing,     // Анализ структуры
    rtpsBuilding,      // Построение таблицы
    rtpsComplete,      // Обработка завершена
    rtpsError          // Ошибка обработки
  );

  // Информация об ошибке обработки
  TRtProcessError = record
    hasError: Boolean;          // Есть ли ошибка
    errorMessage: string;       // Текст ошибки
    errorCode: Integer;         // Код ошибки
  end;

  // Вспомогательная структура для хранения линии
  TRtLineData = record
    position: Double;     // Позиция линии (X для вертикальных, Y для горизонтальных)
    startPos: Double;     // Начальная позиция вдоль линии
    endPos: Double;       // Конечная позиция вдоль линии
  end;
  PRtLineData = ^TRtLineData;
  TRtLineList = specialize TVector<TRtLineData>;

// Вспомогательные функции для работы со структурами

// Создать пустую модель таблицы
function CreateEmptyTableModel: TRtTableModel;

// Освободить ресурсы модели таблицы
procedure FreeTableModel(var aModel: TRtTableModel);

// Создать пустую ячейку
function CreateEmptyCell(aRow, aCol: Integer): TRtTableCell;

// Создать структуру границ ячейки с заданными значениями
function CreateCellBorders(aTop, aBottom, aLeft, aRight: Boolean): TRtCellBorders;

// Проверить, находится ли точка внутри ячейки
function IsPointInCell(const aPoint: TzePoint3d; const aCell: TRtTableCell): Boolean;

// Получить центр ячейки
function GetCellCenter(const aCell: TRtTableCell): TzePoint3d;

// Сравнить два числа с заданным допуском
function IsNearlyEqual(a, b: Double; tolerance: Double = COORDINATE_TOLERANCE): Boolean;

implementation

uses
  Math;

// Создать пустую модель таблицы
function CreateEmptyTableModel: TRtTableModel;
begin
  Result.rows := specialize TVector<TRtTableRow>.Create;
  Result.columns := specialize TVector<TRtTableColumn>.Create;
  Result.cells := specialize TVector<TRtTableCell>.Create;
  Result.rowCount := 0;
  Result.columnCount := 0;
  Result.tableBounds.LBN := CreateVertex(0, 0, 0);
  Result.tableBounds.RTF := CreateVertex(0, 0, 0);
  Result.isValid := False;
end;

// Освободить ресурсы модели таблицы
procedure FreeTableModel(var aModel: TRtTableModel);
begin
  if aModel.rows <> nil then
  begin
    aModel.rows.Free;
    aModel.rows := nil;
  end;
  if aModel.columns <> nil then
  begin
    aModel.columns.Free;
    aModel.columns := nil;
  end;
  if aModel.cells <> nil then
  begin
    aModel.cells.Free;
    aModel.cells := nil;
  end;
  aModel.isValid := False;
end;

// Создать пустую ячейку
function CreateEmptyCell(aRow, aCol: Integer): TRtTableCell;
begin
  Result.rowIndex := aRow;
  Result.columnIndex := aCol;
  Result.bounds.LBN := CreateVertex(0, 0, 0);
  Result.bounds.RTF := CreateVertex(0, 0, 0);
  Result.textContent := '';
  Result.horizontalAlign := rtcaLeft;
  Result.verticalAlign := rtcaTop;
  Result.borders := CreateCellBorders(True, True, True, True);
  Result.isMerged := False;
  Result.mergeRowSpan := 1;
  Result.mergeColSpan := 1;
end;

// Создать структуру границ ячейки с заданными значениями
function CreateCellBorders(aTop, aBottom, aLeft, aRight: Boolean): TRtCellBorders;
begin
  Result.topBorder := aTop;
  Result.bottomBorder := aBottom;
  Result.leftBorder := aLeft;
  Result.rightBorder := aRight;
end;

// Проверить, находится ли точка внутри ячейки
function IsPointInCell(const aPoint: TzePoint3d; const aCell: TRtTableCell): Boolean;
begin
  Result := (aPoint.x >= aCell.bounds.LBN.x) and
            (aPoint.x <= aCell.bounds.RTF.x) and
            (aPoint.y >= aCell.bounds.LBN.y) and
            (aPoint.y <= aCell.bounds.RTF.y);
end;

// Получить центр ячейки
function GetCellCenter(const aCell: TRtTableCell): TzePoint3d;
begin
  Result.x := (aCell.bounds.LBN.x + aCell.bounds.RTF.x) / 2.0;
  Result.y := (aCell.bounds.LBN.y + aCell.bounds.RTF.y) / 2.0;
  Result.z := (aCell.bounds.LBN.z + aCell.bounds.RTF.z) / 2.0;
end;

// Сравнить два числа с заданным допуском
function IsNearlyEqual(a, b: Double; tolerance: Double): Boolean;
begin
  Result := Abs(a - b) <= tolerance;
end;

end.
