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

{**Модуль реализации команды addZona для работы с зонами}
unit uzvcommand_space;

{ file def.inc is necessary to include at the beginning of each module zcad
  it contains a centralized compilation parameters settings }

{ файл def.inc необходимо включать в начале каждого модуля zcad
  он содержит в себе централизованные настройки параметров компиляции  }

{$INCLUDE zengineconfig.inc}

interface
uses
  sysutils,

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
  uzeentpolyline,      //polyline entity
                       //примитив полилиния
  uzegeometrytypes,    //geometry types
                       //геометрические типы
  uzegeometry,         //geometry functions
                       //геометрические функции
  uzbtypes,            //base types
                       //базовые типы
  uzcstrconsts,        //resource strings
                       //строковые константы
  uzccominteractivemanipulators; //interactive manipulators
                                  //интерактивные манипуляторы

function addSpace_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;

implementation

function addSpace_com(const Context:TZCADCommandContext;operands:TCommandOperands):TCommandResult;
var
  ppolyline: PGDBObjPolyLine;
  point: GDBVertex;
  firstPoint: GDBVertex;
  getResult: TGetResult;
  pointCount: integer;
begin
  // Вывод сообщения о запуске команды
  // Output message about command launch
  zcUI.TextMessage('запущена команда addSpace',TMWOHistoryOut);

  // Получаем первую точку
  // Get first point
  if commandmanager.get3dpoint(rscmSpecifyFirstPoint, firstPoint) = GRNormal then begin
    // Создаем полилинию
    // Create polyline
    ppolyline := GDBObjPolyline.CreateInstance;
    zcSetEntPropFromCurrentDrawingProp(ppolyline);

    // Устанавливаем свойства полилинии
    // Set polyline properties
    ppolyline^.Closed := True;  // Полилиния замкнута / Polyline is closed

    // Добавляем первую точку
    // Add first point
    ppolyline^.VertexArrayInOCS.PushBackData(firstPoint);
    pointCount := 1;

    // Добавляем полилинию в конструкторскую область для визуализации
    // Add polyline to construct root for visualization
    zcAddEntToCurrentDrawingConstructRoot(ppolyline);

    // Интерактивный ввод остальных точек
    // Interactive input of remaining points
    point := firstPoint;
    repeat
      // Используем интерактивный манипулятор для следующей точки
      // Use interactive manipulator for next point
      InteractivePolyLineNextVertexManipulator(ppolyline, point, False);

      getResult := commandmanager.Get3DPointInteractive(
        rscmSpecifyNextPoint + ' (Enter to finish):',
        point,
        @InteractivePolyLineNextVertexManipulator,
        ppolyline
      );

      if getResult = GRNormal then begin
        // Добавляем следующую точку
        // Add next point
        ppolyline^.VertexArrayInOCS.PushBackData(point);
        inc(pointCount);
      end;
    until getResult <> GRNormal;

    // Проверяем что введено минимум 3 точки для создания пространства
    // Check that at least 3 points were entered to create a space
    if pointCount >= 3 then begin
      // Копируем полилинию из конструкторской области в чертеж с Undo
      // Copy polyline from construct root to drawing with Undo
      zcMoveEntsFromConstructRootToCurrentDrawingWithUndo('addSpace');
      zcUI.TextMessage('Пространство создано / Space created', TMWOHistoryOut);
    end else begin
      // Если точек меньше 3, очищаем конструкторскую область
      // If less than 3 points, clear construct root
      drawings.GetCurrentDWG^.FreeConstructionObjects;
      zcUI.TextMessage('Отменено: необходимо минимум 3 точки / Cancelled: minimum 3 points required', TMWOHistoryOut);
    end;
  end;

  result := cmd_ok;
end;

initialization
  // Регистрация команды addSpace
  // Register the addSpace command
  CreateZCADCommand(@addSpace_com,'addSpace',CADWG,0);
end.
