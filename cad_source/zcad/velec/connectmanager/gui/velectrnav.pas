unit VElectrNav;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls,Graphics,  laz.VirtualTrees, DB,uzcdrawing,uzcdrawings,uzcinterface,
  Dialogs, ExtCtrls, BufDataset,  DBGrids, Grids, ActnList, ComCtrls, Windows,fgl,
  uzvelaccessdbcontrol,uzvmcmanager,uzvmcstruct,gvector,uzccablemanager,uzcentcable,uzeentdevice,gzctnrVectorTypes,uzcvariablesutils,uzccommandsabstract,uzeentity,uzeentblockinsert,varmandef,uzeconsts;

type

  PNodeData = ^TNodeData;
  TNodeData = record
    DeviceName: string;
    ConnectedTo: string;
    fullpath: string;
    Group: string;
    CanBeNode: Boolean;
  end;

  PGridNodeData = ^TGridNodeData;
  TGridNodeData = record
    DevName: string;
    HDName: string;
    HDGroup: string;
  end;


  { TVElectrNav }

  TVElectrNav = class(TFrame)
    ActionList1: TActionList;
    bufGridDev: TBufDataset;
    dsGridDev: TDataSource;
    vstDev: TLazVirtualStringTree;
    PanelData: TPanel;
    PanelNav: TPanel;
    PanelButton: TPanel;
    panelSplitter: TSplitter;
    FDeviceTree: TLazVirtualStringTree;
    ToolBar1: TToolBar;
    procedure FrameResize(Sender: TObject);
    procedure panelSplitterMoved(Sender: TObject);
    procedure vstDevGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: String);
    procedure vstDevPaintText(Sender: TBaseVirtualTree;
      const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
      TextType: TVSTTextType);
    procedure vstDevClick(Sender: TObject);
    procedure vstDevEditing(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; var Allowed: Boolean);
    procedure vstDevNewText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; const NewText: AnsiString);
  private
    //для работы разделителя
    FProportion: Double; // Пропорция ширины PanelSynchDraw / (ClientWidth - Splitter)
    FIsResizing: Boolean; // Флаг для предотвращения рекурсии
    FDevicesList: TListVElectrDevStruct; // Список устройств из TConnectionManager
    procedure InitializeActionAndButton; //инициализация и настройка кнопок
    procedure InitializePanels;          //инициализация и настройка панелей

    procedure InitializeDeviceTree;
    procedure InitializeBufDataset;
    procedure InitializeVstDev;
    procedure recordingVstDev(const filterPath: string);
    procedure BuildDeviceHierarchy;
    procedure TreeGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: String);
    procedure TreeGetNodeDataSize(Sender: TBaseVirtualTree; var NodeDataSize: Integer);
    procedure TreeInitNode(Sender: TBaseVirtualTree; ParentNode, Node: PVirtualNode;
      var InitialStates: TVirtualNodeInitStates);
    procedure TreeFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure TreeClick(Sender: TObject);
    procedure AddAction(AName, ACaption: string; AImageIndex: string;
  AHint, AShortCut: string; AEvent: TNotifyEvent);
    procedure AddPathToTree(ParentNode: PVirtualNode; const Path: string);
    function FindOrCreateChild(ParentNode: PVirtualNode; const HDWay,NodeName: string): PVirtualNode;
    function GetNodePhysicalPath(Node: PVirtualNode): string;

    procedure CurrentSelActionExecute(Sender: TObject);
    procedure AllSelActionExecute(Sender: TObject);
    procedure SaveActionExecute(Sender: TObject);
    procedure CollapseAllActionExecute(Sender: TObject);
    procedure ExpandAllActionExecute(Sender: TObject);

  public

    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
  end;

  var
      flagEditBufBeforePost:boolean;

implementation

{$R *.lfm}

{ TVElectrNav }

