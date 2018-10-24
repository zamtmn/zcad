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
uses
     sysutils,

     uzccommandsimpl,    //тут реализация объекта CommandRTEdObject
     uzccommandsabstract,//базовые объявления для команд
     uzbtypesbase,       //базовые типы
     uzccommandsmanager, //менеджер команд

     uzvcom,             //
     uzvnum,
     uzvtreedevice,      //новая механизм кабеле прокладки на основе Дерева
     uzvtmasterdev,
     uzvagensl,
     uzvtestdraw, // тестовые рисунки

     uzcinterface,
     uzctnrvectorgdbstring,
     uzbgeomtypes,
     uzegeometry,

     typinfo,
     gzctnrvector,
     uzvconsts,
     uzcutils,
     Varman;             //Зкадовский RTTI

type
Tuzvslagcab_com=object(CommandRTEdObject)//определяем тип - объект наследник базового объекта "динамической" команды
             procedure CommandStart(Operands:TCommandOperands);virtual;//переопределяем метод вызываемый при старте команды
             //procedure CommandEnd; virtual;//переопределяем метод вызываемый при окончании команды
             //procedure CommandCancel; virtual;//переопределяем метод вызываемый при отмене команды

             //+++++//
             procedure visualGlobalGraph(pdata:GDBPlatformint); virtual;//построение графа и его визуализация

             procedure visualGlobalGraphAll(pdata:GDBPlatformint); virtual;//построение всех графов и его визуализация
             procedure visualInspectionGroupHeadGraph(pdata:GDBPlatformint); virtual;//построение графа и его визуализация
             procedure searchErrorsALL(pdata:GDBPlatformint); virtual;//Проверка всех устройств на всех трассах
             procedure cablingGroupHeadGraph(pdata:GDBPlatformint); virtual;//прокладка кабелей по трассе полученной в результате поисков пути и т.д.
             //procedure cablingGraphALL(pdata:GDBPlatformint); virtual;//ВСЕ трассы.прокладка кабелей по трассе полученной в результате поисков пути и т.д.
             procedure test(pdata:GDBPlatformint); virtual;//прокладка кабелей по трассе полученной в результате поисков пути и т.д.

             //+++++//
             procedure visualGraphDevice(pdata:GDBPlatformint); virtual;//построение всех графов и его визуализация

             procedure cablingGraphDevice(pdata:GDBPlatformint); virtual;//построение всех графов и его визуализация

             procedure visualGraphDeviceAll(pdata:GDBPlatformint); virtual;//построение графа и его визуализация
             procedure cablingTreeDeviceOne(pdata:GDBPlatformint); virtual;//Проверка всех устройств на всех трассах
             procedure cablingTreeDeviceAll(pdata:GDBPlatformint); virtual;//прокладка кабелей по трассе полученной в результате поисков пути и т.д.

             //procedure DoSomething(pdata:GDBPlatformint); virtual;//реализация какогото действия
             //procedure DoSomething2(pdata:GDBPlatformint); virtual;//реализация какогото другого действия
            end;
PTuzvslagcabComParams=^TuzvslagcabComParams;//указатель на тип данных параметров команды. зкад работает с ними через указатель

TsettingVizCab=packed record
  sErrors:gdbboolean;
  vizNumMetric:gdbboolean;
  vizFullTreeCab:gdbboolean;
  vizEasyTreeCab:gdbboolean;
end;

TuzvslagcabComParams=packed record       //определяем параметры команды которые будут видны в инспекторе во время выполнения команды
                                      //регистрировать их будем паскалевским RTTI
                                      //не через экспорт исходников и парсинг файла с определениями типов
  NamesList:TEnumData;//это тип для отображения списков в инспекторе
  //nameSL:gdbstring;
  accuracy:gdbdouble;
  metricDev:gdbboolean;
  settingVizCab:TsettingVizCab;

end;
const
  Epsilon=0.2;

var
 uzvslagcab_com:Tuzvslagcab_com;//определяем экземпляр нашей команды
 uzvslagcabComParams:TuzvslagcabComParams;//определяем экземпляр параметров нашей команды

 graphCable:TGraphBuilder;        //созданый граф
 listHeadDevice:TListHeadDevice;  //список головных устройств с подключенными к ним устройствами
 listAllGraph:TListAllGraph;      //список графов




implementation

procedure Tuzvslagcab_com.CommandStart(Operands:TCommandOperands);
var
 listSLname:TGDBlistSLname;
 nameSL:string;
begin
  //создаем командное меню из 3х пунктов
  commandmanager.DMAddMethod('Визуализировать трассу','Позволяет просмотреть трассу, места пересечения и места подключения',visualGlobalGraph);

  commandmanager.DMAddMethod('ывфывфывфыв фывфывфы','Создает предварительный виды графов для его визуального анализа',visualGlobalGraphAll);
  commandmanager.DMAddMethod('ОДНА трасса. Проверка устройств','ЧАСТИЧНАЯ проверка устройств для одной трассы + визуал. шлейфов подключения',visualInspectionGroupHeadGraph);
  commandmanager.DMAddMethod('ВСЕ трассы. Проверка устройств','ПОЛНАЯ проверка устройств всех трасс + визуал. шлейфов подключения',searchErrorsALL);
  commandmanager.DMAddMethod('ОДИН. Прокладка кабелей','Прокладка кабелей по группам',cablingGroupHeadGraph);
  //commandmanager.DMAddMethod('ВСЕ. Прокладка кабеля','Прокладка кабелей по группам на всех трассах',cablingGraphALL);
  commandmanager.DMAddMethod('test','Проtest',test);

  commandmanager.DMAddMethod('Визуализировать кабели','Визуализирует прохождения кабелей по трассам',visualGraphDevice);

  commandmanager.DMAddMethod('Проложить кабели','Проложить кабели по трассам',cablingGraphDevice);

  commandmanager.DMAddMethod('ВСЕ трассы. Проверка устройств','ПОЛНАЯ проверка устройств всех трасс + визуал. шлейфов подключения',visualGraphDeviceAll);
  commandmanager.DMAddMethod('ОДИН. Прокладка кабелей','Прокладка кабелей по группам',cablingTreeDeviceOne);
  commandmanager.DMAddMethod('ВСЕ. Прокладка кабелей','Прокладка всех кабельных трасс по группам',cablingTreeDeviceAll);


  //commandmanager.DMAddMethod('DoSomething1','DoSomething1 hint',DoSomething);
  //commandmanager.DMAddMethod('DoSomething2','DoSomething2 hint)',DoSomething2);

  ///***заполняем поле имени суперлинии
  uzvslagcabComParams.NamesList.Enums.Clear;

  uzvslagcabComParams.NamesList.Enums.PushBackData(vItemAllSLInspector);// добавляем "***"
  listSLname:=TGDBlistSLname.Create;
  uzvcom.getListSuperline(listSLname);
  for nameSL in listSLname do
     uzvslagcabComParams.NamesList.Enums.PushBackData(nameSL);//заполняем

  //показываем командное меню
  commandmanager.DMShow;


  //не забываем вызвать метод родителя, там еще много что должно выполниться
  inherited CommandStart('');
