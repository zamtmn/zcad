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

{**Модуль вывода информации о структуре пространств и светильников}
unit uzvlightexporter_printer;

{$INCLUDE zengineconfig.inc}

interface
uses
  SysUtils,
  uzvlightexporter_types,
  uzcinterface;

{**Вывести информацию о структуре пространств в командную строку}
procedure PrintSpaceStructure(const HierarchyRoot: TLightHierarchyRoot);

{**Вывести информацию об именах светильников в командную строку}
procedure PrintLuminaireNames(const HierarchyRoot: TLightHierarchyRoot);

{**Вывести полную информацию о структуре и светильниках}
procedure PrintFullHierarchyInfo(const HierarchyRoot: TLightHierarchyRoot);

implementation

const
  // Константы для форматирования отступов
  INDENT_STEP = 2;
  MAX_LINE_LENGTH = 80;

{**Получить строку с отступом заданного уровня}
function GetIndent(Level: Integer): string;
var
  SpacesCount: Integer;
begin
  SpacesCount := Level * INDENT_STEP;
  Result := StringOfChar(' ', SpacesCount);
end;

{**Получить строковое представление типа узла}
function GetNodeTypeString(NodeType: TSpaceNodeType): string;
begin
  case NodeType of
    ntBuilding: Result := 'Здание';
    ntSection: Result := 'Секция';
    ntFloor: Result := 'Этаж';
    ntRoom: Result := 'Помещение';
    ntDevice: Result := 'Светильник';
  else
    Result := 'Неизвестный тип';
  end;
end;

{**Вывести информацию об узле здания}
procedure PrintBuildingNode(
  const Node: TBuildingNode;
  Level: Integer
);
var
  Indent: string;
  DisplayName: string;
begin
  Indent := GetIndent(Level);

  // Защита от пустого имени здания
  if Node.Name = '' then
    DisplayName := '<имя не задано>'
  else
    DisplayName := Node.Name;

  zcUI.TextMessage(
    Indent + '└─ Здание: ' + DisplayName,
    TMWOHistoryOut
  );

  if Node.Address <> '' then
  begin
    zcUI.TextMessage(
      Indent + '   Адрес: ' + Node.Address,
      TMWOHistoryOut
    );
  end;

  if Node.YearBuilt > 0 then
  begin
    zcUI.TextMessage(
      Indent + '   Год постройки: ' + IntToStr(Node.YearBuilt),
      TMWOHistoryOut
    );
  end;
end;

{**Вывести информацию об узле секции}
procedure PrintSectionNode(
  const Node: TSectionNode;
  Level: Integer
);
var
  Indent: string;
begin
  Indent := GetIndent(Level);
  zcUI.TextMessage(
    Indent + '└─ Секция: ' + Node.Name,
    TMWOHistoryOut
  );

  if Node.SectionNumber > 0 then
  begin
    zcUI.TextMessage(
      Indent + '   Номер секции: ' + IntToStr(Node.SectionNumber),
      TMWOHistoryOut
    );
  end;
end;

{**Вывести информацию об узле этажа}
procedure PrintFloorNode(
  const Node: TFloorNode;
  Level: Integer
);
var
  Indent: string;
  DisplayName: string;
begin
  Indent := GetIndent(Level);

  // Защита от пустого имени этажа
  if Node.Name = '' then
    DisplayName := '<имя не задано>'
  else
    DisplayName := Node.Name;

  zcUI.TextMessage(
    Indent + '└─ Этаж: ' + DisplayName,
    TMWOHistoryOut
  );

  if Node.FloorNumber <> 0 then
  begin
    zcUI.TextMessage(
      Indent + '   Номер этажа: ' + IntToStr(Node.FloorNumber),
      TMWOHistoryOut
    );
  end;

  if Node.CeilingHeight > 0 then
  begin
    zcUI.TextMessage(
      Indent + '   Высота потолка: ' + FormatFloat('0.00', Node.CeilingHeight) + ' м',
      TMWOHistoryOut
    );
  end;

  if Node.Elevation <> 0 then
  begin
    zcUI.TextMessage(
      Indent + '   Отметка: ' + FormatFloat('0.00', Node.Elevation) + ' м',
      TMWOHistoryOut
    );
  end;
end;

{**Вывести информацию об узле помещения}
procedure PrintRoomNode(
  const Node: TRoomNode;
  Level: Integer
);
var
  Indent: string;
  DisplayName: string;
