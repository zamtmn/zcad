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

{**Модуль иерархической структуры пространств для DIALux}
unit uzvspacehierarchy;

{ file def.inc is necessary to include at the beginning of each module zcad
  it contains a centralized compilation parameters settings }

{ файл def.inc необходимо включать в начале каждого модуля zcad
  он содержит в себе централизованные настройки параметров компиляции  }

{$INCLUDE zengineconfig.inc}

interface
uses
  SysUtils,
  Classes,
  gtree,
  uzeentpolyline,
  uzeentdevice,
  uzcinterface;

type
  {**Тип узла в иерархии пространств}
  {**Node type in space hierarchy}
  TSpaceNodeType = (
    ntBuilding,  // Здание
    ntSection,   // Блок-секция
    ntFloor,     // Этаж
    ntRoom,      // Помещение
    ntDevice     // Устройство (светильник)
  );

  {**Базовый класс данных узла пространственной иерархии}
  {**Base class for spatial hierarchy node data}
  TSpaceNodeBase = class
  public
    NodeType: TSpaceNodeType;     // Тип узла
    Name: string;                  // Наименование узла
    constructor Create(const AName: string; AType: TSpaceNodeType);
  end;

  {**Узел здания в иерархии}
  {**Building node in hierarchy}
  TBuildingNode = class(TSpaceNodeBase)
  public
    Address: string;               // Адрес здания
    YearBuilt: Integer;            // Год постройки
    BuildingPolyline: PGDBObjPolyLine;  // Указатель на полилинию здания
    constructor Create(const AName: string);
  end;

  {**Узел блок-секции в иерархии}
  {**Section node in hierarchy}
  TSectionNode = class(TSpaceNodeBase)
  public
    SectionNumber: Integer;        // Номер секции
    SectionPolyline: PGDBObjPolyLine;  // Указатель на полилинию секции
    constructor Create(const AName: string);
  end;

  {**Узел этажа в иерархии}
  {**Floor node in hierarchy}
  TFloorNode = class(TSpaceNodeBase)
  public
    FloorNumber: Integer;          // Номер этажа
    CeilingHeight: Double;         // Высота потолка (м)
    Elevation: Double;             // Отметка уровня (м)
    FloorPolyline: PGDBObjPolyLine;  // Указатель на полилинию этажа
    constructor Create(const AName: string);
  end;

  {**Узел помещения в иерархии}
  {**Room node in hierarchy}
  TRoomNode = class(TSpaceNodeBase)
  public
    RoomNumber: string;            // Номер помещения
    Area: Double;                  // Площадь помещения (м²)
    Usage: string;                 // Назначение помещения
    RoomPolyline: PGDBObjPolyLine;  // Указатель на полилинию помещения
    constructor Create(const AName: string);
  end;

  {**Узел устройства (светильника) в иерархии}
  {**Device (luminaire) node in hierarchy}
  TDeviceNode = class(TSpaceNodeBase)
  public
    DeviceType: string;            // Тип устройства
    Power: Double;                 // Мощность (Вт)
    MountingHeight: Double;        // Высота установки (м)
    Device: PGDBObjDevice;         // Указатель на устройство
    constructor Create(const AName: string);
  end;

  {**Упрощенные типы для работы с деревом}
  {**Simplified types for tree operations}
  TSpaceTreeNode = TGTreeNode<TSpaceNodeBase>;
  TSpaceTree = TGTree<TSpaceNodeBase>;

  {**Класс-менеджер иерархической структуры пространств}
  {**Manager class for spatial hierarchy structure}
  TSpaceHierarchyManager = class
  private
    FTree: TSpaceTree;             // Дерево иерархии пространств

    {**Найти узел по имени и типу}
    {**Find node by name and type}
    function FindNode(
      const AName: string;
      ANodeType: TSpaceNodeType
    ): TSpaceTreeNode;

    {**Рекурсивный поиск узла в дереве}
    {**Recursive node search in tree}
    function SearchNode(
      ANode: TSpaceTreeNode;
      const AName: string;
      ANodeType: TSpaceNodeType
    ): TSpaceTreeNode;

  public
    constructor Create;
    destructor Destroy; override;

    {**Добавить здание в иерархию}
    {**Add building to hierarchy}
    function AddBuilding(
      const AName: string;
      APolyline: PGDBObjPolyLine
    ): TSpaceTreeNode;

    {**Добавить блок-секцию к зданию}
    {**Add section to building}
    function AddSection(
      const ABuildingName: string;
      const ASectionName: string;
      APolyline: PGDBObjPolyLine
    ): TSpaceTreeNode;

    {**Добавить этаж к секции или зданию}
    {**Add floor to section or building}
    function AddFloor(
      const AParentName: string;
      const AFloorName: string;
      AFloorNumber: Integer;
      ACeilingHeight: Double;
      APolyline: PGDBObjPolyLine
    ): TSpaceTreeNode;

    {**Добавить помещение к этажу}
    {**Add room to floor}
    function AddRoom(
      const AFloorName: string;
      const ARoomName: string;
      const ARoomNumber: string;
      APolyline: PGDBObjPolyLine
    ): TSpaceTreeNode;

    {**Добавить устройство к помещению}
    {**Add device to room}
    function AddDevice(
      const ARoomName: string;
      const ADeviceName: string;
      ADevice: PGDBObjDevice
    ): TSpaceTreeNode;

    {**Вывести дерево в консоль (для отладки)}
    {**Print tree to console (for debugging)}
    procedure PrintTree;

    {**Рекурсивная печать узла}
    {**Recursive node printing}
    procedure PrintNode(ANode: TSpaceTreeNode; AIndent: Integer);

    {**Получить количество узлов дерева}
    {**Get tree node count}
    function GetNodeCount: Integer;

    {**Очистить дерево}
    {**Clear tree}
    procedure ClearTree;

    {**Получить корневые узлы дерева}
    {**Get root nodes of tree}
    function GetRoots: TGTreeNode<TSpaceNodeBase>.TChildren;

    property Tree: TSpaceTree read FTree;
  end;

