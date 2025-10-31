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

{**Модуль общих типов и структур данных для экспорта освещения}
unit uzvlightexporter_types;

{$INCLUDE zengineconfig.inc}

interface
uses
  SysUtils,
  Classes,
  gtree,
  uzeentpolyline,
  uzeentdevice,
  uzegeometrytypes;

const
  // Константы для значений по умолчанию
  UNDEFINED_VALUE = '-1';
  UNDEFINED_NUMERIC_VALUE = -1.0;
  DEFAULT_FLOOR_HEIGHT = 3.0;
  DEFAULT_ROOM_HEIGHT = 2.8;
  DEFAULT_LUMINAIRE_POWER = 35.0;
  DEFAULT_LAMPS_COUNT = 1;

  // Имена переменных в расширениях полилиний
  VAR_SPACE_ROOM = 'Space_Room';
  VAR_SPACE_FLOOR = 'space_Floor';
  VAR_SPACE_BUILDING = 'space_Building';
  VAR_FLOOR_HEIGHT = 'space_FloorHeight';

  // Имена переменных в устройствах
  VAR_LOCATION_FLOORMARK = 'LOCATION_floormark';

  // Константы конвертации единиц измерения
  MM_TO_METERS = 0.001;

  // Константы формата STF для DIALux EVO
  STF_VERSION = '1.0.5';
  STF_PROGRAM_NAME = 'ZCAD';
  STF_PROGRAM_VERSION = '1.0';
  STF_WORKING_PLANE_HEIGHT = 0.8;
  STF_CEILING_REFLECTANCE = 0.75;
  STF_LUMINAIRE_MOUNTING_TYPE = 1;
  STF_LUMINAIRE_SHAPE = 0;
  STF_LUMINAIRE_DEFAULT_FLUX = 0;

type
  {**Тип узла в иерархии пространств}
  TSpaceNodeType = (
    ntBuilding,
    ntSection,
    ntFloor,
    ntRoom,
    ntDevice
  );

  {**Базовый класс данных узла пространственной иерархии}
  TSpaceNodeBase = class
  public
    NodeType: TSpaceNodeType;
    Name: string;
    constructor Create(const AName: string; AType: TSpaceNodeType);
  end;

  {**Узел здания в иерархии}
  TBuildingNode = class(TSpaceNodeBase)
  public
    Address: string;
    YearBuilt: Integer;
    BuildingPolyline: PGDBObjPolyLine;
    constructor Create(const AName: string);
  end;

  {**Узел блок-секции в иерархии}
  TSectionNode = class(TSpaceNodeBase)
  public
    SectionNumber: Integer;
    SectionPolyline: PGDBObjPolyLine;
    constructor Create(const AName: string);
  end;

  {**Узел этажа в иерархии}
  TFloorNode = class(TSpaceNodeBase)
  public
    FloorNumber: Integer;
    CeilingHeight: Double;
    Elevation: Double;
    FloorPolyline: PGDBObjPolyLine;
    constructor Create(const AName: string);
  end;

  {**Узел помещения в иерархии}
  TRoomNode = class(TSpaceNodeBase)
  public
    RoomNumber: string;
    Area: Double;
    Usage: string;
    RoomPolyline: PGDBObjPolyLine;
    constructor Create(const AName: string);
  end;

  {**Узел устройства (светильника) в иерархии}
  TDeviceNode = class(TSpaceNodeBase)
  public
    DeviceType: string;
    Power: Double;
    MountingHeight: Double;
    Position: GDBVertex;
    Rotation: Double;
    NrLamps: Integer;
    Device: PGDBObjDevice;
    constructor Create(const AName: string);
  end;

  {**Упрощенные типы для работы с деревом}
  TSpaceTreeNode = TGTreeNode<TSpaceNodeBase>;
  TSpaceTree = TGTree<TSpaceNodeBase>;

  {**Структура для хранения собранных данных}
  TCollectedData = record
    SpacesList: TList;
    LuminairesList: TList;
  end;

  {**Корневая структура иерархии для экспорта}
  TLightHierarchyRoot = record
    Tree: TSpaceTree;
    ProjectName: string;
    ExportDate: string;
  end;

implementation

{ TSpaceNodeBase }

{**Создать базовый узел пространства}
constructor TSpaceNodeBase.Create(
  const AName: string;
  AType: TSpaceNodeType
);
begin
  inherited Create;
  Name := AName;
  NodeType := AType;
end;

{ TBuildingNode }

{**Создать узел здания}
constructor TBuildingNode.Create(const AName: string);
begin
  inherited Create(AName, ntBuilding);
  Address := '';
  YearBuilt := 0;
  BuildingPolyline := nil;
end;

{ TSectionNode }

{**Создать узел блок-секции}
constructor TSectionNode.Create(const AName: string);
begin
  inherited Create(AName, ntSection);
  SectionNumber := 0;
  SectionPolyline := nil;
end;

{ TFloorNode }

{**Создать узел этажа}
constructor TFloorNode.Create(const AName: string);
begin
  inherited Create(AName, ntFloor);
  FloorNumber := 0;
  CeilingHeight := 0.0;
  Elevation := 0.0;
  FloorPolyline := nil;
end;

{ TRoomNode }

{**Создать узел помещения}
constructor TRoomNode.Create(const AName: string);
begin
  inherited Create(AName, ntRoom);
  RoomNumber := '';
  Area := 0.0;
  Usage := '';
  RoomPolyline := nil;
end;

{ TDeviceNode }

{**Создать узел устройства (светильника)}
constructor TDeviceNode.Create(const AName: string);
begin
  inherited Create(AName, ntDevice);
  DeviceType := '';
  Power := 0.0;
  MountingHeight := 0.0;
  Position.x := 0.0;
  Position.y := 0.0;
  Position.z := 0.0;
  Rotation := 0.0;
  NrLamps := 0;
  Device := nil;
end;

end.