begin
  Indent := GetIndent(Level);

  // Защита от пустого имени помещения
  if Node.Name = '' then
    DisplayName := '<имя не задано>'
  else
    DisplayName := Node.Name;

  zcUI.TextMessage(
    Indent + '└─ Помещение: ' + DisplayName,
    TMWOHistoryOut
  );

  if Node.RoomNumber <> '' then
  begin
    zcUI.TextMessage(
      Indent + '   Номер помещения: ' + Node.RoomNumber,
      TMWOHistoryOut
    );
  end;

  if Node.Area > 0 then
  begin
    zcUI.TextMessage(
      Indent + '   Площадь: ' + FormatFloat('0.00', Node.Area) + ' м²',
      TMWOHistoryOut
    );
  end;

  if Node.Usage <> '' then
  begin
    zcUI.TextMessage(
      Indent + '   Назначение: ' + Node.Usage,
      TMWOHistoryOut
    );
  end;
end;

{**Вывести информацию об узле светильника}
procedure PrintDeviceNode(
  const Node: TDeviceNode;
  Level: Integer
);
var
  Indent: string;
begin
  Indent := GetIndent(Level);
  zcUI.TextMessage(
    Indent + '└─ Светильник: ' + Node.Name,
    TMWOHistoryOut
  );

  if Node.DeviceType <> '' then
  begin
    zcUI.TextMessage(
      Indent + '   Тип: ' + Node.DeviceType,
      TMWOHistoryOut
    );
  end;

  if Node.Power > 0 then
  begin
    zcUI.TextMessage(
      Indent + '   Мощность: ' + FormatFloat('0.0', Node.Power) + ' Вт',
      TMWOHistoryOut
    );
  end;

  if Node.MountingHeight > 0 then
  begin
    zcUI.TextMessage(
      Indent + '   Высота монтажа: ' + FormatFloat('0.00', Node.MountingHeight) + ' м',
      TMWOHistoryOut
    );
  end;

  if Node.NrLamps > 0 then
  begin
    zcUI.TextMessage(
      Indent + '   Количество ламп: ' + IntToStr(Node.NrLamps),
      TMWOHistoryOut
    );
  end;

  zcUI.TextMessage(
    Indent + '   Позиция: (' +
    FormatFloat('0.00', Node.Position.x) + ', ' +
    FormatFloat('0.00', Node.Position.y) + ', ' +
    FormatFloat('0.00', Node.Position.z) + ')',
    TMWOHistoryOut
  );
end;

{**Вывести информацию об узле в зависимости от его типа}
procedure PrintNodeInfo(
  Node: TSpaceNodeBase;
  Level: Integer
);
begin
  // Проверка на nil
  if Node = nil then
    Exit;

  // Используем поле NodeType вместо оператора is для определения типа узла
  // Это безопаснее, так как не требует обращения к VMT (Virtual Method Table)
  // и защищает от Access Violation при работе с поврежденными объектами
  try
    case Node.NodeType of
      ntBuilding:
        PrintBuildingNode(TBuildingNode(Node), Level);
      ntSection:
        PrintSectionNode(TSectionNode(Node), Level);
      ntFloor:
        PrintFloorNode(TFloorNode(Node), Level);
      ntRoom:
        PrintRoomNode(TRoomNode(Node), Level);
      ntDevice:
        PrintDeviceNode(TDeviceNode(Node), Level);
    end;
  except
    // Защита от обращения к уже освобожденному или поврежденному объекту
    // Если возникает исключение, просто выходим из процедуры
    Exit;
  end;
end;

{**Рекурсивно обойти дерево и вывести информацию о всех узлах}
procedure TraverseAndPrintTree(
  Node: TSpaceTreeNode;
  Level: Integer
);
var
  Child: TSpaceTreeNode;
begin
  if Node = nil then
    Exit;

  if Node.Data <> nil then
    PrintNodeInfo(Node.Data, Level);

  for Child in Node.Children do
    TraverseAndPrintTree(Child, Level + 1);
end;

{**Подсчитать количество светильников в иерархии}
function CountLuminaires(const HierarchyRoot: TLightHierarchyRoot): Integer;
var
  Count: Integer;

  procedure CountInNode(Node: TSpaceTreeNode);
  var
    Child: TSpaceTreeNode;
  begin
    if Node = nil then
      Exit;

    // Проверка валидности Node.Data и подсчет светильников
    // Используем поле NodeType для безопасной проверки типа
    if Node.Data <> nil then
    begin
      try
        if Node.Data.NodeType = ntDevice then
          Inc(Count);
      except
        // Объект поврежден, пропускаем его
      end;
    end;

    for Child in Node.Children do
      CountInNode(Child);
  end;

var
  Root: TSpaceTreeNode;
begin
  Count := 0;

  if (HierarchyRoot.Tree <> nil) and (HierarchyRoot.Tree.Root <> nil) then
  begin
    for Root in HierarchyRoot.Tree.Root.Children do
      CountInNode(Root);
  end;

  Result := Count;
