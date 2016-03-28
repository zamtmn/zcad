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

  uzegeometry,
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
  uzedrawingsimple,
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
                         stPoint:GDBVertex;
                         edPoint:GDBVertex;
                         stIndex:Integer; //незнаю нужне ли он будет ну пускай пока будет
                         edIndex:Integer; //незнаю нужне ли он будет ну пускай пока будет
      end;
      TListCableLine=specialize TVector<TStructCableLine>;

      //** Создания списка устройств
      PTStructDeviceLine=^TStructDeviceLine;
      TStructDeviceLine=record
                         deviceEnt:PGDBObjDevice;
                         centerPoint:GDBVertex;
                         //lPoint:GDBVertex;
      end;
      TListDeviceLine=specialize TVector<TStructDeviceLine>;

      //Применяется для функции возврата удлиненной линии
      PTextendedLine=^TextendedLine;
      TextendedLine=record
                         stPoint:GDBVertex;
                         edPoint:GDBVertex;
      end;

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
  if drawings.GetCurrentROOT^.FindObjectsInVolume(volume,NearObjects)then //ищем примитивы оболочка которых пересекается с volume
  begin
       //тут если такие примитивы нашлись, они лежат в списке NearObjects

       //пробегаем по списку
       pc2:=NearObjects.beginiterate(ir);//получаем первый примитив из списка
       if pc2<>nil then                  //если он есть то
       repeat
             if pc2^.GetObjType=GDBCableID then//если он кабель то
             begin
                  FirstPoint:=PGDBVertex(pc2^.VertexArrayInWCS.getelement(0))^;//получаем точку в начале найденного кабеля
                  if uzegeometry.Vertexlength(LastPoint,FirstPoint)<MyEPSILON then//если конец кабеля совпадает с началом с погрешностью, то
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

function compareVertex(p1:GDBVertex;p2:GDBVertex;inaccuracy:GDBDouble):Boolean;
begin
    result:=false;
    if ((p1.x >= p2.x-inaccuracy) and (p1.x <= p2.x+inaccuracy) and (p2.y >= p2.y-inaccuracy) and (p2.y <= p2.y+inaccuracy)) then
       result:=true;
end;

function dublicateVertex(listVertex:TListDeviceLine;addVertex:GDBVertex;inaccuracy:GDBDouble):Boolean;
var
    i:integer;
begin
    result:=false;
    for i:=0 to listVertex.Size-1 do
        if ((addVertex.x >= listVertex[i].centerPoint.x-inaccuracy) and (addVertex.x <= listVertex[i].centerPoint.x+inaccuracy) and (addVertex.y >= listVertex[i].centerPoint.y-inaccuracy) and (addVertex.y <= listVertex[i].centerPoint.y+inaccuracy)) then
           result:=true;
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
         l1begin.x := 350;
         l1begin.y := 80;
         l1begin.z := 0;

         l1end.x := 390;
         l1end.y := 50;
         l1end.z := 0;

         l2begin.x := 350;
         l2begin.y := 80;
         l2begin.z := 0;

         if  compareVertex(l1begin,l2begin,10) then
            HistoryOutStr('rrrrrrrrrrrrrrrrrrrrrrrrrr');

         l2end.x := 350;
         l2end.y := 60;
         l2end.z := 0;

         l222 := uzegeometry.intercept3d(l1begin,l1end,l2begin,l2end).interceptcoord;

         if pc^.GetObjType=GDBCableID then                      //проверяем, кабель это или нет


                                     RecurseSearhCable(pc) //осуществляем поиск ветвей
                                 else
                                     HistoryOutStr('Fuck! You must select Cable'); //не кабель - посылаем
    end;
    result:=cmd_ok;
end;

//function testTempDrawCicle(prompt1,prompt2:GDBString;var p1,p2:GDBVertex):TCommandResult;
function testTempDrawLine(p1:GDBVertex;p2:GDBVertex):TCommandResult;
var
    pline:PGDBObjLine;
   // pe:T3PointCircleModePentity;
   // p1,p2:gdbvertex;
