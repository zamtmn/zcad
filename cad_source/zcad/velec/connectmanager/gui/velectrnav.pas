unit VElectrNav;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls,Graphics,  laz.VirtualTrees, SQLite3Conn, SQLDB, DB,uzcdrawing,uzcdrawings,uzvmcdbconsts,uzcinterface,
  Dialogs, ExtCtrls, BufDataset,  DBGrids, Grids, ActnList, ComCtrls, Windows,fgl,odbcconn,
  uzvelaccessdbcontrol,uzvmcmanager,uzvmanagerconnect,uzvelcreatetempdb,uzvmcstruct,gvector,uzccablemanager,uzcentcable,uzeentdevice,gzctnrVectorTypes,uzcvariablesutils,uzccommandsabstract,uzeentity,uzeentblockinsert,varmandef,uzeconsts,uzvelcontroltempdb;

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
    SQLite3Connection: TSQLite3Connection;
    SQLQuery: TSQLQuery;

    SQLTransaction: TSQLTransaction;
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
    procedure InitializeActionAndButton; //инициализация и настройка кнопок
    procedure InitializePanels;          //инициализация и настройка панелей

    procedure InitializeDatabase;
    procedure InitializeDeviceTree;
    procedure InitializeBufDataset;
    procedure InitializeVstDev;
    procedure recordingVstDev(qry:string);
    procedure BuildDeviceHierarchy;
    procedure TreeGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: String);
    procedure TreeGetNodeDataSize(Sender: TBaseVirtualTree; var NodeDataSize: Integer);
    procedure TreeInitNode(Sender: TBaseVirtualTree; ParentNode, Node: PVirtualNode;
      var InitialStates: TVirtualNodeInitStates);
    procedure TreeFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure TreeClick(Sender: TObject);
    function HasChildren(const DeviceName: string): Boolean;
    function GetDatabasePath: String;
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
      flagConnectDB:boolean;

implementation

{$R *.lfm}

{ TVElectrNav }

constructor TVElectrNav.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  //ShowMessage('Активировался TFRAME: ');

  Name := 'VElectrNav';
  Caption := 'Диспетчер подключений';



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

    flagConnectDB:=false;
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

function IsDatabaseLocked(const DatabaseName: string): Boolean;
var
  FileHandle: THandle;
begin
  Result := False;
  try
    // Пытаемся открыть файл для записи (это проверяет блокировку)
    FileHandle := FileOpen(DatabaseName, fmOpenWrite or fmShareExclusive);
    if FileHandle <> THandle(-1) then
    begin
      FileClose(FileHandle);
      // Файл не заблокирован
      Result := False;
    end
    else
    begin
      // Файл заблокирован
      Result := True;
    end;
  except
    Result := True;
  end;
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
  devicesList: TListVElectrDevStruct;
begin
  //Destroy;
  if flagConnectDB then
    SQLite3Connection.Close;

  // 1. Взаимодействие с uzvmcmanager
  mcManager := TConnectionManager.Create('');
  try
    // 2. Получить список всех устройств GetDevicesFromDrawing
    devicesList := mcManager.GetDevicesFromDrawing;
    try
      // 3. Отсортировать их HierarchyBuilder.SortDeviceList
      mcManager.HierarchyBuilder.SortDeviceList(devicesList);

      uzvelcreatetempdb.createElectricalTempDB;
      uzvelcontroltempdb.addOnlyWayHDandFullWay;
      //uzvmanagerconnect.managerconnectexecute;

         // Инициализация компонентов базы данных
         //ShowMessage('1 ');
      if not flagConnectDB then
      begin
          SQLite3Connection := TSQLite3Connection.Create(Self);
          SQLTransaction := TSQLTransaction.Create(Self);
          SQLQuery := TSQLQuery.Create(Self);
      end;
       //ShowMessage('2 ');

      SQLite3Connection.Transaction := SQLTransaction;
      SQLTransaction.Database := SQLite3Connection;
      SQLQuery.Database := SQLite3Connection;

        // Инициализация базы данных
      InitializeDatabase;
      flagConnectDB:=true;

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
      // 2. Настройка BufDataset

      InitializeBufDataset;
      //Привязываем к источнику данных
      dsGridDev.DataSet := bufGridDev;
      //ShowMessage('открыть файл...');

      // 3. Настройка vstDev
      InitializeVstDev;
                                        //ShowMessage('открыть файл...');
      // 5. При выделении ноды в FDeviceTree, должна выгружаться в vstDev
      // (это обрабатывается в TreeClick, который уже реализован)
      recordingVstDev('SELECT * FROM dev');

      vstDev.OnGetText := @vstDevGetText;
      vstDev.OnPaintText := @vstDevPaintText;
      vstDev.OnClick := @vstDevClick;
      vstDev.OnEditing := @vstDevEditing;
      vstDev.OnNewText := @vstDevNewText;

      //ShowMessage('открыть файл...');
    finally
      devicesList.Free;
    end;
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

procedure TVElectrNav.recordingVstDev(qry:string);
var
    i:integer;
    writeQuery: TSQLQuery;
    Node: PVirtualNode;
    NodeData: PGridNodeData;
