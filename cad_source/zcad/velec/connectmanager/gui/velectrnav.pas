unit VElectrNav;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Types, laz.VirtualTrees, uzcdrawing, uzcdrawings, uzcinterface,
  Dialogs, ExtCtrls, ActnList, ComCtrls, Windows, fgl, Menus,
  uzvelaccessdbcontrol, uzvmcmanager, uzvmcstruct, uzvmcdrawing, gvector, uzccablemanager, uzcentcable, uzeentdevice, gzctnrVectorTypes, uzcvariablesutils, uzccommandsabstract, uzeentity, uzeentblockinsert, varmandef, uzeconsts, uzvvstdevpopulator, uzvmcdevtoexcel, uzvmcphaseoptimizer;

type

  PNodeData = ^TNodeData;
  TNodeData = record
    DeviceName: string;
    ConnectedTo: string;
    fullpath: string;
    Group: string;
    CanBeNode: Boolean;
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
    procedure vstDevDblClick(Sender: TObject);
    procedure vstDevMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure vstDevContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure vstDevEditing(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; var Allowed: Boolean);
    procedure vstDevNewText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; const NewText: AnsiString);
    procedure ContainerMenuItemClick(Sender: TObject);
    //procedure newVSTGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
    //  Column: TColumnIndex; TextType: TVSTTextType; var CellText: String);
  private
    // Для работы разделителя панелей
    FProportion: Double; // Пропорция ширины PanelNav относительно общей ширины
    FIsResizing: Boolean; // Флаг для предотвращения рекурсии при изменении размера
    FDevicesList: TListVElectrDevStruct; // Список устройств из TConnectionManager (вместо SQLite)
    FContainerPopupMenu: TPopupMenu; // Popup menu для родительских нод (контейнеров)
    FRightClickedNode: PVirtualNode; // Нода, на которой был вызван контекстное меню (правый клик)
    // Для различения одинарного и двойного щелчка
    FClickTimer: TTimer; // Таймер для задержки обработки одинарного щелчка
    FPendingClickNode: PVirtualNode; // Нода, ожидающая обработки одинарного щелчка
    FPendingClickColumn: TColumnIndex; // Колонка, ожидающая обработки одинарного щелчка
    FCurrentFilterPath: string; // Текущий путь фильтрации для vstDev (для сохранения состояния после оптимизации)
    procedure InitializeActionAndButton; // Инициализация действий и кнопок панели инструментов
    procedure InitializePanels;          // Инициализация и настройка панелей интерфейса
    procedure InitializeContainerPopupMenu; // Инициализация popup menu для контейнеров
    procedure ClickTimerExecute(Sender: TObject); // Обработчик таймера для отложенного одинарного щелчка

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
     procedure CurrentSelSQLiteActionExecute(Sender: TObject); // Экспорт выбранных устройств в SQLite
     procedure AllSelActionExecute(Sender: TObject);     // Загрузка всех устройств из чертежа в память
    procedure SaveActionExecute(Sender: TObject);       // Сохранение изменений
    procedure CollapseAllActionExecute(Sender: TObject); // Свернуть все узлы дерева
    procedure ExpandAllActionExecute(Sender: TObject);   // Развернуть все узлы дерева
    procedure ExportToExcelActionExecute(Sender: TObject); // Экспорт структуры устройств в Excel
    procedure OptimizePhasesActionExecute(Sender: TObject); // Оптимизация распределения мощности по фазам

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

  // Инициализация popup menu для контейнеров
  InitializeContainerPopupMenu;

  // Инициализация таймера для различения одинарного и двойного щелчка
  FClickTimer := TTimer.Create(Self);
  FClickTimer.Enabled := False;
  FClickTimer.Interval := 150; // 300 мс задержка для различения кликов
  FClickTimer.OnTimer := @ClickTimerExecute;
  FPendingClickNode := nil;
  FPendingClickColumn := -1;

  // Инициализация переменной для хранения ноды, на которой был вызван контекстное меню
  FRightClickedNode := nil;

  // Инициализация текущего пути фильтрации (пустая строка = показать все)
  FCurrentFilterPath := '';

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
const
  sep='.';
var
  accessexport:TConnectionManager;
  devicesList: TListVElectrDevStruct;
  i:integer;
