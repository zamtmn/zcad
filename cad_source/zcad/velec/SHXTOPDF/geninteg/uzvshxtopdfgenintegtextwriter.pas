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
  Модуль: uzvshxtopdfgenintegtextwriter
  Назначение: Генерация текстовых блоков BT/ET для PDF (Этап 7)

  Данный модуль реализует:
  - Генерацию операторов BT (Begin Text) и ET (End Text)
  - Оператор Tf для установки шрифта и размера
  - Оператор Tm для установки матрицы трансформации текста
  - Операторы Tj и TJ для вывода текста
  - Оптимизацию переключений шрифта

  Формат PDF текстовых операторов:
    BT                     - начало текстового блока
    /F1 12 Tf             - установка шрифта F1, размер 12
    1 0 0 1 100 700 Tm    - установка матрицы позиционирования
    (Hello) Tj            - вывод текста
    ET                     - конец текстового блока

  Зависимости:
  - uzvshxtopdfgenintegtypes: типы данных
  - uzvshxtopdfgenintegescape: экранирование строк
  - uzvshxtopdfgenintegfontbind: привязки шрифтов
  - uzclog: логирование

  Module: uzvshxtopdfgenintegtextwriter
  Purpose: BT/ET text block generation for PDF (Stage 7)

  This module implements:
  - BT (Begin Text) and ET (End Text) operator generation
  - Tf operator for font and size setting
  - Tm operator for text transformation matrix setting
  - Tj and TJ operators for text output
  - Font switching optimization
}

unit uzvshxtopdfgenintegtextwriter;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Classes,
  uzvshxtopdfgenintegtypes,
  uzvshxtopdfgenintegescape,
  uzvshxtopdfgenintegfontbind,
  uzclog;

type
  // Генератор текстовых блоков PDF
  // PDF text block generator
  TUzvPdfTextWriter = class
  private
    // Параметры генерации
    // Generation parameters
    FParams: TUzvTextBlockParams;

    // Текущий шрифт (для оптимизации Tf)
    // Current font (for Tf optimization)
    FCurrentFont: AnsiString;

    // Текущий размер шрифта
    // Current font size
    FCurrentFontSize: Double;

    // Счётчик переключений шрифта
    // Font switch counter
    FFontSwitchCount: Integer;

    // Счётчик сегментов
    // Segment counter
    FSegmentCount: Integer;

    // Счётчик символов
    // Character counter
    FCharCount: Integer;

    // Буфер для накопления стрима
    // Buffer for stream accumulation
    FStreamBuffer: TStringList;

    // Флаг включения логирования
    // Logging enabled flag
    FLoggingEnabled: Boolean;

    // Логировать сообщение
    // Log message
    procedure Log(const Msg: AnsiString);

    // Форматировать Double для PDF
    // Format Double for PDF
    function FormatDouble(Value: Double): AnsiString;

    // Форматировать матрицу для PDF
    // Format matrix for PDF
    function FormatTextMatrix(const Matrix: TUzvPdfTextMatrix): AnsiString;

    // Записать оператор Tf (если нужно)
    // Write Tf operator (if needed)
    procedure WriteTfIfNeeded(
      const FontName: AnsiString;
      FontSize: Double
    );

    // Записать оператор Tm
    // Write Tm operator
    procedure WriteTm(const Matrix: TUzvPdfTextMatrix);

    // Записать оператор Tj
    // Write Tj operator
    procedure WriteTj(const Text: AnsiString);

    // Записать оператор TJ (с кернингом)
    // Write TJ operator (with kerning)
    procedure WriteTJ(const Items: array of AnsiString);

    // Записать строку в буфер
    // Write line to buffer
    procedure WriteLine(const Line: AnsiString);

  public
    // Конструктор
    // Constructor
    constructor Create;

    // Конструктор с параметрами
    // Constructor with parameters
    constructor Create(const AParams: TUzvTextBlockParams);

    // Деструктор
    // Destructor
    destructor Destroy; override;

    // Начать текстовый блок (BT)
    // Begin text block (BT)
    procedure BeginText;

    // Закончить текстовый блок (ET)
    // End text block (ET)
    procedure EndText;

    // Записать текстовый сегмент
    // Write text segment
    //
    // Генерирует Tf (если нужно), Tm и Tj операторы
    // Generates Tf (if needed), Tm and Tj operators
    procedure WriteSegment(const Segment: TUzvPdfTextSegment);

    // Записать массив сегментов
    // Write segments array
    procedure WriteSegments(const Segments: TUzvPdfTextSegmentArray);

    // Записать текст с позиционированием
    // Write text with positioning
    //
    // Упрощённая версия для быстрого вывода текста
    // Simplified version for quick text output
    procedure WriteText(
      const Text: AnsiString;
      const FontName: AnsiString;
      FontSize: Double;
      X, Y: Double
    );

    // Записать текст с полной матрицей
    // Write text with full matrix
    procedure WriteTextWithMatrix(
      const Text: AnsiString;
      const FontName: AnsiString;
      FontSize: Double;
      const Matrix: TUzvPdfTextMatrix
    );

    // Получить накопленный стрим
    // Get accumulated stream
    function GetStream: AnsiString;

    // Очистить буфер
    // Clear buffer
    procedure Clear;

    // Сбросить состояние шрифта
    // Reset font state
    procedure ResetFontState;

    // Получить статистику
    // Get statistics
    function GetStats: TUzvPdfIntegStats;

    // Свойства
    // Properties
    property Params: TUzvTextBlockParams read FParams write FParams;
    property LoggingEnabled: Boolean read FLoggingEnabled write FLoggingEnabled;
    property FontSwitchCount: Integer read FFontSwitchCount;
    property SegmentCount: Integer read FSegmentCount;
    property CharCount: Integer read FCharCount;
  end;

