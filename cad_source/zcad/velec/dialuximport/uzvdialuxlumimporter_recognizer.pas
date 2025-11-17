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
  uzvdialuxlumimporter_structs,
  uzvdialuxlumimporter_utils;

{**Распознать соответствие между геометрией и текстами светильников}
procedure RecognizeLuminaires(
  const ParsedData: TParsedData;
  out RecognizedLights: TLightItemArray
);

implementation

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
function GetTextInsertionPoint(TextEntity: PGDBObjEntity): GDBvertex;
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

{**Найти ближайший текст к геометрии светильника}
function FindNearestText(
  const GeometryCenter: GDBvertex;
  const ParsedData: TParsedData;
  out TextEntity: PGDBObjEntity;
  out TextContent: string
): Boolean;
var
  i: Integer;
  CurrentEntity: PGDBObjEntity;
  CurrentPoint: GDBvertex;
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
  const Center: GDBvertex;
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
): GDBvertex;
var
  i: Integer;
  Entity: PGDBObjEntity;
  EntityCenter: GDBvertex;
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

{**Проверить, принадлежат ли две сущности одной группе по близости центров}
function AreEntitiesNearby(
  Entity1, Entity2: PGDBObjEntity;
  const Radius: Double
): Boolean;
var
  Center1, Center2: GDBvertex;
  Distance: Double;
  dx, dy: Double;
begin
  Center1 := CalculateEntityCenter(Entity1);
  Center2 := CalculateEntityCenter(Entity2);

  // Вычисляем расстояние только по X и Y (игнорируем Z)
  dx := Center2.x - Center1.x;
  dy := Center2.y - Center1.y;
  Distance := Sqrt(dx * dx + dy * dy);

  Result := Distance <= Radius;
end;

{**Сгруппировать полилинии по близости}
procedure GroupPolylinesByProximity(
  const GeometryList: TLuminairesGeometryList;
  out Groups: TPolylineGroupArray
);
var
  i, j, k: Integer;
  CurrentEntity: PGDBObjEntity;
  GroupIndex: Integer;
  GroupCount: Integer;
  FoundGroup: Boolean;
begin
  SetLength(Groups, 0);
  GroupCount := 0;

  programlog.LogOutFormatStr(
    'Начата группировка %d полилиний по близости',
    [GeometryList.Count],
    LM_Debug
  );

  // Перебираем все геометрические сущности
  for i := 0 to GeometryList.Count - 1 do
  begin
    CurrentEntity := PGDBObjEntity(GeometryList[i]);
    FoundGroup := False;

    // Ищем существующую группу, к которой принадлежит текущая сущность
    for j := 0 to GroupCount - 1 do
    begin
      // Проверяем близость к любой сущности в группе
      for k := 0 to Groups[j].Entities.Count - 1 do
      begin
        if AreEntitiesNearby(
          CurrentEntity,
          PGDBObjEntity(Groups[j].Entities[k]),
          POLYLINE_GROUPING_RADIUS_MM
        ) then
        begin
          // Добавляем к существующей группе
          Groups[j].Entities.Add(CurrentEntity);
          FoundGroup := True;

          programlog.LogOutFormatStr(
            'Полилиния %d добавлена в группу %d (всего в группе: %d)',
            [i + 1, j + 1, Groups[j].Entities.Count],
            LM_Debug
          );

          Break;
        end;
      end;

      if FoundGroup then
        Break;
    end;

    // Если не нашли подходящую группу, создаем новую
    if not FoundGroup then
    begin
      SetLength(Groups, GroupCount + 1);
      Groups[GroupCount].Entities := TEntityList.Create;
      Groups[GroupCount].Entities.Add(CurrentEntity);
      Groups[GroupCount].Processed := False;

      programlog.LogOutFormatStr(
        'Создана новая группа %d для полилинии %d',
        [GroupCount + 1, i + 1],
        LM_Debug
      );

      Inc(GroupCount);
    end;
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
  GroupCenter: GDBvertex;
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

  // Этап 1: Группировка полилиний по близости
  // Полилинии одного светильника находятся рядом друг с другом
  GroupPolylinesByProximity(ParsedData.LuminairesGeometry, PolylineGroups);

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
