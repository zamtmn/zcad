unit DispatcherConnectionManager;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls,Graphics,  laz.VirtualTrees, SQLite3Conn, SQLDB, DB,uzcdrawing,uzcdrawings,uzvmcdbconsts,uzcinterface,
  Dialogs, ExtCtrls, BufDataset,  DBGrids, Grids, ActnList, ComCtrls, Windows,fgl,odbcconn,
  uzvelaccessdbcontrol,uzvmanagerconnect,uzvelcreatetempdb,gvector,uzccablemanager,uzcentcable,uzeentdevice,gzctnrVectorTypes,uzcvariablesutils,uzccommandsabstract,uzeentity,uzeentblockinsert,varmandef,uzeconsts,uzvelcontroltempdb;

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


  { TDispatcherConnectionFrame }

  TDispatcherConnectionFrame = class(TFrame)
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
  //ShowMessage('Активировался TFRAME: ');

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
type
  //** Создания труктуры
  PTStructCab=^TStructCab;
  TStructCab=record
         nameCab:string;
         nameHeadCab:string;
         numHeadCab:integer;
  end;
  TListStructCab=specialize TVector<TStructCab>;
var
  ODBCConnection: TODBCConnection;
  Query: TSQLQuery;
  Trans: TSQLTransaction;
  listSructCab:TListStructCab;
  i:integer;

  Function getinfoheadcab(iname:string):string;
  var
    Query: TSQLQuery;
    pobj: pGDBObjEntity;   //выделеные объекты в пространстве листа
    pdev: PGDBObjBlockInsert;   //выделеные объекты в пространстве листа
    ir:itrec;  // применяется для обработки списка выделений, но что это понятия не имею :)
    pvd,pvd2:pvardesk;
    i,count, count2:integer;
    errorData:boolean;
  begin
    //Query := TSQLQuery.Create(nil);
    try
      //Query.Database := SQLite3Connection;
      //ZCMsgCallBackInterface.TextMessage(' 1',TMWOHistoryOut);
      // Insert records
      //Query.SQL.Text := 'INSERT INTO dev (zcadid, devname, hdname, hdgroup, icanhd) VALUES (:zcadid, :devname, :hdname, :hdgroup, :icanhd)';
      count:=0;
      pobj:=drawings.GetCurrentROOT^.ObjArray.beginiterate(ir); //зона уже выбрана в перспективе застовлять пользователя ее выбирать
      if pobj<>nil then
        repeat
           //errorData:=true;
           inc(count);
           //result:='-1';
           // Определяем что это устройство
           if pobj^.GetObjType=GDBDeviceID then
             begin
              pdev:=PGDBObjDevice(pobj);
              //zcUI.TextMessage('Tewerqwrqwrqst data added to "dev" table',TMWOHistoryOut);
              //Query.Params.ParamByName('zcadid').AsInteger:=count;
              pvd:=FindVariableInEnt(pdev,'NMO_Name');
              if (pvd<>nil) then
                if (iname=pstring(pvd^.data.Addr.Instance)^) then
                  begin

                    pvd2:=FindVariableInEnt(pdev,'SLCABAGEN1_HeadDeviceName');
                     if (pvd2<>nil) then begin
                       zcUI.TextMessage(iname+ '=111111111111111111111111=' + pstring(pvd^.data.Addr.Instance)^,TMWOHistoryOut);
                       result:= pString(FindVariableInEnt(pdev,'SLCABAGEN1_HeadDeviceName')^.data.Addr.Instance)^ + '.' + pString(FindVariableInEnt(pdev,'SLCABAGEN1_NGHeadDevice')^.data.Addr.Instance)^
                     end;
                  end;
             end;
          pobj:=drawings.GetCurrentROOT^.ObjArray.iterate(ir); //переход к следующем примитиву в списке выбраных примитивов
        until pobj=nil;

      //SQLTransaction.Commit;
      zcUI.TextMessage('Test data added to "dev" table',TMWOHistoryOut);
    finally
      //Query.Free;
    end;
  end;

  procedure getliststructconnect;
    var
    cman:TCableManager;
    pcabledesk:PTCableDesctiptor;
    pobj{,pobj2}:PGDBObjCable;
    pdev:PGDBOBJDevice;
    pnp:PTNodeProp;
    ir,ir2,ir3:itrec;
    iStructCab:TStructCab;
    i,j:integer;
    pvd:pvardesk;
    resres:string;
    begin

      cman.init;
      cman.build;
      pcabledesk:=cman.beginiterate(ir);
      if pcabledesk<>nil then
        BEGIN
         repeat
           //zcUI.TextMessage('  Найдена групповая линия "'+pcabledesk^.Name+'"',TMWOHistoryOut);

           pobj:= pcabledesk^.Segments.beginiterate(ir2);
           //if pobj<>nil then
           //repeat
             pnp:=pobj^.NodePropArray.beginiterate(ir3);
             if pnp<>nil then
                begin
                  iStructCab.nameCab:=pcabledesk^.Name;
                  pdev:=pnp^.DevLink;
                  if pdev<>nil then begin
                   pvd:=FindVariableInEnt(pdev,'SLCABAGEN1_HeadDeviceName');
                     if (pvd<>nil) then
                     iStructCab.nameHeadCab:=pString(FindVariableInEnt(pnp^.DevLink,'SLCABAGEN1_HeadDeviceName')^.data.Addr.Instance)^ + '.' + pString(FindVariableInEnt(pnp^.DevLink,'SLCABAGEN1_NGHeadDevice')^.data.Addr.Instance)^
                     else begin
                      resres:=getinfoheadcab(pString(FindVariableInEnt(pnp^.DevLink,'NMO_Name')^.data.Addr.Instance)^);
                      if resres <> '-1' then
                         iStructCab.nameHeadCab:=resres;
                     end
                     //zcUI.TextMessage('  Найдена групповая лsadsadasdasdasиния "'+iStructCab.nameHeadCab,TMWOHistoryOut);
                     //zcUI.TextMessage('  Найдена групповая линия "'+pString(FindVariableInEnt(pnp^.DevLink,'SLCABAGEN1_NGHeadDevice')^.data.Addr.Instance)^+'"',TMWOHistoryOut);

                  end;
                  iStructCab.numHeadCab:=-1;
                end;
             listSructCab.PushBack(iStructCab);
             //if pnp<>nil then
             // repeat
             //  zcUI.TextMessage('1',TMWOHistoryOut);
             //  //testTempDrawLine(pnp^.PrevP,pnp^.NextP);
             //  pdev:=pnp^.DevLink;
             //  if pdev<>nil then
             //     zcUI.TextMessage('  имя устройства подключенного - '+pString(FindVariableInEnt(pnp^.DevLink,'NMO_Name')^.data.Addr.Instance)^,TMWOHistoryOut);
             //  pnp:=pobj^.NodePropArray.iterate(ir3);
             // until pnp=nil;
             //zcUI.TextMessage('  Найдена групповая линия "'+pcabledesk^.Name+'"');
             //pcabledesk:=cman.iterate(ir);
           //  pobj:=pcabledesk^.Segments.iterate(ir2);
           //until pobj=nil;
           pcabledesk:=cman.iterate(ir);
         until pcabledesk=nil;
        END;

      for i:=0 to listSructCab.Size-1 do
      begin

         for j:=0 to listSructCab.Size-1 do
         begin
             if listSructCab[i].nameCab=listSructCab[j].nameHeadCab then
             begin
                listSructCab.Mutable[j]^.numHeadCab:=i+1;
             end;

         end;
      end;

     //result:=cmd_ok;
    end;