begin
  try
    writeQuery := TSQLQuery.Create(nil);
    writeQuery.Database := SQLite3Connection;
    writeQuery.SQL.Text := qry;
    writeQuery.Open;
    writeQuery.First;

    vstDev.BeginUpdate;
    try
      vstDev.Clear;

      while not writeQuery.EOF do
      begin
        Node := vstDev.AddChild(nil);
        NodeData := vstDev.GetNodeData(Node);

        NodeData^.DevName := writeQuery.FieldByName('devname').AsString;
        NodeData^.HDName := writeQuery.FieldByName('hdname').AsString;
        NodeData^.HDGroup := writeQuery.FieldByName('hdgroup').AsString;

        writeQuery.Next;
      end;
    finally
      vstDev.EndUpdate;
    end;

    writeQuery.Close;
    writeQuery.Free;
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
  UpdateQuery: TSQLQuery;
  FieldName: String;
  OldDevName: String;
begin
  NodeData := Sender.GetNodeData(Node);
  if not Assigned(NodeData) then Exit;

  // Сохраняем старое значение devname для WHERE условия
  OldDevName := NodeData^.DevName;

  // Определяем какое поле обновляем
  case Column of
    1: begin
         FieldName := 'devname';
         NodeData^.DevName := NewText;
       end;
    2: begin
         FieldName := 'hdname';
         NodeData^.HDName := NewText;
       end;
    3: begin
         FieldName := 'hdgroup';
         NodeData^.HDGroup := NewText;
       end;
    else
      Exit;
  end;

  // Обновляем данные в базе
  try
    UpdateQuery := TSQLQuery.Create(nil);
    try
      UpdateQuery.Database := SQLite3Connection;
      UpdateQuery.Transaction := SQLTransaction;
      UpdateQuery.SQL.Text := 'UPDATE dev SET ' + FieldName + ' = :newvalue WHERE devname = :devname';
      UpdateQuery.ParamByName('newvalue').AsString := NewText;
      UpdateQuery.ParamByName('devname').AsString := OldDevName;

      if not SQLTransaction.Active then
        SQLTransaction.StartTransaction;
      UpdateQuery.ExecSQL;
      SQLTransaction.Commit;
    finally
      UpdateQuery.Free;
    end;
  except
    on E: Exception do
    begin
      if SQLTransaction.Active then
        SQLTransaction.Rollback;
      ShowMessage('Ошибка обновления данных: ' + E.Message);
      // Восстанавливаем старое значение
      case Column of
        1: NodeData^.DevName := OldDevName;
        // Для hdname и hdgroup нужно перечитать из базы
      end;
    end;
  end;
end;

destructor TVElectrNav.Destroy;
begin
  // Освобождаем компоненты базы данных
  SQLQuery.Free;
  SQLTransaction.Free;
  SQLite3Connection.Free;

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


function TVElectrNav.GetDatabasePath: String;
//var
//  TempPath: array[0..MAX_PATH] of Char;
begin
  //GetTempPath(MAX_PATH, TempPath);
  Result := ExtractFilePath(PTZCADDrawing(drawings.GetCurrentDwg)^.FileName) + vcalctempdbfilename;
end;

procedure TVElectrNav.InitializeDatabase;
begin
  try
    // Подключаемся к базе данных в папке TEMP
    //ShowMessage('GetDatabasePath: ' + GetDatabasePath);
    SQLite3Connection.DatabaseName := GetDatabasePath;
    SQLite3Connection.Open;

    // Проверяем наличие таблицы dev
    SQLQuery.SQL.Text := 'SELECT name FROM sqlite_master WHERE type=''table'' AND name=''dev''';
    SQLQuery.Open;
    if SQLQuery.EOF then
      raise Exception.Create('Таблица dev не найдена в базе данных');
    SQLQuery.Close;
  except
    on E: Exception do
      ShowMessage('Ошибка подключения к базе данных: ' + E.Message);
  end;
end;

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
  TempQuery: TSQLQuery;
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

    // Загружаем все пути устройств
    TempQuery := TSQLQuery.Create(nil);
    try
      TempQuery.Database := SQLite3Connection;
      TempQuery.SQL.Text := 'SELECT hdway FROM dev WHERE TRIM(hdway) <> ""';
      TempQuery.Open;

      while not TempQuery.EOF do
      begin
        AddPathToTree(RootNode, TempQuery.FieldByName('hdway').AsString);
        TempQuery.Next;
      end;
    finally
      TempQuery.Free;
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
  //if not Assigned(Node) then
  //begin
  //  ShowMessage('Нет выбранной ноды!');
  //  Exit;
  //end;

  if Assigned(Node) then
  begin
    Data := FDeviceTree.GetNodeData(Node);
    if Assigned(Data) then
    begin
      //ShowMessage(
      //  'Устройство: ' + Data^.DeviceName + #13#10 +
      //  'Подключено к: '+ GetNodePhysicalPath(Node) + #13#10
      //  );
      if Data^.DeviceName <> 'Все устройства' then
        recordingVstDev('SELECT * FROM dev WHERE hdway = '''+ GetNodePhysicalPath(Node) + '''')
      else
       recordingVstDev('SELECT * FROM dev')
    end
    else
    begin
      ShowMessage('Все устройства');
      recordingVstDev('SELECT * FROM dev');
    end;
  end;
end;


function TVElectrNav.HasChildren(const DeviceName: string): Boolean;
begin
  SQLQuery.SQL.Text := 'SELECT COUNT(*) FROM dev WHERE hdname = :device_name';
  SQLQuery.ParamByName('device_name').AsString := DeviceName;
  SQLQuery.Open;
  try
    Result := SQLQuery.Fields[0].AsInteger > 0;
  finally
    SQLQuery.Close;
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
