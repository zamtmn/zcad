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
  uzvconnect_struct;

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

  private
    {**Инициализировать дерево подключений}
    procedure InitializeTree;

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
  end;

  with vstConnections.Header.Columns.Add do
  begin
    Position := 2;
    Text := 'Имя головного устройства';
    Width := 200;
  end;

  with vstConnections.Header.Columns.Add do
  begin
    Position := 3;
    Text := 'Номер фидера';
    Width := 150;
  end;

  // Настройка опций дерева
  vstConnections.TreeOptions.SelectionOptions :=
    [toFullRowSelect, toRightClickSelect];
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

{**Обработчик нажатия кнопки 1}
procedure TfrmConnectControl.actButton1Execute(Sender: TObject);
begin
  ShowMessage('1');
end;

{**Обработчик нажатия кнопки 2}
procedure TfrmConnectControl.actButton2Execute(Sender: TObject);
begin
  ShowMessage('2');
end;

{**Обработчик нажатия кнопки 3}
procedure TfrmConnectControl.actButton3Execute(Sender: TObject);
begin
  ShowMessage('3');
end;

{**Обработчик нажатия кнопки 4}
procedure TfrmConnectControl.actButton4Execute(Sender: TObject);
begin
  ShowMessage('4');
end;

end.
