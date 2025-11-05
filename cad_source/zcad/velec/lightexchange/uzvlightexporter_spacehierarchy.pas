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

{**Модуль формирования иерархической структуры пространств}
unit uzvlightexporter_spacehierarchy;

{$INCLUDE zengineconfig.inc}

interface
uses
  SysUtils,
  Classes,
  gtree,
  uzclog,
  uzvlightexporter_types,
  uzvlightexporter_utils;

{**Построить иерархическую структуру из собранных данных}
procedure BuildHierarchy(
  const CollectedData: TCollectedData;
  var HierarchyRoot: TLightHierarchyRoot
);

{**Назначить устройства к помещениям на основе координат}
procedure AssignDevicesToRooms(
  const CollectedData: TCollectedData;
  var HierarchyRoot: TLightHierarchyRoot
);

{**Очистить иерархию и освободить память}
procedure ClearHierarchy(var HierarchyRoot: TLightHierarchyRoot);

implementation

{**Найти узел в дереве по имени и типу}
function FindNodeByNameAndType(
  Tree: TSpaceTree;
  const NodeName: string;
  NodeType: TSpaceNodeType
): TSpaceTreeNode;
var
  Root: TSpaceTreeNode;

  function SearchInSubtree(Node: TSpaceTreeNode): TSpaceTreeNode;
  var
    Child: TSpaceTreeNode;
  begin
    Result := nil;

    if Node = nil then
      Exit;

    if (Node.Data <> nil) and
       (Node.Data.Name = NodeName) and
       (Node.Data.NodeType = NodeType) then
    begin
      Result := Node;
      Exit;
    end;

    for Child in Node.Children do
    begin
      Result := SearchInSubtree(Child);
      if Result <> nil then
        Exit;
    end;
  end;

begin
  Result := nil;

  for Root in Tree.Roots do
  begin
    Result := SearchInSubtree(Root);
    if Result <> nil then
      Exit;
  end;
end;

{**Установить связи между узлами на основе геометрии}
procedure EstablishGeometricRelations(
  SpacesList: TList;
  Tree: TSpaceTree
);
var
  i, j: Integer;
  CurrentNode: TSpaceNodeBase;
  OtherNode: TSpaceNodeBase;
  RoomNode: TRoomNode;
  FloorNode: TFloorNode;
  BuildingNode: TBuildingNode;
  SectionNode: TSectionNode;
  ParentTreeNode: TSpaceTreeNode;
  FloorParentFound: Boolean;
