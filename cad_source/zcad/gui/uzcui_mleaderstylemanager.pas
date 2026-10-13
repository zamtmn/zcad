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
{
  Модуль: uzcui_mleaderstylemanager
  Назначение: диалоговое окно управления стилями мультивыносок DXF
  (MLEADERSTYLE), аналог диалога «Диспетчер стилей мультивыносок» в AutoCAD.
  Сделано по образцу uzcui_tablestylemanager. Форма строится программно,
  без .lfm.
  Позволяет просматривать, создавать, удалять стили и устанавливать текущий.
  При создании нового стиля открывается вспомогательный диалог (тоже программный),
  где пользователь вводит имя и выбирает базовый стиль.
  Зависимости: uzestylesmleaderdxf, uzcdrawings, uzedrawingsimple,
               uzcinterface, uzclog, LCL
}
unit uzcui_mleaderstylemanager;
{$INCLUDE zengineconfig.inc}
{$mode objfpc}{$H+}

interface

uses
  uzclog,
  uzestylesmleaderdxf,
  uzcdrawings,
  uzedrawingsimple,
  gzctnrVectorTypes,
  Classes, SysUtils, Forms, Controls, Graphics,
  ExtCtrls, StdCtrls, Dialogs;

const
  { Размеры главного окна }
  CFormWidth  = 700;
  CFormHeight = 500;

  { Ширина левой панели со списком стилей }
  CPanelLeftWidth  = 180;
  { Ширина правой панели с кнопками действий }
  CPanelRightWidth = 150;
  { Высота верхней панели с меткой текущего стиля }
  CPanelTopHeight  = 35;
  { Высота нижней панели с кнопками «Закрыть» и «Справка» }
  CPanelBottomHeight = 45;
  { Высота нижнего блока фильтра на левой панели }
  CPanelFilterHeight = 55;

  { Высота кнопок на правой панели }
  CButtonHeight = 28;
  { Ширина кнопок на правой панели }
  CButtonWidth  = 130;
  { Горизонтальный отступ кнопок от края }
  CButtonMargin = 10;
  { Вертикальный отступ первой кнопки от верха }
  CButtonTopStart = 10;
  { Вертикальный шаг между кнопками }
  CButtonStep = 35;

  { Размеры диалога создания нового стиля }
  CCreateFormWidth  = 356;
  CCreateFormHeight = 190;
  { Ширина правой колонки кнопок в диалоге создания }
  CCreatePanelButtonsWidth = 96;

  { Шаблон имени нового стиля по умолчанию: «Копия из <базовый>» }
  CNewStyleNameTemplate = 'Копия из %s';