end;

procedure Tuzvslagcab_com.visualGlobalGraph(pdata:GDBPlatformint);
var
 i,m,counterColor:integer;
 UndoMarcerIsPlazed:boolean;
 nameSL:string;
 listSLname:TGDBlistSLname;
 graphBuilderInfo:TListGraphBuilder;
 isVisualVertex:boolean;
begin

  listAllGraph:=TListAllGraph.Create;

  //Получаем имя суперлинии выбраное в меню
  nameSL:=pstring(uzvslagcabComParams.NamesList.Enums.getDataMutable(integer(uzvslagcabComParams.NamesList.selected)))^;

  listSLname:=TGDBlistSLname.Create;
  if nameSL = vItemAllSLInspector then
        uzvcom.getListSuperline(listSLname) // Создаем список всех суперлиний
  else
        listSLname.PushBack(nameSL);        // Создаем список из одной суперлинии

  //Строим граф зная имя суперлиний
  for nameSL in listSLname do
   begin
     graphBuilderInfo.graph:=uzvcom.graphBulderFunc(uzvslagcabComParams.accuracy,nameSL);
     graphBuilderInfo.nameSuperLine:=nameSL;
     listAllGraph.PushBack(graphBuilderInfo);
   end;

  //Визуализация графа
  UndoMarcerIsPlazed:=false;
  zcPlaceUndoStartMarkerIfNeed(UndoMarcerIsPlazed,'Visualisation Graph');

  counterColor:=1;
  isVisualVertex:=true;
      for graphBuilderInfo in listAllGraph do
       begin
         //Строим граф зная имя суперлиний
          if counterColor=6 then
             counterColor:=1;
          for i:=0 to graphBuilderInfo.graph.listEdge.Size-1 do
            uzvcom.visualGraphEdge(graphBuilderInfo.graph.listEdge[i].VPoint1,graphBuilderInfo.graph.listEdge[i].VPoint2,counterColor,vSystemVisualLayerName);

          if isVisualVertex then begin
            for i:=0 to graphBuilderInfo.graph.listVertex.Size-1 do
              begin
                 m:=counterColor;
                 if graphBuilderInfo.graph.listVertex[i].deviceEnt <> nil then m:=6;
                 uzvcom.visualGraphVertex(graphBuilderInfo.graph.listVertex[i].centerPoint,1,m,vSystemVisualLayerName);
              end;
              isVisualVertex:=false;
          end;
          inc(counterColor);
       end;


  zcPlaceUndoEndMarkerIfNeed(UndoMarcerIsPlazed);
  listAllGraph.Destroy;
  zcRedrawCurrentDrawing;
  Commandmanager.executecommandend;
end;


procedure Tuzvslagcab_com.visualGraphDevice(pdata:GDBPlatformint);
var
 i,j,counterColor:integer;
 UndoMarcerIsPlazed:boolean;
 nameSL:string;
 listError:TListError;
 errorInfo:TErrorInfo;
 listSLname:TGDBlistSLname;
 listAllSLname:TGDBlistSLname;
 pConnect,fTreeVertex,eTreeVertex:GDBVertex;
 graphBuilderInfo:TListGraphBuilder;

 listMasterDevice:TVectorOfMasterDevice;
