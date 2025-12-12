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

{
  Модуль: uzvrtrestoretable_dialogs.pas
  Назначение: Мост между ucvrestoretable и uzvspreadsheet
  Описание: Предоставляет функции для интеграции модуля восстановления таблиц
            с подсистемой электронных таблиц:
            1. Показ консольного диалога выбора действия
            2. Сохранение книги в XLSX файл
            3. Открытие книги во внутреннем редакторе
  Зависимости: fpspreadsheet, uzcinterface, Dialogs
}
unit uzvrtrestoretable_dialogs;

{$INCLUDE zengineconfig.inc}

interface

uses
  SysUtils,
  Classes,
  Dialogs,
  fpspreadsheet,
  fpsTypes,
  uzcinterface,
  uzeparserenttypefilter,
  uzeparser,
  uzccommandsabstract,
  uzeparsercmdprompt,
  uzcdrawings,
  uzvspreadsheet_cmdopenbook,
  uzvspreadsheet_actions,
  uzccommandsmanager;

resourcestring
  // Строки консольного диалога
  RSVRestoreDialogPrompt =
    'Готовая книга таблицы восстановлена. Выберите действие: ' +
    '${"&[s]ave",Keys[s],StrId[CLPIdUser1]} - Сохранить в XLSX, ' +
    '${"&[o]pen",Keys[o],StrId[CLPIdUser2]} - Открыть в редакторе, ' +
    '${"&[<]<<",Keys[<],StrId[CLPIdBack]} - Отменить';

  RSVRestoreDialogEnterFilename =
    'Введите путь для сохранения XLSX (или пусто для имени по умолчанию):';

  RSVRestoreDialogSaved =
    'Таблица успешно сохранена в файл:';

  RSVRestoreDialogCancelled =
    'Действие отменено пользователем';

  RSVRestoreDialogError =
    'Ошибка:';

// Показывает консольный диалог выбора действия с книгой
// Возвращает True, если пользователь выполнил какое-либо действие
procedure uzvrtrestoretable_ShowDialog(aWorkbook: TsWorkbook);

// Сохраняет книгу в XLSX файл с диалогом выбора пути
// Возвращает True при успешном сохранении
function uzvrtrestoretable_SaveAsXLSX(aWorkbook: TsWorkbook): Boolean;

// Открывает книгу во внутреннем редакторе uzvspreadsheet
procedure VRestoreTable_OpenInSpreadsheet(aWorkbook: TsWorkbook);

implementation

uses
  uzclog,
  uzvspreadsheet_gui,
  uzcguimanager;

const
  // Параметры диалога сохранения файла
  SAVE_DIALOG_TITLE = 'Сохранить таблицу как XLSX / Save table as XLSX';
  SAVE_DIALOG_FILTER = 'Файлы Excel (*.xlsx)|*.xlsx|Все файлы (*.*)|*.*';
  SAVE_DIALOG_DEFAULT_EXT = 'xlsx';
  SAVE_DIALOG_DEFAULT_FILENAME = 'restored_table.xlsx';

var
  clRestorePrompt: CMDLinePromptParser.TGeneralParsedText = nil;

// Сохраняет книгу в XLSX файл с диалогом выбора пути
function uzvrtrestoretable_SaveAsXLSX(aWorkbook: TsWorkbook): Boolean;
var
  saveDialog: TSaveDialog;
  fileName: string;
