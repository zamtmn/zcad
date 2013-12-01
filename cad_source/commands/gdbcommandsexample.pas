{
*****************************************************************************
*                                                                           *
*  This file is part of the ZCAD                                            *
*                                                                           *
*  See the file COPYING.modifiedLGPL.txt, included in this distribution,    *
*  for details about the copyright.                                         *
*                                                                           *
*  This program is distributed in the hope that it will be useful,          *
*  but WITHOUT ANY WARRANTY; without even the implied warranty of           *
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                     *
*                                                                           *
*****************************************************************************
}
{
@author(Andrey Zubarev <zamtmn@yandex.ru>) 
}
unit gdbcommandsexample;
{$INCLUDE def.inc}{file def.inc is necessary to include at the beginning of each module zcad}
                  {it contains a centralized compilation parameters settings}
                  {файл def.inc необходимо включать в начале каждого модуля zcad}
                  {он содержит в себе централизованные настройки параметров компиляции}

interface
uses
  {uses units, the list will vary depending on the required entities and actions}
  {подключеные модули, список будет меняться в зависимости от требуемых примитивов и действий с ними}
  gdbaligneddimension,//unit describes aligned dimensional entity
                      //модуль описывающий выровненный размерный примитив
  GDBLine,            //unit describes line entity
                      //модуль описывающий примитив линия
  gdbentityfactory,   //unit describing a "factory" to create primitives
                      //модуль описывающий "фабрику" для создания примитивов
  zcadsysvars,        //system global variables
                      //системные переменные
  gdbase,gdbasetypes, //base types
                      //описания базовых типов
  gdbobjectsconstdef, //base constants
                      //описания базовых констант
  commandline,commandlinedef,commanddefinternal,//Commands manager and related objects
                                                //менеджер команд и объекты связанные с ним
  UGDBDescriptor,     //Drawings manager, all open drawings are processed him
                      //"Менеджер" чертежей
  GDBManager,         //different functions simplify the creation entities, while there are very few
                      //разные функции упрощающие создание примитивов, пока их там очень мало
  log;                //log system
                      //система логирования

implementation
{Интерактивные процедуры используются совместно с Get3DPointInteractive, впоследствии будут вынесены в отдельный модуль}
{Interactive procedures are used together with Get3DPointInteractive, later to be moved to a separate unit}

{Procedure interactive changes end of the line}
{Процедура интерактивного изменения конца линии}
procedure InteractiveLineEndManipulator(const PInteractiveData:GDBPointer{pointer to the line entity};Point:GDBVertex{new end coord};Click:GDBBoolean{true if lmb presseed});
begin
     PGDBObjLine(PInteractiveData)^.CoordInOCS.lEnd:=Point;//set the new point to the end of the line
                                                           //устанавливаем новую точку конца линии
     GDBObjSetEntityProp(PGDBObjLine(PInteractiveData),    //assign general properties from system variables to entity
                                                           //присваиваем примитиву общие свойства из системных переменных
                         sysvar.dwg.DWG_CLayer^,           //layer
                                                           //слой
                         sysvar.dwg.DWG_CLType^,           //line type
                                                           //типлиний
                         sysvar.dwg.DWG_CColor^,           //color
                                                           //цвет
                         sysvar.dwg.DWG_CLinew^);          //lineweight
                                                           //вес линий
     PGDBObjLine(PInteractiveData)^.FormatEntity(gdb.GetCurrentDWG^);//format entity
                                                                     //"форматируем" примитив в соответствии с заданными параметрами
end;