begin

  //создаем список ошибок
  listError:=TListError.Create;
  listAllGraph:=TListAllGraph.Create;

  //listAllGraph:=TListAllGraph.Create;
  //listSLname:=TGDBlistSLname.Create;
  // uzvcom.getListSuperline(listSLname);

  //
  //получаем выбраное имя суперлинии
  //nameSL:=pstring(uzvslagcabComParams.NamesList.Enums.getDataMutable(integer(uzvslagcabComParams.NamesList.selected)))^;
  //listSLname.PushBack(nameSL);

  //строим наш граф
  //graphBuilderInfo.graph:=uzvcom.graphBulderFunc(uzvslagcabComParams.accuracy,nameSL);
  //graphBuilderInfo.nameSuperLine:=nameSL;
  //listAllGraph.PushBack(graphBuilderInfo);
  //graphCable:=uzvcom.graphBulderFunc(uzvslagcabComParams.accuracy,nameSL);

    //Получаем имя суперлинии выбраное в меню
  nameSL:=pstring(uzvslagcabComParams.NamesList.Enums.getDataMutable(integer(uzvslagcabComParams.NamesList.selected)))^;

  listSLname:=TGDBlistSLname.Create;
  listAllSLname:=TGDBlistSLname.Create;
  if nameSL = vItemAllSLInspector then begin
        uzvcom.getListSuperline(listSLname);
        uzvcom.getListSuperline(listAllSLname);
  end
  else begin
        listSLname.PushBack(nameSL);
        uzvcom.getListSuperline(listAllSLname);
  end;

  //Строим граф зная имя суперлиний
  for nameSL in listSLname do
   begin
     graphBuilderInfo.graph:=uzvcom.graphBulderFunc(uzvslagcabComParams.accuracy,nameSL);
     graphBuilderInfo.nameSuperLine:=nameSL;
     listAllGraph.PushBack(graphBuilderInfo);
   end;


  UndoMarcerIsPlazed:=false;
  zcPlaceUndoStartMarkerIfNeed(UndoMarcerIsPlazed,'Visualisation Tree Device');

  //Ищем ошибки
  //errorSearchAllParam(listAllGraph[0].graph,uzvslagcabComParams.accuracy,listError,listSLname);

  //uzvtreedevice.errorSearchList(listAllGraph[0].graph,uzvslagcabComParams.accuracy,listError,listSLname);
  uzvtreedevice.errorList(listAllGraph,uzvslagcabComParams.accuracy,listError,listSLname,listAllSLname);

  //**Визуализация ошибок и проверка ошибок
  if uzvslagcabComParams.settingVizCab.sErrors then begin
    for errorInfo in listError do
      begin
        ZCMsgCallBackInterface.TextMessage(errorInfo.name + ' - ошибка: ' + errorInfo.text,TMWOHistoryOut);
        if getPointConnector(errorInfo.device,pConnect) then
              uzvcom.visualGraphError(pConnect,4,6,vSystemVisualLayerName);
      end;
      listError.Destroy;
   end;

    if uzvslagcabComParams.settingVizCab.vizFullTreeCab then
       if commandmanager.get3dpoint('Input tree visualization coordinates',fTreeVertex) then begin
         ZCMsgCallBackInterface.TextMessage('Ok',TMWOHistoryOut);
       end
       else
         ZCMsgCallBackInterface.TextMessage('Coordinate entry canceled!!!',TMWOHistoryOut);


   if uzvslagcabComParams.settingVizCab.vizEasyTreeCab then
         if commandmanager.get3dpoint('Input easy tree visualization coordinates',eTreeVertex) then begin
           ZCMsgCallBackInterface.TextMessage('Ok',TMWOHistoryOut);
         end
         else
           ZCMsgCallBackInterface.TextMessage('Coordinate entry canceled!!!',TMWOHistoryOut);

        fTreeVertex:=uzegeometry.CreateVertex(0,0,0);
        eTreeVertex:=uzegeometry.CreateVertex(0,10000,0);
   for graphBuilderInfo in listAllGraph do
     begin
       listMasterDevice:=uzvtreedevice.buildListAllConnectDevice(graphBuilderInfo.graph,uzvslagcabComParams.accuracy,listError);

       uzvtreedevice.visualGraphConnection(graphBuilderInfo.graph,listMasterDevice,uzvslagcabComParams.settingVizCab.vizFullTreeCab,uzvslagcabComParams.settingVizCab.vizEasyTreeCab,fTreeVertex,eTreeVertex);

       uzvtreedevice.visualMasterGroupLine(graphBuilderInfo.graph,listMasterDevice,uzvslagcabComParams.metricDev,uzvslagcabComParams.accuracy*7,uzvslagcabComParams.settingVizCab.vizNumMetric);

       //uzvtreedevice.cabelingMasterGroupLine(graphBuilderInfo.graph,listMasterDevice,uzvslagcabComParams.metricDev);
     end;








  //listMasterDevice:=uzvtreedevice.buildListAllConnectDevice(graphCable,uzvslagcabComParams.accuracy,listError);
  //
  //uzvtreedevice.visualMasterGroupLine(graphCable,listMasterDevice,uzvslagcabComParams.metricDev);

  //uzvtreedevice.cabelingMasterGroupLine(graphCable,listMasterDevice,uzvslagcabComParams.metricDev);



  zcPlaceUndoEndMarkerIfNeed(UndoMarcerIsPlazed);
  zcRedrawCurrentDrawing;

  Commandmanager.executecommandend;
end;

procedure Tuzvslagcab_com.cablingGraphDevice(pdata:GDBPlatformint);
var
 i,j,counterColor:integer;
 UndoMarcerIsPlazed:boolean;
 nameSL:string;
 listError:TListError;
 errorInfo:TErrorInfo;
 listSLname:TGDBlistSLname;
 pConnect:GDBVertex;
 graphBuilderInfo:TListGraphBuilder;

 listMasterDevice:TVectorOfMasterDevice;
begin
  //тут делаем чтонибудь что будет усполнено по нажатию DoSomething2
  //выполним Commandmanager.executecommandend;
  //эту кнопку можно нажать 1 раз

  //создаем список ошибок
  listError:=TListError.Create;
  listAllGraph:=TListAllGraph.Create;

  //listAllGraph:=TListAllGraph.Create;
  //listSLname:=TGDBlistSLname.Create;
  // uzvcom.getListSuperline(listSLname);

  //
  //получаем выбраное имя суперлинии
  //nameSL:=pstring(uzvslagcabComParams.NamesList.Enums.getDataMutable(integer(uzvslagcabComParams.NamesList.selected)))^;
  //listSLname.PushBack(nameSL);

  //строим наш граф
  //graphBuilderInfo.graph:=uzvcom.graphBulderFunc(uzvslagcabComParams.accuracy,nameSL);
  //graphBuilderInfo.nameSuperLine:=nameSL;
  //listAllGraph.PushBack(graphBuilderInfo);
  //graphCable:=uzvcom.graphBulderFunc(uzvslagcabComParams.accuracy,nameSL);

    //Получаем имя суперлинии выбраное в меню
  nameSL:=pstring(uzvslagcabComParams.NamesList.Enums.getDataMutable(integer(uzvslagcabComParams.NamesList.selected)))^;

  listSLname:=TGDBlistSLname.Create;
  if nameSL = vItemAllSLInspector then
        uzvcom.getListSuperline(listSLname)
  else
        listSLname.PushBack(nameSL);

  //Строим граф зная имя суперлиний
  for nameSL in listSLname do
   begin
     graphBuilderInfo.graph:=uzvcom.graphBulderFunc(uzvslagcabComParams.accuracy,nameSL);
     graphBuilderInfo.nameSuperLine:=nameSL;
     listAllGraph.PushBack(graphBuilderInfo);
   end;


  UndoMarcerIsPlazed:=false;
  zcPlaceUndoStartMarkerIfNeed(UndoMarcerIsPlazed,'Visualisation Tree Device');

  //Ищем ошибки
  uzvtreedevice.errorSearchList(listAllGraph[0].graph,uzvslagcabComParams.accuracy,listError,listSLname);

  //**Визуализация ошибок и проверка ошибок
  if uzvslagcabComParams.settingVizCab.sErrors then begin
    for errorInfo in listError do
      begin
        ZCMsgCallBackInterface.TextMessage(errorInfo.name + ' - ошибка: ' + errorInfo.text,TMWOHistoryOut);
        if getPointConnector(errorInfo.device,pConnect) then
              uzvcom.visualGraphError(pConnect,4,6,vSystemVisualLayerName);
      end;
      listError.Destroy;
   end;


   for graphBuilderInfo in listAllGraph do
     begin
       listMasterDevice:=uzvtreedevice.buildListAllConnectDevice(graphBuilderInfo.graph,uzvslagcabComParams.accuracy,listError);

       //uzvtreedevice.visualMasterGroupLine(graphBuilderInfo.graph,listMasterDevice,uzvslagcabComParams.metricDev,uzvslagcabComParams.accuracy*7,uzvslagcabComParams.settingVizCab.vizNumMetric);

       uzvtreedevice.cabelingMasterGroupLine(graphBuilderInfo.graph,listMasterDevice,uzvslagcabComParams.metricDev);
     end;








  //listMasterDevice:=uzvtreedevice.buildListAllConnectDevice(graphCable,uzvslagcabComParams.accuracy,listError);
  //
  //uzvtreedevice.visualMasterGroupLine(graphCable,listMasterDevice,uzvslagcabComParams.metricDev);

  //uzvtreedevice.cabelingMasterGroupLine(graphCable,listMasterDevice,uzvslagcabComParams.metricDev);



  zcPlaceUndoEndMarkerIfNeed(UndoMarcerIsPlazed);
  zcRedrawCurrentDrawing;

  Commandmanager.executecommandend;
