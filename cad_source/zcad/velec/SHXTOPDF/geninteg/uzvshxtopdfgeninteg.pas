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
  Модуль: uzvshxtopdfgeninteg
  Назначение: Финальная интеграция SHX-шрифтов в PDF-страницы (Этап 7)

  Данный модуль является точкой входа для Этапа 7:
  - Принимает запросы на встраивание текста из CAD-системы
  - Координирует работу подмодулей (FontBind, TextWriter, Escape)
  - Использует результаты Этапов 4-6 (CharProcs, ToUnicode, Subset)
  - Формирует готовый PDF-контент для страницы

  Использование:
    1. CreatePdfIntegrator() - создать интегратор
    2. AddTextRequest() - добавить запрос на текст
    3. Process() - обработать все запросы
    4. GetResult() - получить результат

  Зависимости:
  - uzvshxtopdfgenintegtypes: типы данных
  - uzvshxtopdfgenintegfontbind: привязки шрифтов
  - uzvshxtopdfgenintegtextwriter: генерация текста
  - uzvshxtopdfgenintegescape: экранирование
  - uzvshxtopdfsubcachetypes: типы субсетинга
  - uzvshxtopdfsubcachesubset: менеджер субсетов
  - uzclog: логирование

  Module: uzvshxtopdfgeninteg
  Purpose: Final SHX font integration into PDF pages (Stage 7)

  This module is the entry point for Stage 7:
  - Accepts text embedding requests from CAD system
  - Coordinates submodules (FontBind, TextWriter, Escape)
  - Uses results from Stages 4-6 (CharProcs, ToUnicode, Subset)
  - Produces ready PDF content for page
}

unit uzvshxtopdfgeninteg;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Classes, Math,
  uzvshxtopdfgenintegtypes,
  uzvshxtopdfgenintegfontbind,
  uzvshxtopdfgenintegtextwriter,
  uzvshxtopdfgenintegescape,
  uzvshxtopdfsubcachetypes,
  uzclog;

type
  // Callback для получения PDF Object Reference для шрифта
  // Callback for getting PDF Object Reference for font
  //
  // Вызывается когда интегратору нужна ссылка на PDF-объект шрифта
  // Called when integrator needs PDF font object reference
  TGetFontRefCallback = function(
    const ShxFontName: AnsiString
  ): AnsiString of object;

  // Интегратор PDF для встраивания SHX-текста
  // PDF integrator for SHX text embedding
  TUzvPdfIntegrator = class
  private
    // Менеджер привязок шрифтов
    // Font bindings manager
    FFontBindManager: TUzvFontBindManager;

    // Генератор текстовых блоков
    // Text block generator
    FTextWriter: TUzvPdfTextWriter;

    // Массив запросов на текст
    // Text requests array
    FRequests: TUzvPdfTextRequestArray;

    // Callback для получения ссылок на шрифты
    // Callback for getting font references
    FGetFontRefCallback: TGetFontRefCallback;

    // Параметры генерации
    // Generation parameters
    FParams: TUzvTextBlockParams;

    // Флаг обработки
    // Processing flag
    FProcessed: Boolean;

    // Результат обработки
    // Processing result
    FResult: TUzvPdfEmbedResult;

    // Флаг включения логирования
    // Logging enabled flag
    FLoggingEnabled: Boolean;

    // Логировать сообщение
    // Log message
    procedure Log(const Msg: AnsiString);

    // Обеспечить привязку шрифта
    // Ensure font binding
    function EnsureFontBound(const ShxFontName: AnsiString): TUzvPdfFontBinding;

    // Преобразовать запрос в текстовый сегмент
    // Convert request to text segment
    function RequestToSegment(
      const Request: TUzvPdfTextRequest;
      const FontBinding: TUzvPdfFontBinding
    ): TUzvPdfTextSegment;

    // Вычислить матрицу для запроса
    // Calculate matrix for request
    function CalcRequestMatrix(
      const Request: TUzvPdfTextRequest
    ): TUzvPdfTextMatrix;

  public
    // Конструктор
    // Constructor
    constructor Create;

    // Конструктор с callback
    // Constructor with callback
    constructor Create(AGetFontRefCallback: TGetFontRefCallback);

    // Деструктор
    // Destructor
    destructor Destroy; override;

    // Добавить запрос на встраивание текста
    // Add text embedding request
    procedure AddTextRequest(const Request: TUzvPdfTextRequest);

    // Добавить запрос (упрощённая версия)
    // Add request (simplified version)
    procedure AddText(
      const Text: AnsiString;
      const ShxFontName: AnsiString;
      X, Y, Height: Double
    );

    // Добавить запрос с полными параметрами
    // Add request with full parameters
    procedure AddTextFull(
      const Text: AnsiString;
      const ShxFontName: AnsiString;
      X, Y, Height: Double;
      WidthFactor, ObliqueDeg, RotationDeg: Double
    );

    // Обработать все запросы
    // Process all requests
    //
    // Генерирует PDF-контент для всех добавленных текстов
    // Generates PDF content for all added texts
    procedure Process;

    // Получить результат обработки
    // Get processing result
    function GetResult: TUzvPdfEmbedResult;

    // Получить словарь /Resources /Font
    // Get /Resources /Font dictionary
    function GetResourcesFontDict: AnsiString;

    // Получить текстовый контент (BT/ET блоки)
    // Get text content (BT/ET blocks)
    function GetContentStream: AnsiString;

    // Получить статистику
    // Get statistics
    function GetStats: TUzvPdfIntegStats;

    // Получить количество запросов
    // Get requests count
    function GetRequestCount: Integer;

    // Очистить все запросы и результаты
    // Clear all requests and results
    procedure Clear;

    // Установить callback для получения ссылок на шрифты
    // Set callback for getting font references
    procedure SetFontRefCallback(ACallback: TGetFontRefCallback);

    // Свойства
    // Properties
    property Params: TUzvTextBlockParams read FParams write FParams;
    property LoggingEnabled: Boolean read FLoggingEnabled write FLoggingEnabled;
    property Processed: Boolean read FProcessed;
    property RequestCount: Integer read GetRequestCount;
  end;