type
  { TMLeaderStyleCreateDialog — программный диалог создания нового стиля
    мультивыноски.
    Показывает поле ввода имени и выпадающий список базовых стилей.
    Результат доступен через свойства NewStyleName и BaseStyleName. }
  TMLeaderStyleCreateDialog = class(TForm)
  private
    { Поле ввода имени нового стиля }
    FEditStyleName: TEdit;
    { Выпадающий список существующих стилей (базовый стиль) }
    FComboBaseStyle: TComboBox;
    { Кнопки диалога }
    FButtonNext: TButton;
    FButtonCancel: TButton;

    { Обновляет предлагаемое имя нового стиля при смене базового }
    procedure UpdateSuggestedName;
    { Обработчик смены выбора базового стиля }
    procedure OnBaseStyleChange(Sender: TObject);
    { Обработчик нажатия «Далее» — проверяет имя и закрывает диалог }
    procedure OnNextClick(Sender: TObject);

  public
    { Имя нового стиля — результат диалога (задаётся после mrOk) }
    NewStyleName: string;
    { Имя базового стиля — результат диалога (задаётся после mrOk) }
    BaseStyleName: string;

    constructor Create(AOwner: TComponent); override;

    { Заполняет комбобокс стилями из таблицы текущего чертежа.
      Параметр PreselectedName — имя стиля, который нужно выбрать изначально. }
    procedure FillBaseStyles(const PreselectedName: string);
  end;

  { TMLeaderStyleManagerForm — диалог управления стилями мультивыносок.
    Строится программно, без .lfm-файла. }
  TMLeaderStyleManagerForm = class(TForm)
  private
    { Метка «Текущий стиль мультивыноски: <имя>» }
    FLabelCurrentStyle: TLabel;
    { Список стилей }
    FListBoxStyles: TListBox;
    { Комбобокс фильтра «Все стили» / «Используемые стили» }
    FComboBoxFilter: TComboBox;
    { Метка «Образец: <имя>» }
    FLabelPreview: TLabel;
    { Область предпросмотра }
    FPaintBoxPreview: TPaintBox;
    { Кнопки действий }
    FButtonSetCurrent: TButton;
    FButtonCreate: TButton;
    FButtonEdit: TButton;
    FButtonDelete: TButton;
    { Кнопки нижней панели }
    FButtonClose: TButton;
    FButtonHelp: TButton;
    { Имя текущего стиля (только визуальное в рамках диалога) }
    FCurrentStyleName: string;

    { Создаёт и размещает все панели и элементы управления }
    procedure BuildControls;
    { Создаёт верхнюю панель с меткой текущего стиля }
    procedure BuildTopPanel(ParentForm: TForm);
    { Создаёт нижнюю панель с кнопками «Закрыть» и «Справка» }
    procedure BuildBottomPanel(ParentForm: TForm);
    { Создаёт правую панель с кнопками действий }
    procedure BuildRightPanel(ParentForm: TForm);
    { Создаёт левую панель со списком стилей и фильтром }
    procedure BuildLeftPanel(ParentForm: TForm);
    { Создаёт центральную панель с предпросмотром }
    procedure BuildCenterPanel(ParentForm: TForm);

    { Обновляет текст метки текущего стиля }
    procedure UpdateCurrentStyleLabel;
    { Обновляет текст метки «Образец:» по выбранному элементу }
    procedure UpdatePreviewLabel;
    { Обновляет доступность кнопок «Установить» и «Удалить» }
    procedure UpdateButtonStates;
    { Возвращает указатель на выбранный стиль или nil }
    function GetSelectedStyle: PTGDBDXFMLeaderStyle;
    { Возвращает имя выбранного в списке стиля или пустую строку }
    function GetSelectedStyleName: string;
    { Проверяет, является ли имя стиля текущим }
    function IsCurrentStyle(const StyleName: string): Boolean;

    { Обработчик нажатия «Установить» }
    procedure OnSetCurrentClick(Sender: TObject);
    { Обработчик нажатия «Создать...» }
    procedure OnCreateClick(Sender: TObject);
    { Обработчик нажатия «Редактировать...» }
    procedure OnEditClick(Sender: TObject);
    { Обработчик нажатия «Удалить» }
    procedure OnDeleteClick(Sender: TObject);
    { Обработчик нажатия «Закрыть» }
    procedure OnCloseClick(Sender: TObject);
    { Обработчик смены выбора в ListBox }
    procedure OnStyleSelect(Sender: TObject);
    { Обработчик смены фильтра }
    procedure OnFilterChange(Sender: TObject);
    { Обработчик рисования заглушки предпросмотра }
    procedure OnPaintPreview(Sender: TObject);

    { Рисует заглушку предпросмотра: серый фон, рамка, текст по центру }
    procedure DrawPreviewStub(myCanvas: TCanvas; const Bounds: TRect);

  public
    constructor Create(AOwner: TComponent); override;

    { Заполняет список стилей из таблицы стилей текущего чертежа }
    procedure RefreshStyleList;
  end;

var
  MLeaderStyleManagerForm: TMLeaderStyleManagerForm;

implementation

{ ============================================================ }
{ TMLeaderStyleCreateDialog                                     }
{ ============================================================ }

constructor TMLeaderStyleCreateDialog.Create(AOwner: TComponent);
var
  PanelContent: TPanel;
  PanelButtons: TPanel;
  LabelStyleName: TLabel;
  LabelBaseStyle: TLabel;
