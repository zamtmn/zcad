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

{**Модуль формы сопоставления импортированных светильников с блоками}
unit uzvdialuxlumimporter_uiform;

{$INCLUDE zengineconfig.inc}

interface
uses
  SysUtils,
  Classes,
  Forms,
  Controls,
  StdCtrls,
  ComCtrls,
  Graphics,
  Dialogs,
  ButtonPanel,
  Messages,
  laz.VirtualTrees,
  uzegeometrytypes,
  uzvdialuxlumimporter_structs,
  uzclog;

type
  {**Данные узла дерева сопоставления}
  PLightMappingNodeData = ^TLightMappingNodeData;
  TLightMappingNodeData = record
    LumKey: string;             // Идентификатор светильника
    Center: GDBvertex;          // Координаты центра
    SelectedBlockName: string;  // Выбранное имя блока
  end;

  {**Реализация редактора с выпадающим списком для ячейки дерева}
  TComboBoxEditLink = class(TInterfacedObject, IVTEditLink)
  private
    FEdit: TComboBox;           // Выпадающий список
    FTree: TLazVirtualStringTree; // Дерево
    FNode: PVirtualNode;        // Узел редактирования
    FColumn: TColumnIndex;      // Колонка редактирования
    FBlocksList: TStrings;      // Список блоков

  public
    destructor Destroy; override;

    {**Начать редактирование}
    function BeginEdit: Boolean; stdcall;

    {**Отменить изменения}
    function CancelEdit: Boolean; stdcall;

    {**Завершить редактирование}
    function EndEdit: Boolean; stdcall;

    {**Получить границы редактора}
    function GetBounds: TRect; stdcall;

    {**Подготовить редактор}
    function PrepareEdit(
      Tree: TBaseVirtualTree;
      Node: PVirtualNode;
      Column: TColumnIndex
    ): Boolean; stdcall;

    {**Обработать нажатие клавиши}
    procedure ProcessMessage(var Message: TMessage); stdcall;

    {**Установить границы редактора}
    procedure SetBounds(R: TRect); stdcall;

    {**Установить список блоков}
    procedure SetBlocksList(BlocksList: TStrings);
  end;

  {**Форма сопоставления светильников и блоков}
  TfrmDialuxLumImporter = class(TForm)
    btnApplyInstallation: TButton;
    vstLightMapping: TLazVirtualStringTree;

    {**Обработчик создания формы}
    procedure FormCreate(Sender: TObject);

    {**Обработчик уничтожения формы}
    procedure FormDestroy(Sender: TObject);

    {**Обработчик нажатия кнопки выполнения установки}
    procedure btnApplyInstallationClick(Sender: TObject);

    {**Обработчик получения текста для ячейки дерева}
    procedure vstLightMappingGetText(
      Sender: TBaseVirtualTree;
      Node: PVirtualNode;
      Column: TColumnIndex;
      TextType: TVSTTextType;
      var CellText: string
    );

    {**Обработчик создания редактора для ячейки}
    procedure vstLightMappingCreateEditor(
      Sender: TBaseVirtualTree;
      Node: PVirtualNode;
      Column: TColumnIndex;
      out EditLink: IVTEditLink
    );

    {**Обработчик изменения текста в ячейке}
    procedure vstLightMappingNewText(
      Sender: TBaseVirtualTree;
      Node: PVirtualNode;
      Column: TColumnIndex;
      const NewText: string
    );

    {**Обработчик отрисовки текста в ячейке дерева}
    procedure vstLightMappingPaintText(
      Sender: TBaseVirtualTree;
      const TargetCanvas: TCanvas;
      Node: PVirtualNode;
      Column: TColumnIndex;
      TextType: TVSTTextType
    );

    {**Обработчик инициализации узла дерева}
    procedure vstLightMappingInitNode(
      Sender: TBaseVirtualTree;
      ParentNode: PVirtualNode;
      Node: PVirtualNode;
      var InitialStates: TVirtualNodeInitStates
    );


  private
    FRecognizedLights: TLightItemArray;  // Массив распознанных светильников
    FLoadedBlocks: TLoadedBlocksList;    // Список доступных блоков
    FEditLink: TComboBoxEditLink;        // Ссылка на редактор

    {**Инициализировать колонки дерева}
    procedure InitializeTreeColumns;

    {**Заполнить дерево данными о светильниках}
    procedure PopulateTree;

    {**Создать узел для одного светильника}
    function CreateLightNode(const LightItem: TLightItem): PVirtualNode;

    {**Получить данные узла}
    function GetNodeData(Node: PVirtualNode): PLightMappingNodeData;

    {**Выполнить установку светильников на чертеж}
    procedure ExecuteInstallation;

  public
    {**Загрузить данные в форму}
    procedure LoadData(
      const RecognizedLights: TLightItemArray;
      LoadedBlocks: TLoadedBlocksList
    );

  end;

