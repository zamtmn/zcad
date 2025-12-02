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
  Модуль: uzvshxtopdfgenintegtypes
  Назначение: Типы данных для Этапа 7 конвейера SHX -> PDF (GenInteg)

  Данный модуль содержит структуры данных для:
  - Регистрации шрифтов в PDF-странице (FontBinding)
  - Текстовых блоков BT/ET
  - Параметров позиционирования текста
  - Статистики интеграции

  Зависимости:
  - uzvshxtopdfsubcachetypes: типы данных Этапа 6
  - uzvshxtopdfcharprocstypes: типы данных Этапа 4

  Module: uzvshxtopdfgenintegtypes
  Purpose: Data types for Stage 7 of SHX -> PDF pipeline (GenInteg)

  This module contains data structures for:
  - Font registration in PDF page (FontBinding)
  - Text blocks BT/ET
  - Text positioning parameters
  - Integration statistics
}

unit uzvshxtopdfgenintegtypes;

{$mode objfpc}{$H+}

interface

uses
  SysUtils,
  uzvshxtopdfsubcachetypes,
  uzvshxtopdfcharprocstypes;

type
  // Привязка шрифта к PDF-странице
  // Font binding to PDF page
  //
  // Связывает:
  //   - Имя SHX-шрифта (исходное)
  //   - PDF-имя шрифта (/F1, /F2, ...)
  //   - Ссылку на PDF-объект шрифта
  TUzvPdfFontBinding = record
    ShxFontName: AnsiString;    // Имя SHX-шрифта / SHX font name
    PdfFontName: AnsiString;    // PDF-имя (/F1, /F2, ...) / PDF name
    PdfObjectRef: AnsiString;   // Ссылка на объект (10 0 R) / Object reference
    FontIndex: Integer;         // Индекс шрифта на странице / Font index on page
  end;

  // Массив привязок шрифтов
  // Font bindings array
  TUzvPdfFontBindingArray = array of TUzvPdfFontBinding;

  // Матрица трансформации текста для PDF (Tm)
  // Text transformation matrix for PDF (Tm)
  //
  // Формат: [a b c d e f]
  // Применяется оператором Tm: a b c d e f Tm
  TUzvPdfTextMatrix = record
    A: Double;  // Масштаб по X / X scale
    B: Double;  // Наклон / Skew
    C: Double;  // Наклон / Skew
    D: Double;  // Масштаб по Y / Y scale
    E: Double;  // Смещение X / X translation
    F: Double;  // Смещение Y / Y translation
  end;

  // Текстовый сегмент внутри блока BT/ET
  // Text segment inside BT/ET block
  //
  // Один сегмент = один вызов Tj или TJ
  TUzvPdfTextSegment = record
    Text: AnsiString;           // Закодированный текст / Encoded text
    FontName: AnsiString;       // PDF-имя шрифта / PDF font name
    FontSize: Double;           // Размер шрифта / Font size
    Matrix: TUzvPdfTextMatrix;  // Матрица позиционирования / Position matrix
  end;

  // Массив текстовых сегментов
  // Text segments array
  TUzvPdfTextSegmentArray = array of TUzvPdfTextSegment;

  // Текстовый блок BT/ET
  // Text block BT/ET
  //
  // Содержит все текстовые операции между BT и ET
  TUzvPdfTextBlock = record
    Segments: TUzvPdfTextSegmentArray;  // Текстовые сегменты / Text segments
    Stream: AnsiString;                  // Готовый PDF-стрим / Ready PDF stream
  end;

  // Массив текстовых блоков
  // Text blocks array
  TUzvPdfTextBlockArray = array of TUzvPdfTextBlock;

  // Параметры генерации текстового блока
  // Text block generation parameters
  TUzvTextBlockParams = record
    // Точность координат (знаков после запятой)
    // Coordinate precision (decimal places)
    CoordPrecision: Integer;

    // Использовать оператор TJ вместо Tj для кернинга
    // Use TJ operator instead of Tj for kerning
    UseTJOperator: Boolean;

    // Объединять последовательные сегменты с одинаковым шрифтом
    // Merge consecutive segments with same font
    MergeSegments: Boolean;
  end;

  // Статистика интеграции PDF
  // PDF integration statistics
  TUzvPdfIntegStats = record
    TotalFonts: Integer;        // Всего шрифтов на странице / Total fonts on page
    TotalTextBlocks: Integer;   // Всего текстовых блоков / Total text blocks
    TotalSegments: Integer;     // Всего сегментов / Total segments
    TotalCharacters: Integer;   // Всего символов / Total characters
    FontSwitches: Integer;      // Переключений шрифта / Font switches
  end;

  // Результат встраивания текста в PDF
  // Text embedding result in PDF
  TUzvPdfEmbedResult = record
    Success: Boolean;           // Успешно / Success
    ErrorMessage: AnsiString;   // Сообщение об ошибке / Error message
    ResourcesDict: AnsiString;  // Словарь /Resources /Font / Resources Font dict
    ContentStream: AnsiString;  // Текстовый контент / Text content stream
    Stats: TUzvPdfIntegStats;   // Статистика / Statistics
  end;

  // Запрос на встраивание текста
  // Text embedding request
  TUzvPdfTextRequest = record
    Text: AnsiString;           // Исходный текст / Source text
    ShxFontName: AnsiString;    // Имя SHX-шрифта / SHX font name
    X: Double;                  // Координата X / X coordinate
    Y: Double;                  // Координата Y / Y coordinate
    Height: Double;             // Высота текста / Text height
    WidthFactor: Double;        // Коэффициент ширины / Width factor
    ObliqueDeg: Double;         // Наклон в градусах / Oblique angle
    RotationDeg: Double;        // Поворот в градусах / Rotation angle
  end;

  // Массив запросов на встраивание
  // Embedding requests array
  TUzvPdfTextRequestArray = array of TUzvPdfTextRequest;

