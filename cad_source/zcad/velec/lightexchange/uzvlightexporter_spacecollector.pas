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

{**Модуль сбора выделенных пространств и устройств с чертежа}
unit uzvlightexporter_spacecollector;

{$INCLUDE zengineconfig.inc}

interface
uses
  SysUtils,
  Classes,
  gtree,
  uzcdrawings,
  uzeentity,
  uzeentpolyline,
  uzeentdevice,
  uzegeometrytypes,
  uzcenitiesvariablesextender,
  varmandef,
  uzeconsts,
  gzctnrVectorTypes,
  uzclog,
  uzcinterface,
  uzvlightexporter_types,
  uzvlightexporter_utils;

{**Собрать выделенные пространства и устройства с чертежа}
procedure CollectSelectedSpacesAndDevices(
  var CollectedData: TCollectedData
);

{**Вывести информацию о собранных данных в командную строку}
procedure PrintCollectedDataInfo(const CollectedData: TCollectedData);

{**Очистить собранные данные и освободить память}
procedure ClearCollectedData(var CollectedData: TCollectedData);

implementation

{**Обработать полилинию как пространство}
procedure ProcessPolylineAsSpace(
  PolylinePtr: PGDBObjPolyLine;
  SpacesList: TList;
  var SpaceCount: Integer
);
var
  VarExt: TVariablesExtender;
  SpaceRoom, SpaceRoomPos, SpaceRoomName: string;
  SpaceFloor, SpaceBuilding: string;
  FloorHeight: Double;
  BuildingNode: TBuildingNode;
  FloorNode: TFloorNode;
  RoomNode: TRoomNode;
begin
  VarExt := PolylinePtr^.specialize GetExtension<TVariablesExtender>;

  if VarExt = nil then
    Exit;

  SpaceRoom := GetStringVariable(VarExt, VAR_SPACE_ROOM);
  SpaceRoomPos := GetStringVariable(VarExt, VAR_SPACE_ROOM_POS);
  SpaceRoomName := GetStringVariable(VarExt, VAR_SPACE_ROOM_NAME);
  SpaceFloor := GetStringVariable(VarExt, VAR_SPACE_FLOOR);
  SpaceBuilding := GetStringVariable(VarExt, VAR_SPACE_BUILDING);

  // Проверяем наличие переменных, указывающих на помещение
  // Приоритет: Space_RoomPos или Space_RoomName, затем Space_Room
  if (SpaceRoomPos <> '') or (SpaceRoomName <> '') or (SpaceRoom <> '') then
  begin
    // Используем Space_RoomName как имя, если оно задано
    if SpaceRoomName <> '' then
      RoomNode := TRoomNode.Create(SpaceRoomName)
    else if SpaceRoom <> '' then
      RoomNode := TRoomNode.Create(SpaceRoom)
    else
      RoomNode := TRoomNode.Create('');

    // Используем Space_RoomPos как номер помещения, если он задан
    if SpaceRoomPos <> '' then
      RoomNode.RoomNumber := SpaceRoomPos
    else if SpaceRoom <> '' then
      RoomNode.RoomNumber := SpaceRoom
    else
      RoomNode.RoomNumber := '';

    RoomNode.RoomPolyline := PolylinePtr;
    SpacesList.Add(RoomNode);
    Inc(SpaceCount);
    programlog.LogOutFormatStr(
      'Собрано помещение: %s (номер: %s)',
      [RoomNode.Name, RoomNode.RoomNumber],
      LM_Info
    );
  end
  else if SpaceFloor <> '' then
  begin
    FloorHeight := GetDoubleVariable(VarExt, VAR_FLOOR_HEIGHT, DEFAULT_FLOOR_HEIGHT);
    FloorNode := TFloorNode.Create(SpaceFloor);
    FloorNode.CeilingHeight := FloorHeight;
    FloorNode.FloorPolyline := PolylinePtr;
    SpacesList.Add(FloorNode);
    Inc(SpaceCount);
    programlog.LogOutFormatStr(
      'Собран этаж: %s (высота: %.1f м)',
      [SpaceFloor, FloorHeight],
      LM_Info
    );
  end
  else if SpaceBuilding <> '' then
  begin
    BuildingNode := TBuildingNode.Create(SpaceBuilding);
    BuildingNode.BuildingPolyline := PolylinePtr;
    SpacesList.Add(BuildingNode);
    Inc(SpaceCount);
    programlog.LogOutFormatStr(
      'Собрано здание: %s',
      [SpaceBuilding],
      LM_Info
    );
  end;
end;

{**Обработать устройство как светильник}
procedure ProcessDeviceAsLuminaire(
  DevicePtr: PGDBObjDevice;
  LuminairesList: TList;
  var LuminaireCount: Integer
);
var
  VarExt: TVariablesExtender;
  HeightMM: Double;
  DeviceBrand: string;
  DevicePowerKW: Double;
  DeviceNode: TDeviceNode;