begin
  // Шаг 1: Добавляем здания как корневые узлы
  for i := 0 to SpacesList.Count - 1 do
  begin
    CurrentNode := TSpaceNodeBase(SpacesList[i]);

    if CurrentNode is TBuildingNode then
    begin
      BuildingNode := TBuildingNode(CurrentNode);
      Tree.Add(nil, BuildingNode);
      programlog.LogOutFormatStr(
        'Здание "%s" добавлено как корневой узел',
        [BuildingNode.Name],
        LM_Info
      );
    end;
  end;

  // Шаг 2: Добавляем секции как дочерние к зданиям или корневые узлы
  for i := 0 to SpacesList.Count - 1 do
  begin
    CurrentNode := TSpaceNodeBase(SpacesList[i]);

    if CurrentNode is TSectionNode then
    begin
      SectionNode := TSectionNode(CurrentNode);
      FloorParentFound := False;

      // Ищем родительское здание
      for j := 0 to SpacesList.Count - 1 do
      begin
        if i = j then
          Continue;

        OtherNode := TSpaceNodeBase(SpacesList[j]);

        if OtherNode is TBuildingNode then
        begin
          BuildingNode := TBuildingNode(OtherNode);
          if (SectionNode.SectionPolyline <> nil) and
             (BuildingNode.BuildingPolyline <> nil) and
             PolylineInsidePolyline(SectionNode.SectionPolyline, BuildingNode.BuildingPolyline) then
          begin
            ParentTreeNode := FindNodeByNameAndType(
              Tree,
              BuildingNode.Name,
              ntBuilding
            );
            if ParentTreeNode <> nil then
            begin
              Tree.Add(ParentTreeNode, SectionNode);
              programlog.LogOutFormatStr(
                'Секция "%s" добавлена к зданию "%s"',
                [SectionNode.Name, BuildingNode.Name],
                LM_Info
              );
              FloorParentFound := True;
              Break;
            end;
          end;
        end;
      end;

      // Если родитель не найден, добавляем как корневой узел
      if not FloorParentFound then
      begin
        Tree.Add(nil, SectionNode);
        programlog.LogOutFormatStr(
          'Секция "%s" добавлена как корневой узел',
          [SectionNode.Name],
          LM_Info
        );
      end;
    end;
  end;

  // Шаг 3: Добавляем этажи как дочерние к секциям или зданиям
  for i := 0 to SpacesList.Count - 1 do
  begin
    CurrentNode := TSpaceNodeBase(SpacesList[i]);

    if CurrentNode is TFloorNode then
    begin
      FloorNode := TFloorNode(CurrentNode);
      FloorParentFound := False;

      // Сначала ищем родительскую секцию
      for j := 0 to SpacesList.Count - 1 do
      begin
        if i = j then
          Continue;

        OtherNode := TSpaceNodeBase(SpacesList[j]);

        if OtherNode is TSectionNode then
        begin
          SectionNode := TSectionNode(OtherNode);
          if (FloorNode.FloorPolyline <> nil) and
             (SectionNode.SectionPolyline <> nil) and
             PolylineInsidePolyline(FloorNode.FloorPolyline, SectionNode.SectionPolyline) then
          begin
            ParentTreeNode := FindNodeByNameAndType(
              Tree,
              SectionNode.Name,
              ntSection
            );
            if ParentTreeNode <> nil then
            begin
              Tree.Add(ParentTreeNode, FloorNode);
              programlog.LogOutFormatStr(
                'Этаж "%s" добавлен к секции "%s"',
                [FloorNode.Name, SectionNode.Name],
                LM_Info
              );
              FloorParentFound := True;
              Break;
            end;
          end;
        end;
      end;

      // Если секция не найдена, ищем родительское здание
      if not FloorParentFound then
      begin
        for j := 0 to SpacesList.Count - 1 do
        begin
          if i = j then
            Continue;

          OtherNode := TSpaceNodeBase(SpacesList[j]);

          if OtherNode is TBuildingNode then
          begin
            BuildingNode := TBuildingNode(OtherNode);
            if (FloorNode.FloorPolyline <> nil) and
               (BuildingNode.BuildingPolyline <> nil) and
               PolylineInsidePolyline(FloorNode.FloorPolyline, BuildingNode.BuildingPolyline) then
            begin
              ParentTreeNode := FindNodeByNameAndType(
                Tree,
                BuildingNode.Name,
                ntBuilding
              );
              if ParentTreeNode <> nil then
              begin
                Tree.Add(ParentTreeNode, FloorNode);
                programlog.LogOutFormatStr(
                  'Этаж "%s" добавлен к зданию "%s"',
                  [FloorNode.Name, BuildingNode.Name],
                  LM_Info
                );
                FloorParentFound := True;
                Break;
              end;
            end;
          end;
        end;
      end;

      // Если родитель не найден, добавляем как корневой узел
      if not FloorParentFound then
      begin
        Tree.Add(nil, FloorNode);
        programlog.LogOutFormatStr(
          'Этаж "%s" добавлен как корневой узел',
          [FloorNode.Name],
          LM_Info
        );
      end;
    end;
  end;

  // Шаг 4: Добавляем помещения как дочерние к этажам
  for i := 0 to SpacesList.Count - 1 do
  begin
    CurrentNode := TSpaceNodeBase(SpacesList[i]);

    if CurrentNode is TRoomNode then
    begin
      RoomNode := TRoomNode(CurrentNode);

      for j := 0 to SpacesList.Count - 1 do
      begin
        if i = j then
          Continue;

        OtherNode := TSpaceNodeBase(SpacesList[j]);

        if OtherNode is TFloorNode then
        begin
          FloorNode := TFloorNode(OtherNode);
          if PolylineInsidePolyline(RoomNode.RoomPolyline, FloorNode.FloorPolyline) then
          begin
            ParentTreeNode := FindNodeByNameAndType(
              Tree,
              FloorNode.Name,
              ntFloor
            );
            if ParentTreeNode <> nil then
            begin
              Tree.Add(ParentTreeNode, RoomNode);
              programlog.LogOutFormatStr(
                'Помещение "%s" добавлено к этажу "%s"',
                [RoomNode.Name, FloorNode.Name],
                LM_Info
              );
              Break;
            end;
          end;
        end;
      end;
    end;
  end;
