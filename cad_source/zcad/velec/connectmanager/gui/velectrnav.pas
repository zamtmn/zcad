unit VElectrNav;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, laz.VirtualTrees, uzcdrawing, uzcdrawings, uzcinterface,
  Dialogs, ExtCtrls, ActnList, ComCtrls, Windows, fgl,
  uzvelaccessdbcontrol, uzvmcmanager, uzvmcstruct, gvector, uzccablemanager, uzcentcable, uzeentdevice, gzctnrVectorTypes, uzcvariablesutils, uzccommandsabstract, uzeentity, uzeentblockinsert, varmandef, uzeconsts;

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
    HDGroup: integer;
    PathHD: string;
    FullPathHD: string;
  end;


  { TVElectrNav }

  TVElectrNav = class(TFrame)
    ActionList1: TActionList;
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
    //procedure newVSTGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
    //  Column: TColumnIndex; TextType: TVSTTextType; var CellText: String);
  private
    // Для работы разделителя панелей
    FProportion: Double; // Пропорция ширины PanelNav относительно общей ширины
    FIsResizing: Boolean; // Флаг для предотвращения рекурсии при изменении размера
    FDevicesList: TListVElectrDevStruct; // Список устройств из TConnectionManager (вместо SQLite)
    procedure InitializeActionAndButton; // Инициализация действий и кнопок панели инструментов
    procedure InitializePanels;          // Инициализация и настройка панелей интерфейса

    procedure InitializeDeviceTree;    // Инициализация дерева устройств FDeviceTree
    procedure InitializeVstDev;        // Инициализация виртуальной таблицы устройств
    //procedure InitializeNewVST;        // Инициализация виртуальной таблицы newVST
    procedure recordingVstDev(const filterPath: string); // Заполнение vstDev из FDevicesList с фильтрацией по пути
    //procedure recordingNewVST(const filterPath: string); // Заполнение newVST из FDevicesList с фильтрацией по пути
    procedure BuildDeviceHierarchy;    // Построение иерархии дерева на основе FDevicesList
    procedure TreeGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: String);
    procedure TreeGetNodeDataSize(Sender: TBaseVirtualTree; var NodeDataSize: Integer);
    procedure TreeInitNode(Sender: TBaseVirtualTree; ParentNode, Node: PVirtualNode;
      var InitialStates: TVirtualNodeInitStates);
    procedure TreeFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure TreeClick(Sender: TObject); // Обработчик клика по дереву - фильтрует vstDev по выбранному узлу
    procedure AddAction(AName, ACaption: string; AImageIndex: string;
  AHint, AShortCut: string; AEvent: TNotifyEvent); // Создание действия и добавление в ActionList
    procedure AddPathToTree(ParentNode: PVirtualNode; const Path: string); // Рекурсивное добавление пути в дерево
    function FindOrCreateChild(ParentNode: PVirtualNode; const HDWay,NodeName: string): PVirtualNode; // Поиск или создание дочернего узла
    function GetNodePhysicalPath(Node: PVirtualNode): string; // Получение полного пути узла от корня

    procedure CurrentSelActionExecute(Sender: TObject); // Экспорт выбранных устройств в Access
    procedure AllSelActionExecute(Sender: TObject);     // Загрузка всех устройств из чертежа в память
    procedure SaveActionExecute(Sender: TObject);       // Сохранение изменений
    procedure CollapseAllActionExecute(Sender: TObject); // Свернуть все узлы дерева
    procedure ExpandAllActionExecute(Sender: TObject);   // Развернуть все узлы дерева

  public

    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
  end;

implementation

{$R *.lfm}

{ TVElectrNav }

constructor TVElectrNav.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);

  Name := 'VElectrNav';
  Caption := 'Диспетчер подключений';

  // Инициализация списка устройств (работа в памяти вместо SQLite)
  FDevicesList := TListVElectrDevStruct.Create;



    try
    // Подписываемся на событие изменения размера фрейма
    OnResize := @FrameResize;

    // Добавляем кнопки на панель инструментов
    InitializeActionAndButton;

    // Настраиваем панели интерфейса
    InitializePanels;

    // Сохраняем начальную пропорцию разделения панелей
    FProportion := 0.25; // Начальная пропорция 25%/75% (навигация/данные)
    PanelNav.Width := Round(ClientWidth * FProportion);
    FIsResizing := False;

    // Настраиваем дерево устройств (будет заполнено при вызове AllSelActionExecute)
    FDeviceTree.Parent := PanelNav;
    FDeviceTree.Align := alClient;
    FDeviceTree.NodeDataSize := SizeOf(Pointer);

    // Настраиваем виртуальную таблицу устройств
    vstDev.Parent := PanelData;
    vstDev.Align := alTop;
    vstDev.NodeDataSize := SizeOf(TGridNodeData);


    except
      on E: Exception do
        ShowMessage('Ошибка подключения TFRAME: ' + E.Message);

    end;