begin
  inherited CreateNew(AOwner);
  Caption      := 'Создание нового стиля мультивыносок';
  Width        := CCreateFormWidth;
  Height       := CCreateFormHeight;
  Position     := poMainFormCenter;
  BorderStyle  := bsDialog;
  NewStyleName := '';
  BaseStyleName := '';

  { Правая панель с кнопками }
  PanelButtons := TPanel.Create(Self);
  PanelButtons.Parent     := Self;
  PanelButtons.Align      := alRight;
  PanelButtons.Width      := CCreatePanelButtonsWidth;
  PanelButtons.BevelOuter := bvNone;

  FButtonNext := TButton.Create(Self);
  FButtonNext.Parent   := PanelButtons;
  FButtonNext.Caption  := 'Далее';
  FButtonNext.Left     := 8;
  FButtonNext.Top      := 12;
  FButtonNext.Width    := 80;
  FButtonNext.Height   := 30;
  FButtonNext.Default  := True;
  FButtonNext.OnClick  := @OnNextClick;

  FButtonCancel := TButton.Create(Self);
  FButtonCancel.Parent      := PanelButtons;
  FButtonCancel.Caption     := 'Отмена';
  FButtonCancel.Left        := 8;
  FButtonCancel.Top         := 54;
  FButtonCancel.Width       := 80;
  FButtonCancel.Height      := 30;
  FButtonCancel.Cancel      := True;
  FButtonCancel.ModalResult := mrCancel;

  { Левая панель с полями ввода }
  PanelContent := TPanel.Create(Self);
  PanelContent.Parent     := Self;
  PanelContent.Align      := alClient;
  PanelContent.BevelOuter := bvNone;

  LabelStyleName := TLabel.Create(Self);
  LabelStyleName.Parent  := PanelContent;
  LabelStyleName.Caption := 'Имя нового стиля:';
  LabelStyleName.Left    := 8;
  LabelStyleName.Top     := 12;

  FEditStyleName := TEdit.Create(Self);
  FEditStyleName.Parent := PanelContent;
  FEditStyleName.Left   := 8;
  FEditStyleName.Top    := 36;
  FEditStyleName.Width  := CCreateFormWidth - CCreatePanelButtonsWidth - 20;

  LabelBaseStyle := TLabel.Create(Self);
  LabelBaseStyle.Parent  := PanelContent;
  LabelBaseStyle.Caption := 'На основе:';
  LabelBaseStyle.Left    := 8;
  LabelBaseStyle.Top     := 74;

  FComboBaseStyle := TComboBox.Create(Self);
  FComboBaseStyle.Parent   := PanelContent;
  FComboBaseStyle.Style    := csDropDownList;
  FComboBaseStyle.Left     := 8;
  FComboBaseStyle.Top      := 98;
  FComboBaseStyle.Width    := CCreateFormWidth - CCreatePanelButtonsWidth - 20;
  FComboBaseStyle.OnChange := @OnBaseStyleChange;
end;

{ Заполняет комбобокс именами стилей из таблицы стилей текущего чертежа }
procedure TMLeaderStyleCreateDialog.FillBaseStyles(const PreselectedName: string);
var
  DrawingPtr: PTSimpleDrawing;
  StylePtr: PTGDBDXFMLeaderStyle;
  IterRec: itrec;
  PreselectedIndex: Integer;
begin
  FComboBaseStyle.Items.Clear;
  PreselectedIndex := 0;

  DrawingPtr := drawings.GetCurrentDWG;
  if DrawingPtr = nil then
    Exit;

  StylePtr := DrawingPtr^.DXFMLeaderStyleTable.beginiterate(IterRec);
  while StylePtr <> nil do
  begin
    FComboBaseStyle.Items.Add(StylePtr^.Name);
    StylePtr := DrawingPtr^.DXFMLeaderStyleTable.iterate(IterRec);
  end;

  { Выбираем переданный стиль как базовый, иначе — первый элемент }
  if PreselectedName <> '' then
    PreselectedIndex := FComboBaseStyle.Items.IndexOf(PreselectedName);

  if PreselectedIndex < 0 then
    PreselectedIndex := 0;

  if FComboBaseStyle.Items.Count > 0 then
    FComboBaseStyle.ItemIndex := PreselectedIndex;

  UpdateSuggestedName;
end;

{ Предлагает имя нового стиля на основе выбранного базового }
procedure TMLeaderStyleCreateDialog.UpdateSuggestedName;
var
  BaseName: string;
begin
  if FComboBaseStyle.ItemIndex < 0 then
    Exit;

  BaseName := FComboBaseStyle.Items[FComboBaseStyle.ItemIndex];
  FEditStyleName.Text := Format(CNewStyleNameTemplate, [BaseName]);
end;

{ Смена базового стиля — обновляем предлагаемое имя }
procedure TMLeaderStyleCreateDialog.OnBaseStyleChange(Sender: TObject);
begin
  UpdateSuggestedName;
