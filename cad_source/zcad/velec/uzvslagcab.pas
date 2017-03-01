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
{**
@author(Andrey Zubarev <zamtmn@yandex.ru>)
}

unit uzvslagcab;
{$INCLUDE def.inc}
interface
uses uzccommandsimpl,    //тут реализация объекта CommandRTEdObject
     uzccommandsabstract,//базовые объявления для команд
     uzbtypesbase,       //базовые типы
     uzccommandsmanager, //менеджер команд

     uzvcom,             //
     uzvnum,
     uzvagensl,

     uzcutils,
     Varman;             //Зкадовский RTTI

type
Tuzvslagcab_com=object(CommandRTEdObject)//определяем тип - объект наследник базового объекта "динамической" команды
             procedure CommandStart(Operands:TCommandOperands);virtual;//переопределяем метод вызываемый при старте команды
             //procedure CommandEnd; virtual;//переопределяем метод вызываемый при окончании команды
             //procedure CommandCancel; virtual;//переопределяем метод вызываемый при отмене команды

             procedure visualInspectionGraph(pdata:GDBPlatformint); virtual;//построение графа и его визуализация
             procedure visualInspectionGroupHeadGraph(pdata:GDBPlatformint); virtual;//построение графа и его визуализация
             procedure cablingGroupHeadGraph(pdata:GDBPlatformint); virtual;//прокладка кабелей по трассе полученной в результате поисков пути и т.д.

             procedure DoSomething(pdata:GDBPlatformint); virtual;//реализация какогото действия
             procedure DoSomething2(pdata:GDBPlatformint); virtual;//реализация какогото другого действия
            end;
PTuzvslagcabComParams=^TuzvslagcabComParams;//указатель на тип данных параметров команды. зкад работает с ними через указатель
TuzvslagcabComParams=packed record       //определяем параметры команды которые будут видны в инспекторе во время выполнения команды
                                      //регистрировать их будем паскалевским RTTI
                                      //не через экспорт исходников и парсинг файла с определениями типов
  nameSL:gdbstring;
  accuracy:gdbdouble;
  option2:gdbboolean;

end;
const
  Epsilon=0.2;
var
 uzvslagcab_com:Tuzvslagcab_com;//определяем экземпляр нашей команды
 uzvslagcabComParams:TuzvslagcabComParams;//определяем экземпляр параметров нашей команды

 graphCable:TGraphBuilder; //созданый граф
 listHeadDevice:TListHeadDevice; //список головных устройств с подключенными к ним устройствами



implementation

procedure Tuzvslagcab_com.CommandStart(Operands:TCommandOperands);
begin
  //создаем командное меню из 3х пунктов
  commandmanager.DMAddMethod('Создать граф и визуал. его','Создает предварительный вид графа для его визуального анализа',visualInspectionGraph);
  commandmanager.DMAddMethod('Создать граф и визуал. шлейфы подключения','Создать граф и визуал. шлейфы подключения',visualInspectionGroupHeadGraph);
  commandmanager.DMAddMethod('Прокладка кабелей по группам','Прокладка кабелей по группам',cablingGroupHeadGraph);
  commandmanager.DMAddMethod('DoSomething1','DoSomething1 hint',DoSomething);
  commandmanager.DMAddMethod('DoSomething2','DoSomething2 hint)',DoSomething2);
  //показываем командное меню
  commandmanager.DMShow;
  //не забываем вызвать метод родителя, там еще много что должно выполниться
  inherited CommandStart('');
end;

procedure Tuzvslagcab_com.visualInspectionGraph(pdata:GDBPlatformint);
var
 i:integer;
 UndoMarcerIsPlazed:boolean;
begin
  //тут делаем чтонибудь что будет усполнено по нажатию DoSomething2
  //выполним Commandmanager.executecommandend;
  //эту кнопку можно нажать 1 раз
  graphCable:=uzvcom.graphBulderFunc(uzvslagcabComParams.accuracy,uzvslagcabComParams.nameSL);

  //Визуализация графа
  UndoMarcerIsPlazed:=false;
  zcPlaceUndoStartMarkerIfNeed(UndoMarcerIsPlazed,'Visualisation Graph');
  //for i:=0 to graphCable.listVertex.Size-1 do
  //  if graphCable.listVertex[i].deviceEnt <> nil then
  //    //if graphCable.listVertex[i].break then
  //    begin
  //       uzvcom.testTempDrawCircle(graphCable.listVertex[i].centerPoint,Epsilon*25);
  //    end;
  //
  for i:=0 to graphCable.listEdge.Size-1 do
    begin
       uzvcom.testTempDrawLine(graphCable.listEdge[i].VPoint1,graphCable.listEdge[i].VPoint2);
    end;
  zcPlaceUndoEndMarkerIfNeed(UndoMarcerIsPlazed);
  zcRedrawCurrentDrawing;
  //Commandmanager.executecommandend;
