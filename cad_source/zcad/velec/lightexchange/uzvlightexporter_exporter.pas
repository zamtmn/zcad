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

{**Модуль универсального экспорта (STF и возможные будущие форматы)}
unit uzvlightexporter_exporter;

{$INCLUDE zengineconfig.inc}

interface
uses
  SysUtils,
  Classes,
  gtree,
  uzclog,
  uzegeometrytypes,
  uzvlightexporter_types,
  uzvlightexporter_utils;

{**Экспортировать иерархию в файл STF формата}
function ExportToSTF(
  const HierarchyRoot: TLightHierarchyRoot;
  const FileName: string
): Boolean;

implementation

type
  {**Вспомогательная структура для координат начала}
  TOriginCoordinates = record
    X: Double;
    Y: Double;
  end;

  {**Вспомогательная структура для параметров экспорта помещения}
  TRoomExportParams = record
    Origin: TOriginCoordinates;
    FloorScale: Double;
  end;

{**Рассчитать начало координат из минимальных значений этажей}
procedure CalculateOrigin(
  const HierarchyRoot: TLightHierarchyRoot;
  var Origin: TOriginCoordinates
);
var
  Root: TSpaceTreeNode;
  FloorNode: TFloorNode;
  i: Integer;
  Vertex: TzePoint3d;
  FirstVertex: Boolean;
begin
  Origin.X := 0.0;
  Origin.Y := 0.0;
  FirstVertex := True;

  for Root in HierarchyRoot.Tree.Root.Children do
  begin
    if (Root.Data <> nil) and (Root.Data is TFloorNode) then
    begin
      FloorNode := TFloorNode(Root.Data);
      if FloorNode.FloorPolyline <> nil then
      begin
        for i := 0 to FloorNode.FloorPolyline^.VertexArrayInOCS.Count - 1 do
        begin
          Vertex := FloorNode.FloorPolyline^.VertexArrayInOCS.getData(i);
          if FirstVertex then
          begin
            Origin.X := Vertex.x;
            Origin.Y := Vertex.y;
            FirstVertex := False;
          end
          else
          begin
            if Vertex.x < Origin.X then
              Origin.X := Vertex.x;
            if Vertex.y < Origin.Y then
              Origin.Y := Vertex.y;
          end;
        end;
      end;
    end;
  end;

  programlog.LogOutFormatStr(
    'Начало координат: (%.3f, %.3f)',
    [Origin.X, Origin.Y],
    LM_Debug
  );
end;

{**Записать заголовок STF файла}
procedure WriteSTFHeader(var STFFile: TextFile);
begin
  WriteLn(STFFile, '[VERSION]');
  WriteLn(STFFile, 'STFF=' + STF_VERSION);
  WriteLn(STFFile, 'Progname=' + STF_PROGRAM_NAME);
  WriteLn(STFFile, 'Progvers=' + STF_PROGRAM_VERSION);
end;

{**Подсчитать количество помещений в иерархии}
function CountRooms(const HierarchyRoot: TLightHierarchyRoot): Integer;
var
  Root: TSpaceTreeNode;

  function CountInSubtree(Node: TSpaceTreeNode): Integer;
  var
    Child: TSpaceTreeNode;
  begin
    Result := 0;

    if Node = nil then
      Exit;

    if (Node.Data <> nil) and (Node.Data is TRoomNode) then
      Result := 1;

    for Child in Node.Children do
      Result := Result + CountInSubtree(Child);
  end;

begin
  Result := 0;

  for Root in HierarchyRoot.Tree.Root.Children do
    Result := Result + CountInSubtree(Root);
end;

{**Записать секцию PROJECT}
procedure WriteSTFProject(
  var STFFile: TextFile;
  const HierarchyRoot: TLightHierarchyRoot;
  RoomCount: Integer
);
var
  i: Integer;
begin
  WriteLn(STFFile, '[PROJECT]');
  WriteLn(STFFile, 'Name=' + HierarchyRoot.ProjectName);
  WriteLn(STFFile, 'Date=' + HierarchyRoot.ExportDate);
  WriteLn(STFFile, 'Operator=' + STF_PROGRAM_NAME);
  WriteLn(STFFile, 'NrRooms=' + IntToStr(RoomCount));

  // Записываем ссылки на помещения для совместимости с DIALux EVO
  for i := 1 to RoomCount do
    WriteLn(STFFile, 'Room' + IntToStr(i) + '=ROOM.R' + IntToStr(i));
end;

{**Записать вершины полилинии помещения}
procedure WriteRoomPolyline(
  var STFFile: TextFile;
  RoomNode: TRoomNode;
  const ExportParams: TRoomExportParams
);
var
  i: Integer;
  Vertex: TzePoint3d;
  TransX, TransY: Double;