constructor TVElectrNav.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  //ShowMessage('Активировался TFRAME: ');

  Name := 'VElectrNav';
  Caption := 'Диспетчер подключений';

  // Инициализация списка устройств
  FDevicesList := TListVElectrDevStruct.Create;



    try
    //filepath:=;
    //if AnsiPos(':\', ExtractFilePath(PTZCADDrawing(drawings.GetCurrentDwg)^.FileName)) = 0 then begin
    //   ShowMessage('Ошибка подключен');
    //   ZCMsgCallBackInterface.TextMessage('Команда отменена. Выполните сохранение чертежа в ZCAD!!!!!',TMWOHistoryOut);
    //   //result:=cmd_cancel;
    //   exit;
    //end;

    // Подписываемся на событие изменения размера фрейма
    OnResize := @FrameResize;
    //Добавляем кнопки
    InitializeActionAndButton;
    //Настравиваем панели
    InitializePanels;

    // Сохраняем начальную пропорцию
    FProportion := 0.25; // Начальная пропорция 25%/75%
    PanelNav.Width := Round(ClientWidth * FProportion);
    FIsResizing := False;

    // Настраиваем дерево устройств
    FDeviceTree.Parent := PanelNav;
    FDeviceTree.Align := alClient;
    FDeviceTree.NodeDataSize := SizeOf(Pointer);

  // Настройка событий дерева
  //FDeviceTree.OnGetText := @TreeGetText;
  //FDeviceTree.OnGetNodeDataSize := @TreeGetNodeDataSize;
  //FDeviceTree.OnInitNode := @TreeInitNode;
  //FDeviceTree.OnFreeNode := @TreeFreeNode;
  //FDeviceTree.OnClick := @TreeClick;



  vstDev.Parent := PanelData;
  vstDev.Align := alClient;
  vstDev.NodeDataSize := SizeOf(TGridNodeData);

    except
      //SQLTransaction.Free;
      //SQLite3Connection.Free;
      on E: Exception do
        ShowMessage('Ошибка подключения TFRAME: ' + E.Message);

    end;

end;
procedure TVElectrNav.AddAction(AName, ACaption: string; AImageIndex: string;
  AHint, AShortCut: string; AEvent: TNotifyEvent);
var
  act: TAction;
begin
  act := TAction.Create(self); // или ActionList1
  act.ActionList := ActionList1;
  act.Name := AName;
  act.Caption := ACaption;
  act.Hint := AHint;
  act.OnExecute := AEvent;

  //if AShortCut <> '' then
  //  act.ShortCut := TextToShortCut(AShortCut);

  //act.ActionList := ActionList1;
  //ActionList1.AddAction(act);
end;

// Пока это выгрузка в Аксесс
procedure TVElectrNav.CurrentSelActionExecute(Sender: TObject);
var
  accessexport:TConnectionManager;
  devicesList: TListVElectrDevStruct;
begin
  //uzvelaccessdbcontrol.AddStructureinAccessDB;
  accessexport := TConnectionManager.Create('');
  try
    // Получение списка устройств с чертежа
    devicesList := accessexport.GetDevicesFromDrawing;
    try
      // Сортировка списка устройств
      //accessexport.HierarchyBuilder.SortDeviceList(devicesList);

      // Экспорт подготовленного списка в базу данных Access
      accessexport.ExportDevicesListToAccess(devicesList, 'D:\ZcadDB.accdb');
    finally
      devicesList.Free;
    end;
  finally
    accessexport.Free;
  end;
end;


procedure TVElectrNav.AllSelActionExecute(Sender: TObject);
var
  mcManager: TConnectionManager;