begin
  accessexport := TConnectionManager.Create('');
  try
    // Получение списка устройств с чертежа
    devicesList := accessexport.GetDevicesFromDrawing;

    for i := 0 to devicesList.Size - 1 do
      //zcUI.TextMessage('beforeSort= '
      //                            + ' pathHD=' + devicesList[i].pathHD
      //                            + ' Sort1=' + inttostr(devicesList[i].Sort1)
      //                            + ' Sort2=' + inttostr(devicesList[i].Sort2)
      //                            + ' Sort2name=' + devicesList[i].Sort2name
      //                            + ' Sort3=' + inttostr(devicesList[i].Sort3)
      //                            + ' Sort3name=' + devicesList[i].Sort3name
      //                            + ' Power=' + floattostr(devicesList[i].Power)
      //                            + ' basename=' + devicesList[i].basename
      //                            + ' NEWname=' + devicesList[i].basename + sep
      //                            + devicesList[i].headdev + sep
      //                            + inttostr(devicesList[i].feedernum) + sep
      //                            + inttostr(devicesList[i].numconnect) + sep
      //                            , TMWOHistoryOut);
    // Шаг 3: Сортируем устройства по иерархии
    accessexport.HierarchyBuilder.SortDeviceList(devicesList);
    for i := 0 to devicesList.Size - 1 do
      //zcUI.TextMessage('afterSort= '
      //                            + ' pathHD=' + devicesList[i].pathHD
      //                            + ' Sort1=' + inttostr(devicesList[i].Sort1)
      //                            + ' Sort2=' + inttostr(devicesList[i].Sort2)
      //                            + ' Sort2name=' + devicesList[i].Sort2name
      //                            + ' Sort3=' + inttostr(devicesList[i].Sort3)
      //                            + ' Sort3name=' + devicesList[i].Sort3name
      //                            + ' Power=' + floattostr(devicesList[i].Power)
      //                            + ' basename=' + devicesList[i].basename
      //                            + ' NEWname=' + devicesList[i].basename + sep
      //                            + devicesList[i].headdev + sep
      //                            + inttostr(devicesList[i].feedernum) + sep
      //                            + inttostr(devicesList[i].numconnect) + sep
      //                            , TMWOHistoryOut);


    // Шаг 4: Затем заполнить поля номер устройства в фидере
    accessexport.HierarchyBuilder.SetNumDevinFeeder(devicesList);

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

 // Экспорт текущих устройств в базу данных SQLite
 procedure TVElectrNav.CurrentSelSQLiteActionExecute(Sender: TObject);
 const
   sep='.';
 var
   sqliteexport:TConnectionManager;
   devicesList: TListVElectrDevStruct;
   i:integer;
 begin
   sqliteexport := TConnectionManager.Create('');
   try
     // Получение списка устройств с чертежа
     devicesList := sqliteexport.GetDevicesFromDrawing;

     for i := 0 to devicesList.Size - 1 do
       //zcUI.TextMessage('beforeSort= '
       //                            + ' pathHD=' + devicesList[i].pathHD
       //                            + ' Sort1=' + inttostr(devicesList[i].Sort1)
       //                            + ' Sort2=' + inttostr(devicesList[i].Sort2)
       //                            + ' Sort2name=' + devicesList[i].Sort2name
       //                            + ' Sort3=' + inttostr(devicesList[i].Sort3)
       //                            + ' Sort3name=' + devicesList[i].Sort3name
       //                            + ' Power=' + floattostr(devicesList[i].Power)
       //                            + ' basename=' + devicesList[i].basename
       //                            + ' NEWname=' + devicesList[i].basename + sep
       //                            + devicesList[i].headdev + sep
       //                            + inttostr(devicesList[i].feedernum) + sep
       //                            + inttostr(devicesList[i].numconnect) + sep
       //                            , TMWOHistoryOut);
     // Шаг 3: Сортируем устройства по иерархии
     sqliteexport.HierarchyBuilder.SortDeviceList(devicesList);
     for i := 0 to devicesList.Size - 1 do
       //zcUI.TextMessage('afterSort= '
       //                            + ' pathHD=' + devicesList[i].pathHD
       //                            + ' Sort1=' + inttostr(devicesList[i].Sort1)
       //                            + ' Sort2=' + inttostr(devicesList[i].Sort2)
       //                            + ' Sort2name=' + devicesList[i].Sort2name
       //                            + ' Sort3=' + inttostr(devicesList[i].Sort3)
       //                            + ' Sort3name=' + devicesList[i].Sort3name
       //                            + ' Power=' + floattostr(devicesList[i].Power)
       //                            + ' basename=' + devicesList[i].basename
       //                            + ' NEWname=' + devicesList[i].basename + sep
       //                            + devicesList[i].headdev + sep
       //                            + inttostr(devicesList[i].feedernum) + sep
       //                            + inttostr(devicesList[i].numconnect) + sep
       //                            , TMWOHistoryOut);


     // Шаг 4: Затем заполнить поля номер устройства в фидере
     sqliteexport.HierarchyBuilder.SetNumDevinFeeder(devicesList);

     try
       // Экспорт подготовленного списка в базу данных SQLite
       sqliteexport.ExportDevicesListToSQLite(devicesList);
     finally
       devicesList.Free;
     end;
   finally
     sqliteexport.Free;
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
    vstDev.OnDblClick := @vstDevDblClick;
    vstDev.OnMouseUp := @vstDevMouseUp;
    vstDev.OnContextPopup := @vstDevContextPopup;
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
     AddAction('actSQLiteExport', 'SQL', '0.5', 'Экспорт в SQLite', 'Ctrl+Shift+S', @CurrentSelSQLiteActionExecute);
     AddAction('actOpen', '*', '1', 'Открыть документ', 'Ctrl+O', @AllSelActionExecute);
    AddAction('actSave', 'Cl', '2', 'Сохранить документ', 'Ctrl+S', @SaveActionExecute);
    AddAction('actCollapseAll', '+', '3', 'Свернуть все ноды', '', @CollapseAllActionExecute);
    AddAction('actExpandAll', '-', '4', 'Развернуть все ноды', '', @ExpandAllActionExecute);
    AddAction('actExportToExcel', 'XLS', '5', 'Экспорт в Excel', '', @ExportToExcelActionExecute);
    AddAction('actOptimizePhases', 'Φ', '6', 'Оптимизация распределения мощности по фазам', '', @OptimizePhasesActionExecute);

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

      // Колонка "Реальное имя" (редактируемая)
      with vstDev.Header.Columns.Add do
      begin
        Text := 'realname';
        Width := 100;
        Options := Options + [coAllowFocus, coEditable];
      end;

      // Колонка "Мощность" (редактируемая)
      with vstDev.Header.Columns.Add do
      begin
        Text := 'Power';
        Width := 80;
        Options := Options + [coAllowFocus, coEditable];
      end;

      // Колонка "cosF" (редактируемая)
      with vstDev.Header.Columns.Add do
      begin
        Text := 'cosF';
        Width := 80;
        Options := Options + [coAllowFocus, coEditable];
      end;

      // Колонка "Напряжение" (редактируемая)
      with vstDev.Header.Columns.Add do
      begin
        Text := 'Voltage';
        Width := 80;
        Options := Options + [coAllowFocus, coEditable];
      end;

      // Колонка "Phase" (редактируемая)
      with vstDev.Header.Columns.Add do
      begin
        Text := 'Phase';
        Width := 80;
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
// Использует класс TVstDevPopulator для выполнения операции
procedure TVElectrNav.recordingVstDev(const filterPath: string);
type
  TDeviceGroup = record
    basename: string;
    realname: string;
    power: double;
    cosf: double;
    voltage: integer;
    phase: string;
    devices: array of integer; // индексы устройств в этой группе
  end;