// Создать пустую привязку шрифта
// Create empty font binding
function CreateEmptyFontBinding: TUzvPdfFontBinding;

// Создать привязку шрифта из параметров
// Create font binding from parameters
function CreateFontBinding(
  const AShxFontName: AnsiString;
  const APdfFontName: AnsiString;
  const APdfObjectRef: AnsiString;
  AFontIndex: Integer
): TUzvPdfFontBinding;

// Создать единичную матрицу текста
// Create identity text matrix
function CreateIdentityTextMatrix: TUzvPdfTextMatrix;

// Создать матрицу трансформации текста
// Create text transformation matrix
function CreateTextMatrix(
  AX, AY: Double;
  AScaleX, AScaleY: Double;
  ARotationRad: Double;
  AOblique: Double
): TUzvPdfTextMatrix;

// Создать пустой текстовый сегмент
// Create empty text segment
function CreateEmptyTextSegment: TUzvPdfTextSegment;

// Создать пустой текстовый блок
// Create empty text block
function CreateEmptyTextBlock: TUzvPdfTextBlock;

// Получить параметры генерации по умолчанию
// Get default generation parameters
function GetDefaultTextBlockParams: TUzvTextBlockParams;

// Создать пустую статистику
// Create empty statistics
function CreateEmptyIntegStats: TUzvPdfIntegStats;

// Создать успешный результат встраивания
// Create successful embedding result
function CreateSuccessEmbedResult(
  const AResourcesDict: AnsiString;
  const AContentStream: AnsiString;
  const AStats: TUzvPdfIntegStats
): TUzvPdfEmbedResult;

// Создать результат с ошибкой
// Create error result
function CreateErrorEmbedResult(const AErrorMessage: AnsiString): TUzvPdfEmbedResult;

// Создать запрос на встраивание текста
// Create text embedding request
function CreateTextRequest(
  const AText: AnsiString;
  const AShxFontName: AnsiString;
  AX, AY, AHeight: Double;
  AWidthFactor, AObliqueDeg, ARotationDeg: Double
): TUzvPdfTextRequest;

// Создать запрос на встраивание (упрощённая версия)
// Create text embedding request (simplified version)
function CreateTextRequestSimple(
  const AText: AnsiString;
  const AShxFontName: AnsiString;
  AX, AY, AHeight: Double
): TUzvPdfTextRequest;

implementation

uses
  Math;

// Создать пустую привязку шрифта
function CreateEmptyFontBinding: TUzvPdfFontBinding;
begin
  Result.ShxFontName := '';
  Result.PdfFontName := '';
  Result.PdfObjectRef := '';
  Result.FontIndex := -1;
end;

// Создать привязку шрифта из параметров
function CreateFontBinding(
  const AShxFontName: AnsiString;
  const APdfFontName: AnsiString;
  const APdfObjectRef: AnsiString;
  AFontIndex: Integer
): TUzvPdfFontBinding;
begin
  Result.ShxFontName := AShxFontName;
  Result.PdfFontName := APdfFontName;
  Result.PdfObjectRef := APdfObjectRef;
  Result.FontIndex := AFontIndex;
end;

