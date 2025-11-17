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

{**Модуль формы управления подключениями устройств}
unit uzvconnect_form;

{$INCLUDE zengineconfig.inc}

interface
uses
  Classes,
  SysUtils,
  Forms,
  Controls,
  ExtCtrls,
  ComCtrls,
  ActnList,
  Dialogs,
  laz.VirtualTrees,
  uzvconnect_struct,
  uzvconnect_logic,
  uzvconnect_dwginteraction,
  uzeentdevice,
  uzvconsts;

type
  {**Данные узла дерева подключений}
  PConnectNodeData = ^TConnectNodeData;
  TConnectNodeData = record
    ConnectIndex: Integer;  // Индекс в списке ConnectList
  end;

  {**Форма управления подключениями устройств}
  TfrmConnectControl = class(TForm)
    ActionList1: TActionList;
    actButton1: TAction;
    actButton2: TAction;
    actButton3: TAction;
    actButton4: TAction;
    TopPanel: TPanel;
    MainPanel: TPanel;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    vstConnections: TLazVirtualStringTree;

    {**Обработчик создания формы}
    procedure FormCreate(Sender: TObject);

    {**Обработчик уничтожения формы}
    procedure FormDestroy(Sender: TObject);

    {**Обработчик нажатия кнопки 1}
    procedure actButton1Execute(Sender: TObject);

    {**Обработчик нажатия кнопки 2}
    procedure actButton2Execute(Sender: TObject);

    {**Обработчик нажатия кнопки 3}
    procedure actButton3Execute(Sender: TObject);

    {**Обработчик нажатия кнопки 4}
    procedure actButton4Execute(Sender: TObject);

    {**Обработчик получения текста для ячейки дерева}
    procedure vstConnectionsGetText(
      Sender: TBaseVirtualTree;
      Node: PVirtualNode;
      Column: TColumnIndex;
      TextType: TVSTTextType;
      var CellText: string
    );

    {**Обработчик начала редактирования ячейки}
    procedure vstConnectionsEditing(
      Sender: TBaseVirtualTree;
      Node: PVirtualNode;
      Column: TColumnIndex;
      var Allowed: Boolean
    );

    {**Обработчик изменения текста в ячейке}
    procedure vstConnectionsNewText(
      Sender: TBaseVirtualTree;
      Node: PVirtualNode;
      Column: TColumnIndex;
      const NewText: string
    );

  private
    {**Инициализировать дерево подключений}
    procedure InitializeTree;

    {**Добавить новое подключение к выбранному устройству}
    procedure AddNewConnection;

    {**Обновить дерево с сохранением позиций устройств
       @param APreviousDeviceIndex - индекс устройства, к которому добавлено подключение}
    procedure UpdateTreePreservingPositions(APreviousDeviceIndex: Integer);

    {**Установить значение выделенной ячейки для всех ячеек ниже в том же столбце}
    procedure SetValueToAllBelow;

    {**Установить значение с инкрементом +1 для всех ячеек ниже в том же столбце}
    procedure SetValueWithIncrement;

  public
    {**Загрузить данные из списка подключений}
    procedure LoadConnectionsData;
  end;

var
  frmConnectControl: TfrmConnectControl;

implementation

{$R *.lfm}

{**Обработчик создания формы}
procedure TfrmConnectControl.FormCreate(Sender: TObject);
begin
  InitializeTree;
end;

{**Обработчик уничтожения формы}
procedure TfrmConnectControl.FormDestroy(Sender: TObject);
begin
  // Очистка ресурсов при необходимости
end;

