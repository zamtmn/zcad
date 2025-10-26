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

{**Модуль реализации команды ShowHideSpace для подсветки зон по переменным}
unit uzvcommand_showhidespace;

{ file def.inc is necessary to include at the beginning of each module zcad
  it contains a centralized compilation parameters settings }

{ файл def.inc необходимо включать в начале каждого модуля zcad
  он содержит в себе централизованные настройки параметров компиляции  }

{$INCLUDE zengineconfig.inc}

interface
uses
  sysutils,
  Classes,             //TStringList and related classes
                       //TStringList и связанные классы

  uzccommandsmanager,
  uzccommandsabstract,
  uzccommandsimpl,     //Commands manager and related objects
                       //менеджер команд и объекты связанные с ним
  uzclog,              //log system
                       //система логирования
  uzcinterface,        //interface utilities
                       //утилиты интерфейса
  uzcdrawings,         //Drawings manager
                       //Менеджер чертежей
  uzcutils,            //utility functions
                       //утилиты
  uzeentity,           //base entity
                       //базовый примитив
  uzeentpolyline,      //polyline entity
                       //примитив полилиния
  uzbtypes,            //base types
                       //базовые типы
  uzcstrconsts,        //resource strings
                       //строковые константы
  uzcenitiesvariablesextender,  //entity variables extender
                                //расширение переменных примитивов
  varmandef;                     //variable manager definitions
                                 //определения менеджера переменных

function ShowHideSpace_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;

implementation

// Helper procedure to parse variable names from operands string
// Вспомогательная процедура для разбора имен переменных из строки операндов
procedure ParseVariableNames(const operands: TCommandOperands; var varList: TStringList);
var
  i: integer;
  varname: string;
begin
  // Split operands by comma
  // Разделяем операнды по запятой
  varList.Delimiter := ',';
  varList.StrictDelimiter := True;
  varList.DelimitedText := operands;

  // Trim whitespace from each variable name and remove quotes
  // Удаляем пробелы из каждого имени переменной и убираем кавычки
  for i := 0 to varList.Count - 1 do begin
    varname := Trim(varList[i]);

    // Remove quotes if present
    // Удаляем кавычки если есть
    if (Length(varname) >= 2) and (varname[1] = '''') and (varname[Length(varname)] = '''') then
      varname := Copy(varname, 2, Length(varname) - 2);

    varList[i] := varname;
  end;
end;

// Check if entity has any of the specified variables
// Проверяет содержит ли примитив любую из указанных переменных
function EntityHasAnyVariable(pEntity: PGDBObjEntity; varList: TStringList): boolean;
var
  VarExt: TVariablesExtender;
  i: integer;
  pvd: pvardesk;
begin
  Result := False;

  // Get variables extender from entity
  // Получаем расширение переменных от примитива
  VarExt := pEntity^.GetExtension<TVariablesExtender>;
  if VarExt = nil then
    exit;

  // Check each variable from the list
  // Проверяем каждую переменную из списка
  for i := 0 to varList.Count - 1 do begin
    pvd := VarExt.entityunit.FindVariable(varList[i]);
    if pvd <> nil then begin
      Result := True;
      exit;
    end;
  end;
end;

function ShowHideSpace_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var
  pEntity: PGDBObjEntity;
  ir: itrec;
  varList: TStringList;
  foundCount: integer;
  processedCount: integer;
begin
  // Вывод сообщения о запуске команды
  // Output message about command launch
  zcUI.TextMessage('запущена команда ShowHideSpace',TMWOHistoryOut);

  // Проверяем наличие операндов
  // Check if we have operands
  if Trim(operands) = '' then begin
    zcUI.TextMessage('Ошибка: не указаны имена переменных / Error: variable names not specified', TMWOHistoryOut);
    zcUI.TextMessage('Использование / Usage: ShowHideSpace variable1,variable2,...', TMWOHistoryOut);
    Result := cmd_ok;
    exit;
  end;

  // Парсим имена переменных из операндов
  // Parse variable names from operands
  varList := TStringList.Create;
  try
    ParseVariableNames(operands, varList);

    if varList.Count = 0 then begin
      zcUI.TextMessage('Ошибка: не удалось распознать имена переменных / Error: could not parse variable names', TMWOHistoryOut);
      Result := cmd_ok;
      exit;
    end;

    zcUI.TextMessage('Поиск полилиний с переменными / Searching for polylines with variables: ' + varList.CommaText, TMWOHistoryOut);

    foundCount := 0;
    processedCount := 0;

    // Снимаем выделение со всех объектов перед началом
    // Deselect all objects before starting
    drawings.GetCurrentDWG.DeSelectAll;

    // Перебираем все примитивы в чертеже
    // Iterate through all entities in the drawing
    pEntity := drawings.GetCurrentROOT.ObjArray.beginiterate(ir);
    if pEntity <> nil then
      repeat
        inc(processedCount);

        // Проверяем является ли примитив полилинией
        // Check if entity is a polyline
        if pEntity^.GetObjType = GDBPolyLineID then begin
          // Проверяем содержит ли полилиния указанные переменные
          // Check if polyline contains specified variables
          if EntityHasAnyVariable(pEntity, varList) then begin
            // Выделяем полилинию
            // Select the polyline
            pEntity^.Select(drawings.GetCurrentDWG^.wa.param.SelDesc.Selectedobjcount,
                           @drawings.GetCurrentDWG^.Selector);
            inc(foundCount);
          end;
        end;

        pEntity := drawings.GetCurrentROOT.ObjArray.iterate(ir);
      until pEntity = nil;

    // Выводим результаты
    // Output results
    zcUI.TextMessage('Обработано примитивов / Entities processed: ' + IntToStr(processedCount), TMWOHistoryOut);
    zcUI.TextMessage('Найдено и выделено полилиний / Polylines found and selected: ' + IntToStr(foundCount), TMWOHistoryOut);

    // Перерисовываем для отображения выделения
    // Redraw to show selection
    if foundCount > 0 then
      zcUI.Do_GUIaction(nil, zcMsgUIActionRedraw);

  finally
    varList.Free;
  end;

  Result := cmd_ok;
end;

initialization
  // Регистрация команды ShowHideSpace
  // Register the ShowHideSpace command
  CreateZCADCommand(@ShowHideSpace_com,'ShowHideSpace',CADWG,0);
end.
