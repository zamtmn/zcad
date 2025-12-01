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
  Модуль: uzvshxtopdfcharprocstestpdf
  Назначение: Интеграционный тест PDF генерации

  Тест проверяет полный конвейер:
  1. Этап 1 → SHX (имитация)
  2. Этап 2 → Безье (имитация)
  3. Этап 3 → Трансформации (имитация)
  4. Этап 4 → CharProcs (реальный)
  5. Генерация PDF-стрима
  6. Проверка корректности структуры

  Визуальная проверка в PDF viewer выполняется вручную.

  Module: uzvshxtopdfcharprocstestpdf
  Purpose: Integration test for PDF generation

  This test verifies complete pipeline:
  1. Stage 1 → SHX (simulated)
  2. Stage 2 → Bezier (simulated)
  3. Stage 3 → Transformations (simulated)
  4. Stage 4 → CharProcs (actual)
  5. PDF stream generation
  6. Structure correctness verification

  Visual verification in PDF viewer is performed manually.
}

unit uzvshxtopdfcharprocstestpdf;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Math, Classes,
  uzvshxtopdfapprogeomtypes,
  uzvshxtopdftransformtypes,
  uzvshxtopdfcharprocstypes,
  uzvshxtopdfcharprocsbbox,
  uzvshxtopdfcharprocs,
  uzvshxtopdfcharprocswriter,
  uzvshxtopdfcharprocsfont,
  uzclog;

// Запустить интеграционный тест PDF
// Run PDF integration test
function RunPdfIntegrationTest: Boolean;

// Создать имитацию результата Этапа 3 (буква 'A')
// Create simulation of Stage 3 result (letter 'A')
function CreateSimulatedLetterA: TUzvWorldBezierGlyph;

// Создать имитацию результата Этапа 3 (буква 'B')
// Create simulation of Stage 3 result (letter 'B')
function CreateSimulatedLetterB: TUzvWorldBezierGlyph;

// Создать имитацию шрифта с несколькими глифами
// Create simulated font with multiple glyphs
function CreateSimulatedFont: TUzvWorldBezierFont;

// Сохранить PDF-стримы в файл для отладки
// Save PDF streams to file for debugging
procedure SavePdfStreamsToFile(
  const Font: TUzvPdfType3Font;
  const FileName: string
);

implementation

const
  LOG_PREFIX = 'CharProcsTestPdf: ';

// Создать сегмент Безье из двух точек (прямая линия)
// Create Bezier segment from two points (straight line)
function MakeLineSeg(X1, Y1, X2, Y2: Double): TUzvBezierSegment;
var
  DX, DY: Double;
begin
  Result.P0 := MakePointF(X1, Y1);
  Result.P3 := MakePointF(X2, Y2);

  // Контрольные точки для прямой линии
  // Control points for straight line
  DX := (X2 - X1) / 3.0;
  DY := (Y2 - Y1) / 3.0;
  Result.P1 := MakePointF(X1 + DX, Y1 + DY);
  Result.P2 := MakePointF(X2 - DX, Y2 - DY);
end;

// Создать имитацию буквы 'A' (треугольник + горизонтальная линия)
// Create simulation of letter 'A' (triangle + horizontal line)
function CreateSimulatedLetterA: TUzvWorldBezierGlyph;
var
  OuterPath, InnerPath: TUzvBezierPath;
begin
  Result.Code := 65;  // 'A'

  // Внешний контур - треугольник
  // Outer contour - triangle
  SetLength(OuterPath.Segments, 3);
  OuterPath.Segments[0] := MakeLineSeg(0, 0, 10, 20);      // Левая сторона / Left side
  OuterPath.Segments[1] := MakeLineSeg(10, 20, 20, 0);     // Правая сторона / Right side
  OuterPath.Segments[2] := MakeLineSeg(20, 0, 0, 0);       // Нижняя сторона / Bottom
  OuterPath.IsClosed := True;

  // Горизонтальная перекладина (как отдельный путь)
  // Horizontal crossbar (as separate path)
  SetLength(InnerPath.Segments, 1);
  InnerPath.Segments[0] := MakeLineSeg(5, 8, 15, 8);
  InnerPath.IsClosed := False;

  // Объединяем пути
  // Combine paths
  SetLength(Result.Paths, 2);
  Result.Paths[0] := OuterPath;
  Result.Paths[1] := InnerPath;
end;

// Создать имитацию буквы 'B' (прямоугольник + две дуги)
// Create simulation of letter 'B' (rectangle + two arcs)
function CreateSimulatedLetterB: TUzvWorldBezierGlyph;
var
  VerticalPath, TopArc, BottomArc: TUzvBezierPath;
