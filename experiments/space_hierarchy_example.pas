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

{**Пример использования иерархической структуры пространств}
{**Example of using hierarchical space structure}
program space_hierarchy_example;

uses
  SysUtils,
  uzvspacehierarchy;

{**Процедура добавления тестовой структуры зданий}
{**Procedure to add test building structure}
procedure AddBuildingStructure(Manager: TSpaceHierarchyManager);
var
  Building: TSpaceTreeNode;
  Section: TSpaceTreeNode;
  Floor: TSpaceTreeNode;
  Room: TSpaceTreeNode;
  i, j, k: Integer;
begin
  // Добавляем здание
  // Add building
  Building := Manager.AddBuilding('Здание 1', nil);
  if Building = nil then
  begin
    WriteLn('Ошибка: не удалось создать здание');
    Exit;
  end;

  // Добавляем блок-секции
  // Add sections
  for i := 1 to 2 do
  begin
    Section := Manager.AddSection(
      'Здание 1',
      Format('Блок-секция %d', [i]),
      nil
    );

    if Section = nil then
    begin
      WriteLn('Ошибка: не удалось создать секцию ', i);
      Continue;
    end;

    // Добавляем этажи к секции
    // Add floors to section
    for j := 1 to 3 do
    begin
      Floor := Manager.AddFloor(
        Format('Блок-секция %d', [i]),
        Format('Этаж %d', [j]),
        j,
        2.7,
        nil
      );

      if Floor = nil then
      begin
        WriteLn('Ошибка: не удалось создать этаж ', j);
        Continue;
      end;

      // Добавляем помещения к этажу
      // Add rooms to floor
      for k := 1 to 4 do
      begin
        Room := Manager.AddRoom(
          Format('Этаж %d', [j]),
          Format('Помещение %d.%d.%d', [i, j, k]),
          Format('%d.%d.%d', [i, j, k]),
          nil
        );

        if Room <> nil then
        begin
          // Устанавливаем дополнительные параметры помещения
          // Set additional room parameters
          with TRoomNode(Room.Data) do
          begin
            Area := 25.0 + k;
            Usage := 'Офис';
          end;
        end;
      end;
    end;
  end;
end;

{**Процедура демонстрации работы с иерархией без секций}
{**Procedure demonstrating hierarchy without sections}
procedure AddSimpleStructure(Manager: TSpaceHierarchyManager);
var
  Building: TSpaceTreeNode;
  Floor: TSpaceTreeNode;
  Room: TSpaceTreeNode;
  i, j: Integer;
begin
  // Добавляем здание
  // Add building
  Building := Manager.AddBuilding('Здание 2', nil);
  if Building = nil then
  begin
    WriteLn('Ошибка: не удалось создать здание 2');
    Exit;
  end;

  // Добавляем этажи напрямую к зданию (без секций)
  // Add floors directly to building (without sections)
  for i := 1 to 2 do
  begin
    Floor := Manager.AddFloor(
      'Здание 2',
      Format('Этаж %d', [i]),
      i,
      3.0,
      nil
    );

    if Floor = nil then
    begin
      WriteLn('Ошибка: не удалось создать этаж ', i);
      Continue;
    end;

    // Добавляем помещения
    // Add rooms
    for j := 1 to 3 do
    begin
      Room := Manager.AddRoom(
        Format('Этаж %d', [i]),
        Format('Помещение %d.%d', [i, j]),
        Format('%d.%d', [i, j]),
        nil
      );

      if Room <> nil then
      begin
        with TRoomNode(Room.Data) do
        begin
          Area := 30.0 + j;
          Usage := 'Кабинет';
        end;
      end;
    end;
  end;
end;

var
  Manager: TSpaceHierarchyManager;
begin
  WriteLn('=== Пример использования иерархической структуры пространств ===');
  WriteLn('=== Example of hierarchical space structure usage ===');
  WriteLn;

  // Создаем менеджер иерархии
  // Create hierarchy manager
  Manager := TSpaceHierarchyManager.Create;
  try
    // Добавляем структуру с секциями
    // Add structure with sections
    WriteLn('Добавление структуры со секциями...');
    WriteLn('Adding structure with sections...');
    AddBuildingStructure(Manager);
    WriteLn;

    // Добавляем простую структуру без секций
    // Add simple structure without sections
    WriteLn('Добавление простой структуры...');
    WriteLn('Adding simple structure...');
    AddSimpleStructure(Manager);
    WriteLn;

    // Выводим статистику
    // Output statistics
    WriteLn('Всего узлов в дереве / Total nodes in tree: ',
            Manager.GetNodeCount);
    WriteLn;

    // Выводим дерево
    // Print tree
    Manager.PrintTree;

  finally
    Manager.Free;
  end;

  WriteLn;
  WriteLn('=== Пример завершен / Example completed ===');
end.