end;

procedure Tuzvslagcab_com.visualGraphDeviceAll(pdata:GDBPlatformint);
var
 i,j,counterColor:integer;
 UndoMarcerIsPlazed:boolean;
 nameSL:string;
 listError:TListError;
 errorInfo:TErrorInfo;
 listSLname:TGDBlistSLname;
 pConnect:GDBVertex;
 // nameSL:string;
 //listSLname:TGDBlistSLname;
 graphBuilderInfo:TListGraphBuilder;
begin
  //тут делаем чтонибудь что будет усполнено по нажатию DoSomething2
  //выполним Commandmanager.executecommandend;
  //эту кнопку можно нажать 1 раз

    //создаем список ошибок
  listError:=TListError.Create;

  listAllGraph:=TListAllGraph.Create;
  listSLname:=TGDBlistSLname.Create;
  uzvcom.getListSuperline(listSLname);

  UndoMarcerIsPlazed:=false;
  zcPlaceUndoStartMarkerIfNeed(UndoMarcerIsPlazed,'Visualisation Group Line');

    for nameSL in listSLname do
       begin
          //ZCMsgCallBackInterface.TextMessage('ВСЕ. Визуализация!!!'+nameSL,TMWOHistoryOut);
         //Строим граф зная имя суперлиний
         graphBuilderInfo.graph:=uzvcom.graphBulderFunc(uzvslagcabComParams.accuracy,nameSL);
         graphBuilderInfo.nameSuperLine:=nameSL;
         listAllGraph.PushBack(graphBuilderInfo);
         //graphCable:=uzvcom.graphBulderFunc(uzvslagcabComParams.accuracy,nameSL);
       end;

    errorSearchAllParam(listAllGraph[0].graph,uzvslagcabComParams.accuracy,listError,listSLname);

    for graphBuilderInfo in listAllGraph do
       begin
              //Ищем ошибки
       errorSearchSLAGCAB(graphBuilderInfo.graph,uzvslagcabComParams.accuracy,listError);

       listHeadDevice:=uzvnum.getGroupDeviceInGraph(graphBuilderInfo.graph,uzvslagcabComParams.accuracy,listError);

        counterColor:=1;
        for i:=0 to listHeadDevice.Size-1 do
        begin
           for j:=0 to listHeadDevice[i].listGroup.Size -1 do
              begin
                   if counterColor=6 then
                        counterColor:=1;
                   uzvnum.visualGroupLine(listHeadDevice,graphBuilderInfo.graph,counterColor,i,j,uzvslagcabComParams.accuracy);
                   counterColor:=counterColor+1;
                   //inc(counterColor);
              end;
        end;
    end;

  //listAllGraph:=TListAllGraph.Create;
  //listSLname:=uzvcom.getListSuperline();
  //
  ////получаем выбраное имя суперлинии
  //nameSL:=pstring(uzvslagcabComParams.NamesList.Enums.getDataMutable(integer(uzvslagcabComParams.NamesList.selected)))^;
  //
  ////строим наш граф
  //graphCable:=uzvcom.graphBulderFunc(uzvslagcabComParams.accuracy,nameSL);






  //**Визуализация ошибок
  for errorInfo in listError do
    begin
      ZCMsgCallBackInterface.TextMessage(errorInfo.name + ' - ошибка: ' + errorInfo.text,TMWOHistoryOut);
      if getPointConnector(errorInfo.device,pConnect) then
           uzvcom.visualGraphError(pConnect,4,6,vSystemVisualLayerName);

  end;
  listError.Destroy;



  zcPlaceUndoEndMarkerIfNeed(UndoMarcerIsPlazed);
  zcRedrawCurrentDrawing;

  Commandmanager.executecommandend;
end;






procedure Tuzvslagcab_com.visualGlobalGraphAll(pdata:GDBPlatformint);
var
 i,m:integer;
 UndoMarcerIsPlazed:boolean;
 nameSL:string;
 listSLname:TGDBlistSLname;
 graphBuilderInfo:TListGraphBuilder;