begin
  Result.Code := 66;  // 'B'

  // Вертикальная линия
  // Vertical line
  SetLength(VerticalPath.Segments, 1);
  VerticalPath.Segments[0] := MakeLineSeg(0, 0, 0, 20);
  VerticalPath.IsClosed := False;

  // Верхняя "дуга" (упрощённо как ломаная)
  // Top "arc" (simplified as polyline)
  SetLength(TopArc.Segments, 3);
  TopArc.Segments[0] := MakeLineSeg(0, 20, 12, 20);
  TopArc.Segments[1] := MakeLineSeg(12, 20, 12, 12);
  TopArc.Segments[2] := MakeLineSeg(12, 12, 0, 12);
  TopArc.IsClosed := False;

  // Нижняя "дуга"
  // Bottom "arc"
  SetLength(BottomArc.Segments, 3);
  BottomArc.Segments[0] := MakeLineSeg(0, 12, 15, 12);
  BottomArc.Segments[1] := MakeLineSeg(15, 12, 15, 0);
  BottomArc.Segments[2] := MakeLineSeg(15, 0, 0, 0);
  BottomArc.IsClosed := False;

  // Объединяем пути
  // Combine paths
  SetLength(Result.Paths, 3);
  Result.Paths[0] := VerticalPath;
  Result.Paths[1] := TopArc;
  Result.Paths[2] := BottomArc;
end;

// Создать имитацию шрифта с несколькими глифами
function CreateSimulatedFont: TUzvWorldBezierFont;
begin
  SetLength(Result.Glyphs, 2);
  Result.Glyphs[0] := CreateSimulatedLetterA;
  Result.Glyphs[1] := CreateSimulatedLetterB;
end;

// Сохранить PDF-стримы в файл для отладки
procedure SavePdfStreamsToFile(
  const Font: TUzvPdfType3Font;
  const FileName: string
);
var
  F: TextFile;
  I: Integer;
begin
  AssignFile(F, FileName);
  try
    Rewrite(F);

    WriteLn(F, '% PDF Type3 Font Debug Output');
    WriteLn(F, '% Generated by uzvshxtopdfcharprocstestpdf');
    WriteLn(F, '');

    WriteLn(F, '% ====== Font Object ======');
    WriteLn(F, Font.FontObjectStream);
    WriteLn(F, '');

    WriteLn(F, '% ====== CharProcs ======');
    for I := 0 to High(Font.CharProcs) do
    begin
      WriteLn(F, '');
      WriteLn(F, '% --- CharProc: /' + string(Font.CharProcs[I].CharName) +
              ' (code=' + IntToStr(Font.CharProcs[I].CharCode) + ') ---');
      WriteLn(F, '% Width: ' + FloatToStr(Font.CharProcs[I].Width));
      WriteLn(F, '% BBox: [' +
              FloatToStr(Font.CharProcs[I].BBox.MinX) + ' ' +
              FloatToStr(Font.CharProcs[I].BBox.MinY) + ' ' +
              FloatToStr(Font.CharProcs[I].BBox.MaxX) + ' ' +
              FloatToStr(Font.CharProcs[I].BBox.MaxY) + ']');
      WriteLn(F, 'stream');
      Write(F, string(Font.CharProcs[I].Stream));
      WriteLn(F, 'endstream');
    end;

    CloseFile(F);

    programlog.LogOutFormatStr(
      LOG_PREFIX + 'PDF-стримы сохранены в файл: %s',
      [FileName],
      LM_Info
    );
  except
    on E: Exception do
    begin
      programlog.LogOutFormatStr(
        LOG_PREFIX + 'Ошибка сохранения файла: %s',
        [E.Message],
        LM_Info
      );
    end;
  end;
end;

// Запустить интеграционный тест PDF
function RunPdfIntegrationTest: Boolean;
var
  SimFont: TUzvWorldBezierFont;
  Type3Font: TUzvPdfType3Font;
  I: Integer;
  ExpectedOperators: array[0..4] of AnsiString;
  AllOperatorsPresent: Boolean;