begin
  DeviceNode := TDeviceNode.Create(DevicePtr^.Name);
  DeviceNode.DeviceType := DevicePtr^.Name;
  DeviceNode.Position := DevicePtr^.P_insert_in_WCS;
  DeviceNode.Rotation := DevicePtr^.rotate;
  DeviceNode.Power := DEFAULT_LUMINAIRE_POWER;
  DeviceNode.NrLamps := DEFAULT_LAMPS_COUNT;
  DeviceNode.Device := DevicePtr;

  VarExt := DevicePtr^.specialize GetExtension<TVariablesExtender>;
  if VarExt <> nil then
  begin
    // Получаем высоту монтажа в миллиметрах и конвертируем в метры
    HeightMM := GetDoubleVariable(VarExt, VAR_LOCATION_FLOORMARK, 0.0);
    DeviceNode.MountingHeight := HeightMM * MM_TO_METERS;

    // Получаем марку (бренд) светильника
    DeviceBrand := GetStringVariable(VarExt, VAR_VSPECIFICATION_BRAND);
    if DeviceBrand <> '' then
      DeviceNode.DeviceType := DeviceBrand;

    // Получаем мощность в киловаттах и конвертируем в ватты
    DevicePowerKW := GetDoubleVariable(VarExt, VAR_POWER, 0.0);
    if DevicePowerKW > 0 then
      DeviceNode.Power := DevicePowerKW * 1000.0;

    programlog.LogOutFormatStr(
      'Собран светильник: %s (тип: %s, мощность: %.1f Вт)',
      [DeviceNode.Name, DeviceNode.DeviceType, DeviceNode.Power],
      LM_Debug
    );
  end;

  LuminairesList.Add(DeviceNode);
  Inc(LuminaireCount);
end;

{**Собрать выделенные пространства и устройства с чертежа}
procedure CollectSelectedSpacesAndDevices(
  var CollectedData: TCollectedData
);
var
  EntityPtr: PGDBObjEntity;
  IterRec: itrec;
  PolylinePtr: PGDBObjPolyLine;
  DevicePtr: PGDBObjDevice;
  SpaceCount: Integer;
  LuminaireCount: Integer;
begin
  SpaceCount := 0;
  LuminaireCount := 0;

  CollectedData.SpacesList := TList.Create;
  CollectedData.LuminairesList := TList.Create;

  programlog.LogOutFormatStr(
    'Начат сбор пространств и устройств из выделенных объектов',
    [],
    LM_Info
  );

  EntityPtr := drawings.GetCurrentROOT^.ObjArray.beginiterate(IterRec);
  if EntityPtr = nil then
  begin
    programlog.LogOutFormatStr(
      'Нет объектов для обработки',
      [],
      LM_Warning
    );
    Exit;
  end;

  repeat
    if EntityPtr^.selected then
    begin
      if EntityPtr^.GetObjType = GDBPolyLineID then
      begin
        PolylinePtr := PGDBObjPolyLine(EntityPtr);
        if IsPolylineClosed(PolylinePtr) then
          ProcessPolylineAsSpace(
            PolylinePtr,
            CollectedData.SpacesList,
            SpaceCount
          );
      end
      else if EntityPtr^.GetObjType = GDBDeviceID then
      begin
        DevicePtr := PGDBObjDevice(EntityPtr);
        ProcessDeviceAsLuminaire(
          DevicePtr,
          CollectedData.LuminairesList,
          LuminaireCount
        );
      end;
    end;

    EntityPtr := drawings.GetCurrentROOT^.ObjArray.iterate(IterRec);
  until EntityPtr = nil;

  programlog.LogOutFormatStr(
    'Сбор завершен: пространств=%d, светильников=%d',
    [SpaceCount, LuminaireCount],
    LM_Info
  );
end;

{**Вывести информацию о здании}
procedure PrintBuildingInfo(
  BuildingNode: TBuildingNode;
  Index: Integer;
  var Count: Integer
);
begin
  Inc(Count);
  zcUI.TextMessage(
    '  [' + IntToStr(Index) + '] Здание: ' + BuildingNode.Name,
    TMWOHistoryOut
  );
end;

{**Вывести информацию об этаже}
procedure PrintFloorInfo(
  FloorNode: TFloorNode;
  Index: Integer;
  var Count: Integer
);
begin
  Inc(Count);
  zcUI.TextMessage(
    '  [' + IntToStr(Index) + '] Этаж: ' + FloorNode.Name +
    ' (высота потолка: ' +
    FormatFloat('0.0', FloorNode.CeilingHeight) + ' м)',
    TMWOHistoryOut
  );
end;

