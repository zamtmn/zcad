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
  Модуль: uzvshxtopdfgenintegfontbind
  Назначение: Регистрация шрифтов в PDF-странице для Этапа 7

  Данный модуль реализует:
  - Автоматическое присвоение PDF-имён шрифтам (/F1, /F2, ...)
  - Построение словаря /Resources /Font
  - Управление привязками шрифтов на странице
  - Поиск привязки по имени SHX-шрифта

  Использование:
    1. CreateFontBindManager() - создать менеджер
    2. BindFont() - зарегистрировать шрифт
    3. BuildResourcesDict() - получить словарь /Font
    4. FindBindingByShxName() - найти привязку по имени

  Зависимости:
  - uzvshxtopdfgenintegtypes: типы данных
  - uzclog: логирование

  Module: uzvshxtopdfgenintegfontbind
  Purpose: Font registration in PDF page for Stage 7

  This module implements:
  - Automatic PDF name assignment for fonts (/F1, /F2, ...)
  - Building /Resources /Font dictionary
  - Managing font bindings on page
  - Finding binding by SHX font name
}

unit uzvshxtopdfgenintegfontbind;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Classes,
  uzvshxtopdfgenintegtypes,
  uzclog;

type
  // Менеджер привязок шрифтов
  // Font bindings manager
  TUzvFontBindManager = class
  private
    // Массив привязок
    // Bindings array
    FBindings: TUzvPdfFontBindingArray;

    // Счётчик шрифтов для генерации имён /F1, /F2, ...
    // Font counter for name generation /F1, /F2, ...
    FFontCounter: Integer;

    // Флаг включения логирования
    // Logging enabled flag
    FLoggingEnabled: Boolean;

    // Логировать сообщение
    // Log message
    procedure Log(const Msg: AnsiString);

    // Найти индекс привязки по имени SHX
    // Find binding index by SHX name
    function FindBindingIndex(const ShxFontName: AnsiString): Integer;

    // Сгенерировать PDF-имя шрифта
    // Generate PDF font name
    function GeneratePdfFontName: AnsiString;

  public
    // Конструктор
    // Constructor
    constructor Create;

    // Деструктор
    // Destructor
    destructor Destroy; override;

    // Зарегистрировать шрифт
    // Bind font
    //
    // Если шрифт уже зарегистрирован, возвращает существующую привязку.
    // Иначе создаёт новую привязку с автоматическим PDF-именем.
    //
    // If font is already bound, returns existing binding.
    // Otherwise creates new binding with automatic PDF name.
    //
    // Параметры:
    //   ShxFontName: имя SHX-шрифта
    //   PdfObjectRef: ссылка на PDF-объект шрифта (например, "10 0 R")
    //
    // Parameters:
    //   ShxFontName: SHX font name
    //   PdfObjectRef: PDF font object reference (e.g., "10 0 R")
    function BindFont(
      const ShxFontName: AnsiString;
      const PdfObjectRef: AnsiString
    ): TUzvPdfFontBinding;

    // Найти привязку по имени SHX-шрифта
    // Find binding by SHX font name
    //
    // Возвращает True если найдена, привязка записывается в OutBinding
    // Returns True if found, binding is written to OutBinding
    function FindBindingByShxName(
      const ShxFontName: AnsiString;
      out OutBinding: TUzvPdfFontBinding
    ): Boolean;

    // Найти привязку по PDF-имени
    // Find binding by PDF name
    function FindBindingByPdfName(
      const PdfFontName: AnsiString;
      out OutBinding: TUzvPdfFontBinding
    ): Boolean;

    // Получить PDF-имя шрифта по имени SHX
    // Get PDF font name by SHX name
    //
    // Возвращает пустую строку если шрифт не зарегистрирован
    // Returns empty string if font is not bound
    function GetPdfFontName(const ShxFontName: AnsiString): AnsiString;

    // Проверить, зарегистрирован ли шрифт
    // Check if font is bound
    function IsFontBound(const ShxFontName: AnsiString): Boolean;

    // Получить количество зарегистрированных шрифтов
    // Get bound fonts count
    function GetFontCount: Integer;

    // Получить все привязки
    // Get all bindings
    function GetAllBindings: TUzvPdfFontBindingArray;

    // Построить словарь /Font для /Resources
    // Build /Font dictionary for /Resources
    //
    // Пример результата:
    //   << /F1 10 0 R /F2 11 0 R >>
    //
    // Example result:
    //   << /F1 10 0 R /F2 11 0 R >>
    function BuildResourcesDict: AnsiString;

    // Очистить все привязки
    // Clear all bindings
    procedure Clear;

    // Включить/выключить логирование
    // Enable/disable logging
    property LoggingEnabled: Boolean read FLoggingEnabled write FLoggingEnabled;

    // Количество зарегистрированных шрифтов
    // Bound fonts count
    property FontCount: Integer read GetFontCount;
  end;

// Создать менеджер привязок шрифтов
// Create font bindings manager
function CreateFontBindManager: TUzvFontBindManager;

// Построить словарь /Font из массива привязок
// Build /Font dictionary from bindings array
function BuildFontDictFromBindings(
  const Bindings: TUzvPdfFontBindingArray
): AnsiString;

implementation

const
  LOG_PREFIX = 'FontBind: ';
  PDF_FONT_PREFIX = '/F';

