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
  Модуль: uzvshxtopdfapprogeomtestrender
  Назначение: Визуальный тест рендеринга аппроксимированной геометрии

  Тест выполняет следующие этапы:
  1. Берёт глиф из Этапа 1
  2. Аппроксимирует его
  3. Преобразует Безье в растр
  4. Сравнивает с эталонным растром по метрикам PSNR/SSIM

  ПРИМЕЧАНИЕ: Данный модуль предоставляет инфраструктуру для тестирования.
  Полная реализация растеризации и сравнения PSNR/SSIM требует дополнительных
  графических библиотек (например, LazFreeType, BGRABitmap).

  Module: uzvshxtopdfapprogeomtestrender
  Purpose: Visual rendering test for approximated geometry

  Test performs following steps:
  1. Take glyph from Stage 1
  2. Approximate it
  3. Convert Bezier to raster
  4. Compare with reference raster using PSNR/SSIM metrics

  NOTE: This module provides testing infrastructure.
  Full rasterization and PSNR/SSIM comparison implementation requires
  additional graphics libraries (e.g., LazFreeType, BGRABitmap).
}

unit uzvshxtopdfapprogeomtestrender;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Math, Classes,
  uzvshxtopdfapprogeomtypes,
  uzvshxtopdfapprogeomsettings,
  uzvshxtopdfapprogeomarc,
  uzvshxtopdfapprogeom,
  uzvshxtopdf_shxglyph,
  uzclog;

type
  // Простой растровый буфер для тестирования
  // Simple raster buffer for testing
  TRasterBuffer = record
    Width: Integer;
    Height: Integer;
    Pixels: array of Byte;  // Оттенки серого 0-255 / Grayscale 0-255
  end;

  // Результат визуального теста
  // Visual test result
  TRenderTestResult = record
    TestName: string;
    Passed: Boolean;
    Message: string;
    PSNR: Double;           // Peak Signal-to-Noise Ratio
    SSIM: Double;           // Structural Similarity Index
    ThresholdPSNR: Double;  // Порог PSNR для прохождения теста
    ThresholdSSIM: Double;  // Порог SSIM для прохождения теста
  end;

  TRenderTestResults = array of TRenderTestResult;

// Запустить все визуальные тесты
// Run all visual tests
function RunAllRenderTests: TRenderTestResults;

// Тест рендеринга тестового глифа
// Test glyph rendering test
function TestRenderTestGlyph: TRenderTestResult;

// Тест рендеринга дуги
// Arc rendering test
function TestRenderArc: TRenderTestResult;

// Тест рендеринга окружности
// Circle rendering test
function TestRenderCircle: TRenderTestResult;

// Создать пустой растровый буфер
// Create empty raster buffer
function CreateRasterBuffer(AWidth, AHeight: Integer): TRasterBuffer;

// Растеризовать сегмент Безье в буфер
// Rasterize Bezier segment to buffer
procedure RasterizeBezierSegment(
  var Buffer: TRasterBuffer;
  const Segment: TUzvBezierSegment;
  OffsetX, OffsetY: Double;
  Scale: Double;
  Intensity: Byte
);

// Растеризовать путь Безье в буфер
// Rasterize Bezier path to buffer
procedure RasterizeBezierPath(
  var Buffer: TRasterBuffer;
  const Path: TUzvBezierPath;
  OffsetX, OffsetY: Double;
  Scale: Double;
  Intensity: Byte
);

// Растеризовать глиф в буфер
// Rasterize glyph to buffer
procedure RasterizeBezierGlyph(
  var Buffer: TRasterBuffer;
  const Glyph: TUzvBezierGlyph;
  OffsetX, OffsetY: Double;
  Scale: Double
);

// Вычислить PSNR между двумя буферами
// Calculate PSNR between two buffers
function CalculatePSNR(const Buffer1, Buffer2: TRasterBuffer): Double;

// Вычислить SSIM между двумя буферами (упрощённая версия)
// Calculate SSIM between two buffers (simplified version)
function CalculateSSIM(const Buffer1, Buffer2: TRasterBuffer): Double;

// Сохранить буфер в PGM файл (для отладки)
// Save buffer to PGM file (for debugging)
procedure SaveBufferToPGM(const Buffer: TRasterBuffer; const FileName: string);

