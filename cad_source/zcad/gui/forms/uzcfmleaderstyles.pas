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
  Модуль: uzcfmleaderstyles
  Назначение: менеджер стилей мультивыносок (по образцу uzcftablestyles).
  Отображает список DXF-стилей мультивыносок (MLEADERSTYLE) текущего чертежа
  в виде таблицы и позволяет добавлять и удалять стили.
  При добавлении показывает диалог создания нового стиля.
  Зависимости: uzestylesmleaderdxf, uzcdrawings, uzcfmleaderstylecreate,
               uzclog
}
unit uzcfmleaderstyles;
{$INCLUDE zengineconfig.inc}
{$mode objfpc}{$H+}

interface

uses
  uzclog, uzedrawingsimple, uzcdrawings,
  Classes, SysUtils, Forms, Controls, Graphics,
  Buttons, ExtCtrls, StdCtrls, ComCtrls, ActnList, LMessages,

  uzestylesmleaderdxf,
  uzcimagesmanager, usupportgui, ZListView,
  gzctnrVectorTypes, uzcinterface, uzcstrconsts;

const
  { Индексы колонок менеджера стилей мультивыносок }
  CNomColumn           = 0;
  CContentTypeColumn   = 1;
  CTextStyleColumn     = 2;
  CTextHeightColumn    = 3;
  CArrowHeadColumn     = 4;
  CArrowSizeColumn     = 5;
  CScaleColumn         = 6;
  CAnnotativeColumn    = 7;
  CColumnCount         = 7 + 1;

type
  { TMLeaderStylesForm — форма менеджера стилей мультивыносок }
  TMLeaderStylesForm = class(TForm)
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
  public
    { Получить имя стиля для колонки "Имя" }
    function GetStyleName(Item: TListItem): string;
    { Получить тип содержимого (мтекст, блок, нет) }
    function GetContentType(Item: TListItem): string;
    { Получить имя текстового стиля }
    function GetTextStyleName(Item: TListItem): string;
    { Получить высоту текста }
    function GetTextHeight(Item: TListItem): string;
    { Получить имя блока стрелки }
    function GetArrowHead(Item: TListItem): string;
    { Получить размер стрелки }
    function GetArrowSize(Item: TListItem): string;
    { Получить общий масштаб }
    function GetScale(Item: TListItem): string;
    { Получить признак аннотативности }
    function GetAnnotative(Item: TListItem): string;
  end;

var
  MLeaderStylesForm: TMLeaderStylesForm;

implementation
{$R *.lfm}

uses
  uzcfmleaderstylecreate;

{ Наименование типа содержимого мультивыноски по коду 170 DXF
  (в модели — поле LeaderLineType) }
function ContentTypeToStr(ContentType: Integer): string;
begin
  case ContentType of
    0: Result := 'Нет';
    1: Result := 'Блок';
    2: Result := 'Мтекст';
    3: Result := 'Допуск';
  else
    Result := IntToStr(ContentType);
  end;
end;

{ Инициализация формы: настройка иконок и колонок ListView }
procedure TMLeaderStylesForm.FormCreate(Sender: TObject);
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

  with ListView1.SubItems[CContentTypeColumn] do
    OnGetName := @GetContentType;

  with ListView1.SubItems[CTextStyleColumn] do
    OnGetName := @GetTextStyleName;

  with ListView1.SubItems[CTextHeightColumn] do
    OnGetName := @GetTextHeight;

  with ListView1.SubItems[CArrowHeadColumn] do
    OnGetName := @GetArrowHead;

  with ListView1.SubItems[CArrowSizeColumn] do
    OnGetName := @GetArrowSize;

  with ListView1.SubItems[CScaleColumn] do
    OnGetName := @GetScale;

  with ListView1.SubItems[CAnnotativeColumn] do
    OnGetName := @GetAnnotative;

  programlog.LogOutFormatStr(
    'uzcfmleaderstyles: форма создана', [], LM_Info);
end;

{ Отображение формы: обновляем список стилей }
procedure TMLeaderStylesForm.FormShow(Sender: TObject);
begin
  RefreshListItems(nil);
end;

{ Закрытие формы }
procedure TMLeaderStylesForm.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  programlog.LogOutFormatStr(
    'uzcfmleaderstyles: форма закрыта', [], LM_Info);
end;

