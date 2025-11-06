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

{**Распознать соответствие между геометрией и текстами светильников}
procedure RecognizeLuminaires(
  const ParsedData: TParsedData;
  out RecognizedLights: TLightItemArray
);
var
  i: Integer;
  GeometryEntity: PGDBObjEntity;
  GeometryCenter: GDBvertex;
  TextEntity: PGDBObjEntity;
  TextContent: string;
  RecognizedCount: Integer;
  LightItem: TLightItem;
  ExistingLightIndex: Integer;
begin
  programlog.LogOutFormatStr(
    'Начато распознавание светильников',
    [],
    LM_Info
  );

  SetLength(RecognizedLights, 0);
  RecognizedCount := 0;

  // Перебираем всю геометрию светильников
  for i := 0 to ParsedData.LuminairesGeometry.Count - 1 do
  begin
    GeometryEntity := PGDBObjEntity(ParsedData.LuminairesGeometry[i]);

    // Вычисляем геометрический центр
    GeometryCenter := CalculateEntityCenter(GeometryEntity);

    programlog.LogOutFormatStr(
      'Обработка геометрии %d: центр=(%.1f, %.1f)',
      [i + 1, GeometryCenter.x, GeometryCenter.y],
      LM_Debug
    );

    // Проверяем, есть ли уже светильник в этой точке
    ExistingLightIndex := FindLightAtSameLocation(
      GeometryCenter,
      RecognizedLights,
      RecognizedCount
    );

    if ExistingLightIndex >= 0 then
    begin
      // Добавляем геометрию к существующему светильнику
      RecognizedLights[ExistingLightIndex].GeometryEntities.Add(
        GeometryEntity
      );

      programlog.LogOutFormatStr(
        'Геометрия %d добавлена к существующему светильнику "%s"',
        [i + 1, RecognizedLights[ExistingLightIndex].LumKey],
        LM_Debug
      );
    end
    else
    begin
      // Ищем ближайший текст в радиусе поиска
      if FindNearestText(
        GeometryCenter,
        ParsedData,
        TextEntity,
        TextContent
      ) then
      begin
        // Создаем запись о новом светильнике
        LightItem.LumKey := Trim(TextContent);
        LightItem.Center := GeometryCenter;
        LightItem.GeometryEntities := TEntityList.Create;
        LightItem.GeometryEntities.Add(GeometryEntity);
        LightItem.TextEntity := TextEntity;

        // Добавляем в массив
        SetLength(RecognizedLights, RecognizedCount + 1);
        RecognizedLights[RecognizedCount] := LightItem;
        Inc(RecognizedCount);

        programlog.LogOutFormatStr(
          'Распознан светильник "%s" в точке (%.1f, %.1f)',
          [LightItem.LumKey, GeometryCenter.x, GeometryCenter.y],
          LM_Debug
        );
      end
      else
      begin
        programlog.LogOutFormatStr(
          'Не найден текст для геометрии %d в радиусе %.1f мм',
          [i + 1, SEARCH_RADIUS_MM],
          LM_Warning
        );
      end;
    end;
  end;

  programlog.LogOutFormatStr(
    'Распознавание завершено: найдено %d светильников',
    [RecognizedCount],
    LM_Info
  );
end;

end.