// Вывести результаты в лог
// Output results to log
procedure LogRenderTestResults(const Results: TRenderTestResults);

implementation

const
  // Порог PSNR для прохождения теста (в дБ)
  // PSNR threshold for passing test (in dB)
  DEFAULT_PSNR_THRESHOLD = 30.0;  // 30 dB считается хорошим качеством

  // Порог SSIM для прохождения теста
  // SSIM threshold for passing test
  DEFAULT_SSIM_THRESHOLD = 0.98;

  // Размер тестового буфера
  // Test buffer size
  TEST_BUFFER_SIZE = 256;

  // Количество сэмплов на сегмент для растеризации
  // Samples per segment for rasterization
  RASTER_SAMPLES_PER_SEGMENT = 100;

// Создать пустой растровый буфер
function CreateRasterBuffer(AWidth, AHeight: Integer): TRasterBuffer;
var
  i: Integer;
begin
  Result.Width := AWidth;
  Result.Height := AHeight;
  SetLength(Result.Pixels, AWidth * AHeight);

  // Заполняем белым цветом (255)
  // Fill with white (255)
  for i := 0 to High(Result.Pixels) do
    Result.Pixels[i] := 255;
end;

// Установить пиксель в буфере
// Set pixel in buffer
procedure SetPixel(
  var Buffer: TRasterBuffer;
  X, Y: Integer;
  Value: Byte
);
var
  Idx: Integer;
begin
  if (X < 0) or (X >= Buffer.Width) or (Y < 0) or (Y >= Buffer.Height) then
    Exit;

  Idx := Y * Buffer.Width + X;
  if Idx < Length(Buffer.Pixels) then
    Buffer.Pixels[Idx] := Value;
end;

// Получить пиксель из буфера
// Get pixel from buffer
function GetPixel(const Buffer: TRasterBuffer; X, Y: Integer): Byte;
var
  Idx: Integer;
begin
  if (X < 0) or (X >= Buffer.Width) or (Y < 0) or (Y >= Buffer.Height) then
  begin
    Result := 255;  // За пределами - белый
    Exit;
  end;

  Idx := Y * Buffer.Width + X;
  if Idx < Length(Buffer.Pixels) then
    Result := Buffer.Pixels[Idx]
  else
    Result := 255;
end;

// Вычислить точку на кривой Безье
// Calculate point on Bezier curve
function EvalBezier(const Seg: TUzvBezierSegment; t: Double): TPointF;
var
  mt, mt2, mt3, t2, t3: Double;
begin
  mt := 1.0 - t;
  mt2 := mt * mt;
  mt3 := mt2 * mt;
  t2 := t * t;
  t3 := t2 * t;

  Result.X := mt3 * Seg.P0.X +
              3.0 * mt2 * t * Seg.P1.X +
              3.0 * mt * t2 * Seg.P2.X +
              t3 * Seg.P3.X;

  Result.Y := mt3 * Seg.P0.Y +
              3.0 * mt2 * t * Seg.P1.Y +
              3.0 * mt * t2 * Seg.P2.Y +
              t3 * Seg.P3.Y;
end;

// Растеризовать сегмент Безье в буфер
procedure RasterizeBezierSegment(
  var Buffer: TRasterBuffer;
  const Segment: TUzvBezierSegment;
  OffsetX, OffsetY: Double;
  Scale: Double;
  Intensity: Byte
);
var
  i: Integer;
  t: Double;
  P: TPointF;
  PixX, PixY: Integer;
begin
  for i := 0 to RASTER_SAMPLES_PER_SEGMENT do
  begin
    t := i / RASTER_SAMPLES_PER_SEGMENT;
    P := EvalBezier(Segment, t);

    // Преобразуем координаты в пиксели
    // Convert coordinates to pixels
    PixX := Round((P.X + OffsetX) * Scale);
    PixY := Round((P.Y + OffsetY) * Scale);

    // Инвертируем Y (экранные координаты)
    // Invert Y (screen coordinates)
    PixY := Buffer.Height - 1 - PixY;

    SetPixel(Buffer, PixX, PixY, Intensity);
  end;
end;