end;
procedure TVElectrNav.AddAction(AName, ACaption: string; AImageIndex: string;
  AHint, AShortCut: string; AEvent: TNotifyEvent);
var
  act: TAction;
begin
  act := TAction.Create(self);
  act.ActionList := ActionList1;
  act.Name := AName;
  act.Caption := ACaption;
  act.Hint := AHint;
  act.OnExecute := AEvent;
end;

// Экспорт текущих устройств в базу данных Access
procedure TVElectrNav.CurrentSelActionExecute(Sender: TObject);
var
  accessexport:TConnectionManager;
  devicesList: TListVElectrDevStruct;
begin
  accessexport := TConnectionManager.Create('');
  try
    // Получение списка устройств с чертежа
    devicesList := accessexport.GetDevicesFromDrawing;
    try
      // Экспорт подготовленного списка в базу данных Access
      accessexport.ExportDevicesListToAccess(devicesList, 'D:\ZcadDB.accdb');
    finally
      devicesList.Free;
    end;
  finally
    accessexport.Free;
  end;
end;


// Загрузка всех устройств с чертежа в память и построение иерархии
// Работает с TListVElectrDevStruct вместо SQLite
procedure TVElectrNav.AllSelActionExecute(Sender: TObject);
var
  mcManager: TConnectionManager;
begin
  mcManager := TConnectionManager.Create('');
  try
    // Шаг 1: Очищаем предыдущий список устройств
    FDevicesList.Clear;

    // Шаг 2: Получаем список всех устройств из чертежа
    FDevicesList := mcManager.GetDevicesFromDrawing;

    // Шаг 3: Сортируем устройства по иерархии
    mcManager.HierarchyBuilder.SortDeviceList(FDevicesList);

    // Шаг 4: Настраиваем дерево устройств
    FDeviceTree.Parent := PanelNav;
    FDeviceTree.Align := alClient;
    FDeviceTree.NodeDataSize := SizeOf(Pointer);

    // Настройка событий дерева для отображения иерархии
    FDeviceTree.OnGetText := @TreeGetText;
    FDeviceTree.OnGetNodeDataSize := @TreeGetNodeDataSize;
    FDeviceTree.OnInitNode := @TreeInitNode;
    FDeviceTree.OnFreeNode := @TreeFreeNode;
    FDeviceTree.OnClick := @TreeClick;

    // Шаг 5: Построение дерева на основе pathHD из FDevicesList
    InitializeDeviceTree;
    BuildDeviceHierarchy;

    // Шаг 6: Настройка виртуальной таблицы устройств
    InitializeVstDev;

    // Шаг 7: Заполнение vstDev всеми устройствами (без фильтра)
    recordingVstDev('');

    // Назначение обработчиков событий для vstDev
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
// Инициализация действий и кнопок панели инструментов
procedure TVElectrNav.InitializeActionAndButton;
var
  i:integer;
  btn: TToolButton;
begin
  try
    // Настройка панели инструментов перед созданием кнопок
    ToolBar1.Parent := PanelButton;
    ToolBar1.Height := 50;
    ToolBar1.AutoSize := false;
    ToolBar1.ShowCaptions := True;  // Показывать текст на кнопках
    ToolBar1.ButtonWidth := 40;
    ToolBar1.ButtonHeight := 40;
    ToolBar1.Images := nil; // Без изображений

    // Создаем действия для кнопок
    AddAction('actNew', '1', '0', 'Создать новый документ', 'Ctrl+N', @CurrentSelActionExecute);
    AddAction('actOpen', '*', '1', 'Открыть документ', 'Ctrl+O', @AllSelActionExecute);
    AddAction('actSave', 'Cl', '2', 'Сохранить документ', 'Ctrl+S', @SaveActionExecute);
    AddAction('actCollapseAll', '+', '3', 'Свернуть все ноды', '', @CollapseAllActionExecute);
    AddAction('actExpandAll', '-', '4', 'Развернуть все ноды', '', @ExpandAllActionExecute);

    // Создаем кнопки на панели инструментов
    for i := 0 to ActionList1.ActionCount - 1 do
    begin
      btn := TToolButton.Create(ToolBar1);
      btn.Parent := ToolBar1;
      btn.Action := ActionList1.Actions[i];
      btn.ShowHint := True;
      btn.AutoSize := False;
      btn.Width := 40;
      btn.Height := 40;
    end;

    // Обновляем размеры панели инструментов
    ToolBar1.Realign;
    ToolBar1.Invalidate;
  except
    on E: Exception do
      ShowMessage('Ошибка создания действий: ' + E.Message);
  end;
