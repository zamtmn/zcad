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
  uzclog,
  uzcenitiesvariablesextender,
  varmandef;

type
  {**Список индексов светильников}
  TIntegerList = class(TList)
  end;

  {**Данные узла дерева сопоставления}
  PLightMappingNodeData = ^TLightMappingNodeData;
  TLightMappingNodeData = record
    LumKey: string;             // Идентификатор светильника
    Center: TzePoint3d;          // Координаты центра (первого светильника)
    SelectedBlockName: string;  // Выбранное имя блока
    LightIndices: TIntegerList; // Индексы всех светильников с этим LumKey
  end;

  {**Реализация редактора с выпадающим списком для ячейки дерева}
  TComboBoxEditLink = class(TInterfacedObject, IVTEditLink)
  private
    FEdit: TComboBox;           // Выпадающий список
    FTree: TBaseVirtualTree; // Дерево
    FNode: PVirtualNode;        // Узел редактирования
    FColumn: TColumnIndex;      // Колонка редактирования
    FBlocksList: TStrings;      // Список блоков


  public
    constructor Create;
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

  private
    FRecognizedLights: TLightItemArray;  // Массив распознанных светильников
    FLoadedBlocks: TLoadedBlocksList;    // Список доступных блоков

    {**Инициализировать колонки дерева}
    procedure InitializeTreeColumns;

    {**Заполнить дерево данными о светильниках}
    procedure PopulateTree;

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

   // Включаем редактирование по клику
   vstLightMapping.TreeOptions.MiscOptions :=
     vstLightMapping.TreeOptions.MiscOptions + [toEditable, toEditOnDblClick];

   vstLightMapping.TreeOptions.PaintOptions:= vstLightMapping.TreeOptions.PaintOptions + [
          toShowBackground,
          toThemeAware,
          toShowButtons,
          toShowTreeLines
        ];

  vstLightMapping.OnGetText := @vstLightMappingGetText;
  vstLightMapping.OnNewText := @vstLightMappingNewText;
  vstLightMapping.OnEditing := @vstLightMappingEditing;
  vstLightMapping.OnMouseDown := @vstLightMappingMouseDown;
  vstLightMapping.OnCreateEditor := @vstLightMappingCreateEditor; // Новое событие для создания редактора

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
var
  Node: PVirtualNode;
  NodeData: PLightMappingNodeData;
begin
  // Освобождаем списки индексов для каждого узла
  Node := vstLightMapping.GetFirst;
  while Node <> nil do
  begin
    NodeData := vstLightMapping.GetNodeData(Node);
    if Assigned(NodeData) and Assigned(NodeData^.LightIndices) then
    begin
      NodeData^.LightIndices.Free;
      NodeData^.LightIndices := nil;
    end;
    Node := vstLightMapping.GetNext(Node);
  end;

  programlog.LogOutFormatStr(
    'Форма импорта светильников Dialux закрыта',
    [],
    LM_Info
  );
end;

{**Инициализировать колонки дерева}
procedure TfrmDialuxLumImporter.InitializeTreeColumns;
begin
  // Заголовок должен быть включён
  with vstLightMapping.Header do
  begin
    Options := Options + [hoVisible, hoColumnResize, hoAutoResize];
    Columns.Clear;             // обязательно, иначе LFM перетрёт
    AutoSizeIndex := 0;
  end;
  // Колонка 1
  with vstLightMapping.Header.Columns.Add do
  begin
    Text := 'Импортированные светильники';
    Width := 300;
  end;

  // Колонка 2
  with vstLightMapping.Header.Columns.Add do
  begin
    Text := 'Блок для установки';
    Width := 450;
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
  //
  vstLightMapping.Invalidate;
  vstLightMapping.ReinitNode(nil, True);
vstLightMapping.Refresh;

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
  NodeData: PLightMappingNodeData;
  Node: PVirtualNode;
  UniqueKeys: TStringList;
  LumKey: string;