// Создать генератор текстовых блоков
// Create text block generator
function CreateTextWriter: TUzvPdfTextWriter;

// Создать генератор с параметрами
// Create generator with parameters
function CreateTextWriterWithParams(
  const Params: TUzvTextBlockParams
): TUzvPdfTextWriter;

// Сгенерировать полный текстовый блок BT/ET
// Generate complete BT/ET text block
//
// Принимает массив сегментов и возвращает готовый PDF-стрим
// Takes segments array and returns ready PDF stream
function GenerateTextBlock(
  const Segments: TUzvPdfTextSegmentArray;
  const Params: TUzvTextBlockParams
): AnsiString;

// Сгенерировать простой текстовый блок
// Generate simple text block
//
// Для одного текста с одним шрифтом
// For single text with single font
function GenerateSimpleTextBlock(
  const Text: AnsiString;
  const FontName: AnsiString;
  FontSize: Double;
  X, Y: Double
): AnsiString;

implementation

uses
  Math;

const
  LOG_PREFIX = 'TextWriter: ';

  // PDF операторы
  // PDF operators
  PDF_BT = 'BT';
  PDF_ET = 'ET';
  PDF_TF = 'Tf';
  PDF_TM = 'Tm';
  PDF_TJ = 'Tj';
  PDF_TJ_ARRAY = 'TJ';

// Создать генератор текстовых блоков
function CreateTextWriter: TUzvPdfTextWriter;
begin
  Result := TUzvPdfTextWriter.Create;
end;

// Создать генератор с параметрами
function CreateTextWriterWithParams(
  const Params: TUzvTextBlockParams
): TUzvPdfTextWriter;
begin
  Result := TUzvPdfTextWriter.Create(Params);
end;

// Сгенерировать полный текстовый блок
function GenerateTextBlock(
  const Segments: TUzvPdfTextSegmentArray;
  const Params: TUzvTextBlockParams
): AnsiString;
var
  Writer: TUzvPdfTextWriter;
begin
  Writer := CreateTextWriterWithParams(Params);
  try
    Writer.LoggingEnabled := False;
    Writer.BeginText;
    Writer.WriteSegments(Segments);
    Writer.EndText;
    Result := Writer.GetStream;
  finally
    Writer.Free;
  end;
end;

// Сгенерировать простой текстовый блок
function GenerateSimpleTextBlock(
  const Text: AnsiString;
  const FontName: AnsiString;
  FontSize: Double;
  X, Y: Double
): AnsiString;
var
  Writer: TUzvPdfTextWriter;
begin
  Writer := CreateTextWriter;
  try
    Writer.LoggingEnabled := False;
    Writer.BeginText;
    Writer.WriteText(Text, FontName, FontSize, X, Y);
    Writer.EndText;
    Result := Writer.GetStream;
  finally
    Writer.Free;
  end;