end;

{**Вывести список всех светильников}
procedure PrintLuminairesList(const HierarchyRoot: TLightHierarchyRoot);
var
  LuminaireNumber: Integer;

  procedure PrintLuminairesInNode(Node: TSpaceTreeNode);
  var
    Child: TSpaceTreeNode;
    DeviceNode: TDeviceNode;
  begin
    if Node = nil then
      Exit;

    // Проверка валидности Node.Data и вывод информации о светильнике
    // Используем поле NodeType для безопасной проверки типа
    if Node.Data <> nil then
    begin
      try
        if Node.Data.NodeType = ntDevice then
        begin
          DeviceNode := TDeviceNode(Node.Data);
          Inc(LuminaireNumber);

          zcUI.TextMessage(
            IntToStr(LuminaireNumber) + '. ' + DeviceNode.Name +
            ' (Тип: ' + DeviceNode.DeviceType + ')',
            TMWOHistoryOut
          );
        end;
      except
        // Объект поврежден, пропускаем его
      end;
    end;

    for Child in Node.Children do
      PrintLuminairesInNode(Child);
  end;

var
  Root: TSpaceTreeNode;
begin
  LuminaireNumber := 0;

  if (HierarchyRoot.Tree <> nil) and (HierarchyRoot.Tree.Root <> nil) then
  begin
    for Root in HierarchyRoot.Tree.Root.Children do
      PrintLuminairesInNode(Root);
  end;
end;

{**Вывести разделитель в командную строку}
procedure PrintSeparator;
begin
  zcUI.TextMessage(
    StringOfChar('-', MAX_LINE_LENGTH),
    TMWOHistoryOut
  );
end;

{**Вывести информацию о структуре пространств в командную строку}
procedure PrintSpaceStructure(const HierarchyRoot: TLightHierarchyRoot);
var
  Root: TSpaceTreeNode;
begin
  PrintSeparator;
  zcUI.TextMessage(
    'СТРУКТУРА ПРОСТРАНСТВ',
    TMWOHistoryOut
  );
  PrintSeparator;

  if HierarchyRoot.Tree = nil then
  begin
    zcUI.TextMessage(
      'Иерархия не инициализирована',
      TMWOHistoryOut
    );
    Exit;
  end;

  if HierarchyRoot.Tree.Root = nil then
  begin
    zcUI.TextMessage(
      'Корневой узел не найден',
      TMWOHistoryOut
    );
    Exit;
  end;

  if HierarchyRoot.Tree.Root.Children.Size = 0 then
  begin
    zcUI.TextMessage(
      'Структура пространств пуста',
      TMWOHistoryOut
    );
    Exit;
  end;

  zcUI.TextMessage(
    'Проект: ' + HierarchyRoot.ProjectName,
    TMWOHistoryOut
  );
  zcUI.TextMessage(
    'Дата экспорта: ' + HierarchyRoot.ExportDate,
    TMWOHistoryOut
  );
  zcUI.TextMessage('', TMWOHistoryOut);

  for Root in HierarchyRoot.Tree.Root.Children do
    TraverseAndPrintTree(Root, 0);

  PrintSeparator;
end;

{**Вывести информацию об именах светильников в командную строку}
procedure PrintLuminaireNames(const HierarchyRoot: TLightHierarchyRoot);
var
  LuminaireCount: Integer;
begin
  PrintSeparator;
  zcUI.TextMessage(
    'СПИСОК СВЕТИЛЬНИКОВ',
    TMWOHistoryOut
  );
  PrintSeparator;

  if HierarchyRoot.Tree = nil then
  begin
    zcUI.TextMessage(
      'Иерархия не инициализирована',
      TMWOHistoryOut
    );
    Exit;
  end;

  LuminaireCount := CountLuminaires(HierarchyRoot);

  if LuminaireCount = 0 then
  begin
    zcUI.TextMessage(
      'Светильники не найдены',
      TMWOHistoryOut
    );
    Exit;
  end;

  zcUI.TextMessage(
    'Всего светильников: ' + IntToStr(LuminaireCount),
    TMWOHistoryOut
  );
  zcUI.TextMessage('', TMWOHistoryOut);

  PrintLuminairesList(HierarchyRoot);

  PrintSeparator;
end;

{**Вывести полную информацию о структуре и светильниках}
procedure PrintFullHierarchyInfo(const HierarchyRoot: TLightHierarchyRoot);
begin
  PrintSpaceStructure(HierarchyRoot);
  zcUI.TextMessage('', TMWOHistoryOut);
  PrintLuminaireNames(HierarchyRoot);
end;

end.