begin
  Result := False;

  if aWorkbook = nil then
  begin
    zcUI.TextMessage(
      RSVRestoreDialogError + ' книга не инициализирована',
      TMWOHistoryOut
    );
    Exit;
  end;

  // Создаем диалог сохранения
  saveDialog := TSaveDialog.Create(nil);
  try
    saveDialog.Title := SAVE_DIALOG_TITLE;
    saveDialog.Filter := SAVE_DIALOG_FILTER;
    saveDialog.DefaultExt := SAVE_DIALOG_DEFAULT_EXT;
    saveDialog.FilterIndex := 1;
    saveDialog.FileName := SAVE_DIALOG_DEFAULT_FILENAME;
    saveDialog.Options := saveDialog.Options + [ofOverwritePrompt];

    // Показываем диалог
    if saveDialog.Execute then
    begin
      fileName := saveDialog.FileName;

      try
        // Сохраняем книгу в формате XLSX (OOXML)
        aWorkbook.WriteToFile(fileName, sfOOXML, True);

        zcUI.TextMessage(
          RSVRestoreDialogSaved + ' ' + fileName,
          TMWOHistoryOut
        );

        programlog.LogOutFormatStr(
          'Книга сохранена в файл: %s',
          [fileName],
          LM_Info
        );

        Result := True;

      except
        on E: Exception do
        begin
          zcUI.TextMessage(
            RSVRestoreDialogError + ' при сохранении файла: ' + E.Message,
            TMWOHistoryOut
          );

          programlog.LogOutFormatStr(
            'Ошибка сохранения книги в файл %s: %s',
            [fileName, E.Message],
            LM_Error
          );
        end;
      end;
    end
    else
    begin
      // Пользователь отменил диалог
      zcUI.TextMessage(
        RSVRestoreDialogCancelled,
        TMWOHistoryOut
      );

      programlog.LogOutFormatStr(
        'Сохранение файла отменено пользователем',
        [],
        LM_Info
      );
    end;

  finally
    saveDialog.Free;
  end;
end;

// Получает или создает экземпляр формы электронных таблиц
function GetOrCreateSpreadsheetForm(
  formInfo: PTFormInfoData
): TuzvSpreadsheetForm;
begin
  Result := nil;

  // Проверяем, существует ли уже экземпляр формы
  if (formInfo^.PInstanceVariable <> nil) and
     (TuzvSpreadsheetForm(formInfo^.PInstanceVariable^) <> nil) then
  begin
    // Используем существующую форму
    Result := TuzvSpreadsheetForm(formInfo^.PInstanceVariable^);
    Exit;
  end;

  // Создаем новый экземпляр формы
  Result := TuzvSpreadsheetForm(
    ZCADGUIManager.CreateZCADFormInstance(formInfo^)
  );
  Result.Create(nil);

  // Сохраняем ссылку на экземпляр
  if formInfo^.PInstanceVariable <> nil then
    TuzvSpreadsheetForm(formInfo^.PInstanceVariable^) := Result;

  // Вызываем процедуру настройки, если она определена
  if Assigned(formInfo^.SetupProc) then
    formInfo^.SetupProc(Result);
end;

// Загружает книгу в WorkbookSource формы
function LoadWorkbookIntoForm(
  spreadsheetForm: TuzvSpreadsheetForm;
  aWorkbook: TsWorkbook
): Boolean;
begin
  Result := False;

  if spreadsheetForm.WorkbookSource = nil then
  begin
    zcUI.TextMessage(
      RSVRestoreDialogError + ' источник данных не инициализирован',
      TMWOHistoryOut
    );
    Exit;
  end;

  // Освобождаем текущую книгу, если она есть
  //if spreadsheetForm.WorkbookSource.Workbook <> nil then
  //begin
  //  spreadsheetForm.WorkbookSource.Workbook.Free;
  //  spreadsheetForm.WorkbookSource.Workbook := nil;
  //end;
  //
  //// Устанавливаем новую книгу
  //spreadsheetForm.WorkbookSource.Workbook := aWorkbook;
  //
  // Обновляем отображение
  spreadsheetForm.UpdateCellInfo;

  zcUI.TextMessage(
    'Книга открыта в редакторе электронных таблиц',
    TMWOHistoryOut
  );

  programlog.LogOutFormatStr(
    'Книга загружена в редактор uzvspreadsheet',
    [],
    LM_Info
  );

  Result := True;
end;

// Открывает книгу во внутреннем редакторе uzvspreadsheet
procedure VRestoreTable_OpenInSpreadsheet(aWorkbook: TsWorkbook);
var
  formInfo: PTFormInfoData;
  spreadsheetForm: TuzvSpreadsheetForm;