{**Вывести информацию о помещении}
procedure PrintRoomInfo(
  RoomNode: TRoomNode;
  Index: Integer;
  var Count: Integer
);
begin
  Inc(Count);
  zcUI.TextMessage(
    '  [' + IntToStr(Index) + '] Помещение: ' + RoomNode.Name +
    ' (номер: ' + RoomNode.RoomNumber + ')',
    TMWOHistoryOut
  );
end;

{**Вывести информацию о пространствах}
procedure PrintSpacesInfo(SpacesList: TList);
var
  i: Integer;
  NodeBase: TSpaceNodeBase;
  BuildingCount, FloorCount, RoomCount: Integer;
begin
  BuildingCount := 0;
  FloorCount := 0;
  RoomCount := 0;

  if (SpacesList = nil) or (SpacesList.Count = 0) then
  begin
    zcUI.TextMessage('Пространства: не найдено', TMWOHistoryOut);
    Exit;
  end;

  zcUI.TextMessage(
    'Пространства (' + IntToStr(SpacesList.Count) + '):',
    TMWOHistoryOut
  );

  for i := 0 to SpacesList.Count - 1 do
  begin
    NodeBase := TSpaceNodeBase(SpacesList[i]);

    if NodeBase is TBuildingNode then
      PrintBuildingInfo(TBuildingNode(NodeBase), i + 1, BuildingCount)
    else if NodeBase is TFloorNode then
      PrintFloorInfo(TFloorNode(NodeBase), i + 1, FloorCount)
    else if NodeBase is TRoomNode then
      PrintRoomInfo(TRoomNode(NodeBase), i + 1, RoomCount);
  end;

  zcUI.TextMessage('', TMWOHistoryOut);
  zcUI.TextMessage(
    'Итого пространств: зданий=' + IntToStr(BuildingCount) +
    ', этажей=' + IntToStr(FloorCount) +
    ', помещений=' + IntToStr(RoomCount),
    TMWOHistoryOut
  );
end;

{**Вывести информацию о светильниках}
procedure PrintLuminairesInfo(LuminairesList: TList);
var
  i: Integer;
  DeviceNode: TDeviceNode;
begin
  if (LuminairesList = nil) or (LuminairesList.Count = 0) then
  begin
    zcUI.TextMessage('Светильники: не найдено', TMWOHistoryOut);
    Exit;
  end;

  zcUI.TextMessage(
    'Светильники (' + IntToStr(LuminairesList.Count) + '):',
    TMWOHistoryOut
  );

  for i := 0 to LuminairesList.Count - 1 do
  begin
    DeviceNode := TDeviceNode(LuminairesList[i]);
    zcUI.TextMessage(
      '  [' + IntToStr(i + 1) + '] Тип: ' + DeviceNode.DeviceType +
      ', мощность: ' + FormatFloat('0.0', DeviceNode.Power) + ' Вт' +
      ', высота: ' + FormatFloat('0.00', DeviceNode.MountingHeight) + ' м',
      TMWOHistoryOut
    );
  end;

  zcUI.TextMessage('', TMWOHistoryOut);
  zcUI.TextMessage(
    'Итого светильников: ' + IntToStr(LuminairesList.Count),
    TMWOHistoryOut
  );
end;

{**Вывести информацию о собранных данных в командную строку}
procedure PrintCollectedDataInfo(const CollectedData: TCollectedData);
begin
  zcUI.TextMessage('', TMWOHistoryOut);
  zcUI.TextMessage('=== Информация о собранных данных ===', TMWOHistoryOut);
  zcUI.TextMessage('', TMWOHistoryOut);

  PrintSpacesInfo(CollectedData.SpacesList);

  zcUI.TextMessage('', TMWOHistoryOut);

  PrintLuminairesInfo(CollectedData.LuminairesList);

  zcUI.TextMessage('', TMWOHistoryOut);
  zcUI.TextMessage('=== Конец информации ===', TMWOHistoryOut);
  zcUI.TextMessage('', TMWOHistoryOut);
end;

{**Очистить собранные данные и освободить память}
procedure ClearCollectedData(var CollectedData: TCollectedData);
var
  i: Integer;
  NodeBase: TSpaceNodeBase;
begin
  if CollectedData.SpacesList <> nil then
  begin
    for i := 0 to CollectedData.SpacesList.Count - 1 do
    begin
      NodeBase := TSpaceNodeBase(CollectedData.SpacesList[i]);
      if NodeBase <> nil then
        NodeBase.Free;
    end;
    CollectedData.SpacesList.Free;
    CollectedData.SpacesList := nil;
  end;

  if CollectedData.LuminairesList <> nil then
  begin
    for i := 0 to CollectedData.LuminairesList.Count - 1 do
    begin
      NodeBase := TSpaceNodeBase(CollectedData.LuminairesList[i]);
      if NodeBase <> nil then
        NodeBase.Free;
    end;
    CollectedData.LuminairesList.Free;
    CollectedData.LuminairesList := nil;
  end;
end;

end.