// Создать единичную матрицу текста
function CreateIdentityTextMatrix: TUzvPdfTextMatrix;
begin
  Result.A := 1.0;
  Result.B := 0.0;
  Result.C := 0.0;
  Result.D := 1.0;
  Result.E := 0.0;
  Result.F := 0.0;
end;

// Создать матрицу трансформации текста
function CreateTextMatrix(
  AX, AY: Double;
  AScaleX, AScaleY: Double;
  ARotationRad: Double;
  AOblique: Double
): TUzvPdfTextMatrix;
var
  CosR, SinR: Double;
  TanObl: Double;
begin
  // Вычисляем тригонометрические значения
  // Calculate trigonometric values
  CosR := Cos(ARotationRad);
  SinR := Sin(ARotationRad);
  TanObl := Tan(AOblique);

  // Формируем матрицу:
  // [a b c d e f] = [scaleX*cos  scaleX*sin  scaleY*(-sin+tan*cos)  scaleY*(cos+tan*sin)  x  y]
  // Build matrix:
  // [a b c d e f] = [scaleX*cos  scaleX*sin  scaleY*(-sin+tan*cos)  scaleY*(cos+tan*sin)  x  y]
  Result.A := AScaleX * CosR;
  Result.B := AScaleX * SinR;
  Result.C := AScaleY * (-SinR + TanObl * CosR);
  Result.D := AScaleY * (CosR + TanObl * SinR);
  Result.E := AX;
  Result.F := AY;
end;

// Создать пустой текстовый сегмент
function CreateEmptyTextSegment: TUzvPdfTextSegment;
begin
  Result.Text := '';
  Result.FontName := '';
  Result.FontSize := 0.0;
  Result.Matrix := CreateIdentityTextMatrix;
end;

// Создать пустой текстовый блок
function CreateEmptyTextBlock: TUzvPdfTextBlock;
begin
  SetLength(Result.Segments, 0);
  Result.Stream := '';
end;

// Получить параметры генерации по умолчанию
function GetDefaultTextBlockParams: TUzvTextBlockParams;
begin
  // 4 знака после запятой - достаточная точность для PDF
  // 4 decimal places - sufficient precision for PDF
  Result.CoordPrecision := 4;

  // По умолчанию используем простой Tj
  // Default: use simple Tj
  Result.UseTJOperator := False;

  // Объединяем сегменты для оптимизации
  // Merge segments for optimization
  Result.MergeSegments := True;
end;

// Создать пустую статистику
function CreateEmptyIntegStats: TUzvPdfIntegStats;
begin
  Result.TotalFonts := 0;
  Result.TotalTextBlocks := 0;
  Result.TotalSegments := 0;
  Result.TotalCharacters := 0;
  Result.FontSwitches := 0;
end;

// Создать успешный результат встраивания
function CreateSuccessEmbedResult(
  const AResourcesDict: AnsiString;
  const AContentStream: AnsiString;
  const AStats: TUzvPdfIntegStats
): TUzvPdfEmbedResult;
begin
  Result.Success := True;
  Result.ErrorMessage := '';
  Result.ResourcesDict := AResourcesDict;
  Result.ContentStream := AContentStream;
  Result.Stats := AStats;
end;

// Создать результат с ошибкой
function CreateErrorEmbedResult(const AErrorMessage: AnsiString): TUzvPdfEmbedResult;
begin
  Result.Success := False;
  Result.ErrorMessage := AErrorMessage;
  Result.ResourcesDict := '';
  Result.ContentStream := '';
  Result.Stats := CreateEmptyIntegStats;
end;

// Создать запрос на встраивание текста
function CreateTextRequest(
  const AText: AnsiString;
  const AShxFontName: AnsiString;
  AX, AY, AHeight: Double;
  AWidthFactor, AObliqueDeg, ARotationDeg: Double
): TUzvPdfTextRequest;
begin
  Result.Text := AText;
  Result.ShxFontName := AShxFontName;
  Result.X := AX;
  Result.Y := AY;
  Result.Height := AHeight;
  Result.WidthFactor := AWidthFactor;
  Result.ObliqueDeg := AObliqueDeg;
  Result.RotationDeg := ARotationDeg;
end;

// Создать запрос на встраивание (упрощённая версия)
function CreateTextRequestSimple(
  const AText: AnsiString;
  const AShxFontName: AnsiString;
  AX, AY, AHeight: Double
): TUzvPdfTextRequest;
begin
  Result := CreateTextRequest(
    AText,
    AShxFontName,
    AX, AY, AHeight,
    1.0,    // WidthFactor по умолчанию
    0.0,    // Без наклона
    0.0     // Без поворота
  );
end;

end.