end;

{ TUzvPdfTextWriter }

constructor TUzvPdfTextWriter.Create;
begin
  inherited Create;

  FParams := GetDefaultTextBlockParams;
  FCurrentFont := '';
  FCurrentFontSize := 0.0;
  FFontSwitchCount := 0;
  FSegmentCount := 0;
  FCharCount := 0;
  FLoggingEnabled := True;

  FStreamBuffer := TStringList.Create;

  Log('генератор текстовых блоков создан');
end;

constructor TUzvPdfTextWriter.Create(const AParams: TUzvTextBlockParams);
begin
  Create;
  FParams := AParams;
end;

destructor TUzvPdfTextWriter.Destroy;
begin
  FStreamBuffer.Free;
  Log('генератор текстовых блоков уничтожен');
  inherited Destroy;
end;

procedure TUzvPdfTextWriter.Log(const Msg: AnsiString);
begin
  if FLoggingEnabled then
    programlog.LogOutStr(LOG_PREFIX + Msg, LM_Info);
end;

function TUzvPdfTextWriter.FormatDouble(Value: Double): AnsiString;
var
  FormatStr: AnsiString;
begin
  // Формируем строку формата для заданной точности
  // Build format string for specified precision
  FormatStr := '%.' + IntToStr(FParams.CoordPrecision) + 'f';

  // Используем точку как разделитель (PDF стандарт)
  // Use dot as separator (PDF standard)
  Result := FormatFloat('0.' + StringOfChar('0', FParams.CoordPrecision), Value);

  // Заменяем запятую на точку (для локалей с запятой)
  // Replace comma with dot (for locales with comma)
  Result := StringReplace(Result, ',', '.', [rfReplaceAll]);

  // Убираем незначащие нули справа, но оставляем хотя бы один после точки
  // Remove trailing zeros, but keep at least one after dot
  while (Length(Result) > 1) and (Result[Length(Result)] = '0') and
        (Result[Length(Result) - 1] <> '.') do
    Delete(Result, Length(Result), 1);
end;

function TUzvPdfTextWriter.FormatTextMatrix(
  const Matrix: TUzvPdfTextMatrix
): AnsiString;
begin
  // Формат: a b c d e f Tm
  // Format: a b c d e f Tm
  Result := FormatDouble(Matrix.A) + ' ' +
            FormatDouble(Matrix.B) + ' ' +
            FormatDouble(Matrix.C) + ' ' +
            FormatDouble(Matrix.D) + ' ' +
            FormatDouble(Matrix.E) + ' ' +
            FormatDouble(Matrix.F);
end;

procedure TUzvPdfTextWriter.WriteLine(const Line: AnsiString);
begin
  FStreamBuffer.Add(Line);
end;

procedure TUzvPdfTextWriter.WriteTfIfNeeded(
  const FontName: AnsiString;
  FontSize: Double
);
var
  NeedSwitch: Boolean;
begin
  NeedSwitch := False;

  // Проверяем, нужно ли переключать шрифт
  // Check if font switch is needed
  if not SameText(FCurrentFont, FontName) then
    NeedSwitch := True;

  if Abs(FCurrentFontSize - FontSize) > 0.001 then
    NeedSwitch := True;

  if NeedSwitch then
  begin
    // Записываем оператор Tf
    // Write Tf operator
    WriteLine(FontName + ' ' + FormatDouble(FontSize) + ' ' + PDF_TF);

    FCurrentFont := FontName;
    FCurrentFontSize := FontSize;
    Inc(FFontSwitchCount);

    Log(Format('переключение шрифта: %s %.2f', [FontName, FontSize]));
  end;
end;

procedure TUzvPdfTextWriter.WriteTm(const Matrix: TUzvPdfTextMatrix);
begin
  WriteLine(FormatTextMatrix(Matrix) + ' ' + PDF_TM);
end;

procedure TUzvPdfTextWriter.WriteTj(const Text: AnsiString);
var
  EscapedText: AnsiString;
begin
  // Экранируем текст и оборачиваем в скобки
  // Escape text and wrap in parentheses
  EscapedText := WrapInPdfParens(Text);
  WriteLine(EscapedText + ' ' + PDF_TJ);