end;
// Инициализация и настройка панелей интерфейса
procedure TVElectrNav.InitializePanels;
begin
  try
      // Панель навигации (левая часть с деревом устройств)
      PanelNav.Align := alLeft;
      PanelNav.BevelOuter := bvNone;
      PanelNav.BorderSpacing.Around := 2;

      // Настройка разделителя между панелями
      panelSplitter.Align := alLeft;
      panelSplitter.Width := 8;
      panelSplitter.ResizeStyle := rsUpdate;
      panelSplitter.Color := clBtnFace;
      panelSplitter.MinSize := 100; // Минимальный размер панелей
      panelSplitter.OnMoved:=@panelSplitterMoved;

      // Панель данных (правая часть с таблицей устройств)
      panelData.Align := alClient; // Займет оставшееся пространство
      panelData.BevelOuter := bvNone;
      panelData.BorderSpacing.Around := 2;
  except
    on E: Exception do
      ShowMessage('Ошибка инициализации панелей: ' + E.Message);
  end;
end;

// Инициализация виртуальной таблицы устройств (vstDev)
procedure TVElectrNav.InitializeVstDev;
begin
  try
    vstDev.BeginUpdate;
    try
      vstDev.Header.Columns.Clear;
      vstDev.Clear;

      // Настройка опций отображения (с деревом для группировки, с выделением всей строки)
      vstDev.TreeOptions.PaintOptions :=
        vstDev.TreeOptions.PaintOptions + [toShowRoot,toShowTreeLines, toShowButtons];
      vstDev.TreeOptions.SelectionOptions :=
        vstDev.TreeOptions.SelectionOptions + [toFullRowSelect, toExtendedFocus];
      vstDev.TreeOptions.MiscOptions :=
        vstDev.TreeOptions.MiscOptions + [toEditable, toEditOnDblClick, toGridExtensions];
      vstDev.Header.Options :=
        vstDev.Header.Options + [hoVisible, hoColumnResize] - [hoAutoResize];
      vstDev.Header.AutoSizeIndex := -1;
      vstDev.Header.MainColumn := 0; // Колонка 0 содержит индикаторы дерева (+/-)

      // Колонка "Имя устройства" (редактируемая)
      with vstDev.Header.Columns.Add do
      begin
        Text := 'devname';
        Width := 100;
        Options := Options + [coAllowFocus, coEditable];
      end;

      // Колонка "Головное устройство" (редактируемая)
      with vstDev.Header.Columns.Add do
      begin
        Text := 'hdname';
        Width := 100;
        Options := Options + [coAllowFocus, coEditable];
      end;

      // Колонка "Группа" (редактируемая)
      with vstDev.Header.Columns.Add do
      begin
        Text := 'hdgroup';
        Width := 50;
        Options := Options + [coAllowFocus, coEditable];
      end;

      // Колонка "pathHD" (путь головного устройства)
      with vstDev.Header.Columns.Add do
      begin
        Text := 'pathHD';
        Width := 120;
      end;

      // Колонка "fullpathHD" (полный путь головного устройства)
      with vstDev.Header.Columns.Add do
      begin
        Text := 'fullpathHD';
        Width := 150;
      end;

      // Колонка "Редактировать" (кнопка действия)
      with vstDev.Header.Columns.Add do
      begin
        Text := 'edit';
        Width := 80;
      end;

      // Колонка "Показать" (кнопка действия) - перемещена в конец
      with vstDev.Header.Columns.Add do
      begin
        Text := 'show';
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

