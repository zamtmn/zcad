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
{$mode objfpc}

{**Модуль реализации чертежных команд (линия, круг, размеры и т.д.)}
unit uzvcom;

{ file def.inc is necessary to include at the beginning of each module zcad
  it contains a centralized compilation parameters settings }

{ файл def.inc необходимо включать в начале каждого модуля zcad
  он содержит в себе централизованные настройки параметров компиляции  }
  
{$INCLUDE def.inc}

interface
uses

  { uses units, the list will vary depending on the required entities
    and actions }
  { подключеные модули, список будет меняться в зависимости от требуемых
    примитивов и действий с ними }

  sysutils, math,

  URecordDescriptor,TypeDescriptors,

  Forms, uzcfblockinsert, uzcfarrayinsert,

  uzeentblockinsert,      //unit describes blockinsert entity
                       //модуль описывающий примитив вставка блока
  uzeentline,             //unit describes line entity
                       //модуль описывающий примитив линия

  uzeentlwpolyline,             //unit describes line entity
                       //модуль описывающий примитив двухмерная ПОЛИлиния

  uzeentpolyline,             //unit describes line entity
                       //модуль описывающий примитив трехмерная ПОЛИлиния

  uzeentdimaligned, //unit describes aligned dimensional entity
                       //модуль описывающий выровненный размерный примитив
  uzeentdimrotated,

  uzeentdimdiametric,

  uzeentdimradial,
  uzeentarc,
  uzeentcircle,
  uzeentity,

  gvector,garrayutils, // Подключение Generics и модуля для работы с ним

  uzcentcable,
  uzeentdevice,
  UGDBOpenArrayOfPV,

  geometry,
  uzeentitiesmanager,

  uzcshared,
  uzeentityfactory,    //unit describing a "factory" to create primitives
                      //модуль описывающий "фабрику" для создания примитивов
  uzcsysvars,        //system global variables
                      //системные переменные
  uzgldrawcontext,
  uzcinterface,
  gdbase,gdbasetypes, //base types
                      //описания базовых типов
  uzeconsts, //base constants
                      //описания базовых констант
  uzccommandsmanager,
  uzccommandsabstract,
  uzccommandsimpl, //Commands manager and related objects
                      //менеджер команд и объекты связанные с ним
  uzcdrawing,
  uzcdrawings,     //Drawings manager, all open drawings are processed him
                      //"Менеджер" чертежей
  uzcutils,         //different functions simplify the creation entities, while there are very few
                      //разные функции упрощающие создание примитивов, пока их там очень мало
  varmandef,
  Varman,
  {UGDBOpenArrayOfUCommands,}zcchangeundocommand,

  uzclog;                //log system
                      //<**система логирования
type
    //+++Здесь описывается все переменые для выполения анализа чертежей с целью нумирации извещателе, иполучения длин продукции и тд.

    //** Создания списка кабелей
      PTStructCableLine=^TStructCableLine;
      TStructCableLine=record
                         cableEnt:PGDBObjCable;
                         fPoint:GDBVertex;
                         lPoint:GDBVertex;
      end;
      TListCableLine=specialize TVector<TStructCableLine>;

      //** Создания списка устройств
      PTStructDeviceLine=^TStructDeviceLine;
      TStructDeviceLine=record
                         deviceEnt:PGDBObjDevice;
                         //fPoint:GDBVertex;
                         //lPoint:GDBVertex;
      end;
      TListDeviceLine=specialize TVector<TStructDeviceLine>;


implementation

procedure RecurseSearhCable(pc:PGDBObjCable);
const
     MyEPSILON=0.05;//погрешность с которой ищем - половина стороны куба в котором будет осуществлен поиск
var
    pc2:PGDBObjCable;               //указатель на найденый кабель
    LastPoint,FirstPoint:GDBVertex; //точки в конце кабеля PC и начале кабеля PC2
    Volume:TBoundingBox;            //Ограничивающий объем, обычно в графике его называют AABB - axis aligned bounding box
                                    //куб со сторонами паралелльными осям, определяется 2мя диагональными точками
                                    //левая-нижняя-ближняя и правая-верхняя-дальняя

    NearObjects:GDBObjOpenArrayOfPV;//список примитивов рядом с точкой
    ir:itrec;                       //переменная для пробежки по массивам zcad`а, можно сказать аналог i в цикле for
