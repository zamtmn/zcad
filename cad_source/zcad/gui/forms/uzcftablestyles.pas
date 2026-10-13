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
  Модуль: uzcftablestyles
  Назначение: менеджер стилей таблиц. Отображает список DXF-стилей таблиц
  текущего чертежа в виде таблицы и позволяет добавлять и удалять стили.
  При добавлении показывает диалог создания нового стиля.
  Зависимости: uzestylestablesdxf, uzcdrawings, uzcftablestylecreate, uzclog
}
unit uzcftablestyles;
{$INCLUDE zengineconfig.inc}
{$mode objfpc}{$H+}

interface

uses
  uzclog, uzedrawingsimple, uzcdrawings,
  Classes, SysUtils, Forms, Controls, Graphics,
  Buttons, ExtCtrls, StdCtrls, ComCtrls, ActnList, LMessages,

  uzestylestablesdxf,
  uzcimagesmanager, usupportgui, ZListView,
  gzctnrVectorTypes, uzcinterface, uzcstrconsts;

const
  { Индексы колонок менеджера стилей таблиц }
  CNomColumn           = 0;
  CTitleHeightColumn   = 1;
  CHeaderHeightColumn  = 2;
  CDataHeightColumn    = 3;
  CTitleStyleColumn    = 4;
  CHeaderStyleColumn   = 5;
  CDataStyleColumn     = 6;
  CColumnCount         = 6 + 1;