{**Инициализировать дерево подключений}
procedure TfrmConnectControl.InitializeTree;
begin
  // Настройка дерева
  vstConnections.NodeDataSize := SizeOf(TConnectNodeData);

  // Очистка существующих колонок
  vstConnections.Header.Columns.Clear;

  // Создание колонок
  with vstConnections.Header.Columns.Add do
  begin
    Position := 0;
    Text := 'Имя устройства';
    Width := 200;
  end;

  with vstConnections.Header.Columns.Add do
  begin
    Position := 1;
    Text := 'Имя суперлинии';
    Width := 150;
    Options := [coAllowFocus, coEditable, coEnabled, coVisible];
  end;

  with vstConnections.Header.Columns.Add do
  begin
    Position := 2;
    Text := 'Имя головного устройства';
    Width := 200;
    Options := [coAllowFocus, coEditable, coEnabled, coVisible];
  end;

  with vstConnections.Header.Columns.Add do
  begin
    Position := 3;
    Text := 'Номер фидера';
    Width := 150;
    Options := [coAllowFocus, coEditable, coEnabled, coVisible];
  end;

  // Настройка опций дерева
  vstConnections.TreeOptions.SelectionOptions :=
    [toFullRowSelect, toRightClickSelect];
  vstConnections.TreeOptions.MiscOptions :=
    vstConnections.TreeOptions.MiscOptions +
    [toEditable, toEditOnDblClick];
  vstConnections.Header.Options :=
    [hoColumnResize, hoDblClickResize, hoVisible];
end;

{**Загрузить данные из списка подключений}
procedure TfrmConnectControl.LoadConnectionsData;
var
  i: Integer;
  node: PVirtualNode;
  nodeData: PConnectNodeData;
begin
  // Очищаем дерево перед загрузкой
  vstConnections.Clear;

  // Добавляем узлы для каждого подключения
  for i := 0 to ConnectList.Size - 1 do
  begin
    node := vstConnections.AddChild(nil);
    nodeData := vstConnections.GetNodeData(node);

    if nodeData <> nil then
      nodeData^.ConnectIndex := i;
  end;

  vstConnections.Invalidate;
end;

{**Обработчик получения текста для ячейки дерева}
procedure TfrmConnectControl.vstConnectionsGetText(
  Sender: TBaseVirtualTree;
  Node: PVirtualNode;
  Column: TColumnIndex;
  TextType: TVSTTextType;
  var CellText: string
);
var
  nodeData: PConnectNodeData;
  connectItem: TConnectItem;
begin
  CellText := '';
  nodeData := vstConnections.GetNodeData(Node);

  if nodeData = nil then
    Exit;

  // Проверка корректности индекса
  if (nodeData^.ConnectIndex < 0) or
     (nodeData^.ConnectIndex >= ConnectList.Size) then
    Exit;

  // Получаем данные подключения
  connectItem := ConnectList[nodeData^.ConnectIndex];

  // Заполняем текст в зависимости от колонки
  case Column of
    0: CellText := connectItem.NMO_Name;
    1: CellText := connectItem.SLTypeagen;
    2: CellText := connectItem.HeadDeviceName;
    3: CellText := connectItem.NGHeadDevice;
  end;
end;

{**Обработчик нажатия кнопки 1 - добавление нового подключения}
procedure TfrmConnectControl.actButton1Execute(Sender: TObject);
begin
  AddNewConnection;
end;

{**Обработчик нажатия кнопки 2 - установить значение для всех ниже}
procedure TfrmConnectControl.actButton2Execute(Sender: TObject);
begin
  SetValueToAllBelow;
end;

{**Обработчик нажатия кнопки 3 - установить значение с инкрементом +1}
procedure TfrmConnectControl.actButton3Execute(Sender: TObject);
begin
  SetValueWithIncrement;
end;

{**Обработчик нажатия кнопки 4}
procedure TfrmConnectControl.actButton4Execute(Sender: TObject);
begin
  ShowMessage('4');
end;

{**Добавить новое подключение к выбранному устройству}
procedure TfrmConnectControl.AddNewConnection;
var
  selectedNode: PVirtualNode;
  nodeData: PConnectNodeData;
  connectItem: TConnectItem;
  device: PGDBObjDevice;
  previousDeviceIndex: Integer;
begin
  // Получаем выбранный узел в дереве
  selectedNode := vstConnections.GetFirstSelected;

  if selectedNode = nil then
  begin
    ShowMessage('Выберите устройство в списке');
    Exit;
  end;

  // Получаем данные узла
  nodeData := vstConnections.GetNodeData(selectedNode);

  if nodeData = nil then
    Exit;

  // Проверяем корректность индекса
  if (nodeData^.ConnectIndex < 0) or
     (nodeData^.ConnectIndex >= ConnectList.Size) then
    Exit;

  // Получаем устройство из выбранного подключения
  connectItem := ConnectList[nodeData^.ConnectIndex];
  device := connectItem.Device;

  if device = nil then
  begin
    ShowMessage('Ошибка: устройство не найдено');
    Exit;
  end;

  // Запоминаем индекс для последующего обновления дерева
  previousDeviceIndex := nodeData^.ConnectIndex;

  // Добавляем новое подключение к устройству
  if not AddConnectionToDevice(device) then
  begin
    ShowMessage('Ошибка при добавлении подключения');
    Exit;
  end;

  // Перезагружаем данные с чертежа
  CollectDevicesFromDWG;

  // Обновляем дерево с сохранением позиций
  UpdateTreePreservingPositions(previousDeviceIndex);

  ShowMessage('Подключение успешно добавлено');