end;

procedure TUzvPdfTextWriter.WriteTJ(const Items: array of AnsiString);
var
  I: Integer;
  ArrayStr: AnsiString;
begin
  // Формируем массив для TJ: [(text) kern (text) ...]
  // Build array for TJ: [(text) kern (text) ...]
  ArrayStr := '[';
  for I := 0 to High(Items) do
  begin
    if I > 0 then
      ArrayStr := ArrayStr + ' ';
    ArrayStr := ArrayStr + Items[I];
  end;
  ArrayStr := ArrayStr + ']';

  WriteLine(ArrayStr + ' ' + PDF_TJ_ARRAY);
end;

procedure TUzvPdfTextWriter.BeginText;
begin
  WriteLine(PDF_BT);
  ResetFontState;
  Log('начало текстового блока (BT)');
end;

procedure TUzvPdfTextWriter.EndText;
begin
  WriteLine(PDF_ET);
  Log(Format('конец текстового блока (ET): сегментов=%d, символов=%d, ' +
    'переключений шрифта=%d', [FSegmentCount, FCharCount, FFontSwitchCount]));
end;

procedure TUzvPdfTextWriter.WriteSegment(const Segment: TUzvPdfTextSegment);
begin
  // Устанавливаем шрифт (если нужно)
  // Set font (if needed)
  WriteTfIfNeeded(Segment.FontName, Segment.FontSize);

  // Устанавливаем матрицу позиционирования
  // Set positioning matrix
  WriteTm(Segment.Matrix);

  // Выводим текст
  // Output text
  WriteTj(Segment.Text);

  // Обновляем счётчики
  // Update counters
  Inc(FSegmentCount);
  Inc(FCharCount, Length(Segment.Text));

  Log(Format('записан сегмент: шрифт=%s, символов=%d',
    [Segment.FontName, Length(Segment.Text)]));
end;

procedure TUzvPdfTextWriter.WriteSegments(
  const Segments: TUzvPdfTextSegmentArray
);
var
  I: Integer;
begin
  for I := 0 to High(Segments) do
    WriteSegment(Segments[I]);
end;

procedure TUzvPdfTextWriter.WriteText(
  const Text: AnsiString;
  const FontName: AnsiString;
  FontSize: Double;
  X, Y: Double
);
var
  Segment: TUzvPdfTextSegment;
begin
  Segment := CreateEmptyTextSegment;
  Segment.Text := Text;
  Segment.FontName := FontName;
  Segment.FontSize := FontSize;
  Segment.Matrix := CreateTextMatrix(X, Y, 1.0, 1.0, 0.0, 0.0);

  WriteSegment(Segment);
end;

procedure TUzvPdfTextWriter.WriteTextWithMatrix(
  const Text: AnsiString;
  const FontName: AnsiString;
  FontSize: Double;
  const Matrix: TUzvPdfTextMatrix
);
var
  Segment: TUzvPdfTextSegment;
begin
  Segment := CreateEmptyTextSegment;
  Segment.Text := Text;
  Segment.FontName := FontName;
  Segment.FontSize := FontSize;
  Segment.Matrix := Matrix;

  WriteSegment(Segment);
end;

function TUzvPdfTextWriter.GetStream: AnsiString;
var
  I: Integer;
begin
  Result := '';

  for I := 0 to FStreamBuffer.Count - 1 do
  begin
    if I > 0 then
      Result := Result + #10;  // Перенос строки / Line feed
    Result := Result + FStreamBuffer[I];
  end;
end;

procedure TUzvPdfTextWriter.Clear;
begin
  FStreamBuffer.Clear;
  FSegmentCount := 0;
  FCharCount := 0;
  FFontSwitchCount := 0;
  ResetFontState;

  Log('буфер очищен');
end;

procedure TUzvPdfTextWriter.ResetFontState;
begin
  FCurrentFont := '';
  FCurrentFontSize := 0.0;
end;

function TUzvPdfTextWriter.GetStats: TUzvPdfIntegStats;
begin
  Result := CreateEmptyIntegStats;
  Result.TotalSegments := FSegmentCount;
  Result.TotalCharacters := FCharCount;
  Result.FontSwitches := FFontSwitchCount;
end;

end.
