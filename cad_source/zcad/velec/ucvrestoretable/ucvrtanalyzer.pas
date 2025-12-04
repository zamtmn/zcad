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
  Модуль: ucvrtanalyzer
  Назначение: Анализ геометрии примитивов для построения таблицы
  Описание: Модуль выполняет геометрический анализ примитивов:
            - извлечение горизонтальных и вертикальных линий
            - определение позиций строк и столбцов
            - группировка линий по координатам
            Не содержит визуальных компонентов и зависимостей от UI.
  Зависимости: ucvrtdata, Math
}
unit ucvrtanalyzer;

{$INCLUDE zengineconfig.inc}

interface

uses
  SysUtils,
  Math,
  gvector,
  uzegeometry,
  uzegeometrytypes,
  ucvrtdata;

// Извлечь горизонтальные и вертикальные линии из примитивов
procedure ExtractTableLines(
  const aPrimitives: TRtPrimitiveList;
  out aHorizontalLines: TRtLineList;
  out aVerticalLines: TRtLineList
);

// Получить уникальные позиции из списка линий
procedure ExtractUniquePositions(
  const aLines: TRtLineList;
  out aPositions: array of Double;
  out aCount: Integer
);

// Сортировка позиций по возрастанию
procedure SortPositions(var aPositions: array of Double; aCount: Integer);

// Найти или добавить позицию в список уникальных позиций
function FindOrAddPosition(
  var aPositions: array of Double;
  var aCount: Integer;
  aPos: Double
): Integer;

implementation

uses
  uzcinterface;

// Извлечь линии из одного примитива
procedure ExtractLinesFromPrimitive(
  const aPrimitive: TRtPrimitiveItem;
  var aHorizontalLines: TRtLineList;
  var aVerticalLines: TRtLineList
);
var
  lineData: TRtLineData;
  isHorizontal, isVertical: Boolean;
  dx, dy: Double;
begin
  // Обрабатываем только линии и полилинии
  if not (aPrimitive.primitiveType in [rtptLine, rtptPolyline]) then
    Exit;

  // Вычисляем разницу координат
  dx := Abs(aPrimitive.endPoint.x - aPrimitive.startPoint.x);
  dy := Abs(aPrimitive.endPoint.y - aPrimitive.startPoint.y);

  // Определяем ориентацию линии
  // Горизонтальная: малая разница по Y и достаточная длина по X
  isHorizontal := (dy < COORDINATE_TOLERANCE) and (dx > MIN_CELL_WIDTH);
  // Вертикальная: малая разница по X и достаточная длина по Y
  isVertical := (dx < COORDINATE_TOLERANCE) and (dy > MIN_CELL_HEIGHT);

  // Обработка горизонтальной линии
  if isHorizontal then
  begin
    lineData.position := aPrimitive.startPoint.y;
    lineData.startPos := Min(aPrimitive.startPoint.x, aPrimitive.endPoint.x);
    lineData.endPos := Max(aPrimitive.startPoint.x, aPrimitive.endPoint.x);
    aHorizontalLines.PushBack(lineData);
  end;

  // Обработка вертикальной линии
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
  const aPrimitives: TRtPrimitiveList;
  out aHorizontalLines: TRtLineList;
  out aVerticalLines: TRtLineList
);
var
  i: Integer;
  primitive: PRtPrimitiveItem;
begin
  aHorizontalLines := TRtLineList.Create;
  aVerticalLines := TRtLineList.Create;

  // Перебираем все примитивы и извлекаем линии
  for i := 0 to aPrimitives.Size - 1 do
  begin
    primitive := aPrimitives.Mutable[i];
    ExtractLinesFromPrimitive(primitive^, aHorizontalLines, aVerticalLines);
  end;

  zcUI.TextMessage(
    'Извлечено горизонтальных линий: ' + IntToStr(aHorizontalLines.Size),
    TMWOHistoryOut
  );
  zcUI.TextMessage(
    'Извлечено вертикальных линий: ' + IntToStr(aVerticalLines.Size),
    TMWOHistoryOut
  );
end;

// Найти или добавить позицию в список уникальных позиций
function FindOrAddPosition(
  var aPositions: array of Double;
  var aCount: Integer;
  aPos: Double
): Integer;
var
  i: Integer;
begin
  // Ищем существующую позицию с учетом допуска
  for i := 0 to aCount - 1 do
  begin
    if IsNearlyEqual(aPositions[i], aPos) then
    begin
      Result := i;
      Exit;
    end;
  end;

  // Позиция не найдена, добавляем новую
  if aCount < Length(aPositions) then
  begin
    aPositions[aCount] := aPos;
    Result := aCount;
    Inc(aCount);
  end
  else
    Result := -1;  // Массив переполнен
end;

// Получить уникальные позиции из списка линий
procedure ExtractUniquePositions(
  const aLines: TRtLineList;
  out aPositions: array of Double;
  out aCount: Integer
);
var
  i: Integer;
  line: PRtLineData;
begin
  aCount := 0;

  for i := 0 to aLines.Size - 1 do
  begin
    line := aLines.Mutable[i];
    FindOrAddPosition(aPositions, aCount, line^.position);
  end;
end;

// Сортировка позиций по возрастанию (простая пузырьковая сортировка)
procedure SortPositions(var aPositions: array of Double; aCount: Integer);
var
  i, j: Integer;
  temp: Double;
begin
  for i := 0 to aCount - 2 do
    for j := i + 1 to aCount - 1 do
      if aPositions[i] > aPositions[j] then
      begin
        temp := aPositions[i];
        aPositions[i] := aPositions[j];
        aPositions[j] := temp;
      end;
end;

end.
