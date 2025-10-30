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

{**Модуль анализа примитивов и построения структуры таблицы}
unit uzvtable_analyzer;

{$INCLUDE zengineconfig.inc}

interface

uses
  SysUtils,
  Math,
  gvector,
  uzcinterface,
  uzegeometry,
  uzeentity,
  uzegeometrytypes,
  uzvtable_data;

type
  // Вспомогательная структура для хранения линии
  TLineData = record
    position: Double;     // Позиция линии (X для вертикальных, Y для горизонтальных)
    startPos: Double;     // Начальная позиция вдоль линии
    endPos: Double;       // Конечная позиция вдоль линии
  end;
  PLineData = ^TLineData;
  TLineList = specialize TVector<TLineData>;

// Построить структуру таблицы из списка примитивов
function BuildTableFromPrimitives(
  const aPrimitives: TUzvPrimitiveList;
  out aTable: TUzvTableGrid
): Boolean;

// Извлечь горизонтальные и вертикальные линии из примитивов
procedure ExtractTableLines(
  const aPrimitives: TUzvPrimitiveList;
  out aHorizontalLines: TLineList;
  out aVerticalLines: TLineList
);

// Построить сетку строк и столбцов по линиям
procedure BuildRowsAndColumns(
  const aHorizontalLines: TLineList;
  const aVerticalLines: TLineList;
  var aTable: TUzvTableGrid
);

// Найти текст, который попадает в каждую ячейку
procedure AssignTextToCells(
  const aPrimitives: TUzvPrimitiveList;
  var aTable: TUzvTableGrid
);

implementation

uses
  uzclog;

// Сравнить два числа с заданным допуском
function IsNearlyEqual(a, b: Double; tolerance: Double = COORDINATE_TOLERANCE): Boolean;
begin
  Result := Abs(a - b) <= tolerance;
end;

// Найти или добавить позицию в список уникальных позиций
function FindOrAddPosition(var positions: array of Double; var count: Integer; pos: Double): Integer;
var
  i: Integer;
begin
  // Ищем существующую позицию с учетом допуска
  for i := 0 to count - 1 do
  begin
    if IsNearlyEqual(positions[i], pos) then
    begin
      Result := i;
      Exit;
    end;
  end;

  // Не найдено, добавляем новую позицию
  if count < Length(positions) then
  begin
    positions[count] := pos;
    Result := count;
    Inc(count);
  end
  else
    Result := -1;  // Массив переполнен
end;

// Извлечь линии из примитива
procedure ExtractLinesFromPrimitive(
  const aPrimitive: TUzvPrimitiveItem;
  var aHorizontalLines: TLineList;
  var aVerticalLines: TLineList
);
var
  lineData: TLineData;
  isHorizontal, isVertical: Boolean;
  dx, dy: Double;
begin
  // Обрабатываем только линии и полилинии
  if not (aPrimitive.primitiveType in [ptLine, ptPolyline]) then
    Exit;

  // Вычисляем разницу координат
  dx := Abs(aPrimitive.endPoint.x - aPrimitive.startPoint.x);
  dy := Abs(aPrimitive.endPoint.y - aPrimitive.startPoint.y);

  // Определяем ориентацию линии
  isHorizontal := (dy < COORDINATE_TOLERANCE) and (dx > MIN_CELL_WIDTH);
  isVertical := (dx < COORDINATE_TOLERANCE) and (dy > MIN_CELL_HEIGHT);

  // Горизонтальная линия
  if isHorizontal then
  begin
    lineData.position := aPrimitive.startPoint.y;
    lineData.startPos := Min(aPrimitive.startPoint.x, aPrimitive.endPoint.x);
    lineData.endPos := Max(aPrimitive.startPoint.x, aPrimitive.endPoint.x);
    aHorizontalLines.PushBack(lineData);
  end;

  // Вертикальная линия
  if isVertical then
  begin
    lineData.position := aPrimitive.startPoint.x;
    lineData.startPos := Min(aPrimitive.startPoint.y, aPrimitive.endPoint.y);
    lineData.endPos := Max(aPrimitive.startPoint.y, aPrimitive.endPoint.y);
    aVerticalLines.PushBack(lineData);
  end;