begin
    begin
      //старый способ

      pline := AllocEnt(GDBLineID);                                             //выделяем память
      pline^.init(nil,nil,0,p1,p2);                                             //инициализируем и сразу создаем

      //конец старого способа


      //новый способ
      //pline:=pointer(ENTF_CreateLine(nil,nil,[p1.x,p1.y,p1.z,p2.x,p2.y,p2.z])); //создаем примитив с зпданой геометрией, не указывая владельца и список во владельце
      //конец нового способа

      zcSetEntPropFromCurrentDrawingProp(pline);                                        //присваиваем текущие слой, вес и т.п
      zcAddEntToCurrentDrawingWithUndo(pline);                                    //добавляем в чертеж
    end;
    result:=cmd_ok;
end;
function testTempDrawCircle(p1:GDBVertex;rr:GDBDouble):TCommandResult;
var
    pcircle:PGDBObjCircle;
   // pe:T3PointCircleModePentity;
   // p1,p2:gdbvertex;
begin
    begin
      //старый способ

      pcircle := AllocEnt(GDBCircleID);                                             //выделяем память
      pcircle^.init(nil,nil,0,p1,rr);                                             //инициализируем и сразу создаем

      //конец старого способа


      //новый способ
      //pline:=pointer(ENTF_CreateLine(nil,nil,[p1.x,p1.y,p1.z,p2.x,p2.y,p2.z])); //создаем примитив с зпданой геометрией, не указывая владельца и список во владельце
      //конец нового способа

      zcSetEntPropFromCurrentDrawingProp(pcircle);                                        //присваиваем текущие слой, вес и т.п
      zcAddEntToCurrentDrawingWithUndo(pcircle);                                    //добавляем в чертеж
    end;
    result:=cmd_ok;
end;


function extendedLineFunc(point1:GDBVertex;point2:GDBVertex;extendedAbsolut:double;volume:boolean):TextendedLine;
var
   xline,yline,xyline,xylinenew,xlinenew,ylinenew,xdiffline,ydiffline:double;
   pt1new,pt2new:GDBVertex;
   newextendedLine:TextendedLine;
begin
     xline:=abs(point2.x - point1.x);
     yline:=abs(point2.y - point1.y);
     xyline:=sqrt(sqr(xline) + sqr(yline));
     xylinenew:=xyline + extendedAbsolut;
     xlinenew:=(xline*xylinenew)/xyline;
     ylinenew:=(yline*xylinenew)/xyline;
     xdiffline:= xlinenew - xline;
     ydiffline:= ylinenew - yline;
     if volume then begin
       if point1.x > point2.x then
            begin
              pt1new.x := point1.x + extendedAbsolut;
              pt2new.x := point2.x - extendedAbsolut;
            end
            else
            begin
              pt1new.x := point1.x - extendedAbsolut;
              pt2new.x := point2.x + extendedAbsolut;
            end;
       if point1.y > point2.y then
            begin
              pt1new.y := point1.y + extendedAbsolut;
              pt2new.y := point2.y - extendedAbsolut;
            end
            else
            begin
              pt1new.y := point1.y - extendedAbsolut;
              pt2new.y := point2.y + extendedAbsolut;
            end;
     end
     else begin
          if point1.x > point2.x then
            begin
              pt1new.x := point1.x + xdiffline;
              pt2new.x := point2.x - xdiffline;
            end
            else
            begin
              pt1new.x := point1.x - xdiffline;
              pt2new.x := point2.x + xdiffline;
            end;
       if point1.y > point2.y then
            begin
              pt1new.y := point1.y + ydiffline;
              pt2new.y := point2.y - ydiffline;
            end
            else
            begin
              pt1new.y := point1.y - ydiffline;
              pt2new.y := point2.y + ydiffline;
            end;
     end;

     // не стал вводит 3-ю ось, может позже.
     pt1new.z:=0;
     pt2new.z:=0;
     newextendedLine.stPoint:=pt1new;
     newextendedLine.edPoint:=pt2new;
     extendedLineFunc:= newextendedLine;