var
  populator: TVstDevPopulator;
begin
  try
    // Сохраняем текущий путь фильтрации для последующего восстановления состояния
    FCurrentFilterPath := filterPath;

    populator := TVstDevPopulator.Create(vstDev, FDevicesList);
    try
      populator.PopulateTree(filterPath);
      // Заполняем суммарную мощность для контейнеров 1-го и 2-го уровня
      populator.FillContainersPower;
      // Заполняем количество устройств в devname для контейнеров 1-го и 2-го уровня
      populator.FillContainersDeviceCount;
    finally
      populator.Free;
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
  nodeLevel: integer;
begin
  NodeData := Sender.GetNodeData(Node);
  if not Assigned(NodeData) then Exit;

  nodeLevel := Sender.GetNodeLevel(Node);

  case Column of
    0: CellText := NodeData^.DevName;
    1: CellText := NodeData^.RealName;
    2: if NodeData^.Power <> 0.0 then CellText := FloatToStr(NodeData^.Power) else CellText := '';
    3: if NodeData^.CosF <> 0.0 then CellText := FloatToStr(NodeData^.CosF) else CellText := '';
    4: begin
         // Для узлов 1-го уровня: если Voltage = 0, показываем "Different"
         if (nodeLevel = 0) and (NodeData^.Voltage = 0) then
           CellText := 'Different'
         else if NodeData^.Voltage <> 0 then
           CellText := IntToStr(NodeData^.Voltage)
         else
           CellText := '';
       end;
    5: CellText := NodeData^.Phase;
    6: CellText := NodeData^.HDName;
    7: CellText := inttostr(NodeData^.HDGroup);
    8: CellText := NodeData^.PathHD;
    9: CellText := NodeData^.FullPathHD;
    10: CellText := 'Ред.';
    11: CellText := 'Показать';
  end;