begin
 { for i:=0 to 36 do
                   begin
                        DataArray1[i].a:=100;
                        DataArray1[i].b:=100;
                        DataArray1[i].c:=100;
                   end;
  //////////////////////////////////////////////////
  setlength(DataOpenArray2,100);
  for i:=0 to 100 do
                   begin
                        DataOpenArray2[i].a:=100;
                        DataOpenArray2[i].b:=100;
                        DataOpenArray2[i].c:=100;
                   end;
   setlength(DataOpenArray2,0);
   //////////////////////////////////////////////////
   for i:=0 to 100 do
                    begin
                         setlength(DataOpenArray2,length(DataOpenArray2)+1);
                         DataOpenArray2[i].a:=100;
                         DataOpenArray2[i].b:=100;
                         DataOpenArray2[i].c:=100;
                    end;
   setlength(DataOpenArray2,0);
   //////////////////////////////////////////////////        }
  LastPoint:=PGDBVertex(pc^.VertexArrayInWCS.getelement(pc^.VertexArrayInWCS.Count-1))^;//получаем точку в конце кабеля

  volume.LBN:=createvertex(LastPoint.x-MyEPSILON,LastPoint.y-MyEPSILON,LastPoint.z-MyEPSILON);//считаем левую\нижнюю\ближнюю точку объема
  volume.RTF:=createvertex(LastPoint.x+MyEPSILON,LastPoint.y+MyEPSILON,LastPoint.z+MyEPSILON);//считаем правую\верхнюю\дальнюю точку объема
  NearObjects.init(100); //инициализируем список
  if gdb.GetCurrentROOT^.FindObjectsInVolume(volume,NearObjects)then //ищем примитивы оболочка которых пересекается с volume
  begin
       //тут если такие примитивы нашлись, они лежат в списке NearObjects

       //пробегаем по списку
       pc2:=NearObjects.beginiterate(ir);//получаем первый примитив из списка
       if pc2<>nil then                  //если он есть то
       repeat
             if pc2^.vp.ID=GDBCableID then//если он кабель то
             begin
                  FirstPoint:=PGDBVertex(pc2^.VertexArrayInWCS.getelement(0))^;//получаем точку в начале найденного кабеля
                  if geometry.Vertexlength(LastPoint,FirstPoint)<MyEPSILON then//если конец кабеля совпадает с началом с погрешностью, то
                  begin
                       pc2^.SelectQuik;            //выделяем
                       RecurseSearhCable(pc2);     //рекурсивно ищем на конце найденного кабеля
                  end;
             end;

             pc2:=NearObjects.iterate(ir);//получаем следующий примитив из списка
       until pc2=nil;                     //выходим когда список кончился
  end;
  NearObjects.ClearAndDone;//убиваем список
end;

function TemplateForVeb_com(operands:TCommandOperands):TCommandResult;
var
    pc,pc2:PGDBObjCable;                //указатель на кабель
    LastPoint:GDBVertex;            //точка в конце кабеля
    NearObjects:GDBObjOpenArrayOfPV;//список примитивов рядом с точкой
    l1begin,l1end,l2begin,l2end,l222:GDBVertex;

    ir:itrec;

begin
    if commandmanager.getentity('Select Cable: ',pc) then  //просим выбрать примитив
    begin

         //поис пересечения
         l1begin.x := 353;
         l1begin.y := 80;
         l1begin.z := 0;

         l1end.x := 390;
         l1end.y := 50;
         l1end.z := 0;

         l2begin.x := 390;
         l2begin.y := 65;
         l2begin.z := 0;

         l2end.x := 350;
         l2end.y := 60;
         l2end.z := 0;

         l222 := geometry.intercept3d(l1begin,l1end,l2begin,l2end).interceptcoord;

         if pc^.vp.ID=GDBCableID then                      //проверяем, кабель это или нет


                                     RecurseSearhCable(pc) //осуществляем поиск ветвей
                                 else
                                     HistoryOutStr('Fuck! You must select Cable'); //не кабель - посылаем
    end;
    result:=cmd_ok;
end;

//** Базовая функция запуска алгоритма анализа кабеля на плане, подключенных устройств, их нумерация и.т.д
function NumLengthOtherCable_com(operands:TCommandOperands):TCommandResult;
var
    //список всех кабелей на чертеже в произвольном порядке
    listCable:TListCableLine;   //сам список
    infoCable:TStructCableLine; //инфо по объекта списка


    //список всех устройств на из выделеных на чертеже в произвольном порядке
    listDevice:TListDeviceLine;   //сам список
    infoDevice:TStructDeviceLine; //инфо по объекта списка

    pobj: pGDBObjEntity;   //выделеные объекты в пространстве листа
    pc:PGDBObjCable;

    ir:itrec;  // применяется для обработки списка выделений, но что это понятия не имею :)

    counter:integer; //счетчик
    i:integer;




    //PinfoCable:PTStructCableLine;


    //указатель на кабель
   // LastPoint,FirstPoint:GDBVertex; //точки в конце кабеля PC и начале кабеля PC2
   // NearObjects:GDBObjOpenArrayOfPV;//список примитивов рядом с точкой
  //  l1begin,l1end,l2begin,l2end,l222:GDBVertex;



begin
   listCable := TListCableLine.Create;  // инициализация списка кабелей
   listDevice := TListDeviceLine.Create;  // инициализация списка устройств

   counter:=0; //обнуляем счетчик

  //+++Выбираем зону в которой будет происходить анализ кабельной продукции+++//
  pobj:=gdb.GetCurrentROOT^.ObjArray.beginiterate(ir); //зона уже выбрана в перспективе застовлять пользователя ее выбирать
  if pobj<>nil then
    repeat
      if pobj^.selected then
        begin
             HistoryOutStr(pobj^.GetObjTypeName);
             if pobj^.vp.ID=GDBCableID then
               begin
               pc:=PGDBObjCable(pobj);
               infoCable.cableEnt:=pc;
               infoCable.fPoint:=PGDBVertex(pc^.VertexArrayInOCS.getelement(0))^;
               infoCable.lPoint:=PGDBVertex(pc^.VertexArrayInOCS.getelement(1))^;
               listCable.PushBack(infoCable);
               end;
             //GDBObjDevice
        inc(counter);
        end;
      pobj:=gdb.GetCurrentROOT^.ObjArray.iterate(ir); //переход к следующем примитиву в списке выбраных примитивов
    until pobj=nil;

  HistoryOutStr('Кол-во ввыбранных элементов = ' + IntToStr(counter));

  for i:=0 to listCable.Size-1 do
  begin
    //PinfoCable:=listCable.Mutable[i];
    HistoryOutStr(listCable[i].cableEnt^.GetObjTypeName);
  //  //writeln(myArray[i].a,' --> ',myArray[i].b);
  end;
  if counter>0 then
    begin
         HistoryOutStr('1');

  //Получаем список всех кабельных линий в выбранной нами зоне их адресс, и все координаты
   //if pobj^.vp.ID=GDBCableID then                      //проверяем, кабель это или нет
   //begin
   //    HistoryOutStr('1');
   //end;
  //Ищем пересечения линий между друг другом, с небольшим удлинение линии для иключения погрешности при рисовании

  //Ищем подключеные извещатели, это те извещатели где конец кабельной линии подходит к извещателю
  //При построении кабельной линии там где происходит контакт с извещателем и центром извещателя прокладывается линия

  //Определение


   {
    if commandmanager.getentity('Select Cable: ',pc) then  //просим выбрать примитив
    begin

         //поис пересечения
         l1begin.x := 353;
         l1begin.y := 80;
         l1begin.z := 0;

         l1end.x := 390;
         l1end.y := 50;
         l1end.z := 0;

         l2begin.x := 390;
         l2begin.y := 65;
         l2begin.z := 0;

         l2end.x := 350;
         l2end.y := 60;
         l2end.z := 0;

         l222 := geometry.intercept3d(l1begin,l1end,l2begin,l2end).interceptcoord;

         if pc^.vp.ID=GDBCableID then                      //проверяем, кабель это или нет


                                    // RecurseSearhCable(pc) //осуществляем поиск ветвей
                                 else
                                     HistoryOutStr('Fuck! You must select Cable'); //не кабель - посылаем
    end; }

     end;
    result:=cmd_ok;
  end;

initialization
  CreateCommandFastObjectPlugin(@TemplateForVeb_com,'Trrree',CADWG,0);
  CreateCommandFastObjectPlugin(@NumLengthOtherCable_com,'test111',CADWG,0);
end.
