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

{**Модуль определения структур данных для восстановления таблиц}
unit uzvtable_data;

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
  TPrimitiveType = (
    ptLine,         // Отрезок
    ptPolyline,     // Полилиния
    ptText,         // Однострочный текст
    ptMText,        // Многострочный текст
    ptUnknown       // Неизвестный тип
  );

  // Структура для хранения базовых данных о примитиве
  PUzvPrimitiveItem = ^TUzvPrimitiveItem;
  TUzvPrimitiveItem = record
    primitiveType: TPrimitiveType;      // Тип примитива
    objectPointer: Pointer;             // Указатель на объект в ZCAD
    boundingBox: TBoundingBox;          // Габаритный прямоугольник
    startPoint: TzePoint3d;              // Начальная точка (для линий)
    endPoint: TzePoint3d;                // Конечная точка (для линий)
    textContent: string;                // Текстовое содержимое (для текста)
    processed: Boolean;                 // Флаг обработки
  end;

  // Список примитивов
  TUzvPrimitiveList = specialize TVector<TUzvPrimitiveItem>;

  // Выравнивание текста в ячейке
  TUzvCellAlignment = (
    caLeft,         // По левому краю
    caCenter,       // По центру
    caRight,        // По правому краю
    caTop,          // По верхнему краю
    caMiddle,       // По середине (вертикально)
    caBottom        // По нижнему краю
  );

  // Границы ячейки (какие линии видимы)
  TUzvCellBorders = record
    topBorder: Boolean;       // Верхняя граница
    bottomBorder: Boolean;    // Нижняя граница
    leftBorder: Boolean;      // Левая граница
    rightBorder: Boolean;     // Правая граница
  end;

  // Структура ячейки таблицы
  PUzvTableCell = ^TUzvTableCell;
  TUzvTableCell = record
    rowIndex: Integer;                  // Индекс строки
    columnIndex: Integer;               // Индекс столбца
    bounds: TBoundingBox;               // Границы ячейки
    textContent: string;                // Текстовое содержимое
    horizontalAlign: TUzvCellAlignment; // Горизонтальное выравнивание
    verticalAlign: TUzvCellAlignment;   // Вертикальное выравнивание
    borders: TUzvCellBorders;           // Видимые границы
    isMerged: Boolean;                  // Объединена ли ячейка
    mergeRowSpan: Integer;              // Количество объединенных строк
    mergeColSpan: Integer;              // Количество объединенных столбцов
  end;

  // Список ячеек
  TUzvTableCellList = specialize TVector<TUzvTableCell>;

  // Информация о строке таблицы
  PUzvTableRow = ^TUzvTableRow;
  TUzvTableRow = record
    rowIndex: Integer;        // Индекс строки
    topPosition: Double;      // Y-координата верхней границы
    bottomPosition: Double;   // Y-координата нижней границы
    height: Double;           // Высота строки
  end;

  // Список строк
  TUzvTableRowList = specialize TVector<TUzvTableRow>;

  // Информация о столбце таблицы
  PUzvTableColumn = ^TUzvTableColumn;
  TUzvTableColumn = record
    columnIndex: Integer;     // Индекс столбца
    leftPosition: Double;     // X-координата левой границы
    rightPosition: Double;    // X-координата правой границы
    width: Double;            // Ширина столбца
  end;

  // Список столбцов
  TUzvTableColumnList = specialize TVector<TUzvTableColumn>;

  // Основная структура таблицы
  PUzvTableGrid = ^TUzvTableGrid;
  TUzvTableGrid = record
    rows: TUzvTableRowList;           // Список строк
    columns: TUzvTableColumnList;     // Список столбцов
    cells: TUzvTableCellList;         // Список ячеек
    rowCount: Integer;                // Количество строк
    columnCount: Integer;             // Количество столбцов
    tableBounds: TBoundingBox;        // Общие границы таблицы
    isValid: Boolean;                 // Валидна ли структура таблицы
  end;

  // Статус обработки таблицы
  TUzvTableStatus = (
    tsNotStarted,     // Обработка не начата
    tsReading,        // Чтение примитивов
    tsAnalyzing,      // Анализ структуры
    tsBuilding,       // Построение таблицы
    tsComplete,       // Обработка завершена
    tsError           // Ошибка обработки
  );

  // Информация об ошибке обработки
  TUzvTableError = record
    hasError: Boolean;          // Есть ли ошибка
    errorMessage: string;       // Текст ошибки
    errorCode: Integer;         // Код ошибки
  end;

