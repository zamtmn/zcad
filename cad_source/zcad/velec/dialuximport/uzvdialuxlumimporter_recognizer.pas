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

{**Модуль распознавания светильников и их номеров}
unit uzvdialuxlumimporter_recognizer;

{$INCLUDE zengineconfig.inc}

interface
uses
  SysUtils,
  Math,
  uzeentity,
  uzeenttext,
  uzeentmtext,
  uzegeometrytypes,
  uzegeometry,
  uzeconsts,
  uzclog,
  uzeentpolyline,
  uzeentline,
  uzvdialuxlumimporter_structs,
  uzvdialuxlumimporter_utils;

{**Распознать соответствие между геометрией и текстами светильников}
procedure RecognizeLuminaires(
  const ParsedData: TParsedData;
  out RecognizedLights: TLightItemArray
);

implementation

type
  {**Вершина полилинии с координатами X и Y (Z игнорируется)}
  TVertex2D = record
    x: Double;
    y: Double;
  end;

  {**Массив двумерных вершин}
  TVertex2DArray = array of TVertex2D;

  {**Информация о полилинии для группировки}
  TPolylineInfo = record
    Entity: PGDBObjEntity;        // Указатель на сущность
    Vertices: TVertex2DArray;     // Массив вершин (x,y)
    GroupIndex: Integer;          // Индекс группы (-1 если не назначен)
  end;

  {**Массив информации о полилиниях}
  TPolylineInfoArray = array of TPolylineInfo;

{**Получить текстовое содержимое из текстового объекта}
function GetTextContent(TextEntity: PGDBObjEntity): string;
var
  ObjType: Integer;
  TextPtr: PGDBObjText;
  MTextPtr: PGDBObjMText;
begin
  Result := '';

  if TextEntity = nil then
    Exit;

  ObjType := TextEntity^.GetObjType;

  if ObjType = GDBTextID then
  begin
    TextPtr := PGDBObjText(TextEntity);
    Result := TextPtr^.Content;
  end
  else if ObjType = GDBMTextID then
  begin
    MTextPtr := PGDBObjMText(TextEntity);
    Result := MTextPtr^.Content;
  end;
end;

{**Получить точку вставки текстового объекта}
function GetTextInsertionPoint(TextEntity: PGDBObjEntity): TzePoint3d;
var
  ObjType: Integer;
  TextPtr: PGDBObjText;
  MTextPtr: PGDBObjMText;
begin
  Result := NulVertex;

  if TextEntity = nil then
    Exit;

  ObjType := TextEntity^.GetObjType;

  if ObjType = GDBTextID then
  begin
    TextPtr := PGDBObjText(TextEntity);
    Result := TextPtr^.Local.P_insert;
  end
  else if ObjType = GDBMTextID then
  begin
    MTextPtr := PGDBObjMText(TextEntity);
    Result := MTextPtr^.P_insert_in_WCS;
  end;
end;

{**Проверить, совпадают ли две вершины по координатам x,y с заданным допуском}
function AreVerticesEqual(
  const V1, V2: TVertex2D;
  const Tolerance: Double
): Boolean;
var
  dx, dy: Double;
begin
  dx := Abs(V1.x - V2.x);
  dy := Abs(V1.y - V2.y);
  Result := (dx <= Tolerance) and (dy <= Tolerance);
end;

{**Извлечь вершины из полилинии в формате 2D (только x,y)}
function ExtractPolylineVertices2D(
  Entity: PGDBObjEntity
): TVertex2DArray;
var
  i: Integer;
  PolyPtr: PGDBObjPolyLine;
  LinePtr: PGDBObjLine;
  Count: Integer;
  Vertex: PzePoint3d;
  ObjType: Integer;
begin
  SetLength(Result, 0);

  if Entity = nil then
    Exit;

  ObjType := Entity^.GetObjType;

  if ObjType = GDBPolyLineID then
  begin
    PolyPtr := PGDBObjPolyLine(Entity);
    Count := PolyPtr^.VertexArrayInOCS.Count;

    if Count > 0 then
    begin
      SetLength(Result, Count);
      Vertex := PzePoint3d(PolyPtr^.VertexArrayInOCS.GetParrayAsPointer);

      for i := 0 to Count - 1 do
      begin
        Result[i].x := Vertex^.x;
        Result[i].y := Vertex^.y;
        Inc(Vertex);
      end;
    end;
  end
  else if ObjType = GDBLineID then
  begin
    // Линия имеет только 2 вершины
    LinePtr := PGDBObjLine(Entity);
    SetLength(Result, 2);
    Result[0].x := LinePtr^.CoordInOCS.lBegin.x;
    Result[0].y := LinePtr^.CoordInOCS.lBegin.y;
    Result[1].x := LinePtr^.CoordInOCS.lEnd.x;
    Result[1].y := LinePtr^.CoordInOCS.lEnd.y;
  end;