// Создать интегратор PDF
// Create PDF integrator
function CreatePdfIntegrator: TUzvPdfIntegrator;

// Создать интегратор с callback
// Create integrator with callback
function CreatePdfIntegratorWithCallback(
  ACallback: TGetFontRefCallback
): TUzvPdfIntegrator;

// Быстрая генерация PDF-контента для одного текста
// Quick PDF content generation for single text
//
// Возвращает готовый BT/ET блок
// Returns ready BT/ET block
function GenerateSingleTextPdf(
  const Text: AnsiString;
  const PdfFontName: AnsiString;
  FontSize: Double;
  X, Y: Double
): AnsiString;

// Быстрая генерация PDF-контента с матрицей
// Quick PDF content generation with matrix
function GenerateSingleTextPdfWithMatrix(
  const Text: AnsiString;
  const PdfFontName: AnsiString;
  FontSize: Double;
  const Matrix: TUzvPdfTextMatrix
): AnsiString;

implementation

const
  LOG_PREFIX = 'GenInteg: ';
  DEFAULT_FONT_REF = '0 0 R';  // Заглушка для ссылки / Placeholder for reference

// Создать интегратор PDF
function CreatePdfIntegrator: TUzvPdfIntegrator;
begin
  Result := TUzvPdfIntegrator.Create;
end;

// Создать интегратор с callback
function CreatePdfIntegratorWithCallback(
  ACallback: TGetFontRefCallback
): TUzvPdfIntegrator;
begin
  Result := TUzvPdfIntegrator.Create(ACallback);
end;

// Быстрая генерация PDF-контента для одного текста
function GenerateSingleTextPdf(
  const Text: AnsiString;
  const PdfFontName: AnsiString;
  FontSize: Double;
  X, Y: Double
): AnsiString;
begin
  Result := GenerateSimpleTextBlock(Text, PdfFontName, FontSize, X, Y);
end;

// Быстрая генерация PDF-контента с матрицей
function GenerateSingleTextPdfWithMatrix(
  const Text: AnsiString;
  const PdfFontName: AnsiString;
  FontSize: Double;
  const Matrix: TUzvPdfTextMatrix
): AnsiString;
var
  Segments: TUzvPdfTextSegmentArray;
  Params: TUzvTextBlockParams;