implementation

{$R *.lfm}

{**Обработчик создания формы}
procedure TfrmDialuxLumImporter.FormCreate(Sender: TObject);
begin
  // Установка базовых свойств формы
  Caption := 'Импорт светильников Dialux';
  Width := 800;
  Height := 600;
  Position := poScreenCenter;

  // Настройка дерева
  vstLightMapping.NodeDataSize := SizeOf(TLightMappingNodeData);

  InitializeTreeColumns;

  // Настройка кнопки
  btnApplyInstallation.Caption := 'Выполнить установку';
  btnApplyInstallation.Anchors := [akLeft, akRight, akBottom];
  btnApplyInstallation.OnClick := @btnApplyInstallationClick;

  programlog.LogOutFormatStr(
    'Форма импорта светильников Dialux создана',
    [],
    LM_Info
  );
end;

{**Обработчик уничтожения формы}
procedure TfrmDialuxLumImporter.FormDestroy(Sender: TObject);
begin
  programlog.LogOutFormatStr(
    'Форма импорта светильников Dialux закрыта',
    [],
    LM_Info
  );
end;

{**Инициализировать колонки дерева}
procedure TfrmDialuxLumImporter.InitializeTreeColumns;
var
  Column: TVirtualTreeColumn;
begin
  // Проверяем, что колонки уже созданы в .lfm файле
  if vstLightMapping.Header.Columns.Count = 0 then
  begin
    // Если колонок нет, создаем их программно
    vstLightMapping.Header.Options :=
      vstLightMapping.Header.Options + [hoVisible, hoColumnResize];

    // Колонка 1: Импортированные светильники
    Column := vstLightMapping.Header.Columns.Add;
    Column.Text := 'Импортированные светильники';
    Column.Width := 300;
    Column.Options := Column.Options - [coEditable];

    // Колонка 2: Блок для установки
    Column := vstLightMapping.Header.Columns.Add;
    Column.Text := 'Блок для установки';
    Column.Width := 450;
    Column.Options := Column.Options + [coEditable];

    // Настройки дерева
    vstLightMapping.TreeOptions.SelectionOptions :=
      vstLightMapping.TreeOptions.SelectionOptions + [toFullRowSelect];
    vstLightMapping.TreeOptions.MiscOptions :=
      vstLightMapping.TreeOptions.MiscOptions + [toEditable];
  end
  else
  begin
    // Колонки уже определены в .lfm, только настраиваем их параметры
    if vstLightMapping.Header.Columns.Count >= 2 then
    begin
      // Первая колонка - только для чтения
      vstLightMapping.Header.Columns[0].Options :=
        vstLightMapping.Header.Columns[0].Options - [coEditable];

      // Вторая колонка - редактируемая
      vstLightMapping.Header.Columns[1].Options :=
        vstLightMapping.Header.Columns[1].Options + [coEditable];
    end;
  end;
end;

{**Загрузить данные в форму}
procedure TfrmDialuxLumImporter.LoadData(
  const RecognizedLights: TLightItemArray;
  LoadedBlocks: TLoadedBlocksList
);
begin
  FRecognizedLights := RecognizedLights;
  FLoadedBlocks := LoadedBlocks;

  PopulateTree;

  programlog.LogOutFormatStr(
    'Загружено %d светильника(-ов) и %d блока(-ов)',
    [Length(FRecognizedLights), FLoadedBlocks.Count],
    LM_Info
  );
end;

{**Заполнить дерево данными о светильниках}
procedure TfrmDialuxLumImporter.PopulateTree;
var
  i: Integer;
  LightItem: TLightItem;
begin
  vstLightMapping.BeginUpdate;
  try
    vstLightMapping.Clear;

    for i := 0 to High(FRecognizedLights) do
    begin
      LightItem := FRecognizedLights[i];
      CreateLightNode(LightItem);
    end;

  finally
    vstLightMapping.EndUpdate;
  end;
end;

{**Создать узел для одного светильника}
function TfrmDialuxLumImporter.CreateLightNode(
  const LightItem: TLightItem
): PVirtualNode;
var
  NodeData: PLightMappingNodeData;