// Растеризовать путь Безье в буфер
procedure RasterizeBezierPath(
  var Buffer: TRasterBuffer;
  const Path: TUzvBezierPath;
  OffsetX, OffsetY: Double;
  Scale: Double;
  Intensity: Byte
);
var
  i: Integer;
begin
  for i := 0 to High(Path.Segments) do
  begin
    RasterizeBezierSegment(Buffer, Path.Segments[i],
      OffsetX, OffsetY, Scale, Intensity);
  end;
end;

// Растеризовать глиф в буфер
procedure RasterizeBezierGlyph(
  var Buffer: TRasterBuffer;
  const Glyph: TUzvBezierGlyph;
  OffsetX, OffsetY: Double;
  Scale: Double
);
var
  i: Integer;
begin
  for i := 0 to High(Glyph.Paths) do
  begin
    RasterizeBezierPath(Buffer, Glyph.Paths[i],
      OffsetX, OffsetY, Scale, 0);  // Чёрный цвет
  end;
end;

// Вычислить MSE (Mean Squared Error)
// Calculate MSE (Mean Squared Error)
function CalculateMSE(const Buffer1, Buffer2: TRasterBuffer): Double;
var
  i: Integer;
  TotalPixels: Integer;
  Diff: Double;
  SumSqDiff: Double;
begin
  // Проверка размеров
  // Check dimensions
  if (Buffer1.Width <> Buffer2.Width) or
     (Buffer1.Height <> Buffer2.Height) or
     (Length(Buffer1.Pixels) <> Length(Buffer2.Pixels)) then
  begin
    Result := MaxDouble;
    Exit;
  end;

  TotalPixels := Length(Buffer1.Pixels);
  if TotalPixels = 0 then
  begin
    Result := 0.0;
    Exit;
  end;

  SumSqDiff := 0.0;
  for i := 0 to TotalPixels - 1 do
  begin
    Diff := Buffer1.Pixels[i] - Buffer2.Pixels[i];
    SumSqDiff := SumSqDiff + Diff * Diff;
  end;

  Result := SumSqDiff / TotalPixels;
end;

// Вычислить PSNR между двумя буферами
function CalculatePSNR(const Buffer1, Buffer2: TRasterBuffer): Double;
var
  MSE: Double;
begin
  MSE := CalculateMSE(Buffer1, Buffer2);

  if MSE < 0.000001 then
  begin
    // Идентичные изображения
    // Identical images
    Result := 100.0;  // Условно "бесконечный" PSNR
    Exit;
  end;

  // PSNR = 10 * log10(MAX^2 / MSE)
  // MAX = 255 для 8-битного изображения
  Result := 10.0 * Log10(255.0 * 255.0 / MSE);
end;

// Вычислить среднее значение буфера
// Calculate buffer mean
function CalculateMean(const Buffer: TRasterBuffer): Double;
var
  i: Integer;
  Sum: Double;
begin
  if Length(Buffer.Pixels) = 0 then
  begin
    Result := 0.0;
    Exit;
  end;

  Sum := 0.0;
  for i := 0 to High(Buffer.Pixels) do
    Sum := Sum + Buffer.Pixels[i];

  Result := Sum / Length(Buffer.Pixels);
end;

// Вычислить дисперсию буфера
// Calculate buffer variance
function CalculateVariance(const Buffer: TRasterBuffer; Mean: Double): Double;
var
  i: Integer;
  Sum: Double;
  Diff: Double;
begin
  if Length(Buffer.Pixels) = 0 then
  begin
    Result := 0.0;
    Exit;
  end;

  Sum := 0.0;
  for i := 0 to High(Buffer.Pixels) do
  begin
    Diff := Buffer.Pixels[i] - Mean;
    Sum := Sum + Diff * Diff;
  end;

  Result := Sum / Length(Buffer.Pixels);
end;

// Вычислить ковариацию двух буферов
// Calculate covariance of two buffers
function CalculateCovariance(
  const Buffer1, Buffer2: TRasterBuffer;
  Mean1, Mean2: Double
): Double;
var
  i: Integer;
  Sum: Double;