begin
  //ShowMessage('Выбрать только');
  uzvelaccessdbcontrol.AddStructureinAccessDB;
//  ODBCConnection := TODBCConnection.Create(nil);
//  Query := TSQLQuery.Create(nil);
//  Trans := TSQLTransaction.Create(nil);
//  listSructCab:=TListStructCab.Create();
//
//
//  try
//    // Подключение к Access через ODBC
//    ODBCConnection.Driver := 'Microsoft Access Driver (*.mdb, *.accdb)';
//    ODBCConnection.Params.Clear;
//    ODBCConnection.Params.Add('Dbq=D:\mytest.accdb');
//
//    ODBCConnection.LoginPrompt := False;
//    ODBCConnection.Connected := True;
//
//    // Транзакция
//    Trans.DataBase := ODBCConnection;
//    Query.DataBase := ODBCConnection;
//    Query.Transaction := Trans;
//
//    // 1. Создать таблицу fider
//    Query.SQL.Text :=
//      'CREATE TABLE fider (' +
//      'ID AUTOINCREMENT PRIMARY KEY, ' +
//      'nameFid TEXT(50), ' +
//      'secID INTEGER, ' +
//      'nameHead TEXT(50)) ';
//    try
//      Query.ExecSQL;
//    except
//      on E: Exception do
//        ShowMessage('Пропуск создания таблицы: ' + E.Message);
//    end;
//    getliststructconnect;
//    for i:=0 to listSructCab.Size-1 do
//    begin
//      zcUI.TextMessage('  имя устройства подключенного - '+listSructCab[i].nameCab,TMWOHistoryOut);
//      Query.SQL.Text := 'INSERT INTO fider (nameFid, secID, nameHead) VALUES (:pName, :pSecID, :pnameHead)';
//      Query.Params.ParamByName('pName').AsString := listSructCab[i].nameCab;
//      Query.Params.ParamByName('pSecID').AsInteger := listSructCab[i].numHeadCab;
//      Query.Params.ParamByName('pnameHead').AsString := listSructCab[i].nameHeadCab;
//      Query.ExecSQL;
//    end;
//    // 2. Вставка строк
//
////
////    Query.Params.ParamByName('pName').AsString := 'ВРУ2.3';
////    Query.Params.ParamByName('pSecID').AsInteger := 23;
////    Query.ExecSQL;
////
////    // 3. Обновление второй строки
////    Query.SQL.Text := 'UPDATE fider SET nameFid = :newName WHERE nameFid = :oldName';
////    Query.Params.ParamByName('newName').AsString := 'ЩР2.2';
////    Query.Params.ParamByName('oldName').AsString := 'ВРУ2.3';
////    Query.ExecSQL;
//
//
//    // Коммитим транзакцию
//    Trans.Commit;
//
    //ShowMessage('Операция выполнена успешно!');
