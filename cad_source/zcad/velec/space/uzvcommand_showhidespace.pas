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
  uzeenthatch,         //hatch entity
                       //примитив штриховка
  uzeBoundaryPath,     //boundary path for hatch
                       //граничный путь для штриховки
  UGDBPolyLine2DArray, //2D polyline array
                       //массив 2D полилиний
  uzgldrawcontext,     //drawing context
                       //контекст рисования
  uzegeometrytypes,    //geometry types
                       //геометрические типы
  uzbtypes,            //base types
                       //базовые типы
  uzcstrconsts,        //resource strings
                       //строковые константы
  uzcenitiesvariablesextender,  //entity variables extender
                                //расширение переменных примитивов
  gzctnrVectorTypes,
  uzeconsts,
  varmandef;                     //variable manager definitions
                                 //определения менеджера переменных

function ShowHideSpace_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;

implementation

// Helper function to create solid hatch from polyline
// Вспомогательная функция для создания сплошной штриховки из полилинии
function CreateSolidHatchFromPolyline(ppolyline: PGDBObjPolyLine): PGDBObjHatch;
var
  phatch: PGDBObjHatch;
  pathData: GDBPolyline2DArray;
  v2d: GDBVertex2D;
  i: integer;
  vertexCount: integer;
  dc: TDrawContext;
begin
  Result := nil;

  if ppolyline = nil then
    exit;

  vertexCount := ppolyline^.VertexArrayInOCS.Count;

  // Проверяем что у полилинии достаточно вершин для создания штриховки
  // Check that polyline has enough vertices to create hatch
  if vertexCount < 3 then
    exit;

  // Создаем штриховку
  // Create hatch
  phatch := GDBObjHatch.CreateInstance;

  // Устанавливаем свойства штриховки от полилинии
  // Set hatch properties from polyline
  phatch^.vp.Layer := ppolyline^.vp.Layer;
  phatch^.vp.LineWeight := ppolyline^.vp.LineWeight;
  phatch^.vp.Color := 4; // Светло-голубой цвет (cyan) для подсветки
                         // Light blue color (cyan) for highlighting
  phatch^.PPattern := nil; // Сплошная штриховка (тип solid)
                           // Solid hatch (solid type)

  // Локальная система координат штриховки инициализирована по умолчанию
  // Hatch local coordinate system is initialized by default

  // Создаем путь из вершин полилинии
  // Create path from polyline vertices
  pathData.init(vertexCount, True);

  for i := 0 to vertexCount - 1 do begin
    v2d.x := ppolyline^.VertexArrayInOCS.getData(i).x;
    v2d.y := ppolyline^.VertexArrayInOCS.getData(i).y;
    pathData.PushBackData(v2d);
  end;

  phatch^.Path.paths.PushBackData(pathData);

  // Форматируем примитив штриховки
  // Format hatch entity
  dc := drawings.GetCurrentDWG^.CreateDrawingRC;
  phatch^.FormatEntity(drawings.GetCurrentDWG^, dc);

  Result := phatch;
end;

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
  VarExt := pEntity^.specialize GetExtension<TVariablesExtender>;
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
  pPolyline: PGDBObjPolyLine;
  phatch: PGDBObjHatch;
  ir: itrec;
  varList: TStringList;
  foundCount: integer;
  processedCount: integer;
  hatchCount: integer;
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
    hatchCount := 0;

    // Снимаем выделение со всех объектов перед началом
    // Deselect all objects before starting
    drawings.GetCurrentDWG^.DeSelectAll;

    // Перебираем все примитивы в чертеже
    // Iterate through all entities in the drawing
    pEntity := drawings.GetCurrentROOT^.ObjArray.beginiterate(ir);
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

            // Создаем сплошную штриховку внутри полилинии
            // Create solid hatch inside polyline
            pPolyline := PGDBObjPolyLine(pEntity);
            phatch := CreateSolidHatchFromPolyline(pPolyline);

            if phatch <> nil then begin
              // Добавляем штриховку в чертеж
              // Add hatch to drawing
              zcAddEntToCurrentDrawingWithUndo(phatch);
              inc(hatchCount);
            end;
          end;
        end;

        pEntity := drawings.GetCurrentROOT^.ObjArray.iterate(ir);
      until pEntity = nil;

    // Выводим результаты
    // Output results
    zcUI.TextMessage('Обработано примитивов / Entities processed: ' + IntToStr(processedCount), TMWOHistoryOut);
    zcUI.TextMessage('Найдено и выделено полилиний / Polylines found and selected: ' + IntToStr(foundCount), TMWOHistoryOut);
    zcUI.TextMessage('Создано штриховок / Hatches created: ' + IntToStr(hatchCount), TMWOHistoryOut);

    // Перерисовываем для отображения выделения и штриховок
    // Redraw to show selection and hatches
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