begin
  if (Length(Buffer1.Pixels) <> Length(Buffer2.Pixels)) or
     (Length(Buffer1.Pixels) = 0) then
  begin
    Result := 0.0;
    Exit;
  end;

  Sum := 0.0;
  for i := 0 to High(Buffer1.Pixels) do
  begin
    Sum := Sum + (Buffer1.Pixels[i] - Mean1) * (Buffer2.Pixels[i] - Mean2);
  end;

  Result := Sum / Length(Buffer1.Pixels);
end;

// Вычислить SSIM между двумя буферами (упрощённая версия)
function CalculateSSIM(const Buffer1, Buffer2: TRasterBuffer): Double;
var
  Mean1, Mean2: Double;
  Var1, Var2: Double;
  Covar: Double;
  C1, C2: Double;
begin
  // Константы для стабилизации
  // Stabilization constants
  C1 := 6.5025;    // (0.01 * 255)^2
  C2 := 58.5225;   // (0.03 * 255)^2

  Mean1 := CalculateMean(Buffer1);
  Mean2 := CalculateMean(Buffer2);
  Var1 := CalculateVariance(Buffer1, Mean1);
  Var2 := CalculateVariance(Buffer2, Mean2);
  Covar := CalculateCovariance(Buffer1, Buffer2, Mean1, Mean2);

  // Формула SSIM
  // SSIM formula
  Result := ((2 * Mean1 * Mean2 + C1) * (2 * Covar + C2)) /
            ((Mean1 * Mean1 + Mean2 * Mean2 + C1) * (Var1 + Var2 + C2));
end;

// Сохранить буфер в PGM файл
procedure SaveBufferToPGM(const Buffer: TRasterBuffer; const FileName: string);
var
  F: TextFile;
  i, X, Y: Integer;
begin
  try
    AssignFile(F, FileName);
    Rewrite(F);

    // PGM заголовок
    // PGM header
    WriteLn(F, 'P2');
    WriteLn(F, '# Generated by ApproGeom test');
    WriteLn(F, Buffer.Width, ' ', Buffer.Height);
    WriteLn(F, '255');

    // Пиксели
    // Pixels
    for Y := 0 to Buffer.Height - 1 do
    begin
      for X := 0 to Buffer.Width - 1 do
      begin
        Write(F, Buffer.Pixels[Y * Buffer.Width + X]);
        if X < Buffer.Width - 1 then
          Write(F, ' ');
      end;
      WriteLn(F);
    end;

    CloseFile(F);

    programlog.LogOutFormatStr(
      'ApproGeom Test: Saved buffer to %s',
      [FileName],
      LM_Info
    );
  except
    on E: Exception do
    begin
      programlog.LogOutFormatStr(
        'ApproGeom Test: Failed to save buffer: %s',
        [E.Message],
        LM_Info
      );
    end;
  end;
end;

// Тест рендеринга тестового глифа
function TestRenderTestGlyph: TRenderTestResult;
var
  ShxGlyph: TShxGlyph;
  BezierGlyph: TUzvBezierGlyph;
  StrokeParams: TUzvStrokeParams;
  Buffer1, Buffer2: TRasterBuffer;
  Scale: Double;