begin
  // 1. Взаимодействие с uzvmcmanager
  mcManager := TConnectionManager.Create('');
  try
    // 2. Получить список всех устройств GetDevicesFromDrawing
    // Очищаем предыдущий список
    FDevicesList.Clear;

    // Получаем новый список устройств
    FDevicesList := mcManager.GetDevicesFromDrawing;

    // 3. Отсортировать их HierarchyBuilder.SortDeviceList
    mcManager.HierarchyBuilder.SortDeviceList(FDevicesList);

    // Настраиваем дерево устройств
    FDeviceTree.Parent := PanelNav;
    FDeviceTree.Align := alClient;
    FDeviceTree.NodeDataSize := SizeOf(Pointer);

    // Настройка событий дерева
    FDeviceTree.OnGetText := @TreeGetText;
    FDeviceTree.OnGetNodeDataSize := @TreeGetNodeDataSize;
    FDeviceTree.OnInitNode := @TreeInitNode;
    FDeviceTree.OnFreeNode := @TreeFreeNode;
    FDeviceTree.OnClick := @TreeClick;

    // 4. Построение дерева на основе отсортированного списка
    InitializeDeviceTree;
    BuildDeviceHierarchy;

    // Заполнение vstDev
    flagEditBufBeforePost:=false;

    // Настройка BufDataset
    InitializeBufDataset;
    //Привязываем к источнику данных
    dsGridDev.DataSet := bufGridDev;

    // Настройка vstDev
    InitializeVstDev;

    // 5. При выделении ноды в FDeviceTree, должна выгружаться в vstDev
    // (это обрабатывается в TreeClick, который уже реализован)
    recordingVstDev('');

    vstDev.OnGetText := @vstDevGetText;
    vstDev.OnPaintText := @vstDevPaintText;
    vstDev.OnClick := @vstDevClick;
    vstDev.OnEditing := @vstDevEditing;
    vstDev.OnNewText := @vstDevNewText;
  finally
    mcManager.Free;
  end;
end;
procedure TVElectrNav.SaveActionExecute(Sender: TObject);
begin
  ShowMessage('сохранить файл...');
end;
procedure TVElectrNav.InitializeActionAndButton;
var
  i:integer;
  btn: TToolButton;
begin
  try
    // Настройка ToolBar перед созданием кнопок
    ToolBar1.Parent := PanelButton; // Добавьте эту строку в начало InitializeActionAndButton
    //ToolBar1.Align := alClient;   // Или другой вариант выравнивания
    ToolBar1.Height := 50;    // Явное задание высоты
    ToolBar1.AutoSize := false;  // Автоматически подстраивать размер
    ToolBar1.ShowCaptions := True;  // Показывать текст на кнопках
    ToolBar1.ButtonWidth := 40;  // Ширина кнопок
    ToolBar1.ButtonHeight := 40; // Высота кнопок
    ToolBar1.Images := nil; // Если не используете изображения


    // Создаем действия
    AddAction('actNew', '1', '0', 'Создать новый документ', 'Ctrl+N', @CurrentSelActionExecute);
    AddAction('actOpen', '*', '1', 'Открыть документ', 'Ctrl+O', @AllSelActionExecute);
    AddAction('actSave', 'Cl', '2', 'Сохранить документ', 'Ctrl+S', @SaveActionExecute);
    AddAction('actCollapseAll', '+', '3', 'Свернуть все ноды', '', @CollapseAllActionExecute);
    AddAction('actExpandAll', '-', '4', 'Развернуть все ноды', '', @ExpandAllActionExecute);

    // Создаем кнопки на ToolBar
    for i := 0 to ActionList1.ActionCount - 1 do
    begin
      btn := TToolButton.Create(ToolBar1);
      btn.Parent := ToolBar1;
      btn.Action := ActionList1.Actions[i];
      btn.ShowHint := True;
      btn.AutoSize := False;  // Фиксированный размер
      btn.Width := 40;  // Явное задание ширины
      btn.Height := 40; // Явное задание высоты
    end;

    //Обновляем размеры панели и ToolBar
    ToolBar1.Realign;
    ToolBar1.Invalidate;
  except
    on E: Exception do
      ShowMessage('Ошибка создание активности: ' + E.Message);
  end;