end;

//** Базовая функция запуска алгоритма анализа кабеля на плане, подключенных устройств, их нумерация и.т.д
function NumLengthOtherCable_com(operands:TCommandOperands):TCommandResult;
const
     Epsilon=5;   //ПОГРЕШНОСТЬ при черчении
var
    //список всех кабелей на чертеже в произвольном порядке
    listCable:TListCableLine;   //список реальных и виртуальных линий
    infoCable:TStructCableLine; //инфо по объекта списка

    //vertexLines:


    //список всех устройств на из выделеных на чертеже в произвольном порядке
    listDevice:TListDeviceLine;   //сам список
    infoDevice:TStructDeviceLine; //инфо по объекта списка

    pobj: pGDBObjEntity;   //выделеные объекты в пространстве листа

    pc,ptest:PGDBObjCable;
    pline:PGDBObjLine;
    ppolyline:PGDBObjPolyLine;
    pd,pObjDevice,currentSubObj:PGDBObjDevice;

    ir,ir_inDevice:itrec;  // применяется для обработки списка выделений, но что это понятия не имею :)
    NearObjects:GDBObjOpenArrayOfPV;//список примитивов рядом с точкой


    extMainLine,extNextLine,volumeLine:TextendedLine;

    counter,counter1,counter2:integer; //счетчики
    i,j:integer;

    Volume:TBoundingBox;            //Ограничивающий объем, обычно в графике его называют AABB - axis aligned bounding box
                                    //куб со сторонами паралелльными осям, определяется 2мя диагональными точками
                                    //левая-нижняя-ближняя и правая-верхняя-дальня
    interceptVertex:GDBVertex;
    tempStPointLineComparison, tempEdPointLineComparison:GDBVertex;

    psldb:pointer;

    drawing:PTSimpleDrawing;


    //PinfoCable:PTStructCableLine;


    //указатель на кабель
   // LastPoint,FirstPoint:GDBVertex; //точки в конце кабеля PC и начале кабеля PC2
   // NearObjects:GDBObjOpenArrayOfPV;//список примитивов рядом с точкой
  //  l1begin,l1end,l2begin,l2end,l222:GDBVertex;