end;

{ Нажатие «Далее» — сохраняем результат и закрываем диалог }
procedure TMLeaderStyleCreateDialog.OnNextClick(Sender: TObject);
begin
  NewStyleName := Trim(FEditStyleName.Text);
  if NewStyleName = '' then
  begin
    ShowMessage('Введите имя нового стиля.');
    FEditStyleName.SetFocus;
    Exit;
  end;

  if FComboBaseStyle.ItemIndex >= 0 then
    BaseStyleName := FComboBaseStyle.Items[FComboBaseStyle.ItemIndex]
  else
    BaseStyleName := '';

  programlog.LogOutFormatStr(
    'uzcui_mleaderstylemanager: диалог создания — имя "%s", основа "%s"',
    [NewStyleName, BaseStyleName], LM_Info);

  ModalResult := mrOk;
end;

{ ============================================================ }
{ TMLeaderStyleManagerForm                                      }
{ ============================================================ }

{ --- Конструктор --- }

constructor TMLeaderStyleManagerForm.Create(AOwner: TComponent);
begin
  inherited CreateNew(AOwner);
  Caption          := 'Стили мультивыносок';
  Width            := CFormWidth;
  Height           := CFormHeight;
  Position         := poScreenCenter;
  FCurrentStyleName := '';

  BuildControls;
  RefreshStyleList;

  programlog.LogOutFormatStr(
    'uzcui_mleaderstylemanager: форма инициализирована, стилей: %d',
    [FListBoxStyles.Items.Count], LM_Info);
end;

{ --- Построение интерфейса --- }

{ Создаёт все панели в правильном порядке (align зависит от порядка добавления) }
procedure TMLeaderStyleManagerForm.BuildControls;
begin
  BuildTopPanel(Self);
  BuildBottomPanel(Self);
  BuildRightPanel(Self);
  BuildLeftPanel(Self);
  BuildCenterPanel(Self);
end;

{ Верхняя панель — метка текущего стиля }
procedure TMLeaderStyleManagerForm.BuildTopPanel(ParentForm: TForm);
var
  PanelTop: TPanel;
begin
  PanelTop := TPanel.Create(Self);
  PanelTop.Parent  := ParentForm;
  PanelTop.Align   := alTop;
  PanelTop.Height  := CPanelTopHeight;
  PanelTop.BevelOuter := bvNone;

  FLabelCurrentStyle := TLabel.Create(Self);
  FLabelCurrentStyle.Parent  := PanelTop;
  FLabelCurrentStyle.Left    := 8;
  FLabelCurrentStyle.Top     := 10;
  FLabelCurrentStyle.Caption := 'Текущий стиль мультивыноски: ';
end;

{ Нижняя панель — кнопки «Закрыть» и «Справка» }
procedure TMLeaderStyleManagerForm.BuildBottomPanel(ParentForm: TForm);
var
  PanelBottom: TPanel;
begin
  PanelBottom := TPanel.Create(Self);
  PanelBottom.Parent  := ParentForm;
  PanelBottom.Align   := alBottom;
  PanelBottom.Height  := CPanelBottomHeight;
  PanelBottom.BevelOuter := bvNone;

  FButtonClose := TButton.Create(Self);
  FButtonClose.Parent   := PanelBottom;
  FButtonClose.Caption  := 'Закрыть';
  FButtonClose.Width    := 90;
  FButtonClose.Height   := CButtonHeight;
  FButtonClose.Anchors  := [akRight, akBottom];
  FButtonClose.AnchorSide[akRight].Control := PanelBottom;
  FButtonClose.AnchorSide[akRight].Side    := asrRight;
  FButtonClose.AnchorSide[akBottom].Control := PanelBottom;
  FButtonClose.AnchorSide[akBottom].Side    := asrBottom;
  FButtonClose.BorderSpacing.Right  := CButtonMargin;
  FButtonClose.BorderSpacing.Bottom := 8;
  FButtonClose.OnClick  := @OnCloseClick;

  FButtonHelp := TButton.Create(Self);
  FButtonHelp.Parent   := PanelBottom;
  FButtonHelp.Caption  := 'Справка';
  FButtonHelp.Width    := 90;
  FButtonHelp.Height   := CButtonHeight;
  FButtonHelp.Anchors  := [akRight, akBottom];
  FButtonHelp.AnchorSide[akRight].Control := FButtonClose;
  FButtonHelp.AnchorSide[akRight].Side    := asrLeft;
  FButtonHelp.AnchorSide[akBottom].Control := PanelBottom;
  FButtonHelp.AnchorSide[akBottom].Side    := asrBottom;
  FButtonHelp.BorderSpacing.Right  := 6;
  FButtonHelp.BorderSpacing.Bottom := 8;
  { Справка не реализована на данном этапе }
  FButtonHelp.Enabled := False;