end;
procedure TVElectrNav.InitializePanels;
begin
  try
      // первый контейнер (левая половина)
      PanelNav.Align := alLeft;
      PanelNav.BevelOuter := bvNone;
      PanelNav.BorderSpacing.Around := 2;

      // Настройка разделителя
      panelSplitter.Align := alLeft;
      panelSplitter.Width := 8;
      panelSplitter.ResizeStyle := rsUpdate;
      panelSplitter.Color := clBtnFace;
      panelSplitter.MinSize := 100; // Минимальный размер панелей
      panelSplitter.OnMoved:=@panelSplitterMoved;

      // второй контейнер (правая половина)
      panelData.Align := alClient; // Займет оставшееся пространство
      panelData.BevelOuter := bvNone;
      panelData.BorderSpacing.Around := 2;
  except
    on E: Exception do
      ShowMessage('Ошибка создание инициализации панелей: ' + E.Message);
  end;
end;

procedure TVElectrNav.InitializeBufDataset;
begin
  try
    with bufGridDev do
    begin
      Close;
      FieldDefs.Clear;
      FieldDefs.Add('ActionShow', ftString, 10);
      //FieldDefs.Add('ID', ftInteger);
      FieldDefs.Add('devname', ftString, 10);
      FieldDefs.Add('hdname', ftString, 10);
      FieldDefs.Add('hdgroup', ftString, 10);
      //FieldDefs.Add('icanhd', ftString, 20);
      FieldDefs.Add('ActionEdit', ftString, 10);
      CreateDataset;
    end;
  except
    on E: Exception do
      ShowMessage('Ошибка подключения создания BufDataset: ' + E.Message);
  end;
end;
procedure TVElectrNav.InitializeVstDev;
begin
  try
    vstDev.BeginUpdate;
    try
      vstDev.Header.Columns.Clear;
      vstDev.Clear;

      vstDev.TreeOptions.PaintOptions :=
        vstDev.TreeOptions.PaintOptions - [toShowRoot, toShowTreeLines, toShowButtons];
      vstDev.TreeOptions.SelectionOptions :=
        vstDev.TreeOptions.SelectionOptions + [toFullRowSelect, toExtendedFocus];
      vstDev.TreeOptions.MiscOptions :=
        vstDev.TreeOptions.MiscOptions + [toEditable, toEditOnDblClick, toGridExtensions];
      vstDev.Header.Options :=
        vstDev.Header.Options + [hoVisible, hoColumnResize] - [hoAutoResize];
      vstDev.Header.AutoSizeIndex := -1;

      // Кнопка "Показать"
      with vstDev.Header.Columns.Add do
      begin
        Text := 'show';
        Width := 80;
      end;

      // Обычные поля
      with vstDev.Header.Columns.Add do
      begin
        Text := 'devname';
        Width := 100;
        Options := Options + [coAllowFocus, coEditable];
      end;

      with vstDev.Header.Columns.Add do
      begin
        Text := 'hdname';
        Width := 100;
        Options := Options + [coAllowFocus, coEditable];
      end;

      with vstDev.Header.Columns.Add do
      begin
        Text := 'hdgroup';
        Width := 100;
        Options := Options + [coAllowFocus, coEditable];
      end;

      // Кнопка "Ред."
      with vstDev.Header.Columns.Add do
      begin
        Text := 'edit';
        Width := 80;
      end;
    finally
      vstDev.EndUpdate;
    end;
  except
    on E: Exception do
      ShowMessage('Ошибка создания колонок: ' + E.Message);
  end;
end;

procedure TVElectrNav.recordingVstDev(const filterPath: string);
var
    i: integer;
    Node: PVirtualNode;
    NodeData: PGridNodeData;
    device: TVElectrDevStruct;