begin
  SetLength(Segments, 1);
  Segments[0] := CreateEmptyTextSegment;
  Segments[0].Text := Text;
  Segments[0].FontName := PdfFontName;
  Segments[0].FontSize := FontSize;
  Segments[0].Matrix := Matrix;

  Params := GetDefaultTextBlockParams;
  Result := GenerateTextBlock(Segments, Params);
end;

{ TUzvPdfIntegrator }

constructor TUzvPdfIntegrator.Create;
begin
  inherited Create;

  FFontBindManager := CreateFontBindManager;
  FTextWriter := CreateTextWriter;

  SetLength(FRequests, 0);
  FGetFontRefCallback := nil;
  FParams := GetDefaultTextBlockParams;
  FProcessed := False;
  FResult := CreateErrorEmbedResult('Не обработано');
  FLoggingEnabled := True;

  Log('интегратор PDF создан');
end;

constructor TUzvPdfIntegrator.Create(AGetFontRefCallback: TGetFontRefCallback);
begin
  Create;
  FGetFontRefCallback := AGetFontRefCallback;
end;

destructor TUzvPdfIntegrator.Destroy;
begin
  FFontBindManager.Free;
  FTextWriter.Free;
  SetLength(FRequests, 0);

  Log('интегратор PDF уничтожен');

  inherited Destroy;
end;

procedure TUzvPdfIntegrator.Log(const Msg: AnsiString);
begin
  if FLoggingEnabled then
    programlog.LogOutStr(LOG_PREFIX + Msg, LM_Info);
end;

function TUzvPdfIntegrator.EnsureFontBound(
  const ShxFontName: AnsiString
): TUzvPdfFontBinding;
var
  FontRef: AnsiString;
begin
  // Проверяем, есть ли уже привязка
  // Check if binding already exists
  if FFontBindManager.FindBindingByShxName(ShxFontName, Result) then
    Exit;

  // Получаем ссылку на PDF-объект шрифта
  // Get PDF font object reference
  if Assigned(FGetFontRefCallback) then
    FontRef := FGetFontRefCallback(ShxFontName)
  else
    FontRef := DEFAULT_FONT_REF;

  // Создаём привязку
  // Create binding
  Result := FFontBindManager.BindFont(ShxFontName, FontRef);

  Log(Format('шрифт "%s" привязан как %s (ref: %s)',
    [ShxFontName, Result.PdfFontName, FontRef]));
end;

function TUzvPdfIntegrator.CalcRequestMatrix(
  const Request: TUzvPdfTextRequest
): TUzvPdfTextMatrix;
var
  RotationRad: Double;
  ObliqueRad: Double;
begin
  // Преобразуем градусы в радианы
  // Convert degrees to radians
  RotationRad := DegToRad(Request.RotationDeg);
  ObliqueRad := DegToRad(Request.ObliqueDeg);

  // Создаём матрицу трансформации
  // Create transformation matrix
  Result := CreateTextMatrix(
    Request.X,
    Request.Y,
    Request.WidthFactor,   // Масштаб X учитывает WidthFactor
    1.0,                    // Масштаб Y = 1 (высота задаётся FontSize)
    RotationRad,
    ObliqueRad
  );
end;

function TUzvPdfIntegrator.RequestToSegment(
  const Request: TUzvPdfTextRequest;
  const FontBinding: TUzvPdfFontBinding
): TUzvPdfTextSegment;
begin
  Result := CreateEmptyTextSegment;
  Result.Text := Request.Text;
  Result.FontName := FontBinding.PdfFontName;
  Result.FontSize := Request.Height;  // Размер шрифта = высота текста
  Result.Matrix := CalcRequestMatrix(Request);
end;

procedure TUzvPdfIntegrator.AddTextRequest(const Request: TUzvPdfTextRequest);
var
  NewIndex: Integer;
begin
  NewIndex := Length(FRequests);
  SetLength(FRequests, NewIndex + 1);
  FRequests[NewIndex] := Request;

  // Сбрасываем флаг обработки
  // Reset processed flag
  FProcessed := False;

  Log(Format('добавлен запрос: текст="%s", шрифт=%s, pos=(%.2f, %.2f)',
    [Request.Text, Request.ShxFontName, Request.X, Request.Y]));