{Procedure interactive changes third point of aligned dimensions}
{Процедура интерактивного изменения третьей точки выровненного размера}
procedure InteractiveADimManipulator(const PInteractiveData:GDBPointer;Point:GDBVertex;Click:GDBBoolean);
begin
    GDBObjSetEntityProp(PGDBObjAlignedDimension(PInteractiveData),//assign general properties from system variables to entity
                                                                  //присваиваем примитиву общие свойства из системных переменных
                        sysvar.dwg.DWG_CLayer^,                   //layer
                                                                  //слой
                        sysvar.dwg.DWG_CLType^,                   //line type
                                                                  //типлиний
                        sysvar.dwg.DWG_CColor^,                   //color
                                                                  //цвет
                        sysvar.dwg.DWG_CLinew^);                  //lineweight
                                                                  //вес линий
    PGDBObjAlignedDimension(PInteractiveData)^.PDimStyle:=gdb.GetCurrentDWG^.DimStyleTable.getelement(0);//specify the dimension style (there is no such system variable, in the future it will appear)
                                                                                                         //указываем стиль размеров (пока нет такой системной переменной)

    PGDBObjAlignedDimension(PInteractiveData)^.DimData.P10InWCS:=Point;//assign the obtained point to the appropriate location primitive
                                                                       //присваиваем полученые точки в соответствующие места примитиву

    PGDBObjAlignedDimension(PInteractiveData)^.CalcDNVectors;//calculate P10InWCS - she must lie on normal drawn from P14InWCS, use the built-in to primitive mechanism
                                                             //рассчитываем P10InWCS - она должна лежать на нормали проведенной из P14InWCS, используем для этого встроенный в примитив механизм
    PGDBObjAlignedDimension(PInteractiveData)^.DimData.P10InWCS:=PGDBObjAlignedDimension(PInteractiveData)^.P10ChangeTo(Point);//calculate P10InWCS - she must lie on normal drawn from P14InWCS, use the built-in to primitive mechanism
                                                                                                                               //рассчитываем P10InWCS - она должна лежать на нормали проведенной из P14InWCS, используем для этого встроенный в примитив механизм

    PGDBObjAlignedDimension(PInteractiveData)^.FormatEntity(gdb.GetCurrentDWG^);//format entity
                                                                                //"форматируем" примитив в соответствии с заданными параметрами
end;


{"command" function, they must all have a description of the function name(operands:TCommandOperands):TCommandResult;}
{after the registration, it will be available from the interface}
{"командная" функция, все они должны иметь описание function name(operands:TCommandOperands):TCommandResult;}
{после соответствующей регистрации она будет доступна из интерфейса программ}
function DrawAlignedDim_com(operands:TCommandOperands):TCommandResult;//this example function prompts the user to specify the 3 points and builds on the basis of them aligned dimension
                                                                      //данная примерная функция просит пользователя указать 3 точки и строит на основе них выровненный размер
var
    pd:PGDBObjAlignedDimension;//указатель на создаваемый размерный примитив
                               //pointer to the created dimensional entity
    pline:PGDBObjLine;//указатель на "временную" линию
                      //pointer to temporary line
    p1,p2,p3:gdbvertex;//3 points to be obtained from the user
                       //3 точки которые будут получены от пользователя
    savemode:GDBByte;//variable to store the current mode of the editor
                     //переменная для сохранения текущего режима редактора