begin
  try
    vstDev.BeginUpdate;
    try
      vstDev.Clear;

      // Проходим по всем устройствам в FDevicesList
      for i := 0 to FDevicesList.Size - 1 do
      begin
        device := FDevicesList[i];

        // Если фильтр задан, проверяем соответствие pathHD
        if (filterPath = '') or (device.pathHD = filterPath) then
        begin
          Node := vstDev.AddChild(nil);
          NodeData := vstDev.GetNodeData(Node);

          // Заполняем данные ноды из структуры устройства
          NodeData^.DevName := device.realname;  // или basename
          NodeData^.HDName := device.headdev;
          // Для hdgroup нужно найти группу головного устройства
          // Пока оставим пустым, так как в TVElectrDevStruct нет прямого поля для группы
          NodeData^.HDGroup := '';
        end;
      end;
    finally
      vstDev.EndUpdate;
    end;
  except
    on E: Exception do
      ShowMessage('Ошибка загрузки данных: ' + E.Message);
  end;
end;


procedure TVElectrNav.vstDevGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: String);
var
  NodeData: PGridNodeData;
begin
  NodeData := Sender.GetNodeData(Node);
  if not Assigned(NodeData) then Exit;

  case Column of
    0: CellText := 'Показать';
    1: CellText := NodeData^.DevName;
    2: CellText := NodeData^.HDName;
    3: CellText := NodeData^.HDGroup;
    4: CellText := 'Ред.';
  end;
end;

procedure TVElectrNav.vstDevPaintText(Sender: TBaseVirtualTree;
  const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
  TextType: TVSTTextType);
begin
  if (Column = 0) or (Column = 4) then
  begin
    TargetCanvas.Font.Color := clBlue;
    TargetCanvas.Font.Style := [fsUnderline];
  end;
end;

procedure TVElectrNav.vstDevClick(Sender: TObject);
var
  Node: PVirtualNode;
  NodeData: PGridNodeData;
  HitInfo: THitInfo;
  P: TPoint;
begin
  P := vstDev.ScreenToClient(Mouse.CursorPos);
  vstDev.GetHitTestInfoAt(P.X, P.Y, True, HitInfo);

  if not Assigned(HitInfo.HitNode) then Exit;

  Node := HitInfo.HitNode;
  NodeData := vstDev.GetNodeData(Node);
  if not Assigned(NodeData) then Exit;

  if HitInfo.HitColumn = 0 then
    ShowMessage('devname: ' + NodeData^.DevName)
  else if HitInfo.HitColumn = 4 then
    ShowMessage('Редактировать: ' + NodeData^.HDName);
end;

procedure TVElectrNav.vstDevEditing(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; var Allowed: Boolean);
begin
  // Разрешаем редактирование только для колонок 1, 2, 3 (devname, hdname, hdgroup)
  Allowed := (Column >= 1) and (Column <= 3);
end;

procedure TVElectrNav.vstDevNewText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; const NewText: AnsiString);
var
  NodeData: PGridNodeData;
  OldDevName: String;
  i: Integer;
  device: PTVElectrDevStruct;
begin
  NodeData := Sender.GetNodeData(Node);
  if not Assigned(NodeData) then Exit;

  // Сохраняем старое значение devname для поиска в списке
  OldDevName := NodeData^.DevName;

  // Обновляем визуальные данные ноды
  case Column of
    1: NodeData^.DevName := NewText;
    2: NodeData^.HDName := NewText;
    3: NodeData^.HDGroup := NewText;
    else
      Exit;
  end;

  // Обновляем данные в FDevicesList
  try
    for i := 0 to FDevicesList.Size - 1 do
    begin
      device := FDevicesList.Mutable[i];
      if device^.realname = OldDevName then
      begin
        case Column of
          1: device^.realname := NewText;
          2: device^.headdev := NewText;
          3: begin
            // HDGroup не имеет прямого соответствия в TVElectrDevStruct
            // Это поле может требовать дополнительной логики
          end;
        end;
        Break;
      end;
    end;
  except
    on E: Exception do
    begin
      ShowMessage('Ошибка обновления данных: ' + E.Message);
      // Восстанавливаем старое значение
      case Column of
        1: NodeData^.DevName := OldDevName;
        // Для других полей восстановление требует дополнительной логики
      end;
    end;
  end;
end;