// Вспомогательные функции для работы со структурами

// Создать пустую структуру таблицы
function CreateEmptyTableGrid: TUzvTableGrid;

// Создать пустую ячейку
function CreateEmptyCell(aRow, aCol: Integer): TUzvTableCell;

// Создать структуру границ ячейки с заданными значениями
function CreateCellBorders(aTop, aBottom, aLeft, aRight: Boolean): TUzvCellBorders;

// Проверить, находится ли точка внутри ячейки
function IsPointInCell(const aPoint: TzePoint3d; const aCell: TUzvTableCell): Boolean;

// Получить центр ячейки
function GetCellCenter(const aCell: TUzvTableCell): TzePoint3d;

implementation

uses
  Math;

// Создать пустую структуру таблицы
function CreateEmptyTableGrid: TUzvTableGrid;
var
  tempRows: TUzvTableRowList;
  tempColumns: TUzvTableColumnList;
  tempCells: TUzvTableCellList;
begin
  // Инициализация векторов через временные переменные
  //tempRows.init(10);
  //tempColumns.init(10);
  //tempCells.init(100);

  Result.rows := specialize TVector<TUzvTableRow>.Create;
  Result.columns := specialize TVector<TUzvTableColumn>.Create;
  Result.cells := specialize TVector<TUzvTableCell>.Create;
  Result.rowCount := 0;
  Result.columnCount := 0;
  Result.tableBounds.LBN := CreateVertex(0, 0, 0);
  Result.tableBounds.RTF := CreateVertex(0, 0, 0);
  Result.isValid := False;
end;

// Создать пустую ячейку
function CreateEmptyCell(aRow, aCol: Integer): TUzvTableCell;
begin
  Result.rowIndex := aRow;
  Result.columnIndex := aCol;
  Result.bounds.LBN := CreateVertex(0, 0, 0);
  Result.bounds.RTF := CreateVertex(0, 0, 0);
  Result.textContent := '';
  Result.horizontalAlign := caLeft;
  Result.verticalAlign := caTop;
  Result.borders := CreateCellBorders(True, True, True, True);
  Result.isMerged := False;
  Result.mergeRowSpan := 1;
  Result.mergeColSpan := 1;
end;

// Создать структуру границ ячейки с заданными значениями
function CreateCellBorders(aTop, aBottom, aLeft, aRight: Boolean): TUzvCellBorders;
begin
  Result.topBorder := aTop;
  Result.bottomBorder := aBottom;
  Result.leftBorder := aLeft;
  Result.rightBorder := aRight;
end;

// Проверить, находится ли точка внутри ячейки
function IsPointInCell(const aPoint: TzePoint3d; const aCell: TUzvTableCell): Boolean;
begin
  Result := (aPoint.x >= aCell.bounds.LBN.x) and
            (aPoint.x <= aCell.bounds.RTF.x) and
            (aPoint.y >= aCell.bounds.LBN.y) and
            (aPoint.y <= aCell.bounds.RTF.y);
end;

// Получить центр ячейки
function GetCellCenter(const aCell: TUzvTableCell): TzePoint3d;
begin
  Result.x := (aCell.bounds.LBN.x + aCell.bounds.RTF.x) / 2.0;
  Result.y := (aCell.bounds.LBN.y + aCell.bounds.RTF.y) / 2.0;
  Result.z := (aCell.bounds.LBN.z + aCell.bounds.RTF.z) / 2.0;
end;

end.