end;

{**Построить иерархическую структуру из собранных данных}
procedure BuildHierarchy(
  const CollectedData: TCollectedData;
  var HierarchyRoot: TLightHierarchyRoot
);
begin
  programlog.LogOutFormatStr(
    'Начато построение иерархии пространств',
    [],
    LM_Info
  );

  HierarchyRoot.Tree := TSpaceTree.Create;
  HierarchyRoot.ProjectName := 'STF Export';
  HierarchyRoot.ExportDate := FormatDateTime('yyyy-mm-dd', Now);

  EstablishGeometricRelations(CollectedData.SpacesList, HierarchyRoot.Tree);

  programlog.LogOutFormatStr(
    'Иерархия построена, узлов в дереве: %d',
    [HierarchyRoot.Tree.Count],
    LM_Info
  );
end;

{**Назначить устройства к помещениям на основе координат}
procedure AssignDevicesToRooms(
  const CollectedData: TCollectedData;
  var HierarchyRoot: TLightHierarchyRoot
);
var
  Root: TSpaceTreeNode;
  DeviceCount: Integer;

  procedure ProcessNode(Node: TSpaceTreeNode; Device: TDeviceNode);
  var
    Child: TSpaceTreeNode;
    RoomNode: TRoomNode;
  begin
    if Node = nil then
      Exit;

    if (Node.Data <> nil) and (Node.Data is TRoomNode) then
    begin
      RoomNode := TRoomNode(Node.Data);
      if PointInPolyline(Device.Position, RoomNode.RoomPolyline) then
      begin
        HierarchyRoot.Tree.Add(Node, Device);
        Inc(DeviceCount);
        programlog.LogOutFormatStr(
          'Устройство "%s" добавлено к помещению "%s"',
          [Device.Name, RoomNode.Name],
          LM_Info
        );
        Exit;
      end;
    end;

    for Child in Node.Children do
      ProcessNode(Child, Device);
  end;

var
  i: Integer;
  DeviceNode: TDeviceNode;
begin
  programlog.LogOutFormatStr(
    'Начато назначение устройств к помещениям',
    [],
    LM_Info
  );

  DeviceCount := 0;

  // Обрабатываем устройства из собранных данных
  if CollectedData.LuminairesList <> nil then
  begin
    for i := 0 to CollectedData.LuminairesList.Count - 1 do
    begin
      DeviceNode := TDeviceNode(CollectedData.LuminairesList[i]);

      for Root in HierarchyRoot.Tree.Roots do
        ProcessNode(Root, DeviceNode);
    end;
  end;

  programlog.LogOutFormatStr(
    'Назначение завершено, устройств назначено: %d',
    [DeviceCount],
    LM_Info
  );
end;

{**Очистить иерархию и освободить память}
procedure ClearHierarchy(var HierarchyRoot: TLightHierarchyRoot);
begin
  if HierarchyRoot.Tree <> nil then
  begin
    HierarchyRoot.Tree.Free;
    HierarchyRoot.Tree := nil;
  end;
end;

end.