// Заполнение vstDev устройствами из FDevicesList с возможностью фильтрации по пути
// filterPath - путь иерархии для фильтрации (пустая строка = показать все)
// Группирует устройства по feedernum, создавая родительские узлы для каждой группы
procedure TVElectrNav.recordingVstDev(const filterPath: string);
var
    i,j,deep: integer;
    Node, GroupNode: PVirtualNode;
    NodeData: PGridNodeData;
    device: TVElectrDevStruct;
    currentFeederNum: integer;
    lastFeederNum: integer;
    isFirstDevice: boolean;
    tempName:string;

    function ProcessStrings(const Str1, Str2: string): integer;
      var
        Parts1, Parts2: TStringList;
        LastWordFromStr1: string;
        IndexInStr2, i: Integer;
      begin
        Result := -1;

        Parts1 := TStringList.Create;
        Parts2 := TStringList.Create;
        try
          // Разбиваем первую строку на части
          ExtractStrings(['~'], [], PChar(Str1), Parts1);
          if Parts1.Count = 0 then Exit;

          // Получаем последнее слово из первой строки
          LastWordFromStr1 := Parts1[Parts1.Count - 1];

          // Разбиваем вторую строку на части
          ExtractStrings(['~'], [], PChar(Str2), Parts2);
          if Parts2.Count = 0 then Exit;

          // Ищем последнее слово из первой строки во второй строке
          IndexInStr2 := -1;
          for i := 0 to Parts2.Count - 1 do
          begin
            if Parts2[i] = LastWordFromStr1 then
            begin
              IndexInStr2 := i;
              Break;
            end;
          end;

          if IndexInStr2 = -1 then Exit;

          // Определяем сколько слов осталось после найденного слова
          Result := Parts2.Count - IndexInStr2 - 1;


        finally
          Parts1.Free;
          Parts2.Free;
        end;
      end;
begin
  try
    vstDev.BeginUpdate;
    try
      vstDev.Clear;

      // Инициализация переменных для отслеживания групп
      lastFeederNum := -1;
      GroupNode := nil;
      isFirstDevice := True;

      // Проходим по всем устройствам в FDevicesList
      for i := 0 to FDevicesList.Size - 1 do
      begin
        device := FDevicesList[i];


        // Если фильтр задан, проверяем соответствие fullpathHD (не pathHD!)
        if (filterPath = '') or (device.pathHD = filterPath) then
        begin
          deep:=ProcessStrings(filterPath,device.fullpathHD);
          if (deep=0) then
             currentFeederNum := device.feedernum;

          // Если встретили новую группу (новое значение feedernum), создаём родительский узел
          if isFirstDevice or (currentFeederNum <> lastFeederNum) then
          begin
            // Создаём родительский узел группы
            GroupNode := vstDev.AddChild(nil);
            NodeData := vstDev.GetNodeData(GroupNode);

            // Заполняем данные группового узла
            NodeData^.DevName := device.headdev + '-Гр.' + IntToStr(currentFeederNum);
            NodeData^.HDName := '';
            NodeData^.HDGroup := 0;
            NodeData^.PathHD := '';
            NodeData^.FullPathHD := '';

            // Устанавливаем флаг vsHasChildren для отображения индикаторов +/-
            Include(GroupNode^.States, vsHasChildren);

            lastFeederNum := currentFeederNum;
            isFirstDevice := False;
          end;

          // Создаём дочерний узел устройства под текущей группой
          Node := vstDev.AddChild(GroupNode);
          NodeData := vstDev.GetNodeData(Node);

          // Правильное оформление ноды устройства
          tempName:='';
          for j:=0 to deep-1 do
            tempName:=tempName + ' -';

          // Заполняем данные ноды из структуры устройства
          if deep>0 then
             NodeData^.DevName := tempName+' '+device.basename + ' (Гр.' + inttostr(device.feedernum) + ')'
          else
             NodeData^.DevName := tempName+' '+device.basename;
          NodeData^.HDName := device.headdev;
          NodeData^.HDGroup := device.feedernum;
          NodeData^.PathHD := device.pathHD;
          NodeData^.FullPathHD := device.fullpathHD;
        end;
      end;

      // Разворачиваем все группы для удобства просмотра
      vstDev.FullExpand;
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
    0: CellText := NodeData^.DevName;
    1: CellText := NodeData^.HDName;
    2: CellText := inttostr(NodeData^.HDGroup);
    3: CellText := NodeData^.PathHD;
    4: CellText := NodeData^.FullPathHD;
    5: CellText := 'Ред.';
    6: CellText := 'Показать';
  end;