begin
  vstLightMapping.BeginUpdate;
  try
    vstLightMapping.Clear;

    // Создаём список для отслеживания уникальных LumKey
    UniqueKeys := TStringList.Create;
    try
      UniqueKeys.Sorted := True;
      UniqueKeys.Duplicates := dupIgnore;

      // Проходим по всем светильникам и группируем их по LumKey
      for i := 0 to High(FRecognizedLights) do
      begin
        LightItem := FRecognizedLights[i];
        LumKey := LightItem.LumKey;

        // Проверяем, встречался ли уже такой LumKey
        if UniqueKeys.IndexOf(LumKey) = -1 then
        begin
          // Первая встреча этого LumKey - создаём новый узел
          UniqueKeys.Add(LumKey);
          Node := vstLightMapping.AddChild(nil);
          NodeData := vstLightMapping.GetNodeData(Node);

          if Assigned(NodeData) then
          begin
            FillChar(NodeData^, SizeOf(TLightMappingNodeData), 0);
            NodeData^.LumKey := LumKey;
            NodeData^.Center := LightItem.Center;
            NodeData^.LightIndices := TIntegerList.Create;
            NodeData^.LightIndices.Add(Pointer(PtrInt(i)));

            if FLoadedBlocks.Count > 0 then
              NodeData^.SelectedBlockName := FLoadedBlocks[0];
          end;
        end
        else
        begin
          // LumKey уже существует - добавляем индекс к существующему узлу
          Node := vstLightMapping.GetFirst;
          while Node <> nil do
          begin
            NodeData := vstLightMapping.GetNodeData(Node);
            if Assigned(NodeData) and (NodeData^.LumKey = LumKey) then
            begin
              NodeData^.LightIndices.Add(Pointer(PtrInt(i)));
              Break;
            end;
            Node := vstLightMapping.GetNext(Node);
          end;
        end;
      end;

    finally
      UniqueKeys.Free;
    end;

  finally
    vstLightMapping.EndUpdate;
  end;
end;

{**Обработчик получения текста для ячейки дерева}
procedure TfrmDialuxLumImporter.vstLightMappingGetText(
  Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
  TextType: TVSTTextType; var CellText: string);
var
  NodeData: PLightMappingNodeData;
begin
  CellText := '';
    programlog.LogOutFormatStr('OnGetText called: Col=%d, NodeAssigned=%s',
    [Column, BoolToStr(Node <> nil, True)],
    LM_Info);

  if Node = nil then exit;

  NodeData := Sender.GetNodeData(Node);
  programlog.LogOutFormatStr('  NodeData assigned=%s', [BoolToStr(Assigned(NodeData), True)], LM_Info);

  if not Assigned(NodeData) then exit;

  case Column of
    0:
      // Показываем LumKey и количество светильников с этим номером
      if Assigned(NodeData^.LightIndices) then
        CellText := Format('%s [%d шт.]',
          [NodeData^.LumKey, NodeData^.LightIndices.Count])
      else
        CellText := NodeData^.LumKey;

    1:
      CellText := NodeData^.SelectedBlockName;
  end;
  programlog.LogOutFormatStr('  -> CellText="%s"', [CellText], LM_Info);
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
    //FBlocksList := BlocksList;
    //ComboEditLink.SetBlocksList(FLoadedBlocks);
    ComboEditLink := TComboBoxEditLink.Create;
    ComboEditLink.FBlocksList := FLoadedBlocks;  // ВАЖНО
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

  NodeData := Sender.GetNodeData(Node);
  if not Assigned(NodeData) then Exit;

    NodeData^.SelectedBlockName := NewText;

    programlog.LogOutFormatStr(
      'Для светильника "%s" выбран блок "%s"',
      [NodeData^.LumKey, NewText],
      LM_Info
    );
  //end;
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
  if not Assigned(Node) then Exit;

  // Если нажали левой кнопкой на редактируемую колонку (индекс 1),
  // устанавливаем фокус и начинаем редактирование
  if (Button = mbLeft) and (HitInfo.HitColumn = 1) then
  begin
    vstLightMapping.FocusedNode := Node;
    vstLightMapping.FocusedColumn := HitInfo.HitColumn;
    vstLightMapping.EditNode(Node, HitInfo.HitColumn);
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
  i: Integer;
  LightIndex: Integer;
  LightItem: TLightItem;
  VarExt: TVariablesExtender;
  VarDesc: pvardesk;
  BaseNameValue: string;
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

  // Проходим по всем узлам дерева (каждый узел = уникальный LumKey)
  Node := vstLightMapping.GetFirst;
  while Node <> nil do
  begin
    NodeData := vstLightMapping.GetNodeData(Node);

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
      else if Assigned(NodeData^.LightIndices) then
      begin
        // Устанавливаем блоки для всех светильников с этим LumKey
        for i := 0 to NodeData^.LightIndices.Count - 1 do
        begin
          LightIndex := PtrInt(NodeData^.LightIndices[i]);

          // Проверяем корректность индекса
          if (LightIndex < 0) or (LightIndex > High(FRecognizedLights)) then
          begin
            programlog.LogOutFormatStr(
              'Светильник "%s": некорректный индекс %d',
              [NodeData^.LumKey, LightIndex],
              LM_Error
            );
            Inc(ErrorCount);
            Continue;
          end;

          LightItem := FRecognizedLights[LightIndex];

          try
            // Вызываем функцию вставки блока на чертеж
            // Масштаб применяется одинаково по всем трем осям (X, Y, Z)
            InsertedBlock := drawInsertBlock(
              LightItem.Center,
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
                  LightItem.LumKey,
                  NodeData^.SelectedBlockName,
                  LightItem.Center.x,
                  LightItem.Center.y,
                  RotationAngle,
                  ScaleFactor
                ],
                LM_Info
              );

              // Присваиваем NMO_BaseName значение 'EL' + уникальный номер
              VarExt := InsertedBlock^.specialize GetExtension<TVariablesExtender>;
              if VarExt <> nil then
              begin
                VarDesc := VarExt.entityunit.FindVariable('NMO_BaseName');
                if VarDesc <> nil then
                begin
                  BaseNameValue := 'EL' + LightItem.LumKey;
                  VarDesc^.Data.PTD^.SetValueFromString(
                    VarDesc^.Data.Addr.Instance,
                    BaseNameValue
                  );
                  programlog.LogOutFormatStr(
                    'Светильник "%s": установлено NMO_BaseName = "%s"',
                    [LightItem.LumKey, BaseNameValue],
                    LM_Info
                  );
                end;
              end;

              Inc(InstalledCount);
            end
            else
            begin
              programlog.LogOutFormatStr(
                'Светильник "%s": ошибка вставки блока "%s"',
                [LightItem.LumKey, NodeData^.SelectedBlockName],
                LM_Error
              );
              Inc(ErrorCount);
            end;
          except
            on E: Exception do
            begin
              programlog.LogOutFormatStr(
                'Светильник "%s": исключение при вставке блока "%s": %s',
                [LightItem.LumKey, NodeData^.SelectedBlockName, E.Message],
                LM_Error
              );
              Inc(ErrorCount);
            end;
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


