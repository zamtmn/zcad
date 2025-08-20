unit DispatcherConnectionManager;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls,Graphics,  laz.VirtualTrees, SQLite3Conn, SQLDB, DB,uzcdrawing,uzcdrawings,uzvmcdbconsts,uzcinterface,
  Dialogs, ExtCtrls, BufDataset,  DBGrids, Grids, ActnList, ComCtrls, Windows,
  uzvmanagerconnect;

type

  PNodeData = ^TNodeData;
  TNodeData = record
    DeviceName: string;
    ConnectedTo: string;
    Group: string;
    CanBeNode: Boolean;
  end;


  { TDispatcherConnectionFrame }

  TDispatcherConnectionFrame = class(TFrame)
    ActionList1: TActionList;
    bufGridDev: TBufDataset;
    dsGridDev: TDataSource;
    gridDev: TDBGrid;
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
    procedure gridDevDrawColumnCell(Sender: TObject; const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure gridDevCellClick(Column: TColumn);
  private
    //для работы разделителя
    FProportion: Double; // Пропорция ширины PanelSynchDraw / (ClientWidth - Splitter)
    FIsResizing: Boolean; // Флаг для предотвращения рекурсии
    procedure InitializeActionAndButton; //инициализация и настройка кнопок
    procedure InitializePanels;          //инициализация и настройка панелей

    procedure InitializeDatabase;
    procedure InitializeDeviceTree;
    procedure InitializeBufDataset;
    procedure InitializeGridDev;
    procedure recordingGridDev(qry:string);
    procedure BuildDeviceHierarchy;
    procedure TreeGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: String);
    procedure TreeGetNodeDataSize(Sender: TBaseVirtualTree; var NodeDataSize: Integer);
    procedure TreeInitNode(Sender: TBaseVirtualTree; ParentNode, Node: PVirtualNode;
      var InitialStates: TVirtualNodeInitStates);
    procedure TreeFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure TreeClick(Sender: TObject);
    function HasChildren(const DeviceName: string): Boolean;
    procedure AddChildDevices(ParentNode: PVirtualNode; const ParentDeviceName: string);
    function GetDatabasePath: String;
    procedure AddAction(AName, ACaption: string; AImageIndex: string;
  AHint, AShortCut: string; AEvent: TNotifyEvent);

    procedure CurrentSelActionExecute(Sender: TObject);
    procedure AllSelActionExecute(Sender: TObject);
    procedure SaveActionExecute(Sender: TObject);

  public

    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
  end;

  var
      flagEditBufBeforePost:boolean;
      flagConnectDB:boolean;

implementation

{$R *.lfm}

{ TDispatcherConnectionFrame }

constructor TDispatcherConnectionFrame.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  ShowMessage('Активировался TFRAME: ');

  Name := 'DispatcherConnectionFrame';
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



  gridDev.Options := gridDev.Options + [dgColumnResize, dgHeaderPushedLook];
  // Разрешить изменение ширины колонок
  gridDev.Options := gridDev.Options + [dgColumnResize];

  // Можно также настроить другие параметры:
  gridDev.DefaultDrawing := True;  // Включить стандартное рисование
  gridDev.Flat := False;          // Не использовать плоский стиль (лучше для изменения размеров)

    except
      //SQLTransaction.Free;
      //SQLite3Connection.Free;
      on E: Exception do
        ShowMessage('Ошибка подключения TFRAME: ' + E.Message);

    end;