end;

procedure TVElectrNav.vstDevPaintText(Sender: TBaseVirtualTree;
  const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
  TextType: TVSTTextType);
begin
  if (Column = 10) or (Column = 11) then
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

  // Handle existing button columns (10 and 11)
  if HitInfo.HitColumn = 11 then
    ShowMessage('devname: ' + NodeData^.DevName)
  else if HitInfo.HitColumn = 10 then
    ShowMessage('Редактировать: ' + NodeData^.HDName)
  else
  begin
    // For device nodes (nodes without children), delay showing "один щелчок" message
    // to allow double-click detection
    // Parent nodes (containers) continue to work as usual (expand/collapse)
    if not vstDev.HasChildren[Node] then
    begin
      // Stop any pending click timer
      FClickTimer.Enabled := False;

      // Save click information for delayed processing
      FPendingClickNode := Node;
      FPendingClickColumn := HitInfo.HitColumn;

      // Start timer to execute single-click action after delay
      FClickTimer.Enabled := True;
    end;
  end;
end;

procedure TVElectrNav.vstDevDblClick(Sender: TObject);
var
  Node: PVirtualNode;
  NodeData: PGridNodeData;
  HitInfo: THitInfo;
  P: TPoint;
  deviceCollector: TDeviceDataCollector;
begin
  // Останавливаем таймер одинарного щелчка, чтобы он не сработал
  FClickTimer.Enabled := False;

  P := vstDev.ScreenToClient(Mouse.CursorPos);
  vstDev.GetHitTestInfoAt(P.X, P.Y, True, HitInfo);

  if not Assigned(HitInfo.HitNode) then Exit;

  Node := HitInfo.HitNode;
  NodeData := vstDev.GetNodeData(Node);
  if not Assigned(NodeData) then Exit;

  // Для узлов-устройств (узлов без дочерних элементов) выполняем зуммирование
  // Родительские узлы (контейнеры) продолжают работать как обычно
  if not vstDev.HasChildren[Node] then
  begin
    // Проверяем, что у устройства есть корректный zcadId
    if NodeData^.ZcadId > 0 then
    begin
      // Создаем коллектор устройств для выполнения зуммирования
      deviceCollector := TDeviceDataCollector.Create;
      try
        // Зуммируем на устройство по его zcadId
        deviceCollector.ZoomToDeviceByZcadId(NodeData^.ZcadId);
      finally
        deviceCollector.Free;
      end;
    end;
  end;
end;

procedure TVElectrNav.vstDevMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  Node: PVirtualNode;
  HitInfo: THitInfo;
  P: TPoint;
begin
  // Обработка правого клика мыши
  if Button = mbRight then
  begin
    vstDev.GetHitTestInfoAt(X, Y, True, HitInfo);

    if not Assigned(HitInfo.HitNode) then Exit;

    Node := HitInfo.HitNode;

    // Показываем popup menu только для родительских нод (контейнеров)
    // Родительские ноды имеют дочерние элементы
    if vstDev.HasChildren[Node] then
    begin
      // Сохраняем ссылку на ноду, на которой был вызван контекстное меню
      FRightClickedNode := Node;

      P := vstDev.ClientToScreen(Point.Create(X, Y));
      FContainerPopupMenu.Popup(P.X, P.Y);
    end;
  end;
end;

procedure TVElectrNav.vstDevContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
begin
  // Prevent the standard AnchorDocking context menu from appearing
  // We handle the context menu ourselves in vstDevMouseUp
  Handled := True;
end;

procedure TVElectrNav.InitializeContainerPopupMenu;
var
  MenuItem: TMenuItem;
begin
  // Create popup menu for container nodes
  FContainerPopupMenu := TPopupMenu.Create(Self);

  // Add single menu item
  MenuItem := TMenuItem.Create(FContainerPopupMenu);
  MenuItem.Caption := 'Команда правый щелчок';
  MenuItem.OnClick := @ContainerMenuItemClick;
  FContainerPopupMenu.Items.Add(MenuItem);
