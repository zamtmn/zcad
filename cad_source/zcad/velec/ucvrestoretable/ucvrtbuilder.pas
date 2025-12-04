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
  Модуль: ucvrtbuilder
  Назначение: Построение табличной модели из данных анализа
  Описание: Модуль строит структуру таблицы (TRtTableModel):
            - создает строки и столбцы по координатам линий
            - формирует ячейки на пересечении строк и столбцов
            - назначает текстовое содержимое в ячейки
            Не содержит визуальных компонентов и зависимостей от UI.
  Зависимости: ucvrtdata, ucvrtanalyzer, Math
}
unit ucvrtbuilder;

{$INCLUDE zengineconfig.inc}

interface

uses
  SysUtils,
  Math,
  gvector,
  uzegeometry,
  uzegeometrytypes,
  ucvrtdata,
  ucvrtanalyzer;

// Построить модель таблицы из списка примитивов
// Возвращает True при успешном построении
function BuildTableModel(
  const aPrimitives: TRtPrimitiveList;
  out aTableModel: TRtTableModel
): Boolean;

// Построить сетку строк и столбцов по линиям
procedure BuildRowsAndColumns(
  const aHorizontalLines: TRtLineList;
  const aVerticalLines: TRtLineList;
  var aTableModel: TRtTableModel
);

// Создать ячейки таблицы из строк и столбцов
procedure CreateCells(var aTableModel: TRtTableModel);

// Назначить текст из примитивов в ячейки таблицы
procedure AssignTextToCells(
  const aPrimitives: TRtPrimitiveList;
  var aTableModel: TRtTableModel
);

// Вычислить общие границы таблицы
procedure CalculateTableBounds(var aTableModel: TRtTableModel);

implementation

uses
  uzcinterface;

// Найти ячейку по координатам точки
// Возвращает индекс ячейки или -1, если точка не попадает ни в одну ячейку
function FindCellByPoint(
  const aTableModel: TRtTableModel;
  const aPoint: TzePoint3d
): Integer;
var
  i: Integer;
  cell: PRtTableCell;
begin
  Result := -1;

  for i := 0 to aTableModel.cells.Size - 1 do
  begin
    cell := aTableModel.cells.Mutable[i];

    if IsPointInCell(aPoint, cell^) then
    begin
      Result := i;
      Exit;
    end;
  end;
end;

// Построить сетку строк и столбцов по линиям
procedure BuildRowsAndColumns(
  const aHorizontalLines: TRtLineList;
  const aVerticalLines: TRtLineList;
  var aTableModel: TRtTableModel
);
var
  i: Integer;
  horizontalPositions: array[0..MAX_TABLE_ROWS] of Double;
  verticalPositions: array[0..MAX_TABLE_COLUMNS] of Double;
  hCount, vCount: Integer;
  line: PRtLineData;
  row: TRtTableRow;
  col: TRtTableColumn;
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

  // Сортируем позиции по возрастанию
  SortPositions(horizontalPositions, hCount);
  SortPositions(verticalPositions, vCount);

  // Создаем строки (между соседними горизонтальными линиями)
  aTableModel.rows := TRtTableRowList.Create;
  for i := 0 to hCount - 2 do
  begin
    row.rowIndex := i;
    // В CAD Y растет вверх, поэтому topPosition > bottomPosition
    row.topPosition := horizontalPositions[i + 1];
    row.bottomPosition := horizontalPositions[i];
    row.height := row.topPosition - row.bottomPosition;

    // Добавляем только строки с минимальной высотой
    if row.height >= MIN_CELL_HEIGHT then
      aTableModel.rows.PushBack(row);
  end;

  // Создаем столбцы (между соседними вертикальными линиями)
  aTableModel.columns := TRtTableColumnList.Create;
  for i := 0 to vCount - 2 do
  begin
    col.columnIndex := i;
    col.leftPosition := verticalPositions[i];
    col.rightPosition := verticalPositions[i + 1];
    col.width := col.rightPosition - col.leftPosition;

    // Добавляем только столбцы с минимальной шириной
    if col.width >= MIN_CELL_WIDTH then
      aTableModel.columns.PushBack(col);
  end;

  aTableModel.rowCount := aTableModel.rows.Size;
  aTableModel.columnCount := aTableModel.columns.Size;

  zcUI.TextMessage(
    'Построено строк: ' + IntToStr(aTableModel.rowCount),
    TMWOHistoryOut
  );
  zcUI.TextMessage(
    'Построено столбцов: ' + IntToStr(aTableModel.columnCount),
    TMWOHistoryOut
  );
end;

// Создать ячейки таблицы из строк и столбцов
procedure CreateCells(var aTableModel: TRtTableModel);
var
  i, j: Integer;
  cell: TRtTableCell;
  row: PRtTableRow;
  col: PRtTableColumn;
begin
  aTableModel.cells := TRtTableCellList.Create;

  // Создаем ячейки для каждой комбинации строка/столбец
  for i := 0 to aTableModel.rows.Size - 1 do
  begin
    row := aTableModel.rows.Mutable[i];

    for j := 0 to aTableModel.columns.Size - 1 do
    begin
      col := aTableModel.columns.Mutable[j];

      // Создаем пустую ячейку с заданными индексами
      cell := CreateEmptyCell(i, j);

      // Устанавливаем границы ячейки
      cell.bounds.LBN := CreateVertex(col^.leftPosition, row^.bottomPosition, 0);
      cell.bounds.RTF := CreateVertex(col^.rightPosition, row^.topPosition, 0);

      aTableModel.cells.PushBack(cell);
    end;
  end;

  zcUI.TextMessage(
    'Создано ячеек: ' + IntToStr(aTableModel.cells.Size),
    TMWOHistoryOut
  );