begin

  //ZCMsgCallBackInterface.TextMessage('ВСЕ. Визуализация!!!',TMWOHistoryOut);

  listAllGraph:=TListAllGraph.Create;
  listSLname:=TGDBlistSLname.Create;
  uzvcom.getListSuperline(listSLname);
    for nameSL in listSLname do
       begin
          //ZCMsgCallBackInterface.TextMessage('ВСЕ. Визуализация!!!'+nameSL,TMWOHistoryOut);
         //Строим граф зная имя суперлиний
         graphBuilderInfo.graph:=uzvcom.graphBulderFunc(uzvslagcabComParams.accuracy,nameSL);
         graphBuilderInfo.nameSuperLine:=nameSL;
         listAllGraph.PushBack(graphBuilderInfo);
         //graphCable:=uzvcom.graphBulderFunc(uzvslagcabComParams.accuracy,nameSL);
       end;

  //Получаем имя суперлинии выбраное в меню
  //nameSL:=pstring(uzvslagcabComParams.NamesList.Enums.getDataMutable(integer(uzvslagcabComParams.NamesList.selected)))^;

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
      for graphBuilderInfo in listAllGraph do
       begin
         //Строим граф зная имя суперлиний
         //graphBuilderInfo.graph:=uzvcom.graphBulderFunc(uzvslagcabComParams.accuracy,nameSL);
         //graphBuilderInfo.nameSuperLine:=nameSL;
         //listAllGraph.PushBack(graphBuilderInfo);
         //graphCable:=uzvcom.graphBulderFunc(uzvslagcabComParams.accuracy,nameSL);
          for i:=0 to graphBuilderInfo.graph.listEdge.Size-1 do
            begin
               uzvcom.visualGraphEdge(graphBuilderInfo.graph.listEdge[i].VPoint1,graphBuilderInfo.graph.listEdge[i].VPoint2,2,vSystemVisualLayerName);
            end;
          for i:=0 to graphBuilderInfo.graph.listVertex.Size-1 do
            begin
               m:=2;
               if graphBuilderInfo.graph.listVertex[i].deviceEnt <> nil then m:=3;
               uzvcom.visualGraphVertex(graphBuilderInfo.graph.listVertex[i].centerPoint,1,m,vSystemVisualLayerName);
            end;
       end;
  zcPlaceUndoEndMarkerIfNeed(UndoMarcerIsPlazed);
  listAllGraph.Destroy;
  zcRedrawCurrentDrawing;
  Commandmanager.executecommandend;
end;



procedure Tuzvslagcab_com.visualInspectionGroupHeadGraph(pdata:GDBPlatformint);
var
 i,j,counterColor:integer;
 UndoMarcerIsPlazed:boolean;
 nameSL:string;
 listError:TListError;
 errorInfo:TErrorInfo;
 //listSLname:TGDBlistSLname;
 pConnect:GDBVertex;
begin
  //тут делаем чтонибудь что будет усполнено по нажатию DoSomething2
  //выполним Commandmanager.executecommandend;
  //эту кнопку можно нажать 1 раз

  //создаем список ошибок
  listError:=TListError.Create;

  //listAllGraph:=TListAllGraph.Create;
  //listSLname:=uzvcom.getListSuperline();
  //
  //получаем выбраное имя суперлинии
  nameSL:=pstring(uzvslagcabComParams.NamesList.Enums.getDataMutable(integer(uzvslagcabComParams.NamesList.selected)))^;

  //строим наш граф
  graphCable:=uzvcom.graphBulderFunc(uzvslagcabComParams.accuracy,nameSL);

  //Ищем ошибки
  errorSearchSLAGCAB(graphCable,uzvslagcabComParams.accuracy,listError);


  UndoMarcerIsPlazed:=false;
  zcPlaceUndoStartMarkerIfNeed(UndoMarcerIsPlazed,'Visualisation Group Line');

  //**Визуализация ошибок
  for errorInfo in listError do
    begin
      ZCMsgCallBackInterface.TextMessage(errorInfo.name + ' - ошибка: ' + errorInfo.text,TMWOHistoryOut);
      if getPointConnector(errorInfo.device,pConnect) then
            uzvcom.visualGraphError(pConnect,4,6,vSystemVisualLayerName);
            //uzvtestdraw.testTempDrawPLCross(pConnect,12*epsilon,4);

  end;
  listError.Destroy;


  listHeadDevice:=uzvnum.getGroupDeviceInGraph(graphCable,uzvslagcabComParams.accuracy,listError);

  counterColor:=1;
  for i:=0 to listHeadDevice.Size-1 do
  begin
     for j:=0 to listHeadDevice[i].listGroup.Size -1 do
        begin
             if counterColor=6 then
                  counterColor:=1;
             uzvnum.visualGroupLine(listHeadDevice,graphCable,counterColor,i,j,uzvslagcabComParams.accuracy);
             counterColor:=counterColor+1;
             //inc(counterColor);
        end;
  end;
  zcPlaceUndoEndMarkerIfNeed(UndoMarcerIsPlazed);
  zcRedrawCurrentDrawing;

  Commandmanager.executecommandend;
end;

procedure Tuzvslagcab_com.searchErrorsALL(pdata:GDBPlatformint);
var
 i,j,counterColor:integer;
 UndoMarcerIsPlazed:boolean;
 nameSL:string;
 listError:TListError;
 errorInfo:TErrorInfo;
 listSLname:TGDBlistSLname;
 pConnect:GDBVertex;
 // nameSL:string;
 //listSLname:TGDBlistSLname;
 graphBuilderInfo:TListGraphBuilder;