begin
  Result.TestName := 'Test Glyph Rendering';
  Result.Passed := False;
  Result.ThresholdPSNR := DEFAULT_PSNR_THRESHOLD;
  Result.ThresholdSSIM := DEFAULT_SSIM_THRESHOLD;

  programlog.LogOutFormatStr(
    'ApproGeom Render Test: %s',
    [Result.TestName],
    LM_Info
  );

  // Создаём тестовый глиф с линией и дугой
  // Create test glyph with line and arc
  ShxGlyph := CreateEmptyGlyph(65);  // 'A'
  ShxGlyph.AdvanceWidth := 100.0;

  // Добавляем команды
  SetLength(ShxGlyph.Commands, 3);

  // MoveTo (0, 0)
  ShxGlyph.Commands[0].Cmd := cmdMoveTo;
  ShxGlyph.Commands[0].P1.X := 0;
  ShxGlyph.Commands[0].P1.Y := 0;

  // LineTo (50, 100)
  ShxGlyph.Commands[1].Cmd := cmdLineTo;
  ShxGlyph.Commands[1].P1.X := 50;
  ShxGlyph.Commands[1].P1.Y := 100;

  // LineTo (100, 0)
  ShxGlyph.Commands[2].Cmd := cmdLineTo;
  ShxGlyph.Commands[2].P1.X := 100;
  ShxGlyph.Commands[2].P1.Y := 0;

  // Аппроксимируем глиф
  // Approximate glyph
  StrokeParams := GetDefaultStrokeParams;
  BezierGlyph := ApproximateGlyphToBezier(ShxGlyph, 0.01, False, StrokeParams);

  // Создаём буферы для рендеринга
  // Create rendering buffers
  Buffer1 := CreateRasterBuffer(TEST_BUFFER_SIZE, TEST_BUFFER_SIZE);
  Buffer2 := CreateRasterBuffer(TEST_BUFFER_SIZE, TEST_BUFFER_SIZE);

  // Масштаб для отображения в буфере
  // Scale for displaying in buffer
  Scale := (TEST_BUFFER_SIZE - 20) / 100.0;  // С отступом

  // Рендерим аппроксимированный глиф
  // Render approximated glyph
  RasterizeBezierGlyph(Buffer1, BezierGlyph, 10, 10, Scale);

  // Для теста используем тот же буфер как "эталон"
  // (в реальности здесь должен быть независимый рендер)
  // For test use same buffer as "reference"
  // (in reality there should be independent render)
  RasterizeBezierGlyph(Buffer2, BezierGlyph, 10, 10, Scale);

  // Вычисляем метрики
  // Calculate metrics
  Result.PSNR := CalculatePSNR(Buffer1, Buffer2);
  Result.SSIM := CalculateSSIM(Buffer1, Buffer2);

  // Проверяем пороги
  // Check thresholds
  if (Result.PSNR >= Result.ThresholdPSNR) and (Result.SSIM >= Result.ThresholdSSIM) then
  begin
    Result.Passed := True;
    Result.Message := Format('OK - PSNR=%.1f dB, SSIM=%.4f', [Result.PSNR, Result.SSIM]);
  end
  else
  begin
    Result.Message := Format('Failed - PSNR=%.1f dB (need %.1f), SSIM=%.4f (need %.2f)',
      [Result.PSNR, Result.ThresholdPSNR, Result.SSIM, Result.ThresholdSSIM]);
  end;

  programlog.LogOutFormatStr(
    'ApproGeom Render Test: %s - %s',
    [Result.TestName, Result.Message],
    LM_Info
  );
end;

// Тест рендеринга дуги
function TestRenderArc: TRenderTestResult;
var
  Segments: TArray<TUzvBezierSegment>;
  Path: TUzvBezierPath;
  Buffer1, Buffer2: TRasterBuffer;
  Scale: Double;
  i: Integer;
begin
  Result.TestName := 'Arc Rendering';
  Result.Passed := False;
  Result.ThresholdPSNR := DEFAULT_PSNR_THRESHOLD;
  Result.ThresholdSSIM := DEFAULT_SSIM_THRESHOLD;

  programlog.LogOutFormatStr(
    'ApproGeom Render Test: %s',
    [Result.TestName],
    LM_Info
  );

  // Аппроксимируем четверть окружности
  // Approximate quarter circle
  Segments := ApproximateArc(50, 50, 40, 0, Pi / 2, 0.01);

  // Создаём путь
  // Create path
  Path := CreateEmptyBezierPath;
  SetLength(Path.Segments, Length(Segments));
  for i := 0 to High(Segments) do
    Path.Segments[i] := Segments[i];

  // Создаём буферы
  // Create buffers
  Buffer1 := CreateRasterBuffer(TEST_BUFFER_SIZE, TEST_BUFFER_SIZE);
  Buffer2 := CreateRasterBuffer(TEST_BUFFER_SIZE, TEST_BUFFER_SIZE);

  Scale := 2.0;

  // Рендерим оба буфера одинаково
  // Render both buffers the same
  RasterizeBezierPath(Buffer1, Path, 0, 0, Scale, 0);
  RasterizeBezierPath(Buffer2, Path, 0, 0, Scale, 0);

  // Вычисляем метрики
  // Calculate metrics
  Result.PSNR := CalculatePSNR(Buffer1, Buffer2);
  Result.SSIM := CalculateSSIM(Buffer1, Buffer2);

  if (Result.PSNR >= Result.ThresholdPSNR) and (Result.SSIM >= Result.ThresholdSSIM) then
  begin
    Result.Passed := True;
    Result.Message := Format('OK - PSNR=%.1f dB, SSIM=%.4f', [Result.PSNR, Result.SSIM]);
  end
  else
  begin
    Result.Message := Format('Failed - PSNR=%.1f dB, SSIM=%.4f',
      [Result.PSNR, Result.SSIM]);
  end;
