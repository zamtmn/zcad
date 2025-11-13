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
  uzcinterface,
  laz.VirtualTrees,
  uzegeometrytypes,
  uzvdialuxlumimporter_structs,
  uzvdialuxlumimporter_utils,
  uzeentblockinsert,
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

  { TfrmDialuxLumImporter }

  TfrmDialuxLumImporter = class(TForm)
    btnApplyInstallation: TButton;
    lblRotation: TLabel;
    edtRotation: TEdit;
    lblScale: TLabel;
    edtScale: TEdit;
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

    {**Обработчик начала редактирования ячейки}
    procedure vstLightMappingEditing(
      Sender: TBaseVirtualTree;
      Node: PVirtualNode;
      Column: TColumnIndex;
      var Allowed: Boolean
    );

    {**Обработчик нажатия мыши на дереве}
    procedure vstLightMappingMouseDown(
      Sender: TObject;
      Button: TMouseButton;
      Shift: TShiftState;
      X, Y: Integer
    );

    {**Обработчик инициализации узла дерева}
    //procedure vstLightMappingInitNode(
    //  Sender: TBaseVirtualTree;
    //  ParentNode: PVirtualNode;
    //  Node: PVirtualNode;
    //  var InitialStates: TVirtualNodeInitStates
    //);

    {**Обработчик освобождения узла дерева}
    procedure vstLightMappingFreeNode(
      Sender: TBaseVirtualTree;
      Node: PVirtualNode
    );

    //{**Обработчик инициализации узла дерева}
    //procedure vstLightMappingInitNode(
    //  Sender: TBaseVirtualTree;
    //  ParentNode: PVirtualNode;
    //  Node: PVirtualNode;
    //  var InitialStates: TVirtualNodeInitStates
    //);

    {**Обработчик освобождения узла дерева}
    procedure vstLightMappingFreeNode(
      Sender: TBaseVirtualTree;
      Node: PVirtualNode
    );

  private
    FRecognizedLights: TLightItemArray;  // Массив распознанных светильников
    FLoadedBlocks: TLoadedBlocksList;    // Список доступных блоков

    {**Инициализировать колонки дерева}
    procedure InitializeTreeColumns;

    {**Заполнить дерево данными о светильниках}
    procedure PopulateTree;

    {**Создать узел для одного светильника}
    function CreateLightNode(const LightItem: TLightItem): PVirtualNode;

    {**Получить данные узла}
    function GetNodeData(Node: PVirtualNode): PLightMappingNodeData;

    {**Получить значение угла поворота из поля ввода}
    function GetRotationAngle: Double;

    {**Получить значение масштаба из поля ввода}
    function GetScaleFactor: Double;

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
  Height := 624;
  Position := poScreenCenter;

  // Настройка дерева
  vstLightMapping.NodeDataSize := SizeOf(TLightMappingNodeData);

  // Включаем редактирование по двойному клику
  vstLightMapping.TreeOptions.MiscOptions :=
    vstLightMapping.TreeOptions.MiscOptions + [toEditOnDblClick];

  InitializeTreeColumns;

  // Настройка полей ввода поворота и масштаба
  lblRotation.Caption := 'Поворот:';
  edtRotation.Text := '0';

  lblScale.Caption := 'Масштаб:';
  edtScale.Text := '1';

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
    vstLightMapping.TreeOptions.MiscOptions :=
      vstLightMapping.TreeOptions.MiscOptions + [toEditOnClick];

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
    // Явная инициализация управляемых типов для защиты от ошибок
    NodeData^.LumKey := '';
    NodeData^.SelectedBlockName := '';
    NodeData^.Center.x := 0;
    NodeData^.Center.y := 0;
    NodeData^.Center.z := 0;

    // Заполняем корректными значениями
    NodeData^.LumKey := LightItem.LumKey;
    NodeData^.Center := LightItem.Center;

    //zcUI.TextMessage('======='+LightItem.LumKey,TMWOHistoryOut);
    //zcUI.TextMessage('+++++++'+FLoadedBlocks[0],TMWOHistoryOut);

    // Устанавливаем первый блок по умолчанию, если есть
    if (FLoadedBlocks <> nil) and (FLoadedBlocks.Count > 0) then
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
  // Инициализируем результат пустой строкой
  CellText := '';

  // Проверяем валидность узла
  if Node = nil then
    Exit;

  // Получаем указатель на данные узла
  NodeData := Sender.GetNodeData(Node);

  // Проверяем валидность указателя на данные
  if not Assigned(NodeData) then
    Exit;

  // Защита от исключений при чтении данных
  try
    case Column of
      0: // Колонка: Импортированные светильники
        CellText := Format(
          '%s (%.1f, %.1f)',
          [NodeData^.LumKey, NodeData^.Center.x, NodeData^.Center.y]
        );

      1: // Колонка: Блок для установки
        CellText := NodeData^.SelectedBlockName;
    end;
  except
    on E: Exception do
    begin
      programlog.LogOutFormatStr(
        'Ошибка чтения NodeData в GetText: %s',
        [E.Message],
        LM_Error
      );
      CellText := '';
    end;
  end;