begin
    savemode:=GDB.GetCurrentDWG^.DefMouseEditorMode(MGet3DPoint or MGet3DPointWoOP,         //set mode point of the mouse
                                                                                            //устанавливаем режим указания точек мышью
                                                    MGetSelectionFrame or MGetSelectObject);//reset selection entities  mode
                                                                                            //сбрасываем режим выбора примитивов мышью
    if commandmanager.get3dpoint('Specify first point:',p1) then  //try to get from the user first point
                                                                  //пытаемся получить от пользователя первую точку
    begin
         pline := GDBPointer(gdb.GetCurrentDWG^.ConstructObjRoot.ObjArray.CreateInitObj(GDBLineID,gdb.GetCurrentROOT));//Create a "temporary" line in the constructing entities list
                                                                                                                       //Создаем "временную" линию в списке конструируемых примитивов
         pline^.CoordInOCS.lBegin:=p1;//set the beginning of the line
                                      //устанавливаем начало линии
         InteractiveLineEndManipulator(pline,p1,false);//use the interactive function for final configuration line
                                                       //используем интерактивную функцию для окончательной настройки линии
      if commandmanager.Get3DPointInteractive('Specify second point:',p2,@InteractiveLineEndManipulator,pline) then  //trying to get the user to the second point, use the interactive function to draw a line
                                                                                                                     //пытаемся получить от пользователя вторую точку, используем интерактивную функцию для черчения линии
      begin
           gdb.GetCurrentDWG.FreeConstructionObjects;//clear the constructed objects list (temporary line will be removed)
                                                     //очищаем список конструируемых объектов (временная линия будет удалена)
           pd := GDBPointer(gdb.GetCurrentDWG^.ConstructObjRoot.ObjArray.CreateInitObj(GDBAlignedDimensionID,gdb.GetCurrentROOT));//create dimensional entity in the list of constructing
                                                                                                                                  //создаем размерный примитив в списке конструируемых
           pd^.DimData.P13InWCS:=p1;//assign the obtained point to the appropriate location primitive
                                    //присваиваем полученые точки в соответствующие места примитиву
           pd^.DimData.P14InWCS:=p2;//assign the obtained point to the appropriate location primitive
                                    //присваиваем полученые точки в соответствующие места примитиву
           InteractiveADimManipulator(pd,p2,false);//use the interactive function for final configuration entity
                                                   //используем интерактивную функцию для окончательной настройки примитива
        if commandmanager.Get3DPointInteractive('Specify third point:',p3,@InteractiveADimManipulator,pd) then //try to get from the user the third point, use the interactive function for drawing dimensional primitive
                                                                                                               //пытаемся получить от пользователя третью точку, используем интерактивную функцию для черчения размерного примитива
          begin //if all 3 points were obtained - build primitive in the list of primitives
                //если все 3 точки получены - строим примитив в списке примитивов
               pd := CreateObjFree(GDBAlignedDimensionID);//allocate memory for the primitive
                                                          //выделяем вамять под примитив
               pd^.initnul(gdb.GetCurrentROOT);//инициализируем примитив, указываем его владельца
                                               //initialize the primitive, specify its owner
               GDBObjSetEntityProp(pd,                     //assign general properties from system variables to entity
                                                           //присваиваем примитиву общие свойства из системных переменных
                                   sysvar.dwg.DWG_CLayer^, //layer
                                                           //слой
                                   sysvar.dwg.DWG_CLType^, //line type
                                                           //типлиний
                                   sysvar.dwg.DWG_CColor^, //color
                                                           //цвет
                                   sysvar.dwg.DWG_CLinew^);//lineweight
                                                           //вес линий

               pd^.PDimStyle:=gdb.GetCurrentDWG^.DimStyleTable.getelement(0);//specify the dimension style (there is no such system variable)
                                                                             //is assigned a zero-dimensional style from the table descriptions, i.e. 'Standart'
                                                                             //указываем стиль размеров (пока нет такой системной переменной)
                                                                             //присваевается нулевой размерный стиль из таблицы описаний, т.е. 'Standart'
               pd^.DimData.P13InWCS:=p1;//assign the obtained point to the appropriate location primitive
                                        //присваиваем полученые точки в соответствующие места примитиву
               pd^.DimData.P14InWCS:=p2;//assign the obtained point to the appropriate location primitive
                                        //присваиваем полученые точки в соответствующие места примитиву
               pd^.DimData.P10InWCS:=p3;//assign the obtained point to the appropriate location primitive
                                        //присваиваем полученые точки в соответствующие места примитиву

               pd^.CalcDNVectors;                        //calculate p3 - she must lie on normal drawn from p2, use the built-in to primitive mechanism
                                                         //рассчитываем p3 - она должна лежать на нормали проведенной из p2, используем для этого встроенный в примитив механизм
               pd^.DimData.P10InWCS:=pd^.P10ChangeTo(p3);//calculate p3 - she must lie on normal drawn from p2, use the built-in to primitive mechanism
                                                         //рассчитываем p3 - она должна лежать на нормали проведенной из p2, используем для этого встроенный в примитив механизм

               pd^.FormatEntity(gdb.GetCurrentDWG^);//format entity
                                                    //"форматируем" примитив в соответствии с заданными параметрами

               gdb.AddEntToCurrentDrawingWithUndo(pd);//Add entity to drawing considering tying to undo-redo
                                                      //Добавляем примитив в чертеж с учетом обвязки для undo-redo
          end;
      end;
    end;
    result:=cmd_ok;//All Ok
                   //команда завершилась, говорим что всё заебись
    GDB.GetCurrentDWG^.SetMouseEditorMode(savemode);//restore editor mode
                                                    //восстанавливаем сохраненный режим редактора
end;

initialization
     {$IFDEF DEBUGINITSECTION}LogOut('gdbcommandsexample.initialization');{$ENDIF}//write to log for the control initialization sequence
                                                                                  //пишем в лог для отслеживания последовательности инициализации модулей
                                                                                  //раньше с последовательностью были проблемы, теперь их нет
                                                                                  //и писать собственно не обязятельно, но я по привычке пишу

     {тут регистрация функций в интерфейсе зкада}
     CreateCommandFastObjectPlugin(@DrawAlignedDim_com,'DimAligned',CADWG,0);//function DrawAlignedDim_com will be available by the name of DimAligned,
                                                                             //to run requires open drawing
                                                                             //ie when typing in command line "DimAligned" executed DrawAlignedDim_com
                                                                             //функция DrawAlignedDim_com будет доступна по имени DimAligned,
                                                                             //для запуска требует наличия открытого чертежа
                                                                             //т.е. при наборе в комстроке DimAligned выполнится DrawAlignedDim_com
end.