end;

{ Правая панель — кнопки «Установить», «Создать», «Редактировать», «Удалить» }
procedure TMLeaderStyleManagerForm.BuildRightPanel(ParentForm: TForm);
var
  PanelRight: TPanel;

  { Вспомогательная функция создания одной кнопки на правой панели }
  function AddButton(const ButtonCaption: string; TopPos: Integer): TButton;
  begin
    Result := TButton.Create(Self);
    Result.Parent  := PanelRight;
    Result.Caption := ButtonCaption;
    Result.Width   := CButtonWidth;
    Result.Height  := CButtonHeight;
    Result.Left    := CButtonMargin;
    Result.Top     := TopPos;
  end;

begin
  PanelRight := TPanel.Create(Self);
  PanelRight.Parent  := ParentForm;
  PanelRight.Align   := alRight;
  PanelRight.Width   := CPanelRightWidth;
  PanelRight.BevelOuter := bvNone;

  FButtonSetCurrent := AddButton('Установить',
    CButtonTopStart);
  FButtonSetCurrent.OnClick := @OnSetCurrentClick;

  FButtonCreate := AddButton('Создать...',
    CButtonTopStart + CButtonStep);
  FButtonCreate.OnClick := @OnCreateClick;

  FButtonEdit := AddButton('Редактировать...',
    CButtonTopStart + CButtonStep * 2);
  FButtonEdit.OnClick := @OnEditClick;

  FButtonDelete := AddButton('Удалить',
    CButtonTopStart + CButtonStep * 3);
  FButtonDelete.OnClick := @OnDeleteClick;
end;

{ Левая панель — список стилей и фильтр }
procedure TMLeaderStyleManagerForm.BuildLeftPanel(ParentForm: TForm);
var
  PanelLeft: TPanel;
  PanelFilter: TPanel;
  LabelStyles: TLabel;
  LabelFilter: TLabel;
begin
  PanelLeft := TPanel.Create(Self);
  PanelLeft.Parent  := ParentForm;
  PanelLeft.Align   := alLeft;
  PanelLeft.Width   := CPanelLeftWidth;
  PanelLeft.BevelOuter := bvNone;

  LabelStyles := TLabel.Create(Self);
  LabelStyles.Parent  := PanelLeft;
  LabelStyles.Caption := 'Стили:';
  LabelStyles.Left    := 4;
  LabelStyles.Top     := 4;

  { Нижняя часть левой панели — фильтр }
  PanelFilter := TPanel.Create(Self);
  PanelFilter.Parent  := PanelLeft;
  PanelFilter.Align   := alBottom;
  PanelFilter.Height  := CPanelFilterHeight;
  PanelFilter.BevelOuter := bvNone;

  LabelFilter := TLabel.Create(Self);
  LabelFilter.Parent  := PanelFilter;
  LabelFilter.Caption := 'Вывести в список:';
  LabelFilter.Left    := 4;
  LabelFilter.Top     := 4;

  FComboBoxFilter := TComboBox.Create(Self);
  FComboBoxFilter.Parent  := PanelFilter;
  FComboBoxFilter.Style   := csDropDownList;
  FComboBoxFilter.Left    := 4;
  FComboBoxFilter.Top     := 20;
  FComboBoxFilter.Width   := CPanelLeftWidth - 12;
  FComboBoxFilter.Items.Add('Все стили');
  FComboBoxFilter.Items.Add('Используемые стили');
  FComboBoxFilter.ItemIndex := 0;
  FComboBoxFilter.OnChange  := @OnFilterChange;

  { Список занимает оставшееся пространство левой панели }
  FListBoxStyles := TListBox.Create(Self);
  FListBoxStyles.Parent := PanelLeft;
  FListBoxStyles.Align  := alClient;
  FListBoxStyles.OnClick := @OnStyleSelect;
end;