//  finally
//    Query.Free;
//    Trans.Free;
//    ODBCConnection.Free;
//  end;
end;


procedure TDispatcherConnectionFrame.AllSelActionExecute(Sender: TObject);
begin
  //Destroy;
  if flagConnectDB then
    SQLite3Connection.Close;

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

  // Построение дерева
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
  recordingVstDev('SELECT * FROM dev');

  vstDev.OnGetText := @vstDevGetText;
  vstDev.OnPaintText := @vstDevPaintText;
  vstDev.OnClick := @vstDevClick;
  vstDev.OnEditing := @vstDevEditing;
  vstDev.OnNewText := @vstDevNewText;

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
procedure TDispatcherConnectionFrame.InitializeVstDev;
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

procedure TDispatcherConnectionFrame.recordingVstDev(qry:string);
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


procedure TDispatcherConnectionFrame.vstDevGetText(Sender: TBaseVirtualTree;
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

procedure TDispatcherConnectionFrame.vstDevPaintText(Sender: TBaseVirtualTree;
  const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
  TextType: TVSTTextType);
begin
  if (Column = 0) or (Column = 4) then
  begin
    TargetCanvas.Font.Color := clBlue;
    TargetCanvas.Font.Style := [fsUnderline];
  end;
end;

procedure TDispatcherConnectionFrame.vstDevClick(Sender: TObject);
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

procedure TDispatcherConnectionFrame.vstDevEditing(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; var Allowed: Boolean);
begin
  // Разрешаем редактирование только для колонок 1, 2, 3 (devname, hdname, hdgroup)
  Allowed := (Column >= 1) and (Column <= 3);
end;

procedure TDispatcherConnectionFrame.vstDevNewText(Sender: TBaseVirtualTree;
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
procedure TDispatcherConnectionFrame.AddPathToTree(ParentNode: PVirtualNode; const Path: string);
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
function TDispatcherConnectionFrame.FindOrCreateChild(ParentNode: PVirtualNode; const HDWay,NodeName: string): PVirtualNode;
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

function TDispatcherConnectionFrame.GetNodePhysicalPath(Node: PVirtualNode): string;
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


procedure TDispatcherConnectionFrame.TreeClick(Sender: TObject);
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