begin
  //тут делаем чтонибудь что будет усполнено по нажатию DoSomething2
  //выполним Commandmanager.executecommandend;
  //эту кнопку можно нажать 1 раз

    //создаем список ошибок
  listError:=TListError.Create;

  listAllGraph:=TListAllGraph.Create;

  listSLname:=TGDBlistSLname.Create;
  uzvcom.getListSuperline(listSLname);

  UndoMarcerIsPlazed:=false;
  zcPlaceUndoStartMarkerIfNeed(UndoMarcerIsPlazed,'Visualisation Group Line');

    for nameSL in listSLname do
       begin
          //ZCMsgCallBackInterface.TextMessage('ВСЕ. Визуализация!!!'+nameSL,TMWOHistoryOut);
         //Строим граф зная имя суперлиний
         graphBuilderInfo.graph:=uzvcom.graphBulderFunc(uzvslagcabComParams.accuracy,nameSL);
         graphBuilderInfo.nameSuperLine:=nameSL;
         listAllGraph.PushBack(graphBuilderInfo);
         //graphCable:=uzvcom.graphBulderFunc(uzvslagcabComParams.accuracy,nameSL);
       end;

    errorSearchAllParam(listAllGraph[0].graph,uzvslagcabComParams.accuracy,listError,listSLname);

    for graphBuilderInfo in listAllGraph do
       begin
              //Ищем ошибки
       errorSearchSLAGCAB(graphBuilderInfo.graph,uzvslagcabComParams.accuracy,listError);

       listHeadDevice:=uzvnum.getGroupDeviceInGraph(graphBuilderInfo.graph,uzvslagcabComParams.accuracy,listError);

        counterColor:=1;
        for i:=0 to listHeadDevice.Size-1 do
        begin
           for j:=0 to listHeadDevice[i].listGroup.Size -1 do
              begin
                   if counterColor=6 then
                        counterColor:=1;
                   uzvnum.visualGroupLine(listHeadDevice,graphBuilderInfo.graph,counterColor,i,j,uzvslagcabComParams.accuracy);
                   counterColor:=counterColor+1;
                   //inc(counterColor);
              end;
        end;
    end;

  //listAllGraph:=TListAllGraph.Create;
  //listSLname:=uzvcom.getListSuperline();
  //
  ////получаем выбраное имя суперлинии
  //nameSL:=pstring(uzvslagcabComParams.NamesList.Enums.getDataMutable(integer(uzvslagcabComParams.NamesList.selected)))^;
  //
  ////строим наш граф
  //graphCable:=uzvcom.graphBulderFunc(uzvslagcabComParams.accuracy,nameSL);






  //**Визуализация ошибок
  for errorInfo in listError do
    begin
      ZCMsgCallBackInterface.TextMessage(errorInfo.name + ' - ошибка: ' + errorInfo.text,TMWOHistoryOut);
      if getPointConnector(errorInfo.device,pConnect) then
           uzvcom.visualGraphError(pConnect,4,6,vSystemVisualLayerName);

  end;
  listError.Destroy;



  zcPlaceUndoEndMarkerIfNeed(UndoMarcerIsPlazed);
  zcRedrawCurrentDrawing;

  Commandmanager.executecommandend;
end;

procedure Tuzvslagcab_com.cablingGroupHeadGraph(pdata:GDBPlatformint);
var
 i,j,k:integer;
 UndoMarcerIsPlazed:boolean;
 nameSL:string;
  listError:TListError;
  errorInfo:TErrorInfo;
   pConnect:GDBVertex;
begin
  //тут делаем чтонибудь что будет усполнено по нажатию DoSomething2
  //выполним Commandmanager.executecommandend;
  //эту кнопку можно нажать 1 раз

  //создаем список ошибок
listError:=TListError.Create;

//listAllGraph:=TListAllGraph.Create;
//listSLname:=uzvcom.getListSuperline();

  nameSL:=pstring(uzvslagcabComParams.NamesList.Enums.getDataMutable(integer(uzvslagcabComParams.NamesList.selected)))^;


  graphCable:=uzvcom.graphBulderFunc(uzvslagcabComParams.accuracy,nameSL);

    //Ищем ошибки
  errorSearchSLAGCAB(graphCable,uzvslagcabComParams.accuracy,listError);

  UndoMarcerIsPlazed:=false;
  zcPlaceUndoStartMarkerIfNeed(UndoMarcerIsPlazed,'AutoCabeling SuperLine Method');

  listHeadDevice:=uzvnum.getGroupDeviceInGraph(graphCable,uzvslagcabComParams.accuracy,listError);
  //Прокладка кабелей
  for i:=0 to listHeadDevice.Size-1 do
  begin
     for j:=0 to listHeadDevice[i].listGroup.Size -1 do
        begin
             uzvnum.cablingGroupLine(listHeadDevice,graphCable,i,j);
        end;
  end;
    //заупстить метрику для всех датчиков (зависимости от их имени)
      for i:=0 to listHeadDevice.Size-1 do
        begin
           for j:=0 to listHeadDevice[i].listGroup.Size -1 do
              begin
                 for k:=0 to listHeadDevice[i].listGroup[j].listDevice.size -1 do
                    begin
                         uzvnum.metricNumeric(uzvslagcabComParams.metricDev,graphCable.listVertex[listHeadDevice[i].listGroup[j].listDevice[k].num].deviceEnt);
                    end;
              end;
        end;

        //**Визуализация ошибок
  for errorInfo in listError do
    begin
      ZCMsgCallBackInterface.TextMessage(errorInfo.name + ' - ошибка: ' + errorInfo.text,TMWOHistoryOut);
      if getPointConnector(errorInfo.device,pConnect) then
            uzvcom.visualGraphError(pConnect,4,6,vSystemVisualLayerName);
            //uzvtestdraw.testTempDrawPLCross(pConnect,12*epsilon,4);
  end;
  listError.Destroy;

    zcPlaceUndoEndMarkerIfNeed(UndoMarcerIsPlazed);
    zcRedrawCurrentDrawing;
    Commandmanager.executecommandend;