begin
  if aWorkbook = nil then
  begin
    zcUI.TextMessage(
      RSVRestoreDialogError + ' книга не инициализирована',
      TMWOHistoryOut
    );
    Exit;
  end;

  try
    // Получаем информацию о форме из менеджера
    if not ZCADGUIManager.GetZCADFormInfo('uzvspreadsheet_gui', formInfo) then
    begin
      zcUI.TextMessage(
        RSVRestoreDialogError + ' форма электронных таблиц не зарегистрирована',
        TMWOHistoryOut
      );
      programlog.LogOutFormatStr(
        'Ошибка: форма uzvspreadsheet_gui не найдена в ZCADGUIManager',
        [],
        LM_Error
      );
      Exit;
    end;

    // Получаем или создаем форму
    spreadsheetForm := GetOrCreateSpreadsheetForm(formInfo);
    if spreadsheetForm = nil then
      Exit;

    // Загружаем книгу в форму
    if not LoadWorkbookIntoForm(spreadsheetForm, aWorkbook) then
      Exit;

    // Показываем форму
    spreadsheetForm.Show;

  except
    on E: Exception do
    begin
      zcUI.TextMessage(
        RSVRestoreDialogError + ' при открытии редактора: ' + E.Message,
        TMWOHistoryOut
      );

      programlog.LogOutFormatStr(
        'Ошибка открытия редактора uzvspreadsheet: %s',
        [E.Message],
        LM_Error
      );
    end;
  end;
end;

// Показывает консольный диалог выбора действия с книгой
procedure uzvrtrestoretable_ShowDialog(aWorkbook: TsWorkbook);
type
  TDialogMode = (DMWaitAction);
var
  dialogMode: TDialogMode;
  inputText: string;
  inputResult: TzcInteractiveResult;
begin
  if aWorkbook = nil then
  begin
    zcUI.TextMessage(
      RSVRestoreDialogError + ' книга не инициализирована',
      TMWOHistoryOut
    );
    Exit;
  end;

  // Подготавливаем диалог
  if clRestorePrompt = nil then
    clRestorePrompt := CMDLinePromptParser.GetTokens(RSVRestoreDialogPrompt);

  commandmanager.SetPrompt(clRestorePrompt);
  commandmanager.ChangeInputMode([IPEmpty], []);

  dialogMode := DMWaitAction;

  // Основной цикл диалога
  repeat
    inputResult := commandmanager.GetInput('', inputText);

    case inputResult of
      IRId:
        case commandmanager.GetLastId of
          CLPIdUser1: // Save
          begin
            programlog.LogOutFormatStr(
              'Пользователь выбрал сохранение в XLSX',
              [],
              LM_Info
            );

            uzvrtrestoretable_SaveAsXLSX(aWorkbook);
            Break;
          end;

          CLPIdUser2: // Open
          begin
            programlog.LogOutFormatStr(
              'Пользователь выбрал открытие в редакторе',
              [],
              LM_Info
            );
            // Показать инспектор объектов
            commandmanager.executecommand('Show(uzvspreadsheet_gui)', drawings.GetCurrentDWG, drawings.GetCurrentOGLWParam);

            uzvspreadsheet_cmdopenbook.LoadBookFromFileTsWorkbook(aWorkbook);
            Break;
          end;

          CLPIdBack: // Cancel
          begin
            zcUI.TextMessage(
              RSVRestoreDialogCancelled,
              TMWOHistoryOut
            );

            programlog.LogOutFormatStr(
              'Пользователь отменил действие',
              [],
              LM_Info
            );

            Break;
          end;
        end;

      IRCancel:
      begin
        zcUI.TextMessage(
          RSVRestoreDialogCancelled,
          TMWOHistoryOut
        );
        Break;
      end;

      IRNormal, IRInput:
      begin
        // Если пользователь ввел что-то не из меню
        zcUI.TextMessage(
          'Выберите действие из меню',
          TMWOHistoryOut
        );
      end;
    end;

  until inputResult = IRCancel;

  programlog.LogOutFormatStr(
    'Диалог выбора действия завершен',
    [],
    LM_Info
  );
end;

initialization
  programlog.LogOutFormatStr(
    'Модуль uzvspreadsheet_bridge инициализирован',
    [],
    LM_Info
  );

finalization
  if clRestorePrompt <> nil then
    clRestorePrompt.Free;

  programlog.LogOutFormatStr(
    'Модуль uzvspreadsheet_bridge завершен',
    [],
    LM_Info
  );

end.