{ Центральная панель — метка и область предпросмотра }
procedure TMLeaderStyleManagerForm.BuildCenterPanel(ParentForm: TForm);
var
  PanelCenter: TPanel;
begin
  PanelCenter := TPanel.Create(Self);
  PanelCenter.Parent  := ParentForm;
  PanelCenter.Align   := alClient;
  PanelCenter.BevelOuter := bvNone;

  FLabelPreview := TLabel.Create(Self);
  FLabelPreview.Parent  := PanelCenter;
  FLabelPreview.Caption := 'Образец: ';
  FLabelPreview.Left    := 4;
  FLabelPreview.Top     := 4;

  FPaintBoxPreview := TPaintBox.Create(Self);
  FPaintBoxPreview.Parent  := PanelCenter;
  FPaintBoxPreview.Align   := alClient;
  FPaintBoxPreview.OnPaint := @OnPaintPreview;
end;

{ --- Заполнение данных --- }

{ Загружает имена стилей из таблицы DXFMLeaderStyleTable текущего чертежа }
procedure TMLeaderStyleManagerForm.RefreshStyleList;
var
  DrawingPtr: PTSimpleDrawing;
  IterRec: itrec;
  StylePtr: PTGDBDXFMLeaderStyle;
  StyleCount: Integer;
begin
  FListBoxStyles.Items.BeginUpdate;
  FListBoxStyles.Items.Clear;
  StyleCount := 0;

  DrawingPtr := drawings.GetCurrentDWG;
  if DrawingPtr = nil then
  begin
    FListBoxStyles.Items.EndUpdate;
    Exit;
  end;

  StylePtr := DrawingPtr^.DXFMLeaderStyleTable.beginiterate(IterRec);
  while StylePtr <> nil do
  begin
    FListBoxStyles.Items.AddObject(StylePtr^.Name, TObject(StylePtr));
    Inc(StyleCount);
    StylePtr := DrawingPtr^.DXFMLeaderStyleTable.iterate(IterRec);
  end;

  FListBoxStyles.Items.EndUpdate;

  { Выбираем первый элемент, если список не пуст }
  if FListBoxStyles.Items.Count > 0 then
    FListBoxStyles.ItemIndex := 0;

  { Инициализируем текущий стиль первым из списка, если не задан }
  if (FCurrentStyleName = '') and (FListBoxStyles.Items.Count > 0) then
    FCurrentStyleName := FListBoxStyles.Items[0];

  UpdateCurrentStyleLabel;
  UpdatePreviewLabel;
  UpdateButtonStates;

  programlog.LogOutFormatStr(
    'uzcui_mleaderstylemanager: список обновлён, стилей: %d',
    [StyleCount], LM_Info);
end;

{ --- Вспомогательные методы --- }

{ Обновляет текст метки «Текущий стиль мультивыноски:» }
procedure TMLeaderStyleManagerForm.UpdateCurrentStyleLabel;
begin
  FLabelCurrentStyle.Caption :=
    'Текущий стиль мультивыноски: ' + FCurrentStyleName;
end;

{ Обновляет текст метки «Образец:» по выбранному стилю }
procedure TMLeaderStyleManagerForm.UpdatePreviewLabel;
var
  SelectedName: string;
begin
  if FListBoxStyles.ItemIndex >= 0 then
    SelectedName := FListBoxStyles.Items[FListBoxStyles.ItemIndex]
  else
    SelectedName := '';

  FLabelPreview.Caption := 'Образец: ' + SelectedName;
end;

{ Обновляет доступность кнопок «Установить» и «Удалить» }
procedure TMLeaderStyleManagerForm.UpdateButtonStates;
var
  HasSelection: Boolean;
begin
  HasSelection := FListBoxStyles.ItemIndex >= 0;
  FButtonSetCurrent.Enabled := HasSelection;
  FButtonDelete.Enabled     := HasSelection;
  FButtonEdit.Enabled       := HasSelection;
end;

{ Возвращает указатель на выбранный стиль или nil, если ничего не выбрано }
function TMLeaderStyleManagerForm.GetSelectedStyle: PTGDBDXFMLeaderStyle;
var
  Index: Integer;
begin
  Result := nil;
  Index := FListBoxStyles.ItemIndex;
  if Index < 0 then
    Exit;
  Result := PTGDBDXFMLeaderStyle(FListBoxStyles.Items.Objects[Index]);