end;

{**Проверить, имеют ли две полилинии общие вершины}
function DoPolylinesShareVertices(
  const Poly1, Poly2: TPolylineInfo;
  const Tolerance: Double
): Boolean;
var
  i, j: Integer;
begin
  Result := False;

  // Проверяем все пары вершин из двух полилиний
  for i := 0 to High(Poly1.Vertices) do
  begin
    for j := 0 to High(Poly2.Vertices) do
    begin
      if AreVerticesEqual(Poly1.Vertices[i], Poly2.Vertices[j], Tolerance) then
      begin
        Result := True;
        Exit;
      end;
    end;
  end;
end;

{**Извлечь информацию о всех полилиниях из списка геометрии}
procedure ExtractPolylineInfoArray(
  const GeometryList: TLuminairesGeometryList;
  out PolyInfoArray: TPolylineInfoArray
);
var
  i: Integer;
  Entity: PGDBObjEntity;
begin
  SetLength(PolyInfoArray, GeometryList.Count);

  for i := 0 to GeometryList.Count - 1 do
  begin
    Entity := PGDBObjEntity(GeometryList[i]);
    PolyInfoArray[i].Entity := Entity;
    PolyInfoArray[i].Vertices := ExtractPolylineVertices2D(Entity);
    PolyInfoArray[i].GroupIndex := -1; // Изначально не принадлежит ни одной группе
  end;
end;

{**Найти ближайший текст к геометрии светильника}
function FindNearestText(
  const GeometryCenter: TzePoint3d;
  const ParsedData: TParsedData;
  out TextEntity: PGDBObjEntity;
  out TextContent: string
): Boolean;
var
  i: Integer;
  CurrentEntity: PGDBObjEntity;
  CurrentPoint: TzePoint3d;
  CurrentDistance: Double;
  MinDistance: Double;
  BestEntity: PGDBObjEntity;
  BestContent: string;
begin
  Result := False;
  TextEntity := nil;
  TextContent := '';
  MinDistance := SEARCH_RADIUS_MM + 1.0;
  BestEntity := nil;
  BestContent := '';

  // Перебираем все текстовые объекты
  for i := 0 to ParsedData.LuminairesKeys.Count - 1 do
  begin
    CurrentEntity := PGDBObjEntity(ParsedData.LuminairesKeys[i]);
    CurrentPoint := GetTextInsertionPoint(CurrentEntity);
    CurrentDistance := CalculateDistance(GeometryCenter, CurrentPoint);

    // Проверяем, находится ли текст в радиусе поиска
    if CurrentDistance <= SEARCH_RADIUS_MM then
    begin
      // Ищем ближайший текст
      if CurrentDistance < MinDistance then
      begin
        MinDistance := CurrentDistance;
        BestEntity := CurrentEntity;
        BestContent := GetTextContent(CurrentEntity);
        Result := True;
      end;
    end;
  end;

  if Result then
  begin
    TextEntity := BestEntity;
    TextContent := BestContent;
  end;
end;

{**Найти существующий светильник в той же точке}
function FindLightAtSameLocation(
  const Center: TzePoint3d;
  const RecognizedLights: TLightItemArray;
  Count: Integer
): Integer;
var
  i: Integer;
  Distance: Double;
begin
  Result := -1;

  for i := 0 to Count - 1 do
  begin
    Distance := CalculateDistance(Center, RecognizedLights[i].Center);

    // Если расстояние меньше допуска, считаем это той же точкой
    if Distance <= GROUPING_TOLERANCE_MM then
    begin
      Result := i;
      Exit;
    end;
  end;
end;

{**Освободить память списка сущностей в светильнике}
procedure FreeLightItemGeometry(var LightItem: TLightItem);
begin
  if LightItem.GeometryEntities <> nil then
  begin
    LightItem.GeometryEntities.Free;
    LightItem.GeometryEntities := nil;
  end;
end;

{**Вычислить центр группы полилиний (с игнорированием Z координаты)}
function CalculateGroupCenter(
  const Entities: TEntityList
): TzePoint3d;
var
  i: Integer;
  Entity: PGDBObjEntity;
  EntityCenter: TzePoint3d;
  SumX, SumY: Double;
  Count: Integer;
