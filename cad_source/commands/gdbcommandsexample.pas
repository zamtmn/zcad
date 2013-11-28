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
{$INCLUDE def.inc}

interface
uses
  {подключеные модули, список будет меняться в зависимости от требуемых примитивов и действий с ними}
  gdbaligneddimension,//модуль описывающий выровненный размерный примитив
  gdbentityfactory,   //модуль описывающий "фабрику" для создания примитивов
  zcadsysvars,        //системные переменные
  gdbase,gdbasetypes, //описания базовых типов
  gdbobjectsconstdef, //описания базовых констант
  commandline,commandlinedef,commanddefinternal, //описания менеджера команд и объектов связанных с ним
  UGDBDescriptor,     //"Менеджер" чертежей
  GDBManager,         //разные функции упрощающие создание примитивов, пока их там очень мало
  log;                //система логирования

implementation

{"командная" функция, все они должны иметь описание function name(operands:pansichar):GDBInteger;}
{после соответствующей регистрации она будет доступна из интерфейса программ}
function DrawAlignedDim_com(operands:pansichar):GDBInteger;//данная примерная функция просит пользователя указать 3 точки и строит на основе них выровненный размер
var
    pd:PGDBObjAlignedDimension;//указатель на создаваемый примитив
    p1,p2,p3:gdbvertex;//3 точки которые будут получены от пользователя
    savemode:GDBByte;//переменная для сохранения текущего режима редактора
begin
    savemode:=GDB.GetCurrentDWG^.DefMouseEditorMode(MGet3DPoint or MGet3DPointWoOP,         //устанавливаем режим указания точек мышью
                                                    MGetSelectionFrame or MGetSelectObject);//сбрасываем режим выбора примитивов мышью
    if commandmanager.get3dpoint(p1) then    //пытаемся получить от пользователя первую точку
      if commandmanager.get3dpoint(p2) then  //если первая получена, пытаемся получить от пользователя вторую точку
        if commandmanager.get3dpoint(p3) then//если вторая получена, пытаемся получить от пользователя третью точку
          begin                              //если все 3 точки получены - строим примитив
               pd := CreateObjFree(GDBAlignedDimensionID);//выделяем вамять под примитив
               pd^.initnul(gdb.GetCurrentROOT);//инициализируем примитив, указываем его владельца
               GDBObjSetEntityProp(pd,                     //присваиваем пимитиву общие свойства из системных переменных
                                   sysvar.dwg.DWG_CLayer^, //слой
                                   sysvar.dwg.DWG_CLType^, //типлиний
                                   sysvar.dwg.DWG_CColor^, //цвет
                                   sysvar.dwg.DWG_CLinew^);//веслиний

               {тут в зависимости от примитива, настройка примитива согласно полученных точек}
               pd^.PDimStyle:=gdb.GetCurrentDWG^.DimStyleTable.getelement(0);//указываем стиль размеров (пока нет такой системной переменной)
                                                                             //присваевается нулевой размерный стиль из таблицы описаний, т.е. 'Standart'
               pd^.DimData.P13InWCS:=p1;//присваиваем полученые точки в соответствующие места примитиву
               pd^.DimData.P14InWCS:=p2;//присваиваем полученые точки в соответствующие места примитиву
               pd^.DimData.P10InWCS:=p3;//присваиваем полученые точки в соответствующие места примитиву

               pd^.CalcDNVectors;                        //перерасчитываем p3 - она должна лежать на нормали выпущеной из p2
               pd^.DimData.P10InWCS:=pd^.P10ChangeTo(p3);//перерасчитываем p3 - она должна лежать на нормали выпущеной из p2
               {конец настройки зависимой от создаваемого примитива}

               pd^.FormatEntity(gdb.GetCurrentDWG^);//примитив строит сам себя, с учетом настроек выше

               gdb.AddEntToCurrentDrawingWithUndo(pd);//Добавляем примитив в чертеж с учетом обвязки для undo-redo
          end;
    result:=cmd_ok;//команда завершилась, говорим что всё заебись
    GDB.GetCurrentDWG^.SetMouseEditorMode(savemode);//восстанавливаем сохраненный режим редактора
end;
initialization
     {$IFDEF DEBUGINITSECTION}LogOut('gdbcommandsexample.initialization');{$ENDIF}//пишем в лог для отслеживания последовательности инициализации модулей
                                                                                  //раньше с последовательностью были проблемы, теперь их нет
                                                                                  //и писать собственно не обязятельно, но я по привычке пишу

     {тут регистрация функций в интерфейсе зкада}
     CreateCommandFastObjectPlugin(@DrawAlignedDim_com,'DimAligned',CADWG,0);//функция DrawAlignedDim_com будет доступна по имени DimAligned,
                                                                             //для запуска требует наличия открытого чертежа
                                                                             //т.е. при наборе в комстроке DimAligned выполнится DrawAlignedDim_com
end.