begin
  Result := True;

  programlog.LogOutStr(
    LOG_PREFIX + 'начало интеграционного теста PDF',
    LM_Info
  );

  // === Этап 1-3: Имитация ===
  // === Stage 1-3: Simulation ===

  programlog.LogOutStr(
    LOG_PREFIX + 'Этапы 1-3: создание имитации World Bezier Font',
    LM_Info
  );

  SimFont := CreateSimulatedFont;

  programlog.LogOutFormatStr(
    LOG_PREFIX + 'создано глифов: %d',
    [Length(SimFont.Glyphs)],
    LM_Info
  );

  // === Этап 4: Генерация CharProcs ===
  // === Stage 4: CharProcs generation ===

  programlog.LogOutStr(
    LOG_PREFIX + 'Этап 4: генерация CharProcs',
    LM_Info
  );

  Type3Font := BuildType3FontCharProcsAuto(SimFont);

  programlog.LogOutFormatStr(
    LOG_PREFIX + 'сгенерировано CharProcs: %d',
    [Length(Type3Font.CharProcs)],
    LM_Info
  );

  // === Проверка PDF-стримов ===
  // === PDF stream verification ===

  programlog.LogOutStr(
    LOG_PREFIX + 'проверка структуры PDF-стримов',
    LM_Info
  );

  // Список ожидаемых операторов
  // List of expected operators
  ExpectedOperators[0] := ' m';   // moveTo
  ExpectedOperators[1] := ' l';   // lineTo (or ' c' for curves)
  ExpectedOperators[2] := 'q';    // gsave
  ExpectedOperators[3] := 'Q';    // grestore
  ExpectedOperators[4] := 'S';    // stroke

  AllOperatorsPresent := True;
  for I := 0 to High(Type3Font.CharProcs) do
  begin
    // Проверяем наличие основных операторов
    // Check presence of main operators
    if Pos(ExpectedOperators[0], Type3Font.CharProcs[I].Stream) = 0 then
    begin
      programlog.LogOutFormatStr(
        LOG_PREFIX + 'ПРЕДУПРЕЖДЕНИЕ: глиф %d не содержит оператор moveTo',
        [Type3Font.CharProcs[I].CharCode],
        LM_Info
      );
    end;

    if (Pos(ExpectedOperators[2], Type3Font.CharProcs[I].Stream) = 0) or
       (Pos(ExpectedOperators[3], Type3Font.CharProcs[I].Stream) = 0) then
    begin
      programlog.LogOutFormatStr(
        LOG_PREFIX + 'ПРЕДУПРЕЖДЕНИЕ: глиф %d не содержит q/Q',
        [Type3Font.CharProcs[I].CharCode],
        LM_Info
      );
    end;

    // Логирование размера стрима
    // Log stream size
    programlog.LogOutFormatStr(
      LOG_PREFIX + 'глиф %d: размер стрима = %d байт',
      [Type3Font.CharProcs[I].CharCode, Length(Type3Font.CharProcs[I].Stream)],
      LM_Info
    );
  end;

  // === Проверка FontBBox ===
  // === FontBBox verification ===

  if IsPdfBBoxEmpty(Type3Font.FontBBox) then
  begin
    programlog.LogOutStr(
      LOG_PREFIX + 'ОШИБКА: FontBBox пустой',
      LM_Info
    );
    Result := False;
  end
  else
  begin
    programlog.LogOutFormatStr(
      LOG_PREFIX + 'FontBBox: [%.2f %.2f %.2f %.2f]',
      [Type3Font.FontBBox.MinX, Type3Font.FontBBox.MinY,
       Type3Font.FontBBox.MaxX, Type3Font.FontBBox.MaxY],
      LM_Info
    );
  end;

  // === Проверка FirstChar/LastChar ===
  // === FirstChar/LastChar verification ===

  if Type3Font.FirstChar <> 65 then  // 'A'
  begin
    programlog.LogOutFormatStr(
      LOG_PREFIX + 'ОШИБКА: FirstChar = %d, ожидалось 65',
      [Type3Font.FirstChar],
      LM_Info
    );
    Result := False;
  end
  else
  begin
    programlog.LogOutStr(
      LOG_PREFIX + 'OK: FirstChar = 65 (A)',
      LM_Info
    );
  end;

  if Type3Font.LastChar <> 66 then  // 'B'
  begin
    programlog.LogOutFormatStr(
      LOG_PREFIX + 'ОШИБКА: LastChar = %d, ожидалось 66',
      [Type3Font.LastChar],
      LM_Info
    );
    Result := False;
  end
  else
  begin
    programlog.LogOutStr(
      LOG_PREFIX + 'OK: LastChar = 66 (B)',
      LM_Info
    );
  end;

  // === Сохранение для визуальной проверки ===
  // === Save for visual verification ===

  // Опционально: сохранить стримы в файл
  // Optional: save streams to file
  // SavePdfStreamsToFile(Type3Font, 'charprocs_debug.txt');

  if Result then
    programlog.LogOutStr(
      LOG_PREFIX + 'интеграционный тест PDF пройден успешно',
      LM_Info
    )
  else
    programlog.LogOutStr(
      LOG_PREFIX + 'ИНТЕГРАЦИОННЫЙ ТЕСТ PDF ПРОВАЛЕН',
      LM_Info
    );
end;

end.