end;

{**Обновить дерево с сохранением позиций устройств}
procedure TfrmConnectControl.UpdateTreePreservingPositions(
  APreviousDeviceIndex: Integer
);
var
  i: Integer;
  node: PVirtualNode;
  nodeData: PConnectNodeData;
  currentIndex: Integer;
  deviceToInsertAfter: PGDBObjDevice;
  insertionMade: Boolean;
  skipNext: Boolean;
begin
  // Определяем устройство, после которого нужно вставить новое подключение
  if (APreviousDeviceIndex >= 0) and
     (APreviousDeviceIndex < ConnectList.Size) then
    deviceToInsertAfter := ConnectList[APreviousDeviceIndex].Device
  else
    deviceToInsertAfter := nil;

  // Очищаем дерево
  vstConnections.Clear;

  // Добавляем узлы в дерево с учетом порядка
  currentIndex := 0;
  insertionMade := False;
  skipNext := False;

  for i := 0 to ConnectList.Size - 1 do
  begin
    // Пропускаем элемент, если он был обработан на предыдущей итерации
    if skipNext then
    begin
      skipNext := False;
      Continue;
    end;

    // Если это устройство, к которому добавили подключение,
    // добавляем его старые подключения
    if (not insertionMade) and
       (deviceToInsertAfter <> nil) and
       (ConnectList[i].Device = deviceToInsertAfter) then
    begin
      // Добавляем текущее подключение
      node := vstConnections.AddChild(nil);
      nodeData := vstConnections.GetNodeData(node);

      if nodeData <> nil then
        nodeData^.ConnectIndex := i;

      // Проверяем, есть ли следующее подключение того же устройства
      if (i + 1 < ConnectList.Size) and
         (ConnectList[i + 1].Device = deviceToInsertAfter) then
      begin
        // Это новое подключение - добавляем его
        node := vstConnections.AddChild(nil);
        nodeData := vstConnections.GetNodeData(node);

        if nodeData <> nil then
          nodeData^.ConnectIndex := i + 1;

        insertionMade := True;
        skipNext := True; // Отмечаем, что следующий элемент уже обработан
      end;
    end
    else
    begin
      // Обычное добавление узла
      node := vstConnections.AddChild(nil);
      nodeData := vstConnections.GetNodeData(node);

      if nodeData <> nil then
        nodeData^.ConnectIndex := i;
    end;
  end;

  // Обновляем отображение
  vstConnections.Invalidate;
end;

{**Обработчик начала редактирования ячейки}
procedure TfrmConnectControl.vstConnectionsEditing(
  Sender: TBaseVirtualTree;
  Node: PVirtualNode;
  Column: TColumnIndex;
  var Allowed: Boolean
);
begin
  // Разрешаем редактирование для всех колонок кроме первой (имя устройства)
  // Колонка 0 - имя устройства (только для чтения)
  // Колонки 1-3 - редактируемые параметры подключения
  Allowed := (Column >= 1) and (Column <= 3);
end;

{**Обработчик изменения текста в ячейке}
procedure TfrmConnectControl.vstConnectionsNewText(
  Sender: TBaseVirtualTree;
  Node: PVirtualNode;
  Column: TColumnIndex;
  const NewText: string
);
var
  nodeData: PConnectNodeData;
  connectItem: TConnectItem;
  device: PGDBObjDevice;
  connectionIndex: Integer;
  paramName: String;
