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
  Модуль: uzvshxtopdfcharprocstestfont
  Назначение: Unit-тест: проверка структуры PDF Font объекта

  Тест проверяет наличие всех обязательных ключей в структуре Type3 Font:
  - /Type
  - /Subtype
  - /CharProcs
  - /Encoding
  - /Widths
  - /FirstChar
  - /LastChar
  - /FontBBox

  Module: uzvshxtopdfcharprocstestfont
  Purpose: Unit test: PDF Font object structure verification

  This test verifies presence of all required keys in Type3 Font structure:
  - /Type
  - /Subtype
  - /CharProcs
  - /Encoding
  - /Widths
  - /FirstChar
  - /LastChar
  - /FontBBox
}

unit uzvshxtopdfcharprocstestfont;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Math,
  uzvshxtopdfapprogeomtypes,
  uzvshxtopdftransformtypes,
  uzvshxtopdfcharprocstypes,
  uzvshxtopdfcharprocs,
  uzvshxtopdfcharprocstestcount,
  uzclog;

// Запустить тест структуры Font объекта
// Run Font object structure test
function RunFontStructureTest: Boolean;

// Проверить наличие ключа в PDF-строке
// Check if key is present in PDF string
function ContainsKey(const PdfStr: AnsiString; const Key: AnsiString): Boolean;

implementation

const
  LOG_PREFIX = 'CharProcsTestFont: ';

// Проверить наличие ключа в PDF-строке
function ContainsKey(const PdfStr: AnsiString; const Key: AnsiString): Boolean;
begin
  Result := Pos(Key, PdfStr) > 0;
end;

// Запустить тест структуры Font объекта
function RunFontStructureTest: Boolean;
var
  TestFont: TUzvWorldBezierFont;
  Type3Font: TUzvPdfType3Font;
  FontStream: AnsiString;
  RequiredKeys: array[0..9] of AnsiString;
  I: Integer;
  AllKeysPresent: Boolean;
begin
  Result := True;

  programlog.LogOutStr(
    LOG_PREFIX + 'начало теста структуры Font объекта',
    LM_Info
  );

  // Список обязательных ключей
  // List of required keys
  RequiredKeys[0] := '/Type';
  RequiredKeys[1] := '/Font';
  RequiredKeys[2] := '/Subtype';
  RequiredKeys[3] := '/Type3';
  RequiredKeys[4] := '/CharProcs';
  RequiredKeys[5] := '/Encoding';
  RequiredKeys[6] := '/Widths';
  RequiredKeys[7] := '/FirstChar';
  RequiredKeys[8] := '/LastChar';
  RequiredKeys[9] := '/FontBBox';

  // Создаём тестовый шрифт с 3 глифами
  // Create test font with 3 glyphs
  TestFont := CreateTestFont(3);

  // Генерируем Type3 Font
  // Generate Type3 Font
  Type3Font := BuildType3FontCharProcsAuto(TestFont);

  // Получаем FontObjectStream
  // Get FontObjectStream
  FontStream := Type3Font.FontObjectStream;

  // Проверяем наличие всех ключей
  // Check presence of all keys
  AllKeysPresent := True;
  for I := 0 to High(RequiredKeys) do
  begin
    if not ContainsKey(FontStream, RequiredKeys[I]) then
    begin
      programlog.LogOutFormatStr(
        LOG_PREFIX + 'ОШИБКА: отсутствует ключ %s',
        [RequiredKeys[I]],
        LM_Info
      );
      AllKeysPresent := False;
      Result := False;
    end
    else
    begin
      programlog.LogOutFormatStr(
        LOG_PREFIX + 'OK: найден ключ %s',
        [RequiredKeys[I]],
        LM_Info
      );
    end;
  end;

  // Дополнительные проверки структуры
  // Additional structure checks

  // Проверка FirstChar <= LastChar
  // Check FirstChar <= LastChar
  if Type3Font.FirstChar > Type3Font.LastChar then
  begin
    programlog.LogOutFormatStr(
      LOG_PREFIX + 'ОШИБКА: FirstChar (%d) > LastChar (%d)',
      [Type3Font.FirstChar, Type3Font.LastChar],
      LM_Info
    );
    Result := False;
  end
  else
  begin
    programlog.LogOutFormatStr(
      LOG_PREFIX + 'OK: FirstChar (%d) <= LastChar (%d)',
      [Type3Font.FirstChar, Type3Font.LastChar],
      LM_Info
    );
  end;

  // Проверка количества Widths
  // Check Widths count
  if Length(Type3Font.Widths) <> (Type3Font.LastChar - Type3Font.FirstChar + 1) then
  begin
    programlog.LogOutFormatStr(
      LOG_PREFIX + 'ОШИБКА: неверное количество Widths: %d, ожидалось %d',
      [Length(Type3Font.Widths), Type3Font.LastChar - Type3Font.FirstChar + 1],
      LM_Info
    );
    Result := False;
  end
  else
  begin
    programlog.LogOutFormatStr(
      LOG_PREFIX + 'OK: количество Widths: %d',
      [Length(Type3Font.Widths)],
      LM_Info
    );
  end;

  // Проверка FontBBox
  // Check FontBBox
  if IsPdfBBoxEmpty(Type3Font.FontBBox) then
  begin
    programlog.LogOutStr(
      LOG_PREFIX + 'ПРЕДУПРЕЖДЕНИЕ: FontBBox пустой',
      LM_Info
    );
  end
  else
  begin
    programlog.LogOutFormatStr(
      LOG_PREFIX + 'OK: FontBBox = [%.2f %.2f %.2f %.2f]',
      [Type3Font.FontBBox.MinX, Type3Font.FontBBox.MinY,
       Type3Font.FontBBox.MaxX, Type3Font.FontBBox.MaxY],
      LM_Info
    );
  end;

  // Проверка валидности структуры
  // Validate structure
  if not ValidateType3Font(Type3Font) then
  begin
    programlog.LogOutStr(
      LOG_PREFIX + 'ОШИБКА: ValidateType3Font вернул False',
      LM_Info
    );
    Result := False;
  end
  else
  begin
    programlog.LogOutStr(
      LOG_PREFIX + 'OK: ValidateType3Font вернул True',
      LM_Info
    );
  end;

  if Result then
    programlog.LogOutStr(
      LOG_PREFIX + 'все тесты структуры пройдены успешно',
      LM_Info
    )
  else
    programlog.LogOutStr(
      LOG_PREFIX + 'ТЕСТ СТРУКТУРЫ ПРОВАЛЕН',
      LM_Info
    );
end;

end.
