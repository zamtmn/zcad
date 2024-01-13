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
@author(Vladimir Bobrov)
}

unit uzvagslcom;
{$INCLUDE zengineconfig.inc}
interface
uses uzccommandsimpl,    //тут реализация объекта CommandRTEdObject
     uzccommandsabstract,//базовые объявления для команд
            //базовые типы
     uzccommandsmanager, //менеджер команд
       uzeentpolyline,
       uzcinterface,
       sysutils,
     uzegeometrytypes,
     uzegeometry,
     //uzvcom,             //
     //uzvnum,
     //uzvagensl,


     //UGDBSelectedObjArray,

     //uzcutils,
     Varman;             //Зкадовский RTTI

type
Tuzvagsl_com=object(CommandRTEdObject)//определяем тип - объект наследник базового объекта "динамической" команды
             procedure CommandStart(const Context:TZCADCommandContext;Operands:TCommandOperands);virtual;//переопределяем метод вызываемый при старте команды
             //procedure CommandEnd; virtual;//переопределяем метод вызываемый при окончании команды
             //procedure CommandCancel; virtual;//переопределяем метод вызываемый при отмене команды

             procedure generatorSLinRooms(pdata:PtrInt); virtual;//построение графа и его визуализация
             //procedure visualInspectionGroupHeadGraph(pdata:PtrInt); virtual;//построение графа и его визуализация
             //procedure cablingGroupHeadGraph(pdata:PtrInt); virtual;//прокладка кабелей по трассе полученной в результате поисков пути и т.д.

             //procedure DoSomething(pdata:PtrInt); virtual;//реализация какогото действия
             //procedure DoSomething2(pdata:PtrInt); virtual;//реализация какогото другого действия
            end;

//PTTypeNumbering=^TTypeNumbering;
//TTypeNumbering=packed record
//                         pu:PTUnit;                //рантайм юнит с параметрами суперлинии
//                         LayerNamePrefix:String;//префикс
//                         ProcessLayer:Boolean;  //выключатель
//                     end;
PTuzvagslComParams=^TuzvagslComParams;//указатель на тип данных параметров команды. зкад работает с ними через указатель
TuzvagslComParams=record       //определяем параметры команды которые будут видны в инспекторе во время выполнения команды
                                      //регистрировать их будем паскалевским RTTI
                                      //не через экспорт исходников и парсинг файла с определениями типов
  //InverseX:Boolean;
  //InverseY:Boolean;
  BaseName:String;
  DeadDand:Double;
  NumberVar:String;
  option2:Boolean;

end;


const
  Epsilon=0.2;
var
 uzvagsl_com:Tuzvagsl_com;//определяем экземпляр нашей команды
 uzvagslComParams:TuzvagslComParams;//определяем экземпляр параметров нашей команды

 //graphCable:TGraphBuilder; //созданый граф
 //listHeadDevice:TListHeadDevice; //список головных устройств с подключенными к ним устройствами



implementation
uses
      uzvagsl;
procedure Tuzvagsl_com.CommandStart(const Context:TZCADCommandContext;Operands:TCommandOperands);
begin
  //создаем командное меню из 3х пунктов
  commandmanager.DMAddMethod('Пронумеровать','Временная пронумеровка извещателей',generatorSLinRooms);
  //commandmanager.DMAddMethod('Создать граф и визуал. шлейфы подключения','Создать граф и визуал. шлейфы подключения',visualInspectionGroupHeadGraph);
  //commandmanager.DMAddMethod('Прокладка кабелей по группам','Прокладка кабелей по группам',cablingGroupHeadGraph);
  //commandmanager.DMAddMethod('DoSomething1','DoSomething1 hint',DoSomething);
  //commandmanager.DMAddMethod('DoSomething2','DoSomething2 hint)',DoSomething2);
  //показываем командное меню
  commandmanager.DMShow;
  //не забываем вызвать метод родителя, там еще много что должно выполниться
  inherited CommandStart(context,'');
end;

procedure Tuzvagsl_com.generatorSLinRooms(pdata:PtrInt);
var
 contourRoom:PGDBObjPolyLine;
 //listDeviceinRoom:TListVertexDevice;
 //contourRoomEmbedSL:TListVertex;
 stPoint:gdbvertex;
begin
  stPoint:=uzegeometry.CreateVertex(0,0,0);
  //if commandmanager.get3dpoint('Specify insert point:',stPoint)= GRNormal then
  //     ZCMsgCallBackInterface.TextMessage('координата введена',TMWOHistoryOut)
  //   else
  //     ZCMsgCallBackInterface.TextMessage('координаты НЕТ',TMWOHistoryOut);

   if uzvagsl.getContourRoom(contourRoom) then                  // получить контур помещения
      if uzvagsl.isRectangelRoom(contourRoom) then begin        //это прямоугольная комната?
         ZCMsgCallBackInterface.TextMessage('проверки пройдены',TMWOHistoryOut);
         // if mainElementAutoEmbedSL(contourRoom,contourRoomEmbedSL) then  begin
         //  listDeviceinRoom:=uzvagsl.getListDeviceinRoom(contourRoom);  //получен список извещателей внутри помещения
         //  ZCMsgCallBackInterface.TextMessage('Количество выделяных извещателей = ' + inttostr(listDeviceinRoom.Size));
         //end;
         //uzvagsl.autoNumberDevice(uzvagslComParams);
   end;
   Commandmanager.executecommandend;