implementation

{ TSpaceNodeBase }

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

constructor TBuildingNode.Create(const AName: string);
begin
  inherited Create(AName, ntBuilding);
  Address := '';
  YearBuilt := 0;
  BuildingPolyline := nil;
end;

{ TSectionNode }

constructor TSectionNode.Create(const AName: string);
begin
  inherited Create(AName, ntSection);
  SectionNumber := 0;
  SectionPolyline := nil;
end;

{ TFloorNode }

constructor TFloorNode.Create(const AName: string);
begin
  inherited Create(AName, ntFloor);
  FloorNumber := 0;
  CeilingHeight := 0.0;
  Elevation := 0.0;
  FloorPolyline := nil;
end;

{ TRoomNode }

constructor TRoomNode.Create(const AName: string);
begin
  inherited Create(AName, ntRoom);
  RoomNumber := '';
  Area := 0.0;
  Usage := '';
  RoomPolyline := nil;
end;

{ TDeviceNode }

constructor TDeviceNode.Create(const AName: string);
begin
  inherited Create(AName, ntDevice);
  DeviceType := '';
  Power := 0.0;
  MountingHeight := 0.0;
  Device := nil;
end;

{ TSpaceHierarchyManager }

constructor TSpaceHierarchyManager.Create;
begin
  inherited Create;
  FTree := TSpaceTree.Create;
end;

destructor TSpaceHierarchyManager.Destroy;
begin
  ClearTree;
  FTree.Free;
  inherited Destroy;
end;

{**Очистить дерево и освободить память узлов}
{**Clear tree and free node memory}
procedure TSpaceHierarchyManager.ClearTree;
var
  Root: TSpaceTreeNode;
  Node: TSpaceNodeBase;
begin
  // Освобождаем данные узлов
  // Free node data
  for Root in FTree.Roots do
  begin
    if Root.Data <> nil then
    begin
      Node := Root.Data;
      Node.Free;
    end;
  end;

  // Очищаем дерево
  // Clear tree
  FTree.Clear;
end;

{**Рекурсивный поиск узла в дереве по имени и типу}
{**Recursive search for node in tree by name and type}
function TSpaceHierarchyManager.SearchNode(
  ANode: TSpaceTreeNode;
  const AName: string;
  ANodeType: TSpaceNodeType
): TSpaceTreeNode;
var
  Child: TSpaceTreeNode;
