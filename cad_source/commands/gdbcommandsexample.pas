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
{$INCLUDE def.inc}{файл def.inc необходимо включать в начале каждого модуля zcad}
                  {он содержит в себе централизованные настройки параметров компиляции}

interface
uses
  {подключеные модули, список будет меняться в зависимости от требуемых примитивов и действий с ними}
  gdbaligneddimension,//модуль описывающий выровненный размерный примитив
  GDBLine,            //модуль описывающий примитив линия
  gdbentityfactory,   //модуль описывающий "фабрику" для создания примитивов
  zcadsysvars,        //системные переменные
  gdbase,gdbasetypes, //описания базовых типов
  gdbobjectsconstdef, //описания базовых констант
  commandline,commandlinedef,commanddefinternal, //описания менеджера команд и объектов связанных с ним
  UGDBDescriptor,     //"Менеджер" чертежей
  GDBManager,         //разные функции упрощающие создание примитивов, пока их там очень мало
  log;                //система логирования

implementation

procedure InteractiveLineManipulator(const PInteractiveData:GDBPointer;Point:GDBVertex;Click:GDBBoolean);
begin
     PGDBObjLine(PInteractiveData)^.CoordInOCS.lEnd:=Point;//устанавливаем новую точку конца линии
     GDBObjSetEntityProp(PGDBObjLine(PInteractiveData),//присваиваем пимитиву общие свойства из системных переменных
                         sysvar.dwg.DWG_CLayer^, //слой
                         sysvar.dwg.DWG_CLType^, //типлиний
                         sysvar.dwg.DWG_CColor^, //цвет
                         sysvar.dwg.DWG_CLinew^);//веслиний
     PGDBObjLine(PInteractiveData)^.FormatEntity(gdb.GetCurrentDWG^);//"форматируем" примитив в соответствии с заданными параметрами
end;

function Getpoint_com(Operands:pansichar):GDBInteger;
var
   p1,p2:gdbvertex;
   pline:PGDBObjLine;//указатель на создаваемый примитив
   savemode:GDBByte;
   point:boolean;
begin
    savemode:=GDB.GetCurrentDWG.OGLwindow1.param.md.mode;
    GDB.GetCurrentDWG.OGLwindow1.param.md.mode:=(savemode or MGet3DPoint or MGet3DPointWoOP)and(not MGetSelectionFrame)and(not MGetSelectObject);
    repeat
    point:=commandmanager.get3dpoint('Specify point:',p1);
    if point then
    begin
         pline := GDBPointer(gdb.GetCurrentDWG^.ConstructObjRoot.ObjArray.CreateInitObj(GDBLineID,gdb.GetCurrentROOT));//выделяем вамять под примитив
         GDBObjSetEntityProp(pline,                  //присваиваем пимитиву общие свойства из системных переменных
                             sysvar.dwg.DWG_CLayer^, //слой
                             sysvar.dwg.DWG_CLType^, //типлиний
                             sysvar.dwg.DWG_CColor^, //цвет
                             sysvar.dwg.DWG_CLinew^);//веслиний
         pline^.CoordInOCS.lBegin:=p1;
         pline^.CoordInOCS.lEnd:=p1;
         pline^.FormatEntity(gdb.GetCurrentDWG^);
         point:=commandmanager.Get3DPointInteractive('Specify point:',p2,@InteractiveLineManipulator,pline);
    end;
    until not point;
    result:=cmd_ok;
    GDB.GetCurrentDWG.OGLwindow1.param.md.mode:=savemode;
end;

procedure InteractiveADimManipulator(const PInteractiveData:GDBPointer;Point:GDBVertex;Click:GDBBoolean);
begin
    GDBObjSetEntityProp(PGDBObjAlignedDimension(PInteractiveData),//присваиваем пимитиву общие свойства из системных переменных
                        sysvar.dwg.DWG_CLayer^, //слой
                        sysvar.dwg.DWG_CLType^, //типлиний
                        sysvar.dwg.DWG_CColor^, //цвет
                        sysvar.dwg.DWG_CLinew^);//веслиний
    PGDBObjAlignedDimension(PInteractiveData)^.PDimStyle:=gdb.GetCurrentDWG^.DimStyleTable.getelement(0);//указываем стиль размеров (пока нет такой системной переменной)

    PGDBObjAlignedDimension(PInteractiveData)^.DimData.P10InWCS:=Point;//присваиваем полученые точки в соответствующие места примитиву
    PGDBObjAlignedDimension(PInteractiveData)^.CalcDNVectors;                        //перерасчитываем p3 - она должна лежать на нормали выпущеной из p2
    PGDBObjAlignedDimension(PInteractiveData)^.DimData.P10InWCS:=PGDBObjAlignedDimension(PInteractiveData)^.P10ChangeTo(Point);//перерасчитываем p3 - она должна лежать на нормали выпущеной из p2

    PGDBObjAlignedDimension(PInteractiveData)^.FormatEntity(gdb.GetCurrentDWG^);//примитив строит сам себя, с учетом настроек выше
end;

{"командная" функция, все они должны иметь описание function name(operands:pansichar):GDBInteger;}
{после соответствующей регистрации она будет доступна из интерфейса программ}
function DrawAlignedDim_com(operands:pansichar):GDBInteger;//данная примерная функция просит пользователя указать 3 точки и строит на основе них выровненный размер
var
    pd:PGDBObjAlignedDimension;//указатель на создаваемый примитив
    pline:PGDBObjLine;//указатель на "временную" линию
    p1,p2,p3:gdbvertex;//3 точки которые будут получены от пользователя
    savemode:GDBByte;//переменная для сохранения текущего режима редактора
begin
    savemode:=GDB.GetCurrentDWG^.DefMouseEditorMode(MGet3DPoint or MGet3DPointWoOP,         //устанавливаем режим указания точек мышью
                                                    MGetSelectionFrame or MGetSelectObject);//сбрасываем режим выбора примитивов мышью
    if commandmanager.get3dpoint('Specify first point:',p1) then    //пытаемся получить от пользователя первую точку
    begin
         pline := GDBPointer(gdb.GetCurrentDWG^.ConstructObjRoot.ObjArray.CreateInitObj(GDBLineID,gdb.GetCurrentROOT));//выделяем вамять под примитив
         pline^.CoordInOCS.lBegin:=p1;
         InteractiveLineManipulator(pline,p1,false);
      if commandmanager.Get3DPointInteractive('Specify second point:',p2,@InteractiveLineManipulator,pline) then  //если первая получена, пытаемся получить от пользователя вторую точку
      begin
           gdb.GetCurrentDWG.FreeConstructionObjects;
           pd := GDBPointer(gdb.GetCurrentDWG^.ConstructObjRoot.ObjArray.CreateInitObj(GDBAlignedDimensionID,gdb.GetCurrentROOT));//выделяем вамять под примитив
           pd^.DimData.P13InWCS:=p1;//присваиваем полученые точки в соответствующие места примитиву
           pd^.DimData.P14InWCS:=p2;//присваиваем полученые точки в соответствующие места примитиву
           InteractiveADimManipulator(pd,p2,false);
        if commandmanager.Get3DPointInteractive('Specify third point:',p3,@InteractiveADimManipulator,pd) then//если вторая получена, пытаемся получить от пользователя третью точку
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
      end;
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
     CreateCommandFastObjectPlugin(@Getpoint_com,'TestGetPoint',CADWG,0);
end.
