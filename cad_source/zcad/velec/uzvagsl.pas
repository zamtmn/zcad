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

unit uzvagsl;
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
Tuzvagsl_com=object(CommandRTEdObject)//определяем тип - объект наследник базового объекта "динамической" команды
             procedure CommandStart(Operands:TCommandOperands);virtual;//переопределяем метод вызываемый при старте команды
             //procedure CommandEnd; virtual;//переопределяем метод вызываемый при окончании команды
             //procedure CommandCancel; virtual;//переопределяем метод вызываемый при отмене команды

             procedure visualInspectionGraph(pdata:GDBPlatformint); virtual;//построение графа и его визуализация
             procedure visualInspectionGroupHeadGraph(pdata:GDBPlatformint); virtual;//построение графа и его визуализация
             procedure cablingGroupHeadGraph(pdata:GDBPlatformint); virtual;//прокладка кабелей по трассе полученной в результате поисков пути и т.д.

             procedure DoSomething(pdata:GDBPlatformint); virtual;//реализация какогото действия
             procedure DoSomething2(pdata:GDBPlatformint); virtual;//реализация какогото другого действия
            end;
PTuzvagslComParams=^TuzvagslComParams;//указатель на тип данных параметров команды. зкад работает с ними через указатель
TuzvagslComParams=packed record       //определяем параметры команды которые будут видны в инспекторе во время выполнения команды
                                      //регистрировать их будем паскалевским RTTI
                                      //не через экспорт исходников и парсинг файла с определениями типов
  InverseX:gdbboolean;
  InverseY:gdbboolean;
  option3:gdbstring;
  option1:gdbdouble;
  option2:gdbboolean;

end;
const
  Epsilon=0.2;
var
 uzvagsl_com:Tuzvagsl_com;//определяем экземпляр нашей команды
 uzvagslComParams:TuzvagslComParams;//определяем экземпляр параметров нашей команды

 graphCable:TGraphBuilder; //созданый граф
 listHeadDevice:TListHeadDevice; //список головных устройств с подключенными к ним устройствами



implementation

procedure Tuzvagsl_com.CommandStart(Operands:TCommandOperands);
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

procedure Tuzvagsl_com.autoNumberDevice(pdata:GDBPlatformint);
  var
      psd:PSelectedObjDesc;
      ir:itrec;
      mpd:devcoordarray;
      pdev:PGDBObjDevice;
      //key:GDBVertex;
      index:integer;
      pvd:pvardesk;
      dcoord:tdevcoord;
      i,count:integer;
      process:boolean;
      DC:TDrawContext;
      pdevvarext:PTVariablesExtender;
  begin
       mpd:=devcoordarray.Create;
       psd:=drawings.GetCurrentDWG^.SelObjArray.beginiterate(ir);
       count:=0;
       dc:=drawings.GetCurrentDWG^.CreateDrawingRC;
       if psd<>nil then
       repeat
             if psd^.objaddr^.GetObjType=GDBDeviceID then
             begin
                  case NumberingParams.SortMode of
                                                  TST_YX,TST_UNSORTED:
                                                         begin
                                                         dcoord.coord:=PGDBObjDevice(psd^.objaddr)^.P_insert_in_WCS;
                                                         if NumberingParams.InverseX then
                                                                                         dcoord.coord.x:=-dcoord.coord.x;
                                                         if NumberingParams.InverseY then
                                                                                         dcoord.coord.y:=-dcoord.coord.y;
                                                         end;
                                                  TST_XY:
                                                         begin
                                                              dcoord.coord.x:=PGDBObjDevice(psd^.objaddr)^.P_insert_in_WCS.y;
                                                              dcoord.coord.y:=PGDBObjDevice(psd^.objaddr)^.P_insert_in_WCS.x;
                                                              dcoord.coord.z:=PGDBObjDevice(psd^.objaddr)^.P_insert_in_WCS.z;
                                                              if NumberingParams.InverseX then
                                                                                              dcoord.coord.y:=-dcoord.coord.y;
                                                              if NumberingParams.InverseY then
                                                                                              dcoord.coord.x:=-dcoord.coord.x;
                                                         end;
                                                 end;{case}
                  dcoord.pdev:=pointer(psd^.objaddr);
                  inc(count);
                  mpd.PushBack(dcoord);
             end;
       psd:=drawings.GetCurrentDWG^.SelObjArray.iterate(ir);
       until psd=nil;
       if count=0 then
                      begin
                           historyoutstr('In selection not found devices');
                           mpd.Destroy;
                           Commandmanager.executecommandend;
                           exit;
                      end;
       index:=NumberingParams.StartNumber;
       if NumberingParams.SortMode<>TST_UNSORTED then
                                                     devcoordsort.Sort(mpd,mpd.Size);
       count:=0;
       for i:=0 to mpd.Size-1 do
         begin
              dcoord:=mpd[i];
              pdev:=dcoord.pdev;
              pdevvarext:=pdev^.GetExtension(typeof(TVariablesExtender));

              if NumberingParams.BaseName<>'' then
              begin
              //pvd:=PTObjectUnit(pdev^.ou.Instance)^.FindVariable('NMO_BaseName');
              pvd:=pdevvarext^.entityunit.FindVariable('NMO_BaseName');
              if pvd<>nil then
              begin
              if uppercase(pvd^.data.PTD^.GetUserValueAsString(pvd^.data.Instance))=
                 uppercase(NumberingParams.BaseName) then
                                                         process:=true
                                                     else
                                                         process:=false;
              end
                 else
                     begin
                          process:=true;
                          historyoutstr('In device not found BaseName variable. Processed');
                     end;
              end
                 else
                     process:=true;
              if process then
              begin
              //pvd:=PTObjectUnit(pdev^.ou.Instance)^.FindVariable(NumberingParams.NumberVar);
              pvd:=pdevvarext^.entityunit.FindVariable(NumberingParams.NumberVar);
              if pvd<>nil then
              begin
                   pvd^.data.PTD^.SetValueFromString(pvd^.data.Instance,inttostr(index));
                   inc(index,NumberingParams.Increment);
                   inc(count);
                   pdev^.FormatEntity(drawings.GetCurrentDWG^,dc);
              end
                 else
                 historyoutstr('In device not found numbering variable');
              end
              else
                  historyoutstr('Device with basename "'+pvd^.data.PTD^.GetUserValueAsString(pvd^.data.Instance)+'" filtred out');
         end;
       historyoutstr(sysutils.format(rscmNEntitiesProcessed,[inttostr(count)]));
       if NumberingParams.SaveStart then
                                        NumberingParams.StartNumber:=index;
       mpd.Destroy;
       Commandmanager.executecommandend;