destructor TVElectrNav.Destroy;
begin
  // Освобождаем список устройств
  if Assigned(FDevicesList) then
    FDevicesList.Free;

  inherited Destroy;
end;

//Для работы разделителя
procedure TVElectrNav.FrameResize(Sender: TObject);
begin
  if FIsResizing then Exit;

  try
    FIsResizing := True;

    // Сохраняем пропорции при изменении размера фрейма
    if (ClientWidth > 0) and (panelSplitter.Width > 0) then
    begin
      PanelNav.Width := Round((ClientWidth - panelSplitter.Width) * FProportion);
    end;
  finally
    FIsResizing := False;
  end;
end;

procedure TVElectrNav.panelSplitterMoved(Sender: TObject);
begin
  // Просто обновляем пропорцию при перемещении разделителя
  FProportion := PanelNav.Width / (ClientWidth - panelSplitter.Width);
end;

////////////////////////////////

procedure TVElectrNav.InitializeDeviceTree;
begin
  FDeviceTree.BeginUpdate;
  try
    // Очистка всех предыдущих столбцов
    FDeviceTree.Header.Columns.Clear;

    FDeviceTree.Clear;
    FDeviceTree.TreeOptions.PaintOptions :=
      FDeviceTree.TreeOptions.PaintOptions + [toShowRoot, toShowTreeLines, toShowButtons];
    FDeviceTree.TreeOptions.SelectionOptions :=
      FDeviceTree.TreeOptions.SelectionOptions + [toFullRowSelect];
    FDeviceTree.Header.Options :=
      FDeviceTree.Header.Options + [hoVisible, hoAutoResize];

    // Только один столбец с именем устройства
    with FDeviceTree.Header.Columns.Add do
    begin
      Text := 'Устройства';
      Width := 250;
    end;
  finally
    FDeviceTree.EndUpdate;
  end;
end;

procedure TVElectrNav.BuildDeviceHierarchy;
var
  RootNode: PVirtualNode;
  RootData: PNodeData;
  i: Integer;
  pathHD: string;
begin
  FDeviceTree.BeginUpdate;
  try
    // Очищаем дерево
    FDeviceTree.Clear;
    FDeviceTree.NodeDataSize := SizeOf(TNodeData);

    // Создаём корневой узел "Все устройства"
    RootNode := FDeviceTree.AddChild(nil);
    RootNode^.CheckType := ctTriStateCheckBox;
    RootData := FDeviceTree.GetNodeData(RootNode);
    RootData^.DeviceName := 'Все устройства';
    RootData^.fullpath := '';

    // Загружаем все пути устройств из FDevicesList
    for i := 0 to FDevicesList.Size - 1 do
    begin
      pathHD := Trim(FDevicesList[i].pathHD);
      if pathHD <> '' then
        AddPathToTree(RootNode, pathHD);
    end;

    FDeviceTree.FullExpand;
  finally
    FDeviceTree.EndUpdate;
  end;
end;

// ===============================================================
//  Рекурсивное добавление пути в дерево
// ===============================================================
procedure TVElectrNav.AddPathToTree(ParentNode: PVirtualNode; const Path: string);
var
  Parts: TStringList;
  i: Integer;
  CurrentNode: PVirtualNode;
  NodeData: PNodeData;
begin
  Parts := TStringList.Create;
  try
    Parts.Delimiter := '~';
    Parts.StrictDelimiter := True;
    Parts.DelimitedText := Path;

    CurrentNode := ParentNode;

    for i := 0 to Parts.Count - 1 do
    begin
      // Проверяем, есть ли уже узел с таким именем
      CurrentNode := FindOrCreateChild(CurrentNode,Path, Parts[i]);
    end;
  finally
    Parts.Free;
  end;
end;

// ===============================================================
//  Поиск существующего узла или его создание
// ===============================================================
function TVElectrNav.FindOrCreateChild(ParentNode: PVirtualNode; const HDWay,NodeName: string): PVirtualNode;
var
  ChildNode: PVirtualNode;
  NodeData: PNodeData;