begin
  // Получаем данные узла
  nodeData := vstConnections.GetNodeData(Node);

  if nodeData = nil then
    Exit;

  // Проверка корректности индекса
  if (nodeData^.ConnectIndex < 0) or
     (nodeData^.ConnectIndex >= ConnectList.Size) then
    Exit;

  // Получаем данные подключения
  connectItem := ConnectList[nodeData^.ConnectIndex];
  device := connectItem.Device;

  if device = nil then
    Exit;

  // Определяем номер подключения для данного устройства
  connectionIndex := FindConnectionIndexForDevice(device, nodeData^.ConnectIndex);

  if connectionIndex < 1 then
    Exit;

  // Обновляем параметр в зависимости от колонки
  case Column of
    1: // Имя суперлинии
    begin
      paramName := velec_VarNameForConnectBefore +
                   IntToStr(connectionIndex) +
                   '_' +
                   velec_VarNameForConnectAfter_SLTypeagen;
      SetDeviceParameterAsString(device, paramName, NewText);
    end;

    2: // Имя головного устройства
    begin
      paramName := velec_VarNameForConnectBefore +
                   IntToStr(connectionIndex) +
                   '_' +
                   velec_VarNameForConnectAfter_HeadDeviceName;
      SetDeviceParameterAsString(device, paramName, NewText);
    end;

    3: // Номер фидера
    begin
      paramName := velec_VarNameForConnectBefore +
                   IntToStr(connectionIndex) +
                   '_' +
                   velec_VarNameForConnectAfter_NGHeadDevice;
      SetDeviceParameterAsString(device, paramName, NewText);
    end;
  end;

  // Обновляем данные в списке
  ConnectList.Mutable[nodeData^.ConnectIndex]^ := connectItem;

  // Перезагружаем данные с чертежа для отображения изменений
  CollectDevicesFromDWG;
  LoadConnectionsData;
end;

{**Установить значение выделенной ячейки для всех ячеек ниже в том же столбце}
procedure TfrmConnectControl.SetValueToAllBelow;
var
  selectedNode: PVirtualNode;
  currentNode: PVirtualNode;
  nodeData: PConnectNodeData;
  selectedColumn: TColumnIndex;
  selectedValue: String;
  selectedIndex: Integer;
  i: Integer;
  device: PGDBObjDevice;
  connectionIndex: Integer;
  paramName: String;
  updatedCount: Integer;
begin
  // Получаем выделенную ячейку
  selectedNode := vstConnections.GetFirstSelected;

  if selectedNode = nil then
  begin
    ShowMessage('Выберите ячейку в списке');
    Exit;
  end;

  // Получаем выбранную колонку
  selectedColumn := vstConnections.FocusedColumn;

  // Проверяем, что выбрана редактируемая колонка (1, 2 или 3)
  if (selectedColumn < 1) or (selectedColumn > 3) then
  begin
    ShowMessage('Выберите редактируемое поле (Имя суперлинии, Имя головного устройства или Номер фидера)');
    Exit;
  end;

  // Получаем данные выбранного узла
  nodeData := vstConnections.GetNodeData(selectedNode);

  if nodeData = nil then
    Exit;

  selectedIndex := nodeData^.ConnectIndex;

  // Проверка корректности индекса
  if (selectedIndex < 0) or (selectedIndex >= ConnectList.Size) then
    Exit;

  // Получаем значение из выделенной ячейки
  case selectedColumn of
    1: selectedValue := ConnectList[selectedIndex].SLTypeagen;
    2: selectedValue := ConnectList[selectedIndex].HeadDeviceName;
    3: selectedValue := ConnectList[selectedIndex].NGHeadDevice;
    else
      Exit;
  end;

  updatedCount := 0;

  // Применяем значение ко всем ячейкам ниже в том же столбце
  for i := selectedIndex + 1 to ConnectList.Size - 1 do
  begin
    device := ConnectList[i].Device;

    if device = nil then
      Continue;

    // Определяем номер подключения для данного устройства
    connectionIndex := FindConnectionIndexForDevice(device, i);

    if connectionIndex < 1 then
      Continue;

    // Формируем имя параметра в зависимости от колонки
    case selectedColumn of
      1: // Имя суперлинии
        paramName := velec_VarNameForConnectBefore +
                     IntToStr(connectionIndex) +
                     '_' +
                     velec_VarNameForConnectAfter_SLTypeagen;
      2: // Имя головного устройства
        paramName := velec_VarNameForConnectBefore +
                     IntToStr(connectionIndex) +
                     '_' +
                     velec_VarNameForConnectAfter_HeadDeviceName;
      3: // Номер фидера
        paramName := velec_VarNameForConnectBefore +
                     IntToStr(connectionIndex) +
                     '_' +
                     velec_VarNameForConnectAfter_NGHeadDevice;
      else
        Continue;
    end;

    // Устанавливаем значение параметра
    SetDeviceParameterAsString(device, paramName, selectedValue);
    Inc(updatedCount);
  end;

  // Перезагружаем данные для отображения изменений
  CollectDevicesFromDWG;
  LoadConnectionsData;

  // Информируем пользователя о результате
  ShowMessage(Format('Обновлено ячеек: %d', [updatedCount]));