end;

// Извлечь горизонтальные и вертикальные линии из примитивов
procedure ExtractTableLines(
  const aPrimitives: TUzvPrimitiveList;
  out aHorizontalLines: TLineList;
  out aVerticalLines: TLineList
);
var
  i: Integer;
  primitive: PUzvPrimitiveItem;
begin
  aHorizontalLines:= TLineList.Create;
  aVerticalLines:= TLineList.Create;;

  // Перебираем все примитивы
  for i := 0 to aPrimitives.Size - 1 do
  begin
    primitive := aPrimitives.Mutable[i];
    ExtractLinesFromPrimitive(primitive^, aHorizontalLines, aVerticalLines);
  end;

  zcUI.TextMessage('Извлечено горизонтальных линий: ' + IntToStr(aHorizontalLines.Size),TMWOHistoryOut);
  zcUI.TextMessage('Извлечено вертикальных линий: ' + IntToStr(aVerticalLines.Size),TMWOHistoryOut);
  //zcLog.LogInfo('Извлечено горизонтальных линий: ' + IntToStr(aHorizontalLines.Size));
  //zcLog.LogInfo('Извлечено вертикальных линий: ' + IntToStr(aVerticalLines.Size));
end;

// Сортировка позиций по возрастанию (для строк и столбцов)
procedure SortPositions(var positions: array of Double; count: Integer);
var
  i, j: Integer;
  temp: Double;
begin
  // Простая сортировка пузырьком
  for i := 0 to count - 2 do
    for j := i + 1 to count - 1 do
      if positions[i] > positions[j] then
      begin
        temp := positions[i];
        positions[i] := positions[j];
        positions[j] := temp;
      end;
end;

// Построить сетку строк и столбцов по линиям
procedure BuildRowsAndColumns(
  const aHorizontalLines: TLineList;
  const aVerticalLines: TLineList;
  var aTable: TUzvTableGrid
);
var
  i: Integer;
  horizontalPositions: array[0..MAX_TABLE_ROWS] of Double;
  verticalPositions: array[0..MAX_TABLE_COLUMNS] of Double;
  hCount, vCount: Integer;
  line: PLineData;
  row: TUzvTableRow;
  col: TUzvTableColumn;
begin
  hCount := 0;
  vCount := 0;

  // Собираем уникальные позиции горизонтальных линий
  for i := 0 to aHorizontalLines.Size - 1 do
  begin
    line := aHorizontalLines.Mutable[i];
    FindOrAddPosition(horizontalPositions, hCount, line^.position);
  end;

  // Собираем уникальные позиции вертикальных линий
  for i := 0 to aVerticalLines.Size - 1 do
  begin
    line := aVerticalLines.Mutable[i];
    FindOrAddPosition(verticalPositions, vCount, line^.position);
  end;

  // Сортируем позиции
  SortPositions(horizontalPositions, hCount);
  SortPositions(verticalPositions, vCount);

  // Создаем строки (между горизонтальными линиями)
  aTable.rows:=TUzvTableRowList.Create;
  for i := 0 to hCount - 2 do
  begin
    row.rowIndex := i;
    row.topPosition := horizontalPositions[i + 1];  // В CAD Y растет вверх
    row.bottomPosition := horizontalPositions[i];
    row.height := row.topPosition - row.bottomPosition;

    // Проверяем минимальную высоту
    if row.height >= MIN_CELL_HEIGHT then
      aTable.rows.PushBack(row);
  end;

  // Создаем столбцы (между вертикальными линиями)
  aTable.columns:=TUzvTableColumnList.Create;
  for i := 0 to vCount - 2 do
  begin
    col.columnIndex := i;
    col.leftPosition := verticalPositions[i];
    col.rightPosition := verticalPositions[i + 1];
    col.width := col.rightPosition - col.leftPosition;

    // Проверяем минимальную ширину
    if col.width >= MIN_CELL_WIDTH then
      aTable.columns.PushBack(col);
  end;

  aTable.rowCount := aTable.rows.Size;
  aTable.columnCount := aTable.columns.Size;

  zcUI.TextMessage('Построено строк: ' + IntToStr(aTable.rowCount),TMWOHistoryOut);
  zcUI.TextMessage('Построено столбцов: ' + IntToStr(aTable.columnCount),TMWOHistoryOut);
  //zcLog.LogInfo('Построено строк: ' + IntToStr(aTable.rowCount));
  //zcLog.LogInfo('Построено столбцов: ' + IntToStr(aTable.columnCount));