end;


//procedure Tuzvagsl_com.visualInspectionGroupHeadGraph(pdata:PtrInt);
//var
// i,j,counterColor:integer;
// UndoMarcerIsPlazed:boolean;
//begin
//  //тут делаем чтонибудь что будет усполнено по нажатию DoSomething2
//  //выполним Commandmanager.executecommandend;
//  //эту кнопку можно нажать 1 раз
//  graphCable:=uzvcom.graphBulderFunc(uzvagslComParams.option1,uzvagslComParams.option3);
//
//  UndoMarcerIsPlazed:=false;
//  zcPlaceUndoStartMarkerIfNeed(UndoMarcerIsPlazed,'Visualisation Group Line');
//
//  listHeadDevice:=uzvnum.getGroupDeviceInGraph(graphCable,uzvagslComParams.option1);
//
//  counterColor:=1;
//  for i:=0 to listHeadDevice.Size-1 do
//  begin
//     for j:=0 to listHeadDevice[i].listGroup.Size -1 do
//        begin
//             if counterColor=7 then
//                  counterColor:=1;
//             uzvnum.visualGroupLine(listHeadDevice,graphCable,counterColor,i,j);
//             counterColor:=counterColor+1;
//             //inc(counterColor);
//        end;
//  end;
//  zcPlaceUndoEndMarkerIfNeed(UndoMarcerIsPlazed);
//    zcRedrawCurrentDrawing;
//  //Commandmanager.executecommandend;
//end;
//
//procedure Tuzvagsl_com.cablingGroupHeadGraph(pdata:PtrInt);
//var
// i,j,counterColor:integer;
// UndoMarcerIsPlazed:boolean;
//begin
//  //тут делаем чтонибудь что будет усполнено по нажатию DoSomething2
//  //выполним Commandmanager.executecommandend;
//  //эту кнопку можно нажать 1 раз
//  graphCable:=uzvcom.graphBulderFunc(uzvagslComParams.option1,uzvagslComParams.option3);
//  listHeadDevice:=uzvnum.getGroupDeviceInGraph(graphCable,uzvagslComParams.option1);
//  //Прокладка кабелей
//  UndoMarcerIsPlazed:=false;
//  zcPlaceUndoStartMarkerIfNeed(UndoMarcerIsPlazed,'Прокладка кабелей по трассе');
//  counterColor:=1;
//  for i:=0 to listHeadDevice.Size-1 do
//  begin
//     for j:=0 to listHeadDevice[i].listGroup.Size -1 do
//        begin
//             uzvnum.cablingGroupLine(listHeadDevice,graphCable,i,j);
//        end;
//  end;
//    zcPlaceUndoEndMarkerIfNeed(UndoMarcerIsPlazed);
//   // Commandmanager.executecommandend;
//end;
//
//
//procedure Tuzvagsl_com.DoSomething(pdata:PtrInt);
//var
// k:integer;
//begin
//  //тут делаем чтонибудь что будет выполнено по нажатию DoSomething
//  //если тут не вызывать Commandmanager.executecommandend;
//  //то выполнение команды не завершится и кнопку можно жать много раз
//  //для примера просто играем параметрами
// // inc(ExampleComParams.option1);
//  k:=uzvagensl.autoGenSLBetweenDevices('победа');
//  uzvagslComParams.option2:=not uzvagslComParams.option2;
//
//
//
//end;
//
//procedure Tuzvagsl_com.DoSomething2(pdata:PtrInt);
//begin
//  //тут делаем чтонибудь что будет усполнено по нажатию DoSomething2
//  //выполним Commandmanager.executecommandend;
//  //эту кнопку можно нажать 1 раз
//  Commandmanager.executecommandend;
//end;

initialization
  //начальные значения параметров
  //uzvagslComParams.InverseX:=false;
  //uzvagslComParams.InverseY:=true;
  uzvagslComParams.BaseName:='BTH';
  uzvagslComParams.DeadDand:=10;
  uzvagslComParams.NumberVar:='GC_NumberInGroup';
  uzvagslComParams.option2:=false;


  SysUnit.RegisterType(TypeInfo(PTuzvagslComParams));//регистрируем тип данных в зкадном RTTI
  SysUnit.SetTypeDesk(TypeInfo(TuzvagslComParams),['Имя суперлинии','Погрешность','Параметр2']);//Даем человечьи имена параметрам
  uzvagsl_com.init('AGSLROOM',CADWG,0);//инициализируем команду
  uzvagsl_com.SetCommandParam(@uzvagslComParams,'PTuzvagslComParams');//привязываем параметры к команде
end.