end;


procedure Tuzvagsl_com.visualInspectionGroupHeadGraph(pdata:GDBPlatformint);
var
 i,j,counterColor:integer;
 UndoMarcerIsPlazed:boolean;
begin
  //тут делаем чтонибудь что будет усполнено по нажатию DoSomething2
  //выполним Commandmanager.executecommandend;
  //эту кнопку можно нажать 1 раз
  graphCable:=uzvcom.graphBulderFunc(uzvagslComParams.option1,uzvagslComParams.option3);

  UndoMarcerIsPlazed:=false;
  zcPlaceUndoStartMarkerIfNeed(UndoMarcerIsPlazed,'Visualisation Group Line');

  listHeadDevice:=uzvnum.getGroupDeviceInGraph(graphCable,uzvagslComParams.option1);

  counterColor:=1;
  for i:=0 to listHeadDevice.Size-1 do
  begin
     for j:=0 to listHeadDevice[i].listGroup.Size -1 do
        begin
             if counterColor=7 then
                  counterColor:=1;
             uzvnum.visualGroupLine(listHeadDevice,graphCable,counterColor,i,j);
             counterColor:=counterColor+1;
             //inc(counterColor);
        end;
  end;
  zcPlaceUndoEndMarkerIfNeed(UndoMarcerIsPlazed);
    zcRedrawCurrentDrawing;
  //Commandmanager.executecommandend;
end;

procedure Tuzvagsl_com.cablingGroupHeadGraph(pdata:GDBPlatformint);
var
 i,j,counterColor:integer;
 UndoMarcerIsPlazed:boolean;
begin
  //тут делаем чтонибудь что будет усполнено по нажатию DoSomething2
  //выполним Commandmanager.executecommandend;
  //эту кнопку можно нажать 1 раз
  graphCable:=uzvcom.graphBulderFunc(uzvagslComParams.option1,uzvagslComParams.option3);
  listHeadDevice:=uzvnum.getGroupDeviceInGraph(graphCable,uzvagslComParams.option1);
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


procedure Tuzvagsl_com.DoSomething(pdata:GDBPlatformint);
var
 k:integer;
begin
  //тут делаем чтонибудь что будет выполнено по нажатию DoSomething
  //если тут не вызывать Commandmanager.executecommandend;
  //то выполнение команды не завершится и кнопку можно жать много раз
  //для примера просто играем параметрами
 // inc(ExampleComParams.option1);
  k:=uzvagensl.autoGenSLBetweenDevices('победа');
  uzvagslComParams.option2:=not uzvagslComParams.option2;



end;

procedure Tuzvagsl_com.DoSomething2(pdata:GDBPlatformint);
begin
  //тут делаем чтонибудь что будет усполнено по нажатию DoSomething2
  //выполним Commandmanager.executecommandend;
  //эту кнопку можно нажать 1 раз
  Commandmanager.executecommandend;
end;

initialization
  //начальные значения параметров
  uzvagslComParams.InverseX:=false;
  uzvagslComParams.InverseY:=false;
  uzvagslComParams.option1:=0.1;
  uzvagslComParams.option2:=false;
  uzvagslComParams.option3:='-';

  SysUnit.RegisterType(TypeInfo(PTuzvagslComParams));//регистрируем тип данных в зкадном RTTI
  SysUnit.SetTypeDesk(TypeInfo(TuzvagslComParams),['Имя суперлинии','Погрешность','Параметр2']);//Даем человечьи имена параметрам
  uzvagsl_com.init('UZVAGSL',CADWG,0);//инициализируем команду
  uzvagsl_com.SetCommandParam(@uzvagslComParams,'PTuzvagslComParams');//привязываем параметры к команде
end.