begin
  // Ищем среди уже созданных детей
  ChildNode := FDeviceTree.GetFirstChild(ParentNode);
  while Assigned(ChildNode) do
  begin
    NodeData := FDeviceTree.GetNodeData(ChildNode);
    if Assigned(NodeData) and (NodeData^.DeviceName = NodeName) then
      Exit(ChildNode);

    ChildNode := FDeviceTree.GetNextSibling(ChildNode);
  end;

  // Если не нашли — создаём новый узел
  Result := FDeviceTree.AddChild(ParentNode);
  NodeData := FDeviceTree.GetNodeData(Result);
  NodeData^.DeviceName := NodeName;
  NodeData^.fullpath := HDWay;
end;

function TVElectrNav.GetNodePhysicalPath(Node: PVirtualNode): string;
var
  Cur: PVirtualNode;
  NodeData: PNodeData;
  Parts: TStringList;
  tempName: String;
begin
  Result := '';
  if not Assigned(Node) then Exit;

  Parts := TStringList.Create;
  try
    Cur := Node;
    while Assigned(Cur) do
    begin
      NodeData := FDeviceTree.GetNodeData(Cur);
      if Assigned(NodeData) then
      begin
        tempName := Trim(NodeData^.DeviceName);
        if tempName <> '' then
          Parts.Insert(0, tempName); // ключевой момент: добавляем в начало
      end;

      // дошли до верхнего уровня — выходим
      if FDeviceTree.GetNodeLevel(Cur) = 0 then
        Break;

      Cur := Cur^.Parent;
    end;

    // убираем корневую "шапку"
    if (Parts.Count > 0) and (Parts[0] = 'Все устройства') then
      Parts.Delete(0);

    Parts.StrictDelimiter := True;
    Parts.Delimiter := '~';
    Result := Parts.DelimitedText;
  finally
    Parts.Free;
  end;
end;


procedure TVElectrNav.TreeClick(Sender: TObject);
var
  Node: PVirtualNode;
  Data: PNodeData;
begin
  Node := FDeviceTree.GetFirstSelected;

  if Assigned(Node) then
  begin
    Data := FDeviceTree.GetNodeData(Node);
    if Assigned(Data) then
    begin
      // Если выбран корневой узел "Все устройства", показываем все
      if Data^.DeviceName <> 'Все устройства' then
        recordingVstDev(GetNodePhysicalPath(Node))
      else
        recordingVstDev('');
    end
    else
    begin
      // Если данных нет, показываем все устройства
      recordingVstDev('');
    end;
  end;
end;



procedure TVElectrNav.TreeGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: String);
var
  Data: PNodeData;
begin
  Data := Sender.GetNodeData(Node);
  if not Assigned(Data) then
    CellText := 'Все устройства'
  else
    CellText := Data^.DeviceName;
end;

procedure TVElectrNav.TreeGetNodeDataSize(Sender: TBaseVirtualTree;
  var NodeDataSize: Integer);
begin
  NodeDataSize := SizeOf(Pointer);
end;

procedure TVElectrNav.TreeInitNode(Sender: TBaseVirtualTree;
  ParentNode, Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
begin
  // Ничего не нужно делать
end;

procedure TVElectrNav.TreeFreeNode(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
var
  Data: PPointer;
begin
  Data := Sender.GetNodeData(Node);
  Data^ := nil;
end;

procedure TVElectrNav.CollapseAllActionExecute(Sender: TObject);
begin
  if Assigned(vstDev) then
    vstDev.FullCollapse;
end;

procedure TVElectrNav.ExpandAllActionExecute(Sender: TObject);
begin
  if Assigned(vstDev) then
    vstDev.FullExpand;
end;

//procedure TVElectrNav.FrameResize(Sender: TObject);
//begin
//  if Assigned(FDeviceTree) then
//    FDeviceTree.FullExpand;
//end;

end.