begin
  Result := nil;

  if ANode = nil then
    Exit;

  // Проверяем текущий узел
  // Check current node
  if (ANode.Data <> nil) and
     (ANode.Data.Name = AName) and
     (ANode.Data.NodeType = ANodeType) then
  begin
    Result := ANode;
    Exit;
  end;

  // Рекурсивно ищем в дочерних узлах
  // Recursively search in child nodes
  for Child in ANode.Children do
  begin
    Result := SearchNode(Child, AName, ANodeType);
    if Result <> nil then
      Exit;
  end;
end;

{**Найти узел по имени и типу в дереве}
{**Find node by name and type in tree}
function TSpaceHierarchyManager.FindNode(
  const AName: string;
  ANodeType: TSpaceNodeType
): TSpaceTreeNode;
var
  Root: TSpaceTreeNode;
begin
  Result := nil;

  // Ищем среди всех корневых узлов
  // Search among all root nodes
  for Root in FTree.Roots do
  begin
    Result := SearchNode(Root, AName, ANodeType);
    if Result <> nil then
      Exit;
  end;
end;

{**Добавить здание в иерархию как корневой узел}
{**Add building to hierarchy as root node}
function TSpaceHierarchyManager.AddBuilding(
  const AName: string;
  APolyline: PGDBObjPolyLine
): TSpaceTreeNode;
var
  BuildingData: TBuildingNode;
begin
  // Создаем узел здания
  // Create building node
  BuildingData := TBuildingNode.Create(AName);
  BuildingData.BuildingPolyline := APolyline;

  // Добавляем как корневой узел
  // Add as root node
  Result := FTree.Add(nil, BuildingData);
end;

{**Добавить блок-секцию к зданию}
{**Add section to building}
function TSpaceHierarchyManager.AddSection(
  const ABuildingName: string;
  const ASectionName: string;
  APolyline: PGDBObjPolyLine
): TSpaceTreeNode;
var
  ParentNode: TSpaceTreeNode;
  SectionData: TSectionNode;
begin
  Result := nil;

  // Находим родительский узел здания
  // Find parent building node
  ParentNode := FindNode(ABuildingName, ntBuilding);
  if ParentNode = nil then
    Exit;

  // Создаем узел секции
  // Create section node
  SectionData := TSectionNode.Create(ASectionName);
  SectionData.SectionPolyline := APolyline;

  // Добавляем к зданию
  // Add to building
  Result := FTree.Add(ParentNode, SectionData);
end;

{**Добавить этаж к секции или зданию}
{**Add floor to section or building}
function TSpaceHierarchyManager.AddFloor(
  const AParentName: string;
  const AFloorName: string;
  AFloorNumber: Integer;
  ACeilingHeight: Double;
  APolyline: PGDBObjPolyLine
): TSpaceTreeNode;
var
  ParentNode: TSpaceTreeNode;
  FloorData: TFloorNode;
begin
  Result := nil;

  // Пытаемся найти родителя-секцию
  // Try to find parent section
  ParentNode := FindNode(AParentName, ntSection);

  // Если не нашли секцию, ищем здание
  // If section not found, search for building
  if ParentNode = nil then
    ParentNode := FindNode(AParentName, ntBuilding);

  if ParentNode = nil then
    Exit;

  // Создаем узел этажа
  // Create floor node
  FloorData := TFloorNode.Create(AFloorName);
  FloorData.FloorNumber := AFloorNumber;
  FloorData.CeilingHeight := ACeilingHeight;
  FloorData.FloorPolyline := APolyline;

  // Добавляем к родителю
  // Add to parent
  Result := FTree.Add(ParentNode, FloorData);
end;

{**Добавить помещение к этажу}
{**Add room to floor}
function TSpaceHierarchyManager.AddRoom(
  const AFloorName: string;
  const ARoomName: string;
  const ARoomNumber: string;
  APolyline: PGDBObjPolyLine
): TSpaceTreeNode;
var
  ParentNode: TSpaceTreeNode;
  RoomData: TRoomNode;