end;

procedure TVElectrNav.vstDevPaintText(Sender: TBaseVirtualTree;
  const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
  TextType: TVSTTextType);
begin
  if (Column = 5) or (Column = 6) then
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

  if HitInfo.HitColumn = 6 then
    ShowMessage('devname: ' + NodeData^.DevName)
  else if HitInfo.HitColumn = 5 then
    ShowMessage('Редактировать: ' + NodeData^.HDName);
end;

procedure TVElectrNav.vstDevEditing(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; var Allowed: Boolean);
begin
  // Разрешаем редактирование только для колонок 0, 1, 2 (devname, hdname, hdgroup)
  Allowed := (Column >= 0) and (Column <= 2);
end;

// Обработчик изменения текста в ячейке vstDev
// Обновляет данные в FDevicesList при редактировании
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
    0: NodeData^.DevName := NewText;
    1: NodeData^.HDName := NewText;
    2: NodeData^.HDGroup := strtoint(NewText);
    else
      Exit;
  end;

  // Обновляем данные в FDevicesList (работа с памятью вместо SQL UPDATE)
  try
    for i := 0 to FDevicesList.Size - 1 do
    begin
      device := FDevicesList.Mutable[i];
      if device^.realname = OldDevName then
      begin
        case Column of
          0: device^.realname := NewText;    // Обновление имени устройства
          1: device^.headdev := NewText;     // Обновление головного устройства
          2: begin
            device^.feedernum := strtoint(NewText);
            // HDGroup не имеет прямого соответствия в TVElectrDevStruct
            // Требуется дополнительная логика для сохранения группы
          end;
        end;
        Break;
      end;
    end;
  except
    on E: Exception do
    begin
      ShowMessage('Ошибка обновления данных: ' + E.Message);
      // Восстанавливаем старое значение при ошибке
      case Column of
        1: NodeData^.DevName := OldDevName;
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

// Обработчик изменения размера фрейма
// Сохраняет пропорции панелей при изменении размера окна
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

// Обработчик перемещения разделителя панелей
// Обновляет сохраненную пропорцию разделения
procedure TVElectrNav.panelSplitterMoved(Sender: TObject);
begin
  FProportion := PanelNav.Width / (ClientWidth - panelSplitter.Width);
end;

// ============================================================================
// Методы работы с деревом устройств (FDeviceTree)
// ============================================================================

// Инициализация структуры дерева устройств
procedure TVElectrNav.InitializeDeviceTree;
begin
  FDeviceTree.BeginUpdate;
  try
    FDeviceTree.Header.Columns.Clear;
    FDeviceTree.Clear;

    // Настройка опций отображения дерева
    FDeviceTree.TreeOptions.PaintOptions :=
      FDeviceTree.TreeOptions.PaintOptions + [toShowRoot, toShowTreeLines, toShowButtons];
    FDeviceTree.TreeOptions.SelectionOptions :=
      FDeviceTree.TreeOptions.SelectionOptions + [toFullRowSelect];
    FDeviceTree.Header.Options :=
      FDeviceTree.Header.Options + [hoVisible, hoAutoResize];

    // Единственный столбец - имя устройства в иерархии
    with FDeviceTree.Header.Columns.Add do
    begin
      Text := 'Устройства';
      Width := 250;
    end;
  finally
    FDeviceTree.EndUpdate;
  end;
end;

// Построение иерархического дерева устройств из FDevicesList
// Использует поле pathHD для построения структуры узлов
procedure TVElectrNav.BuildDeviceHierarchy;
var
  RootNode: PVirtualNode;
  RootData: PNodeData;
  i: Integer;
  pathHD: string;
begin
  FDeviceTree.BeginUpdate;
  try
    FDeviceTree.Clear;
    FDeviceTree.NodeDataSize := SizeOf(TNodeData);

    // Создаём корневой узел "Все устройства"
    RootNode := FDeviceTree.AddChild(nil);
    RootNode^.CheckType := ctTriStateCheckBox;
    RootData := FDeviceTree.GetNodeData(RootNode);
    RootData^.DeviceName := 'Все устройства';
    RootData^.fullpath := '';

    // Загружаем все пути устройств из FDevicesList и строим дерево
    for i := 0 to FDevicesList.Size - 1 do
    begin
      pathHD := Trim(FDevicesList[i].pathHD);
      if pathHD <> '' then
        AddPathToTree(RootNode, pathHD);
    end;

    // Разворачиваем все узлы дерева
    FDeviceTree.FullExpand;
  finally
    FDeviceTree.EndUpdate;
  end;