begin
  Result := NulVertex;

  if (Entities = nil) or (Entities.Count = 0) then
    Exit;

  SumX := 0.0;
  SumY := 0.0;
  Count := 0;

  // Суммируем координаты центров всех сущностей в группе
  for i := 0 to Entities.Count - 1 do
  begin
    Entity := PGDBObjEntity(Entities[i]);
    EntityCenter := CalculateEntityCenter(Entity);

    SumX := SumX + EntityCenter.x;
    SumY := SumY + EntityCenter.y;
    // Z координату игнорируем согласно требованию
    Inc(Count);
  end;

  if Count > 0 then
  begin
    Result.x := SumX / Count;
    Result.y := SumY / Count;
    Result.z := 0.0; // Z всегда 0, так как мы его игнорируем
  end;
end;

{**Объединить две группы полилиний (алгоритм Union-Find)}
procedure MergePolylineGroups(
  var PolyInfoArray: TPolylineInfoArray;
  Index1, Index2: Integer
);
var
  i: Integer;
  OldGroupIndex, NewGroupIndex: Integer;
begin
  // Определяем, какую группу заменяем
  OldGroupIndex := PolyInfoArray[Index2].GroupIndex;
  NewGroupIndex := PolyInfoArray[Index1].GroupIndex;

  // Объединяем группы: все элементы с OldGroupIndex получают NewGroupIndex
  for i := 0 to High(PolyInfoArray) do
  begin
    if PolyInfoArray[i].GroupIndex = OldGroupIndex then
      PolyInfoArray[i].GroupIndex := NewGroupIndex;
  end;
end;

{**Сгруппировать полилинии по совпадению вершин (алгоритм связных компонент)}
procedure GroupPolylinesByVertexMatching(
  const GeometryList: TLuminairesGeometryList;
  out Groups: TPolylineGroupArray
);
var
  i, j, k: Integer;
  PolyInfoArray: TPolylineInfoArray;
  NextGroupIndex: Integer;
  GroupCount: Integer;
  GroupIndices: array of Integer;
  GroupIndex: Integer;
begin
  SetLength(Groups, 0);

  if GeometryList.Count = 0 then
    Exit;

  programlog.LogOutFormatStr(
    'Начата группировка %d полилиний по совпадению вершин',
    [GeometryList.Count],
    LM_Info
  );

  // Этап 1: Извлекаем информацию о вершинах всех полилиний
  ExtractPolylineInfoArray(GeometryList, PolyInfoArray);

  // Этап 2: Применяем алгоритм поиска связных компонент
  NextGroupIndex := 0;

  for i := 0 to High(PolyInfoArray) do
  begin
    // Если полилиния еще не в группе, создаем новую группу
    if PolyInfoArray[i].GroupIndex = -1 then
    begin
      PolyInfoArray[i].GroupIndex := NextGroupIndex;
      Inc(NextGroupIndex);
    end;

    // Проверяем все последующие полилинии на совпадение вершин
    for j := i + 1 to High(PolyInfoArray) do
    begin
      if DoPolylinesShareVertices(
        PolyInfoArray[i],
        PolyInfoArray[j],
        VERTEX_MATCH_TOLERANCE_MM
      ) then
      begin
        // Если j-я полилиния еще не в группе, добавляем в группу i-й
        if PolyInfoArray[j].GroupIndex = -1 then
        begin
          PolyInfoArray[j].GroupIndex := PolyInfoArray[i].GroupIndex;

          programlog.LogOutFormatStr(
            'Полилинии %d и %d имеют общие вершины, объединены в группу %d',
            [i + 1, j + 1, PolyInfoArray[i].GroupIndex + 1],
            LM_Debug
          );
        end
        // Если обе в разных группах, объединяем группы
        else if PolyInfoArray[j].GroupIndex <> PolyInfoArray[i].GroupIndex then
        begin
          programlog.LogOutFormatStr(
            'Объединение групп %d и %d через полилинии %d и %d',
            [PolyInfoArray[i].GroupIndex + 1, PolyInfoArray[j].GroupIndex + 1,
             i + 1, j + 1],
            LM_Debug
          );

          MergePolylineGroups(PolyInfoArray, i, j);
        end;
      end;
    end;
  end;

  // Этап 3: Подсчитываем количество уникальных групп и нормализуем индексы
  SetLength(GroupIndices, NextGroupIndex);
  for i := 0 to High(GroupIndices) do
    GroupIndices[i] := -1;

  GroupCount := 0;
  for i := 0 to High(PolyInfoArray) do
  begin
    GroupIndex := PolyInfoArray[i].GroupIndex;
    if GroupIndices[GroupIndex] = -1 then
    begin
      GroupIndices[GroupIndex] := GroupCount;
      Inc(GroupCount);
    end;
    PolyInfoArray[i].GroupIndex := GroupIndices[GroupIndex];
  end;

  programlog.LogOutFormatStr(
    'Найдено %d уникальных групп',
    [GroupCount],
    LM_Info
  );

  // Этап 4: Создаем массив групп и заполняем его
  SetLength(Groups, GroupCount);
  for i := 0 to GroupCount - 1 do
  begin
    Groups[i].Entities := TEntityList.Create;
    Groups[i].Processed := False;
  end;

  // Распределяем полилинии по группам
  for i := 0 to High(PolyInfoArray) do
  begin
    GroupIndex := PolyInfoArray[i].GroupIndex;
    Groups[GroupIndex].Entities.Add(PolyInfoArray[i].Entity);
  end;

  // Вычисляем центры для всех групп
  for i := 0 to GroupCount - 1 do
  begin
    Groups[i].Center := CalculateGroupCenter(Groups[i].Entities);

    programlog.LogOutFormatStr(
      'Группа %d: %d полилиний, центр=(%.1f, %.1f)',
      [i + 1, Groups[i].Entities.Count, Groups[i].Center.x, Groups[i].Center.y],
      LM_Info
    );
  end;

  programlog.LogOutFormatStr(
    'Группировка завершена: создано %d групп',
    [GroupCount],
    LM_Info
  );