{ Обработчик изменения размера: освобождаем редактор }
procedure TMLeaderStylesForm.onrsz(Sender: TObject);
begin
  { Ничего не делаем — редактирование колонок не поддерживается в этой версии }
end;

{ Нажатие "Закрыть" }
procedure TMLeaderStylesForm.AplyClose(Sender: TObject);
begin
  Close;
end;

{ Заполняет список стилей из таблицы стилей текущего чертежа }
procedure TMLeaderStylesForm.RefreshListItems(Sender: TObject);
var
  DrawingPtr: PTSimpleDrawing;
  IterRec: itrec;
  StyleItem: PTGDBDXFMLeaderStyle;
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

  StyleItem := DrawingPtr^.DXFMLeaderStyleTable.beginiterate(IterRec);
  if StyleItem <> nil then
  repeat
    ListItem := ListView1.Items.Add;
    Inc(FStyleCount);
    ListItem.Data := StyleItem;
    ListView1.UpdateItem(ListItem, nil);
    StyleItem := DrawingPtr^.DXFMLeaderStyleTable.iterate(IterRec);
  until StyleItem = nil;

  ListView1.SortColumn := 1;
  ListView1.SetFocus;
  ListView1.EndUpdate;

  DescLabel.Caption := Format('Стилей мультивыносок: %d', [FStyleCount]);

  programlog.LogOutFormatStr(
    'uzcfmleaderstyles: загружено стилей = %d', [FStyleCount], LM_Info);
end;

{ Обработчик выбора элемента в списке }
procedure TMLeaderStylesForm.ListView1SelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
var
  StylePtr: PTGDBDXFMLeaderStyle;
begin
  if Selected and (Item <> nil) then
  begin
    StylePtr := PTGDBDXFMLeaderStyle(Item.Data);
    DescLabel.Caption := Format('Стиль: %s', [StylePtr^.Name]);
  end;
end;

{ Добавление нового стиля: показывает диалог создания и копирует базовый стиль }
procedure TMLeaderStylesForm.StyleAdd(Sender: TObject);
var
  DrawingPtr: PTSimpleDrawing;
  BaseStylePtr: PTGDBDXFMLeaderStyle;
  NewStylePtr: PTGDBDXFMLeaderStyle;
  CreateDialog: TMLeaderStyleCreateForm;