end;

// Рекурсивное добавление пути в дерево
// Path содержит иерархию устройств, разделенную символом '~'
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

    // Проходим по всем частям пути и создаем узлы
    for i := 0 to Parts.Count - 1 do
    begin
      CurrentNode := FindOrCreateChild(CurrentNode, Path, Parts[i]);
    end;
  finally
    Parts.Free;
  end;
end;

// Поиск существующего дочернего узла или его создание
// HDWay - полный путь иерархии, NodeName - имя текущего узла
function TVElectrNav.FindOrCreateChild(ParentNode: PVirtualNode; const HDWay,NodeName: string): PVirtualNode;
var
  ChildNode: PVirtualNode;
  NodeData: PNodeData;
begin
  // Ищем среди уже созданных дочерних узлов
  ChildNode := FDeviceTree.GetFirstChild(ParentNode);
  while Assigned(ChildNode) do
  begin
    NodeData := FDeviceTree.GetNodeData(ChildNode);
    if Assigned(NodeData) and (NodeData^.DeviceName = NodeName) then
      Exit(ChildNode); // Узел уже существует

    ChildNode := FDeviceTree.GetNextSibling(ChildNode);
  end;

  // Если не нашли - создаём новый узел
  Result := FDeviceTree.AddChild(ParentNode);
  NodeData := FDeviceTree.GetNodeData(Result);
  NodeData^.DeviceName := NodeName;
  NodeData^.fullpath := HDWay;
end;

// Получение полного пути узла в дереве от корня
// Возвращает путь в формате "узел1~узел2~узел3" (без корневого "Все устройства")
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
          Parts.Insert(0, tempName); // Добавляем в начало для правильного порядка
      end;

      // Дошли до верхнего уровня - выходим
      if FDeviceTree.GetNodeLevel(Cur) = 0 then
        Break;

      Cur := Cur^.Parent;
    end;

    // Убираем корневой узел "Все устройства" из пути
    if (Parts.Count > 0) and (Parts[0] = 'Все устройства') then
      Parts.Delete(0);

    Parts.StrictDelimiter := True;
    Parts.Delimiter := '~';
    Result := Parts.DelimitedText;
  finally
    Parts.Free;
  end;
end;

// Обработчик клика по узлу дерева
// Фильтрует таблицы vstDev и newVST по выбранному пути иерархии
procedure TVElectrNav.TreeClick(Sender: TObject);
var
  Node: PVirtualNode;
  Data: PNodeData;
  filterPath: string;
begin
  Node := FDeviceTree.GetFirstSelected;

  if Assigned(Node) then
  begin
    Data := FDeviceTree.GetNodeData(Node);
    if Assigned(Data) then
    begin
      // Если выбран корневой узел "Все устройства", показываем все устройства
      if Data^.DeviceName <> 'Все устройства' then
        filterPath := GetNodePhysicalPath(Node)
      else
        filterPath := '';

      // Фильтруем обе таблицы
      recordingVstDev(filterPath);
    end
    else
    begin
      // Если данных нет, показываем все устройства
      recordingVstDev('');
    end;
  end;
end;

// Получение текста для отображения в ячейке дерева
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

// Установка размера данных узла дерева
procedure TVElectrNav.TreeGetNodeDataSize(Sender: TBaseVirtualTree;
  var NodeDataSize: Integer);
begin
  NodeDataSize := SizeOf(Pointer);
end;

// Инициализация нового узла дерева
procedure TVElectrNav.TreeInitNode(Sender: TBaseVirtualTree;
  ParentNode, Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
begin
  // Специальная инициализация не требуется
end;

// Освобождение данных узла дерева
procedure TVElectrNav.TreeFreeNode(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
var
  Data: PPointer;
begin
  Data := Sender.GetNodeData(Node);
  Data^ := nil;
end;

// Свернуть все узлы в таблице устройств
procedure TVElectrNav.CollapseAllActionExecute(Sender: TObject);
begin
  if Assigned(vstDev) then
    vstDev.FullCollapse;
end;

// Развернуть все узлы в таблице устройств
procedure TVElectrNav.ExpandAllActionExecute(Sender: TObject);
begin
  if Assigned(vstDev) then
    vstDev.FullExpand;
end;

end.