end;

{**Обработчик создания редактора для ячейки}
procedure TfrmDialuxLumImporter.vstLightMappingCreateEditor(
  Sender: TBaseVirtualTree;
  Node: PVirtualNode;
  Column: TColumnIndex;
  out EditLink: IVTEditLink
);
var
  ComboEditLink: TComboBoxEditLink;
begin
  // Для второй колонки создаем редактор с выпадающим списком
  if Column = 1 then
  begin
    ComboEditLink := TComboBoxEditLink.Create;
    ComboEditLink.SetBlocksList(FLoadedBlocks);
    EditLink := ComboEditLink;
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

{**Обработчик начала редактирования ячейки}
procedure TfrmDialuxLumImporter.vstLightMappingEditing(
  Sender: TBaseVirtualTree;
  Node: PVirtualNode;
  Column: TColumnIndex;
  var Allowed: Boolean
);
begin
  // Разрешаем редактирование только для второй колонки (индекс 1)
  // Первая колонка (индекс 0) - только для чтения
  Allowed := (Column = 1);
end;

{**Обработчик нажатия мыши на дереве}
procedure TfrmDialuxLumImporter.vstLightMappingMouseDown(
  Sender: TObject;
  Button: TMouseButton;
  Shift: TShiftState;
  X, Y: Integer
);
var
  HitInfo: THitInfo;
  Node: PVirtualNode;
begin
  // Получаем информацию о том, на что нажали
  vstLightMapping.GetHitTestInfoAt(X, Y, True, HitInfo);
  Node := HitInfo.HitNode;

  // Проверяем, что нажали на валидный узел
  if Node = nil then
    Exit;

  // Если нажали левой кнопкой на редактируемую колонку (индекс 1),
  // устанавливаем фокус и начинаем редактирование
  if (Button = mbLeft) and (HitInfo.HitColumn = 1) then
  begin
    vstLightMapping.FocusedNode := Node;
    vstLightMapping.FocusedColumn := HitInfo.HitColumn;
    vstLightMapping.EditNode(Node, HitInfo.HitColumn);
  end;
end;

{**Обработчик инициализации узла дерева}
//procedure TfrmDialuxLumImporter.vstLightMappingInitNode(
//  Sender: TBaseVirtualTree;
//  ParentNode: PVirtualNode;
//  Node: PVirtualNode;
//  var InitialStates: TVirtualNodeInitStates
//);
//var
//  NodeData: PLightMappingNodeData;
//begin
//  // Получаем указатель на данные узла
//  NodeData := Sender.GetNodeData(Node);
//
//  // Инициализируем управляемые типы (строки) пустыми значениями
//  // Это необходимо для корректной работы с памятью и предотвращения
//  // ошибок при чтении неинициализированных строковых полей
//  if Assigned(NodeData) then
//  begin
//    NodeData^.LumKey := '';
//    NodeData^.SelectedBlockName := '';
//    NodeData^.Center.x := 0;
//    NodeData^.Center.y := 0;
//    NodeData^.Center.z := 0;
//  end;
//end;

{**Обработчик освобождения узла дерева}
procedure TfrmDialuxLumImporter.vstLightMappingFreeNode(
  Sender: TBaseVirtualTree;
  Node: PVirtualNode
);
var
  NodeData: PLightMappingNodeData;
