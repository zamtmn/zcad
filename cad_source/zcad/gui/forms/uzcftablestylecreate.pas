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
  Модуль: uzcftablestylecreate
  Назначение: диалог создания нового стиля таблицы.
  Позволяет задать имя нового стиля и выбрать базовый стиль,
  на основе которого будет создан новый.
  Зависимости: uzestylestablesdxf, uzcdrawings, uzclog
}
unit uzcftablestylecreate;
{$INCLUDE zengineconfig.inc}
{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Buttons, ExtCtrls,
  uzclog,
  gzctnrVectorTypes,
  uzestylestablesdxf,
  uzcdrawings,
  uzedrawingsimple;

type
  { TTableStyleCreateForm — диалог создания нового стиля таблицы }
  TTableStyleCreateForm = class(TForm)
    LabelStyleName: TLabel;
    EditStyleName: TEdit;
    LabelBaseStyle: TLabel;
    ComboBaseStyle: TComboBox;
    ButtonNext: TBitBtn;
    ButtonCancel: TBitBtn;
    PanelBottom: TPanel;
    PanelContent: TPanel;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ButtonNextClick(Sender: TObject);
    procedure ButtonCancelClick(Sender: TObject);
    procedure ComboBaseStyleChange(Sender: TObject);
  private
    { Обновляет имя нового стиля при смене базового }
    procedure UpdateNewStyleName;
    { Заполняет комбобокс существующими стилями из текущего чертежа }
    procedure FillBaseStyleCombo;
  public
    { Имя нового стиля — результат диалога }
    NewStyleName: string;
    { Имя базового стиля — результат диалога }
    BaseStyleName: string;
  end;

var
  TableStyleCreateForm: TTableStyleCreateForm;

implementation
{$R *.lfm}

const
  { Шаблон имени для нового стиля: "Копия из <базовый>" }
  CNewStyleNameTemplate = 'Копия из %s';

{ Инициализация формы при создании }
procedure TTableStyleCreateForm.FormCreate(Sender: TObject);
begin
  NewStyleName := '';
  BaseStyleName := '';
end;

{ Заполнение комбобокса при отображении формы }
procedure TTableStyleCreateForm.FormShow(Sender: TObject);
begin
  FillBaseStyleCombo;
  UpdateNewStyleName;
  EditStyleName.SetFocus;
end;

{ Заполняет список базовых стилей из таблицы стилей текущего чертежа }
procedure TTableStyleCreateForm.FillBaseStyleCombo;
var
  StyleTable: PGDBDXFTableStyleArray;
  StyleItem: PTGDBDXFTableStyle;
  IterRec: itrec;
begin
  ComboBaseStyle.Items.Clear;
  StyleTable := @drawings.GetCurrentDWG^.DXFTableStyleTable;

  StyleItem := StyleTable^.beginiterate(IterRec);
  if StyleItem = nil then
    Exit;

  repeat
    ComboBaseStyle.Items.Add(StyleItem^.Name);
    StyleItem := StyleTable^.iterate(IterRec);
  until StyleItem = nil;

  { Выбираем первый элемент по умолчанию }
  if ComboBaseStyle.Items.Count > 0 then
    ComboBaseStyle.ItemIndex := 0;

  programlog.LogOutFormatStr(
    'uzcftablestylecreate: загружено стилей = %d',
    [ComboBaseStyle.Items.Count], LM_Info);
end;

{ Обновляет предлагаемое имя нового стиля на основе выбранного базового }
procedure TTableStyleCreateForm.UpdateNewStyleName;
var
  BaseName: string;
begin
  if ComboBaseStyle.ItemIndex < 0 then
    Exit;

  BaseName := ComboBaseStyle.Items[ComboBaseStyle.ItemIndex];
  EditStyleName.Text := Format(CNewStyleNameTemplate, [BaseName]);
end;

{ Обработчик смены базового стиля — обновляет предлагаемое имя }
procedure TTableStyleCreateForm.ComboBaseStyleChange(Sender: TObject);
begin
  UpdateNewStyleName;
end;

{ Нажатие "Далее" — сохраняет результаты и закрывает диалог }
procedure TTableStyleCreateForm.ButtonNextClick(Sender: TObject);
begin
  NewStyleName := Trim(EditStyleName.Text);
  if NewStyleName = '' then
  begin
    ShowMessage('Введите имя нового стиля.');
    EditStyleName.SetFocus;
    Exit;
  end;

  if ComboBaseStyle.ItemIndex >= 0 then
    BaseStyleName := ComboBaseStyle.Items[ComboBaseStyle.ItemIndex]
  else
    BaseStyleName := '';

  programlog.LogOutFormatStr(
    'uzcftablestylecreate: новый стиль "%s" на основе "%s"',
    [NewStyleName, BaseStyleName], LM_Info);

  ModalResult := mrOk;
end;

{ Нажатие "Отмена" — закрывает диалог без сохранения }
procedure TTableStyleCreateForm.ButtonCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

initialization
  programlog.LogOutFormatStr('Unit "%s" initialization', [{$INCLUDE %FILE%}],
    LM_Info, UnitsInitializeLMId);

finalization
  programlog.LogOutFormatStr('Unit "%s" finalization', [{$INCLUDE %FILE%}],
    LM_Info, UnitsFinalizeLMId);
end.