begin
   listCable := TListCableLine.Create;  // инициализация списка кабелей
   listDevice := TListDeviceLine.Create;  // инициализация списка устройств

   counter:=0; //обнуляем счетчик
   counter1:=0;
   counter2:=0;

  //+++Выбираем зону в которой будет происходить анализ кабельной продукции.Создаем два списка, список всех отрезков кабелей и список всех девайсов+++//
  pobj:=drawings.GetCurrentROOT^.ObjArray.beginiterate(ir); //зона уже выбрана в перспективе застовлять пользователя ее выбирать
  if pobj<>nil then
    repeat
      if pobj^.selected then
        begin
         //    HistoryOutStr(pobj^.GetObjTypeName);
             if pobj^.GetObjType=GDBCableID then
               begin
                 pc:=PGDBObjCable(pobj);
                 infoCable.cableEnt:=pc;
                // HistoryOutStr('число ребер в кабеле = ' + IntToStr(pc^.VertexArrayInOCS.GetRealCount));
                 for i:=1 to pc^.VertexArrayInOCS.GetRealCount-1 do
                     begin

                       infoCable.stPoint:=PGDBVertex(pc^.VertexArrayInOCS.getelement(i-1))^;
                       infoCable.edPoint:=PGDBVertex(pc^.VertexArrayInOCS.getelement(i))^;
                       infoCable.stIndex:=i-1;
                       infoCable.edIndex:=i;
                       listCable.PushBack(infoCable); //добавляем к списку реальные кабели
                       inc(counter1);
                     end;
               end;
             if pobj^.GetObjType=GDBDeviceID then
               begin
                 pd:=PGDBObjDevice(pobj);
                 infoDevice.deviceEnt:=pd;
                 infoDevice.centerPoint:=pd^.GetCenterPoint;
                 listDevice.PushBack(infoDevice);
                 inc(counter2);
               end;
             //GDBObjDevice
        inc(counter);
        end;
      pobj:=drawings.GetCurrentROOT^.ObjArray.iterate(ir); //переход к следующем примитиву в списке выбраных примитивов
    until pobj=nil;

  HistoryOutStr('Кол-во ввыбранных элементов = ' + IntToStr(counter));
  HistoryOutStr('Список кусков кабельных линий состоит из = ' + IntToStr(counter1));
  HistoryOutStr('Список устройств состоит из = ' + IntToStr(counter2));

 // ptest := listCable[0].cableEnt;

  ///***+++Ищем пересечения каждого кабеля либо друг с другом либо с граними девайсов+++***///
  drawing:=drawings.GetCurrentDWG;
  psldb:=drawing^.GetLayerTable^.{drawings.GetCurrentDWG.LayerTable.}getAddres('SYS_DEVICE_BORDER');

  for i:=0 to listCable.Size-1 do
  begin
    extMainLine:= extendedLineFunc(listCable[i].stPoint,listCable[i].edPoint,Epsilon,false) ; // увиличиваем длину кабеля для исключения погрешности
    volumeLine:= extendedLineFunc(listCable[i].stPoint,listCable[i].edPoint,Epsilon,true) ; // находим зону в которой будет находится наш  удлиненый кабель и кабель который его будет пересекать
    testTempDrawLine(extMainLine.stPoint,extMainLine.edPoint); // визуализация
    testTempDrawCircle(volumeLine.stPoint,1); // визуализация
    testTempDrawCircle(volumeLine.edPoint,2); // визуализация
    //FindObjectsInVolume
    volume.LBN:=volumeLine.stPoint;
    volume.RTF:=volumeLine.edPoint;
    NearObjects.init(100); //инициализируем список
    if drawings.GetCurrentROOT^.FindObjectsInVolume(volume,NearObjects)then //ищем примитивы оболочка которых пересекается с volume
    begin
       pobj:=NearObjects.beginiterate(ir);//получаем первый примитив из списка
       counter:=0;
       if pobj<>nil then                  //если он есть то
       repeat
             inc(counter);
             if pobj^.GetObjType=GDBCableID then//если он кабель то
             begin
                 pc:=PGDBObjCable(pobj);
                // infoCable.cableEnt:=pc;
                // HistoryOutStr('число ребер в кабеле = ' + IntToStr(pc^.VertexArrayInOCS.GetRealCount));
                 for j:=1 to pc^.VertexArrayInOCS.GetRealCount-1 do
                     begin
                       // Опеделяем выбраный програмой учаток трассы тот же что и выбранный перебором, как то так
                     //  tempStPointLineComparison:= PGDBVertex(pc^.VertexArrayInOCS.getelement(j-1))^;
                     //  tempEdPointLineComparison:= PGDBVertex(pc^.VertexArrayInOCS.getelement(j))^;
                     //if ((listCable[i].stPoint.x = tempStPointLineComparison.x) AND
                     //    (listCable[i].stPoint.y = tempStPointLineComparison.y) AND
                     //    (listCable[i].edPoint.x = tempEdPointLineComparison.x) AND
                     //    (listCable[i].edPoint.y = tempEdPointLineComparison.y)) or
                     //    ((listCable[i].edPoint.x = tempStPointLineComparison.x) AND
                     //     (listCable[i].edPoint.y = tempStPointLineComparison.y) AND
                     //     (listCable[i].stPoint.x = tempEdPointLineComparison.x) AND
                     //     (listCable[i].stPoint.y = tempEdPointLineComparison.y)
                     //    ) then
                     //       HistoryOutStr('Оно самое')    // странно почему то ничего не находит :) наверное условие написано не правильно. Но все работает как должно
                     //    else
                     //      begin
                              //удлиняем каждую проверяемую линиию, для исключения погрешностей
                              extNextLine:= extendedLineFunc(PGDBVertex(pc^.VertexArrayInOCS.getelement(j-1))^,PGDBVertex(pc^.VertexArrayInOCS.getelement(j))^,Epsilon,false) ;
                              //Производим сравнение основной линии с перебираемой линией
                              if uzegeometry.intercept3d(extMainLine.stPoint,extMainLine.edPoint,extNextLine.stPoint,extNextLine.edPoint).isintercept then
                              begin
                                interceptVertex:=uzegeometry.intercept3d(extMainLine.stPoint,extMainLine.edPoint,extNextLine.stPoint,extNextLine.edPoint).interceptcoord;
                                //выполнить проверку на есть ли уже такая вершина
                                 if dublicateVertex(listDevice,interceptVertex,Epsilon) = false then begin
                                  infoDevice.deviceEnt:=nil;
                                  infoDevice.centerPoint:=interceptVertex;
                                  listDevice.PushBack(infoDevice);
                                  testTempDrawCircle(interceptVertex,Epsilon);
                                end;
                              end;

                     //      end;
                     end;
               end;
             if pobj^.GetObjType=GDBDeviceID then
               begin
                 //POBJ^.
                pObjDevice:= PGDBObjDevice(pobj); // передача объекта в девайсы
                currentSubObj:=pObjDevice^.VarObjArray.beginiterate(ir_inDevice);
                if (currentSubObj<>nil) then
                repeat
                      if currentSubObj^.GetLayer=psldb then BEGIN
                        if currentSubObj^.GetObjType=GDBLineID then begin

                        end;
                        if currentSubObj^.GetObjType=GDBPolyLineID then begin

                        end;
                      end;
                    currentSubObj:=pObjDevice^.VarObjArray.iterate(ir_inDevice);
                until currentSubObj=nil;


               end;
             pobj:=NearObjects.iterate(ir);//получаем следующий примитив из списка
       until pobj=nil;
       HistoryOutStr('сколько было обследовано элементов = ' + IntToStr(counter));   //выходим когда список кончился
    end;
  NearObjects.ClearAndDone;//убиваем список

  end;



                  //  for j:=0 to listCable.Size-1 do
  //2   begin
  //     if i <> j then
  //       begin
  //         HistoryOutStr(IntToStr(i)+'плохо'+IntToStr(j));
  //       end;
  //   end;
    //PinfoCable:=listCable.Mutable[i];
    //if listCable[i].cableEnt = ptest then
    //    HistoryOutStr(listCable[i].cableEnt^.GetObjTypeName)
    //else
    //    HistoryOutStr('плохо');
  //  //writeln(myArray[i].a,' --> ',myArray[i].b);
  //Получаем список всех кабельных линий в выбранной нами зоне их адресс, и все координаты
   //if pobj^.GetObjType=GDBCableID then                      //проверяем, кабель это или нет
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

         l222 := uzegeometry.intercept3d(l1begin,l1end,l2begin,l2end).interceptcoord;

         if pc^.GetObjType=GDBCableID then                      //проверяем, кабель это или нет


                                    // RecurseSearhCable(pc) //осуществляем поиск ветвей
                                 else
                                     HistoryOutStr('Fuck! You must select Cable'); //не кабель - посылаем
    end; }
    result:=cmd_ok;
  end;

initialization
  CreateCommandFastObjectPlugin(@TemplateForVeb_com,'Trrree',CADWG,0);
  CreateCommandFastObjectPlugin(@NumLengthOtherCable_com,'test111',CADWG,0);
end.