type
  { TTableStylesForm — форма менеджера стилей таблиц }
  TTableStylesForm = class(TForm)
    CoolBar1: TCoolBar;
    Panel1: TPanel;
    AddStyle: TAction;
    DelStyle: TAction;
    RefreshStyles: TAction;
    ActionList1: TActionList;
    ButtonApplyClose: TBitBtn;
    DescLabel: TLabel;
    ListView1: TZListView;
    ToolBar1: TToolBar;
    ToolButton_Add: TToolButton;
    ToolButton_Delete: TToolButton;
    Separator1: TToolButton;
    ToolButton_Refresh: TToolButton;
    procedure AplyClose(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure RefreshListItems(Sender: TObject);
    procedure StyleAdd(Sender: TObject);
    procedure DeleteItem(Sender: TObject);
    procedure onrsz(Sender: TObject);
    procedure ListView1SelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
  private
    { Число стилей, отображённых в списке }
    FStyleCount: Integer;
    { Удаляет выбранный элемент списка со стилем }
    procedure DoStyleDelete(ProcessedItem: TListItem);
    { Копирует данные базового стиля в новый }
    procedure CopyStyleData(
      const BaseStyle: PTGDBDXFTableStyle;
      const TargetStyle: PTGDBDXFTableStyle);
  public
    { Получить имя стиля для колонки "Имя" }
    function GetStyleName(Item: TListItem): string;
    { Получить высоту текста заголовка таблицы }
    function GetTitleHeight(Item: TListItem): string;
    { Получить высоту текста строки заголовков колонок }
    function GetHeaderHeight(Item: TListItem): string;
    { Получить высоту текста строки данных }
    function GetDataHeight(Item: TListItem): string;
    { Получить имя текстового стиля заголовка }
    function GetTitleStyleName(Item: TListItem): string;
    { Получить имя текстового стиля строки заголовков колонок }
    function GetHeaderStyleName(Item: TListItem): string;
    { Получить имя текстового стиля строки данных }
    function GetDataStyleName(Item: TListItem): string;
  end;

var
  TableStylesForm: TTableStylesForm;

implementation
{$R *.lfm}

uses
  uzcftablestylecreate;

{ Возвращает высоту текста для заданного типа строки (0=title,1=header,2=data) }
function GetCellTextHeight(
  const Style: PTGDBDXFTableStyle;
  RowIndex: Integer): string;
var
  IterRec: itrec;
  CellPtr: PTGDBDXFTableCellStyle;
  CurrentIdx: Integer;
begin
  Result := '';
  CurrentIdx := 0;
  CellPtr := Style^.CellFormats.beginiterate(IterRec);
  while CellPtr <> nil do
  begin
    if CurrentIdx = RowIndex then
    begin
      Result := FloatToStr(CellPtr^.TextHeight);
      Exit;
    end;
    Inc(CurrentIdx);
    CellPtr := Style^.CellFormats.iterate(IterRec);
  end;
end;

{ Возвращает имя текстового стиля для заданного типа строки }
function GetCellTextStyleName(
  const Style: PTGDBDXFTableStyle;
  RowIndex: Integer): string;
begin
  if RowIndex <= 2 then
    Result := Style^.CellTextStyleName[RowIndex]
  else
    Result := '';
end;

{ Инициализация формы: настройка иконок и колонок ListView }
procedure TTableStylesForm.FormCreate(Sender: TObject);
begin
  FStyleCount := 0;

  ActionList1.Images := ImagesManager.IconList;
  ToolBar1.Images := ImagesManager.IconList;
  AddStyle.ImageIndex := ImagesManager.GetImageIndex('plus');
  DelStyle.ImageIndex := ImagesManager.GetImageIndex('minus');
  RefreshStyles.ImageIndex := ImagesManager.GetImageIndex('Refresh');

  ListView1.SmallImages := ImagesManager.IconList;

  SetLength(ListView1.SubItems, CColumnCount);

  { Настраиваем обработчики колонок ListView }
  with ListView1.SubItems[CNomColumn] do
    OnGetName := @GetStyleName;

  with ListView1.SubItems[CTitleHeightColumn] do
    OnGetName := @GetTitleHeight;

  with ListView1.SubItems[CHeaderHeightColumn] do
    OnGetName := @GetHeaderHeight;

  with ListView1.SubItems[CDataHeightColumn] do
    OnGetName := @GetDataHeight;

  with ListView1.SubItems[CTitleStyleColumn] do
    OnGetName := @GetTitleStyleName;

  with ListView1.SubItems[CHeaderStyleColumn] do
    OnGetName := @GetHeaderStyleName;

  with ListView1.SubItems[CDataStyleColumn] do
    OnGetName := @GetDataStyleName;

  programlog.LogOutFormatStr(
    'uzcftablestyles: форма создана', [], LM_Info);
end;

{ Отображение формы: обновляем список стилей }
procedure TTableStylesForm.FormShow(Sender: TObject);
begin
  RefreshListItems(nil);
end;

{ Закрытие формы }
procedure TTableStylesForm.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  programlog.LogOutFormatStr(
    'uzcftablestyles: форма закрыта', [], LM_Info);
end;

{ Обработчик изменения размера: освобождаем редактор }
procedure TTableStylesForm.onrsz(Sender: TObject);
begin
  { Ничего не делаем — редактирование колонок не поддерживается в этой версии }
end;

{ Нажатие "Закрыть" }
procedure TTableStylesForm.AplyClose(Sender: TObject);
begin
  Close;
end;

{ Заполняет список стилей из таблицы стилей текущего чертежа }
procedure TTableStylesForm.RefreshListItems(Sender: TObject);
var
  DrawingPtr: PTSimpleDrawing;
  IterRec: itrec;
  StyleItem: PTGDBDXFTableStyle;
  ListItem: TListItem;
begin
  ListView1.BeginUpdate;
  ListView1.Clear;
  FStyleCount := 0;

  DrawingPtr := drawings.GetCurrentDWG;
  if (DrawingPtr = nil) or (DrawingPtr = PTSimpleDrawing(BlockBaseDWG)) then
  begin
    ListView1.EndUpdate;
    Exit;
  end;

  StyleItem := DrawingPtr^.DXFTableStyleTable.beginiterate(IterRec);
  if StyleItem <> nil then
  repeat
    ListItem := ListView1.Items.Add;
    Inc(FStyleCount);
    ListItem.Data := StyleItem;
    ListView1.UpdateItem(ListItem, nil);
    StyleItem := DrawingPtr^.DXFTableStyleTable.iterate(IterRec);
  until StyleItem = nil;

  ListView1.SortColumn := 1;
  ListView1.SetFocus;
  ListView1.EndUpdate;

  DescLabel.Caption := Format('Стилей таблиц: %d', [FStyleCount]);

  programlog.LogOutFormatStr(
    'uzcftablestyles: загружено стилей = %d', [FStyleCount], LM_Info);
end;

{ Обработчик выбора элемента в списке }
procedure TTableStylesForm.ListView1SelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
var
  StylePtr: PTGDBDXFTableStyle;
begin
  if Selected and (Item <> nil) then
  begin
    StylePtr := PTGDBDXFTableStyle(Item.Data);
    DescLabel.Caption := Format('Стиль: %s', [StylePtr^.Name]);
  end;
end;

{ Копирует данные из базового стиля в целевой, сохраняя имя целевого }
procedure TTableStylesForm.CopyStyleData(
  const BaseStyle: PTGDBDXFTableStyle;
  const TargetStyle: PTGDBDXFTableStyle);
var
  SavedName: string;
  I: Integer;
  CellItem: TGDBDXFTableCellStyle;
  SrcIterRec: itrec;
  CellIter: PTGDBDXFTableCellStyle;
begin
  SavedName := TargetStyle^.Name;

  { Копируем числовые поля стиля }
  TargetStyle^.Flags70 := BaseStyle^.Flags70;
  TargetStyle^.Flags71 := BaseStyle^.Flags71;
  TargetStyle^.HorzCellMargin := BaseStyle^.HorzCellMargin;
  TargetStyle^.VertCellMargin := BaseStyle^.VertCellMargin;
  TargetStyle^.TitleSuppressed := BaseStyle^.TitleSuppressed;
  TargetStyle^.ColumnHeadingSuppressed := BaseStyle^.ColumnHeadingSuppressed;

  { Копируем имена текстовых стилей для каждой строки }
  for I := 0 to 2 do
    TargetStyle^.CellTextStyleName[I] := BaseStyle^.CellTextStyleName[I];

  { Копируем форматы ячеек через итерацию }
  TargetStyle^.CellFormats.Done;
  TargetStyle^.CellFormats.Init(3);
  CellIter := BaseStyle^.CellFormats.beginiterate(SrcIterRec);
  while CellIter <> nil do
  begin
    CellItem := CellIter^;
    TargetStyle^.CellFormats.PushBackData(CellItem);
    CellIter := BaseStyle^.CellFormats.iterate(SrcIterRec);
  end;

  { Восстанавливаем имя нового стиля }
  TargetStyle^.Name := SavedName;
end;

{ Добавление нового стиля: показывает диалог создания и копирует базовый стиль }
procedure TTableStylesForm.StyleAdd(Sender: TObject);
var
  DrawingPtr: PTSimpleDrawing;
  BaseStylePtr: PTGDBDXFTableStyle;
  NewStylePtr: PTGDBDXFTableStyle;
  CreateDialog: TTableStyleCreateForm;
begin
  DrawingPtr := drawings.GetCurrentDWG;
  if DrawingPtr = nil then
    Exit;

  { Открываем диалог выбора имени и базового стиля }
  CreateDialog := TTableStyleCreateForm.Create(nil);
  try
    if CreateDialog.ShowModal <> mrOk then
      Exit;

    { Проверяем, что стиль с таким именем ещё не существует }
    if DrawingPtr^.DXFTableStyleTable.getIndex(CreateDialog.NewStyleName) >= 0 then
    begin
      zcUI.TextMessage(
        'Стиль с именем "' + CreateDialog.NewStyleName + '" уже существует.',
        TMWOShowError);
      Exit;
    end;

    { Создаём новый стиль }
    NewStylePtr := DrawingPtr^.DXFTableStyleTable.AddStyle(
      CreateDialog.NewStyleName);

    if NewStylePtr = nil then
    begin
      programlog.LogOutFormatStr(
        'uzcftablestyles: ошибка создания стиля "%s"',
        [CreateDialog.NewStyleName], LM_Info);
      Exit;
    end;

    { Если указан базовый стиль — копируем его данные }
    if CreateDialog.BaseStyleName <> '' then
    begin
      BaseStylePtr := PTGDBDXFTableStyle(
        DrawingPtr^.DXFTableStyleTable.getAddres(CreateDialog.BaseStyleName));
      if BaseStylePtr <> nil then
        CopyStyleData(BaseStylePtr, NewStylePtr);
    end;

    programlog.LogOutFormatStr(
      'uzcftablestyles: создан стиль "%s" на основе "%s"',
      [CreateDialog.NewStyleName, CreateDialog.BaseStyleName], LM_Info);

  finally
    CreateDialog.Free;
  end;

  { Обновляем список после добавления }
  RefreshListItems(nil);
end;

{ Удаляет стиль из таблицы и из ListView.
  RemoveDataFromArray только убирает указатель из массива, поэтому стиль
  освобождается явно (Done + Freemem, как GZVectorPData.done). Строка
  ListView удаляется до освобождения: ListView читает Item.Data. }
procedure TTableStylesForm.DoStyleDelete(ProcessedItem: TListItem);
var
  DrawingPtr: PTSimpleDrawing;
  StylePtr: PTGDBDXFTableStyle;
begin
  DrawingPtr := drawings.GetCurrentDWG;
  StylePtr := PTGDBDXFTableStyle(ProcessedItem.Data);

  programlog.LogOutFormatStr(
    'uzcftablestyles: удаление стиля "%s"',
    [StylePtr^.Name], LM_Info);

  ListView1.Items.Delete(ListView1.Items.IndexOf(ProcessedItem));
  DrawingPtr^.DXFTableStyleTable.RemoveDataFromArray(StylePtr);
  StylePtr^.Done;
  Freemem(Pointer(StylePtr));
end;

{ Обработчик кнопки удаления стиля }
procedure TTableStylesForm.DeleteItem(Sender: TObject);
var
  DrawingPtr: PTSimpleDrawing;
  StylePtr: PTGDBDXFTableStyle;
begin
  DrawingPtr := drawings.GetCurrentDWG;
  if not Assigned(ListView1.Selected) then
  begin
    zcUI.TextMessage(rsStyleMustBeSelected, TMWOShowError);
    Exit;
  end;

  StylePtr := PTGDBDXFTableStyle(ListView1.Selected.Data);

  { Не позволяем удалять последний стиль — в DXF должен быть хотя бы один }
  if DrawingPtr^.DXFTableStyleTable.count <= 1 then
  begin
    zcUI.TextMessage(
      'Нельзя удалить последний стиль таблицы.',
      TMWOShowError);
    Exit;
  end;

  programlog.LogOutFormatStr(
    'uzcftablestyles: запрос удаления стиля "%s"',
    [StylePtr^.Name], LM_Info);

  DoStyleDelete(ListView1.Selected);
  DescLabel.Caption := '';
end;

{ --- Методы получения данных для колонок ListView --- }

{ Возвращает имя стиля }
function TTableStylesForm.GetStyleName(Item: TListItem): string;
begin
  Result := PTGDBDXFTableStyle(Item.Data)^.Name;
end;

{ Возвращает высоту текста заголовка таблицы (строка 0) }
function TTableStylesForm.GetTitleHeight(Item: TListItem): string;
begin
  Result := GetCellTextHeight(PTGDBDXFTableStyle(Item.Data), 0);
end;

{ Возвращает высоту текста строки заголовков колонок (строка 1) }
function TTableStylesForm.GetHeaderHeight(Item: TListItem): string;
begin
  Result := GetCellTextHeight(PTGDBDXFTableStyle(Item.Data), 1);
end;

{ Возвращает высоту текста строки данных (строка 2) }
function TTableStylesForm.GetDataHeight(Item: TListItem): string;
begin
  Result := GetCellTextHeight(PTGDBDXFTableStyle(Item.Data), 2);
end;

{ Возвращает имя текстового стиля для заголовка таблицы }
function TTableStylesForm.GetTitleStyleName(Item: TListItem): string;
begin
  Result := GetCellTextStyleName(PTGDBDXFTableStyle(Item.Data), 0);
end;

{ Возвращает имя текстового стиля для строки заголовков колонок }
function TTableStylesForm.GetHeaderStyleName(Item: TListItem): string;
begin
  Result := GetCellTextStyleName(PTGDBDXFTableStyle(Item.Data), 1);
end;

{ Возвращает имя текстового стиля для строки данных }
function TTableStylesForm.GetDataStyleName(Item: TListItem): string;
begin
  Result := GetCellTextStyleName(PTGDBDXFTableStyle(Item.Data), 2);
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization', [{$INCLUDE %FILE%}],
    LM_Info, UnitsInitializeLMId);

finalization
  programlog.LogOutFormatStr('Unit "%s" finalization', [{$INCLUDE %FILE%}],
    LM_Info, UnitsFinalizeLMId);
end.