end;


procedure Tuzvslagcab_com.visualInspectionGroupHeadGraph(pdata:GDBPlatformint);
var
 i,j,counterColor:integer;
 UndoMarcerIsPlazed:boolean;
begin
  //тут делаем чтонибудь что будет усполнено по нажатию DoSomething2
  //выполним Commandmanager.executecommandend;
  //эту кнопку можно нажать 1 раз
  graphCable:=uzvcom.graphBulderFunc(uzvslagcabComParams.accuracy,uzvslagcabComParams.nameSL);

  UndoMarcerIsPlazed:=false;
  zcPlaceUndoStartMarkerIfNeed(UndoMarcerIsPlazed,'Visualisation Group Line');

  listHeadDevice:=uzvnum.getGroupDeviceInGraph(graphCable,uzvslagcabComParams.accuracy);

  counterColor:=1;
  for i:=0 to listHeadDevice.Size-1 do
  begin
     for j:=0 to listHeadDevice[i].listGroup.Size -1 do
        begin
             if counterColor=4 then
                  counterColor:=1;
             uzvnum.visualGroupLine(listHeadDevice,graphCable,counterColor,i,j,uzvslagcabComParams.accuracy);
             counterColor:=counterColor+1;
             //inc(counterColor);
        end;
  end;
  zcPlaceUndoEndMarkerIfNeed(UndoMarcerIsPlazed);
    zcRedrawCurrentDrawing;
  //Commandmanager.executecommandend;
end;

procedure Tuzvslagcab_com.cablingGroupHeadGraph(pdata:GDBPlatformint);
var
 i,j:integer;
 UndoMarcerIsPlazed:boolean;
begin
  //тут делаем чтонибудь что будет усполнено по нажатию DoSomething2
  //выполним Commandmanager.executecommandend;
  //эту кнопку можно нажать 1 раз
  graphCable:=uzvcom.graphBulderFunc(uzvslagcabComParams.accuracy,uzvslagcabComParams.nameSL);

  UndoMarcerIsPlazed:=false;
  zcPlaceUndoStartMarkerIfNeed(UndoMarcerIsPlazed,'AutoCabeling SuperLine Method');

  listHeadDevice:=uzvnum.getGroupDeviceInGraph(graphCable,uzvslagcabComParams.accuracy);
  //Прокладка кабелей
  for i:=0 to listHeadDevice.Size-1 do
  begin
     for j:=0 to listHeadDevice[i].listGroup.Size -1 do
        begin
             uzvnum.cablingGroupLine(listHeadDevice,graphCable,i,j);
        end;
  end;
    zcPlaceUndoEndMarkerIfNeed(UndoMarcerIsPlazed);
   // Commandmanager.executecommandend;
end;


procedure Tuzvslagcab_com.DoSomething(pdata:GDBPlatformint);
var
 k:integer;
begin
  //тут делаем чтонибудь что будет выполнено по нажатию DoSomething
  //если тут не вызывать Commandmanager.executecommandend;
  //то выполнение команды не завершится и кнопку можно жать много раз
  //для примера просто играем параметрами
 // inc(ExampleComParams.option1);
  k:=uzvagensl.autoGenSLBetweenDevices('победа');
    Commandmanager.executecommandend;



end;

procedure Tuzvslagcab_com.DoSomething2(pdata:GDBPlatformint);
begin
  //тут делаем чтонибудь что будет усполнено по нажатию DoSomething2
  //выполним Commandmanager.executecommandend;
  //эту кнопку можно нажать 1 раз
  Commandmanager.executecommandend;
end;

initialization
  //начальные значения параметров
  uzvslagcabComParams.nameSL:='-';
  uzvslagcabComParams.accuracy:=0.3;
  uzvslagcabComParams.option2:=false;


  SysUnit.RegisterType(TypeInfo(PTuzvslagcabComParams));//регистрируем тип данных в зкадном RTTI
  SysUnit.SetTypeDesk(TypeInfo(TuzvslagcabComParams),['Имя суперлинии','Погрешность','Параметр2']);//Даем человечьи имена параметрам
  uzvslagcab_com.init('slagcab',CADWG,0);//инициализируем команду
  uzvslagcab_com.SetCommandParam(@uzvslagcabComParams,'PTuzvslagcabComParams');//привязываем параметры к команде
end.