end;

// Создать ячейки таблицы из строк и столбцов
procedure CreateCells(var aTable: TUzvTableGrid);
var
  i, j: Integer;
  cell: TUzvTableCell;
  row: PUzvTableRow;
  col: PUzvTableColumn;
begin
  aTable.cells:=TUzvTableCellList.Create;

  // Создаем ячейки для каждой комбинации строка/столбец
  for i := 0 to aTable.rows.Size - 1 do
  begin
    row := aTable.rows.Mutable[i];

    for j := 0 to aTable.columns.Size - 1 do
    begin
      col := aTable.columns.Mutable[j];

      // Создаем пустую ячейку
      cell := CreateEmptyCell(i, j);

      // Устанавливаем границы ячейки
      cell.bounds.LBN := CreateVertex(col^.leftPosition, row^.bottomPosition, 0);
      cell.bounds.RTF := CreateVertex(col^.rightPosition, row^.topPosition, 0);

      aTable.cells.PushBack(cell);
    end;
  end;

  zcUI.TextMessage('Создано ячеек: ' + IntToStr(aTable.cells.Size),TMWOHistoryOut);
  //zcLog.LogInfo('Создано ячеек: ' + IntToStr(aTable.cells.Size));
end;

// Найти ячейку по координатам точки
function FindCellByPoint(const aTable: TUzvTableGrid; const aPoint: GDBVertex): Integer;
var
  i: Integer;
  cell: PUzvTableCell;
begin
  Result := -1;

  for i := 0 to aTable.cells.Size - 1 do
  begin
    cell := aTable.cells.Mutable[i];

    if IsPointInCell(aPoint, cell^) then
    begin
      Result := i;
      Exit;
    end;
  end;
end;

// Найти текст, который попадает в каждую ячейку
procedure AssignTextToCells(
  const aPrimitives: TUzvPrimitiveList;
  var aTable: TUzvTableGrid
);
var
  i, cellIndex: Integer;
  primitive: PUzvPrimitiveItem;
  cell: PUzvTableCell;
  textCenter: GDBVertex;
begin
  // Перебираем все примитивы
  for i := 0 to aPrimitives.Size - 1 do
  begin
    primitive := aPrimitives.Mutable[i];

    // Обрабатываем только текстовые примитивы
    if primitive^.primitiveType in [ptText, ptMText] then
    begin
      // Используем позицию вставки текста или центр габаритного прямоугольника
      if primitive^.primitiveType = ptText then
        textCenter := primitive^.startPoint
      else
      begin
        // Для MText берем центр габаритного прямоугольника
        textCenter.x := (primitive^.boundingBox.LBN.x + primitive^.boundingBox.RTF.x) / 2;
        textCenter.y := (primitive^.boundingBox.LBN.y + primitive^.boundingBox.RTF.y) / 2;
        textCenter.z := 0;
      end;

      // Находим ячейку, в которую попадает текст
      cellIndex := FindCellByPoint(aTable, textCenter);

      if cellIndex >= 0 then
      begin
        cell := aTable.cells.Mutable[cellIndex];

        // Добавляем текст к содержимому ячейки
        if cell^.textContent <> '' then
          cell^.textContent := cell^.textContent + ' ' + primitive^.textContent
        else
          cell^.textContent := primitive^.textContent;

        // Отмечаем примитив как обработанный
        primitive^.processed := True;
      end;
    end;
  end;
end;