end;

{**Установить значение с инкрементом +1 для всех ячеек ниже в том же столбце}
procedure TfrmConnectControl.SetValueWithIncrement;
var
  selectedNode: PVirtualNode;
  nodeData: PConnectNodeData;
  selectedColumn: TColumnIndex;
  selectedValue: String;
  selectedIndex: Integer;
  i: Integer;
  device: PGDBObjDevice;
  connectionIndex: Integer;
  paramName: String;
  baseValue: Integer;
  currentValue: Integer;
  updatedCount: Integer;
begin
  // Получаем выделенную ячейку
  selectedNode := vstConnections.GetFirstSelected;

  if selectedNode = nil then
  begin
    ShowMessage('Выберите ячейку в списке');
    Exit;
  end;

  // Получаем выбранную колонку
  selectedColumn := vstConnections.FocusedColumn;

  // Проверяем, что выбрана редактируемая колонка (1, 2 или 3)
  if (selectedColumn < 1) or (selectedColumn > 3) then
  begin
    ShowMessage('Выберите редактируемое поле (Имя суперлинии, Имя головного устройства или Номер фидера)');
    Exit;
  end;

  // Получаем данные выбранного узла
  nodeData := vstConnections.GetNodeData(selectedNode);

  if nodeData = nil then
    Exit;

  selectedIndex := nodeData^.ConnectIndex;

  // Проверка корректности индекса
  if (selectedIndex < 0) or (selectedIndex >= ConnectList.Size) then
    Exit;

  // Получаем значение из выделенной ячейки
  case selectedColumn of
    1: selectedValue := ConnectList[selectedIndex].SLTypeagen;
    2: selectedValue := ConnectList[selectedIndex].HeadDeviceName;
    3: selectedValue := ConnectList[selectedIndex].NGHeadDevice;
    else
      Exit;
  end;

  // Пытаемся преобразовать значение в число
  if not TryStrToInt(selectedValue, baseValue) then
  begin
    ShowMessage('Значение выбранной ячейки должно быть числом');
    Exit;
  end;

  updatedCount := 0;
  currentValue := baseValue + 1;

  // Применяем значение с инкрементом ко всем ячейкам ниже в том же столбце
  for i := selectedIndex + 1 to ConnectList.Size - 1 do
  begin
    device := ConnectList[i].Device;

    if device = nil then
      Continue;

    // Определяем номер подключения для данного устройства
    connectionIndex := FindConnectionIndexForDevice(device, i);

    if connectionIndex < 1 then
      Continue;

    // Формируем имя параметра в зависимости от колонки
    case selectedColumn of
      1: // Имя суперлинии
        paramName := velec_VarNameForConnectBefore +
                     IntToStr(connectionIndex) +
                     '_' +
                     velec_VarNameForConnectAfter_SLTypeagen;
      2: // Имя головного устройства
        paramName := velec_VarNameForConnectBefore +
                     IntToStr(connectionIndex) +
                     '_' +
                     velec_VarNameForConnectAfter_HeadDeviceName;
      3: // Номер фидера
        paramName := velec_VarNameForConnectBefore +
                     IntToStr(connectionIndex) +
                     '_' +
                     velec_VarNameForConnectAfter_NGHeadDevice;
      else
        Continue;
    end;

    // Устанавливаем значение параметра с текущим инкрементом
    SetDeviceParameterAsString(device, paramName, IntToStr(currentValue));
    Inc(currentValue);
    Inc(updatedCount);
  end;

  // Перезагружаем данные для отображения изменений
  CollectDevicesFromDWG;
  LoadConnectionsData;

  // Информируем пользователя о результате
  ShowMessage(Format('Обновлено ячеек: %d', [updatedCount]));
end;

end.
