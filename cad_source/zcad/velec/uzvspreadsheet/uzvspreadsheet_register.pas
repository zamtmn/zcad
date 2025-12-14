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

{** Модуль регистрации формы электронных таблиц в системе ZCAD
    Содержит только регистрацию формы в initialization и очистку в finalization
    Не содержит GUI-кода и логики fpspreadsheet }
unit uzvspreadsheet_register;

{$INCLUDE zengineconfig.inc}

interface

uses
  Classes,
  SysUtils,
  Controls,
  Types,
  uzcguimanager,
  uzvspreadsheet_gui;

implementation

uses
  uzclog,
  uzcinterface;

{ Процедура настройки формы при создании }
procedure uzvspreadsheetSetupProc(Form: TControl);
begin
  // Здесь можно добавить дополнительную настройку формы
  // при её создании через менеджер GUI ZCAD
  programlog.LogOutFormatStr(
    'Форма электронных таблиц инициализирована через SetupProc',
    [],
    LM_Info
  );
end;

initialization
  // Регистрируем форму в менеджере GUI ZCAD
  ZCADGUIManager.RegisterZCADFormInfo(
    'uzvspreadsheet_gui',         // Идентификатор формы
    'uzvspreadsheet_gui',         // Отображаемое имя формы
    TuzvSpreadsheetForm,          // Класс формы
    Rect(0, 100, 800, 600),       // Начальные размеры и положение
    @uzvspreadsheetSetupProc,     // Процедура настройки формы
    nil,                          // Параметры по умолчанию
    @uzvSpreadsheetForm,          // Указатель на переменную формы
    True                          // Флаг регистрации
  );

  programlog.LogOutFormatStr(
    'Модуль uzvspreadsheet зарегистрирован в системе ZCAD',
    [],
    LM_Info
  );

finalization
  // Освобождение ресурсов при завершении программы
  programlog.LogOutFormatStr(
    'Модуль uzvspreadsheet выгружен из системы ZCAD',
    [],
    LM_Info
  );

end.