end;

{ Возвращает имя выбранного в списке стиля или пустую строку }
function TMLeaderStyleManagerForm.GetSelectedStyleName: string;
var
  Index: Integer;
begin
  Result := '';
  Index := FListBoxStyles.ItemIndex;
  if Index >= 0 then
    Result := FListBoxStyles.Items[Index];
end;

{ Проверяет, совпадает ли имя стиля с текущим (без учёта регистра) }
function TMLeaderStyleManagerForm.IsCurrentStyle(const StyleName: string): Boolean;
begin
  Result := SameText(StyleName, FCurrentStyleName);
end;

{ --- Заглушка предпросмотра --- }

{ Рисует на Canvas серый прямоугольник с надписью «Предпросмотр недоступен» }
procedure TMLeaderStyleManagerForm.DrawPreviewStub(myCanvas: TCanvas;
  const Bounds: TRect);
const
  CPreviewText   = 'Предпросмотр недоступен';
  CPreviewFontSz = 10;
var
  TextWidth, TextHeight: Integer;
  TextX, TextY: Integer;
begin
  myCanvas.Brush.Color := clSilver;
  myCanvas.FillRect(Bounds);

  myCanvas.Pen.Color := clGray;
  myCanvas.Rectangle(Bounds);

  myCanvas.Font.Color := clBlack;
  myCanvas.Font.Size  := CPreviewFontSz;
  TextWidth  := myCanvas.TextWidth(CPreviewText);
  TextHeight := myCanvas.TextHeight(CPreviewText);
  TextX := Bounds.Left + (Bounds.Right  - Bounds.Left - TextWidth)  div 2;
  TextY := Bounds.Top  + (Bounds.Bottom - Bounds.Top  - TextHeight) div 2;
  myCanvas.TextOut(TextX, TextY, CPreviewText);
end;

{ --- Обработчики событий --- }

{ Перерисовка области предпросмотра }
procedure TMLeaderStyleManagerForm.OnPaintPreview(Sender: TObject);
begin
  DrawPreviewStub(
    FPaintBoxPreview.Canvas,
    Rect(0, 0, FPaintBoxPreview.Width, FPaintBoxPreview.Height));
end;

{ Смена выбора в списке стилей }
procedure TMLeaderStyleManagerForm.OnStyleSelect(Sender: TObject);
begin
  UpdatePreviewLabel;
  UpdateButtonStates;
end;

{ Смена значения фильтра — на данном этапе просто обновляем список }
procedure TMLeaderStyleManagerForm.OnFilterChange(Sender: TObject);
begin
  { Фильтр «Используемые стили» пока является заглушкой — показываем все }
  RefreshStyleList;
end;

{ Кнопка «Установить» — устанавливает выбранный стиль как текущий }
procedure TMLeaderStyleManagerForm.OnSetCurrentClick(Sender: TObject);
var
  StylePtr: PTGDBDXFMLeaderStyle;
begin
  StylePtr := GetSelectedStyle;
  if StylePtr = nil then
    Exit;

  FCurrentStyleName := StylePtr^.Name;
  UpdateCurrentStyleLabel;

  programlog.LogOutFormatStr(
    'uzcui_mleaderstylemanager: текущий стиль: "%s"',
    [FCurrentStyleName], LM_Info);
end;

{ Кнопка «Создать...» — открывает диалог выбора имени и базового стиля,
  затем создаёт новый стиль как копию выбранного базового }
procedure TMLeaderStyleManagerForm.OnCreateClick(Sender: TObject);
var
  DrawingPtr: PTSimpleDrawing;
  CreateDialog: TMLeaderStyleCreateDialog;
  NewStylePtr: PTGDBDXFMLeaderStyle;
  BaseStylePtr: PTGDBDXFMLeaderStyle;
  NewIndex: Integer;