begin
  Result := vstLightMapping.AddChild(nil);
  NodeData := GetNodeData(Result);

  if NodeData <> nil then
  begin
    NodeData^.LumKey := LightItem.LumKey;
    NodeData^.Center := LightItem.Center;
    NodeData^.SelectedBlockName := '';

    // Устанавливаем первый блок по умолчанию, если есть
    if FLoadedBlocks.Count > 0 then
      NodeData^.SelectedBlockName := FLoadedBlocks[0];
  end;
end;

{**Получить данные узла}
function TfrmDialuxLumImporter.GetNodeData(
  Node: PVirtualNode
): PLightMappingNodeData;
begin
  if Node <> nil then
    Result := vstLightMapping.GetNodeData(Node)
  else
    Result := nil;
end;

{**Обработчик получения текста для ячейки дерева}
procedure TfrmDialuxLumImporter.vstLightMappingGetText(
  Sender: TBaseVirtualTree;
  Node: PVirtualNode;
  Column: TColumnIndex;
  TextType: TVSTTextType;
  var CellText: string
);
var
  NodeData: PLightMappingNodeData;
begin
  // Получаем указатель на данные узла напрямую из Sender
  NodeData := Sender.GetNodeData(Node);

  // Проверяем валидность указателя
  if not Assigned(NodeData) then
    Exit;

  case Column of
    0: // Колонка: Импортированные светильники
      CellText := Format(
        '%s (%.1f, %.1f)',
        [NodeData^.LumKey, NodeData^.Center.x, NodeData^.Center.y]
      );

    1: // Колонка: Блок для установки
      CellText := NodeData^.SelectedBlockName;
  end;
end;

{**Обработчик создания редактора для ячейки}
procedure TfrmDialuxLumImporter.vstLightMappingCreateEditor(
  Sender: TBaseVirtualTree;
  Node: PVirtualNode;
  Column: TColumnIndex;
  out EditLink: IVTEditLink
);
begin
  // Для второй колонки создаем редактор с выпадающим списком
  if Column = 1 then
  begin
    FEditLink := TComboBoxEditLink.Create;
    FEditLink.SetBlocksList(FLoadedBlocks);
    EditLink := FEditLink;
  end
  else
    EditLink := nil;
end;

{**Обработчик изменения текста в ячейке}
procedure TfrmDialuxLumImporter.vstLightMappingNewText(
  Sender: TBaseVirtualTree;
  Node: PVirtualNode;
  Column: TColumnIndex;
  const NewText: string
);
var
  NodeData: PLightMappingNodeData;
begin
  if Column <> 1 then
    Exit;

  NodeData := GetNodeData(Node);
  if NodeData <> nil then
  begin
    NodeData^.SelectedBlockName := NewText;

    programlog.LogOutFormatStr(
      'Для светильника "%s" выбран блок "%s"',
      [NodeData^.LumKey, NewText],
      LM_Debug
    );
  end;
end;

{**Обработчик отрисовки текста в ячейке дерева}
procedure TfrmDialuxLumImporter.vstLightMappingPaintText(
  Sender: TBaseVirtualTree;
  const TargetCanvas: TCanvas;
  Node: PVirtualNode;
  Column: TColumnIndex;
  TextType: TVSTTextType
);
begin
  // Устанавливаем цвет текста и фон для всех ячеек
  // Это необходимо для корректной отрисовки текста в компоненте TLazVirtualStringTree
  TargetCanvas.Font.Color := clBlack;
  TargetCanvas.Brush.Color := clWhite;
end;

{**Обработчик инициализации узла дерева}
procedure TfrmDialuxLumImporter.vstLightMappingInitNode(
  Sender: TBaseVirtualTree;
  ParentNode: PVirtualNode;
  Node: PVirtualNode;
  var InitialStates: TVirtualNodeInitStates
);
var
  NodeData: PLightMappingNodeData;
begin
  // Получаем указатель на данные узла
  NodeData := Sender.GetNodeData(Node);

  // Инициализируем память узла нулевыми значениями
  if Assigned(NodeData) then
  begin
    NodeData^.LumKey := '';
    NodeData^.Center.x := 0;
    NodeData^.Center.y := 0;
    NodeData^.Center.z := 0;
    NodeData^.SelectedBlockName := '';
  end;
end;

{**Обработчик нажатия кнопки выполнения установки}
procedure TfrmDialuxLumImporter.btnApplyInstallationClick(Sender: TObject);
begin
  programlog.LogOutFormatStr(
    'Начата установка светильников на чертеж',
    [],
    LM_Info
  );

  ExecuteInstallation;

  // Закрываем форму после установки
  ModalResult := mrOk;
end;

{**Выполнить установку светильников на чертеж}
procedure TfrmDialuxLumImporter.ExecuteInstallation;
var
  Node: PVirtualNode;
  NodeData: PLightMappingNodeData;
  InstalledCount: Integer;
  ErrorCount: Integer;