end;

// Обработчик команды "Выделить все устройства в ноде"
// Вызывается при клике на пункт меню контейнера
// Собирает все zcadId устройств внутри выбранной ноды и выделяет их на чертеже
procedure TVElectrNav.ContainerMenuItemClick(Sender: TObject);
var
  deviceCollector: TDeviceDataCollector;
  zcadIds: specialize TVector<integer>;
  zcadIdsArray: array of integer;
  i: integer;
begin
  // Проверяем, что нода была установлена при вызове контекстного меню
  if not Assigned(FRightClickedNode) then
  begin
    ShowMessage('Ошибка: нода не выбрана');
    Exit;
  end;

  // Проверяем, что это действительно контейнер (имеет дочерние элементы)
  if not vstDev.HasChildren[FRightClickedNode] then
  begin
    ShowMessage('Ошибка: выбранная нода не является контейнером');
    Exit;
  end;

  try
    // Собираем все zcadId устройств внутри выбранной ноды
    zcadIds := CollectDeviceZcadIdsInNode(vstDev, FRightClickedNode);
    try
      // Проверяем, что внутри ноды есть устройства
      if zcadIds.Size = 0 then
      begin
        ShowMessage('Внутри выбранной ноды нет устройств');
        Exit;
      end;

      // Конвертируем вектор в массив для передачи в процедуру выделения
      SetLength(zcadIdsArray, zcadIds.Size);
      for i := 0 to zcadIds.Size - 1 do
      begin
        zcadIdsArray[i] := zcadIds[i];
      end;

      // Создаем коллектор устройств для выполнения выделения на чертеже
      deviceCollector := TDeviceDataCollector.Create;
      try
        // Выделяем все устройства по их zcadId на чертеже
        deviceCollector.SelectDevicesByZcadIds(zcadIdsArray);
      finally
        deviceCollector.Free;
      end;

    finally
      zcadIds.Free;
    end;
  except
    on E: Exception do
      ShowMessage('Ошибка при выделении устройств: ' + E.Message);
  end;
end;

procedure TVElectrNav.vstDevEditing(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; var Allowed: Boolean);
begin
  // Разрешаем редактирование для колонок 0-7 (devname, realname, power, cosF, voltage, phase, hdname, hdgroup)
  Allowed := (Column >= 0) and (Column <= 7);
end;

// Обработчик таймера для выполнения отложенного одинарного щелчка
// Вызывается через 300мс после клика, если не произошел двойной щелчок
procedure TVElectrNav.ClickTimerExecute(Sender: TObject);
var
  NodeData: PGridNodeData;
  deviceCollector: TDeviceDataCollector;
begin
  // Отключаем таймер
  FClickTimer.Enabled := False;

  // Проверяем, что нода для обработки еще установлена
  if Assigned(FPendingClickNode) then
  begin
    // Получаем данные узла
    NodeData := vstDev.GetNodeData(FPendingClickNode);
    if Assigned(NodeData) and (NodeData^.ZcadId > 0) then
    begin
      // Создаем коллектор устройств для выполнения выделения
      deviceCollector := TDeviceDataCollector.Create;
      try
        // Выделяем устройство по его zcadId на чертеже
        //ShowMessage('zcadid: ' + inttostr(NodeData^.ZcadId));
        deviceCollector.SelectDeviceByZcadId(NodeData^.ZcadId);
      finally
        deviceCollector.Free;
      end;
    end;

    // Очищаем состояние
    FPendingClickNode := nil;
    FPendingClickColumn := -1;
  end;
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
    1: NodeData^.RealName := NewText;
    2: NodeData^.Power := StrToFloatDef(NewText, 0.0);
    3: NodeData^.CosF := StrToFloatDef(NewText, 0.0);
    4: NodeData^.Voltage := StrToIntDef(NewText, 0);
    5: NodeData^.Phase := NewText;
    6: NodeData^.HDName := NewText;
    7: NodeData^.HDGroup := StrToIntDef(NewText, 0);
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
          0: device^.basename := NewText;      // Обновление базового имени устройства
          1: device^.realname := NewText;      // Обновление реального имени устройства
          2: device^.power := StrToFloatDef(NewText, 0.0);  // Обновление мощности
          3: device^.cosfi := StrToFloatDef(NewText, 0.0);  // Обновление cosfi
          4: device^.voltage := StrToIntDef(NewText, 0);    // Обновление напряжения
          5: device^.phase := NewText;         // Обновление фазы
          6: device^.headdev := NewText;       // Обновление головного устройства
          7: device^.feedernum := StrToIntDef(NewText, 0);  // Обновление номера фидера
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