begin
  DrawingPtr := drawings.GetCurrentDWG;
  if DrawingPtr = nil then
    Exit;

  { Открываем диалог: изначально выбран тот стиль, что выделен в списке }
  CreateDialog := TMLeaderStyleCreateDialog.Create(Self);
  try
    CreateDialog.FillBaseStyles(GetSelectedStyleName);
    if CreateDialog.ShowModal <> mrOk then
      Exit;

    { Проверяем, что стиль с таким именем ещё не существует }
    if DrawingPtr^.DXFMLeaderStyleTable.getIndex(CreateDialog.NewStyleName) >= 0 then
    begin
      ShowMessage(
        'Стиль с именем "' + CreateDialog.NewStyleName + '" уже существует.');
      Exit;
    end;

    { Создаём новый стиль }
    NewStylePtr := DrawingPtr^.DXFMLeaderStyleTable.AddStyle(
      CreateDialog.NewStyleName);
    if NewStylePtr = nil then
    begin
      programlog.LogOutFormatStr(
        'uzcui_mleaderstylemanager: ошибка создания стиля "%s"',
        [CreateDialog.NewStyleName], LM_Info);
      Exit;
    end;

    { Копируем свойства базового стиля в новый }
    if CreateDialog.BaseStyleName <> '' then
    begin
      BaseStylePtr := PTGDBDXFMLeaderStyle(
        DrawingPtr^.DXFMLeaderStyleTable.getAddres(CreateDialog.BaseStyleName));
      if BaseStylePtr <> nil then
        NewStylePtr^.CopyPropertiesFrom(BaseStylePtr^);
    end;

    programlog.LogOutFormatStr(
      'uzcui_mleaderstylemanager: создан стиль "%s" на основе "%s"',
      [CreateDialog.NewStyleName, CreateDialog.BaseStyleName], LM_Info);

    RefreshStyleList;

    { Выбираем только что созданный стиль в списке }
    NewIndex := FListBoxStyles.Items.IndexOf(CreateDialog.NewStyleName);
    if NewIndex >= 0 then
      FListBoxStyles.ItemIndex := NewIndex;

    UpdatePreviewLabel;
    UpdateButtonStates;
  finally
    CreateDialog.Free;
  end;
end;

{ Кнопка «Редактировать...» — заглушка }
procedure TMLeaderStyleManagerForm.OnEditClick(Sender: TObject);
begin
  ShowMessage('Редактирование стиля пока не реализовано');

  programlog.LogOutFormatStr(
    'uzcui_mleaderstylemanager: редактирование — заглушка',
    [], LM_Info);
end;

{ Кнопка «Удалить» — удаляет выбранный стиль с подтверждением }
procedure TMLeaderStyleManagerForm.OnDeleteClick(Sender: TObject);
var
  DrawingPtr: PTSimpleDrawing;
  StylePtr: PTGDBDXFMLeaderStyle;
  StyleName: string;
  Confirmed: Integer;
begin
  StylePtr := GetSelectedStyle;
  if StylePtr = nil then
    Exit;

  StyleName  := StylePtr^.Name;
  DrawingPtr := drawings.GetCurrentDWG;

  { Нельзя удалить текущий стиль }
  if IsCurrentStyle(StyleName) then
  begin
    ShowMessage('Нельзя удалить текущий стиль мультивыноски');
    Exit;
  end;

  { Нельзя удалить последний стиль — в таблице должен остаться хотя бы один }
  if DrawingPtr^.DXFMLeaderStyleTable.count <= 1 then
  begin
    ShowMessage('Нельзя удалить последний стиль мультивыноски.');
    Exit;
  end;

  Confirmed := MessageDlg(
    'Удалить стиль "' + StyleName + '"?',
    mtConfirmation,
    [mbYes, mbNo],
    0);

  if Confirmed <> mrYes then
    Exit;

  DrawingPtr^.DXFMLeaderStyleTable.RemoveDataFromArray(StylePtr);

  programlog.LogOutFormatStr(
    'uzcui_mleaderstylemanager: удалён стиль "%s"',
    [StyleName], LM_Info);

  { Список перестраивается до освобождения стиля (Items.Objects списка
    хранят указатели на стили); RemoveDataFromArray только убирает
    указатель из массива, поэтому стиль освобождается явно, как в
    GZVectorPData.done. }
  RefreshStyleList;
  StylePtr^.Done;
  Freemem(Pointer(StylePtr));
end;

{ Кнопка «Закрыть» }
procedure TMLeaderStyleManagerForm.OnCloseClick(Sender: TObject);
begin
  ModalResult := mrClose;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization', [{$INCLUDE %FILE%}],
    LM_Info, UnitsInitializeLMId);

finalization
  programlog.LogOutFormatStr('Unit "%s" finalization', [{$INCLUDE %FILE%}],
    LM_Info, UnitsFinalizeLMId);
end.