begin
  InstalledCount := 0;
  ErrorCount := 0;

  Node := vstLightMapping.GetFirst;
  while Node <> nil do
  begin
    NodeData := GetNodeData(Node);

    if NodeData <> nil then
    begin
      // Проверяем, что выбран блок
      if NodeData^.SelectedBlockName = '' then
      begin
        programlog.LogOutFormatStr(
          'Светильник "%s": блок не выбран',
          [NodeData^.LumKey],
          LM_Warning
        );
        Inc(ErrorCount);
      end
      else
      begin
        // TODO: Здесь будет вызов функции установки блока на чертеж
        programlog.LogOutFormatStr(
          'Светильник "%s" → Блок "%s" (%.1f, %.1f)',
          [
            NodeData^.LumKey,
            NodeData^.SelectedBlockName,
            NodeData^.Center.x,
            NodeData^.Center.y
          ],
          LM_Info
        );
        Inc(InstalledCount);
      end;
    end;

    Node := vstLightMapping.GetNext(Node);
  end;

  programlog.LogOutFormatStr(
    'Установка завершена: успешно=%d, ошибок=%d',
    [InstalledCount, ErrorCount],
    LM_Info
  );

  // Показываем сообщение пользователю
  if ErrorCount = 0 then
    ShowMessage(Format('Установлено %d светильника(-ов)', [InstalledCount]))
  else
    ShowMessage(
      Format(
        'Установлено %d светильника(-ов), ошибок: %d',
        [InstalledCount, ErrorCount]
      )
    );
end;

{ TComboBoxEditLink }

{**Деструктор}
destructor TComboBoxEditLink.Destroy;
begin
  if FEdit <> nil then
    FEdit.Free;
  inherited Destroy;
end;

{**Установить список блоков}
procedure TComboBoxEditLink.SetBlocksList(BlocksList: TStrings);
begin
  FBlocksList := BlocksList;
end;

{**Подготовить редактор}
function TComboBoxEditLink.PrepareEdit(
  Tree: TBaseVirtualTree;
  Node: PVirtualNode;
  Column: TColumnIndex
): Boolean; stdcall;
var
  NodeData: PLightMappingNodeData;
begin
  Result := True;
  FTree := Tree as TLazVirtualStringTree;
  FNode := Node;
  FColumn := Column;

  // Создаем ComboBox
  FEdit := TComboBox.Create(nil);
  FEdit.Visible := False;
  FEdit.Parent := Tree;
  FEdit.Style := csDropDownList;

  // Заполняем список блоков
  if FBlocksList <> nil then
    FEdit.Items.Assign(FBlocksList);

  // Устанавливаем текущее значение
  NodeData := FTree.GetNodeData(Node);
  if NodeData <> nil then
  begin
    FEdit.ItemIndex := FEdit.Items.IndexOf(NodeData^.SelectedBlockName);
    if FEdit.ItemIndex < 0 then
      FEdit.ItemIndex := 0;
  end;
end;

{**Начать редактирование}
function TComboBoxEditLink.BeginEdit: Boolean; stdcall;
begin
  Result := True;
  FEdit.Show;
  FEdit.SetFocus;
  FEdit.DroppedDown := True;
end;

{**Завершить редактирование}
function TComboBoxEditLink.EndEdit: Boolean; stdcall;
var
  NodeData: PLightMappingNodeData;
begin
  Result := True;

  if FEdit.ItemIndex >= 0 then
  begin
    NodeData := FTree.GetNodeData(FNode);
    if NodeData <> nil then
      NodeData^.SelectedBlockName := FEdit.Items[FEdit.ItemIndex];
  end;

  FEdit.Hide;
  FEdit.Free;
  FEdit := nil;
end;

{**Отменить изменения}
function TComboBoxEditLink.CancelEdit: Boolean; stdcall;
begin
  Result := True;
  FEdit.Hide;
  FEdit.Free;
  FEdit := nil;
end;

{**Получить границы редактора}
function TComboBoxEditLink.GetBounds: TRect; stdcall;
begin
  Result := FEdit.BoundsRect;
end;

{**Установить границы редактора}
procedure TComboBoxEditLink.SetBounds(R: TRect); stdcall;
begin
  FEdit.BoundsRect := R;
end;

{**Обработать нажатие клавиши}
procedure TComboBoxEditLink.ProcessMessage(var Message: TMessage); stdcall;
begin
  // Передаем сообщения в ComboBox
  if FEdit <> nil then
    FEdit.WindowProc(Message);
end;

end.