// Экспорт структуры устройств в Excel
// Использует существующий класс TStandardDeviceExporter для создания файла Excel
procedure TVElectrNav.ExportToExcelActionExecute(Sender: TObject);
var
  SaveDialog: TSaveDialog;
  exporter: TStandardDeviceExporter;
  success: Boolean;
begin
  // Проверяем, что список устройств загружен
  if FDevicesList.Size = 0 then
  begin
    ShowMessage('Список устройств пуст. Сначала загрузите устройства из чертежа, нажав кнопку "*".');
    Exit;
  end;

  // Создаем диалог сохранения файла
  SaveDialog := TSaveDialog.Create(nil);
  try
    SaveDialog.Title := 'Экспорт устройств в Excel';
    SaveDialog.Filter := 'Файлы Excel (*.xlsx)|*.xlsx|Все файлы (*.*)|*.*';
    SaveDialog.DefaultExt := 'xlsx';
    SaveDialog.FileName := 'devices_export.xlsx';
    SaveDialog.Options := SaveDialog.Options + [ofOverwritePrompt];

    // Показываем диалог выбора файла
    if SaveDialog.Execute then
    begin
      // Создаем экспортер
      exporter := TStandardDeviceExporter.Create;
      try
        // Выполняем экспорт
        success := exporter.ExportToFile(FDevicesList, SaveDialog.FileName);

        // Показываем результат
        if success then
          ShowMessage('Экспорт завершен успешно!' + LineEnding +
                     'Файл сохранен: ' + SaveDialog.FileName)
        else
          ShowMessage('Ошибка при экспорте устройств в Excel.' + LineEnding +
                     'Проверьте логи для получения дополнительной информации.');
      finally
        exporter.Free;
      end;
    end;
  finally
    SaveDialog.Free;
  end;
end;

destructor TVElectrNav.Destroy;
begin
  // Останавливаем и освобождаем таймер
  if Assigned(FClickTimer) then
  begin
    FClickTimer.Enabled := False;
    FClickTimer.Free;
  end;

  // Освобождаем popup menu
  if Assigned(FContainerPopupMenu) then
    FContainerPopupMenu.Free;

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

// Оптимизация распределения мощности по фазам
// Вызывает класс TPhaseOptimizer для оптимального распределения групп устройств по фазам A, B, C
// Оптимизирует только устройства, которые сейчас отображаются в vstDev
procedure TVElectrNav.OptimizePhasesActionExecute(Sender: TObject);
var
  optimizer: TPhaseOptimizer;
  vstDevDevices: TListVElectrDevStruct;
begin
  // Проверяем, что список устройств загружен
  if FDevicesList.Size = 0 then
  begin
    ShowMessage('Список устройств пуст. Сначала загрузите устройства из чертежа, нажав кнопку "*".');
    Exit;
  end;

  try
    // Получаем список устройств, которые сейчас отображаются в vstDev
    vstDevDevices := CollectDevicesFromVstDev(vstDev, FDevicesList);
    try
      // Проверяем, что в vstDev есть устройства
      if vstDevDevices.Size = 0 then
      begin
        ShowMessage('В таблице устройств нет отображаемых устройств для оптимизации.');
        Exit;
      end;

      // Создаем оптимизатор и запускаем процесс оптимизации
      // Передаем только устройства из vstDev вместо всего FDevicesList
      optimizer := TPhaseOptimizer.Create(vstDevDevices);
      try
        // Выполняем оптимизацию распределения по фазам
        optimizer.OptimizePhases;

        // Обновляем отображение vstDev после оптимизации
        // ВАЖНО: Используем FCurrentFilterPath для сохранения текущего состояния дерева
        // Это предотвращает сброс выбранного фильтра и потерю выгрузки vstDev
        recordingVstDev(FCurrentFilterPath);

        ShowMessage('Оптимизация распределения по фазам завершена!' + LineEnding +
                   'Результаты выведены в командную строку zcUI.' + LineEnding +
                   'Таблица устройств обновлена.');
      finally
        optimizer.Free;
      end;
    finally
      vstDevDevices.Free;
    end;
  except
    on E: Exception do
      ShowMessage('Ошибка при оптимизации распределения по фазам: ' + E.Message);
  end;
end;

end.