// Вычислить общие границы таблицы
procedure CalculateTableBounds(var aTable: TUzvTableGrid);
var
  minX, minY, maxX, maxY: Double;
  i: Integer;
  col: PUzvTableColumn;
  row: PUzvTableRow;
begin
  if (aTable.columns.Size = 0) or (aTable.rows.Size = 0) then
  begin
    aTable.tableBounds.LBN := CreateVertex(0, 0, 0);
    aTable.tableBounds.RTF := CreateVertex(0, 0, 0);
    Exit;
  end;

  // Находим минимальные и максимальные координаты
  col := aTable.columns.Mutable[0];
  minX := col^.leftPosition;

  col := aTable.columns.Mutable[aTable.columns.Size - 1];
  maxX := col^.rightPosition;

  row := aTable.rows.Mutable[0];
  minY := row^.bottomPosition;

  row := aTable.rows.Mutable[aTable.rows.Size - 1];
  maxY := row^.topPosition;

  aTable.tableBounds.LBN := CreateVertex(minX, minY, 0);
  aTable.tableBounds.RTF := CreateVertex(maxX, maxY, 0);
end;

// Построить структуру таблицы из списка примитивов
function BuildTableFromPrimitives(
  const aPrimitives: TUzvPrimitiveList;
  out aTable: TUzvTableGrid
): Boolean;
var
  horizontalLines: TLineList;
  verticalLines: TLineList;
begin
  Result := False;
  aTable := CreateEmptyTableGrid;

  // Проверяем наличие примитивов
  if aPrimitives.Size = 0 then
  begin
    zcUI.TextMessage('Ошибка: список примитивов пуст',TMWOHistoryOut);
    //zcLog.LogInfo('Ошибка: список примитивов пуст');
    Exit;
  end;

  zcUI.TextMessage('Начало построения таблицы из ' + IntToStr(aPrimitives.Size) + ' примитивов',TMWOHistoryOut);
  //zcLog.LogInfo('Начало построения таблицы из ' + IntToStr(aPrimitives.Size) + ' примитивов');

  try
    // Шаг 1: Извлекаем линии из примитивов
    ExtractTableLines(aPrimitives, horizontalLines, verticalLines);

    // Проверяем, что найдены линии
    if (horizontalLines.Size < 2) or (verticalLines.Size < 2) then
    begin
      zcUI.TextMessage('Ошибка: недостаточно линий для построения таблицы',TMWOHistoryOut);
      //zcLog.LogInfo('Ошибка: недостаточно линий для построения таблицы');
      Exit;
    end;

    // Шаг 2: Строим сетку строк и столбцов
    BuildRowsAndColumns(horizontalLines, verticalLines, aTable);

    // Проверяем, что получилась таблица
    if (aTable.rowCount = 0) or (aTable.columnCount = 0) then
    begin
      zcUI.TextMessage('Ошибка: не удалось построить сетку таблицы',TMWOHistoryOut);
      //zcLog.LogInfo('Ошибка: не удалось построить сетку таблицы');
      Exit;
    end;

    // Шаг 3: Создаем ячейки
    CreateCells(aTable);

    // Шаг 4: Назначаем текст в ячейки
    AssignTextToCells(aPrimitives, aTable);

    // Шаг 5: Вычисляем общие границы таблицы
    CalculateTableBounds(aTable);

    // Устанавливаем флаг валидности
    aTable.isValid := True;
    Result := True;

    zcUI.TextMessage('Таблица успешно построена: ' +
                      IntToStr(aTable.rowCount) + ' строк, ' +
                      IntToStr(aTable.columnCount) + ' столбцов, ' +
                      IntToStr(aTable.cells.Size) + ' ячеек'
                      ,TMWOHistoryOut);
    //zcLog.LogInfo('Таблица успешно построена: ' +
    //  IntToStr(aTable.rowCount) + ' строк, ' +
    //  IntToStr(aTable.columnCount) + ' столбцов, ' +
    //  IntToStr(aTable.cells.Size) + ' ячеек');

  finally
    // Освобождаем временные списки
    horizontalLines.Free;
    verticalLines.Free;
  end;
end;

end.