begin
  WriteLn(STFFile, 'NrPoints=' +
    IntToStr(RoomNode.RoomPolyline^.VertexArrayInOCS.Count));

  for i := 0 to RoomNode.RoomPolyline^.VertexArrayInOCS.Count - 1 do
  begin
    Vertex := RoomNode.RoomPolyline^.VertexArrayInOCS.getData(i);
    // Применяем масштаб этажа к координатам и смещение относительно начала
    TransX := TransformCoordinate(Vertex.x, ExportParams.Origin.X) *
      ExportParams.FloorScale;
    TransY := TransformCoordinate(Vertex.y, ExportParams.Origin.Y) *
      ExportParams.FloorScale;

    WriteLn(STFFile, 'Point' + IntToStr(i + 1) + '=' +
      FormatFloat('0.###', TransX) + ' ' +
      FormatFloat('0.###', TransY));
  end;
end;

{**Записать светильники помещения}
procedure WriteRoomLuminaires(
  var STFFile: TextFile;
  RoomTreeNode: TSpaceTreeNode;
  const ExportParams: TRoomExportParams
);
var
  Child: TSpaceTreeNode;
  DeviceNode: TDeviceNode;
  LumIndex: Integer;
  TransX, TransY: Double;
begin
  LumIndex := 0;

  for Child in RoomTreeNode.Children do
  begin
    if (Child.Data <> nil) and (Child.Data is TDeviceNode) then
    begin
      Inc(LumIndex);
      DeviceNode := TDeviceNode(Child.Data);

      WriteLn(STFFile, 'Lum' + IntToStr(LumIndex) + '=' +
        DeviceNode.DeviceType);

      // Применяем масштаб этажа к координатам светильников
      TransX := TransformCoordinate(DeviceNode.Position.x, ExportParams.Origin.X) *
        ExportParams.FloorScale;
      TransY := TransformCoordinate(DeviceNode.Position.y, ExportParams.Origin.Y) *
        ExportParams.FloorScale;

      WriteLn(STFFile, 'Lum' + IntToStr(LumIndex) + '.Pos=' +
        FormatFloat('0.###', TransX) + ' ' +
        FormatFloat('0.###', TransY) + ' ' +
        FormatFloat('0.###', DeviceNode.MountingHeight));

      WriteLn(STFFile, 'Lum' + IntToStr(LumIndex) + '.Rot=0 0 ' +
        FormatFloat('0.#', DeviceNode.Rotation));
    end;
  end;

  WriteLn(STFFile, 'NrLums=' + IntToStr(LumIndex));
end;

{**Записать одно помещение}
procedure WriteRoom(
  var STFFile: TextFile;
  RoomTreeNode: TSpaceTreeNode;
  RoomIndex: Integer;
  const ExportParams: TRoomExportParams
);
var
  RoomNode: TRoomNode;
  RoomHeight: Double;
begin
  if (RoomTreeNode = nil) or (RoomTreeNode.Data = nil) then
    Exit;

  if not (RoomTreeNode.Data is TRoomNode) then
    Exit;

  RoomNode := TRoomNode(RoomTreeNode.Data);
  RoomHeight := DEFAULT_ROOM_HEIGHT;

  WriteLn(STFFile, '[ROOM.R' + IntToStr(RoomIndex) + ']');
  WriteLn(STFFile, 'Name=' + RoomNode.Name);
  WriteLn(STFFile, 'Height=' + FormatFloat('0.0', RoomHeight));
  WriteLn(STFFile, 'WorkingPlane=' +
    FormatFloat('0.0', STF_WORKING_PLANE_HEIGHT));

  WriteRoomPolyline(STFFile, RoomNode, ExportParams);

  WriteLn(STFFile, 'R_Ceiling=' +
    FormatFloat('0.00', STF_CEILING_REFLECTANCE));

  WriteRoomLuminaires(STFFile, RoomTreeNode, ExportParams);

  WriteLn(STFFile, 'NrStruct=0');
  WriteLn(STFFile, 'NrFurns=0');
end;

{**Записать все помещения из иерархии}
procedure WriteAllRooms(
  var STFFile: TextFile;
  const HierarchyRoot: TLightHierarchyRoot;
  const Origin: TOriginCoordinates;
  var RoomIndex: Integer
);
var
  Root: TSpaceTreeNode;

  {**Рекурсивно обработать узлы, сохраняя масштаб текущего этажа}
  procedure ProcessNode(Node: TSpaceTreeNode; CurrentFloorScale: Double);
  var
    Child: TSpaceTreeNode;
    ExportParams: TRoomExportParams;
    NewScale: Double;
    FloorNode: TFloorNode;
  begin
    if Node = nil then
      Exit;

    NewScale := CurrentFloorScale;

    // Если узел является этажом, обновляем масштаб для вложенных помещений
    if (Node.Data <> nil) and (Node.Data is TFloorNode) then
    begin
      FloorNode := TFloorNode(Node.Data);
      NewScale := FloorNode.FloorScale;
      programlog.LogOutFormatStr(
        'Этаж "%s": применяется масштаб %.3f',
        [FloorNode.Name, NewScale],
        LM_Debug
      );
    end;

    // Если узел является помещением, экспортируем его с текущим масштабом
    if (Node.Data <> nil) and (Node.Data is TRoomNode) then
    begin
      Inc(RoomIndex);
      ExportParams.Origin := Origin;
      ExportParams.FloorScale := NewScale;
      WriteRoom(STFFile, Node, RoomIndex, ExportParams);
    end;

    // Рекурсивно обрабатываем дочерние узлы с актуальным масштабом
    for Child in Node.Children do
      ProcessNode(Child, NewScale);
  end;