end;
//procedure Tuzvslagcab_com.cablingGraphALL(pdata:GDBPlatformint);
//var
// i,j,k:integer;
// UndoMarcerIsPlazed:boolean;
// nameSL:string;
//  listError:TListError;
//  listSLname:TGDBlistSLname;
//  graphBuilderInfo:TListGraphBuilder;
//begin
//  //тут делаем чтонибудь что будет усполнено по нажатию DoSomething2
//  //выполним Commandmanager.executecommandend;
//  //эту кнопку можно нажать 1 раз
//
//    //создаем список ошибок
//    listError:=TListError.Create;
//
//    listAllGraph:=TListAllGraph.Create;
//    listSLname:=uzvcom.getListSuperline();
//
//  //nameSL:=pstring(uzvslagcabComParams.NamesList.Enums.getDataMutable(integer(uzvslagcabComParams.NamesList.selected)))^;
//
//  //graphCable:=uzvcom.graphBulderFunc(uzvslagcabComParams.accuracy,nameSL);
//
//
//  for nameSL in listSLname do
//     begin
//        //ZCMsgCallBackInterface.TextMessage('ВСЕ. Визуализация!!!'+nameSL,TMWOHistoryOut);
//       //Строим граф зная имя суперлиний
//       graphBuilderInfo.graph:=uzvcom.graphBulderFunc(uzvslagcabComParams.accuracy,nameSL);
//       graphBuilderInfo.nameSuperLine:=nameSL;
//       listAllGraph.PushBack(graphBuilderInfo);
//       //graphCable:=uzvcom.graphBulderFunc(uzvslagcabComParams.accuracy,nameSL);
//     end;
//
//  UndoMarcerIsPlazed:=false;
//  zcPlaceUndoStartMarkerIfNeed(UndoMarcerIsPlazed,'AutoCabeling SuperLine Method');
//
//
//  errorSearchAllParam(listAllGraph[0].graph,uzvslagcabComParams.accuracy,listError,listSLname);
//
//    for graphBuilderInfo in listAllGraph do
//       begin
//              //Ищем ошибки
//       errorSearchSLAGCAB(graphBuilderInfo.graph,uzvslagcabComParams.accuracy,listError);
//
//       listHeadDevice:=uzvnum.getGroupDeviceInGraph(graphBuilderInfo.graph,uzvslagcabComParams.accuracy,listError);
//
//        for i:=0 to listHeadDevice.Size-1 do
//        begin
//           for j:=0 to listHeadDevice[i].listGroup.Size -1 do
//              begin
//                   uzvnum.cablingGroupLine(listHeadDevice,graphCable,i,j);
//              end;
//        end;
//          //заупстить метрику для всех датчиков (зависимости от их имени)
//            for i:=0 to listHeadDevice.Size-1 do
//              begin
//                 for j:=0 to listHeadDevice[i].listGroup.Size -1 do
//                    begin
//                       for k:=0 to listHeadDevice[i].listGroup[j].listDevice.size -1 do
//                          begin
//                               uzvnum.metricNumeric(uzvslagcabComParams.metricDev,graphCable.listVertex[listHeadDevice[i].listGroup[j].listDevice[k].num].deviceEnt);
//                          end;
//                    end;
//              end;
//    end;
//
//
//  //listHeadDevice:=uzvnum.getGroupDeviceInGraph(graphCable,uzvslagcabComParams.accuracy,listError);
//  //Прокладка кабелей
//  //for i:=0 to listHeadDevice.Size-1 do
//  //begin
//  //   for j:=0 to listHeadDevice[i].listGroup.Size -1 do
//  //      begin
//  //           uzvnum.cablingGroupLine(listHeadDevice,graphCable,i,j);
//  //      end;
//  //end;
//  //  //заупстить метрику для всех датчиков (зависимости от их имени)
//  //    for i:=0 to listHeadDevice.Size-1 do
//  //      begin
//  //         for j:=0 to listHeadDevice[i].listGroup.Size -1 do
//  //            begin
//  //               for k:=0 to listHeadDevice[i].listGroup[j].listDevice.size -1 do
//  //                  begin
//  //                       uzvnum.metricNumeric(uzvslagcabComParams.metricDev,graphCable.listVertex[listHeadDevice[i].listGroup[j].listDevice[k].num].deviceEnt);
//  //                  end;
//  //            end;
//  //      end;
//
//    zcPlaceUndoEndMarkerIfNeed(UndoMarcerIsPlazed);
//    zcRedrawCurrentDrawing;
//    Commandmanager.executecommandend;
//end;
procedure Tuzvslagcab_com.test(pdata:GDBPlatformint);
var
 i,j,counterColor:integer;
 UndoMarcerIsPlazed:boolean;
 nameSL:string;
 listError:TListError;
 errorInfo:TErrorInfo;
 //listSLname:TGDBlistSLname;
 pConnect:GDBVertex;
 listMasterDevice:TVectorOfMasterDevice;
begin
  //тут делаем чтонибудь что будет усполнено по нажатию DoSomething2
  //выполним Commandmanager.executecommandend;
  //эту кнопку можно нажать 1 раз

  //создаем список ошибок
  listError:=TListError.Create;

  //listAllGraph:=TListAllGraph.Create;
  //listSLname:=uzvcom.getListSuperline();
  //
  //получаем выбраное имя суперлинии
  nameSL:=pstring(uzvslagcabComParams.NamesList.Enums.getDataMutable(integer(uzvslagcabComParams.NamesList.selected)))^;

  //строим наш граф
  graphCable:=uzvcom.graphBulderFunc(uzvslagcabComParams.accuracy,nameSL);

  //Ищем ошибки
  //uzvtreedevice.errorSearchList(graphCable,uzvslagcabComParams.accuracy,listError);


  UndoMarcerIsPlazed:=false;
  zcPlaceUndoStartMarkerIfNeed(UndoMarcerIsPlazed,'Visualisation Group Line');

  //**Визуализация ошибок
  for errorInfo in listError do
    begin
      ZCMsgCallBackInterface.TextMessage(errorInfo.name + ' - ошибка: ' + errorInfo.text,TMWOHistoryOut);
      if getPointConnector(errorInfo.device,pConnect) then
            uzvcom.visualGraphError(pConnect,4,6,vSystemVisualLayerName);
            //uzvtestdraw.testTempDrawPLCross(pConnect,12*epsilon,4);

  end;
  listError.Destroy;

  listMasterDevice:=uzvtreedevice.buildListAllConnectDevice(graphCable,uzvslagcabComParams.accuracy,listError);

  //visualTreeDevice(listHeadDevice,graphCable,counterColor,i,j,uzvslagcabComParams.accuracy);

  counterColor:=1;
  //for i:=0 to listHeadDevice.Size-1 do
  //begin
  //   for j:=0 to listHeadDevice[i].listGroup.Size -1 do
  //      begin
  //           if counterColor=6 then
  //                counterColor:=1;
  //           uzvnum.visualGroupLine(listHeadDevice,graphCable,counterColor,i,j,uzvslagcabComParams.accuracy);
  //           counterColor:=counterColor+1;
  //           //inc(counterColor);
  //      end;
  //end;
  zcPlaceUndoEndMarkerIfNeed(UndoMarcerIsPlazed);
  zcRedrawCurrentDrawing;

  Commandmanager.executecommandend;
