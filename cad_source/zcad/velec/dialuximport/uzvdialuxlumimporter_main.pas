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
{$mode objfpc}{$H+}

{**Основной модуль импорта светильников Dialux}
unit uzvdialuxlumimporter_main;

{$INCLUDE zengineconfig.inc}

interface
uses
  SysUtils,
  uzccommandsmanager,
  uzccommandsabstract,
  uzccommandsimpl,
  uzbtypes,
  uzclog,
  uzvdialuxlumimporter_structs,
  uzvdialuxlumimporter_utils,
  uzvdialuxlumimporter_parser,
  uzvdialuxlumimporter_recognizer,
  uzvdialuxlumimporter_blocks;

{**Функция команды импорта светильников Dialux}
function ImportDialuxLuminaires_com(
  const Context: TZCADCommandContext;
  operands: TCommandOperands
): TCommandResult;

implementation

{**Вывести результаты распознавания светильников}
procedure PrintRecognizedLights(
  const RecognizedLights: TLightItemArray
);
var
  i: Integer;
  LightItem: TLightItem;
begin
  if Length(RecognizedLights) = 0 then
  begin
    PrintMessage('[Dialux Importer] Не распознано ни одного светильника.');
    Exit;
  end;

  PrintFormatMessage(
    '[Dialux Importer] Распознано %d светильника(-ов):',
    [Length(RecognizedLights)]
  );

  for i := 0 to High(RecognizedLights) do
  begin
    LightItem := RecognizedLights[i];
    PrintFormatMessage(
      '  %s → (%.1f, %.1f)',
      [LightItem.LumKey, LightItem.Center.x, LightItem.Center.y]
    );
  end;
end;

{**Вывести результаты сбора загруженных блоков}
procedure PrintLoadedBlocks(LoadedBlocks: TLoadedBlocksList);
var
  i: Integer;
begin
  if LoadedBlocks.Count = 0 then
  begin
    PrintMessage(
      '[Dialux Importer] Не найдено блоков с префиксом VELEC.'
    );
    Exit;
  end;

  PrintFormatMessage(
    '[Dialux Importer] Загруженные блоки (%d):',
    [LoadedBlocks.Count]
  );

  for i := 0 to LoadedBlocks.Count - 1 do
  begin
    PrintFormatMessage(' - %s', [LoadedBlocks[i]]);
  end;
end;

{**Вывести итоговые результаты анализа}
procedure PrintFinalSummary(
  GeometryCount, KeysCount: Integer;
  const RecognizedLights: TLightItemArray;
  LoadedBlocks: TLoadedBlocksList
);
begin
  PrintMessage('[Dialux Importer] ====== Результаты анализа ======');
  PrintFormatMessage(
    'Найдено: %d элементов DLX_LUM',
    [GeometryCount]
  );
  PrintFormatMessage(
    'Найдено: %d текста DLX_LUMKEY_IDX',
    [KeysCount]
  );
  PrintFormatMessage(
    'Распознано: %d светильника(-ов)',
    [Length(RecognizedLights)]
  );
  PrintFormatMessage(
    'Загруженные блоки (%d):',
    [LoadedBlocks.Count]
  );

  if LoadedBlocks.Count > 0 then
  begin
    PrintLoadedBlocks(LoadedBlocks);
  end;

  PrintMessage('[Dialux Importer] =================================');
end;

{**Функция команды импорта светильников Dialux}
function ImportDialuxLuminaires_com(
  const Context: TZCADCommandContext;
  operands: TCommandOperands
): TCommandResult;
var
  ParsedData: TParsedData;
  RecognizedLights: TLightItemArray;
  LoadedBlocks: TLoadedBlocksList;
begin
  Result := cmd_ok;

  programlog.LogOutFormatStr(
    'Запущена команда импорта светильников Dialux',
    [],
    LM_Info
  );

  PrintMessage('[Dialux Importer] Запуск анализа...');

  // Этап 2: Получение выделенных элементов
  programlog.LogOutFormatStr(
    'Этап 2: Получение выделенных элементов',
    [],
    LM_Info
  );

  if not HasSelectedObjects then
  begin
    PrintMessage('[Dialux Importer] Нет выделенных объектов.');
    programlog.LogOutFormatStr(
      'Команда завершена: нет выделенных объектов',
      [],
      LM_Warning
    );
    Exit;
  end;

  ParseSelectedElements(ParsedData);

  PrintFormatMessage(
    '[Dialux Importer] Найдено %d элемента в слое DLX_LUM.',
    [ParsedData.GeometryCount]
  );
  PrintFormatMessage(
    '[Dialux Importer] Найдено %d текста в слое DLX_LUMKEY_IDX.',
    [ParsedData.KeysCount]
  );

  // Этап 3: Распознавание светильников
  programlog.LogOutFormatStr(
    'Этап 3: Распознавание светильников',
    [],
    LM_Info
  );

  RecognizeLuminaires(ParsedData, RecognizedLights);

  PrintRecognizedLights(RecognizedLights);

  // Этап 4: Определение загруженных блоков
  programlog.LogOutFormatStr(
    'Этап 4: Определение загруженных блоков',
    [],
    LM_Info
  );

  GetLoadedBlocks(LoadedBlocks);

  // Вывод итоговых результатов
  PrintFinalSummary(
    ParsedData.GeometryCount,
    ParsedData.KeysCount,
    RecognizedLights,
    LoadedBlocks
  );

  // Освобождение памяти
  FreeParsedData(ParsedData);
  FreeLoadedBlocks(LoadedBlocks);
  SetLength(RecognizedLights, 0);

  programlog.LogOutFormatStr(
    'Команда импорта светильников Dialux завершена успешно',
    [],
    LM_Info
  );
end;

end.
