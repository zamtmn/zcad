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
procedure AssignDevicesToRooms(var HierarchyRoot: TLightHierarchyRoot);

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

  for Root in Tree.Root.Children do
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
  ParentTreeNode: TSpaceTreeNode;
  RoomTreeNode: TSpaceTreeNode;
begin
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
              RoomTreeNode := TSpaceTreeNode.Create(RoomNode);
              ParentTreeNode.Children.PushBack(RoomTreeNode);
              programlog.LogOutFormatStr(
                'Помещение "%s" добавлено к этажу "%s"',
                [RoomNode.Name, FloorNode.Name],
                LM_Debug
              );
              Break;
            end;
          end;
        end;
      end;
    end
    else if CurrentNode is TFloorNode then
    begin
      FloorNode := TFloorNode(CurrentNode);
        // если корня ещё нет — присваиваем Root
      //if Tree.Root = nil then
        Tree.Root := TSpaceTreeNode.Create(FloorNode);
      //else
      //  // если уже есть Root и хочешь несколько "корней",
      //  // то добавляем в Children текущего Root
      //  begin
      //
      //    Tree.Root.Children.PushBack(FloorTreeNode);
      //
      //  end;
      //Tree.Add(nil, FloorNode);
      programlog.LogOutFormatStr(
        'Этаж "%s" добавлен как корневой',
        [FloorNode.Name],
        LM_Debug
      );
    end;
  end;
end;

{**Построить иерархическую структуру из собранных данных}
procedure BuildHierarchy(
  const CollectedData: TCollectedData;
  var HierarchyRoot: TLightHierarchyRoot
);
var
  i: Integer;
  NodeBase: TSpaceNodeBase;
  BuildingNode: TBuildingNode;
begin
  programlog.LogOutFormatStr(
    'Начато построение иерархии пространств',
    [],
    LM_Info
  );

  HierarchyRoot.Tree := TSpaceTree.Create;
  HierarchyRoot.ProjectName := 'STF Export';
  HierarchyRoot.ExportDate := FormatDateTime('yyyy-mm-dd', Now);

  for i := 0 to CollectedData.SpacesList.Count - 1 do
  begin
    NodeBase := TSpaceNodeBase(CollectedData.SpacesList[i]);

    if NodeBase is TBuildingNode then
    begin
      BuildingNode := TBuildingNode(NodeBase);
      HierarchyRoot.Tree.Root := TSpaceTreeNode.Create(BuildingNode);
      //HierarchyRoot.Tree.Add(nil, BuildingNode);
      programlog.LogOutFormatStr(
        'Здание "%s" добавлено как корневой узел',
        [BuildingNode.Name],
        LM_Debug
      );
    end;
  end;

  EstablishGeometricRelations(CollectedData.SpacesList, HierarchyRoot.Tree);

  programlog.LogOutFormatStr(
    'Иерархия построена, узлов в дереве: %d',
    [HierarchyRoot.Tree.Root.Children.Size],
    LM_Info
  );
end;

{**Назначить устройства к помещениям на основе координат}
procedure AssignDevicesToRooms(var HierarchyRoot: TLightHierarchyRoot);
var
  Root: TSpaceTreeNode;
  DeviceCount: Integer;

  procedure ProcessNode(Node: TSpaceTreeNode; Device: TDeviceNode);
  var
    Child: TSpaceTreeNode;
    RoomNode: TRoomNode;
    DeviceTreeNode: TSpaceTreeNode;
  begin
    if Node = nil then
      Exit;

    if (Node.Data <> nil) and (Node.Data is TRoomNode) then
    begin
      RoomNode := TRoomNode(Node.Data);
      if PointInPolyline(Device.Position, RoomNode.RoomPolyline) then
      begin
        DeviceTreeNode := TSpaceTreeNode.Create(Device); // TRoomNode -> TTreeNode<T>
        Node.Children.PushBack(DeviceTreeNode);           // добавляем в Children
        Inc(DeviceCount);
        programlog.LogOutFormatStr(
          'Устройство "%s" добавлено к помещению "%s"',
          [Device.Name, RoomNode.Name],
          LM_Debug
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
  DummyList: TList;
begin
  programlog.LogOutFormatStr(
    'Начато назначение устройств к помещениям',
    [],
    LM_Info
  );

  DeviceCount := 0;
  DummyList := TList.Create;
  try
    for i := 0 to HierarchyRoot.Tree.Root.Children.Size - 1 do
    begin
      if HierarchyRoot.Tree.Items[i].Data is TDeviceNode then
        DummyList.Add(HierarchyRoot.Tree.Items[i].Data);
    end;

    for i := 0 to DummyList.Count - 1 do
    begin
      DeviceNode := TDeviceNode(DummyList[i]);

      for Root in HierarchyRoot.Tree.Roots do
        ProcessNode(Root, DeviceNode);
    end;
  finally
    DummyList.Free;
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