end;



procedure Tuzvslagcab_com.cablingTreeDeviceOne(pdata:GDBPlatformint);
begin

end;
procedure Tuzvslagcab_com.cablingTreeDeviceAll(pdata:GDBPlatformint);
begin

end;

{*var
 listSLname:TGDBlistSLname;
 name:string;
begin
    ZCMsgCallBackInterface.TextMessage('ТЕСТ РАБОТАЕТ!!!',TMWOHistoryOut);
    //ZCMsgCallBackInterface.TextMessage('В полученном графе вершин = ' + IntToStr(ourGraph.listVertex.Size));

        //ZCMsgCallBackInterface.TextMessage(IntToStr(uzvslagcabComParams.NamesList.Selected),TMWOHistoryOut);

//    ZCMsgCallBackInterface.TextMessage(GetEnumName(TypeInfo(uzvslagcabComParams.NamesList.Enums),uzvslagcabComParams.NamesList.Selected),TMWOHistoryOut);
    //ZCMsgCallBackInterface.TextMessage(uzvslagcabComParams.NamesList.Enums.GetObjName,TMWOHistoryOut);

    ZCMsgCallBackInterface.TextMessage(pstring(uzvslagcabComParams.NamesList.Enums.getDataMutable(integer(uzvslagcabComParams.NamesList.selected)))^,TMWOHistoryOut);

    //uzvslagcabComParams.NamesList.Enums.GetTextWithEOL;
    ZCMsgCallBackInterface.TextMessage(IntToStr(integer(uzvslagcabComParams.NamesList.selected)),TMWOHistoryOut);
      //uzvslagcabComParams.NamesList.Enums.
    //GetEnumNameCount
     //uzvslagcabComParams.NamesList.Enums.GetObjName;

    //uzvcom.clearVisualGraph(systemVisualLayerName);
    //uzvslagcabComParams.NamesList.Enums.Clear;
    //listSLname:=uzvcom.getListSuperline();
    //for name in listSLname do
    //   uzvslagcabComParams.NamesList.Enums.PushBackData(name);//заполняем
       //ZCMsgCallBackInterface.TextMessage('имя-суперлинии--'+name,TMWOHistoryOut);

    //****Сюда включить методы по созданию выподающего списка в инспекторе,
    //****заполнитель данных в инспектор добавить сюда.
    //****список хранится в listSLname


  //тут делаем чтонибудь что будет усполнено по нажатию DoSomething2
  //выполним Commandmanager.executecommandend;
  //эту кнопку можно нажать 1 раз
  //graphCable:=uzvcom.graphBulderFunc(uzvslagcabComParams.accuracy,uzvslagcabComParams.nameSL);
  //
  ////Визуализация графа
  //UndoMarcerIsPlazed:=false;
  //zcPlaceUndoStartMarkerIfNeed(UndoMarcerIsPlazed,'Visualisation Graph');
  ////for i:=0 to graphCable.listVertex.Size-1 do
  ////  if graphCable.listVertex[i].deviceEnt <> nil then
  ////    //if graphCable.listVertex[i].break then
  ////    begin
  ////       uzvcom.testTempDrawCircle(graphCable.listVertex[i].centerPoint,Epsilon*25);
  ////    end;
  ////
  //for i:=0 to graphCable.listEdge.Size-1 do
  //  begin
  //     uzvcom.visualGraphEdge(graphCable.listEdge[i].VPoint1,graphCable.listEdge[i].VPoint2,2);
  //  end;
  //zcPlaceUndoEndMarkerIfNeed(UndoMarcerIsPlazed);
  //zcRedrawCurrentDrawing;
  //Commandmanager.executecommandend;
end;  *}


//procedure Tuzvslagcab_com.DoSomething(pdata:GDBPlatformint);
//var
// k:integer;
//begin
//  //тут делаем чтонибудь что будет выполнено по нажатию DoSomething
//  //если тут не вызывать Commandmanager.executecommandend;
//  //то выполнение команды не завершится и кнопку можно жать много раз
//  //для примера просто играем параметрами
// // inc(ExampleComParams.option1);
//  k:=uzvagensl.autoGenSLBetweenDevices('победа');
//    Commandmanager.executecommandend;
//
//
//
//end;


initialization
  //начальные значения параметров
  uzvslagcabComParams.NamesList.Enums.init(10);//инициализируем список
  //uzvslagcabComParams.NamesList.Enums.Clear;//потом при нужде его так очищаем
  //uzvslagcabComParams.NamesList.Enums.PushBackData('нуль');//заполняем
  //uzvslagcabComParams.NamesList.Enums.PushBackData('адин');//заполняем
  //uzvslagcabComParams.NamesList.Enums.PushBackData('тва');//заполняем
  //uzvslagcabComParams.NamesList.Selected:=1;//изначально будет выбран 'адин'

  //uzvslagcabComParams.nameSL:='-';
  uzvslagcabComParams.accuracy:=0.3;
  uzvslagcabComParams.metricDev:=true;
  uzvslagcabComParams.settingVizCab.sErrors:=true;


  SysUnit.RegisterType(TypeInfo(PTuzvslagcabComParams));//регистрируем тип данных в зкадном RTTI

  SysUnit.SetTypeDesk(TypeInfo(TsettingVizCab),['Проверять ошибки','Пронумировать устройства','Построить полное дерево','Построить простое дерево']);//Даем человечьи имена параметрам
  SysUnit.SetTypeDesk(TypeInfo(TuzvslagcabComParams),['Имя суперлинии','Погрешность','Метрика нумерации по типам датчиков','Визуализация настройки']);//Даем человечьи имена параметрам

  uzvslagcab_com.init('slagcab',CADWG,0);//инициализируем команду
  uzvslagcab_com.SetCommandParam(@uzvslagcabComParams,'PTuzvslagcabComParams');//привязываем параметры к команде
finalization
  uzvslagcabComParams.NamesList.Enums.done;//незабываем убить проинициализированный объект
end.