begin
  RoomIndex := 0;

  for Root in HierarchyRoot.Tree.Root.Children do
    ProcessNode(Root, DEFAULT_FLOOR_SCALE);
end;

{**Собрать уникальные типы светильников}
procedure CollectLuminaireTypes(
  const HierarchyRoot: TLightHierarchyRoot;
  LumTypes: TStringList
);
var
  Root: TSpaceTreeNode;

  procedure ProcessNode(Node: TSpaceTreeNode);
  var
    Child: TSpaceTreeNode;
    DeviceNode: TDeviceNode;
  begin
    if Node = nil then
      Exit;

    if (Node.Data <> nil) and (Node.Data is TDeviceNode) then
    begin
      DeviceNode := TDeviceNode(Node.Data);
      if LumTypes.IndexOf(DeviceNode.DeviceType) < 0 then
        LumTypes.Add(DeviceNode.DeviceType);
    end;

    for Child in Node.Children do
      ProcessNode(Child);
  end;

begin
  LumTypes.Clear;

  for Root in HierarchyRoot.Tree.Root.Children do
    ProcessNode(Root);
end;

{**Записать определения типов светильников}
procedure WriteLuminaireTypes(
  var STFFile: TextFile;
  LumTypes: TStringList
);
var
  i: Integer;
  LumTypeName: string;
begin
  for i := 0 to LumTypes.Count - 1 do
  begin
    LumTypeName := LumTypes[i];

    WriteLn(STFFile, '[' + LumTypeName + ']');
    WriteLn(STFFile, 'Manufacturer=');
    WriteLn(STFFile, 'Name=');
    WriteLn(STFFile, 'OrderNr=');
    WriteLn(STFFile, 'Box=1 1 0');
    WriteLn(STFFile, 'Shape=' + IntToStr(STF_LUMINAIRE_SHAPE));
    WriteLn(STFFile, 'Load=' + IntToStr(Round(DEFAULT_LUMINAIRE_POWER)));
    WriteLn(STFFile, 'Flux=' + IntToStr(STF_LUMINAIRE_DEFAULT_FLUX));
    WriteLn(STFFile, 'NrLamps=' + IntToStr(DEFAULT_LAMPS_COUNT));
    WriteLn(STFFile, 'MountingType=' +
      IntToStr(STF_LUMINAIRE_MOUNTING_TYPE));
  end;
end;

{**Экспортировать иерархию в файл STF формата}
function ExportToSTF(
  const HierarchyRoot: TLightHierarchyRoot;
  const FileName: string
): Boolean;
var
  STFFile: TextFile;
  Origin: TOriginCoordinates;
  RoomCount: Integer;
  RoomIndex: Integer;
  LumTypes: TStringList;
begin
  Result := False;

  programlog.LogOutFormatStr(
    'Начат экспорт в STF: %s',
    [FileName],
    LM_Info
  );

  try
    RoomCount := CountRooms(HierarchyRoot);

    if RoomCount = 0 then
    begin
      programlog.LogOutFormatStr(
        'Нет помещений для экспорта',
        [],
        LM_Warning
      );
      Exit;
    end;

    CalculateOrigin(HierarchyRoot, Origin);

    LumTypes := TStringList.Create;
    try
      CollectLuminaireTypes(HierarchyRoot, LumTypes);

      AssignFile(STFFile, FileName);
      SetTextCodePage(STFFile, 1251);
      Rewrite(STFFile);

      try
        WriteSTFHeader(STFFile);
        WriteSTFProject(STFFile, HierarchyRoot, RoomCount);
        WriteAllRooms(STFFile, HierarchyRoot, Origin, RoomIndex);
        WriteLuminaireTypes(STFFile, LumTypes);

        Result := True;

        programlog.LogOutFormatStr(
          'Экспорт завершен: помещений=%d, типов светильников=%d',
          [RoomCount, LumTypes.Count],
          LM_Info
        );
      finally
        CloseFile(STFFile);
      end;
    finally
      LumTypes.Free;
    end;

  except
    on E: Exception do
    begin
      programlog.LogOutFormatStr(
        'Ошибка экспорта: %s',
        [E.Message],
        LM_Error
      );
      Result := False;
    end;
  end;
end;

end.