end;
procedure TDispatcherConnectionFrame.AddAction(AName, ACaption: string; AImageIndex: string;
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

procedure TDispatcherConnectionFrame.CurrentSelActionExecute(Sender: TObject);
begin
  ShowMessage('Выбрать только');
end;
procedure TDispatcherConnectionFrame.AllSelActionExecute(Sender: TObject);
begin
  //Destroy;
  if flagConnectDB then
    SQLite3Connection.Close;

  uzvmanagerconnect.managerconnectexecute;

     // Инициализация компонентов базы данных
     ShowMessage('1 ');
  if not flagConnectDB then
  begin
      SQLite3Connection := TSQLite3Connection.Create(Self);
      SQLTransaction := TSQLTransaction.Create(Self);
      SQLQuery := TSQLQuery.Create(Self);
  end;
   ShowMessage('2 ');

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

  // Построение дерева
  InitializeDeviceTree;
  BuildDeviceHierarchy;

  // Заполнение gridDev

  flagEditBufBeforePost:=false;
  // 2. Настройка BufDataset

  InitializeBufDataset;
  //Привязываем к источнику данных
  dsGridDev.DataSet := bufGridDev;
  gridDev.DataSource := dsGridDev;
  //ShowMessage('открыть файл...');
  ////Настраиваем колонки DBGrid
  gridDev.Columns.Clear;
                                    //ShowMessage('открыть файл...');


  // 3. Настройка DBGRID gridDev
  InitializeGridDev;
                                    //ShowMessage('открыть файл...');
  recordingGridDev('SELECT * FROM dev');

  gridDev.OnDrawColumnCell := @gridDevDrawColumnCell;
  gridDev.OnCellClick := @gridDevCellClick;

  //ShowMessage('открыть файл...');
end;
procedure TDispatcherConnectionFrame.SaveActionExecute(Sender: TObject);
begin
  ShowMessage('сохранить файл...');
end;
procedure TDispatcherConnectionFrame.InitializeActionAndButton;
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
procedure TDispatcherConnectionFrame.InitializePanels;
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

procedure TDispatcherConnectionFrame.InitializeBufDataset;
begin
  try
    with bufGridDev do
    begin
      Close;
      FieldDefs.Clear;
      FieldDefs.Add('ActionShow', ftString, 10);
      FieldDefs.Add('ID', ftInteger);
      FieldDefs.Add('devname', ftString, 20);
      FieldDefs.Add('hdname', ftString, 20);
      FieldDefs.Add('hdgroup', ftString, 20);
      FieldDefs.Add('icanhd', ftString, 20);
      FieldDefs.Add('ActionEdit', ftString, 10);
      CreateDataset;
    end;
  except
    on E: Exception do
      ShowMessage('Ошибка подключения создания BufDataset: ' + E.Message);
  end;
end;
procedure TDispatcherConnectionFrame.InitializeGridDev;
begin
  try
    // Кнопка "Показать"
    with gridDev.Columns.Add do
    begin
      Title.Caption := 'show';
      Width := 70;
      FieldName := 'ActionShow'; // Без привязки
    end;

    // Обычные поля
    with gridDev.Columns.Add do FieldName := 'ID';
    with gridDev.Columns.Add do FieldName := 'devname';
    with gridDev.Columns.Add do FieldName := 'hdname';
    with gridDev.Columns.Add do FieldName := 'hdgroup';
    with gridDev.Columns.Add do FieldName := 'icanhd';


    // Кнопка "Ред."
    with gridDev.Columns.Add do
    begin
      Title.Caption := 'edit';
      Width := 60;
      FieldName := 'ActionEdit'; // Без привязки
    end;
  except
    on E: Exception do
      ShowMessage('Ошибка создания колонок: ' + E.Message);
  end;
end;

procedure TDispatcherConnectionFrame.recordingGridDev(qry:string);
var
    i:integer;
    writeQuery: TSQLQuery;
begin
  try
    writeQuery := TSQLQuery.Create(nil);
    writeQuery.Database := SQLite3Connection;
    writeQuery.SQL.Text := qry;
    writeQuery.Open;
    writeQuery.First;
    bufGridDev.Close;
    bufGridDev.Open;
    while not writeQuery.EOF do
    begin
      bufGridDev.Append;
      bufGridDev.FieldByName('ActionShow').AsString := '';
      bufGridDev.FieldByName('ActionEdit').AsString := '';
      for i := 0 to writeQuery.Fields.Count - 1 do
        bufGridDev.Fields[i+1].Assign(writeQuery.Fields[i]);
      bufGridDev.Post;
      writeQuery.Next;
    end;
    writeQuery.Close;
  except
    on E: Exception do
      ShowMessage('Ошибка создания колонок: ' + E.Message);
  end;
end;


procedure TDispatcherConnectionFrame.gridDevDrawColumnCell(Sender: TObject; const Rect: TRect;
  DataCol: Integer; Column: TColumn; State: TGridDrawState);
var
  BtnRect: TRect;
  BtnText:string;
begin
  if (Column.Index = 0) or (Column.Index = gridDev.Columns.Count - 1) then
  begin
    // Очищаем область
    gridDev.Canvas.FillRect(Rect);
    // Рисуем кнопку
    BtnRect := Rect;
    InflateRect(BtnRect, -2, -2);

    gridDev.Canvas.Brush.Color := clBtnFace;
    gridDev.Canvas.Rectangle(BtnRect);
    gridDev.Canvas.Font.Color := clBlack;
    if Column.Index = 0 then
      BtnText:='Показать'
    else
      BtnText:='Ред.';

    gridDev.Canvas.TextOut(
      BtnRect.Left + (BtnRect.Width - gridDev.Canvas.TextWidth(BtnText)) div 2,
      BtnRect.Top + (BtnRect.Height - gridDev.Canvas.TextHeight(BtnText)) div 2,
      BtnText
    );
  end
  else
    gridDev.DefaultDrawColumnCell(Rect, DataCol, Column, State);
end;

procedure TDispatcherConnectionFrame.gridDevCellClick(Column: TColumn);
var
  idVal, t1Val: String;
begin
  //ApplyUpdates;

  if not Assigned(bufGridDev) or bufGridDev.IsEmpty then Exit;

  idVal := bufGridDev.FieldByName('devname').AsString;
  t1Val := bufGridDev.FieldByName('hdname').AsString;

  if Column.Index = 0 then
    ShowMessage('devname: ' + idVal)
  else if Column.Index = gridDev.Columns.Count - 1 then
    ShowMessage('Редактировать: ' + t1Val);
end;

destructor TDispatcherConnectionFrame.Destroy;
begin
  // Освобождаем компоненты базы данных
  SQLQuery.Free;
  SQLTransaction.Free;
  SQLite3Connection.Free;

  inherited Destroy;
end;

//Для работы разделителя
procedure TDispatcherConnectionFrame.FrameResize(Sender: TObject);
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

procedure TDispatcherConnectionFrame.panelSplitterMoved(Sender: TObject);
begin
  // Просто обновляем пропорцию при перемещении разделителя
  FProportion := PanelNav.Width / (ClientWidth - panelSplitter.Width);
end;

////////////////////////////////


function TDispatcherConnectionFrame.GetDatabasePath: String;
//var
//  TempPath: array[0..MAX_PATH] of Char;
begin
  //GetTempPath(MAX_PATH, TempPath);
  Result := ExtractFilePath(PTZCADDrawing(drawings.GetCurrentDwg)^.FileName) + vcalctempdbfilename;
end;

procedure TDispatcherConnectionFrame.InitializeDatabase;
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

procedure TDispatcherConnectionFrame.InitializeDeviceTree;
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

procedure TDispatcherConnectionFrame.BuildDeviceHierarchy;
var
  RootNode, DeviceNode: PVirtualNode;
  TempQuery: TSQLQuery;
  NodeData: PNodeData;
begin
  FDeviceTree.BeginUpdate;
  try
    FDeviceTree.Clear;
    FDeviceTree.NodeDataSize := SizeOf(TNodeData);

    // Добавляем корневой узел "Все устройства"
    RootNode := FDeviceTree.AddChild(nil);
    RootNode^.CheckType := ctTriStateCheckBox;
    NodeData := FDeviceTree.GetNodeData(RootNode);
    NodeData^.DeviceName := 'Все устройства';

    TempQuery := TSQLQuery.Create(nil);
    try
      TempQuery.Database := SQLite3Connection;
      TempQuery.SQL.Text := 'SELECT devname, hdname, hdgroup, icanhd FROM dev WHERE hdname = '''' OR hdname = ''???''';
      TempQuery.Open;

      while not TempQuery.EOF do
      begin
        ZCMsgCallBackInterface.TextMessage('112121',TMWOHistoryOut);
        if TempQuery.FieldByName('icanhd').AsInteger = 1 then
        begin
          // Создаем узел устройства
          DeviceNode := FDeviceTree.AddChild(RootNode);
          NodeData := FDeviceTree.GetNodeData(DeviceNode);
          NodeData^.DeviceName := TempQuery.FieldByName('devname').AsString;
          ZCMsgCallBackInterface.TextMessage('NodeData^.DeviceName=' + NodeData^.DeviceName,TMWOHistoryOut);
          NodeData^.ConnectedTo := TempQuery.FieldByName('hdname').AsString;
          NodeData^.Group := TempQuery.FieldByName('hdgroup').AsString;
          NodeData^.CanBeNode := TempQuery.FieldByName('icanhd').AsBoolean;

          // Добавляем дочерние устройства
          AddChildDevices(DeviceNode, NodeData^.DeviceName);
        end;
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

procedure TDispatcherConnectionFrame.AddChildDevices(ParentNode: PVirtualNode;
  const ParentDeviceName: string);
var
  ChildQuery: TSQLQuery;
  NodeData: PNodeData;
  ChildNode: PVirtualNode;
begin
  ChildQuery := TSQLQuery.Create(nil);
  try
    ChildQuery.Database := SQLite3Connection;
    ChildQuery.SQL.Text := 'SELECT devname, hdname, hdgroup, icanhd FROM dev WHERE hdname = :parent_name';
    ChildQuery.ParamByName('parent_name').AsString := ParentDeviceName;
    ChildQuery.Open;

    while not ChildQuery.EOF do
    begin
      // Создаем дочерний узел
      ChildNode := FDeviceTree.AddChild(ParentNode);
      NodeData := FDeviceTree.GetNodeData(ChildNode);
      NodeData^.DeviceName := ChildQuery.FieldByName('devname').AsString;
      NodeData^.ConnectedTo := ChildQuery.FieldByName('hdname').AsString;
      NodeData^.Group := ChildQuery.FieldByName('hdgroup').AsString;
      NodeData^.CanBeNode := ChildQuery.FieldByName('icanhd').AsBoolean;

      // Если устройство может быть узлом, добавляем его детей
      if NodeData^.CanBeNode then
        AddChildDevices(ChildNode, NodeData^.DeviceName);

      ChildQuery.Next;
    end;
  finally
    ChildQuery.Free;
  end;
end;

procedure TDispatcherConnectionFrame.TreeClick(Sender: TObject);
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
      //ShowMessage(
      //  'Устройство: ' + Data^.DeviceName + #13#10 +
      //  'Подключено к: ' + Data^.ConnectedTo + #13#10 +
      //  'Группа подключения: ' + Data^.Group + #13#10 +
      //  'Может быть узлом: ' + BoolToStr(Data^.CanBeNode, True));
      if Data^.DeviceName <> 'Все устройства' then
        recordingGridDev('SELECT * FROM dev WHERE hdname = '''+ Data^.DeviceName + '''')
      else
       recordingGridDev('SELECT * FROM dev')
    end
    else
    begin
      ShowMessage('Все устройства');
      recordingGridDev('SELECT * FROM dev');
    end;
  end;
end;


function TDispatcherConnectionFrame.HasChildren(const DeviceName: string): Boolean;
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

procedure TDispatcherConnectionFrame.TreeGetText(Sender: TBaseVirtualTree;
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

procedure TDispatcherConnectionFrame.TreeGetNodeDataSize(Sender: TBaseVirtualTree;
  var NodeDataSize: Integer);
begin
  NodeDataSize := SizeOf(Pointer);
end;

procedure TDispatcherConnectionFrame.TreeInitNode(Sender: TBaseVirtualTree;
  ParentNode, Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
begin
  // Ничего не нужно делать
end;

procedure TDispatcherConnectionFrame.TreeFreeNode(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
var
  Data: PPointer;
begin
  Data := Sender.GetNodeData(Node);
  Data^ := nil;
end;


//procedure TDispatcherConnectionFrame.FrameResize(Sender: TObject);
//begin
//  if Assigned(FDeviceTree) then
//    FDeviceTree.FullExpand;
//end;

end.