// Создать менеджер привязок шрифтов
function CreateFontBindManager: TUzvFontBindManager;
begin
  Result := TUzvFontBindManager.Create;
end;

// Построить словарь /Font из массива привязок
function BuildFontDictFromBindings(
  const Bindings: TUzvPdfFontBindingArray
): AnsiString;
var
  I: Integer;
begin
  if Length(Bindings) = 0 then
  begin
    Result := '<< >>';
    Exit;
  end;

  Result := '<<';
  for I := 0 to High(Bindings) do
  begin
    Result := Result + ' ' + Bindings[I].PdfFontName +
              ' ' + Bindings[I].PdfObjectRef;
  end;
  Result := Result + ' >>';
end;

{ TUzvFontBindManager }

constructor TUzvFontBindManager.Create;
begin
  inherited Create;

  SetLength(FBindings, 0);
  FFontCounter := 0;
  FLoggingEnabled := True;

  Log('менеджер привязок шрифтов создан');
end;

destructor TUzvFontBindManager.Destroy;
begin
  Clear;
  Log('менеджер привязок шрифтов уничтожен');
  inherited Destroy;
end;

procedure TUzvFontBindManager.Log(const Msg: AnsiString);
begin
  if FLoggingEnabled then
    programlog.LogOutStr(LOG_PREFIX + Msg, LM_Info);
end;

function TUzvFontBindManager.FindBindingIndex(
  const ShxFontName: AnsiString
): Integer;
var
  I: Integer;
begin
  Result := -1;

  for I := 0 to High(FBindings) do
  begin
    // Сравнение без учёта регистра
    // Case-insensitive comparison
    if SameText(FBindings[I].ShxFontName, ShxFontName) then
    begin
      Result := I;
      Exit;
    end;
  end;
end;

function TUzvFontBindManager.GeneratePdfFontName: AnsiString;
begin
  Inc(FFontCounter);
  Result := PDF_FONT_PREFIX + IntToStr(FFontCounter);
end;

function TUzvFontBindManager.BindFont(
  const ShxFontName: AnsiString;
  const PdfObjectRef: AnsiString
): TUzvPdfFontBinding;
var
  ExistingIndex: Integer;
  NewBinding: TUzvPdfFontBinding;
  NewIndex: Integer;
begin
  // Проверяем, не зарегистрирован ли уже шрифт
  // Check if font is already bound
  ExistingIndex := FindBindingIndex(ShxFontName);

  if ExistingIndex >= 0 then
  begin
    // Шрифт уже зарегистрирован
    // Font is already bound
    Result := FBindings[ExistingIndex];
    Log(Format('шрифт "%s" уже зарегистрирован как %s',
      [ShxFontName, Result.PdfFontName]));
    Exit;
  end;

  // Создаём новую привязку
  // Create new binding
  NewBinding := CreateFontBinding(
    ShxFontName,
    GeneratePdfFontName,
    PdfObjectRef,
    Length(FBindings)
  );

  // Добавляем в массив
  // Add to array
  NewIndex := Length(FBindings);
  SetLength(FBindings, NewIndex + 1);
  FBindings[NewIndex] := NewBinding;

  Log(Format('шрифт "%s" зарегистрирован как %s (ref: %s)',
    [ShxFontName, NewBinding.PdfFontName, PdfObjectRef]));

  Result := NewBinding;
end;

function TUzvFontBindManager.FindBindingByShxName(
  const ShxFontName: AnsiString;
  out OutBinding: TUzvPdfFontBinding
): Boolean;
var
  Index: Integer;
begin
  Result := False;
  OutBinding := CreateEmptyFontBinding;

  Index := FindBindingIndex(ShxFontName);
  if Index >= 0 then
  begin
    OutBinding := FBindings[Index];
    Result := True;
  end;
end;

function TUzvFontBindManager.FindBindingByPdfName(
  const PdfFontName: AnsiString;
  out OutBinding: TUzvPdfFontBinding
): Boolean;
var
  I: Integer;
begin
  Result := False;
  OutBinding := CreateEmptyFontBinding;

  for I := 0 to High(FBindings) do
  begin
    if SameText(FBindings[I].PdfFontName, PdfFontName) then
    begin
      OutBinding := FBindings[I];
      Result := True;
      Exit;
    end;
  end;
end;

function TUzvFontBindManager.GetPdfFontName(
  const ShxFontName: AnsiString
): AnsiString;
var
  Index: Integer;
begin
  Result := '';

  Index := FindBindingIndex(ShxFontName);
  if Index >= 0 then
    Result := FBindings[Index].PdfFontName;
end;

function TUzvFontBindManager.IsFontBound(const ShxFontName: AnsiString): Boolean;
begin
  Result := FindBindingIndex(ShxFontName) >= 0;
end;

function TUzvFontBindManager.GetFontCount: Integer;
begin
  Result := Length(FBindings);
end;

function TUzvFontBindManager.GetAllBindings: TUzvPdfFontBindingArray;
begin
  Result := FBindings;
end;

function TUzvFontBindManager.BuildResourcesDict: AnsiString;
begin
  Result := BuildFontDictFromBindings(FBindings);

  Log(Format('словарь /Font построен: %d шрифтов', [Length(FBindings)]));
end;

procedure TUzvFontBindManager.Clear;
begin
  SetLength(FBindings, 0);
  FFontCounter := 0;

  Log('все привязки очищены');
end;

end.