end;

procedure TUzvPdfIntegrator.AddText(
  const Text: AnsiString;
  const ShxFontName: AnsiString;
  X, Y, Height: Double
);
begin
  AddTextRequest(CreateTextRequestSimple(Text, ShxFontName, X, Y, Height));
end;

procedure TUzvPdfIntegrator.AddTextFull(
  const Text: AnsiString;
  const ShxFontName: AnsiString;
  X, Y, Height: Double;
  WidthFactor, ObliqueDeg, RotationDeg: Double
);
begin
  AddTextRequest(CreateTextRequest(
    Text, ShxFontName, X, Y, Height,
    WidthFactor, ObliqueDeg, RotationDeg
  ));
end;

procedure TUzvPdfIntegrator.Process;
var
  I: Integer;
  FontBinding: TUzvPdfFontBinding;
  Segment: TUzvPdfTextSegment;
  Stats: TUzvPdfIntegStats;
begin
  Log(Format('начало обработки: %d запросов', [Length(FRequests)]));

  // Проверка на пустой список запросов
  // Check for empty requests list
  if Length(FRequests) = 0 then
  begin
    FResult := CreateSuccessEmbedResult('', '', CreateEmptyIntegStats);
    FProcessed := True;
    Log('обработка завершена: нет запросов');
    Exit;
  end;

  // Очищаем буфер текстового генератора
  // Clear text generator buffer
  FTextWriter.Clear;
  FTextWriter.Params := FParams;
  FTextWriter.LoggingEnabled := FLoggingEnabled;

  // Начинаем текстовый блок
  // Begin text block
  FTextWriter.BeginText;

  // Обрабатываем каждый запрос
  // Process each request
  for I := 0 to High(FRequests) do
  begin
    // Обеспечиваем привязку шрифта
    // Ensure font binding
    FontBinding := EnsureFontBound(FRequests[I].ShxFontName);

    // Преобразуем запрос в сегмент
    // Convert request to segment
    Segment := RequestToSegment(FRequests[I], FontBinding);

    // Записываем сегмент
    // Write segment
    FTextWriter.WriteSegment(Segment);
  end;

  // Заканчиваем текстовый блок
  // End text block
  FTextWriter.EndText;

  // Собираем статистику
  // Collect statistics
  Stats := FTextWriter.GetStats;
  Stats.TotalFonts := FFontBindManager.FontCount;
  Stats.TotalTextBlocks := 1;  // Пока один блок BT/ET

  // Формируем результат
  // Build result
  FResult := CreateSuccessEmbedResult(
    FFontBindManager.BuildResourcesDict,
    FTextWriter.GetStream,
    Stats
  );

  FProcessed := True;

  Log(Format('обработка завершена: шрифтов=%d, сегментов=%d, символов=%d',
    [Stats.TotalFonts, Stats.TotalSegments, Stats.TotalCharacters]));
end;

function TUzvPdfIntegrator.GetResult: TUzvPdfEmbedResult;
begin
  if not FProcessed then
    Process;

  Result := FResult;
end;

function TUzvPdfIntegrator.GetResourcesFontDict: AnsiString;
begin
  if not FProcessed then
    Process;

  Result := FResult.ResourcesDict;
end;

function TUzvPdfIntegrator.GetContentStream: AnsiString;
begin
  if not FProcessed then
    Process;

  Result := FResult.ContentStream;
end;

function TUzvPdfIntegrator.GetStats: TUzvPdfIntegStats;
begin
  if not FProcessed then
    Process;

  Result := FResult.Stats;
end;

function TUzvPdfIntegrator.GetRequestCount: Integer;
begin
  Result := Length(FRequests);
end;

procedure TUzvPdfIntegrator.Clear;
begin
  SetLength(FRequests, 0);
  FFontBindManager.Clear;
  FTextWriter.Clear;
  FProcessed := False;
  FResult := CreateErrorEmbedResult('Не обработано');

  Log('все запросы и результаты очищены');
end;

procedure TUzvPdfIntegrator.SetFontRefCallback(ACallback: TGetFontRefCallback);
begin
  FGetFontRefCallback := ACallback;
end;

end.