begin
  DrawingPtr := drawings.GetCurrentDWG;
  if DrawingPtr = nil then
    Exit;

  { Открываем диалог выбора имени и базового стиля }
  CreateDialog := TMLeaderStyleCreateForm.Create(nil);
  try
    if CreateDialog.ShowModal <> mrOk then
      Exit;

    { Проверяем, что стиль с таким именем ещё не существует }
    if DrawingPtr^.DXFMLeaderStyleTable.getIndex(CreateDialog.NewStyleName) >= 0 then
    begin
      zcUI.TextMessage(
        'Стиль с именем "' + CreateDialog.NewStyleName + '" уже существует.',
        TMWOShowError);
      Exit;
    end;

    { Создаём новый стиль }
    NewStylePtr := DrawingPtr^.DXFMLeaderStyleTable.AddStyle(
      CreateDialog.NewStyleName);

    if NewStylePtr = nil then
    begin
      programlog.LogOutFormatStr(
        'uzcfmleaderstyles: ошибка создания стиля "%s"',
        [CreateDialog.NewStyleName], LM_Info);
      Exit;
    end;

    { Если указан базовый стиль — копируем его данные }
    if CreateDialog.BaseStyleName <> '' then
    begin
      BaseStylePtr := PTGDBDXFMLeaderStyle(
        DrawingPtr^.DXFMLeaderStyleTable.getAddres(CreateDialog.BaseStyleName));
      if BaseStylePtr <> nil then
        NewStylePtr^.CopyPropertiesFrom(BaseStylePtr^);
    end;

    programlog.LogOutFormatStr(
      'uzcfmleaderstyles: создан стиль "%s" на основе "%s"',
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
procedure TMLeaderStylesForm.DoStyleDelete(ProcessedItem: TListItem);
var
  DrawingPtr: PTSimpleDrawing;
  StylePtr: PTGDBDXFMLeaderStyle;
begin
  DrawingPtr := drawings.GetCurrentDWG;
  StylePtr := PTGDBDXFMLeaderStyle(ProcessedItem.Data);

  programlog.LogOutFormatStr(
    'uzcfmleaderstyles: удаление стиля "%s"',
    [StylePtr^.Name], LM_Info);

  ListView1.Items.Delete(ListView1.Items.IndexOf(ProcessedItem));
  DrawingPtr^.DXFMLeaderStyleTable.RemoveDataFromArray(StylePtr);
  StylePtr^.Done;
  Freemem(Pointer(StylePtr));
end;

{ Обработчик кнопки удаления стиля }
procedure TMLeaderStylesForm.DeleteItem(Sender: TObject);
var
  DrawingPtr: PTSimpleDrawing;
  StylePtr: PTGDBDXFMLeaderStyle;
begin
  DrawingPtr := drawings.GetCurrentDWG;
  if not Assigned(ListView1.Selected) then
  begin
    zcUI.TextMessage(rsStyleMustBeSelected, TMWOShowError);
    Exit;
  end;

  StylePtr := PTGDBDXFMLeaderStyle(ListView1.Selected.Data);

  { Не позволяем удалять последний стиль — в чертеже должен быть хотя бы один }
  if DrawingPtr^.DXFMLeaderStyleTable.count <= 1 then
  begin
    zcUI.TextMessage(
      'Нельзя удалить последний стиль мультивыноски.',
      TMWOShowError);
    Exit;
  end;

  programlog.LogOutFormatStr(
    'uzcfmleaderstyles: запрос удаления стиля "%s"',
    [StylePtr^.Name], LM_Info);

  DoStyleDelete(ListView1.Selected);
  DescLabel.Caption := '';
end;

{ --- Методы получения данных для колонок ListView ---
  Значения берутся по кодам групп DXF объекта MLEADERSTYLE; имена полей
  модели TGDBDXFMLeaderStyle не всегда совпадают со смыслом кода
  (соответствие кодов и полей — в uzestylesmleaderdxfnod). }

{ Возвращает имя стиля }
function TMLeaderStylesForm.GetStyleName(Item: TListItem): string;
begin
  Result := PTGDBDXFMLeaderStyle(Item.Data)^.Name;
end;

{ Возвращает тип содержимого (код 170) }
function TMLeaderStylesForm.GetContentType(Item: TListItem): string;
begin
  Result := ContentTypeToStr(PTGDBDXFMLeaderStyle(Item.Data)^.LeaderLineType);
end;

{ Возвращает имя текстового стиля (код 342) }
function TMLeaderStylesForm.GetTextStyleName(Item: TListItem): string;
begin
  Result := PTGDBDXFMLeaderStyle(Item.Data)^.TextStyleName;
end;

{ Возвращает высоту текста (код 45) }
function TMLeaderStylesForm.GetTextHeight(Item: TListItem): string;
begin
  Result := FloatToStr(PTGDBDXFMLeaderStyle(Item.Data)^.ArrowHeadSize);
end;

{ Возвращает имя блока стрелки (код 341); пусто — стрелка по умолчанию }
function TMLeaderStylesForm.GetArrowHead(Item: TListItem): string;
begin
  Result := PTGDBDXFMLeaderStyle(Item.Data)^.ArrowHeadBlockName;
  if Result = '' then
    Result := 'Замкнутая заливка';
end;

{ Возвращает размер стрелки (код 44) }
function TMLeaderStylesForm.GetArrowSize(Item: TListItem): string;
begin
  Result := FloatToStr(PTGDBDXFMLeaderStyle(Item.Data)^.TextHeight);
end;

{ Возвращает общий масштаб (код 142) }
function TMLeaderStylesForm.GetScale(Item: TListItem): string;
begin
  Result := FloatToStr(PTGDBDXFMLeaderStyle(Item.Data)^.BlockContentScaleZ);
end;

{ Возвращает признак аннотативности (код 296) }
function TMLeaderStylesForm.GetAnnotative(Item: TListItem): string;
begin
  if PTGDBDXFMLeaderStyle(Item.Data)^.IsMTextContent then
    Result := 'Да'
  else
    Result := 'Нет';
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization', [{$INCLUDE %FILE%}],
    LM_Info, UnitsInitializeLMId);

finalization
  programlog.LogOutFormatStr('Unit "%s" finalization', [{$INCLUDE %FILE%}],
    LM_Info, UnitsFinalizeLMId);
end.
