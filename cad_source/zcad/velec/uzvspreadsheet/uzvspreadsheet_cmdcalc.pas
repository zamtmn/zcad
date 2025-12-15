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

{** Модуль команды пересчёта формул в книге
    Содержит логику выполнения пересчёта и управления флагом автокалькуляции }
unit uzvspreadsheet_cmdcalc;

{$INCLUDE zengineconfig.inc}

interface

uses
  Classes,
  SysUtils,
  fpspreadsheet,
  fpsTypes,
  fpspreadsheetctrls;

{ Выполняет пересчёт всех формул в книге }
procedure ExecuteCalcFormulas(aWorkbookSource: TsWorkbookSource);

{ Выполняет пересчёт формул на активном листе }
procedure ExecuteCalcActiveSheet(aWorkbookSource: TsWorkbookSource);

{ Устанавливает режим автопересчёта формул }
procedure SetAutoCalcEnabled(aWorkbookSource: TsWorkbookSource;
  aEnabled: Boolean);

{ Возвращает текущее состояние автопересчёта }
function IsAutoCalcEnabled(aWorkbookSource: TsWorkbookSource): Boolean;

implementation

uses
  uzclog,
  uzcinterface;

{ Выполняет пересчёт всех формул в книге }
procedure ExecuteCalcFormulas(aWorkbookSource: TsWorkbookSource);
var
  workbook: TsWorkbook;
begin
  if aWorkbookSource = nil then
  begin
    zcUI.TextMessage('Ошибка: источник данных книги не инициализирован',
      TMWOHistoryOut);
    Exit;
  end;

  workbook := aWorkbookSource.Workbook;
  if workbook = nil then
  begin
    zcUI.TextMessage('Ошибка: книга не загружена', TMWOHistoryOut);
    Exit;
  end;

  try
    programlog.LogOutFormatStr(
      'Начат пересчёт формул в книге',
      [],
      LM_Info
    );

    // Выполняем пересчёт всех формул в книге
    workbook.CalcFormulas;

    programlog.LogOutFormatStr(
      'Пересчёт формул в книге завершён',
      [],
      LM_Info
    );
    zcUI.TextMessage('Пересчёт формул выполнен', TMWOHistoryOut);
  except
    on E: Exception do
    begin
      programlog.LogOutFormatStr(
        'Ошибка пересчёта формул: %s',
        [E.Message],
        LM_Info
      );
      zcUI.TextMessage('Ошибка пересчёта формул: ' + E.Message, TMWOHistoryOut);
    end;
  end;
end;

{ Выполняет пересчёт формул на активном листе }
procedure ExecuteCalcActiveSheet(aWorkbookSource: TsWorkbookSource);
var
  workbook: TsWorkbook;
  worksheet: TsWorksheet;
begin
  if aWorkbookSource = nil then
  begin
    zcUI.TextMessage('Ошибка: источник данных книги не инициализирован',
      TMWOHistoryOut);
    Exit;
  end;

  workbook := aWorkbookSource.Workbook;
  if workbook = nil then
  begin
    zcUI.TextMessage('Ошибка: книга не загружена', TMWOHistoryOut);
    Exit;
  end;

  worksheet := workbook.ActiveWorksheet;
  if worksheet = nil then
  begin
    zcUI.TextMessage('Ошибка: активный лист не выбран', TMWOHistoryOut);
    Exit;
  end;

  try
    programlog.LogOutFormatStr(
      'Начат пересчёт формул на листе: %s',
      [worksheet.Name],
      LM_Info
    );

    // Выполняем пересчёт формул на активном листе
    worksheet.CalcFormulas;

    programlog.LogOutFormatStr(
      'Пересчёт формул на листе %s завершён',
      [worksheet.Name],
      LM_Info
    );
    zcUI.TextMessage('Пересчёт формул на листе "' + worksheet.Name +
      '" выполнен', TMWOHistoryOut);
  except
    on E: Exception do
    begin
      programlog.LogOutFormatStr(
        'Ошибка пересчёта формул на листе: %s',
        [E.Message],
        LM_Info
      );
      zcUI.TextMessage('Ошибка пересчёта: ' + E.Message, TMWOHistoryOut);
    end;
  end;
end;

{ Устанавливает режим автопересчёта формул }
procedure SetAutoCalcEnabled(aWorkbookSource: TsWorkbookSource;
  aEnabled: Boolean);
var
  workbook: TsWorkbook;
begin
  if aWorkbookSource = nil then
  begin
    zcUI.TextMessage('Ошибка: источник данных книги не инициализирован',
      TMWOHistoryOut);
    Exit;
  end;

  workbook := aWorkbookSource.Workbook;
  if workbook = nil then
  begin
    zcUI.TextMessage('Ошибка: книга не загружена', TMWOHistoryOut);
    Exit;
  end;

  try
    if aEnabled then
    begin
      // Включаем автопересчёт - убираем флаг boAutoCalc из Options
      // NOTE: В fpspreadsheet автопересчёт управляется через Options
      workbook.Options := workbook.Options + [boAutoCalc];

      programlog.LogOutFormatStr(
        'Автопересчёт формул включён',
        [],
        LM_Info
      );
    end
    else
    begin
      // Выключаем автопересчёт
      workbook.Options := workbook.Options - [boAutoCalc];

      programlog.LogOutFormatStr(
        'Автопересчёт формул выключен',
        [],
        LM_Info
      );
    end;
  except
    on E: Exception do
    begin
      programlog.LogOutFormatStr(
        'Ошибка изменения режима автопересчёта: %s',
        [E.Message],
        LM_Info
      );
      zcUI.TextMessage('Ошибка: ' + E.Message, TMWOHistoryOut);
    end;
  end;
end;

{ Возвращает текущее состояние автопересчёта }
function IsAutoCalcEnabled(aWorkbookSource: TsWorkbookSource): Boolean;
var
  workbook: TsWorkbook;
begin
  Result := False;

  if aWorkbookSource = nil then
    Exit;

  workbook := aWorkbookSource.Workbook;
  if workbook = nil then
    Exit;

  Result := boAutoCalc in workbook.Options;
end;

end.