end;

// Назначить текст из примитивов в ячейки таблицы
procedure AssignTextToCells(
  const aPrimitives: TRtPrimitiveList;
  var aTableModel: TRtTableModel
);
var
  i, cellIndex: Integer;
  primitive: PRtPrimitiveItem;
  cell: PRtTableCell;
  textCenter: TzePoint3d;
begin
  // Перебираем все примитивы
  for i := 0 to aPrimitives.Size - 1 do
  begin
    primitive := aPrimitives.Mutable[i];

    // Обрабатываем только текстовые примитивы
    if primitive^.primitiveType in [rtptText, rtptMText] then
    begin
      // Определяем позицию текста
      if primitive^.primitiveType = rtptText then
        // Для однострочного текста используем точку вставки
        textCenter := primitive^.startPoint
      else
      begin
        // Для MText берем центр габаритного прямоугольника
        textCenter.x := (primitive^.boundingBox.LBN.x +
                         primitive^.boundingBox.RTF.x) / 2;
        textCenter.y := (primitive^.boundingBox.LBN.y +
                         primitive^.boundingBox.RTF.y) / 2;
        textCenter.z := 0;
      end;

      // Находим ячейку, в которую попадает текст
      cellIndex := FindCellByPoint(aTableModel, textCenter);

      if cellIndex >= 0 then
      begin
        cell := aTableModel.cells.Mutable[cellIndex];

        // Добавляем текст к содержимому ячейки
        // Если ячейка уже содержит текст, добавляем через пробел
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
procedure CalculateTableBounds(var aTableModel: TRtTableModel);
var
  minX, minY, maxX, maxY: Double;
  col: PRtTableColumn;
  row: PRtTableRow;
begin
  // Проверка наличия строк и столбцов
  if (aTableModel.columns.Size = 0) or (aTableModel.rows.Size = 0) then
  begin
    aTableModel.tableBounds.LBN := CreateVertex(0, 0, 0);
    aTableModel.tableBounds.RTF := CreateVertex(0, 0, 0);
    Exit;
  end;

  // Находим минимальные и максимальные координаты
  col := aTableModel.columns.Mutable[0];
  minX := col^.leftPosition;

  col := aTableModel.columns.Mutable[aTableModel.columns.Size - 1];
  maxX := col^.rightPosition;

  row := aTableModel.rows.Mutable[0];
  minY := row^.bottomPosition;

  row := aTableModel.rows.Mutable[aTableModel.rows.Size - 1];
  maxY := row^.topPosition;

  aTableModel.tableBounds.LBN := CreateVertex(minX, minY, 0);
  aTableModel.tableBounds.RTF := CreateVertex(maxX, maxY, 0);
end;

// Построить модель таблицы из списка примитивов
function BuildTableModel(
  const aPrimitives: TRtPrimitiveList;
  out aTableModel: TRtTableModel
): Boolean;
var
  horizontalLines: TRtLineList;
  verticalLines: TRtLineList;
begin
  Result := False;
  aTableModel := CreateEmptyTableModel;

  // Проверяем наличие примитивов
  if aPrimitives.Size = 0 then
  begin
    zcUI.TextMessage(
      'Ошибка: список примитивов пуст',
      TMWOHistoryOut
    );
    Exit;
  end;

  zcUI.TextMessage(
    'Начало построения таблицы из ' + IntToStr(aPrimitives.Size) + ' примитивов',
    TMWOHistoryOut
  );

  try
    // Шаг 1: Извлекаем линии из примитивов
    ExtractTableLines(aPrimitives, horizontalLines, verticalLines);

    // Проверяем, что найдено достаточно линий
    if (horizontalLines.Size < 2) or (verticalLines.Size < 2) then
    begin
      zcUI.TextMessage(
        'Ошибка: недостаточно линий для построения таблицы',
        TMWOHistoryOut
      );
      Exit;
    end;

    // Шаг 2: Строим сетку строк и столбцов
    BuildRowsAndColumns(horizontalLines, verticalLines, aTableModel);

    // Проверяем, что получилась таблица
    if (aTableModel.rowCount = 0) or (aTableModel.columnCount = 0) then
    begin
      zcUI.TextMessage(
        'Ошибка: не удалось построить сетку таблицы',
        TMWOHistoryOut
      );
      Exit;
    end;

    // Шаг 3: Создаем ячейки
    CreateCells(aTableModel);

    // Шаг 4: Назначаем текст в ячейки
    AssignTextToCells(aPrimitives, aTableModel);

    // Шаг 5: Вычисляем общие границы таблицы
    CalculateTableBounds(aTableModel);

    // Устанавливаем флаг валидности
    aTableModel.isValid := True;
    Result := True;

    zcUI.TextMessage(
      'Таблица успешно построена: ' +
      IntToStr(aTableModel.rowCount) + ' строк, ' +
      IntToStr(aTableModel.columnCount) + ' столбцов, ' +
      IntToStr(aTableModel.cells.Size) + ' ячеек',
      TMWOHistoryOut
    );

  finally
    // Освобождаем временные списки линий
    horizontalLines.Free;
    verticalLines.Free;
  end;
end;

end.