constructor TComboBoxEditLink.Create;
begin
  inherited;
  FEdit := TComboBox.Create(nil);
  FEdit.Style := csDropDownList;
end;


{**Деструктор}
destructor TComboBoxEditLink.Destroy;
begin
  if FEdit <> nil then
    FEdit.Free;
  inherited Destroy;
end;

{**Подготовить редактор}
function TComboBoxEditLink.PrepareEdit(
  Tree: TBaseVirtualTree;
  Node: PVirtualNode;
  Column: TColumnIndex
): Boolean; stdcall;
var
  R: TRect;
  NodeData: PLightMappingNodeData;
begin
  FTree := Tree;
  FNode := Node;
  FColumn := Column;

  FEdit.Parent := Tree as TWinControl;
  FEdit.Items.Assign(FBlocksList);

  // Получаем прямоугольник ячейки
  R := Tree.GetDisplayRect(Node, Column, True);

  // Увеличиваем высоту для комбобокса
  R.Bottom := R.Top + FEdit.Height;

  FEdit.BoundsRect := R;

  // Устанавливаем текущее значение
  NodeData := Tree.GetNodeData(Node);
  if Assigned(NodeData) then
    FEdit.ItemIndex := FEdit.Items.IndexOf(NodeData^.SelectedBlockName)
  else
    FEdit.ItemIndex := 0;

  Result := True;
end;

{**Начать редактирование}
function TComboBoxEditLink.BeginEdit: Boolean; stdcall;
begin
  Result := True;

  // Показываем ComboBox
  FEdit.Show;

  // Устанавливаем фокус на ComboBox
  FEdit.SetFocus;

  // Обрабатываем сообщения для завершения операций фокуса
  //Application.ProcessMessages;

  // Теперь разворачиваем список после того, как фокус установлен
  //FEdit.DroppedDown := True;
end;

{**Завершить редактирование}
function TComboBoxEditLink.EndEdit: Boolean; stdcall;
var
  NodeData: PLightMappingNodeData;
begin
  Result := True;
  if Assigned(FTree) and Assigned(FNode) then
  begin
    NodeData := FTree.GetNodeData(FNode);
    if Assigned(NodeData) and (FEdit.ItemIndex >= 0) then
    begin
      NodeData^.SelectedBlockName := FEdit.Items[FEdit.ItemIndex];
      FTree.InvalidateNode(FNode);
    end;
  end;
  FEdit.Hide;
end;

{**Отменить изменения}
function TComboBoxEditLink.CancelEdit: Boolean; stdcall;
begin
  Result := True;
  FEdit.Hide;

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