begin
  // Получаем указатель на данные узла
  NodeData := Sender.GetNodeData(Node);

  // Очищаем строковые поля для корректного освобождения памяти
  if Assigned(NodeData) then
  begin
    NodeData^.LumKey := '';
    NodeData^.SelectedBlockName := '';
  end;
end;

{**Получить значение угла поворота из поля ввода}
function TfrmDialuxLumImporter.GetRotationAngle: Double;
var
  TempValue: Double;
begin
  // Значение по умолчанию
  Result := 0.0;

  // Попытка преобразовать текст в число
  if TryStrToFloat(edtRotation.Text, TempValue) then
    Result := TempValue
  else
  begin
    programlog.LogOutFormatStr(
      'Некорректное значение угла поворота "%s", используется 0',
      [edtRotation.Text],
      LM_Warning
    );
    // Восстанавливаем корректное значение в поле
    edtRotation.Text := '0';
  end;
end;

{**Получить значение масштаба из поля ввода}
function TfrmDialuxLumImporter.GetScaleFactor: Double;
var
  TempValue: Double;
begin
  // Значение по умолчанию
  Result := 1.0;

  // Попытка преобразовать текст в число
  if TryStrToFloat(edtScale.Text, TempValue) then
  begin
    // Проверка на корректность значения (масштаб не должен быть нулевым)
    if TempValue <> 0.0 then
      Result := TempValue
    else
    begin
      programlog.LogOutFormatStr(
        'Масштаб не может быть равен нулю, используется 1',
        [],
        LM_Warning
      );
      edtScale.Text := '1';
    end;
  end
  else
  begin
    programlog.LogOutFormatStr(
      'Некорректное значение масштаба "%s", используется 1',
      [edtScale.Text],
      LM_Warning
    );
    // Восстанавливаем корректное значение в поле
    edtScale.Text := '1';
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
  zcUI.TextMessage('кнопку нажал',TMWOHistoryOut);
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
  InsertedBlock: PGDBObjBlockInsert;
  RotationAngle: Double;
  ScaleFactor: Double;
begin
  InstalledCount := 0;
  ErrorCount := 0;

  // Получаем значения поворота и масштаба из полей ввода
  RotationAngle := GetRotationAngle;
  ScaleFactor := GetScaleFactor;

  programlog.LogOutFormatStr(
    'Установка с параметрами: поворот=%.2f, масштаб=%.2f',
    [RotationAngle, ScaleFactor],
    LM_Info
  );

  // Проходим по всем узлам дерева
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
        try
          zcUI.TextMessage('SelectedBlockName='+NodeData^.SelectedBlockName,TMWOHistoryOut);
          // Вызываем функцию вставки блока на чертеж
          // Масштаб применяется одинаково по всем трем осям (X, Y, Z)
          InsertedBlock := drawInsertBlock(
            NodeData^.Center,
            ScaleFactor,
            ScaleFactor,
            RotationAngle,
            NodeData^.SelectedBlockName
          );

          if InsertedBlock <> nil then
          begin
            programlog.LogOutFormatStr(
              'Светильник "%s" → Блок "%s" установлен в (%.1f, %.1f) ' +
              'с поворотом %.2f° и масштабом %.2f',
              [
                NodeData^.LumKey,
                NodeData^.SelectedBlockName,
                NodeData^.Center.x,
                NodeData^.Center.y,
                RotationAngle,
                ScaleFactor
              ],
              LM_Info
            );
            Inc(InstalledCount);
          end
          else
          begin
            programlog.LogOutFormatStr(
              'Светильник "%s": ошибка вставки блока "%s"',
              [NodeData^.LumKey, NodeData^.SelectedBlockName],
              LM_Error
            );
            Inc(ErrorCount);
          end;
        except
          on E: Exception do
          begin
            programlog.LogOutFormatStr(
              'Светильник "%s": исключение при вставке блока "%s": %s',
              [NodeData^.LumKey, NodeData^.SelectedBlockName, E.Message],
              LM_Error
            );
            Inc(ErrorCount);
          end;
        end;
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