begin
  Result := nil;

  // Находим родительский этаж
  // Find parent floor
  ParentNode := FindNode(AFloorName, ntFloor);
  if ParentNode = nil then
    Exit;

  // Создаем узел помещения
  // Create room node
  RoomData := TRoomNode.Create(ARoomName);
  RoomData.RoomNumber := ARoomNumber;
  RoomData.RoomPolyline := APolyline;

  // Добавляем к этажу
  // Add to floor
  Result := FTree.Add(ParentNode, RoomData);
end;

{**Добавить устройство к помещению}
{**Add device to room}
function TSpaceHierarchyManager.AddDevice(
  const ARoomName: string;
  const ADeviceName: string;
  ADevice: PGDBObjDevice
): TSpaceTreeNode;
var
  ParentNode: TSpaceTreeNode;
  DeviceData: TDeviceNode;
begin
  Result := nil;

  // Находим родительское помещение
  // Find parent room
  ParentNode := FindNode(ARoomName, ntRoom);
  if ParentNode = nil then
    Exit;

  // Создаем узел устройства
  // Create device node
  DeviceData := TDeviceNode.Create(ADeviceName);
  DeviceData.Device := ADevice;

  // Добавляем к помещению
  // Add to room
  Result := FTree.Add(ParentNode, DeviceData);
end;

{**Рекурсивная печать узла с отступами}
{**Recursive node printing with indentation}
procedure TSpaceHierarchyManager.PrintNode(
  ANode: TSpaceTreeNode;
  AIndent: Integer
);
var
  Child: TSpaceTreeNode;
  Base: TSpaceNodeBase;
  IndentStr: string;
begin
  if ANode = nil then
    Exit;

  Base := ANode.Data;
  if Base = nil then
    Exit;

  // Формируем строку отступа
  // Create indent string
  IndentStr := StringOfChar(' ', AIndent * 2);

  // Выводим информацию о узле в зависимости от типа
  // Output node information depending on type
  case Base.NodeType of
    ntBuilding:
      zcUI.TextMessage(IndentStr + '- ' + Base.Name + ' (Здание)', TMWOHistoryOut);
    ntSection:
      zcUI.TextMessage(IndentStr + '- ' + Base.Name + ' (Блок-секция №' +
        IntToStr((Base as TSectionNode).SectionNumber) + ')', TMWOHistoryOut);
    ntFloor:
      zcUI.TextMessage(IndentStr + '- ' + Base.Name + ' (Этаж ' +
        IntToStr((Base as TFloorNode).FloorNumber) + ', высота ' +
        FloatToStrF((Base as TFloorNode).CeilingHeight, ffFixed, 15, 1) +
        ' м)', TMWOHistoryOut);
    ntRoom:
      zcUI.TextMessage(IndentStr + '- ' + Base.Name + ' (Помещение №' +
        (Base as TRoomNode).RoomNumber + ')', TMWOHistoryOut);
    ntDevice:
      zcUI.TextMessage(IndentStr + '- ' + Base.Name + ' (Устройство)', TMWOHistoryOut);
  end;

  // Рекурсивно выводим дочерние узлы
  // Recursively output child nodes
  for Child in ANode.Children do
    PrintNode(Child, AIndent + 1);
end;

{**Вывести дерево в консоль}
{**Print tree to console}
procedure TSpaceHierarchyManager.PrintTree;
var
  Root: TSpaceTreeNode;
begin
  zcUI.TextMessage('=== Иерархия пространств / Space Hierarchy ===', TMWOHistoryOut);

  for Root in FTree.Roots do
    PrintNode(Root, 0);

  zcUI.TextMessage('=== Конец иерархии / End of Hierarchy ===', TMWOHistoryOut);
end;

{**Получить количество узлов в дереве}
{**Get node count in tree}
function TSpaceHierarchyManager.GetNodeCount: Integer;
begin
  Result := FTree.Count;
end;

{**Получить корневые узлы дерева}
{**Get root nodes of tree}
function TSpaceHierarchyManager.GetRoots: TGTreeNode<TSpaceNodeBase>.TChildren;
begin
  Result := FTree.Roots;
end;

end.
