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
{**
@author(Andrey Zubarev <zamtmn@yandex.ru>)
}

unit uzccomexample2;
{$INCLUDE zengineconfig.inc}
interface
uses uzccommandsimpl,    //тут реализация объекта CommandRTEdObject
     uzccommandsabstract,//базовые объявления для команд
            //базовые типы
     uzccommandsmanager, //менеджер команд

     uzvcom,             //
     uzvnum,
     uzvagensl,

     uzcutils,
     Varman;             //Зкадовский RTTI

type
TExample_com=object(CommandRTEdObject)//определяем тип - объект наследник базового объекта "динамической" команды
             procedure CommandStart(const Context:TZCADCommandContext;Operands:TCommandOperands);virtual;//переопределяем метод вызываемый при старте команды
             //procedure CommandEnd; virtual;//переопределяем метод вызываемый при окончании команды
             //procedure CommandCancel; virtual;//переопределяем метод вызываемый при отмене команды

             procedure visualInspectionGraph(pdata:PtrInt); virtual;//построение графа и его визуализация
             procedure visualInspectionGroupHeadGraph(pdata:PtrInt); virtual;//построение графа и его визуализация
             procedure cablingGroupHeadGraph(pdata:PtrInt); virtual;//прокладка кабелей по трассе полученной в результате поисков пути и т.д.

             procedure DoSomething(pdata:PtrInt); virtual;//реализация какогото действия
             procedure DoSomething2(pdata:PtrInt); virtual;//реализация какогото другого действия
            end;
PTExampleComParams=^TExampleComParams;//указатель на тип данных параметров команды. зкад работает с ними через указатель
TExampleComParams=record       //определяем параметры команды которые будут видны в инспекторе во время выполнения команды
                                      //регистрировать их будем паскалевским RTTI
                                      //не через экспорт исходников и парсинг файла с определениями типов
  option3:String;
  option1:Double;
  option2:Boolean;

end;
const
  Epsilon=0.2;
var
 Example_com:TExample_com;//определяем экземпляр нашей команды
 ExampleComParams:TExampleComParams;//определяем экземпляр параметров нашей команды

 graphCable:TGraphBuilder; //созданый граф
 listHeadDevice:TListHeadDevice; //список головных устройств с подключенными к ним устройствами



implementation

procedure TExample_com.CommandStart(const Context:TZCADCommandContext;Operands:TCommandOperands);
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

procedure TExample_com.visualInspectionGraph(pdata:PtrInt);
var
 i:integer;
 UndoMarcerIsPlazed:boolean;
begin
  //тут делаем чтонибудь что будет усполнено по нажатию DoSomething2
  //выполним Commandmanager.executecommandend;
  //эту кнопку можно нажать 1 раз
  graphCable:=uzvcom.graphBulderFunc(ExampleComParams.option1,ExampleComParams.option3);

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
       //uzvcom.testTempDrawLine(graphCable.listEdge[i].VPoint1,graphCable.listEdge[i].VPoint2);
    end;
  zcPlaceUndoEndMarkerIfNeed(UndoMarcerIsPlazed);
  zcRedrawCurrentDrawing;
  //Commandmanager.executecommandend;
end;


procedure TExample_com.visualInspectionGroupHeadGraph(pdata:PtrInt);
var
 i,j,counterColor:integer;
 UndoMarcerIsPlazed:boolean;
begin
  //тут делаем чтонибудь что будет усполнено по нажатию DoSomething2
  //выполним Commandmanager.executecommandend;
  //эту кнопку можно нажать 1 раз
  graphCable:=uzvcom.graphBulderFunc(ExampleComParams.option1,ExampleComParams.option3);

  UndoMarcerIsPlazed:=false;
  zcPlaceUndoStartMarkerIfNeed(UndoMarcerIsPlazed,'Visualisation Group Line');

  listHeadDevice:=uzvnum.getGroupDeviceInGraph(graphCable,ExampleComParams.option1);

  counterColor:=1;
  for i:=0 to listHeadDevice.Size-1 do
  begin
     for j:=0 to listHeadDevice[i].listGroup.Size -1 do
        begin
             if counterColor=7 then
                  counterColor:=1;
             uzvnum.visualGroupLine(listHeadDevice,graphCable,counterColor,i,j,1);
             counterColor:=counterColor+1;
             //inc(counterColor);
        end;
  end;
  zcPlaceUndoEndMarkerIfNeed(UndoMarcerIsPlazed);
    zcRedrawCurrentDrawing;
  //Commandmanager.executecommandend;
end;

procedure TExample_com.cablingGroupHeadGraph(pdata:PtrInt);
var
 i,j,counterColor:integer;
 UndoMarcerIsPlazed:boolean;
begin
  //тут делаем чтонибудь что будет усполнено по нажатию DoSomething2
  //выполним Commandmanager.executecommandend;
  //эту кнопку можно нажать 1 раз
  graphCable:=uzvcom.graphBulderFunc(ExampleComParams.option1,ExampleComParams.option3);
  listHeadDevice:=uzvnum.getGroupDeviceInGraph(graphCable,ExampleComParams.option1);
  //Прокладка кабелей
  UndoMarcerIsPlazed:=false;
  zcPlaceUndoStartMarkerIfNeed(UndoMarcerIsPlazed,'Прокладка кабелей по трассе');
  counterColor:=1;
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


procedure TExample_com.DoSomething(pdata:PtrInt);
var
 k:integer;
begin
  //тут делаем чтонибудь что будет выполнено по нажатию DoSomething
  //если тут не вызывать Commandmanager.executecommandend;
  //то выполнение команды не завершится и кнопку можно жать много раз
  //для примера просто играем параметрами
 // inc(ExampleComParams.option1);
  k:=uzvagensl.autoGenSLBetweenDevices('победа');
  ExampleComParams.option2:=not ExampleComParams.option2;



end;

procedure TExample_com.DoSomething2(pdata:PtrInt);
begin
  //тут делаем чтонибудь что будет усполнено по нажатию DoSomething2
  //выполним Commandmanager.executecommandend;
  //эту кнопку можно нажать 1 раз
  Commandmanager.executecommandend;
end;

initialization
  //начальные значения параметров
  ExampleComParams.option1:=0.1;
  ExampleComParams.option2:=false;
  ExampleComParams.option3:='-';

  SysUnit.RegisterType(TypeInfo(PTExampleComParams));//регистрируем тип данных в зкадном RTTI
  SysUnit.SetTypeDesk(TypeInfo(TExampleComParams),['Имя суперлинии','Погрешность','Параметр2']);//Даем человечьи имена параметрам
  Example_com.init('ExampleCom',CADWG,0);//инициализируем команду
  Example_com.SetCommandParam(@ExampleComParams,'PTExampleComParams');//привязываем параметры к команде
end.