end;

{**Освободить память массива групп полилиний}
procedure FreePolylineGroups(var Groups: TPolylineGroupArray);
var
  i: Integer;
begin
  for i := 0 to High(Groups) do
  begin
    if Groups[i].Entities <> nil then
    begin
      Groups[i].Entities.Free;
      Groups[i].Entities := nil;
    end;
  end;

  SetLength(Groups, 0);
end;

{**Распознать соответствие между геометрией и текстами светильников}
procedure RecognizeLuminaires(
  const ParsedData: TParsedData;
  out RecognizedLights: TLightItemArray
);
var
  i, j: Integer;
  PolylineGroups: TPolylineGroupArray;
  GroupCenter: TzePoint3d;
  TextEntity: PGDBObjEntity;
  TextContent: string;
  RecognizedCount: Integer;
  LightItem: TLightItem;
begin
  programlog.LogOutFormatStr(
    'Начато распознавание светильников',
    [],
    LM_Info
  );

  SetLength(RecognizedLights, 0);
  RecognizedCount := 0;

  // Этап 1: Группировка полилиний по совпадению вершин
  // Полилинии одного светильника имеют общие вершины (по координатам x,y)
  GroupPolylinesByVertexMatching(ParsedData.LuminairesGeometry, PolylineGroups);

  try
    // Этап 2: Распознавание светильников на основе групп
    for i := 0 to High(PolylineGroups) do
    begin
      GroupCenter := PolylineGroups[i].Center;

      programlog.LogOutFormatStr(
        'Обработка группы %d: %d полилиний, центр=(%.1f, %.1f)',
        [i + 1, PolylineGroups[i].Entities.Count,
         GroupCenter.x, GroupCenter.y],
        LM_Debug
      );

      // Ищем ближайший текст в радиусе поиска
      if FindNearestText(
        GroupCenter,
        ParsedData,
        TextEntity,
        TextContent
      ) then
      begin
        // Создаем запись о новом светильнике
        LightItem.LumKey := Trim(TextContent);
        LightItem.Center := GroupCenter;
        LightItem.GeometryEntities := TEntityList.Create;

        // Добавляем все полилинии группы в список геометрии светильника
        for j := 0 to PolylineGroups[i].Entities.Count - 1 do
        begin
          LightItem.GeometryEntities.Add(
            PolylineGroups[i].Entities[j]
          );
        end;

        LightItem.TextEntity := TextEntity;

        // Добавляем в массив
        SetLength(RecognizedLights, RecognizedCount + 1);
        RecognizedLights[RecognizedCount] := LightItem;
        Inc(RecognizedCount);

        programlog.LogOutFormatStr(
          'Распознан светильник "%s" в точке (%.1f, %.1f) ' +
          '(%d полилиний в составе)',
          [LightItem.LumKey, GroupCenter.x, GroupCenter.y,
           PolylineGroups[i].Entities.Count],
          LM_Info
        );
      end
      else
      begin
        programlog.LogOutFormatStr(
          'Не найден текст для группы %d в радиусе %.1f мм',
          [i + 1, SEARCH_RADIUS_MM],
          LM_Warning
        );
      end;
    end;

    programlog.LogOutFormatStr(
      'Распознавание завершено: найдено %d светильников из %d групп',
      [RecognizedCount, Length(PolylineGroups)],
      LM_Info
    );
  finally
    // Освобождаем память групп
    FreePolylineGroups(PolylineGroups);
  end;
end;

end.
