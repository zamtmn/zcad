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
  uzvlightexporter_types,
  uzvlightexporter_utils;

{**Собрать выделенные пространства и устройства с чертежа}
procedure CollectSelectedSpacesAndDevices(
  var CollectedData: TCollectedData
);

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
  SpaceRoom, SpaceFloor, SpaceBuilding: string;
  FloorHeight: Double;
  BuildingNode: TBuildingNode;
  FloorNode: TFloorNode;
  RoomNode: TRoomNode;
begin
  VarExt := PolylinePtr^.specialize GetExtension<TVariablesExtender>;

  if VarExt = nil then
    Exit;

  SpaceRoom := GetStringVariable(VarExt, VAR_SPACE_ROOM);
  SpaceFloor := GetStringVariable(VarExt, VAR_SPACE_FLOOR);
  SpaceBuilding := GetStringVariable(VarExt, VAR_SPACE_BUILDING);

  if SpaceRoom <> '' then
  begin
    RoomNode := TRoomNode.Create(SpaceRoom);
    RoomNode.RoomNumber := SpaceRoom;
    RoomNode.RoomPolyline := PolylinePtr;
    SpacesList.Add(RoomNode);
    Inc(SpaceCount);
    programlog.LogOutFormatStr(
      'Собрано помещение: %s',
      [SpaceRoom],
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
    HeightMM := GetDoubleVariable(VarExt, VAR_LOCATION_FLOORMARK, 0.0);
    DeviceNode.MountingHeight := HeightMM * MM_TO_METERS;
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