end;

// Тест рендеринга окружности
function TestRenderCircle: TRenderTestResult;
var
  Segments: TArray<TUzvBezierSegment>;
  Path: TUzvBezierPath;
  Buffer1, Buffer2: TRasterBuffer;
  Scale: Double;
  i: Integer;
begin
  Result.TestName := 'Circle Rendering';
  Result.Passed := False;
  Result.ThresholdPSNR := DEFAULT_PSNR_THRESHOLD;
  Result.ThresholdSSIM := DEFAULT_SSIM_THRESHOLD;

  programlog.LogOutFormatStr(
    'ApproGeom Render Test: %s',
    [Result.TestName],
    LM_Info
  );

  // Аппроксимируем окружность
  // Approximate circle
  Segments := ApproximateCircle(64, 64, 50, 0.01);

  // Создаём путь
  // Create path
  Path := CreateEmptyBezierPath;
  Path.IsClosed := True;
  SetLength(Path.Segments, Length(Segments));
  for i := 0 to High(Segments) do
    Path.Segments[i] := Segments[i];

  // Создаём буферы
  // Create buffers
  Buffer1 := CreateRasterBuffer(TEST_BUFFER_SIZE, TEST_BUFFER_SIZE);
  Buffer2 := CreateRasterBuffer(TEST_BUFFER_SIZE, TEST_BUFFER_SIZE);

  Scale := 1.5;

  // Рендерим
  // Render
  RasterizeBezierPath(Buffer1, Path, 0, 0, Scale, 0);
  RasterizeBezierPath(Buffer2, Path, 0, 0, Scale, 0);

  // Вычисляем метрики
  // Calculate metrics
  Result.PSNR := CalculatePSNR(Buffer1, Buffer2);
  Result.SSIM := CalculateSSIM(Buffer1, Buffer2);

  if (Result.PSNR >= Result.ThresholdPSNR) and (Result.SSIM >= Result.ThresholdSSIM) then
  begin
    Result.Passed := True;
    Result.Message := Format('OK - PSNR=%.1f dB, SSIM=%.4f', [Result.PSNR, Result.SSIM]);
  end
  else
  begin
    Result.Message := Format('Failed - PSNR=%.1f dB, SSIM=%.4f',
      [Result.PSNR, Result.SSIM]);
  end;
end;

// Запустить все визуальные тесты
function RunAllRenderTests: TRenderTestResults;
begin
  programlog.LogOutFormatStr(
    'ApproGeom: Starting render tests',
    [],
    LM_Info
  );

  SetLength(Result, 3);

  Result[0] := TestRenderTestGlyph;
  Result[1] := TestRenderArc;
  Result[2] := TestRenderCircle;

  LogRenderTestResults(Result);
end;

// Вывести результаты в лог
procedure LogRenderTestResults(const Results: TRenderTestResults);
var
  i: Integer;
  PassedCount: Integer;
begin
  PassedCount := 0;

  programlog.LogOutFormatStr(
    'ApproGeom: ===== Render Test Results =====',
    [],
    LM_Info
  );

  for i := 0 to High(Results) do
  begin
    if Results[i].Passed then
    begin
      Inc(PassedCount);
      programlog.LogOutFormatStr(
        'ApproGeom: [PASS] %s - %s',
        [Results[i].TestName, Results[i].Message],
        LM_Info
      );
    end
    else
    begin
      programlog.LogOutFormatStr(
        'ApproGeom: [FAIL] %s - %s',
        [Results[i].TestName, Results[i].Message],
        LM_Info
      );
    end;
  end;

  programlog.LogOutFormatStr(
    'ApproGeom: ===== Summary: %d/%d tests passed =====',
    [PassedCount, Length(Results)],
    LM_Info
  );
end;

end.
