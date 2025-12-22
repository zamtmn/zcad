# Иерархическая структура пространств / Hierarchical Space Structure

## Описание / Description

Модуль `uzvspacehierarchy.pas` реализует иерархическую древовидную структуру для организации пространств в проектах DIALux EVO.

The `uzvspacehierarchy.pas` module implements a hierarchical tree structure for organizing spaces in DIALux EVO projects.

## Структура иерархии / Hierarchy Structure

Иерархия организована в виде дерева с пятью типами узлов:

The hierarchy is organized as a tree with five node types:

1. **Здание (Building)** - корневой уровень / root level
2. **Блок-секция (Section)** - опциональный промежуточный уровень / optional intermediate level
3. **Этаж (Floor)** - уровень этажа / floor level
4. **Помещение (Room)** - уровень помещения / room level
5. **Устройство (Device)** - уровень устройства (светильника) / device (luminaire) level

## Использование / Usage

### Создание менеджера иерархии / Creating Hierarchy Manager

```pascal
var
  Manager: TSpaceHierarchyManager;
begin
  Manager := TSpaceHierarchyManager.Create;
  try
    // Работа с иерархией / Work with hierarchy
  finally
    Manager.Free;
  end;
end;
```

### Добавление зданий / Adding Buildings

```pascal
var
  Building: TSpaceTreeNode;
begin
  Building := Manager.AddBuilding('Здание 1', PolylinePointer);
end;
```

### Добавление блок-секций / Adding Sections

```pascal
var
  Section: TSpaceTreeNode;
begin
  Section := Manager.AddSection('Здание 1', 'Блок-секция 1', PolylinePointer);
end;
```

### Добавление этажей / Adding Floors

Этажи могут быть добавлены как к зданиям, так и к секциям:

Floors can be added to both buildings and sections:

```pascal
var
  Floor: TSpaceTreeNode;
begin
  // К секции / To section
  Floor := Manager.AddFloor('Блок-секция 1', 'Этаж 1', 1, 2.7, PolylinePointer);

  // Или напрямую к зданию / Or directly to building
  Floor := Manager.AddFloor('Здание 1', 'Этаж 1', 1, 3.0, PolylinePointer);
end;
```

### Добавление помещений / Adding Rooms

```pascal
var
  Room: TSpaceTreeNode;
begin
  Room := Manager.AddRoom('Этаж 1', 'Помещение 101', '101', PolylinePointer);

  // Установка дополнительных параметров / Setting additional parameters
  with TRoomNode(Room.Data) do
  begin
    Area := 25.5;
    Usage := 'Офис';
  end;
end;
```

### Добавление устройств / Adding Devices

```pascal
var
  Device: TSpaceTreeNode;
begin
  Device := Manager.AddDevice('Помещение 101', 'Светильник 1', DevicePointer);

  // Установка параметров / Setting parameters
  with TDeviceNode(Device.Data) do
  begin
    DeviceType := 'LED Panel';
    Power := 35.0;
    MountingHeight := 2.5;
  end;
end;
```

## Примеры / Examples

Полный пример использования находится в файле:

Full usage example can be found in file:

```
examples/space_hierarchy_example.pas
```

## Типы узлов / Node Types

### TBuildingNode - Узел здания

Поля / Fields:
- `Name: string` - название здания / building name
- `Address: string` - адрес / address
- `YearBuilt: Integer` - год постройки / year built
- `BuildingPolyline: PGDBObjPolyLine` - указатель на полилинию / polyline pointer

### TSectionNode - Узел блок-секции

Поля / Fields:
- `Name: string` - название секции / section name
- `SectionNumber: Integer` - номер секции / section number
- `SectionPolyline: PGDBObjPolyLine` - указатель на полилинию / polyline pointer

### TFloorNode - Узел этажа

Поля / Fields:
- `Name: string` - название этажа / floor name
- `FloorNumber: Integer` - номер этажа / floor number
- `CeilingHeight: Double` - высота потолка (м) / ceiling height (m)
- `Elevation: Double` - отметка уровня (м) / elevation (m)
- `FloorPolyline: PGDBObjPolyLine` - указатель на полилинию / polyline pointer

### TRoomNode - Узел помещения

Поля / Fields:
- `Name: string` - название помещения / room name
- `RoomNumber: string` - номер помещения / room number
- `Area: Double` - площадь (м²) / area (m²)
- `Usage: string` - назначение / usage
- `RoomPolyline: PGDBObjPolyLine` - указатель на полилинию / polyline pointer

### TDeviceNode - Узел устройства

Поля / Fields:
- `Name: string` - название устройства / device name
- `DeviceType: string` - тип устройства / device type
- `Power: Double` - мощность (Вт) / power (W)
- `MountingHeight: Double` - высота установки (м) / mounting height (m)
- `Device: PGDBObjDevice` - указатель на устройство / device pointer

## Методы менеджера / Manager Methods

- `AddBuilding` - добавить здание / add building
- `AddSection` - добавить секцию / add section
- `AddFloor` - добавить этаж / add floor
- `AddRoom` - добавить помещение / add room
- `AddDevice` - добавить устройство / add device
- `PrintTree` - вывести дерево в консоль / print tree to console
- `GetNodeCount` - получить количество узлов / get node count
- `ClearTree` - очистить дерево / clear tree
- `GetRoots` - получить корневые узлы / get root nodes

## Интеграция с uzvdialuxmanager.pas / Integration with uzvdialuxmanager.pas

Данная иерархическая структура предназначена для использования в будущих версиях менеджера DIALux для более эффективной организации и экспорта данных пространств.

This hierarchical structure is intended for use in future versions of the DIALux manager for more efficient organization and export of space data.

## Требования / Requirements

- Free Pascal Compiler (FPC) 3.0 или выше / 3.0 or higher
- Библиотека gtree из FCL-STL / gtree library from FCL-STL

## Автор / Author

Vladimir Bobrov

## Лицензия / License

См. файл COPYING.txt в корне проекта / See COPYING.txt file in project root
